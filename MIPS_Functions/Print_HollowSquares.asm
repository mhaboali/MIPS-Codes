.data 
	# space to store user input
	inputStr: .space  2000000
	# User prompt to enter values
	prompt:   .asciiz "Please enter a Sentence -> "
	#size of buffer that will hold the string input
	numChars: .word	2000000
	
	# newline character
	newline:    .asciiz "\n"
	
	
	
.text
	MAIN:
        ##########
	#  Read user input
	##########

	# Prepare to print the prompt
	la $a0, prompt
	# Print prompt, print string system call
	li $v0, 4
	syscall

	GET_INPUT:
		# Read String form user
		li $v0,8
		la $a0,inputStr			#determine the buffer address to get the string
		la $a1,numChars			#determine the buffer size
		syscall
		
		addi $t4,$a0,0			#save the index to first char in input string

		
	STR_PARSER:	#Here we parse the string to get integers and chars that we used to draw patterns
	
		addi $t5,$zero,0		#counter=0 counter to know how many digits of integer number
		addi $s4,$zero,1		#multiplication factor as an indication to value of integer number while conversion
		WHILE:
			lb $s3,0($t4)		#load char by char in seperate iterations of this loop
			addi $t4,$t4,1		#increasing the index to char in string
			addi $t5,$t5,1		#incrasing counter to know how many digits of integer number
			mul $s4, $s4,10		#to know the weight of each digit in number ... 1000 100 10 0
			sgt $t3,$s3,32		#32 is ascii of space,which used as flag to get the integer and char
			bne $t3,$zero,WHILE	
		#start converting char digit to int digit
			#here we get char digits 
			addi $t5,$t5,-1
			sub $s5,$t4,$t5
			addi $s5,$s5,-1
			div $s4,$s4,100
			addi $t2,$t4,4
			addi $t4,$s5,0
		addi $s0,$zero,0
		FOR:
			#here we convert each digit to corresponding int digit with proper weight
			lb $s3,0($t4)		#load each char digit	
			addi $t4,$t4,1				
			addi $s3,$s3,-48	#git the absolute int value of it
			#get its really proper value
			mul $s3,$s3,$s4
			add $s0,$s0,$s3
			addi $t5,$t5,-1
			div $s4,$s4,10
			bne $t5,$zero,FOR
			addi $t4,$t2,3

		beq $s0,$zero,EXIT		#check if n==0
		#ELSE
		lb $s1,0($t2)
		addi $t0,$t0,8
		
		#Print the integer value
		li $v0,1
		addi $a0,$s0,0
		syscall
		addi $s0,$s0,-1
		
		#Display output pattern
		#initialize counters to print charaters
		sub $s6,$zero,1

		ROW_LOOP:
			li $v0,4
			la $a0,newline
			syscall
			sub $s7,$zero,1
			#check boundries
			slt $t6,$s6,$s0
			beq $t6,$zero,STR_PARSER
			addi $s6,$s6,1
			
			COL_LOOP:
			
			#if((row>0 && r< n-1) && (col >0 && col<n-1))	>> print ' ' 
			#else >> print char
			
				slt $t7,$s7,$s0			#check boundry of the number of coloumns
				beq $t7,$zero,ROW_LOOP
				addi $s7,$s7,1
				beq $s6,$zero,PRINT_CHAR
				slt $t1,$s6,$s0
				beq $t1,$zero,PRINT_CHAR
				beq $s7,$zero,PRINT_CHAR
				slt $t1,$s7,$s0
				beq $t1,$zero,PRINT_CHAR
				# print space, 32 is ASCII code for space
				li $a0, 32
				li $v0, 11  # syscall number for printing character
				syscall
				j COL_LOOP
				PRINT_CHAR:
					li $v0,11
					addi $a0,$s1,0
					syscall
					j COL_LOOP
		

	EXIT:	
		li $v0,10
		syscall
		
