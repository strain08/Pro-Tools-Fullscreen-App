#Requires AutoHotkey v2
#SingleInstance Force

#Include .\include\system_func.ahk

/*
-------------------------------------
PT_FS_App - Make Pro Tools borderless
Version: 1.1.0b
TODO:
	- fix project name window
History
1.1.1b
	- disable menu toggle when menu open
	- do not hide menu if pt is not fullscreen
	- backup menu pointer
1.1.0b
	- toggle menu in order to fix region move offset
1.0.0b
	- initial release
-------------------------------------
*/

; >>>>> Configure

; Toggle fullscreen shortcut
^F12:: TogglePTFullScreen()
MButton:: ToggleMenu()

; Monitor to make Pro Tools full screen on.
; Default: MonitorGetPrimary()
PT_MONITOR:= MonitorGetPrimary()

; Custom window width.
; True: Read the window width from INI file.
; False (default): Use PT_MONITOR width.
CUSTOM_WIDTH:= false

; Show project name when window in focus
; Default: true
SHOW_PROJECT_NAME:= false

; <<<<<< Configure

INI_PATH:=A_ScriptDir "\"
INI_FILE:=INI_PATH "PTFS_App.ini"
INI_SECTION_SIZE:= "WindowSize"
INI_KEY_WIDTH:= "WindowWidth"
INI_WINDOW_WIDTH:= IniRead(INI_FILE, INI_SECTION_SIZE, INI_KEY_WIDTH, -1)
if INI_WINDOW_WIDTH == -1{
	MonitorGetWorkArea(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
	IniWrite(INI_WINDOW_WIDTH:= Right - Left, INI_FILE, INI_SECTION_SIZE, INI_KEY_WIDTH)
}

ProjectCaption:=""
ProjectWindowID:={}
PT_IS_FULLSCREEN:=false

; check if instance matches the saved one
; if true, restore menu pointer from INI
MENU_PTR:=0
PT_MAIN_HWND:=0
if PT_MAIN_HWND:=WinExist("ahk_class DigiAppWndClass") {
	t:=IniRead(INI_FILE, "Instance", "PT_MAIN_HWND")
	if t=PT_MAIN_HWND { ; if instance matches, load menu pointer from INI
		MENU_PTR:=IniRead(INI_FILE, "Instance", "MENU_PTR")
	}
}
; if window has a visible menu, do not try to show it
if DllCall("GetMenu", "Ptr", PT_MAIN_HWND) != 0
	MENU_PTR := 0

; show or hide Pro Tools menu
ToggleMenu() {
	global MENU_PTR
	global SHOW_PROJECT_NAME
	global ProjectWindowID

	if !PT_MAIN_HWND:=WinActive("ahk_class DigiAppWndClass")
		return
	if !IsWindowStyled(PT_MAIN_HWND) ; check if window is full screen
		return
	if WinExist("ahk_class #32768") ; detect if window menu is open
		return

	if MENU_PTR = 0 {
		; hide menu
		MENU_PTR := DllCall("GetMenu", "Ptr", PT_MAIN_HWND) ; store menu pointer
		DllCall("SetMenu", "Ptr", PT_MAIN_HWND, "Ptr", 0)
		; hide project name window
		if SHOW_PROJECT_NAME
			DisplayProjectName false
		; adjust edit and mix window bottom, they will be off by 20 pixels when menu is hidden
		pt_edit_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Edit:")
		pt_mix_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Mix:")
		WinGetPos(,,,&Height, pt_edit_hWnd)
		WinMove(,,,Height+20, pt_edit_hWnd)
		WinGetPos(,,,&Height, pt_mix_hWnd)
		WinMove(,,,Height+20, pt_mix_hWnd)
		; save instance data, in case we close the script when menu is hidden
		IniWrite(PT_MAIN_HWND, INI_FILE, "Instance", "PT_MAIN_HWND")
		IniWrite(MENU_PTR, INI_FILE, "Instance", "MENU_PTR")
	}
	else {
		; show menu
		DllCall("SetMenu", "Ptr", PT_MAIN_HWND, "Ptr", MENU_PTR)
		; show project name window
		if SHOW_PROJECT_NAME
			DisplayProjectName true
		; adjust edit and mix window bottom
		pt_edit_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Edit:")
		pt_mix_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Mix:")
		WinGetPos(, &YPos,, &Height, pt_edit_hWnd)
		WinMove(, YPos-20,, Height-20, pt_edit_hWnd)
		WinGetPos(, &YPos,, &Height, pt_mix_hWnd)
		WinMove(, YPos-20,, Height-20, pt_mix_hWnd)
		; invalidate menu pointer
		MENU_PTR := 0
	}
}

; updates the project name
; updates the edit/mix window styles when project opened
ProjectNameTimer(){
	global TextID
	global ProjectCaption
	global ProjectWindowID
	global SHOW_PROJECT_NAME
	global PT_IS_FULLSCREEN
	global PT_MAIN_HWND
	global MENU_PTR

	PT_MAIN_HWND:=WinExist("ahk_class DigiAppWndClass")
	if PT_MAIN_HWND = 0
		return

	pt_edit_hWnd:=GetMDIWindow(PT_MAIN_HWND, "Edit:")
	pt_mix_hWnd:=GetMDIWindow(PT_MAIN_HWND, "Mix:")
	ToggleControl(pt_mix_hWnd)
	ToggleControl(pt_edit_hWnd)

	text:=""
	try{
		; no way yet to find which one is visible... use just project name
		text:= LTrim(ControlGetText(pt_edit_hWnd),"Edit: ")
	}
	catch{
		text:=""
	}
	try {
		if PT_MAIN_HWND:=WinActive( "ahk_class DigiAppWndClass") && PT_IS_FULLSCREEN && SHOW_PROJECT_NAME {
			ControlSetText(text, TextID)
			if ControlGetVisible(ProjectWindowID)=0 {
				ProjectWindowID.Show
				WinActivate PT_MAIN_HWND
			}
		}
		else{
			if ControlGetVisible(ProjectWindowID)!=0 && !SHOW_PROJECT_NAME
				ProjectWindowID.Hide

		}
	}
	catch
	{ }
}

TogglePTFullScreen(){
	global PT_IS_FULLSCREEN
	global SHOW_PROJECT_NAME

    PT_MAIN_HWND:= WinExist("ahk_class DigiAppWndClass")
	if PT_MAIN_HWND == 0
        return 0

	ToggleMainWindow(PT_MAIN_HWND)

	if PT_IS_FULLSCREEN
		SetTimer ProjectNameTimer, 250
	else
		SetTimer ProjectNameTimer, -250 ; negative means run once in specified interval

	; Send Ctrl + =  twice, force a redraw
    WinActivate PT_MAIN_HWND
    Send "^="
    Send "^="
}

ToggleMainWindow(hWnd) {
	global PT_MONITOR
	global CUSTOM_WIDTH
	global INI_WINDOW_WIDTH
	global SHOW_PROJECT_NAME
	global PT_IS_FULLSCREEN

	if !WinExist(hWnd)
        return false

    if !IsWindowStyled(hWnd){
        ToggleStyles(hWnd)
		MonitorGetWorkArea(PT_MONITOR, &Left, &Top, &Right, &Bottom)
        if CUSTOM_WIDTH
			WinMove Left, Top, INI_WINDOW_WIDTH, Bottom - Top, hWnd
		else
			WinMove Left, Top, Right - Left, Bottom - Top, hWnd
		PT_IS_FULLSCREEN:=true
    }
	else
	{
        ToggleStyles(hWnd)
		WinRestore hWnd
		WinMaximize hWnd
		PT_IS_FULLSCREEN:=false
    }

	if SHOW_PROJECT_NAME
		DisplayProjectName(PT_IS_FULLSCREEN)
}

; style the control to match main window style
ToggleControl(hWnd) {
	global PT_IS_FULLSCREEN

    if !WinExist(hWnd)
        return false

	if PT_IS_FULLSCREEN {
		if !IsWindowStyled(hWnd) {
			WinMove 0,0,,,hWnd
			ToggleStyles hWnd
			WinRestore hWnd
			WinMaximize hWnd
		}
	}
	else {
		if IsWindowStyled(hWnd){
				ToggleStyles hWnd
				WinRestore hWnd
				WinMaximize hWnd
		}
	}
}

DisplayProjectName(show:=false){
	global PT_MONITOR
	global TextID
	global ProjectWindowID
	if show{
		MonitorGetWorkArea(PT_MONITOR, &Left, &Top, &Right, &Bottom)
		ProjectWindowID := Gui()
		ProjectWindowID.BackColor:="333333"
		ProjectWindowID.SetFont("s10 c38D177 w100")
		;ID.Add("Text",, Left " " Top " " Right " " Bottom )

		textStart:=Right - 100
		boxWidth:=1350
		TextID:= ProjectWindowID.AddText("x0 y2 w1200 h20 Center")

		ProjectWindowID.Show( "X" Right - boxWidth " Y" Top " w" boxWidth " h-19 NoActivate" )
		ProjectWindowID.Opt("+AlwaysOnTop -Caption +ToolWindow")
	} else
		try	ProjectWindowID.Hide
		;catch
}
