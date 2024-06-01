#Include "FindTextv2_FeiYue_9.5.ahk"

global XTRA
XTRA:=50
if A_ScreenWidth > 1920 {
	XTRA:=5000
}
SendMode("Event")

FORTNITEWINDOW := "ahk_class UnrealWindow"
FORTNITEPROCESS := "FortniteClient-Win64-Shipping.exe"

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

DoFrenzy() {
	global XTRA

	Try {
		WinActivate(FORTNITEWINDOW)
		WinWaitActive(FORTNITEWINDOW)
		WinShow(FORTNITEWINDOW)
		WinActivate(FORTNITEWINDOW)
		WinWaitActive(FORTNITEWINDOW)
		MoveWindowToUpperRight()
	}
	
	; need to find/create a stable keybinding for remote
	; it seems to change randomly
	Sleep(333)
	;FIXME!!!
	Send(Chr(96)) ; pickaxe, for testing
	; Send("1") ; remote?
	; Send("2") ; remote is sometimes 2

	; This might do it; scan for the black outline of the remote,
	; then determine whether it is "lifted" higher on the screen (Y=327 vs. 334):
	Loop 3 {
		t1:=A_TickCount, Text:=X:=Y:=""

		signalremote_xtra:=10
		Text:="|<singleremoted>*1$13.00X001F0sUQ0AEA0402421V0AU0UE"
		if (ok:=FindText(&X, &Y, 1561-signalremote_xtra, 327-signalremote_xtra*4, 1561+signalremote_xtra, 327+signalremote_xtra*4, 0, 0, Text))
		{
		  ToolTip(X "," Y)
		  Sleep(2000)
		  if Y < 330 {
			Send("{WheelUp}")
			break
		  }
		}
		Send("{WheelDown}")
	}

	Sleep(555)
	Send("{RButton}")
	Sleep(888)

	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	Text:="|<GoldenTree>*11$47.Ml7797bDOm/8O2/G4YGQo4Gxd8YVM8t9KFN2kF+AMvXYUWLU"
	if (ok:=FindText(&X, &Y, 1228-XTRA, 145-XTRA, 1228+XTRA, 145+XTRA, 0, 0, Text))
	{
		Sleep(222)
		FindText().Click(X, Y, "L")
	}
	Sleep(666)
	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	Text:="|<Frenzy>*11$29.vb9CH5cOAe9QoFrQVNVcZ2m2F/Yj4U"
	if (ok:=FindText(&X, &Y, 1057-XTRA, 241-XTRA, 1057+XTRA, 241+XTRA, 0, 0, Text))
	{
		Sleep(666)
		FindText().Click(X, Y, "L")
	}
	Sleep(666)
	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	Text:="|<ACTIVATE>*11$53.C03v8EsyywT7qNXlxVcn6An6VX2F0ANa937wm0Ml8n6ATaMlWFyAMnDVX7XAMz303664Aly"
	if (ok:=FindText(&X, &Y, 1064-XTRA, 307-XTRA, 1064+XTRA, 307+XTRA, 0, 0, Text))
	{
		Sleep(666)
		FindText().Click(X, Y, "L")
	}

	Sleep(666)
	Send(Chr(96))
	Sleep(666)
}