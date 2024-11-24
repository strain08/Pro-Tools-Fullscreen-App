#Requires AutoHotkey v2.0

; style child window to match main window style
MDIToggleWindow(PT_MAIN_HWND, Settings, hWnd) {
    if !WinExist(hWnd)
        return false

	if Settings.KEEP_MAIN_WINDOW {
		if !IsWindowStyled(hWnd) {
			MDIMaximizeWindow(PT_MAIN_HWND, hWnd)
			ToggleStyles(hWnd, Settings.KEEP_MAIN_WINDOW && Settings.THIN_BORDER)
		}
		else {
			ToggleStyles(hWnd, Settings.KEEP_MAIN_WINDOW && Settings.THIN_BORDER)
			WinRestore hWnd
			WinMaximize hWnd
		}
		return
	}

	if IsWindowStyled(PT_MAIN_HWND) {
		if !IsWindowStyled(hWnd) {
			WinMove 0,0,,,hWnd
			ToggleStyles(hWnd)
			WinRestore hWnd
			WinMaximize hWnd
		}
	}
	else {
		if IsWindowStyled(hWnd) {
				ToggleStyles(hWnd)
				WinRestore hWnd
				WinMaximize hWnd
		}
	}
}
; Set child windows borders on or off.
MDISetState(PT_MAIN_HWND, Settings, fullscreen) {
	MDIGetHandles(PT_MAIN_HWND, &edit_hwnd, &mix_hwnd)
	edit_fs:=IsWindowStyled(edit_hwnd, Settings.KEEP_MAIN_WINDOW && Settings.THIN_BORDER)
	mix_fs:=IsWindowStyled(mix_hwnd, Settings.KEEP_MAIN_WINDOW && Settings.THIN_BORDER)

	if mix_fs == !fullscreen
		MDIToggleWindow(PT_MAIN_HWND, Settings, mix_hwnd)

	if edit_fs == !fullscreen{
		MDIToggleWindow(PT_MAIN_HWND, Settings, edit_hwnd)
		MenuSelect(PT_MAIN_HWND, "", "Window", "Edit")
	}
}

; maximize child window
MDIMaximizeWindow(PT_MAIN_HWND, hWnd) {
	try {
		WinGetClientPos(,,&W,&H,PT_MAIN_HWND)
		WinMove(0,0, W, H, hWnd)
	}
}

MDIGetWindowHandle(hWnd, ID)
{
    try{
		return ControlGetHwnd(ID,hWnd)
	}
    catch
		return false
}

MDIGetHandles(PT_MAIN_HWND, &edit_hwnd, &mix_hwnd){
	edit_hwnd:=MDIGetWindowHandle(PT_MAIN_HWND, "Edit:")
	mix_hwnd:=MDIGetWindowHandle(PT_MAIN_HWND, "Mix:")
}