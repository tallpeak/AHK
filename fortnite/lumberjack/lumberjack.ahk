; https://github.com/tallpeak/AHK/tree/main/fortnite
#Requires AutoHotkey v2.0
#WinActivateForce 1
#SingleInstance
InstallKeybdHook(true)
InstallMouseHook(true) ; so that A_TIMEIDLEPHYSICAL includes mouse
SetDefaultMouseSpeed 5 ; default 2, trying to slow down a bit just in case mouse speed affects glitchy behavior at low wattage

#Include "DoFrenzy.ahk"
; WinActivate failed with just EXE
; may need both EXE and CLASS due to ambiguity; see
; https://www.autohotkey.com/boards/viewtopic.php?t=103024
FORTNITEPROCESS := "FortniteClient-Win64-Shipping.exe"
FORTNITEWINDOW := "ahk_class UnrealWindow" ; ahk_exe " . FORTNITEPROCESS
; FORTNITEWINDOW := "ahk_exe FortniteClient-Win64-Shipping.exe"
FORTNITEEXCLUDEWINDOW := "Epic Games Launcher"

DO_UNFOCUS := true ;  false ; due to winactivate failures

; maybe lower this once used to the auto-hide behavior:
HIDE_SECONDS := 10
; Some users won't like these enabled
ENABLE_AUTO_HIDE := true
ENABLE_RESIZE := true
; For resize: I like FN small, in upper-right:
SCALINGFACTOR := 0.4
; WINWIDTH := A_ScreenWidth * SCALINGFACTOR
; WINHEIGHT := A_ScreenHeight * SCALINGFACTOR
WINWIDTH := 640
WINHEIGHT := 360
WINX := A_ScreenWidth - WINWIDTH
WINY := 10
CENTERX := WINX + WINWIDTH/2
CENTERY := WINY + WINHEIGHT/2
; ToolTip("WW,WH,WX,WY=" WINWIDTH "," WINHEIGHT "," WINX "," WINY) ; 640,360,960,10
; Sleep(2222)

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
Delay60 := 666   ; when 60/100 
Charged_Delay := 666 ; When "Charged!" is found
Charged_Count := 1
; ChargedCountAtDelay := 4
; Charged_MaxRunDelay := 4 ; only delay for first n appearances of Charged
; Charged_MaxRunDelay doesnt do much because
; "Charged!"" isn't always caught by screen-scanning
keydown_time := 200 ; ms
ctrl_time := "DT0.2" ; seconds
firekey := 13 ; Enter
; from https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116471
use_FindText := false
MyScreenDPI := 96  ; my HP 17's laptop screen is 1600x900 (96dpi)
; #Include "*i FindTextv2_FeiYue_9.5.ahk" ;  Version : 9.5  (2024-04-27)
#Include "*i findtextv2_v9.6.ahk"
try {
	; throws exception if FindText is undefined
	use_FindText := HasMethod(FindText, "Call")
}
if A_ScreenDPI != MyScreenDPI {
	ToolTip("Only " MyScreenDPI " DPI supported; your DPI is " A_ScreenDPI)
	use_FindText := false
}

findtext_60() {
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:=Y:=""
	xtra:=50
	Text:="|<x60/100>*254$43.zzTTtxyhxxrSrPjyqvjPhozRRzhqvzjjzqzTrttvvbnU"
	ok:=FindText(&X, &Y, 1352-xtra, 242-xtra, 1352+xtra, 242+xtra, 0, 0, Text)
	return ok
}

findtext_Charged() {
	if ! use_FindText {
		return 0
	}
	t1:=A_TickCount, Text:=X:=Y:=""
	Text:="|<Charged>*254$39.rzzzzzzxzzzzyTfnzjzHxjjqqqThxiyynhhhzrqrxxizDTzzzyzzU"
	ok:=FindText(&X, &Y, 1330-22, 238-22, 1330+50, 238+10, 0, 0, Text)
	return ok
}

; findtext_x1Charged() {
; 	if ! use_FindText {
; 		return 0
; 	}
; 	t1:=A_TickCount, Text:=X:=Y:=""
; 	Text:="|<x1Charged>*254$58.zzzTzzzzzzwzzvzzzzxavzTfnzjzKzjxyrrvPPOSzrvTPjjhzvzRhhjyyrvjzTrqvwxzzzzzzzxzzs"
; 	ok:=FindText(&X, &Y, 1344-150000, 242-150000, 1344+150000, 242+150000, 0, 0, Text)
; }

global Volume := 50
VolumeIncrement := 5

SendMode("Event")
SetKeyDelay 50,100

ToolTip("Loading macros...and sending {Enter up}")
Send("{Enter up}")

If(! WinExist(FORTNITEWINDOW) ) {
	RunWait("com.epicgames.launcher://apps/fn%3A4fe75bbc5a674f4f9b356b5c90567da5%3AFortnite?action=launch&silent=true")
	Sleep(1000)
}

ActivateFortniteWindow() {
	MouseMove(CENTERX,CENTERY)
	WinActivate(FORTNITEWINDOW, , FORTNITEEXCLUDEWINDOW)
}

Try {
	ActivateFortniteWindow()
	WinWaitActive(FORTNITEWINDOW)
	WinShow(FORTNITEWINDOW)
	ActivateFortniteWindow()
	WinWaitActive(FORTNITEWINDOW)
}

SetKeyDelay(11,5)

#HotIf WinActive(FORTNITEWINDOW)
; active/focused window key bindings
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
SC027 & s::doStopAtLowHealth()

maybe_unfocus() {
	if DO_UNFOCUS {
		unfocus()
	}
}

StopAtLowHealth := false
doStopAtLowHealth() {
	global StopAtLowHealth
	StopAtLowHealth := !StopAtLowHealth 
	if StopAtLowHealth {
		ToolTip("should stop when health of 409vg tree is down to 3vg")
	} else {
		ToolTip("healthstop disabled")
	}
}


FrenzyLoop(frenzyfirst:=false) {
	global StopAtLowHealth
	loop 16 {
		if frenzyfirst {
			MoveWindowToUpperRight()
			ToolTip("Frenzy for loop #" A_Index)
			Sleep(2111)
			attempts := 0
			DetectHiddenWindows(true)
			while ! WinActive(FORTNITEWINDOW,,FORTNITEEXCLUDEWINDOW) && attempts < 100 {
				ActivateFortniteWindow()
				WinWaitActive(FORTNITEWINDOW, , 0.2, FORTNITEEXCLUDEWINDOW)
				attempts += 1
				if attempts > 1 {
					ToolTip("WinActivate " FORTNITEWINDOW " failed, attempt#" attempts,1000,10)
				}
				Send("!Tab")
				Sleep(200)
				; ToolTip()
				; WinActivate("Fortnite")
				; WinActivate("AHK_ID 17892")
				WinWaitActive(FORTNITEWINDOW, , 0.1)
			} 			
			Sleep(211)
			Send(Chr(96))
			Sleep(333)
			Click()
			Sleep(222)
			Send(Chr(firekey))
			Sleep(222)
			DoFrenzy()
		}
		xtratime := 0
		clicktime := 15*60 + xtratime ; time to grow a golden tree
		; temp, for when wanting to use up my golden trees (testing):
	    ; clicktime := 4 * 60 ; debugging
		; clicktime := 20 ; debug with 0 golden trees saved
		ToolTip("clicker for loop #" A_Index)
		Sleep(1111)

		term := clicker_unfocused(false, clicktime)
		if term { 
			return
		}
		; ToolTip("15 minutes of clicking has ended; pausing 30 seconds (or until click) before next frenzy")
		; KeyWait("LButton","DT30")
		; ToolTip()
			vg := getTreeHealthVg()
			if A_TimeIdlePhysical < 5000 
				|| vg > 0.1 && vg < 5.0 && StopAtLowHealth {
			ToolTip("Continue frenzyloop? Press y within 20 seconds to continue ")
			kw := KeyWait("y","DT20") ; nonzero if yes, 0 if timeout
			if !kw {
				ToolTip("Stopping frenzyloop (A_TimeIdlePhysical = " A_TimeIdlePhysical " < 3000; user abort?)")
				FileAppend("Stopped:" . A_Now "; A_TimeIdlePhysical=" A_TimeIdlePhysical ",vg=" vg "`n", "Lumberjack_log.txt")
				Sleep(2222)
				ToolTip()
				break
				}
		} else {
			ToolTip("pausing 10 seconds before next frenzy (or click)")
			KeyWait("LButton","DT10")
			ToolTip()
		}
		frenzyfirst := true
	}
}

; SetTimer(showPercent,2000)

; for 409vg immortal tree (level 11)
getTreeHealthVg() 
{
	color := "ED4D4D"
	reds := FindText().PixelCount(1191, 26, 1367, 26, color,33)
	vg := 409 * (reds / (1367-1191))
	; ToolTip("vg=" vg, 1367,5)
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

LAlt & LWin::{
	if GetKeyState("LCtrl") {
		unfocus()
	}
}
; hold shift down for slowly changing volume:
LCTRL & UP::VolumeUpLoop()
LCTRL & Down::VolumeDownLoop()

+e::Send "{e 100}"  ; was {e 100}
;^!+e::Send "{e 1000}"
#HotIf

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
	global Charged_MaxRunDelay
	global keydown_time
	global ctrl_time
	global firekey
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
	msg := "Clicking! Your focus should be on the desktop."
			. "`nIf captured, tap Windows key. Avoid alt-tab."
			. "`nUse RCtrl/Click (when in focus) to stop clicking, or reload (Ctrl-R)."
	        . (hideWindow ? "`nWindow hides in " . HIDE_SECONDS . " seconds (Ctrl-C to start w/o auto-hide)"
					        . "`nUse Ctrl-Shift-H to hide, Ctrl-Alt-Shift-H to unhide FN window.":"")
	ttHWND := ToolTip(msg,10,10)
	toolTip_showing := true
	kw := KeyWait("NumPadDel","U")
	; immediately unfocusing before first Enter/click event
	; sometimes prevented the clicking from starting
	; I'm not sure if this fixes it?
	Send(Chr(96)) ; pickaxe
	Sleep(111)
	Click()
	Sleep(keydown_time)
	; KeyWait("LAlt") ; doesnt work?!
	PostMessage(WM_KEYDOWN,firekey,0,,FORTNITEWINDOW)
	Sleep(keydown_time)
	PostMessage(WM_KEYUP,firekey,0,,FORTNITEWINDOW)
	Sleep(keydown_time)
	maybe_unfocus()
	total_milliseconds := total_seconds * 1000
	ToolTip("starting clicking...")
	while A_TickCount < startTick + total_milliseconds {
		seconds_left := Floor((startTick + total_milliseconds - A_TickCount ) * 0.001) 
		if seconds_left < 9999 
			and ( Mod(seconds_left,5) = 0 or seconds_left < 30 ) {
			ToolTip(seconds_left . "s",WINX+WINWIDTH-100,WINY+100)
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
				ToolTip()
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
				ToolTip("RCtrl/Button found; stopping clicking")
				Sleep(1500)
				ToolTip()
				term := true
				break
			}
		}
		if Delay60 {
			ok:=findtext_60()
			if ok {
				xy:=ok[1]
				ToolTip("60/100(" . xy.1 . "," . xy.2 . ") +" . Delay60 . "ms",xy.1+xy.3*2,xy.2+xy.4)
				Sleep(Delay60)
				ToolTip()  
			}			
	}
	ok:=findtext_Charged()
		if ok {
			Charged_Count += 1
			; if Charged_Count = ChargedCountAtDelay {
				xy:=ok[1]
				toolTip("Charged(" . xy.1 . "," . xy.2 . ") +" . Charged_Delay . "ms,#" . Charged_Count,xy.1+xy.3*2,xy.2+xy.4)
				Sleep(Charged_Delay) ; slow down during Charged!
				ToolTip()
			; }
			
		} else {
			Charged_Count := 0
		}
	}
	ToolTip("end of clicking...")
	Sleep(2222)
	ToolTip()
	; Hotkey("Alt & Enter",,"Off")
	return term
}

oldclicker() {
	ToolTip("Press RCtrl or RButton to stop clicking",66,66	)
	ActivateFortniteWindow()
	;Send("{LClick Down}")
	Loop {
		; terminate only if window switch was likely initiated by the user:
		if !WinActive(FORTNITEWINDOW) && A_TimeIdle < 5000 {
			; ActivateFortniteWindow()
			ToolTip(FORTNITEWINDOW " not active due to user activity; stopping clicking")
			Sleep(333)
			ToolTip()
			break
		}
		if WinActive(FORTNITEWINDOW) {
			Click()
		}
		kw := KeyWait("RCtrl","DT0.2")
		rb := GetKeyState("RButton")
		if kw or rb {
			ToolTip("RCtrl/RButton found; stopping clicking")
			Sleep(1500)
			ToolTip()
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
			ToolTip("RCtrl/RButton/!f found; stopping clicking")
			Sleep(1500)
			ToolTip()
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
				ToolTip("Sending {e 111}")
				Send "{e 111}"
				Sleep(222)
				ToolTip()
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
			ToolTip("RCtrl found, stopping b (emote)")
			Sleep(3000)
			ToolTip()
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

WindowHideToggle() {
	try {
		WinHide(FORTNITEWINDOW)
	} catch {
		WinShow(FORTNITEWINDOW)
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
ToolTip()  ; get rid of "Loading..."

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

; Sleep(2146473647)