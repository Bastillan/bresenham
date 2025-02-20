# Jedrzej Kedzierski

.include "img_info.asm"
.include "examples.asm"

	.data
	
imgInfo: .space	28	# image descriptor

	.align 2		# word boundary alignment
dummy:		.space 2
bmpHeader:	.space	BMPHeader_Size
		.space  1024	# enough for 256 lookup table entries

	.align 2
imgData: 	.space	MAX_IMG_SIZE

#ifname: .asciz "white256x256.bmp" # requires changing color in examples.asm
ifname:	.asciz "black256x256.bmp"
ofname: .asciz "result.bmp"
#ofname: .asciz "result_black_on_white.bmp"

	.align 2
start_coords:	.space 8
end_coords:	.space 8


	.text
main:
# initialize image descriptor
	la a0, imgInfo 
	la t0, ifname	# input file name
	sw t0, ImgInfo_fname(a0)
	la t0, bmpHeader
	sw t0, ImgInfo_hdrdat(a0)
	la t0, imgData
	sw t0, ImgInfo_imdat(a0)
	jal	read_bmp
	bnez a0, main_failure
	
# First Line
	la a0, imgInfo
# setting start_coords
	la a1, start_coords
	li t0, start_x
	sw t0, pos_x(a1)
	li t0, start_y
	sw t0, pos_y(a1)
# setting end_coords
	la a2, end_coords
	li t0, end_x
	sw t0, pos_x(a2)
	li t0, end_y
	sw t0, pos_y(a2)
# setting color and number of iterations
	li a3, color
	li s1, iterations
	
draw:
	jal	draw_line

# Next Lines
	
# setting next start_coords
	la a1, start_coords
	lw t0, pos_x(a1)
	addi t0, t0, s_x_delta
	sw t0, pos_x(a1)
	lw t0, pos_y(a1)
	addi t0, t0, s_y_delta
	sw t0, pos_y(a1)
# setting next end_coords
	la a2, end_coords
	lw t0, pos_x(a2)
	addi t0, t0, e_x_delta
	sw t0, pos_x(a2)
	lw t0, pos_y(a2)
	addi t0, t0, e_y_delta
	sw t0, pos_y(a2)
	
	addi s1, s1, -1
	
	bgtz s1, draw

# saving BMP
	la a0, imgInfo
	la t0, ofname
	sw t0, ImgInfo_fname(a0)
	jal save_bmp

main_failure:
	li a7, 10
	ecall
