	.data
promptMsg:	.asciiz "\nPlease Enter:\n1) Convert from binary\n2) Convert from hexadecimal\n3) Convert from decimal\n4)Exit\n"
empty: 		.space 16
newLine: 	.asciiz "\n"
sum: 		.space 16 
msg1:  		.asciiz "Enter a number in base 2: "
msg2: 		.asciiz "\nResult:\n"
create_space: 	.space 9
error: 		.asciiz "Invalid hexadecimal number."
msgHex:		.asciiz "Enter a hexadecimal number: "
promptDec:	.asciiz "Enter a decimal number: "
rejectInput:	.asciiz "bro u gotta put either 1, 2, 3, or 4"
	.text
main:
	menuLoop:
	li $v0, 4
	la $a0, promptMsg
	syscall	
	li $v0, 5
	syscall
	Case1:
		addi $t0, $v0, -1
		bne $t0, $0, Case2
		jal convertFromBin
		j menuLoop
	Case2:
		addi $t0, $v0, -2
		bne $t0, $0, Case3
		jal convertFromHex
		j menuLoop
	Case3:
		addi $t0, $v0, -3
		bne $t0, $0, Case4
		jal convertFromDec
		j menuLoop
	Case4:
		addi $t0, $v0, -4
		bne $t0, $0, Else
		j exit
	Else:
		li $v0, 4
		la $a0, rejectInput
		syscall
		j menuLoop
		
convertFromBin:
	getNum:
	li $v0,4        # Print string system call
	la $a0,msg1         #"Please insert value (A > 0) : "
	syscall
	la $a0, empty
	li $a1, 16              # load 16 as max length to read into $a1
	li $v0,8                # 8 is string system call
	syscall
	la $a0, empty
	li $v0, 4               # print string
	syscall
	li $t4, 0               # initialize sum to 0
	startConvert:
 	la $t1, empty
 	li $t9, 16             # initialize counter to 16
	firstByte:
 	lb $a0, ($t1)      # load the first byte
  	blt $a0, 48, printSum    # adjust
  	addi $t1, $t1, 1          # increment offset
  	subi $a0, $a0, 48         # subtract 48 to convert to int value
 	subi $t9, $t9, 1          # decrement counter
  	beq $a0, 0, isZero
  	beq $a0, 1, isOne
  	j convert     # 
	isZero:
  	j firstByte
 	isOne:                   # do 2^counter 
   	li $t8, 1               # load 1
   	sllv $t5, $t8, $t9    # shift left by counter = 1 * 2^counter, store in $t5
   	add $t4, $t4, $t5         # add sum to previous sum 
  	move $a0, $t4        # load sum
  	j firstByte
	convert:
	printSum:
  	srlv $t4, $t4, $t9
  	la $a0, msg2
  	li $v0, 4
  	syscall
 	move $a0, $t4      # load sum
 	li $v0, 1      # print int
 	syscall
 	li $v0, 4
 	la $a0, newLine
 	syscall
 	li $v0, 34
 	addi $a0, $t4, 0
 	syscall
 	jr $ra
 	
convertFromHex:
	li $v0, 4
	la $a0, msgHex
	syscall
	
	li $v0, 8			#Syscall for v0 = 8 is Read String
	la $t0, create_space		#Create Space in $t0
	la $a0, 0($t0)			#Loads Input into Argument
	la $a1, 9			#Loads Length of Input
	syscall 			#Calls syscall 8 - Read String

	addi $t7, $t0, 8		#Move 9th byte of Input to Register
	addi $s5, $t0, 0		#Move input to Register
	add $s3, $zero, $zero   	#Intialize Register to Zero

	length_of_input:		#Count length of Input
	lb $t1, 0($s5)
	beq $t1, 0, revert
	beq $t1, 10, revert
	addi $s3, $s3, 4
	addi $s5, $s5, 1 
	j length_of_input
	revert:					#To revert back to last position in Input, rather than /n or NULL
	addi $s3, $s3, -4
	test_valid_invalid:			#Testing for Valid Input	
	lb $t1, 0($t0)				#Load Byte from 0 offset to a pointer in address of Input
	beq $t1, 0, handle_signed		#Branch to Handle large (signed to unsigned) numbers
	beq $t1, 10, handle_signed
	blt $t1, 48, invalid_input		#Branch on less than 48 - ASCII for 0 - Invalid Input
	addi $s1, $0, 48			#Store Subtraction in Register
	blt $t1, 58, valid_input		#Branch on less than 58 - ASCII for 9 - Valid Input
	blt $t1, 65, invalid_input		#Branch on less than 65 - ASCII for A - Invalid Input
	addi $s1, $0, 55			#Store Subtraction in Register
	blt $t1, 71, valid_input		#Branch on less than 71 - ASCII for G - Valid Input
	blt $t1, 97, invalid_input		#Branch on less than 97 - ASCII for a - Invalid Input
	addi $s1, $0, 87			#Store Subtraction in Register
	blt $t1, 103, valid_input		#Branch on less than 103 - ASCII for g - Valid Input
	bgt $t1, 102, invalid_input		#Branch on greater than 102 - ASCII for f - Invalid Input
	invalid_input:				#Must throw error on Invalid input
	li $v0, 4				#Syscall for v0 = 4 is Print String
	la $a0, error				#Loads error prompt into Register
	syscall 				#Calls syscall 4 - Print String
	jr $ra					#Return if input is invalid
	valid_input:				#Must compute Decimal value on Valid input
	addi $t0, $t0, 1			#Point to next address of Input
	sub $s4, $t1, $s1			#Subtract from ASCII value to get Decimal Value of character
	sllv $s4, $s4, $s3			#Shifting Left is the same as Multiplying
	addi $s3, $s3, -4
	add $s2, $s4, $s2				
	bne $t0, $t7, test_valid_invalid	#If not end of Input (NULL/n) continue iterating through Loop
	handle_signed:				#To Handle Large (signed to unsigned) numbers
	addi $s0, $0, 10		
	addi $t0, $t0, -1			#Point to Previous Byte in Input
	lb $t1, 0($t0)
	blt $t1, 58, end_program		#Branch on less than 58 - ASCII for 9
	divu $s2, $s0				#Unsigned Division with 10
	mflo $a0				#Printing Quotient
	#move $s6, $0	########
	move $s6, $s2
	li $v0, 1				#Syscall for v0 = 1 is Print Signed Integer
	syscall 				#Calls syscall 1 - Print Signed Integer
	mfhi $s2				#Priting Remainder
	end_program:
	li $v0, 1			
	#addi $a0, $s2, 0			#load args for syscall
	move $a0, $s2
	syscall 			
	la $a0, newLine
	li $v0, 4
	syscall
	#div $0, 
	li $v0, 35
	move $a0, $s6
	syscall
	jr $ra
	
convertFromDec:
	li $v0, 4
	la $a0, promptDec
	syscall
	li $v0, 5
	syscall
	addi $t3, $v0, 0
	li $v0, 4
	la $a0, msg2
	syscall
	li $v0, 34
	addi $a0, $t3, 0
	syscall
	li $v0, 4
	la $a0, newLine
	syscall
	li $v0, 35
	addi $a0, $t3, 0
	syscall
	jr $ra
 	
 exit:
 	li $v0, 10
 	syscall
