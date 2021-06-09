######################################################################
# 			     BOUNCER BALL                             	#
######################################################################
#           Programmed by VU HOANG NAM	20194809	          #
######################################################################
#	This program requires the Keyboard and Display MMIO      #
#       and the Bitmap Display to be connected to MIPS.            	#
#								    	#
#       Bitmap Display Settings:                                    		#
#	Unit Width: 1						     	#
#	Unit Height: 1						    	#
#	Display Width: 512					     	#
#	Display Height: 512					     	#
#	Base Address for Display: 0x10010000 (static data)		#
######################################################################

#Initialize some data to run the program
.data
	frame:	.space 0x80000
	w:		.word  512
	h:		.word  512
	r:		.word  10
	velocity: 	.word  2
# direction variable
# 119 - moving up - W
# 115 - moving down - S
# 97 - moving left - A
# 100 - moving right - D
# numbers are selected due to ASCII characters
.eqv 	MOVEUP 	0x77
.eqv 	MOVEDOWN	0x73
.eqv 	MOVELEFT 	0x61
.eqv 	MOVERIGHT 0x64
.text	
main:
	la 	$s0, frame # get the first address of the frame
	lw 	$s1, w	# frame width 
	lw 	$s2, h # frame height
	
	srl 	$a0, $s1, 1 # Get the x coordinate center
	srl  	$a1, $s2, 1 # Get the y coordinate center
	lw	$a2, r # Get the initial radius of the circle to draw
	
	li 	$a3, 0x00ffff00 #Get the color to paint the ball with yellow
	jal 	drawBall #shape the ball to initialize
###############################################################
# 	MOVE PIXELS PROCEDURE
###############################################################
move_ball:
	move	$t2, $zero # x-velocity = 0
	move	$t3, $zero # y-velocity = 0
	lw 	$s5, velocity # delta(v) with unit of pixels
	move 	$t8, $a0 # new center
	move	$t9, $a1 # new center
	
	DO_WHILE:
	lw	$s3, 0xffff0000
	lw	$s4, 0xffff0004 #Get the direction from input
	
	beqz	$s3, idleMode
	
	
	li	$s6, 1	#Set the flag is 1 to remain moving even no input specified
	beq	$s4, MOVEUP, moveUp
	beq	$s4, MOVERIGHT, moveRight
	beq	$s4, MOVEDOWN, moveDown
	beq	$s4, MOVELEFT, moveLeft
	j	process_move
	
	##### Move the original O to new position #####
	moveUp:
		move 	$t8, $a0 # x = x_previous
		sub	$t9, $a1, $s5 # y = y - delta(v)
		move	$t2, $zero # x-velocity = 0
		sub	$t3, $zero, $s5 # y-velocity = -$t5
		j	process_move
	moveRight:
		add	$t8, $a0, $s5		# x = x + delta(v)
		move 	$t9, $a1		# y = y_previous
		move	$t3, $zero		# y-velocity = 0
		add	$t2, $zero, $s5		# x-velocity = $t5
		j	process_move
	moveDown:
		move 	$t8, $a0 # x = x_previous
		add	$t9, $a1, $s5 # y = y + delta(v)
		move	$t2, $zero # x-velocity = 0
		add	$t3, $zero, $s5 # y-velocity = $t5
		j	process_move	
	moveLeft:
		sub	$t8, $a0, $s5 # x = x - delta(v)
		move 	$t9, $a1 # y = y_previous
		move	$t3, $zero # y-velocity = 0
		sub	$t2, $zero, $s5 # x-velocity = -$t5
		j	process_move	
	
	process_move:
	li 	$a3, 0x00000000 # draw the old location to black
	jal	drawBall # draw the old location to black
	
	move	$a0, $t8 # new center
	move 	$a1, $t9 # new center
	
	li	$a3, 0x00ffff00 # draw at new location
	jal	drawBall
	
	j DO_WHILE
	
	idleMode:
	beqz	$s6, WHILE_IDLE # neu truoc day chua nhap input thi s6 = 0
	li	$a3, 0x00000000 # neu s6 = 1, thi xoa circle o vi tri cu
	jal 	drawBall
	
	WHILE_IDLE:
	
	# check if the ball hit the wall or not
	bgt	$a0, $a2, hitCeil	# if the ball does not hit the left wall, then check up wall
	move	$t3, $zero # y-velocity = 0
	add	$t2, $zero, $s5 # x-velocity = $t5
	j 	final
	
	hitCeil:
	bgt	$a1, $a2, hitRight # if the ball does not hit upper wall
	move	$t2, $zero # x-velocity = 0
	add	$t3, $zero, $s5 # y-velocity = $t5
	j 	final
	
	hitRight:
	sub	$t4, $s1, $a2 # frameWidth - radius
	blt	$a0, $t4, hitFloor # if the ball does not hit right wall
	move	$t3, $zero # y-velocity = 0
	sub	$t2, $zero, $s5 # x-velocity = -$t5
	j 	final
	
	hitFloor:
	sub 	$t4, $s2, $a2 # frameHeight - radius
	blt	$a1, $t4, final # if the ball does not hit bottom wall
	move	$t2, $zero # x-velocity = 0
	sub	$t3, $zero, $s5 # y-velocity = -$t5
	j 	final
	
	final:
	add	$a0, $a0, $t2 # if no character input, then use previous location + velocity
	add	$a1, $a1, $t3
	li	$a3, 0x00ffff00 # draw yellow ball
	jal	drawBall
	j	DO_WHILE

#################################################################
#	DRAW BALL PROCEDURE
#################################################################
#Input:
# $s0: base of the frame
# $a0: original x center
# $a1: original y center
# $a2: circle radius
# $a3: color of the ball
#
#// Implementing Mid-Point Circle Drawing Algorithm
# drawBall(int x_centre, int y_centre, int r)
#{
#   int x = r, y = 0;
#      
#    // Printing the initial point on the axes 
#    // after translation
#    drawPixel(x + x_centre, y + y_centre);
#      
#    // When radius is zero only a single
#    // point will be printed
#   if (r > 0)
#    {
#        drawPixel( x + x_centre, -y + y_centre);
#        drawPixel( y + x_centre, x + y_centre);
#        drawPixel(-y + x_centre, x + y_centre);
#    }
#      
#    // Initialising the value of P
#   int P = 1 - r;
#    while (x > y)
#    { 
#        y++;
#          
#        // Mid-point is inside or on the perimeter
#        if (P <= 0)
#            P = P + 2*y + 1;
#              
#        // Mid-point is outside the perimeter
#        else
#        {
#            x--;
#            P = P + 2*y - 2*x + 1;
#        }
#          
#        // All the perimeter points have already been printed
#        if (x < y)
#            break;
#          
#        // Printing the generated point and its reflection
#        // in the other octants after translation
#        drawPixel( x + x_centre, y + y_centre );
#        drawPixel( -x + x_centre, y + y_centre );
#        drawPixel( x + x_centre, -y + y_centre );
#        drawPixel( -x + x_centre, -y + y_centre );
#          
#        // If the generated point is on the line x = y then 
#        // the perimeter points have already been printed
#        if (x != y)
#        {
#            drawPixel(, y + x_centre, x + y_centre );
#            drawPixel(, -y + x_centre, x + y_centre );
#            drawPixel( y + x_centre, -x + y_centre );
#            drawPixel( -y + x_centre, -x + y_centre );
#        }
#    } 
#}

drawBall:	# draw circle
	addi	$sp, $sp, -4
	sw	$ra, 0($sp) # store return address
	
	add 	$t0, $a2, $zero # initialize: x = r
	add	$t1, $zero, $zero # initialize: y = 0
	
	move	$t6, $t0 # temporary x
	move	$t7, $t1 # temporary y
	
	jal	storeCoordinate
	add	$t0, $t6, $a0 # x = x + centre(x)
	add	$t1, $t7, $a1 # y = y + centre(y)
	jal	drawPixel
	
	blez	$a2, NegativeRadius #if radius is negative or equal to zero, print only one point
	
	add	$t0, $t6, $a0 # x = x + centre(x)
	sub	$t1, $a1, $t7 # y = -y + centre(y)
	jal	drawPixel
	
	add	$t0, $t7, $a0 # x = temp(y) + centre(x)
	add	$t1, $t6, $a1 # y = temp(x) + centre(y)
	jal	drawPixel

	sub	$t0, $a0, $t7 # x = -temp(y) + centre(x)
	add	$t1, $t6, $a1 # y = temp(x) + centre(y)
	jal	drawPixel
	jal	restoreCoordinate

	NegativeRadius:
	addi 	$s3, $zero, 1 # P = 1
	sub 	$s3, $s3, $a2 #P = P - r = 1 - r
	
	WHILE_LOOP:
	ble	$t0, $t1, end_while # if x <= y then break out while loop
	addi	$t1, $t1, 1 # y++
	
	bgtz	$s3, positiveP #If Mid-point is outside the perimeter
	#Otherwise. Mid-point is inside the perimeter
	# calculate P = P + 2*y + 1
	addi 	$s3, $s3, 1
	add	$s3, $s3, $t1
	add	$s3, $s3, $t1 # P = P + 2*y + 1
	j	end_if
	
	positiveP:
	addi	$t0, $t0, -1 # x--
	# calculate P = P + 2*y - 2*x + 1
	addi 	$s3, $s3, 1
	add	$s3, $s3, $t1
	add	$s3, $s3, $t1 # P = P + 2*y + 1
	sub	$s3, $s3, $t0
	sub	$s3, $s3, $t0 # P = P + 2*y - 2*x + 1
	
	end_if:
	blt	$t0, $t1, end_while # if x < y then break out while loop
	
	move	$t6, $t0 # update x
	move	$t7, $t1 # update y
	
	jal	storeCoordinate
	add	$t0, $t6, $a0 # x = x + centre(x)
	add	$t1, $t7, $a1 # y = x + centre(y)
	jal	drawPixel
	
	sub	$t0, $a0, $t6 # x = -x + centre(x)
	add	$t1, $t7, $a1#x = x + centre(y)
	jal	drawPixel
	
	add	$t0, $t6, $a0 # x = x + centre(x)
	sub	$t1, $a1, $t7# y = -y + centre(y)
	jal	drawPixel

	sub	$t0, $a0, $t6 # x = -x + centre(x)
	sub	$t1, $a1, $t7 # y = -y + centre(y)
	jal	drawPixel
	jal	restoreCoordinate
	# If the generated point is on the line x = y then 
	# the perimeter points have already been printed
	beq	$t0, $t1, end_while # if x == y then go to end_while
	
	jal	storeCoordinate
	add	$t0, $t7, $a0 # x = y + centre(x)
	add	$t1, $t6, $a1 # y = x + centre(y)
	jal	drawPixel
	
	sub	$t0, $a0, $t7 # x = -y + centre(x)
	add	$t1, $t6, $a1 # y = x + centre(y)
	jal	drawPixel
	
	add	$t0, $t7, $a0 # x = y + centre(x)
	sub	$t1, $a1, $t6 # y = -x + centre(y)
	jal	drawPixel

	sub	$t0, $a0, $t7 # x = -y + centre(x)
	sub	$t1, $a1, $t6 # y = -x + centre(y)
	jal	drawPixel
	jal	restoreCoordinate
	
	j WHILE_LOOP
	
	end_while:
	lw 	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr 	$ra
#procedure to store the value of x and y of the center circle to use it later
storeCoordinate:
	addi 	$sp, $sp, -8 #Expanding the space for saving in the stack
	sw 	$t0, 4($sp) #Save the value $t0 to the stack
	sw	$t1, 0($sp) #Save the value $t1 to the stack 
	jr	$ra
restoreCoordinate:
	lw	$t1, 0($sp) # Load the value to the register $t1
	lw 	$t0, 4($sp) # Load the value to the register $t0
	addi 	$sp, $sp, 8 # Shrink the space of stack 
	jr	$ra
#################################################################
# 		DRAW PIXEL PROCEDURE
################################################################# 
# Input: 
# $t0: the value of x-coordinate
# $t1: the value of y-coordinate
# $a3: the color to be filled
# Output:
# Print the color to the screen according to the location in the memory which
# has been calculated
#
drawPixel:	# convert (x,y) to memory location and store color at that location
		# location = (y-1) * width + (x-1)
	mul 	$t5, $t1, $s1		# y * frameWidth
	sub 	$t5, $t5, $s1		# (y-1) * frameWidth
	add	$t5, $t5, $t0		# (y-1) * frameWidth + x
	subi	$t5, $t5, 1		# location = (y-1) * frameWidth + (x - 1)
	sll	$t5, $t5, 2		# 4 * location
	sw	$a3, frame($t5)	# store color in located pixel
	jr 	$ra

