#Requires AutoHotkey v2
#SingleInstance Force
/*
-------------------------------------
PTFS App - Make Pro Tools borderless
https://github.com/strain08/Pro-Tools-Fullscreen-App

*/
APP_VERSION:="1.2.1"
APP_NAME:="PTFS App"

#Include .\include\windowStyle.ahk
#Include .\include\mainWindow.ahk
#Include .\include\mdiWindow.ahk
#Include .\include\class_RegStartup.ahk
#Include .\include\class_AppSettings.ahk
#Include .\include\class_SaveWindowPosition.ahk
#Include .\include\class_SessionNameWindow.ahk
#Include .\include\ptfs_App_GUI.ahk


PT_WINDOW:="ahk_class DigiAppWndClass"

INI_PATH:=A_ScriptDir "\"
INI_FILE:=INI_PATH "PTFS_App.ini"

; >> Configure
; Hotkeys
#HotIf WinActive(PT_WINDOW)
	; Toggle fullscreen
	^F12:: TogglePTFullScreen(WinExist(PT_WINDOW))
	; Toggle menu, only when KEEP_MAIN_WINDOW:= false
	MButton:: ToggleMenu(WinActive(PT_WINDOW))

#HotIf
; << Configure

; >> INIT
Init()
; Script exit callback
OnExit(OnExitHandler,1)
; << INIT

Init() {
	global MENU_PTR, prjw, Settings, rs

	; Load settings from INI_FILE
	Settings:=AppSettings(INI_FILE)

	; Window that overlays project name on menu
	prjw:=SessionNameWindow(MonitorGetPrimary())
	; Registry startup key manager
	rs:=RegStartup(APP_NAME, A_ScriptFullPath)
	; Tray menu
	BuildTrayMenu(APP_VERSION, Settings)

	MENU_PTR:=0

	; check if active PT window instance matches the saved one
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
		if IsWindowStyled(MDIGetWindowHandle(PT_MAIN_HWND, "Edit:"), Settings.KEEP_MAIN_WINDOW && Settings.THIN_BORDER) {
			SetTimer MDITimer, 250
		}
		; store init window size
		WindowSizeChanged(PT_MAIN_HWND)
	}
	; start monitoring for pro tools window
	SetTimer AutoFullscreen, 1000

}

; Toggles fullscreen mode if AUTO_FULLSCREEN = true
; When Pro Tools exits, clears the menu pointer
AutoFullscreen() {
	global MENU_PTR, prjw

	PT_MAIN_HWND:=WinWait(PT_WINDOW)
	; code below executes after PT has been opened
	prjw.SetOwner(PT_MAIN_HWND)
	MDIGetHandles(PT_MAIN_HWND, &edit_hwnd, &mix_hwnd)

	if !edit_hwnd || !mix_hwnd
		return
	; code below executes after a session has been opened
	if Settings.AUTO_FULLSCREEN {
		SetPTFullscreen(PT_MAIN_HWND, Settings, true)
		MenuSelect(PT_MAIN_HWND, "", "Window", "Edit")
	}
	WinWaitClose(PT_WINDOW)
	; code below executes after PT has been closed
	prjw.Visible:=false
	;prjw.ResetOwner()
	MENU_PTR:=0

}

; Toggle pt and child windows borders.
TogglePTFullScreen(PT_MAIN_HWND) {

	if PT_MAIN_HWND == 0
        return

	MDIGetHandles(PT_MAIN_HWND, &edit_hwnd, &mix_hwnd)

	SetTimer MDITimer, 0

	if Settings.KEEP_MAIN_WINDOW {
		MDIToggleWindow(PT_MAIN_HWND, Settings, mix_hwnd)
		MDIToggleWindow(PT_MAIN_HWND, Settings,edit_hwnd)

		if IsWindowStyled(edit_hwnd, Settings.KEEP_MAIN_WINDOW && Settings.THIN_BORDER){
			SetTimer MDITimer, 250
		}
		else{
			DisplayProjectInTitle(PT_MAIN_HWND,"")
			SetTimer MDITimer, 0
		}

		return
	}

	ToggleMainWindow(PT_MAIN_HWND, Settings)
	MDIToggleWindow(PT_MAIN_HWND, Settings, mix_hwnd)
	MDIToggleWindow(PT_MAIN_HWND, Settings, edit_hwnd)

	if IsWindowStyled(PT_MAIN_HWND) {
		SetTimer MDITimer, 250
	}
	else {
		prjw.Visible:=false
		SetTimer MDITimer, 0
	}
}

; Show or hide Pro Tools menu when main window is borderless.
ToggleMenu(PT_MAIN_HWND) {
	global MENU_PTR

	if !IsWindowStyled(PT_MAIN_HWND) ; check if window is full screen
		return
	if WinExist("ahk_class #32768") ; do not toggle if window menu is open
		return

	pt_edit_hWnd:= MDIGetWindowHandle(PT_MAIN_HWND, "Edit:")
	pt_mix_hWnd:= MDIGetWindowHandle(PT_MAIN_HWND, "Mix:")

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
		if Settings.SHOW_PROJECT_NAME
			prjw.Visible := true
		; invalidate menu pointer
		MENU_PTR := 0
	}
}

; Updates the project name.
; Updates the edit/mix window full screen state when project opened/changed
MDITimer() {
	global MENU_PTR

	PT_MAIN_HWND:=WinExist(PT_WINDOW)
	; hide project name if pt is closed
	if PT_MAIN_HWND = 0	{
		if Settings.SHOW_PROJECT_NAME {
			prjw.Visible:=false
		}
		return
	}

	MDISetState(PT_MAIN_HWND, Settings, true)

	if !Settings.SHOW_PROJECT_NAME
		return

	; update project name text
	prjw.ProjectName:= GetProjectName(PT_MAIN_HWND)

	if Settings.KEEP_MAIN_WINDOW	{
		DisplayProjectInTitle(PT_MAIN_HWND, GetProjectName(PT_MAIN_HWND) )
		if WindowSizeChanged(PT_MAIN_HWND) {
			MDIGetHandles(PT_MAIN_HWND, &edit_hwnd, &mix_hwnd)
			MDIMaximizeWindow(PT_MAIN_HWND, mix_hwnd)
			MDIMaximizeWindow(PT_MAIN_HWND, edit_hwnd)
		}
		return
	}
	; main window styled , menu visible, window active => show project name
	if IsWindowStyled(PT_MAIN_HWND) && 	DllCall("GetMenu", "Ptr", PT_MAIN_HWND) != 0 ; &&	WinActive(PT_WINDOW)
		prjw.Visible:=true

	; window inactive => hide project name
	;if !WinActive(PT_WINDOW)
;	;prjw.Visible:=false

}

; Restores borders, window caption and menu when quitting script
OnExitHandler(*) {
	if PT_MAIN_HWND:=WinExist(PT_WINDOW){
		prjw.Visible:=false
		DisplayProjectInTitle(PT_MAIN_HWND,'')
		MainState(PT_MAIN_HWND, Settings, false)
		MDISetState(PT_MAIN_HWND, Settings, false)
		if DllCall("GetMenu", "Ptr", PT_MAIN_HWND) == 0 && MENU_PTR != 0 {
			DllCall("SetMenu", "Ptr", PT_MAIN_HWND, "Ptr", MENU_PTR)
		}
		MDIGetHandles(PT_MAIN_HWND, &hedit, &hmix)
		ResetMDIStyle(hedit)
		ResetMDIStyle(hmix)
	}
}
