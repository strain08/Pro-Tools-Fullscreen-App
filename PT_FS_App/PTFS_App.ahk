#Requires AutoHotkey v2
#SingleInstance Force

#Include .\include\system_func.ahk
#Include .\include\projectWindow_class.ahk
/*
-------------------------------------
PT_FS_App - Make Pro Tools borderless
Version: 0.9.7b
*/

PT_WINDOW:="ahk_class DigiAppWndClass"

INI_PATH:=A_ScriptDir "\"
INI_FILE:=INI_PATH "PTFS_App.ini"

; >>>>> Configure

; Shortcuts
#HotIf WinActive(PT_WINDOW)

; Toggle fullscreen shortcut
^F12:: TogglePTFullScreen(WinExist(PT_WINDOW))

; Toggle menu shortcut, only when KEEP_MAIN_WINDOW:= false
MButton:: ToggleMenu(WinActive(PT_WINDOW))

#HotIf

; <<<<<< Configure

; >> INIT

; Load settings from INI_FILE

ReadSetting(Section, Name, Default){
	try{
		return IniRead(INI_FILE, Section, Name)
	}
	catch{
		IniWrite(Default,INI_FILE,Section, Name)
		return Default
	}
}

; Monitor to make Pro Tools full screen on.
; Default: MonitorGetPrimary()
PT_MONITOR:= ReadSetting("General", "PT_Monitor", MonitorGetPrimary())

; Custom window width.
; True: Read the window width from INI file.
; False:(default) Use PT_MONITOR width.
CUSTOM_WIDTH:= ReadSetting("General", "Custom_Width", false)

; Show project name when window in focus
; Default: true
SHOW_PROJECT_NAME:= ReadSetting("General", "Show_Project_Name", true)

; Keep main window border and menu
; Default: false
KEEP_MAIN_WINDOW:= ReadSetting("General", "Keep_Main_Window", false)

; Works only when KEEP_MAIN_WINDOW:= true
; true: wil use WM_BORDER as window style; false: remove all borders from edit and mix windows
; Prevents glitching on 1080p monitors at least
; Default: true
THIN_BORDER:= ReadSetting("General", "Thin_Border", true)

; Toggles full screen mode when Pro Tools starts
; Default: false
AUTO_FULLSCREEN:= ReadSetting("General", "Auto_Fullscreen", false)

INI_SECTION_SIZE:= "WindowSize"
INI_KEY_WIDTH:= "WindowWidth"
INI_WINDOW_WIDTH:= IniRead(INI_FILE, INI_SECTION_SIZE, INI_KEY_WIDTH, -1)
if INI_WINDOW_WIDTH == -1 {
	MonitorGetWorkArea(PT_MONITOR, &Left, &Top, &Right, &Bottom)
	IniWrite(INI_WINDOW_WIDTH:= Right - Left, INI_FILE, INI_SECTION_SIZE, INI_KEY_WIDTH)
}

Initialize()

; << INIT

Initialize(){
	global MENU_PTR, prjw

	MENU_PTR:=0
	prjw:=projectWindow(PT_MONITOR)

	; check if instance matches the saved one
	; if true, restore menu pointer from INI
	if PT_MAIN_HWND:=WinExist(PT_WINDOW) {
		; if instance matches, load menu pointer from INI
		if IniRead(INI_FILE, "Instance", "PT_MAIN_HWND", "0") = PT_MAIN_HWND {
			MENU_PTR:=IniRead(INI_FILE, "Instance", "MENU_PTR", "0")
		}
		; if window already has a visible menu, do not try to show it
		if DllCall("GetMenu", "Ptr", PT_MAIN_HWND) != 0 {
			MENU_PTR := 0
		}
		; if full screen start window timer
		if IsWindowStyled(GetMDIWindow(PT_MAIN_HWND, "Edit:"), KEEP_MAIN_WINDOW && THIN_BORDER) {
			SetTimer MDITimer, 250
		}
		; store init window size
		WindowSizeChanged(PT_MAIN_HWND)

	}

	; Update HWND's for PT main window and MDI windows
	; Toggle fullscreen if AUTO_FULLSCREEN is true
	SetTimer HwndUpdate, 1000
}

HwndUpdate() {
	global MENU_PTR
	PT_MAIN_HWND:=WinWait(PT_WINDOW)
	if !GetMDIWindow(PT_MAIN_HWND, "Edit:")
		return
	if !GetMDIWindow(PT_MAIN_HWND, "Mix:")
		return
	if AUTO_FULLSCREEN {
		if IsWindowStyled(GetMDIWindow(PT_MAIN_HWND, "Edit:"), KEEP_MAIN_WINDOW && THIN_BORDER){
			WinWaitClose(PT_WINDOW)
			MENU_PTR:=0
			return
		}
		TogglePTFullScreen(PT_MAIN_HWND)
		MenuSelect(PT_MAIN_HWND, "", "Window", "Edit")
	}
	WinWaitClose(PT_WINDOW)
	MENU_PTR:=0
}

; show or hide Pro Tools menu
ToggleMenu(PT_MAIN_HWND) {
	global MENU_PTR

	if !IsWindowStyled(PT_MAIN_HWND) ; check if window is full screen
		return
	if WinExist("ahk_class #32768") ; do not toggle if window menu is open
		return

	pt_edit_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Edit:")
	pt_mix_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Mix:")

	if MENU_PTR = 0 {
		; hide project window
		prjw.Visible:=false
		; hide menu
		MENU_PTR := DllCall("GetMenu", "Ptr", PT_MAIN_HWND) ; store menu pointer
		DllCall("SetMenu", "Ptr", PT_MAIN_HWND, "Ptr", 0)
		; adjust edit and mix window bottom, they will be off by 20 pixels when menu is hidden
		WinGetPos(,,,&Height, pt_edit_hWnd)
		WinMove(,,,Height+20, pt_edit_hWnd)
		WinGetPos(,,,&Height, pt_mix_hWnd)
		WinMove(,,,Height+20, pt_mix_hWnd)
		; save instance data, in case we close the script when menu is hidden
		try {
			IniWrite(PT_MAIN_HWND, INI_FILE, "Instance", "PT_MAIN_HWND")
			IniWrite(MENU_PTR, INI_FILE, "Instance", "MENU_PTR")
		} catch
		{
			MsgBox("Can not write " INI_FILE ". Will restore menu and exit script.")
			DllCall("SetMenu", "Ptr", PT_MAIN_HWND, "Ptr", MENU_PTR)
			ExitApp
		}
	}
	else {
		; show menu
		DllCall("SetMenu", "Ptr", PT_MAIN_HWND, "Ptr", MENU_PTR)
		; adjust edit and mix window bottom
		WinGetPos(, &YPos,, &Height, pt_edit_hWnd)
		WinMove(, YPos-20,, Height-20, pt_edit_hWnd)
		WinGetPos(, &YPos,, &Height, pt_mix_hWnd)
		WinMove(, YPos-20,, Height-20, pt_mix_hWnd)
		; show project window
		if SHOW_PROJECT_NAME
			prjw.Visible := true
		; invalidate menu pointer
		MENU_PTR := 0
	}
}

; updates the project name
; updates the edit/mix window styles when project opened
MDITimer() {
	global MENU_PTR

	PT_MAIN_HWND:=WinExist(PT_WINDOW)
	; hide project name if pt is closed
	if PT_MAIN_HWND = 0	{
		if SHOW_PROJECT_NAME {
			prjw.Visible:=false
		}
		return
	}

	pt_edit_hWnd:=GetMDIWindow(PT_MAIN_HWND, "Edit:")
	pt_mix_hWnd:=GetMDIWindow(PT_MAIN_HWND, "Mix:")
	if !IsWindowStyled(pt_mix_hWnd, KEEP_MAIN_WINDOW && THIN_BORDER)
		ToggleMDIWin(PT_MAIN_HWND, pt_mix_hWnd)
	if !IsWindowStyled(pt_edit_hWnd, KEEP_MAIN_WINDOW && THIN_BORDER)
		ToggleMDIWin(PT_MAIN_HWND, pt_edit_hWnd)

	if !SHOW_PROJECT_NAME
		return

	; update project name text
	prjw.ProjectName:= GetProjectName(PT_MAIN_HWND)

	if KEEP_MAIN_WINDOW	{
		DisplayProjectInTitle(PT_MAIN_HWND, GetProjectName(PT_MAIN_HWND) )
		if WindowSizeChanged(PT_MAIN_HWND) {
			MaximizeMDIWin(PT_MAIN_HWND, pt_mix_hWnd)
			MaximizeMDIWin(PT_MAIN_HWND, pt_edit_hWnd)
		}
		return
	}
	; main window styled , menu visible => show project name
	if IsWindowStyled(PT_MAIN_HWND) && DllCall("GetMenu", "Ptr", PT_MAIN_HWND) != 0
		prjw.Visible:=true

	; window inactive => hide project name
	if PT_MAIN_HWND != WinActive(PT_WINDOW)
		prjw.Visible:=false

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

DisplayProjectInTitle(PT_MAIN_HWND, name) {
	try{
		If name == "" {
			WinSetTitle("Pro Tools", PT_MAIN_HWND)
			return
		}
		WinSetTitle("Pro Tools - " name , PT_MAIN_HWND)
	}
}

GetProjectName(PT_MAIN_HWND) {

	try {
		pt_edit_hWnd:=GetMDIWindow(PT_MAIN_HWND, "Edit:")
		name:=LTrim(ControlGetText(pt_edit_hWnd),"Edit: ")
		return name
	}
	catch
		return ""
}

TogglePTFullScreen(PT_MAIN_HWND) {

	if PT_MAIN_HWND == 0
        return

	pt_edit_hWnd:=GetMDIWindow(PT_MAIN_HWND, "Edit:")
	pt_mix_hWnd:=GetMDIWindow(PT_MAIN_HWND, "Mix:")

	SetTimer MDITimer, 0

	if KEEP_MAIN_WINDOW {
		ToggleMDIWin(PT_MAIN_HWND, pt_mix_hWnd)
		ToggleMDIWin(PT_MAIN_HWND, pt_edit_hWnd)

		if IsWindowStyled(pt_edit_hWnd, KEEP_MAIN_WINDOW && THIN_BORDER){
			SetTimer MDITimer, 250
		}
		else{
			DisplayProjectInTitle(PT_MAIN_HWND,"")
			SetTimer MDITimer, 0
		}

		return
	}

	ToggleMainWindow(PT_MAIN_HWND)
	ToggleMDIWin(PT_MAIN_HWND, pt_mix_hWnd)
	ToggleMDIWin(PT_MAIN_HWND, pt_edit_hWnd)

	if IsWindowStyled(PT_MAIN_HWND) {
		SetTimer MDITimer, 250
	}
	else {
		prjw.Visible:=false
		SetTimer MDITimer, 0
	}
}

ToggleMainWindow(PT_MAIN_HWND) {
	global MENU_PTR

	if !WinExist(PT_MAIN_HWND)
        return false

    if !IsWindowStyled(PT_MAIN_HWND) {
		; make window fulll screen
        ToggleStyles(PT_MAIN_HWND)
		MonitorGetWorkArea(PT_MONITOR, &Left, &Top, &Right, &Bottom)
        if CUSTOM_WIDTH
			WinMove Left, Top, INI_WINDOW_WIDTH, Bottom - Top, PT_MAIN_HWND
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

MaximizeMDIWin(PT_MAIN_HWND, hWnd) {
	try {
		WinGetClientPos(,,&W,&H,PT_MAIN_HWND)
		WinMove(0,0, W, H, hWnd)
	}
}

; style the control to match main window style
ToggleMDIWin(PT_MAIN_HWND, hWnd) {
    if !WinExist(hWnd)
        return false

	if KEEP_MAIN_WINDOW {
		if !IsWindowStyled(hWnd) {
			MaximizeMDIWin(PT_MAIN_HWND, hWnd)
			ToggleStyles(hWnd, KEEP_MAIN_WINDOW && THIN_BORDER)
		}
		else {
			ToggleStyles(hWnd, KEEP_MAIN_WINDOW && THIN_BORDER)
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

