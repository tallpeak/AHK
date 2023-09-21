#Requires AutoHotkey v2.0
#SingleInstance force

global outputTitle := true

if InStr(A_ScriptFullPath, "RyzenAdj.ahk") {
	outputTitle := false
}
global Ryzen_milliwatts := 0 ; slow-limit
global Ryzen_milliwatts_last_set := Ryzen_milliwatts
global Ryzen_milliwatt_increment := 250
global Ryzen_milliwatts_min := 6000  ; A reasonable minimum power level; for lower levels (eg 4 watts) use control-alt-p 0 4
global Ryzen_milliwatts_max := 30000 ; AMD 5625U default stapm_limit for my HP 17

reload_as_admin() {
	; the RegExMatch was supposed to prevent accidental endless loop,
	; but not needed for my use-case
	if not (A_IsAdmin ) ;;;; or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		try
		{
			if A_IsCompiled {
				Run('*RunAs "' A_ScriptFullPath '" /restart')
			} else {
				Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
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
	cmd := A_ComSpec " /c C:/tools/bin/ryzenadj-win64\ryzenadj.exe --info > " outputfile
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
		global Ryzen_milliwatts_last_set := Ryzen_milliwatts
	}
}

; adjust power (mostly for throttling down)
^!NumPadAdd::
{
	global
	if (Ryzen_milliwatts < Ryzen_milliwatts_min) {
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
	SetTimer(update_milliwatts, -500, 0)
}

^!NumPadSub::{
	global
	if (Ryzen_milliwatts = 0) {
		Ryzen_milliwatts := Ryzen_milliwatts_min
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
	SetTimer(update_milliwatts, -500, 0)
}

update_titlebar_inputhook(_InputHook, txt) {
	outMessage(txt)
}

; holding control-alt-NumPadAdd or Sub to select wattage works ok but feels goofy
; This seems better:
; ^!p = power, select 01 to 99 watts (limited by min and max above)
^!p::{
	; hacky; need to change all settitles to use a single function that uses globals
	global last_keystate := "suspended"
	outMessage("Type 01 to 99 for watts,00/x/esc to abort")
	ih := InputHook("L2T5","{Esc}{Del}")
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


outMessage(msg) {
	if outputTitle {
		WinSetTitle(GTAtitle . msg, GTAwindow)
	} else {
		ToolTip(msg)
	}
}

show_milliwatts() {
	outMessage("`: adjusting to "  (Ryzen_milliwatts * 0.001) " watts")
}

update_milliwatts() {
	; SetTimer(set_milliwatts, -500, 0)
	show_milliwatts()
	set_milliwatts()
}

set_milliwatts() {
	global
	local cmd
	;OutputDebug "A_IsAdmin: " A_IsAdmin "`nCommand line: " full_command_line
	if Ryzen_milliwatts == 0 && Ryzen_milliwatts_last_set == 0 {
		get_Ryzen_adj_info()
	}
	if A_IsAdmin {
		if Ryzen_milliwatts_last_set != Ryzen_milliwatts {
			if Ryzen_milliwatts < Ryzen_milliwatts_min {
				Ryzen_milliwatts := Ryzen_milliwatts_min
			}
			if Ryzen_milliwatts > Ryzen_milliwatts_max {
				Ryzen_milliwatts := Ryzen_milliwatts_max
			}
			global last_keystate := "suspended"
			outputfile := A_Temp "/ryzenadj-output.txt"
			cmd := A_ComSpec " /c C:/tools/bin/ryzenadj-win64\ryzenadj.exe --slow-limit=" Ryzen_milliwatts " --power-saving > " outputfile
			WinSetTitle("running: " cmd, GTAwindow)
			Run(cmd,,"Hide")
			Ryzen_milliwatts_last_set := Ryzen_milliwatts
			Sleep(1500)
			; OutputDebug outputfile
			try {
				text := FileRead(outputfile)
				WinSetTitle(SubStr(StrReplace(StrReplace(text,"`r"," "),"`n"," "),1,120), GTAwindow)
				Sleep(1000)
			}
			global last_keystate := ""
		}
	} else {
		WinSetTitle("Can't run RyzenAdj; not admin! Reloading macros as admin...", GTAwindow)
		Sleep(1000)
		reload_as_admin()
	}
}


