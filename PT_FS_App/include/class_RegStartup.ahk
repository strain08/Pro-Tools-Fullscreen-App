#Requires AutoHotkey v2

class RegStartup {
    __New(AppName, AppExecutable) {
        this.AppName:=AppName
        this.AppExecutable:=AppExecutable
    }
    HK_RUN:="HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"

    IsEnabled(){
        try {
            RegRead(this.HK_RUN, this.AppName)
            return true
        }
        catch{
            return false
        }
    }

    Set(Enable){
        if Enable
            this.Enable()
        else
            this.Disable()
    }

    Enable(){
        try{
            this.Disable()
        }

        try{
        RegWrite(this.AppExecutable,"REG_SZ", this.HK_RUN, this.AppName)
        }
        catch
            MsgBox "Error writing to registry."
    }

    Disable(){
        try{
            RegDelete(this.HK_RUN, this.AppName)
        }
    }
}