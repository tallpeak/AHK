; Miner Odyssey
; for mob rooms

#HotIf WinActive(FORTNITEWINDOW)
^Enter::start_firing()
SC019 & Enter::start_firing()
#HotIf

; SC019 & m::autolevel()
; ^+m::autolevel()
NumpadDiv & NumpadMult::autolevel()

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
		Sleep(50) 
		PostMessage(WM_KEYUP,firekey,0,,FORTNITEWINDOW)
		Sleep(50) 
	}
}

findtext_ActivateDrill() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<ACTIVATE_DRILL>*15$64.MPmGAwsMQYFWG98kW19+F+88YZ2C4Yd4YUWIG8UGQYHmG8lsW19+F968X4WC74drU"
  xtra:=50
  X:="wait"
  Y:=2.0
  if (ok:=FindText(&X, &Y, 1131-xtra, 309-xtra, 1131+xtra, 309+xtra, 0.05, 0.05, Text))
  {
      Sleep(300)
      FindText().Click(X, Y, "L")
      Sleep(200)
  } else {
    FindText().ToolTip("Drill not found")
  }
}

drill() {
  Sleep(400)
  switchToRemote() 

  ; Sleep(400)
  ; Send("RButton")
  ; Click("Right")

  Sleep(1200)
  Loop 2 {
    Click("Right") 
    Sleep(150)
  }

  Sleep(400)
  findtext_ActivateDrill()
}

autolevel() {
  seconds := 900
  Loop {      
    MoveWindowToUpperRight()
    Sleep(777)
    ;this one usually doesnt work (except for the first time)
    ; cnteff:=find_and_click_upgrades(x1:=1385,1) ; efficiency
    ; Sleep(1000)
    ; cntup:=find_and_click_upgrades(x1:=1275,5) ; strength
    ; Sleep(1000)
    ; cnteff+=find_and_click_upgrades(x1:=1385,3) ; efficiency
    ; Sleep(1000)
    drill()
    cnt:=find_and_click_upgrades()
    click_X()
    Sleep(1000)
    clicker_unfocused(false,seconds)
    if !cnt {
      seconds += 5
    }
  }
}

click_area_if_green(x1,y1,x2,y2,max:=10) {
  ; color := "80E381-303030"
  ; greens := FindText().PixelCount(1290,96,1365, 110, color,33)
  color := "80E381-202020"
  loop max {
    Sleep(55)
    greens := FindText().PixelCount(x1,y1,x2,y2,color,11)
    if greens > 10 {
      Loop 5 {
        Sleep(100)
        FindText().Click(x1+50,y1+5)
      }
    } else break
  }
}

click_X() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<X>*22$6.nnGSSGnnU"
  xtra:=50
  X:="wait"
  Y:=2.0
  ; Sleep(500)
  if (ok:=FindText(&X, &Y, 1468-xtra, 46-xtra, 1468+xtra, 46+xtra, 0, 0, Text))
  {
     Sleep(50)
     FindText().Click(X, Y, "L")
     Sleep(2000)
  } else {
    FindText().ToolTip("X not found")
  }
  Sleep(1000)
  FindText().ToolTip()
}

find_and_click_upgrades(maxcount:=2)
{
  KeyWait("NumpadDiv")
  KeyWait("Ctrl")
  KeyWait("Alt")
  Sleep(666)
  ActivateFortniteWindow()
  switchToRemote() 
  Sleep(1200)
  Loop 2 {
    Click() 
    Sleep(150)
  }

  count_found := 0
  count_found += FindAndClick_0_0() 
  count_found += FindAndClick_MAX_LEVEL()
  count_found += FindAndClick_GreenMAX() 
  count_found += FindAndClick_0_0() 
    
  if count_found > 0 and Random(0,5) {
    return
  }
  ; bottom to top:
  for y1 in [266,226,180,139,96] {
    Loop maxcount {
      for x1 in [1385,1275,1385] {
        Sleep(555)
        y2:=y1+14
        x2:=x1+100
        click_area_if_green(x1,y1,x2,y2,max:=10)
      }
    }
  }
  return count_found
}

; ^+m::autolevel()
; autolevel_old_neverused_Deadcode() {
;   KeyWait("m")
;   KeyWait("Ctrl")
;   KeyWait("Shift")
;   seconds := 10
;   Loop {
;     clicker_unfocused(seconds)
;     Sleep(1111)
;     MoveWindowToUpperRight()
;     eff := find_and_click_upgrades(1385,10) ; efficiency2
;     Sleep(1111)
;     str := find_and_click_upgrades(1275,25) ; strength
;     if !eff and !str {
;       seconds += 5
;     }
;     if eff + str > 10 {
;       seconds -= 5
;     }
;   }
; }

FindAndClick_GreenMAX() {
  cnt := 0
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<MAX>80E381-101010$24.MkcoIEcIJN8QJN8QHNwoEN4aU"
  if (ok:=FindText(&X, &Y, 1349-99, 1, 1349+99, 1500, 0.05, 0.05, Text))
  {
    cnt += 1  
    FindText().Click(X,Y, "L")
    FindText().Click(X,Y, "L")
    Loop 3 {
      Sleep(50)
      FindText().Click(X+100, Y, "L")
    }
  }
  return cnt
}

FindAndClick_0_0() {
  cnt := 0
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<0_0>*240$69.tTzzzzzzzzwjRzzzzzzzzzivjzzzzzzzzxrRzzzzzzzzzivTzzzzzzzzxjXzzzzzzzzzlU"
  if (ok:=FindText(&X, &Y, 1134-100, 1, 1134+100, 1500, 0.05, 0.05, Text))
  {
    cnt += 1  
    Loop 10 {
      Sleep(100)
      FindText().Click(X+210,Y, "L")
    }
    Loop 5 {
      Sleep(100)
      FindText().Click(X+310, Y, "L")
    }
  }
  return 0
}

FindAndClick_MAX_LEVEL() {
  cnt := 0
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<MAX_LEVEL>*200$54.CCCnvkqEr6CCHvrqLrLAj7vrqrrJBj7vkqkrFAb7vrmrrNA6HtrsrnTBqnsEskkU"
  xtra:=50
  if (ok:=FindText(&X, &Y, 1331-xtra, 189-xtra, 1331+xtra, 189+xtra, 0.05, 0.05, Text))
  {
    cnt += 1  
    Loop 5 {
      Sleep(100)
      FindText().Click(X+100, Y, "L")
    }
  }
  return 0
}
