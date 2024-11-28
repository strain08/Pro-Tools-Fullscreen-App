#Requires AutoHotkey v2.0.18+
#SingleInstance Force
#Include saveWindowPosition.ahk

ShowSettingsGUI(appSettings){
    MyGui:=Gui()
    pos:=saveWindowPosition(MyGui,INI_FILE,"OptionsWindow")
    MyGui.Opt("+AlwaysOnTop -Disabled -SysMenu +Owner")
    MyGui.Title:="PTFS App"

    MyGui.AddText(,'General')
    MyGui.AddCheckbox('xm+8 vAUTO_FULLSCREEN','Auto-fullscreen').Value:=appSettings.AUTO_FULLSCREEN
    MyGui.AddCheckbox('xm+8 vSHOW_PROJECT_NAME','Display project name').Value:=appSettings.SHOW_PROJECT_NAME

    cmwcb:=MyGui.AddCheckbox('vKEEP_MAIN_WINDOW','Keep main window')
    cmwcb.Value:=appSettings.KEEP_MAIN_WINDOW
    cmwcb.OnEvent('Click', KeepMainWindow_Click)

    tbcb:=MyGui.AddCheckbox('vTHIN_BORDER','Use thin border')
    tbcb.Value:=appSettings.THIN_BORDER
    tbcb.Enabled:=appSettings.KEEP_MAIN_WINDOW

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
        pos.SavePosition()
        MyGui.Destroy()
    }

    Ok_Click(*){
        pos.SavePosition()
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
        tbcb.Enabled:=cmwcb.Value
    }
    CustomWidth_Change(*){
        for k,v in cWidth
            v.Enabled:=cwcb.Value
    }

    pos.LoadPosition()
    if pos.X != -1 || pos.Y != -1
        MyGui.Show( 'X' pos.X ' Y' pos.Y ' W150 H280')
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
    tray:=A_TrayMenu
    appVersion:= "PTFS App " appVersion
    TraySetIcon(A_ScriptDir . '\res\ptfsApp.ico')
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




