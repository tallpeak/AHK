 ; Fortnite Creative - bee tycoon
; todo user config into Map https://www.autohotkey.com/docs/v2/lib/Map.htm
; findtext strings etc
#Requires AutoHotkey v2.0
#SingleInstance
; #WinActivateForce 1

; #Include "*i findtextv2_v9.6.ahk" ; revert because of crashes occurring after Windows update (23H2 rollup)
#Include "*i findtextv2_v10.ahk"

#Include "appvol.ahk"

; #MaxThreads 5
InstallKeybdHook(true)
InstallMouseHook(true) ; so that A_TIMEIDLEPHYSICAL includes mouse
; SetDefaultMouseSpeed 3 ; default 2, trying to slow down a bit just in case mouse speed affects glitchy behavior at low wattage

SendMode("Event")
SetKeyDelay 80,80

FindText().ToolTip("Loading macros...",270,70)
; Send("{Enter up}")

FORTNITEPROCESS := "FortniteClient-Win64-Shipping.exe"
; FORTNITEWINDOW := "ahk_class UnrealWindow" ; ahk_exe " . FORTNITEPROCESS
FORTNITEWINDOW := "ahk_exe FortniteClient-Win64-Shipping.exe"
FORTNITEEXCLUDEWINDOW := "Epic Games Launcher"

; main key bindings (for FN=active/focused window):
#HotIf WinActive(FORTNITEWINDOW)
; ^PrintScreen::FindText().Gui("Show") ; problematic if in a captured window

; ^End::Reload
^r::Reload

LCTRL & UP::VolumeUpLoop()
LCTRL & Down::VolumeDownLoop()

; ^!+e::Edit()
#HotIf

^PrintScreen::FindText().Gui("Show")

^!+h::WindowHideToggle() ; control alt shift h to toggle window-hidden state:
^!+f::WinShow(FORTNITEWINDOW)

WINWIDTH := 640
WINHEIGHT := 360
WINX := A_ScreenWidth - WINWIDTH
WINY := 10
CENTERX := WINX + WINWIDTH/2
CENTERY := WINY + WINHEIGHT/2
DetectHiddenWindows true

IF ! WINEXIST(FORTNITEWINDOW) {
  Run("com.epicgames.launcher://apps/fn%3A4fe75bbc5a674f4f9b356b5c90567da5%3AFortnite?action=launch&silent=true")
  FindText().ToolTip("Launching Fortnite...",270,70)
  Sleep(10000)
  WinWait(FORTNITEWINDOW, 120)
  if ! WINEXIST(FORTNITEWINDOW) {

    FindText().ToolTip("Fortnite window not found",270,70)
    Sleep(10000)
    FindText().ToolTip()
    ; ExitApp
  }

}

global SignalRemoteKey := "" ; 1 or 2

getSignalRemoteKey()

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

MoveWindowToBigCenter() {
	WinMove(160,66,1280,720,FORTNITEWINDOW)
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

WinShow(FORTNITEWINDOW)

WindowHideToggle() {
	DetectHiddenWindows true
  global hidden
  localHidden := false  ; AHK fails to initialize globals half the time??!
  try localHidden := hidden
	if !localHidden {
    ; try catch as for the default setting, which is
    ; DetectHiddenWindows false
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
    else {
    WinShow(FORTNITEWINDOW)
    hidden := false
  }
}

WindowShowAndFocus() {
	WinShow(FORTNITEWINDOW)
	ActivateFortniteWindow()
	WinWaitActive(FORTNITEWINDOW)
}

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


  ; if (ok:=FindText(&X, &Y, 1582-150000, 328-150000, 1582+150000, 328+150000, 0, 0, Text))

  Text:="|<signalremote2_blackoutline>*44$12.60048307E60A08U80EsEAE3kU"
  Text.="|<signalremote2_raised>*44$12.60048307E60A08U80E8E6E0UU"
  ok:=FindText(&X, &Y, 1582-xtra, 335-xtra, 1582+xtra, 335+xtra, 0.08,0.08, Text)
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

; findtext_X()
; {
;   t1:=A_TickCount, Text:=X:=Y:=""
;   Text:="|<X>*48$14.A040200000000n0Ak1M0S07U1M0n0As"
;     xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 50)
;   if (ok:=FindText(&X, &Y, 1471-xtra, 54-xtra, 1471+xtra, 54+xtra, 0.03, 0.03, Text))
;   {
;     Loop 3 {
;       sleep(100)
;       FindText().Click(X, Y, "L")
;     }
;   }
; }


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

findtext_signalRemote_bottomleftcurve() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<signalremote>BF611B-101010$18.008000000U00s00s04s00s00k00s00k00s0Uk06s0Dw0Tx0zDNy3zw1zkU"
  ok:=FindText(&X, &Y, 1582-150000, 334-150000, 1582+150000, 334+150000, 0, 0, Text)
  return ok
}


;;; END OF (stuff copied from) MINER TYCOON code ;;;

Sleep(1000)
FindText().ToolTip()

; wanted to time meteors
; #include "*i MOTiming.ahk"

^!+End::Run("taskkill /IM `"FortniteClient-Win64-*`"")

close_chat_box()
{
    t1:=A_TickCount, Text:=X:=Y:=""
    Text:="|<REPORT>*99$27.tr6QwcZ+GtrdQIcVuGU"
    if (ok:=FindText(&X, &Y, 989-150000, 314-150000, 989+150000, 314+150000, 0, 0, Text))
    {
     Send("{{Escape}")
    }
}

findtext_close()
{
    t1:=A_TickCount, Text:=X:=Y:=""
    Text:="|<CLOSE>*33$34.A031k3wkzBbwn3AUMUA8nVy0kX1aAn3A2MzDjnty"
    xtra:=200
    if (ok:=FindText(&X, &Y, 1280-xtra, 313-xtra, 1280+xtra, 313+xtra, 0.05, 0.05, Text))
    {
        FindText().Click(X, Y, "L")
    }
    else
    {
        FindText().ToolTip("CLOSE not found")
    }
}

findtext_Activate()
{
    t1:=A_TickCount, Text:=X:=Y:=""
    Text:="|<ACTIVATE>*33$53.C7nvAMsyyKMVa8VMNVgk3AN6kn39U6MqAVbrn6AkgT3AMnsNVlX6TU"
    xtra:=200
    if (ok:=FindText(&X, &Y, 1099-xtra, 264-xtra, 1099+xtra, 264+xtra, 0.05, 0.05, Text))
    {
        Sleep(500)
        FindText().Click(X, Y, "L")
    }
    else
    {
        Sleep(500)
        FindText().Click(1099, 264, "L")
    }
}

findtext_use_smoker()
{
  ms:=666
  ; Sleep(ms)
  ; srk:=getSignalRemoteKey()

;   close_chat_box()
  Sleep(ms)
  switchToRemote()
  Sleep(ms)
  switchToRemote()
  Sleep(ms)
  Click("R")
  Sleep(ms)
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<BEE SMOKER>*66$71.zDrsTiCTAnxzWMA0kSxXNa37syT1spP6yDaSNUk0ReqBwMDgP1U0PNgPAkNzbvwDq3DaNylU"
  xtra:=200
  if (ok:=FindText(&X, &Y, 1279-xtra, 263-xtra, 1279+xtra, 263+xtra, 0.05, 0.05, Text))
  {
    Sleep(500)
    FindText().Click(X, Y, "L")
  } else {
    Sleep(500)
    FindText().Click(1279, 263, "L")
  }

  Sleep(500)
  findtext_Activate()


    ; findtext_close() ; not needed
    ; Sleep(ms)

    Sleep(ms)
    pickaxe()
    Sleep(ms)
    pickaxe()
    Sleep(ms/2)

}

find_0_smoke()
{
    t1:=A_TickCount, Text:=X:=Y:=""
    Text:="|<0 smoke>*253$32.zzzztzzzyA7zzzT1zzzzmTzzyBzzzzVAvzzs3/Tzzw6rzzzDRzzybvTzztCrzzyzzzzzjzzzznzzzzsbzzzw0s"
    xtra:=200
    ok:=FindText(&X, &Y, 994-xtra, 277-xtra, 994+xtra, 277+xtra, 0.0001, 0.0001, Text)
    return ok
}

global last_auto_buy_time := 0

smoker_loop(enable_buying:=true, total_minutes:=15) {
  global last_auto_buy_time
  MoveWindowToUpperRight()
  ms:=666
  loop {

    ActivateFortniteWindow()

    ; MoveWindowToUpperRight()

    if !WinActive(FORTNITEWINDOW, , FORTNITEEXCLUDEWINDOW) {
      FindText().ToolTip("smoker_loop:waiting for FN window",270,70)
      Sleep(5000)
      FindText().ToolTip()
      continue
    }

    ; first loop is user-initiated
    ; after that he may forget the macro is running
    if A_Index > 1 && A_TimeIdlePhysical < 60*1000 {
        FindText().ToolTip("smoker_loop:user busy (need 60s idle)",270,70)
        Sleep(3000)
        FindText().ToolTip()
        Sleep(60000)
        continue
    }

    if enable_buying
      findtext_autobuy_click()


    Sleep(ms)
    pickaxe()

    Sleep(ms)
    Send("{y down}")
    Sleep(ms/2)
    Send("{y up}")
    Sleep(ms/2)
    Send("{Escape}")
    Sleep(ms)
    Click("Left Up")
    Sleep(ms)
    nosmoke := find_0_smoke()
    smokers := ! nosmoke
    FindText().ToolTip("smoker_loop:smokers=" smokers,270,70)
    Sleep(ms)

    if smokers {
        FindText().ToolTip("smoker_loop:smoking",270,70)
        findtext_use_smoker()
    } else {
        FindText().ToolTip("smoker_loop:0 smoke",270,70)
    }

    clicking(3)
    if enable_buying
      findtext_autobuy_click()
    if total_minutes > 3
      clicking(total_minutes - 3)

    ; Send("{Esc}")
    Sleep(ms)

    ; ; if an hour has passed
    ; if last_auto_buy_time < A_TickCount - 60000*3600  {
    ;   findtext_autobuy_click()
    ;   last_auto_buy_time := A_TickCount
    ; }
  }
  FindText().ToolTip()

}

clicking(minutes) {
  ms:=666
  FindText().ToolTip("smoker_loop:clicking(" minutes ")",270,70)
  Sleep(200)
  Send("{y down}")
  Sleep(200)
  Send("{y up}")

  Sleep(ms)
  Send("{Escape}")


  Sleep(ms*2)
  Click("Left Down")
  Sleep(ms*2)
  Send("{y down}")
  Sleep(ms*2)
  Send("{y up}")
  Sleep(ms*4)
  Click("Left Up")
  Sleep(ms)
  Sleep(minutes*60*1000)
  ; re-think this; default behavior for ^d is to dump 6 smokers in 18 minutes
  ; hp := get_hivehp()
  ; if hp == 0 {
  ;   return
  ; }
  ; while hp > 0 {
  ;   Sleep(2000)
  ;   hp := get_hivehp()
  ; }
  Sleep(3000)
  FindText().ToolTip()
}

; WinGetPos(&X, &Y,&WW, &WH, FORTNITEWINDOW)
; FindText().ToolTip("WinGetPos=" X "," Y "," WW "," WH) ; 160,66,1280,720
; Sleep(2222)

smallwindow() {
  Try WinGetPos(&X, &Y,&WW, &WH, FORTNITEWINDOW)
  if (WW <= 640 || WH  <= 360) {
    ; FindText().ToolTip("smallwindow:WINWIDTH,WINHEIGHT,WINX,WINY=" WINWIDTH "," WINHEIGHT "," WINX "," WINY)
    return true
  } else {
    return false
  }
}

; available_efficiencies_unbuyable()
; {
;   if smallwindow()
;     return true

;   green := "0x63DE64"
;   red := "0xE06B72"
;   ; The following are GetRange offsets of bounding boxes
;   ; for which I would like code to count the pixels of red or green:
;   ; 1104, 246, 1323, 289
;   ; 1116,350,1321,386
;   ; 1098,441,1326,480
;   ; 1102, 542, 1326, 572
;   ; 1102, 629, 1317, 669

;   ; please write the code for me below, using PixelCount() to count the pixels of red or green in the bounding boxes above:
;   ; and track the count of boxes containing red pixels,
;   ; and the count of boxes containing green pixels:
;   ; finally return ttrue iff boxes containing red > 0
;   ; and boxes containing green == 0
;   ; (indicating that the player has unbuyable efficiencies)
;   ; otherwise return false


;   ; I will then use this function to determine whether to buy efficiencies or not
;   ScreenShot := 0 ; only do the bitblt the first time
;   for i, box in {
;     1: [1104, 246, 1323, 289],
;     2: [1116, 350, 1321, 386],
;     3: [1098, 441, 1326, 480],
;     4: [1102, 542, 1326, 572],
;     5: [1102, 629, 1317, 669]
;   } {
;     red_pixels := FindText().PixelCount(1104, box[2], 1320, box[4], red, ScreenShot)
;     ScreenShot := 1
;     green_pixels := FindText().PixelCount(1104, box[2], 1320, box[4], green, ScreenShot)
;     if (red_pixels > 0 && green_pixels == 0) {
;       return true
;     }
;   }
; }


available_efficiencies_unbuyable()
{
  if smallwindow()
    return true

  green := "0x63DE64"
  red := "0xE06B72"

  ; Constants for X positions (averaged from provided boxes)
  x1 := 1104
  x2 := 1320

  ; Y positions calculated for equidistant spacing
  ; First button at y=246, last at y=629, with 5 buttons
  y_start := 246
  spacing := (629 - 246) / 4  ; Approx 95.75 pixels between buttons

  red_count := 0
  green_count := 0
  ScreenShot := 0

  Loop 5
  {
    y_top := y_start + (A_Index - 1) * spacing
    y_bottom := y_top + 43  ; Approximate height from original boxes (e.g., 289-246)

    red_pixels := FindText().PixelCount(x1, y_top, x2, y_bottom, red, ScreenShot)
    ScreenShot := 1
    green_pixels := FindText().PixelCount(x1, y_top, x2, y_bottom, green, ScreenShot)

    if (red_pixels > 0)
      red_count++
    if (green_pixels > 0)
      green_count++
  }

  return (red_count > 0 && green_count == 0)
}

BUY_ANY := false

findtext_autobuy_click()
{
  global BUY_ANY
  ms:=666
  Sleep(ms/2)
  Send("{y down}")
  Sleep(ms/2)
  Send("{y up}")

  Sleep(ms*2)
  Send("{Escape}")
  Sleep(ms*2)
  switchToRemote()
  Sleep(ms)
  switchToRemote()  ; often fails first attempt
  Sleep(ms)
  Click("L")
  Sleep(ms)

  if BUY_ANY || ! available_efficiencies_unbuyable() {
    t1:=A_TickCount, Text:=X:=Y:=""
    Text:="|<AUTO>*55$22.QqwtHNYpBaFyqNi9lX8"
    ; xtra:=200
    xtra:=(A_SCREENWIDTH != 1600 ? A_SCREENWIDTH: 200)
    if (ok:=FindText(&X, &Y, 1405-xtra, 46-xtra, 1405+xtra, 46+xtra, 0.08, 0.08, Text))
    {
      Sleep(700)
      FindText().Click(X, Y, "L")
    } else {
      Sleep(700)
      FindText().Click(1405, 46, "L")
    }
    Sleep(ms)
  }
  ; findtext_close()
  Sleep(ms)
  findtext_X()  ; hit X to close

  Sleep(ms)

  pickaxe()
  Sleep(ms)

}

; close
findtext_X()
{
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<smallX>*33$6.nHOSOHnU"
  xtra:=100
  if (ok:=FindText(&X, &Y, 1468-xtra, 45-xtra, 1468+xtra, 45+xtra, 0.08, 0.08, Text))
  {
    Sleep(500)
    FindText().Click(X, Y, "L")
    Sleep(100)
  } else {
    Sleep(500)
    FindText().Click(1468, 45, "L")
    Sleep(100)
  }
  return ok
}

global meteorhp_pct := 0

get_hivehp() { ; get_meteorhp() {
  global meteorhp_pct
  ; global show_meteorhp
  ; global last_auto_buy_time
  ; try {
  ;   show_meteorhp |= false ; do-nothing assignment
  ; } catch {
  ;   show_meteorhp := false
  ; }
  ; count pixels that are red in this range: 1189, 34, 1373, 43
  ; 0xC41C24 , 0xA1171E
  color := "A1171E"
  ; offset := A_ScreenWidth-1600
  ; 1522/34   1189+320=
  ; y := 36  ; back to 34; it was 42; was the window moved temporarily? What would have moved it?
  ;1177, 29, 1384, 30
  IF smallwindow(){
  ; 1177,30,1383,38
    offset:=0
    y:=31
    reds := FindText().PixelCount(1177+offset, y, 1384+offset, y, color,15)
    hppct := Round((reds / (1384-1177))*100)
    FindText().ToolTip("HP%=" hppct, 1177-640,44)
  } else {
    reds := FindText().PixelCount(566, 113, 1031, 114, color,15)
    hppct := Round((reds / (1031-566))*100)
    FindText().ToolTip("HP%=" hppct, 1031-160,137-66)
  }
  meteorhp_pct := hppct
  ; if show_meteorhp {
  ;   FindText().ToolTip("HP%=" hppct, 1373,5,4)
  ; }
  ; if auto_buy {
  ;   if hppct == 0 && last_auto_buy_time < A_TickCount - 10000  {
  ;     autobuy_fast()
  ;     last_auto_buy_time := A_TickCount
  ;   }
  ; }
  return hppct
}

; SetTimer(get_hivehp, 2000)

toggleWindowPosition() {
  if smallwindow() {
    MoveWindowToBigCenter()
  } else {
    MoveWindowToUpperRight()
  }
}

findtext_joinfight() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<>*22$56.000T000007zUzw3sz1xzsTzkyDsTTyDzwDXy7kDXwTXszlw3sy3syDwT0yTUyDXrbkDbkDXsxtw3tw3syDDT0yT0yDXnrkDbkDXswTw3sy3syD7z0yDUyDXkzsTXwzXswDzzkTzkyD1zzw3zsDXkTzw0Tw3sw3y"
  X:="wait"
  Y:=5.0
  xtra:=100
  if (ok:=FindText(&X, &Y, 1226-xtra, 565-xtra, 1226+xtra, 565+xtra, 0, 0, Text))
  {
    Sleep(55)
    FindText().Click(X, Y, "L")
  } else {
    Sleep(55)
    FindText().Click(1226, 565, "L")
  }
}

findtext_start()
{
  t1:=A_TickCount, Text:=X:=Y:=""
  X:="wait"
  Y:=5
  Text:="|<>*22$80.1s000000000003zlzzUTs3zy7zxzyTzs7y0zzlzzzDbzy1zkDzyTzzVw3s0yw3sDUDXs00y0DD0y3s3sz00DU3nsDUy0y7y03s1wy3sDUDUzw0y0T7Uy7k3s3zUDU7lwDzk0y03w3s3sT3zy0DU0T0y0zzkzzk3sw7kDUDzwDUy0yDVw3s3zzXsDUDXzz0y1w3sy3s3sTzUDUT0yDUy0y1zU3s7kDnsDUDW"
  xtra:=100
  if (ok:=FindText(&X, &Y, 1226-xtra, 565-xtra, 1226+xtra, 565+xtra, 0, 0, Text))
  {
    Sleep(55)
    FindText().Click(X, Y, "L")
  } else {
    Sleep(55)
    FindText().Click(1226, 565, "L")
  }

}

findtext_timer00()
{
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<00:>*254$31.s7y1zk1w0TssSC7sSC7XUT77lkDXXss7klwCXssyDlwQT7sSC7XyC7XVl07k1ss7y1wE"
  xtra:=80
  X:="wait0"
  Y:=20.0
  ok:=FindText(&X, &Y, 1091-xtra, 492-xtra, 1091+xtra, 492+xtra, 0.06, 0.06, Text)
  return ok
}

findtext_1of4()
{
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<1/4>*254$30.zznzzzznzzkzXy10zbwF0zbwl8z7slsz7tlszDllsyDXlsyDblsyTU0swTU0swTzlswzzlswzzlzszzzzszzzU"
  xtra:=80
  ok:=FindText(&X, &Y, 1307-xtra, 263-xtra, 1307+xtra, 263+xtra, 0.05, 0.05, Text)
  return ok
}

findtext_HPleft()
{
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<>C41C24-102020$24.zzzzzzzzzzzzzzzz0003zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU"
  xtra:=80
  ; X:="wait0"
  ; Y:=seconds
  ok:=FindText(&X, &Y, 579-xtra, 124-xtra, 579+xtra, 124+xtra, 0.09, 0.09, Text)
  return ok
}

getHPbar()
{
  ; 568, 110, 1031, 137
  color := "C41C24"
  reds := FindText().PixelCount(568,116,1031,116,color,0)
  ; FindText().ToolTip("reds=" reds, 1031-160,137-66)
  return reds
}

bear() {
  MoveWindowToBigCenter()
  KeyWait("Control", "T3")
  KeyWait("b", "T3")
  Send("{space}")
  Sleep(111)
  Send("2") ; gun, I hope
  Sleep(111)
  Send("2") ; gun, I hope
  Sleep(111)
  Send("2") ; gun, I hope
  Loop {

    if !WinActive(FORTNITEWINDOW, , FORTNITEEXCLUDEWINDOW) {
      break
    }

    ; Send("{space}")
    Sleep(111)
    Send("2") ; gun, I hope
    Sleep(111)
    if A_TimeIdlePhysical < 1111 && A_Index > 1 {
      FindText().ToolTip("bear:stopped due to user activity",270,70)
      break
    }
    Send("e")
    Sleep(111)
    
    Sleep(2222)
    if A_Index = 1 {
      findtext_hardmode_click()
      Sleep(666)
      findtext_exmode_click()
      Sleep(111)
    }


    ; search JOIN
    findtext_joinfight()
    Sleep(333)
    Sleep(2222)
    ; cant chat inside a fight
    ; Send("{y down}")
    ; Sleep(333)
    ; Send("{y up}")
    ; Sleep(333)
    ; Send("you have three seconds to join the fight{enter}")
    ; Sleep(2222)
    ; Send("{y down}")
    ; Sleep(333)
    ; Send("{y up}")
    ; Sleep(333)
    ; Send("y{Escape}")
    carry_mode := ! findtext_1of4()
    findtext_start()
    findtext_timer00()
    ; findtext_start()
    ; Sleep(55)
    ; Send("2") ; gun, I hope
    ; Sleep(55)
    shooting_length := 15
    if carry_mode {
      ; Send("2") ; gun, I hope
      Send("{d down}")
      Sleep(300)
      Send("{d up}")
      shooting_length := 25
    }
    Sleep(22)
    ; Send("2") ; gun, I hope
    ; Sleep(55)
    Loop shooting_length {
      Click("Left Up")  ; firing
      Sleep(33)
      Click("Left Down")  ; firing
      Sleep(350)
      if A_Index > 12 && getHPbar() < 2 {
        ; FindText().ToolTip("HP gone,walking forward",,{timeout:3})
        Click("Left Up")  ; firing
        break
      }
    }
    ; Click("Left Down")  ; firing
    Send("{w down}")
    Sleep(1111)
    Click("Left Up")
    Sleep(3666) ; was 3333
    
    Send("{w up}{a down}{e down}")
    Sleep(3888) ; was 3555
    Send("{a up}")
    Sleep(111)
    Send("{e up}")
    ; Loop(5)
    ; {
    ;   Send("e")
    ;   Send("{w down}")
    ;   Sleep(444)
    ;   Send("{w up}")
    ; }

    ; Sleep(4000)  ; a little long because we dont know how long it will take to exit the battle
    FindText().ToolTip("Stop with shift...(4 sec)",270,70)
    kwshift := KeyWait("Shift", "DT4")
    if kwshift {
      FindText().ToolTip("bear:stopped with shift",270,70)
      Sleep(3000)
      FindText().ToolTip()
      return
    }
    FindText().ToolTip()
  ; walk back to the platform
    Send("{d down}{e down}")
    Sleep(900)
    Send("{d up}{e up}")

  }

}

findtext_hardmode_click()
{

  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<HARD M>*22$61.sQ3sDsDs0DQC3w7z7z07y71q3XnXk3z3UvVktks1zVkNksQsS0vzsQsQQQD0RzwCCDwC7UCQC777z73U7C77zXXnVk3b3XVtktzs1nVlkQsQzs0t"
  if (ok:=FindText(&X, &Y, 1226-150000, 637-150000, 1226+150000, 637+150000, 0, 0, Text))
  {
    Sleep(222)
      FindText().Click(X, Y, "L")
  }  
}

findtext_exmode_click() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<EX MODE>*22$79.znls1sD1w3y1zzsss0wDXzVzkzy0SQ0S7lvktsQ707Q0DXtswQCC3U3i06nQsCC771z0y039iQ773XyzUzU1abC3XVlzQ0Rk0nnb1lkssC0Sw0MtnlsswQ7yCC0AMszsTwDzzD7U60QDsDw7y00000001k0000U"
  if (ok:=FindText(&X, &Y, 1226-150000, 638-150000, 1226+150000, 638+150000, 0, 0, Text))
  {
    Sleep(222)
     FindText().Click(X, Y, "L")
  }  
}

#HotIf WinActive(FORTNITEWINDOW)

^s::smoker_loop(true,15)
^d::smoker_loop(false,3) ; dump "drills" without autobuy

RShift & b::bear()
^+m::toggleWindowPosition() ; MoveWindowToUpperRight() ; for when I accidentally fullscreen
^+a::findtext_autobuy_click()

#HotIf


; Area4 Huge Hive gather rate comparison:
; 3x critical damage (7%) =  41 to 64 = 23qtdc (smoker)
; 3x gather rate (7%) = 66.7 to  89 or less = 22.3qtdc (smoker)
; 2x crit chance + FS = 91 to 113 = 22 qtdc (smoker)
