#Requires AutoHotkey v2.0
#Include UIA-v2/UIA.ahk

; ============================================================
; Vimium 風ヒント: 無変換 + g で、アクティブウィンドウの
; クリックできる要素にラベルを出し、ラベルを打つとクリックする
; ============================================================
;   Esc        : 取り消し (無変換 + w や、ラベルに無い文字でも取り消し)
;   Backspace  : 1 文字戻す
;
; 仕組み:
;  ・UI Automation (UIA-v2) でアクティブウィンドウの要素を集める。
;    1 要素ずつ COM を呼ぶと遅いので、種類と位置だけをキャッシュして一度に取る
;  ・ラベルは 1 枚の透明なウィンドウにまとめて描く。要素ごとにウィンドウを
;    作ると、数百個あるときに表示が遅くなるため
;  ・選んだ要素は UIA の Invoke などで実行し、効かなければ中央をクリックする
;
; 制約:
;  ・管理者権限で動くウィンドウは、このスクリプトも管理者で動かさないと読めない (UIPI)
;  ・モニターごとに拡大率が違う環境では、ラベルの位置がずれることがある

vk1D & g:: Hint_Show()

; ヒントを待ち受けている InputHook。待ち受けていないときは 0
Hint_ActiveHook := 0

; 無変換 + w (muhenkan_mouse.ahk で Esc に割り当て) は InputHook より先にホットキーとして
; 処理され、そこから SendInput で送る Esc は自分のスクリプトの InputHook に届かない。
; そのため、ヒントを出している間だけ、無変換 + w で直接取り消す
#HotIf Hint_ActiveHook
vk1D & w:: Hint_ActiveHook.Stop()
#HotIf

Hint_Show() {
    static chars := "sadfjklewcmpgh"
    static condition := 0, cacheRequest := 0
    if !condition {
        condition := UIA.CreateCondition({
            IsOffscreen: 0,
            IsEnabled: 1,
            Type: ["Button", "Hyperlink", "MenuItem", "TabItem", "ListItem", "TreeItem",
                "CheckBox", "RadioButton", "ComboBox", "Edit", "SplitButton", "DataItem"]
        })
        cacheRequest := UIA.CreateCacheRequest(["Type", "BoundingRectangle"])
    }

    hwnd := WinExist("A")
    if !hwnd
        return

    start := A_TickCount
    try {
        root := UIA.ElementFromHandle(hwnd)
        win := root.BoundingRectangle
        found := root.FindAllBuildCache(cacheRequest, condition)
    } catch as e {
        Hint_Notify("UIA の取得に失敗: " e.Message)
        return
    }

    ; 見えていない要素と、ウィンドウの外にはみ出した要素を除く
    targets := []
    for el in found {
        r := el.CachedBoundingRectangle
        if r.r - r.l < 2 || r.b - r.t < 2
            continue
        if r.r <= win.l || r.l >= win.r || r.b <= win.t || r.t >= win.b
            continue
        targets.Push({ el: el, rect: r, type: el.CachedType })
    }
    elapsed := A_TickCount - start

    if !targets.Length {
        Hint_Notify("クリックできる要素が見つからない (" elapsed " ms)")
        return
    }

    labels := Hint_Labels(targets.Length, chars)

    ; 透明な 1 枚のウィンドウにラベルを並べる。WS_EX_TRANSPARENT (0x20) でクリックを素通しする
    overlay := Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x20")
    overlay.BackColor := "010101"
    overlay.SetFont("s9 bold c000000", "Consolas")
    for i, t in targets {
        x := Max(t.rect.l, win.l) - win.l
        y := Max(t.rect.t, win.t) - win.t
        t.label := labels[i]
        t.ctrl := overlay.AddText("x" x " y" y " +Border BackgroundFFD84D", " " StrUpper(labels[i]) " ")
    }
    ; 表示してから透明にすると、背景の黒が一瞬ウィンドウいっぱいに見えるため、
    ; 非表示のまま透明化と表示アニメーションの停止を済ませてから表示する
    overlay.Show("x" win.l " y" win.t " w" (win.r - win.l) " h" (win.b - win.t) " Hide")
    WinSetTransColor "010101", overlay
    DllCall("dwmapi\DwmSetWindowAttribute", "ptr", overlay.Hwnd, "uint", 3, "int*", 1, "uint", 4)   ; DWMWA_TRANSITIONS_FORCEDISABLED
    overlay.Show("NoActivate")

    ToolTip targets.Length " 個 / " elapsed " ms", win.l, win.t - 24

    chosen := Hint_ReadLabel(targets, overlay)

    overlay.Destroy()
    ToolTip

    if chosen
        Hint_Activate(chosen)
}

; 同じ長さのラベルを count 個つくる。長さをそろえると、打ち終わりを判定しやすい
Hint_Labels(count, chars) {
    base := StrLen(chars)
    len := 1
    while base ** len < count
        len++
    labels := []
    loop count {
        n := A_Index - 1
        label := ""
        loop len {
            label := SubStr(chars, Mod(n, base) + 1, 1) label
            n := n // base
        }
        labels.Push(label)
    }
    return labels
}

; キー入力でラベルを絞り込み、決まった要素を返す。取り消したら 0
; 1 文字ごとに InputHook を止めて再開すると、そのすき間に打ったキーが
; 元のアプリに流れてしまうため、決まるまで 1 つの InputHook で受け続ける
Hint_ReadLabel(targets, overlay) {
    state := { typed: "", result: 0 }
    ih := InputHook("", "{Esc}")
    ih.BackspaceIsUndo := false
    ih.KeyOpt("{Backspace}", "N")
    ih.OnChar := (ih, ch) => Hint_OnInput(ih, state, targets, overlay, state.typed StrLower(ch))
    ih.OnKeyDown := (ih, vk, sc) => Hint_OnInput(ih, state, targets, overlay, SubStr(state.typed, 1, -1))
    global Hint_ActiveHook := ih
    ih.Start()
    ih.Wait()
    Hint_ActiveHook := 0
    return state.result
}

Hint_OnInput(ih, state, targets, overlay, typed) {
    state.typed := typed
    matches := 0, last := 0

    ; ラベルを 1 つずつ出し入れするたびに再描画されると遅いので、まとめて 1 回だけ描き直す
    DllCall("SendMessage", "ptr", overlay.Hwnd, "uint", 0x000B, "ptr", 0, "ptr", 0)   ; WM_SETREDRAW: off
    for t in targets {
        hit := SubStr(t.label, 1, StrLen(typed)) = typed
        if t.ctrl.Visible != hit
            t.ctrl.Visible := hit
        if hit
            matches++, last := t
    }
    DllCall("SendMessage", "ptr", overlay.Hwnd, "uint", 0x000B, "ptr", 1, "ptr", 0)   ; WM_SETREDRAW: on
    ; RDW_INVALIDATE | RDW_ERASE | RDW_ALLCHILDREN | RDW_UPDATENOW
    DllCall("RedrawWindow", "ptr", overlay.Hwnd, "ptr", 0, "ptr", 0, "uint", 0x185)

    if matches = 0 {
        ih.Stop()
    } else if matches = 1 && last.label = typed {
        state.result := last
        ih.Stop()
    }
}

Hint_Activate(t) {
    el := t.el
    ; 入力欄はクリックではなくフォーカスを移す
    if t.type = UIA.Type.Edit || t.type = UIA.Type.ComboBox {
        try {
            el.SetFocus()
            return
        }
    }
    try {
        if el.Click()
            return
    }
    CoordMode "Mouse", "Screen"
    Click (t.rect.l + t.rect.r) // 2, (t.rect.t + t.rect.b) // 2
}

Hint_Notify(msg) {
    ToolTip msg
    SetTimer () => ToolTip(), -2000
}
