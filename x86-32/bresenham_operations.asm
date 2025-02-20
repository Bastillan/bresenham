;=====================================================================
; Jedrzej Kedzierski 325169	ARKO 23L
; Bresenham Line Drawing Algorithm
;
;	ImageInfo* draw_line_x(ImageInfo* pImg, Coords start, Coords end, unsigned int color);
;	ImageInfo* draw_line_y(ImageInfo* pImg, Coords start, Coords end, unsigned int color);
;=====================================================================

; ImageInfo structure layout
img_width		EQU 0
img_height		EQU 4
img_linebytes	EQU 8
img_bitsperpel	EQU 12
img_pImg		EQU	16

section	.text
global  draw_line_x
global	draw_line_y

;============================================
; STACK
;============================================
;
; greater addresses
;
;  |                                   |
;  | ...                               |
;  -------------------------------------
;  | function argument - color         | EBP+28
;  -------------------------------------
;  | function argument - end.pos_y     | EBP+24
;  -------------------------------------
;  | function argument - end.pos_x     | EBP+20
;  -------------------------------------
;  | function argument - start.pos_y   | EBP+16
;  -------------------------------------
;  | function argument - start.pos_x   | EBP+12
;  -------------------------------------
;  | function argument - ImgInfo* pImg | EBP+8
;  -------------------------------------
;  | return address                    | EBP+4
;  -------------------------------------
;  | saved ebp value                   | EBP, ESP (at the start)
;  -------------------------------------
;  | y update value                    | EBP-4
;  -------------------------------------
;  | ... local variables               | EBP-x
;  |                                   |
;
; \/                               \/
; \/ stack is growing in this      \/
; \/                direction      \/
;
; lower addresses
;
;============================================

;          ___---
; __------/
;/

; drawing "low" line
draw_line_x:
	push ebp
	mov	ebp, esp
	sub esp, 4				; reserving space for y update value ( +/- img_linebytes)
	push ebx				; saving registers
	push esi
	push edi

	; y update value
	mov	ecx, [ebp+8]		; ECX - address of image info struct
	mov ebx, [ecx+img_linebytes]
	mov [ebp-4], ebx

	; finding first pixels
	mov eax, [ebp+16]			; EAX - (y*img_linebytes)
	mul ebx						; (EAX = EAX * EBX)
	mov edx, [ebp+12]			; x/8
	shr edx, 3
	add eax, edx				; EAX - pixel's byte offset
	add eax, [ecx + img_pImg]	; EAX - current byte address

	; mask and color
	mov cl, [ebp+12]
	and cl, 0x7				; CL - pixel's offset within the byte
	mov ch, 0x7F			; CH - pixel's mask
	ror ch, cl
	add cl, 1
	ror BYTE [ebp+28], cl
	mov cl, [ebp+28]		; CL - color

	; initializing algorithm's values
	mov edx, [ebp+20]		; EDX - dx
	sub edx, [ebp+12]
	mov esi, edx			; ESI - loop_counter = dx
	mov edi, [ebp+24]		; EDI - dy
	sub edi, [ebp+16]
	jg direction_set		; sub sets the flags	if (dy < 0) then y will be decrementing
	neg DWORD [ebp-4]		; setting y update value to be negative
	neg edi					; negating dy

direction_set:
	shl edi, 1				; EDI - 2dy
	mov ebx, edi			; EBX - D(decision factor) = 2dy - dx
	sub ebx, edx
	shl edx, 1				; EDX - 2dx

;	EDX = 2dx	EBX = D (decision factor)	EDI = 2dy	ESI = loop_counter	EAX = current byte address
;	[EBP-4] = y update value	CL = color	CH = pixel's mask

draw_loop:
	; setting pixel's color
	and [eax], ch
	or [eax], cl

	dec esi
	js draw_line_exit

	; rotating pixel's mask and color
	ror cl, 1
	ror ch, 1

	; checking if mask starts from the begining [01111111]
	cmp ch, 0x7F
	jne draw_loop_continue

	; changing working byte
	add eax, 1

draw_loop_continue:
	test ebx, ebx
	js go_right

go_up_down:
	; D-=2dx
	; byte's address =+ (y update value)
	sub ebx, edx
	add eax, [ebp-4]

go_right:
	; D+/-=2dy
	add ebx, edi
	jmp draw_loop

draw_line_exit:
	; restoring registers
	pop edi
	pop esi
	pop ebx
	mov esp, ebp		; deallocating local variable
	pop	ebp
	ret

; ---------------------------------------------
;
; ---------------------------------------------

;  /
; |
;/

; drawing "hight" line
draw_line_y:
	push ebp
	mov	ebp, esp
	sub esp, 4				; reserving space for y update value ( +/- img_linebytes)
	push ebx				; saving registers
	push esi
	push edi

	; y update value
	mov	ecx, [ebp+8]		; ECX - address of image info struct
	mov ebx, [ecx+img_linebytes]
	mov [ebp-4], ebx

	; finding first pixels
	mov eax, [ebp+16]			; EAX - (y*img_linebytes)
	mul ebx						; (EAX = EAX * EBX)
	mov edx, [ebp+12]			; x/8
	shr edx, 3
	add eax, edx				; EAX - pixel's byte offset
	add eax, [ecx + img_pImg]	; EAX - current byte address

	mov cl, [ebp+12]
	and cl, 0x7			; CL - pixel's offset within the byte
	mov ch, 0x7F		; CH - pixel's mask
	ror ch, cl
	add cl, 1
	ror BYTE [ebp+28], cl
	mov cl, [ebp+28]	; CL - color

	; initializing algorithm's values
	mov edi, [ebp+20]		; EDI - dx
	sub edi, [ebp+12]
	mov edx, [ebp+24]		; EDX - dy
	sub edx, [ebp+16]
	mov esi, edx			; ESI - loop_counter = dy
	jg y_direction_set		; sub sets the flags	if (dy < 0) then y will be decrementing
	neg DWORD [ebp-4]		; setting y update value to be negative
	neg edx					; negating dy
	neg esi					; negating loop_counter

y_direction_set:
	shl edi, 1				; EDI - 2dx
	mov ebx, edi			; EBX - D(decision factor) = 2dx - dy
	sub ebx, edx
	shl edx, 1				; EDX - 2dy

;	EDX = 2dy	EBX = D (decision factor)	EDI = 2dx	ESI = loop_counter	EAX = current byte address
;	[EBP-4] = y update value	CL = color	CH = pixel's mask

y_draw_loop:
	; setting pixel's color
	and [eax], ch
	or [eax], cl

	dec esi
	js y_draw_line_exit

	; adding/subtracting one line = position y +/-= 1
	add eax, [ebp-4]

	test ebx, ebx
	js y_go_up_down

y_go_right:
	; rotating pixel's mask and color
	ror cl, 1
	ror ch, 1

	; D-=2dy
	sub ebx, edx

	; checking if mask starts from the begining [01111111]
	cmp ch, 0x7F
	jne y_go_up_down

	; changing working byte
	add eax, 1

y_go_up_down:
	; D+=2dx
	add ebx, edi
	jmp y_draw_loop

y_draw_line_exit:
	;restoring registers
	pop edi
	pop esi
	pop ebx
	mov esp, ebp		; deallocating local variable
	pop	ebp
	ret