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

ResetMDIStyle(hWnd){
	try {
		WinSetStyle "0x57CF0000", hWnd
	}
}

IsWindowStyled(hWnd, thinBorder:=false){
	if !WinExist(hWnd)
        return false
	try {
		if thinBorder
			return !(WinGetStyle(hWnd) & 0xC00000)

		return  !(WinGetStyle(hWnd) & 0x40000)
	}
	catch{
		return false
	}
}

