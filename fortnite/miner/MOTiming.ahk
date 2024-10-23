; MOTiming.ahk
;https://github.com/RaptorX/SQLite
; https://www.autohotkey.com/boards/viewtopic.php?style=7&t=123107

#include ".\SQLite\SQLite.ahk" 

; #maxthreads	20
; example usage
; db := SQLite() ; this creates a temporary file that will be deleted on close
; db.Exec('BEGIN TRANSACTION;')
; db.Exec('CREATE TABLE IF NOT EXISTS test (id INTEGER PRIMARY KEY, name TEXT, value REAL)')
; loop 20
; 	db.Exec('INSERT INTO test VALUES(' A_Index ', "name' A_Index '", "value' A_Index '");')
; db.Exec('COMMIT TRANSACTION;')
; table := db.Exec('SELECT * FROM test')
; msgbox table.count


flags := SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
db3 := SQLite.Open('miner.db', flags)

db3.Exec("CREATE TABLE IF NOT EXISTS timing(start_time datetime, end_time datetime, elapsed double, start_hp double, end_hp double, event TEXT, description text);")

; Function to insert timing data
InsertTiming(event, description := "", start_time := "", end_time := "", elapsed := 0.0, start_hp := 0.0, end_hp := 0.0) {
    global db3
	db3.Exec('BEGIN TRANSACTION;')
	RegExMatch(start_time, "(....)(..)(..)(..)(..)(..)", &p)
	st:=p[1] "-" p[2] "-" p[3] " " p[4] ":" p[5] ":" p[6] 
	RegExMatch(end_time, "(....)(..)(..)(..)(..)(..)", &p)
	et:=p[1] "-" p[2] "-" p[3] " " p[4] ":" p[5] ":" p[6] 	
	db3.Exec("INSERT INTO timing (start_time, end_time, elapsed, start_hp, end_hp, event, description) VALUES (datetime('" . 
	  st "'), datetime('" et "'), " elapsed ", " start_hp ", " end_hp ", " elapsed ", '" event "', '" description "')")
	db3.Exec("COMMIT TRANSACTION;")
}

; db3.Exec('BEGIN TRANSACTION;')
; Loop 2 {
; 	HP := Random(1, 100)
; 	InsertTiming("StartMining", "Beginning mining operation", A_Now, A_Now, 0.0, HP, HP)
; 	if db3.error {
; 		ToolTip("error: " db3.error)
; 	}
; }
; db3.Exec('COMMIT TRANSACTION;')
; db3.Close()



; #Include ".\AHK-ToolKit\AHK-ToolKit.ahk"

#HotIf WinActive(FORTNITEWINDOW)
^+t::measure_30seconds()
#HotIf

; Measure hp at start and 100 seconds later
measure_30seconds() {	
	global hp := -1
	FindText().ToolTip("start timing for 30 seconds")
	Click()
	Sleep(500)
	dttm := FormatTime(A_Now, "yyyyMMdd_HHmmss")
	FindText().ScreenShot()
	FindText().SavePic("meteor_hp_" dttm "_start.png", 1184, 35, 1376, 44)
	start_tick := A_TickCount
	start_time := A_Now
	hp := get_meteorhp()
	; sleep(100000)
	clicker_unfocused_meteor(false, 30)
	end_tick := A_TickCount
	elapsed := (end_tick - start_tick) * 0.001
	end_time := A_Now
	hp2 := get_meteorhp()
	FindText().ScreenShot()
	FindText().SavePic("meteor_hp_" dttm "_end.png", 1184, 35, 1376, 44)
	InsertTiming("Measure", "30 seconds", start_time, end_time, elapsed, hp, hp2)
	FindText().ToolTip("done, hpdiff: " hp - hp2)
	
}



    




