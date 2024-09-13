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
^+d::clicker_unfocused_meteor()

;; experimental:
^NumpadMult::toggle_auto_buy()
^!NumpadMult::autobuy_fast()

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

  Sleep(400)
	pickaxe()
	Sleep(400)
	pickaxe()
	Sleep(400)

}

; this will vary by player, depending on their strength
; stronger players may want a higher threshold, to avoid wasting part of a drill
global MINIMUM_METEOR_HP_FOR_DRILLING := 80

drill_loop() {
  global MINIMUM_METEOR_HP_FOR_DRILLING
  seconds := 180
  Loop {
    MoveWindowToUpperRight()
    Sleep(1200)
    ok:=findtext_Drills_0()
    hp := get_meteorhp()
    if !ok {
      if A_TimeIdle > 5000 && hp > MINIMUM_METEOR_HP_FOR_DRILLING 
        || A_Index == 1 {
        drill()
      } else {
        msg := "you seem busy (or HP(" hp ") < " MINIMUM_METEOR_HP_FOR_DRILLING "); will try drilling later..."
        FindText().ToolTip(msg,,,,{timeout:5})
      }
    } else {
      seconds := 180 ; after adding meteor hp detection, we need to try for drilling more often
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

autobuy_fast()
{
  BlockInput("On")
  ; store state of wasd keys (direction the user is moving)
  ; w:=GetKeyState("w")
  ; a:=GetKeyState("a")
  ; s:=GetKeyState("s")
  ; d:=GetKeyState("d") 
  Sleep(55)
  switchToRemote()
  ; Send("{Blind}2")
  Sleep(222)
  Send("{LButton}")
  Send("{LButton}")
  Sleep(222)
  WinGetClientPos(&wx,&wy,&ww,&wh,FORTNITEWINDOW)
  x:=1405,y:=46
  if ww == 360 {
    x:=1405,y:=46
  } else if ww == 1600 {
    x:=1238,y:=98
  }
  Loop 10 {
    FindText().Click(x,y, "L") ;AUTO
  }
  Sleep(222)
  click_X()
  Sleep(222)
  ; pickaxe() ; too slow (winactivate) 
  Send("f")
  Sleep(55)
  Send(Chr(96)) ; pickaxe
   ; Sleep(55)
 
  ; ; restore wasd state
  ; if w {
  ;   Send("{w down}")
  ; }
  ; if a {
  ;   Send("{a down}")
  ; }
  ; if s {
  ;   Send("{s down}")
  ; }
  ; if d {
  ;   Send("{d down}")
  ; }
  BlockInput("Off")
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
; if (ok:=FindText(&X, &Y, 1250-xtra, 176-xtra, 1250+xtra, 176+xtra, 0.03, 0.03, Text))
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
  Text:="|<EXTREME_EXP>*166$61.3zzzzzzsTzjzjzzzzxzzrqdfDhtyyqgTPvPPPTXvNyRvVhgDjngyqRbqqzrqq3PawPvXsPOE"
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

; keep Google Chrome (or presumably any other window) 
; at least 40 pixels away from left edge of FN window
findtext_Drills_0() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<Drills_0>*253$30.CzzzzBzzzpnrzzirjzzioTzzicjzzhfbzznU"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 20)
  ; ok:=FindText(&X, &Y, 964, 272, 1013, 306, 0.05, 0.05, Text)
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

global meteorhp_pct := -1
global show_meteorhp := false
global last_auto_buy_time := 0
global auto_buy := false

settimer(get_meteorhp, 1000)

get_meteorhp() {
  global meteorhp_pct
  global show_meteorhp
  global last_auto_buy_time
  try {
    show_meteorhp |= false ; do-nothing assignment
  } catch {
    show_meteorhp := false
  }
  ; count pixels that are red in this range: 1189, 34, 1373, 43
  color := "D61F28"
  reds := FindText().PixelCount(1189, 34, 1373, 34, color,33)
  hppct := Round((reds / (1373-1189))*100)
  meteorhp_pct := hppct
  if show_meteorhp {
    FindText().ToolTip("HP%=" hppct, 1373,5,2)
  }
  if auto_buy {
    if hppct == 0 && last_auto_buy_time < A_TickCount - 10000  {
      autobuy_fast()
      last_auto_buy_time := A_TickCount
    }
  }
  return hppct
}

toggle_auto_buy() {
  global auto_buy
  auto_buy := !auto_buy
  FindText().ToolTip("auto_buy=" auto_buy)
}

FindText_title() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<MINER_TYCOON>*253$82.bBrgATUrTTrxxsQaBbaTjPqRbNXJmOqSNywizjPqhRPhPsTntvyxjPJhiljizDjatiPgLqva6vxyzjvyytU"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  ok:=FindText(&X, &Y, 1039-xtra, 261-xtra, 1039+xtra, 261+xtra, 0, 0, Text)
  return ok
}

findtext_PLAY_and_click2() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<PLAY>*33$28.wA3XDwkSAwn1cGnA4Vvwkn7D33wAkDgkn0yVX8"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  if (ok:=FindText(&X, &Y, 1038-xtra, 313-xtra, 1038+xtra, 313+xtra, 0, 0, Text))
  {
      FindText().Click(X, Y, "L")
  }
}

scanForGameLauncher_Meteor() {
	global EXTRA
	global SignalRemoteKey
	global EventBossTimer
  FindText().ToolTip("Looking for title screen",500,30)
  if (ok:=FindText_title()) {
		FindText().ToolTip("Found title screen")
		; LogMessage("start","Found title screen")
		; FindText().Click(X, Y, "L")
		earlyAbort := true
		EventBossTimer := A_TickCount ; reset event boss timer
		Send("{LButton up}")
		Sleep(200)
		Send("{Enter up}")
		Sleep(200)
		findtext_PLAY_and_click2()
		Sleep(5000)
		; FindText().ToolTip("Waiting two minutes for LJH to load...Scanning for signal remote")
		FindText().ToolTip("Wait for Miner Tycoon to load`nScan for signal remote")
		; Sleep(120000) ; is this long enough?
		; wait for something to indicate loaded, such as the signal remote?
		; (or wait for loading screen to go away)
		SignalRemoteKey := ""
		tries := 0
		while !SignalRemoteKey && tries++ < 240 {
			if findtext_signalRemote() {
				break
			}
			Sleep(2000)
		} 
	
    getSignalRemoteKey()
		FindText().ToolTip("Found signal remote; about to TP Immortal Tree...")
		MoveWindowToUpperRight()
		ActivateFortniteWindow()
		Sleep(1000)
		FindText().ToolTip()
		WalkToMeteor() 
	}
	
  WalkToMeteor() {
    FindText().ToolTip("Walking to Meteor...")
    Sleep(1000)
    FindText().ToolTip()
    Send("{w down}")
    Sleep(1000)
    Send("{w up}")
    Sleep(1000)
    Send("{a down}")
    Sleep(1000)
    Send("{a up}")
    Sleep(1000)
    }   
	; findtext_BATTLEPASS_CLAIM_and_click()
	SetTimer(scanForGameLauncher_Meteor, -60000) ; 1 minute (temp)
}

; SetTimer(scanForGameLauncher_Meteor, -60000) ; 1 minute (temp)

findtext_minertycoon_big() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<MINER_TYCOON_big>*250$227.s3z0S1s7w7U07U1zzy00A3w1zxzzzjzzxzy1z1k7y0w3k7sD00D007zs00M3s7w07zU0zw07w1y30Ds3kD0DkQ00Q007zk00s7UTU07w00zU07k3w60TU7US0DUs00s00DzU01kD0y007k00y007U3sA0T0D0w0S1kDzkDUTzy1zUQ3s3UD0A0s1U707UM0w0S1s0Q7UTzUT0zzw7zUsDkDUS1w1kDUC071k1k0w7k0sD0zz1y1zzkDz0Uz0zUs7w30zUQ0C31XW3kD00kQ00w3w7zzUTy01y1zzkDs61z0k0A63647US31Us01s7UTzz0zy07s7zz0zk87y1UkMA64MD0w603k03k03zzy1zw0TkDzy1z0kDs71U0sA1kS1sC07UTzU07zzw7zs1zUTkQ3y1UTkC3U1kM3Uw7kQ0D1zz003zzkDzs3z0z0s3s70T0w7031sC3kD1w0Q3zw3s7zzUTzkDy0Q3k30C0M1kT063kw7US3s0s00s7kDzz0zzUTy007k00y007Uy0A7zsD0w7s3k01kDUTzy1zz0zy00zk03y00T1y0sDzkS1sDk7U07UT0zzw7zy3zy07zk0Ty03y3w1kTzUw7kTkD00D1y1zzkDzs7zzzzzzTzzvzw7w3k"
  ok:=FindText(&X, &Y, 217-150000, 598-150000, 217+150000, 598+150000, 0, 0, Text)
  return ok 
}

findtext_READY_big() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<READY!_big>*15$113.zzw7zz0Dz07zz0zUTlzzzwDzy0Tz0DzzUzVz3zzzwTzw0zy0TzzVz3y7zzzszzs3zw0zzz1y7sDzkTly007vw1y3z3wTkTzUTXw00Drs3w3y3wz0zz0z7s00Tjk7s7w7ty1zy1yDzw1yDkDk7s7ns3zw7wTzs3wTUTUDkDzk7zzzkzzk7sz0z0TUTz0Dzzy1zzUTly1y0z0Ty0Tzzw3w00z3y3w1y0zs0zzzy7s01zzw7s7w0zk0zy7wDk07zzsDkDs1zU1vw7wTU0DzzsTUzk1y007sDszzsTzzkzzz03w00DkDlzzkz0TVzzy07s0DzUTXzzXy0zXzzs0Dk0zz0z7zz7w1z7zz00TU1zy1yDzyDk3yDzU00z03w000000000000000001Y"
  ok:=FindText(&X, &Y, 216-150000, 744-150000, 216+150000, 744+150000, 0, 0, Text)
  return ok
}

findtext_PLAY_big() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<PLAY>" ; TODO capture
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  if (ok:=FindText(&X, &Y, 1038-xtra, 313-xtra, 1038+xtra, 313+xtra, 0, 0, Text))
  {
      FindText().Click(X, Y, "L")
  }
}


; maybe lower this once used to the auto-hide behavior:
HIDE_SECONDS := 10
; Some users won't like these enabled
ENABLE_AUTO_HIDE := true
ENABLE_RESIZE := true
; For resize: I like FN small, in upper-right:
SCALINGFACTOR := 0.4
; WINWIDTH := A_ScreenWidth * SCALINGFACTOR
; WINHEIGHT := A_ScreenHeight * SCALINGFACTOR
; FindText().ToolTip("WW,WH,WX,WY=" WINWIDTH "," WINHEIGHT "," WINX "," WINY) ; 640,360,960,10
; Sleep(2222)

DO_UNFOCUS := true ; false ; due to winactivate failures
WINWIDTH := 640
WINHEIGHT := 360
WINX := A_ScreenWidth - WINWIDTH
WINY := 10
CENTERX := WINX + WINWIDTH/2
CENTERY := WINY + WINHEIGHT/2

global 	WM_KEYDOWN 	:= 0x0100
global WM_KEYUP 	:= 0x0101

Delay60 := 222   ; when 60/100 
Charged_Delay := 50 ; When "Charged!" is found
X1Charged_Delay := 2500 ; When "x1 Charged!" is found
Charged_Count := 0
ChargedCountAtDelay := 1
; Charged_MaxRunDelay := 4 ; only delay for first n appearances of Charged
; Charged_MaxRunDelay doesnt do much because
; "Charged!"" isn't always caught by screen-scanning
keydown_time := 200 ; ms
ctrl_time := "DT0.2" ; seconds
firekey := 13 ; Enter
; from https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116471
use_FindText := false
MyScreenDPI := 96  ; my HP 17's laptop screen is 1600x900 (96dpi)
#Include "*i findtextv2_v9.6.ahk" ; revert because of crashes occurring after Windows update (23H2 rollup)
; #Include "*i findtextv2_v9.7b.ahk" ; v9.7 adds fuzzy searching by default, 9.7b removes the default
try {
	; throws exception if FindText is undefined
	use_FindText := HasMethod(FindText, "Call")
}
if A_ScreenDPI != MyScreenDPI {
	FindText().ToolTip("Only " MyScreenDPI " DPI supported; your DPI is " A_ScreenDPI)
	use_FindText := false
}

; only seems to work out-of-focus when firekey = enter
; (You need to go into FN settings and bind fire to enter)
; drill_loop2
clicker_unfocused_meteor(hideWindow:=false) {
  total_seconds := 3600 * 4
	global Delay60 
	global Charged_Count
	; global Charged_MaxRunDelay
	global keydown_time
	global ctrl_time
	global firekey
	global earlyAbort
	global WM_KEYDOWN
	global WM_KEYUP 	
	earlyAbort := false
	term := false
	DetectHiddenWindows true
	startTick := A_TickCount
	; tried to block alt+enter, didnt work
	; Hotkey("Alt & Enter",DoNothing,"On") ; didnt work
	starttick := A_TickCount
	prev_delay_tick := A_TickCount
  hidWindow := false
  last_hp := 0
  global meteorhp_pct
; I like my Window in the upper-right at 40% size
	; I realize not all users will want this behavior
	; Having a consistent size can enable screen-scanning macros
	; (in the future), eg. using FindText
  if ENABLE_RESIZE {
		MoveWindowToUpperRight()
		; FindText().BindWindow(WinExist(FORTNITEWINDOW)) ; doesnt work
	}
	; if !unfocusChk.Value {
		ActivateFortniteWindow()
	; }
	msg := "Clicking! Your focus should be on the desktop."
			. "`nIf captured, tap Windows key. Avoid alt-tab."
			. "`nUse RCtrl/Click (when in focus) to stop clicking, or reload (Ctrl-R)."
			. "`nIMPORTANT: Configure key bindings in Fortnite settings:"
			. "`npickaxe(Harvesting Tool)=backquote(``) (Chr(96))"
			. "`nFire=Enter(Return key) (Chr(13))"
	        . (hideWindow ? "`nWindow hides in " . HIDE_SECONDS . " seconds (Ctrl-C to start w/o auto-hide)"
					        . "`nUse Ctrl-Shift-H to hide, Ctrl-Alt-Shift-H to unhide FN window.":"")
	ttHWND := FindText().ToolTip(msg,10,10,2,{timeout:3})
	toolTip_showing := true
	kw := KeyWait("NumPadDel","U")
	; immediately unfocusing before first Enter/click event
	; sometimes prevented the clicking from starting
	; I'm not sure if this fixes it?
	Sleep(400)
	pickaxe()
	Sleep(400)
	pickaxe()
	Sleep(400)
	Click()
	Sleep(keydown_time)
	; KeyWait("LAlt") ; doesnt work?!
	PostMessage(WM_KEYDOWN,firekey,0,,FORTNITEWINDOW)
	Sleep(keydown_time)
	PostMessage(WM_KEYUP,firekey,0,,FORTNITEWINDOW)
	Sleep(keydown_time)
	maybe_unfocus()
	total_milliseconds := total_seconds * 1000
	; FindText().ToolTip("starting clicking...")
	; will this fix the "not chopping" issue at start?
	; (You may need to click in the window and restart the clicker macro, at times)
	MouseMove(CENTERX,CENTERY)
	Click()
	Sleep(333)
	maybe_unfocus()
	while A_TickCount < startTick + total_milliseconds {
		seconds_left := Floor((startTick + total_milliseconds - A_TickCount ) * 0.001) 
		if seconds_left < 9999 
			and ( Mod(seconds_left,5) = 0 or seconds_left < 30 ) {
			FindText().ToolTip(seconds_left . "s",WINX+WINWIDTH-100,WINY+100)
			SecondsRemain.Value:=seconds_left
		}
		; give user 6 seconds to read the message:
		if A_TickCount - starttick > HIDE_SECONDS * 1000 {
			if hideWindow {
				hideWindow := false ; once only
        hidWindow := true
				unfocus()
				Sleep(111)
				try {
					WinHide(FORTNITEWINDOW)
				}
			}
			if toolTip_showing {
				activeWindow := WinExist("A")
				fnWindow := WinExist(FORTNITEWINDOW)
				FindText().ToolTip()
				TrayTip(msg)
				toolTip_showing := false
				; maybe_unfocus()
				Sleep(333)
				if activeWindow != fnWindow {
					WinActivate(activeWindow) ; return focus after traytip bubble
				}
			}
		}
		PostMessage(WM_KEYDOWN,firekey,0,,FORTNITEWINDOW)
		Sleep(keydown_time)
		PostMessage(WM_KEYUP,firekey,0,,FORTNITEWINDOW)
		kw := KeyWait("RCtrl",ctrl_time)
		if WinActive(FORTNITEWINDOW) {
			lb := GetKeyState("LButton")
			rb := GetKeyState("RButton")
			if A_TickCount > startTick + 2000
			   and (kw or lb or rb) {
				FindText().ToolTip("RCtrl/Button found; stopping clicking")
				Sleep(1500)
				FindText().ToolTip()
				term := true
				break
			}
		}
    haveDrill := !findtext_Drills_0()
    ; if meteor just came down and a new one is up:
    if meteorhp_pct > 95 && last_hp == 0 && haveDrill{
      if hidWindow {
        try {
          WinShow(FORTNITEWINDOW)
          WinActivate(FORTNITEWINDOW)
        } 
      }
      drill()
      Sleep(555)
      if hidWindow {
        try {
          WinHide(FORTNITEWINDOW)
          unfocus()
        }
      }
    }
    last_hp := meteorhp_pct
		if earlyAbort {
			break
		}
	}
	FindText().ToolTip("end of clicking...")
	Sleep(2222)
	FindText().ToolTip()
	; Hotkey("Alt & Enter",,"Off")
	return term
}


; wanted to time meteors 
#include "*i MOTiming.ahk"
