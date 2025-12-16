INCLUDE Irvine32.inc

Beep PROTO, dwFreq:DWORD, dwDuration:DWORD

CONSOLE_CURSOR_INFO STRUCT
  dwSize DWORD ?
  bVisible DWORD ?
CONSOLE_CURSOR_INFO ENDS

GetStdHandle PROTO, nStdHandle:DWORD
SetConsoleCursorInfo PROTO, hConsoleOutput:DWORD,
lpConsoleCursorInfo:PTR CONSOLE_CURSOR_INFO
STD_OUTPUT_HANDLE EQU -11

.data

outHandle       DWORD ?
cursorInfo      CONSOLE_CURSOR_INFO <>

; files00
filename_high   BYTE "highscores.txt", 0
filename_save   BYTE "savegame.bin", 0
fileHandle      HANDLE ?
buffer          BYTE 5000 DUP(?)
bytesRead       DWORD ?
bytesWritten    DWORD ?

; map settings
boardW          DWORD 40
boardH          DWORD 25
boardSize       DWORD 1000
boardMap        BYTE 1000 DUP(0)

; player stuff
playerX         DWORD 1
playerY         DWORD 1
playerColor     DWORD 0
playerScore     SDWORD 0
gameSpeed       DWORD 80
baseSpeed       DWORD 80

passengerActive BYTE 0
passengersDrop  DWORD 0

; modes
gameMode        DWORD 0
timeLimit       DWORD 600
careerGoal      DWORD 500

; enemy cars
NUM_NPCS        EQU 5
npcX            DWORD NUM_NPCS DUP(?)
npcY            DWORD NUM_NPCS DUP(?)
npcDir          DWORD NUM_NPCS DUP(?)

playerName      BYTE 20 DUP(0)
strScore        BYTE "SCORE: ",0
strPass         BYTE "DROPPED: ",0
strStatus       BYTE "STATUS: ",0
strEmpty        BYTE "TAXI EMPTY     ",0
strOnboard      BYTE "PASSENGER ONBOARD",0
strBonus        BYTE "BONUS ITEM!          ",0
strDropTxt      BYTE "DROP SUCCESS!        ",0
strPickupTxt    BYTE "PICKUP SUCCESS!      ",0
strCrash        BYTE "CRASH! -POINTS       ",0
strWin          BYTE "YOU WIN! GOAL REACHED!",0
strTime         BYTE "TIME LEFT: ",0
strOver         BYTE "GAME OVER! TIME UP!    ",0
strSaving       BYTE "Saving Score...",0

; menu text
menuTitle       BYTE "=== RUSH HOUR TAXI ===",0
menu1           BYTE "1. New Game",0
menu2           BYTE "2. Continue (Load Game)",0
menu3           BYTE "3. Difficulty",0
menu4           BYTE "4. Leaderboard",0
menu5           BYTE "5. Instructions",0
menu6           BYTE "6. Exit",0

modeMsg         BYTE "Select Game Mode:",0
mode1           BYTE "1. Career Mode (Reach 500 Pts)",0
mode2           BYTE "2. Time Mode (60 Seconds)",0
mode3           BYTE "3. Endless Mode (No Limits)",0

diffMsg         BYTE "Select Difficulty:",0
diff1           BYTE "1. Easy (Slow Traffic)",0
diff2           BYTE "2. Hard (Fast Traffic)",0
diffCur         BYTE "Current: ",0
strEasy         BYTE "EASY",0
strHard         BYTE "HARD",0

instrTitle      BYTE "--- INSTRUCTIONS ---",0
instr1          BYTE "1. Use Arrow Keys to Move.",0
instr2          BYTE "2. Drive to 'P' (Yellow) to Pick Up.",0
instr3          BYTE "3. Drive to 'D' (Magenta) to Drop Off.",0
instr4          BYTE "4. Avoid Blue NPC Cars and Red Obstacles.",0
instr5          BYTE "5. Press 'S' to Save, 'P' to Pause.",0
instrPress      BYTE "Press any key to return...",0

leaderTitle     BYTE "--- LEADERBOARD ---",0
leaderErr       BYTE "No highscores found.",0
scoreStrBuffer  BYTE 20 DUP(0)
newLine         BYTE 13, 10, 0
strSep          BYTE " : ", 0

inputNameMsg    BYTE "Enter Player Name: ",0
colorMsg        BYTE "Choose Taxi: (1) Yellow [Fast]  (2) Red [Slow]: ",0
pauseMsg        BYTE "GAME PAUSED (Press P to Resume)",0

.code

main PROC
    call Randomize
    call NoCursor

    ; clear screen
    mov  eax, white + (black * 16)
    call SetTextColor
    call Clrscr

MenuLoop:
    mov  eax, white + (black * 16)
    call SetTextColor
    call Clrscr

    ; draw menu
    mov  dl, 10
    mov  dh, 5
    call Gotoxy
    mov  edx, OFFSET menuTitle
    call WriteString

    mov  dl, 10
    mov  dh, 7
    call Gotoxy
    mov  edx, OFFSET menu1
    call WriteString

    mov  dl, 10
    mov  dh, 8
    call Gotoxy
    mov  edx, OFFSET menu2
    call WriteString

    mov  dl, 10
    mov  dh, 9
    call Gotoxy
    mov  edx, OFFSET menu3
    call WriteString

    mov  dl, 10
    mov  dh, 10
    call Gotoxy
    mov  edx, OFFSET menu4
    call WriteString

    mov  dl, 10
    mov  dh, 11
    call Gotoxy
    mov  edx, OFFSET menu5
    call WriteString

    mov  dl, 10
    mov  dh, 12
    call Gotoxy
    mov  edx, OFFSET menu6
    call WriteString

    call ReadChar

    ; check input
    cmp  al, '1'
    je   PickMode
    cmp  al, '2'
    je   DoLoad
    cmp  al, '3'
    je   DiffMenu
    cmp  al, '4'
    je   ShowHigh
    cmp  al, '5'
    je   ShowInst
    cmp  al, '6'
    je   QuitGame
    jmp  MenuLoop

PickMode:
    call Clrscr
    mov  edx, OFFSET modeMsg
    call WriteString
    call Crlf
    mov  edx, OFFSET mode1
    call WriteString
    call Crlf
    mov  edx, OFFSET mode2
    call WriteString
    call Crlf
    mov  edx, OFFSET mode3
    call WriteString
    call Crlf

    call ReadChar
    cmp  al, '1'
    je   ModeCareer
    cmp  al, '2'
    je   ModeTime
    cmp  al, '3'
    je   ModeEndless
    jmp  PickMode

ModeCareer:
    mov gameMode, 0
    jmp StartGame
ModeTime:
    mov gameMode, 1
    mov timeLimit, 600
    jmp StartGame
ModeEndless:
    mov gameMode, 2
    jmp StartGame

StartGame:
    call PlayerSetup
    call MakeMap
    call ResetVars
    call InitCars

    mov  eax, white + (black * 16)
    call SetTextColor
    call Clrscr
   
    call PlayGame
    jmp  MenuLoop

DoLoad:
    call LoadData
    mov  eax, white + (black * 16)
    call SetTextColor
    call Clrscr
   
    call PlayGame
    jmp  MenuLoop

DiffMenu:
    call Clrscr
    mov  edx, OFFSET diffMsg
    call WriteString
    call Crlf
    mov  edx, OFFSET diff1
    call WriteString
    call Crlf
    mov  edx, OFFSET diff2
    call WriteString
    call Crlf

    call ReadChar
    cmp  al, '1'
    je   SetEasy
    cmp  al, '2'
    je   SetHard
    jmp  MenuLoop

SetEasy:
    mov baseSpeed, 100
    mov gameSpeed, 100
    jmp MenuLoop
SetHard:
    mov baseSpeed, 50
    mov gameSpeed, 50
    jmp MenuLoop

ShowHigh:
    call Clrscr
    mov  edx, OFFSET leaderTitle
    call WriteString
    call Crlf
    call Crlf

    mov edx, OFFSET filename_high
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je NoScores

    mov fileHandle, eax

    mov edx, OFFSET buffer
    mov ecx, 4999
    call ReadFromFile
    mov buffer[eax], 0

    mov edx, OFFSET buffer
    call WriteString

    mov eax, fileHandle
    call CloseFile

    call Crlf
    mov  edx, OFFSET instrPress
    call WriteString
    call ReadChar
    jmp  MenuLoop

NoScores:
    mov  edx, OFFSET leaderErr
    call WriteString
    call Crlf
    mov  edx, OFFSET instrPress
    call WriteString
    call ReadChar
    jmp  MenuLoop

ShowInst:
    call Clrscr
    mov  edx, OFFSET instrTitle
    call WriteString
    call Crlf
    call Crlf
    mov  edx, OFFSET instr1
    call WriteString
    call Crlf
    mov  edx, OFFSET instr2
    call WriteString
    call Crlf
    mov  edx, OFFSET instr3
    call WriteString
    call Crlf
    mov  edx, OFFSET instr4
    call WriteString
    call Crlf
    mov  edx, OFFSET instr5
    call WriteString
    call Crlf
    call Crlf
    mov  edx, OFFSET instrPress
    call WriteString
    call ReadChar
    jmp  MenuLoop

QuitGame:
    exit

main ENDP

SaveScore PROC uses eax edx ecx
    mov edx, OFFSET filename_high
    call CreateOutputFile
    mov fileHandle, eax

    mov edx, OFFSET playerName
    mov ecx, 0

    mov edi, edx
    mov ecx, 0
    not ecx
    mov al, 0
    cld
    repne scasb
    not ecx
    dec ecx

    mov eax, fileHandle
    call WriteToFile

    mov edx, OFFSET strSep
    mov ecx, 3
    mov eax, fileHandle
    call WriteToFile

    mov eax, fileHandle
    call CloseFile
    ret
SaveScore ENDP

NoCursor PROC
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outHandle, eax
    mov cursorInfo.dwSize, 100
    mov cursorInfo.bVisible, 0
    INVOKE SetConsoleCursorInfo, outHandle, ADDR cursorInfo
    ret
NoCursor ENDP

PlayerSetup PROC
    mov  eax, white + (black * 16)
    call SetTextColor
    call Clrscr

    mov  edx, OFFSET inputNameMsg
    call WriteString
    mov  edx, OFFSET playerName
    mov  ecx, 19
    call ReadString

    call Crlf
    mov  edx, OFFSET colorMsg
    call WriteString

SelectColor:
    call ReadChar
    cmp  al, '1'
    je   SetYellow
    cmp  al, '2'
    je   SetRed
    jmp  SelectColor

SetYellow:
    mov  playerColor, 0
    mov  eax, baseSpeed
    mov  gameSpeed, eax
    ret
SetRed:
    mov  playerColor, 1
    mov  eax, baseSpeed
    add  eax, 30
    mov  gameSpeed, eax
    ret
PlayerSetup ENDP

PlayGame PROC

GameLoop:
    call DrawMap
    call DrawStats

    ; check mode
    cmp gameMode, 0
    je CheckCareer
    cmp gameMode, 1
    je CheckTime
    jmp InputPhase

CheckCareer:
    cmp playerScore, 500
    jge WinGame
    jmp InputPhase

CheckTime:
    dec timeLimit
    cmp timeLimit, 0
    jle GameOver
    jmp InputPhase

InputPhase:
    call ReadKey
    jz   NoInput

    cmp  ah, 48h    ; up key
    je   GoUp
    cmp  ah, 50h    ; down key
    je   GoDown
    cmp  ah, 4Bh    ; left key
    je   GoLeft
    cmp  ah, 4Dh    ; right key
    je   GoRight

    cmp  al, 'p'    ; pause
    je   PauseLabel
    cmp  al, 's'    ; save
    je   SaveLabel

    cmp  al, 'e'
    je   ActionLabel
    cmp  al, 'E'
    je   ActionLabel

NoInput:
    call MoveCars
    call SpawnPass
    mov  eax, gameSpeed
    call Delay
    jmp  GameLoop

WinGame:
    call SaveScore
    call Clrscr
    mov edx, OFFSET strWin
    call WriteString
    call WaitMsg
    ret

GameOver:
    call SaveScore
    call Clrscr
    mov edx, OFFSET strOver
    call WriteString
    call WaitMsg
    ret

GoUp:
    mov  eax, playerY
    dec  eax
    mov  ebx, playerX
    call CheckHit
    cmp  eax, 1
    je   GameLoop
    dec  playerY
    jmp  GameLoop

GoDown:
    mov  eax, playerY
    inc  eax
    mov  ebx, playerX
    call CheckHit
    cmp  eax, 1
    je   GameLoop
    inc  playerY
    jmp  GameLoop

GoLeft:
    mov  ebx, playerX
    dec  ebx
    mov  eax, playerY
    call CheckHit
    cmp  eax, 1
    je   GameLoop
    dec  playerX
    jmp  GameLoop

GoRight:
    mov  ebx, playerX
    inc  ebx
    mov  eax, playerY
    call CheckHit
    cmp  eax, 1
    je   GameLoop
    inc  playerX
    jmp  GameLoop

PauseLabel:
    mov  dl, 0
    mov  dh, 28
    call Gotoxy
    mov  edx, OFFSET pauseMsg
    call WriteString
PauseLoop:
    call ReadChar
    cmp  al, 'p'
    jne  PauseLoop
    jmp  GameLoop

SaveLabel:
    mov  edx, OFFSET filename_save
    call CreateOutputFile
    mov  fileHandle, eax

    mov  eax, fileHandle
    mov  edx, OFFSET boardMap
    mov  ecx, boardSize
    call WriteToFile

    mov  eax, fileHandle
    mov  edx, OFFSET playerScore
    mov  ecx, 4
    call WriteToFile

    mov  eax, fileHandle
    call CloseFile
    jmp  GameLoop

ActionLabel:
    jmp GameLoop

PlayGame ENDP

CheckHit PROC uses esi
    push eax
    imul eax, boardW
    add  eax, ebx
    mov  esi, eax
    pop  eax

    ; check bounds
    cmp  ebx, 0
    jl   IsWall
    cmp  ebx, boardW
    jge  IsWall
    cmp  eax, 0
    jl   IsWall
    cmp  eax, boardH
    jge  IsWall

    movzx ecx, boardMap[esi]
    cmp  ecx, 1
    je   IsWall
    cmp  ecx, 2
    je   HitObs
    cmp  ecx, 5        
    je   HitCar

    cmp  ecx, 3
    je   PickIt

    cmp  ecx, 4
    je   DropIt

    mov  eax, 0
    ret

IsWall:
    mov  eax, 1
    ret

HitObs:
    INVOKE Beep, 400, 200
    cmp  playerColor, 0
    je   PenYellow
    sub  playerScore, 2
    jmp  ClearObs
PenYellow:
    sub  playerScore, 4
ClearObs:
    mov  boardMap[esi], 0
    mov  eax, 0
    ret

HitCar:
    INVOKE Beep, 200, 300
    sub playerScore, 5
    mov eax, 0
    ret

PickIt:
    cmp passengerActive, 1
    je  SafeMove

    mov passengerActive, 1
    mov boardMap[esi], 0
    INVOKE Beep, 1000, 100
    call MakeDest
    mov eax, 0
    ret

DropIt:
    cmp passengerActive, 0
    je  SafeMove

    mov passengerActive, 0
    mov boardMap[esi], 0
    add playerScore, 10
    inc passengersDrop
    INVOKE Beep, 1500, 150
   
    ; check speed
    mov edx, 0
    mov eax, passengersDrop
    mov ecx, 2
    div ecx
    cmp edx, 0
    jne SafeMove
    sub gameSpeed, 10
    cmp gameSpeed, 10
    jg  SafeMove
    mov gameSpeed, 10

SafeMove:
    mov eax, 0
    ret
CheckHit ENDP

InitCars PROC uses ecx esi
    mov ecx, NUM_NPCS
    mov esi, 0
InitLoop:
    call GetRandPos
    mov eax, esi
    mov edx, 0
    mov ebx, boardW
    div ebx

    mov npcY[esi*4], eax
    mov npcX[esi*4], edx

    mov eax, 4
    call RandomRange
    mov npcDir[esi*4], eax

    mov boardMap[esi], 5

    inc esi
    loop InitLoop
    ret
InitCars ENDP

MoveCars PROC uses ecx esi eax ebx
    mov ecx, NUM_NPCS
    mov esi, 0

NpcLoop:
    mov eax, npcY[esi*4]
    imul eax, boardW
    add eax, npcX[esi*4]
    mov edi, eax
    mov boardMap[edi], 0

    mov eax, npcY[esi*4]
    mov ebx, npcX[esi*4]

    cmp npcDir[esi*4], 0
    je DirUp
    cmp npcDir[esi*4], 1
    je DirDown
    cmp npcDir[esi*4], 2
    je DirLeft
    cmp npcDir[esi*4], 3
    je DirRight

DirUp:
    dec eax
    jmp CheckNpc
DirDown:
    inc eax
    jmp CheckNpc
DirLeft:
    dec ebx
    jmp CheckNpc
DirRight:
    inc ebx
    jmp CheckNpc

CheckNpc:
    push eax
    imul eax, boardW
    add eax, ebx
    mov edi, eax
    pop eax

    cmp ebx, 0
    jl RevDir
    cmp ebx, boardW
    jge RevDir
    cmp eax, 0
    jl RevDir
    cmp eax, boardH
    jge RevDir

    mov dl, boardMap[edi]
    cmp dl, 0
    jne RevDir

    mov npcY[esi*4], eax
    mov npcX[esi*4], ebx
    mov boardMap[edi], 5
    jmp NextNpc

RevDir:
    push eax
    mov eax, 4
    call RandomRange
    mov npcDir[esi*4], eax
    pop eax

    mov eax, npcY[esi*4]
    imul eax, boardW
    add eax, npcX[esi*4]
    mov edi, eax
    mov boardMap[edi], 5

NextNpc:
    inc esi
    dec ecx
    cmp ecx, 0
    jg NpcLoop

    ret
MoveCars ENDP

MakeMap PROC
    mov  ecx, boardSize
    mov  esi, 0
GenLoop:
    mov  eax, 100
    call RandomRange
    ; wall chance
    cmp  eax, 15
    jl   WallTile

    ; obs chance
    cmp  eax, 20
    jl   ObsTile

    mov  boardMap[esi], 0
    jmp  NextTile

WallTile:
    mov  boardMap[esi], 1
    jmp  NextTile

ObsTile:
    mov  boardMap[esi], 2

NextTile:
    inc  esi
    dec  ecx
    jnz  GenLoop

    mov  boardMap[41], 0
    mov  boardMap[42], 0
    mov  boardMap[81], 0

    mov  eax, 3
    call RandomRange
    add  eax, 3

    mov  ecx, eax
SpawnInit:
    push ecx
    call GetRandPos
    mov boardMap[esi], 3
    pop ecx
    loop SpawnInit

    ret
MakeMap ENDP

DrawMap PROC uses ebx
    mov  dl, 0
    mov  dh, 0
    call Gotoxy
    mov  eax, white + (black * 16)
    call SetTextColor

    mov  al, 201
    call WriteChar
    mov  ecx, boardW
TopLine:
    mov  al, 205
    call WriteChar
    loop TopLine
    mov  al, 187
    call WriteChar

    mov  esi, 0
    mov  ecx, 0

RowLoop:
    push ecx

    inc  cl
    mov  dh, cl
    mov  dl, 0
    call Gotoxy

    mov  eax, white + (black * 16)
    call SetTextColor
    mov  al, 186
    call WriteChar

    mov  ecx, boardW
    mov  ebx, 0

ColLoop:
    cmp  ebx, playerX
    jne  DrawItem
    mov  al, byte ptr [esp]
    cmp  al, byte ptr playerY
    jne  DrawItem

    cmp  playerColor, 0
    je   CarYellow
    mov  eax, yellow + (black * 16)
    jmp  PrintCar
CarYellow:
    mov  eax, lightRed + (black * 16)
PrintCar:
    call SetTextColor
    mov  al, 254
    call WriteChar
    jmp  Continue

DrawItem:
    movzx eax, boardMap[esi]

    cmp  eax, 0
    je   DrawRoad
    cmp  eax, 1
    je   DrawWall
    cmp  eax, 2
    je   DrawObs
    cmp  eax, 3
    je   DrawPass
    cmp  eax, 4
    je   DrawDest
    cmp  eax, 5
    je   DrawNpc

    jmp  DrawRoad

DrawObs:
    mov  eax, lightRed + (black * 16)
    call SetTextColor
    mov  al, 177
    call WriteChar
    jmp  Continue

DrawRoad:
    mov  eax, gray + (black * 16)
    call SetTextColor
    mov  al, 250
    call WriteChar
    jmp  Continue

DrawWall:
    mov  eax, gray + (black * 16)
    call SetTextColor
    mov  al, 178
    call WriteChar
    jmp  Continue

DrawPass:
    mov  eax, yellow + (black * 16)
    call SetTextColor
    mov  al, 'P'
    call WriteChar
    jmp  Continue

DrawDest:
    mov  eax, lightMagenta + (black * 16)
    call SetTextColor
    mov  al, 'D'
    call WriteChar
    jmp  Continue

DrawNpc:
    mov  eax, lightBlue + (black * 16)
    call SetTextColor
    mov  al, 254
    call WriteChar

Continue:
    inc  esi
    inc  ebx
    dec  ecx
    jnz  ColLoop

    mov  eax, white + (black * 16)
    call SetTextColor
    mov  al, 186
    call WriteChar

    pop  ecx
    inc  ecx
    cmp  ecx, boardH
    jl   RowLoop

    mov  dl, 0
    mov  dh, 26
    call Gotoxy
    mov  eax, white + (black * 16)
    call SetTextColor

    mov  al, 200
    call WriteChar
    mov  ecx, boardW
BotLine:
    mov  al, 205
    call WriteChar
    loop BotLine
    mov  al, 188
    call WriteChar

    ret
DrawMap ENDP

DrawStats PROC
    mov  dl, 0
    mov  dh, 27
    call Gotoxy

    mov  eax, white + (black * 16)
    call SetTextColor

    mov  al, 201
    call WriteChar
    mov  ecx, 38
    mov  al, 205
HudLine1:
    call WriteChar
    loop HudLine1
    mov  al, 187
    call WriteChar

    mov  dl, 0
    mov  dh, 28
    call Gotoxy
    mov  al, 186
    call WriteChar

    mov  dl, 2
    call Gotoxy
    mov  edx, OFFSET strScore
    call WriteString
    mov  eax, playerScore
    call WriteInt

    cmp gameMode, 1
    jne PassStat

    mov dl, 15
    call Gotoxy
    mov edx, OFFSET strTime
    call WriteString
    mov eax, timeLimit
    call WriteDec
    jmp StatShow

PassStat:
    mov  dl, 15
    call Gotoxy
    mov  edx, OFFSET strPass
    call WriteString
    mov  eax, passengersDrop
    call WriteDec

StatShow:
    mov  dl, 25
    call Gotoxy
    cmp  passengerActive, 1
    je   ShowOnboard
    mov  eax, lightGreen + (black * 16)
    call SetTextColor
    mov  edx, OFFSET strEmpty
    jmp  PrintStat
ShowOnboard:
    mov  eax, lightCyan + (black * 16)
    call SetTextColor
    mov  edx, OFFSET strOnboard
PrintStat:
    call WriteString

    mov  eax, white + (black * 16)
    call SetTextColor
    mov  dl, 39
    mov  dh, 28
    call Gotoxy
    mov  al, 186
    call WriteChar

    mov  dl, 0
    mov  dh, 29
    call Gotoxy
    mov  al, 200
    call WriteChar
    mov  ecx, 38
    mov  al, 205
HudLine2:
    call WriteChar
    loop HudLine2
    mov  al, 188
    call WriteChar

    ret
DrawStats ENDP

SpawnPass PROC uses eax ecx esi ebx
    mov  ecx, boardSize
    mov  esi, 0
    mov  ebx, 0

CountLoop:
    movzx eax, boardMap[esi]
    cmp   eax, 3
    jne   CheckNext
    inc   ebx
CheckNext:
    inc   esi
    dec   ecx
    jnz   CountLoop

    cmp   ebx, 3
    jl    ForceSpawn
    ret

ForceSpawn:
    call GetRandPos
    mov  boardMap[esi], 3
    ret
SpawnPass ENDP

MakeDest PROC
RetryDest:
    call GetRandPos
    push eax
    mov  eax, playerY
    imul eax, boardW
    add  eax, playerX
    cmp  esi, eax
    pop  eax
    je   RetryDest

    mov  boardMap[esi], 4
    ret
MakeDest ENDP

GetRandPos PROC
Search:
    mov  eax, boardSize
    call RandomRange
    mov  esi, eax
    cmp  boardMap[esi], 0
    jne  Search
    ret
GetRandPos ENDP

ResetVars PROC
    mov playerScore, 0
    mov passengersDrop, 0
    mov passengerActive, 0
    mov playerX, 1
    mov playerY, 1
    ret
ResetVars ENDP

LoadData PROC
    mov  edx, OFFSET filename_save
    call OpenInputFile
    cmp  eax, INVALID_HANDLE_VALUE
    je   LoadFail
    mov  fileHandle, eax

    mov  eax, fileHandle
    mov  edx, OFFSET boardMap
    mov  ecx, boardSize
    call ReadFromFile

    mov  eax, fileHandle
    mov  edx, OFFSET playerScore
    mov  ecx, 4
    call ReadFromFile

    mov  eax, fileHandle
    call CloseFile
    ret
LoadFail:
    ret
LoadData ENDP

END main
