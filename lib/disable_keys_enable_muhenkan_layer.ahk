#Requires AutoHotkey v2.0
#include delete_key.ahk

g_muhenkan_layer_flg := false

vk1D::vk1D
vk1D & Space:: run_muhenkan_layer("{Blind}{vk1C}")
vk1D & e:: run_muhenkan_layer("{Esc}")
vk1D & c:: run_muhenkan_layer("^c")
vk1D & x:: run_muhenkan_layer("^x")
vk1D & v:: run_muhenkan_layer("^v")
vk1D & s:: run_muhenkan_layer("^s")
vk1D & z:: run_muhenkan_layer("^z")
vk1D & y:: run_muhenkan_layer("^+z")
vk1D & f:: run_muhenkan_layer("^f")
vk1D & a:: run_muhenkan_layer("^a")

run_muhenkan_layer(key) {
    Send(key)
    global g_muhenkan_layer_flg
    func_disable()
    while (GetKeyState("vk1D", "P")) {
        g_muhenkan_layer_flg := true
    }
    g_muhenkan_layer_flg := false
    func_enable()
}

#HotIf g_muhenkan_layer_flg
vk1D & Space:: Send("{Blind}{vk1C}")
vk1D & e:: Send("{Esc}")
vk1D & c:: Send("^c")
vk1D & x:: Send("^x")
vk1D & v:: Send("^v")
vk1D & s:: Send("^s")
vk1D & z:: Send("^z")
vk1D & y:: Send("^+z")
vk1D & f:: Send("^f")
vk1D & a:: Send("^a")
#HotIf