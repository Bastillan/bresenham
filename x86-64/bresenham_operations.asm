;=====================================================================
; Jedrzej Kedzierski 325169	ARKO 23L
; Bresenham Line Drawing Algorithm
;
;	ImageInfo* draw_line_x(ImageInfo* pImg, Coords* start, Coords* end, unsigned int color);
;	ImageInfo* draw_line_y(ImageInfo* pImg, Coords* start, Coords* end, unsigned int color);
;=====================================================================

; ImageInfo structure layout
img_width		EQU 0
img_height		EQU 4
img_linebytes	EQU 8
img_bitsperpel	EQU 12
img_pImg		EQU	16

; Coords structure layout
pos_x			EQU 0
pos_y			EQU 4

section	.text
global  draw_line_x
global	draw_line_y

; Function's arguments:
; ------------------------------
; RDI - ImageInfo pImg's address
; ------------------------------
; RSI - Coords start's address
; ------------------------------
; RDX - Coords end's address
; ------------------------------
; RCX (CL) - color
; ------------------------------

;============================================

;          ___---
; __------/
;/

; drawing "low" line
draw_line_x:
	; y update value
	mov r8d, [rdi + img_linebytes]	; R8 - line in bytes -> y update value

	; securing values from RDX, before MUL R8 instruction as is result is saved in RDX:RAX
	mov r10d, [rdx + pos_x]			; R10 = end.pos_x
	mov r11d, [rdx + pos_y]			; R11 = end.pos_y

	; finding first pixels
	mov eax, [rsi + pos_y]			; RAX = start.pos_y
	mul r8							; RAX = RAX * R8 (y*img_linebytes)
	mov edx, [rsi + pos_x]			; RDX = start.pos_x
	mov r9, rdx						; R9 = start.pos_x stored for later use
	shr rdx, 3						; x/8
	add rax, rdx					; RAX = pixel's byte offset
	add rax, [rdi + img_pImg]		; RAX = current byte address

	; initializing algorithm's values
	sub r10, r9						; R10 = dx
	mov edx, [rsi + pos_y]			; RDX = start.pos_y
	mov rsi, r10					; RSI = loop_counter = dx
	sub r11, rdx					; R11 = dy
	jg direction_set				; sub sets the flags	if (dy < 0) then y will be decrementing
	neg r8							; setting y update value to be negative
	neg r11							; negating dy


direction_set:
	shl r11, 1				; R11 = 2dy
	mov rdi, r11			; RDI = D(decision factor) = 2dy - dx
	sub rdi, r10
	shl r10, 1				; R10 = 2dx

	; mask and color
	and r9b, 0x7			; R9B = pixel's offset within the byte = x%8
	xchg r9b, cl			; CL = pixel's offset within the byte	//	R9B = color			|| the nesesary swap for ROR instruction
	mov ch, 0x7f			; CH = pixel's mask
	ror ch, cl				; ROR instruction uses CL register as the count operand, for this reason values in CL and R9B were swaped
	add cl, 1
	ror r9b, cl				; R9B = color

;	R10 = 2dx		R11 = 2dy		RDI = D (decision factor)		RSI = loop_counter		RAX = current byte address
;	R8 = y update value				R9B = color						CH = pixel's mask

draw_loop:
	; setting pixel's color
	and [rax], ch
	or [rax], r9b

	dec rsi
	js draw_line_exit

	; rotating pixel's mask and color
	ror r9b, 1
	ror ch, 1

	; checking if mask starts from the begining [01111111]
	cmp ch, 0x7F
	jne draw_loop_continue

	; changing working byte
	add rax, 1

draw_loop_continue:
	test rdi, rdi
	js go_right

go_up_down:
	; D-=2dx
	; byte's address =+ (y update value)
	sub rdi, r10
	add rax, r8

go_right:
	; D+/-=2dy
	add rdi, r11
	jmp draw_loop

draw_line_exit:
	ret

; ---------------------------------------------
;
; ---------------------------------------------

;  /
; |
;/

; drawing "hight" line
draw_line_y:
	; y update value
	mov r8d, [rdi + img_linebytes]	; R8 - line in bytes -> y update value

	; securing values from RDX, before MUL R8 instruction as is result is saved in RDX:RAX
	mov r10d, [rdx + pos_x]			; R10 = end.pos_x
	mov r11d, [rdx + pos_y]			; R11 = end.pos_y

	; finding first pixels
	mov eax, [rsi + pos_y]			; RAX = start.pos_y
	mul r8							; RAX = RAX * R8 = (y*img_linebytes)
	mov edx, [rsi + pos_x]			; RDX = start.pos_x
	mov r9, rdx						; R9 = start.pos_x stored for later use
	shr rdx, 3						; x/8
	add rax, rdx					; RAX = pixel's byte offset
	add rax, [rdi + img_pImg]		; RAX = current byte address

	; initializing algorithm's values
	sub r10, r9						; R10 = dx
	mov edx, [rsi + pos_y]			; RDX = start.pos_y
	sub r11, rdx					; R11 = dy
	mov rsi, r11					; RSI = loop_counter = dy
	jg y_direction_set				; sub sets the flags	if (dy < 0) then y will be decrementing
	neg r8							; setting y update value to be negative
	neg r11							; negating dy
	neg rsi							; negating loop_counter

y_direction_set:
	shl r10, 1				; R10 = 2dx
	mov rdi, r10			; RDI = D(decision factor) = 2dx - dy
	sub rdi, r11
	shl r11, 1				; R11 = 2dy

	; mask and color
	and r9b, 0x7			; R9B = pixel's offset within the byte = x%8
	xchg r9b, cl			; CL = pixel's offset within the byte	//	R9B = color			|| nesesary swap for the ROR instruction
	mov ch, 0x7f			; CH = pixel's mask
	ror ch, cl				; ROR instruction uses CL register as the count operand, for this reason values in CL and R9B were swaped
	add cl, 1
	ror r9b, cl				; R9B = color

;	R10 = 2dx		R11 = 2dy		RDI = D (decision factor)		RSI = loop_counter		RAX = current byte address
;	R8 = y update value				R9B = color						CH = pixel's mask

y_draw_loop:
	; setting pixel's color
	and [rax], ch
	or [rax], r9b

	dec esi
	js y_draw_line_exit

	; adding/subtracting one line = position y +/-= 1
	add rax, r8

	test rdi, rdi
	js y_go_up_down

y_go_right:
	; rotating pixel's mask and color
	ror r9b, 1
	ror ch, 1

	; D-=2dy
	sub rdi, r11

	; checking if mask starts from the begining [01111111]
	cmp ch, 0x7F
	jne y_go_up_down

	; changing working byte
	add rax, 1

y_go_up_down:
	; D+=2dx
	add rdi, r10
	jmp y_draw_loop

y_draw_line_exit:
	ret