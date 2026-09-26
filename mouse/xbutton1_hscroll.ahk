#Requires AutoHotkey v2.0

; ============================================================
; 戻るボタン(XButton1) + ホイールで横スクロール
; ============================================================
;   XButton1 + WheelDown … 右スクロール
;   XButton1 + WheelUp   … 左スクロール
;   XButton1 単押し      … 通常の「戻る」
;
; 仕組み:
;   XButton1 & WheelDown のような combo を定義すると XButton1 は prefix key に
;   なり、単押しの「戻る」が発火しなくなる。そのため XButton1:: 側で離されるのを
;   待ち、ホイールが使われなかった場合だけ本来の XButton1 を送り直す。

hscrollUsed := false

XButton1:: {
    global hscrollUsed
    hscrollUsed := false
    KeyWait "XButton1"
    if !hscrollUsed
        Send "{XButton1}"
}

XButton1 & WheelDown:: {
    global hscrollUsed
    hscrollUsed := true
    Send "{WheelRight}"
}

XButton1 & WheelUp:: {
    global hscrollUsed
    hscrollUsed := true
    Send "{WheelLeft}"
}
