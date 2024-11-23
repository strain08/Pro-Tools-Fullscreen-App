#Requires AutoHotkey v2.0.18+
#SingleInstance Force

ShowSettingsGUI(appSettings){
    MyGui:=Gui()
    MyGui.Opt("+AlwaysOnTop -Disabled -SysMenu +Owner")
    MyGui.Title:="Options"

    MyGui.AddText(,'General')

    MyGui.AddCheckbox('xm+8 vSHOW_PROJECT_NAME','Display project name').Value:=appSettings.SHOW_PROJECT_NAME
    MyGui.AddCheckbox('vKEEP_MAIN_WINDOW','Keep main window').Value:=appSettings.KEEP_MAIN_WINDOW
    MyGui.AddCheckbox('vTHIN_BORDER','Use thin border').Value:=appSettings.THIN_BORDER

    MyGui.AddText('xm yp+20','Window size')

    cwcb:=MyGui.AddCheckbox('xm+8 vCUSTOM_WIDTH','Use custom width')
    cwcb.OnEvent('Click',CustomWidth_Change)
    cwcb.Value:=appSettings.CUSTOM_WIDTH
    cWidth:=Map()

    cWidth[1]:= MyGui.AddText('yp+20 xp','Monitor:')
    a:=[]
    loop MonitorGetCount(){
        a.Push A_Index
    }
    cWidth[2]:=MyGui.AddDDL("vcbx xp w50 vPT_MONITOR",a)
    cWidth[2].Choose(appSettings.PT_MONITOR)

    cWidth[3]:=MyGui.AddText('','Custom width:')

    cWidth[4]:=MyGui.AddEdit('xp w50 vINI_WINDOW_WIDTH','')
    cWidth[4].Text:=appSettings.INI_WINDOW_WIDTH

    for k,v in cWidth
        v.Enabled:=cwcb.Value

    MyGui.AddButton('x10 yp+30 h30 w60','OK').OnEvent('Click', Ok_Click)
    MyGui.AddButton('yp hp wp','Cancel').OnEvent('Click', Cancel_Click)

    Cancel_Click(*){
        MyGui.Destroy()
    }

    Ok_Click(*){
        result:=MyGui.Submit(true)
        for name,value in result.OwnProps() {
            value:=StrReplace(value,'(P)')
            appSettings.%name%:=value
        }
        appSettings.SaveSettings()
        MyGui.Destroy()
        Reload()
    }

    CustomWidth_Change(*){
        for k,v in cWidth
            v.Enabled:=cwcb.Value
    }
    MyGui.Show('W150 H260')
}

BuildTrayMenu(appVersion, appSettings){
    tray:=A_TrayMenu
    tray.Delete()
    tray.Add(appVersion, dummy)
    tray.Add("Options", OptionsMenu_Click)
    tray.Add("Exit", ExitMenu_Click)
    tray.Disable(appVersion)

    ExitMenu_Click(*){
        ExitApp
    }

    dummy(*){

    }

    OptionsMenu_Click(*){
        ShowSettingsGUI(appSettings)
    }
}




