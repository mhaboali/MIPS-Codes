
	.data
arr:		.word	76 32 21 44 21 90 1 11 61 81 92 3 5 2 8 38 63 	#place your array elements here
arr_size:	.space	4
before:		.asciiz	"Before : "
after:		.asciiz "After  : "
space:		.asciiz " "
newLine:	.asciiz "\n"

	.text
	.globl MAIN

MAIN:

# store the size of arr
	la $t0, arr_size			#load the address of first element in array
	la $t1, arr				#load the address of first element after last element in the array
	sub $t2, $t0, $t1			#get the number of elements in array
	srl $t2, $t2, 2				#multiply by 4 because array of integers which need 4 bytes for each element
	sw $t2, 0($t0)				#store the size of array in $t2
	
# print "Before : "
	li $v0, 4
	la $a0, before
	syscall
# print arr
	jal PRINT				#PRINT : to print the array's elements
	
# Call quick sort
	#Here the arguments to be passed in $a0,$a1,$a2 for quick procedure
	la $a0, arr				#passing the address of first element in array
	li $a1, 0				#passing the most left element in array / sub-array after partioning 
	# store the array's size -1 into $a2 to point to last element in array	 
	lw $t0, arr_size
	addi $t0, $t0, -1
	add $a2, $t0,$zero
	# function call
	jal QUICK
	#when get here the array became sorted
# print "After : "
	li $v0, 4
	la $a0, after
	syscall
# print Sorted arr
	jal PRINT 

	
# end program
	li $v0, 10
	syscall

PRINT:
## print arr
	la $s0, arr					#get pointer to first element in array
	lw $t0, arr_size				#load array size into $t0
LOOP_MAIN1:
	beq $t0, $zero, LOOP_MAIN1_DONE			#base condition to break from this loop and jump to loop_DONE
	# make space
	li $v0, 4
	la $a0, space
	syscall
	# printing arr elements
	li $v0, 1
	lw $a0, 0($s0)
	syscall
	
	addi $t0, $t0, -1
	addi $s0, $s0, 4
	
	j LOOP_MAIN1
	
LOOP_MAIN1_DONE:
	# make new line
	li $v0, 4
	la $a0, newLine
	syscall
	jr $ra					#return to the MAIN

QUICK:
## quick sort

# store all $s i used and $ra on the stack
	addi $sp, $sp, -24			# Adjuest sp to store 6 registers on stack
	sw $s0, 0($sp)				# store s0
	sw $s1, 4($sp)				# store s1
	sw $s2, 8($sp)				# store s2
	sw $a1, 12($sp)				# store a1
	sw $a2, 16($sp)				# store a2
	sw $ra, 20($sp)				# store ra

# set $s0 as left pointer , $s1 as right pointer and $s2 as a pivot element
	move $s0, $a1				# l = left
	move $s1, $a2				# r = right
	move $s2, $a1				# p = left

# while (l < r)
LOOP_QS1:
	bge $s0, $s1, LOOP_QS1_DONE
	
# while (arr[l] <= arr[p] && l < right)
LOOP_QS1_1:
	li $t7, 4				# t7 = 4 to use as multiplier factor for accessing the integer elements
	# t0 = &arr[l]
	mult $s0, $t7				#set the ouput of mult into LO register "lower order of 32 bit reg"
	mflo $t0				# t0 =  l * 4bit to access the result of a multiplication and set it into $t0
	add $t0, $t0, $a0			# t0 = &arr[l]
	lw $t0, 0($t0)
	# t1 = &arr[p]
	mult $s2, $t7
	mflo $t1				# t1 =  p * 4bit to access the result of a multiplication and set it into $t1
	add $t1, $t1, $a0			# t1 = &arr[p]
	lw $t1, 0($t1)
	# check arr[l] <= arr[p]
	bgt $t0, $t1, LOOP_QS1_1_DONE
	# check l < right
	bge $s0, $a2, LOOP_QS1_1_DONE
	# l++
	addi $s0, $s0, 1
	j LOOP_QS1_1
	
LOOP_QS1_1_DONE:

# while (arr[r] >= arr[p] && r > left)
LOOP_QS1_2:
	li $t7, 4				# t7 = 4
	# t0 = &arr[r]
	mult $s1, $t7
	mflo $t0				# t0 =  r * 4bit
	add $t0, $t0, $a0			# t0 = &arr[r]
	lw $t0, 0($t0)
	# t1 = &arr[p]
	mult $s2, $t7
	mflo $t1				# t1 =  p * 4bit
	add $t1, $t1, $a0			# t1 = &arr[p]
	lw $t1, 0($t1)
	# check arr[r] >= arr[p]
	blt $t0, $t1, LOOP_QUICK2_END
	# check r > left
	ble $s1, $a1, LOOP_QUICK2_END
	# r--
	addi $s1, $s1, -1
	j LOOP_QS1_2
	
LOOP_QUICK2_END:

# if (l >= r)
	blt $s0, $s1, If_QS1_JUMP
# SWAP (arr[p], arr[r])
	li $t7, 4				# t7 = 4
	# t0 = &arr[p]
	mult $s2, $t7
	mflo $t6				# t6 =  p * 4bit
	add $t0, $t6, $a0			# t0 = &arr[p]
	# t1 = &arr[r]
	mult $s1, $t7
	mflo $t6				# t6 =  r * 4bit
	add $t1, $t6, $a0			# t1 = &arr[r]
	# Swap
	lw $t2, 0($t0)
	lw $t3, 0($t1)
	sw $t3, 0($t0)
	sw $t2, 0($t1)
	
# quick(arr, left, r - 1) 
	# set arguments
	move $a2, $s1
	addi $a2, $a2, -1			# a2 = r - 1
	jal QUICK				#Recurrsive call #1
	# free the data from the stack
	lw $a1, 12($sp)				# load a1
	lw $a2, 16($sp)				# load a2
	lw $ra, 20($sp)				# load ra
	
# quick(arr, r + 1, right)
	# set arguments
	move $a1, $s1
	addi $a1, $a1, 1			# a1 = r + 1
	jal QUICK				#Recurrsive call #2
	# free data from stack
	lw $a1, 12($sp)				# load a1
	lw $a2, 16($sp)				# load a2
	lw $ra, 20($sp)				# load ra
	
# return
	lw $s0, 0($sp)				# load s0
	lw $s1, 4($sp)				# load s1
	lw $s2, 8($sp)				# load s2
	addi $sp, $sp, 24			# Adjest sp
	jr $ra					#return from 2nd recurrsive call

If_QS1_JUMP:

# SWAP (arr[l], arr[r])
	li $t7, 4				# t7 = 4
	# t0 = &arr[l]
	mult $s0, $t7
	mflo $t6				# t6 =  l * 4bit
	add $t0, $t6, $a0			# t0 = &arr[l]
	# t1 = &arr[r]
	mult $s1, $t7
	mflo $t6				# t6 =  r * 4bit
	add $t1, $t6, $a0			# t1 = &arr[r]
	# Swap
	lw $t2, 0($t0)
	lw $t3, 0($t1)
	sw $t3, 0($t0)
	sw $t2, 0($t1)
	
	j LOOP_QS1
	
LOOP_QS1_DONE:
	
# return

	lw $s0, 0($sp)				# load s0
	lw $s1, 4($sp)				# load s1
	lw $s2, 8($sp)				# load s2
	addi $sp, $sp, 24			# Adjest sp
	jr $ra					#return from 1st recurrsive call
