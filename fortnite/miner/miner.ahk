; Miner Tycoon (Odyssey)
; todo user config into Map https://www.autohotkey.com/docs/v2/lib/Map.htm
; findtext strings etc
#Requires AutoHotkey v2.0
#WinActivateForce 1
#SingleInstance

#include "cactoro.ahk"

#Include "*i findtextv2_v9.6.ahk" ; revert because of crashes occurring after Windows update (23H2 rollup)

; #MaxThreads 5
InstallKeybdHook(true)
; no...  InstallMouseHook(true) ; so that A_TIMEIDLEPHYSICAL includes mouse
; SetDefaultMouseSpeed 3 ; default 2, trying to slow down a bit just in case mouse speed affects glitchy behavior at low wattage

SendMode("Event")
SetKeyDelay 80,80

FindText().ToolTip("Loading macros...and sending {Enter up}",70,300)
Send("{Enter up}")

; main key bindings (for FN=active/focused window):
#HotIf WinActive(FORTNITEWINDOW)
^PrintScreen::FindText().Gui("Show")

^End::Reload
^r::Reload
^+r::Reload

; ^!+e::Edit()

; ^c::clicker_unfocused(false)  ; without hide
SC027 & c::clicker_unfocused_meteor(false,false)  ; semicolon c

; ^+c::clicker_unfocused(ENABLE_AUTO_HIDE)  ; move and hide
^+c::clicker_unfocused_meteor(true,false)
^c::clicker_unfocused_meteor(false,false)

^+m::MoveWindowToUpperRight() ; for when I accidentally fullscreen

; control shift h to toggle window-hidden state when FN is in focus:

^+h::WindowHideToggle()
^+u::unfocus()

; hold shift down for slowly changing volume:
LCTRL & UP::VolumeUpLoop()
LCTRL & Down::VolumeDownLoop()
 
^Enter::start_firing()
SC019 & Enter::start_firing()
NumpadDiv & NumpadMult::autolevel()
^+a::autolevel()
^0::autolevel(40)
^+0::autolevel(80) ; click for only 10 seconds between autolevels
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
^+v::old_drill_loop()
^d::clicker_unfocused_meteor(false,true)   ; (newer drill loop)
; ^+d::clicker_unfocused_meteor()

; ^+w::WalkToMeteor() ; not yet implemented
^+q::WalkToQuarryRock()

;; experimental:
^NumpadMult::toggle_auto_buy()
^!NumpadMult::autobuy_fast()

; LAlt & LWin::{
; 	if GetKeyState("LCtrl") {
; 		unfocus()
; 	}
; }

; Myth Heroes 
^+z::fight_zeus()  ; Myth Heroes 
^+g::getcolorforgeToggle() ; Myth Heroes 
^+o::forge()
!o::forge2()

#HotIf

^!+h::WindowHideToggle() ; control alt shift h to toggle window-hidden state:

FORTNITEPROCESS := "FortniteClient-Win64-Shipping.exe"
; FORTNITEWINDOW := "ahk_class UnrealWindow" ; ahk_exe " . FORTNITEPROCESS
FORTNITEWINDOW := "ahk_exe FortniteClient-Win64-Shipping.exe"
FORTNITEEXCLUDEWINDOW := "Epic Games Launcher"

WINWIDTH := 640
WINHEIGHT := 360
WINX := A_ScreenWidth - WINWIDTH
WINY := 10
CENTERX := WINX + WINWIDTH/2
CENTERY := WINY + WINHEIGHT/2

IF ! WINEXIST(FORTNITEWINDOW) {
  Run("com.epicgames.launcher://apps/fn%3A4fe75bbc5a674f4f9b356b5c90567da5%3AFortnite?action=launch&silent=true")
}

; User needs to configure key bindings 
; for pickaxe(Harvesting tool)=` 
; and fire=enter(return)
pickaxe() {
	WinActivate(FORTNITEWINDOW,,FORTNITEEXCLUDEWINDOW)
	Send(Chr(96)) ; pickaxe
}

ActivateFortniteWindow() {
	if !WinActive(FORTNITEWINDOW, , FORTNITEEXCLUDEWINDOW) {
		CoordMode "Mouse", (bak:=A_CoordModeMouse)?"Screen":"Screen"
		MouseMove(CENTERX,CENTERY)	
		CoordMode "Mouse", bak
		Sleep(33)
		WinActivate(FORTNITEWINDOW, , FORTNITEEXCLUDEWINDOW)
		Sleep(33)  ; try to stop the scrollwheel action that seems to be happening
	}
}

MoveWindowToUpperRight() {
	WinMove(WINX, WINY, WINWIDTH,WINHEIGHT,FORTNITEWINDOW)
}


global EXTRA
EXTRA:=50
if A_ScreenWidth != 1600 {
	EXTRA:= A_ScreenWidth
}

; maybe lower this once used to the auto-hide behavior:
HIDE_SECONDS := 10
; Some users won't like these enabled
ENABLE_AUTO_HIDE := true
ENABLE_RESIZE := true
; For resize: I like FN small, in upper-right:
; SCALINGFACTOR := 0.4
DO_UNFOCUS := true ; false ; due to winactivate failures

global 	WM_KEYDOWN 	:= 0x0100
global WM_KEYUP 	:= 0x0101
global hidden := false

WindowHideToggle() {
	global hidden
	try {
		WinHide(FORTNITEWINDOW)
		hidden := true
		; BtnHide.Text := "Unhide"
	} catch {
		WinShow(FORTNITEWINDOW)
		hidden := false
		; BtnHide.Text := "ClickHide"
	}
}

WindowShowAndFocus() {
	WinShow(FORTNITEWINDOW)
	ActivateFortniteWindow()
	WinWaitActive(FORTNITEWINDOW)
}



global SignalRemoteKey := "2" ; always 2 for miner tycoon

getSignalRemoteKey()
{
    ok:=findtext_signalRemote()
	if !ok {
		return
	}
}


switchToRemote() 
{
	Send(SignalRemoteKey)
}


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

; this broke. did the button move?
findtext_ActivateDrill() {
  t1:=A_TickCount, Text:=X:=Y:=""
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 100)
  X:="wait"
  Y:=1.0
  ; Text:="|<ACTIVATE>*3$39.MHmGAws4UGE04UUWEE8QY4G214QYW0C84W4FWF7U"
  ; if (ok:=FindText(&X, &Y, 1460-xtra, 309-xtra, 1460+xtra, 309+xtra, 0.03, 0.03, Text))
  ; moved from 309 to 219, apparently?
  Text:="|<ACTIVATE>*15$39.MPmGAwv4YGFV4cUWGI8wY4GWF4wYWAS8YX4FWF7U"
  if (foundDrill:=FindText(&X, &Y, 1460-xtra, 219-xtra, 1460+xtra, 219+xtra, 0.03, 0.03, Text))
  {
    Sleep(50)
    FindText().Click(X, Y, "L")
    return foundDrill
  } else {
    FindText().ToolTip("Drill not found")
    ; FindText().Click(1460, 219, "L")
    Loop 2 { 
      Sleep(300)
      pickaxe()
    }
    FindText().ToolTip()
    return 0
  }
  ; return foundDrill
}

drill() {
  oldHWND := WinExist("A")
  ; TEMP:
  ; FindText().ToolTip(oldHWND) ; debug info
  ; MouseMove(A_ScreenWidth - 100, 100)
  BlockInput("On")

  ActivateFortniteWindow()

  ; TODO: reduce this delay? 
  ; (Shouldn't need to try 3 times)
  ; But needs reasonable testing (a few drills)
  ; Sleep(300)
  ; switchToRemote()
  ; Sleep(300)
  ; Click("Right") ; try to focus the window
  
  Sleep(300)
  Click()

  ; Sleep(400)
  ; Send("RButton")
  ; Click("Right")

  ; my friend's router and ISP are very bad
  ; TODO: EXIT EARLY IF SUCCESSFUL
  Loop 3 {
    ; Loop 3 {
      Sleep(500)
      switchToRemote()  
    ; }
    
    ; Sleep(400)
    ; Send("RButton")

    ; Loop 3 {
      Sleep(400)
      Click("Right")
    ; } 
    Sleep(400)
    foundDrill := findtext_ActivateDrill()
    if foundDrill {
      break
    }
  }
  ; I HOPE WE FOUND IT!!!
  ; if we didn't find it? ... then ... 
  ; FindText().Click(1460, 219, "L")
  ; FIXME, enable pickaxe detection!!!
  Loop 9 { ; was 4, then 2, now 8, until fixed... 
    Sleep(400) ; was 400
    pickaxe()
    whites := pickaxe_boxcount()
    FindText().ToolTip(whites)
    if whites == 23 || A_Index >= 3 {
      break
    }
  }
  Sleep(300)
  Send("{Enter down}") ; or firekey

  BlockInput("Off")
  Try WinActivate("AHK_ID " oldHWND)

}

; this will vary by player, depending on their strength
; stronger players may want a higher threshold, to avoid wasting part of a drill
global MINIMUM_METEOR_HP_FOR_DRILLING := 50
global drills_estimated := 4 ; no more than this many exist

; old drill loop; usually you want the new one (control d = clicker_unfocused_meteor)
old_drill_loop() {
  global MINIMUM_METEOR_HP_FOR_DRILLING
  seconds := 180
  Loop {
    MoveWindowToUpperRight()
    Sleep(1200)
    ok:=findtext_Drills_0()
    hp := get_meteorhp()
    if !ok {
      if A_TimeIdlePhysical > 5000 && hp > MINIMUM_METEOR_HP_FOR_DRILLING 
        || A_Index == 1 {
        drill()
      } else {
        msg := "you seem busy (or HP(" hp ") < " MINIMUM_METEOR_HP_FOR_DRILLING "); will try drilling later..."
        FindText().ToolTip(msg,,,,{timeout:5})
      }
    } else {
      seconds := 180 ; after adding meteor hp detection, we need to try for drilling more often
    }
    term := clicker_unfocused_dontuse(false,seconds)
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
      term := clicker_unfocused_dontuse(false,seconds_per_loop)
      if term { 
        return
      }

    }


    autobuy()
    click_X()

    drill()
    seconds := 100  ; maxed drill is <= 90 seconds
    clicker_unfocused_dontuse(false,seconds)
    
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
  if (ok:=FindText(&X, &Y, FORGELEFT-99, 1, FORGELEFT+99, 1500, 0.05, 0.05, Text))
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
  ; Text:="|<Drills_0>*253$30.CzzzzBzzzpnrzzirjzzioTzzicjzzhfbzznU" ; stopped working after AMD driver update
  Text:="|<drill_0>*244$30.vzzzznzzzzXDzzz6zzzzBzzzpXnzzipjzzioSzzicfzzhV7zznz/zzzzXzzzU"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 40)
  ; ok:=FindText(&X, &Y, 964, 272, 1013, 306, 0.05, 0.05, Text)
  ; was 282 now 300?
  ok:=FindText(&X, &Y, 980-xtra, 300-xtra, 980+xtra, 300+xtra, 0.05, 0.05, Text)
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
  color := "D61F28" ; 0xD61F28
  offset := A_ScreenWidth-1600
  ; 1522/34   1189+320=
  y := 42
  reds := FindText().PixelCount(1189+offset, y, 1373+offset, y, color,15)
  hppct := Round((reds / (1373-1189))*100)
  meteorhp_pct := hppct
  if show_meteorhp {
    FindText().ToolTip("HP%=" hppct, 1373,5,4)
  }
  if auto_buy {
    if hppct == 0 && last_auto_buy_time < A_TickCount - 10000  {
      autobuy_fast()
      last_auto_buy_time := A_TickCount
    }
  }
  return hppct
}

TryWinActivate(w)
{
	try {
		WinActivate(w)
	} catch Error as err {
		return ; err.Message
	}
}

unfocus() {
	TryWinActivate("ahk_exe explorer.exe") ; Only remove focus from FortNite
}

maybe_unfocus() {
	unfocus()
}

toggle_auto_buy() {
  global auto_buy
  auto_buy := !auto_buy
  FindText().ToolTip("auto_buy=" auto_buy)
}

FindText_title() {
  t1:=A_TickCount, Text:=X:=Y:=""
  ; Text:="|<MINER_TYCOON>*253$82.bBrgATUrTTrxxsQaBbaTjPqRbNXJmOqSNywizjPqhRPhPsTntvyxjPJhiljizDjatiPgLqva6vxyzjvyytU"
  Text:="|<MINER_TYCOON>*244$82.bBnAATUbTTrxwkMaAbaTjNqQb9X1WMKSNywiTbNq5NNgNsDntvytiP5hiljizDjatCHgLqva6vwyzjvyytU"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  ok:=FindText(&X, &Y, 1039-xtra, 261-xtra, 1039+xtra, 261+xtra, 0.03, 0.03, Text)
  return ok
}

findtext_PLAY_and_click2() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<PLAY>*33$28.wA3XDwkSAwn1cGnA4Vvwkn7D33wAkDgkn0yVX8"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  if (ok:=FindText(&X, &Y, 1038-xtra, 313-xtra, 1038+xtra, 313+xtra, 0.03, 0.03, Text))
  {
    Loop 3 {
      Sleep(444)
      FindText().Click(X, Y, "L")
    }
  }
}

findtext_signalRemote()
{
	global EXTRA
	t1:=A_TickCount, Text:=X:=Y:=""
	xtra := EXTRA ; 100
	; Text:="|<remoteDown2>*1$13.00X001F0sUQ0AEA0402421V0QU3kE"
	Text:="|<remoteUp1>*1$13.00X001F0sUQ0AEA0402421V0AU0UE"
	Text.="|<SignalRemoteDown>*1$13.00X001F0sUQ0AEA0402421V0QU3kE" ; captured with v9.7
	Text.="|<SignalRemoteDown2>##101010$0/0/9B461C,0/-1/9B471D,-1/-3/A04D1F,-1/-7/B0602C,-1/-4/A35122,-1/-2/9D491D,-2/-6/B15C26,-2/-9/BD6B30,-2/-12/C6783C,-2/-13/C77B3F,-2/-15/C77F46,-8/-7/D36E1C,-8/-6/CE6A1B,-7/-7/D06D1E,-6/-5/C0611C"
	; if (ok:=FindText(&X, &Y, 1575-150000, 334-150000, 1575+150000, 334+150000, 0, 0, Text))
	Text.="|<SignalRemoteUp2>D7792F@0.80$13.zzQTgUCA7130XY3kXk1s0y0zUTzTk"
	; if (ok:=FindText(&X, &Y, 1561-150000, 327-150000, 1561+150000, 327+150000, 0, 0, Text))
	X:="wait"
    Y:=120.0 ; seconds
    ok:=FindText(&X, &Y, 1561-xtra, 334-xtra, 1561+xtra, 334+xtra, 0.051, 0.051, Text)
	return ok
}

scanForGameLauncher_MinerTycoon() {
	global EXTRA
	global SignalRemoteKey
	global EventBossTimer
  ; if FNWinHidden {
  ;   return
  ; }
  try {
    WinGetPos &zx, &zy, &zw, &zh, FORTNITEWINDOW
  } catch {
    return
  }
  if zw > WINWIDTH && zh > WINHEIGHT {
    MoveWindowToUpperRight()
  }
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
    ; findtext_READY_big()
    ; findtext_PLAY_big()
		Sleep(5000)
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
		FindText().ToolTip("Found signal remote; just walking forward to quarry rock for now...")
		MoveWindowToUpperRight()
		ActivateFortniteWindow()
		Sleep(1000)
    ; WalkToMeteor() 
		WalkToQuarryRock()
    FindText().ToolTip()
		clicker_unfocused_meteor(false) ; don't waste drills on quarry rock
	}
  FindText().ToolTip()
	; findtext_BATTLEPASS_CLAIM_and_click()
	SetTimer(scanForGameLauncher_MinerTycoon, -600000) ; 1 minute (temp)
}

; WalkToMeteor() {}

; just quarry rock for now
WalkToQuarryRock() {
  FindText().ToolTip("Walking to Quarry Rock...")
  Sleep(1000)
  FindText().ToolTip()

  Send("{Space}")
  Sleep(333)

  Send("2")
  Sleep(555)
  Send("{RButton}")
  Sleep(555)
  findtext_Quarry()


  Send("{d down}")
  Sleep(1000)
  Send("{d up}")
  
  Send("{w down}")
  Sleep(2750)
  Send("{w up}")
  Sleep(1000)
  ; Send("{a down}")
  ; Sleep(1000)
  ; Send("{a up}")
  ; Sleep(1000)
}   

findtext_Quarry()
{
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<TO_QUARRY>*15$46.wM696CQYWEYYMZ+W92GGWIe8Y999CQMWEYgwZ9261VWGIY00400002"
  xtra:=50
  if (ok:=FindText(&X, &Y, 1340-xtra, 219-xtra, 1340+xtra, 219+xtra, 0, 0, Text))
  {
    FindText().Click(X, Y, "L")
  } else {
    FindText().ToolTip("cant find quarry")
  }
}

; SetTimer(scanForGameLauncher_MinerTycoon, -600000) ; 10 minutes

findtext_minertycoon_big() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<MINER_TYCOON_big>*250$227.s3z0S1s7w7U07U1zzy00A3w1zxzzzjzzxzy1z1k7y0w3k7sD00D007zs00M3s7w07zU0zw07w1y30Ds3kD0DkQ00Q007zk00s7UTU07w00zU07k3w60TU7US0DUs00s00DzU01kD0y007k00y007U3sA0T0D0w0S1kDzkDUTzy1zUQ3s3UD0A0s1U707UM0w0S1s0Q7UTzUT0zzw7zUsDkDUS1w1kDUC071k1k0w7k0sD0zz1y1zzkDz0Uz0zUs7w30zUQ0C31XW3kD00kQ00w3w7zzUTy01y1zzkDs61z0k0A63647US31Us01s7UTzz0zy07s7zz0zk87y1UkMA64MD0w603k03k03zzy1zw0TkDzy1z0kDs71U0sA1kS1sC07UTzU07zzw7zs1zUTkQ3y1UTkC3U1kM3Uw7kQ0D1zz003zzkDzs3z0z0s3s70T0w7031sC3kD1w0Q3zw3s7zzUTzkDy0Q3k30C0M1kT063kw7US3s0s00s7kDzz0zzUTy007k00y007Uy0A7zsD0w7s3k01kDUTzy1zz0zy00zk03y00T1y0sDzkS1sDk7U07UT0zzw7zy3zy07zk0Ty03y3w1kTzUw7kTkD00D1y1zzkDzs7zzzzzzTzzvzw7w3k"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  ok:=FindText(&X, &Y, 217-xtra, 598-xtra, 217+xtra, 598+xtra, 0, 0, Text)
  return ok 
}

findtext_READY_big() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<READY!_big>*15$113.zzw7zz0Dz07zz0zUTlzzzwDzy0Tz0DzzUzVz3zzzwTzw0zy0TzzVz3y7zzzszzs3zw0zzz1y7sDzkTly007vw1y3z3wTkTzUTXw00Drs3w3y3wz0zz0z7s00Tjk7s7w7ty1zy1yDzw1yDkDk7s7ns3zw7wTzs3wTUTUDkDzk7zzzkzzk7sz0z0TUTz0Dzzy1zzUTly1y0z0Ty0Tzzw3w00z3y3w1y0zs0zzzy7s01zzw7s7w0zk0zy7wDk07zzsDkDs1zU1vw7wTU0DzzsTUzk1y007sDszzsTzzkzzz03w00DkDlzzkz0TVzzy07s0DzUTXzzXy0zXzzs0Dk0zz0z7zz7w1z7zz00TU1zy1yDzyDk3yDzU00z03w000000000000000001Y"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  ok:=FindText(&X, &Y, 216-xtra, 744-xtra, 216+xtra, 744+xtra, 0, 0, Text)
  if ok {
    Loop 3 {
      Sleep(444)
      FindText().Click(X, Y, "L")
    } 
  }
  ; return ok
}

findtext_PLAY_big() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<PLAY_big>*22$80.zy07s00Tw0zUTzzy1y00Dz0Ds7zzzkTU03zs1y3yzzy7s00zy0Tkzjzzly00DzU3wDnw7wTU07vw0z7wz0z7s01yz07tyDkDly00Tjk1yTXw3wTU0Dly0Dbkz0z7s03wTU3zwDkTly00z7s0zy3zzwTU0Tly07zUzzy7s07sTk1zkDzz1y01zzw0Dw3zzUTU0Tzz03y0zU07s0Dzzs0TUDk01zzXzzy07s3w00Tzsz0TU1y0z007zyTk7w0TUDk01zzbw1z07s3w00Tzty0Dk1y0U"
  xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
  ok:=FindText(&X, &Y, 217-xtra, 743-xtra, 217+xtra, 743+xtra, 0, 0, Text)
  if ok {
    Loop 3 {
      Sleep(444)
      FindText().Click(X, Y, "L")
    } 
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
clicker_unfocused_meteor(hideWindow:=false, allowDrilling:=false) {
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
  global drills_estimated
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
  previous_drill_tickcount := 0
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
  start_time := A_TickCount
  start_tick := A_TickCount
  end_tick := A_TickCount
  hp := 0
  hp2 := 0
  start_time := A_Now
  end_time := A_Now
  while A_TickCount < startTick + total_milliseconds {
		seconds_left := Floor((startTick + total_milliseconds - A_TickCount ) * 0.001) 
		if seconds_left < 9999 
			and ( Mod(seconds_left,5) = 0 or seconds_left < 30 ) {
			FindText().ToolTip(seconds_left . "s",WINX+WINWIDTH-100,WINY+100)
			; SecondsRemain.Value:=seconds_left
		}
		; give user 6 seconds to read the message:
		if A_TickCount - starttick > HIDE_SECONDS * 1000 {
			if hideWindow {
				hideWindow := false ; once only
        hidWindow := true
				unfocus()
				Sleep(111)
				try {
          ; FNWinHidden := true
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
          Try {
            WinActivate(activeWindow) ; return focus after traytip bubble
          } 
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
    get_meteorhp()
    ; DEBUG:
    ; ToolTip("meteorhp_pct=" meteorhp_pct ",last_hp=" last_hp,1000,300,2) ; DEBUG
    if meteorhp_pct > 10 && last_hp < 2 {
      start_tick := A_TickCount
      start_time := A_Now
      hp := meteorhp_pct
    }
    if meteorhp_pct == 0 && last_hp > 0  {
      end_tick := A_TickCount
      end_time := A_Now
      elapsed := Round( (end_tick - start_tick) * 0.001 , 3)
      hp2 := meteorhp_pct
      dttm := FormatTime(A_Now, "yyyyMMdd_HHmmss")
      if WinActive(FORTNITEWINDOW) {
        FindText().ToolTip(elapsed " s",580,20,2)
      } else {
        FindText().ToolTip()
      } 
      ; doesn't seem to work ; InsertTiming("Measure", "meteor", start_time, end_time, elapsed, hp, hp2)
      txt := "meteor,"  start_time "," end_time "," elapsed "," hp "," hp2 "`n"
      Try FileAppend(txt,"miner.log")
    }
    ; FindText().ToolTip(allowDrilling,400,40,3)

    if allowDrilling 
      && A_TimeIdlePhysical > 4 * 60000 
      && WinActive("AHK_EXE CHROME.EXE") {
        ; notifications may be blocking the window
        allowDrilling := false
        FindText().ToolTip("disabled drilling")
    }   

    ; if meteor just came down and a new one is up, then drill (if any drills):
    ; (unless user is busy typing or moving mouse (within last 5 seconds))
    user_initiated := start_time < A_TickCount + 10000 ; just started the macro, so do not regard A_TIMEIDLE
    user_is_idle := A_TimeIdlePhysical > 5000 || user_initiated
    haveDrill := !findtext_Drills_0()
    prevdrillover90seconds := (A_TickCount - previous_drill_tickcount) > 90000  
    if allowDrilling 
        && meteorhp_pct > MINIMUM_METEOR_HP_FOR_DRILLING 
        && last_hp < 5 && haveDrill 
        && user_is_idle && prevdrillover90seconds
        && drills_estimated > 0 {
      if hidWindow {
        try {
          WinShow(FORTNITEWINDOW)
          WinActivate(FORTNITEWINDOW)
        } 
      }
      drill()
      drills_estimated := drills_estimated - 1
      drills_estimated := drills_estimated + (A_TickCount - previous_drill_tickcount) / 900
      previous_drill_tickcount := A_TickCount
      if hidWindow {
        try {
          WinHide(FORTNITEWINDOW)
          ; unfocus()
        }
      }
      ; unfocus()
      maybe_unfocus()

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

; TODO: drill only when estimated >0 drills
; do not use findtext
; (create global for drill count and increment every 90 seconds)
; (decrement every drill)

; this one probably is redundant and not needed anymore
; only seems to work out-of-focus when firekey = enter
; (You need to go into FN settings and bind fire to enter)
clicker_unfocused_dontuse(hideWindow, total_seconds := 3600*4) {
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
	ttHWND := FindText().ToolTip(msg,10,10,2,{timeout:5})
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
			; SecondsRemain.Value:=seconds_left
		}
		; give user 6 seconds to read the message:
		if A_TickCount - starttick > HIDE_SECONDS * 1000 {
			if hideWindow {
				hideWindow := false ; once only
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
          Try {
            WinActivate(activeWindow) ; return focus after traytip bubble
          }
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


; Application Volume stuff

global Volume := 50
VolumeIncrement := 5

ShowVolume()
{
	; WinSetTitle(GTAtitle "`: V" Volume, GTAwindow)
}

VolumeUpLoop() {
	Loop
	{
		if (GetKeyState("Shift", "P")) {
			global Volume:=Volume + 1
		} else
			global Volume:=Volume + VolumeIncrement
		If (Volume > 100)
			global Volume := 100
		ShowVolume()
		SetVolume()
		Sleep(10)
		if (! GetKeyState("Up", "P") )
			break
	}
    setVolume()
}

VolumeDownLoop()
{
	Loop
	{
		if (GetKeyState("Shift", "P")) {
			global Volume:=Volume - 1
		} else
			global Volume:=Volume - VolumeIncrement

		If (Volume <= 0) {
			global Volume := 1
			SetVolume()
			global Volume := 0
		}
		ShowVolume()
		SetVolume()
		Sleep(10)
		if (! GetKeyState("Down", "P") )
			break
	}
    setVolume()
}

setVolume()
{
	ErrorLevel := ProcessExist(FORTNITEPROCESS)
	global ProcessId := ErrorLevel
    SetAppVolume(ProcessId, Volume)
    ;;appvol:=GetAppVolume(ProcessId)
	;appvol:=SoundGetVolume()
}

; for v2
SetAppVolume(PID, MasterVolume)    ; WIN_V+
{
	;;SoundSetVolume(MasterVolume) ; this is system/master volume, not app volume
	AppVol(FORTNITEPROCESS,MasterVolume) ; thanks to the github gist!
}

; from https://gist.github.com/anonymous1184/b251cd8407a379d4965791585887cfce
AppVol(Target := "A", Level := 0) {
    if (Target ~= "^[-+]?\d+$") {
        Level := Target
        Target := "A"
    } else if (SubStr(Target, -4) = ".exe") {
        Target := "ahk_exe " Target
    }
    try {
        hw := DetectHiddenWindows(true)
        appName := WinGetProcessName(Target)
        DetectHiddenWindows(hw)
    } catch {
        throw TargetError("Target not found.", -1, Target)
    }
    GUID := Buffer(16)
    DllCall("ole32\CLSIDFromString", "Str", "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}", "Ptr", GUID)
    IMMDeviceEnumerator := ComObject("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
    ComCall(4, IMMDeviceEnumerator, "UInt", 0, "UInt", 1, "Ptr*", &IMMDevice := 0)
    ObjRelease(IMMDeviceEnumerator.Ptr)
    ComCall(3, IMMDevice, "Ptr", GUID, "UInt", 23, "Ptr", 0, "Ptr*", &IAudioSessionManager2 := 0)
    ObjRelease(IMMDevice)
    ComCall(5, IAudioSessionManager2, "Ptr*", &IAudioSessionEnumerator := 0) || DllCall("SetLastError", "UInt", 0)
    ObjRelease(IAudioSessionManager2)
    ComCall(3, IAudioSessionEnumerator, "UInt*", &cSessions := 0)
    loop cSessions {
        ComCall(4, IAudioSessionEnumerator, "Int", A_Index - 1, "Ptr*", &IAudioSessionControl := 0)
        IAudioSessionControl2 := ComObjQuery(IAudioSessionControl, "{BFB7FF88-7239-4FC9-8FA2-07C950BE9C6D}")
        ObjRelease(IAudioSessionControl)
        ComCall(14, IAudioSessionControl2, "UInt*", &pid := 0)
        try {
            if (pid && ProcessGetName(pid) == appName) {
                ISimpleAudioVolume := ComObjQuery(IAudioSessionControl2, "{87CE5498-68D6-44E5-9215-6DA47EF883D8}")
                ComCall(6, ISimpleAudioVolume, "Int*", &isMuted := 0)
                if (isMuted || !Level) {
                    ComCall(5, ISimpleAudioVolume, "Int", !isMuted, "Ptr", 0)
                }
                if (Level) {
                    ComCall(4, ISimpleAudioVolume, "Float*", &levelOld := 0.0)
                    if (Level ~= "^[-+]") {
                        levelNew := Max(0.0, Min(1.0, levelOld + (Level * 0.01)))
                    } else {
                        levelNew := Level * 0.01
                    }
                    if (levelNew != levelOld) {
                        ComCall(3, ISimpleAudioVolume, "Float", levelNew, "Ptr", 0)
                    }
                }
                ObjRelease(ISimpleAudioVolume.Ptr)
            }
        }
    }
    return (IsSet(levelOld) ? Round(levelOld * 100) : -1)
}


findtext_AUTO_X()  {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<AUTO_X>*3$76.MZsU00000003AWE4U00000004c94G00000000GUYF8000000019mF4U00000004d44800000000nU"
  if (ok:=FindText(&X, &Y, 1433-150000, 46-150000, 1433+150000, 46+150000, 0, 0, Text))
  {
      FindText().Click(X+20, Y, "L")
  }
}


findtext_pickaxe_whitebox() {
  ; #Include <FindText>
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<whiteborderbox>*253$23.0000zzztzzznzzzbzzzDzzyTzzwzzztzzznzzzbzzzDzzyTzzwzzztzzznzzzbzzzDzzyTzzwzzztzzznzzzU000E"
  if (ok:=FindText(&X, &Y, 1536-150000, 326-150000, 1536+150000, 326+150000, 0, 0, Text))
  {
    ; FindText().Click(X, Y, "L")
  }
}

; SetTimer(pickaxe_boxcount,500)

; 20 when pickaxe is selected
pickaxe_boxcount() {
  ; 1527, 315, 1546, 315
  whites := FindText().PixelCount(1520, 315, 1550, 315, "FEFEFE")
  ; FindText().ToolTip(whites,500,20,3)  
  return whites
}

;;; END OF MINER TYCOON code ;;; 

; sorry to you Miner Tycoon players; this was just the most convenient place to stick this for now
fight_zeus() 
{
  MoveWindowToUpperRight()
  Loop {
    Send("{shift up}{space}{w down}")
    Loop 10 {
      Sleep(100)
      Send("e")
    }
    Send("{w up}")

    Send("e")
    Sleep(1000)

    ; choose DPS
    t1:=A_TickCount, Text:=X:=Y:=""
    X:="wait"
    Y:=5.0
    Text:="|<DPS_icon>*222$13.zDzjzrzxzWDyzyjv6xXMlXMrgPqBx5zrw"
    if (ok:=FindText(&X, &Y, 1239-150000, 320-150000, 1239+150000, 320+150000, 0.09, 0.09, Text))
    {
      FindText().Click(X, Y, "L")
    } else {
      FindText().Click(1239,320, "L")
    }
    
    t1:=A_TickCount, Text:=X:=Y:=""
    Text:="|<FIGHT>*233$25.mwzPDPBjrhyrPqzTjPRjqxiqvSszBk"
    X:="wait"
    Y:=10.0
    if (ok:=FindText(&X, &Y, 1432-150000, 311-150000, 1432+150000, 311+150000, 0.09, 0.09, Text))
    {
       Sleep(200)
       FindText().Click(X, Y, "L")
    }
    
    Loop 2 {
      FindText().Click(1432, 311, "L")
      Sleep(1000)
    }

    FindText().ToolTip("15 sec wait")
    Sleep(15000)

    ; Send("{LButton down}")
    ; Sleep(60000)
    FindText().ToolTip("clicking")
    Loop 200 * 5 {
      Click()
      if A_Index > 150 {
        if A_Index = 151 { 
          FindText().ToolTip("scanning")
        }
        t1:=A_TickCount, Text:=X:=Y:=""
        Text:="|<HP_left_border>*17$13.D3k00020100E088200Y0A01U0AU"
        ok:=FindText(&X, &Y, 1065-150000, 46-150000, 1065+150000, 46+150000, 0.09, 0.09, Text)
        Sleep(100) 
        if (! ok)
        {
          Click("down")
          FindText().ToolTip("cant find HP_left_border")
          Sleep(2000)
          break
        }
      } else {
        Sleep(200)
      }
    }
    FindText().ToolTip("Stopped clicking")
    Sleep(2000)
    FindText().ToolTip("10 second delay")
    Click("up")
    Sleep(9000)
    FindText().ToolTip("loop")
    Sleep(1000)
  } 
}

; 44.7QiD @ 2:19
; 50.9Qid @3:42
; 6.2Qid in 83 minutes

; count_pandoras() {
;   t1:=A_TickCount, Text:=X:=Y:=""
;   Text:="|<>00DB84-101010$3.w"
;   xtrax:=20
;   xtray:=0
;   ok:=FindText(&X, &Y, 981-xtrax, 238-xtray, 981+xtrax, 238+xtray, 0, 0, Text)
;   pandoras:=IsObject(ok)?ok.Length:ok
;   FindText().ToolTip(pandoras)
;   return pandoras
; }

count_pandoras() {
  greens := FindText().PixelCount(970,238,1020,238,"00DB84")
  pandoras := greens/3
  ; FindText().ToolTip(pandoras)
  return pandoras
}


getcolorforgeEnable := false 

getcolorforge() {
  color := PixelGetColor( 1356, 305)
  FindText().ToolTip(color,550,20)
  return color
}

getcolorforgeToggle() {
  global getcolorforgeEnable
  getcolorforgeEnable := ! getcolorforgeEnable
  if getcolorforgeEnable {
    SetTimer(getcolorforge, 100)
  }  else {
    SetTimer(getcolorforge, 0)
    FindText().ToolTip()
  } 
}

; untested (surely not right)
; probably need pixelcount instead of PixelGetColor
; didnt work; see next version
forge_nonworking() {
  sleeptime := 10
  Loop 1000 {
    purple:= "860062" 
    blue := "0055A8"
    c := getcolorforge()
    if c := blue {
      Click("L")
      Sleep(sleeptime*3)
    }
    if c := purple {
      Click("R")
      Sleep(sleeptime*3)
    }
    Sleep(sleeptime)
  }
}

FORGELEFT := 1349  ; was 1349

findtext_forgeblue() {
  global FORGELEFT
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<forge_blue>260072-101010$12.U0U0EU8801804001040EU"
  xtra:=20
  if (ok:=FindText(&X, &Y, FORGELEFT-xtra, 308-xtra, FORGELEFT+xtra, 308+xtra, 0, 0, Text))
  {
    Click()
  }
  return X
}


findtext_forgepurple() {
  global FORGELEFT
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<forge_purple>241172-101010$14.00E08040080000088"
  xtra:=20
  if (ok:=FindText(&X, &Y, FORGELEFT-xtra, 308-xtra, FORGELEFT+xtra, 308+xtra, 0, 0, Text))
  {
     Click("R")
  }
  return X
}

findtext_forge_blue_purple() {
  global FORGELEFT
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<forge_blue>260072-101010$12.U0U0EU8801804001040EU"
  Text.="|<forge_purple>241172-101010$14.00E08040080000088"
  xtra:=20
  X:="wait1"
  Y:=1.0
  if (ok:=FindText(&X, &Y, FORGELEFT-xtra, 308-xtra, FORGELEFT+xtra, 308+xtra, 0, 0, Text))
  {
    ; cmnt := ""
    ; Try
    cmnt := ok[1].id
    if cmnt == "forge_blue" {
      Click("L")
    }
    else if cmnt == "forge_purple" {
      Click("R")
    }
    ;  else {
    ;   Click("L")
    ;   Click("R")
    ; }
    ; FindText().ToolTip("(" X "," Y ") " cmnt,500,20)
    Sleep(5)
  }
  return ok
}

forge()
{
  fails := 0
  loop 10000 {
    fb:=findtext_forgeblue()
    fp:=findtext_forgepurple()
    ok := fb || fp
    if ok {
      fails := 0
      ; Try m := ok[1]
      ; cmnt := ""
      ; Try cmnt := m.id
      ; Try FindText().ToolTip("(" m.x "," m.y ") " cmnt,500,20)
      ; Sleep(20)
    } else {
      fails += 1
    }
    Sleep(15)
    if fails > 500 {
      break
    }
  }
}

forge2()
{
  fails := 0
  loop 600 {
    ; fb:=findtext_forgeblue()
    ; fp:=findtext_forgepurple()
    ; if fb || fp {
    f := findtext_forge_blue_purple()
    if f {
      fails := 0
    } else {
      fails += 1
    }
    Sleep(5)
    if fails > 99 {
      FindText().ToolTip("exiting forge")
      break
    }
  }
}
; SetTimer(count_pandoras, 1000)

Sleep(1000)
FindText().ToolTip()

; wanted to time meteors 
; #include "*i MOTiming.ahk"

