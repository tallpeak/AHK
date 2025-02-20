; Miner Tycoon (Odyssey)
; todo user config into Map https://www.autohotkey.com/docs/v2/lib/Map.htm
; findtext strings etc
#Requires AutoHotkey v2.0
#SingleInstance
; #WinActivateForce 1

#Include "*i findtextv2_v9.6.ahk" ; revert because of crashes occurring after Windows update (23H2 rollup)
#Include "appvol.ahk"


; no longer makes sense to time meteor1:
TimeMeteor1 := false

; #MaxThreads 5
; InstallKeybdHook(true)
; no...  InstallMouseHook(true) ; so that A_TIMEIDLEPHYSICAL includes mouse
; SetDefaultMouseSpeed 3 ; default 2, trying to slow down a bit just in case mouse speed affects glitchy behavior at low wattage

SendMode("Event")
SetKeyDelay 80,80

FindText().ToolTip("Loading macros...",70,300)
; Send("{Enter up}")

global DRILLS_TO_KEEP := 2
global scanForGameLauncher_MinerTycoon_interval_ms := 60000

; main key bindings (for FN=active/focused window):
#HotIf WinActive(FORTNITEWINDOW)
; ^PrintScreen::FindText().Gui("Show") ; problematic if in a captured window

; ^End::Reload
^r::Reload
!r::Reload

LCTRL & UP::VolumeUpLoop()
LCTRL & Down::VolumeDownLoop()

; ^!+e::Edit()
#HotIf

^PrintScreen::FindText().Gui("Show")


update_DRILLS_TO_KEEP(n) {
  global DRILLS_TO_KEEP
  DRILLS_TO_KEEP += n
  if DRILLS_TO_KEEP > 4
    DRILLS_TO_KEEP := 4
  if DRILLS_TO_KEEP < 0
    DRILLS_TO_KEEP := 0
  FindText().ToolTip("drills to keep=" DRILLS_TO_KEEP, 450, 20, 2, {timeout:2})
}

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
		; CoordMode "Mouse", (bak:=A_CoordModeMouse)?"Screen":"Screen"
		; MouseMove(CENTERX,CENTERY)
		; CoordMode "Mouse", bak
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

global SignalRemoteKey := "" ; 1 or 2; initialized by a timer

switchToRemote() 
{
	if ! SignalRemoteKey {
		getSignalRemoteKey()
		while ! SignalRemoteKey {
			FindText().ToolTip("Waiting for signal remote to appear")
			Sleep(1000)
			getSignalRemoteKey()
		}  
		FindText().ToolTip()
	}
	Send(SignalRemoteKey)
}
  
findtext_signalRemote()
{
	; global EXTRA
	xtra := 444 ; EXTRA 
  t1:=A_TickCount, Text:=X:=Y:=""
  ; X:="wait"
  ; Y:=5.0
  Text:="|<signalremote2_blackoutline>*44$12.60048307E60A08U80EsEAE3kU"
  ok:=FindText(&X, &Y, 1582-xtra, 335-xtra, 1582+xtra, 335+xtra, 0.05,0.05, Text)
  if ok
    return ok
  ; Text:="|<signalremote1>*33$11.6000010k1000802122141kU" ; latest capture, window was in wrong positions
  ; ok:=FindText(&X, &Y, 1524-xtra, 326-xtra, 1524+xtra, 326+xtra, 0, 0, Text)
  ; if ok
  ;   return ok
  Text:="|<signalremote1>*55$13.00X005F0sUQ0A0A0402421V0AU0UE"  
  ok:=FindText(&X, &Y, 1557-xtra, 327-xtra, 1557+xtra, 327+xtra, 0.051, 0.051, Text)
	return ok
}

getSignalRemoteKey()
{
	global SignalRemoteKey
	oldSignalRemoteKey := SignalRemoteKey
	ok:=findtext_signalRemote()
	if !ok && SignalRemoteKey == "" {
    ; FindText().ToolTip("signal remote not found")
		; Sleep(2222)
		; FindText().ToolTip()	
		return
	}
  x:=0
	Try x:=ok[1].x
	if x > 1557+5 { ; A_ScreenWidth-40 {
		SignalRemoteKey := "2"
	} else if x > 1500 {
		SignalRemoteKey := "1"
	}
	if oldSignalRemoteKey != SignalRemoteKey {
		FindText().ToolTip("x=" x ",SignalRemoteKey=" SignalRemoteKey,400,20,2,{timeout:3})
		; Sleep(3333)
		; FindText().ToolTip()	
	}
	; global SignalRemoteKey
	; WinActivate(FORTNITEWINDOW)
	; sleep(333) 
	; SignalRemoteKey := InputBox("Enter signal remote key (eg. 1 or 2)","SignalRemoteKey",,"1").Value
	; sleep(333) 
	; WinActivate(FORTNITEWINDOW)
	; sleep(333)
	; every 10 seconds until found, then every 60 secconds
	if SignalRemoteKey {
		SetTimer(getSignalRemoteKey,-60000)
	} else {
		SetTimer(getSignalRemoteKey,-10000)
	}
	return SignalRemoteKey
}

SetTimer(getSignalRemoteKey, -10000)
 
Click_at_Cursor() {
  Loop {
    Click()
    kw:=KeyWait("RCtrl", "DT0.03")
    if kw {
      break
    }
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
	; unfocus()
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

; global DRILLS_TO_KEEP := 0

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
VK_BACKSPACE := 8
VK_DELETE	:= 0x2E	; DEL key
firekey := VK_DELETE ; 9 ;  165 ; ralt ; 18 alt ; 161 ; VK_RSHIFT ; VK_BACKSPACE   ; 13 ; Enter
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



findtext_AUTO_X()  {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<AUTO_X>*3$76.MZsU00000003AWE4U00000004c94G00000000GUYF8000000019mF4U00000004d44800000000nU"
  if (ok:=FindText(&X, &Y, 1433-150000, 46-150000, 1433+150000, 46+150000, 0, 0, Text))
  {
      FindText().Click(X+20, Y, "L")
  }
}


findtext_signalRemote_bottomleftcurve() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<signalremote>BF611B-101010$18.008000000U00s00s04s00s00k00s00k00s0Uk06s0Dw0Tx0zDNy3zw1zkU"
  ok:=FindText(&X, &Y, 1582-150000, 334-150000, 1582+150000, 334+150000, 0, 0, Text)
  return ok
}


;;; END OF MINER TYCOON code ;;;

Sleep(1000)
FindText().ToolTip()

; wanted to time meteors
; #include "*i MOTiming.ahk"

^!+End::Run("taskkill /IM `"FortniteClient-Win64-*`"")


; sorry to you Miner Tycoon players; this was just the most convenient place to stick this for now
fight_zeus() 
{
  pickaxe() ; Send("``") ; pickaxe
  MoveWindowToUpperRight()
  Loop {
    Send("{shift up}{space}{w down}")
    Loop 10 {
      Sleep(100)
      Send("e")
    }
    Send("{w up}")

    Send("e")
    Sleep(500)

    ; ; choose DPS
    ; t1:=A_TickCount, Text:=X:=Y:=""
    ; X:="wait"
    ; Y:=1.0
    ; Text:="|<DPS_icon>*222$13.zDzjzrzxzWDyzyjv6xXMlXMrgPqBx5zrw"
    ; if (ok:=FindText(&X, &Y, 1239-150000, 320-150000, 1239+150000, 320+150000, 0.09, 0.09, Text))
    ; {
    ;   FindText().Click(X, Y, "L")
    ; } else {
    ;   FindText().Click(1239,320, "L")
    ; }
    
    t1:=A_TickCount, Text:=X:=Y:=""
    Text:="|<FIGHT>*233$25.mwzPDPBjrhyrPqzTjPRjqxiqvSszBk"
    X:="wait"
    Y:=2.0
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
    seconds := 85
    Loop seconds * 5 {
      Click("D")
      if A_Index/5 >= 25 {
        if A_Index/5 = 25 { 
          FindText().ToolTip("scanning")
        }
        t1:=A_TickCount, Text:=X:=Y:=""
        Text:="|<HP_left_border>*33$17.U00000002000004004004006003001U00A004006"
        ; if (ok:=FindText(&X, &Y, 1067-150000, 48-150000, 1067+150000, 48+150000, 0, 0, Text))
        Text.="|<HP_left_border>*17$13.D3k00020100E088200Y0A01U0AU"
        Text.="|<HP_left_border>**50$18.s00Dzz1U00zz0k00M00C003001kU"
        xtra:=200
        ok:=FindText(&X, &Y, 1065-xtra, 46-xtra, 1065+xtra, 46+xtra, 0.22, 0.22, Text)
        Sleep(100) 
        if (! ok)
        {
          Click("down")
          FindText().ToolTip("cant find HP_left_border")
          Sleep(1000)
          Click("up")
          break
        }
      } else {
        Sleep(200)
      }
    }
    Click("up")
    FindText().ToolTip("Stopped clicking..wait 10 seconds..looping")
    Sleep(10000)
    FindText().ToolTip("loop")
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
  FindText().ToolTip(pandoras,100,10) ; DEBUG (with SetTimer)
  return pandoras
}

; SetTimer(count_pandoras, 1000)


; newer clips on 2/4/2025
; findtext_purpleforge() {
;   t1:=A_TickCount, Text:=X:=Y:=""
;   Text:="|<purpleforge>662483-101010$15.00M0T0Dk7w7y3zAlz7jU1U0C0U"
;   xtra:=20
;   ok:=FindText(&X, &Y, 1367-xtra, 305-xtra, 1367+xtra, 305+xtra, 0, 0, Text)
;   return ok
; }

; findtext_blueforge() {
;   t1:=A_TickCount, Text:=X:=Y:=""
;   Text:="|<blueforge>2D2E83@0.90$15.k07U0TU1z07z1jw7wkTD0AU7UU"
;   xtra:=20
;   ok:=FindText(&X, &Y, 1367-xtra, 305-xtra, 1367+xtra, 305+xtra, 0, 0, Text)
;   return ok
; }


getcolorforgeEnable := false 

drift := -10

getcolorforge() {
  global drift
  CoordMode('Pixel','Screen') 
  X := 1366 + drift
  drift := drift + 1
  if drift > 10 {
    drift := -10
  }
  ; color := PixelGetColor( 1356, 305)
  color := PixelGetColor( X, 308)
  FindText().ToolTip(X "," color,222,333)
    return color
}

getcolorforgeToggle() {
  global getcolorforgeEnable
  getcolorforgeEnable := ! getcolorforgeEnable
  if getcolorforgeEnable {
    SetTimer(getcolorforge, 999)
  }  else {
    SetTimer(getcolorforge, 0)
    FindText().ToolTip()
  } 
}

; ; untested (surely not right)
; ; probably need pixelcount instead of PixelGetColor
; ; didnt work; see next version
; forge_nonworking() {
;   sleeptime := 10
;   Loop 1000 {
;     purple:= "860062" 
;     blue := "0055A8"
;     c := getcolorforge()
;     if c := blue {
;       Click("L")
;       Sleep(sleeptime*3)
;     }
;     if c := purple {
;       Click("R")
;       Sleep(sleeptime*3)
;     }
;     Sleep(sleeptime)
;   }
; }

FORGELEFT := 1369  ; was 1349 when left-to-right search, now right-to-left so add the 20 pixels tolerance

; findtext_forgeblue() {
;   global FORGELEFT
;   t1:=A_TickCount, Text:=X:=Y:=""
;   Text:="|<forge_blue>260072-101010$12.U0U0EU8801804001040EU"
;   xtra:=20
;   if (ok:=FindText(&X, &Y, FORGELEFT-xtra, 308-xtra, FORGELEFT+xtra, 308+xtra, 0, 0, Text))
;   {
;     Click()
;   }
;   return X
; }


; findtext_forgepurple() {
;   global FORGELEFT
;   t1:=A_TickCount, Text:=X:=Y:=""
;   Text:="|<forge_purple>241172-101010$14.00E08040080000088"
;   xtra:=20
;   if (ok:=FindText(&X, &Y, FORGELEFT-xtra, 308-xtra, FORGELEFT+xtra, 308+xtra, 0, 0, Text))
;   {
;      Click("R")
;   }
;   return X
; }



; forge()
; {
;   fails := 0
;   loop 10000 {
;     fb:=findtext_forgeblue()
;     fp:=findtext_forgepurple()
;     ok := fb || fp
;     if ok {
;       fails := 0
;       ; Try m := ok[1]
;       ; cmnt := ""
;       ; Try cmnt := m.id
;       ; Try FindText().ToolTip("(" m.x "," m.y ") " cmnt,500,20)
;       ; Sleep(20)
;     } else {
;       fails += 1
;     }
;     Sleep(15)
;     if fails > 500 {
;       break
;     }
;   }
; }

; do not exceed 1356 (leftmost)   pixels
FORGE_XTRAX := 20
FORGELEFT := 1365  ; was 1349 when left-to-right search, now right-to-left so add the 20 pixels tolerance

findtext_forge_blue_purple() {
  global FORGELEFT, FORGE_XTRAX
  t1:=A_TickCount, Text:=X:=Y:=""
  ; Text:="|<forge_blue>260072-101010$12.U0U0EU8801804001040EU"
  ; Text.="|<forge_purple>241172-101010$14.00E08040080000088"
  Text:="|<p>662483-101010$15.00M0T0Dk7w7y3zAlz7jU1U0C0U" ; purple
  Text.="|<b>2D2E83@0.90$15.k07U0TU1z07z1jw7wkTD0AU7UU"   ; blue

  xtrax:=FORGE_XTRAX ; was 20, but missed a few?
  xtray:=5 ; smallest that works? (reduce?) 
  X:="wait1"
  Y:=5.0 ; seconds to wait for a forge icon to appear 
  right_to_left := 2 ; or 7; see https://www.autohotkey.com/boards/viewtopic.php?t=102806 ?
  if (ok:=FindText(&X, &Y, FORGELEFT-xtrax, 308-xtray, FORGELEFT+xtrax, 308+xtray, 0.05, 0.05, Text,,FindAll:=0,,,,dir:=right_to_left))
  {
    cmnt := ok[1].id
    if cmnt == "b" {
      Click("L")
      ; Sleep(5)
      ; Click("R") ; if you get the color wrong, it may work to click the other color
    }
    else if cmnt == "p" {
      Click("R")
      ; Sleep(5)
      ; Click("L") ; if you get the color wrong, it may work to click the other color
    }
    ; Sleep(40)
    ms:=(FORGELEFT-X)*12  ; approx 10 ms per pixel; rightmost finds should not delay,
      ;  but leftmost finds should delay long enough to prevent clicking outside of the forge area
    ; FindText().ToolTip(ms "ms" ",(" X "," Y ") " cmnt,222,333)
    if ms>1 {
      ; FindText().ToolTip(ms "ms,X=" X,222,333)
      Sleep(ms)
    }    
  }
  return ok
}

FORGE_FASTMODE := true

toggle_fastmode() {
  global FORGE_FASTMODE
  FORGE_FASTMODE := ! FORGE_FASTMODE
  if FORGE_FASTMODE {
    FindText().ToolTip("Fast mode", 450, 20, 2, {timeout:1})
  } else {
    FindText().ToolTip("Slow mode", 450, 20, 2, {timeout:1})
  }
}

forge_click_blue_purple() {
  cpurple:= "860062" 
  cpurplef := "662483"
  cblue := "0055A8"
  cbluef := "2D2E83"
  if A_CoordModePixel != 'Screen' {
    CoordMode('Pixel','Screen') 
  }  
  c := PixelGetColor(1369, 308)
  c2 := PixelGetColor(1369, 305)
  if c == cblue || c == cbluef || c2 == cblue || c2 == cbluef {
    Click("L")
  } else if c == cpurple || c == cpurplef || c2 == cpurple || c2 == cpurplef {
    Click("R")
  }
  
}

global prev_ttt := ""

forge_click_blue_purple2() {
  global prev_ttt 
  cpurple:= "860062" 
  cpurplef := "662483"
  cblue := "0055A8"
  cbluef := "2D2E83"
  if A_CoordModePixel != 'Screen' {
    CoordMode('Pixel','Screen') 
  }  
  x1 := 1357
  y1 := 305  ; 308 - 3
  x2 := 1366
  y2 := 311  ; 308 + 3

  ; p1 := FindText().PixelCount(x1:=x1, y1:=y1, x2:=x2, y2:=y2, ColorID:=cpurple, Variation:=0, ScreenShot:=1)
  p2 := FindText().PixelCount(x1:=x1, y1:=y1, x2:=x2, y2:=y2, ColorID:=cpurplef, Variation:=0, ScreenShot:=1)
  ; b1 := FindText().PixelCount(x1:=x1, y1:=y1, x2:=x2, y2:=y2, ColorID:=cblue, Variation:=0, ScreenShot:=0)
  b2 := FindText().PixelCount(x1:=x1, y1:=y1, x2:=x2, y2:=y2, ColorID:=cbluef, Variation:=0, ScreenShot:=0)
  p := p2 ; + p1
  b := b2 ; + b1
  thresh := 10
  if b > thresh && b > p {
    Click("L")
  } else if p > thresh {
    Click("R")
  }
  if b > thresh || p > thresh {
    ; ; Only show non-zero values
    ; ttt := ""
    ; if p > 0
    ;   ttt .= "p=" p ","
    ; if b > 0
    ;   ttt .= "b=" b ","
    ; ; remove trailing comma:
    ; ttt := SubStr(ttt, 1, StrLen(ttt)-1) ; thanks to https://www.autohotkey.com/boards/viewtopic.php?t=102806
    ; if ttt && ttt != prev_ttt {
    ;   FindText().ToolTip(ttt, 320, 1372)
    ;   prev_ttt := ttt
    ; }
    Sleep(80)
  }
}

forge2()
{
  global FORGE_FASTMODE
  FindText().ToolTip("forge2",70,300)
  Send("e")
  Sleep(800)
  FindText().ToolTip()

  ; SetTimer(getcolorforge, 999) ; must disable until working again
  fails := 0
  loop 2345 {
    if FORGE_FASTMODE {
      ; forge_click_blue_purple() ; getpixel version
      forge_click_blue_purple2() ; pixelcount version
      Sleep(5)  
    }
    else {
      f := findtext_forge_blue_purple()
      if f {
        fails := 0
      } else {
        fails += 1
      }
      Sleep(15)
      rc := GetKeyState("RCtrl")
      if fails > 10 || rc {
        FindText().ToolTip(">10 fails exiting forge")
        Sleep(5000)
        FindText().ToolTip()
        break
      }
  
    }


  }

  SetTimer(getcolorforge, 0)
  FindText().ToolTip()

}

; from miner??
; FindAndClick_GreenMAX() {
;     cnt := 0
;     t1:=A_TickCount, Text:=X:=Y:=""
;     Text:="|<MAX>80E381-101010$24.MkcoIEcIJN8QJN8QHNwoEN4aU"
;     if (ok:=FindText(&X, &Y, FORGELEFT-99, 1, FORGELEFT+99, 1500, 0.05, 0.05, Text))
;     {
;       cnt += 1
;       FindText().Click(X,Y, "L")
;       Sleep(100)
;       FindText().Click(X,Y, "L")
;       Loop 3 {
;         Sleep(100)
;         FindText().Click(X+100, Y, "L")
;       }
;     }
;     return cnt
; }

; clicker_pandoras() {
;     Loop {
;         Click("L down")
;         kw:=KeyWait("RCtrl", "DT0.03")
;         if kw {
;             break
;         }
;         ps:=count_pandoras()
;         if ps > 2 {
;             Click("L up")
;             switchToRemote()
;             Click("L")
;             ; findtext_PAndoras()
;         }

;     }
;     Click("L up")


; }

;same as below????    
findtext_close2_golem_scoreboard() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<CLOSE>*222$21.awlVLOhOvLfrORSvNXLPZ+vIglaAU"
  if (ok:=FindText(&X, &Y, 1430-150000, 65-150000, 1430+150000, 65+150000, 0, 0, Text))
  {
    FindText().Click(X, Y, "L")
  }
}

findtext_close_golem() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<CLOSE>*220$22.awlUfhKqipvSvHhvhaKip/+vIiMn68"
  X:="wait"
  Y:=15.0
  xtra:=200
  if (ok:=FindText(&X, &Y, 1431-xtra, 65-xtra, 1431+xtra, 65+xtra, 0, 0, Text))
  {
      FindText().Click(X, Y, "L")
  }
}

findtext_close() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<CLOSE>*210$22.WwlUfVGqip/SvHhvhaKirPOvIgfhGsXAMU"
  X:="wait"
  Y:=1.0
  if (ok:=FindText(&X, &Y, 1415-150000, 62-150000, 1415+150000, 62+150000, 0, 0, Text))
  {
    FindText().Click(X, Y, "L")
  } else {
    Sleep(500)
    FindText().Click(1415, 62, "L")
  }
}

findtext_HPGolem()
{
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<hpbar_leftedge>**50$23.rU7kFs0sES0ME7UEE1U0E1U0E100k300k300U300U201U601060106"
  ok:=FindText(&X, &Y, 1072-150000, 43-150000, 1072+150000, 43+150000, 0, 0, Text)
  return ok
}

; find [E] BOSS FIGHT GOLEM interaction button
findtext_BOSSFI(secs) {
  t1:=A_TickCount, Text:=""
  X:="wait1"
  Y:=secs
  Text:="|<BOSSFI>*200$41.DzgnDCTzzSizzwzzxixybztaNzns"
  xtra:=100
  ok:=FindText(&X, &Y, 1261-xtra, 170-xtra, 1261+xtra, 170+xtra, 0, 0, Text)
  return ok
}

fight_golem1() {
  Send("{shift up}{space}")
  Loop 20 {
    Send("{w down}")
    Sleep(50)
    Send("{w up}")
    Sleep(50)
    Send("e")
  }
  Sleep(50)
  Send("{w up}")
  Sleep(50)

  Send("e")
  Sleep(500)

  ; ; choose DPS
  ; t1:=A_TickCount, Text:=X:=Y:=""
  ; X:="wait"
  ; Y:=1.0
  ; Text:="|<DPS_icon>*222$13.zDzjzrzxzWDyzyjv6xXMlXMrgPqBx5zrw"
  ; if (ok:=FindText(&X, &Y, 1239-150000, 320-150000, 1239+150000, 320+150000, 0.09, 0.09, Text))
  ; {
  ;   FindText().Click(X, Y, "L")
  ; } else {
  ;   FindText().Click(1239,320, "L")
  ; }
  
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<FIGHT>*233$25.mwzPDPBjrhyrPqzTjPRjqxiqvSszBk"
  X:="wait"
  Y:=2.0
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
  seconds := 200
  golemhpfailures := 0
  Loop seconds * 5 {
    Click("D")
    ; don't scan for at least 20 seconds
    if A_Index/5 >= 20 {
      ok := findtext_HPGolem()
      if (! ok)
      {
        golemhpfailures += 1
      } else {
        golemhpfailures := 0
      }
      if golemhpfailures > 3 {
        FindText().ToolTip("cant find HP Golem leftborder")
        Click("up")
        ; Sleep(3000)
        findtext_close_golem()
        ; Sleep(5000)
        findtext_close_golem()
        break
      }
    } else {
      Sleep(200)
    }
  }
  Click("up")
  FindText().ToolTip("Stopped clicking..wait 20 seconds..looping")
  ; Sleep(15000)
  findtext_BOSSFI(25)
  FindText().ToolTip("loop")
}

fight_golem()
{
  pickaxe() 
  MoveWindowToUpperRight()
  Loop {
    fight_golem1()
  }
}

findtext_use_pandora()
{
  ms:=666
  ; Sleep(ms)
  ; srk:=getSignalRemoteKey()

  Sleep(ms)
  switchToRemote()
  Sleep(ms)
  Click("R")
  Sleep(ms)
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<PANDORASBOX>*220$56.6PEl3+7GhKaJdKuhqdJdZOpetxeJOfKhGjD4YJeZfFhtq94kdOJMPReJRfKZOqLGhDvoSyjnnnm"
  xtra:=200
  if (ok:=FindText(&X, &Y, 1415-xtra, 206-xtra, 1415+xtra, 206+xtra, 0.05, 0.05, Text))
  {
      FindText().Click(X, Y, "L")
  } else {
      Sleep(500)
      FindText().Click(1415, 206, "L")
  }

  findtext_Activate()

  findtext_close()

  Sleep(ms)
  pickaxe()
 
}

findtext_Activate() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<Activate>*210$41.XzzTzzzLzTzzjyjCBhb7/RxvPqxavvqiBsUrnhPNrRnnQmtn"
  xtra:=200
  if (ok:=FindText(&X, &Y, 1214-xtra, 254-xtra, 1214+xtra, 254+xtra, 0, 0, Text))
  {
      FindText().Click(X, Y, "L")
  } else {
      Sleep(500)
      FindText().Click(1214, 254, "L")
  }
}

pandora_loop() {
  ms:=666
  loop {
    Sleep(ms)
    Send("Y")
    Sleep(ms)
    Send("{Escape}")
    Sleep(ms)
    Click("Left Up")
    Sleep(ms)
    ps:=count_pandoras()
    FindText().ToolTip("pandoras:" ps)
    if ps >= 3 { 
      findtext_use_pandora()
    }
    ; fails if not in focus:
    ActivateFortniteWindow()
    Sleep(ms)
    Click("Left Down")
    Sleep(ms)
    Send("Y")
    FindText().ToolTip()
    minutes := 5
    if ps <= 2 {
      minutes := 15
    }
    Sleep(minutes*60*1000)
    Send("{Esc}")
    Sleep(ms)
    Click("Left Up")
    Sleep(ms)
  }

}

#HotIf WinActive(FORTNITEWINDOW)

; ^/::FindText().MouseTip(150,150,20,20)
; RShift & [::FindText().CaptureCursor(1) ; to Capture Cursor
; RShift & ]::FindText().CaptureCursor(0) ; to Cancel Capture Cursor
; look into MouseGetPos and Gui_MouseMove and how FindText captures the mouse cursor

^o::forge2()
RShift & o::forge2()
^+z::fight_zeus() ; actually any boss except Golem
^g::fight_golem() ; blocking not implemented
^p::pandora_loop()

^f::toggle_fastmode()

^+m::MoveWindowToUpperRight() ; for when I accidentally fullscreen

; ^+g::getcolorforgeToggle()


#HotIf 
