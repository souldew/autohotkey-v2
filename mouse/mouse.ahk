#Requires AutoHotkey v2.0

; ホバーしているウインドウのタブを切り替える
RButton & WheelDown:: TabSwitch("next")
RButton & WheelUp:: TabSwitch("prev")

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

RButton::RButton
XButton2::XButton2

; Alt+Tabの状態を管理する変数
altTabActive := false
wheelUsed := false

XButton1::
{
    global wheelUsed
    wheelUsed := false

    ; XButton1が離されるまで待機
    KeyWait "XButton1"

    ; ホイールが使われなかった場合は戻る機能
    if (!wheelUsed) {
        Send "{XButton1}"
    }
}

XButton1 & WheelDown::
{
    global altTabActive, wheelUsed
    wheelUsed := true

    if (!altTabActive) {
        Send "{Alt Down}"
        altTabActive := true
        SetTimer(() => CheckXButton1Release(), 10)
    }

    Send "{Tab}"
}

XButton1 & WheelUp::
{
    global altTabActive, wheelUsed
    wheelUsed := true

    if (!altTabActive) {
        Send "{Alt Down}"
        altTabActive := true
        SetTimer(() => CheckXButton1Release(), 10)
    }

    Send "+{Tab}"
}

CheckXButton1Release() {
    global altTabActive
    if (!GetKeyState("XButton1", "P")) {
        Send "{Alt Up}"
        altTabActive := false
        SetTimer(CheckXButton1Release, 0)
    }
}
