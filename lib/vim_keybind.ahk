#Requires AutoHotkey v2.0
#include delete_key.ahk
#include ime.ahk

; 特定操作中にvim keybindによる方向キー操作を許可する

; ; 案1
; g_vim_keybind_flg := false

; vk1C & h::run_vim_key_bind("{Blind}{Left}")
; vk1C & j::run_vim_key_bind("{Blind}{Down}")
; vk1C & k::run_vim_key_bind("{Blind}{Up}")
; vk1C & l::run_vim_key_bind("{Blind}{Right}")

; run_vim_key_bind(key){
;     Send(key)
;     global g_vim_keybind_flg
;     func_disable()
;     while (GetKeyState("vk1C", "P")) {
;         g_vim_keybind_flg := true
;     }
;     g_vim_keybind_flg := false
;     func_enable()
; }

; #HotIf g_vim_keybind_flg
; vk1C & h::Send("{Blind}{Left}")
; vk1C & j::Send("{Blind}{Down}")
; vk1C & k::Send("{Blind}{Up}")
; vk1C & l::Send("{Blind}{Right}")
; ; d & h::Send("{Blind}^{Left}")
; #HotIf

; 案2
vk1C & h:: SendEvent("{Blind}{Left}")
vk1C & j:: SendEvent("{Blind}{Down}")
vk1C & k:: SendEvent("{Blind}{Up}")
vk1C & l:: SendEvent("{Blind}{Right}")

vk1D & Space:: SendEvent("{Blind}{vk1C}")
vk1C & N:: SendEvent("{Blind}{Home}")
vk1C & M:: SendEvent("{Blind}{PgDn}")
vk1C & ,:: SendEvent("{Blind}{PgUp}}")
vk1C & .:: SendEvent("{Blind}{End}")

vk1C & vkBB:: SendEvent("{Bs}")
vk1C & vkBA:: SendEvent("{Delete}")
vk1C & Space:: SendEvent("{Enter}")
vk1D & e:: SendEvent("{Esc}")

; vk1D::IME_SET(0)
; vk1C::IME_SET(1)

vk1D::vk1D
vk1C::vk1C

vk1D & c:: SendEvent("^c")
vk1D & x:: SendEvent("^x")
vk1D & v:: SendEvent("^v")
vk1D & s:: SendEvent("^s")
vk1D & z:: SendEvent("^z")
vk1D & y:: SendEvent("^+z")
vk1D & f:: SendEvent("^f")
vk1D & a:: SendEvent("^a")

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
