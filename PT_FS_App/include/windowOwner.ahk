#Requires AutoHotkey v2.0

WinSetOwner(Hwnd, hOwner:=Unset)                           ;  By SKAN for ah2 on D48U/D48U @ autohotkey.com/r?t=94330
{
    Local GWL_HWNDPARENT := -8,   GW_CHILD := 5,    SW_RESTORE := 9

    If ( ! WinExist(Hwnd) )
        Return

    Local Class := WinGetClass( Integer(Hwnd) )
    If ( Class="WorkerW" || Class="Progman" )
         Return

    If ( IsSet(hOwner) = False )
        Return( A_PtrSize=8 ? DllCall("User32.dll\GetWindowLongPtr", "ptr",Hwnd, "int",GWL_HWNDPARENT, "ptr")
                            : DllCall("User32.dll\GetWindowLong",    "ptr",Hwnd, "int",GWL_HWNDPARENT, "ptr") )

    If ! ( DllCall("User32.dll\IsTopLevelWindow", "ptr",Hwnd) || WinSetOwner(Hwnd) )
        Return

    If ( hOwner != "SHELLDLL_DefView" )
         hOwner := Format("{:d}", hOwner)
    Else hOwner := DllCall("User32.dll\GetWindow"
                            , "ptr",Max( WinExist("ahk_class WorkerW", "FolderView")
                                       , WinExist("ahk_class Progman", "FolderView") )
                            , "int",GW_CHILD, "ptr")

    If DllCall("User32.dll\IsIconic", "ptr",Hwnd)
       DllCall("User32.dll\ShowWindow", "ptr",Hwnd, "int",SW_RESTORE)

    hOwner := WinExist( Integer( Format("{:d}", hOwner) ) )

    If ( A_PtrSize = 8 )
         DllCall("User32.dll\SetWindowLongPtr", "ptr",Hwnd, "int",GWL_HWNDPARENT, "int",hOwner ? hOwner : Gui().Hwnd)
    Else DllCall("User32.dll\SetWindowLong",    "ptr",Hwnd, "int",GWL_HWNDPARENT, "int",hOwner ? hOwner : Gui().Hwnd)

    Return( WinSetOwner(Hwnd) = hOwner )
}