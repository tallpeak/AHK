; https://github.com/tallpeak/AHK/GTA/keystate.ahk

#Requires AutoHotkey v2.0
InstallKeybdHook
InstallMouseHook
KeyHistory(100)
Persistent
#SingleInstance force

WindowSearchCriteria := "ahk_exe GTA5.exe"

TIMEIT := false

GetAllKeyState() {
	qpf := 0
	qpStart := 0
	qpStop := 0
	;Critical "On" ;; testing to see if the timing would be more stable
	if TIMEIT {
		DllCall("QueryPerformanceFrequency", "Int64*", &qpf)
		DllCall("QueryPerformanceCounter", "Int64*", &qpStart)
	}
	kp := "" ; physical key states
	kl := "" ; logical key states
	kb := "" ; both
	Loop 255 {
		vk := Format("vk{:X}", A_Index)
		n := GetKeyName(vk)
		p := GetKeyState(vk, "P")
		l := GetKeyState(vk)
		;; display vk only if not [0-9A-Z]
		if A_Index >= 48 && A_Index <= 57 || A_Index >= 65 && A_Index <= 90 {
			ks := n . " "
		} else {
			ks := n . "(" . vk . ") "
		}
		if p && l && p == l {
			kb .= ks
		} else if l && !p {
			kl .= ks
		} else if p && !l {
			kp .= ks
		}
	}
	kss := ""
	if StrLen(kb) {
		kss .= " keyState:" . kb
	}
	if StrLen(kp) {
		kss .= "Phys:" . kp
	}
	if StrLen(kl) {
		kss .= " Logi:" . kl
	}
	if TIMEIT {
		if StrLen(kss)>0 {
			DllCall("QueryPerformanceCounter", "Int64*", &qpStop)
			kss .= "" . Format("{:d} �s", (qpStop - qpStart) * 1000000 / qpf)
		}
	}
	;Critical "Off"
	return kss
}

~^!Home::ClearAllKeyState()

ClearAllKeyState() {
	kss := ""
	WinSetTitle("Clearing key state", WindowSearchCriteria)
	Loop 255 {
		vk := Format("\{vk{:X} UP\}", A_Index)
		Send(vk)
	}
	return kss
}

global last_title := ""

UpdateTitleBar_KeyState() {
	global last_title
	kss := ""
	kss := GetAllKeyState()
	current_title := kss
	if last_title != current_title {
		WinSetTitle(current_title, WindowSearchCriteria)
		last_title := current_title
	}
	;;Send("{vk9E UP}");;didnt work
}

SetTimer(UpdateTitleBar_KeyState,1000,0)

Return ; should not unload script,
; even if directives at top are removed, due to the timer