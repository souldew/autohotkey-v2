#Requires AutoHotkey v2.0

; vk1C (変換: 右)

vk1C::vk1C

vk1C & h:: Send "{Blind}{Left}"
vk1C & j:: Send "{Blind}{Down}"
vk1C & k:: Send "{Blind}{Up}"
vk1C & l:: Send "{Blind}{Right}"

vk1C & n:: Send "{Blind}{Home}"
vk1C & m:: Send "{Blind}{PgDn}"
vk1C & ,:: Send "{Blind}{PgUp}"
vk1C & .:: Send "{Blind}{End}"

vk1C & Space:: Send "{Blind}{Enter}"
vk1C & vkBB:: Send "{Blind}{Backspace}"
vk1C & vkBA:: Send "{Blind}{Delete}"

; 片手操作用に追加
vk1C & o:: Send "{Blind}{Enter}"