; Miner Odyssey
; for mob rooms
start_firing() {
	global WM_KEYDOWN
	global firekey
	global FORTNITEWINDOW
	KeyWait("Ctrl")
	KeyWait("Enter")
	Send("{Enter Down}")
	maybe_unfocus()
	Loop {
		PostMessage(WM_KEYDOWN,firekey,0,,FORTNITEWINDOW)
		Sleep(100) 
		PostMessage(WM_KEYUP,firekey,0,,FORTNITEWINDOW)
		Sleep(100) 
	}
}

^+NumpadDiv::{
  seconds := 11
  Loop {      
    Sleep(1000)
    cnteff:=find_and_click_upgrades(x1:=1385,10) ; efficiency
    Sleep(200)
    cntup:=find_and_click_upgrades(x1:=1275,25) ; strength
    Sleep(1000)
    click_X()
    Sleep(1000)
    clicker_unfocused(false,seconds)
    if !cntup and !cnteff {
      seconds += 1
    }
  }
}


click_area_if_green(x1,y1,x2,y2,max:=10) {
  ; color := "80E381-303030"
  ; greens := FindText().PixelCount(1290,96,1365, 110, color,33)
  color := "80E381-303030"
  loop max {
    greens := FindText().PixelCount(x1,y1,x2,y2,color,33)
    if greens > 33 {
      FindText().Click(x1+50,y1+5)
    } else break
  }
}

click_X() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<X>*22$6.nnGSSGnnU"
  xtra:=50
  Sleep(500)
  if (ok:=FindText(&X, &Y, 1468-xtra, 46-xtra, 1468+xtra, 46+xtra, 0, 0, Text))
  {
     Sleep(500)
     FindText().Click(X, Y, "L")
     Sleep(2500)
  } else {
    FindText().ToolTip("X not found")
  }
  Sleep(1000)
  FindText().ToolTip()
}

find_and_click_upgrades(x1,maxcount:=10)
{
  KeyWait("NumpadDiv")
  KeyWait("Ctrl")
  KeyWait("Alt")
  Sleep(300)
  switchToRemote() 
  Sleep(500)
  Click() 
  Sleep(1500)
  count_found := 0
  ; bottom to top:
  for y1 in [266,226,180,139,96] {
    y2:=y1+14
    x2:=x1+100
    click_area_if_green(x1,y1,x2,y2,max:=10)
  }
  return count_found
}

^+m::autolevel()
autolevel() {
  KeyWait("m")
  KeyWait("Ctrl")
  KeyWait("Shift")
  seconds := 10
  Loop {
    clicker_unfocused(seconds)
    eff := find_and_click_upgrades(1275,5) ; eff
    str := find_and_click_upgrades(1385,25) ; str
    if !eff and !str {
      seconds += 5
    }
    if eff + str > 10 {
      seconds -= 5
    }
  }
}

