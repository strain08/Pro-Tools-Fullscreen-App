#Requires AutoHotkey v2.0

ToggleStyles(hWnd, thinBorder:=false){
	if !WinExist(hWnd)
        return
	try {
		if thinBorder {
			WinSetStyle "^0xC00000", hWnd ; WS_CAPTION
			WinSetStyle "^0x080000", hWnd ; WS_BORDER (thin border)
			return
		}
		WinSetStyle "^0x040000", hWnd ; WS_SIZEBOX
		WinSetStyle "^0xC00000", hWnd ; WS_CAPTION
	}
}

IsWindowStyled(hWnd, thinBorder:=false){
	if !WinExist(hWnd)
        return false

	if thinBorder{
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


