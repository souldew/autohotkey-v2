#Requires AutoHotkey v2.0
#include delete_key.ahk

g_henkan_layer_flg := false

vk1C::vk1C
vk1C & h:: run_henkan_layer("{Blind}{Left}")
vk1C & j:: run_henkan_layer("{Blind}{Down}")
vk1C & k:: run_henkan_layer("{Blind}{Up}")
vk1C & l:: run_henkan_layer("{Blind}{Right}")

vk1C & N:: run_henkan_layer("{Blind}{Home}")
vk1C & M:: run_henkan_layer("{Blind}{PgDn}")
vk1C & ,:: run_henkan_layer("{Blind}{PgUp}}")
vk1C & .:: run_henkan_layer("{Blind}{End}")

vk1C & vkBB:: run_henkan_layer("{Bs}")
vk1C & vkBA:: run_henkan_layer("{Delete}")
vk1C & Space:: run_henkan_layer("{Enter}")

run_henkan_layer(key) {
    Send(key)
    global g_henkan_layer_flg
    func_disable()
    while (GetKeyState("vk1C", "P")) {
        g_henkan_layer_flg := true
    }
    g_henkan_layer_flg := false
    func_enable()
}

#HotIf g_henkan_layer_flg
vk1C & h:: Send("{Blind}{Left}")
vk1C & j:: Send("{Blind}{Down}")
vk1C & k:: Send("{Blind}{Up}")
vk1C & l:: Send("{Blind}{Right}")
vk1C & N:: Send("{Blind}{Home}")
vk1C & M:: Send("{Blind}{PgDn}")
vk1C & ,:: Send("{Blind}{PgUp}}")
vk1C & .:: Send("{Blind}{End}")
vk1C & vkBB:: Send("{Bs}")
vk1C & vkBA:: Send("{Delete}")
vk1C & Space:: Send("{Enter}")
#HotIf