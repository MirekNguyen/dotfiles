KEYBOARD="$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep 'KeyboardLayout Name')"

if echo "$KEYBOARD" | grep -q 'Czech'; then
  sketchybar -m --set keyboard icon=􀇳  drawing=on label="CZ"
else
  sketchybar -m --set keyboard drawing=off
fi
