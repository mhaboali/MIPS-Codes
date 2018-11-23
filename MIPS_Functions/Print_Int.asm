.data

#These are variables to be used in .text section
#======================================================
	enterMsg: 	.asciiz"Please, Enter Postive Integer Number : "
	outputMsg:	.asciiz"\nThe Ouput Is : \n"
	errorMsg:	.asciiz"ERROR : You Entered Negative Number!, Please Try Again \n\n"
	newLine:	.asciiz"\n"
	ch_ast:		.byte'*'
.text
	MAIN: #Here's our MAIN function
		jal GET_INT
		jal PRINT_INT
		
		#Printing n '*'
		jal PRINT_CHAR
		
	EXIT:	#when get here the OS 'll terminate your program
		li $v0,10
		syscall
	GET_INT:
		#display Enter Msg
		li $v0,4			#4 is a print string
		la $a0,enterMsg			#get the enterMsg from RAM
		syscall				#tell the os to execute printing string
	
		#Get the integer number from user:
		li $v0,5			#5 is read integer code
		syscall
		slti $s1,$v0,0			#check if the input is negative or not
		bne $s1,$zero,BREAK		#if $s1==1 goto BREAK
		#ELSE
		addi $s0,$v0,0			#$s0 = n;
		jr $ra				#to return at instruction that's after jal GET_INT
		
	PRINT_INT:
		#here 's printing the output in desired format
		#print outputMsg
		li $v0,4
		la $a0,outputMsg
		syscall
		
		#print number
		li $v0,1
		move $a0,$s0			#set the n at $a0 to be printed
		syscall
		
		li $v0,4
		la $a0,newLine
		syscall
		jr $ra				# to return at the instruction after jal
		
		BREAK: #GET HERE IF INPUT WAS NEGATIVE
			li $v0,4			
		       	la $a0,errorMsg
		       	syscall
		       	j MAIN
		       
	PRINT_CHAR:
		addi $s2,$zero,0 		#$t1=i=0; initialization of coutner of loop
		while:	# loop to print * n times
		
			addi $s2,$s2,1		#counter+=1
			bgt $s2,$s0,exit	#check if(counter>n) to break the loop
			li $v0,4		#print the char
			la $a0,ch_ast
			syscall
			
			j while			#to loops n times
		
		exit:
			jr $ra
	
