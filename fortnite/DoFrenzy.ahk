#Include "FindTextv2_FeiYue_9.5.ahk"

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

	Try {
		WinActivate(FORTNITEWINDOW)
		WinWaitActive(FORTNITEWINDOW)
		WinShow(FORTNITEWINDOW)
		WinActivate(FORTNITEWINDOW)
		WinWaitActive(FORTNITEWINDOW)
		MoveWindowToUpperRight()
	}
	
	Send("1") ; remote?
	; Send("2") ; remote
	Sleep(555)
	Send("{RButton}")
	Sleep(555)

	xtra:=50
	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	Text:="|<GoldenTree>*11$47.Ml7797bDOm/8O2/G4YGQo4Gxd8YVM8t9KFN2kF+AMvXYUWLU"
	if (ok:=FindText(&X, &Y, 1228-xtra, 145-xtra, 1228+xtra, 145+xtra, 0, 0, Text))
	{
	FindText().Click(X, Y, "L")
	}
	Sleep(1000)
	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	Text:="|<Frenzy>*11$29.vb9CH5cOAe9QoFrQVNVcZ2m2F/Yj4U"
	if (ok:=FindText(&X, &Y, 1057-xtra, 241-xtra, 1057+xtra, 241+xtra, 0, 0, Text))
	{
	FindText().Click(X, Y, "L")
	}
	Sleep(1000)
	t1:=A_TickCount, Text:=X:=Y:=""
	X:="wait"
	Text:="|<ACTIVATE>*11$53.C03v8EsyywT7qNXlxVcn6An6VX2F0ANa937wm0Ml8n6ATaMlWFyAMnDVX7XAMz303664Aly"
	if (ok:=FindText(&X, &Y, 1064-xtra, 307-xtra, 1064+xtra, 307+xtra, 0, 0, Text))
	{
	FindText().Click(X, Y, "L")
	}

	Sleep(222)
	Send(Chr(96))
	Sleep(1111)
}