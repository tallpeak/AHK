; https://github.com/tallpeak/AHK/tree/main/fortnite
#Requires AutoHotkey v2.0
#WinActivateForce 1
#SingleInstance
; #InstallKeybdHook
; #InstallMouseHook

; maybe lower this once used to the auto-hide behavior:
HIDE_SECONDS := 10
; Some users won't like these enabled
ENABLE_AUTO_HIDE := true 
ENABLE_RESIZE := true 
; For resize: I like FN small, in upper-right:
SCALINGFACTOR := 0.4
WINWIDTH := A_ScreenWidth * SCALINGFACTOR
WINHEIGHT := A_ScreenHeight * SCALINGFACTOR
WINX := A_ScreenWidth - WINWIDTH
WINY := 10

; optional screen-scanning for Charged!:
Charged_Delay := 666 ; When "Charged!" is found
; from https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116471
FindText_defined := false
#Include "*i FindTextv2_FeiYue_9.5.ahk" ;  Version : 9.5  (2024-04-27)
try {
	FindText_defined := HasMethod(FindText, "Call")
}
findtext_Charged() {
	if ! FindText_defined {
		return 0
	}
	t1:=A_TickCount, Text:=X:=Y:=""
	Text:="|<>*254$39.rzzzzzzxzzzzyTfnzjzHxjjqqqThxiyynhhhzrqrxxizDTzzzyzzU"
	ok:=FindText(&X, &Y, 1330-22, 238-22, 1330+50, 238+10, 0, 0, Text)
	; if ok {
	; 	ToolTip("found:" X "," Y)
	; }
	return ok
}

global Volume := 50
VolumeIncrement := 5

SendMode("Event")

FORTNITEWINDOW := "ahk_class UnrealWindow"
; FORTNITEWINDOW := "ahk_exe FortniteClient-Win64-Shipping.exe"
FORTNITEPROCESS := "FortniteClient-Win64-Shipping.exe"

ToolTip("Loading macros...")

If(! WinExist(FORTNITEWINDOW) ) {
	RunWait("com.epicgames.launcher://apps/fn%3A4fe75bbc5a674f4f9b356b5c90567da5%3AFortnite?action=launch&silent=true")
	Sleep(1000)
}

Try {
	WinActivate(FORTNITEWINDOW)
	WinWaitActive(FORTNITEWINDOW)
	WinShow(FORTNITEWINDOW)
	WinActivate(FORTNITEWINDOW)
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
^+f::fastclicker() ; sword tycoon
^+o::oldclicker()  ; requires window focus
^c::clicker_unfocused(false)  ; without hide
^+c::clicker_unfocused(ENABLE_AUTO_HIDE)  ; move and hide
^+m::MoveWindowToUpperRight() ; for when I accidentally fullscreen
^+b::emoting()  ; usually used for dance floors
; control shift h to toggle window-hidden state when FN is in focus:
^+h::WindowHideToggle()

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

unfocus() {
	; Send("{AltTab}") ; didnt work
	TryWinActivate("ahk_exe chrome.exe")
	TryWinActivate("ahk_exe msedge.exe")
	TryWinActivate("ahk_exe firefox.exe")
	TryWinActivate("Visual Studio") ; I like VS Code showing on top
	TryWinActivate("ahk_exe explorer.exe") ; I think this does nothing?
	TryWinActivate("ahk_class Progman") ; except maybe remove focus from FortNite 
}

; see https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
; might want to try other bindings but so far only enter seems to work

; only seems to work out-of-focus when firekey = enter
; (You need to go into FN settings and bind fire to enter)
clicker_unfocused(hideWindow) {
	DetectHiddenWindows true
	; tried to block alt+enter, didnt work
	; Hotkey("Alt & Enter",DoNothing,"On") ; didnt work
	WM_KEYDOWN 	:= 0x0100
	WM_KEYUP 	:= 0x0101
	t1 := 200  ; ms
	t2 := "DT0.2" ; seconds
	firekey := 13 ; Enter
	starttick := A_TickCount
	; I like my Window in the upper-right at 40% size
	; I realize not all users will want this behavior
	; Having a consistent size can enable screen-scanning macros
	; (in the future), eg. using FindText
	if ENABLE_RESIZE {
		MoveWindowToUpperRight()
	}
	msg := "Clicking! Your focus should be on the desktop."
			. "`nIf captured, tap Windows key. Avoid alt-tab." 
			. "`nUse RCtrl/Click (when in focus) to stop clicking, or reload (Ctrl-R)." 
	        . (hideWindow ? "`nWindow hides in " . HIDE_SECONDS . " seconds (Ctrl-C to start w/o auto-hide)"
					        . "`nUse Ctrl-Shift-H to hide, Ctrl-Alt-Shift-H to unhide FN window.":"")
	ttHWND := ToolTip(msg,10,10)
	toolTip_showing := true
	kw := KeyWait("NumPadDel","U")

	Loop {
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
				ToolTip()
				TrayTip(msg)
				toolTip_showing := false
			}	
	}
		PostMessage(WM_KEYDOWN,firekey,0,,FORTNITEWINDOW)
		Sleep(t1)
		PostMessage(WM_KEYUP,firekey,0,,FORTNITEWINDOW)
		kw := KeyWait("RCtrl",t2)
		if WinActive(FORTNITEWINDOW) {
			lb := GetKeyState("LButton")
			rb := GetKeyState("RButton")
			if kw or lb or rb {
				ToolTip("RCtrl/Button found; stopping clicking")
				Sleep(1500)
				ToolTip()
				break
			}
		}
		if ok:=findtext_Charged() {
			xy:=ok[1]
			toolTip("(" xy.1 "," xy.2 ") +" Charged_Delay "ms",xy.1+xy.3*2,xy.2+xy.4)
			Sleep(Charged_Delay) ; slow down during Charged!
			ToolTip()
		}
	}
	; Hotkey("Alt & Enter",,"Off")
}

oldclicker() {
	ToolTip("Press RCtrl or RButton to stop clicking",66,66	)
	WinActivate(FORTNITEWINDOW)
	;Send("{LClick Down}")
	Loop {
		; terminate only if window switch was likely initiated by the user:
		if !WinActive(FORTNITEWINDOW) && A_TimeIdle < 5000 {
			; WinActivate(FORTNITEWINDOW)
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

InteractionLoop() {
	Loop {
		if A_TimeIdlePhysical > 200000 {
			WinActivate(FORTNITEWINDOW)
		}
		if WinActive(FORTNITEWINDOW) {
			if	A_TimeIdle > 555 {
			; this was for SuperVillain Tycoon, I think, or maybe Robot Tycoon 2
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
	WinActivate(FORTNITEWINDOW)
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