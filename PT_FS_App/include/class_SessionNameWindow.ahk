#Requires AutoHotkey v2.0

; Displays the open session's name on top of menu bar
; in a window owned by Pro Tools main window
class SessionNameWindow{
    MyGui:=0
    boxWidth:=1350
    boxHeight:=20 ; menu height
    _visible:=false
    _owner:=0
    _monitorNumber:=0
    _projectName:=""
    TextID:=0

    __New(MonitorNumber) {
        this._monitorNumber:=MonitorNumber
        this.CreateGui()
    }

    CreateGui() {
        if this.MyGui {
            try this.MyGui.Destroy()
        }
        this.MyGui := Gui()
        this.MyGui.BackColor:= "White"
        WinSetTransColor("White", this.MyGui)
        this.MyGui.SetFont("s9 cBlack w700", "Segoe UI")
        this.TextID:= this.MyGui.AddText("x0 y2 w1200 h" this.boxHeight " Center", this._projectName)
        
        ; Initial options. If we already had an owner, re-apply it immediately
        ; to avoid taskbar flicker or ownership issues.
        opt := "-AlwaysOnTop -Caption -SysMenu +Owner"
        if this._owner
            opt .= this._owner
        
        this.MyGui.Opt(opt)
        this._visible := false
    }

    SetOwner(HWND){
        if (HWND == 0)
            return

        ; Ensure GUI window actually exists
        if !WinExist(this.MyGui)
            this.CreateGui()

        if (this._owner == HWND)
            return
            
        try {
            this.MyGui.Opt("+Owner" HWND)
            this._owner:=HWND
        }
    }

    ProjectName {
        set {
            this._projectName := Value
            try {
                if !WinExist(this.MyGui)
                    this.CreateGui()
                ControlSetText(Value, this.TextID)
            }
        }
        get => this._projectName
    }

    Visible{
        get => this._visible
        set{
            if Value{
                ; Ensure GUI exists
                if !WinExist(this.MyGui)
                    this.CreateGui()

                ; Show if not currently tracked as visible or if hidden externally (OS check)
                if !this._visible || !DllCall("IsWindowVisible", "Ptr", this.MyGui.Hwnd) {
                    MonitorGetWorkArea(this._monitorNumber, &Left, &Top, &Right, &Bottom)
                    this.MyGui.Show("X" Right - this.boxWidth "Y" Top "W" this.boxWidth "H" this.boxHeight " NoActivate" )
                    this._visible:=true
                }
            }
            else if this._visible {
                try {
                    this.MyGui.Hide()
                }
                this._visible:=false
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
        control_text:= ControlGetText(pt_edit_hWnd)
        ; remove leading "Edit: ", workaround weird LTrim bug that removes letter "E" from beginning of project name
		name:= SubStr(control_text, 7)
		return name
	}
	catch
		return ""
}