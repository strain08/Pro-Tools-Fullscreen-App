#Requires AutoHotkey v2
#SingleInstance Force
/*
-------------------------------------
PT_FS_App - Make Pro Tools borderless
Version: 1.0.0b
-------------------------------------
*/

; >>>>> Configure

; shortcut
PrintScreen:: TogglePTFullScreen()

; Monitor to make Pro Tools full screen on.
; Default: MonitorGetPrimary()
PT_MONITOR:= MonitorGetPrimary()

; Custom window width. 
; True: Read the window width from INI file.
; False (default): Use PT_MONITOR width. 
CUSTOM_WIDTH:= false

; Configure <<<<<<

INI_PATH:=A_ScriptDir "\"
INI_FILE:=INI_PATH "PTFS_App.ini"
INI_SECTION_SIZE:= "WindowSize"
INI_KEY_WIDTH:= "WindowWidth"
INI_WINDOW_WIDTH:= IniRead(INI_FILE, INI_SECTION_SIZE, INI_KEY_WIDTH, -1)
if INI_WINDOW_WIDTH == -1{
	MonitorGetWorkArea(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
	IniWrite(INI_WINDOW_WIDTH:= Right - Left, INI_FILE, INI_SECTION_SIZE, INI_KEY_WIDTH)
}else
	CUSTOM_WIDTH:=true
	
PT_IS_FULLSCREEN:=false
PT_MAIN_HWND:=0

ControlTimer(){
	if PT_MAIN_HWND = 0
		return
	pt_edit_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Edit:")
    pt_mix_hWnd:= GetMDIWindow(PT_MAIN_HWND, "Mix:")    
	ToggleControl(pt_mix_hWnd)
    ToggleControl(pt_edit_hWnd)
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
    try           
		return ControlGetHwnd(ID,hWnd)    
    catch 		
		return false   
}

