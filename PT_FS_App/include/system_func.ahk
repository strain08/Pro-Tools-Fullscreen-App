#Requires AutoHotkey v2.0

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