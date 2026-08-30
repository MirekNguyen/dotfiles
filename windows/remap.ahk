; Capslock::Esc
; ; Swap Left Alt and Left Windows
; LAlt::LWin
; LWin::LAlt
;
; ; Swap Right Alt and Right Windows
; RAlt::RWin
; RWin::RAlt
;
; !l::SendInput ^l
; !r::SendInput ^r
; !t::SendInput ^t
; !w::SendInput ^w
; !a::SendInput ^a

#NoEnv
#SingleInstance Force
#UseHook ; Forces low-level interception for faster response times
#MenuMaskKey vkE8 ; Natively blocks Start Menu without race conditions

; ---------------------------------------------------------
; 1. SYSTEM FIXES
; ---------------------------------------------------------
; Map Caps Lock to Escape
Capslock::Esc

; Disable Windows key behavior
~LWin::Send {Blind}{vkE8}

; ---------------------------------------------------------
; 2. APP SWITCHING
; ---------------------------------------------------------
; Map Left Cmd + Tab to Alt + Tab (Switch open applications)
LWin & Tab::AltTab

; ---------------------------------------------------------
; 3. GENERAL ESSENTIALS (Cmd -> Ctrl)
; ---------------------------------------------------------
<#c::SendInput ^c  ; Copy
<#v::SendInput ^v  ; Paste
<#x::SendInput ^x  ; Cut
<#z::SendInput ^z  ; Undo
<#y::SendInput ^y  ; Redo
<#s::SendInput ^s  ; Save
<#f::SendInput ^f  ; Find
<#a::SendInput ^a  ; Select All
<#n::SendInput ^n  ; New File/Window
<#o::SendInput ^o  ; Open File
<#p::SendInput ^p  ; Print / Command Palette (VS Code/Terminal)

; ---------------------------------------------------------
; 4. BROWSER & TAB MANAGEMENT (Zen Browser / IDEs)
; ---------------------------------------------------------
<#t::SendInput ^t        ; New Tab
<#w::SendInput ^w        ; Close Tab
<#r::SendInput ^r        ; Refresh
<#l::SendInput ^l        ; Focus Address Bar
<#j::SendInput ^j        ; Downloads
<#+t::SendInput ^+t      ; Reopen Closed Tab (Cmd + Shift + T)

; History Navigation (Cmd + [ and Cmd + ])
<#[::SendInput !{Left}   ; Go Back (Translates to Alt + Left)
<#]::SendInput !{Right}  ; Go Forward (Translates to Alt + Right)

; Tab Switching (Cmd + Shift + [ and Cmd + Shift + ])
<#+[::SendInput ^+{Tab}  ; Previous Tab
<#+]::SendInput ^{Tab}   ; Next Tab

; Alternative Tab Switching (Cmd + Option + Left/Right)
; Mac users often use this combination for tabs as well
<#<!Left::SendInput ^+{Tab}  ; Previous Tab
<#<!Right::SendInput ^{Tab}  ; Next Tab

; Jump to specific tabs (Cmd + 1 through 9)
<#1::SendInput ^1
<#2::SendInput ^2
<#3::SendInput ^3
<#4::SendInput ^4
<#5::SendInput ^5
<#6::SendInput ^6
<#7::SendInput ^7
<#8::SendInput ^8
<#9::SendInput ^9

; ---------------------------------------------------------
; 5. TEXT EDITING & TERMINAL NAVIGATION
; ---------------------------------------------------------
; CMD + Arrows (Mac behavior: Jump to start/end of line or document)
<#Left::SendInput {Home}       ; Jump to start of line
<#Right::SendInput {End}       ; Jump to end of line
<#Up::SendInput ^{Home}        ; Jump to top of document
<#Down::SendInput ^{End}       ; Jump to bottom of document

; CMD + Shift + Arrows (Mac behavior: Select text to start/end of line)
<#+Left::SendInput +{Home}
<#+Right::SendInput +{End}
<#+Up::SendInput ^+{Home}
<#+Down::SendInput ^+{End}

; OPTION + Arrows (Mac behavior: Jump word by word)
; Note: In NuPhy Mac mode, your physical Option key sends Left Alt (<!).
<!Left::SendInput ^{Left}      ; Jump one word left
<!Right::SendInput ^{Right}    ; Jump one word right
<!+Left::SendInput ^+{Left}    ; Select one word left
<!+Right::SendInput ^+{Right}  ; Select one word right

; Backspace behavior
<#Backspace::SendInput +{Home}{Backspace}  ; Cmd + Backspace deletes entire line to the left
<!Backspace::SendInput ^{Backspace}        ; Option + Backspace deletes one word to the left

; ---------------------------------------------------------
; 6. WINDOW MANAGEMENT (The Missing Pieces)
; ---------------------------------------------------------
; Quit Application (Cmd + Q translates to Alt + F4)
<#q::SendInput !{F4}

; Minimize Window (Cmd + M minimizes the active window)
<#m::WinMinimize, A

; Hide Window (Cmd + H minimizes the active window, similar to Mac's Hide)
<#h::WinMinimize, A

; ---------------------------------------------------------
; 7. EMERGENCY MODIFIER RESET
; ---------------------------------------------------------
; Press Ctrl + Win + Alt + Shift + R to force-release all modifiers
^#+!r::SendInput {LWin Up}{RWin Up}{LAlt Up}{RAlt Up}{LCtrl Up}{RCtrl Up}{LShift Up}{RShift Up}
