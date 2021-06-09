# Author: Ta Minh Quan - 20194824
# pseudo code:
# do{
# 	char inputString[80];
#	printf("Nhap chuoi ki tu : ");
#  	scanf("%s", inputString);
#	int length = FindLength(inputString);
#	if( IsValidString(length) == 0){
#		cout << "Chuoi ki tu khong hop le\n";
#	}
#	else break;
#   }while(1);
# SimulateRaid5(inputString, length);

.data
	prompt: .asciiz "Nhap chuoi ki tu : "
	invalidStringPrompt: .asciiz "Chuoi ki tu khong hop le\n"
	inputString: .space 80
.text
inputLoop:
	# Prompt string
	li $v0, 4
	la $a0, prompt
	syscall
	
	li $v0, 8
	la $a0, inputString
	li $a1, 80
	syscall
	
	move $s0, $a0			# stores inputString into $s0
	
	# Find the length of string
	jal FindLength
	move $s1, $a1			# stores length of string into $s1
	
	# Check if the input string is valid or not
	move $a0, $s1
	jal IsValidString
	beq $a1, 1, OutInputLoop	# if valid then exit the loop
	# else if invalid
	li $v0, 4
	la $a0, invalidStringPrompt
	syscall
	
	j inputLoop			
OutInputLoop:
	move $a0, $s0
	move $a1, $s1
	jal SimulateRaid5

	# Exit the program
	li $v0, 10
	syscall 

# subprogram: IsValidString
# purpose: to check the input string is valid or not
# input: 	a0 - length of the string
# output:	a1 - valid string or not (1 is valid, 0 is invalid)
# pseudo code:
# if(length % 8 !=0) return false;
# return true;

IsValidString:
	rem $t0, $a0, 8
	beqz $t0, isValid				# if length % 8 == 0, then valid
		# else if length % 8 != 0	
		li $a1, 0				# return false
		j ExitIsValid			
	isValid:
	li $a1, 1					# return true
	j ExitIsValid

	ExitIsValid:
	jr $ra						# return 	

# subprogram: FindLength
# purpose: return the input string's length
# input: 	a0 	- input string
# output: 	a1 	- length of the string
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
		beqz $t1, ExitFindLengthLoop		# check for null terminator
		beq $t1, 0xa, ExitFindLengthLoop	# check for \n 
		addi $a0, $a0, 1			# increment string pointer
		addi $t0, $t0, 1			# increment the length
		j FindLengthLoop
	ExitFindLengthLoop:
	lw $a0, 0($sp)					# restores the address of a0 
	addi $sp, $sp, 4				# restores the $sp
	move $a1, $t0					# stores length of string into a1
	jr $ra						# return 
	
# subprogram: SimulateRaid5
# purpose: simulate raid 5 with 3 disk, print the desired interface
# input: 	a0 - input string
#		a1 - length of the string
# output: 	none
# pseudo code:
# printf("     Disk 1                Disk 2                Disk 3     \n");
# printf(" --------------        --------------        -------------- \n");
# int i = 0;
# int numberOfLoop = length / 8;
# for(int i=0;i<length;i++){
#	char firstString[4]; 
#	char secondString[4];
#	char xorString[4];  
#	for(int j=0;j<4;j++){
#       	char first = str[8*i+j];
#           	char second = str[8*i+j+4];
#           	firstString[j] = first;
#            	secondString[j] = second;
#            	xorString[j] = first^second;
#      	}
#      	if(i%3==0){
#            	printNormal(firstString);
#            	printf("     ");
#            	printNormal(secondString);
#            	printf("     ");
#            	printXorResult(xorString);
#       }
#     	if(i%3==1){
#            	printNormal(firstString);
#            	printf("     ");
#            	printXorResult(xorString);
#            	printf("     ");
#           	printNormal(secondString);
#        	}
#    	if(i%3==2){
#		printXorResult(xorString);
#            	printf("     ");
#          	printNormal(firstString);
#            	printf("     ");
#           	printNormal(secondString);
#       	}
#       	printf("\n");
#   	}
#   	printf(" --------------        --------------        -------------- \n");
# }

.data
	diskLine: .asciiz "     Disk 1                Disk 2                Disk 3     \n"
	hyphenLine: .asciiz " --------------        --------------        -------------- \n"
	fiveSpace: .asciiz "      "
	newLine: .asciiz "\n"
	first: .space 4
	second: .space 4
	xorString: .space 4

.text
SimulateRaid5:
	addi $sp, $sp, -4					# reserve space for storing in $sp
	sw $ra, 0($sp)						# stores $ra in 0($sp)
	move $s0, $a0						# stores a0 in s0
	move $s1, $a1						# stores a1 in s1
	# Print disk line
	li $v0, 4
	la $a0, diskLine
	syscall
	# Print hyphen line
	li $v0, 4
	la $a0, hyphenLine
	syscall
	# Initialize variable
	li $t0, 0						# t0 = i = 0
	div $s2, $s1, 8						# s2 = numberOfLoop = length/8;
	la $s3, first
	la $s4, second
	la $s5, xorString
	
	# start the for loop	
OuterLoop:
	bge $t0, $s2, EndOuterLoop				# if i >= numberOfLoop, then end loop
	# else:
	li $t1, 0						# t1 = j  = 0
	InnerLoop:
		bge $t1, 4, EndInnerLoop			# if j >= 4, then end loop
		# else:
		mul $t2, $t0, 8					# t2 = 8*i
		add $t2, $t2, $t1				# t2 = 8*i+j
		add $t2, $t2, $s0				# t2 = str + 8*i+j = str + 8*i+j
		
		lb $t3, 0($t2)					# t3 = str[8*i+j]
		add $t4, $s3, $t1				# t4 = first + j
		sb $t3, 0($t4)					# t4 = first + j = str[8*i+j]
		
		addi $t2, $t2, 4				# t2 = str + 8*i+j + 4
		lb $t4, 0($t2)					# t4 = str[8*i+j+4]
		add $t5, $s4, $t1				# t5 = second + j
		sb $t4, 0($t5)					# t5 = second + j = str[8*i+j+4]
		
		xor $t3, $t3, $t4				# t3 = t3 xor t4 = str[8*i+j] xor str[8*i+j+4]
		add $t4, $s5, $t1				# t4 = xorString + j
		sb $t3, 0($t4)					# t4 = xorString + j = str[8*i+j] xor str[8*i+j+4]
		
		addi $t1, $t1, 1				# j = j + 1
		j InnerLoop
	EndInnerLoop:
	rem $t1, $t0, 3						# t1 = t0 % 3 = i % 3
	beqz $t1, InZero					# if t1 == 0, branch to InZero
	beq $t1, 1, InOne					# if t1 == 1, branch to InOne
	# else if t1 == 2:
		move $a0, $s5
		jal printXorResult
		li $v0, 4
		la $a0, fiveSpace
		syscall
		move $a0, $s3
		jal printNormal
		li $v0, 4
		la $a0, fiveSpace
		syscall
		move $a0, $s4
		jal printNormal		
		j EndIf
	InZero:
		move $a0, $s3
		jal printNormal
		li $v0, 4
		la $a0, fiveSpace
		syscall
		move $a0, $s4
		jal printNormal
		li $v0, 4
		la $a0, fiveSpace
		syscall
		move $a0, $s5
		jal printXorResult		
		j EndIf
	InOne:			
		move $a0, $s3
		jal printNormal
		li $v0, 4
		la $a0, fiveSpace
		syscall
		move $a0, $s5
		jal printXorResult
		li $v0, 4
		la $a0, fiveSpace
		syscall
		move $a0, $s4
		jal printNormal		
		j EndIf
	EndIf:
	addi $t0, $t0, 1					# i = i + 1
	# Print new line
	li $v0, 4			
	la $a0, newLine
	syscall
	j OuterLoop
EndOuterLoop:
	# print hyphen line
	li $v0, 4 
	la $a0, hyphenLine
	syscall
	
	lw $ra, 0($sp)						# restores value of $ra
	addi $sp, $sp, 4					# restores space at $sp
	
	jr $ra							# return

.data
	diskGap: .asciiz "      "
	openVerticalLine: .asciiz "|     "
	closeVerticalLine: .asciiz "     |"
	openSquareBracket: .asciiz "["
	closeSquareBracket: .asciiz "]"
	oneSpace: .asciiz " "
	comma: .asciiz ","
	lookupTable: .byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'

.text
# subprogram: printNormal
# purpose: print normal string
# input: 	a0 - inputString
# output: 	none
# pseudo code:
# printf("|     ");
# for(int i=0;i<4;i++){
#  	printf("%c", str[i]);
# }
# printf("     |");

printNormal:
	addi $sp, $sp, -12					# reserves spaces for storing 
	sw $ra, 0($sp)						# stores $ra in 0($sp)
	sw $t0, 4($sp)						# stores $t0
	sw $t1, 8($sp)						# stores $t1
	
	move $t1, $a0						# stores a0 in t1
	# printf("|     "); 
	li $v0, 4
	la $a0, openVerticalLine
	syscall
	# start the loop
	li $t0, 0						# t0 = i = 0
printNormalLoop:
	bge $t0, 4, OutNormalLoop				# if i >= 4, out the loop
	# else:
	add $t2, $t1, $t0					# t2 = inputString + i
	li $v0, 11
	lb $a0, 0($t2)				
	syscall							# print inputString[i]
	addi $t0, $t0, 1					# i = i + 1
	j printNormalLoop
OutNormalLoop:
	# printf("     |");
	li $v0, 4
	la $a0, closeVerticalLine
	syscall
	lw $ra, 0($sp)						# restores $ra
	lw $t0, 4($sp)						# restores $t0
	lw $t1, 8($sp)						# restores $t1
	addi $sp, $sp, 12					# restores space in $sp
	jr $ra							# return

# subprogram: printXorResult
# purpose: print xor result in  desired format
# input: 	a0 - inputString
# output: 	none
# pseudo code:
# printf("[[ ");
# printLastTwoByte(str[0]);
# for(int i=1;i<4;i++){
#	printf(",");
#  	printLastTwoByte(str[i]);
# }
# printf("]]");

printXorResult:
	addi $sp, $sp, -12					# reserves spaces for storing 
	sw $ra, 0($sp)						# stores $ra in 0($sp)
	sw $t0, 4($sp)						# stores $t0
	sw $t1, 8($sp)						# stores $t1
	
	move $t0, $a0						# stores a0 in t0
	# printf("[[ ");
	li $v0, 4
	la $a0, openSquareBracket
	syscall
	syscall
	la $a0, oneSpace
	syscall
	# printf("%02x", str[0]);
	lb $a0, 0($t0)
	jal printLastTwoByte
	
	li $t1, 1						# t1 = i = 1
PrintXorLoop:
	bge $t1, 4, OutPrintXorLoop				# if i >= 4, then out the loop
	# else:
	li $v0, 4
	la $a0, comma
	syscall							# printf(",");
	add $t2, $t0, $t1					# t2 = str + i		
	lb $a0, 0($t2)						# a0 = str[i]
	jal printLastTwoByte					# printf("%02x", str[i]);
	addi $t1, $t1, 1					# i = i + 1
	j PrintXorLoop
OutPrintXorLoop:
	# printf("]]");
	li $v0, 4
	la $a0, closeSquareBracket
	syscall
	syscall
	
	lw $ra, 0($sp)						# restores $ra
	lw $t0, 4($sp)						# restores $t0
	lw $t1, 8($sp)						# restores $t1
	addi $sp, $sp, 12					# restores space in $sp
	
	jr $ra
	
# subprogram: printLastTwoByte
# purpose: print the last two byte 
# input: 	a0 - xor's result string (xorString)
# output:	none
# pseudo code:
# printf(lookupTable[xorString[1]]);
# printf(lookupTable[xorString[0]]);
# side effect: print last two byte of xor's result string
printLastTwoByte:
	addi $sp, $sp, -8					# reserves space for storing in $sp
	sw $t0, 0($sp)						# stores $t0
	sw $t1, 4($sp)						# stores $t1

	move $t0, $a0						# stores a0 in t0
	la $t1, lookupTable					# t1 = lookupTable			
	
	andi $t2, $t0, 15					# t2 = t0 xor 15 = xorString[0]
	add $t2, $t1, $t2					# t2 = lookupTable[t2]
	
	srl $t0, $t0, 4						
	andi $t3, $t0, 15					# t3 = xorString[1]
	add $t3, $t1, $t3					# t3 = lookupTable[t3]
	
	# Print
	li $v0, 11					
	lb $a0, 0($t3)
	syscall
	
	li $v0, 11
	lb $a0, 0($t2)
	syscall
	
	lw $t0, 0($sp)						# restores $t0
	lw $t1, 4($sp)						# restores $t1
	addi $sp, $sp, 8					# restores space in $sp
	
	jr $ra							# return
