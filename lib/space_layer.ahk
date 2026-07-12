#Requires AutoHotkey v2.0

; Space を押している間だけ half-qwerty 配列にするレイヤー
;
; half-qwerty はキーボードを中央で左右反転させた片手入力配列。
; Space を押しながら反対側の手のキーを押すと、ミラー位置のキーが入力される。
; （例: Space + j → f、Space + f → j）
; Space を単押ししたときは通常どおり Space を送る（Space::Space）。
;
; {Blind} を付けて Shift などの修飾キーの状態を維持する（大文字や記号に対応）。

Space::Space

; 数字段  1 2 3 4 5 6 7 8 9 0
; HHKB Studio には半角/全角キーが無いため、左上の Esc に - を割り当て（左手で届く）。
Space & Esc:: Send "{Blind}-"   ; Esc → -
Space & 1:: Send "{Blind}0"
Space & 2:: Send "{Blind}9"
Space & 3:: Send "{Blind}8"
Space & 4:: Send "{Blind}7"
Space & 5:: Send "{Blind}6"
Space & 6:: Send "{Blind}5"
Space & 7:: Send "{Blind}4"
Space & 8:: Send "{Blind}3"
Space & 9:: Send "{Blind}2"
Space & 0:: Send "{Blind}1"

; 上段  q w e r t y u i o p
Space & q:: Send "{Blind}p"
Space & w:: Send "{Blind}o"
Space & e:: Send "{Blind}i"
Space & r:: Send "{Blind}u"
Space & t:: Send "{Blind}y"
Space & y:: Send "{Blind}t"
Space & u:: Send "{Blind}r"
Space & i:: Send "{Blind}e"
Space & o:: Send "{Blind}w"
Space & p:: Send "{Blind}q"

; 中段  a s d f g h j k l ;
Space & a:: Send "{Blind};"
Space & s:: Send "{Blind}l"
Space & d:: Send "{Blind}k"
Space & f:: Send "{Blind}j"
Space & g:: Send "{Blind}h"
Space & h:: Send "{Blind}g"
Space & j:: Send "{Blind}f"
Space & k:: Send "{Blind}d"
Space & l:: Send "{Blind}s"
Space & vkBA:: Send "{Blind}a"   ; ; キー → a

; 下段  z x c v b n m , . /
Space & z:: Send "{Blind}/"
Space & x:: Send "{Blind}."
Space & c:: Send "{Blind},"
Space & v:: Send "{Blind}m"
Space & b:: Send "{Blind}n"
Space & n:: Send "{Blind}b"
Space & m:: Send "{Blind}v"
Space & vkBC:: Send "{Blind}c"   ; , キー → c
Space & vkBE:: Send "{Blind}x"   ; . キー → x
Space & vkBF:: Send "{Blind}z"   ; / キー → z
