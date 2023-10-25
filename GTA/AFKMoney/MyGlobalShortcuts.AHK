; MyGlobalShortcuts.AHK
#Requires AutoHotkey v2.0
#SingleInstance force

^!t::{
	try {
		WinActivate("AHK_EXE WindowsTerminal.EXE")
	} catch Error as e {
		;ToolTip(e.Message) ; "Target window not found"
		Run("C:\Users\tallp\AppData\Local\Microsoft\WindowsApps\wt.exe")
		;Sleep(5000)
		;ToolTip()
	}
}