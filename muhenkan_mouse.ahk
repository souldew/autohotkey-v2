#Requires AutoHotkey v2.0

; キーボードマウス以外の挙動
vk1D::vk1D
vk1D & w:: Send "{Blind}{Esc}"
vk1D & p:: CenterCursorOnActiveWindow()

CenterCursorOnActiveWindow() {
    hwnd := WinExist("A")
    if !hwnd
        return
    WinGetPos &x, &y, &w, &h, hwnd
    CoordMode "Mouse", "Screen"
    MouseMove x + w // 2, y + h // 2, 0
}

; ============================================================
; 無変換マウス: 無変換(vk1D) を押している間だけマウス操作
; ============================================================
; mouse.ahk の keybd_mouse がもと。起動方法と速度の決め方が違う:
;   keybd_mouse … 無変換 + / でトグル、/ で終了
;   このファイル … 無変換を押している間だけ有効 (離すと終了)
;
;   移動      : E上 / D下 / S左 / F右
;   クリック  : H左 / I右 / U中   （追加: A左 / Z右）
;   スクロール: K上 / J下         （追加: V上 / C下）
;
; 速度は Miryoku にならい、加速・減速キーを持たない。移動・スクロールのキーを押し続けた
; 時間に応じて最高速まで直線的に上がり、離すと最低速に戻る。Shift / Ctrl は修飾キーとして
; そのままクリックやホイールに効く（Ctrl+クリック、Shift+ホイールなど）。
; カーソル移動の速さは MM_MOVE_PRESET で名前付きのプリセットから選ぶ（設定は下）。
; 各プリセットの速さの比較と、採用の経緯は docs/mouse-speed-presets.md。
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

; モードの状態
MM := { active: false, btn: Map() }

; カーソル移動のプリセット
;   type "qmk"    … QMK Mouse Keys の Accelerated モード (quantum/mousekey.c の move_unit)。
;                   delta / maxSpeed / timeToMax / intervalMs / moveMax は QMK の
;                   MOUSEKEY_MOVE_DELTA / MAX_SPEED / TIME_TO_MAX / INTERVAL / MOVE_MAX と同じ意味。
;                   1 レポート = AHK の 1px として扱うので、Windows のポインター速度の設定しだいで
;                   実機の QMK とは体感が少しずれる。
;   type "linear" … ループ (Sleep 10、実際は 10〜16ms) ごとの移動量を、押し続けた時間に応じて
;                   min から max px まで rampMs かけて直線的に増やす。斜めは補正しない。
MM_MOVE_PRESET := "miryoku-max28"
MM_MOVE_PRESETS := Map(
    ; Miryoku の config.h の値そのまま (moveMax は QMK の既定値)
    "miryoku", { type: "qmk", delta: 8, maxSpeed: 6, timeToMax: 64, intervalMs: 16, moveMax: 127 },
    ; Miryoku の加速のまま、1 レポートの移動量の上限だけ下げたもの
    "miryoku-max36", { type: "qmk", delta: 8, maxSpeed: 6, timeToMax: 64, intervalMs: 16, moveMax: 36 },
    "miryoku-max28", { type: "qmk", delta: 8, maxSpeed: 6, timeToMax: 64, intervalMs: 16, moveMax: 28 },
    "linear-ramp", { type: "linear", min: 1, max: 36, rampMs: 1000 }
)

; ホイールの設定
MM_WHEEL_SLOW_MS := 100   ; 押し始めのホイール送り間隔
MM_WHEEL_FAST_MS := 25    ; 最高速のホイール送り間隔
MM_WHEEL_RAMP_MS := 1000  ; 最高速に達するまでの時間

; 無変換 + 割当キーでマウスモード起動 (無変換を押している間だけ)
vk1D & e:: MuhenkanMouse_Start()   ; 移動 上
vk1D & d:: MuhenkanMouse_Start()   ; 移動 下
vk1D & s:: MuhenkanMouse_Start()   ; 移動 左
vk1D & f:: MuhenkanMouse_Start()   ; 移動 右
vk1D & h:: MuhenkanMouse_Start()   ; 左クリック
vk1D & i:: MuhenkanMouse_Start()   ; 右クリック
vk1D & u:: MuhenkanMouse_Start()   ; 中クリック
vk1D & k:: MuhenkanMouse_Start()   ; 上スクロール
vk1D & j:: MuhenkanMouse_Start()   ; 下スクロール
vk1D & a:: MuhenkanMouse_Start()   ; 左クリック
vk1D & z:: MuhenkanMouse_Start()   ; 右クリック
vk1D & v:: MuhenkanMouse_Start()   ; 上スクロール
vk1D & c:: MuhenkanMouse_Start()   ; 下スクロール

MuhenkanMouse_Start() {
    global MM

    if MM.active                      ; 既に起動中なら、このキー入力を消費するだけ
        return
    MM.active := true

    ; --- キー設定 ---
    keyUp := "e"
    keyDown := "d"
    keyLeft := "s"
    keyRight := "f"
    keyLB := ["h", "a"]          ; 左クリック
    keyRB := ["i", "z"]          ; 右クリック
    keyMB := ["u"]               ; 中クリック
    keyScrollU := ["k", "v"]          ; 上スクロール
    keyScrollD := ["j", "c"]          ; 下スクロール

    moveRatio := 1                 ; 縦横移動量倍率
    preset := MM_MOVE_PRESETS[MM_MOVE_PRESET]

    ; --- 開始処理 ---
    CoordMode "Mouse", "Client"
    MM.btn := Map("Left", false, "Right", false, "Middle", false)
    moveStart := 0                    ; 移動キーを押し始めた時刻 (0 = 押していない)
    moveRepeat := 0                   ; 次に送るレポートの番号 (QMK の mousekey_repeat)

    ; --- メインループ (無変換を押している間だけ) ---
    while GetKeyState("vk1D", "P") {
        ; 移動
        ; type "qmk": QMK はキーを押した瞬間に repeat=0 のレポートを送り、MOUSEKEY_DELAY=0 なので
        ; 直後に repeat=1、以降 MOUSEKEY_INTERVAL ごとに repeat=2,3,... を送る。
        ; Sleep の精度は 10〜16ms と粗いので、経過時間から送るべきレポート数を出して
        ; 遅れた分はまとめて動かす。
        dirX := GetKeyState(keyRight, "P") - GetKeyState(keyLeft, "P")
        dirY := GetKeyState(keyDown, "P") - GetKeyState(keyUp, "P")
        if MuhenkanMouse_AnyDown([keyUp, keyDown, keyLeft, keyRight]) {
            if !moveStart {
                moveStart := A_TickCount
                moveRepeat := 0
            }
            moveX := 0, moveY := 0
            if preset.type = "linear" {
                speed := Round(MuhenkanMouse_Ramp(moveStart, preset.rampMs, preset.min, preset.max))
                moveX := speed * dirX, moveY := speed * dirY
            } else {
                due := (A_TickCount - moveStart) // preset.intervalMs + 1
            }
            while preset.type = "qmk" && moveRepeat <= due {
                unit := MuhenkanMouse_MoveUnit(preset, moveRepeat)
                stepX := unit * dirX, stepY := unit * dirY
                if stepX && stepY {
                    stepX := MuhenkanMouse_TimesInvSqrt2(stepX)
                    stepY := MuhenkanMouse_TimesInvSqrt2(stepY)
                }
                moveX += stepX, moveY += stepY
                moveRepeat++
            }
            if moveX || moveY
                MouseMove moveX * moveRatio, moveY, 0, "R"
        } else {
            moveStart := 0
        }

        ; クリック (押下/解放をエッジ検出)
        MuhenkanMouse_Button(keyLB, "Left")
        MuhenkanMouse_Button(keyRB, "Right")
        MuhenkanMouse_Button(keyMB, "Middle")

        ; スクロール
        MuhenkanMouse_Scroll(keyScrollU, "{WheelUp}")
        MuhenkanMouse_Scroll(keyScrollD, "{WheelDown}")

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
; NOTE: 以前はここで Sleep 150 していたが、その間に素早い2連打(離す→再押下)が
;       握りつぶされ、ダブルクリックが1回の長押しになってしまうため削除。
;       Sleep を挟まないことで、2連打が確実に2クリック → Windows が
;       ダブルクリックとして認識する。ドラッグ(押しながら移動)も可能。
MuhenkanMouse_Button(keys, btn) {
    global MM
    if MuhenkanMouse_AnyDown(keys) {
        if !MM.btn[btn] {
            MouseClick btn, , , , , "D"
            MM.btn[btn] := true
        }
    } else if MM.btn[btn] {
        MouseClick btn, , , , , "U"
        MM.btn[btn] := false
    }
}

; スクロールキーが押されている間、ホイールを送り続ける (押し続けるほど間隔が短くなる)
MuhenkanMouse_Scroll(keys, wheel) {
    global MM
    start := A_TickCount
    while MM.active && GetKeyState("vk1D", "P") && MuhenkanMouse_AnyDown(keys) {
        Send "{Blind}" wheel
        Sleep Round(MuhenkanMouse_Ramp(start, MM_WHEEL_RAMP_MS, MM_WHEEL_SLOW_MS, MM_WHEEL_FAST_MS))
    }
}

; QMK の move_unit (Accelerated モード、速度切り替えキー無し) と同じ計算
MuhenkanMouse_MoveUnit(p, repeat) {
    if repeat = 0
        unit := p.delta
    else if repeat >= p.timeToMax
        unit := p.delta * p.maxSpeed
    else
        unit := (p.delta * p.maxSpeed * repeat) // p.timeToMax
    return Min(Max(unit, 1), p.moveMax)
}

; QMK の times_inv_sqrt2 と同じ。斜め移動で x・y を 181/256 倍し、0 になるときは符号付きの 1 にする
MuhenkanMouse_TimesInvSqrt2(x) {
    n := x * 181
    r := n < 0 ? -((-n + 128) // 256) : (n + 128) // 256
    return r ? r : (x < 0 ? -1 : 1)
}

; start からの経過時間に応じて from から to へ直線的に変わる値 (rampMs 経過後は to)
MuhenkanMouse_Ramp(start, rampMs, from, to) {
    t := Min((A_TickCount - start) / rampMs, 1)
    return from + (to - from) * t
}

; 割当キー(配列)のいずれかが物理的に押されているか
MuhenkanMouse_AnyDown(keys) {
    for k in keys {
        if GetKeyState(k, "P")
            return true
    }
    return false
}
