#Requires AutoHotkey v2.0.18+
#SingleInstance Force
#Include saveWindowPosition.ahk
#Include class_RegStartup.ahk

ShowSettingsGUI(appSettings){
    MyGui:=Gui()


    windowPosition:=saveWindowPosition(MyGui,INI_FILE,"OptionsWindow")
    MyGui.Opt("+AlwaysOnTop -Disabled -SysMenu +Owner")
    MyGui.Title:="PTFS App"

    MyGui.AddText(,'General')
    MyGui.AddCheckbox('xm+8 vAUTO_FULLSCREEN','Auto-fullscreen').Value:=appSettings.AUTO_FULLSCREEN
    MyGui.AddCheckbox('xm+8 vSHOW_PROJECT_NAME','Display project name').Value:=appSettings.SHOW_PROJECT_NAME

    cbKeepMainWindow:=MyGui.AddCheckbox('vKEEP_MAIN_WINDOW','Keep main window')
    cbKeepMainWindow.Value:=appSettings.KEEP_MAIN_WINDOW
    cbKeepMainWindow.OnEvent('Click', KeepMainWindow_Click)

    cbThinBorder:=MyGui.AddCheckbox('vTHIN_BORDER','Use thin border')
    cbThinBorder.Value:=appSettings.THIN_BORDER
    cbThinBorder.Enabled:=appSettings.KEEP_MAIN_WINDOW

    MyGui.AddText('xm yp+20','Window size')

    cbUseCustomWidth:=MyGui.AddCheckbox('xm+8 vCUSTOM_WIDTH','Use custom width')
    cbUseCustomWidth.OnEvent('Click',UseCustomWidth_Click)
    cbUseCustomWidth.Value:=appSettings.CUSTOM_WIDTH
    mapCustomWidthOptions:=Map() ; controls enabled when cbUseCustomWidth.Value = true

    mapCustomWidthOptions[1]:= MyGui.AddText('yp+20 xp','Monitor:')
    monitors:=[]
    loop MonitorGetCount(){
        monitors.Push A_Index
    }
    mapCustomWidthOptions[2]:=MyGui.AddDDL("vcbx xp w50 vPT_MONITOR",monitors)
    mapCustomWidthOptions[2].Choose(appSettings.PT_MONITOR)

    mapCustomWidthOptions[3]:=MyGui.AddText('','Custom width:')

    mapCustomWidthOptions[4]:=MyGui.AddEdit('xp w50 vINI_WINDOW_WIDTH','')
    mapCustomWidthOptions[4].Text:=appSettings.INI_WINDOW_WIDTH

    for k,v in mapCustomWidthOptions
        v.Enabled:=cbUseCustomWidth.Value

    MyGui.AddButton('x10 yp+30 h30 w60','OK').OnEvent('Click', Ok_Click)
    MyGui.AddButton('yp hp wp','Cancel').OnEvent('Click', Cancel_Click)

    Cancel_Click(*){
        windowPosition.SavePosition()
        MyGui.Destroy()
    }

    Ok_Click(*){
        windowPosition.SavePosition()
        result:=MyGui.Submit(true)
        for name,value in result.OwnProps() {
            value:=StrReplace(value,'(P)')
            appSettings.%name%:=value
        }
        appSettings.SaveSettings()
        MyGui.Destroy()
        Reload()
    }
    KeepMainWindow_Click(*){
        cbThinBorder.Enabled:= cbKeepMainWindow.Value
    }
    UseCustomWidth_Click(*){
        for k,v in mapCustomWidthOptions
            v.Enabled:=cbUseCustomWidth.Value
    }

    windowPosition.LoadPosition()
    if windowPosition.X != -1 || windowPosition.Y != -1
        MyGui.Show( 'X' windowPosition.X ' Y' windowPosition.Y ' W150 H280')
    else
        MyGui.Show( 'W150 H280')

    BottomRightPosition(W, H, &PosX, &PosY){
        mon:=MonitorGetPrimary()
        MonitorGetWorkArea(mon, &Left, &Top, &Right, &Bottom)
        PosX:= Right - W - 50
        PosY:= Bottom - H - 50
    }
}

BuildTrayMenu(appVersion, appSettings){
    global rs
    tray:=A_TrayMenu
    appVersion:= "PTFS App " appVersion

    TraySetIcon(A_ScriptDir . '\res\ptfsApp.ico')
    tray.Delete()

    tray.Add(appVersion, dummy)
    tray.Add("Run at startup", RunAtStartup_Click)
    if rs.IsEnabled(){
        tray.Check("Run at startup")
    }
    tray.Add("Options...", OptionsMenu_Click,"")
    tray.Add()
    tray.Add("Exit", ExitMenu_Click)
    tray.Disable(appVersion)

    ExitMenu_Click(*){
        ExitApp
    }

    dummy(*){

    }
    RunAtStartup_Click(*){
        if rs.IsEnabled(){
            rs.Disable()
            tray.Uncheck("Run at startup")
            return
        }
        rs.Enable()
        tray.Check("Run at startup")
    }

    OptionsMenu_Click(*){
        ShowSettingsGUI(appSettings)
    }
}




