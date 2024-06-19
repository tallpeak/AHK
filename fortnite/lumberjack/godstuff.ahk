FORTNITEPROCESS := "FortniteClient-Win64-Shipping.exe"
FORTNITEWINDOW := "ahk_class UnrealWindow" ; ahk_exe " . FORTNITEPROCESS
; FORTNITEWINDOW := "ahk_exe FortniteClient-Win64-Shipping.exe"
FORTNITEEXCLUDEWINDOW := "Epic Games Launcher"

global EXTRA
EXTRA:=150
if A_ScreenWidth != 1600 {
	EXTRA:= A_ScreenWidth
}

#HotIf WinActive(FORTNITEWINDOW)
^+9::FightGod()
+NumpadPgup::FightGod()
+Numpad9::FightGod()
SC027 & 1::TPboss(1)
SC027 & 2::TPboss(2)
SC027 & 3::TPboss(3)
SC027 & 4::TPboss(4)
SC027 & 5::TPboss(5)
SC027 & 6::TPboss(6)
SC027 & 7::TPboss(7)
SC027 & 8::TPboss(8)
SC027 & 9::TPboss(9)
'::TPboss()
^\::TPimmortalTree(true)
^+\::TPimmortalTree(false)
#HotIf

findtext_GuardiansPage2() {
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:="", Y:=""
	Text:="|<Page2/2>*99$49.N733vDjqBthhzDryEkokzDnyPuNvzDvyRwAQDVxz3"
	xtra:=111
	X:="wait"
	Y:=0.2
	; 968, 289, 1028, 325
	ok:=FindText(&X, &Y, 1000-xtra, 311-xtra, 1000+xtra, 311+xtra, 0, 0, Text)
	return ok
}

findtext_ElysiumGod() {
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<ElysiumGod>*240$58.TTzzzzyvztxxXTSzvySVqqxhhjjqqTOwqqqyvPNxnxPPPvhhUzCBpzjltvzxzzzzzzzy"
	xtra:=444
	X:="wait"
	ok:=FindText(&X, &Y, 1063-xtra, 201-xtra, 1063+xtra, 201+xtra, 0, 0, Text)
	return ok
}

findtext_FORESTGUARDIANS() {
	global EXTRA
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<FORESTGUARDIANS>*11$91.tXb4w6GAQsX4W00FNO545d6/KFXGU08YZm224Z4d9Fd007GQUF1OGHYYYg802/9EcUZNt+mSKI0134i8EAMYZl99400U"
	X:="wait"
	xtra:=EXTRA
	ok:=FindText(&X, &Y, 1237-xtra, 193-xtra, 1237+xtra, 193+xtra, 0, 0, Text)
	return ok
}

findtext_ForestGuard() {
	global EXTRA
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<ForestGuard>*240$61.TzzzrxrzzzDbqQMyzvbqbhaqxzThxalqrTaziqyrNvPjxDrPPPgyRtlnwSghvU"
	X:="wait"
	xtra:=EXTRA
	ok:=FindText(&X, &Y, 1064-xtra, 90-xtra, 1064+xtra, 90+xtra, 0, 0, Text)
	return ok
}

findtext_TELEPORT_and_click() {
	global EXTRA
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<TELEPORT>*1$54.yyMTC00sDykMMDVsyDMkMMAnAn6MwMSAm4n6MkMMBW4y6MkMMD3Am6MySTA1sn6MySTA00n6U"
	X:="wait"
	xtra:=EXTRA ; 100
	ok:=FindText(&X, &Y, 1527-xtra, 89-xtra, 1527+xtra, 89+xtra, 0, 0, Text)
	if ok {
		; ToolTip("TELEPORT:X=" X ",Y=" Y)
		FindText().Click(X, Y, "L")
		; Sleep(555)
	}
	return ok	
}

findtext_TELEPORT_and_click_n(n) {
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<TELEPORT>*1$54.yyMTC00sDykMMDVsyDMkMMAnAn6MwMSAm4n6MkMMBW4y6MkMMD3Am6MySTA1sn6MySTA00n6U"
	X:="wait"
	xtra:=EXTRA ; 100
	xy:=0
	ok:=FindText(&X, &Y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0, 0, Text)
	if ok {
		xy := ok[n]
		FindText().Click(xy.1, xy.2, "L")
	}
	return xy	
}

findtext_JOIN_and_click() {
	global EXTRA
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<JOIN>*1$24.Q0AlASAlAnAtAVAVAVAZAnAbsSAX00AXU"
	xtra:=EXTRA
	X:="wait"
	if (ok:=FindText(&X, &Y, 1464-xtra, 201-xtra, 1464+xtra, 201+xtra, 0, 0, Text))
	{
		; ToolTip("found JOIN")
		Sleep(300)
		FindText().Click(X+11, Y+6, "L")
	}
}

findtext_CLOSE_and_click() {
	global EXTRA
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<CLOSE>*1$34.0A001xskSBaAn3AUMUA8F1u0kV1aAn3A2MSD7X9w0w007s"
	xtra:=EXTRA
	X:="wait"
	if (ok:=FindText(&X, &Y, 1280-xtra, 325-xtra, 1280+xtra, 325+xtra, 0, 0, Text))
	{
		; Sleep(100)
		FindText().Click(X, Y, "L")
	}
}

FightGod() {
	; start Elysium God bossfight then TP to Forest Guard
	; then turn around and run to the changing booth
	MoveWindowToUpperRight()
	ToolTip
	KeyWait("9")
	KeyWait("NumpadPgup")
	KeyWait("Numpad9")
	KeyWait("Shift")
	KeyWait("SC027") ;";"
	Sleep(444)
	switchToRemote()
	Sleep(444)
	Click("Right")
	Send("{RButton}")
	Sleep(666)
	ok := findtext_FORESTGUARDIANS()
	if ok {
		X := ok[1].1 + 33
		Y := ok[1].2
		FindText().Click(X, Y, "L")
		Sleep(666)
	} else {
		ToolTip("Error finding FORESTGUARDIANS")
		return
	}
	ok := findtext_GuardiansPage2() 
	if !ok {
		FindText_larrow_and_click()
		Sleep(888)
	} 
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<TELEPORT>*1$54.yyMTC00sDykMMDVsyDMkMMAnAn6MwMSAm4n6MkMMBW4y6MkMMD3Am6MySTA1sn6MySTA00n6U"
	X:="wait"
	xtra:=30
	ok:=FindText(&X, &Y, 1524-xtra, 201-xtra, 1524+xtra, 201+xtra, 0, 0, Text)
	if ok {
		; ToolTip("TPed to Boss9? Clicking TP")
		FindText().Click(X, Y, "L")
	} else {
		ToolTip("Error finding boss9 TELEPORT")
		return
	}
	
	Sleep(2222)

	; wait for [E] Forest Guardian
	xtra:=50
	t1:=A_TickCount, Text:="", X:="wait", Y:="2"
	Text:="|<E_ForestGuardian>**50$62.m01zzzzzzzzU0NAWNmYW/807htivdfgy01jHxjrmDAU0TDmPn/D/s07zzzzzzzU"
	ok:=FindText(&X, &Y, 1317-xtra, 165-xtra, 1317+xtra, 165+xtra, 0, 0, Text)

	Sleep(555)
	Send("e")
	Sleep(555)
	findtext_JOIN_and_click()
	Sleep(222)
	findtext_CLOSE_and_click()

	TPboss1()
	ToolTip()
}

FindText_larrow_and_click() {
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<LArrow>*1$4.4zQM"
	; xtra:=EXTRA
	xtra:=88
	X:="wait"
	if (ok:=FindText(&X, &Y, 1172-xtra, 310-xtra, 1172+xtra, 310+xtra, 0, 0, Text))
	{
	 FindText().Click(X, Y, "L")
	}
}

; NumPadAdd::{
; 	ok := findtext_GuardiansPage2() 
; 	if ok {
; 		FindText_larrow_and_click()
; 	}
; }

NumPad1::TPboss1()

TPboss1() {
	; WinActivate(FORTNITEWINDOW,,FORTNITEEXCLUDEWINDOW)
	; SendMode("Event")
	; ToolTip("TPBoss1")
	Sleep(111)
	switchToRemote()
	Sleep(400)
	; Click("Right")
	Send("{RButton}")
	; Send("{NumpadDot}")
	; Sleep(99)
	Sleep(400)
	ok := findtext_FORESTGUARDIANS()
	if ok {
		X := ok[1].1 + 22
		Y := ok[1].2 + 11
		Sleep(333)
		FindText().Click(X, Y, "L")
	} else {
		ToolTip("failed findtext_FORESTGUARDIANS")
		return
	}
	Sleep(666)
	ok := findtext_GuardiansPage2() 
	if ok {
		ToolTip("ok findtext_GuardiansPage2 ")
		; go to page 1
		; Sleep(111)
		; X := 1169
		; Y := 311
		; FindText().Click(X, Y, "L")
		Sleep(222)
		FindText_larrow_and_click()
		Sleep(222)
	} else {
		ToolTip("failed findtext_GuardiansPage2 ")
		Sleep(1111)
	}
	; ok := findtext_ForestGuard()
	; if ok {
	; 	; TELEPORT
	; 	X := 1527 
	; 	Y := ok[1].2 + 15
	; 	FindText().Click(X, Y, "L")
		Sleep(350)
		ok:=findtext_TELEPORT_and_click()
		if ok {
			ToolTip("1=" ok[1].1 ",2=" ok[1].2)
		} else {
			ToolTip("failed findtext_TELEPORT_and_click, ok=" ok)
		}
		
	; } else {
	; 	ToolTip("cant find ForestGuard")
	; }
	Sleep(1111)
	ToolTip()
}

TPboss(n:=0) {
	KeyWait("'")
	if !n {
		ToolTip("Boss#?")
		ih := InputHook("L1")
		ih.Start()
		ih.Wait()
		try {
			n:=Integer(ih.Input)
		}
	}
	if !n {
		ToolTip("No boss")
		Sleep(2000)
		ToolTip()
		return
	}
	Sleep(500)
	switchToRemote()
	Sleep(500)
	; Click("Right")
	Send("{RButton}")
	Sleep(400)
	ok := findtext_FORESTGUARDIANS()
	if ok {
		X := ok[1].1
		Y := ok[1].2
		Sleep(111)
		FindText().Click(X, Y, "L")
	} else {
		ToolTip("failed findtext_FORESTGUARDIANS")
		return
	}
	Sleep(333)
	ok := findtext_GuardiansPage2() 
	if !ok {
		ToolTip("findtext_GuardiansPage2 not found")
	}
	if (ok && n < 6) || ((!ok) && n>=6) {
		; ToolTip("need to page switch ")
		; go to page 1
		; Sleep(111)
		; X := 1169
		; Y := 311
		; FindText().Click(X, Y, "L")
		Sleep(400)
		FindText_larrow_and_click()
		Sleep(222)
	} else {
		; ToolTip("no page switch ")
		Sleep(111)
	}
	; ok := findtext_ForestGuard()
	; if ok {
	; 	; TELEPORT
	; 	X := 1527 
	; 	Y := ok[1].2 + 15
	; 	FindText().Click(X, Y, "L")
		Sleep(111)
		xy:=findtext_TELEPORT_and_click_n(1+Mod(n-1,5))
		if xy {
			ToolTip("1=" xy.1 ",2=" xy.2)
		} else {
			ToolTip("failed findtext_TELEPORT_and_click, xy=" xy)
		}
		
	; } else {
	; 	ToolTip("cant find ForestGuard")
	; }
	Sleep(1111)
	ToolTip()
}

TPimmortalTree(startfrenzy:=true) {
	KeyWait("\")
	Sleep(333)
	Send("{Space}") ; jump up to stop crouching
	Sleep(666)
	TPboss(6) ; atlantean guard
	;Walkback to wall (10 seconds?)
	;walk left (1.5 secconds?)
	Send("{blind}{s down}{LShift down}")
	Sleep(15000) ; rather long because half the time my character is crouching and won't run
	; Send("{blind}{a down}")
	; Sleep(200)
	; Send("{blind}{a up}")
	Send("{blind}{s up}{LShift up}")
	Sleep(400)
	Send("e")
	Sleep(400)
	;TP immortal tree
	t1:=A_TickCount, Text:=X:="wait",Y:=2
	Text:="|<ImmortalTree>*1$62.YG81XX47AQt4WEGEF0WI+F8YY4EE8VnYG99l442CEdIeGEFt0W4+F8U4Y2Q8ZnU"
	xtra:=EXTRA
	if (ok:=FindText(&X, &Y, 1020-xtra, 215-xtra, 1020+xtra, 215+xtra, 0, 0, Text))
	{
		FindText().Click(X, Y, "L")
	}
	; now walk up to the tree
	Sleep(3000)
	Send("{w down}")
	Sleep(4000)
	Send("{w up}")
	FrenzyLoop(startfrenzy)
}
