#Requires AutoHotkey v2.0

class projectWindow{
    ProjectWindowID := Gui()
    boxWidth:=1350
    boxHeight:=20 ; menu height

    __New(MonitorNumber) {
        MonitorGetWorkArea(MonitorNumber, &Left, &Top, &Right, &Bottom)
        ;this.ProjectWindowID.BackColor:="333333"
        this.ProjectWindowID.BackColor:= "White"
        ;this.ProjectWindowID.SetFont("s10 c38D177 w100")
        this.ProjectWindowID.SetFont("s10 cBlack w100")
        this.TextID:= this.ProjectWindowID.AddText("x0 y2 w1200 h" this.boxHeight " Center")
        this.ProjectWindowID.Show("h-" this.boxHeight " NoActivate")
        WinMove(Right - this.boxWidth, Top, this.boxWidth, this.boxHeight, this.ProjectWindowID)
        WinSetTransColor("White", this.ProjectWindowID)
        this.ProjectWindowID.Opt("+AlwaysOnTop -Caption +ToolWindow")
        this.ProjectWindowID.Hide
    }

    ProjectName {
        set => ControlSetText(Value, this.TextID)
    }

    Visible{
        set{
            if Value{
                ; only show if not visible, otherwise it will hide the window
                if !ControlGetVisible(this.ProjectWindowID){
                    this.ProjectWindowID.Show("NoActivate")

                }
            } else
                try this.ProjectWindowID.Hide
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
		pt_edit_hWnd:=GetMDIWindow(PT_MAIN_HWND, "Edit:")
		name:=LTrim(ControlGetText(pt_edit_hWnd),"Edit: ")
		return name
	}
	catch
		return ""
}