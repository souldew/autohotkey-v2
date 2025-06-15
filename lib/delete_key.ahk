#Requires AutoHotkey v2.0





func_disable(){
    keys_all := ["h", "j" , "k", "l"]
    Loop keys_all.Length{
        Hotkey(keys_all[A_Index], (ThisHotkey)=>disable_key, "On")
    }
    return
}

func_enable(){
    keys_all := ["h", "j" , "k", "l"]
    Loop keys_all.Length{
        Hotkey(keys_all[A_Index], (ThisHotkey)=>disable_key, "Off")
    }
    return
}

disable_key(){
    return
}