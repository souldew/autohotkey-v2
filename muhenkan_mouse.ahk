#Requires AutoHotkey v2.0

; ============================================================
; 無変換マウス: 無変換(vk1D) を押している間だけマウス操作
; ============================================================
; mouse.ahk の keybd_mouse と同じ挙動。違いは起動方法のみ:
;   keybd_mouse … 無変換 + / でトグル、/ で終了
;   このファイル … 無変換を押している間だけ有効 (離すと終了)
;
; キー配置・速度・加速/減速・スクロールは keybd_mouse と同一。
;   移動      : E上 / D下 / S左 / F右
;   クリック  : H左 / I右 / U中
;   スクロール: K上 / J下
;   加速      : ; (vkBB)     減速: L
;
; 仕組み:
;  ・無変換 + 割当キーを押すとポーリングループが起動し、無変換を
;    押している間だけ物理キー状態を見て移動・クリック・スクロールする。
;  ・割当キーは vk1D & X の combo として定義するため、無変換押下中は
;    そのキーの文字入力は消費される (keybd_mouse の DisableKeys 相当)。
;
; NOTE: このファイルは muhenkan_layer.ahk の代わりに読み込む前提。
;       ^c/^s/^f 等の無変換ショートカットは無効化される（併用しない）。
;       同じ理由で vk1D::vk1D もここで宣言する（重複宣言に注意）。

vk1D::vk1D

; モードの状態
MM := { active: false, btn: Map() }

; 無変換 + 割当キーでマウスモード起動 (無変換を押している間だけ)
vk1D & e::    MuhenkanMouse_Start()   ; 移動 上
vk1D & d::    MuhenkanMouse_Start()   ; 移動 下
vk1D & s::    MuhenkanMouse_Start()   ; 移動 左
vk1D & f::    MuhenkanMouse_Start()   ; 移動 右
vk1D & h::    MuhenkanMouse_Start()   ; 左クリック
vk1D & i::    MuhenkanMouse_Start()   ; 右クリック
vk1D & u::    MuhenkanMouse_Start()   ; 中クリック
vk1D & k::    MuhenkanMouse_Start()   ; 上スクロール
vk1D & j::    MuhenkanMouse_Start()   ; 下スクロール
vk1D & vkBB:: MuhenkanMouse_Start()   ; 加速 (;)
vk1D & l::    MuhenkanMouse_Start()   ; 減速

MuhenkanMouse_Start() {
    global MM

    if MM.active                      ; 既に起動中なら、このキー入力を消費するだけ
        return
    MM.active := true

    ; --- キー設定 ---
    keyUp      := "e"
    keyDown    := "d"
    keyLeft    := "s"
    keyRight   := "f"
    keyLB      := "h"                 ; 左クリック
    keyRB      := "i"                 ; 右クリック
    keyMB      := "u"                 ; 中クリック
    keyScrollU := "k"                 ; 上スクロール
    keyScrollD := "j"                 ; 下スクロール
    accelKey   := "vkBB"              ; 加速 (;)
    decelKey   := "l"                 ; 減速

    ; 低:5 中:24 高:64
    defaultSpeed := 12                ; 規定のカーソル移動速度
    accelVol     := 24                ; 加速時の増加量
    slowVol      := 5                 ; 減速時の速度
    moveRatio    := 1                 ; 縦横移動量倍率

    ; --- 開始処理 ---
    CoordMode "Mouse", "Client"
    MM.btn := Map("Left", false, "Right", false, "Middle", false)

    ; --- メインループ (無変換を押している間だけ) ---
    while GetKeyState("vk1D", "P") {
        ; 速度
        speed := defaultSpeed
        if GetKeyState(accelKey, "P")
            speed += accelVol
        if GetKeyState(decelKey, "P")
            speed := slowVol

        ; 移動
        moveX := 0, moveY := 0
        if GetKeyState(keyUp, "P")
            moveY += speed
        if GetKeyState(keyDown, "P")
            moveY -= speed
        if GetKeyState(keyLeft, "P")
            moveX -= speed * moveRatio
        if GetKeyState(keyRight, "P")
            moveX += speed * moveRatio
        MouseMove moveX, -moveY, 0, "R"

        ; クリック (押下/解放をエッジ検出)
        MuhenkanMouse_Button(keyLB, "Left")
        MuhenkanMouse_Button(keyRB, "Right")
        MuhenkanMouse_Button(keyMB, "Middle")

        ; スクロール
        MuhenkanMouse_Scroll(keyScrollU, "{WheelUp}", accelKey, decelKey, accelVol)
        MuhenkanMouse_Scroll(keyScrollD, "{WheelDown}", accelKey, decelKey, accelVol)

        Sleep 10
    }

    ; --- 終了処理 ---
    for btn, down in MM.btn {         ; 押しっぱなしのボタンを解放
        if down
            MouseClick btn, , , , , "U"
    }
    MM.active := false
}

; ボタンの押下状態を見て、変化した瞬間だけ Down / Up を送る
MuhenkanMouse_Button(key, btn) {
    global MM
    if GetKeyState(key, "P") {
        if !MM.btn[btn] {
            MouseClick btn, , , , , "D"
            MM.btn[btn] := true
            Sleep 150                 ; 押下時に一瞬止める
        }
    } else if MM.btn[btn] {
        MouseClick btn, , , , , "U"
        MM.btn[btn] := false
    }
}

; スクロールキーが押されている間、ホイールを送り続ける
MuhenkanMouse_Scroll(key, wheel, accelKey, decelKey, accelVol) {
    global MM
    while MM.active && GetKeyState("vk1D", "P") && GetKeyState(key, "P") {
        Send "{Blind}" wheel
        wait := 100
        if GetKeyState(accelKey, "P")
            wait -= accelVol * 5
        if GetKeyState(decelKey, "P")
            wait := 200
        Sleep Max(wait, 10)
    }
}
