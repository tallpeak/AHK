; https://github.com/tallpeak/AHK/tree/main/fortnite
#Requires AutoHotkey v2.0
#WinActivateForce 1
#SingleInstance
InstallKeybdHook(true)
InstallMouseHook(true) ; so that A_TIMEIDLEPHYSICAL includes mouse
SetDefaultMouseSpeed 3 ; default 2, trying to slow down a bit just in case mouse speed affects glitchy behavior at low wattage

; User needs to configure key bindings 
; for pickaxe(Harvesting tool)=` 
; and fire=enter(return)
pickaxe() {
	WinActivate(FORTNITEWINDOW,,FORTNITEEXCLUDEWINDOW)
	Send(Chr(96)) ; pickaxe
}

; #Include ControlColor.ahk

global EXTRA
EXTRA:=50
if A_ScreenWidth != 1600 {
	EXTRA:= A_ScreenWidth
}

global EnableGUI
EnableGUI := true

; WinActivate failed with just EXE
; may need both EXE and CLASS due to ambiguity; see
; https://www.autohotkey.com/boards/viewtopic.php?t=103024
FORTNITEPROCESS := "FortniteClient-Win64-Shipping.exe"
FORTNITEWINDOW := "ahk_class UnrealWindow" ; ahk_exe " . FORTNITEPROCESS
; FORTNITEWINDOW := "ahk_exe FortniteClient-Win64-Shipping.exe"
FORTNITEEXCLUDEWINDOW := "Epic Games Launcher"

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

; #Include "LumberClickGui2.ahk" ; pasted below, instead
#Requires Autohotkey v2
;AutoGUI creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;EasyAutoGUI-AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2

GuiX := WINX
GuiY := WINY + WINHEIGHT

global myGui

createGui() {
	global myGui
	myGui := Constructor()
	myGui.Opt("-Caption +Owner")
	myGui.Show("w700 h30 x" GuiX " y" GuiY " NoActivate")
	;WinMove(GuiX,GuiY,610,287,myGui.Title)	
}

if EnableGUI {
	createGui()
}

destroyGui(evt) { 
	global EnableGUI
	EnableGUI := false 
	myGui.Destroy()
}

toggleGui() {
	global EnableGUI
	EnableGUI := ! EnableGUI
	if ! EnableGUI {
		destroyGui(0)
	} else {
		createGui()
	}
}

HideEvent(*) {
	WindowHideToggle()
	if hidden {
		BtnHide.Text := "Show"
		; WindowShowAndFocus()
	} else {
		BtnHide.Text := "Hide"
	}
}

global LogCtl
global LoopsCtl
global MinsCtl
global LoopNum
global ChargedCtl
global unfocusChk
global BtnHide
global BtnFrenzy
global earlyAbort := false
global logVisible := false

unfocusChk.Value := DO_UNFOCUS
Constructor()
{	
	global LogCtl
	global LoopsCtl
	global MinsCtl
	global LoopNum
	global SecondsRemain
	global ChargedCtl
	global unfocusChk
	global BtnHide
	global BtnFrenzy
	global earlyAbort
	global logVisible
	
	myGui := Gui()
	; myGui.Opt("+AlwaysOnTop")
	BtnStop  := myGui.Add("Button", "x0 y02 w50 h23", "STOP")
	BtnClick := myGui.Add("Button", "x45 y02 w45 h23", "Click")
	; BthUnhide := myGui.Add("Button", "x144 y02 w57 h23", "Unhide")
	BtnFrenzy := myGui.Add("Button", "x90 y02 w50 h23", "Frenzy")
	LoopsLbl := myGui.Add("Text", "x150 y02 w18 h21", "#")
	LoopsCtl := myGui.Add("Edit", "x160 y02 w26 h21 +Number", "16")
	; ErrorLevel := SendMessage(0x1501, 1, StrPtr("iterations"), , "ahk_id " LoopsCtl.Hwnd) ; EM_SETCUEBANNER
	LoopsLbl := myGui.Add("Text", "x195 y02 w30 h21", "mins")
	MinsCtl := myGui.Add("Edit", "x220 y02 w26 h21", "15")

	LoopNum := myGui.Add("Text", "x400 y02 w30 h21", "0")
	SecondsRemain := myGui.Add("Text", "x430 y02 w30 h21", "0")
	ChargedCtl := myGui.Add("Text", "x460 y02 w50 h21", "Charged")
	UnfocusChk := myGui.Add("CheckBox", "x530 y02 w61 h23", "Unfocus")	
	BtnHide := myGui.Add("Button", "x575 y02 w57 h23", "Hide")
	BtnLog := myGui.Add("Button", "x620 y02 w26 h23", "Log")
	
	; ErrorLevel := SendMessage(0x1501, 1, StrPtr("minutes"), , "ahk_id " MinsCtl.Hwnd) ; EM_SETCUEBANNER
	global LogCtl := myGui.Add("ListView", "x32 y64 w572 h120 +LV0x4000", ["time", "event", "description"])
	LogCtl.ModifyCol(1, 100)
	LogCtl.ModifyCol(2, 50)
	LogCtl.ModifyCol(3, 2000)
	; LogCtl.Add(,"Sample1")
	; LogCtl.OnEvent("DoubleClick", LV_DoubleClick)
	BtnClick.OnEvent("Click", (*) => clicker_unfocused(false))
	BtnHide.OnEvent("Click", HideEvent)
	BtnStop.OnEvent("Click", stopClicking)
	; UnfocusChk.OnEvent("Click", OnEventHandler)
	BtnFrenzy.OnEvent("Click", (*) => FrenzyLoop(true))
	; BthUnhide.OnEvent("Click", (*) => WindowShowAndFocus())
	BtnLog.OnEvent("Click", ToggleLog)

	; LoopsCtl.OnEvent("Change", OnEventHandler)
	; MinsCtl.OnEvent("Change", OnEventHandler)
	; myGui.OnEvent('Close', (*) => ExitApp())
	myGui.OnEvent('Close', destroyGui )
	myGui.Title := "LumberjackClicker"
	
	; LV_DoubleClick(LV, RowNum)
	; {
	; 	if not RowNum
	; 		return
	; 	FindText().ToolTip(LV.GetText(RowNum), 77, 277)
	; 	SetTimer () => FindText().ToolTip(), -3000
	; }
	; Clicker(CtrlHwnd, GuiEvent, EventInfo, ErrLevel := "") {
	; }
	
	OnEventHandler(*)
	{
		FindText().ToolTip("Click! This is a sample action.`n"
		. "Active GUI element values include:`n"  
		. "BtnClick => " BtnClick.Text "`n" 
		. "BtnHide => " BtnHide.Text "`n" 
		. "UnfocusChk => " UnfocusChk.Value "`n" 
		. "BtnFrenzy => " BtnFrenzy.Text "`n" 
		. "LoopsCtl => " LoopsCtl.Value "`n" 
		. "MinsCtl => " MinsCtl.Value "`n", 77, 277)
		SetTimer () => FindText().ToolTip(), -3000 ; clear-tooltip timer
	}
	stopClicking(*) {
		earlyAbort := true
	}
	ToggleLog(*) {
		logVisible := !logVisible
		if logVisible {
			; myGui.Opt("+Resize +MinSize700x220")
			myGui.Show("h220")
		} else {
			; myGui.Opt("+Resize +MinSize700x30")
			myGui.Show("h30")
		}		
	}
	return myGui
}

LogMessage(cat,msg) {
	if EnableGUI {
		tm := A_Now
		RowNumber := LogCtl.Add(,tm,cat,msg)
		if RowNumber>99
			LogCtl.Delete(1)	
	} else {
		createGui()
	}
}

#Include "DoFrenzy.ahk"

; Optional screen-scanning for Charged!
; Note that it works only when the window is visible;
; not obscured, and not hidden
; You would need to recapture "Charged" using FindTextv2,
; and convert to grayscale with a threshold of 254,
; to use the Charged_Delay functionality on your screen
; If 96 DPI but not 1600x900, you may be able to get it to work
; by expanding the search area
; 5/11/2024: I was exceeding 400 Od wood per frenzy for a while last night
; but more like 200 to 300 today.
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

findtext_60() {
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:=Y:=""
	xtra:=50
	Text:="|<x60/100>*254$43.zzTTtxyhxxrSrPjyqvjPhozRRzhqvzjjzqzTrttvvbnU"
	ok:=FindText(&X, &Y, 1352-xtra, 242-xtra, 1352+xtra, 242+xtra, 0.01, 0.01, Text)
	return ok
}

findtext_Charged() {
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:=Y:=""
	Text:="|<Charged>*254$39.rzzzzzzxzzzzyTfnzjzHxjjqqqThxiyynhhhzrqrxxizDTzzzyzzU"
	ok:=FindText(&X, &Y, 1330-22, 238-22, 1330+50, 238+10, 0.01, 0.01, Text)
	return ok
}

findtext_x1Charged() {
	global EXTRA
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:=Y:=""
	Text:="|<x2Charge>*240$52.zPynTzzjxhjvxSRFtzyzjqynPPbryzPvRhxwzvBhhzrqkzlymrTbU"
	xtrax:=50
	xtray:=20
	if EXTRA > 100 {
		xtrax := EXTRA
		xtray := EXTRA
	}
	ok:=FindText(&X, &Y, 1344-xtrax, 242-xtray, 1344+xtrax, 242+xtray, 0.05, 0.05, Text) ; asdfasdf
	return ok
}

; uses color similarity, looking for yellows
; reset a 30-minute countdown timer when this is found
FindText_EventBossIcon() {
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:=Y:=""
	Text:="|<eventbossicon>E5B230-424242$10.U7BsF0004SLfwzzU"
	Text.="|<EventBossIcon>D89C44@0.90/D6AA4D@0.90/C18825@0.90$10.07AQn0000SH/wzz02"
	; if (ok:=FindText(&X, &Y, 1493-150000, 22-150000, 1493+150000, 22+150000, 0, 0, Text))
	ok:=FindText(&X, &Y, 800, 0, 1600, 100, 0.01, 0.01, Text)
	return ok
}

findtext_BATTLEPASS_CLAIM_and_click() {
	t1:=A_TickCount, Text:=X:=Y:=""
	Text:="|<BATTLEPASS_CLAIM>*15$128.knrYQCA8E0000000028MYMA8F42H5+000000001+69DZ24FkZF2000000000EWWPZ8V4ECG480000000048YZPS8F427Z+000000001+D9LYW4RkV8V0000000008uGFU"
	xtrax:=50
	xtray:=20
	if EXTRA > 100 {
		xtrax := EXTRA
		xtray := EXTRA
	}
	if (ok:=FindText(&X, &Y, 1273-xtrax, 337-xtray, 1273+xtrax, 337+xtray, 0, 0, Text))
	{
		FindText().ToolTip("clicking BATTLEPASS_CLAIM")
		Sleep(600)
		FindText().Click(X+55, Y, "L")
		Sleep(5000)
		FindText().ToolTip()
	}
}

#include "*i GodStuff.ahk"

global Volume := 50
VolumeIncrement := 5

SendMode("Event")
SetKeyDelay 50,100

FindText().ToolTip("Loading macros...and sending {Enter up}",70,300)
Send("{Enter up}")

If(! WinExist(FORTNITEWINDOW) ) {
	Run("com.epicgames.launcher://apps/fn%3A4fe75bbc5a674f4f9b356b5c90567da5%3AFortnite?action=launch&silent=true")
	Sleep(1000)
 	WinWait(FORTNITEWINDOW,,60)
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

Try {
	ActivateFortniteWindow()
	Sleep(100)
	; WinWaitActive(FORTNITEWINDOW)
	WinShow(FORTNITEWINDOW)
	Sleep(100)
	ActivateFortniteWindow()
	Sleep(100)
	; WinWaitActive(FORTNITEWINDOW)
}

SetKeyDelay(11,5)

; main key bindings (for FN=active/focused window):
#HotIf WinActive(FORTNITEWINDOW)
^End::Reload
^r::Reload
^+r::Reload
^+e::InteractionLoop()
^!+e::Edit()
; ^+f::fastclicker() ; sword tycoon
^+o::oldclicker()  ; requires window focus
^c::clicker_unfocused(false)  ; without hide
SC027 & c::clicker_unfocused(false)  ; semicolon c
; ~LButton & RButton::clicker_unfocused(false)  ; tilde~ prevents blocking click
^+c::clicker_unfocused(ENABLE_AUTO_HIDE)  ; move and hide
^+m::MoveWindowToUpperRight() ; for when I accidentally fullscreen
^+b::emoting()  ; usually used for dance floors
; control shift h to toggle window-hidden state when FN is in focus:
^+h::WindowHideToggle()
^+u::unfocus()
^+g::toggleGui()

^NumpadAdd::FrenzyLoop(true) 
^+NumpadAdd::FrenzyLoop(false) 

; bad keybinding; I somehow kept hitting it accidentally during boss fights
; ^f::FrenzyLoop(true) 
; ^+f::FrenzyLoop(false) 
SC027 & f::FrenzyLoop(true) 
SC027 & g::FrenzyLoop(false) 
SC027 & h::{
	global StopAtLowHealth
	StopAtLowHealth := true
	FrenzyLoop(true) 
}
SC027 & s::toggleStopAtLowHealth()

*^+NumLock::ClearAllKeyState()

LAlt & LWin::{
	if GetKeyState("LCtrl") {
		unfocus()
	}
}
; hold shift down for slowly changing volume:
LCTRL & UP::VolumeUpLoop()
LCTRL & Down::VolumeDownLoop()

; +e::Send "{e 100}"  ; was {e 100}
;^!+e::Send "{e 1000}"

;run: (sprint)
r::{
	Send "{w down}{LShift Down}"
	KeyWait("r")
	Send "{w up}{LShift Up}"
}
#HotIf


maybe_unfocus() {
	if unfocusChk.Value {
		unfocus()
	}
}

StopAtLowHealth := false

toggleStopAtLowHealth() {
	global StopAtLowHealth
	StopAtLowHealth := !StopAtLowHealth 
	if StopAtLowHealth {
		FindText().ToolTip("should stop when health of 409vg tree is down below 5vg")
	} else {
		FindText().ToolTip("StopAtLowHealth disabled")
	}
}

FrenzyLoop(frenzyfirst:=false) {
	global StopAtLowHealth
	; ControlColor(BtnFrenzy, myGui, "Blue")
	BtnFrenzy.Opt("+Redraw +BackgroundGreen") 
	loop LoopsCtl.Value {
		LoopNum.Value := A_Index
		if frenzyfirst {
			MoveWindowToUpperRight()
			FindText().ToolTip("Frenzy for loop #" A_Index)
			Sleep(2111)
			attempts := 0
			DetectHiddenWindows(true)
			while ! WinActive(FORTNITEWINDOW,,FORTNITEEXCLUDEWINDOW) && attempts < 10 {
				ActivateFortniteWindow()
				WinWaitActive(FORTNITEWINDOW, , 0.2, FORTNITEEXCLUDEWINDOW)
				attempts += 1
				if attempts > 1 {
					FindText().ToolTip("WinActivate " FORTNITEWINDOW " failed, attempt#" attempts,1000,10)
				}
				Send("{alt down}{tab}{alt up}")
				Sleep(200)
				; FindText().ToolTip()
				; WinActivate("Fortnite")
				; WinActivate("AHK_ID 17892")
				WinWaitActive(FORTNITEWINDOW, , 0.1)
			} 			
			Sleep(444)
			pickaxe()
			Sleep(444)
			Click()
			Sleep(444)
			Send(Chr(firekey))
			Sleep(444)
			DoFrenzy()
		}
		xtratime := 0
		clicktime := MinsCtl.Value*60 + xtratime ; time to grow a golden tree
		; temp, for when wanting to use up my golden trees (testing):
	    ; clicktime := 4 * 60 ; debugging
		; clicktime := 20 ; debug with 0 golden trees saved

		FindText().ToolTip("clicker for loop #" A_Index,,,,{timeout:3})
		Sleep(333)

		term := clicker_unfocused(false, clicktime)
		if term { 
			return
		}
		; FindText().ToolTip("15 minutes of clicking has ended; pausing 30 seconds (or until click) before next frenzy")
		; KeyWait("LButton","DT30")
		; FindText().ToolTip()
			vg := getTreeHealthVg()
			if A_TimeIdlePhysical < 5000 
				|| vg > 1.0 && vg < 5.0 && StopAtLowHealth {
			FindText().ToolTip("Continue frenzyloop? Press y within 20 seconds to continue ")
			kw := KeyWait("y","DT20") ; nonzero if yes, 0 if timeout
			if !kw {
				FindText().ToolTip("Stopping frenzyloop (A_TimeIdlePhysical = " A_TimeIdlePhysical " < 3000; user abort?)",,,,{timeout:5})
				FileAppend("Stopped:" . A_Now "; A_TimeIdlePhysical=" A_TimeIdlePhysical ",vg=" vg "`n", "Lumberjack_log.txt")
				break
			}
		} else {
			FindText().ToolTip("pausing 10 seconds before next frenzy (or click)")
			KeyWait("LButton","DT10")
			FindText().ToolTip()
		}
		frenzyfirst := true
	}
	; ControlColor(BtnFrenzy, myGui, "White")
	BtnFrenzy.Opt("+BackgroundWhite +Redraw")

}

; SetTimer(showPercent,2000)

; for 409vg immortal tree (level 11)
getTreeHealthVg() 
{
	color := "ED4D4D"
	reds := FindText().PixelCount(1191, 26, 1367, 26, color,33)
	vg := 409 * (reds / (1367-1191))
	; FindText().ToolTip("vg=" vg, 1367,5)
	return vg
}


; need a do-not-disturb 
; if stupid windows badges are coming up and not going away
; ^+q::FocusMode()

; FocusMode() {
; 	RunWait("ms-settings:quiethours")
; 	Sleep(1111)
; 	t1:=A_TickCount, Text:=X:=Y:=""
; 	Loop 9 {
; 		Text:="|<->**50$64.050000000+00I0000000c01k0000002Uzrzjk000Dvw1q3V0000U08nNaw0003yzrBbPk0000+1QqxlU0000c5nPrq00002ULBjTM0000+2"
		
; 		if (ok:=FindText(&X, &Y, 1111-150000, 514-150000, 1111+150000, 514+150000, 0, 0, Text))
; 		{
; 		FindText().Click(X, Y, "L")
; 		}
; 	}

; 	Text:="|<Startfocus>**50$86.s0000000000000DU0000000000002S003k0000s0000Vs01Uk01U800008700EA00M2000020Q067rXz3tsSVDU1U0slAlU8nA8G80M07A18M2MK24m0Q00P7m60a4UV7UQ002n4VU9VMAEMS00Fgn8M2An3A6S007lbm30VsSTDU"
; 	if (ok:=FindText(&X, &Y, 1051-150000, 450-150000, 1051+150000, 450+150000, 0, 0, Text))
; 	{
; 	 FindText().Click(X, Y, "L")
; 	}

; }

; Global hotkeys:
^!+r::Reload
#HotIf !WinActive(FORTNITEWINDOW)
^!+h::WindowHideToggle() ; control alt shift h to toggle window-hidden state:
#HotIf

^!+s::WindowShowAndFocus()

MoveWindowToUpperRight() {
	WinMove(WINX, WINY, WINWIDTH,WINHEIGHT,FORTNITEWINDOW)
	;no... unfocus()
}

; I prefer to remove focus from the game
; whenever I start the clicker,
; so that I can get back to work in another window
;
; At first I thought I wanted my focus returned to Chrome
; or VS Code, but it's not always the same window
; So I changed it to explorer/Progman,
; then I can move the mouse wherever I want:
unfocus() {
	; Send("{AltTab}") ; didnt work
	; TryWinActivate("ahk_exe chrome.exe")
	; TryWinActivate("ahk_exe msedge.exe")
	; TryWinActivate("ahk_exe firefox.exe")
	; TryWinActivate("Visual Studio") ; VS Code
	TryWinActivate("ahk_exe explorer.exe") ; Only remove focus from FortNite
	; or: TryWinActivate("ahk_class Progman") ;
}

; see https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
; might want to try other bindings but so far only enter seems to work

; $*Alt::return ; doesnt work either
; $*LAlt::return

; only seems to work out-of-focus when firekey = enter
; (You need to go into FN settings and bind fire to enter)
clicker_unfocused(hideWindow, total_seconds := 3600*4) {
	global Delay60 
	global Charged_Count
	; global Charged_MaxRunDelay
	global keydown_time
	global ctrl_time
	global firekey
	global earlyAbort
	earlyAbort := false
	term := false
	DetectHiddenWindows true
	startTick := A_TickCount
	; tried to block alt+enter, didnt work
	; Hotkey("Alt & Enter",DoNothing,"On") ; didnt work
	WM_KEYDOWN 	:= 0x0100
	WM_KEYUP 	:= 0x0101
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
	ttHWND := FindText().ToolTip(msg,10,10,2,{timeout:10})
	toolTip_showing := true
	kw := KeyWait("NumPadDel","U")
	; immediately unfocusing before first Enter/click event
	; sometimes prevented the clicking from starting
	; I'm not sure if this fixes it?
	Sleep(333)
	pickaxe()
	Sleep(333)
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
		if Delay60 {
			ok:=findtext_60()
			if ok {
				xy:=ok[1]
				FindText().ToolTip("60/100(" . xy.1 . "," . xy.2 . ") +" . Delay60 . "ms",xy.1+xy.3*2,xy.2+xy.4)
				Sleep(Delay60)
				FindText().ToolTip()  
			}			
		}
		ok:=findtext_x1Charged()
		if ok {
			Charged_Count += 1
			if Charged_Count = ChargedCountAtDelay {
				xy:=ok[1]
				msg1:=xy.id . "(" . xy.1 . "," . xy.2 . ") +" . X1Charged_Delay . "ms,#" . Charged_Count
				; LogMessage("found",msg1)
				FindText().ToolTip(msg1,xy.1,xy.2+xy.4*2)
				if EnableGUI {
					try {
						ChargedCtl.Text := xy.x "," xy.y
						ChargedCtl.Opt("+BackgroundRed +Redraw")
					}
				}
				Sleep(X1Charged_Delay) ; slow down during Charged!
				if EnableGUI {
					try {
						ChargedCtl.Text := "Charged"
						ChargedCtl.Opt("+BackgroundWhite +Redraw")
					}
				}
				FindText().ToolTip()
			}
			
		} else {
			if findtext_Charged() {
				Sleep(Charged_Delay)
			}
			Charged_Count := 0
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

oldclicker() {
	FindText().ToolTip("Press RCtrl or RButton to stop clicking",66,66	)
	ActivateFortniteWindow()
	;Send("{LClick Down}")
	Loop {
		; terminate only if window switch was likely initiated by the user:
		if !WinActive(FORTNITEWINDOW) && A_TimeIdle < 5000 {
			; ActivateFortniteWindow()
			FindText().ToolTip(FORTNITEWINDOW " not active due to user activity; stopping clicking")
			Sleep(333)
			FindText().ToolTip()
			break
		}
		if WinActive(FORTNITEWINDOW) {
			Click()
		}
		kw := KeyWait("RCtrl","DT0.2")
		rb := GetKeyState("RButton")
		if kw or rb {
			FindText().ToolTip("RCtrl/RButton found; stopping clicking")
			Sleep(1500)
			FindText().ToolTip()
			break
		}
	}
}


; fastclick for sword tycoon
; (which is rather pointless with this cheat)
; let go of f to stop clicking
fastclicker() {
	loop 999 {
		if WinActive(FORTNITEWINDOW) {
			Click()
		}
		kw := KeyWait("RCtrl","DT0.005")
		rb := GetKeyState("RButton")
		f := GetKeyState("F","P")
		if kw or rb or f==0 {
			FindText().ToolTip("RCtrl/RButton/!f found; stopping clicking")
			Sleep(1500)
			FindText().ToolTip()
			break
		}
	}
}

; many tycoons require you to interact repeatedly
; eg. sword tycoon, collecting eggs
InteractionLoop() {
	Loop {
		if A_TimeIdlePhysical > 200000 {
			ActivateFortniteWindow()
		}
		if WinActive(FORTNITEWINDOW) {
			if	A_TimeIdle > 555 {
				; useful for (eg) Robot Tycoon 2
				FindText().ToolTip("Sending {e 111}")
				Send "{e 111}"
				Sleep(222)
				FindText().ToolTip()
			}
			Sleep(522)
		} else {
			return
		}
	}
}

DoNothing(HotkeyName)
{
}

emoting() {
	Loop {
		Send("{b}")
		kw := KeyWait("RCtrl","DT0.1")
		if kw {
			FindText().ToolTip("RCtrl found, stopping b (emote)")
			Sleep(3000)
			FindText().ToolTip()
			break
		}
	}
}

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


;#HotIf WinActive(FORTNITEWINDOW)
;!Enter::Return

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
#Requires AutoHotkey v2.0

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

TryWinActivate(w)
{
	try {
		WinActivate(w)
	} catch Error as err {
		return ; err.Message
	}
}

Sleep(1000)
FindText().ToolTip()  ; get rid of "Loading..."

; does not seem necessary
; and this did not fix WinActivate failures when using EXE only
; ; elevate by restarting the script with *RunAs
; reload_as_admin() {
; 	; the RegExMatch was supposed to prevent accidental endless loop,
; 	; but not needed for my use-case
; 	if not (A_IsAdmin ) ;;;; or RegExMatch(full_command_line, " /restart(?!\S)"))
; 	{
; 		try
; 		{
; 			if A_IsCompiled {
; 				Run("thisisoneargument")
; 				; Run('*RunAs "' . A_ScriptFullPath . '" /restart')
; 				Run('*RunAs "' . A_AhkPath . '" /restart "' . A_ScriptFullPath . '"')
; 			} else {
; 				Run('*RunAs "' . A_AhkPath . '" /restart "' . A_ScriptFullPath . '"')
; 			}
; 		}
; 		catch as e {
; 			WinSetTitle(e.Message)
; 		}
; 		ExitApp
; 	}
; }

; reload_as_admin()

#Include "DateParse2.ahk"
checkForUpdate() {
	whr := ComObject("WinHttp.WinHttpRequest.5.1")
	url := "https://qomph.com/lumberjack/lumberjack.zip"
	filename := "lumberjack.zip"
	whr.Open("HEAD", url, true)
	whr.Send()
	; Using 'true' above and the call below allows the script to remain responsive.
	whr.WaitForResponse()
	last_modified_str := whr.GetResponseHeader("Last-Modified")
    last_modified := DateParse(last_modified_str)
    this_modified := FileGetTime(A_ScriptFullPath, "M")
	; this_modified := DateAdd(this_modified,8,"Hours") ; conversion to UTC
	; respect local timezone settings:
    utcoffset := A_NowUTC - A_Now 
	this_modified := this_modified + utcoffset
	if this_modified < last_modified  {
		; MsgBox("this_modified=" this_modified ", last_modified=" last_modified)
        FindText().ToolTip("Notice: Update is available! see: `n" url 
						  "`nPress y to download (in 10 seconds)",80,WINHEIGHT-80)
        ; Sleep(5000)
		k := KeyWait("y","DT10")
		if k {
			Download(url,filename)
			RunWait(filename) ; open the archive; let the user extract
		}
		FindText().ToolTip()
    }
}

checkForUpdate()

ClearAllKeyState() {
	; WinSetTitle("Clearing key state", FORTNITEWINDOW)
	Loop 255 {
		vk := Format("vk{:X}", A_Index)
		p := GetKeyState(vk, "P")
		l := GetKeyState(vk)
		vkups :=""
		if p || l {
			vkup := "{" . vk . " up}"
			Send(vkup)
			vkups .= vkup " "
		}
	}
	if vkups {
		FindText().ToolTip("Cleared:" vkups)
		Sleep(2000)
	}
}

global EventBossTimer
EventBossTimer := A_TickCount
SetTimer(scanForGameLauncher, -5000) ; 5 seconds one-shot timer for manual reload trigger

scanForGameLauncher() {
	global EXTRA
	global SignalRemoteKey
	global EventBossTimer
	; FindText().ToolTip("Looking for title screen")
	X:=Y:=""
	Text:="|<LUMBERJACK_HEROES>*254$70.jitn7VXlszzQwv79YwnrfqNXnBQannCRizVTQrK7T3vqvypwrPPhxri1av0zxxXkrTvbzizzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzrQATzVzzzzzyRbaPAyrzzzzs6SNSnnzzzzziPsRvTtzzzzytjinRxbzzzzvi6vzkzzzy"
	xtra:=EXTRA
	if (ok:=FindText(&X, &Y, 1038-xtra, 256-xtra, 1038+xtra, 256+xtra, 0, 0, Text))
	{
		FindText().ToolTip("Found title screen")
		LogMessage("start","Found title screen")
		; FindText().Click(X, Y, "L")
		earlyAbort := true
		EventBossTimer := A_TickCount ; reset event boss timer
		Send("{LButton up}")
		Sleep(200)
		Send("{Enter up}")
		Sleep(200)
		findtext_PLAY_and_click()
		Sleep(5000)
		; FindText().ToolTip("Waiting two minutes for LJH to load...Scanning for signal remote")
		FindText().ToolTip("Wait for LJH to load`nScan for signal remote")
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
		; this seemed to get stuck?!
		; Loop 600 {
		; 	getSignalRemoteKey()
		; 	if SignalRemoteKey {
		; 		break
		; 	}				
		; 	Sleep(2000)
		; }
		getSignalRemoteKey()
		FindText().ToolTip("Found signal remote; about to TP Immortal Tree...")
		MoveWindowToUpperRight()
		ActivateFortniteWindow()
		Sleep(1000)
		FindText().ToolTip()
		TPimmortalTree() 
	}
	; Sleep(5000)
	; ToolTip()

	; attempt to show approx. minutes until next event boss
	ok:=FindText_EventBossIcon()
	elapsed := A_TickCount - EventBossTimer
	if ok && elapsed > 10000 {
		FindText().ToolTip("EB icon!",ok[1].1,ok[1].2+20,,{timeout:3})
		EventBossTimer := A_TickCount + 3 * 60000
	}
	mins := Round(30 - elapsed / 60000)
	if mins < 33 || true {
		CoordMode "ToolTip", (bak:=A_CoordModeMouse)?"Screen":"Screen"
		FindText().ToolTip(mins,A_ScreenWidth-50,40,3,{color:"White",bgcolor:"AA6622",size:(mins>9?10:14)})
		CoordMode "ToolTip", bak
	}

	findtext_BATTLEPASS_CLAIM_and_click()

	SetTimer(scanForGameLauncher, -60000) ; 1 minute (temp)
}

findtext_PLAY_and_click() {
	global EXTRA
	t1:=A_TickCount, Text:=X:=Y:=""
	Text:="|<PLAY>FFFF01@0.95$29.0EwA001k8003UM0070k00C0kU8M1V1k0327U366"
	Text.="|<PLAY>*15$28.sA32DskSAgn18GnA4VP8kH3D33wAkDAEn0wV38"
	xtra:=EXTRA
	if (ok:=FindText(&X, &Y, 1037-xtra, 313-xtra, 1037+xtra, 313+xtra, 0, 0, Text))
	{
		FindText().Click(X, Y, "L")
	}
}

ClearAllKeyState()

MoveWindowToUpperRight()

; scanForGameLauncher() 


; Sleep(2146473647)