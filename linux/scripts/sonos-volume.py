#!/usr/bin/env python3
"""Volume keys that follow the audio to where it actually ends up.
Usage: sonos-volume.py up|down|mute|status|watch
"""

import json
import os
import re
import socket
import subprocess
import sys
import urllib.request

STEP = 2  # Sonos volume is 0-100; the Beam is loud, so small steps
MAX_VOLUME = 60  # guard against holding the key down into ear-splitting
SONOS_SINK = "Burr-Brown"  # substring of the UCA202's PipeWire node name
ROOM = os.environ.get("SONOS_ROOM", "")  # optional: pin a room if you add speakers
CACHE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "sonos-ip")
RC = "urn:schemas-upnp-org:service:RenderingControl:1"
WATCH_PID = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "sonos-volume-watch.pid")


def default_sink() -> str:
    out = subprocess.run(
        ["wpctl", "inspect", "@DEFAULT_AUDIO_SINK@"], capture_output=True, text=True
    ).stdout
    m = re.search(r'node\.name = "([^"]*)"', out)
    return m.group(1) if m else ""


def default_sink_description() -> str:
    out = subprocess.run(
        ["wpctl", "inspect", "@DEFAULT_AUDIO_SINK@"], capture_output=True, text=True
    ).stdout
    m = re.search(r'node\.(?:nick|description) = "([^"]*)"', out)
    return m.group(1) if m else default_sink()


def sonos_playing() -> bool:
    # Apps can be routed to the UCA202 without it being the default (Sunshine
    # likes to grab the default), so "audio is flowing into it" counts too.
    out = subprocess.run(
        ["pactl", "list", "sinks", "short"], capture_output=True, text=True
    ).stdout
    return any(
        SONOS_SINK in line and "RUNNING" in line for line in out.splitlines()
    )


def wpctl(action: str) -> None:
    cmd = {
        "up": ["wpctl", "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", "5%+"],
        "down": ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"],
        "mute": ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"],
    }[action]
    subprocess.run(cmd)


def room_name(ip: str) -> str:
    try:
        with urllib.request.urlopen(
            f"http://{ip}:1400/xml/device_description.xml", timeout=2
        ) as r:
            m = re.search(rb"<roomName>([^<]*)", r.read())
            return m.group(1).decode() if m else ""
    except OSError:
        return ""


def discover() -> str | None:
    msg = (
        "M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\n"
        'MAN: "ssdp:discover"\r\nMX: 1\r\n'
        "ST: urn:schemas-upnp-org:device:ZonePlayer:1\r\n\r\n"
    ).encode()
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(2)
    s.sendto(msg, ("239.255.255.250", 1900))
    try:
        while True:
            _, (ip, _) = s.recvfrom(4096)
            if not ROOM or room_name(ip) == ROOM:
                return ip
    except OSError:
        return None


def soap(ip: str, action: str, args: str) -> str:
    body = (
        '<?xml version="1.0"?><s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"'
        ' s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><s:Body>'
        f'<u:{action} xmlns:u="{RC}"><InstanceID>0</InstanceID><Channel>Master</Channel>'
        f"{args}</u:{action}></s:Body></s:Envelope>"
    ).encode()
    req = urllib.request.Request(
        f"http://{ip}:1400/MediaRenderer/RenderingControl/Control",
        data=body,
        headers={
            "Content-Type": 'text/xml; charset="utf-8"',
            "SOAPACTION": f'"{RC}#{action}"',
        },
    )
    with urllib.request.urlopen(req, timeout=2) as r:
        return r.read().decode()


def field(xml: str, tag: str) -> int:
    return int(re.search(rf"<{tag}>(\d+)</{tag}>", xml).group(1))


def sonos(ip: str, action: str) -> tuple[int, bool]:
    """Apply action ("status" is a no-op) and return (volume, muted)."""
    vol = field(soap(ip, "GetVolume", ""), "CurrentVolume")
    muted = bool(field(soap(ip, "GetMute", ""), "CurrentMute"))
    if action == "mute":
        muted = not muted
        soap(ip, "SetMute", f"<DesiredMute>{int(muted)}</DesiredMute>")
    elif action in ("up", "down"):
        vol = min(vol + STEP, MAX_VOLUME) if action == "up" else max(vol - STEP, 0)
        soap(ip, "SetVolume", f"<DesiredVolume>{vol}</DesiredVolume>")
        if action == "up" and muted:  # raising should unmute, like a real remote
            muted = False
            soap(ip, "SetMute", "<DesiredMute>0</DesiredMute>")
    return vol, muted


def with_speaker(action: str) -> tuple[int, bool] | None:
    ip = open(CACHE).read().strip() if os.path.exists(CACHE) else None
    for attempt in (ip, "rediscover"):
        if attempt == "rediscover":
            ip = discover()
            if not ip:
                break
            with open(CACHE, "w") as f:
                f.write(ip)
        if not ip:
            continue
        try:
            return sonos(ip, action)
        except (OSError, AttributeError):
            continue
    return None


def pipewire_state() -> tuple[int, bool]:
    out = subprocess.run(
        ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"], capture_output=True, text=True
    ).stdout
    m = re.search(r"([\d.]+)", out)
    return round(float(m.group(1)) * 100) if m else 0, "MUTED" in out


def waybar(vol: int | None, muted: bool, target: str) -> None:
    """One line of JSON for waybar's custom module (return-type: json)."""
    if vol is None:
        text, cls = "󰖁  --", "unreachable"
    elif muted:
        text, cls = "󰝟  muted", "muted"
    else:
        icon = "󰕿" if vol < 34 else "󰖀" if vol < 67 else "󰕾"
        text, cls = f"{icon}  {vol}%", ""
    print(json.dumps({"text": text, "tooltip": target, "class": cls}, ensure_ascii=False), flush=True)


def on_sonos() -> bool:
    return SONOS_SINK in default_sink() or sonos_playing()


def status() -> None:
    if on_sonos():
        waybar(*(with_speaker("status") or (None, False)), "Sonos Beam")
    else:
        waybar(*pipewire_state(), default_sink_description())


def watch() -> None:
    """Long-running feed for waybar: reprint whenever something changes.

    PipeWire changes (switching output, plugging a device in, starting or
    stopping playback, wpctl volume) arrive as `pactl subscribe` events. The
    Sonos can't push to us, so it is re-read every POLL seconds to pick up
    changes from the Sonos app or its remote; the keys poke us with SIGUSR1 so
    they show up at once instead of on the next poll.
    """
    import select
    import signal
    import time

    POLL = 5
    with open(WATCH_PID, "w") as f:
        f.write(str(os.getpid()))
    wake_r, wake_w = os.pipe()
    signal.signal(signal.SIGUSR1, lambda *_: os.write(wake_w, b"x"))
    events = subprocess.Popen(
        ["pactl", "subscribe"], stdout=subprocess.PIPE, text=True, bufsize=1
    )
    last = ""
    next_poll = 0.0
    while True:
        timeout = max(0.0, next_poll - time.monotonic())
        ready, _, _ = select.select([events.stdout, wake_r], [], [], timeout)
        if events.stdout in ready:
            line = events.stdout.readline()
            if not line:  # pactl died (PipeWire restart); waybar will restart us
                return
            if not re.search(r"'(change|new|remove)' on (sink|server)", line):
                continue
            time.sleep(0.05)  # events come in bursts; let them settle
        if wake_r in ready:
            os.read(wake_r, 64)
        out = io_status()
        if out != last:
            print(out, flush=True)
            last = out
        next_poll = time.monotonic() + POLL


def io_status() -> str:
    import contextlib
    import io

    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        status()
    return buf.getvalue().strip()


def poke_watcher() -> None:
    try:
        os.kill(int(open(WATCH_PID).read()), 10)  # SIGUSR1
    except (OSError, ValueError):
        pass


def main() -> int:
    action = sys.argv[1] if len(sys.argv) > 1 else ""
    if action not in ("up", "down", "mute", "status", "watch"):
        print(__doc__.strip().splitlines()[2], file=sys.stderr)
        return 2

    if action == "status":
        status()
        return 0
    if action == "watch":
        watch()
        return 0

    if on_sonos():
        ok = with_speaker(action) is not None
    else:
        wpctl(action)
        ok = True
    poke_watcher()
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
