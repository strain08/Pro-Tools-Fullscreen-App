#Requires AutoHotkey v2.0

ptfsSettingsMap:=Map()

; ptfsSettingsMap[PROPERTY]:=['Section', 'Name', 'Default value']

iSection:=1
iName:=2
iDefaultValue:=3

; Show project name when window in focus
; Default: true
ptfsSettingsMap["SHOW_PROJECT_NAME"]:=['General', 'Show_Project_Name', true]

; Keep main window border and menu
; Default: false
ptfsSettingsMap["KEEP_MAIN_WINDOW"]:=['General', 'Keep_Main_Window', false]

; Works only when KEEP_MAIN_WINDOW = true
; true: wil use WM_BORDER as window style; false: remove all borders from edit and mix windows
; Prevents glitching on 1080p monitors at least
; Default: true
ptfsSettingsMap["THIN_BORDER"]:=['General', 'Thin_Border', true]

; Toggles full screen mode when Pro Tools starts
; Default: false
ptfsSettingsMap["AUTO_FULLSCREEN"]:=['General', 'Auto_Fullscreen', false]

; True: Read main window width from INI file.
; Default: False (Use PT_MONITOR width)
ptfsSettingsMap["CUSTOM_WIDTH"]:=['WindowSize', 'Custom_Width', false]

; Pro Tools Window width when CUSTOM_WIDTH = true
ptfsSettingsMap["INI_WINDOW_WIDTH"]:=['WindowSize', 'WindowWidth', 0]

class AppSettings{

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

    SaveSettings(){
        for k,v in ptfsSettingsMap{
            IniWrite(this.%k%, this.INI_FILE, v[iSection], v[iName])
        }

    }

    LoadSettings()
    {
        for k,v in ptfsSettingsMap{
            defaultValue:=0
            ; compute default values for some keys being read from INI file
            switch k, false{
                case "INI_WINDOW_WIDTH":
                    MonitorGetWorkArea(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
                    defaultValue:= Right-Left
                default:
                    defaultValue:= v[iDefaultValue]
            }
            this.%k%:= this.ReadSetting(v[iSection], v[iName], defaultValue)
        }
    }
}