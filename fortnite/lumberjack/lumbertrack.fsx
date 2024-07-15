open System 
open System.Text.RegularExpressions
open System.IO
let p = File.ReadAllLines("prestiges.txt")

let abbr = ",k,M,B,T,Qa,Qt,Sx,Sp,Oc,No,Dc,UDc,DDc,TDc,QaDc,QtDc,SxDc,SpDc,ODc,NDc,Vg,UVg,DVg,TVg,QaVg,QtVg,SxVg,SpVg,OVg,NVg,Tg,UTg,DTg,TTg,QaTg,QtTg,SxTg,SpTg,OTg,NTg,Qd,UQd,DQd,TQd,QaQd,QtQd,SxQd,SpQd,OQd,NQd,Qi,UQi,DQi,TQi,QaQi,QtQi,SxQi,SpQi,OQi,NQi,Se,USe,DSe,TSe,QaSe,QtSe,SxSe,SpSe,OSe,NSe,St,USt,DSt,TSt,QaSt,QtSt,SxSt,SpSt,OSt,NSt,Og,UOg,DOg,TOg,QaOg,QtOg,SxOg,SpOg,OOg,NOg,Nn,UNn,DNn,TNn,QaNn,QtNn,SxNn,SpNn,ONn,NNn,e303".Split(",")
let exponents = 
    abbr  
    |> Seq.mapi (fun i s -> s.ToLower(),i*3)
    |> Map.ofSeq

let rx = Regex("\s*([0-9.]+)\s*([a-z]*)")

let ljh2exp s = 
    let m = rx.Match(s)
    let xp = exponents.TryFind(m.Groups[2].Value)
    if xp.IsSome then 
        let b,d = Double.TryParse(m.Groups[1].Value + "e" + xp.Value.ToString())
        if b then d else nan
    else nan

// printfn "%A" (ljh2exp "2vg") 

for ln in p do
    let [|wood ; crystals|] = ln.Split(",") 
    printfn "%6.3g,%6.3g" (ljh2exp wood) (ljh2exp crystals)

// after asking chatgpt to perform a regression

let crystals_given_wood wood = 
    let a = 5.75e13
    let b = -1e16 
    let c = 3.89e17
    a * wood*wood + b * wood + c 

for ln in p do
    let [|wood ; crystals|] = ln.Split(",") 
    let wood = (ljh2exp wood)
    printfn "%6.3g,%6.3g,%6.3g" wood (ljh2exp crystals) (crystals_given_wood wood)
