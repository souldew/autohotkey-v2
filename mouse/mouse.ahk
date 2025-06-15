#Requires AutoHotkey v2.0

; ホバーしているウインドウのタブを切り替える
XButton1 & WheelDown:: TabSwitch("next")
XButton1 & WheelUp:: TabSwitch("prev")

TabSwitch(direction) {
    ; マウス位置とウィンドウを取得
    CoordMode "Mouse", "Screen"
    MouseGetPos &mouseX, &mouseY, &winId

    ; マウス下のウィンドウをアクティブ化
    if !WinActive("ahk_id " winId)
        WinActivate "ahk_id " winId

    ; タブ切り替え
    if (direction == "next")
        Send "^{Tab}"
    else
        Send "^+{Tab}"
}
