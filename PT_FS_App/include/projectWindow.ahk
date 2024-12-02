#Requires AutoHotkey v2.0
#Include windowOwner.ahk

class projectWindow{
    ProjectWindowID := Gui()
    boxWidth:=1350
    boxHeight:=20 ; menu height
    _visible:=false
    __New(MonitorNumber) {
        MonitorGetWorkArea(MonitorNumber, &Left, &Top, &Right, &Bottom)
        ;this.ProjectWindowID.BackColor:="333333"
        this.ProjectWindowID.BackColor:= "White"
        ;this.ProjectWindowID.SetFont("s10 c38D177 w100")
        this.ProjectWindowID.SetFont("s9 cBlack w700", "Segoe UI")
        this.TextID:= this.ProjectWindowID.AddText("x0 y2 w1200 h" this.boxHeight " Center")
        WinSetTransColor("White", this.ProjectWindowID)
        this.ProjectWindowID.Show("Hide h-" this.boxHeight " NoActivate")
        ; reset window owner
       ; WinSetOwner(this.ProjectWindowID.Hwnd)
        WinMove(Right - this.boxWidth, Top, this.boxWidth, this.boxHeight, this.ProjectWindowID)

        this.ProjectWindowID.Opt("-AlwaysOnTop -Caption +ToolWindow")
        this.ProjectWindowID.Hide
    }

    SetOwner(HWND){
        WinSetOwner(this.ProjectWindowID.Hwnd, HWND)
    }

    ResetOwner(){
        WinSetOwner(this.ProjectWindowID.Hwnd)
    }

    ProjectName {
        set => ControlSetText(Value, this.TextID)
    }

    Visible{
        set{
            if this._visible != Value{
                if Value{
                    ; only show if not visible, otherwise it will hide the window
                    if !ControlGetVisible(this.ProjectWindowID){
                            this.ProjectWindowID.Show("NoActivate")
                            this._visible:=true
                    }
                }
                else {
                    try {
                        ;WinSetOwner(this.ProjectWindowID.Hwnd)
                        this.ProjectWindowID.Hide
                        this._visible:=false
                    }
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
		pt_edit_hWnd:=MDIGetWindowHandle(PT_MAIN_HWND, "Edit:")
		name:=LTrim(ControlGetText(pt_edit_hWnd),"Edit: ")
		return name
	}
	catch
		return ""
}