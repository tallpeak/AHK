#Requires AutoHotkey v2.0
#SingleInstance force

#Include "*i MyGlobalShortcuts.AHK" ; misc (Ctrl-Alt-T to open Windows Terminal, to start)

#Include "AppVol.AHK"

; Version 0.2
; Get ryzenadj.exe from https://github.com/FlyGoat/RyzenAdj
; Then edit the following line per your system:
global RYZENADJ := "C:/tools/bin/ryzenadj-win64/ryzenadj.exe"
global outputTitle := true  ; update the title bar if AHK_EXE GTA5.EXE
; OnExit occurs upon Reload, which is one behavior I didn't like
global revert_onexit := false ; if true, put it back to original slow_limit before exit

; stream outline (twitch.tv/sqlexpert on 9/21/2023; will expire in 2 weeks) :
; What is RyzenAdj.exe? (for AMD APUs; eg. laptop CPUs)
; What is the SMU? system management unit? 32-CPU
; Why RyzenAdj, and this script? (save power when looping AFK mission overnight)
; Why target 6 watts, <15 watts, etc (avoid thermal throttle when running @25W target)
; Why use title bar for output? (in case user goes full-screen, as I have not found a good overlay solution)
; Why initial UI (looping while holding a key)? (easy to use and understand)
; Why later UI (two digits)? (less clunky)
; How I supported both UIs...
; Why reload_as_admin? (and how...)
; Walkthrough of some parts of the script.

global Volume := 50
global VolumeIncrement := 5

; for running as a standalone script:
if InStr(A_ScriptFullPath, "RyzenAdj.ahk") {
	outputTitle := false
	global GTAtitle := "unknown"
	global GTAwindow := "A"
	Hotkey("CTRL & ALT & UP",AppVolUp)
	Hotkey("CTRL & ALT & DOWN",AppVolDown)
}


rShowVolume()
{
	WinSetTitle(GTAtitle "`: V" Volume, GTAwindow)
}


; hold shift down for slowly changing volume:
AppVolUp(hknm) {
	;ttl := WinGetTitle("A")
	;if ttl.Contains("Chrome") {
	;	Send "{Ctrl Up}"
	;}
	Loop
	{
		if (GetKeyState("Shift", "P")) {
			global Volume:=Volume + 1
		} else
			global Volume:=Volume + VolumeIncrement
		If (Volume > 100)
			global Volume := 100
		rShowVolume()
		rSetVolume()
		Sleep(10)
		if (! GetKeyState("Up", "P") )
			break
	}
    rsetVolume()
}

AppVolDown(hknm) {
	Loop
	{
		if (GetKeyState("Shift", "P")) {
			global Volume:=Volume - 1
		} else
			global Volume:=Volume - VolumeIncrement

		If (Volume < 0)
			global Volume := 0
		rShowVolume()
		rSetVolume()
		Sleep(10)
		if (! GetKeyState("Down", "P") )
			break
	}
    rsetVolume()
}

rsetVolume()
{
	ErrorLevel := ProcessExist("GTA5.exe")
	global ProcessId := ErrorLevel
    rSetAppVolume(ProcessId, Volume)
}

rSetAppVolume(PID, MasterVolume)    ; WIN_V+
{
	AppVol("A",MasterVolume)
}



global Ryzen_milliwatts := 0 ; slow-limit
global Ryzen_milliwatts_default := 0
global Ryzen_milliwatts_last_set := Ryzen_milliwatts
global Ryzen_milliwatt_increment := 250
global Ryzen_milliwatts_min := 5500  ; A reasonable minimum power level; for lower levels (eg 4 watts) use control-alt-p 0 4
global Ryzen_milliwatts_max := 30000 ; AMD 5625U default stapm_limit for my HP 17
global Ryzen_milliwatts_min_restore := 13000  ; return to at least this wattage upon exit (only for my possibly-defective AMD 5625U!)

; elevate by restarting the script with *RunAs
reload_as_admin() {
	; the RegExMatch was supposed to prevent accidental endless loop,
	; but not needed for my use-case
	if not (A_IsAdmin ) ;;;; or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		try
		{
			if A_IsCompiled {
				Run("thisisoneargument")
				; Run('*RunAs "' . A_ScriptFullPath . '" /restart')
				Run('*RunAs "' . A_AhkPath . '" /restart "' . A_ScriptFullPath . '"')
			} else {
				Run('*RunAs "' . A_AhkPath . '" /restart "' . A_ScriptFullPath . '"')
			}
		}
		catch as e {
			WinSetTitle(e.Message)
		}
		ExitApp
	}
}

;~ | STAPM LIMIT         |    30.000 | stapm-limit        |
;~ | PPT LIMIT FAST      |    30.000 | fast-limit         |
;~ | PPT LIMIT SLOW      |     7.750 | slow-limit         |
;~ | StapmTimeConst      |     1.000 | stapm-time         |
;~ | SlowPPTTimeConst    |     5.000 | slow-time          |
;~ | PPT LIMIT APU       |    25.000 | apu-slow-limit     |
;~ | TDC LIMIT VDD       |    33.000 | vrm-current        |
;~ | TDC LIMIT SOC       |    13.000 | vrmsoc-current     |
;~ | EDC LIMIT VDD       |    70.001 | vrmmax-current     |
;~ | EDC LIMIT SOC       |    17.000 | vrmsocmax-current  |
;~ | THM LIMIT CORE      |    80.001 | tctl-temp          |
;~ | STT LIMIT APU       |    35.000 | apu-skin-temp      |
;~ | STT LIMIT dGPU      |     0.000 | dgpu-skin-temp     |

get_Ryzen_adj_info() {
	if ! A_IsAdmin {
		reload_as_admin()
	}
	outputfile := A_Temp "/ryzenadj-info.txt"
	cmd := A_ComSpec " /c " RYZENADJ " --info > " outputfile
	RunWait(cmd,,"Hide")
	text := FileRead(outputfile)
	slowLimit := 0
	Loop Parse text, "`r`n" {
		pos := RegExMatch(A_LoopField, "[|][^|]+[|]([^|]+)[|]([^|]+)[|]", &m)
		if pos && m.Count >= 2 {
			v := m[1]
			p := trim(m[2])
			switch(p) {
				case "slow-limit":
					slowLimit := Integer(Float(v) * 1000)
					; MsgBox("slowLimit=" slowLimit)
			}
		}
	}
	if slowLimit > 0
	{
		global Ryzen_milliwatts := slowLimit
		global Ryzen_milliwatts_default := slowLimit
		global Ryzen_milliwatts_last_set := slowLimit
	}
}

; adjust power (mostly for throttling down)
; To use, hold down control-alt-+ or - until you reach the desired wattage
^!NumPadAdd::
{
	SetTimer(update_milliwatts, 0, 0)
	global Ryzen_milliwatts, Ryzen_milliwatts_last_set, Ryzen_milliwatts_max,  Ryzen_milliwatts_min, Ryzen_milliwatt_increment
	if (Ryzen_milliwatts == 0) {
		Ryzen_milliwatts := Ryzen_milliwatts_min
		get_Ryzen_adj_info()
	}
	Loop {
		global Ryzen_milliwatts += Ryzen_milliwatt_increment
		show_milliwatts()
		;Sleep(100)
		KeyWait("NumPadAdd","T0.1")
		if (! GetKeyState("NumPadAdd", "P") )
			break
	}
	;KeyWait("Ctrl")
	;KeyWait("Alt")
	SetTimer(update_milliwatts, -1500, 0)
}

; Reduce power in 0.25 watt increments, until minimum is reached
^!NumPadSub::{
	global Ryzen_milliwatts, Ryzen_milliwatts_last_set, Ryzen_milliwatts_max,  Ryzen_milliwatts_min, Ryzen_milliwatt_increment
	if (Ryzen_milliwatts == 0) {
		get_Ryzen_adj_info()
	}
	Loop {
		global Ryzen_milliwatts -= Ryzen_milliwatt_increment
		if Ryzen_milliwatts < Ryzen_milliwatts_min {
			Ryzen_milliwatts := Ryzen_milliwatts_min
		}
		show_milliwatts()
		;Sleep(100)
		KeyWait("NumPadSub","T0.1")
		if (! GetKeyState("NumPadSub", "P") )
			break
	}
    ;update_milliwatts()
	; make it async to make it possible to tap +/- as well as hold them down
	SetTimer(update_milliwatts, -1500, 0)
}

update_titlebar_inputhook(_InputHook, txt) {
	outMessage(txt)
}

; holding control-alt-NumPadAdd or Sub to select wattage works ok but feels goofy
; This seems better:
; ^!p = power, select 01 to 99 watts (limited by min and max above)
; Also, there is no minimum enforced (except 01 watt)
^!p::setWattage()

setWattage() {
	; hacky; need to change all settitles to use a single function that uses globals
	global last_keystate := "suspended"
	outMessage("Type 01 to 99 for watts,00/x/esc to abort")
	ih := InputHook("L2T5","{Esc}x")
	ih.Start()
	ih.OnChar := update_titlebar_inputhook
	ih.Wait()
	if ih.EndReason == "Max" {
		try {
			watts := Integer(ih.Input)
			if watts > 0 {
				global Ryzen_milliwatts := watts * 1000
				update_milliwatts()
			}
		}
	}
	global last_keystate := ""
}

clearToolTip() {
	ToolTip()
}

clearToolTipAfterDelay(ms) {
	SetTimer(clearToolTip, -ms, 0)
}

outMessage(msg) {
	global outputTitle
	if outputTitle {
		try {
			WinSetTitle(GTAtitle . ":" . msg, GTAwindow)
			return
		} catch {
			outputTitle := false
		}
	}
	; TrayTip(msg,,4) ; too annoying to have multiple badges
	ToolTip(msg)
	clearToolTipAfterDelay(2500)
}

show_milliwatts() {
	outMessage("adjusting to "  (Ryzen_milliwatts * 0.001) " watts")
}

update_milliwatts() {
	; SetTimer(set_milliwatts, -500, 0)
	show_milliwatts()
	set_milliwatts()
}

set_milliwatts() {
	global Ryzen_milliwatts, Ryzen_milliwatts_last_set, Ryzen_milliwatts_max,  Ryzen_milliwatts_min, Ryzen_milliwatt_increment
	;OutputDebug "A_IsAdmin: " A_IsAdmin "`nCommand line: " full_command_line
	if Ryzen_milliwatts == 0 {
		get_Ryzen_adj_info()
	}
	if A_IsAdmin {
		if Ryzen_milliwatts_last_set != Ryzen_milliwatts {
			;~ if Ryzen_milliwatts < Ryzen_milliwatts_min {
				;~ Ryzen_milliwatts := Ryzen_milliwatts_min
			;~ }
			if Ryzen_milliwatts > Ryzen_milliwatts_max {
				Ryzen_milliwatts := Ryzen_milliwatts_max
			}
			global last_keystate := "suspended"
			outputfile := A_Temp "/ryzenadj-output.txt"
			cmd := A_ComSpec " /c " RYZENADJ " --slow-limit=" Ryzen_milliwatts " --power-saving > " outputfile
			outMessage("running: " cmd)
			Run(cmd,,"Hide")
			Ryzen_milliwatts_last_set := Ryzen_milliwatts
			Sleep(1500)
			; OutputDebug outputfile
			try {
				text := FileRead(outputfile)
				outMessage(SubStr(StrReplace(StrReplace(text,"`r"," "),"`n"," "),1,120))
				Sleep(1000)
			}
			global last_keystate := ""
		}
	} else {
		outMessage("Can't run RyzenAdj; not admin! Reloading macros as admin...")
		Sleep(1000)
		reload_as_admin()
	}
}

revert_milliwatts(ExitReason, ExitCode) {
	global Ryzen_milliwatts, Ryzen_milliwatts_default, Ryzen_milliwatts_last_set
	if Ryzen_milliwatts_last_set > 0 && Ryzen_milliwatts_last_set != Ryzen_milliwatts_default {
		Ryzen_milliwatts := Ryzen_milliwatts_default
		if Ryzen_milliwatts < Ryzen_milliwatts_min_restore {
			Ryzen_milliwatts := Ryzen_milliwatts_min_restore
		}
		set_milliwatts()
	}
}

if revert_onexit {
	OnExit(revert_milliwatts , 1)
}

; This is really just for me; my audio dies sometimes
; (when on bluetooth and two applications contend for the audio),
; and this restarts it
^!PgUp::{
	Run("*RunAs c:\tools\bin\ssaudio.bat")
	return
}
; cat C:\tools\bin\ssaudio.bat
; net stop "Realtek Audio Universal Service"
; net stop "windows audio"
; net start "Realtek Audio Universal Service"
; net start "windows audio"

; google: turn bluetooth off and on windows 11 powershell https://techcommunity.microsoft.com/t5/windows-powershell/switch-bluetooth-off-and-on-via-powershell/m-p/2275616
; -->  https://superuser.com/questions/1168551/turn-on-off-bluetooth-radio-adapter-from-cmd-powershell-in-windows-10/1293303#1293303
;bluetooth off on
^!b::{
	RunWait("powershell bluetoothonoff.ps1 off")
	RunWait("powershell bluetoothonoff.ps1 on")
}