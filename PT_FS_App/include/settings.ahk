#Requires AutoHotkey v2.0

class ptfsSettings{
    __New(INI_FILE) {
        this.INI_FILE:=INI_FILE
        this.LoadSettings()
    }

    ReadSetting(Section, Name, Default){
        try{
            value:=IniRead(this.INI_FILE, Section, Name)
            ; switch case-insensitive
            switch value, false{
                case "true":
                    return 1
                case "false":
                    return 0
                default:
                    return Number(value)
            }
        }
        catch{
            IniWrite(Default,this.INI_FILE,Section, Name)
            return Default
        }
    }

    LoadSettings()
    {
        this.INI_FILE:=INI_FILE
        ; Show project name when window in focus
        ; Default: true
        this.SHOW_PROJECT_NAME:= this.ReadSetting("General", "Show_Project_Name", true)

        ; Keep main window border and menu
        ; Default: false
        this.KEEP_MAIN_WINDOW:= this.ReadSetting("General", "Keep_Main_Window", false)

        ; Works only when KEEP_MAIN_WINDOW = true
        ; true: wil use WM_BORDER as window style; false: remove all borders from edit and mix windows
        ; Prevents glitching on 1080p monitors at least
        ; Default: true
        this.THIN_BORDER:= this.ReadSetting("General", "Thin_Border", true)

        ; Toggles full screen mode when Pro Tools starts
        ; Default: false
        this.AUTO_FULLSCREEN:= this.ReadSetting("General", "Auto_Fullscreen", false)

        ; Monitor to make Pro Tools full screen on.
        ; Default: MonitorGetPrimary()
        this.PT_MONITOR:= this.ReadSetting("WindowSize", "PT_Monitor", MonitorGetPrimary())

        ; True: Read main window width from INI file.
        ; Default: False (Use PT_MONITOR width)
        this.CUSTOM_WIDTH:= this.ReadSetting("WindowSize", "Custom_Width", false)

        ; Pro Tools Window width when CUSTOM_WIDTH = true
        MonitorGetWorkArea(this.PT_MONITOR, &Left, &Top, &Right, &Bottom)
        this.INI_WINDOW_WIDTH:=this.ReadSetting("WindowSize", "WindowWidth", Right - Left )
    }
}