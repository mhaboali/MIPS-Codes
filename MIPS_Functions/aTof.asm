.data

str_new_line:	.asciiz		"\n"
zeroF:		.float 0.0
fileName:	.asciiz  "/media/jayger/P2/mine/Work/MIPS_Assignment/numbers.txt"	#type here the full path of your input file
error1:		.asciiz "File failed to open"
FILE:		.word 0
fileWords:	.space 10000
.text

main:

	# Initializations
		add $t1,$zero,$zero		#will be used as a flag
		addi $t2,$zero,1		#multiplication factor which used in converstion
		add $t3,$zero,$zero		#will be used as a flag
		add $s1,$zero,$zero		#digit-counter of number
		add $s2,$zero,$zero		#wll be used as a flag
		addi $t6,$zero,48		#just hold the ascii of zero
		addi $t7,$zero,0		#flag for excludin pure integers
		
read_input:
		#HOW TO READ INTO A FILE
	
	li $v0,13           	# open_file syscall code = 13
    	la $a0,fileName     	# get the file name
    	li $a1,0           	# file flag = read (0)
    	syscall
    	
    	add $s7,$v0,$zero        # save the file descriptor. $s7 = file
	sw $s7, FILE
	#read the file
	li $v0, 14		# read_file syscall code = 14
	add $a0,$s7,$zero	# file descriptor
	la $a1,fileWords  	# The buffer that holds the string of the WHOLE file
	la $a2,10000		# hardcoded buffer length
	syscall
	add $s0,$a1,$zero
	
	#Close the file
    	li $v0, 16         		# close_file syscall code
    	add $a0,$s7,$zero      		# file descriptor to close
    	syscall


FILE_PARSER:	
	#Here we parse the file contents to extract only the floating point numbers
	#load each char
	lb $t0,($s0)
	beq $t0,0,EOF				#check for end of file
	addi $s0,$s0,1				#increase loop-counter
	beq $t0,32,SPACE			#if(char==' ') goto SPACE
	beq $t0,46,DOT				#if(char=='.') goto SPACE
	slt $t1,$t0,$t6
	#If any char not number
	beq $t1,1,FILE_PARSER
	sgt $t1,$t0,57
	beq $t1,1,FILE_PARSER
	DIGIT:
	#get here if only the char is a digit of number
		#start preparing for conversion
		mul $t2,$t2,10			#ascii of back space "end of line"
		addi $s1,$s1,1
		lb $t0,($s0)
		beq $t0,10,BACK_SPACE1		#To detect end of line , it handles the last number in the line
		j FILE_PARSER
	DOT:
	#get here if the char is '.' and check if it's percision point or not ,
	#then continue the conversion
		sub $s0,$s0,2
		lb $t0,($s0)
		sge $t3,$t0,48			#check if >=0
		sle $s2,$t0,57			#check if <=9
		and $t3,$t3,$s2
		addi $s0,$s0,2
		addi $t7,$zero,1
		#get here if any char
		beq $t3,1,FILE_PARSER		#goto file parser if it's percision point
		#get here if it'snot percision point		
		addi $s1,$zero,0
		addi $t2,$zero,1
		j FILE_PARSER
	SPACE:	
	#get here only if the char is ' ' space and checking if it seperates 2 numbers 
	#or char and number or what exactly
		#look at the previous element if it's number , so we convert the whole number if it's float
		#else goto file parser
		sub $s0,$s0,2
		lb $t0,($s0)
		sge $t3,$t0,48
		sle $s2,$t0,57
		and $t3,$t3,$s2
		addi $s0,$s0,2
		beq $t7,0,INTEGER			#to prevent integers from conversion
		beq $t3,0,FILE_PARSER
		addi $s3,$s0,-2
	BACK_SPACE2:
	#get here only at the end of line to get its floating number
		sub $s3,$s3,$s1
		div $t2,$t2,10
		CONVERT_LOOP:
		#here we convert the whole number as it to float
			lb $t0,($s3)
			addi $s3,$s3,1
			bne $t0,46,NOT_DOT
			#get here if only the char is '.' to skip it
			mul $t5,$t2,10
			j CONVERT_LOOP
			
		NOT_DOT:
		#get here if the char is a digit and convert it to weighted integer number
			addi $t0,$t0,-48
			mul $t4,$t0,$t2
			add $s4,$t4,$s4
			div $t2,$t2,10
			sub $s1,$s1,1
			bne $s1,$zero,CONVERT_LOOP
			aTof_return:
			#get here to convert the integer number to floating point and print it
			#mainly it converts into float by calculating the whole number as integer 
			#then divide by pow(10,number of digits after dot)
				#move the integer numbers into floating point registers and converting it to be suitable at fp registers
				mtc1 $s4,$f0
				cvt.s.w $f0,$f0			#convert from word to single percision
				mtc1 $t5,$f1
				cvt.s.w $f1,$f1
				div.s $f12,$f0,$f1		#dividing to get the fp number
				#print the fp number
				li $v0,2
				syscall
				#print space
				li $v0,11
				li $a0,32
				syscall
			INTEGER:
			#get here if the number is pure integer which needed to be excluded
				addi $s1,$zero,0
				addi $t2,$zero,1
				add $s4,$zero,$zero
				addi $t7,$zero,0
				j FILE_PARSER
				
	EOF:
	#exit from program if reach end of file
		li $v0,10
		syscall
	BACK_SPACE1:
	#get here only for handling printing the last number in the line
		addi $s3,$s0,-1
		beq $t7,0,FILE_PARSER
		j BACK_SPACE2	
		
	