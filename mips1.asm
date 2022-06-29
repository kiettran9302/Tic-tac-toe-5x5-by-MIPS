#PrintArray
#Move+check
#Main
#create array full 0
#addr 	= baseAdd + (rowIndex*colsize+colindex)*data size 
#	= baseAdd + ((rowIndex+1)*colsize* datasize ) + colindex *datasize
#						= j*4  
	.data

#matrix store elements from 0 to 24	
matrix: .word 0:25
size:	.word 5 
.eqv DATASIZE 4

wel1:	.asciiz "TIC TAC TOE 5x5 \n"
req1: 	.asciiz "During the first turn of both players, they are not allowed to choose the central point. \n" 
req2:	.asciiz "Any player who has 3 points in row, column, diagonal will be winner. \n"
req3: 	.asciiz "Players can undo 1 move before the opponent plays. \n"

line:	.asciiz "------------------------------- \n"
p1:	.asciiz "Player 1 turn \n"
p2:	.asciiz "Player 2 turn \n"
tyrow:	.asciiz "Type your row: "
tycol:	.asciiz "Type your col: "

spacing: .asciiz " | "
nline:	.asciiz " |\n"

err1:	.asciiz "Invalid move! Please try again. \n"
undotxt: 	.asciiz "Do you want undo your move? "
p1win:	.asciiz "Player 1 win \n"
p2win: 	.asciiz "Player 2 win \n"
draw:	.asciiz "It's tie \n"
	.text
main:
	#define variable.
	# arr = $s0
	# i = $s1 
	# check = $t9
	# row = $t3
	# col = $t4 
	# Result = $s5
	# undo1 = $s6
	# undo2 = $s7
	# t1 print
	# t2 = 2 
	
	#print request 
	li	$v0,4
	la 	$a0, line
	syscall
	
	li	$v0, 4
	la 	$a0, wel1
	syscall
	
	li	$v0, 4
	la	$a0, req1
	syscall
	
	li	$v0, 4
	la 	$a0, req2
	syscall
	
	li	$v0, 4
	la	$a0, req3
	syscall
	
	#start
	la $s0, matrix
	lw $s4, size 
	addi $s1, $zero, 1
	addi $s5, $zero, 0
	addi $s6, $zero, 1
	addi $s7, $zero, 1
	addi $t2, $zero, 2
	addi $s2, $zero, 1
	addi $t9, $zero, 1
	addi $t7, $zero, 0
	addi $t8, $zero, 0
biggerloop:
	beq $s1, 26, finish
	rem $t9, $s1, 2
	beq $t9, 1, p1turn
	j p2turn
	
perror1: 
	li	$v0, 4
	la 	$a0, err1
	syscall
	j p1turn
perror2:
	li	$v0,4
	la 	$a0, err1
	syscall
	j p2turn
p1turn:
	addi 	$s2, $zero, 1
	li	$v0,4
	la 	$a0, line
	syscall
	
	li	$v0, 4
	la 	$a0, p1
	syscall
	
	#add row
	li 	$v0, 4
	la 	$a0, tyrow
	syscall
	
	li 	$v0, 5
	syscall 
	add 	$a0, $zero, $v0
	add 	$t4, $zero, $a0	
	
	#add col
	li 	$v0, 4
	la 	$a0, tycol
	syscall
	
	li 	$v0, 5
	syscall 
	add 	$a0, $zero, $v0
	add 	$t5, $zero, $a0	
	
	#check codintion
	beq $s1, 1,checkerr
	j moving
next1:
	bnez $s6, undo1
	j next3
	
	p2turn:
	addi $s2, $zero, 2
	li	$v0,4
	la 	$a0, line
	syscall
	
	li	$v0, 4
	la 	$a0, p2
	syscall
	
	#add row
	li 	$v0, 4
	la 	$a0, tyrow
	syscall
	
	li 	$v0, 5
	syscall 
	add 	$a0, $0, $v0
	add 	$t4, $zero, $a0	
	
	#add col
	li 	$v0, 4
	la 	$a0, tycol
	syscall
	
	li 	$v0, 5
	syscall 
	add 	$a0, $0, $v0
	add 	$t5, $zero, $a0	
	
	#check codintion
	beq 	$s1,2,checkerr
	j moving

next2:
	bnez $s7, undo2
next3:
	addi 	$s1, $s1, 1
	j biggerloop



	#print matrix 
prt:	
	li $t1, 0
	la $s0, matrix
	li	$v0,4
	la 	$a0, line
	syscall
prt_loop:
	
	bgt 	$t1, 24, checkwin
	
	li 	$v0, 4
	la 	$a0, spacing
	syscall
	
	lw 	$a0, 0($s0)
	li 	$v0,1
	syscall
	
	
	addi 	$t1, $t1, 1
	addi 	$s0, $s0, 4
	rem 	$s3, $t1, 5
	beq 	$s3, $zero, newline 
	j 	prt_loop

newline:
	li	$v0, 4
	la	$a0, nline
	syscall
	j prt_loop
	

checknext:
	beq $s2, $t2,next2
	j next1

checkerr:	
		bne $t4, 2, moving
		bne $t5, 2, moving
		beq $s2, 1, perror1
		j perror2


	#find pos of index
moving:	
	bgt $t4, 4, moverr
	bgt $t5, 4, moverr
	mul $t6, $t4 ,$s4 #t6 = row index * column size
	add $t6, $t6, $t5# 		    + column index
	mul $t6, $t6, DATASIZE # 	     * data size
	lw $a2, matrix($t6)
	bnez $a2,moverr
	sw $s2,matrix($t6)
	j prt

moverr:
	beq $s2, 1, perror1
	j perror2
undo1:
	li $v0,4
	la $a0, undotxt
	syscall 
	
	li $v0, 5
	syscall
	add $t1, $zero, $v0
	
	beqz $t1, next3
	
	mul $t6, $t4 ,$s4 #t6 = row index * column size
	add $t6, $t6, $t5# 		    + column index
	mul $t6, $t6, DATASIZE # 	     * data size
	sw $zero,matrix($t6)
	addi $s6,$s6,-1
	j p1turn
	
undo2:
	li $v0,4
	la $a0, undotxt
	syscall 
	
	li $v0, 5
	syscall
	add $t1, $zero, $v0
	
	beqz $t1, next3
	
	mul $t6, $t4 ,$s4 #t6 = row index * column size
	add $t6, $t6, $t5# 		    + column index
	mul $t6, $t6, DATASIZE # 	     * data size
	sw $zero,matrix($t6)
	addi $s7, $s7,-1
	j p2turn
	
checkwin: 
#check hoizontal  
	# x = t7, y = t8
 #case1: check i-j, i-j+1, i-j+2
 	#for (x = 0, x < 3, x ++)
 	li $t7,0
 h1l1:	
 	beq $t7, 5, verticalcheck
 	li $t8, 0
 	h1l2:
 	beq $t8, 5, eh1l1
 	
 	#load arr[i][j]
 	mul $t6, $t7 ,$s4 #t6 = row index * column size
	add $t6, $t6, $t8# 		    + column index
	mul $t6, $t6, DATASIZE # 	     * data size
	lw  $a2,matrix($t6)
	
	#load arr[i][j + 1]
	addi $t6, $t6, 4
	lw  $a3,matrix($t6)
	
	#load arr[i][j + 2]
	addi $t6, $t6, 4
	lw  $a1,matrix($t6)
	
	#a2 co bang a 3 ko
	bne $a2, $a3, eh1l2
	bne $a2, $a1, eh1l2
	bne $a2, $s2, eh1l2
	beq $s2, 1, p1winner 
	j p2winner 	
 eh1l2:	
 	addi $t8, $t8,1 
 	b h1l2
 eh1l1:
 	li $t9, 1
 	addi $t7, $t7, 1
 	b h1l1
 
 	#check vertical
 verticalcheck:
 	li $t7,0
 v1l1:	
 	beq $t7, 5, diagcheckright
 	li $t8, 0
 	v1l2:
 	beq $t8, 5, ev1l1
 	
 	#load arr[i][j]
 	mul $t6, $t7 ,$s4 #t6 = row index * column size
	add $t6, $t6, $t8# 		    + column index
	mul $t6, $t6, DATASIZE # 	     * data size
	lw  $a2,matrix($t6)
	
	#load arr[i+1][j]
	addi $t6, $t6,20
	lw  $a3,matrix($t6)
	
	#load arr[i+2][j]
	addi $t6, $t6, 20
	lw  $a1,matrix($t6)
	
	#a2 co bang a 3 ko
	bne $a2, $a3, ev1l2
	bne $a2, $a1, ev1l2
	bne $a2, $s2, ev1l2
	beq $s2, 1, p1winner 
	j p2winner 	
 ev1l2:	
 	addi $t8, $t8,1 
 	b v1l2
 ev1l1:
 	addi $t7, $t7, 1
 	b v1l1
 	
 diagcheckright:
 	li $t7,0
 d1l1:	
 	beq $t7, 3, diagcheckleft
 	li $t8, 0
 	d1l2:
 	beq $t8, 3, ed1l1
 	
 	#load arr[i][j]
 	mul $t6, $t7 ,$s4 #t6 = row index * column size
	add $t6, $t6, $t8# 		    + column index
	mul $t6, $t6, DATASIZE # 	     * data size
	lw  $a2,matrix($t6)
	
	#load arr[i+1][j+1]
	addi $t6, $t7, 1
	mul $t6, $t6 ,$s4 #t6 = row index * column size
	add $t6, $t6, $t8# 		    + column index
	addi $t6, $t6, 1
	mul $t6, $t6, DATASIZE # 	     * data size
	lw  $a3,matrix($t6)
	
	addi $t6, $t7, 2
	mul $t6, $t6 ,$s4 #t6 = row index * column size
	add $t6, $t6, $t8# 
	addi $t6, $t6, 2 #		    + column index
	mul $t6, $t6, DATASIZE # 	     * data size
	lw  $a1,matrix($t6)
	
	#a2 co bang a 3 ko
	bne $a2, $a3, ed1l2
	bne $a2, $a1, ed1l2
	bne $a2, $s2, ed1l2
	beq $s2, 1, p1winner 
	j p2winner 	
 ed1l2:	
 	addi $t8, $t8,1 
 	b d1l2
 ed1l1:
 	addi $t7, $t7, 1
 	b d1l1
 
 diagcheckleft:
  	li $t7,0
 d2l1:	
 	beq $t7, 3, checknext
 	li $t8, 0
 	d2l2:
 	beq $t8, 3, ed2l1
 	
 	#load arr[i][j]
 	mul $t6, $t7 ,$s4 #t6 = row index * column size
	add $t6, $t6, $t8# 		    + column index
	mul $t6, $t6, DATASIZE # 	     * data size
	lw  $a2,matrix($t6)
	
	#load arr[i-1][j-1]
	addi $t6, $t7, 1
	mul $t6, $t6 ,$s4 #t6 = row index * column size
	add $t6, $t6, $t8# 		    + column index
	addi $t6, $t6, 1
	mul $t6, $t6, DATASIZE # 	     * data size
	lw  $a3,matrix($t6)
	
	addi $t6, $t7, 2
	mul $t6, $t6 ,$s4 #t6 = row index * column size
	add $t6, $t6, $t8# 
	addi $t6, $t6, 2#		    + column index
	mul $t6, $t6, DATASIZE # 	     * data size
	lw  $a1,matrix($t6)
	
	#a2 co bang a 3 ko
	bne $a2, $a3, ed2l2
	bne $a2, $a1, ed2l2
	bne $a2, $s2, ed2l2
	beq $s2, 1, p1winner 
	j p2winner 	
 ed2l2:	
 	addi $t8, $t8,1 
 	b d2l2
 ed2l1:
 	addi $t7, $t7, 1
 	b d2l1
 
 	
	
p1winner:
	li $a0, 4
	la $a0, line
	syscall 
	
	li $a0,4
	la $a0,p1win
	syscall
	j exit

p2winner:
	li $a0, 4
	la $a0, line
	syscall 
	
	li $a0,4
	la $a0,p2win
	syscall
	j exit
	

finish:
	li $a0, 4
	la $a0, line
	syscall 
	
	li $a0,4
	la $a0,draw
	syscall
	j exit
	
exit:
