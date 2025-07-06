#Requires AutoHotkey v2.0

keys_all := [
    "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "^"
    "q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "@", "[",
    "a", "s", "d", "d", "f", "g", "h", "j", "k", "l", "vkBB", "vkBA", "]",
    "z", "x", "c", "v", "b", "n", "m", ",", ".", "/", "vkE2"
]

func_disable() {
    ; keys_all := ["h", "j", "k", "l"]
    loop keys_all.Length {
        Hotkey(keys_all[A_Index], (ThisHotkey) => disable_key, "On")
    }
    return
}

func_enable() {
    ; keys_all := ["h", "j", "k", "l"]
    loop keys_all.Length {
        Hotkey(keys_all[A_Index], (ThisHotkey) => disable_key, "Off")
    }
    return
}

disable_key() {
    return
}
