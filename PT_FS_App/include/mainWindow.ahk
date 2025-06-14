#Requires AutoHotkey v2.0

; set main window borders on or off
MainState(PT_MAIN_HWND, Settings, fullscreen) {
	style:=IsWindowStyled(PT_MAIN_HWND)
	If  style && fullscreen
		return
	If !style && !fullscreen
		return
	ToggleMainWindow(PT_MAIN_HWND, Settings)
}
; Toggles main program window.
; Restores menu if hidden.
ToggleMainWindow(PT_MAIN_HWND, Settings) {
	global MENU_PTR

	if !WinExist(PT_MAIN_HWND)
        return false

    if !IsWindowStyled(PT_MAIN_HWND) {
		; make window fulll screen
        ToggleStyles(PT_MAIN_HWND)
		MonitorGetWorkArea(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)

        if Settings.CUSTOM_WIDTH{
			WinRestore PT_MAIN_HWND
			WinMove Left, Top, Settings.INI_WINDOW_WIDTH, Bottom - Top, PT_MAIN_HWND
		}
		else
			WinMove Left, Top, Right - Left, Bottom - Top, PT_MAIN_HWND
    }
	else {
		; restore window
        ToggleStyles(PT_MAIN_HWND)
		; restore menu
		if DllCall("GetMenu", "Ptr", PT_MAIN_HWND) == 0 && MENU_PTR != 0
		{
			DllCall("SetMenu", "Ptr", PT_MAIN_HWND, "Ptr", MENU_PTR)
			MENU_PTR:=0
		}
		WinRestore PT_MAIN_HWND
		WinMaximize PT_MAIN_HWND
    }
}

; toggle main window borders
SetPTFullscreen(PT_MAIN_HWND, Settings, fullscreen) {

	MDIGetHandles(PT_MAIN_HWND, &edit_hwnd, &mix_hwnd)

	style:=IsWindowStyled(PT_MAIN_HWND)
	edit_styled:=IsWindowStyled(edit_hwnd, Settings.KEEP_MAIN_WINDOW && Settings.THIN_BORDER)
	mix_styled:=IsWindowStyled(mix_hwnd, Settings.KEEP_MAIN_WINDOW && Settings.THIN_BORDER)

	if (style == !fullscreen) || ((edit_styled || mix_styled) == !fullscreen)
		TogglePTFullScreen(PT_MAIN_HWND)

}

WindowSizeChanged(hWnd) {
	if !WinExist(hWnd)
		return
	static Width:=0, Height:=0
	WinGetPos(,,&W,&H,hWnd)
	if W!=Width || H!=Height{
		Width:=W
		Height:=H
		return true
	}
	return false
}
