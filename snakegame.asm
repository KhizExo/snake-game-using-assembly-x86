INCLUDE Irvine32.inc

.data
heading BYTE "SNAKE GAME",0
borders BYTE 52 DUP("*"),0

Difficultyprompt BYTE "Difficulty (1-Hard, 2-Medium, 3-Easy): ",0
speed	DWORD 0

scorePrompts BYTE "Your score is: ",0
score BYTE 0

RetryMsg BYTE "Press 1 to retry, 0 to end",0
Errormsg BYTE "Inavlid Input",0
wasted BYTE "WASTED :(",0
pointPrompt BYTE "Score",0
blank BYTE "                                     ",0
snake BYTE "=", 104 DUP("=")
Axis_x BYTE 45,44,43,42,41, 100 DUP(?)
Axis_y BYTE 15,15,15,15,15, 100 DUP(?)

border_x BYTE 34,34,85,85			
border_y BYTE 5,24,5,24

food_x BYTE ?
food_y BYTE ?

inputChar BYTE "+"					
lastInputChar BYTE ?				



.code
main PROC
mov eax,yellow+(black*16)
call settextcolor
mov dh,3
mov dl,45
call gotoxy
mov edx,OFFSET heading
call writestring
;Specifies Difficulty
call DifficultyMenu	

;Generates Player Boundaries
call BorderGenerator

mov esi,0
mov ecx,5
snakemaker:
	call SnakeGenerator			
	inc esi
loop snakemaker

	call Randomize
	call FoodGenerator
	call Food			
startgame::
mov dl,106
mov dh,1
call gotoxy

;check user input
call readkey
jz keynotpressed  ;if no key is entered the loop will jump to empty label
checkkey:
;input char stored in lastinputchar
mov bl, inputchar
mov lastinputchar,bl
;new input stored in inputchar
mov inputchar,al

;Controls:
;W : Forward
;A : Left
;S : Reverse
;D : Right
keynotpressed:
cmp inputchar, "x" ;end of game
je quitgame
cmp inputchar,"w" ;forward
je checkfront
cmp inputchar,"a" ;left
je checkleft
cmp inputchar,"s" ;back
je checkbefore
cmp inputchar,"d" ;right
je checkright
jne startgame
; check whether snake can continue moving
		checkbefore:	
		cmp lastInputChar, "w"
		je dontChgDirection		;since snake is going down it is impossible to go up
		mov cl, border_y[1]
		dec cl					;one unit above the lower wall
		cmp Axis_y[0],cl			;if current position of snake is exactly above lower wall it dies in the next move
		jl moveDown				
		je died					;dies due to collision with wall

		checkLeft:		
		cmp lastInputChar, "+"	;check whether its the start of the game
		je dontGoLeft			;if the game has not started yet it will not go left
		cmp lastInputChar, "d"  ;cant goleft after going right
		je dontChgDirection
		mov cl, border_x[0]		
		inc cl					
		cmp Axis_x[0],cl	
		jg moveLeft				;if current position of snake is exactly above left wall it dies in the next move
		je died					;Dies due to collision with wall
		

		; check for right	
		checkRight:		
		cmp lastInputChar, "a"
		je dontChgDirection
		mov cl, border_x[2]
		dec cl
		cmp Axis_x[0],cl
		jl moveRight
		je died	
		

		; check for up
		checkfront:		
		cmp lastInputChar, "s"
		je dontChgDirection
		mov cl, border_y[0]
		inc cl
		cmp Axis_y,cl
		jg moveUp
		je died
		

		moveUp:		
		mov eax, speed		
		add eax, speed
		call delay
		mov esi, 0			;snake head
		call UpdatePlayer	
		mov ah, Axis_y[esi]	
		mov al, Axis_x[esi]	;al,ah stores the positions of snakes body 
		dec Axis_y[esi]		;move the head up
		call SnakeGenerator		
		call DrawBody
		call CheckSnake

		
		moveDown:			;move down
		mov eax, speed
		add eax, speed
		call delay
		mov esi, 0
		call UpdatePlayer
		mov ah, Axis_y[esi]
		mov al, Axis_x[esi]
		inc Axis_y[esi]
		call SnakeGenerator
		call DrawBody
		call checksnake


		moveLeft:			;move left
		mov eax, speed
		call delay
		mov esi, 0
		call UpdatePlayer
		mov ah, Axis_y[esi]
		mov al, Axis_x[esi]
		dec Axis_x[esi]
		call SnakeGenerator
		call DrawBody
		call checksnake


		moveRight:			;move right
		mov eax, speed
		call delay
		mov esi, 0
		call UpdatePlayer
		mov ah, Axis_y[esi]
		mov al, Axis_x[esi]
		inc Axis_x[esi]
		call SnakeGenerator
		call DrawBody
		call checksnake


		checkfood::
		mov esi,0
		mov bl,Axis_x[0]
		cmp bl,food_x
		jne startgame			;reloop if snake is not intersecting with coin
		mov bl,Axis_y[0]
		cmp bl,food_y
		jne startgame			;reloop if snake is not intersecting with coin

		call EatingFood			;call to update score, append snake and generate new coin	

jmp startgame				;reiterate the gameloop



	dontChgDirection:		;dont allow user to change direction
	mov inputChar, bl		;set current inputChar as previous
	jmp keynotpressed				;jump back to continue moving the same direction 

	dontGoLeft:				;forbids the snake to go left at the begining of the game
	mov	inputChar, "+"		;set current inputChar as "+"
	jmp startgame			;restart the game loop

	died::
	call Youdied
	 
	playagn::			
	call ReinitializeGame			;reinitialise everything
	
	quitgame::

exit
exit
main ENDP

BorderGenerator PROC		

;Upper Boundary
mov dl,border_x[0]
mov dh,border_y[0]
call Gotoxy	
mov edx,OFFSET borders
call WriteString			

;Lower Boundary
mov dl,border_x[1]
mov dh,border_y[1]
call Gotoxy	
mov edx,OFFSET borders		
call WriteString		

;Right Boundary
mov dl, border_x[2]
mov dh, border_y[2]
mov eax,"*"	

;Keep looping till it reaches the bottom part of the border
L1: 
call Gotoxy	
call WriteChar	
inc dh ;changeline
;border_y[2] = y axis pa 5 rkha ha
;border_y[3] = y axis pa 85 rkha ha
cmp dh, border_y[3]			
jl L1

;Left Boundary
;Loop starts from coordinates (34,5) and end at (34,24)
mov dl, border_x[0]
mov dh, border_y[0]
mov eax,"*"	
L12: 
call Gotoxy	
call WriteChar	
inc dh
cmp dh, border_y[3]			
jl L12
ret
BorderGenerator ENDP


DifficultyMenu PROC			;procedure for player to choose speed
mov edx,0
mov dl,34				
mov dh,12
call Gotoxy	
mov edx,OFFSET Difficultyprompt	
call WriteString
call crlf
mov esi,40				;Default Speed
mov eax,0
mov dl,48				
mov dh,14
call Gotoxy
call readInt			
cmp ax,1				
jl error
cmp ax, 3
jg error
mul esi					
mov speed, eax
call clrscr
ret

;User enters wrong input
error:			
mov edx, OFFSET ErrorMsg
call msgbox
call DifficultyMenu					
ret
DifficultyMenu ENDP

SnakeGenerator PROC	
	mov dl,Axis_x[esi]	
	mov dh,Axis_y[esi]	
	call Gotoxy
	push eax			
	mov al, snake[esi]		
	call WriteChar
	pop eax		
	ret
SnakeGenerator ENDP

UpdatePlayer PROC		; erase player at (Axis_x,Axis_y)
mov dl,Axis_x[esi]
mov dh,Axis_y[esi]
call Gotoxy
mov dl, al			;temporarily save al in dl
mov al, " "
	call WriteChar
	mov al, dl
	ret
UpdatePlayer ENDP

Food PROC
mov dl,food_x
mov dh,food_y
call Gotoxy
mov al,"F"
call WriteChar
ret
Food ENDP

FoodGenerator PROC			
mov eax,49
call RandomRange	;Generate a random number between 0-49 and add 35 to ensure it is within the walls
add eax,36			;Border Range: 35 - 85 Max Food Range = 36-84
mov food_x,al
mov eax,17			
call RandomRange	;Generate no. from 0-17
add eax,6			;Food Range = 6-23
mov food_y,al
ret
FoodGenerator ENDP



DrawBody PROC				;procedure to print body of the snake
		mov ecx, 4
		add cl, score		;number of iterations to print the snake body n tail	
		printbodyloop:	
		inc esi				;loop to print remaining units of snake
		call UpdatePlayer
		mov dl, Axis_x[esi]
		mov dh, Axis_y[esi]	;dldh temporarily stores the current pos of the unit 
		mov Axis_y[esi], ah
		mov Axis_x[esi], al	;assign new position to the unit
		mov al, dl
		mov ah,dh			;move the current position back into alah
		call SnakeGenerator
		cmp esi, ecx
		jl printbodyloop
	ret
DrawBody ENDP
CheckSnake PROC				;check whether the snake head collides w its body 
	mov al, Axis_x[0] 
	mov ah, Axis_y[0] 
	mov esi,4				;start checking from index 4(5th unit)
	mov ecx,1
	add cl,score
checkXposition:
	cmp Axis_x[esi], al		;check if Axis_x same ornot
	je XposSame
	contloop:
	inc esi
loop checkXposition
	jmp checkfood
	XposSame:				; if Axis_x same, check for Axis_y
	cmp Axis_y[esi], ah
	je died					;if collides, snake dies
	jmp contloop

CheckSnake ENDP

EatingFood PROC
	; snake is eating food
	inc score
	mov ebx,4
	add bl, score
	mov esi, ebx
	mov ah, Axis_y[esi-1]
	mov al, Axis_x[esi-1]	
	mov Axis_x[esi], al		;Make the snake bigger
	mov Axis_y[esi], ah		;pos of new tail = pos of old tail

	cmp Axis_x[esi-2], al		;check if the old tail and the unit before is on the yAxis
	jne checky				;jump if not on the yAxis

	cmp Axis_y[esi-2], ah		;check if the new tail should be above or below of the old tail 
	jl incy			
	jg decy
	incy:					;inc if below
	inc Axis_y[esi]
	jmp continue
	decy:					;dec if above
	dec Axis_y[esi]
	jmp continue

	checky:					;old tail and the unit before is on the xAxis
	cmp Axis_y[esi-2], ah		;check if the new tail should be right or left of the old tail
	jl incx
	jg decx
	incx:					;inc if right
	inc Axis_x[esi]			
	jmp continue
	decx:					;dec if left
	dec Axis_x[esi]

	continue:				;add snake tail and update new coin
	call SnakeGenerator		
	call FoodGenerator
	call Food			

	mov dl,17				; write updated score
	mov dh,1
	call Gotoxy
	mov al,score
	call WriteInt
	ret
EatingFood ENDP

YouDied PROC
	mov eax, 1000
	call delay
	Call ClrScr	
	
	mov dl,	57
	mov dh, 12
	call Gotoxy
	mov edx, OFFSET wasted	;"you died"
	call WriteString

	mov dl,	56
	mov dh, 14
	call Gotoxy
	
	mov edx, OFFSET scorePrompts	;display score
	call WriteString
	movzx eax, score
	call WriteInt

	mov dl,	50
	mov dh, 18
	call Gotoxy
	mov edx, OFFSET RetryMsg
	call WriteString		;"try again?"

	retry:
	mov dh, 19
	mov dl,	56
	call Gotoxy
	call ReadInt			;get user input
	cmp al, 1
	je playagn				;playagn
	cmp al, 0
	je quitgame				;exitgame

	mov dh,	17
	call Gotoxy
	mov edx, OFFSET ErrorMsg	;"Invalid input"
	call WriteString		
	mov dl,	56
	mov dh, 19
	call Gotoxy
	mov edx, OFFSET blank			;erase previous input
	call WriteString
	jmp retry						;let user input again
YouDied ENDP



ReinitializeGame PROC		;procedure to reinitialize everything
	mov Axis_x[0], 45
	mov Axis_x[1], 44
	mov Axis_x[2], 43
	mov Axis_x[3], 42
	mov Axis_x[4], 41
	mov Axis_y[0], 15
	mov Axis_y[1], 15
	mov Axis_y[2], 15
	mov Axis_y[3], 15
	mov Axis_y[4], 15			;reinitialize snake position
	mov score,0				;reinitialize score
	mov lastInputChar, 0
	mov	inputChar, "+"			;reinitialize inputChar and lastInputChar
	dec border_y[3]			;reset wall position
	Call ClrScr
	jmp main				;start over the game
ReinitializeGame ENDP
END main