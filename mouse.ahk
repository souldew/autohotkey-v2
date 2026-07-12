#Requires AutoHotkey v2.0

; ============================================================
; マウス操作レイヤー (無変換 vk1D を使う)
; ============================================================
; 1. 右手十字マウス   : 無変換 + I/J/K/L でカーソル移動、W/Q でクリック
; 2. キーボードマウス : 無変換 + / でトグル起動する片手マウスモード
;
; NOTE: 無変換単押しの動作 (vk1D::vk1D) はここでは宣言しない。
;       main.ahk 経由で muhenkan_layer.ahk と併用しても衝突しないようにするため。
;       単体で使う場合も vk1D は自動的にプレフィックスキーとして機能する。

; ------------------------------------------------------------
; 1. 右手十字マウス
; ------------------------------------------------------------
; 無変換を押している間、I/J/K/L でカーソルを動かす。
; Ctrl で加速、Shift で減速。
vk1D & i::
vk1D & j::
vk1D & k::
vk1D & l::
{
    CoordMode "Mouse", "Client"
    while GetKeyState("vk1D", "P") {          ; 無変換が押され続けている間ループ
        moveX := 0, moveY := 0
        moveY += GetKeyState("i", "P") ? -24 : 0
        moveX += GetKeyState("j", "P") ? -24 : 0
        moveY += GetKeyState("k", "P") ? 24 : 0
        moveX += GetKeyState("l", "P") ? 24 : 0
        if GetKeyState("Ctrl", "P") {         ; 加速 (64/24 倍)
            moveX *= 64 / 24
            moveY *= 64 / 24
        }
        if GetKeyState("Shift", "P") {        ; 減速 (5/24 倍)
            moveX *= 5 / 24
            moveY *= 5 / 24
        }
        MouseMove moveX, moveY, 0, "R"
        Sleep 0
    }
}

; クリック (押しっぱなしに対応するため Down/Up を分ける)
vk1D & w:: MouseClick "Right", , , , , "D"
vk1D & w Up:: MouseClick "Right", , , , , "U"
vk1D & q:: MouseClick "Left", , , , , "D"
vk1D & q Up:: MouseClick "Left", , , , , "U"

; ------------------------------------------------------------
; 2. キーボードマウス (無変換 + / でトグル起動)
; ------------------------------------------------------------
; 起動中は KM_KEYS_ALL のキーを無効化し、以下のキーでマウスを操作する。
;   移動     : E上 / D下 / S左 / F右
;   クリック : H左 / I右 / U中
;   スクロール: K上 / J下
;   加速     : ; (vkBB)     減速: L
;   終了     : /

; 起動中に無効化するキー一覧
KM_KEYS_ALL :=
    "0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,@,/,vkBB,vkBA,vkBC,Space,Tab,Enter,Backspace,vkF3,vkF4,vkF2,vkF0"

; モードの状態
KM := { active: false, btn: Map() }

vk1D & /:: KeybdMouse_Start()

KeybdMouse_Start() {
    global KM

    if KM.active                      ; 二重起動防止
        return
    KM.active := true

    ; --- キー設定 ---
    exitKey := "/"                 ; 終了
    keyUp := "e"
    keyDown := "d"
    keyLeft := "s"
    keyRight := "f"
    keyLB := "h"                 ; 左クリック
    keyRB := "i"                 ; 右クリック
    keyMB := "u"                 ; 中クリック
    keyScrollU := "k"                 ; 上スクロール
    keyScrollD := "j"                 ; 下スクロール
    accelKey := "vkBB"              ; 加速 (;)
    decelKey := "l"                 ; 減速

    ; 低:5 中:24 高:64
    defaultSpeed := 12                ; 規定のカーソル移動速度
    accelVol := 24                ; 加速時の増加量
    slowVol := 5                 ; 減速時の速度
    moveRatio := 1                 ; 縦横移動量倍率

    ; --- 開始処理 ---
    KeybdMouse_DisableKeys(true)      ; 通常入力を無効化
    Hotkey exitKey, KeybdMouse_Stop, "On"
    KM.btn := Map("Left", false, "Right", false, "Middle", false)

    ; --- メインループ ---
    while KM.active {
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
        KeybdMouse_Button(keyLB, "Left")
        KeybdMouse_Button(keyRB, "Right")
        KeybdMouse_Button(keyMB, "Middle")

        ; スクロール
        KeybdMouse_Scroll(keyScrollU, "{WheelUp}", accelKey, decelKey, accelVol)
        KeybdMouse_Scroll(keyScrollD, "{WheelDown}", accelKey, decelKey, accelVol)

        Sleep 10
    }

    ; --- 終了処理 ---
    for btn, down in KM.btn {         ; 押しっぱなしのボタンを解放
        if down
            MouseClick btn, , , , , "U"
    }
    Hotkey exitKey, KeybdMouse_Stop, "Off"
    KeybdMouse_DisableKeys(false)
}

; 終了キー(/)で呼ばれ、メインループを抜けさせる
KeybdMouse_Stop(*) {
    global KM
    KM.active := false
}

; KM_KEYS_ALL のキーを一括で無効化 / 復帰する
KeybdMouse_DisableKeys(disable) {
    global KM_KEYS_ALL
    state := disable ? "On" : "Off"
    for key in StrSplit(KM_KEYS_ALL, ",")
        try Hotkey key, KeybdMouse_Nop, state
}
KeybdMouse_Nop(*) {
}

; ボタンの押下状態を見て、変化した瞬間だけ Down / Up を送る
KeybdMouse_Button(key, btn) {
    global KM
    if GetKeyState(key, "P") {
        if !KM.btn[btn] {
            MouseClick btn, , , , , "D"
            KM.btn[btn] := true
            Sleep 150                 ; 押下時に一瞬止める
        }
    } else if KM.btn[btn] {
        MouseClick btn, , , , , "U"
        KM.btn[btn] := false
    }
}

; スクロールキーが押されている間、ホイールを送り続ける
KeybdMouse_Scroll(key, wheel, accelKey, decelKey, accelVol) {
    global KM
    while KM.active && GetKeyState(key, "P") {
        Send "{Blind}" wheel
        wait := 100
        if GetKeyState(accelKey, "P")
            wait -= accelVol * 5
        if GetKeyState(decelKey, "P")
            wait := 200
        Sleep Max(wait, 10)
    }
}
