#Requires AutoHotkey v2.0
; from v1.3.1 of GTA V Online AHK-Macros; see below
#SingleInstance force
;#MaxThreadsPerHotkey 2 ; no thanks; this was causing my hotkeys to run twice

SendMode("Event") ; default, and only working method

;
; GTA V Online AHK-Macros v1.3.0 by 2called-chaos
; based on/inspired by GTA V Useful Macros v4.21 by twentyafterfour
;
; # Description
;
; Provides hotkeys for opening snack menu, equipping armor, entering passive mode and much more.
;
;
; # General Notes
;
;   * Read the god damn readme, please! https://github.com/2called-chaos/gtav-online-ahk/blob/master/README.md
;   * After cutscenes or just from time to time the interaction menu lags
;     and the macro won't work. Periodically, especially after loading/cutscenes
;     press m and backspace (aka open the menu once)
;   * If you add something consider committing a pull request so we can all enjoy (VIP stuff for example)
;
;
; # Hotkeys / Binding:
;
; To change a hotkey for a macro change the configuration section at the top of the file
; or even better copy the line to your config.ahk (see Readme) and change it there.
; A list of keynames for the non-alphanumeric can be found in the autohotkey help under
; the heading "Basic Usage and Syntax" with the name "Key List".
; They can also be found at https://www.autohotkey.com/docs/KeyList.htm
;
;
; # FAQ, Docs, Source, Bugs, etc.
;
; Read the wiki, propose features, fix and/or report bugs... it's all yours at
;
;     https://github.com/2called-chaos/gtav-online-ahk
;

; ==============================
; === CONFIGURATION GOES vvv ===
; ==============================

; Bindings (bind the desired functions to a key of your choice)
;   https://www.autohotkey.com/docs/KeyList.htm
; WARNING: If you don't want to use a certain binding use "F24"
;          or any other valid key or it will break!
; Consider using a config.ahk!
SnackMenuKey         := "+#" ; Open Snack menu (+ = shift, rtfm).
AutoHealthKey        := "#" ; Automatic snacking. Eats 2 snacks from second snack slot.
ArmorMenuKey         := "+F1" ; Open Armor menu.
AutoArmorKey         := "F1" ; Automatic armor equip (uses super heavy armor only).
RetrieveCarKey       := "F2" ; Request currently active Personal Vehicle.
ToggleRadarKey       := "+F2" ; Toggle between extended and standar radar.
CEOBuzzardKey        := "F3" ; Spawn free CEO buzzard
RequestSparrowKey    := "+F3" ; Call in your Sparrow (or whatever you last requested moon pool vehicle was)
ReturnSparrowKey     := "^F3" ; Return your Sparrow to the Kosatka
ForceDisconnectKey   := "F12" ; Force disconnect by suspending process for 10s, requires pssuspend.exe
KillGameKey          := "+F12" ; Kill game process, requires pskill.exe
ToggleVIPKey         := "NumpadMult" ; Toggle VIP mode (required when VIP/CEO/MC).  Won't have effect if using ManualInventoryLocation option.
ToggleCPHKey         := "^NumpadMult" ; Toggle Cayo Perico Heist Final mode (extra menu entry), also see DoToggleCPHWithVIP.  Won't have effect if using ManualInventoryLocation option.
ToggleAFKKey         := "+NumpadMult" ; Toggle AFK mode

TogglePassiveKey     := "F24" ; Toggle passive mode.
ToggleClickerKey     := "F24" ; Toggle Clicker (XButton2 = Mouse5)
ToggleAutoHeliKey    := "F24" ; Keeps throttle and pitch forward pressed, First take heli to sufficient height and then use this as autopilot
ChatSnippetsKey      := "F24" ; Gives you a few text snippets to put in chat (chat must be already open)
CycleOutfitKey       := "F24" ; Equip next/cycle through saved outfits.
RandomHeistKey       := "F24" ; Chooses on-call random heist from phone options
EquipScarfKey        := "F24" ; Equip first scarf (heist outfit glitch, see readme/misc).

DialDialogKey        := "+F5" ; Call GUI with a list of almost all numbers
CallMechanicKey      := "^F5" ; Call Mechanic
CallPegasusKey       := "F24" ; Call Pegasus
CallMerryweatherKey  := "F24" ; Call Merryweather
CallInsuranceKey     := "F6" ; Call Insurance
CallLesterKey        := "+F6" ; Call Lester
CallAssistantKey     := "^F6" ; Call Assistant

CheckForUpdatesKey   := "F24" ; Checks on startup by default, see DoCheckForUpdates option


; ManualInventoryLocation (manual inventory line calibration)
ManualInventoryLocation := false        ; if true, use manual calibration of the inventory line in the interactive menu. IsCPHActive and IsVIPActive flags will be ignored.
InvLocation             := 4            ; by default, this is the location of the inventory in the menu
AutoSnackLocation       := 2            ; by default, this is the snack autosnack will select
; these keys will not be bound if ManualInventoryLocation is false
IncInvKey               := "NumpadAdd"  ; for increasing the value of the inventory line
DecInvKey               := "NumpadSub"  ; for decreasing the value of the inventory line
IncSnackKey             := "^NumpadAdd" ; for increasing the line for the snack selected by autosnacking
DecSnackKey             := "^NumpadSub" ; for decreasing the line for the snack selected by autosnacking


; Options (should be fine out of the box)
WindowScale          := 1.0       ; Change this to reflect your Windows display scale (e.g. set it to 3 if you have UI scale set to 300%)
DoConfirmKill        := true      ; If true the KillGame action will ask for confirmation before killing the process
DoConfirmDisconnect  := true      ; If true the ForceDisconnect action will ask for confirmation before suspending the process
IntDisconnectDelay   := 10        ; Amount of seconds to freeze the process for, 10 works fine
DoToggleCPHWithVIP   := false     ; If true ToggleVIP will become a 3-way toggle (off/on/CayoPericoHeistFinal)
DisableCapsOnAction  := true      ; Disable caps lock before executing macros, some macros might fail if caps lock is on
DoCheckForUpdates    := true      ; Check for script updates on startup (you can manually bind this instead or additionally)


; Internal variables (probably no need to edit)
IsVIPActivated       := false ; Initial status of CEO/VIP mode (after (re)loading script)
IsAFKActivated       := false ; Initial status of AFK mode (should always be false)
IsCPHActivated       := false ; Initial status of CPH mode (should always be false)
IsClickerActivated   := false ; Initial status of Clicker (should always be false)

; Delays (you normally don't want to change these, you can try to play with these values if you have a slow/fast PC)
IntFocusDelay        := 100  ; delay (in ms) after focussing game when AHK-GUI took focus.
IntMenuDelay         := 120  ; delay (in ms) after opening interaction menu.
IntPhoneMenuDelay    := 1850 ; delay (in ms) after opening phone menu.
IntPhoneMenuDelay2   := 250  ; delay (in ms) after selecting phone menu entries.
IntPhoneScrollDelay  := 75   ; delay (in ms) between scrolls in the phone menu.
IntKeySendDelay      := 5   ; delay (in ms) delay between send key commands.
IntKeyPressDuration  := 55    ; duration (in ms) each key press is held down.


; In case you changed your ingame bindings:
global IGB_Interaction := "m"
global IGB_Phone := "up"
global IGB_PhoneSpecial := "space"
global IGB_Pause := "p"
; the following refer to your phone binding and also apply to the interaction menu
global IGB_Up := "up"
global IGB_Down := "down"
global IGB_Left := "left"
global IGB_Right := "right"
global IGB_Enter := "enter"
; the following refer to movement (used for AFK)
global IGB_MoveLeft := "a"
global IGB_MoveRight := "d"
; aircraft/helicopter
global IGB_ThrottleUp := "w"
global IGB_PitchForward := "Numpad8"


; Phone numbers for DialDialog GUI dialog (you can change the order if you want or hide entries by commenting them out)
ArrayPhonebook := []
ArrayPhonebook.push("911           - Emergency Services")
ArrayPhonebook.push("346-555-0137  - Assistant")
ArrayPhonebook.push("328-555-0153  - Mechanic")
ArrayPhonebook.push("611-555-0149  - Mors Mutual Insurance")
ArrayPhonebook.push("328-555-0122  - Pegasus Lifestyle Management")
ArrayPhonebook.push("273-555-0120  - Merryweather Security")
ArrayPhonebook.push("346-555-0176  - Atomic Blimp")
ArrayPhonebook.push("323-555-5555  - Downtown Cab Co.")
ArrayPhonebook.push("346-555-0102  - Lester Crest")
ArrayPhonebook.push("273-555-0172  - Captain (Yacht)")
ArrayPhonebook.push("273-555-0185  - Brucie (Bull Shark Testosterone)")
ArrayPhonebook.push("346-555-0141  - Lamar (Mugger/Mission)")
ArrayPhonebook.push("346-555-0188  - Martin Madrazo (Job)")
ArrayPhonebook.push("328-555-0198  - Ron (Job)")
ArrayPhonebook.push("611-555-0120  - Simeon (Job)")
ArrayPhonebook.push("611-555-0152  - Gerald (Job)")
ArrayPhonebook.push("020-755-0152  - Agent 14 (?)")
ArrayPhonebook.push("273-555-0193  - Benny (broken?)")
ArrayPhonebook.push("611-555-0192  - Paige (?)")
ArrayPhonebook.push("273-555-0180  - Bryony (?)")
ArrayPhonebook.push("346-555-0196  - Wendy (?)")

; Hookers
ArrayPhonebook.push("611-555-0163  - Chastity (Prostitute)")
ArrayPhonebook.push("328-555-0167  - Cheetah (Prostitute")
ArrayPhonebook.push("346-555-0186  - Fufu (Prostitute)")
ArrayPhonebook.push("611-555-0184  - Infernus (Prostitute)")
ArrayPhonebook.push("346-555-0183  - Nikki (Prostitute)")
ArrayPhonebook.push("273-555-0189  - Peach (Prostitute)")
ArrayPhonebook.push("328-555-0177  - Sapphire (Prostitute)")

; Random stuff
;ArrayPhonebook.push("555-0182      - (useless) *modem* ")
;ArrayPhonebook.push("1-999-9327667 - (useless) *holding music* ")
;ArrayPhonebook.push("425-555-0170  - (useless) 'This mailbox is full' ")
;ArrayPhonebook.push("310-555-0156  - (useless) *Pickup* .. *Hangup*")
;ArrayPhonebook.push("1-999-768822  - (useless) 'This number is no longer in service'")
;ArrayPhonebook.push("273-555-0155  - (useless) Truthseeker Helpline")


; ================================================
; === Are you sure you want to scroll further? ===
; ================================================


; REMOVED: #NoEnv
SetWorkingDir(A_ScriptDir)

; Disables hotkeys when alt-tabbed or GTA is closed.
;;;#HotIf WinActive("ahk_class grcWindow")

;~ ; Hotkey/Function mapping

;~ Hotkey(DialDialogKey, DialDialog)
;~ Hotkey(CallMechanicKey, CallMechanic)
;~ Hotkey(CallPegasusKey, CallPegasus)
;~ Hotkey(CallMerryweatherKey, CallMerryweather)
;~ Hotkey(CallInsuranceKey, CallInsurance)
;~ Hotkey(CallLesterKey, CallLester)
;~ Hotkey(CallAssistantKey, CallAssistant)


openPhone() {
  global IntPhoneMenuDelay

  ; Opens Phone Menu
  turnCapslockOff()
  Send("{" IGB_Phone "}")

  ; Necessary delay to allow phone menu to open properly (which it often doesn't anyways)
  Sleep(IntPhoneMenuDelay)
}

scrollPhoneUp(by := 1) {
  global IntPhoneScrollDelay
  Loop by {
    MouseClick("WheelUp", , , 20, 0, "D", "R")
    Sleep(IntPhoneScrollDelay)
  }
}

turnCapslockOff() {
  global DisableCapsOnAction
  if (!DisableCapsOnAction) {
    return
  }
  if (GetKeyState("CapsLock", "T") = 1) {
    SetCapsLockState("off")
  }
}

makeCall(scrollUp, doOpenPhone := false, menu := 2) {
  global IntPhoneMenuDelay2
  global IntKeySendDelay
  SetKeyDelay(IntKeySendDelay, IntKeyPressDuration)
  turnCapslockOff()
  if(doOpenPhone) {
    openPhone()
  }
  Sleep(200)
  ; go to contacts
  scrollPhoneUp(menu)
  Sleep(IntKeySendDelay)
  Send("{" IGB_Enter "}")
  Sleep(IntPhoneMenuDelay2)

  ; scroll to contact
  scrollPhoneUp(scrollUp)

  ; call it
  Send("{" IGB_Enter "}")
}

dialNumber(number, doOpenPhone := false) {

  SetKeyDelay(IntKeySendDelay, IntKeyPressDuration)

  global IntKeySendDelay
  global IntKeyPressDuration
  global IntPhoneScrollDelay
  global IntPhoneMenuDelay2

  ; turnCapslockOff()


  if (doOpenPhone) {
    openPhone()
  }
  Sleep(200)

  ; go to contacts
  scrollPhoneUp(2)
  Send("{" IGB_Enter "}")
  Sleep(IntPhoneMenuDelay2)

  ; enter number screen
  Send("{" IGB_PhoneSpecial "}")
  Sleep(IntPhoneMenuDelay2)

  ; change key delay for this function
  SetKeyDelay(IntPhoneScrollDelay, IntKeyPressDuration)

  ; cleanup number
  number_clean := RegExReplace(number, "[^0-9]", "")

  ; enter the actual number
  pointer := 1
  Loop Parse, number_clean
  {
    deltax := _phonePointerCol(A_LoopField) - _phonePointerCol(pointer)
    deltay := _phonePointerRow(A_LoopField) - _phonePointerRow(pointer)

    ; wrap around shortcuts
    if (deltax = 2)
      deltax := -1
    if (deltax = -2)
      deltax := 1
    if (deltay = -3)
      deltay := 1
    if (deltay = 3)
      deltay := -1

    ; move pointer
    if (deltax > 0)
      Send("{" IGB_Right " " deltax "}")

    if (deltay > 0)
      Send("{" IGB_Down " " deltay "}")

    if (deltax < 0) {
      deltax := Abs(deltax)
      Send("{" IGB_Left " " deltax "}")
    }

    if (deltay < 0) {
      deltay := Abs(deltay)
      Send("{" IGB_Up " " deltay "}")
    }

    pointer := A_LoopField
    Send("{" IGB_Enter "}")
  }

  ; reset key delay (should not be necessary)
  SetKeyDelay(IntKeySendDelay, IntKeyPressDuration)

  ; call it
  Send("{" IGB_PhoneSpecial "}")
}

_phonePointerRow(num) {
  if (num = 0) {
    return 4
  } else {
    return Ceil(num / 3)
  }
}

_phonePointerCol(num) {
  if (num = 0) {
    return 2
  }
  else {
    div := Mod(num, 3)
    return div = 0 ? 3 : div
  }
}

; note, maybe switch to ahk_class
bringGameIntoFocus(something := true) {
  WinActivate("ahk_class grcWindow")
}

DIAL := ""

DialDialog(ThisHotkey)
{
  global DIAL
  pbl := ""
  For each, item in ArrayPhonebook {
    pbl .= (!pbl ? "" : "|") item
  }
  DIAL := Gui()
  DIAL.OnEvent("Close", DIALGuiClose)
DIAL.OnEvent("Escape", DIALGuiEscape)
DIAL.add("Text", , "double click item")
  DIAL.SetFont(, "Courier New")
  ogcListBoxPhoneNumberSelect := DIAL.add("ListBox", "w500 h250 vPhoneNumberSelect", [pbl])
  ogcListBoxPhoneNumberSelect.OnEvent("DoubleClick", _DialDialogMakeCallFromSelect.Bind("DoubleClick"))
  DIAL.SetFont(, "Arial")
  DIAL.add("Text", , "or type number:")
  ogcEditPhoneNumber := DIAL.add("Edit", "w500 vPhoneNumber")
  ogcButtonmakecall := DIAL.add("Button", "w500 Default", "make call...")
  ogcButtonmakecall.OnEvent("Click", _DialDialogMakeCall.Bind("Normal"))
  DIAL.show()
}

DIALGuiEscape(*)
{
  global DIAL
  DIAL.cancel()
  DIAL.destroy()
  bringGameIntoFocus()
}

DIALGuiClose(*)
{
  DIAL.cancel()
  DIAL.destroy()
  bringGameIntoFocus()
}

_DialDialogMakeCallFromSelect(A_GuiEvent, GuiCtrlObj, Info, *)
{
  if(A_GuiEvent = "DoubleClick") {
    Goto(_DialDialogMakeCall)
  }
}

_DialDialogMakeCall(A_GuiEvent, GuiCtrlObj, Info, *)
{
  oSaved := DIAL.submit()
  PhoneNumberSelect := oSaved.PhoneNumberSelect
  PhoneNumber := oSaved.PhoneNumber
  bringGameIntoFocus(true)
  if (PhoneNumber) {
    dialNumber(PhoneNumber, true)
  } else if (PhoneNumberSelect) {
    dialNumber(PhoneNumberSelect, true)
  }
  DIAL.destroy()
}

CallPegasus(ThisHotkey)
{
  dialNumber("328-555-0122", true)
}

CallMerryweather(ThisHotkey)
{
  dialNumber("273-555-0120", true)
}

CallInsurance(ThisHotkey)
{
  dialNumber("611-555-0149", true)
}

CallLester(ThisHotkey)
{
  dialNumber("346-555-0102", true)
}

CallAssistant(ThisHotkey)
{
  dialNumber("346-555-0137", true)
}

CallMechanic(ThisHotkey) {
	dialNumber("328-555-0153", true)
}

CallMechanicKey := "^m"

Hotkey(CallMechanicKey, CallMechanic)

CallMorsKey := "^+m"

CallMors(ThisHotkey) {
	dialNumber("611-555-0149", true)
}

Hotkey(CallMorsKey, CallMors)
