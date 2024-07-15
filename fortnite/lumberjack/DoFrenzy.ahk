; agenda for stream 6/2/2024
; Basic usage (a few keybindings)
; How to use FindText; explain signal remote 1 vs 2
#WinActivateForce
#Requires AutoHotkey v2.0 

; #Include "FindTextv2_FeiYue_9.5.ahk"
; #Include "findtextv2_v9.7.ahk"

if A_LineFile = A_ScriptFullPath && !A_IsCompiled {
	FindText().ToolTip("Do not run DoFrenzy.ahk directly")
	Sleep(2000)
	ExitApp()
}

global EXTRA
EXTRA:=50
if A_ScreenWidth != 1600 {
	EXTRA:= A_ScreenWidth
}
SendMode("Event")

; FORTNITEWINDOW := "ahk_class UnrealWindow"
; FORTNITEPROCESS := "FortniteClient-Win64-Shipping.exe"
FORTNITEWINDOW := "ahk_exe FortniteClient-Win64-Shipping.exe"
; ^NumpadAdd::DoFrenzyAndChop()

; DoFrenzyAndChop() {
; 	try {
; 		MoveWindowToUpperRight()
; 	}
; 	DoFrenzy()	
; 	try {
; 		clicker_unfocused(false)
; 	}

; }

global SignalRemoteKey := "" ; getSignalRemoteKey() ; "1"

switchToRemote() 
{
	if ! SignalRemoteKey {
		getSignalRemoteKey()
	}
	while ! SignalRemoteKey {
		FindText().ToolTip("Waiting for signal remote to appear")
		Sleep(1000)
		getSignalRemoteKey()
	}  
	FindText().ToolTip()
	Send(SignalRemoteKey)
}

findtext_signalRemote()
{
	global EXTRA
	t1:=A_TickCount, Text:=X:=Y:=""
	xtra := EXTRA ; 100
	; Text:="|<remoteDown2>*1$13.00X001F0sUQ0AEA0402421V0QU3kE"
	Text.="|<remoteUp1>*1$13.00X001F0sUQ0AEA0402421V0AU0UE"
	Text.="|<SignalRemoteDown>*1$13.00X001F0sUQ0AEA0402421V0QU3kE" ; captured with v9.7
	Text.="|<SignalRemoteDown2>##101010$0/0/9B461C,0/-1/9B471D,-1/-3/A04D1F,-1/-7/B0602C,-1/-4/A35122,-1/-2/9D491D,-2/-6/B15C26,-2/-9/BD6B30,-2/-12/C6783C,-2/-13/C77B3F,-2/-15/C77F46,-8/-7/D36E1C,-8/-6/CE6A1B,-7/-7/D06D1E,-6/-5/C0611C"
	; if (ok:=FindText(&X, &Y, 1575-150000, 334-150000, 1575+150000, 334+150000, 0, 0, Text))
	Text.="|<SignalRemoteUp2>D7792F@0.80$13.zzQTgUCA7130XY3kXk1s0y0zUTzTk"
	; if (ok:=FindText(&X, &Y, 1561-150000, 327-150000, 1561+150000, 327+150000, 0, 0, Text))
	ok:=FindText(&X, &Y, 1561-xtra, 334-xtra, 1561+xtra, 334+xtra, 0.1, 0.1, Text)
	return ok
}

getSignalRemoteKey()
{
	global SignalRemoteKey
	oldSignalRemoteKey := SignalRemoteKey
	ok:=findtext_signalRemote()
	if !ok {
		return
	}
	xy:=ok[1]
	if xy.1 > A_ScreenWidth-30 {
		SignalRemoteKey := "2"
	} else {
		SignalRemoteKey := "1"
	}
	if oldSignalRemoteKey != SignalRemoteKey {
		FindText().ToolTip("SignalRemoteKey=" SignalRemoteKey, , "Timeout=1555")
		Sleep(2000)
		FindText().ToolTip()	
	}
	; global SignalRemoteKey
	; WinActivate(FORTNITEWINDOW)
	; sleep(333) 
	; SignalRemoteKey := InputBox("Enter signal remote key (eg. 1 or 2)","SignalRemoteKey",,"1").Value
	; sleep(333) 
	; WinActivate(FORTNITEWINDOW)
	; sleep(333)
	; every second until found, then every 30 secconds
	if SignalRemoteKey {
		SetTimer(getSignalRemoteKey,-30000)
	} else {
		SetTimer(getSignalRemoteKey,-1000)
	}
	; return SignalRemoteKey
}

SetTimer(getSignalRemoteKey, -1000)

DoFrenzy() {
	global EXTRA
	global SignalRemoteKey
	
	getSignalRemoteKey()

	; Try {
		WinActivate(FORTNITEWINDOW)
		Sleep(111)
		; WinWaitActive(FORTNITEWINDOW) ; gets stuck
		WinShow(FORTNITEWINDOW)
		Sleep(111)
		WinActivate(FORTNITEWINDOW)
		Sleep(111)
		; WinWaitActive(FORTNITEWINDOW)
		MoveWindowToUpperRight()
	; }
	
	Sleep(333)
	switchToRemote() ; 1 or 2

	; ; This might do it; scan for the black outline of the remote,
	; ; then determine whether it is "lifted" higher on the screen (Y=327 vs. 334):
	; Loop 3 {
	; 	t1:=A_TickCount, Text:=X:=Y:=""

	; 	signalremote_xtra:=10
	; 	if EXTRA > 100 {
	; 		signalremote_xtra := EXTRA
	; 	}

	; 	t1:=A_TickCount, Text:=X:=Y:=""
	; 	Text:="|<singleremoted>*1$13.00X001F0sUQ0AEA0402421V0AU0UE"
	; 	if (ok:=FindText(&X, &Y, 1561-signalremote_xtra, 327-signalremote_xtra*4, 1561+signalremote_xtra, 327+signalremote_xtra*4, 0.01, 0.01, Text))
	; 	{
	; 	  FindText().ToolTip(X "," Y)
	; 	  Sleep(2000)
	; 	  if Y < 330 {
	; 		Send("{WheelUp}")
	; 		break
	; 	  }
	; 	}
	; 	Send("{WheelDown}")
	; }

	; t1:=A_TickCount, Text:=X:=Y:=""
	; Text:="|<signalRemoteD_text>*200$48.5YNQEKE8BQNRG5OOp4FQG1+O5ZJ5EuO8U"
	; if (ok:=FindText(&X, &Y, 1493-signalremote_xtra, 341-signalremote_xtra, 1493+signalremote_xtra, 341+signalremote_xtra, 0.01, 0.01, Text))

	Sleep(666)
	Send("{RButton}")
	Sleep(555)
	Send("{RButton}")
	Sleep(555)

	FindText().ToolTip("Searching for GoldenTree", WINWIDTH - 150, 50)
	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	; Text:="|<GoldenTree>*11$47.Ml7797bDOm/8O2/G4YGQo4Gxd8YVM8t9KFN2kF+AMvXYUWLU"
	; if (ok:=FindText(&X, &Y, 1228-EXTRA, 145-EXTRA, 1228+EXTRA, 145+EXTRA, 0.01, 0.01, Text))
	xtra:=EXTRA
	Text:="|<GOLDEN_TREE>*31$52.Ml7797bCSpYKEo4KV8GF9nEF/bh94Y/178GJYKEg4GV6ARlmEF/bU"
	if (ok:=FindText(&X, &Y, 1231-xtra, 145-xtra, 1231+xtra, 145+xtra, 0.05, 0.05, Text))
	{
		Sleep(333)
		FindText().Click(X, Y, "L")
	} else { 
		FindText().ToolTip("failed findtext_GoldenTree")
		return
	}
	FindText().ToolTip("Searching for Frenzy", WINWIDTH - 150, 50)
	Sleep(555)
	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	; Text:="|<Frenzy>*11$29.vb9CH5cOAe9QoFrQVNVcZ2m2F/Yj4U"
	; if (ok:=FindText(&X, &Y, 1057-EXTRA, 241-EXTRA, 1057+EXTRA, 241+EXTRA, 0.01, 0.01, Text))
	Text:="|<FRENZY>*31$29.vb9CH5cOAe9QoFrQVNVcZ2m2F/Yj4U"
	if (ok:=FindText(&X, &Y, 1057-EXTRA, 241-EXTRA, 1057+EXTRA, 241+EXTRA, 0.01, 0.01, Text))
	{
		Sleep(333)
		FindText().Click(X, Y, "L")
	} else { 
		FindText().ToolTip("failed findtext_Frenzy")
		return
	}
	FindText().ToolTip("Searching for Activate", WINWIDTH - 150, 50)
	Sleep(333)
	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	; Text:="|<ACTIVATE>*11$53.C03v8EsyywT7qNXlxVcn6An6VX2F0ANa937wm0Ml8n6ATaMlWFyAMnDVX7XAMz303664Aly"
	; if (ok:=FindText(&X, &Y, 1064-EXTRA, 307-EXTRA, 1064+EXTRA, 307+EXTRA, 0.01, 0.01, Text))
	Text:="|<ACTIVATE>*31$52.wTjqNXnxzFaANaB36960laMYATaM3696MlXtaAMoTX69bslXlaAT363664Aly"
	if (ok:=FindText(&X, &Y, 1065-EXTRA, 307-EXTRA, 1065+EXTRA, 307+EXTRA, 0.01, 0.01, Text))
	{
		Sleep(333)
		FindText().Click(X, Y, "L")
	} else { 
		FindText().ToolTip("failed findtext_ACTIVATE")
		return
	}
	Sleep(333)
	; signal remote is 1, then Click("WheelUp") else Click("WheelDown") should work to move back to pickaxe
	; if SignalRemoteKey = "1" {
	; 	Click("WheelUp")
	; } else {
	; 	Click("WheelUp")
	; }
	pickaxe() ; my key binding for pickaxe?
	Sleep(333)
}