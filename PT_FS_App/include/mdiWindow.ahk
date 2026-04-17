#Requires AutoHotkey v2.0

; style child window to match main window style or explicit state
MDISetWindowStyle(PT_MAIN_HWND, Settings, hWnd, fullscreen:="") {
    if !WinExist(hWnd)
        return false

    ; If fullscreen is not specified, determine it based on settings and main window
    if fullscreen == "" {
        if Settings.KEEP_MAIN_WINDOW {
            ; In keep main window mode, we can't infer from main window, so we probably shouldn't call without param
            ; but for safety let's assume we want current style (no change)
            fullscreen := IsWindowStyled(hWnd, Settings.THIN_BORDER)
        } else {
            fullscreen := IsWindowStyled(PT_MAIN_HWND)
        }
    }

    current := IsWindowStyled(hWnd, Settings.KEEP_MAIN_WINDOW && Settings.THIN_BORDER)
    if current == fullscreen
        return

	if Settings.KEEP_MAIN_WINDOW {
		if fullscreen {
			MDIMaximizeWindow(PT_MAIN_HWND, hWnd)
			ToggleStyles(hWnd, Settings.THIN_BORDER)
		}
		else {
			ToggleStyles(hWnd, Settings.THIN_BORDER)
			WinRestore hWnd
			WinMaximize hWnd
		}
		return
	}

	if fullscreen {
        WinMove 0,0,,,hWnd
        ToggleStyles(hWnd)
        WinRestore hWnd
        WinMaximize hWnd
	}
	else {
        ToggleStyles(hWnd)
        WinRestore hWnd
        WinMaximize hWnd
	}
}

; Set child windows borders on or off.
MDISetState(PT_MAIN_HWND, Settings, fullscreen) {
	MDIGetHandles(PT_MAIN_HWND, &edit_hwnd, &mix_hwnd)
	
    MDISetWindowStyle(PT_MAIN_HWND, Settings, mix_hwnd, fullscreen)
    
	if MDISetWindowStyle(PT_MAIN_HWND, Settings, edit_hwnd, fullscreen) {
        if (fullscreen)
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