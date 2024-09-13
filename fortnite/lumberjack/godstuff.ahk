FORTNITEPROCESS := "FortniteClient-Win64-Shipping.exe"
FORTNITEWINDOW := "ahk_class UnrealWindow" .  " ahk_exe " . FORTNITEPROCESS
; FORTNITEWINDOW := "ahk_exe FortniteClient-Win64-Shipping.exe"
FORTNITEEXCLUDEWINDOW := "Epic Games Launcher"

global EXTRA
EXTRA:=150
if A_ScreenWidth != 1600 {
	EXTRA:= A_ScreenWidth
}

; some weird keybindings below; feel free to change for your needs!
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
SC027 & 0::FightGodNoTP()
'::TPboss()
^\::TPimmortalTree(true)     ; control slash to start frenzyloop with a frenzy
^+\::TPimmortalTree(false)   ; control shift slash to start frenzyloop without a frenzy
; ^+p::FindText().Gui("Show") ; this is preventing the ability to enter p in searches
^PrintScreen::FindText().Gui("Show")  
#HotIf

^!PrintScreen::FindText().Gui("Show") 


findtext_GuardiansPage2() {
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:="", Y:=""
	Text:="|<Page2/2>*99$49.N733vDjqBthhzDryEkokzDnyPuNvzDvyRwAQDVxz3"
	Text.="|<Page2/2>*99$49.7zzzwzrtUzxzwDnsKEkkwnttVCGPTnxzYAB8DnwzaQaCrUyT1T373sDTkE"
	Text.="|<Page1/2>*120$46.HzvztyT1YQSDbvxawqqzTjy33H3xyzZxgxzrrwrknszTTkU"
	xtra:=111
	X:="wait"
	Y:=0.1
	; 968, 289, 1028, 325
	; ok:=FindText(&X, &Y, 1000-xtra, 311-xtra, 1000+xtra, 311+xtra, 0.01, 0.01, Text)
	ok:=FindText(&X, &Y, 1000-xtra, 310-xtra, 1000+xtra, 310+xtra, 0.01, 0.01, Text)
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
	ok:=FindText(&X, &Y, 1063-xtra, 201-xtra, 1063+xtra, 201+xtra, 0.05, 0.05, Text)
	return ok
}

findtext_FORESTGUARDIANS() {
	global EXTRA
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<FORESTGUARDIANS>*11$91.tXb4w6GAQsX4W00FNO545d6/KFXGU08YZm224Z4d9Fd007GQUF1OGHYYYg802/9EcUZNt+mSKI0134i8EAMYZl99400U"
	Text.="|<FOREST_GUARDIANS>*31$78.tXb4w6GAQsX4WWmo+8/GAKgX6ZWGL888GIGYZ6YuHY28/GGQYYZVWmI+89KSGgbZZVWL486AGGsYYWU"
	X:="wait"
	y:=3.0
	xtra:=EXTRA
	ok:=FindText(&X, &Y, 1231-xtra, 193-xtra, 1231+xtra, 193+xtra, 0.05, 0.05, Text)
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
	ok:=FindText(&X, &Y, 1064-xtra, 90-xtra, 1064+xtra, 90+xtra, 0.01, 0.01, Text)
	return ok
}

findtext_TELEPORT_and_click() {
	global EXTRA
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<TELEPORT>*1$54.yyMTC00sDykMMDVsyDMkMMAnAn6MwMSAm4n6MkMMBW4y6MkMMD3Am6MySTA1sn6MySTA00n6U"
	Text.="|<TELEPORT>*31$56.zTADbUMSDzrn3tyTbvwlUkkNaNaAATADaNaNX36331yNbkklUkkS6NYAATDja1yNX37nvtU66Mm"
	X:="wait"
	xtra:=EXTRA ; 100
	; ok:=FindText(&X, &Y, 1527-xtra, 89-xtra, 1527+xtra, 89+xtra, 0.01, 0.01, Text)
	ok:=FindText(&X, &Y, 1527-xtra, 20-xtra, 1527+xtra, 500+xtra, 0.01, 0.01, Text)
	if ok {
		; ToolTip("TELEPORT:X=" X ",Y=" Y)
		Sleep(100)
		FindText().Click(X, Y, "L")
		; Sleep(555)
	} else {
		FindText().ToolTip("failed findtext_TELEPORT")
		return
	}
	return ok	
}

findtext_TELEPORT_and_click_n(n) {
	t1:=A_TickCount, Text:=X:="", Y:=0
	; Text:="|<TELEPORT>*1$54.yyMTC00sDykMMDVsyDMkMMAnAn6MwMSAm4n6MkMMBW4y6MkMMD3Am6MySTA1sn6MySTA00n6U"
	Text:="|<TELEPORT>*31$56.zTADbUMSDzrn3tyTbvwlUkkNaNaAATADaNaNX36331yNbkklUkkS6NYAATDja1yNX37nvtU66Mm"
	X:="wait"
	Y:=2.0
	xtra:=EXTRA ; 100
	xy:=0
	; ok:=FindText(&X, &Y, 0, 0, A_ScreenWidth, A_ScreenHeight, 0.01, 0.01, Text)
	ok:=FindText(&X, &Y, 1527-xtra, 20-xtra, 1527+xtra, 500+xtra, 0.01, 0.01, Text)
	if ok {
		xy := ok[n]
		FindText().Click(xy.1, xy.2, "L")
	} else {
		FindText().ToolTip("failed findtext_TELEPORT_and_click_n(" n ")")
		return
	}
	return xy	
}

findtext_JOIN_and_click() {
	global EXTRA
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<JOIN>*1$24.Q0AlASAlAnAtAVAVAVAZAnAbsSAX00AXU"
	Text.="|<JOIN>*31$24.wAAlwzAtAnAtAnAxAnArAnArwzAnkAAnU"
	xtra:=EXTRA
	X:="wait"
	Y:=2.0
	if (ok:=FindText(&X, &Y, 1464-xtra, 201-xtra, 1464+xtra, 201+xtra, 0.01, 0.01, Text))
	{
		; ToolTip("found JOIN")
		; Sleep(100)
		FindText().Click(X+11, Y+6, "L")
	} else {
		FindText().ToolTip("failed findtext_JOIN")
		return
	}
}

findtext_CLOSE_and_click() {
	global EXTRA
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text:="|<CLOSE>*1$34.0A001xskSBaAn3AUMUA8F1u0kV1aAn3A2MSD7X9w0w007s"
	Text.="|<CLOSE>*15$33.0A001vlUwNAnAAm1Y1V28DUA8ENaNVa1ASD7X9s1s00DU"
	xtra:=EXTRA
	X:="wait"
	Y:=2.0
	if (ok:=FindText(&X, &Y, 1280-xtra, 325-xtra, 1280+xtra, 325+xtra, 0.01, 0.01, Text))
	{
		; Sleep(100)
		FindText().Click(X, Y, "L")
	} else {
		FindText().ToolTip("failed findtext_CLOSE")
		return
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
	TPboss(9)
	; Sleep(444)
	; Click("Right")
	; Send("{RButton}")
	; Sleep(666)
	; ok := findtext_FORESTGUARDIANS()
	; if ok {
	; 	X := ok[1].1 + 33
	; 	Y := ok[1].2
	; 	FindText().Click(X, Y, "L")
	; 	Sleep(666)
	; } else {
	; 	ToolTip("Error finding FORESTGUARDIANS")
	; 	return
	; }
	; ok := findtext_GuardiansPage2() 
	; if !ok {
	; 	FindText_larrow_and_click()
	; } 
	; Sleep(444)
	; t1:=A_TickCount, Text:=X:="", Y:=0
	; Text:="|<TELEPORT>*1$54.yyMTC00sDykMMDVsyDMkMMAnAn6MwMSAm4n6MkMMBW4y6MkMMD3Am6MySTA1sn6MySTA00n6U"
	; X:="wait"
	; xtra:=100
	; ok:=FindText(&X, &Y, 1524-xtra, 201-xtra, 1524+xtra, 201+xtra, 0.01, 0.01, Text)
	; if ok {
	; 	; ToolTip("TPed to Boss9? Clicking TP")
	; 	FindText().Click(X, Y, "L")
	; } else {
	; 	ToolTip("Error finding boss9 TELEPORT")
	; 	return
	; }
	
	Sleep(2000)
	FightGodNoTP()
}

FightGodNoTP() {
	; wait for [E] Forest Guardian
	xtra:=50
	t1:=A_TickCount, Text:="", X:="wait", Y:="3"
	Text:="|<E_ForestGuardian>**50$62.m01zzzzzzzzU0NAWNmYW/807htivdfgy01jHxjrmDAU0TDmPn/D/s07zzzzzzzU"
	ok:=FindText(&X, &Y, 1317-xtra, 165-xtra, 1317+xtra, 165+xtra, 0.01, 0.01, Text)

	Sleep(666)
	Send("e")
	Sleep(666)
	findtext_JOIN_and_click()
	Sleep(50)
	findtext_CLOSE_and_click()

	; TPboss1()
	TPboss(1)
	; FindText().ToolTip()
}

FindText_larrow_and_click() {
	t1:=A_TickCount, Text:=X:="", Y:=0
	Text.="|<LArrow>*15$4.4zQM"
	Text.="|<LArrow>*22$5.2Tvlk"
; xtra:=EXTRA
	xtra:=88
	X:="wait"
	Y:=3.0
	; if (ok:=FindText(&X, &Y, A_ScreenWidth-(1600-1172)-xtra, 310-xtra, A_ScreenWidth-(1600-1172)+xtra, 310+xtra, 0.01, 0.01, Text))
	if (ok:=FindText(&X, &Y, 1172-xtra, 310-xtra, 1172+xtra, 310+xtra, 0.05, 0.05, Text))
	{
		Sleep(50)
	 	FindText().Click(X, Y, "L")
	} else {
		FindText().ToolTip("failed to find left arrow")
		return
	}
}

; NumPadAdd::{
; 	ok := findtext_GuardiansPage2() 
; 	if ok {
; 		FindText_larrow_and_click()
; 	}
; }

; NumPad1::TPboss1()

; TPboss1() {
; 	; WinActivate(FORTNITEWINDOW,,FORTNITEEXCLUDEWINDOW)
; 	; SendMode("Event")
; 	; ToolTip("TPBoss1")
; 	Sleep(400)
; 	ToolTip("Trying to switch to remote, key=" SignalRemoteKey)
; 	switchToRemote()
; 	ToolTip()
; 	Sleep(400)
; 	; Click("Right")
; 	Send("{RButton}")
; 	; Send("{NumpadDot}")
; 	; Sleep(99)
; 	Sleep(50)
; 	ok := findtext_FORESTGUARDIANS()
; 	if ok {
; 		X := ok[1].1 + 22
; 		Y := ok[1].2 + 11
; 		Sleep(333)
; 		FindText().Click(X, Y, "L")
; 	} else {
; 		FindText().ToolTip("failed findtext_FORESTGUARDIANS")
; 		return
; 	}
; 	Sleep(666)
; 	ok := findtext_GuardiansPage2() 
; 	if ok {
; 		ToolTip("ok findtext_GuardiansPage2 ")
; 		; go to page 1
; 		; Sleep(111)
; 		; X := 1169
; 		; Y := 311
; 		; FindText().Click(X, Y, "L")
; 		Sleep(222)
; 		FindText_larrow_and_click()
; 		Sleep(222)
; 	} else {
; 		FindText().ToolTip("failed findtext_GuardiansPage2 ")
; 		Sleep(1111)
; 	}
; 	; ok := findtext_ForestGuard()
; 	; if ok {
; 	; 	; TELEPORT
; 	; 	X := 1527 
; 	; 	Y := ok[1].2 + 15
; 	; 	FindText().Click(X, Y, "L")
; 		Sleep(350)
; 		ok:=findtext_TELEPORT_and_click()
; 		if ok {
; 			ToolTip("1=" ok[1].1 ",2=" ok[1].2)
; 		} else {
; 			FindText().ToolTip("failed findtext_TELEPORT_and_click, ok=" ok)
; 		}
		
; 	; } else {
; 	; 	ToolTip("cant find ForestGuard")
; 	; }
; 	Sleep(1111)
; 	ToolTip()
; }

TPboss(n:=0) {
	KeyWait("'")
	KeyWait(";")
	KeyWait("1")
	KeyWait("2")
	KeyWait("3")
	KeyWait("4")
	KeyWait("5")
	KeyWait("6")
	KeyWait("7")
	KeyWait("8")
	KeyWait("9")
	if !n {
		FindText().ToolTip("Boss#?")
		ih := InputHook("L1")
		ih.Start()
		ih.Wait()
		try {
			n:=Integer(ih.Input)
		}
	}
	if !n {
		FindText().ToolTip("No boss")
		Sleep(2000)
		FindText().ToolTip()
		return
	}
	Sleep(200)
	switchToRemote()
	Sleep(600)
	; Click("Right")
	; Send("{RButton}")
	Send("{RButton Down}")
	Sleep(200)
	Send("{RButton Down}")
	Sleep(50)
	Send("{RButton Up}")
	Sleep(50)
	Send("{RButton Up}")
	Sleep(100)
	ok := findtext_FORESTGUARDIANS()
	if ok {
		X := ok[1].1
		Y := ok[1].2
		Sleep(50)
		FindText().Click(X, Y, "L")
		Sleep(600)
	} else {
		FindText().ToolTip("failed findtext_FORESTGUARDIANS",,,,{timeout:3})
		return
	}
	ok := findtext_GuardiansPage2() 
	if !ok {
		FindText().ToolTip("findtext_GuardiansPage2 not found",,,,{timeout:1})
	}
	if (ok && ok[1].id == "Page2/2" && n < 6) 
		|| (ok && ok[1].id == "Page1/2" && n>=6) {
		; ToolTip("need to page switch ")
		; go to page 1
		; Sleep(111)
		; X := 1169
		; Y := 311
		; FindText().Click(X, Y, "L")
		; Sleep(100)
		FindText_larrow_and_click()
		Sleep(222)
	} else {
		; ToolTip("no page switch ")
		Sleep(222)
	}
	; ok := findtext_ForestGuard()
	; if ok {
	; 	; TELEPORT
	; 	X := 1527 
	; 	Y := ok[1].2 + 15
	; 	FindText().Click(X, Y, "L")
		; Sleep(111)
		xy:=findtext_TELEPORT_and_click_n(1+Mod(n-1,5))
		if xy {
			ToolTip("1=" xy.1 ",2=" xy.2)
		} else {
			FindText().ToolTip("failed findtext_TELEPORT_and_click, xy=" xy)
		}
		
	; } else {
	; 	ToolTip("cant find ForestGuard")
	; }
	ToolTip()
	Sleep(111)
}

TPimmortalTree(startfrenzy:=true) {
	KeyWait("Shift")
	KeyWait("\")
	KeyWait("Ctrl")
	Sleep(500)
	Send("{Space}") ; jump up to stop crouching
	Sleep(777)
	TPboss(6) ; atlantean guard
	;Walk backwards to wall
	Sleep(1200)
	Send("{blind}{s down}{LShift down}") ; run backwards
	; use findtext with wait1 to search for Interact?
	Text:="|<INTERACT>*180$25.A0NY5PgjQhaLiK+oq"
	X:="wait1"
	Y:=15.0
	xtra:=EXTRA
	ok:=FindText(&X, &Y, 1264-xtra, 300-xtra, 1264+xtra, 300+xtra, 0.05, 0.05, Text)
	; if not found then it should have waited 15 seconds, so following not needed:
	; if (!ok) {
	; 	Sleep(14000) ; was rather long because half the time my character was crouching and won't run
	; }
	if !ok {
		FindText().ToolTip("failed findtext_INTERACT")
	}
	Sleep(50)
	Send("{blind}{s up}{LShift up}") 
	Sleep(500)
	Send("e")
	Sleep(2500) ; because "wait" doesn't work?
	;TP immortal tree
	t1:=A_TickCount, Text:=X:="",Y:=4.0
	Text:="|<ImmortalTree>*1$62.YG81XX47AQt4WEGEF0WI+F8YY4EE8VnYG99l442CEdIeGEFt0W4+F8U4Y2Q8ZnU"
	Text.="|<IMMORTAL_TREE>*31$63.YG8lrX4DCQwqP//MMUlO4anN995429QweJ9C8gUFm4ZGdN97Y29EYWF699YsF/bU"
	Text.="|<IMMORTAL_TREE>*22$63.YG8lrX4DCQwqP/98MUF+4anN995429QweJ9C8YUFm4ZGdN97Y29EYWF699YsF/bU"
	; if (ok:=FindText(&X, &Y, 1024-150000, 215-150000, 1024+150000, 215+150000, 0, 0, Text))
	xtra:=EXTRA+50
	X:="wait" ; doesnt seem to work
	if (ok:=FindText(&X, &Y, 1020-xtra, 215-xtra, 1020+xtra, 215+xtra, 0.05, 0.05, Text))
	{
		Sleep(300)
		FindText().Click(X, Y, "L")
		; ToolTip("IMMORTAL=" X "," Y)
	} else {
		FindText().ToolTip("failed findtext_IMMORTAL_TREE")
	}

	; now walk up to the tree
	Sleep(3000)
	Send("{w down}")
	Sleep(3000)
	Send("{w up}")
	FrenzyLoop(startfrenzy)
}