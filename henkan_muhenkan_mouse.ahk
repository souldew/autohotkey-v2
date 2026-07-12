#Requires AutoHotkey v2.0

; ============================================================
; 両手マウス: 変換(vk1C) + 無変換(vk1D) を同時押ししている間だけマウス操作
; ============================================================
; 両方のキーを押している間だけ以下でマウスを操作し、どちらかを離すと即終了する。
;   移動      : I上 / J左 / K下 / L右
;   クリック  : F左 / D右 / S中
;   スクロール: E上 / C下
;   加速      : Ctrl        減速: Shift
;
; 仕組み:
;  ・#HotIf「両方が物理的に押されている」の間だけ、マウス用キーの
;    hotkey 変種が有効になり、既存の combo (henkan_layer / muhenkan_layer /
;    mouse.ahk) を上書きして消費する。両方を離すと通常動作に戻る。
;  ・実際の移動・クリック・スクロールは BothMouse_Start() の
;    ポーリングループが物理キー状態を見て行う。
;  ・押す順序に依存しないよう GetKeyState で両押しを判定する。
;
; NOTE: mouse.ahk と併用可。vk1C / vk1D は既存レイヤーがプレフィックスとして
;       使うため、ここでは vk1C::/vk1D:: 単体は宣言しない。

BM := { active: false, btn: Map() }

; --- 両押し中だけ有効: マウス用キーが既存 combo を上書き & ループ起動 ---
#HotIf (GetKeyState("vk1C", "P") && GetKeyState("vk1D", "P"))
vk1C & i:: BothMouse_Start()
vk1D & i:: BothMouse_Start()
vk1C & j:: BothMouse_Start()
vk1D & j:: BothMouse_Start()
vk1C & k:: BothMouse_Start()
vk1D & k:: BothMouse_Start()
vk1C & l:: BothMouse_Start()
vk1D & l:: BothMouse_Start()
vk1C & f:: BothMouse_Start()
vk1D & f:: BothMouse_Start()
vk1C & d:: BothMouse_Start()
vk1D & d:: BothMouse_Start()
vk1C & s:: BothMouse_Start()
vk1D & s:: BothMouse_Start()
vk1C & e:: BothMouse_Start()
vk1D & e:: BothMouse_Start()
vk1C & c:: BothMouse_Start()
vk1D & c:: BothMouse_Start()
#HotIf

BothMouse_Start() {
    global BM
    if BM.active                 ; 既に起動中なら、このキー入力を消費するだけ
        return
    BM.active := true

    ; --- キー設定 ---
    keyUp      := "i"
    keyDown    := "k"
    keyLeft    := "j"
    keyRight   := "l"
    keyLB      := "f"            ; 左クリック
    keyRB      := "d"            ; 右クリック
    keyMB      := "s"            ; 中クリック
    keyScrollU := "e"            ; 上スクロール
    keyScrollD := "c"            ; 下スクロール

    defaultSpeed := 16           ; 規定のカーソル移動速度
    accelVol     := 32           ; Ctrl 加速時の増加量
    slowVol      := 5            ; Shift 減速時の速度
    moveRatio    := 1            ; 縦横移動量倍率

    CoordMode "Mouse", "Client"
    BM.btn := Map("Left", false, "Right", false, "Middle", false)

    ; --- メインループ (両方を押している間だけ) ---
    while (GetKeyState("vk1C", "P") && GetKeyState("vk1D", "P")) {
        ; 速度
        speed := defaultSpeed
        if GetKeyState("Ctrl", "P")
            speed += accelVol
        if GetKeyState("Shift", "P")
            speed := slowVol

        ; 移動
        moveX := 0, moveY := 0
        if GetKeyState(keyUp, "P")
            moveY -= speed
        if GetKeyState(keyDown, "P")
            moveY += speed
        if GetKeyState(keyLeft, "P")
            moveX -= speed * moveRatio
        if GetKeyState(keyRight, "P")
            moveX += speed * moveRatio
        MouseMove moveX, moveY, 0, "R"

        ; クリック (押下/解放をエッジ検出)
        BothMouse_Button(keyLB, "Left")
        BothMouse_Button(keyRB, "Right")
        BothMouse_Button(keyMB, "Middle")

        ; スクロール
        BothMouse_Scroll(keyScrollU, "{WheelUp}")
        BothMouse_Scroll(keyScrollD, "{WheelDown}")

        Sleep 10
    }

    ; --- 終了処理 ---
    for b, down in BM.btn {      ; 押しっぱなしのボタンを解放
        if down
            MouseClick b, , , , , "U"
    }
    BM.active := false
}

; ボタンの押下状態を見て、変化した瞬間だけ Down / Up を送る
BothMouse_Button(key, btn) {
    global BM
    if GetKeyState(key, "P") {
        if !BM.btn[btn] {
            MouseClick btn, , , , , "D"
            BM.btn[btn] := true
            Sleep 150             ; 押下時に一瞬止める
        }
    } else if BM.btn[btn] {
        MouseClick btn, , , , , "U"
        BM.btn[btn] := false
    }
}

; スクロールキーが押されている間、ホイールを送り続ける
BothMouse_Scroll(key, wheel) {
    global BM
    while (BM.active && GetKeyState(key, "P") && GetKeyState("vk1C", "P") && GetKeyState("vk1D", "P")) {
        Send "{Blind}" wheel
        Sleep 80
    }
}
