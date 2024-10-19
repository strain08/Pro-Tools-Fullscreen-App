#Requires AutoHotkey v2
#SingleInstance Force
/*
-------------------------------------
PT_FS_App - Make Pro Tools borderless
Version: 1.1.0b
TODO:
	- fix project name window
	- disable middle-click action when menu open
	- check if pt is fullscreen before hide menu (?)
History
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

ToggleMenu()
{
	global menuPtr
	if menuPtr = 0 {
		; hide menu
		menuPtr := DllCall("GetMenu", "Ptr", PT_MAIN_HWND)
		DllCall("SetMenu", "Ptr", PT_MAIN_HWND, "Ptr", 0)
		pt_edit_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Edit:")
		WinGetPos(,,,&Height,pt_edit_hWnd)
		WinMove(,,,Height + 20,pt_edit_hWnd)
	} 
	else {
		; show menu
		DllCall("SetMenu", "Ptr", PT_MAIN_HWND, "Ptr", menuPtr)
		pt_edit_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Edit:")
		WinGetPos(, &YPos,, &Height, pt_edit_hWnd)
		WinMove(, YPos-20,, Height - 20, pt_edit_hWnd)
		menuPtr := 0
	}
}

; Monitor to make Pro Tools full screen on.
; Default: MonitorGetPrimary()
PT_MONITOR:= MonitorGetPrimary()

; Custom window width. 
; True: Read the window width from INI file.
; False (default): Use PT_MONITOR width. 
CUSTOM_WIDTH:= false
menuPtr:=0
; Show project name when window in focus
; Default: true
SHOW_PROJECT_NAME:= false

; Configure <<<<<<

INI_PATH:=A_ScriptDir "\"
INI_FILE:=INI_PATH "PTFS_App.ini"
INI_SECTION_SIZE:= "WindowSize"
INI_KEY_WIDTH:= "WindowWidth"
INI_WINDOW_WIDTH:= IniRead(INI_FILE, INI_SECTION_SIZE, INI_KEY_WIDTH, -1)
if INI_WINDOW_WIDTH == -1{
	MonitorGetWorkArea(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
	IniWrite(INI_WINDOW_WIDTH:= Right - Left, INI_FILE, INI_SECTION_SIZE, INI_KEY_WIDTH)
}
	
PT_IS_FULLSCREEN:=false
PT_MAIN_HWND:=0
ProjectCaption:=""
ProjectWindowID:={}
activeControl:=0

ControlTimer(){
	global TextID
	global ProjectCaption
	global ProjectWindowID	
	global SHOW_PROJECT_NAME

	if PT_MAIN_HWND = 0
		return
	pt_edit_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Edit:")
    pt_mix_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Mix:")
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
		if WinActive( "ahk_exe ProTools.exe") && PT_IS_FULLSCREEN && SHOW_PROJECT_NAME {
			ControlSetText(text, TextID)
			if ControlGetVisible(ProjectWindowID)=0{
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
    global PT_MAIN_HWND:= WinExist("ahk_class DigiAppWndClass","")
    
	if PT_MAIN_HWND == 0    
        return 0   
    
	ToggleMainWindow(PT_MAIN_HWND)	

	if PT_IS_FULLSCREEN
		SetTimer ControlTimer, 1000
	else
		SetTimer ControlTimer, -1000 ; negative means run once in specified interval
    
	; Send Ctrl + =  twice, force a redraw
    WinActivate PT_MAIN_HWND    
    Send "^="    
    Send "^="    
}

ToggleMainWindow(hWnd){
	global PT_IS_FULLSCREEN	
	global PT_MONITOR
	global CUSTOM_WIDTH
	global INI_WINDOW_WIDTH
	global SHOW_PROJECT_NAME

	if !WinExist(hWnd)
        return false	

    if !IsWindowStyled(hWnd){
        ToggleStyles hWnd        
		MonitorGetWorkArea(PT_MONITOR, &Left, &Top, &Right, &Bottom)
        if CUSTOM_WIDTH
			WinMove Left, Top, INI_WINDOW_WIDTH, Bottom - Top, hWnd
		else
			WinMove Left, Top, Right - Left, Bottom - Top, hWnd
		PT_IS_FULLSCREEN:=true
    }
    else{
        ToggleStyles hWnd
       WinRestore hWnd
		PT_IS_FULLSCREEN:=false
    }
	
	if SHOW_PROJECT_NAME 
		DisplayProjectName (PT_IS_FULLSCREEN)
}

ToggleControl(hWnd){
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
		}
    }
}

ToggleStyles(hWnd){
	WinSetStyle "^0x040000", hWnd ; WS_SIZEBOX    
	WinSetStyle "^0xC00000", hWnd ; WS_CAPTION
}

IsWindowStyled(hWnd){
	if !WinExist(hWnd)	
        return false
	
	if WinGetStyle(hWnd) & 0x40000
			return false
		else    
			return true	
}

GetMDIWindow(hWnd, ID)
{	
    try{		
		return ControlGetHwnd(ID,hWnd)
	}
    catch 		
		return false   
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
		try {
		ProjectWindowID.Hide
		} catch
			{}
}
