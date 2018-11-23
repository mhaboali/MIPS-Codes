.data 
	#these variables 'll be used in .text section
	prompt:   	.asciiz "Please enter a Number -> "
	display_1:	.asciiz"P("
	display_2:	.asciiz") = "
	# newline character
	newline:    	.asciiz "\n"
	n:		.word 0
	r:		.word 0
	result:		.word 0
	
.globl Fact
.globl Permaute	
	
	
.text
	MAIN:	
		#get the input from user
		li $v0,4
		la $a0,prompt
		syscall
		
		li $v0,5
		syscall
		sw $v0,n				#store the input number into n variable
		addi $s4,$v0,1				#counter for loop and it's added by one for controlling the loop iterations
		
		WHILE_PERMAUTE:
		#here we get the all permautations of this number and all numbers which's less than it				
			sub $s4,$s4,1
			sw $s4,n
			add $a0,$s4,$zero
			add $a1,$s4,$zero
			beq $s4,$zero,EXIT
			jal Permaute			# to get permuatation of each number the input and others less than input number
			j WHILE_PERMAUTE
			
		
	EXIT:
		li $v0,10
		syscall
		
	Permaute:
		#p(n,r) = fact(n)/fact(n-r)		
		jal Fact
		add $s1,$v0,$zero		#s1=fact(n)
		lw $a0,n
		sub $a0,$a0,$a1			#n-r=a0
		jal Fact	
		add $s2,$v0,$zero		#s2=fact(n-r)
		div $s3,$s1,$s2			#p(n,r)
		#display each p(n,r) in proper format
		li $v0,4
		la $a0,display_1
		syscall
		#n
		li $v0,1
		lw $a0,n
		syscall
		#this printing comma
		li $v0,11
		li $a0,44
		syscall
		#r		
		li $v0,1
		add $a0,$a1,$zero
		syscall
		li $v0,4
		la $a0,display_2
		syscall
		li $v0,1
		add $a0,$s3,$zero
		syscall
		li $v0,4
		la $a0,newline
		syscall
		sub $a1,$a1,1
		lw $a0,n
		beq $a1,$zero,WHILE_PERMAUTE
		j Permaute
		
		
	Fact:
	# is implemented in recurrsive way
		subu $sp,$sp,8
		sw $ra,($sp)
		sw $s0,4($sp)
		#base condition
		li $v0,1
		beq $a0,$zero,FACT_DONE
		#fact(n-1)
		add $s0,$a0,$zero
		sub $a0,$a0,1
		jal Fact
		#basic operation
		mul $v0,$s0,$v0
		
		FACT_DONE:
			lw $ra,($sp)
			lw $s0,4($sp)
			addu $sp,$sp,8
			jr $ra
			
		
		
		
