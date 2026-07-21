#Requires AutoHotkey v2.0
ProcessSetPriority "High"

; キーボードマウスはホットキーを高速連発するため、暴走検知ダイアログを抑止する
; (既定: 70回/2000ms を超えると確認ダイアログが出る)
A_MaxHotkeysPerInterval := 1000

; #include lib/disable_keys_enable_henkan_layer.ahk
; #include lib/disable_keys_enable_muhenkan_layer.ahk

#include lib/henkan_layer.ahk
; #include lib/muhenkan_layer.ahk
; #include lib/space_layer.ahk
; #include lib/vscode.ahk

; #include mouse/mouse.ahk
#Include muhenkan_mouse.ahk

; テストコマンド用
; ^q:: {

; }
