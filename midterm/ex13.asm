.data
message_input: .asciiz "Enter ticket number: "

invalid_big: 	  .asciiz	"Number is too big!" 
invalid_negative: .asciiz	"Number is negative!"
invalid_odd: 	  .asciiz	"Number of digits is odd!" 

lucky: .asciiz	"Lucky number"
not_lucky: .asciiz "Not lucky number"

.text 
main: 	li $v0, 4		# in thong bao nhan dau vao
	la $a0, message_input
	syscall
	
	li $v0, 5 		# Doc so n nhap tu ban phim
	syscall
	add $s0, $v0, $0 	# Luu gia tri n vao s0

	jal check_input 	# check_input -> kiem tra dau vao n
	nop

	jal is_lucky 		# is_lucky -> kiem tra xem n lucky hay khong va in ket qua
	nop
	
end_main: 	li $v0, 10	# ket thuc chuong trinh
		syscall
#------------------------------------------------------------------------------
# function error($a1)
# In thong bao loi
# $a1: luu dia chi cua string chua noi dung loi
#------------------------------------------------------------------------------
error:	li $v0, 4
	add $a0, $a1, $0
	syscall
	j end_main
	
#------------------------------------------------------------------------------
# function result($a1)
# In thong bao ket qua, la ham con trong is_lucky
# $a1: luu dia chi cua string chua noi dung ket qua
#------------------------------------------------------------------------------	
result:	li $v0, 4
	add $a0, $a1, $0
	syscall

	j end_is_lucky
#------------------------------------------------------------------------------
# function check_input($s0)
# Kiem tra so nhap vao n co thoa man dieu kien hay khong
# Cac loi kiem tra: so qua lon, so am, so chu so la so le
# Dong thoi push cac chu so vao stack voi con tro $sp
# $s0: chua gia tri n
# Tra ve: $k0 -> so chu so cua n
#	  $k1 -> mot nua so chu so cua n n (1/2 của $k0) 
#------------------------------------------------------------------------------
check_input: 	add  $s1, $s0, $0 	# $s1 = $s0 = n
		li   $t2, 1000000000	# 1.000.000.000 -> gioi han cua n
		
# check_big -> kiem tra n ($s1) < 1.000.000.000 hay khong
check_big:	slt  $t1, $s1, $t2 	# Neu n($s1) < 1.000.000.000 ? t1 = 1 nguoc lai t1 = 0

		la   $a1, invalid_big	# gan dia chi string chua loi vao $a1 de su dung ham error
		beqz $t1, error		# in loi neu t1 = 0 ( hay n > 1.000.000.000 )
		
# check_negative -> kiem tra n la so am hay khong		
check_negative:	slt  $t1, $0, $s1 		# kiem tra 0 < n($s1) ? t1 = 1 : t1 = 0

		la   $a1, invalid_negative	# gan dia chi string chua loi vao $a1 de su dung ham error 
		beqz $t1, error			# in loi neu t1 = 0 ( hay n < 0 )
		
# check_odd -> kiem tra so chu so cua n chan hay le				
check_odd:	addi $t1, $0, 10  	# $t1 = 10 -> dung lam so chia đe tach cac chu so

# loop -> chia n dan cho 10 va gan lai n bang thuong va so du push dan vao stack
# Vong lap dung khi n = 0 -> het chu so
# $k0 dem so chu so	
loop:		beq $s1, 0, countinue_check 	# if ($s1) == 0 -> dung loop
		nop		      		

		divu $s1, $t1 		# chia n cho 10 lay thuong va so du o lo, hi
		mfhi $t2		# so du o hi duoc luu vao $t2 = n % 10
		mflo $t3		# thuong o lo duoc luu vao $t3 = n / 10
		add  $s1, $t3, $0	# n($s1) = n / 10 = $t3  
		
# push: push chu so hay so du vua tim duoc vao stack
push:		addi $sp, $sp, -4 	# danh stack cho mot phan tu
		sw   $t2, 0($sp)	# luu so du hay cac chu cai cua n vao stack
		add  $k0, $k0, 1   	# tang bien dem $k0 ++
		j loop
		
# countinue_check -> sau khi dung vong lap, tiep tuc kiem tra so chu so le hay không (kiem tra $k0 chia het cho 2)
countinue_check:addi $t4, $0, 2		# gan t4 = 2 -> lam so chia

		div  $k0, $t4		# chia $k0 cho 2 -> thuong va du luu o lo, hi
		mfhi $t4		# lay so du tu hi luu vao $t4
		mflo $k1		# thuong la 1/2 so chu so cua n luu vao $k1
		
		la   $a1, invalid_odd   # gan dia chi string chua loi vao $a1 de su dung ham error
		bne  $t4, 0, error	# neu khong chia het hay so du ($t4) khac 0 -> bao loi bang ham error
		nop
		
		jr $ra			# thoat ham check_input tro ve ham main
		
#------------------------------------------------------------------------------
# function is_lucky($sp, $k1)
# Kiem tra tong nua dau va nua sau cua cac chu so cua n (lucky) va in ket qua qua ham result
# Duyet nua stack dau và tinh tong, tuong tu voi nua sau
# So sanh 2 tong va dua ra ket luan
# $sp -> stack chu cac chu so cua n
# $k1 -> 1/2 so chu so cua n hay 1/2 so phan tu cua stack
#------------------------------------------------------------------------------
is_lucky: addi $t1, $0, 0	# i = 0 -> bien chay vong lap nua dau
	  addi $t2, $0, 0	# j = 0 -> bien chay vong lap nua sau
	  add $s2, $0, $0	# $s2 luu sum cua nua dau
	  add $s3, $0, $0	# $s3 luu sum cua nua sau

# loop1: tinh tong nua dau cua stack 
loop1:	beq	$t1, $k1, loop2		# neu i($t1) == $k0 -> dung vong lap -> di den tinh tong nua sau
	nop
# pop1: lay phan tu trong stack ra de cong dan vao $s2 de tinh tong
pop1:	lw 	$t3, 0($sp) 	# pop chu ra khoi stack vao $t3
	addi 	$sp, $sp, 4 	# xoa 1 muc ra khoi stack
	
	add 	$s2, $s2, $t3	# tinh tong ($s2) += $t3 (chu so vua pop ra)
	addi 	$t1, $t1, 1	# tang bien dem de lap i++
	j 	loop1
	
# loop2: tinh tong nua sau cua stack 
loop2:	beq	$t2, $k1, check_lucky	# neu i($t1) == $k0 -> dung vong lap -> di den so sanh 2 tong o check_lucky
	nop
# pop1: lay phan tu trong stack ra de cong dan vao $s3 de tinh tong
pop2:	lw 	$t3, 0($sp) 	# pop và luu vao $t3
	addi 	$sp, $sp, 4 	# xoa 1 muc ra khoi stack
	
	add 	$s3, $s3, $t3	# tinh tong ($s3) += $t3
	addi 	$t2, $t2, 1	# tang bien dem de lap j++
	j 	loop2
# check_lucky -> kiem tra tong 2 nua co bang nhau hay khong
check_lucky: 	la $a1, not_lucky	# luu dia chi thong bao vao $a1 đe su dung ham result
		bne $s2, $s3, result	# neu 2 nua khong bang nhau in thong bao not_lucky
		nop			# nguoc lai -> lucky
		la $a1, lucky		# luu dia chi thong bao vao $a1 de su dung ham result
		j  result		
end_is_lucky:	jr $ra			# ket thuc ham is_lucky tro ve ham main
