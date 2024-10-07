#HotIf WinActive(FORTNITEWINDOW)
NumpadPgdn::fight_cactoro()
Numpad3::fight_cactoro()
#HotIf

fight_cactoro() {
  Loop {
    Loop 3 {
      Send("e")
      Sleep(200) 
    }
    Send("{s down}")
    Sleep(350)
    Send("{s up}")
    Loop 10 {
      Send("e")
      Sleep(200) 
    }
    Sleep(999)
    ; findtext_JOIN()
    ; findtext_START()
    Loop 4 {
      FindText().Click(1472, 253, "L")
      Sleep(500)
    }
    
    findtext_00_wait()

    ; Sleep(500)
    Loop 5 {
      Send("1")  ; rifle
      Sleep(200) 
    }
    if A_Index < 2 {
      Send("{Space down}") ; jump to stop crouching
      Sleep(500)
      Send("{Space up}") ; jump to stop crouching
      Sleep(500)
    }
    ;todo: switch_to_rifle() ; not always 1??
    loop 5 {
      Click()
      Sleep(100)
    }
    Send("{w down}")
    loop 20 {
      Click()
      Sleep(100)
    }
    Sleep(2200)
    Send("{w up}")
    ; Send("e")
    Loop 15 {
      Send("e")
      Sleep(500) 
    }
  }
}

findtext_JOIN() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<JOIN>*31$24.wAAlwzAtAnAtAnAhAnAbAnAbwzAnkAAnU"
  xtra:=100
  if (ok:=FindText(&X, &Y, 1472-xtra, 253-xtra, 1472+xtra, 253+xtra, 0, 0, Text))
  {
    FindText().Click(X, Y, "L")
  }
  ;  FindText().Click(1472, 253, "L")
}

findtext_START() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<START>*31$34.8z77XzPwwTjw33FaAsA96MkMlaT30X7tYAqANaMkkl3NX8"
  xtra:=100
  if (ok:=FindText(&X, &Y, 1473-xtra, 253-xtra, 1473+xtra, 253+xtra, 0, 0, Text))
  {
    FindText().Click(X, Y, "L")
  }
}

findtext_00_wait() {
  t1:=A_TickCount, Text:=X:=Y:=""
  Text:="|<00>*244$12.fpRiRiRiPhXlU"
  xtra:=50
  X:="wait0"
  Y:=15.0
  ok:=FindText(&X, &Y, 1410-xtra, 219-xtra, 1410+xtra, 219+xtra, 0.03, 0.03, Text)
  return ok
}