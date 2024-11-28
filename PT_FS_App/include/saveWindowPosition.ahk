#Requires AutoHotkey v2.0

class saveWindowPosition{
    X:=0
    Y:=0
    __New(MyGui, INI_FILE, windowName) {
        this.MyGui:=MyGui
        this.INI_FILE:=INI_FILE
        this.windowName:=windowName
    }
    SavePosition(){
        this.MyGui.GetPos(&X,&Y)
        this.X:=X
        this.Y:=Y
        IniWrite(this.X, this.INI_FILE, this.windowName, "WinX")
        IniWrite(this.Y, this.INI_FILE, this.windowName, "WinY")
    }
    LoadPosition(){
        this.X:= IniRead(this.INI_FILE, this.windowName, "WinX", -1)
        this.Y:= IniRead(this.INI_FILE, this.windowName, "WinY", -1)
    }
}




