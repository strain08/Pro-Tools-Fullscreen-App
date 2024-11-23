#Requires AutoHotkey v2.0.18+
;ProjectName:=true
MyGui:=Gui()
MyGui.Opt("+AlwaysOnTop -Disabled -SysMenu +Owner")
MyGui.Title:="Options"

MyGui.AddText(,'General')

MyGui.AddCheckbox('xm+8 vProjectName','Display project name')
MyGui.AddCheckbox('vKeepMainWindow','Keep main window')
MyGui.AddCheckbox('vThinBorder','Use thin border')

MyGui.AddText('xm yp+20','Window size')

MyGui.AddCheckbox('xm+8 vUseCustomWidth','Use custom width')
MyGui.AddText('yp+20 xp','Monitor:')

a:=[]
loop MonitorGetCount(){
    a.Push A_Index = MonitorGetPrimary() ? A_Index . '(P)' : A_Index
}
MyGui.AddDDL("vcbx xp w50 vMonitorNumber",a).Choose(MonitorGetPrimary())
MyGui.AddText('','Custom width:')
MyGui.AddEdit('xp w50','')

MyGui.AddButton('x10 yp+30 h30 w60','OK').OnEvent('Click',Ok_Click)
MyGui.AddButton('yp hp wp','Cancel').OnEvent('Click', Cancel_Click)
Cancel_Click(*){
    MyGui.Destroy()
}
Ok_Click(*){
    result:=MyGui.Submit(1)
    OutputDebug(result.ProjectName)
}


MyGui.Show('W150 H260')

