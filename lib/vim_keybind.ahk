#Requires AutoHotkey v2.0
#include delete_key.ahk
#include ime.ahk

; 2025-07-06
; キー入力抜けが発生するのでlayer変更中は他のキー入力を無視するほうを使用するため未使用

; 特定操作中にvim keybindによる方向キー操作を許可する

; 案2
vk1C & h:: Send "{Blind}{Left}"
vk1C & j:: Send "{Blind}{Down}"
vk1C & k:: Send "{Blind}{Up}"
vk1C & l:: Send "{Blind}{Right}"

vk1D & Space:: Send "{Blind}{vk1C}"
vk1C & N:: Send "{Blind}{Home}"
vk1C & M:: Send "{Blind}{PgDn}"
vk1C & ,:: Send "{Blind}{PgUp}}"
vk1C & .:: Send "{Blind}{End}"

vk1C & vkBB:: Send "{Bs}"
vk1C & vkBA:: Send "{Delete}"
vk1C & Space:: Send "{Enter}"
vk1D & e:: Send "{Esc}"

; vk1D::IME_SET(0)
; vk1C::IME_SET(1)

vk1D::vk1D
vk1C::vk1C

vk1D & c:: Send "^c"
vk1D & x:: Send "^x"
vk1D & v:: Send "^v"
vk1D & s:: Send "^s"
vk1D & z:: Send "^z"
vk1D & y:: Send "^+z"
vk1D & f:: Send "^f"
vk1D & a:: Send "^a"

; vk1C & h::{
;     BlockInput true
;     SendEvent("{Blind}{Left}")
;     BlockInput false
; }
; vk1C & j::{
;     BlockInput true
;     SendEvent("{Blind}{Down}")
;     BlockInput false
; }
; vk1C & k::{
;     BlockInput true
;     SendEvent("{Blind}{Up}")
;     BlockInput false
; }
; vk1C & l::{
;     BlockInput true
;     SendEvent("{Blind}{Right}")
;     BlockInput false
; }

!Tab::
{
    Send "{Blind}!{Tab}"
    Sleep 150
    while (GetKeyState("Alt", "P")) {
        if (GetKeyState("h", "P")) {
            Send "{Blind}{Left}"
            Sleep 150
        } else if (GetKeyState("j", "P")) {
            Send "{Blind}{Down}"
            Sleep 150
        } else if (GetKeyState("k", "P")) {
            Send "{Blind}{Up}"
            Sleep 150
        } else if (GetKeyState("l", "P")) {
            Send "{Blind}{Right}"
            Sleep 150
        } else if (GetKeyState("Tab", "P")) {
            if (GetKeyState("Shift", "P")) {
                ; shift込の場合は勝手に押したことになる
                ; Send "{Blind}+{Tab}"
                Sleep 150
            } else {
                Send "{Blind}{Tab}"
                Sleep 150
            }
        }
    }
}
