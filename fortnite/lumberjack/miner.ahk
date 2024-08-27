; Miner Odyssey
; for mob rooms

#HotIf WinActive(FORTNITEWINDOW)
^Enter::start_firing()
SC019 & Enter::start_firing()
NumpadDiv & NumpadMult::autolevel()
^+a::autolevel()
^0::autolevel(40)
^1::autolevel(1)
^2::autolevel(2)
^3::autolevel(3)
^4::autolevel(4)
^5::autolevel(5)
^6::autolevel(6)
^7::autolevel(7)
^8::autolevel(8)
^9::autolevel(9)
NumpadIns & NumpadDel::Click_at_Cursor()
^+!b::Click_at_Cursor()
NumpadEnd::Expedition_loop()
Numpad1::Expedition_loop()
^+v::drill_loop()
#HotIf

; SC019 & m::autolevel()
; ^+m::autolevel()

global TTLEFT:=400
global TTTOP:=300

alt_handler(arg) {
; nothing to do?
}

;sweep drifts left
global SWEEP := false ; cant get this damn thing to work!

; for mob rooms
; switch to gun first
start_firing() {
	global WM_KEYDOWN
	global firekey
	global FORTNITEWINDOW
  global SWEEP
  KeyWait("Ctrl")
	KeyWait("Enter")
  Send("1")
  Sleep(500)
	Send("{Enter Down}")
	; maybe_unfocus()
  ; switch_to_gun()
  MouseGetPos(&oX,&oY,&WIN,&CTRL,1)
  FindText().ToolTip("mouse=(" oX "," oY ") WIN=" WIN ",CTRL=" CTRL
    "`nIf you want to remove focus, press control-shift-U to unfocus"
    "`npress RCtrl or right-click to stop shooting",,,,{timeout:5})
  ; left := X - 300
  ; right := X + 300
  x := oX
  y := oY
  startTick:=A_TickCount
  ; SendMode("Play")
  ; SetMouseDelay(10)

  ; oldCoordMode := CoordMode("Mouse","Screen")
  movement := 40
  MouseSpeed := 5
  SetDefaultMouseSpeed(MouseSpeed)
  Hotkey("Alt",alt_handler) ;try to block alt-enter
  direction := movement ; left or right direction
  target_left := 1380   ; shield icon moves right as we sweep left
  target_right := 1020  ; and v-v
  left := 150
  right := 500
  lr  := 0
  Loop {
    ; This is easier to terminate (might want to add a tooltip for instructions...)
    if !GetKeyState("Alt")
      SendMessage(WM_KEYDOWN,firekey,0,,FORTNITEWINDOW)
    ;v1
    if SWEEP {
      if WinActive(FORTNITEWINDOW) {
        if lr  {
          SetDefaultMouseSpeed(50)
          MouseMove(left,Y)
        }
        else {
          SetDefaultMouseSpeed(50)
          MouseMove(right,Y)
        }
        lr ^= 1
      }
    } else {
      Sleep(1000)
    }

    ; ; v2
    ; if SWEEP && WinActive(FORTNITEWINDOW) {
    ;   ok:=findtext_mobroom_icon()
    ;   if ok {
    ;     xy:=ok[1]
    ;     ; clrLeft := FindText().GetColor(1035, 54)
    ;     ; if color is black then we panned left far enough or too far
    ;     ; clrRight := FindText().GetColor(?1550?, 54)
    ;     ; if color is black then we panned right far enough or too far
    ;     ;...
    ;     MouseGetPos(&x,&y,&WIN,&CTRL,1)
    ;     yr := 0
    ;     if xy.y < 100 {
    ;       y -= 3
    ;       yr := -3
    ;     }
    ;     if xy.y > 140 {
    ;       y += 10
    ;       yr := 10
    ;     }
    ;     if xy.x > target_left || x < 100 { ;
    ;       direction := movement
    ;     }
    ;     if xy.x < target_right || x > A_ScreenWidth * 0.8 { ;
    ;       direction := -movement*2
    ;     }
    ;     x += direction

    ;     ; if x > (A_ScreenWidth * 0.4) && direction > 0 {
    ;     ;   FindText().ToolTip("too far right!",500,30,,{timeout:3})
    ;     ;   MouseMove(Floor(A_ScreenWidth * 0.05),y,20)
    ;     ;   DllCall("SetCursorPos", "int", Floor(A_ScreenWidth * 0.15), "int", y)
    ;     ;   ; direction := movement*2
    ;     ; }
    ;     ; if x < (A_ScreenWidth * 0.1) && direction < 0 {
    ;     ;   FindText().ToolTip("too far left!",500,30,,{timeout:3})
    ;     ;   MouseMove(Floor(A_ScreenWidth * 0.4),y,20)
    ;     ;   DllCall("SetCursorPos", "int", Floor(A_ScreenWidth * 0.4), "int", y)
    ;     ;   ; direction := -movement*2
    ;     ; }

    ;     ; ; relative movement stops working when the x coordinate is <=0 or >= window width
    ;     ; ; too much drift of the absolute x position; attempt to compensate:
    ;     ; if xy.x > target_left - 80 && x > 500 {
    ;     ;   ; MouseSetPos??
    ;     ;   SetDefaultMouseSpeed(0)
    ;     ;   MouseMove(100,y)
    ;     ;   ; DllCall("SetCursorPos", "int", 100, "int", y)
    ;     ;   SetDefaultMouseSpeed(MouseSpeed)
    ;     ;   direction := movement
    ;     ; }
    ;     ; if xy.x < target_right + 80 && x < 100 {
    ;     ;   ; MouseSetPos??
    ;     ;   SetDefaultMouseSpeed(0)
    ;     ;   MouseMove(500,y)
    ;     ;   ; DllCall("SetCursorPos", "int", 500, "int", y)
    ;     ;   SetDefaultMouseSpeed(MouseSpeed)
    ;     ;   direction := -movement
    ;     ; }
    ;     ToolTip("(" xy.x "," xy.y "," direction "," x "," y ")",1520,10)
    ;     ; MouseMove(x,y)
    ;     MouseMove(direction,yr,MouseSpeed,"r")
    ;     ; DllCall("SetCursorPos", "int", 300, "int", 110)
    ;     ; mouseX:=300
    ;     ; mouseY:=100
    ;     ; DllCall("mouse_event", "uint", 0x8001, "int", ceil(mouseX*65535/a_screenwidth), "int", ceil(mouseY*65535/a_screenheight), "uint", 0, "uint", 0)
    ;   }
    ; }
	  ; if !GetKeyState("Alt")
    SendMessage(WM_KEYUP,firekey,0,,FORTNITEWINDOW)
		if WinActive(FORTNITEWINDOW) {
      ; kw := KeyWait("RCtrl","DT0.01")
      kw := GetKeyState("RCtrl")
			; lb := GetKeyState("LButton")
			rb := GetKeyState("RButton")
			if A_TickCount > startTick + 3000
			   and (kw or rb) {
				FindText().ToolTip("RCtrl/Button found; stopping clicking")
				Sleep(1500)
				FindText().ToolTip()
				break
			}
		}
  }
  Hotkey("Alt","Off")
  ; CoordMode("Mouse",oldCoordMode)
}

findtext_ActivateDrill() {
  t1:=A_TickCount, Text:=X:=Y:=""
  ; old Text:="|<ACTIVATE_DRILL>*15$64.MPmGAwsMQYFWG98kW19+F+88YZ2C4Yd4YUWIG8UGQYHmG8lsW19+F968X4WC74drU"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  X:="wait"
  Y:=2.0
  Text:="|<ACTIVATE>*3$39.MHmGAws4UGE04UUWEE8QY4G214QYW0C84W4FWF7U"
  if (ok:=FindText(&X, &Y, 1460-xtra, 309-xtra, 1460+xtra, 309+xtra, 0.03, 0.03, Text))
  {
      Sleep(300)
      FindText().Click(X, Y, "L")
      Sleep(200)
  } else {
    FindText().ToolTip("Drill not found")
  }
}

drill() {
  ; MouseMove(A_ScreenWidth - 100, 100)
  ActivateFortniteWindow()
  Sleep(500)
  switchToRemote()
  Sleep(500)
  Click("Right") ; try to focus the window
  Sleep(500)
  switchToRemote()

  ; Sleep(400)
  ; Send("RButton")
  ; Click("Right")

  Sleep(1200)
  Loop 2 {
    Click("Right")
    Sleep(150)
  }
  Sleep(400)
  findtext_ActivateDrill()
}

drill_loop() {
  seconds := 180
  Loop {
    MoveWindowToUpperRight()
    Sleep(1200)
    ok:=findtext_Drills_0()
    if !ok {
      if A_TimeIdle > 5000 || A_Index == 1 {
        drill()
      } else {
        FindText().ToolTip("you seem busy, will try drilling later...",,,,{timeout:5})
      }
    } else {
      seconds := 900
    }
    term := clicker_unfocused(false,seconds)
    if term { 
     return
     }
    Sleep(1000)
  }
}

autolevel(nloops:=1) {
  Loop {
    MoveWindowToUpperRight()
    Sleep(777)
    ;this one usually doesnt work (except for the first time)
    ; cnteff:=find_and_click_upgrades(x1:=1385,1) ; efficiency
    ; Sleep(1000)
    ; cntup:=find_and_click_upgrades(x1:=1275,5) ; strength
    ; Sleep(1000)
    ; cnteff+=find_and_click_upgrades(x1:=1385,3) ; efficiency
    ; Sleep(1000)

    ; nloops := 1
    total_seconds := 800 
    seconds_per_loop := Integer(total_seconds / nloops)
    Loop nloops {
      ; cnt:=find_and_click_upgrades()
      ; click_X()
      autobuy()
      click_X()

      Sleep(1000)
      term := clicker_unfocused(false,seconds_per_loop)
      if term { 
        return
      }

    }


    autobuy()
    click_X()

    drill()
    seconds := 100  ; maxed drill is <= 90 seconds
    clicker_unfocused(false,seconds)
    
    ; cnt2:=find_and_click_upgrades()
    ; click_X()

    Sleep(1000)
    ; if !cnt && !cnt2 {
    ;   seconds += 15
    ; }
  }
}

; some problem with this, seeing red/grey as green?
click_area_if_green(x1,y1,x2,y2,max:=2) {
  ; color := "80E381-303030"
  ; greens := FindText().PixelCount(1290,96,1365, 110, color,33)
  ; color := "4DFE4D-181818" ;light green
  color := "80E381-181818"
  loop max {
    Sleep(55)
    greens := FindText().PixelCount(x1,y1,x2,y2,color,0)
    if greens > 5 {
      Loop 5 {
        FindText().ToolTip(greens,x1+70,y1+15)
        Sleep(70)
        FindText().Click(x1+50,y1+5)
        FindText().ToolTip()
      }
    } else break
  }
}

click_X() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<X>*22$6.nnGSSGnnU"
    xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  X:="wait"
  Y:=2.0
  ; Sleep(500)
  if (ok:=FindText(&X, &Y, 1468-xtra, 46-xtra, 1468+xtra, 46+xtra, 0.03, 0.03, Text))
  {
     Sleep(50)
     FindText().Click(X, Y, "L")
     Sleep(2000)
  } else {
    FindText().ToolTip("X not found")
  }
  Sleep(1000)
  FindText().ToolTip()
}

; ^/::FindText().MouseTip(150,150,20,20)
; RShift & [::FindText().CaptureCursor(1) ; to Capture Cursor
; RShift & ]::FindText().CaptureCursor(0) ; to Cancel Capture Cursor
; look into MouseGetPos and Gui_MouseMove and how FindText captures the mouse cursor

autobuy()
{
  KeyWait("NumpadDiv")
  KeyWait("Ctrl")
  KeyWait("Alt")
  Sleep(666)
  ActivateFortniteWindow()
  Sleep(666)
  switchToRemote()
  Sleep(1200)
  Loop 3 {
    Click()
    Sleep(150)
  }
  findtext_auto_click()
}

; don't like how this works, and don't use it much anymore:
find_and_click_upgrades(maxcount:=2)
{
  KeyWait("NumpadDiv")
  KeyWait("Ctrl")
  KeyWait("Alt")
  Sleep(666)
  ActivateFortniteWindow()
  Sleep(666)
  switchToRemote()
  Sleep(1200)
  Loop 3 {
    Click()
    Sleep(150)
  }

  count_found := 0
  ; count_found += FindAndClick_0_0()
  ; count_found += FindAndClick_GreenMAX()
  ; count_found += FindAndClick_0_0()
  ; ; if count_found > 0  {
  ; ;   return
  ; ; }
  ; count_found += FindAndClick_MAX_LEVEL()
  ; if count_found > 0 {   ; and Random(0,5)
  ;   return
  ; }
  ; ; bottom to top:
  for y1 in [266,226,180,139,96] {
    Loop maxcount {
      for x1 in [1385,1275,1385] {
        Sleep(111)
        y2:=y1+14
        x2:=x1+100
        Loop 5 {
          FindText().Click(x1+50,y1+7, "L")
        }
        ; click_area_if_green(x1,y1,x2,y2,max:=10) ; some problem with this, seeing red/grey as green?
      }
    }
  }
  return count_found
}

; ^+m::autolevel()
; autolevel_old_neverused_Deadcode() {
;   KeyWait("m")
;   KeyWait("Ctrl")
;   KeyWait("Shift")
;   seconds := 10
;   Loop {
;     clicker_unfocused(seconds)
;     Sleep(1111)
;     MoveWindowToUpperRight()
;     eff := find_and_click_upgrades(1385,10) ; efficiency2
;     Sleep(1111)
;     str := find_and_click_upgrades(1275,25) ; strength
;     if !eff and !str {
;       seconds += 5
;     }
;     if eff + str > 10 {
;       seconds -= 5
;     }
;   }
; }

FindAndClick_GreenMAX() {
  cnt := 0
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<MAX>80E381-101010$24.MkcoIEcIJN8QJN8QHNwoEN4aU"
  if (ok:=FindText(&X, &Y, 1349-99, 1, 1349+99, 1500, 0.05, 0.05, Text))
  {
    cnt += 1
    FindText().Click(X,Y, "L")
    Sleep(100)
    FindText().Click(X,Y, "L")
    Loop 3 {
      Sleep(100)
      FindText().Click(X+100, Y, "L")
    }
  }
  return cnt
}

FindAndClick_0_0() {
  cnt := 0
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<0_0>*240$69.tTzzzzzzzzwjRzzzzzzzzzivjzzzzzzzzxrRzzzzzzzzzivTzzzzzzzzxjXzzzzzzzzzlU"
  if (ok:=FindText(&X, &Y, 1134-100, 1, 1134+100, 1500, 0.05, 0.05, Text))
  {
    cnt += 1
    Loop 10 {
      Sleep(100)
      FindText().Click(X+210,Y, "L")
    }
    Loop 5 {
      Sleep(100)
      FindText().Click(X+310, Y, "L")
    }
  }
  return 0 ; cnt
}

FindAndClick_MAX_LEVEL() {
  cnt := 0
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<MAX_LEVEL>*200$54.CCCnvkqEr6CCHvrqLrLAj7vrqrrJBj7vkqkrFAb7vrmrrNA6HtrsrnTBqnsEskkU"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  if (ok:=FindText(&X, &Y, 1331-xtra, 189-xtra, 1331+xtra, 189+xtra, 0.05, 0.05, Text))
  {
    cnt += 1
    Loop 5 {
      Sleep(100)
      FindText().Click(X+100, Y, "L")
    }
  }
  return 0
}

Click_at_Cursor() {
  Loop {
    Click()
    kw:=KeyWait("RCtrl", "DT0.03")
    if kw {
      break
    }
  }
}

Expedition_loop() {
  global TTLEFT,TTTOP
  ; Send("``")
  pickaxe()
  MoveWindowToUpperRight()
  ActivateFortniteWindow()
  ; pickaxe()
  Sleep(1000)
  Click()  ; I think this might help activate/focus the window?
  Loop {
    findtext_Expeditions()
    findtext_PROGRESS()
    FindText().ToolTip("PROGRESS gone",TTLEFT,TTTOP)
    findtext_X()
    Sleep(999)

    FindText().ToolTip("Expeditions:",TTLEFT,TTTOP)
    Sleep(999)
    findtext_Expeditions()
    Sleep(999)
    FindText().ToolTip("CLAIM:",TTLEFT,TTTOP)
    findtext_CLAIM()
    FindText().ToolTip("X:",TTLEFT,TTTOP)
    findtext_X()
    Sleep(999)
; mob room - crystals - 23.49k @ 11:37:15 23.50k @ 11:38:15
; 200 hrs for paragon rifle
    FindText().ToolTip("Expeditions:",TTLEFT,TTTOP)
    findtext_Expeditions()

    ; FindText().ToolTip("Hard:",TTLEFT,TTTOP)
    ; findtext_Hard()
    ; or findtext_extreme_exp()

    ; FindText().ToolTip("HARD?")
    ; Sleep(5000)

    FindText().ToolTip("Ghost:",TTLEFT,TTTOP)
    findtext_Ghost()
    ; FindText().ToolTip("GHOST?")
    ; Sleep(5000)
    FindText().ToolTip("HARD/EXTREME & GHOST? ABORT (^r) WITHIN 5 seconds...", TTLEFT,TTTOP)
    Sleep(5000)
    FindText().ToolTip("LAUNCH:",TTLEFT,TTTOP)
    findtext_LAUNCH()
    FindText().ToolTip("X:",TTLEFT,TTTOP)
    findtext_X()
    Sleep(999)

    minutes := 9 ; adjust over time as you accumulate ghosts
    Loop minutes {
      FindText().ToolTip("Waiting " (minutes + 1 - A_Index) " minutes...", TTLEFT,TTTOP)
      Sleep(60000) ; HARD
    }

    findtext_Expeditions()
    findtext_PROGRESS()
    FindText().ToolTip("PROGRESS gone",TTLEFT,TTTOP)
    findtext_X()
    Sleep(999)

    FindText().ToolTip("loop in 2s..")
    Sleep(2222)
    FindText().ToolTip()
  }

}

findtext_X()
{
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<X>*48$14.A040200000000n0Ak1M0S07U1M0n0As"
    xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  if (ok:=FindText(&X, &Y, 1471-xtra, 54-xtra, 1471+xtra, 54+xtra, 0.03, 0.03, Text))
  {
    Loop 3 {
      sleep(100)
      FindText().Click(X, Y, "L")
    }
  }
}

findtext_Expeditions() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<E_EXPEDITIONS>*166$47.DzzzzzzzzzzzzzzwzsYE+6Gbzn+Zif5HzaF/RKHTz1C1vnYU"
  X:="wait"
  Y:=2
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 600) ; can move all over the place
  if (ok:=FindText(&X, &Y, 1267-xtra, 255-xtra, 1267+xtra, 255+xtra, 0.09, 0.09, Text))
  {
    ; FindText().Click(X, Y, "L")
  } else {
    FindText().ToolTip("failed to find E EXPEDITIONS A_SCREENWIDTH = " A_SCREENWIDTH)
  }
  ; send it regardless; the findtext was just to try to make sure it's ready and on-screen
  ; as you can see, I'm having trouble
  ; getting some keys to register
  ; in FN consistently!
  Loop 8 {
    Sleep(200)
    Send("{e down}")
  }
  Loop 15 {
    Sleep(200)
    Send("{e up}")
  }
  ; Sleep(2000) ; wait for screen to come up
  FindText().ToolTip()
}

findtext_LAUNCH() {
  t1:=A_TickCount, Text:=X:=Y:=""
  ; Text:="|<LAUNCH>*22$44.kCAn000w4XAdDnD18n+HAnkGAmoU/QAnAZ82r2on93AnglDm8zAz8M0X03C"
  Text:="|<LAUNCH>*22$44.kCAn4AAw7XAtDnD1cnCHAnkGAnokDwAnAbA3z3wn9nAnynDnAzAzcMkn33C"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 150)
  X:="wait"
  Y:=2.0
  if (ok:=FindText(&X, &Y, 1470-xtra, 293-xtra, 1470+xtra, 293+xtra, 0.03, 0.03, Text))
  {
    Loop 3 {
      sleep(100)
      FindText().Click(X, Y, "L")
    }
  } else {
    FindText().ToolTip("failed to find LAUNCH")
  }
}

; findtext_expeditions1() {
; t1:=A_TickCount, Text:=X:=Y:=""
; Text:="|<>*188$29.DzDY3zznjMzvYSrzsrkM"
; if (ok:=FindText(&X, &Y, 1250-150000, 176-150000, 1250+150000, 176+150000, 0.03, 0.03, Text))
; {
;   ; FindText().Click(X, Y, "L")
; }
; }

findtext_CLAIM()
{
 t1:=A_TickCount, Text:=X:=Y:=""
  ; Text:="|<CLAIM>*22$34.8A3WA3wkKAdQn18mZUA4X+60knAWwn2omPz/AH9g0wVgks" ; 150% brightness + other changes
  Text:="|<CLAIM>*22$34.AA3XADwkSAtwn1cnbkA4X+D0knAawn3wmPzDgn9gkyVgks" ; at defaults
  xtrax:=50
  xtray:=10
  X:="wait"
  Y:=2  ; 30*60 ; Extreme
  if (ok:=FindText(&X, &Y, 1470-xtrax, 293-xtray, 1470+xtrax, 293+xtray, 0.03, 0.03, Text))
  {
    Loop 3 {
      Sleep(100)
      FindText().Click(X, Y, "L")
    }
  } else {
    FindText().ToolTip("failed to find CLAIM")
    Sleep(1000)
    ; halt()?
  }
}


; ^H::findtext_Hard()

findtext_Hard() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<Hard>*180$68.NzzbVzzzx7lqTzvvzzzzTTxYREyyq666VgNvBjVhhhhhvEErPvwvMPPSpZhqyyKqyqnhN3QjVhdlZiPc"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 250)
  if (ok:=FindText(&X, &Y, 1277-xtra, 173-xtra, 1277+xtra, 173+xtra, 0.05, 0.05, Text))
  {
    Loop 3 {
      sleep(100)
      FindText().Click(X+40, Y+20, "L")
    }
  } else {
    FindText().ToolTip("failed to find Hard")
    ; FindText().Click(1277+40, 173+20, "L")
  }
}

; this was for testing: NumPadDown::findtext_Ghost()

findtext_Ghost() {
  t1:=A_TickCount, Text:=X:=Y:=""
  ; Text:="|<EQUIP:GHOST>*122$54.sn9C0mHXjVN9/lOGqav99933qH2X99D3OqEWtNN81+Gqmtll8lmHXa0U0000000U"
  Text:="|<EQUIP:GHOST>*103$55.wthj0vNlrsyqrwzhxjzPPPMNyqsqBhhwBzP7Prrqw7xjhhttnMlqnXa0M0000000E"
    xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 150)
  if (ok:=FindText(&X, &Y, 1096-xtra, 255-xtra, 1096+xtra, 255+xtra, 0.05, 0.05, Text))
  {
    Loop 3 {
      sleep(100)
      FindText().Click(X, Y, "L")
    }
  } else {
    FindText().ToolTip("failed to find ghost")
  }
}

; is there a PROGRESS button on-screen? (with Time Left: above it)
findtext_PROGRESS() {
  FindText().ToolTip("Waiting for PROGRESS to disappear")
  t1:=A_TickCount, Text:=X:=Y:=""
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  X:="wait0"
  Y:=30*60
  ; Text:="|<PROGRESS>*121$61.zDkwDDnwyTDnwzDnwiTDqNatiNaMQiPAnQzEnDbXlyTCTjT7kwSyDrDnBn3CbM6NyTiNwzTw7AS7XAyTDc"
  Text:="|<PROGRESS>*70$59.yDVkS9XUsRyTbty6UHtjAnAnAm4636NaNa1ULC7DnsnB3Uk73z6taMaNU31kAnwv8ntwzUNXk89blku"
  ok:=FindText(&X, &Y, 1469-xtra, 293-xtra, 1469+xtra, 293+xtra, 0.03, 0.03, Text)
  FindText().ToolTip()
}

findtext_extreme_exp() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<>*166$61.3zzzzzzsTzjzjzzzzxzzrqdfDhtyyqgTPvPPPTXvNyRvVhgDjngyqRbqqzrqq3PawPvXsPOE"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  if (ok:=FindText(&X, &Y, 1410-xtra, 172-xtra, 1410+xtra, 172+xtra,  0.03, 0.03, Text))
  {
    FindText().Click(X, Y, "L")
  }
}

#include "*i cactoro.ahk"


findtext_mobroom_icon() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<MOBROOM_ICON>F05C29@1.00$12.zDk7U3U301U3k3M64A3E1UU"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  ok:=FindText(&X, &Y, 1280-xtra, 112-xtra, 1280+xtra, 112+xtra, 0.03, 0.03, Text)
  return ok
}

findtext_Drills_0() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<Drills_0>*253$30.CzzzzBzzzpnrzzirjzzioTzzicjzzhfbzznU"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  ok:=FindText(&X, &Y, 980-xtra, 282-xtra, 980+xtra, 282+xtra, 0.05, 0.05, Text)
  return ok
}

findtext_auto_click()
{  
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<AUTO>*15$21.MZsn4W9cYFAYW9wgFAX26U"
  xtra:=100
  if (ok:=FindText(&X, &Y, 1405-xtra, 46-xtra, 1405+xtra, 46+xtra, 0.03, 0.03, Text))
  {
     FindText().Click(X, Y, "L")
  } else {
    FindText().ToolTip("AUTO NOT FOUND")
  }
}
