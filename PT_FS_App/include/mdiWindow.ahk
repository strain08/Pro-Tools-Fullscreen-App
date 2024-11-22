#Requires AutoHotkey v2.0

; style the control to match main window style
ToggleMDIWin(PT_MAIN_HWND, hWnd) {
    if !WinExist(hWnd)
        return false

	if Settings.KEEP_MAIN_WINDOW {
		if !IsWindowStyled(hWnd) {
			MaximizeMDIWin(PT_MAIN_HWND, hWnd)
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
; set child windows borders on or off
MdiState(PT_MAIN_HWND, fullscreen) {
	GetMDIWindows(PT_MAIN_HWND, &edit_hwnd, &mix_hwnd)
	edit_fs:=IsWindowStyled(edit_hwnd, Settings.KEEP_MAIN_WINDOW && Settings.THIN_BORDER)
	mix_fs:=IsWindowStyled(mix_hwnd, Settings.KEEP_MAIN_WINDOW && Settings.THIN_BORDER)

	if mix_fs == !fullscreen
		ToggleMDIWin(PT_MAIN_HWND, mix_hwnd)

	if edit_fs == !fullscreen{
		ToggleMDIWin(PT_MAIN_HWND, edit_hwnd)
		MenuSelect(PT_MAIN_HWND, "", "Window", "Edit")
	}
}

; maximize child window
MaximizeMDIWin(PT_MAIN_HWND, hWnd) {
	try {
		WinGetClientPos(,,&W,&H,PT_MAIN_HWND)
		WinMove(0,0, W, H, hWnd)
	}
}

GetMDIWindow(hWnd, ID)
{
    try{
		return ControlGetHwnd(ID,hWnd)
	}
    catch
		return false
}

GetMDIWindows(PT_MAIN_HWND, &edit_hwnd, &mix_hwnd){
	edit_hwnd:=GetMDIWindow(PT_MAIN_HWND, "Edit:")
	mix_hwnd:=GetMDIWindow(PT_MAIN_HWND, "Mix:")
}