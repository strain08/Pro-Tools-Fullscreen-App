#Requires AutoHotkey v2.0

; Displays the open session's name on top of menu bar
; in a window owned by Pro Tools main window
class SessionNameWindow{
    MyGui := Gui()
    boxWidth:=1350
    boxHeight:=20 ; menu height
    _visible:=false
    __New(MonitorNumber) {
        this._monitorNumber:=MonitorNumber

        ;this.MyGui.BackColor:="333333"
        ;this.MyGui.SetFont("s10 c38D177 w100")
        this.MyGui.BackColor:= "White"
        WinSetTransColor("White", this.MyGui)
        this.MyGui.SetFont("s9 cBlack w700", "Segoe UI")
        this.TextID:= this.MyGui.AddText("x0 y2 w1200 h" this.boxHeight " Center")
        this.MyGui.Opt("-AlwaysOnTop -Caption -SysMenu +Owner")
    }

    SetOwner(HWND){
        try {
        this.MyGui.Opt("+Owner" HWND)
        }
    }

    ProjectName {
        set => ControlSetText(Value, this.TextID)
    }

    Visible{
        set{
            if this._visible != Value{
                if Value{
                    ; only show if not visible, otherwise it will hide the window
                    if !ControlGetVisible(this.MyGui){
                            MonitorGetWorkArea(this._monitorNumber, &Left, &Top, &Right, &Bottom)
                            this.MyGui.Show("X" Right - this.boxWidth "Y" Top "W" this.boxWidth "H" this.boxHeight " NoActivate" )
                            this._visible:=true
                    }
                }
                else {
                    try {
                        this.MyGui.Hide
                    }
                    this._visible:=false
                }

            }
        }
    }
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
		pt_edit_hWnd:= MDIGetWindowHandle(PT_MAIN_HWND, "Edit:")
		name:= LTrim(ControlGetText(pt_edit_hWnd),"Edit: ")
		return name
	}
	catch
		return ""
}