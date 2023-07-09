.data
prompt: .asciiz  "Please input an Interger(0-999 999 999): "
zero: .asciiz"zero"
one: .asciiz "One "
two: .asciiz "Two "
three: .asciiz "Three "
four: .asciiz "Four "
five: .asciiz "Five "
six: .asciiz "Six "
seven: .asciiz "Seven "
eight: .asciiz "Eight "
nine: .asciiz "Nine "
ten: .asciiz "Ten "

eleven: .asciiz "Eleven "
twelve: .asciiz "Twelve "
thirteen: .asciiz "Thirteen "
fourteen: .asciiz "Fourteen "
fifteen: .asciiz "Fifteen "
sixteen: .asciiz "Sixteen "
seventeen: .asciiz "Seventeen "
eighteen: .asciiz "Eighteen "
nineteen: .asciiz "Nineteen "
twenty: .asciiz "Twenty-"
thirty: .asciiz "Thirty-"
forty: .asciiz "Forty-"
fifty: .asciiz "Fifty-"
sixty: .asciiz "Sixty-"
seventy: .asciiz "Seventy-"
eighty: .asciiz "Eighty-"
ninety: .asciiz "Ninety-"

hundred: .asciiz "Hundred "
thousand: .asciiz "Thounsand "
million: .asciiz "Million "
error1: .asciiz "The number is smaller than 0, please input again. "
error2: .asciiz "The number is greater than 999999999, please input again. "
input_buffer: .space 100
.text
#------------------------------------------------------------------------------------------
#Procedure main1
#@brief Get an Interger from User Input, the interger is checked to be from 0 to 999999999
#@param[out] a1 The Interger that User inputted
#------------------------------------------------------------------------------------------
main1:
	li $v0, 4		# Prompt User to input a Number
	la $a0, prompt
	syscall

	li $v0, 5		# Get a Number from the keyboard
	syscall
	add $a1,$v0,$0 		# Store the Number from User in a1
loop:
 	bltz $v0, negative      # If the inputted Number is smaller than 0, go to negative
 	bgt $v0, 999999999, outofrange
 	j kb                    # If the inputted Number is greater or equal to 0, go to kb
negative:
 	li $v0, 4                 
 	la $a0, error1  	#Print out the message
 	syscall
 	j main1    		# Roll back to main1 to input the number again
outofrange:
	li $v0, 4
	la $a0, error2
	syscall
	j main1

#------------------------------------------------------------------------------------------
#Procedure kb
#@bfief Assigning the value 10, 100, 1000, 1000000 to s0, s1, s3, s4
#------------------------------------------------------------------------------------------                   
kb:
	addi $s0,$s0, 10
	addi $s1,$s1, 100
	addi $s3,$s3, 1000
	addi $s4,$s4, 1000000

	beq $a1,0,zero1 # Handle the special case number 0
	nop
	bne $a1,0,main # If the number is not 0 then go to main
	nop
#------------------------------------------------------------------------------------------
#Procedure zero1
#@brief Print out "zero" if the inputted interger is 0
#------------------------------------------------------------------------------------------
zero1:
	li $v0, 4
	la $a0,zero
	syscall
	j done


main:
#------------------------------------------------------------------------------------------
#@brief We seperate our interger into 3 three-digit parts: million, thousand, and hundred
#------------------------------------------------------------------------------------------
	div $a1, $s4 			#divide a1 by 1000000
	mflo $a3                        	#store quotient to a3
	beq $a3,0,thousands		#if a3=0 branch to thousands
	addi $t8,$t8,1			#if a3 is not 0 then t8 = 1
	j print3				

print_mils:
	addi $t8,$t8,-1			#If print million then t8 = 0
	la $a0, million
	syscall

thousands:
	div $a1, $s4                      #divide a1 by 1000000		
	mfhi $a3                          #store remainder in a3
	div $a3,$s3                       #divide a3 by 1000
	mflo $a3                          #store quotient in a3
	beq $a3,0,units			 #if a3 = 0 brach to units
	addi $t9,$t9,1			 #if a3 is not 0 then t9 = 1
	j print3
print_thous:
	addi $t9,$t9,-1			 #If print thousand then t9 = 0
	la $a0, thousand
	syscall

units:
	div $a1, $s3    			 #divide a1 by 1000
	mfhi $a3        			 #store remainder in a3
	j print3



#------------------------------------------------------------------------------------------
#Procedure print3
#@brief After we got 3 three-digit parts, now we turn them into text
#@param[in] a3 The three-digit part we got above
#------------------------------------------------------------------------------------------
print3:
	div $a3 ,$s1   			#divide a3 by 100											
	mflo $v1       			#store quotient in v1				
	jal print_digit			#branch to print_digit
	nop
	beq $v1,0,last_2units		#if v1 = 0 branch to last_2units	
	la $a0,hundred			#if v1 is not 0 then print "hundred"	
	syscall

last_2units:
	div $a3 ,$s1			#divide a3 by 100
	mfhi $v1				#store remainder in v1
	beq $v1, 0, exit 		#if v1 = 0 branch to exit
	bgt $v1,19,print_ty		#if v1>19 branch to print_ty
	bgt $v1,9, print_teen		#if v1>9 branch to print_teen
last_unit:	
	div $v1, $s0			#divide v1 by 10
	mfhi $v1                         #store remainder in v1
	jal print_digit			#branch to print_digit	
	nop
	j exit				#branch to exit	
#------------------------------------------------------------------------------------------
#@brief We turn 1, 2, 3, 4, 5, 6, 7, 8, 9 into text
#------------------------------------------------------------------------------------------
print_digit:				
	li $v0,4
p1:	bne $v1,1,p2	
	la $a0,one
	syscall
	j return
p2:	bne $v1,2,p3
	la $a0,two
	syscall
	j return
p3:	bne $v1,3,p4
	la $a0,three
	syscall
	j return
p4:	bne $v1,4,p5
	la $a0,four
	syscall
	j return
p5:	bne $v1,5,p6
	la $a0,five
	syscall
	j return
p6:	bne $v1,6,p7
	la $a0,six
	syscall
	j return
p7:	bne $v1,7,p8
	la $a0,seven
	syscall
	j return
p8: 	bne $v1,8,p9
	la $a0,eight
	syscall
	j return
p9:	bne $v1,9,return
	la $a0,nine
	syscall
	j return

#------------------------------------------------------------------------------------------
#@brief We turn 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 to text
#------------------------------------------------------------------------------------------
print_teen:				
	li $v0,4
p10:	bne $v1,10,p11	
	la $a0,ten
	syscall
	j exit
p11:	bne $v1,11,p12	
	la $a0,eleven
	syscall
	j exit
p12:	bne $v1,12,p13
	la $a0,twelve
	syscall
	j exit
p13:	bne $v1,13,p14
	la $a0,thirteen
	syscall
	j exit
p14:	bne $v1,14,p15
	la $a0,fourteen
	syscall
	j exit
p15:	bne $v1,15,p16
	la $a0,fifteen
	syscall
	j exit
p16:	bne $v1,16,p17
	la $a0,sixteen
	syscall
	j exit
p17:	bne $v1,17,p18
	la $a0,seventeen
	syscall
	j exit
p18: 	bne $v1,18,p19
	la $a0,eighteen
	syscall
	j exit
p19:	bne $v1,19,p20
	la $a0,nineteen
	syscall
	j exit

#------------------------------------------------------------------------------------------
#@brief We turn 20, 30, 40, 50, 60, 70, 80, 90 into text
#------------------------------------------------------------------------------------------
print_ty: 				
	li $v0,4
p20:	bgt $v1,29,p30
	la $a0,twenty
	syscall
	j last_unit
p30:	bgt $v1,39,p40
	la $a0,thirty
	syscall
	j last_unit
p40:	bgt $v1,49,p50
	la $a0,forty
	syscall
	j last_unit
p50:	bgt $v1,59,p60
	la $a0,fifty
	syscall
	j last_unit
p60:	bgt $v1,69,p70
	la $a0,sixty
	syscall
	j last_unit
p70:	bgt $v1,79,p80
	la $a0,seventy
	syscall
	j last_unit
p80:	bgt $v1,89,p90
	la $a0,eighty
	syscall
	j last_unit
p90:	
	la $a0,ninety
	syscall
	j last_unit

return:
	jr $ra
#------------------------------------------------------------------------------------------
#@brief We check if we need to print "million" and "thousand" from t8 and t9
#------------------------------------------------------------------------------------------	
exit:	
	beq $t8,1,print_mils 		# If t8 = 1, branch to print_mils
	beq $t9,1,print_thous		# If t9 = 1, branch to print_thous
done:
