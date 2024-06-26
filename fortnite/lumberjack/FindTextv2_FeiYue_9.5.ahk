;/*
;===========================================
;  FindText - Capture screen image into text and then find it
;  https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116471
;
;  Author  : FeiYue
;  Version : 9.5
;  Date    : 2024-04-27
;
;  Usage:  (required AHK v2.02)
;  1. Capture the image to text string.
;  2. Test find the text string on full Screen.
;  3. When test is successful, you may copy the code
;     and paste it into your own script.
;     Note: Copy the "FindText()" function and the following
;     functions and paste it into your own script Just once.
;  4. The more recommended way is to save the script as
;     "FindText.ahk" and copy it to the "Lib" subdirectory
;     of AHK program, instead of copying the "FindText()"
;     function and the following functions, add a line to
;     the beginning of your script: #Include <FindText>
;  5. If you want to call a method in the "FindTextClass" class,
;     use the parameterless FindText() to get the default object
;
;===========================================
;*/


if (!A_IsCompiled && A_LineFile=A_ScriptFullPath)
  FindText().Gui("Show")


;===== Copy The Following Functions To Your Own Code Just once =====


FindText(args*)
{
  static obj:=FindTextClass()
  return !args.Length ? obj : obj.FindText(args*)
}

Class FindTextClass
{  ;// Class Begin

Floor(i) => IsNumber(i) ? i+0 : 0

__New()
{
  this.bits:={ Scan0: 0, hBM: 0, oldzw: 0, oldzh: 0 }
  this.bind:={ id: 0, mode: 0, oldStyle: 0 }
  this.Lib:=Map()
  this.Cursor:=0
}

__Delete()
{
  if (this.bits.hBM)
    DllCall("DeleteObject", "Ptr",this.bits.hBM)
}

New()
{
  return FindTextClass()
}

help()
{
return "
(
;--------------------------------
;  FindText - Capture screen image into text and then find it
;  Version : 9.5  (2024-04-27)
;--------------------------------
;  returnArray:=FindText(
;      &OutputX --> The name of the variable used to store the returned X coordinate
;    , &OutputY --> The name of the variable used to store the returned Y coordinate
;    , X1 --> the search scope's upper left corner X coordinates
;    , Y1 --> the search scope's upper left corner Y coordinates
;    , X2 --> the search scope's lower right corner X coordinates
;    , Y2 --> the search scope's lower right corner Y coordinates
;    , err1 --> Fault tolerance percentage of text       (0.1=10%)
;    , err0 --> Fault tolerance percentage of background (0.1=10%)
;    , Text --> can be a lot of text parsed into images, separated by '|'
;    , ScreenShot --> if the value is 0, the last screenshot will be used
;    , FindAll --> if the value is 0, Just find one result and return
;    , JoinText --> if you want to combine find, it can be 1, or an array of words to find
;    , offsetX --> Set the max text offset (X) for combination lookup
;    , offsetY --> Set the max text offset (Y) for combination lookup
;    , dir --> Nine directions for searching: up, down, left, right and center
;    , zoomW --> Zoom percentage of image width  (1.0=100%)
;    , zoomH --> Zoom percentage of image height (1.0=100%)
;  )
;
;  The function returns an Array containing all lookup results,
;  any result is a object with the following values:
;  {1:X, 2:Y, 3:W, 4:H, x:X+W//2, y:Y+H//2, id:Comment}
;  If no image is found, the function returns 0.
;  All coordinates are relative to Screen, colors are in RGB format
;
;  If the return variable is set to 'ok', ok[1] is the first result found.
;  ok[1].1, ok[1].2 is the X, Y coordinate of the upper left corner of the found image,
;  ok[1].3 is the width of the found image, and ok[1].4 is the height of the found image,
;  ok[1].x <==> ok[1].1+ok[1].3//2 ( is the Center X coordinate of the found image ),
;  ok[1].y <==> ok[1].2+ok[1].4//2 ( is the Center Y coordinate of the found image ),
;  ok[1].id is the comment text, which is included in the <> of its parameter.
;
;  If OutputX is equal to 'wait' or 'wait1'(appear), or 'wait0'(disappear)
;  it means using a loop to wait for the image to appear or disappear.
;  the OutputY is the wait time in seconds, time less than 0 means infinite waiting
;  Timeout means failure, return 0, and return other values means success
;  If you want to appear and the image is found, return the found array object
;  If you want to disappear and the image cannot be found, return 1
;  Example 1: FindText(&X:='wait', &Y:=3, 0,0,0,0,0,0,Text)   ; Wait 3 seconds for appear
;  Example 2: FindText(&X:='wait0', &Y:=-1, 0,0,0,0,0,0,Text) ; Wait indefinitely for disappear
;
;  <FindMultiColor> <FindColor> : FindColor is FindMultiColor with only one point
;  Text:='|<>##DRDGDB $ 0/0/RRGGBB1-DRDGDB1/RRGGBB2, xn/yn/-RRGGBB3/RRGGBB4, ...'
;  Color behind '##' (0xDRDGDB) is the default allowed variation for all colors
;  Initial point (0,0) match 0xRRGGBB1(+/-0xDRDGDB1) or 0xRRGGBB2(+/-0xDRDGDB),
;  point (xn,yn) match not 0xRRGGBB3(+/-0xDRDGDB) and not 0xRRGGBB4(+/-0xDRDGDB)
;  Starting with '-' after a point coordinate means excluding all subsequent colors
;  Each point can take up to 10 sets of colors (xn/yn/RRGGBB1/.../RRGGBB10)
;
;  <FindPic> : Text parameter require manual input
;  Text:='|<>##DRDGDB-RRGGBB1-RRGGBB2... $ d:\a.bmp'
;  the 0xRRGGBB1(+/-0xDRDGDB)... all as transparent color
;
;--------------------------------
)"
}

FindText(OutputX:="", OutputY:=""
  , x1:=0, y1:=0, x2:=0, y2:=0, err1:=0, err0:=0, text:=""
  , ScreenShot:=1, FindAll:=1, JoinText:=0, offsetX:=20, offsetY:=10
  , dir:=1, zoomW:=1, zoomH:=1)
{
  wait:=(OutputX is VarRef) && IsSetRef(OutputX) ? %OutputX% : OutputX
  if !IsObject(wait) && (wait ~= "i)^\s*wait[10]?\s*$")
  {
    time:=(OutputY is VarRef) && IsSetRef(OutputY) ? %OutputY% : OutputY
    found:=!InStr(wait,"0"), time:=this.Floor(time)
    , timeout:=A_TickCount+Round(time*1000)
    Loop
    {
      ok:=this.FindText(,, x1, y1, x2, y2, err1, err0, text, ScreenShot
        , FindAll, JoinText, offsetX, offsetY, dir, zoomW, zoomH)
      if (found && ok)
      {
        (OutputX is VarRef) && (%OutputX%:=ok[1].x)
        , (OutputY is VarRef) && (%OutputY%:=ok[1].y)
        return ok
      }
      if (!found && !ok)
        return 1
      if (time>=0 && A_TickCount>=timeout)
        Break
      Sleep 50
    }
    return 0
  }
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(&x,&y,&w,&h,ScreenShot,&zx,&zy), x-=zx, y-=zy
  , this.ok:=0, info:=[]
  Loop Parse, text, "|"
    if IsObject(j:=this.PicInfo(A_LoopField))
      info.Push(j)
  if (w<1 || h<1 || !(num:=info.Length) || !bits.Scan0)
  {
    return 0
  }
  arr:=[], info2:=Map(), info2.Default:=[], k:=0, s:=""
  , mode:=(IsObject(JoinText) ? 2 : JoinText ? 1 : 0)
  For i,j in info
  {
    k:=Max(k, (j[7]=5 && j[8]=0 ? j[9] : j[2]*j[3]))
    if (mode)
      v:=(mode=2 ? j[10] : i) . "", s.="|" v
      , (!info2.Has(v) && info2[v]:=[]), (v!="" && info2[v].Push(j))
  }
  sx:=x, sy:=y, sw:=w, sh:=h
  , JoinText:=(mode=1 ? [s] : JoinText)
  , s1:=Buffer(k*4), s0:=Buffer(k*4)
  , ss:=Buffer(sw*(sh+2))
  , allpos_max:=(FindAll || JoinText ? 10240 : 1)
  , ini:={ sx:sx, sy:sy, sw:sw, sh:sh, zx:zx, zy:zy
  , mode:mode, bits:bits, ss:ss.Ptr, s1:s1.Ptr, s0:s0.Ptr
  , err1:err1, err0:err0, allpos_max:allpos_max
  , zoomW:zoomW, zoomH:zoomH }
  Loop 2
  {
    if (err1=0 && err0=0) && (num>1 || A_Index>1)
      ini.err1:=err1:=0.05, ini.err0:=err0:=0.05
    if (!JoinText)
    {
      allpos:=Buffer(allpos_max*4), allpos_ptr:=allpos.Ptr
      For i,j in info
      Loop this.PicFind(ini, j, dir, sx, sy, sw, sh, allpos_ptr)
      {
        pos:=NumGet(allpos, 4*(A_Index-1), "uint")
        , x:=(pos&0xFFFF)+zx, y:=(pos>>16)+zy
        , w:=Floor(j[2]*zoomW), h:=Floor(j[3]*zoomH), comment:=j[10]
        , arr.Push({1:x, 2:y, 3:w, 4:h, x:x+w//2, y:y+h//2, id:comment})
        if (!FindAll)
          Break 3
      }
    }
    else
    For k,v in JoinText
    {
      v:=StrSplit(Trim(RegExReplace(v, "\s*\|[|\s]*", "|"), "|")
      , (InStr(v,"|")?"|":""), " `t")
      , this.JoinText(arr, ini, info2, v, 1, offsetX, offsetY
      , FindAll, dir, 0, 0, 0, sx, sy, sw, sh)
      if (!FindAll && arr.Length)
        Break 2
    }
    if (err1!=0 || err0!=0 || arr.Length || info[1][4] || info[1][7]=5)
      Break
  }
  if (arr.Length)
  {
    (OutputX is VarRef) && (%OutputX%:=arr[1].x)
    , (OutputY is VarRef) && (%OutputY%:=arr[1].y)
    , this.ok:=arr
    return arr
  }
  return 0
}

; the join text object <==> [ "abc", "xyz", "a1|a2|a3" ]

JoinText(arr, ini, info2, text, index, offsetX, offsetY
  , FindAll, dir, minX, minY, maxY, sx, sy, sw, sh)
{
  if !(Len:=text.Length)
    return 0
  allpos:=Buffer(ini.allpos_max*4), allpos_ptr:=allpos.Ptr
  , zoomW:=ini.zoomW, zoomH:=ini.zoomH, mode:=ini.mode
  For i,j in info2[text[index]]
  if (mode!=2 || text[index]==j[10])
  Loop this.PicFind(ini, j, dir, sx, sy, (index=1 ? sw
  : Min(sx+offsetX+Floor(j[2]*zoomW),ini.sx+ini.sw)-sx), sh, allpos_ptr)
  {
    pos:=NumGet(allpos, 4*(A_Index-1), "uint")
    , x:=pos&0xFFFF, y:=pos>>16
    , w:=Floor(j[2]*zoomW), h:=Floor(j[3]*zoomH)
    , (index=1 && (minX:=x, minY:=y, maxY:=y+h))
    , minY1:=Min(y, minY), maxY1:=Max(y+h, maxY), sx1:=x+w
    if (index<Len)
    {
      sy1:=Max(minY1-offsetY, ini.sy)
      , sh1:=Min(maxY1+offsetY, ini.sy+ini.sh)-sy1
      if this.JoinText(arr, ini, info2, text, index+1, offsetX, offsetY
      , FindAll, 5, minX, minY1, maxY1, sx1, sy1, 0, sh1)
      && (index>1 || !FindAll)
        return 1
    }
    else
    {
      comment:=""
      For k,v in text
        comment.=(mode=2 ? v : info2[v][1][10])
      x:=minX+ini.zx, y:=minY1+ini.zy, w:=sx1-minX, h:=maxY1-minY1
      , arr.Push({1:x, 2:y, 3:w, 4:h, x:x+w//2, y:y+h//2, id:comment})
      if (index>1 || !FindAll)
        return 1
    }
  }
  return 0
}

PicFind(ini, j, dir, sx, sy, sw, sh, allpos_ptr)
{
  static MyFunc:=""
  if (!MyFunc)
  {
    x32:="VVdWU4HslAAAAIO8JKgAAAAFi6wkrAAAAIu8JOAAAAAPhH8HAACLhCTkAAAAhcAP"
    . "jgQOAAAxwImsJKwAAADHBCQAAAAAx0QkFAAAAADHRCQMAAAAAInFx0QkGAAAAACQ"
    . "i4Qk3AAAAItMJBgx9jHbAciF@4lEJAh@PemQAAAAZpAPr4QkyAAAAInBifCZ9@8B"
    . "wYtEJAiAPBgxdEyLhCTYAAAAg8MBA7Qk+AAAAIkMqIPFATnfdFSLBCSZ97wk5AAA"
    . "AIO8JKgAAAAEdbUPr4QkvAAAAInBifCZ9@+NDIGLRCQIgDwYMXW0i0QkDIuUJNQA"
    . "AACDwwEDtCT4AAAAiQyCg8ABOd+JRCQMdawBfCQYg0QkFAGLjCT8AAAAi0QkFAEM"
    . "JDmEJOQAAAAPhTL@@@+LTCQMu62L22iJ7g+vjCToAAAAiWwkMIusJKwAAACJyMH5"
    . "H@frwfoMKcqLjCTsAAAAiVQkNA+vzonIwfkf9+vB+gwpyolUJDiDvCSoAAAABA+E"
    . "TwgAAIuEJLwAAACLvCTAAAAAD6+EJMQAAACLlCTIAAAAi4wkqAAAAPfahcmNBLiL"
    . "vCS8AAAAjTyXiXwkIA+FTQIAAInqienHRCQcAAAAAMHqEMdEJCgAAAAAD7b6i5Qk"
    . "zAAAAIl8JAgPtv2J6Yl8JBQPtvmJfCQYi7wkyAAAAMHnAoXSiXwkPA+OyAAAAIms"
    . "JKwAAACLvCTIAAAAhf8PjpEAAACLtCS4AAAAi2wkKAOsJNAAAAABxgNEJDyJRCQs"
    . "A4QkuAAAAIkEJI22AAAAAA+2TgKLXCQID7ZGAQ+2FitEJBQrVCQYic8B2SnfjZkA"
    . "BAAAD6@AD6@fweALD6@fAcO4@gUAACnID6@CD6@QAdM5nCSwAAAAD5NFAIPGBIPF"
    . "ATs0JHWqi7QkyAAAAAF0JCiLRCQsg0QkHAEDRCQgi3wkHDm8JMwAAAAPhUb@@@+L"
    . "rCSsAAAAi0QkOIt8JDSJBCSLdCQMMcCLDCQ5@g9O8Il0JAyLdCQwOc4PT8aJRCQw"
    . "i4QkqAAAAIPoBIP4AQ+GYQQAAMdEJBQAAAAAx0QkCAAAAACLRCQIA4QkyAAAACuE"
    . "JPgAAACJRCQci0QkFAOEJMwAAAArhCT8AAAAg7wktAAAAAmJRCQYD4RRAgAAi4Qk"
    . "tAAAAIPoAYP4Bw+HCQIAAIP4A4lEJDQPjgQCAACLRCQIi3QkFMdEJDgAAAAAiUQk"
    . "SIl0JECJRCQUi3QkSDl0JByLRCRAiUQkCA+MuQEAAIt0JEA5dCQYD4zvCgAA9kQk"
    . "NAKLdCRIifJ0DItEJBQDRCQcKfCJwvZEJDQBi3QkQInwdAqLRCQIA0QkGCnwi3Qk"
    . "NInRg@4DD0@ID0@CiUwkKIlEJCDptwIAAI20JgAAAACDvCSoAAAAAQ+EYAkAAIO8"
    . "JKgAAAACD4TuBgAAieqJ6Q+2tCSwAAAAweoQx0QkFAAAAADHRCQcAAAAAA+2+ouU"
    . "JLAAAACJPCQPtv2J6Yl8JAgPtvmLjCSwAAAAweoQiXwkGA+2+g+21Yn5D6@PidcP"
    . "r@qJTCQki4wkzAAAAIl8JASJ9w+v@ol8JBCLvCTIAAAAwecChcmJfCQsD44m@v@@"
    . "iawkrAAAAIuUJMgAAACF0g+OgwAAAIuUJLgAAACLXCQci6wkuAAAAAOcJNAAAAAB"
    . "wgNEJCyJRCQoAcWQjXQmAA+2QgIx@w+2SgErBCQPtjIPr8A5RCQkfCIrTCQID6@J"
    . "OUwkBHwVifAPtvArdCQYD6@2OXQkEA+dwInHifiDwgSDwwGIQ@856nW2i7QkyAAA"
    . "AAF0JByLRCQog0QkFAEDRCQgi3wkFDm8JMwAAAAPhVT@@@@pZ@3@@4tEJDiBxJQA"
    . "AABbXl9dwlgAx0QkNAAAAACLRCQUi3QkHMdEJDgAAAAAiUQkSItEJBiJdCQYiUQk"
    . "HItEJAiJRCRA6ev9@@+LdCQIi0wkHMdEJFwAAAAAx0QkWAEAAADHRCREAAAAAMdE"
    . "JFAAAAAAifDHRCQ4AAAAAAHIKfGLdCQYicIrdCQUjVkBweofg8EJAdDR+IlEJCCL"
    . "RCQUA0QkGInCweofAdCJwonw0fqDwAmJVCQojVYBid4Pr@I50w9PwYm0JIAAAACJ"
    . "xg+v8Im0JIQAAACLtCSAAAAAOXQkXA+NHP@@@4u0JIQAAAA5dCRQx0QkVAAAAAAP"
    . "jQP@@@+LTCRYOUwkVA+NggQAAItEJCCLdCQIOfAPjOAGAACLdCQcOfAPj9QGAACL"
    . "RCQoi0wkFDnID4zEBgAAi0wkGDnID4+4BgAAg0QkXAGJdCQYiUwkHMdEJDQJAAAA"
    . "i3QkMItEJAw5xg9NxoO8JKgAAAAFiUQkLItEJCgPhOIJAACDvCSoAAAABA+EawgA"
    . "AA+vhCTIAAAAi1QkLIt0JCCF0o0cMA+EygcAAIuMJNAAAACLNCQx0ol8JDyJXCRg"
    . "AdnrDYPCATlUJCwPhKEHAAA7VCQMfRyLnCTUAAAAiwSTAciAOAB1C4NsJDwBD4j0"
    . "BwAAOVQkMH7Li5wk2AAAAIsEkwHIgDgBdbqD7gF5tenTBwAAi4QkxAAAAMeEJMQA"
    . "AAAAAAAAiUQkFIuEJMAAAADHhCTAAAAAAAAAAIlEJAjpfvv@@zHAhe0PlcCJRCR4"
    . "D4RdAgAAi4Qk5AAAAIu0JNwAAACJ6Q+2yQ+vx40EholEJEyJ6MHoEA+20InoD7bE"
    . "idYPr8APr@KJRCQEicgPr8GJdCQkiUQkEIuEJOQAAACFwA+OhgYAAIt0JEyNBL0A"
    . "AAAAieuJvCTgAAAAi2wkJIu8JLAAAACJRCQ4McDHRCQsAAAAAMdEJDAAAAAAx0Qk"
    . "DAAAAACJNCSLtCTgAAAAhfYPjiYBAACLjCTcAAAAizQkx0QkGAAAAACJXCQgAcED"
    . "RCQ4iUwkFIlEJDQDhCTcAAAAiUQkKI12AI28JwAAAACLRCQUhf8PtlABD7ZIAg+2"
    . "AIkUJIlEJAh0SDHSjXQmAIsclonYwegQD7bAKcgPr8A5xXwjD7bHKwQkD6@AOUQk"
    . "BHwUD7bDK0QkCA+vwDlEJBAPjSsEAACDwgE5+nXCiVwkIItEJAzB4RDB4AKJRCQc"
    . "i0QkLJn3vCTkAAAAD6+EJLwAAACJw4tEJBiZ97wk4AAAAItUJAyNBIOLnCTUAAAA"
    . "iQSTiwQkg8IBi5wk2AAAAIlUJAzB4AgJwQtMJAiLRCQciQwDg0QkFASLlCT4AAAA"
    . "i0QkFAFUJBg7RCQoD4Ue@@@@i1wkIItEJDSJNCSDRCQwAYu0JPwAAACLTCQwAXQk"
    . "LDmMJOQAAAAPhar+@@+LTCQMuq2L22iJ3Q+vjCToAAAAxwQkAAAAAMdEJDAAAAAA"
    . "icjB+R@36sH6DInXKc@pDvn@@4nowegQD6+EJPwAAACZ97wk5AAAAA+vhCS8AAAA"
    . "icEPt8UPr4Qk+AAAAJn3@4t8JDSNLIGLRCQ4iQQk6c74@@+LhCSwAAAAhcAPhDwE"
    . "AACLtCTUAAAAi5QksAAAAIuEJNgAAACLnCTcAAAAibwk4AAAAI0MlonHiUwkCDHJ"
    . "iyuDxgSDw1iDxwSJ6MHoEA+vhCT8AAAAmfe8JOQAAAAPr4QkvAAAAIkEJA+3xQ+v"
    . "hCT4AAAAmfe8JOAAAACLFCSNBIKJRvyLQ6yNBEGDwRaJR@w7dCQIdaeLhCSwAAAA"
    . "i4wk6AAAALqti9toD6@IiUQkDInIwfkf9+qJ0MH4DCnIi7wk3AAAAMcEJAAAAADH"
    . "RCQwAAAAAIPHCIl8JEyJx+ns9@@@i3QkRINEJFABifCD4AEBwYnwg8ABiUwkWIPg"
    . "A4lEJETpIfv@@4u0JMgAAACLvCTQAAAAi4wkzAAAAMcEJAAAAADHRCQIAAAAAI08"
    . "d4l8JCiJ98HnAoXJiXwkFA+OgPf@@4uUJMgAAACF0n5fi4wkuAAAAItcJCgDXCQI"
    . "AcEDRCQUiUQkGAOEJLgAAACJxw+2UQKDwQSDwwFr8iYPtlH9a8JLjRQGD7Zx@Inw"
    . "weAEKfAB0MH4B4hD@zn5ddKLtCTIAAAAAXQkCItEJBiDBCQBA0QkIIs8JDm8JMwA"
    . "AAB1gouEJMgAAACLvCSwAAAAMfbHRCQUAAAAAImsJKwAAACD6AGJRCQci4QkzAAA"
    . "AIPoAYlEJCCLrCTIAAAAhe0PjggBAACLXCQUi0QkKIuMJMgAAACLrCTQAAAAhduJ"
    . "w40UMA+URCQYAfEBy4lMJCyJ8SuMJMgAAAAB7okcJIl0JAgBwTHA6aQAAACNdCYA"
    . "gHwkGAAPhZ0AAAA5RCQcD4STAAAAi1wkFDlcJCAPhIUAAAAPtjoPtmr@vgEAAAAD"
    . "vCSsAAAAOe9yRg+2agE573I+D7YpOe9yN4scJA+2Kznvci0Ptmn@Oe9yJQ+2aQE5"
    . "73IdD7Zr@74BAAAAOe9yEA+2cwE59w+Sw4nekI10JgCLbCQIifOIXAUAg8ABg8IB"
    . "gwQkAYPBATmEJMgAAAB0G4XAD4VY@@@@i3QkCMYEBgLr2IlcJCDpOfz@@4t0JCyD"
    . "RCQUAYtEJBQ5hCTMAAAAD4XT@v@@i0QkOIm8JLAAAACLrCSsAAAAi3wkNIkEJOmO"
    . "9f@@i0QkHIt0JBiJRCQYiXQkHItEJESFwA+F@gAAAINsJCgBg0QkVAHp5@j@@4u8"
    . "JMgAAACLtCTMAAAAjVUBxwQkAAAAAMdEJAgAAAAAweIHwecChfaJ1Yl8JBgPjiT1"
    . "@@+LnCTIAAAAhdt+X4uMJLgAAACLXCQIi7wkuAAAAAOcJNAAAAABwQNEJBiJRCQU"
    . "AccPtlECD7ZBAQ+2MWvAS2vSJgHCifDB4AQp8AHQOcUPlwODwQSDwwE5+XXVi7Qk"
    . "yAAAAAF0JAiLRCQUgwQkAQNEJCCLPCQ5vCTMAAAAD4V+@@@@6Z30@@@HRCQ4AAAA"
    . "AMdEJDQAAAAAx0QkMAAAAADHRCQMAAAAAOkY8@@@McDHRCQMAAAAAOlk@P@@g3wk"
    . "RAF0VIN8JEQCdEMxwIN8JEQDD5TAKUQkIOnm@v@@Mf@HBCQAAAAAx0QkDAAAAADH"
    . "RCQwAAAAAOlU9P@@i0QkCINEJEgBiUQkQOnb9P@@g0QkKAHprP7@@4NEJCAB6aL+"
    . "@@+LXCRgi0QkDIXAdCKLlCTUAAAAjTSCi4Qk0AAAAI0MGIsCg8IEAcg51sYAAHXy"
    . "i4Qk8AAAAINEJDgBi3QkOIXAdDOLVCQoA5QkxAAAAItEJCADhCTAAAAAi4wk8AAA"
    . "AMHiEAnQO7Qk9AAAAIlEsfwPjSH2@@+DfCQ0CQ+EAf7@@4NEJEAB6VP0@@8Pr4Qk"
    . "vAAAAIt0JCCLTCQsjQSwi7QkuAAAAIlEJGAB6IXJD7Z0BgKJdCRki7QkuAAAAA+2"
    . "dAYBiXQkaIu0JLgAAAAPtgQGiUQkbA+EVP@@@4sEJIl8JHCJfCQ8iawkrAAAAIn1"
    . "iUQkdDHAicfre422AAAAADl8JDB+YouEJNgAAACLVCRgi1wkZAMUuA+2TBUCD7ZE"
    . "FQErRCRoD7ZUFQArVCRsic4B2SnejZkABAAAD6@AD6@eweALD6@eAcO4@gUAACnI"
    . "D6@CD6@CAdg5hCSwAAAAcgeDbCR0AXh9g8cBOXwkLA+E2wIAADt8JAx9hYuEJNQA"
    . "AACLVCRgi1wkZAMUuA+2TBUCD7ZEFQErRCRoD7ZUFQArVCRsic4B2SnejZkABAAA"
    . "D6@AD6@eweALD6@eAcO4@gUAACnID6@CD6@CAdg5hCSwAAAAD4Mm@@@@g2wkcAEP"
    . "iRv@@@+LfCQ8i6wkrAAAAOmC@v@@D6+EJLwAAACLdCQgjQSwiUQkPItEJHiFwA+F"
    . "gAEAAIt0JCyF9g+EEP7@@4uEJNQAAACJfCR8iXwkdIt8JCSJRCRki0QkTIlEJGiL"
    . "hCTYAAAAiUQkbGtEJCwWx0QkLAAAAACJhCSIAAAAi3QkZItEJDyLXCQsAwaLdCRo"
    . "iVwkJIsOiUwkYItMJGyLCYmMJLAAAACJ8Yu0JLgAAAAPtnQGAol0JHCLtCS4AAAA"
    . "D7Z0BgGJtCSMAAAAi7QkuAAAAA+2BAaJhCSQAAAA6XkAAACLcQSLEYNEJCQCifeJ"
    . "0MHvEMHoEIn7D7bAK0QkcA+2+4nzD7bfiVwkBInzD7bziXQkEIn+D6@AD6@3OfB@"
    . "OItcJAQPtsYrhCSMAAAAid4Pr8APr@M58H8eD7bCi3QkECuEJJAAAACJ8g+vwA+v"
    . "1jnQD44nAQAAg8EIi0QkJDmEJLAAAAAPh3b@@@+BfCRg@@@@AHcLg2wkfAEPiNoA"
    . "AACDRCQsFoNEJGQEi0QkLINEJGhYg0QkbAQ7hCSIAAAAD4XX@v@@iXwkJIt8JHTp"
    . "nPz@@4tcJCyF2w+EkPz@@zH2iXwkYOsVkI20JgAAAACDxgE5dCQsD4SMAAAAi4Qk"
    . "1AAAAItMJDwDDLCLhCTYAAAAixSwi4QkuAAAAA+2bAgCidAPtt7B6BAPtsApxYuE"
    . "JLgAAAAPr+0PtkQIASnYOWwkJIucJLgAAAAPtgwLfBoPr8A5RCQEfBEPtsEPtsop"
    . "yA+vwDlEJBB9hoNsJGABD4l7@@@@idXpO@z@@4l8JCSLfCR06S78@@+J1eng+@@@"
    . "i3wkPIusJKwAAADp0Pv@@4F8JGD@@@8AD4fp@v@@6e@+@@+QkJCQkJCQkJCQkJCQ"
    x64:="QVdBVkFVQVRVV1ZTSIHsqAAAAESLtCQwAQAAi5wkYAEAAImMJPAAAACDvCTwAAAA"
    . "BYnRRIlEJCBEiYwkCAEAAIu8JGgBAAAPhGQHAACF@w+Ojw0AAESJbCQsi7Qk8AAA"
    . "ADHtTIusJFABAABEi6QkkAEAAEUx0sdEJAgAAAAARTH@x0QkGAAAAABEiVwkKImU"
    . "JPgAAABMY1wkGEUxyUUxwEwDnCRYAQAAhdt@Met1ZpBBD6@GicFEiciZ9@sBwUOA"
    . "PAMxdDxJg8ABSWPCRQHhQYPCAUQ5w0GJTIUAfkKJ6Jn3@4P+BHXJD6+EJBgBAACJ"
    . "wUSJyJn3+0OAPAMxjQyBdcRIi5QkSAEAAEmDwAFJY8dFAeFBg8cBRDnDiQyCf74B"
    . "XCQYg0QkCAEDrCSYAQAAi0QkCDnHD4Va@@@@RIuMJHABAABBuK2L22hEi1wkKIuM"
    . "JPgAAABEi2wkLEUPr89EichBwfkfQffoidDB+AxEKchEi4wkeAEAAIlEJChFD6@K"
    . "RInIQcH5H0H36InQwfgMRCnIiUQkLIO8JPAAAAAED4QgCAAAi4QkGAEAAIu8JCAB"
    . "AAAPr4QkKAEAAI0EuIu8JBgBAABBicFEifD32I0Eh4lEJAiLhCTwAAAAhcAPhU4C"
    . "AABEi6QkOAEAAA+2xYnNwe0QicIPtsFAD7bticdFheQPjl0DAABCjQS1AAAAAESL"
    . "ZCQgMdtEiXwkOESJbCRQidbHRCQYAAAAAIlEJDBBid9EiVQkRESJXCRIRYnNiYwk"
    . "+AAAAEWF9g+OjQAAAEiLnCQQAQAASWPFRTHbTI1UAwJIY1wkGEgDnCRAAQAADx8A"
    . "QQ+2Uv5FD7YKQQ+2Qv8p+kSJyUGJ0EKNVA0AKekp8ESNigAEAAAPr8BED6@JweAL"
    . "RA+vybn+BQAAKdGJykEPr9BBjQQBQQ+v0AHQQTnEQg+TBBtJg8MBSYPCBEU53n+g"
    . "RANsJDBEAXQkGEGDxwFEA2wkCEQ5vCQ4AQAAD4VT@@@@i0QkLESLfCQ4RItUJERE"
    . "i1wkSESLbCRQi4wk+AAAAIt8JCiJRCQIMcBBOf9ED074RDtUJAhED07Qi4Qk8AAA"
    . "AIPoBIP4AQ+GQwQAAMdEJCgAAAAAx0QkGAAAAACLRCQYRAHwK4QkkAEAAInFi0Qk"
    . "KAOEJDgBAAArhCSYAQAAg7wkCAEAAAmJRCQsD4Q6AgAAi4QkCAEAAIPoAYP4Bw+H"
    . "+AEAAIP4A4lEJEQPjvMBAACLRCQYi1wkKMdEJEgAAAAAiUQkWIlcJECJRCQoO2wk"
    . "WItEJECJRCQYD4ylAQAAi1wkQDlcJCwPjGIKAAD2RCREAotcJFiJ2nQKi0QkKAHo"
    . "KdiJwvZEJEQBi1wkQInYdAqLRCQYA0QkLCnYi1wkRInWg@sDD0@wD0@CiXQkOIlE"
    . "JDDpowIAAGYPH4QAAAAAAIO8JPAAAAABD4T6CAAAg7wk8AAAAAIPhKQGAACLfCQg"
    . "D7bFRIuEJDgBAABBicQPtsGJzYnDwe0Qx0QkGAAAAABAD7bXQYn7SIn4idcPtsRB"
    . "wesQD6@6QYnFRQ+220QPr+hCjQS1AAAAAEAPtu2JfCQkMf+JRCQwRQ+v20WFwA+O"
    . "rwAAAESJfCQ4RIlUJEREic5Bid+JjCT4AAAARYX2fm5Ii5wkEAEAAEhjxkUxwEiN"
    . "VAMCSGNcJBhIA5wkQAEAAA+2AkUx0g+2Sv9ED7ZK@inoD6@AQTnDfBtEKeEPr8lB"
    . "Oc18EEUp+UUPr8lEOUwkJEEPncJGiBQDSYPAAUiDwgRFOcZ@uwN0JDBEAXQkGIPH"
    . "AQN0JAg5vCQ4AQAAD4V5@@@@RIt8JDhEi1QkRIuMJPgAAACLRCQsi3wkKIlEJAjp"
    . "pP3@@4tEJEhIgcSoAAAAW15fXUFcQV1BXkFfw8dEJEQAAAAAi0QkKMdEJEgAAAAA"
    . "iUQkWItEJCyJbCQsicWLRCQYiUQkQOkC@v@@RItMJBiLXCQoQYnoi3QkLMdEJGgA"
    . "AAAAx0QkZAEAAADHRCRMAAAAAESJyEUpyMdEJFwAAAAAAehFjUgBQYPACYnCx0Qk"
    . "SAAAAADB6h8B0NH4iUQkMInYAfAp3kSJy4nCweofAdCNVgHR+A+v2olEJDiJ8IPA"
    . "CUE50UEPT8CJnCSIAAAAicMPr9iJnCSMAAAAi5wkiAAAADlcJGgPjRj@@@+LnCSM"
    . "AAAAOVwkXMdEJGAAAAAAD43@@v@@i3QkZDl0JGAPjUgEAACLRCQwi1wkGDnYD4yK"
    . "BgAAOegPj4IGAACLRCQ4i1wkKDnYD4xyBgAAi1wkLDnYD49mBgAAg0QkaAGJbCQs"
    . "id3HRCRECQAAAEU5+kWJ@ItEJDhFD03ig7wk8AAAAAUPhLkJAACDvCTwAAAABA+E"
    . "AggAAEEPr8aLXCQwRYXkRI0MGA+EXAcAAItcJAiJ@kUxwOsNSYPAAUU5xA+ORAcA"
    . "AEU5x0SJRCRQfiZIi4QkSAEAAESJykIDFIBIi4QkQAEAAIA8EAB1CYPuAQ+IkAcA"
    . "AEQ7VCRQfrxIi5QkUAEAAESJyEIDBIJIi5QkQAEAAIA8AgF1n4PrAXma6WIHAACQ"
    . "i4QkKAEAAMeEJCgBAAAAAAAAiUQkKIuEJCABAADHhCQgAQAAAAAAAIlEJBjpnPv@"
    . "@zHAhdIPlcCJhCSAAAAAD4Q9AgAAifhBidMPttIPr8NBwesQRQ+228HgAkiYSAOE"
    . "JFgBAABFD6@bSIlEJBAPtsVBicVED6@oidAPr8KF@4lEJCQPjiEGAACLdCQgjUP@"
    . "ibwkaAEAAIt8JCTHRCQYAAAAAEUx@0iNBIUGAAAAx0QkKAAAAADHRCQsAAAAAI1W"
    . "@0iLdCQQRIm0JDABAABIiUQkMI0EnQAAAACJnCRgAQAASI10lgSJRCQ4i4QkYAEA"
    . "AIXAD47wAAAASGNEJCxIi5wkWAEAADHtSI1cAwJIA0QkMEgDhCRYAQAASIlEJAiQ"
    . "i0QkIEQPtgNED7ZL@0QPtlP+hcB0Q0iLVCQQDx9EAACLConIwegQD7bARCnAD6@A"
    . "QTnDfBsPtsVEKcgPr8BBOcV8DQ+2wUQp0A+vwDnHfVtIg8IESDnWdceLRCQYTWP3"
    . "QcHgEEHB4QhBg8cBRQnImUUJ0Pe8JGgBAAAPr4QkGAEAAEGJxInomfe8JGABAABI"
    . "i5QkSAEAAEGNBIRCiQSySIuEJFABAABGiQSwSIPDBAOsJJABAABIO1wkCA+FP@@@"
    . "@4tcJDgBXCQsg0QkKAGLlCSYAQAAi0QkKAFUJBg5hCRoAQAAD4Xg@v@@RIuEJHAB"
    . "AAC6rYvbaESLtCQwAQAAx0QkCAAAAABFMdJFD6@HRInAQcH4H@fqwfoMiddEKcfp"
    . "VPn@@4nIwegQD6+EJJgBAACZ9@+LfCQoD6+EJBgBAABBicAPt8EPr4QkkAEAAJn3"
    . "+0GNDICLRCQsiUQkCOkW+f@@i0QkIEUxyTH2TIuUJFgBAACFwA+EBQQAAEiLrCRI"
    . "AQAATIukJFABAABEi7wkmAEAAEGLCkmDwliJyMHoEEEPr8eZ9@8Pr4QkGAEAAEGJ"
    . "wA+3wQ+vhCSQAQAAmff7QY0EgEKJRI0AQYtCrI0ERoPGFkOJBIxJg8EBRDlMJCB3"
    . "skSLRCQguq2L22hFicdED6+EJHABAABEicBBwfgf9+qJ0MH4DEQpwEiLvCRYAQAA"
    . "x0QkCAAAAABFMdJIg8cISIl8JBCJx+lN+P@@i1wkTINEJFwBidiD4AEBxonYg8AB"
    . "iXQkZIPgA4lEJEzpW@v@@0ONBDaLnCQ4AQAAMf8x7UaNJLUAAAAASJhIA4QkQAEA"
    . "AIXbSIlEJBgPjkX6@@+JjCT4AAAARInJRYX2fl1Ii5wkEAEAAEhj9UgDdCQYSGPB"
    . "RTHJTI1EAwIPH4QAAAAAAEEPthBJg8AEa9omQQ+2UPtrwkuNFANBD7ZY+onYweAE"
    . "KdgB0MH4B0KIBA5Jg8EBRTnOf8xEAeFEAfWDxwEDTCQIObwkOAEAAHWOSWPGugEA"
    . "AACLjCT4AAAASI14AUgpwkSLRCQgQY1G@0SJVCRIRIlcJFBIiXwkMIu8JDgBAABF"
    . "MeTHRCQIAAAAAEiJVCQ4QYnCRIl8JESD7wFBiftFhfYPjuYAAABIY3QkCEiLfCQw"
    . "RYXkSItEJBhBD5THSI0cN0iLfCQ4SI1UMAFIAcNMjQw3SIu8JEABAABJAcExwEgB"
    . "9+mTAAAAZi4PH4QAAAAAAEWE@w+FiAAAAEE5wg+EfwAAAEU543R6RA+2Qv8Ptmr+"
    . "vgEAAABBAchBOehyQw+2KkE56HI7QQ+2af9BOehyMQ+2a@9BOehyKEEPtmn+QTno"
    . "ch5BD7YpQTnochUPtmv+QTnocgwPtjNBOfBAD5LGZpBAiDQHSIPAAUiDwgFIg8MB"
    . "SYPBAUE5xn4OhcAPhW@@@@@GBAcC691EAXQkCEGDxAFEOaQkOAEAAA+F@@7@@4tE"
    . "JCxEi3wkRESLVCRIRItcJFBEiUQkIIt8JCiJRCQI6QX2@@+J6ItsJCyJRCQsi1Qk"
    . "TIXSD4XWAAAAg2wkOAGDRCRgAek9+f@@i7QkOAEAAIPBATH@weEHMe1GjSS1AAAA"
    . "AIX2D44K+P@@RIlUJBhFicpFhfZ+V0iLnCQQAQAASGP1SAO0JEABAABJY8JFMclM"
    . "jUQDAkEPthBBD7ZA@0EPtlj+a8BLa9ImAcKJ2MHgBCnYAdA5wUIPlwQOSYPBAUmD"
    . "wARFOc5@zUUB4kQB9YPHAUQDVCQIObwkOAEAAHWTi0QkLESLVCQYi3wkKIlEJAjp"
    . "NPX@@8dEJCwAAAAAx0QkKAAAAABFMdJFMf@pl@P@@4N8JEwBdFWDfCRMAnREMcCD"
    . "fCRMAw+UwClEJDDpDv@@@zHARTH@6X78@@@HRCQIAAAAADH@RTH@RTHS6ev0@@+L"
    . "RCQYg0QkWAGJRCRA6Wz1@@+DRCQ4AenT@v@@g0QkMAHpyf7@@0WF@3QrSIuUJEgB"
    . "AABBjUf@TI1EggREicgDAkiLnCRAAQAASIPCBEk50MYEAwB15oNEJEgBSIO8JIAB"
    . "AAAAi1wkSHQ4i1QkOAOUJCgBAABMY8OLRCQwA4QkIAEAAEiLtCSAAQAAweIQCdA7"
    . "nCSIAQAAQolEhvwPjZP2@@+DfCRECQ+EJ@7@@4NEJEAB6dn0@@8Pr4QkGAEAAItc"
    . "JDCNBJhIi5wkEAEAAIlEJFAByEWF5I1QAkhj0g+2HBONUAFImEhj0olcJGxIi5wk"
    . "EAEAAA+2HBOJXCR4SIucJBABAAAPtgQDiUQkcA+EQ@@@@4tEJAiJjCT4AAAAMfaJ"
    . "fCR8SInZiYQkhAAAAOmUAAAARDuUJJAAAAB+fUiLhCRQAQAAi1QkUESLTCRsAxSw"
    . "jUICSJhED7YEAY1CAUhj0g+2FBFImCtUJHAPtgQBRInDRQHIK0QkeEQpy0WNiAAE"
    . "AABED6@LD6@ARA+vy8HgC0EBwbj+BQAARCnAD6@CD6@CQQHBRDlMJCByDoOsJIQA"
    . "AAABD4iaAAAASIPGAUE59A+OCgMAAEE594m0JJAAAAAPjlz@@@9Ii4QkSAEAAItU"
    . "JFBEi0wkbAMUsI1CAkiYRA+2BAGNQgFIY9IPthQRSJgrVCRwD7YEAUSJw0UByCtE"
    . "JHhEKctFjYgABAAARA+vyw+vwEQPr8vB4AtBAcG4@gUAAEQpwA+vwg+vwkQByDlE"
    . "JCAPg+r+@@+DbCR8AQ+J3@7@@4uMJPgAAADpQv7@@w+vhCQYAQAAi1wkMI0EmIlE"
    . "JGyLhCSAAAAAhcAPhY4BAABFheQPhMv9@@9Ii4QkSAEAAEiLtCRIAQAASItcJBCJ"
    . "vCSEAAAAx0QkfAAAAABIiUQkUEiLhCRQAQAASIlEJHBBjUQk@0iNRIYERInuSImE"
    . "JJAAAABIi1QkUItEJGxEiwNMi6wkEAEAAESLTCR8iYwk+AAAAAMCRIlEJHhMi0Qk"
    . "cI1QAUSNYAJImEEPtkQFAEWLAEhj0k1j5EEPtlQVAEcPtmQlAESJRCQgSYnYiYQk"
    . "nAAAAImUJJgAAADpdQAAAEWLaARBixBBg8ECRYnridBMienB6BBBwesQD7b1RQ+2"
    . "2w+2wEEPts1EKeBFid2JTCQkD6@ARQ+v60Q56H8zD7bGK4QkmAAAAEGJ9UQPr+4P"
    . "r8BEOeh@Gg+2wiuEJJwAAACJyg+v0Q+vwDnQD44FAQAASYPACEQ5TCQgd4SBfCR4"
    . "@@@@AIuMJPgAAAB3CoOsJIQAAAABeDBIg0QkUARIg8NYSINEJHAESItEJFCDRCR8"
    . "Fkg7hCSQAAAAD4XW@v@@QYn16U78@@9BifXpkvz@@0WF5A+EPfz@@4n+RTHJSIuE"
    . "JEgBAABEi0QkbEiLnCQQAQAARgMEiEiLhCRQAQAAQosMiEGNQAJImA+2FAOJyMHo"
    . "EA+2wCnCQY1AAU1jwA+v0kiYD7YEAw+23SnYQTnTicNIi4QkEAEAAEYPtgQAfByJ"
    . "2A+vw0E5xXwSQQ+2wA+20SnQD6@AOUQkJH0Jg+4BD4j9+@@@SYPBAUU5zA+PbP@@"
    . "@+mf+@@@gXwkeP@@@wCLjCT4AAAAD4cC@@@@6Qf@@@+LjCT4AAAA6Xn7@@+QkJCQ"
    this.MCode(&MyFunc, StrReplace((A_PtrSize=8?x64:x32),"@","/"))
  }
  text:=j[1], w:=j[2], h:=j[3]
  , err1:=this.Floor(j[4] ? j[5] : ini.err1)
  , err0:=this.Floor(j[4] ? j[6] : ini.err0)
  , mode:=j[7], color:=j[8], n:=j[9]
  return (!ini.bits.Scan0) ? 0 : DllCall(MyFunc.Ptr
    , "int",mode, "uint",color, "uint",n, "int",dir
    , "Ptr",ini.bits.Scan0, "int",ini.bits.Stride
    , "int",sx, "int",sy, "int",sw, "int",sh
    , "Ptr",ini.ss, "Ptr",ini.s1, "Ptr",ini.s0
    , (mode=5 ? "Ptr":"AStr"),text, "int",w, "int",h
    , "int",Floor(err1*10000), "int",Floor(err0*10000)
    , "Ptr",allpos_ptr, "int",ini.allpos_max
    , "int",Floor(w*ini.zoomW), "int",Floor(h*ini.zoomH))
}

code()
{
return "
(

//***** C source code of machine code *****

int __attribute__((__stdcall__)) PicFind(
  int mode, unsigned int c, unsigned int n, int dir
  , unsigned char * Bmp, int Stride
  , int sx, int sy, int sw, int sh
  , unsigned char * ss, unsigned int * s1, unsigned int * s0
  , unsigned char * text, int w, int h, int err1, int err0
  , unsigned int * allpos, int allpos_max
  , int new_w, int new_h )
{
  int ok, o, i, j, k, v, e1, e0, len1, len0, max;
  int x, y, x1, y1, x2, y2, x3, y3;
  int r, g, b, rr, gg, bb, dR, dG, dB;
  int ii, jj, RunDir, DirCount, RunCount, AllCount1, AllCount2;
  unsigned int c1, c2;
  unsigned char * gs;
  unsigned int * cors;
  ok=0; o=0; len1=0; len0=0;
  //----------------------
  if (mode==5)
  {
    if (k=(c!=0))  // FindPic
    {
      cors=(unsigned int *)(text+w*h*4);
      r=(c>>16)&0xFF; g=(c>>8)&0xFF; b=c&0xFF;
      dR=r*r; dG=g*g; dB=b*b;
      for (y=0; y<h; y++)
      {
        for (x=0; x<w; x++, o+=4)
        {
          rr=text[2+o]; gg=text[1+o]; bb=text[o];
          for (i=0; i<n; i++)
          {
            c=cors[i]; r=((c>>16)&0xFF)-rr;
            g=((c>>8)&0xFF)-gg; b=(c&0xFF)-bb;
            if (r*r<=dR && g*g<=dG && b*b<=dB) goto NoMatch1;
          }
          s1[len1]=(y*new_h/h)*Stride+(x*new_w/w)*4;
          s0[len1++]=(rr<<16)|(gg<<8)|bb;
          NoMatch1:;
        }
      }
    }
    else  // FindMultiColor or FindColor
    {
      cors=(unsigned int *)text;
      for (; len1<n; len1++, o+=22)
      {
        c=cors[o]; y=c>>16; x=c&0xFFFF;
        s1[len1]=(y*new_h/h)*Stride+(x*new_w/w)*4;
        s0[len1]=o+cors[o+1]*2;
      }
      cors+=2;
    }
    goto StartLookUp;
  }
  //----------------------
  // Generate Lookup Table
  for (y=0; y<h; y++)
  {
    for (x=0; x<w; x++)
    {
      if (mode==4)
        i=(y*new_h/h)*Stride+(x*new_w/w)*4;
      else
        i=(y*new_h/h)*sw+(x*new_w/w);
      if (text[o++]=='1')
        s1[len1++]=i;
      else
        s0[len0++]=i;
    }
  }
  //----------------------
  // Color Position Mode
  // only used to recognize multicolored Verification Code
  if (mode==4)
  {
    y=c>>16; x=c&0xFFFF;
    c=(y*new_h/h)*Stride+(x*new_w/w)*4;
    goto StartLookUp;
  }
  //----------------------
  // Generate Two Value Image
  o=sy*Stride+sx*4; j=Stride-sw*4; i=0;
  if (mode==0)  // Color Mode
  {
    rr=(c>>16)&0xFF; gg=(c>>8)&0xFF; bb=c&0xFF;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]-rr; g=Bmp[1+o]-gg; b=Bmp[o]-bb; v=r+rr+rr;
        ss[i]=((1024+v)*r*r+2048*g*g+(1534-v)*b*b<=n) ? 1:0;
      }
  }
  else if (mode==1)  // Gray Threshold Mode
  {
    c=(c+1)<<7;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
        ss[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15<c) ? 1:0;
  }
  else if (mode==2)  // Gray Difference Mode
  {
    gs=ss+sw*2;
    for (y=0; y<sh; y++, o+=j)
    {
      for (x=0; x<sw; x++, o+=4, i++)
        gs[i]=(Bmp[2+o]*38+Bmp[1+o]*75+Bmp[o]*15)>>7;
    }
    for (i=0, y=0; y<sh; y++)
      for (x=0; x<sw; x++, i++)
      {
        if (x==0 || y==0 || x==sw-1 || y==sh-1)
          ss[i]=2;
        else
        {
          n=gs[i]+c;
          ss[i]=(gs[i-1]>n || gs[i+1]>n
          || gs[i-sw]>n   || gs[i+sw]>n
          || gs[i-sw-1]>n || gs[i-sw+1]>n
          || gs[i+sw-1]>n || gs[i+sw+1]>n) ? 1:0;
        }
      }
  }
  else  // (mode==3) Color Difference Mode
  {
    rr=(c>>16)&0xFF; gg=(c>>8)&0xFF; bb=c&0xFF;
    r=(n>>16)&0xFF; g=(n>>8)&0xFF; b=n&0xFF;
    dR=r*r; dG=g*g; dB=b*b;
    for (y=0; y<sh; y++, o+=j)
      for (x=0; x<sw; x++, o+=4, i++)
      {
        r=Bmp[2+o]-rr; g=Bmp[1+o]-gg; b=Bmp[o]-bb;
        ss[i]=(r*r<=dR && g*g<=dG && b*b<=dB) ? 1:0;
      }
  }
  //----------------------
  StartLookUp:
  err1=len1*err1/10000;
  err0=len0*err0/10000;
  if (err1>=len1) len1=0;
  if (err0>=len0) len0=0;
  max=(len1>len0) ? len1 : len0;
  if (mode==5 || mode==4)
  {
    x1=sx; y1=sy; sx=0; sy=0;
  }
  else
  {
    x1=0; y1=0;
  }
  x2=x1+sw-new_w; y2=y1+sh-new_h;
  // 1 ==> ( Left to Right ) Top to Bottom
  // 2 ==> ( Right to Left ) Top to Bottom
  // 3 ==> ( Left to Right ) Bottom to Top
  // 4 ==> ( Right to Left ) Bottom to Top
  // 5 ==> ( Top to Bottom ) Left to Right
  // 6 ==> ( Bottom to Top ) Left to Right
  // 7 ==> ( Top to Bottom ) Right to Left
  // 8 ==> ( Bottom to Top ) Right to Left
  // 9 ==> Center to Four Sides
  if (dir==9)
  {
    x=(x1+x2)/2; y=(y1+y2)/2; i=x2-x1+1; j=y2-y1+1;
    AllCount1=i*j; i=(i>j) ? i+8 : j+8;
    AllCount2=i*i; RunCount=0; DirCount=1; RunDir=0;
    for (ii=0; RunCount<AllCount1 && ii<AllCount2; ii++)
    {
      for(jj=0; jj<DirCount; jj++)
      {
        if(x>=x1 && x<=x2 && y>=y1 && y<=y2)
        {
          RunCount++;
          goto FindPos;
          FindPos_GoBak:;
        }
        if (RunDir==0) y--;
        else if (RunDir==1) x++;
        else if (RunDir==2) y++;
        else if (RunDir==3) x--;
      }
      if (RunDir & 1) DirCount++;
      RunDir = (++RunDir) & 3;
    }
    goto Return1;
  }
  if (dir<1 || dir>8) dir=1;
  if (--dir>3) { r=y1; y1=x1; x1=r; r=y2; y2=x2; x2=r; }
  for (y3=y1; y3<=y2; y3++)
  {
    for (x3=x1; x3<=x2; x3++)
    {
      y=(dir & 2) ? y1+y2-y3 : y3;
      x=(dir & 1) ? x1+x2-x3 : x3;
      if (dir>3) { r=y; y=x; x=r; }
      //----------------------
      FindPos:
      e1=err1; e0=err0;
      if (mode==5)
      {
        o=y*Stride+x*4;
        if (k)
        {
          for (i=0; i<max; i++)
          {
            j=o+s1[i]; c=s0[i]; r=Bmp[2+j]-((c>>16)&0xFF);
            g=Bmp[1+j]-((c>>8)&0xFF); b=Bmp[j]-(c&0xFF);
            if ((r*r>dR || g*g>dG || b*b>dB) && (--e1)<0) goto NoMatch;
          }
        }
        else
        {
          for (i=0; i<max; i++)
          {
            j=o+s1[i]; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
            for (j=i*22, v=cors[j]>0xFFFFFF, n=s0[i]; j<n;)
            {
              c1=cors[j++]; c2=cors[j++];
              r=((c1>>16)&0xFF)-rr; g=((c1>>8)&0xFF)-gg; b=(c1&0xFF)-bb;
              dR=(c2>>16)&0xFF; dG=(c2>>8)&0xFF; dB=c2&0xFF;
              if (r*r<=dR*dR && g*g<=dG*dG && b*b<=dB*dB)
              {
                if (v) goto NoMatch2;
                goto MatchOK;
              }
            }
            if (v) goto MatchOK;
            NoMatch2:;
            if ((--e1)<0) goto NoMatch;
            MatchOK:;
          }
        }
      }
      else if (mode==4)
      {
        o=y*Stride+x*4;
        j=o+c; rr=Bmp[2+j]; gg=Bmp[1+j]; bb=Bmp[j];
        for (i=0; i<max; i++)
        {
          if (i<len1)
          {
            j=o+s1[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb; v=r+rr+rr;
            if ((1024+v)*r*r+2048*g*g+(1534-v)*b*b>n && (--e1)<0) goto NoMatch;
          }
          if (i<len0)
          {
            j=o+s0[i]; r=Bmp[2+j]-rr; g=Bmp[1+j]-gg; b=Bmp[j]-bb; v=r+rr+rr;
            if ((1024+v)*r*r+2048*g*g+(1534-v)*b*b<=n && (--e0)<0) goto NoMatch;
          }
        }
      }
      else
      {
        o=y*sw+x;
        for (i=0; i<max; i++)
        {
          if (i<len1 && ss[o+s1[i]]==0 && (--e1)<0) goto NoMatch;
          if (i<len0 && ss[o+s0[i]]==1 && (--e0)<0) goto NoMatch;
        }
        // Clear the image that has been found
        for (i=0; i<len1; i++)
          ss[o+s1[i]]=0;
      }
      ok++;
      if (allpos!=0)
      {
        allpos[ok-1]=(sy+y)<<16|(sx+x);
        if (ok>=allpos_max) goto Return1;
      }
      NoMatch:;
      if (dir==9) goto FindPos_GoBak;
    }
  }
  //----------------------
  Return1:
  return ok;
}

)"
}

PicInfo(text)
{
  static info:=Map(), bmp:=[]
  if !InStr(text, "$")
    return
  key:=(r:=StrLen(text))<10000 ? text
    : DllCall("ntdll\RtlComputeCrc32", "uint",0
    , "Ptr",StrPtr(text), "uint",r*2, "uint")
  if info.Has(key)
    return info[key]
  v:=text, comment:="", seterr:=err1:=err0:=0
  ; You Can Add Comment Text within The <>
  if RegExMatch(v, "<([^>\n]*)>", &r)
    v:=StrReplace(v,r[0]), comment:=Trim(r[1])
  ; You can Add two fault-tolerant in the [], separated by commas
  if RegExMatch(v, "\[([^\]\n]*)]", &r)
  {
    v:=StrReplace(v,r[0]), r:=StrSplit(r[1] ",", ",")
    , seterr:=1, err1:=r[1], err0:=r[2]
  }
  color:=SubStr(v,1,InStr(v,"$")-1), v:=Trim(SubStr(v,InStr(v,"$")+1))
  mode:=InStr(color,"##") ? 5
    : InStr(color,"#") ? 4 : InStr(color,"-") ? 3
    : InStr(color,"**") ? 2 : InStr(color,"*") ? 1 : 0
  color:=RegExReplace(color, "[*#\s]")
  (mode=0 || mode=3 || mode=5) && color:=StrReplace(color,"0x")
  if (mode=5)
  {
    if !(v~="/[\s\-\w]+/[\s\-\w,/]+$")
    {
      ; <FindPic> : Text parameter require manual input
      ; Text:='|<>##DRDGDB-RRGGBB1-RRGGBB2... $ d:\a.bmp'
      ; the 0xRRGGBB1(+/-0xDRDGDB)... all as transparent color
      if !(hBM:=LoadPicture(v))
        return
      this.GetBitmapWH(hBM, &w, &h)
      if (w<1 || h<1)
        return
      hBM2:=this.CreateDIBSection(w, h, 32, &Scan0)
      this.CopyHBM(hBM2, 0, 0, hBM, 0, 0, w, h)
      DllCall("DeleteObject", "Ptr",hBM)
      if (!Scan0)
        return
      ; All images used for Search are cached
      StrReplace(color, "-",,, &n)
      bmp.Push(buf:=Buffer(w*h*4+n*4)), v:=buf.Ptr
      DllCall("RtlMoveMemory", "Ptr",v, "Ptr",Scan0, "Ptr",w*h*4)
      DllCall("DeleteObject", "Ptr",hBM2)
      p:=v+w*h*4-4, tab:=Map(), tab.CaseSense:="Off"
      , tab.Set("Black", "000000", "White", "FFFFFF"
      , "Red", "FF0000", "Green", "008000", "Blue", "0000FF"
      , "Yellow", "FFFF00", "Silver", "C0C0C0", "Gray", "808080"
      , "Teal", "008080", "Navy", "000080", "Aqua", "00FFFF"
      , "Olive", "808000", "Lime", "00FF00", "Fuchsia", "FF00FF"
      , "Purple", "800080", "Maroon", "800000")
      For k1,v1 in StrSplit(color, "-")
      if (k1>1)
        NumPut("uint", this.Floor("0x" (tab.Has(v1)?tab[v1]:v1)), p+=4)
      color:=this.Floor("0x" StrSplit(color "-", "-")[1])|0x1000000
    }
    else
    {
      ; <FindMultiColor> <FindColor> : FindColor is FindMultiColor with only one point
      ; Text:='|<>##DRDGDB $ 0/0/RRGGBB1-DRDGDB1/RRGGBB2, xn/yn/-RRGGBB3/RRGGBB4, ...'
      ; Color behind '##' (0xDRDGDB) is the default allowed variation for all colors
      ; Initial point (0,0) match 0xRRGGBB1(+/-0xDRDGDB1) or 0xRRGGBB2(+/-0xDRDGDB),
      ; point (xn,yn) match not 0xRRGGBB3(+/-0xDRDGDB) and not 0xRRGGBB4(+/-0xDRDGDB)
      ; Starting with '-' after a point coordinate means excluding all subsequent colors
      ; Each point can take up to 10 sets of colors (xn/yn/RRGGBB1/.../RRGGBB10)
      arr:=StrSplit(Trim(RegExReplace(v, "i)\s|0x"), ","), ",")
      if !(n:=arr.Length)
        return
      bmp.Push(buf:=Buffer(n*22*4)), v:=buf.Ptr
      , color:=StrSplit(color "-", "-")[1]
      For k1,v1 in arr
      {
        r:=StrSplit(v1 "/", "/")
        , x:=this.Floor(r[1]), y:=this.Floor(r[2])
        , (A_Index=1) ? (x1:=x2:=x, y1:=y2:=y)
        : (x1:=Min(x1,x), x2:=Max(x2,x)
        , y1:=Min(y1,y), y2:=Max(y2,y))
      }
      For k1,v1 in arr
      {
        r:=StrSplit(v1 "/", "/")
        , x:=this.Floor(r[1])-x1, y:=this.Floor(r[2])-y1
        , n1:=Min(Max(r.Length-3, 0), 10)
        , NumPut("uint", y<<16|x, p:=v+(A_Index-1)*22*4)
        , NumPut("uint", n1, p+=4)
        Loop n1
          k1:=(InStr(v1:=r[2+A_Index], "-")=1 ? 0x1000000:0)
          , c:=StrSplit(Trim(v1,"-") "-" color, "-")
          , NumPut("uint", this.Floor("0x" c[1])&0xFFFFFF|k1, p+=4)
          , NumPut("uint", this.Floor("0x" c[2]), p+=4)
      }
      color:=0, w:=x2-x1+1, h:=y2-y1+1
    }
  }
  else
  {
    r:=StrSplit(v ".", "."), w:=this.Floor(r[1])
    , v:=this.base64tobit(r[2]), h:=StrLen(v)//w
    if (w<1 || h<1 || StrLen(v)!=w*h)
      return
    if (mode=3)
    {
      r:=StrSplit(color, "-")
      , color:=this.Floor("0x" r[1]), n:=this.Floor("0x" r[2])
    }
    else
    {
      r:=StrSplit(color "@1", "@")
      , color:=this.Floor((mode=0?"0x":"") r[1]), n:=this.Floor(r[2])
      , n:=(n<=0||n>1?1:n), n:=Floor(4606*255*255*(1-n)*(1-n))
      , (mode=4) && color:=((color-1)//w)<<16|Mod(color-1,w)
    }
  }
  return info[key]:=[v, w, h, seterr, err1, err0, mode, color, n, comment]
}

GetBitsFromScreen(&x:=0, &y:=0, &w:=0, &h:=0
  , ScreenShot:=1, &zx:=0, &zy:=0, &zw:=0, &zh:=0)
{
  static CAPTUREBLT:=""
  (!IsObject(this.bits) && this.bits:={Scan0:0, hBM:0, oldzw:0, oldzh:0})
  , bits:=this.bits
  if (!ScreenShot && bits.Scan0)
  {
    zx:=bits.zx, zy:=bits.zy, zw:=bits.zw, zh:=bits.zh
    , w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
    , h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
    return bits
  }
  cri:=A_IsCritical
  Critical
  if (id:=this.BindWindow(0,0,1))
  {
    id:=WinGetID("ahk_id " id)
    WinGetPos &zx, &zy, &zw, &zh, id
  }
  if (!id)
    zx:=SysGet(76), zy:=SysGet(77), zw:=SysGet(78), zh:=SysGet(79)
  this.UpdateBits(bits, zx, zy, zw, zh)
  , w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
  , h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
  if (!ScreenShot || w<1 || h<1 || !bits.hBM)
  {
    Critical(cri)
    return bits
  }
  if IsSet(GetBitsFromScreen2) && (GetBitsFromScreen2 is Func)
    && GetBitsFromScreen2(bits, x-zx, y-zy, w, h)
  {
    ; Each small range of data obtained from DXGI must be
    ; copied to the screenshot cache using FindText().CopyBits()
    zx:=bits.zx, zy:=bits.zy, zw:=bits.zw, zh:=bits.zh
    Critical(cri)
    return bits
  }
  if (CAPTUREBLT="")  ; thanks Descolada
  {
    DllCall("Dwmapi\DwmIsCompositionEnabled", "Int*", &i:=0)
    CAPTUREBLT:=i ? 0 : 0x40000000
  }
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",bits.hBM, "Ptr")
  if (id)
  {
    if (mode:=this.BindWindow(0,0,0,1))<2
    {
      hDC:=DllCall("GetDCEx", "Ptr",id, "Ptr",0, "int",3, "Ptr")
      DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , "Ptr",hDC, "int",x-zx, "int",y-zy, "uint",0xCC0020|CAPTUREBLT)
      DllCall("ReleaseDC", "Ptr",id, "Ptr",hDC)
    }
    else
    {
      hBM2:=this.CreateDIBSection(zw, zh)
      mDC2:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
      oBM2:=DllCall("SelectObject", "Ptr",mDC2, "Ptr",hBM2, "Ptr")
      DllCall("PrintWindow", "Ptr",id, "Ptr",mDC2, "uint",(mode>3)*3)
      DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
        , "Ptr",mDC2, "int",x-zx, "int",y-zy, "uint",0xCC0020)
      DllCall("SelectObject", "Ptr",mDC2, "Ptr",oBM2)
      DllCall("DeleteDC", "Ptr",mDC2)
      DllCall("DeleteObject", "Ptr",hBM2)
    }
  }
  else
  {
    hDC:=DllCall("GetWindowDC","Ptr",id:=DllCall("GetDesktopWindow","Ptr"),"Ptr")
    DllCall("BitBlt","Ptr",mDC,"int",x-zx,"int",y-zy,"int",w,"int",h
      , "Ptr",hDC, "int",x, "int",y, "uint",0xCC0020|CAPTUREBLT)
    DllCall("ReleaseDC", "Ptr",id, "Ptr",hDC)
  }
  if this.CaptureCursor(0,0,0,0,0,1)
    this.CaptureCursor(mDC, zx, zy, zw, zh)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteDC", "Ptr",mDC)
  Critical(cri)
  return bits
}

UpdateBits(bits, zx, zy, zw, zh)
{
  if (zw>bits.oldzw || zh>bits.oldzh || !bits.hBM)
  {
    Try DllCall("DeleteObject", "Ptr",bits.hBM)
    bits.hBM:=this.CreateDIBSection(zw, zh, bpp:=32, &ppvBits)
    , bits.Scan0:=(!bits.hBM ? 0:ppvBits)
    , bits.Stride:=((zw*bpp+31)//32)*4
    , bits.oldzw:=zw, bits.oldzh:=zh
  }
  bits.zx:=zx, bits.zy:=zy, bits.zw:=zw, bits.zh:=zh
}

CreateDIBSection(w, h, bpp:=32, &ppvBits:=0)
{
  NumPut("int",40, "int",w, "int",-h, "short",1, "short",bpp, bi:=Buffer(40,0))
  return DllCall("CreateDIBSection", "Ptr",0, "Ptr",bi
    , "int",0, "Ptr*",&ppvBits:=0, "Ptr",0, "int",0, "Ptr")
}

GetBitmapWH(hBM, &w, &h)
{
  bm:=Buffer(size:=(A_PtrSize=8 ? 32:24))
  , DllCall("GetObject", "Ptr",hBM, "int",size, "Ptr",bm)
  , w:=NumGet(bm,4,"int"), h:=Abs(NumGet(bm,8,"int"))
}

CopyHBM(hBM1, x1, y1, hBM2, x2, y2, w, h, Clear:=0, trans:=0, alpha:=255)
{
  if (w<1 || h<1 || !hBM1 || !hBM2)
    return
  mDC1:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM1:=DllCall("SelectObject", "Ptr",mDC1, "Ptr",hBM1, "Ptr")
  mDC2:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM2:=DllCall("SelectObject", "Ptr",mDC2, "Ptr",hBM2, "Ptr")
  if (trans)
    DllCall("GdiAlphaBlend", "Ptr",mDC1, "int",x1, "int",y1, "int",w, "int",h
    , "Ptr",mDC2, "int",x2, "int",y2, "int",w, "int",h, "uint",alpha<<16)
  else
    DllCall("BitBlt", "Ptr",mDC1, "int",x1, "int",y1, "int",w, "int",h
    , "Ptr",mDC2, "int",x2, "int",y2, "uint",0xCC0020)
  if (Clear)
    DllCall("BitBlt", "Ptr",mDC1, "int",x1, "int",y1, "int",w, "int",h
    , "Ptr",mDC1, "int",x1, "int",y1, "uint",MERGECOPY:=0xC000CA)
  DllCall("SelectObject", "Ptr",mDC1, "Ptr",oBM1)
  DllCall("DeleteDC", "Ptr",mDC1)
  DllCall("SelectObject", "Ptr",mDC2, "Ptr",oBM2)
  DllCall("DeleteDC", "Ptr",mDC2)
}

CopyBits(Scan01,Stride1,x1,y1,Scan02,Stride2,x2,y2,w,h,Reverse:=0)
{
  if (w<1 || h<1 || !Scan01 || !Scan02)
    return
  static init:="", MFCopyImage
  if (!init && init:=1)
  {
    MFCopyImage:=DllCall("GetProcAddress", "Ptr"
    , DllCall("LoadLibrary", "Str","Mfplat.dll", "Ptr")
    , "AStr","MFCopyImage", "Ptr")
  }
  if (MFCopyImage && !Reverse)  ; thanks QQ:RenXing
  {
    return DllCall(MFCopyImage
      , "Ptr",Scan01+y1*Stride1+x1*4, "int",Stride1
      , "Ptr",Scan02+y2*Stride2+x2*4, "int",Stride2
      , "uint",w*4, "uint",h)
  }
  ListLines (lls:=A_ListLines)?0:0
  p1:=Scan01+(y1-1)*Stride1+x1*4
  , p2:=Scan02+(y2-1)*Stride2+x2*4, w*=4
  if (Reverse)
    p2+=(h+1)*Stride2, Stride2:=-Stride2
  Loop h
    DllCall("RtlMoveMemory","Ptr",p1+=Stride1,"Ptr",p2+=Stride2,"Ptr",w)
  ListLines lls
}

DrawHBM(hBM, lines)
{
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",hBM, "Ptr")
  oldc:="", brush:=0, rect:=Buffer(16)
  For k,v in lines  ; [ [x, y, w, h, color] ]
  if IsObject(v)
  {
    if (oldc!=v[5])
    {
      oldc:=v[5], BGR:=(oldc&0xFF)<<16|oldc&0xFF00|(oldc>>16)&0xFF
      DllCall("DeleteObject", "Ptr",brush)
      brush:=DllCall("CreateSolidBrush", "UInt",BGR, "Ptr")
    }
    DllCall("SetRect", "Ptr",rect, "int",v[1], "int",v[2]
      , "int",v[1]+v[3], "int",v[2]+v[4])
    DllCall("FillRect", "Ptr",mDC, "Ptr",rect, "Ptr",brush)
  }
  DllCall("DeleteObject", "Ptr",brush)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteObject", "Ptr",mDC)
}

; Bind the window so that it can find images when obscured
; by other windows, it's equivalent to always being
; at the front desk. Unbind Window using FindText().BindWindow(0)

BindWindow(bind_id:=0, bind_mode:=0, get_id:=0, get_mode:=0)
{
  (!IsObject(this.bind) && this.bind:={id:0, mode:0, oldStyle:0})
  , bind:=this.bind
  if (get_id)
    return bind.id
  if (get_mode)
    return bind.mode
  if (bind_id)
  {
    bind.id:=bind_id:=this.Floor(bind_id)
    , bind.mode:=bind_mode, bind.oldStyle:=0
    if (bind_mode & 1)
    {
      i:=WinGetExStyle(bind_id)
      bind.oldStyle:=i
      WinSetTransparent(255, bind_id)
      Loop 30
      {
        Sleep 100
        i:=WinGetTransparent(bind_id)
      }
      Until (i=255)
    }
  }
  else
  {
    bind_id:=bind.id
    if (bind.mode & 1)
      WinSetExStyle(bind.oldStyle, bind_id)
    bind.id:=0, bind.mode:=0, bind.oldStyle:=0
  }
}

; Use FindText().CaptureCursor(1) to Capture Cursor
; Use FindText().CaptureCursor(0) to Cancel Capture Cursor

CaptureCursor(hDC:=0, zx:=0, zy:=0, zw:=0, zh:=0, get_cursor:=0)
{
  if (get_cursor)
    return this.Cursor
  if (hDC=1 || hDC=0) && (zw=0)
  {
    this.Cursor:=hDC
    return
  }
  mi:=Buffer(40, 0), NumPut("int", 16+A_PtrSize, mi)
  DllCall("GetCursorInfo", "Ptr",mi)
  bShow:=NumGet(mi, 4, "int")
  hCursor:=NumGet(mi, 8, "Ptr")
  x:=NumGet(mi, 8+A_PtrSize, "int")
  y:=NumGet(mi, 12+A_PtrSize, "int")
  if (!bShow) || (x<zx || y<zy || x>=zx+zw || y>=zy+zh)
    return
  ni:=Buffer(40, 0)
  DllCall("GetIconInfo", "Ptr",hCursor, "Ptr",ni)
  xCenter:=NumGet(ni, 4, "int")
  yCenter:=NumGet(ni, 8, "int")
  hBMMask:=NumGet(ni, (A_PtrSize=8?16:12), "Ptr")
  hBMColor:=NumGet(ni, (A_PtrSize=8?24:16), "Ptr")
  DllCall("DrawIconEx", "Ptr",hDC
    , "int",x-xCenter-zx, "int",y-yCenter-zy, "Ptr",hCursor
    , "int",0, "int",0, "int",0, "int",0, "int",3)
  DllCall("DeleteObject", "Ptr",hBMMask)
  DllCall("DeleteObject", "Ptr",hBMColor)
}

MCode(&code, hex)
{
  flag:=((hex~="[^\s\da-fA-F]")?1:4), hex:=RegExReplace(hex, "[\s=]")
  , code:=Buffer(len:=(flag=1 ? StrLen(hex)//4*3+3 : StrLen(hex)//2))
  DllCall("crypt32\CryptStringToBinary", "Str",hex, "uint",0
    , "uint",flag, "Ptr",code, "uint*",&len, "Ptr",0, "Ptr",0)
  DllCall("VirtualProtect", "Ptr",code, "Ptr",len, "uint",0x40, "Ptr*",0)
}

bin2hex(addr, size, base64:=1)
{
  flag:=(base64 ? 1|0x40000000 : 4|0x0000000C)
  Loop 2
    p:=(A_Index=1 ? 0 : Buffer(len*2))
    , DllCall("Crypt32\CryptBinaryToString", "Ptr",addr, "uint",size
    , "uint",flag, "Ptr",p, "uint*",&len:=0)
  return RegExReplace(StrGet(p, len), "\s+")
}

base64tobit(s)
{
  ListLines (lls:=A_ListLines)?0:0
  static Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  Loop Parse, Chars
    if InStr(s, A_LoopField, 1)
      s:=StrReplace(s, A_LoopField, ((i:=A_Index-1)>>5&1)
      . (i>>4&1) . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1), 1)
  s:=RegExReplace(RegExReplace(s,"[^01]+"),"10*$")
  ListLines lls
  return s
}

bit2base64(s)
{
  ListLines (lls:=A_ListLines)?0:0
  s:=RegExReplace(s,"[^01]+")
  s.=SubStr("100000",1,6-Mod(StrLen(s),6))
  s:=RegExReplace(s,".{6}","|$0")
  Chars:="0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  Loop Parse, Chars
    s:=StrReplace(s, "|" . ((i:=A_Index-1)>>5&1)
    . (i>>4&1) . (i>>3&1) . (i>>2&1) . (i>>1&1) . (i&1), A_LoopField)
  ListLines lls
  return s
}

ASCII(s)
{
  if RegExMatch(s, "\$(\d+)\.([\w+/]+)", &r)
  {
    s:=RegExReplace(this.base64tobit(r[2]),".{" r[1] "}","$0`n")
    s:=StrReplace(StrReplace(s,"0","_"),"1","0")
  }
  else s:=""
  return s
}

; You can put the text library at the beginning of the script,
; and Use FindText().PicLib(Text,1) to add the text library to PicLib()'s Lib,
; Use FindText().PicLib("comment1|comment2|...") to get text images from Lib

PicLib(comments, add_to_Lib:=0, index:=1)
{
  (!IsObject(this.Lib) && this.Lib:=Map()), Lib:=this.Lib
  , (!Lib.Has(index) && Lib[index]:=Map()), Lib:=Lib[index]
  if (add_to_Lib)
  {
    re:="<([^>\n]*)>[^$\n]+\$[^`"'\r\n]+"
    Loop Parse, comments, "|"
      if RegExMatch(A_LoopField, re, &r)
      {
        s1:=Trim(r[1]), s2:=""
        Loop Parse, s1
          s2.="_" . Format("{:d}",Ord(A_LoopField))
        Lib[s2]:=r[0]
      }
    Lib[""]:=""
  }
  else
  {
    Text:=""
    Loop Parse, comments, "|"
    {
      s1:=Trim(A_LoopField), s2:=""
      Loop Parse, s1
        s2.="_" . Format("{:d}",Ord(A_LoopField))
      if Lib.Has(s2)
        Text.="|" . Lib[s2]
    }
    return Text
  }
}

; Decompose a string into individual characters and get their data

PicN(Number, index:=1)
{
  return this.PicLib(RegExReplace(Number,".","|$0"), 0, index)
}

; Use FindText().PicX(Text) to automatically cut into multiple characters
; Can't be used in ColorPos mode, because it can cause position errors

PicX(Text)
{
  if !RegExMatch(Text, "(<[^$\n]+)\$(\d+)\.([\w+/]+)", &r)
    return Text
  v:=this.base64tobit(r[3]), Text:=""
  c:=StrLen(StrReplace(v,"0"))<=StrLen(v)//2 ? "1":"0"
  txt:=RegExReplace(v,".{" r[2] "}","$0`n")
  While InStr(txt,c)
  {
    While !(txt~="m`n)^" c)
      txt:=RegExReplace(txt,"m`n)^.")
    i:=0
    While (txt~="m`n)^.{" i "}" c)
      i:=Format("{:d}",i+1)
    v:=RegExReplace(txt,"m`n)^(.{" i "}).*","$1")
    txt:=RegExReplace(txt,"m`n)^.{" i "}")
    if (v!="")
      Text.="|" r[1] "$" i "." this.bit2base64(v)
  }
  return Text
}

; Screenshot and retained as the last screenshot.

ScreenShot(x1:=0, y1:=0, x2:=0, y2:=0)
{
  this.FindText(,, x1, y1, x2, y2)
}

; Get the RGB color of a point from the last screenshot.
; If the point to get the color is beyond the range of
; Screen, it will return White color (0xFFFFFF).

GetColor(x, y, fmt:=1)
{
  bits:=this.GetBitsFromScreen(,,,,0,&zx,&zy,&zw,&zh)
  , c:=(x<zx || x>=zx+zw || y<zy || y>=zy+zh || !bits.Scan0)
  ? 0xFFFFFF : NumGet(bits.Scan0+(y-zy)*bits.Stride+(x-zx)*4,"uint")
  return (fmt ? Format("0x{:06X}",c&0xFFFFFF) : c)
}

; Set the RGB color of a point in the last screenshot

SetColor(x, y, color:=0x000000)
{
  bits:=this.GetBitsFromScreen(,,,,0,&zx,&zy,&zw,&zh)
  if !(x<zx || x>=zx+zw || y<zy || y>=zy+zh || !bits.Scan0)
    NumPut("uint", color, bits.Scan0+(y-zy)*bits.Stride+(x-zx)*4)
}

; Identify a line of text or verification code
; based on the result returned by FindText().
; offsetX is the maximum interval between two texts,
; if it exceeds, a "*" sign will be inserted.
; offsetY is the maximum height difference between two texts.
; overlapW is used to set the width of the overlap.
; Return Association array {text:Text, x:X, y:Y, w:W, h:H}

Ocr(ok, offsetX:=20, offsetY:=20, overlapW:=0)
{
  ocr_Text:=ocr_X:=ocr_Y:=min_X:=dx:=""
  For k,v in ok
    x:=v.1
    , min_X:=(A_Index=1 || x<min_X ? x : min_X)
    , max_X:=(A_Index=1 || x>max_X ? x : max_X)
  While (min_X!="" && min_X<=max_X)
  {
    LeftX:=""
    For k,v in ok
    {
      x:=v.1, y:=v.2
      if (x<min_X) || (ocr_Y!="" && Abs(y-ocr_Y)>offsetY)
        Continue
      ; Get the leftmost X coordinates
      if (LeftX="" || x<LeftX)
        LeftX:=x, LeftY:=y, LeftW:=v.3, LeftH:=v.4, LeftOCR:=v.id
    }
    if (LeftX="")
      Break
    if (ocr_X="")
      ocr_X:=LeftX, min_Y:=LeftY, max_Y:=LeftY+LeftH
    ; If the interval exceeds the set value, add "*" to the result
    ocr_Text.=(ocr_Text!="" && LeftX>dx ? "*":"") . LeftOCR
    ; Update for next search
    min_X:=LeftX+LeftW-(overlapW>LeftW//2 ? LeftW//2:overlapW)
    , dx:=LeftX+LeftW+offsetX, ocr_Y:=LeftY
    , (LeftY<min_Y && min_Y:=LeftY)
    , (LeftY+LeftH>max_Y && max_Y:=LeftY+LeftH)
  }
  if (ocr_X="")
    ocr_X:=0, min_Y:=0, min_X:=0, max_Y:=0
  return {text:ocr_Text, x:ocr_X, y:min_Y
    , w: min_X-ocr_X, h: max_Y-min_Y}
}

; Sort the results of FindText() from left to right
; and top to bottom, ignore slight height difference

Sort(ok, dy:=10)
{
  if !IsObject(ok)
    return ok
  s:="", n:=150000, ypos:=[]
  For k,v in ok
  {
    x:=v.x, y:=v.y, add:=1
    For k1,v1 in ypos
    if Abs(y-v1)<=dy
    {
      y:=v1, add:=0
      Break
    }
    if (add)
      ypos.Push(y)
    s.=(y*n+x) "." k "|"
  }
  s:=Sort(Trim(s,"|"), "N D|")
  ok2:=[]
  Loop Parse, s, "|"
    ok2.Push( ok[StrSplit(A_LoopField,".")[2]] )
  return ok2
}

; Sort the results of FindText() according to the nearest distance

Sort2(ok, px, py)
{
  if !IsObject(ok)
    return ok
  s:=""
  For k,v in ok
    s.=((v.x-px)**2+(v.y-py)**2) "." k "|"
  s:=Sort(Trim(s,"|"), "N D|")
  ok2:=[]
  Loop Parse, s, "|"
    ok2.Push( ok[StrSplit(A_LoopField,".")[2]] )
  return ok2
}

; Sort the results of FindText() according to the search direction

Sort3(ok, dir:=1)
{
  if !IsObject(ok)
    return ok
  s:="", n:=150000
  For k,v in ok
    x:=v.1, y:=v.2
    , s.=(dir=1 ? y*n+x
    : dir=2 ? y*n-x
    : dir=3 ? -y*n+x
    : dir=4 ? -y*n-x
    : dir=5 ? x*n+y
    : dir=6 ? x*n-y
    : dir=7 ? -x*n+y
    : dir=8 ? -x*n-y : y*n+x) "." k "|"
  s:=Sort(Trim(s,"|"), "N D|")
  ok2:=[]
  Loop Parse, s, "|"
    ok2.Push( ok[StrSplit(A_LoopField,".")[2]] )
  return ok2
}

; Prompt mouse position in remote assistance

MouseTip(x:="", y:="", w:=10, h:=10, d:=3)
{
  if (x="")
  {
    pt:=Buffer(16,0), DllCall("GetCursorPos", "Ptr",pt)
    x:=NumGet(pt,0,"uint"), y:=NumGet(pt,4,"uint")
  }
  Loop 4
  {
    this.RangeTip(x-w, y-h, 2*w+1, 2*h+1, (A_Index & 1 ? "Red":"Blue"), d)
    Sleep 500
  }
  this.RangeTip()
}

; Shows a range of the borders, similar to the ToolTip

RangeTip(x:="", y:="", w:="", h:="", color:="Red", d:=3)
{
  static Range:=Map()
  if (x="")
  {
    Loop 4
      if (Range.Has(i:=A_Index) && Range[i])
        Range[i].Destroy(), Range[i]:=0
    return
  }
  if !(Range.Has(1) && Range[1])
  {
    Loop 4
      Range[A_Index]:=Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000")
  }
  x:=(IsNumBer(x)?x:0), y:=(IsNumBer(y)?y:0)
  , w:=(IsNumBer(w)?w:0), h:=(IsNumBer(h)?h:0), d:=(IsNumBer(d)?d:0)
  Loop 4
  {
    i:=A_Index
    , x1:=(i=2 ? x+w : x-d)
    , y1:=(i=3 ? y+h : y-d)
    , w1:=(i=1 || i=3 ? w+2*d : d)
    , h1:=(i=2 || i=4 ? h+2*d : d)
    Range[i].BackColor:=color
    Range[i].Show("NA x" x1 " y" y1 " w" w1 " h" h1)
  }
}

; Use RButton to select the screen range

GetRange(ww:=25, hh:=8, key:="RButton")
{
  static Gui_Off:="", hk, GetRange_HotkeyIf:=""
  if (!Gui_Off)
    Gui_Off:=this.GetRange.Bind(this, "Off")
  if (ww="Off")
    return hk:=Trim(A_ThisHotkey, "*")
  ;---------------------
  Try GetRange_HotkeyIf.Destroy()
  GetRange_HotkeyIf:=_Gui:=Gui()
  _Gui.Opt "-Caption +ToolWindow +E0x80000"
  _Gui.Title:="GetRange_HotkeyIf"
  _Gui.Show "NA x0 y0 w0 h0"
  ;---------------------
  HotIfWinExist "GetRange_HotkeyIf"
  keys:=key "|Up|Down|Left|Right"
  For k,v in StrSplit(keys, "|")
  {
    KeyWait v
    Try Hotkey "*" v, Gui_Off, "On"
  }
  KeyWait "Ctrl"
  HotIfWinExist
  ;---------------------
  Critical (cri:=A_IsCritical)?"Off":"Off"
  CoordMode "Mouse"
  tip:=this.Lang("s5")
  hk:="", oldx:=oldy:="", keydown:=0
  Loop
  {
    Sleep 50
    MouseGetPos &x, &y
    if (hk=key) || GetKeyState(key,"P") || GetKeyState("Ctrl","P")
    {
      keydown++
      if (keydown=1)
        MouseGetPos &x1, &y1, &Bind_ID
      KeyWait key
      KeyWait "Ctrl"
      hk:=""
      if (keydown>1)
        Break
    }
    else if (hk="Up") || GetKeyState("Up","P")
      (hh>1 && hh--), hk:=""
    else if (hk="Down") || GetKeyState("Down","P")
      hh++, hk:=""
    else if (hk="Left") || GetKeyState("Left","P")
      (ww>1 && ww--), hk:=""
    else if (hk="Right") || GetKeyState("Right","P")
      ww++, hk:=""
    this.RangeTip((keydown?x1:x)-ww, (keydown?y1:y)-hh
      , 2*ww+1, 2*hh+1, (A_MSec<500?"Red":"Blue"))
    if (oldx=x && oldy=y)
      Continue
    oldx:=x, oldy:=y
    ToolTip "x: " (keydown?x1:x) " y: " (keydown?y1:y) "`n" tip
  }
  ToolTip
  this.RangeTip()
  HotIfWinExist "GetRange_HotkeyIf"
  For k,v in StrSplit(keys, "|")
    Try Hotkey "*" v, Gui_Off, "Off"
  HotIfWinExist
  GetRange_HotkeyIf.Destroy
  Critical(cri)
  return [x1-ww, y1-hh, x1+ww, y1+hh, Bind_ID]
}

; Take a screenshot to Clipboard or File, or only get Range

SnapShot(ScreenShot:=1, key:="LButton")
{
  static Gui_Off:="", hk, SnapShot_HotkeyIf:="", SnapShot_Box:=""
  if (!Gui_Off)
    Gui_Off:=this.SnapShot.Bind(this, "Off")
  if (ScreenShot="Off")
    return hk:=Trim(A_ThisHotkey, "*")
  n:=150000, x:=y:=-n, w:=h:=2*n
  hBM:=this.BitmapFromScreen(&x,&y,&w,&h,ScreenShot,&zx,&zy,&zw,&zh)
  ;---------------
  Try SnapShot_HotkeyIf.Destroy()    ; WS_EX_NOACTIVATE:=0x08000000
  SnapShot_HotkeyIf:=_Gui:=Gui()
  _Gui.Opt "+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000"
  _Gui.MarginX:=0, _Gui.MarginY:=0
  _Gui.Add "Pic", "w" zw " h" zh, "HBITMAP:*" hBM
  _Gui.Title:="SnapShot_HotkeyIf"
  _Gui.Show "NA x" zx " y" zy " w" zw " h" zh
  ;---------------
  Try SnapShot_Box.Destroy()
  SnapShot_Box:=_Gui:=Gui()
  _Gui.Opt "+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000"
  box_id:=_Gui.Hwnd
  _Gui.MarginX:=0, _Gui.MarginY:=0
  _Gui.SetFont "s12"
  For k,v in StrSplit(this.Lang("s15"), "|")
    id:=_Gui.Add("Button", (k=1?"":"x+0"), v)
  id.GetPos(&pX, &pY, &pW, &pH)
  box_w:=pX+pW+10, box_h:=pH+10
  _Gui.Title:="SnapShot_Box"
  _Gui.Show "Hide"
  ;---------------
  HotIfWinExist "SnapShot_HotkeyIf"
  keys:=key "|RButton|Esc|Up|Down|Left|Right"
  For k,v in StrSplit(keys, "|")
  {
    KeyWait v
    Try Hotkey "*" v, Gui_Off, "On"
  }
  HotIfWinExist
  ;---------------
  Critical (cri:=A_IsCritical)?"Off":"Off"
  CoordMode "Mouse"
  Loop
  {  ;// For ReTry
  tip:=this.Lang("s16")
  hk:="", oldx:=oldy:="", ok:=0, d:=10, oldt:=0, oldf:=""
  x:=y:=w:=h:=0
  Loop
  {
    Sleep 50
    if (hk="RButton") || (hk="Esc") || GetKeyState("RButton","P") || GetKeyState("Esc","P")
      Break 2
    MouseGetPos &x1, &y1
    if (oldx=x1 && oldy=y1)
      Continue
    oldx:=x1, oldy:=y1
    ToolTip "x: " x1 " y: " y1 " w: 0 h: 0`n" tip
  }
  Until (hk=key) || GetKeyState(key,"P")
  Loop
  {
    Sleep 50
    MouseGetPos &x2, &y2
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x1-x2)+1, h:=Abs(y1-y2)+1
    this.RangeTip(x, y, w, h, (A_MSec<500 ? "Red":"Blue"))
    if (oldx=x2 && oldy=y2)
      Continue
    oldx:=x2, oldy:=y2
    ToolTip "x: " x " y: " y " w: " w " h: " h "`n" tip
  }
  Until !GetKeyState(key,"P")
  hk:=""
  Loop
  {
    Sleep 50
    MouseGetPos &x3, &y3
    x1:=x, y1:=y, x2:=x+w-1, y2:=y+h-1
    , d1:=Abs(x3-x1)<=d, d2:=Abs(x3-x2)<=d
    , d3:=Abs(y3-y1)<=d, d4:=Abs(y3-y2)<=d
    , d5:=x3>x1+d && x3<x2-d, d6:=y3>y1+d && y3<y2-d
    , f:=(d1 && d3 ? 1 : d2 && d3 ? 2 : d1 && d4 ? 3
    : d2 && d4 ? 4 : d5 && d3 ? 5 : d5 && d4 ? 6
    : d6 && d1 ? 7 : d6 && d2 ? 8 : d5 && d6 ? 9 : 0)
    if (oldf!=f)
      oldf:=f, this.SetCursor(f=1 || f=4 ? "SIZENWSE"
      : f=2 || f=3 ? "SIZENESW" : f=5 || f=6 ? "SIZENS"
      : f=7 || f=8 ? "SIZEWE" : f=9 ? "SIZEALL" : "ARROW")
    ;--------------
    if (hk="Up") || GetKeyState("Up","P")
      hk:="", y--
    else if (hk="Down") || GetKeyState("Down","P")
      hk:="", y++
    else if (hk="Left") || GetKeyState("Left","P")
      hk:="", x--
    else if (hk="Right") || GetKeyState("Right","P")
      hk:="", x++
    else if (hk="RButton") || (hk="Esc") || GetKeyState("RButton","P") || GetKeyState("Esc","P")
      Break
    else if (hk=key) || GetKeyState(key,"P")
    {
      MouseGetPos(,, &id, &mc)
      if (id=box_id) && (mc="Button1")
      {
        KeyWait key
        this.RangeTip(), this.SetCursor()
        SnapShot_Box.Hide
        Continue 2
      }
      if (id=box_id) && (ok:=mc="Button2" ? 2 : mc="Button4" ? 1:100)
        Break
      SnapShot_Box.Hide
      ToolTip
      Loop
      {
        Sleep 50
        MouseGetPos &x4, &y4
        x1:=x, y1:=y, x2:=x+w-1, y2:=y+h-1, dx:=x4-x3, dy:=y4-y3
        , (f=1 ? (x1+=dx, y1+=dy) : f=2 ? (x2+=dx, y1+=dy)
        : f=3 ? (x1+=dx, y2+=dy) : f=4 ? (x2+=dx, y2+=dy)
        : f=5 ? y1+=dy : f=6 ? y2+=dy : f=7 ? x1+=dx : f=8 ? x2+=dx
        : f=9 ? (x1+=dx, y1+=dy, x2+=dx, y2+=dy) : 0)
        , (f ? this.RangeTip(Min(x1,x2), Min(y1,y2), Abs(x1-x2)+1, Abs(y1-y2)+1
        , (A_MSec<500 ? "Red":"Blue")) : 0)
      }
      Until !GetKeyState(key,"P")
      hk:="", x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x1-x2)+1, h:=Abs(y1-y2)+1
      if (f=9) && Abs(dx)<2 && Abs(dy)<2 && (ok:=(-oldt)+(oldt:=A_TickCount)<400)
        Break
    }
    this.RangeTip(x, y, w, h, (A_MSec<500 ? "Red":"Blue"))
    x1:=x+w-box_w, (x1<10 && x1:=10), (x1>zx+zw-box_w && x1:=zx+zw-box_w)
    , y1:=y+h+10, (y1>zy+zh-box_h && y1:=y-box_h), (y1<10 && y1:=10)
    SnapShot_Box.Show "NA x" x1 " y" y1
    ;-------------
    if (oldx=x3 && oldy=y3)
      Continue
    oldx:=x3, oldy:=y3
    ToolTip "x: " x " y: " y " w: " w " h: " h "`n" tip
  }
  Break
  }  ;// For ReTry
  HotIfWinExist "SnapShot_HotkeyIf"
  For k,v in StrSplit(keys, "|")
  {
    KeyWait v
    Try Hotkey "*" v, Gui_Off, "Off"
  }
  HotIfWinExist
  ToolTip
  this.RangeTip()
  this.SetCursor()
  SnapShot_Box.Destroy
  SnapShot_HotkeyIf.Destroy
  Critical(cri)
  ;---------------
  w:=Min(x+w,zx+zw), x:=Max(x,zx), w-=x
  h:=Min(y+h,zy+zh), y:=Max(y,zy), h-=y
  if (ok=1)
    this.SaveBitmapToFile(0, hBM, x-zx, y-zy, w, h)
  else if (ok=2)
  {
    f:=FileSelect("S18", A_Desktop "\1.bmp", "SaveAs", "Image (*.bmp)")
    this.SaveBitmapToFile(f, hBM, x-zx, y-zy, w, h)
  }
  DllCall("DeleteObject", "Ptr",hBM)
  return [x, y, x+w-1, y+h-1]
}

SetCursor(cursor:="", *)
{
  static init:=0, tab:=Map()
  if (!init && init:=1)
  {
    OnExit(this.SetCursor.Bind(this,"")), this.SetCursor()
    s:="ARROW,32512, SIZENWSE,32642, SIZENESW,32643"
      . ", SIZEWE,32644, SIZENS,32645, SIZEALL,32646"
      . ", IBEAM,32513, WAIT,32514, CROSS,32515, UPARROW,32516"
      . ", NO,32648, HAND,32649, APPSTARTING,32650, HELP,32651"
    For i,v in StrSplit(s, ",", " ")
      (i&1) ? (k:=v) : (tab[k]:=DllCall("CopyImage", "Ptr"
      , DllCall("LoadCursor", "Ptr",0, "Ptr",v, "Ptr")
      , "int",2, "int",0, "int",0, "int",0, "Ptr"))
  }
  if (cursor!="") && tab.Has(cursor)
    DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr",tab[cursor]
    , "int",2, "int",0, "int",0, "int",0, "Ptr"), "int",32512)
  else
    DllCall("SystemParametersInfo", "int",0x57, "int",0, "Ptr",0, "int",0)
}

BitmapFromScreen(&x:=0, &y:=0, &w:=0, &h:=0
  , ScreenShot:=1, &zx:=0, &zy:=0, &zw:=0, &zh:=0)
{
  bits:=this.GetBitsFromScreen(&x,&y,&w,&h,ScreenShot,&zx,&zy,&zw,&zh)
  if (w<1 || h<1 || !bits.hBM)
    return
  hBM:=this.CreateDIBSection(w, h)
  this.CopyHBM(hBM, 0, 0, bits.hBM, x-zx, y-zy, w, h, 1)
  return hBM
}

; Quickly save screen image to BMP file for debugging
; if file = 0 or "", save to Clipboard

SavePic(file:=0, x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  hBM:=this.BitmapFromScreen(&x, &y, &w, &h, ScreenShot)
  this.SaveBitmapToFile(file, hBM)
  DllCall("DeleteObject", "Ptr",hBM)
}

; Save Bitmap To File, if file = 0 or "", save to Clipboard
; hBM_or_file can be a bitmap handle or file path, eg: "c:\1.bmp"

SaveBitmapToFile(file, hBM_or_file, x:=0, y:=0, w:=0, h:=0)
{
  if IsNumber(hBM_or_file)
    hBM_or_file:="HBITMAP:*" hBM_or_file
  if !hBM:=DllCall("CopyImage", "Ptr",LoadPicture(hBM_or_file)
  , "int",0, "int",0, "int",0, "uint",0x2008)
    return
  if (file) || (w!=0 && h!=0)
  {
    (w=0 || h=0) && this.GetBitmapWH(hBM, &w, &h)
    hBM2:=this.CreateDIBSection(w, -h, bpp:=(file ? 24 : 32))
    this.CopyHBM(hBM2, 0, 0, hBM, x, y, w, h)
    DllCall("DeleteObject", "Ptr",hBM), hBM:=hBM2
  }
  dib:=Buffer(dib_size:=(A_PtrSize=8 ? 104:84))
  , DllCall("GetObject", "Ptr",hBM, "int",dib_size, "Ptr",dib)
  , pbi:=dib.Ptr+(bitmap_size:=A_PtrSize=8 ? 32:24)
  , size:=NumGet(pbi+20, "uint"), pBits:=NumGet(pbi-A_PtrSize, "Ptr")
  if (!file)
  {
    hdib:=DllCall("GlobalAlloc", "uint",2, "Ptr",40+size, "Ptr")
    pdib:=DllCall("GlobalLock", "Ptr",hdib, "Ptr")
    DllCall("RtlMoveMemory", "Ptr",pdib, "Ptr",pbi, "Ptr",40)
    DllCall("RtlMoveMemory", "Ptr",pdib+40, "Ptr",pBits, "Ptr",size)
    DllCall("GlobalUnlock", "Ptr",hdib)
    DllCall("OpenClipboard", "Ptr",0)
    DllCall("EmptyClipboard")
    if !DllCall("SetClipboardData", "uint",8, "Ptr",hdib)
      DllCall("GlobalFree", "Ptr",hdib)
    DllCall("CloseClipboard")
  }
  else
  {
    if InStr(file,"\") && !FileExist(dir:=RegExReplace(file,"[^\\]*$"))
      Try DirCreate(dir)
    bf:=Buffer(14, 0), NumPut("short", 0x4D42, bf)
    NumPut("uint", 54+size, bf, 2), NumPut("uint", 54, bf, 10)
    f:=FileOpen(file, "w"), f.RawWrite(bf, 14)
    , f.RawWrite(pbi+0, 40), f.RawWrite(pBits+0, size), f.Close()
  }
  DllCall("DeleteObject", "Ptr",hBM)
}

; Show the saved Picture file

ShowPic(file:="", show:=1, &x:="", &y:="", &w:="", &h:="")
{
  if (file="")
  {
    this.ShowScreenShot()
    return
  }
  if !(hBM:=LoadPicture(file))
    return
  this.GetBitmapWH(hBM, &w, &h)
  bits:=this.GetBitsFromScreen(,,,,0,&x,&y,&zw,&zh)
  this.UpdateBits(bits, x, y, Max(w,zw), Max(h,zh))
  this.CopyHBM(bits.hBM, 0, 0, hBM, 0, 0, w, h)
  DllCall("DeleteObject", "Ptr",hBM)
  if (show)
    this.ShowScreenShot(x, y, x+w-1, y+h-1, 0)
}

; Show the memory Screenshot for debugging

ShowScreenShot(x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  static hPic, oldx, oldy, oldw, oldh, FindText_Screen:=""
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
  {
    if (FindText_Screen)
      FindText_Screen.Destroy(), FindText_Screen:=""
    return
  }
  x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  if !hBM:=this.BitmapFromScreen(&x,&y,&w,&h,ScreenShot)
    return
  ;---------------
  if (!FindText_Screen)
  {
    FindText_Screen:=_Gui:=Gui()  ; WS_EX_NOACTIVATE:=0x08000000
    _Gui.Opt "+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000"
    _Gui.Name:="FindText_Screen"
    _Gui.MarginX:=0, _Gui.MarginY:=0
    id:=_Gui.Add("Pic", "w" w " h" h), hPic:=id.Hwnd
    _Gui.Title:="Show Pic"
    _Gui.Show "NA x" x " y" y " w" w " h" h
    oldx:=x, oldy:=y, oldw:=w, oldh:=h
  }
  else if (oldx!=x || oldy!=y || oldw!=w || oldh!=h)
  {
    if (oldw!=w || oldh!=h)
      FindText_Screen[hPic].Move(,, w, h)
    FindText_Screen.Show "NA x" x " y" y " w" w " h" h
    oldx:=x, oldy:=y, oldw:=w, oldh:=h
  }
  this.BitmapToWindow(hPic, 0, 0, hBM, 0, 0, w, h)
  DllCall("DeleteObject", "Ptr",hBM)
}

BitmapToWindow(hwnd, x1, y1, hBM, x2, y2, w, h)
{
  mDC:=DllCall("CreateCompatibleDC", "Ptr",0, "Ptr")
  oBM:=DllCall("SelectObject", "Ptr",mDC, "Ptr",hBM, "Ptr")
  hDC:=DllCall("GetDC", "Ptr",hwnd, "Ptr")
  DllCall("BitBlt", "Ptr",hDC, "int",x1, "int",y1, "int",w, "int",h
    , "Ptr",mDC, "int",x2, "int",y2, "uint",0xCC0020)
  DllCall("ReleaseDC", "Ptr",hwnd, "Ptr",hDC)
  DllCall("SelectObject", "Ptr",mDC, "Ptr",oBM)
  DllCall("DeleteDC", "Ptr",mDC)
}

; Quickly get the search data of screen image

GetTextFromScreen(x1, y1, x2, y2, Threshold:=""
  , ScreenShot:=1, &rx:="", &ry:="", cut:=1)
{
  x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(&x,&y,&w,&h,ScreenShot,&zx,&zy)
  if (w<1 || h<1 || !bits.Scan0)
  {
    return
  }
  ListLines (lls:=A_ListLines)?0:0
  gray:=Map(), gray.Default:=0
  j:=bits.Stride-w*4, p:=bits.Scan0+(y-zy)*bits.Stride+(x-zx)*4-4-j
  Loop h + 0*(k:=0)
  Loop w + 0*(p+=j)
    c:=NumGet(p+=4,"uint")
    , gray[++k]:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
  if InStr(Threshold,"**")
  {
    Threshold:=StrReplace(Threshold,"*")
    if (Threshold="")
      Threshold:=50
    s:="", sw:=w, w-=2, h-=2, x++, y++
    Loop h + 0*(y1:=0)
    Loop w + 0*(y1++)
      i:=y1*sw+A_Index+1, j:=gray[i]+Threshold
      , s.=( gray[i-1]>j || gray[i+1]>j
      || gray[i-sw]>j || gray[i+sw]>j
      || gray[i-sw-1]>j || gray[i-sw+1]>j
      || gray[i+sw-1]>j || gray[i+sw+1]>j ) ? "1":"0"
    Threshold:="**" Threshold
  }
  else
  {
    Threshold:=StrReplace(Threshold,"*")
    if (Threshold="")
    {
      pp:=Map(), pp.Default:=0
      Loop 256
        pp[A_Index-1]:=0
      Loop w*h
        pp[gray[A_Index]]++
      IP0:=IS0:=0
      Loop 256
        k:=A_Index-1, IP0+=k*pp[k], IS0+=pp[k]
      Threshold:=Floor(IP0/IS0)
      Loop 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP0-IP1, IS2:=IS0-IS1
        if (IS1!=0 && IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
    }
    s:=""
    Loop w*h
      s.=gray[A_Index]<=Threshold ? "1":"0"
    Threshold:="*" Threshold
  }
  ListLines lls
  ;--------------------
  w:=Format("{:d}",w), CutUp:=CutDown:=0
  if (cut=1)
  {
    re1:="(^0{" w "}|^1{" w "})"
    re2:="(0{" w "}$|1{" w "}$)"
    While (s~=re1)
      s:=RegExReplace(s,re1), CutUp++
    While (s~=re2)
      s:=RegExReplace(s,re2), CutDown++
  }
  rx:=x+w//2, ry:=y+CutUp+(h-CutUp-CutDown)//2
  s:="|<>" Threshold "$" w "." this.bit2base64(s)
  ;--------------------
  return s
}

; Wait for the screen image to change within a few seconds
; Take a Screenshot before using it: FindText().ScreenShot()

WaitChange(time:=-1, x1:=0, y1:=0, x2:=0, y2:=0)
{
  hash:=this.GetPicHash(x1, y1, x2, y2, 0)
  time:=this.Floor(time), timeout:=A_TickCount+Round(time*1000)
  Loop
  {
    if (hash!=this.GetPicHash(x1, y1, x2, y2, 1))
      return 1
    if (time>=0 && A_TickCount>=timeout)
      Break
    Sleep 10
  }
  return 0
}

; Wait for the screen image to stabilize

WaitNotChange(time:=1, timeout:=30, x1:=0, y1:=0, x2:=0, y2:=0)
{
  oldhash:="", timeout:=A_TickCount+Round(this.Floor(timeout)*1000)
  Loop
  {
    hash:=this.GetPicHash(x1, y1, x2, y2, 1), t:=A_TickCount
    if (hash!=oldhash)
      oldhash:=hash, timeout2:=t+Round(this.Floor(time)*1000)
    if (t>=timeout2)
      return 1
    if (t>=timeout)
      return 0
    Sleep 100
  }
}

GetPicHash(x1:=0, y1:=0, x2:=0, y2:=0, ScreenShot:=1)
{
  static init:=DllCall("LoadLibrary", "Str","ntdll", "Ptr")
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(&x,&y,&w,&h,ScreenShot,&zx,&zy), x-=zx, y-=zy
  if (w<1 || h<1 || !bits.Scan0)
    return 0
  hash:=0, Stride:=bits.Stride, p:=bits.Scan0+(y-1)*Stride+x*4, w*=4
  Loop h
    hash:=(hash*31+DllCall("ntdll\RtlComputeCrc32", "uint",0
      , "Ptr",p+=Stride, "uint",w, "uint"))&0xFFFFFFFF
  return hash
}

WindowToScreen(&x, &y, x1, y1, id:="")
{
  if (!id)
    id:=WinGetID("A")
  rect:=Buffer(16, 0)
  , DllCall("GetWindowRect", "Ptr",id, "Ptr",rect)
  , x:=x1+NumGet(rect,"int"), y:=y1+NumGet(rect,4,"int")
}

ScreenToWindow(&x, &y, x1, y1, id:="")
{
  this.WindowToScreen(&dx, &dy, 0, 0, id), x:=x1-dx, y:=y1-dy
}

ClientToScreen(&x, &y, x1, y1, id:="")
{
  if (!id)
    id:=WinGetID("A")
  pt:=Buffer(8, 0), NumPut("int64", 0, pt)
  , DllCall("ClientToScreen", "Ptr",id, "Ptr",pt)
  , x:=x1+NumGet(pt,"int"), y:=y1+NumGet(pt,4,"int")
}

ScreenToClient(&x, &y, x1, y1, id:="")
{
  this.ClientToScreen(&dx, &dy, 0, 0, id), x:=x1-dx, y:=y1-dy
}

; It is not like FindText always use Screen Coordinates,
; But like built-in command ImageSearch using CoordMode Settings
; ImageFile can use "*n *TransBlack-White-RRGGBB... d:\a.bmp"

ImageSearch(&rx:="", &ry:="", x1:=0, y1:=0, x2:=0, y2:=0
  , ImageFile:="", ScreenShot:=1, FindAll:=0)
{
  dx:=dy:=0
  if (A_CoordModePixel="Window")
    this.WindowToScreen(&dx, &dy, 0, 0)
  else if (A_CoordModePixel="Client")
    this.ClientToScreen(&dx, &dy, 0, 0)
  text:=""
  Loop Parse, ImageFile, "|"
  if (v:=Trim(A_LoopField))!=""
  {
    text.=InStr(v,"$") ? "|" v : "|##"
    . (RegExMatch(v, "(^|\s)\*(\d+)\s", &r)
    ? Format("{:06X}", r[2]<<16|r[2]<<8|r[2]) : "000000")
    . (RegExMatch(v, "i)(^|\s)\*Trans([\-\w]+)\s", &r)
    ? "-" . Trim(r[2],"-") : "") . "$"
    . Trim(RegExReplace(v, "(?<=^|\s)\*\S+"))
  }
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x1:=y1:=-n, x2:=y2:=n
  if (ok:=this.FindText(,, x1+dx, y1+dy, x2+dx, y2+dy
    , 0, 0, text, ScreenShot, FindAll))
  {
    For k,v in ok  ; you can use ok:=FindText().ok
      v.1-=dx, v.2-=dy, v.x-=dx, v.y-=dy
    rx:=ok[1].1, ry:=ok[1].2
    return ok
  }
  else
  {
    rx:=ry:=""
    return 0
  }
}

; It is not like FindText always use Screen Coordinates,
; But like built-in command PixelSearch using CoordMode Settings
; ColorID can use "RRGGBB-DRDGDB|RRGGBB-DRDGDB", Variation in 0-255

PixelSearch(&rx:="", &ry:="", x1:=0, y1:=0, x2:=0, y2:=0
  , ColorID:="", Variation:=0, ScreenShot:=1, FindAll:=0)
{
  n:=this.Floor(Variation), text:=Format("##{:06X}$0/0", n<<16|n<<8|n)
  Loop Parse, ColorID, "|"
  if (v:=Trim(A_LoopField))!=""
    text.="/" v
  return this.ImageSearch(&rx, &ry, x1, y1, x2, y2, text, ScreenShot, FindAll)
}

; Pixel count of certain colors within the range indicated by Screen Coordinates
; ColorID can use "RRGGBB-DRDGDB|RRGGBB-DRDGDB", Variation in 0-255

PixelCount(x1:=0, y1:=0, x2:=0, y2:=0, ColorID:="", Variation:=0, ScreenShot:=1)
{
  x1:=this.Floor(x1), y1:=this.Floor(y1), x2:=this.Floor(x2), y2:=this.Floor(y2)
  if (x1=0 && y1=0 && x2=0 && y2=0)
    n:=150000, x:=y:=-n, w:=h:=2*n
  else
    x:=Min(x1,x2), y:=Min(y1,y2), w:=Abs(x2-x1)+1, h:=Abs(y2-y1)+1
  bits:=this.GetBitsFromScreen(&x,&y,&w,&h,ScreenShot,&zx,&zy), x-=zx, y-=zy
  sum:=0, s1:=Buffer(4), s0:=Buffer(4)
  , ini:={ bits:bits, ss:0, s1:s1.Ptr, s0:s0.Ptr
  , err1:0, err0:0, allpos_max:0, zoomW:1, zoomH:1 }
  , n:=this.Floor(Variation), text:=Format("##{:06X}$0/0", n<<16|n<<8|n)
  Loop Parse, ColorID, "|"
  if (v:=Trim(A_LoopField))!=""
    text.="/" v
  if (w>0 && h>0 && bits.Scan0) && IsObject(j:=this.PicInfo(text))
    sum:=this.PicFind(ini, j, 1, x, y, w, h, 0)
  return sum
}

Click(x:="", y:="", other1:="", other2:="", GoBack:=0)
{
  CoordMode "Mouse", (bak:=A_CoordModeMouse)?"Screen":"Screen"
  if GoBack
    MouseGetPos &oldx, &oldy
  MouseMove x, y, 0
  Click x "," y "," other1 "," other2
  if GoBack
    MouseMove oldx, oldy, 0
  CoordMode "Mouse", bak
}

; Using ControlClick instead of Click, Use Screen Coordinates,
; If you want to click on the background window, please provide hwnd

ControlClick(x, y, WhichButton:="", ClickCount:=1, Opt:="", hwnd:="")
{
  if !hwnd
    hwnd:=DllCall("WindowFromPoint", "int64",y<<32|x&0xFFFFFFFF, "Ptr")
  pt:=Buffer(8,0), ScreenX:=x, ScreenY:=y
  Loop
  {
    NumPut("int64",0,pt), DllCall("ClientToScreen", "Ptr",hwnd, "Ptr",pt)
    , x:=ScreenX-NumGet(pt,"int"), y:=ScreenY-NumGet(pt,4,"int")
    , id:=DllCall("ChildWindowFromPoint", "Ptr",hwnd, "int64",y<<32|x, "Ptr")
    if (!id || id=hwnd)
      Break
    else hwnd:=id
  }
  DetectHiddenWindows (bak:=A_DetectHiddenWindows)?1:1
  PostMessage 0x200, 0, y<<16|x, hwnd  ; WM_MOUSEMOVE
  SetControlDelay -1
  ControlClick "x" x " y" y, hwnd,, WhichButton, ClickCount, "NA Pos " Opt
  DetectHiddenWindows bak
}

; Running AHK code dynamically with new threads

Class Thread
{
  __New(args*)
  {
    this.pid:=this.Exec(args*)
  }
  __Delete()
  {
    ProcessClose(this.pid)
  }
  Exec(s, Ahk:="", args:="")    ; required AHK v1.1.34+ and Ahk2Exe Use .exe
  {
    Ahk:=Ahk ? Ahk : A_IsCompiled ? A_ScriptFullPath : A_AhkPath
    s:="`nDllCall(`"SetWindowText`",`"Ptr`",A_ScriptHwnd,`"Str`",`"<AHK>`")`n"
      . "`n`n" . s, s:=RegExReplace(s, "\R", "`r`n")
    Try
    {
      shell:=ComObject("WScript.Shell")
      oExec:=shell.Exec("`"" Ahk "`" /script /force /CP0 * " args)
      oExec.StdIn.Write(s)
      oExec.StdIn.Close(), pid:=oExec.ProcessID
    }
    Catch
    {
      f:=A_Temp "\~ahk.tmp"
      s:="`r`nTry FileDelete(`"" f "`")`r`n" s
      Try FileDelete(f)
      FileAppend(s, f)
      r:=this.Clear.Bind(this)
      SetTimer(r, -3000)
      Run "`"" Ahk "`" /script /force /CP0 `"" f "`" " args,,, &pid
    }
    return pid
  }
  Clear()
  {
    Try FileDelete(A_Temp "\~ahk.tmp")
    SetTimer(,0)
  }
}

; FindText().QPC() Use the same as A_TickCount

QPC()
{
  static f:=0, c:=DllCall("QueryPerformanceFrequency", "Int*",&f)+(f/=1000)
  return (!DllCall("QueryPerformanceCounter", "Int64*",&c))*0+(c/f)
}

; FindText().ToolTip() Use the same as ToolTip

ToolTip(s:="", x:="", y:="", num:=1, arg:="")
{
  static ini:=Map(), tip:=Map(), timer:=Map()
  f:="ToolTip_" . this.Floor(num)
  if (s="")
  {
    ini[f]:=""
    Try tip[f].Destroy()
    return
  }
  ;-----------------
  r1:=A_CoordModeToolTip
  r2:=A_CoordModeMouse
  CoordMode "Mouse", "Screen"
  MouseGetPos &x1, &y1
  CoordMode "Mouse", r1
  MouseGetPos &x2, &y2
  CoordMode "Mouse", r2
  (x!="" && x:="x" (this.Floor(x)+x1-x2))
  , (y!="" && y:="y" (this.Floor(y)+y1-y2))
  , (x="" && y="" && x:="x" (x1+16) " y" (y1+16))
  ;-----------------
  (!IsObject(arg) && arg:={})
  bgcolor:=arg.HasOwnProp("bgcolor") ? arg.bgcolor : "FAFBFC"
  color:=arg.HasOwnProp("color") ? arg.color : "Black"
  font:=arg.HasOwnProp("font") ? arg.font : "Consolas"
  size:=arg.HasOwnProp("size") ? arg.size : "10"
  bold:=arg.HasOwnProp("bold") ? arg.bold : ""
  trans:=arg.HasOwnProp("trans") ? arg.trans & 255 : 255
  timeout:=arg.HasOwnProp("timeout") ? arg.timeout : ""
  ;-----------------
  r:=bgcolor "|" color "|" font "|" size "|" bold "|" trans "|" s
  if (!ini.Has(f) || ini[f]!=r)
  {
    ini[f]:=r
    Try tip[f].Destroy()
    tip[f]:=_Gui:=Gui()  ; WS_EX_LAYERED:=0x80000, WS_EX_TRANSPARENT:=0x20
    _Gui.Opt "+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x80020"
    _Gui.MarginX:=2, _Gui.MarginY:=2
    _Gui.BackColor:=bgcolor
    _Gui.SetFont "c" color " s" size " " bold, font
    _Gui.Add "Text",, s
    _Gui.Title:=f
    _Gui.Show "Hide"
    ;------------------
    DetectHiddenWindows (bak:=A_DetectHiddenWindows)?1:1
    WinSetTransparent(trans, _Gui.Hwnd)
    DetectHiddenWindows bak
  }
  else _Gui:=tip[f]
  _Gui.Opt "+AlwaysOnTop"
  _Gui.Show "NA " x " " y
  if (timeout)
  {
    (!timer.Has(f) && timer[f]:=this.ToolTip.Bind(this,"","","",num))
    SetTimer(timer[f], -Round(Abs(this.Floor(timeout)*1000))-1)
  }
}

; FindText().ObjView()  view object values for Debug

ObjView(obj, keyname:="")
{
  static Gui_DeBug:=""
  if IsObject(obj)
  {
    s:=""
    For k,v in (HasMethod(obj,"__Enum") ? obj : obj.OwnProps())
      s.=this.ObjView(v, keyname "[" (k is Number ? k : "`"" k "`"") "]")
  }
  else
    s:=keyname ": " (obj is Number ? obj : "`"" obj "`"") "`n"
  if (keyname!="")
    return s
  ;------------------
  Try Gui_DeBug.Destroy()
  Gui_DeBug:=_Gui:=Gui()
  _Gui.Opt "+LastFound +AlwaysOnTop"
  _Gui.Add("Button", "y270 w350 Default", "OK").OnEvent("Click", (*) => WinHide())
  _Gui.Add "Edit", "xp y10 w350 h250 -Wrap -WantReturn"
  _Gui["Edit1"].Value:=s
  _Gui.Title:="Debug view object values"
  _Gui.Show
  DetectHiddenWindows(0)
  WinWaitClose "ahk_id " WinExist()
  _Gui.Destroy
}

EditScroll(hEdit, regex:="", line:=0, pos:=0)
{
  s:=ControlGetText(hEdit)
  pos:=(regex!="") ? InStr(SubStr(s,1,s~=regex),"`n",0,-1)
    : (line>1) ? InStr(s,"`n",0,1,line-1) : pos
  SendMessage 0xB1, pos, pos, hEdit
  SendMessage 0xB7,,, hEdit
}

; Get Script from Compiled programs

GetScript()  ; thanks TAC109
{
  if (!A_IsCompiled)
    return
  For i,ahk in ["#1", ">AUTOHOTKEY SCRIPT<"]
  if (rc:=DllCall("FindResource", "Ptr",0, "Str",ahk, "Ptr",10, "Ptr"))
  && (sz:=DllCall("SizeofResource", "Ptr",0, "Ptr",rc, "Uint"))
  && (pt:=DllCall("LoadResource", "Ptr",0, "Ptr",rc, "Ptr"))
  && (pt:=DllCall("LockResource", "Ptr",pt, "Ptr"))
  && (DllCall("VirtualProtect", "Ptr",pt, "Ptr",sz, "UInt",0x4, "UInt*",0))
  && (InStr(StrGet(pt, 20, "utf-8"), "<COMPILER"))
    return this.FormatScript(StrGet(pt, sz, "utf-8"))
}

FormatScript(s, space:="", tab:="    ")
{
  ListLines (lls:=A_ListLines)?0:0
  VarSetStrCapacity(&ss, StrLen(s)*2), n:=0, w:=StrLen(tab)
  , space2:=StrReplace(Format("{:020d}",0), "0", tab)
  Loop Parse, s, "`n", "`r"
  {
    v:=Trim(A_LoopField), n2:=n
    if RegExMatch(v, "^\s*[{}][\s{}]*|\{\s*$|\{\s+;", &r)
      n+=w*(StrLen(RegExReplace(r[0], "[^{]"))
      -StrLen(RegExReplace(r[0], "[^}]"))), n2:=Min(n,n2)
    ss.=Space . SubStr(space2,1,n2) . v . "`r`n"
  }
  ListLines lls
  return SubStr(ss,1,-2)
}

; Get Gui object from Gui.Name

GuiFromName(GuiName:="")
{
  DetectHiddenWindows (bak:=A_DetectHiddenWindows)?1:1
  List:=WinGetList("ahk_class AutoHotkeyGUI ahk_pid " DllCall("GetCurrentProcessId"))
  DetectHiddenWindows bak
  For id in List
    Try if (_Gui:=GuiFromHwnd(id)) && (_Gui.Name=GuiName)
      return _Gui
}

; Get Last GuiControl object from Gui.Opt("+LastFound")

LastCtrl()
{
  For Ctrl in GuiFromHwnd(WinExist())
    last:=Ctrl
  return last
}

; Hide Gui from Gui.Opt("+LastFound")

Hide(id:="")
{
  if (id ? WinExist("ahk_id " id) : WinExist())
  {
    WinMinimize
    WinHide
    ToolTip
    DetectHiddenWindows 0
    WinWaitClose "ahk_id " WinExist()
  }
}


;==== Optional GUI interface ====


Gui(cmd, arg1:="", args*)
{
  static
  local _Gui, cri, lls
  (InStr("MouseMove|ToolTipOff", cmd) && ListLines(0))
  static init:=0
  if (!init && init:=1)
  {
    SavePicDir:=A_Temp "\Ahk_ScreenShot\"
    Gui_ := this.Gui.Bind(this)
    Gui_G := this.Gui.Bind(this, "G")
    Gui_Run := this.Gui.Bind(this, "Run")
    Gui_Off := this.Gui.Bind(this, "Off")
    Gui_Show := this.Gui.Bind(this, "Show")
    Gui_KeyDown := this.Gui.Bind(this, "KeyDown")
    Gui_LButtonDown := this.Gui.Bind(this, "LButtonDown")
    Gui_RButtonDown := this.Gui.Bind(this, "RButtonDown")
    Gui_MouseMove := this.Gui.Bind(this, "MouseMove")
    Gui_ScreenShot := this.Gui.Bind(this, "ScreenShot")
    Gui_ShowPic := this.Gui.Bind(this, "ShowPic")
    Gui_Slider := this.Gui.Bind(this, "Slider")
    Gui_ToolTip := this.Gui.Bind(this, "ToolTip")
    Gui_ToolTipOff := this.Gui.Bind(this, "ToolTipOff")
    Gui_SaveScr := this.Gui.Bind(this, "SaveScr")
    FindText_Capture:=FindText_Main:=FindText_SubPic:=""
    cri:=A_IsCritical
    Critical
    Lang:=this.Lang(,1), Tip_Text:=this.Lang(,2)
    Gui_("MakeCaptureWindow")
    Gui_("MakeMainWindow")
    OnMessage(0x100, Gui_KeyDown)
    OnMessage(0x201, Gui_LButtonDown)
    OnMessage(0x204, Gui_RButtonDown)
    OnMessage(0x200, Gui_MouseMove)
    A_TrayMenu.Add
    A_TrayMenu.Add Lang["s1"], Gui_Show
    if (!A_IsCompiled && A_LineFile=A_ScriptFullPath)
    {
      A_TrayMenu.Default:=Lang["s1"]
      A_TrayMenu.ClickCount:=1
      TraySetIcon "Shell32.dll", 23
    }
    Critical(cri)
    _Gui:=Gui("+LastFound")
    _Gui.Destroy
    ;-------------------
    Pics:=PrevControl:=x:=y:=oldx:=oldy:="", oldt:=0
  }
  Switch cmd, 1
  {
  Case "Off":
    return hk:=Trim(A_ThisHotkey, "*")
  Case "G":
    id:=this.LastCtrl()
    Try id.OnEvent("Click", Gui_Run)
    Try id.OnEvent("Change", Gui_Run)
    return
  Case "Run":
    Critical
    Gui_(arg1.Name)
    return
  Case "Show":
    _Gui:=FindText_Main
    _Gui.Show(arg1 ? "Center" : "")
    ControlFocus(hscr)
    return
  Case "Cancel", "Cancel2":
    WinHide
    return
  Case "MakeCaptureWindow":
    WindowColor:="0xDDEEFF"
    Try FindText_Capture.Destroy()
    FindText_Capture:=_Gui:=Gui()
    _Gui.Opt "+LastFound +AlwaysOnTop -DPIScale"
    _Gui.MarginX:=15, _Gui.MarginY:=15
    _Gui.BackColor:=WindowColor
    _Gui.SetFont "s12", "Verdana"
    Tab:=_Gui.Add("Tab3", "vMyTab1 -Wrap", StrSplit(Lang["s18"],"|"))
    Tab.UseTab(1)
    C_:=Map(), nW:=71, nH:=25, w:=h:=12, pW:=nW*(w+1)-1, pH:=(nH+1)*(h+1)-1
    _Gui.Opt "-Theme"
    ListLines (lls:=A_ListLines)?0:0
    Loop nW*(nH+1)
    {
      i:=A_Index, j:=i=1 ? "Section" : Mod(i,nW)=1 ? "xs y+1":"x+1"
      id:=_Gui.Add("Progress", j " w" w " h" h " -E0x20000 Smooth")
      C_[i]:=id.Hwnd
    }
    ListLines lls
    _Gui.Opt "+Theme"
    _Gui.Add "Slider", "xs w" pW " vMySlider1 +Center Page20 Line10 NoTicks AltSubmit"
    Gui_G()
    _Gui.Add "Slider", "ys h" pH " vMySlider2 +Center Page20 Line10 NoTicks AltSubmit +Vertical"
    Gui_G()
    Tab.UseTab(2)
    pW-=120+15
    id:=_Gui.Add("Text", "w" pW " h" pH " +Border Section"), parent_id:=id.Hwnd
    _Gui.Add "Slider", "xs w" pW " vMySlider3 +Center Page20 Line10 NoTicks AltSubmit"
    Gui_G()
    _Gui.Add "Slider", "ys h" pH " vMySlider4 +Center Page20 Line10 NoTicks AltSubmit +Vertical"
    Gui_G()
    _Gui.Add "ListBox", "ys w120 h200 vSelectBox AltSubmit 0x100"
    Gui_G()
    _Gui.Add "Button", "y+0 wp vClearAll", Lang["ClearAll"]
    Gui_G()
    _Gui.Add "Button", "y+0 wp vOpenDir", Lang["OpenDir"]
    Gui_G()
    _Gui.Add "Button", "y+0 wp vLoadPic", Lang["LoadPic"]
    Gui_G()
    _Gui.Add "Button", "y+0 wp vSavePic", Lang["SavePic"]
    Gui_G()
    Tab.UseTab()
    MySlider1:=MySlider2:=MySlider3:=MySlider4:=dx:=dy:=0
    ;--------------
    _Gui.Add "Button", "xm Hidden Section", Lang["Auto"]
    this.LastCtrl().GetPos(&pX, &pY, &pW, &pH)
    w:=Round(pW*0.75), i:=Round(w*3+15+pW*0.5-w*1.5)
    _Gui.Add "Button", "xm+" i " yp w" w " hp -Wrap vRepU", Lang["RepU"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp hp -Wrap vCutU", Lang["CutU"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp hp -Wrap vCutU3", Lang["CutU3"]
    Gui_G()
    _Gui.Add "Button", "xm wp hp -Wrap vRepL", Lang["RepL"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp hp -Wrap vCutL", Lang["CutL"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp hp -Wrap vCutL3", Lang["CutL3"]
    Gui_G()
    _Gui.Add "Button", "x+15 w" pW " hp -Wrap vAuto", Lang["Auto"]
    Gui_G()
    _Gui.Add "Button", "x+15 w" w " hp -Wrap vRepR", Lang["RepR"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp hp -Wrap vCutR", Lang["CutR"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp hp -Wrap vCutR3", Lang["CutR3"]
    Gui_G()
    _Gui.Add "Button", "xm+" i " wp hp -Wrap vRepD", Lang["RepD"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp hp -Wrap vCutD", Lang["CutD"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp hp -Wrap vCutD3", Lang["CutD3"]
    Gui_G()
    ;--------------
    _Gui.Add "Text", "x+60 ys+3 Section", Lang["SelGray"]
    _Gui.Add "Edit", "x+3 yp-3 w60 vSelGray ReadOnly"
    _Gui.Add "Text", "x+15 ys", Lang["SelColor"]
    _Gui.Add "Edit", "x+3 yp-3 w150 vSelColor ReadOnly"
    _Gui.Add "Text", "x+15 ys", Lang["SelR"]
    _Gui.Add "Edit", "x+3 yp-3 w60 vSelR ReadOnly"
    _Gui.Add "Text", "x+5 ys", Lang["SelG"]
    _Gui.Add "Edit", "x+3 yp-3 w60 vSelG ReadOnly"
    _Gui.Add "Text", "x+5 ys", Lang["SelB"]
    _Gui.Add "Edit", "x+3 yp-3 w60 vSelB ReadOnly"
    ;--------------
    x:=w*6+pW+15*4
    Tab:=_Gui.Add("Tab3", "x" x " y+15 -Wrap", StrSplit(Lang["s2"],"|"))
    Tab.UseTab(1)
    _Gui.Add "Text", "x+15 y+15", Lang["Threshold"]
    _Gui.Add "Edit", "x+15 w100 vThreshold"
    _Gui.Add "Button", "x+15 yp-3 vGray2Two", Lang["Gray2Two"]
    Gui_G()
    Tab.UseTab(2)
    _Gui.Add "Text", "x+15 y+15", Lang["GrayDiff"]
    _Gui.Add "Edit", "x+15 w100 vGrayDiff", "50"
    _Gui.Add "Button", "x+15 yp-3 vGrayDiff2Two", Lang["GrayDiff2Two"]
    Gui_G()
    Tab.UseTab(3)
    _Gui.Add "Text", "x+15 y+15", Lang["Similar1"] " 0"
    _Gui.Add "Slider", "x+0 w120 vSimilar1 +Center Page1 NoTicks ToolTip", 100
    Gui_G()
    _Gui.Add "Text", "x+0", "100"
    _Gui.Add "Button", "x+15 yp-3 vColor2Two", Lang["Color2Two"]
    Gui_G()
    Tab.UseTab(4)
    _Gui.Add "Text", "x+15 y+15", Lang["Similar2"] " 0"
    _Gui.Add "Slider", "x+0 w120 vSimilar2 +Center Page1 NoTicks ToolTip", 100
    Gui_G()
    _Gui.Add "Text", "x+0", "100"
    _Gui.Add "Button", "x+15 yp-3 vColorPos2Two", Lang["ColorPos2Two"]
    Gui_G()
    Tab.UseTab(5)
    _Gui.Add "Text", "x+10 y+15", Lang["DiffR"]
    _Gui.Add "Edit", "x+5 w80 vDiffR Limit3"
    _Gui.Add "UpDown", "vdR Range0-255 Wrap"
    _Gui.Add "Text", "x+5", Lang["DiffG"]
    _Gui.Add "Edit", "x+5 w80 vDiffG Limit3"
    _Gui.Add "UpDown", "vdG Range0-255 Wrap"
    _Gui.Add "Text", "x+5", Lang["DiffB"]
    _Gui.Add "Edit", "x+5 w80 vDiffB Limit3"
    _Gui.Add "UpDown", "vdB Range0-255 Wrap"
    _Gui.Add "Button", "x+15 yp-3 vColorDiff2Two", Lang["ColorDiff2Two"]
    Gui_G()
    Tab.UseTab(6)
    _Gui.Add "Text", "x+10 y+15", Lang["DiffRGB"]
    _Gui.Add "Edit", "x+5 w80 vDiffRGB Limit3"
    _Gui.Add "UpDown", "vdRGB Range0-255 Wrap"
    _Gui.Add "Checkbox", "x+15 yp+5 vMultiColor", Lang["MultiColor"]
    Gui_G()
    _Gui.Add "Button", "x+15 yp-5 vUndo", Lang["Undo"]
    Gui_G()
    Tab.UseTab()
    ;--------------
    _Gui.Add "Button", "xm vReset", Lang["Reset"]
    Gui_G()
    _Gui.Add "Checkbox", "x+15 yp+5 vModify", Lang["Modify"]
    Gui_G()
    _Gui.Add "Text", "x+30", Lang["Comment"]
    _Gui.Add "Edit", "x+5 yp-2 w150 vComment"
    _Gui.Add "Button", "x+10 yp-3 vSplitAdd", Lang["SplitAdd"]
    Gui_G()
    _Gui.Add "Button", "x+10 vAllAdd", Lang["AllAdd"]
    Gui_G()
    _Gui.Add "Button", "x+30 wp vOK", Lang["OK"]
    Gui_G()
    _Gui.Add "Button", "x+10 wp vCancel", Lang["Cancel"]
    Gui_G()
    _Gui.Add "Button", "xm vBind0", Lang["Bind0"]
    Gui_G()
    _Gui.Add "Button", "x+10 vBind1", Lang["Bind1"]
    Gui_G()
    _Gui.Add "Button", "x+10 vBind2", Lang["Bind2"]
    Gui_G()
    _Gui.Add "Button", "x+10 vBind3", Lang["Bind3"]
    Gui_G()
    _Gui.Add "Button", "x+10 vBind4", Lang["Bind4"]
    Gui_G()
    _Gui.Add "Button", "x+60 vSavePic2", Lang["SavePic2"]
    Gui_G()
    _Gui.Title:=Lang["s3"]
    _Gui.Show "Hide"
    ;--------------------
    Try FindText_SubPic.Destroy()
    FindText_SubPic:=_Gui:=Gui()  ; Don't use +AlwaysOnTop
    _Gui.Opt "+Parent" parent_id " -Caption +ToolWindow -DPIScale"
    _Gui.MarginX:=0, _Gui.MarginY:=0
    _Gui.BackColor:="White"
    id:=_Gui.Add("Pic", "x0 y0 w500 h500"), sub_hpic:=id.Hwnd
    _Gui.Title:="SubPic"
    _Gui.Show "Hide"
    return
  Case "MakeMainWindow":
    Try FindText_Main.Destroy()
    FindText_Main:=_Gui:=Gui()
    _Gui.Opt "+LastFound +AlwaysOnTop -DPIScale"
    _Gui.MarginX:=15, _Gui.MarginY:=10
    _Gui.BackColor:=WindowColor
    _Gui.SetFont "s12", "Verdana"
    _Gui.Add "Text", "xm", Lang["NowHotkey"]
    _Gui.Add "Edit", "x+5 w160 vNowHotkey ReadOnly"
    _Gui.Add "Hotkey", "x+5 w160 vSetHotkey1"
    s:="F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|LWin|MButton"
      . "|ScrollLock|CapsLock|Ins|Esc|BS|Del|Tab|Home|End|PgUp|PgDn"
      . "|NumpadDot|NumpadSub|NumpadAdd|NumpadDiv|NumpadMult"
    _Gui.Add "DDL", "x+5 w160 vSetHotkey2", StrSplit(s,"|")
    _Gui.Add "Button", "x+15 vApply", Lang["Apply"]
    Gui_G()
    _Gui.Add "GroupBox", "xm y+0 w280 h55 vMyGroup cBlack"
    _Gui.Add "Text", "xp+15 yp+20 Section", Lang["Myww"] ": "
    _Gui.Add "Text", "x+0 w80", nW//2
    _Gui.Add "UpDown", "vMyww Range1-100", nW//2
    _Gui.Add "Text", "x+15 ys", Lang["Myhh"] ": "
    _Gui.Add "Text", "x+0 w80", nH//2
    _Gui.Add "UpDown", "vMyhh Range1-100", nH//2
    this.LastCtrl().GetPos(&pX, &pY, &pW, &pH)
    _Gui["MyGroup"].Move(,, pX+pW, pH+30)
    _Gui.Add "Checkbox", "x+100 ys vAddFunc", Lang["AddFunc"] " FindText()"
    this.LastCtrl().GetPos(&pX, &pY, &pW, &pH)
    pW:=pX+pW-15, pW:=(pW<720?720:pW), w:=pW//5
    _Gui.Add "Button", "xm y+18 w" w " vCutL2", Lang["CutL2"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp vCutR2", Lang["CutR2"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp vCutU2", Lang["CutU2"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp vCutD2", Lang["CutD2"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp vUpdate", Lang["Update"]
    Gui_G()
    _Gui.SetFont "s6 bold", "Verdana"
    _Gui.Add "Edit", "xm y+10 w" pW " h260 vMyPic -Wrap HScroll"
    _Gui.SetFont "s12 norm", "Verdana"
    w:=pW//3
    _Gui.Add "Button", "xm w" w " vCapture", Lang["Capture"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp vTest", Lang["Test"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp vCopy", Lang["Copy"]
    Gui_G()
    _Gui.Add "Button", "xm y+0 wp vCaptureS", Lang["CaptureS"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp vGetRange", Lang["GetRange"]
    Gui_G()
    _Gui.Add "Button", "x+0 wp vGetOffset", Lang["GetOffset"]
    Gui_G()
    _Gui.Add "Edit", "xm y+10 w130 hp vClipText"
    _Gui.Add "Button", "x+0 vPaste", Lang["Paste"]
    Gui_G()
    _Gui.Add "Button", "x+0 vTestClip", Lang["TestClip"]
    Gui_G()
    _Gui.Add "Button", "x+0 vGetClipOffset", Lang["GetClipOffset"]
    Gui_G()
    r:=pW
    this.LastCtrl().GetPos(&pX, &pY, &pW, &pH)
    w:=((r+15)-(pX+pW))//2, pW:=r
    _Gui.Add "Edit", "x+0 w" w " hp vOffset"
    _Gui.Add "Button", "x+0 wp vCopyOffset", Lang["CopyOffset"]
    Gui_G()
    _Gui.SetFont "cBlue"
    id:=_Gui.Add("Edit", "xm w" pW " h250 vscr -Wrap HScroll"), hscr:=id.Hwnd
    _Gui.Title:=Lang["s4"]
    _Gui.Show "Hide"
    Gui_("LoadScr")
    OnExit(Gui_SaveScr)
    return
  Case "LoadScr":
    f:=A_Temp "\~scr2.tmp"
    Try s:="", s:=FileRead(f)
    _Gui:=FindText_Main
    _Gui["scr"].Value:=s
    return
  Case "SaveScr":
    f:=A_Temp "\~scr2.tmp"
    _Gui:=FindText_Main
    s:=_Gui["scr"].Value
    Try FileDelete(f)
    FileAppend(s, f)
    return
  Case "Capture", "CaptureS":
    _Gui:=FindText_Main
    if WinExist()!=_Gui.Hwnd
      return this.GetRange()
    this.Hide()
    if !InStr(cmd, "CaptureS")
    {
      _Gui:=FindText_Main
      w:=_Gui["Myww"].Value
      h:=_Gui["Myhh"].Value
      p:=this.GetRange(w, h)
      sx:=p[1], sy:=p[2], sw:=p[3]-p[1]+1, sh:=p[4]-p[2]+1
      , Bind_ID:=p[5], bind_mode:=""
      _Gui:=FindText_Capture
      _Gui["MyTab1"].Choose(1)
    }
    else
    {
      sx:=0, sy:=0, sw:=1, sh:=1, Bind_ID:=WinExist("A"), bind_mode:=""
      _Gui:=FindText_Capture
      _Gui["MyTab1"].Choose(2)
    }
    this.ScreenShot()
    n:=150000, x:=y:=-n, w:=h:=2*n
    hBM:=this.BitmapFromScreen(&x,&y,&w,&h,0)
    Gui_("CaptureUpdate")
    Gui_("PicUpdate")
    Names:=[], s:=""
    Loop Files, SavePicDir "*.bmp"
      Names.Push(v:=A_LoopFileFullPath), s.="|" RegExReplace(v,"i)^.*\\|\.bmp$")
    _Gui["SelectBox"].Delete()
    _Gui["SelectBox"].Add(StrSplit(Trim(s,"|"),"|"))
    ;------------------------
    Loop Parse, "SelGray|SelColor|SelR|SelG|SelB|Threshold|Comment", "|"
      _Gui[A_LoopField].Value:=""
    _Gui["Modify"].Value:=Modify:=0
    _Gui["MultiColor"].Value:=MultiColor:=0
    _Gui["GrayDiff"].Value:=50
    _Gui["Gray2Two"].Focus()
    _Gui["Gray2Two"].Opt("+Default")
    _Gui.Opt "+LastFound"
    _Gui.Show "Center"
    Event:=Result:=""
    DetectHiddenWindows 0
    Critical "Off"
    WinWaitClose "ahk_id " WinExist()
    Critical
    ToolTip
    FindText_SubPic.Hide
    _Gui:=FindText_Main
    ;--------------------------------
    if (bind_mode!="")
    {
      tt:=WinGetTitle(Bind_ID)
      tc:=WinGetClass(Bind_ID)
      tt:=Trim(SubStr(tt,1,30) (tc ? " ahk_class " tc:""))
      tt:=StrReplace(RegExReplace(tt, "[;``]", "``$0"), "`"","```"")
      Result:="`nSetTitleMatchMode 2`nid:=WinExist(`"" tt "`")"
        . "`nFindText().BindWindow(id" (bind_mode=0 ? "":"," bind_mode)
        . ")  `; " Lang["s6"] " FindText().BindWindow(0)`n`n" Result
    }
    if (Event="OK")
    {
      if (!A_IsCompiled)
        s:=FileRead(A_LineFile)
      else
        s:=this.GetScript()
      re:="i)\n\s*FindText[^\n]+args\*[\s\S]*?Script_End[(){\s]+}"
      if RegExMatch(s, re, &r)
        s:="`n;==========`n" r[0] "`n"
      _Gui["scr"].Value:=Result "`n" s
      _Gui["MyPic"].Value:=Trim(this.ASCII(Result),"`n")
    }
    else if (Event="SplitAdd") || (Event="AllAdd")
    {
      s:=_Gui["scr"].Value
      r:=SubStr(s, 1, InStr(s,"=FindText("))
      i:=j:=0, re:="<[^>\n]*>[^$\n]+\$[^`"'\r\n]+"
      While j:=RegExMatch(r, re,, j+1)
        i:=InStr(r, "`n", 0, j)
      _Gui["scr"].Value:=SubStr(s,1,i) . Result . SubStr(s,i+1)
      _Gui["MyPic"].Value:=Trim(this.ASCII(Result),"`n")
    }
    if (Event) && RegExMatch(Result, "\$\d+\.[\w+/]{1,100}", &r)
      this.EditScroll(hscr, "\Q" r[0] "\E")
    Event:=Result:=s:=""
    ;----------------------
    Gui_Show()
    return
  Case "CaptureUpdate":
    nX:=sx, nY:=sy, nW:=sw, nH:=sh
    bits:=this.GetBitsFromScreen(&nX,&nY,&nW,&nH,0,&zx,&zy)
    cors:=Map(), cors.Default:=0
    , show:=Map(), show.Default:=0
    , ascii:=Map(), ascii.Default:=0
    , SelPos:=bg:=color:=""
    , dx:=dy:=CutLeft:=CutRight:=CutUp:=CutDown:=0
    ListLines (lls:=A_ListLines)?0:0
    if (nW>0 && nH>0 && bits.Scan0)
    {
      j:=bits.Stride-nW*4, p:=bits.Scan0+(nY-zy)*bits.Stride+(nX-zx)*4-4-j
      Loop nH + 0*(k:=0)
      Loop nW + 0*(p+=j)
        show[++k]:=1, cors[k]:=NumGet(p+=4,"uint")
    }
    Loop 25 + 0*(ty:=dy-1)*(k:=0)
    Loop 71 + 0*(tx:=dx-1)*(ty++)
    {
      c:=(++tx)<nW && ty<nH ? cors[ty*nW+tx+1] : WindowColor
      SendMessage 0x2001,0,(c&0xFF)<<16|c&0xFF00|(c>>16)&0xFF,C_[++k]
    }
    Loop 71 + 0*(k:=71*25)
      SendMessage 0x2001,0,0xAAFFFF,C_[++k]
    ListLines lls
    _Gui:=FindText_Capture
    _Gui["MySlider1"].Enabled:=nW>71
    _Gui["MySlider2"].Enabled:=nH>25
    _Gui["MySlider1"].Value:=0
    _Gui["MySlider2"].Value:=0
    return
  Case "PicUpdate":
    FindText_SubPic[sub_hpic].Value:="*w0 *h0 HBITMAP:" hBM
    _Gui:=FindText_Capture
    _Gui["MySlider3"].Value:=0
    _Gui["MySlider4"].Value:=0
    Gui_("MySlider3")
    return
  Case "MySlider3", "MySlider4":
    _Gui:=FindText_Capture
    _Gui[parent_id].GetPos(,, &pW, &pH)
    MySlider3:=_Gui["MySlider3"].Value
    MySlider4:=_Gui["MySlider4"].Value
    w:=pW, h:=pH
    FindText_SubPic[sub_hpic].GetPos(,, &pW, &pH)
    x:=pW>w ? -Round((pW-w)*MySlider3/100) : 0
    y:=pH>h ? -Round((pH-h)*MySlider4/100) : 0
    FindText_SubPic.Show "NA x" x " y" y " w" pW " h" pH
    return
  Case "Reset":
    Gui_("CaptureUpdate")
    return
  Case "LoadPic":
    _Gui:=FindText_Capture
    _Gui.Opt "+OwnDialogs"
    f:=arg1
    if (f="")
    {
      if !FileExist(SavePicDir)
        DirCreate(SavePicDir)
      f:=SavePicDir "*.bmp"
      Loop Files, f
        f:=A_LoopFileFullPath
      f:=FileSelect(, f, "Select Picture")
    }
    if !FileExist(f)
    {
      MsgBox(Lang["s17"] " !", "Tip", "4096 T1")
      return
    }
    this.ShowPic(f, 0, &sx, &sy, &sw, &sh)
    hBM:=this.BitmapFromScreen(&sx, &sy, &sw, &sh, 0)
    sw:=Min(sw,200), sh:=Min(sh,200)
    Gui_("CaptureUpdate")
    Gui_("PicUpdate")
    return
  Case "SavePic":
    _Gui:=FindText_Capture
    SelectBox:=_Gui["SelectBox"].Value
    Try f:="", f:=Names[SelectBox]
    _Gui.Hide
    this.ShowPic(f)
    pos:=this.SnapShot(0)
    Gui_("ScreenShot", pos[1] "|" pos[2] "|" pos[3] "|" pos[4] "|0")
    this.ShowPic()
    return
  Case "SelectBox":
    _Gui:=FindText_Capture
    SelectBox:=_Gui["SelectBox"].Value
    Try f:="", f:=Names[SelectBox]
    if (f!="")
      Gui_("LoadPic", f)
    return
  Case "ClearAll":
    FindText_Capture.Hide
    Try FileDelete(SavePicDir "*.bmp")
    return
  Case "OpenDir":
    FindText_Capture.Minimize
    if !FileExist(SavePicDir)
      DirCreate(SavePicDir)
    Run SavePicDir
    return
  Case "GetRange":
    _Gui:=FindText_Main
    _Gui.Opt "+LastFound"
    this.Hide()
    p:=this.SnapShot(), v:=p[1] ", " p[2] ", " p[3] ", " p[4]
    s:=_Gui["scr"].Value
    re:="i)(=FindText\([^\n]*?)([^(,\n]*,){4}([^,\n]*,[^,\n]*,[^,\n]*Text)"
    if SubStr(s,1,s~="i)\n\s*FindText[^\n]+args\*")~=re
    {
      s:=RegExReplace(s, re, "$1 " v ",$3",, 1)
      _Gui["scr"].Value:=s
    }
    _Gui["Offset"].Value:=v
    Gui_Show()
    return
  Case "Test", "TestClip":
    _Gui:=FindText_Main
    _Gui.Opt "+LastFound"
    this.Hide()
    ;----------------------
    if (cmd="Test")
      s:=_Gui["scr"].Value
    else
      s:=_Gui["ClipText"].Value
    if (cmd="Test") && InStr(s, "MCode(")
    {
      s:="`nA_TrayMenu.ClickCount:=1`n" s "`nExitApp`n"
      Thread1:=FindTextClass.Thread(s)
      DetectHiddenWindows 1
      if WinWait("ahk_class AutoHotkey ahk_pid " Thread1.pid,, 3)
        WinWaitClose(,, 30)
      ; Thread1:=""  ; kill the Thread
    }
    else
    {
      t:=A_TickCount, v:=X:=Y:=""
      if RegExMatch(s, "<[^>\n]*>[^$\n]+\$[^`"'\r\n]+", &r)
        v:=this.FindText(&X, &Y, 0,0,0,0, 0,0, r[0])
      r:=StrSplit(Lang["s8"] "||||", "|")
      MsgBox(r[1] ":`t" (IsObject(v)?v.Length:v) "`n`n"
        . r[2] ":`t" (A_TickCount-t) " " r[3] "`n`n"
        . r[4] ":`t" X ", " Y "`n`n"
        . r[5] ":`t<" (IsObject(v)?v[1].id:"") ">", "Tip", "4096 T3")
      Try For i,j in v
        if (i<=2)
          this.MouseTip(j.x, j.y)
      v:="", A_Clipboard:=X "," Y
    }
    ;----------------------
    Gui_Show()
    return
  Case "GetOffset", "GetClipOffset":
    FindText_Main.Hide
    p:=this.GetRange()
    _Gui:=FindText_Main
    if (cmd="GetOffset")
      s:=_Gui["scr"].Value
    else
      s:=_Gui["ClipText"].Value
    if RegExMatch(s, "<[^>\n]*>[^$\n]+\$[^`"'\r\n]+", &r)
    && this.FindText(&X, &Y, 0,0,0,0, 0,0, r[0])
    {
      r:=StrReplace("X+" ((p[1]+p[3])//2-X)
        . ", Y+" ((p[2]+p[4])//2-Y), "+-", "-")
      if (cmd="GetOffset")
      {
        re:="i)(\(\)\.\w*Click\w*\()[^,\n]*,[^,)\n]*"
        if SubStr(s,1,s~="i)\n\s*FindText[^\n]+args\*")~=re
          s:=RegExReplace(s, re, "$1" r,, 1)
        _Gui["scr"].Value:=s
      }
      _Gui["Offset"].Value:=r
    }
    s:="", Gui_Show()
    return
  Case "Paste":
    s:=A_Clipboard
    if RegExMatch(s, "\|?<[^>\n]*>[^$\n]+\$[^`"'\r\n]+", &r)
    {
      _Gui:=FindText_Main
      _Gui["ClipText"].Value:=r[0]
      _Gui["MyPic"].Value:=Trim(this.ASCII(r[0]),"`n")
    }
    return
  Case "CopyOffset":
    _Gui:=FindText_Main
    s:=_Gui["Offset"].Value
    A_Clipboard:=s
    return
  Case "Copy":
    _Gui:=FindText_Main
    s:=EditGetSelectedText(hscr)
    if (s="")
    {
      s:=_Gui["scr"].Value
      r:=_Gui["AddFunc"].Value
      if (r != 1)
        s:=RegExReplace(s, "i)\n\s*FindText[^\n]+args\*[\s\S]*")
        , s:=RegExReplace(s, "i)\n; ok:=FindText[\s\S]*")
        , s:=SubStr(s, (s~="i)\n[ \t]*Text"))
    }
    A_Clipboard:=RegExReplace(s, "\R", "`r`n")
    ControlFocus(hscr)
    return
  Case "Apply":
    _Gui:=FindText_Main
    NowHotkey:=_Gui["NowHotkey"].Value
    SetHotkey1:=_Gui["SetHotkey1"].Value
    SetHotkey2:=_Gui["SetHotkey2"].Text
    if (NowHotkey!="")
      Try Hotkey "*" NowHotkey,, "Off"
    k:=SetHotkey1!="" ? SetHotkey1 : SetHotkey2
    if (k!="")
      Try Hotkey "*" k, Gui_ScreenShot, "On"
    _Gui["NowHotkey"].Value:=k
    _Gui["SetHotkey1"].Value:=""
    _Gui["SetHotkey2"].Choose(0)
    return
  Case "ScreenShot":
    Critical
    if !FileExist(SavePicDir)
      DirCreate(SavePicDir)
    Loop
      f:=SavePicDir . Format("{:03d}.bmp",A_Index)
    Until !FileExist(f)
    this.SavePic(f, StrSplit(arg1,"|")*)
    CoordMode "ToolTip"
    this.ToolTip(Lang["s9"],, 0,, { bgcolor:"Yellow", color:"Red"
      , size:48, bold:"bold", trans:200, timeout:0.2 })
    return
  Case "Bind0", "Bind1", "Bind2", "Bind3", "Bind4":
    this.BindWindow(Bind_ID, bind_mode:=SubStr(cmd,5))
    n:=150000, x:=y:=-n, w:=h:=2*n
    hBM:=this.BitmapFromScreen(&x,&y,&w,&h,1)
    Gui_("PicUpdate")
    FindText_Capture["MyTab1"].Choose(2)
    this.BindWindow(0)
    return
  Case "MySlider1", "MySlider2":
    SetTimer Gui_Slider, -10
    return
  Case "Slider":
    Critical
    _Gui:=FindText_Capture
    MySlider1:=_Gui["MySlider1"].Value
    MySlider2:=_Gui["MySlider2"].Value
    dx:=nW>71 ? Round((nW-71)*MySlider1/100) : 0
    dy:=nH>25 ? Round((nH-25)*MySlider2/100) : 0
    if (oldx=dx && oldy=dy)
      return
    ListLines (lls:=A_ListLines)?0:0
    Loop 25 + 0*(ty:=dy-1)*(k:=0)
    Loop 71 + 0*(tx:=dx-1)*(ty++)
    {
      c:=((++tx)>=nW || ty>=nH || !show[i:=ty*nW+tx+1]
      ? WindowColor : bg="" ? cors[i] : ascii[i] ? 0 : 0xFFFFFF)
      SendMessage 0x2001,0,(c&0xFF)<<16|c&0xFF00|(c>>16)&0xFF,C_[++k]
    }
    Loop 71*(oldx!=dx) + 0*(i:=nW*nH+dx)*(k:=71*25)
      SendMessage 0x2001,0,(show[++i]?0x0000FF:0xAAFFFF),C_[++k]
    ListLines lls
    oldx:=dx, oldy:=dy
    return
  Case "RepColor":
    show[k]:=1, c:=(bg="" ? cors[k] : ascii[k] ? 0 : 0xFFFFFF)
    if (tx:=Mod(k-1,nW)-dx)>=0 && tx<71 && (ty:=(k-1)//nW-dy)>=0 && ty<25
      SendMessage 0x2001,0,(c&0xFF)<<16|c&0xFF00|(c>>16)&0xFF,C_[ty*71+tx+1]
    return
  Case "CutColor":
    show[k]:=0, c:=WindowColor
    if (tx:=Mod(k-1,nW)-dx)>=0 && tx<71 && (ty:=(k-1)//nW-dy)>=0 && ty<25
      SendMessage 0x2001,0,(c&0xFF)<<16|c&0xFF00|(c>>16)&0xFF,C_[ty*71+tx+1]
    return
  Case "RepL":
    if (CutLeft<=0) || (bg!="" && InStr(color,"**") && CutLeft=1)
      return
    k:=CutLeft-nW, CutLeft--
    Loop nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && Gui_("RepColor"))
    return
  Case "CutL":
    if (CutLeft+CutRight>=nW)
      return
    CutLeft++, k:=CutLeft-nW
    Loop nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && Gui_("CutColor"))
    return
  Case "CutL3":
    Loop 3
      Gui_("CutL")
    return
  Case "RepR":
    if (CutRight<=0) || (bg!="" && InStr(color,"**") && CutRight=1)
      return
    k:=1-CutRight, CutRight--
    Loop nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && Gui_("RepColor"))
    return
  Case "CutR":
    if (CutLeft+CutRight>=nW)
      return
    CutRight++, k:=1-CutRight
    Loop nH
      k+=nW, (A_Index>CutUp && A_Index<nH+1-CutDown && Gui_("CutColor"))
    return
  Case "CutR3":
    Loop 3
      Gui_("CutR")
    return
  Case "RepU":
    if (CutUp<=0) || (bg!="" && InStr(color,"**") && CutUp=1)
      return
    k:=(CutUp-1)*nW, CutUp--
    Loop nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && Gui_("RepColor"))
    return
  Case "CutU":
    if (CutUp+CutDown>=nH)
      return
    CutUp++, k:=(CutUp-1)*nW
    Loop nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && Gui_("CutColor"))
    return
  Case "CutU3":
    Loop 3
      Gui_("CutU")
    return
  Case "RepD":
    if (CutDown<=0) || (bg!="" && InStr(color,"**") && CutDown=1)
      return
    k:=(nH-CutDown)*nW, CutDown--
    Loop nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && Gui_("RepColor"))
    return
  Case "CutD":
    if (CutUp+CutDown>=nH)
      return
    CutDown++, k:=(nH-CutDown)*nW
    Loop nW
      k++, (A_Index>CutLeft && A_Index<nW+1-CutRight && Gui_("CutColor"))
    return
  Case "CutD3":
    Loop 3
      Gui_("CutD")
    return
  Case "Gray2Two":
    ListLines (lls:=A_ListLines)?0:0
    gray:=Map(), gray.Default:=0, k:=0
    Loop nW*nH
      gray[++k]:=((((c:=cors[k])>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    _Gui:=FindText_Capture
    _Gui["Threshold"].Focus()
    Threshold:=_Gui["Threshold"].Value
    if (Threshold="")
    {
      pp:=Map(), pp.Default:=0
      Loop 256
        pp[A_Index-1]:=0
      Loop nW*nH
        if (show[A_Index])
          pp[gray[A_Index]]++
      IP0:=IS0:=0
      Loop 256
        k:=A_Index-1, IP0+=k*pp[k], IS0+=pp[k]
      Threshold:=Floor(IP0/IS0)
      Loop 20
      {
        LastThreshold:=Threshold
        IP1:=IS1:=0
        Loop LastThreshold+1
          k:=A_Index-1, IP1+=k*pp[k], IS1+=pp[k]
        IP2:=IP0-IP1, IS2:=IS0-IS1
        if (IS1!=0 && IS2!=0)
          Threshold:=Floor((IP1/IS1+IP2/IS2)/2)
        if (Threshold=LastThreshold)
          Break
      }
      _Gui["Threshold"].Value:=Threshold
    }
    Threshold:=Round(Threshold)
    color:="*" Threshold, k:=i:=0
    Loop nW*nH
      ascii[++k]:=v:=(gray[k]<=Threshold)
      , (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), Gui_("BlackWhite")
    ListLines lls
    return
  Case "GrayDiff2Two":
    _Gui:=FindText_Capture
    GrayDiff:=_Gui["GrayDiff"].Value
    if (GrayDiff="")
    {
      _Gui.Opt "+OwnDialogs"
      MsgBox(Lang["s11"] " !", "Tip", "4096 T1")
      return
    }
    ListLines (lls:=A_ListLines)?0:0
    gray:=Map(), gray.Default:=0, k:=0
    Loop nW*nH
      gray[++k]:=((((c:=cors[k])>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
    if (CutLeft=0)
      Gui_("CutL")
    if (CutRight=0)
      Gui_("CutR")
    if (CutUp=0)
      Gui_("CutU")
    if (CutDown=0)
      Gui_("CutD")
    GrayDiff:=Round(GrayDiff)
    color:="**" GrayDiff, k:=i:=0
    Loop nW*nH
      j:=gray[++k]+GrayDiff
      , ascii[k]:=v:=( gray[k-1]>j || gray[k+1]>j
      || gray[k-nW]>j || gray[k+nW]>j
      || gray[k-nW-1]>j || gray[k-nW+1]>j
      || gray[k+nW-1]>j || gray[k+nW+1]>j )
      , (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), Gui_("BlackWhite")
    ListLines lls
    return
  Case "Color2Two", "ColorPos2Two":
    _Gui:=FindText_Capture
    c:=_Gui["SelColor"].Value
    if (c="")
    {
      _Gui.Opt "+OwnDialogs"
      MsgBox(Lang["s12"] " !", "Tip", "4096 T1")
      return
    }
    UsePos:=(cmd="ColorPos2Two")
    n:=this.Floor(_Gui[UsePos?"Similar2":"Similar1"].Value)
    n:=Round(n/100,2), color:=StrReplace(c,"0x") "@" n
    , n:=Floor(4606*255*255*(1-n)*(1-n)), k:=i:=0
    , rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
    ListLines (lls:=A_ListLines)?0:0
    Loop nW*nH
      c:=cors[++k], r:=((c>>16)&0xFF)-rr
      , g:=((c>>8)&0xFF)-gg, b:=(c&0xFF)-bb, j:=r+rr+rr
      , ascii[k]:=v:=((1024+j)*r*r+2048*g*g+(1534-j)*b*b<=n)
      , (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), Gui_("BlackWhite")
    ListLines lls
    return
  Case "ColorDiff2Two":
    _Gui:=FindText_Capture
    c:=_Gui["SelColor"].Value
    if (c="")
    {
      _Gui.Opt "+OwnDialogs"
      MsgBox(Lang["s12"] " !", "Tip", "4096 T1")
      return
    }
    dR:=_Gui["dR"].Value
    dG:=_Gui["dG"].Value
    dB:=_Gui["dB"].Value
    rr:=(c>>16)&0xFF, gg:=(c>>8)&0xFF, bb:=c&0xFF
    , n:=Format("{:06X}",(dR<<16)|(dG<<8)|dB)
    , color:=StrReplace(c "-" n,"0x"), k:=i:=0
    ListLines (lls:=A_ListLines)?0:0
    Loop nW*nH
      c:=cors[++k], r:=(c>>16)&0xFF, g:=(c>>8)&0xFF, b:=c&0xFF
      , ascii[k]:=v:=(Abs(r-rr)<=dR && Abs(g-gg)<=dG && Abs(b-bb)<=dB)
      , (show[k] && i:=(v?i+1:i-1))
    bg:=(i>0 ? "1":"0"), Gui_("BlackWhite")
    ListLines lls
    return
  Case "BlackWhite":
    Loop 25 + 0*(ty:=dy-1)*(k:=0)
    Loop 71 + 0*(tx:=dx-1)*(ty++)
    if (k++)*0 + (++tx)<nW && ty<nH && show[i:=ty*nW+tx+1]
      SendMessage 0x2001,0,(ascii[i] ? 0 : 0xFFFFFF),C_[k]
    return
  Case "Modify":
    _Gui:=FindText_Capture
    Modify:=_Gui["Modify"].Value
    return
  Case "MultiColor":
    _Gui:=FindText_Capture
    MultiColor:=_Gui["MultiColor"].Value
    Result:=""
    ToolTip
    return
  Case "Undo":
    Result:=RegExReplace(Result, ",[^/]+/[^/]+/[^/]+$")
    ToolTip Trim(Result,"/,")
    return
  Case "Similar1":
    _Gui:=FindText_Capture
    _Gui["Similar2"].Value:=_Gui["Similar1"].Value
    return
  Case "Similar2":
    _Gui:=FindText_Capture
    _Gui["Similar1"].Value:=_Gui["Similar2"].Value
    return
  Case "GetTxt":
    txt:=""
    if (bg="")
      return
    k:=0
    ListLines (lls:=A_ListLines)?0:0
    Loop nH
    {
      v:=""
      Loop nW
        v.=!show[++k] ? "" : ascii[k] ? "1":"0"
      txt.=v="" ? "" : v "`n"
    }
    ListLines lls
    return
  Case "Auto":
    Gui_("GetTxt")
    if (txt="")
    {
      FindText_Capture.Opt "+OwnDialogs"
      MsgBox(Lang["s13"] " !", "Tip", "4096 T1")
      return
    }
    While InStr(txt,bg)
    {
      if (txt~="^" bg "+\n")
        txt:=RegExReplace(txt, "^" bg "+\n"), Gui_("CutU")
      else if !(txt~="m`n)[^\n" bg "]$")
        txt:=RegExReplace(txt, "m`n)" bg "$"), Gui_("CutR")
      else if (txt~="\n" bg "+\n$")
        txt:=RegExReplace(txt, "\n\K" bg "+\n$"), Gui_("CutD")
      else if !(txt~="m`n)^[^\n" bg "]")
        txt:=RegExReplace(txt, "m`n)^" bg), Gui_("CutL")
      else Break
    }
    txt:=""
    return
  Case "OK", "SplitAdd", "AllAdd":
    _Gui:=FindText_Capture
    _Gui.Opt "+OwnDialogs"
    Gui_("GetTxt")
    if (txt="") && (!MultiColor)
    {
      MsgBox(Lang["s13"] " !", "Tip", "4096 T1")
      return
    }
    if InStr(color,"@") && (UsePos) && (!MultiColor)
    {
      r:=StrSplit(color,"@")
      k:=i:=j:=0
      ListLines (lls:=A_ListLines)?0:0
      Loop nW*nH
      {
        if (!show[++k])
          Continue
        i++
        if (k=SelPos)
        {
          j:=i
          Break
        }
      }
      ListLines lls
      if (j=0)
      {
        MsgBox(Lang["s12"] " !", "Tip", "4096 T1")
        return
      }
      color:="#" j "@" r[2]
    }
    Comment:=_Gui["Comment"].Value
    if (cmd="SplitAdd") && (!MultiColor)
    {
      if InStr(color,"#")
      {
        MsgBox(Lang["s14"], "Tip", "4096 T3")
        return
      }
      bg:=StrLen(StrReplace(txt,"0"))
        > StrLen(StrReplace(txt,"1")) ? "1":"0"
      s:="", i:=0, k:=nW*nH+1+CutLeft
      Loop w:=nW-CutLeft-CutRight
      {
        i++
        if (!show[k++] && A_Index<w)
          Continue
        i:=Format("{:d}",i)
        v:=RegExReplace(txt,"m`n)^(.{" i "}).*","$1")
        txt:=RegExReplace(txt,"m`n)^.{" i "}"), i:=0
        While InStr(v,bg)
        {
          if (v~="^" bg "+\n")
            v:=RegExReplace(v,"^" bg "+\n")
          else if !(v~="m`n)[^\n" bg "]$")
            v:=RegExReplace(v,"m`n)" bg "$")
          else if (v~="\n" bg "+\n$")
            v:=RegExReplace(v,"\n\K" bg "+\n$")
          else if !(v~="m`n)^[^\n" bg "]")
            v:=RegExReplace(v,"m`n)^" bg)
          else Break
        }
        if (v!="")
        {
          v:=Format("{:d}",InStr(v,"`n")-1) "." this.bit2base64(v)
          s.="`nText.=`"|<" SubStr(Comment, 1, 1) ">" color "$" v "`"`n"
          Comment:=SubStr(Comment, 2)
        }
      }
      Event:=cmd, Result:=s
      _Gui.Hide
      return
    }
    if (!MultiColor)
      txt:=Format("{:d}",InStr(txt,"`n")-1) "." this.bit2base64(txt)
    else
    {
      n:=_Gui["dRGB"].Value
      color:=Format("##{:06X}", n<<16|n<<8|n)
      r:=StrSplit(Trim(StrReplace(Result, ",", "/"), "/"), "/")
      , x:=(r.Has(1)?r[1]:0), y:=(r.Has(2)?r[2]:0), s:="", i:=1
      Loop r.Length//3
        s.="," (r[i++]-x) "/" (r[i++]-y) "/" r[i++]
      txt:=SubStr(s,2)
    }
    s:="`nText.=`"|<" Comment ">" color "$" txt "`"`n"
    if (cmd="AllAdd")
    {
      Event:=cmd, Result:=s
      _Gui.Hide
      return
    }
    x:=nX+CutLeft+(nW-CutLeft-CutRight)//2
    y:=nY+CutUp+(nH-CutUp-CutDown)//2
    s:=StrReplace(s, "Text.=", "Text:="), r:=StrSplit(Lang["s8"] "|||||||", "|")
    s:="`; #Include <FindText>`n"
    . "`nt1:=A_TickCount, Text:=X:=Y:=`"`"`n" s
    . "`nif (ok:=FindText(&X, &Y, " x "-150000, "
    . y "-150000, " x "+150000, " y "+150000, 0, 0, Text))"
    . "`n{"
    . "`n  `; FindText()." . "Click(" . "X, Y, `"L`")"
    . "`n}`n"
    . "`n`; ok:=FindText(&X:=`"wait`", &Y:=3, 0,0,0,0,0,0,Text)  `; " r[7]
    . "`n`; ok:=FindText(&X:=`"wait0`", &Y:=-1, 0,0,0,0,0,0,Text)  `; " r[8]
    . "`n`nMsgBox(`"" r[1] ":``t`" (IsObject(ok)?ok.Length:ok)"
    . "`n  . `"``n``n" r[2] ":``t`" (A_TickCount-t1) `" " r[3] "`""
    . "`n  . `"``n``n" r[4] ":``t`" X `", `" Y"
    . "`n  . `"``n``n" r[5] ":``t<`" (IsObject(ok)?ok[1].id:`"`") `">`", `"Tip`", 4096)`n"
    . "`nTry For i,v in ok  `; ok " r[6] " ok:=FindText().ok"
    . "`n  if (i<=2)"
    . "`n    FindText().MouseTip(ok[i].x, ok[i].y)`n"
    Event:=cmd, Result:=s
    _Gui.Hide
    return
  Case "SavePic2":
    x:=nX+CutLeft, w:=nW-CutLeft-CutRight
    y:=nY+CutUp, h:=nH-CutUp-CutDown
    Gui_("ScreenShot", x "|" y "|" (x+w-1) "|" (y+h-1) "|0")
    return
  Case "ShowPic":
    _Gui:=FindText_Main
    i:=EditGetCurrentLine(hscr)
    s:=EditGetLine(i, hscr)
    _Gui["MyPic"].Value:=Trim(this.ASCII(s),"`n")
    return
  Case "KeyDown":
    Critical
    _Gui:=FindText_Main
    if (WinExist()!=_Gui.Hwnd)
      return
    Try ctrl:="", ctrl:=args[3]
    if (ctrl=hscr)
      SetTimer Gui_ShowPic, -150
    else if (ctrl=_Gui["ClipText"].Hwnd)
    {
      s:=_Gui["ClipText"].Value
      _Gui["MyPic"].Value:=Trim(this.ASCII(s),"`n")
    }
    return
  Case "LButtonDown":
    Critical
    Try k1:="", k1:=GuiFromHwnd(args[3],1).Hwnd
    if (k1=FindText_SubPic.Hwnd)
    {
      ; Two windows trigger two messages
      if (A_TickCount-oldt)<100 || !GetKeyState("LButton","P")
        return
      CoordMode "Mouse"
      MouseGetPos &k1, &k2
      ListLines (lls:=A_ListLines)?0:0
      Loop
      {
        Sleep 50
        MouseGetPos &k3, &k4
        this.RangeTip(Min(k1,k3), Min(k2,k4)
        , Abs(k1-k3), Abs(k2-k4), (A_MSec<500 ? "Red":"Blue"))
      }
      Until !GetKeyState("LButton","P")
      ListLines lls
      this.RangeTip()
      this.GetBitsFromScreen(,,,,0,&zx,&zy)
      this.ClientToScreen(&sx, &sy, 0, 0, sub_hpic)
      if Abs(k1-k3)+Abs(k2-k4)>4
        sx:=zx+Min(k1,k3)-sx, sy:=zy+Min(k2,k4)-sy
        , sw:=Abs(k1-k3), sh:=Abs(k2-k4)
      else
        sx:=zx+k1-sx-71//2, sy:=zy+k2-sy-25//2, sw:=71, sh:=25
      Gui_("CaptureUpdate")
      FindText_Capture["MyTab1"].Choose(1)
      oldt:=A_TickCount
      return
    }
    if (k1!=FindText_Capture.Hwnd)
      return Gui_("KeyDown", arg1, args*)
    MouseGetPos(,,, &k2, 2)
    k1:=0
    ListLines (lls:=A_ListLines)?0:0
    For k_,v_ in C_
      if (v_=k2) && (k1:=k_)
        Break
    ListLines lls
    if (k1<1)
      return
    else if (k1>71*25)
    {
      k3:=nW*nH+dx+(k1-71*25)
      SendMessage 0x2001,0,((show[k3]:=!show[k3])?0x0000FF:0xAAFFFF),k2
      return
    }
    k2:=Mod(k1-1,71)+dx, k3:=(k1-1)//71+dy
    if (k2<0 || k2>=nW || k3<0 || k3>=nH)
      return
    k1:=k, k:=k3*nW+k2+1, k4:=c
    if (MultiColor && show[k])
    {
      c:="," (nX+k2) "/" (nY+k3) "/"
      . Format("{:06X}",cors[k]&0xFFFFFF)
      , Result.=InStr(Result,c) ? "":c
      ToolTip Trim(Result,"/,")
    }
    if (Modify && bg!="" && show[k])
    {
      c:=((ascii[k]:=!ascii[k]) ? 0 : 0xFFFFFF)
      if (tx:=Mod(k-1,nW)-dx)>=0 && tx<71 && (ty:=(k-1)//nW-dy)>=0 && ty<25
        SendMessage 0x2001,0,c,C_[ty*71+tx+1]
    }
    else
    {
      c:=cors[k], SelPos:=k
      _Gui:=FindText_Capture
      _Gui["SelGray"].Value:=(((c>>16)&0xFF)*38+((c>>8)&0xFF)*75+(c&0xFF)*15)>>7
      _Gui["SelColor"].Value:=Format("0x{:06X}",c&0xFFFFFF)
      _Gui["SelR"].Value:=(c>>16)&0xFF
      _Gui["SelG"].Value:=(c>>8)&0xFF
      _Gui["SelB"].Value:=c&0xFF
    }
    k:=k1, c:=k4
    return
  Case "RButtonDown":
    Critical
    Try k1:="", k1:=GuiFromHwnd(args[3],1).Hwnd
    if (k1!=FindText_SubPic.Hwnd)
      return
    ; Two windows trigger two messages
    if (A_TickCount-oldt)<100 || !GetKeyState("RButton","P")
      return
    r:=[x, y, w, h, pX, pY, pW, pH]
    CoordMode "Mouse"
    MouseGetPos &k1, &k2
    WinGetPos &x, &y, &w, &h, parent_id
    WinGetPos &pX, &pY, &pW, &pH, sub_hpic
    pX-=x, pY-=y, pW-=w, pH-=h
    ListLines (lls:=A_ListLines)?0:0
    Loop
    {
      Sleep 10
      MouseGetPos &k3, &k4
      x:=Min(Max(pX+k3-k1,-pW),0), y:=Min(Max(pY+k4-k2,-pH),0)
      FindText_SubPic.Show "NA x" x " y" y
      FindText_Capture["MySlider3"].Value:=Round(-x/pW*100)
      FindText_Capture["MySlider4"].Value:=Round(-y/pH*100)
    }
    Until !GetKeyState("RButton","P")
    ListLines lls
    x:=r[1], y:=r[2], w:=r[3], h:=r[4], pX:=r[5], pY:=r[6], pW:=r[7], pH:=r[8]
    oldt:=A_TickCount
    return
  Case "MouseMove":
    Try ctrl_name:="", ctrl_name:=GuiCtrlFromHwnd(args[3]).Name
    if (PrevControl != ctrl_name)
    {
      ToolTip
      PrevControl:=ctrl_name
      if IsSet(Gui_ToolTip)
      {
        SetTimer Gui_ToolTip, PrevControl ? -500 : 0
        SetTimer Gui_ToolTipOff, PrevControl ? -5500 : 0
      }
    }
    return
  Case "ToolTip":
    MouseGetPos(,, &_TT)
    if WinExist("ahk_id " _TT " ahk_class AutoHotkeyGUI")
      Try ToolTip Tip_Text[PrevControl]
    return
  Case "ToolTipOff":
    ToolTip
    return
  Case "CutL2", "CutR2", "CutU2", "CutD2":
    _Gui:=FindText_Main
    s:=_Gui["MyPic"].Value
    s:=Trim(s,"`n") . "`n", v:=SubStr(cmd,4,1)
    if (v="U")
      s:=RegExReplace(s,"^[^\n]+\n")
    else if (v="D")
      s:=RegExReplace(s,"[^\n]+\n$")
    else if (v="L")
      s:=RegExReplace(s,"m`n)^[^\n]")
    else if (v="R")
      s:=RegExReplace(s,"m`n)[^\n]$")
    _Gui["MyPic"].Value:=Trim(s,"`n")
    return
  Case "Update":
    _Gui:=FindText_Main
    ControlFocus(hscr)
    i:=EditGetCurrentLine(hscr)
    s:=EditGetLine(i, hscr)
    if !RegExMatch(s, "(<[^>\n]*>[^$\n]+\$)\d+\.[\w+/]+", &r)
      return
    v:=_Gui["MyPic"].Value
    v:=Trim(v,"`n") . "`n", w:=Format("{:d}",InStr(v,"`n")-1)
    v:=StrReplace(StrReplace(v,"0","1"),"_","0")
    s:=StrReplace(s, r[0], r[1] . w "." this.bit2base64(v))
    v:="{End}{Shift Down}{Home}{Shift Up}{Del}"
    ControlSend(v, hscr)
    EditPaste(s, hscr)
    ControlSend("{Home}", hscr)
    return
  }
}

Lang(text:="", getLang:=0)
{
  static Lang1:="", Lang2
  if (!Lang1)
  {
    s:="
    (
Myww       = Width = Adjust the width of the capture range
Myhh       = Height = Adjust the height of the capture range
AddFunc    = Add = Additional FindText() in Copy
NowHotkey  = Hotkey = Current screenshot hotkey
SetHotkey1 = = First sequence Screenshot hotkey
SetHotkey2 = = Second sequence Screenshot hotkey
Apply      = Apply = Apply new screenshot hotkey
CutU2      = CutU = Cut the Upper Edge of the text in the edit box below
CutL2      = CutL = Cut the Left Edge of the text in the edit box below
CutR2      = CutR = Cut the Right Edge of the text in the edit box below
CutD2      = CutD = Cut the Lower Edge of the text in the edit box below
Update     = Update = Update the text in the edit box below to the line of Code
GetRange   = GetRange = Get screen range and update the search range of the Code
GetOffset  = GetOffset = Get position offset relative to the Text from the Code and update FindText().Click()
GetClipOffset  = GetOffset2 = Get position offset relative to the Text from the Left Box
Capture    = Capture = Initiate Image Capture Sequence
CaptureS   = CaptureS = Restore the Saved ScreenShot by Hotkey and then start capturing
Test       = Test = Test the Text from the Code to see if it can be found on the screen
TestClip   = Test2 = Test the Text from the Left Box and copy the result to Clipboard
Paste      = Paste = Paste the Text from Clipboard to the Left Box
CopyOffset = Copy2 = Copy the Offset to Clipboard
Copy       = Copy = Copy the selected or all of the code to the clipboard
Reset      = Reset = Reset to Original Captured Image
SplitAdd   = SplitAdd = Using Markup Segmentation to Generate Text Library
AllAdd     = AllAdd = Append Another FindText Search Text into Previously Generated Code
Gray2Two      = Gray2Two = Converts Image Pixels from Gray Threshold to Black or White
GrayDiff2Two  = GrayDiff2Two = Converts Image Pixels from Gray Difference to Black or White
Color2Two     = Color2Two = Converts Image Pixels from Color Similar to Black or White
ColorPos2Two  = ColorPos2Two = Converts Image Pixels from Color Position to Black or White
ColorDiff2Two = ColorDiff2Two = Converts Image Pixels from Color Difference to Black or White
SelGray    = Gray = Gray value of the selected color
SelColor   = Color = The selected color
SelR       = R = Red component of the selected color
SelG       = G = Green component of the selected color
SelB       = B = Blue component of the selected color
RepU       = -U = Undo Cut the Upper Edge by 1
CutU       = U = Cut the Upper Edge by 1
CutU3      = U3 = Cut the Upper Edge by 3
RepL       = -L = Undo Cut the Left Edge by 1
CutL       = L = Cut the Left Edge by 1
CutL3      = L3 = Cut the Left Edge by 3
Auto       = Auto = Automatic Cut Edge after image has been converted to black and white
RepR       = -R = Undo Cut the Right Edge by 1
CutR       = R = Cut the Right Edge by 1
CutR3      = R3 = Cut the Right Edge by 3
RepD       = -D = Undo Cut the Lower Edge by 1
CutD       = D = Cut the Lower Edge by 1
CutD3      = D3 = Cut the Lower Edge by 3
Modify     = Modify = Allows Modify the Black and White Image
MultiColor = FindMultiColor = Click multiple colors with the mouse, then Click OK button
Undo       = Undo = Undo the last selected color
Comment    = Comment = Optional Comment used to Label Code ( Within <> )
Threshold  = Gray Threshold = Gray Threshold which Determines Black or White Pixel Conversion (0-255)
GrayDiff   = Gray Difference = Gray Difference which Determines Black or White Pixel Conversion (0-255)
Similar1   = Similarity = Adjust color similarity as Equivalent to The Selected Color
Similar2   = Similarity = Adjust color similarity as Equivalent to The Selected Color
DiffR      = R = Red Difference which Determines Black or White Pixel Conversion (0-255)
DiffG      = G = Green Difference which Determines Black or White Pixel Conversion (0-255)
DiffB      = B = Blue Difference which Determines Black or White Pixel Conversion (0-255)
DiffRGB    = R/G/B = Determine the allowed R/G/B Error (0-255) when Find MultiColor
Bind0      = BindWin1 = Bind the window and Use GetDCEx() to get the image of background window
Bind1      = BindWin1+ = Bind the window Use GetDCEx() and Modify the window to support transparency
Bind2      = BindWin2 = Bind the window and Use PrintWindow() to get the image of background window
Bind3      = BindWin2+ = Bind the window Use PrintWindow() and Modify the window to support transparency
Bind4      = BindWin3 = Bind the window and Use PrintWindow(,,3) to get the image of background window
OK         = OK = Create New FindText Code for Testing
OK2        = OK = Restore this ScreenShot then Capturing
Cancel     = Cancel = Close the Window Don't Do Anything
Cancel2    = Cancel = Close the Window Don't Do Anything
ClearAll   = ClearAll = Clean up all saved ScreenShots
OpenDir    = OpenDir = Open the saved screenshots directory
SavePic    = SavePic = Select a range and save as a picture
SavePic2   = SavePic = Save the trimmed original image as a picture
LoadPic    = LoadPic = Load a picture as Capture image
ClipText   = = Displays the Text data from clipboard
Offset     = = Displays the results of GetOffset2 or GetRange
SelectBox  = = Select a screenshot to display in the upper left corner of the screen
s1  = FindText
s2  = Gray|GrayDiff|Color|ColorPos|ColorDiff|MultiColor
s3  = Capture Image To Text
s4  = Capture Image To Text and Find Text Tool
s5  = Direction keys to fine tune\nFirst click RButton\nMove the mouse away\nSecond click RButton
s6  = Unbind Window using
s7  = Please drag a range with the LButton\nCoordinates are copied to clipboard
s8  = Found|Time|ms|Pos|Result|value can be get from|Wait 3 seconds for appear|Wait indefinitely for disappear
s9  = Success
s10 = The Capture Position|Perspective binding window\nRight click to finish capture
s11 = Please Set Gray Difference First
s12 = Please select the core color first
s13 = Please convert the image to black or white first
s14 = Can't be used in ColorPos mode, because it can cause position errors
s15 = ReTry|ToFile|GetRange|ToClipboard
s16 = LButton Drag to select range\nDirection keys to fine tune\nRButton or ESC to get range\nDouble-Click copy to Clipboard
s17 = Please Save Picture First
s18 = Capture|ScreenShot
    )"
    Lang1:=Map(), Lang1.Default:="", Lang2:=Map(), Lang2.Default:=""
    Loop Parse, s, "`n", "`r"
      if InStr(v:=A_LoopField, "=")
        r:=StrSplit(StrReplace(v "==","\n","`n"), "=", "`t ")
        , Lang1[r[1]]:=r[2], Lang2[r[1]]:=r[3]
  }
  return getLang=1 ? Lang1 : getLang=2 ? Lang2 : Lang1[text]
}

}  ;// Class End

Script_End() {
}

;================= The End =================

;
