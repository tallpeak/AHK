#Requires AutoHotkey v2.0
#SingleInstance force

; AFKMoney_v2 moved to github on 8/14/2023:
; https://github.com/tallpeak/AHK/tree/main/GTA/AFKMoney
; Also linked from QOMPH.com/gta ; ignore the ZIP of the v1 version

; IMPORTANT SETUP INSTRUCTIONS!
; If you want to use F8 to start looping the
; AFKMoney & RP mission, you will need to make screenshots
; of some appropriate portion of the screen used to identify
; the corresponding screen
; representing where in the process the game currently is.
;
; These files must be placed in the "img" subdirectory.
;
; My resolution is 1280x720, so my screen clippings are named as follows:
; AFKMoney&RPv2_1280x720.png
; ConfirmSettings_1280x720.png
; INVITE_1280x720.png
; Play_1280x720.png
; Replay_1280x720.png
; SETTINGS_1280x720.png
;
; And yes, I know this process could use some
; better error detection and documentation... maybe tomorrow.

InstallKeybdHook
InstallMouseHook ; causes WheelDown and WheelUp to remain "physically" pressed-down, according to GetKeyState
; but installing the mouse hook causes A_TimeIdlePhysical to revert to 0 when mouse is moving
hideMouseWheelUpDownPhysical := false ; hide this apparent bug (whether in AHK, Windows, bluetooth mouse driver, or game); it seems to go away after resetting bluetooth.
KeyHistory(100)
Persistent

#Include "AppVol.AHK"
#Include "dialer.AHK"

global gWaitTimer := 0

; Important configuration variables
Debug_KeyState := true
KeyState_Update_Interval := 500
AttemptLaunch := true   ; Run steam game

; only if running as admin...
; slow-limit
global Ryzen_milliwatts := 15000 ; slow-limit
global Ryzen_milliwatts_last_set := Ryzen_milliwatts
global Ryzen_milliwatt_increment := 250
global Ryzen_milliwatts_min := 3500  ; I don't want to go much below 3.5 watts
global Ryzen_milliwatts_max := 30000 ; AMD 5625U default stapm_limit for HP 17


launch_dir := A_ScriptDir
SetWorkingDir(A_ScriptDir)  ; Ensures a consistent starting directory.
imgDir := A_ScriptDir . "/img"
if (! FileExist(imgDir)) {
	 DirCreate(imgDir)
	 ; also need to do some setup to screenshot the relevant clippings
}
GTAtitle := "GTA5"

SetNumLockState("Off")  ; set a consistent state for Numlock
SetCapsLockState("Off") ; it always annoys me when I accidentally hit capslock

SendMode("Event") ; default, and only working method

myTimeIdlePhysical() {
	return Min(A_TimeIdleKeyboard, A_TimeIdleMouse)
}

; AFKmoney by Aaron W. West, aaron@qomph.com
; converted to AHK2 7/13-7/21/2023
; uploaded to https://qomph.com/gta
; Started 3/7/2021
; Original script by reddit u/lucasgabriel7, "Updated 6/27/20" per
; https://www.reddit.com/r/gtaglitches/comments/gx8kol/improved_ahk_script_for_afk_money_rp_glitch_pc/
; For use with "AFK Money & RP v2" job
; Bookmark the job from Social Club;
; and make sure it is your first job in the list of bookmarked Survival jobs.

; 4/24: Quick volume control: Ctrl Up and Down
; 4/29: Interrupt the user after 25 minutes, until Replay pressed, regardless of whether busy
;       (added MinMissionSeconds & elapsedMission)
; 5/?? aggressive window switching after 25 minutes, to avoid missing Replay
; 5/16 replaced A_TimeIdlePhysical with A_TimeIdlePhysical but didn't like aggressive window switching; changing back

; 7/26 - 7/20 update broke ImageSearch -- fixed, I think
; 8/2  SetVolume was creating multiple timers, now -2000
; 8/4  wait for Ctrl to be released for get vehicle
; 10/3/2021 stop searching for Play button; this seems to no longer work

; The biggest remaining issue with this script:
; Originally I was trying to make the computer usable during automation
; (return keyboard focus to the "original" window)
; I did not fully succeed, but it's usable during Netflix or Youtube,
; and sometimes light work if you don't mind the aggressive window switching at about 25 minutes into mission.
; ImageSearch can only work when the window is active, unfortunately;
; binary code could be included to fix this issue, but I like this script to be pure AutoHotKey and no binaries.

; Rewrite needed, using SetTimer instead of a loop. Would be much cleaner.

#SingleInstance force
; #WinActivateForce ; This does not seem to have any effect; a different workaround may be needed for occasionally failing WinActivate
; REMOVED: #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; disable #Warn for normal use because it can bring up modal dialogs (halt script with error)
#Warn All ;,OutputDebug ; Enable warnings to assist with detecting common errors
; SendMode must be left at the default (Event); GTA does not seem to respond to "Input":
; SendMode,Event
; DetectHiddenWindows, On
; CONSTANTS
; A "kick" is a periodic activity to prevent idle; currently {z}

GTAwindow := "ahk_exe GTA5.exe" ; or "ahk_class grcWindow"

;Sky Fall Fast AFK Test = 8
WhichJob := 0 ; (only upload this as #0, first job) move down how many times in the bookmarked Survivals?
helptext:=" F8 Start,F9 Resume,F10 Exit,F12 Freemode "
UserIdleThreshold := 122 * 1000 ; (milliseconds) At least 10 to 60 seconds, to avoid interrupting the user
; Tweak this for your system, based on highest elapsed value seen during wave 20:
; start interrupting the user when close to end of mission
; If set too high, the Replay button may be missed:
MinMissionSeconds := 1500-10 ; Last measured 1506 (25 minutes)
MaxMissionSeconds := 1500+90  ; Stop aggressively switching windows after this time
MinKickSeconds := 3 * 60  ; when user is idle
MaxKickSeconds := 10 * 60 ; Normally, 2 to 14 minutes, to avoid idle kick at 15 min
EmergencyKickSeconds := 9*60 ; A few minutes before 15 minute idle kick
RaiseStealth := false ; if you'd like more stealth, set to true
; global KEY_SEND_DELAY := 190 ; Increase this if it moves between menus very fast.
; global KEY_PRESS_DELAY := 20 ; If it doesn't press, increase it too.
Enable_SPAM := false ; seems to just annoy people when advertised in freemode
MenuDelay := 1600
warning := ""
lastKick := A_TickCount
idleSec := 0
VolumeIncrement := 5
Volume := 50 ; I like starting volume to be lower than other apps (for the first SetVolume)
ProcessId := 0
gotoFreemode := ""
setdefaultkeydelay()
WX := 0
WY := 0
WW := 0
WH := 0
if ! WinExist(GTAwindow) {
	if AttemptLaunch {
		Run("steam://rungameid/271590") ; RunWait sometimes gets stuck
	}
	; If the user alt-tabs away while the launcher is loading, this can take a long time
	w := 0
	Loop 3 {
		ToolTip("Looking for GTA5, waiting 60 seconds, loop #" . A_Index . " of 3")
		w := WinWaitActive(GTAwindow,,60) ; Set GTA in focus at start (but user can change focus)
		if w {
			break
		}
		WinActivate(GTAwindow)
	}
	ToolTip("")
	if w && WinExist(GTAwindow) {
		ToolTip("GTA5 window found, reloading script in 4 seconds...")
		Sleep(4000)
		ToolTip()
		Reload
		ToolTip("Reload failed")
		Sleep(2000)
		ExitApp(1)
	} else {
		ToolTip("can't find GTA5.exe; exiting in 10 seconds. Reload the script after loading GTA")
		Sleep(10000)
		ExitApp(1)
	}
}
;WinGetPos(&WX, &WY, &WW, &WH)
WinGetClientPostries := 0
Loop {
	TryWinActivate(GTAwindow)
	WinGetClientPos(&WX, &WY, &WW, &WH, GTAwindow)
	Sleep(100)
	if WinGetClientPostries > 100 {
		throw("can't get client window position/size, bombing out")
	}
	WinGetClientPostries += 1
} until WW > 0 && WH > 0

full_command_line := DllCall("GetCommandLine", "str")

WinSetAlwaysOnTop(false) ; bug I hit once after alt-enter to go fullscreen; it was stuck on top after returning to windowed
; ImageResolution := "_1280x720" ;  screen resolution at which the image was clipped
; bug in 2.0.7? ImageResolution == _0x0 WX: -32000 WY: -32000 WH: 0 WW: 0
ImageResolution := "_" . WW . "x" . WH ; current screen resolution; look for images recorded at same
XToolTip := 200
YToolTip := WH-20
; Old method of messaging the user was ToolTip, but I like WinSetTitle better
; although title bar usage requires windowed with borders
;ToolTip, Instructions for use`: %helptext%, XToolTip, YToolTip, 1
WinSetTitle(GTAtitle "`: " helptext, GTAwindow)
startMission := 0

ListLines false

GetAllKeyState() {
	ListLines false
	freq := 0
	CounterBefore := 0
	CounterAfter := 0
	;Critical "On" ;; testing to see if the timing would be more stable
	;~ DllCall("QueryPerformanceFrequency", "Int64*", &freq)
	;~ DllCall("QueryPerformanceCounter", "Int64*", &CounterBefore)
	;~ kss := ""
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
		} else if p && !l && (((A_Index & 0x9E) != 0x9E) && !hideMouseWheelUpDownPhysical)  {
			; got tired of seeing MouseWheelUp and MouseWheelDown
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
	;~ if StrLen(kss)>0 {
		;~ DllCall("QueryPerformanceCounter", "Int64*", &CounterAfter)
		;~ kss .= "" . Format("{:d} µs", (CounterAfter - CounterBefore) * 1000000 / freq)
	;~ }
	;Critical "Off"
	ListLines true
	return kss
}
	ListLines true

; Reload clears logical keystate, so this may not be very useful,
; or only useful when "physical" keystate is stuck down

*^!NumLock::ClearAllKeyState()

ClearAllKeyState() {
	WinSetTitle("Clearing key state", GTAwindow)
	Loop 255 {
		vk := Format("vk{:X}", A_Index)
		p := GetKeyState(vk, "P")
		l := GetKeyState(vk)
		if p || l {
			Send("{" . vk . " up}")
		}
	}
	UpdateTitleBar_KeyState()
}

global current_keystate := ""
global last_keystate  := ""

updateTitleBar() {
	global last_keystate
	if last_keystate == "suspended" {
		return
	}
	if last_keystate != current_keystate  {
		title := GTAtitle . "`: " . current_keystate
		WinSetTitle(title, GTAwindow)
		last_keystate := current_keystate
	}
}

UpdateTitleBar_KeyState() {
	global current_keystate := GetAllKeyState()
	updateTitleBar()
}

if Debug_KeyState {
	SetTimer(UpdateTitleBar_KeyState, KeyState_Update_Interval, 0)
}
Return

;Hotkey, F8, Start_AFK_Farming
;Hotkey, F9, Resume_AFK_Farming
;Hotkey, F10, Shutdown_AFK_Farming
;;;;;;;;;;;;;;;;;;;;;;;
;; pressDuration must be longer than 1 frame
;; so if vsync = half (30fps), then it must be at least 34ms
setdefaultkeydelay(){
	SetKeyDelay(30, 90) ;delay,pressDuration ; WAS 190,20
}

^!+s::
StealthCircles(*)
{
	KeyWait("Ctrl", "T2")
	KeyWait("Alt", "T2")
	KeyWait("Shift", "T2")
	KeyWait("s", "T1")
	global RaiseStealth:=!RaiseStealth
	if (RaiseStealth)
	{
		Send("{LCtrl}")
		Send("{d down}")
	}
	else
	{
		Send("{LCtrl}")
		Send("{d up}")
	}
}


; ^!F4::
; Process, Close, GTA5.exe
; return

*^!F6::
{
	ClearAllKeyState()
	reloadscript()
}

^!F7::
;Sleep, 10*60000 ; 10 minutes, enough time for a resupply to come in
{
	Loop 300
	{
		remaining := 600 - A_Index * 2
		WinSetTitle(remaining " seconds until start of automation", GTAwindow)
		Sleep(2000)
	}
	Start_AFK_Farming()
}

^!F8::
{
	Start_AFK_Farming()
}

^!F9::
{
	Resume_AFK_Farming()
}

^!F10::
{
	Shutdown_AFK_Farming()
}

^!F11::
{
	KeyWait("Ctrl", "T2")
	KeyWait("Alt", "T2")
	KeyWait("F11", "T1")
	Goto(SPAM)
}

^!F12::
{
	toggleReturnToFreemode()
}

; Avoid messing with application-specific hotkeys:
#HotIf WinActive(GTAwindow) ; //replaces #IfWinActive from AHK v1
; Try this ?
; HotIfWinActive(GTAwindow)

; Pressing F8 hogs the thread so that F8 doesn't work again,
; until SetTimer and Return releases the thread
F8::Start_AFK_Farming()

Start_AFK_Farming()
{
;Start_AFK_Farming:
	SetCapsLockState("AlwaysOff") ; prevent Social Club from popping up during automation
	global gotoFreemode := ""
	setdefaultkeydelay()
	job_status := 0
	TryWinActivate(GTAwindow) ; GTA need to be on focus.
	Sleep(10)
	ErrorLevel := WinWaitActive(GTAwindow, , 1) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
	Sleep(10)
	KeyWait("Ctrl", "T1")
	KeyWait("Shift", "T2")
	KeyWait("F8", "T3") ; wait for F8 to be released
	Sleep(MenuDelay)
	Send("{esc down}") 		; Pause menu
	Sleep(MenuDelay)
	Send("{esc up}") 		; Pause menu
	Sleep( MenuDelay * 5 ) ; this is hard to get right?
	Send("{d}") 		; ONLINE tab
	Sleep(MenuDelay)
	Send("{enter}") 	; ONLINE dropdown
	Sleep(MenuDelay)
	Send("{enter}") 	; Jobs
	Sleep(MenuDelay)
	Send("{s}") 		; Play Job
	Sleep(MenuDelay)
	Send("{enter}") 	; select Play Job
	Sleep(MenuDelay)
	Send("{s}") 		; Bookmarked
	Sleep(MenuDelay)
	Send("{enter}") 	; select Bookmarked
	Sleep( MenuDelay * 4 ) ; it can take a long time for this menu to come up
	Send("{w 5}") 		; Survivals
	Send("{enter}")	; Select Survivals
	Sleep(66)
	Loop WhichJob ; which survival
	{
		Send("{s}")
	}
	Send("{enter}")
	Loop 5
	{
		Sleep(MenuDelay)
		Send("{enter}")
	}
	;Gosub, SPAM
	; Sleep, ( MenuDelay * 3.2 )
	global startMission := A_TickCount
	; Goto, Resume_AFK_Farming
	SetTimer(Resume_AFK_Farming,-100)
}

F9::Resume_AFK_Farming()

Resume_AFK_Farming()
	; It's impossible to compute startMission, so I just make a guess
	; Unless it's possible to read Wave ## (but if I could do that, I'd scan for Wave 20)
{
	global startMission := A_TickCount - 5 * 60000 ; Just a guess
	SetTimer(Resume_AFK_Farming2,-100)
	Return ; Free the thread so that F8/F9 keys can be pressed again
}

Resume_AFK_Farming2()
{
	global gotoFreemode := ""
	setdefaultkeydelay()
	SPAM()
	Loop
	{
		original := 0
		elapsedMission := Round((A_TickCount - startMission) / 1000)
		; try to avoid interrupting the user when busy
		; Do not change below to A_TimeIdlePhysical; it starts aggressive windows switching and interrupting the game
		; I think it's because keydown is a single event, so driving/flying straight is idle activity, after the threashold
		; Ideally, I would like to be able to customize the meaning of TimeIdle(Physical) to my needs
		; Or create a keyboard+mouse hook for every event to create my own idle variable
		if (A_TimeIdlePhysical < UserIdleThreshold
			&& (elapsedMission < MinMissionSeconds || elapsedMission >= MaxMissionSeconds ))
		{
			if (! WinActive(GTAwindow) && WinExist(GTAwindow)) {
				;ToolTip, %warning% User busy`:idle`=%idleSec%s, 750, 1, 1
				kss := GetAllKeyState()
				WinSetTitle(GTAtitle "`:" kss " " warning " User busy`:idle`=" idleSec "s idle=" A_TimeIdle " phys=" A_TimeIdlePhysical " " gotoFreemode " elapseM=" elapsedMission " V" Volume, GTAwindow)
			}
		}
		else
		{
			if (A_TimeIdlePhysical < UserIdleThreshold && (! WinActive("ahk_axe GTA5.exe")) && (! gotoFreemode))
			{
				; warn the user that they are being interrupted
				Loop 1 {
					SoundBeep(6666, 10)
					;Sleep(10)
				}
			}
			original := -1
			tries := 0
			while original == -1 && tries < 5 {
				tries += 1
				try {
					original := WinGetID("A")
					break
				} catch Error as e {
					OutputDebug("Error" || e)
				}
				OutputDebug("original wingetid=" || original || ",tries=" || tries)
			}
			;~ if original == -1 {
				;~ ToolTip("cant get original window; returning")
				;~ sleep(3333)
				;~ ToolTip("")
				;~ return
			;~ }
			TryWinActivate(GTAwindow)
			Sleep(200)
			ErrorLevel := WinWaitActive(GTAwindow, , 2)
			ErrorLevel := ErrorLevel = 0 ? 1 : 0
		}
		;ImageSearch is pointless if GTA not active window (it will fail)
		If WinActive(GTAwindow)
		{
			; Possibly reduce search area to lower CPU usage
			; And/or change image search frequency depending on elapsed time in mission
			ErrorLevel := !ImageSearch(&xSettings, &ySettings, 1, 1, A_ScreenWidth, A_ScreenHeight, "*30 " launch_dir "\img\SETTINGS" ImageResolution ".png")
			ErrorLevel := !ImageSearch(&xInvite, &yInvite, 1, 1, A_ScreenWidth, A_ScreenHeight, "*30 " launch_dir "\img\INVITE" ImageResolution ".png")
			; ImageSearch, xPlay, yPlay, 1, 1, A_ScreenWidth, A_ScreenHeight, *80 %launch_dir%\img\Play800.png

			; Replay=534,694; *50 because it has to be higher than 30, because Replay is on a changing background, I think
			ErrorLevel := !ImageSearch(&xReplay, &yReplay, 1, 1, A_ScreenWidth, A_ScreenHeight, "*80 " launch_dir "\img\Replay" ImageResolution ".png")

			; Some debugging information; status and image locations if found
			global idleSec:=Round((A_TickCount - lastKick)/1000)
			;ToolTip, %warning% SETTINGS`=%xSettings%`,%ySettings% INVITE=%xInvite%`,%yInvite% Replay=%xReplay%`,%yReplay% idle`=%idleSec%s %helptext%, XToolTip, YToolTip, 1
			WinSetTitle(GTAtitle "`:" gotoFreemode " " warning " SETTINGS`=" xSettings "," ySettings " INVITE=" xInvite "," yInvite " Replay=" xReplay "," yReplay " idle`=" idleSec "s idle=" A_TimeIdle " phys=" A_TimeIdlePhysical  " elapM=" elapsedMission " " helptext " V" Volume " " WW "x" WH, GTAwindow)


			if (xSettings != "")
			{
				Sleep(MenuDelay)
				TryWinActivate(GTAwindow) ; GTA need to be on focus.
				Send("{w}")
				Send("{enter}")
				if original > 0 {
					TryWinActivate("ahk_id " original)
				}
				Sleep(( MenuDelay * 2 ))
				Continue
			}
			else if (xInvite != "") ; && xPlay != ""
			{
				; TODO: change from search for Invite to search for PLAY
				Sleep(MenuDelay * 6) ; this seems necessary; play button doesnt appear immediately
				; Experiment with leaving the mission open? (can make more with more players)
				; No: they will often vote me into a real survival!
				TryWinActivate(GTAwindow) ; GTA need to be on focus.
				CloseMission := True
				if (CloseMission) {
					Send("{d}") ; Matchmaking: closed
					Sleep(222)
				}
				Send("{w}")
				Sleep(222)
				Send("{w}")
				Sleep(222)
				if (CloseMission) {
					Send("{d}") ; client invites: disabled
					Sleep(222)
				}
				Send("{s}") ; Play
				Sleep(222)
				Send("{enter}") ; launch
				Sleep(2000)
				Send("{enter 3}") ; are you sure you want to launch this on your own?
                ; a few of minutes of waiting for possible player joining
				Loop 50 ; because of "player joining" at times
                {
    				Sleep(MenuDelay * 5)
					if WinActive(GTAwindow)
					{
						if (A_TimeIdlePhysical > 10000) ; dont interrupt typing in chat, etc
						{
		    				Send("{enter}") ; launch
						}
						; for more accurate mission timing,
						; find the AFKMoney&RPv2 image and set the mission start time
						Send("{z}")
						Sleep(100)
						TryWinActivate(GTAwindow) ; GTA need to be on focus.
						ErrorLevel := !ImageSearch(&xMission, &yMission, 1, 1, A_ScreenWidth, A_ScreenHeight, "*30 " launch_dir "\img\AFKMoney&RPv2" ImageResolution ".png")
						if (xMission)
						{
							;ToolTip, AFKMoney`&RPv2_800x600=(%xMission%`,%yMission%), xMission, yMission, 2
							; (x,y)=(14,29)
							;SetTimer, deleteToolTip2, -30000
							break ; so that we can set startMission
						}
							; consider killing GTA5,
							; Quitting the mission,
							; or other drastic measures if we fail to find the mission we are looking for
					}
					SetCapsLockState("Off") ; instead of AlwaysOff; this is to prevent Social Club from popping up during automation
					if A_LoopField == 50 {
						; failed to find mission, need to exit after the end of this
						global gotoFreemode := "Freemode"
					}
                }
				global startMission := A_TickCount ; - 5 * 24 ; compensate for loop above
				TryWinActivate("ahk_id " original)
				Sleep(( MenuDelay * 10 ))
				if WinActive(GTAwindow)
				{
					doSPAM() ; clue any joiners into the fact that I am likely AFK!
					Send("t{Esc}")
				}
				Continue
			}
			else if (xReplay != "")
			{
				; Job is done, time to find a new one! (Press replay!)
				Send("{w}zz")
				if (gotoFreemode)
				{
					Send("{d}zz{d}") ; Freemode is two to the right from Replay
					Sleep(MenuDelay)
					SoundBeep(444, 20)
				}
				Sleep(MenuDelay)
				Send("{enter}")  ; vote for replay or freemode
				Sleep(60000) ; wait a minute! To prevent possible re-vote
				startMission := A_TickCount ; so that we stop bothering the user with window switching as soon as possible!
				TryWinActivate("ahk_id " original)
				if gotoFreemode && A_TimeIdlePhysical > 3600000 {
					; user is very idle (over an hour) yet we are returning to freemode; not good!
					; spending a long time in freemode while AFK can lead to raids, for example
					; so just suspend the game until the user gets back
					WinSetTitle("Idle>1hr while going Freemode; suspending game in 180 sec; ESC to abort",GTAwindow)
					kw := KeyWait("{ESC}","DT180")
					if !kw && A_TimeIdlePhysical > 3600000 {

						; copy-paste coding (sorry!)
						Thread("NoTimers")
						Suspend(true) ; prevent hotkeys (Send to the window would cause a deadlock)
						global last_kss := "suspended"
						Critical "On"

						PID_or_Name := GTAwindow
						WinSetTitle("Suspending game...",PID_or_Name)
						Sleep(200)
						PID := (InStr(PID_or_Name, ".")) ? ProcExist(PID_or_Name) : PID_or_Name
						h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", pid)
						If !h
							Return -1
						DllCall("ntdll.dll\NtSuspendProcess", "Int", h)

						mb := MsgBox("Resume game? (exit script if no)",,4)

						if mb == "Yes" {
							DllCall("ntdll.dll\NtResumeProcess", "Int", h)
							DllCall("CloseHandle", "Int", h)
						} else {
							ExitApp()
						}
						Critical "Off"
						global last_kss := ""
						Suspend(false)
						Thread("NoTimers",false)
					}
				}
				job_status := 0
				Sleep(( MenuDelay * 3 ))
				Continue
			}
		}
		; else { ; Prevent AFK idle kick
		if (A_TimeIdlePhysical > UserIdleThreshold
			&& A_TickCount > ( lastKick + MinKickSeconds*1000)
			|| A_TickCount > ( lastKick + MaxKickSeconds*1000) )
		{
			;WinGet, original, , ahk_exe GTA5.exe
			TryWinActivate(GTAwindow)
			ErrorLevel := WinWaitActive(GTAwindow, , 1) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
			if !WinActive(GTAwindow)
			{
				; This code comes from a time when I thought WinActivate was failing. It could probably be deleted
				if WinExist(GTAwindow)
				{
					; WinMinimize, A
					; Send {Alt Down}{Tab}{Alt Up}
					; Sleep,50
					TryWinActivate(GTAwindow)
					ErrorLevel := WinWaitActive(GTAwindow, , 1) , ErrorLevel := ErrorLevel = 0 ? 1 : 0 ; might be hanging?
				}
				Else ; If GTA5 crashed, we might as well quit? Consider restarting GTA5?
				{
					ToolTip("`"GTA5 gone; crashed? Exiting...`"")
					Sleep(5000)
					ToolTip()
					ExitApp(1)
				}
			}
			If WinActive(GTAwindow)
			{
				if (A_TimeIdlePhysical > 4*60*1000) ; when *very* AFK, but hopefully not about to get kicked (ESC can interfere with some things)
				{
					Send("{t}")	; talk, but don't say anything
					Sleep(600)   ;I think this is needed when social club overlay is up?
					Send("{Esc}")  ; this should escape from Social Club overlay if up, else escape from Talk
					Sleep(600)
				}
				Send("{z}")
				if (RaiseStealth)
				{
					if (A_TickCount < startMission + 15 * 60000)
					{
						StealthCircles()
					}
					else
					{
						Send("{d up}")
					}
				}

				; Sleep, MenuDelay * 10
				global lastKick := A_TickCount
				global warning := ""
				ToolTip(, , , 2)
			}
			Else
			{
				warning := " WinActivate Failed!"
				ToolTip(warning, 20, 100, 2)
				if (A_TickCount > ( lastKick + EmergencyKickSeconds*1000))
				{
					; EMERGENCY! Warn user that idle kick timeout may be coming quickly
					Loop 10
					{
						TryWinActivate(GTAwindow)
						ErrorLevel := WinWaitActive(GTAwindow, , 1) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
						If WinActive(GTAwindow)
						{
							Send("{z}")
							; Sleep, MenuDelay * 10
							lastKick := A_TickCount
							warning := ""
							ToolTip(, , , 2)
							Continue
						}
						else
						{
							If (!WinExist(GTAwindow))
							{
								;ToolTip, "GTA5.exe does not exist; crashed? Exiting..."
								;sleep,3000
								;ExitApp, 1 ; no need to keep running? User will just have to restart.
								Continue
							}
							SoundBeep(666, 10)
							Sleep(10)
						}
					}
				}
			}
			TryWinActivate("ahk_id " original)
		}
		TryWinActivate("ahk_id " original)
		Sleep(( MenuDelay * 2))
	}
}

; first time pressed; disable Replay image search and window activation
; second time pressed = exit AHK
F10::Shutdown_AFK_Farming()

Shutdown_AFK_Farming()
{
	if (startMission > 0) {
		global startMission := -24*3600*1000 ; a large negative number equal to one day
		Return
	}

Shutdown_AFK_Farming1:
	;ToolTip, Shutting down AFK_Farming..., XToolTip, YToolTip, 1
	WinSetTitle(GTAtitle "`: Shutting down AFKmoney...", GTAwindow)
	Sleep(MenuDelay * 2) ; Just so the user can read the message
	;ToolTip, , , , 1
	WinSetTitle("Grand Theft Auto V", GTAwindow)
	ExitApp() ; stop the macro
}

F6::reloadscript()

reloadscript()
{
	Reload()
	Sleep(1000) ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
	msgResult := MsgBox("The script could not be reloaded. Would you like to open it for editing?", "", 4)
	if (msgResult = "Yes")
		Edit()
}

^!+r::Reload()  ; Ctrl+Alt+R

; A little bit of self-promotion; hopefully not too much
SPAM()
{
  IF (Enable_SPAM)
  {
	doSPAM()
  }
}

F11::doSPAM()

doSPAM()
{
  if (WinActive(GTAwindow) )
  {
	SetKeyDelay(3, 1)
	Send("t{Esc}")
	Sleep(100)
	Send("t")
	Sleep(100)
	Send("Free AFK money macro: QOMPH.COM/GTA")
	setdefaultkeydelay()
	Sleep(MenuDelay * 2) ; a brief chance to press ESC to reduce spamming
	Send("{Enter}")
  }
}

pasteToChat(msg)
{
	KeyWait("Ctrl", "T2")
	KeyWait("Alt", "T2")
	KeyWait("v", "T2")
	SetKeyDelay(0, 10)
	;Send("t{Esc}")
	;SendMode("Input")
	Loop Parse msg, "`r`n", "`r`n" {
		if StrLen(A_LoopField) > 0 {
			m := StrReplace(A_LoopField,"`t","    ")
			Sleep(200)
			Send("t")
			Sleep(100)
			Send("{Raw}" . m)
			;SendInput("Input:{Raw}" . m)
			;SendPlay("Play:{Raw}" . m)
			;SendEvent("Event:{Raw}" . m)
			;SendText("Text:{Raw}" . m)
			Send("{enter}")
		}
	}
	;SendMode("Event")
}

/* ^+F11::{
	msg := ( "Public service announcement, to help PC users with griefing modders"
			"|To escape from a session, get pssuspend from Microsoft.com and run this command:"
			"|pssuspend gta5 && timeout -T 10 && pssuspend -r gta5"
			"|See https://learn.microsoft.com/en-us/sysinternals/downloads/pssuspend{enter}" )
	pasteToChat(msg)
	setdefaultkeydelay()
} */


F12::toggleReturnToFreemode()

toggleReturnToFreemode()
{
	global gotoFreemode
	ErrorLevel := !KeyWait("Ctrl", "T2")
	ErrorLevel := !KeyWait("Alt", "T2")
	ErrorLevel := !KeyWait("F12", "T1")
	if (gotoFreemode) {
		global gotoFreemode := ""
	} else global gotoFreemode := "Freemode"
	Return
}

; get oppressor mk2 from mechanic using dialNumber (last vehicle in arcade)
^o::{
	dialMechanic_getCar(-8,-1)
}

; -1 means last garage or last car
; 0 should be first garage or first car
; +1 is second garage or second car
dialMechanic_getCar(garage,car) {
	CallMechanic("")
	Sleep(5250)
	Send("{" (garage >= 0 ? "down" : "up") " " abs(garage) "}")
	Send("{enter}")
	Send("{" (car >= 0 ? "down" : "up") " " abs(car) "}")
	; Send("{enter}")
	setdefaultkeydelay()
}


; old call mors insurance; only works in freemode
; so use dialNumber instead
;~ ^m::
;~ {
	;~ SetCapsLockState("AlwaysOff")
	;~ ErrorLevel := !KeyWait("Alt", "T2")
	;~ SetKeyDelay(10, 200) ;delay,pressDuration
	;~ Send("{up}")
	;~ Sleep(666)
	;~ Send("{right}{up}{enter}")
	;~ Sleep(666)
	;~ Send("{up 16}{enter}")
	;~ setdefaultkeydelay()
;~ }

;~ ; get oppressor mk2 from mechanic (last vehicle in arcade)
;~ ^o::
;~ {
	;~ SetCapsLockState("AlwaysOff")
	;~ ErrorLevel := !KeyWait("Alt", "T2")
	;~ SetKeyDelay(15, 200) ;delay,pressDuration
	;~ Send("{up}")
	;~ Sleep(666)
	;~ Send("{right}{up}{enter}")
	;~ Sleep(777)
	;~ ;Send("{up 18}{enter}") ; sometimes 17
	;~ Send("{left 4}{down 2}{enter}")
	;~ Sleep(5250) ; or up 9 instead of {down 5(assoc) or 6(ceo)}
	;~ Send("{up 8}{enter}{up}") ; {enter}
	;~ setdefaultkeydelay()
;~ }

; Oppressor Mk2 get ??? seems to be  return to garage
	;~ ErrorLevel := !KeyWait("Alt", "T2")
	;~ SetKeyDelay(25, 15) ;delay,pressDuration
	;~ Send("{m}")
	;~ Sleep(55) ; or up 9 instead of {down 5(assoc) or 6(ceo)}
	;~ Send("{down 5}{enter}{down 3}{enter}{down 2}{enter}")
	;~ setdefaultkeydelay()


; Oppressor Mk2 get from terrorbyte
^+o::
{
	KeyWait("Shift", "T2")
	KeyWait("Control", "T2")
	SetKeyDelay(10, 70) ;delay,pressDuration
	Send("{m}")
	Sleep(55)
	Send("{down 6}{enter}{down 3}{enter}{down 2}{enter}")
	Send("z{enter}z{esc 3}") ; one extra enter, some delay
	setdefaultkeydelay()
}

;;helicopter fly forward 120 seconds
^+NumpadUp::
^+Numpad8::
{
    KeyWait("Control", "T1")
	KeyWait("Shift", "T1")
    KeyWait("Numpad8", "T1")
    KeyWait("NumpadUp", "T1")
	Send("{w down}{numpad8 down}")
	KeyWait("w","DT120") ;sleep(120000) or until w
	Send("{w up}{numpad8 up}")
}

; walk or fly straight
; for when up in the air on my oppressor mk2
^!w::
{
	Send("{w down}")
}

;Drive slowly for nightclub VIP to hosp or home, etc
^!+w::
{
	;~ global TBmode
	;~ TBmode := "driving slowly"
	Loop 999 {
		Send("{w down}")
		Sleep(444)
		Send("{w up}")
		Sleep(333)
		if GetKeyState("w","P") || GetKeyState("Shift","P")
			return
	}
}

; Run or swim straight
^!r::
{
	Send("{w down}{ShiftDown}")
	Return
}

WaitTimer_Start() {
	global gWaitTimer := 0
	SetTimer(WaitTimer,10)
}

WaitTimer_Stop() {
	SetTimer(WaitTimer,0)
	WinSetTitle("t=" . gWaitTimer, GTAwindow)
}

WaitTimer() {
	global gWaitTimer += 1
	if Mod(gWaitTimer,5)==0 {
		WinSetTitle("t=" . gWaitTimer, GTAwindow)
	}
}


; for Oppressor Mk2 owners - fly across the map
; Originally: fly straight for 2 minutes; first up, then straight, then down partway
; Control-Shift W
; Now: Hold w for longer for a longer flight; 1 second held = t=100 = about a 45-second flight
^+w::
{
	WaitTimer_Start()
	global gWaitTimer := 50
	KeyWait("w", "T10")
	WaitTimer_Stop()
	t := gWaitTimer
    KeyWait("Shift", "T2")
    KeyWait("Control", "T2")
    Sleep(100)
    Send("{Numpad5 Down}{w Down}")
    Sleep(5000)
	Send("{space down}")
    ;Sleep(25000)
	el:=KeyWait("w","DT" . (t / 2 + 5)) ; DT25
	Send("{space up}")
	if GetKeyState("w","P")
		goto endflight ;return
	;Input(l,"L30")
    Send("{Numpad5 Up}{w Down}")
    Sleep(20)
	;Sleep(10000)
	; doesnt seem to work: el:=KeyWait("w","T10")
	el:=KeyWait("w","DT" . (t / 4)) ; DT10
	if GetKeyState("w","P")
		goto endflight ;return
	;Input(l,"L10")
    Send("{Shift Down}{w Down}")
    ;Sleep(20000)
	el:=KeyWait("w","DT" . (t / 4)) ; DT10
	if GetKeyState("w","P")
		return
	;Input(l,"L20")
endflight:
    Send("{Numpad5 Up}{Shift Up}{w up}{space up}")
}

; a simpler example:
; danceOlder:
;     Loop 10000 ; make it longer after tuning
;     {
;         Sleep,480
;         Click
; 	}
; 	Return

; Dance!
^!d::
{
	;Sleep(1600)
	;ErrorLevel := !KeyWait("Control")
	;ErrorLevel := !KeyWait("Alt")
	ErrorLevel := !KeyWait("d")
	ToolTip("Hold right-click to stop dancing", 11, 11)
	Send("e") ; start dancing
    Loop ;,10000 ; make it longer after tuning
    {
        Sleep(480)
        if WinActive(GTAwindow)
		{
            Click()
			Send("{Space}")
			if (GetKeyState("RButton","P"))
			{
				Send("{Esc}")  ; stop dancing
				Break
			}
		}
    }
	ToolTip()
}

; walk in circles. Dangerous (breaks Replay)
^+d::Send("{d down}")

; get vehicle (when CEO/MC)
^+v::
{
	SetKeyDelay(25, 15) ;delay,pressDuration
	Send("{m}")
	Sleep(100)
	Send("{Down 5}{Enter 2}")
	ErrorLevel := !KeyWait("Ctrl", "T2")
	If (! Errorlevel )
	{
		Send("{Esc}")
	}
	setdefaultkeydelay()
}

;~ ; get vehicle (when not CEO)
;~ ^!v::
;~ {
	;~ SetKeyDelay(25, 15) ;delay,pressDuration
	;~ Send("{m}")
	;~ Sleep(100)
	;~ Send("{Down 4}{Enter 2}")
	;~ KeyWait("Alt", "T2")
	;~ ErrorLevel := !KeyWait("Ctrl", "T2")
	;~ If (! Errorlevel )
	;~ {
		;~ Send("{Esc}")
	;~ }
	;~ setdefaultkeydelay()
;~ }

; New session:
^!n::
{
	If(!WinActive(GTAwindow))
		Return
	SetKeyDelay(10, 90) ;delay,pressDuration
	KeyWait("Ctrl", "T3")
	KeyWait("Alt", "T3")
	KeyWait("N", "T3")
	Sleep(100)
	Send("{Esc down}")
	Sleep(MenuDelay * 2)
	Send("{Esc up}")
	Sleep(MenuDelay)
	Send("d") ; Online
	Sleep(MenuDelay)
	Send("{Enter}") ; select online
	Sleep(MenuDelay * 2)
	Send("{s 11}") ; Find new session; {w 3} might work but risks selecting Exit Online if it misses one w
	setdefaultkeydelay()
	Send("{Enter}")
	Sleep(MenuDelay*2)
	Loop 5 {
		Sleep(MenuDelay)
		Send("{Enter}")
	} ; extra (are you sure take a while to show up)
}

deleteToolTip2:
{
	ToolTip(, , , 2)
	Return
}

ResolutionUp(n)
{
	global MenuDelay
	TryWinActivate(GTAwindow)
	ErrorLevel := WinWaitActive(GTAwindow, , 1) , ErrorLevel := ErrorLevel = 0 ? 1 : 0
	ErrorLevel := !KeyWait("Ctrl", "T2")
	ErrorLevel := !KeyWait("Shift", "T2")
	setdefaultkeydelay()
	Sleep(200)
	Send("{Esc}")
	Sleep(MenuDelay *2)
	Send("{a 4}") ;Settings
	Send("{Enter}") ; select Settings
	Sleep(MenuDelay)
	Send("{s 6}") ; Graphics
	Send("{Enter}") ; Select Graphics
	Sleep(MenuDelay)
	Send("sss") ; down to Resolution
	if(n>0)
	{
		Send("{d " n "}") ; up Resolution n times
	} Else {
		n:=-n
		Send("{a " n "}") ; down Resolution n times
	}
	Send("{s 2}")
	Sleep(MenuDelay)
	Send("{space}") ; make the change
	Sleep(MenuDelay)
	Send("{Enter}") ; confirm the change
	Sleep(MenuDelay)
	Send("{Enter}") ; extra?
	Sleep(MenuDelay)
	Send("{Esc 3}") ; escape out of settings (sometimes misses one?)
}

; go to min res from max (wraparound), then start AFK money mining mission
; 800x600
^+8::
{
	ResolutionUp(1)
	Goto(Start_AFK_Farming)
}

; go to max res from min (wraparound)
^+0::
{
	ResolutionUp(-1)
}

;armor, verified working in Survival (only)
!a::
{
	SetKeyDelay(50, 30)
	Send("m{Down 2}{Enter}{Down 3}{Enter}{Down 4}{Enter}{Esc 3}")
	setdefaultkeydelay()
}

;armor, might work in other missions/heists (when associate/MC/CEO?)
!+a::
{
	SetKeyDelay(50, 30)
	Send("m{Down 3}{Enter}{Down 3}{Enter}{Down 4}{Enter}{Esc 3}")
	setdefaultkeydelay()
}

; snacks, verified working in Survival (only)
!s::
{
	SetKeyDelay(50, 30)
	Send("`"m{Down 2}{Enter}{Down 4}{Enter}{Down 0}{Enter 2}{Esc 3}`"")
}

;snack, but leave in menu for more
!+s::
{
	SetKeyDelay(50, 30)
	Send("`"m{Down 2}{Enter}{Down 4}{Enter}{Down 0}{Enter 2}`"")
}

; This puts me in a solo session.
; Same as a batch file with:
; pssuspend gta5 && sleep 10 && pssuspend -r gta5
; pssuspend gta5 && timeout -T 10 && pssuspend -r gta5
; Also helps for getting un-stuck when frozen entering Arcade or Casino
*^!NumpadEnd::
*^!End::
{
	;UpdateTitleBar_KeyState()
	global current_keystate := GetAllKeyState() . "Ending session (sleeping 10 seconds...)"
	updateTitleBar()
	Sleep(0) ; try to trigger the update of the title bar; Windows needs a tiny bit of time
	;this was hanging; probably updating the title bar while suspended lead to a deadlock
	Thread("NoTimers")
	Suspend(true) ; prevent hotkeys (Send to the window would cause a deadlock)
	global last_kss := "suspended"
	Critical "On"
	h := process_suspend_milliseconds("GTA5.exe",10000)
	Critical "Off"
	global last_kss := ""
	Suspend(false)
	Thread("NoTimers",false)
	ClearAllKeyState()

	;; this just deadlocked too, apparently
	;~ Run("pssuspend gta5")
	;~ Sleep(11000)
	;~ Run("pssuspend -r gta5")

	; the following worked, but is a bit slow to start
	; RunWait("cmd /c suspend_for_seconds.bat gta5 10")
}

; control shift alt delete to end GTA5
^+!Del::
{
	RunWait("pskill GTA5")
	; this didn't work:
	; el:=WinKill(GTAwindow)
	; ToolTip("WinKill ErrorLevel=" . el)
	;Sleep(5000)
	;ToolTip()
}

Process_Suspend(PID_or_Name){
	PID := (InStr(PID_or_Name, ".")) ? ProcExist(PID_or_Name) : PID_or_Name
	h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", pid)
	If !h
		Return -1
	DllCall("ntdll.dll\NtSuspendProcess", "Int", h)
	DllCall("CloseHandle", "Int", h)
}

Process_Resume(PID_or_Name){
	PID := (InStr(PID_or_Name, ".")) ? ProcExist(PID_or_Name) : PID_or_Name
	h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", pid)
	If !h
		Return -1
	DllCall("ntdll.dll\NtResumeProcess", "Int", h)
	DllCall("CloseHandle", "Int", h)
}

process_suspend_milliseconds(PID_or_Name, ms){
	PID := (InStr(PID_or_Name, ".")) ? ProcExist(PID_or_Name) : PID_or_Name
	h:=DllCall("OpenProcess", "uInt", 0x1F0FFF, "Int", 0, "Int", pid)
	If !h
		Return -1
	DllCall("ntdll.dll\NtSuspendProcess", "Int", h)
	Sleep(ms)
	DllCall("ntdll.dll\NtResumeProcess", "Int", h)
	DllCall("CloseHandle", "Int", h)
}

ProcExist(PID_or_Name:=""){
	ErrorLevel := ProcessExist((PID_or_Name="") ? DllCall("GetCurrentProcessID") : PID_or_Name)
	Return Errorlevel
}

; I don't use these anymore; I only use the fast ones
VolumeUp(n)
{
	global MenuDelay
	ErrorLevel := !KeyWait("Ctrl", "T3")
	ErrorLevel := !KeyWait("Alt", "T3")
	ErrorLevel := !KeyWait("NumpadAdd", "T3")
	Sleep(200)
	Send("{Esc}")
	Sleep(MenuDelay)
	Sleep(MenuDelay)
	Send("{a 4}")
	Sleep(MenuDelay)
	Send("{Enter}")
	Sleep(MenuDelay)
	Send("{s 3}")
	Sleep(MenuDelay)
	Send("{Enter}")
	Sleep(MenuDelay)
	if (n>0) {
		Send("{d " n "}")
	} else {
		n1 := -n
		Send("{a " n1 "}")
	}
	Sleep(MenuDelay)
	Send("s")
	Send("{Enter}")
	Sleep(MenuDelay)
	if (n>0) {
		Send("{d " n "}")
	} else {
		n1 := -n
		Send("{a " n1 "}")
	}
	Sleep(MenuDelay)
	Send("{Esc 6}")
	; Return 0
}


;a&w
!^+a::
{
	Send("{a down}")
	Send("{w down}")
}

;~ ; (slow) Volume up
;~ ^!NumpadAdd::
;~ {
	;~ VolumeUp(3)
;~ }

;~ ; (slow) Volume down
;~ ^!NumpadSub::
;~ {
	;~ VolumeUp(-10)
;~ }

;; cant figure out how to get GetNum to work in v2
;; but SoundSetVolume exists so no need

;; Fast volume control
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; originally in quiet.ahk ;
; There's some "scary" (dangerous) DLLCall stuff here,
; but I (usually) have no problem with it (one day it seemed to be crashing/hanging GTA5?)
; and really like having a quick volume control
; #SingleInstance, force
;make gta5.exe quiet

; global ProcessId
; Process Exist, GTA5.exe
; ProcessId := ErrorLevel

; I use TV remote for finer volume control
; you may want 5 or 10 as an increment
; VolumeIncrement := 20

; #Warn LocalSameAsGlobal,Off

; LCTRL & UP::
;     Volume:=Volume + VolumeIncrement
; 	If (Volume > 100)
; 		Volume := 100
;     Goto setVolume

; LCTRL & DOWN::
;     Volume:=Volume - VolumeIncrement
; 	If (Volume < 0)
; 		Volume := 0
;     Goto setVolume


ShowVolume()
{
	WinSetTitle(GTAtitle "`: V" Volume, GTAwindow)
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

		If (Volume < 0)
			global Volume := 0
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
	ErrorLevel := ProcessExist("GTA5.exe")
	global ProcessId := ErrorLevel
    SetAppVolume(ProcessId, Volume)
    ;;appvol:=GetAppVolume(ProcessId)
	;appvol:=SoundGetVolume()
}


; for v2
SetAppVolume(PID, MasterVolume)    ; WIN_V+
{
	;;SoundSetVolume(MasterVolume) ; this is system/master volume, not app volume
	AppVol("GTA5.exe",MasterVolume) ; thanks to the github gist!
}

TryWinActivate(w)
{
	try {
		win := WinActivate(w)
		return win
	} catch Error as err {
		return 0 ; err.Message
	}
}

^!NumPadAdd::
{
	global
	Ryzen_milliwatts += Ryzen_milliwatt_increment
	update_milliwatts()
}

^!NumPadSub::
{
	global
	Ryzen_milliwatts -= Ryzen_milliwatt_increment
	update_milliwatts()
}

update_milliwatts() {
	SetTimer(set_milliwatts, -500, 0)
	WinSetTitle(GTAtitle "`: adjusting to "  (Ryzen_milliwatts * 0.001) " watts", GTAwindow)
}

set_milliwatts() {
	global
	local cmd
	OutputDebug "A_IsAdmin: " A_IsAdmin "`nCommand line: " full_command_line
	if A_IsAdmin {
		if Ryzen_milliwatts_last_set != Ryzen_milliwatts {
			cmd := "C:/tools/bin/ryzenadj-win64\ryzenadj.exe --slow-limit=" Ryzen_milliwatts " --power-saving"
			WinSetTitle("running: " cmd, GTAwindow)
			Run(cmd)
			Sleep(2000)
			WinSetTitle(cmd, GTAwindow)
			Ryzen_milliwatts_last_set := Ryzen_milliwatts
		}
	} else {
		WinSetTitle("Can't run RyzenAdj; not admin! Reloading macros as admin...", GTAwindow)
		Sleep(2000)
		reload_as_admin()
	}
}

reload_as_admin()
{
	; the RegExMatch was supposed to prevent accidental endless loop,
	; but not needed for my use-case
	if not (A_IsAdmin ) ;;;; or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		try
		{
			if A_IsCompiled {
				Run('*RunAs "' A_ScriptFullPath '" /restart')
			} else {
				Run('*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"')
			}
		}
		catch as e {
			MsgBox(e.Message)
		}
		ExitApp
	}
}


;;;;;;;;;;;;;;;;;;;;;;;;;;; I'm double-NATted so this probably wouldn't do anything anyway
;; might work if administrator; turn on/off blocking of UDP ports 61455-61458
;;^!F7::Run,netsh advfirewall firewall set rule name="GTA5:block-spectator-mode-hackers" new enable=no
;;^!F8::Run,netsh advfirewall firewall set rule name="GTA5:block-spectator-mode-hackers" new enable=yes

;; https://www.irisclasson.com/2015/01/30/creating-a-dynamic-hotkey-window-overlay-with-autohotkey/

; displayOverlay(msg,xpos,ypos){
; 	;GetTextSize(msg,35,"Verdana",theight,twidth)
; 	; msg = %msg%h=%height%,w=%width%
; 	msg := msg . "   "
; 	theight := "40"
; 	twidth := "100"
; 	bgTopPadding := "20"
; 	bgWidthPadding := "50"
; 	bgHeight := theight + bgTopPadding
; 	bgWidth := twidth + bgWidthPadding
; 	padding := "20"
; 	; yPlacement = % A_ScreenHeight - bgHeight - padding
; 	; xPlacement = % A_ScreenWidth - bgWidth - padding
; 	yPlacement := ypos ; + 50
; 	xPlacement := xpos ; + 20
; 	myGui := Gui()
; 	myGui.BackColor := "46bfec"
; 	myGui.MarginX := "20", myGui.MarginY := "20"
; 	; Gui, Add, Picture, x0 y0 w%bgWidth% h%bgHeight%, img\black.png
; 	myGui.Opt("+LastFound +AlwaysOnTop -Border -SysMenu +Owner -Caption +ToolWindow")
; 	myGui.SetFont("s18 cWhite", "Verdana")
; 	myGui.Add("Text", "xm y5 x5", msg)
; 	myGui.Show("x" . xPlacement . " y" . yPlacement)
; 	;WinActivate, AHK_EXE GTA5.EXE
; 	SetTimer(RemoveGui,1000)
; }

; GetTextSize_broken(str, size, font,&height,&width) {
; 	temp := Gui()
; 	temp.Font("s" . size, font)
; 	temp.Add("Text", , str)
; 	; GuiControlGet T, temp:Pos, Static1
; 	; ogcStatic1.GetPos(&TX, &TY, &TW, &TH)

; 	temp.Destroy()
; 	height := TH
; 	width := TW
; }

; RemoveGui()
; {
; 	temp.Destroy()
; 	;WinActivate, AHK_EXE GTA5.EXE
; 	return
; }

;!7::
;	CreateWindow("Win + 7")
;	return

; EDIT NOW!!!
^!E:: {
	win := TryWinActivate("AHK_EXE SCITE.EXE")
	if !win {
		p := RunWait("`"C:\Program Files\AutoHotkey\SciTE\SciTE.exe`" " A_ScriptFullPath)
	}
}

; lucky wheel; these settings arent working yet
^!L:: {
    delay := 2500 ;Edit this value to change the spinning speed: higher value = slower spin
	global last_keystate := "suspended"
	WinSetTitle("Lucky Wheel...e", GTAwindow)
	KeyWait("Ctrl", "T2")
	KeyWait("Alt", "T2")
	KeyWait("l", "T2")
    SetKeyDelay(10,90)
    Send("{e down}")
	sleep(200)
	Send("{e up}")
    Sleep(4800)
	WinSetTitle("Lucky Wheel...enter", GTAwindow)
    Send("{enter down}")
	Sleep(200)
	Send("{enter up}")
	WinSetTitle("Lucky Wheel: Waiting " delay " ms...before s", GTAwindow)
    Sleep(delay)
    WinSetTitle("Lucky Wheel: s(spinning)", GTAwindow)
    Send("{s down}")
    Sleep(55)
    Send("{s up}")
	setdefaultkeydelay()
	WinSetTitle("GTA5: Lucky Wheel completed")
	global last_keystate := ""
}

#HotIf

;;paste
^!v::{
	pasteToChat(A_Clipboard)
}

;~ ; This might work well if you are not in full-screen mode (avoid running in full-screen mode!)
;~ ; https://www.reddit.com/r/software/comments/lt0ai9/is_there_a_alternative_to_chevolume_and_audio/
;~ ^!V::
;~ {
	;~ Run("ms-settings:apps-volume")
;~ }


