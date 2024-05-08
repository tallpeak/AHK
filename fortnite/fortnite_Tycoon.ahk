﻿#Requires AutoHotkey v2.0
#WinActivateForce 1
#SingleInstance
; #InstallKeybdHook
; #InstallMouseHook

; not used yet:
; from https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116471
; #Include "FindTextv2_FeiYue_9.5.ahk"

global Volume := 50
VolumeIncrement := 5

SendMode("Event")

FORTNITEWINDOW := "ahk_class UnrealWindow"
; FORTNITEWINDOW := "ahk_exe FortniteClient-Win64-Shipping.exe"
FORTNITEPROCESS := "FortniteClient-Win64-Shipping.exe"

If(! WinExist(FORTNITEWINDOW) ) {
	RunWait("com.epicgames.launcher://apps/fn%3A4fe75bbc5a674f4f9b356b5c90567da5%3AFortnite?action=launch&silent=true")
	Sleep(90000)
}

WinShow(FORTNITEWINDOW)
WinWaitActive(FORTNITEWINDOW)
WinActivate(FORTNITEWINDOW)
WinWaitActive(FORTNITEWINDOW)
SetKeyDelay(11,5)

#HotIf WinActive(FORTNITEWINDOW)

; key bindings
; NumPadDel key-binding has been removed

^!e::InteractionLoop()
^!+e::Edit()
End::Reload
^!r::Reload
^+f::fastclicker()
^+o::oldclicker()
^c::clicker_unfocused(false)
^+c::clicker_unfocused(true)
^!b::emoting()  ; usually used for dance floors
+e::Send "{e 10}"  ; was {e 100}
;^!+e::Send "{e 1000}"

; hold shift down for slowly changing volume:
LCTRL & UP::VolumeUpLoop()

LCTRL & Down::VolumeDownLoop()

#HotIf

; Global hotkeys:
; control alt shift h to toggle window-hidden state:
^!+h::WindowHideToggle()
^!+s::WindowShow()


; see https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
;~ VK_TAB := 0x09
;~ VK_OEM_2 := 0xBF ; slash
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
	firekey := 13
	starttick := A_TickCount
	; I like my Window in the upper-right at 40% size
	; I realize not all users will want this behavior
	; Having a consistent size can enable screen-scanning macros
	; (in the future), eg. using FindText
	SCALINGFACTOR := 0.4
	WW := A_ScreenWidth * SCALINGFACTOR
	WH := A_ScreenHeight * SCALINGFACTOR
	winmove(A_ScreenWidth-WW,10,WW,WH,FORTNITEWINDOW)
	; DllCall("SetWindowPos", "UInt", WinId, "UInt", 0, "Int", New_x, "Int", New_y, "Int", New_w, "Int", New_h, "UInt", 0x400)
	; WinActivateBottom(FORTNITEWINDOW)

	ToolTip("AFK clicker on! To switch windows, tap the Windows key." 
			. "`nAvoid alt-tab. Use RCtrl/Click to stop clicking." 
	        . (hideWindow ? "`nWindow hides in 15 seconds (use Control-C to start clicker without auto-hide behavior)"
					        . "`nUse Ctrl-Alt-Shift-H to toggle window-hidden status.":"") ,10,10)
	toolTip_showing := true
	kw := KeyWait("NumPadDel","U")

	Loop {
		; give user 6 seconds to read the message:
		if A_TickCount - starttick > 15000 {
			if toolTip_showing {
				ToolTip
				toolTip_showing := false
			}
			if hideWindow {
				hideWindow := false ; once only
				; Send("{AltTab}") ; didnt work
				TryWinActivate("ahk_exe chrome.exe")
				TryWinActivate("ahk_exe msedge.exe")
				TryWinActivate("ahk_exe firefox.exe")
				TryWinActivate("Visual Studio")
				TryWinActivate("ahk_exe explorer.exe") 
				TryWinActivate("ahk_class Progman") 
				Sleep(111)
				try {
					WinHide(FORTNITEWINDOW)
				}
			}
		}
		PostMessage(WM_KEYDOWN,firekey,0,,FORTNITEWINDOW)
		Sleep(t1)
		PostMessage(WM_KEYUP,firekey,0,,FORTNITEWINDOW)
		;~ kw := KeyWait("NumPadDel",t2)
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

WindowShow() {
	WinShow(FORTNITEWINDOW)
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
