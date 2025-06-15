#Requires AutoHotkey v2.0

; 現在開いているエクスプローラーのディレクトリを取得
get_current_dir() {
    explorerHwnd := WinActive("ahk_class CabinetWClass")
    if (explorerHwnd) {
        for window in ComObject("Shell.Application").Windows {
            if (window.hwnd == explorerHwnd)
                return window.Document.Folder.Self.Path
        }
    }
}
