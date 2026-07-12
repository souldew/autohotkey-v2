AutoHotkey v2での例です。Spaceを「単押し=Space、長押し=別レイヤー（ここでは hjkl を矢印キーにする例）」にします。

```ahk
#Requires AutoHotkey v2.0

; Spaceを単独で押した時とレイヤーキーとして使う時を区別
*Space:: {
    static held := false
    held := true
    ; Spaceが押されている間だけレイヤー有効
    KeyWait("Space")  ; 離されるまで待つ
    held := false

    ; 押下時間で単押し判定
    if (A_TimeSinceThisHotkey < 200 && !layerUsed)
        Send("{Space}")
    layerUsed := false
}
```

ただし上のような自前のタイマー判定は誤爆しやすいので、AHK v2なら以下の「レイヤー方式」のほうが安定します。Spaceを押している間だけ hjkl などを矢印に変える実装です。

```ahk
#Requires AutoHotkey v2.0

spaceDown := false
spaceUsedAsLayer := false

*Space:: {
    global spaceDown := true
    global spaceUsedAsLayer := false
}

*Space up:: {
    global spaceDown := false
    ; レイヤーとして一度も使われなければ通常のSpaceを送る
    if (!spaceUsedAsLayer)
        Send("{Space}")
    global spaceUsedAsLayer := false
}

; Space押下中だけ有効になるレイヤー（#HotIf = 条件付きホットキー）
#HotIf spaceDown
h:: LayerKey("{Left}")
j:: LayerKey("{Down}")
k:: LayerKey("{Up}")
l:: LayerKey("{Right}")
#HotIf

LayerKey(key) {
    global spaceUsedAsLayer := true
    Send(key)
}
```

仕組みは次の通りです。`*Space::` でSpace押下を検知してフラグを立て、`#HotIf spaceDown` で「Spaceが押されている間だけ」hjklなどのホットキーを有効化します。レイヤーキーが一度でも使われたら `spaceUsedAsLayer` を立て、Spaceを離した時にそのフラグが立っていなければ通常のSpaceを送る、という判定です。これでSpace単押しはちゃんとSpaceとして機能します。

割り当てたいキーは `#HotIf spaceDown` ブロック内に追加してください。例えば数字レイヤーやマウス操作なども同じ形で増やせます。

どんなキーをレイヤーに割り当てたいか決まっていれば、その内容で書き換えた版を出します。