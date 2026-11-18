# 無変換マウスのカーソル速度プリセット

`muhenkan_mouse.ahk` のカーソル移動の速さは、`MM_MOVE_PRESET` にプリセット名を入れて選ぶ。ここには、試したプリセットの中身と比較、採用の経緯を残す。速さと動いた距離のグラフは [mouse-acceleration.html](mouse-acceleration.html)。

## 今の採用

`miryoku-max28`（2026-11-18〜）

- Miryoku と同じ加速で、最高速だけ 1 レポート 28px（約 1750px/秒）に抑えたもの
- Miryoku の方式（押し続けると速くなる）は加速・減速キーを持たないので、Shift・Ctrl を修飾キーとしてそのまま使える（Shift＋クリック、Ctrl＋クリックなど）
- 今後変える可能性があるので、試したプリセットはコードに残し、名前で切り替えられるようにしている

## プリセットの比較

| 名前 | 方式 | 押し始め | 最高速 | 最高速まで | 実装 |
| --- | --- | --- | --- | --- | --- |
| `legacy-accel-keys` | 一定速度＋加速・減速キー | 12px/ループ | 36px/ループ（加速キー） | 加速キーを押した瞬間 | commit cbddd10 の `muhenkan_mouse.ahk` |
| `miryoku` | QMK Accelerated | 8px のあと 1px/16ms | 48px/16ms（約 3000px/秒） | 約 1.0 秒 | `MM_MOVE_PRESETS` |
| `miryoku-max36` | QMK Accelerated | 8px のあと 1px/16ms | 36px/16ms（約 2250px/秒） | 約 0.75 秒 | `MM_MOVE_PRESETS` |
| `miryoku-max28` | QMK Accelerated | 8px のあと 1px/16ms | 28px/16ms（約 1750px/秒） | 約 0.6 秒 | `MM_MOVE_PRESETS` |
| `linear-ramp` | ループごとの直線加速 | 1px/ループ | 36px/ループ | 1.0 秒 | `MM_MOVE_PRESETS` |

「ループ」は `Sleep 10` のループ 1 回。AutoHotkey の `Sleep` は OS の時間の刻みに合わせて 10ms か 15.6ms に切り上げられ、どちらになるかは PC による。そのため、ループ単位のプリセットの 1 秒あたりの速さは PC で変わる（36px/ループなら約 2300〜3600px/秒）。QMK 方式のプリセットは経過時間からレポート数を数えるので、この影響を受けない。

## 各プリセット

### legacy-accel-keys

最初の実装。今のコードには入っておらず、commit cbddd10 の `muhenkan_mouse.ahk` に残っている。

- 移動: ループごとに 12px。`;` か Shift を押している間は 36px、`l` か Ctrl を押している間は 5px
- ホイール: 100ms ごと。加速キーで 10ms ごと、減速キーで 200ms ごと
- Shift・Ctrl を加速・減速に使うので、Shift＋クリックや Ctrl＋クリックができない

### miryoku

QMK Mouse Keys の Accelerated モードの計算式（`quantum/mousekey.c` の `move_unit`）に、Miryoku の `config.h` の値を入れたもの。

- 値: `MOUSEKEY_MOVE_DELTA` 8（QMK の既定値）、`MOUSEKEY_MAX_SPEED` 6、`MOUSEKEY_TIME_TO_MAX` 64、`MOUSEKEY_INTERVAL` 16、`MOUSEKEY_MOVE_MAX` 127（QMK の既定値）
- 1 レポートの移動量は、押した瞬間が 8、そのあとは `8 × 6 × repeat ÷ 64`（最低 1）で、repeat 64 以降は 48
- 斜めは縦・横それぞれ 181/256 倍（QMK の `times_inv_sqrt2`）
- 1 レポート = 1px として扱う。実機の QMK は USB マウスの移動量なので、Windows のポインター速度の設定しだいで体感が少しずれる

参照: [miryoku_qmk の config.h](https://github.com/manna-harbour/miryoku_qmk/blob/miryoku/users/manna-harbour_miryoku/config.h)・[QMK の mousekey.c](https://github.com/qmk/qmk_firmware/blob/master/quantum/mousekey.c)

### miryoku-max36・miryoku-max28

`miryoku` の加速のまま、`MOUSEKEY_MOVE_MAX`（1 レポートの移動量の上限）だけ 36・28 に下げたもの。加速の傾きは同じなので、上限が低いほど早く最高速に届く。

### linear-ramp

ループごとの移動量を、押し続けた時間に応じて 1 秒かけて 1px から 36px まで直線的に増やす。最高速は `legacy-accel-keys` の加速キーと同じ。斜めは補正しない。

## ホイール

ホイールはプリセットとは別で、押し続けると約 1 秒で送る間隔が 100ms から 25ms まで縮む（`MM_WHEEL_*`）。Miryoku（QMK の既定値）は 80ms ごとに 1 ノッチから送り、約 3.2 秒で 1 回 8 ノッチまで増える。こちらはまだ合わせていない。


## 👤メモ

もともとは、一定の速さで動かし、加速キーを押している間だけ速くする実装にしていた。しかし、この方式ではドラッグがしづらかった。
- 一定の速さでは、ドラッグ中に細かく位置を合わせられなかった
- 加速・減速キーに Shift・Ctrl を使っていたので、ドラッグ中に修飾キーとして押したいときにぶつかった

そこで、QMK の Mouse Keys の既定の動き方（Accelerated: キーを押し続けるほど速くなる）を取り入れる。押し始めは遅いので細かく合わせられ、加速・減速キーが要らないので Shift・Ctrl を修飾キーとして使える。設定の値は、よく参照される配列の Miryoku に合わせる。

ただ、Miryoku の最高速（約 3000px/秒）は速すぎて目で追えないので、そのままは採用しない。もとの実装の最高速（加速キーを押したときの 36px/ループ）を目安にする。
カーソルを次のディスプレイへ移す機能を入れるなら、長い距離を動かす速さはそこまで要らない。そのため、加速しても目で追える 28px（16ms あたり、約 1750px/秒）をいったん採用する。
