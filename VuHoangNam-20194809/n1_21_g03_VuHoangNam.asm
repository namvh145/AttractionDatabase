################################################################
#			DEGREE NUMBER PROGRAM
################################################################
#	Programmed by Vu Hoang Nam 20194809
################################################################
# 	This program run in the console, to get one number and then process that
# 	number to get the degree of the number
################################################################
.data
	msg_in: .asciiz "Enter a number to find a digit: "
	msg_out: .asciiz "\nThe degree of the number is: "
.text
main:
	#Input the number by using syscall 5
	la $a0, msg_in
	li $v0, 4
	syscall
	li $v0, 5
	syscall
	move $s0, $v0 #Save the number to the register s0 = n

	#Implement the procedure digitDegree(int n)
	move $a0, $s0
	li $v0, 0
	jal digitDegree
	move $s0, $v0 #Temporarily save the result to the register s0
	
	#Print out the result to the console by uisng syscall 1
	la $a0, msg_out
	li $v0, 4
	syscall
	move $a0, $s0
	li $v0, 1
	syscall
	
	#Exit the program
	li $v0, 10
	syscall
################################################################
#		GET THE DEGREE OF THE NUMBER PROCEDURE
################################################################
#Input:
# $a0 - the old number (n)
# $s0 - the new number(new_number) => $a0
# $s1 - the current digit (digit)
# $t0 - condition variable
# Output:
# $v0: the degree of the number
#Pseudocode for procedure digitDegree(n: int)
#digitDegree(int n)
#	if (n < 10)
#		then return 0
#	new_number = 0
#	while (  n != 0 )
#	{
#		digit = n % 10
# 		new_number = new_number + digit
# 		n  = n / 10
# 	}
# 	return 1 + digitDegree(new_number)
#
digitDegree:
	#Make space for the incoming procedure
	addi $sp, $sp, -4 
	sw $fp, 0($sp)	#Save the frame pointer of the stack
	add $fp, $sp, $zero #Save the current stack pointer
	addi $sp, $sp, -8
	sw $ra, 0($sp)	#Save the caller's address
	sw $s0, 4($sp) #Save the value of register $s0 
	
	li $s0, 0 #Initialize the variable new_number = 0
	#Create the base condition for the recursion
	slti $t0, $a0, 10 #t0 = n < 10?
	beqz $t0, WHILE_LOOP #if n >= 10, jump to the while loop
	b LEAF_RECURSION #else go to the return 0
	
	
	WHILE_LOOP:
		beqz $a0, END_WHILE_LOOP #if n = 0 then exit the while loop
		rem $s1, $a0, 10 #digit = n % 10
		add $s0, $s0, $s1 #new_number += digit
		div $a0, $a0, 10 #n = n / 10
		j WHILE_LOOP #Go the while loop again
	END_WHILE_LOOP:
	move $a0, $s0 #Move the current number to the parameter of the next call
	addi $v0, $v0, 1
	jal digitDegree #call recursively
	
	#go to the final recursion
	LEAF_RECURSION:
		#Restore all values needed
		add $v0, $v0, $0
		lw $s0, 4($sp)
		lw $ra, 0($sp)
		add $sp, $fp, $0
		lw $fp, 0($sp)
		addi $sp, $sp, 4 
		jr $ra #Return to the caller's address
