#Requires AutoHotkey v2.0

ToggleStyles(hWnd, sizeMethod:=false){
	if sizeMethod {
		WinSetStyle "^0xC00000", hWnd ; WS_CAPTION
		WinSetStyle "^0x080000", hWnd ; WS_BORDER (thin border)
		return
	}
	WinSetStyle "^0x040000", hWnd ; WS_SIZEBOX
	WinSetStyle "^0xC00000", hWnd ; WS_CAPTION

}

IsWindowStyled(hWnd, sizeMethod:=false){
	if !WinExist(hWnd)
        return false
	if sizeMethod{
		if WinGetStyle(hWnd) & 0xC00000
			return false
		else
			return true
	}

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