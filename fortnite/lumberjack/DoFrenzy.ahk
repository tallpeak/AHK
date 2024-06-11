; agenda for streem 6/2/2024
; Basic usage (a few keybindings)
; How to use FindText; explain signal remote 1 vs 2
#WinActivateForce
#Requires AutoHotkey v2.0 

; #Include "FindTextv2_FeiYue_9.5.ahk"
#Include "findtextv2_v9.6.ahk"

if A_LineFile = A_ScriptFullPath && !A_IsCompiled {
	ToolTip("Do not run DoFrenzy.ahk directly")
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

global SignalRemoteKey := "1" ; getSignalRemoteKey() ; "1"

findtext_signalRemote()
{
	global EXTRA
	t1:=A_TickCount, Text:=X:=Y:=""
	xtra := EXTRA ; 100
	Text:="|<remoteDown2>*1$13.00X001F0sUQ0AEA0402421V0QU3kE"
	Text.="|<remoteUp1>*1$13.00X001F0sUQ0AEA0402421V0AU0UE"
	ok:=FindText(&X, &Y, 1561-xtra, 334-xtra, 1561+xtra, 334+xtra, 0, 0, Text)
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
		ToolTip("SignalRemoteKey=" SignalRemoteKey)
		Sleep(2000)
		ToolTip()	
	}
	; global SignalRemoteKey
	; WinActivate(FORTNITEWINDOW)
	; sleep(333) 
	; SignalRemoteKey := InputBox("Enter signal remote key (eg. 1 or 2)","SignalRemoteKey",,"1").Value
	; sleep(333) 
	; WinActivate(FORTNITEWINDOW)
	; sleep(333)
	SetTimer(getSignalRemoteKey,60000)
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
	
	; need to find/create a stable keybinding for remote
	; it seems to change randomly
	Sleep(111)

	;FIXME!!!
	;Send(Chr(96)) ; pickaxe, for testing
	; Send("1") ; remote?
	; Send("2") ; remote is sometimes 2
	if SignalRemoteKey = "" {
		getSignalRemoteKey()
	}
	Sleep(333)
	Send(SignalRemoteKey)

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
	; 	if (ok:=FindText(&X, &Y, 1561-signalremote_xtra, 327-signalremote_xtra*4, 1561+signalremote_xtra, 327+signalremote_xtra*4, 0, 0, Text))
	; 	{
	; 	  ToolTip(X "," Y)
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
	; if (ok:=FindText(&X, &Y, 1493-signalremote_xtra, 341-signalremote_xtra, 1493+signalremote_xtra, 341+signalremote_xtra, 0, 0, Text))

	Sleep(555)
	Send("{RButton}")
	Sleep(888)

	ToolTip("Searching for GoldenTree", WINWIDTH - 150, 50)
	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	Text:="|<GoldenTree>*11$47.Ml7797bDOm/8O2/G4YGQo4Gxd8YVM8t9KFN2kF+AMvXYUWLU"
	if (ok:=FindText(&X, &Y, 1228-EXTRA, 145-EXTRA, 1228+EXTRA, 145+EXTRA, 0, 0, Text))
	{
		Sleep(333)
		FindText().Click(X, Y, "L")
	}
	ToolTip("Searching for Frenzy", WINWIDTH - 150, 50)
	Sleep(333)
	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	Text:="|<Frenzy>*11$29.vb9CH5cOAe9QoFrQVNVcZ2m2F/Yj4U"
	if (ok:=FindText(&X, &Y, 1057-EXTRA, 241-EXTRA, 1057+EXTRA, 241+EXTRA, 0, 0, Text))
	{
		Sleep(333)
		FindText().Click(X, Y, "L")
	}
	ToolTip("Searching for Activate", WINWIDTH - 150, 50)
	Sleep(333)
	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	Text:="|<ACTIVATE>*11$53.C03v8EsyywT7qNXlxVcn6An6VX2F0ANa937wm0Ml8n6ATaMlWFyAMnDVX7XAMz303664Aly"
	if (ok:=FindText(&X, &Y, 1064-EXTRA, 307-EXTRA, 1064+EXTRA, 307+EXTRA, 0, 0, Text))
	{
		Sleep(333)
		FindText().Click(X, Y, "L")
	}

	Sleep(333)
	; signal remote is 1, then Click("WheelUp") else Click("WheelDown") should work to move back to pickaxe
	; if SignalRemoteKey = "1" {
	; 	Click("WheelUp")
	; } else {
	; 	Click("WheelUp")
	; }
	Send(Chr(96)) ; my key binding for pickaxe?
	Sleep(333)
}