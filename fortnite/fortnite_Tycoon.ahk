﻿#Requires AutoHotkey v2.0
#WinActivateForce 1
#SingleInstance
; #InstallKeybdHook
; #InstallMouseHook

global Volume := 50
VolumeIncrement := 5

SendMode("Input")

FORTNITEWINDOW := "ahk_class UnrealWindow"
; FORTNITEWINDOW := "ahk_exe FortniteClient-Win64-Shipping.exe"
FORTNITEPROCESS := "FortniteClient-Win64-Shipping.exe"

If(! WinExist(FORTNITEWINDOW) ) {
	RunWait("com.epicgames.launcher://apps/fn%3A4fe75bbc5a674f4f9b356b5c90567da5%3AFortnite?action=launch&silent=true")
	Sleep(90000)
}

WinActivate(FORTNITEWINDOW)
SetKeyDelay(11,5)

^!e::InteractionLoop()

InteractionLoop() {
	Loop {
		if A_TimeIdlePhysical > 200000 {
			WinActivate(FORTNITEWINDOW)
		}
		if WinActive(FORTNITEWINDOW) && A_TimeIdle > 5555 {
			; this was for SuperVillain Tycoon, I think, or maybe Robot Tycoon 2
				ToolTip("Sending {e 111}")
				Send "{e 111}"
				Sleep(222)
				ToolTip()
			}
		Sleep(555)
	}
}

#HotIf WinActive(FORTNITEWINDOW)

+e::Send "{e 100}"

;^!+e::Send "{e 1000}"

^F6::Reload
^r::Reload

; clicker:
; don't use ctrl-alt
; right-shift right-ctrl works well for Lumberjack
^+c::
{
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
		kw := KeyWait("RCtrl","DT0.5")
		rb := GetKeyState("RButton")
		if kw or rb {
			ToolTip("RCtrl/RButton found; stopping clicking")
			Sleep(1500)
			ToolTip()
			break
		}

	}
}

; clickdown
^!+c::
{
	ToolTip("Press RCtrl to stop clicking")
	;Send("{LClick Down}")
	Loop {
		Click()
		kw := KeyWait("RCtrl","DT0.05")
		if kw {
			ToolTip("RCtrl found, stopping clicking")
			Sleep(3000)
			ToolTip()
			break
		}

	}
}

^!b::
{
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


; hold shift down for slowly changing volume:
LCTRL & UP::
{
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

LCTRL & Down::
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

#HotIf

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
