# Author: Ta Minh Quan -20194824
# pseudo code:
#   do{
# 	char inputString[20];
# 	cout << "Input string: "
#  	cin >> inputString;
#	int length = FindLength(inputString);
#	if( IsValidString(inputString, length) == 0){
#		cout << "Your input string is invalid\n";
#	}
#	else break;
#   }while(1);
#   if( is_surpassing_word(inputString, length)) cout << "True";
#   else cout << "False";

.data
	prompt: .asciiz "Input string: "
	invalidInputPrompt: .asciiz "Your input string is invalid\n"
	isTruePrompt: .asciiz "True\n"
	isFalsePrompt: .asciiz "False\n"
	inputString: .space 20
	
.text
inputLoop:
	# Prompt string
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 8
	la $a0, inputString
	li $a1, 20
	syscall
	
	move $s0, $a0			# stores inputString into $s0
	
	# Find the length of string
	jal FindLength
	move $s1, $v0			# stores length of string into $s1
	
	# Check if the input string is valid or not
	move $a0, $s0
	move $a1, $s1
	jal IsValidString
	beq $v0, 1, OutInputLoop	# if valid then exit the loop
	# else if invalid
	li $v0, 4
	la $a0, invalidInputPrompt
	syscall
	
	j inputLoop			
OutInputLoop:
	# Check if string is surpassing 
	move $a0, $s0			# pass input string argument
	move $a1, $s1			# pass string's lenth argument
	jal IsSurpassingWord
	beqz $v0, IsFalse		# if v0 == 0 then jump to IsFalse
		# else if v0 == 1
		li $v0, 4
		la $a0, isTruePrompt
		syscall
		j CheckSurpassingFinish 
	IsFalse:
		li $v0, 4
		la $a0, isFalsePrompt
		syscall
		
	CheckSurpassingFinish:
	j ExitProgram
	
	# Exit the program
	ExitProgram:
	li $v0, 10
	syscall

# subprogram: IsValidString
# purpose: to check the input string is valid or not
# input: 	a0 	- input string
#		a1	- string's length
# output: 	v0	- result (0 is false, 1 is true) 
# pseudo code:
# for(int i=0;i<length;i++){
#	if(('a'<=str[i] && str[i]<='z') || ('A'<= str[i] && str[i]<='Z')){
#		cotinue;
#	}
#	else{
#		return false;
#	}
# }
# return true;

IsValidString:
	li $t0, 0			# i = 0
	IsValidLoop:
		bge $t0, $a1, ExitValidLoop		# if i >= length, then exit loop
		add $t1, $t0, $a0			
		lb $t1, 0($t1)				# t1 = str[i]
		sge $t2, $t1, 0x41			# str[i] >= 'A' = 0x41 ?
		sle $t3, $t1, 0x5a			# str[i] <= 'Z' = 0x5A ?
		and $t2, $t2, $t3			# t2 = 'A'<= str[i] && str[i]<='Z'
		
		sge $t4, $t1, 0x61			# str[i] >= 'a' = 0x61 ?
		sle $t5, $t1, 0x7a			# str[i] <= 'z' = 0x7a ?
		and $t4, $t4, $t5			# t4 = 'a'<= str[i] && str[i]<='z'
		
		or $t2, $t2, $t4			
		beqz $t2, Invalid			# if t2 == 0 then exit loop
		
		addi $t0, $t0, 1			# i = i+1
		j IsValidLoop
		
	ExitValidLoop:
	j Valid
	
	Valid:
	li $v0, 1
	j ExitIsValid
	
	Invalid:
	li $v0, 0
	j ExitIsValid
	
	ExitIsValid:
	jr $ra						# return
	

# subprogram: FindLength
# purpose: return the input string's length
# input: 	a0 	- input string
# output: 	v0 	- length of the string
# pseudo code:
# length = 0
# while(A[length]!='\0' && A[length]!='\n'){
#	length++;
# }
# return length;

FindLength:
	addi $sp, $sp, -4
	sw $a0, 0($sp)					# stores the address of a0 into $sp
	move $t0, $zero					# initalize length to 0 
	FindLengthLoop:	
		lb $t1, 0($a0)				# load the next character into $t1
		beqz $t1, ExitFindLengthLoop		# check for \0
		beq $t1, 0xa, ExitFindLengthLoop	# check for \n 
		addi $a0, $a0, 1			# increment string pointer
		addi $t0, $t0, 1			# increment the length
		j FindLengthLoop
	ExitFindLengthLoop:
	lw $a0, 0($sp)					# restores the address of a0 
	addi $sp, $sp, 4				# restores the $sp
	move $v0, $t0					# stores length of string into v0
	jr $ra						# return 
				

# subprogram: is_surpassing_word
# purpose: to check the input string is surpassing or not
# input:	a0 	- input string
# 		a1	- string's length
# output: 	v0 	- result (0 is false, 1 is true)
# pseudo code:
# if(length == 0) return true;
# if(length == 1) return true;
# if(length == 2) return true;
# int tmp = abs(str[1] - str[0]);
# int previous = tmp;
# for(int i=2;i<length;i++){
# 	tmp = abs(str[i] - str[i-1]);
# 	if(previous < tmp){
#		previous = tmp;
#	}
# 	else{
#		return false;
#	}
# }
# return true; 
 	
IsSurpassingWord:
	beqz $a1, ReturnTrue		# length == 0 ?
	beq $a1, 1, ReturnTrue		# length == a1 = 1 ? 
	beq $a1, 2, ReturnTrue		# length == a1 = 2 ?
	lb $t2, 0($a0)			# t2 = str[0]
	lb $t3, 1($a0)			# t3 = str[1]
	sub $t0, $t3, $t2		
	abs $t0, $t0			# t0 = tmp = abs(t3-t2) = abs(str[1]-str[0])
	move $t1, $t0			# t1 = previous = tmp
	li $t4, 2			# t4 = i = 2
	SurpassingLoop:			
		bge $t4, $a1, EndSurpassingLoop		# if i < length, then end loop 
		add $t5, $a0, $t4			# t5 = str[0+i] = str[i]
		lb $t3, 0($t5)				# t3 = t5 = str[i]
		addi $t5, $t5, -1			
		lb $t2, 0($t5)				# t2 = str[i-1]
		sub $t0, $t3, $t2
		abs $t0, $t0				# t0 = tmp = abs(t3-t2) = abs(str[i]-str[i-1])
		bge $t1, $t0, ReturnFalse		# if previsous >= tmp, then return false
		# else if previous < tmp
		move $t1, $t0				# previous = tmp
		addi $t4, $t4, 1			# i = i + 1
		j SurpassingLoop
		
	EndSurpassingLoop:
	j ReturnTrue
	
	ReturnTrue:
	li $v0, 1
	j ExitIsSurpassing
	
	ReturnFalse:
	li $v0, 0
	j ExitIsSurpassing
	
	ExitIsSurpassing:
	jr $ra						# return 
		
		
	
	
	
	
	
