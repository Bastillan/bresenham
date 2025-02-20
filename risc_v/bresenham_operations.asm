# Jedrzej Kedzierski

.include "img_info.asm"
.globl draw_line

	.text

# ============================================================================
# draw_line - draws line from the given start coordinates to given end coordinates in the input image
#arguments:
#	a0 - address of ImgInfo image descriptor
#	a1 - address of Coords starting position
#	a2 - address of Coords ending position
#	a3 - color (black/white)
#return value:
#	none


draw_line:
	lw a4, pos_y(a1)		# a4 - start pos_y
	lw a1, pos_x(a1)		# a1 - start pos_x
	
	lw a5, pos_y(a2)		# a5 - end pos_y
	lw a2, pos_x(a2)		# a2 - end pos_x
	
	lw t3, ImgInfo_lbytes(a0)	# t3 - line in bytes
	lw t4, ImgInfo_imdat(a0)	# t4 - pixel data addr
	
# initializing algorithm's values
	sub t0, a2, a1			# t0 - dx
	mv a2, t0			# a2 - loop counter (draw while > 0)
	
	sub t1, a5, a4			# t1 - dy
	slli t1, t1, 1			# t1 - 2*dy
	
	sub t2, t1, t0			# t2 - D (decision factor) = 2*dy -dx
	slli t0, t0, 1			# t0 - 2*dx
	
# finding starting pixel
	mul a4, t3, a4			# a4 - line in bytes * start y
	srai a5, a1, 3			# a4 - (pixel offset in line) = x/8
	add a4, a4, a5			# a4 - pixel's byte offset
	andi a5, a1, 0x7		# a5 - pixel offset within the byte = x%8
	
# t0 - 2dx;		t1 - 2dy;		t2 - D (decision factor);	t3 - line in bytes;			t4 - pixel data addr;
# a1 - start x;		a2 - loop counter;	a4 - pixel's byte offset;	a5 - pixel offset within the byte
	
draw_loop:
# setting pixel
	add t5, a4, t4			# t5 - address of the pixel's byte = pixel's byte offset + pixel data addr
	
	lbu a1, (t5)			# load byte
	sll a1, a1, a5			# pixel bit is on the msb of the lowest byte
	
# setting color
	andi a3, a3, 1			# mask the color
	li a6, 0x80			# pixel mask
	beqz a3, set_pixel_black
	
set_pixel_white:
	or a1, a1, a6
	srl a1, a1, a5
	sb a1, (t5)			# store byte
	b draw_loop_continue

set_pixel_black:
	not a6, a6
	and a1, a1, a6
	srl, a1, a1, a5
	sb a1, (t5)			# store byte
	
draw_loop_continue:
	beqz a2, draw_line_exit
	
# updates
	addi a2, a2, -1			# loop counter - 1
	addi a5, a5, 1			# pixel offset within the byte
	andi a5, a5, 0x7		# pixel offset within the byte % 8
	
	bnez a5, the_same_byte
	addi a4, a4, 1			# pixel's byte offset updated to the next byte
	
the_same_byte:
	blez t2, go_right

go_up:
	add a4, a4, t3			# pixel's byte offset + line in bytes
	sub t2, t2, t0			# D-=2dx

go_right:
	add t2, t2, t1			# D+=2dy
	b draw_loop
	
draw_line_exit:
	jr ra
