########################################
Refresh ECB Diamond Function [DukeItOut]
#
# Used by codes below to update only the
# current diamond instead of both it
# and the previous!
#
# Used by several physics fixes in this
# file!
########################################
HOOK @ $80132B9C
{
	stfs f0, 0x38(r3)
	blr					# Make room for below custom function
}
# Mode 0 - Update ECBs Only
# Mode 1 - Update Models Only
# Mode 2 - Update Both!
# Mode 3 - Update Corrections and state, too!
HOOK @ $80132BA0
{
	stwu r1, -0x70(r1)
	stw r31, 0x08(r1)
	stw r30, 0x0C(r1)
	stw r4, 0x10(r1)
	mflr r0
	stw r0, 0x74(r1)
	mr r31, r3	
	lwz r3, 0x70(r31)
	lwz r3, 0x20(r3)
	lwz r3, 0x0C(r3)
	lwz r3, 0x2D0(r3)
	lwz r0, 0x10(r3)	# Frames airborne
	stw r0, 0x14(r1)
	lwz r0, 0x14(r3)	# Frames grounded
	stw r0, 0x18(r1)
	stw r3, 0x1C(r1)
	cmpwi r4, 0
	beq noModelUpdate	# If we set it to non-zero, we want to update the 
modelUpdate:
	lwz r3, 8(r31)
	lwz r12, 0x40(r3)
	lwz r12, 0x30(r12)
	li r4, 0	# 1 = update movement, but we don't want this!
	mtctr r12
	bctrl 		# Update Posture
	lwz r3, 8(r31)
	lwz r12, 0x40(r3)
	lwz r12, 0x74(r12)
	mtctr r12
	bctrl		# Update Rough Pos
	lwz r3, 8(r31)
	lwz r12, 0x40(r3)
	lwz r12, 0x50(r12)
	mtctr r12
	bctrl		# Update Node SRT	
noModelUpdate:	
	lwz r4, 0x10(r1)	
	cmpwi r4, 1; beq- modelsOnly
	lwz r30, 0x1C(r31)
	lwz r30, 0x28(r30)
	lwz r30, 0x10(r30)
	lwz r4, 0x5C(r30)	# Prev Diamond
	addi r3, r1, 0x20	# Scratch
	lwz r12, 0(r4)
	lwz r12, 0x40(r12)
	mtctr r12
	bctrl				# Copy ECB (Set)
	
	li r4, 0
	lwz r3, 0x1C(r31)
	lwz r12, 8(r3)
	lwz r12, 0x34(r12)
	mtctr r12
	bctrl				# update collisions (this also updates the diamond for the prev frame)

	mr r3, r30
	lbz r4, 0x73(r30)	# \
	andi. r4, r4, 0xFB	# | force collision test to update
	stb r4, 0x73(r30)	# /
	bla 0x134CA0		# test collision

	lwz r4, 0x10(r1)
	cmpwi r4, 3
	bne noProcess
	
	lwz r3, 0x8(r31)
	lwz r12, 0x3C(r3)
	lwz r12, 0x18(r12)
	mtctr r12
	bctrl					# processPreMapCorrection
	lwz r3, 0x8(r31)
	lwz r12, 0x3C(r3)
	lwz r12, 0x1C(r12)
	mtctr r12
	bctrl					# processMapCorrection

	stwu r1, -0xC0(r1)		#
	stmw r3, 0x10(r1)		#
	lwz r3, -0x4490(r13)	# area manager
	bla 0x012660			# brute force fixing position of ALL areas
	lmw r3, 0x10(r1)		#
	addi r1, r1, 0xC0		# This was needed to allow item grabbing on frames going through this function!


noProcess:
	lwz r3, 0x5C(r30)	# Prev Diamond that we are going to restore
	addi r4, r1, 0x20
	lwz r12, 0(r3)
	lwz r12, 0x40(r12)
	mtctr r12
	bctrl				# Copy ECB back!
modelsOnly:
	lwz r3, 0x1C(r1)
	lwz r0, 0x14(r1)
	stw r0, 0x10(r3)	# Frames airborne
	lwz r0, 0x18(r1)
	stw r0, 0x14(r3)	# Frames Grounded
	lwz r31, 0x08(r1)
	lwz r30, 0x0C(r1)
	lwz r0, 0x74(r1)
	mtlr r0
	addi r1, r1, 0x70 
	blr
}

##########################################
Momentum Shifts Revert Physics [DukeItOut]
##########################################
# Adjusts the following scenarios:
#	-Altering speeds within the PSA
#	-Altering speeds when landing
#	-Hard-coded character momentum shifts
#	-Unusual Double Jumps
#	-Double Jump Cancels
#
# DJC is activated using RA-Bit 33 on
# relevant jumps!! Don't set speed inside
# .pac files anymore in the DJC script!
##########################################
HOOK @ $8089D314		# Adjust double jumps entering an aerial attack to address an off-by-one issue
{
	lfs f1, 0x18(r13)	# 1.0
	fsubs f1, f27, f1	# Subtract 1 frame. # Original operation: fmr f1, f27 (animation frame of double jump)
}

HOOK @ $8089D450		# Used by double jumps to properly double jump cancel
{
	cmpwi r3, 0			# Original operation
	bne- %END% 			# Check if mid-air jump animation has ended
	lwz r3, 0x88(r31)	# Secondary subaction ID
	cmpwi r3, -1		# Check if invalid (secondary animation already disabled)
	beq- %END%
	lwz r4, 0x70(r30)	# \
	lwz r4, 0x24(r4)	# |
	lwz r4, 0x1C(r4)	# | RA-Bit 32-63
	lwz r4, 0x4(r4)		# /
	andi. r4, r4, 2		# Is RA-Bit 33 Set? If so, cancel mid-air jump animation!
	beq+ %END%
	
	lwz r4, 0x08(r30)	# \
	lwz r4, 0x110(r4)	# / Instance ID
	cmpwi r4, 0xA		# Is it Ness?
	beq+ forceDJC		# His horizontally-oriented jump, unlike the others, happens to feel better the way it was!
	
	stwu r1, -0xA0(r1)
	stw r29, 8(r1)
	
	# Based on getTransNTranslate r31->0x114 (80722B84)
	
	lfs f1, 0x70(r31)	# Current animation frame of jump anim
	stfs f1, 0xC(r1)	# Preserve it!
	
	lfs f2, 0x7C(r31)	# Mid-air jump animation rate
	fsubs f1, f1, f2	# We want to virtually backtrack one in-game frame to see the offset difference!
	lwz r3, 0x6C(r31)
	lwz r12, 0(r3)
	lwz r12, 0x1C(r12)	
	mtctr r12
	bctrl 				# Set the animation frame!
	
	lwz r3, 0x168(r31)
	lwz r3, 0xD8(r3)
	lwz r29, 4(r3)
	lwz r12, 8(r29)
	mr r3, r29 
	lwz r12, 0xC8(r12)
	mtctr r12
	bctrl			# Get the node ID for TransN
	lwz r12, 8(r29)
	mr r4, r3
	mr r3, r29
	lwz r12, 0x90(r12)
	mtctr r12
	bctrl			# Convert node ID (-1 if invalid)
	
	mr r5, r3
	stw r5, 0x10(r1)
	lwz r3, 0x6C(r31) # Secondary animation
	addi r4, r1, 0x30	# Where to write to (assume a size of around 0x58?)
	lwz r12, 0(r3)
	lwz r12, 0x38(r12)
	mtctr r12
	bctrl				# Calculate
	addi r3, r1, 0x30	# Calculated key info
	addi r4, r1, 0x20	# Where to place translation data
	bla 0x19589C		# Get translation data

	lfs f1, 0xC(r1)		# Restore animation frame!
	lwz r3, 0x6C(r31)
	lwz r12, 0(r3)
	lwz r12, 0x1C(r12)	
	mtctr r12
	bctrl 				# Set the animation frame!
	
	lwz r5, 0x10(r1)	# Calculate again, but for this frame instead of previous!
	addi r4, r1, 0x30
	lwz r3, 0x6C(r31)
	lwz r12, 0(r3)
	lwz r12, 0x38(r12)
	mtctr r12
	bctrl
	addi r3, r1, 0x30
	addi r4, r1, 0x14	# Different spot than above
	bla 0x19589C		# Get translation data
	
	
	lwz r3, 0x168(r31)
	lwz r4, 0xD8(r3)
	lwz r3, 4(r4)
	lwz r12, 0x8(r3)
	lwz r12, 0xE0(r12)
	mtctr r12
	bctrl				# Get model scale (typically 1.0)
	fmr f3, f1			
	lwz r3, 0xC(r4)
	lwz r12, 0(r3)
	lwz r12, 0x60(r12)
	mtctr r12	
	bctrl				# Get item status scale (mushrooms/lightning/special modes)
	fmr f4, f1			
	
	psq_l f1, 0x20(r1), 0, 0 # X and Y pos calculated for TransN node's prev frame
	psq_l f2, 0x14(r1), 0, 0 # X and Y pos calculated for this frame
	ps_sub f1, f2, f1
	
	ps_muls0 f1, f1, f3	# Animation Offset Diff * Model Scale
	ps_muls0 f1, f1, f4	# *= Item Status Scale
	
	lwz r4, 0x88(r30)
	lwz r4, 0x14(r4)
	lwz r3, 0x28(r4)
	psq_l f2, 0x08(r3), 0, 0 # Current XY Gravity (negative for downward, unlike in attributes)
	
	ps_add f1, f1, f2	# += Gravity
	
	lwz r3, 0x1C(r4)
	psq_st f1, 0x8(r3), 0, 0	# Set XY force speed
	
	lwz r29, 8(r1)
	addi r1, r1, 0xA0	
forceDJC:
	crclr 2				# cleared eq register = ne
}

HOOK @ $80792F24        # When done inside of a PSA script
{						# Command 0E020100 set to a parameter value of 1 triggers.
						# "Prevent Vertical Movement"
	stw r3, 0x18(r1)	# Preserve this!
	lwz r12, 0x08(r31)
	lwz r12, 0x3C(r12)
	lwz r12, 0xA4(r12)
	mtctr r12
	bctrl				# Get object type
	cmpwi r3, 0
	bne- normal
	
	lwz r3, 0x7C(r31)
	lhz r3, 0x3A(r3)
	cmpwi r3, 0x73		# Grabbing a ledge
	beq- normal			# Don't accidentally mess up cliff detection!
	
	lwz r3, 0x1C(r31)	# \
	lwz r3, 0x28(r3)	# | Get collision info
	lwz r3, 0x10(r3)	# /
	lbz r3, 0x75(r3)	# Collision contact status
	andi. r0, r3, 0x80	# Touching floor?
	bne+ normal
	
	
    lwz r12, 0x18(r31)    
    lfs f0, 0x1C(r12)     # Prev Y pos
    stfs f0, 0x10(r12)    # Current Y pos
	
	mr r3, r31
	li r4, 2
	bla 0x132BA0	# Update model and collisions!
normal:
	lwz r3, 0x18(r1)	# Restore!
    lwz r12, 0x0(r3)    # Original operation
}

##############################
Rising Aerial Fix [DukeItOut]
##############################
# Fixes bug where double jumps
# stay in place for a frame
##############################
HOOK @ $8089D368		
{
	lwz r12, 0x88(r27)
	lwz r12, 0x58(r12)
	lfs f1, 0xC(r12)	# Y speed
	stfs f1, 0xC(r1)	# Store to scratch
	bctrl				# Original operation. Normally clears Y speed as a side effect.
	lwz r12, 0x88(r27)
	lwz r12, 0x14(r12)
	lwz r12, 0x1C(r12)
	lfs f1, 0xC(r1)
	stfs f1, 0xC(r12)	# Restore the Y force speed
	lwz r12, 0x18(r27)
	lfs f2, 0x10(r12)	# Current Y position
	fadds f2, f2, f1	# Add force speed for this frame
	stfs f2, 0x10(r12)	# Update the position!
}

#########################################
Ledge Release Applies Gravity [DukeItOut]
#########################################
HOOK @ $80867AE4
{
	# uses cr1 instead of cr0 due to comparison before hook!
	lwz r3, 0x7C(r29)
	lhz r5, 0x06(r3)	# Previous action
	cmpwi cr1, r5, 0x75	# was it hanging from a ledge?
	bne+ cr1, normal
	lhz r5, 0x3A(r3)	# Current action
	cmpwi cr1, r5, 0x49		# is it tumbling from holding ledge?
	beq- cr1, addGravity
	cmpwi cr1, r5, 0xE		# is it falling?
	bne+ cr1, normal
addGravity:
	lfs f0, 0x10(r31)	# Gravity to apply
	lwz r3, 0x18(r29)	# \
	lfs f2, 0x10(r3)	# | Apply gravity to Y position!
	fadds f2, f2, f0	# |
	stfs f2, 0x10(r3)	# /
normal:
	stfs f0, 0xC(r31)	# Set Y speed. Original operaton
}

HOOK @ $80867F5C
{
	lwz r3, 0x7C(r30)
	lhz r4, 0x3A(r3)	# Current action
	cmpwi r4, 0xE; bne+ normal
	lhz r4, 0x06(r3)
	cmpwi r4, 0x75; beq- normalFall_check
	cmpwi r4, 0x0B; blt- normalFall_check # Common grounded actions
	cmpwi r4, 0x11; blt- normal			  # Jumping/Falling
	cmpwi r4, 0x1D; bgt+ normal			  # Most things
normalFall_check: # Don't FF first frame falling airborne from the ledge
	lwz r3, 0x70(r30) #
	lwz r4, 0x24(r3) # RA
	lwz r3, 0x0C(r4) # Basic
	lwz r3, 0x28(r3) # 10 (Customized to increment every frame while falling)
	cmpwi r3, 1
	bge+ normal		# The first frame of falling normally won't allow this
						# Done on purpose to match Melee and prevent ledge drops from instantly fastfalling when pressing downwards!
	lwz r3, 0x1C(r4) # Bit
	lbz r5, 0x03(r3)
	andi. r5, r5, 0xFB # Clear the FF bit!
	stb r5, 0x03(r3)
	lis r12, 0x8086
	ori r12, r12, 0x7F84
	mtctr r12
	bctr				# Don't FF!
	
normal:
	mr r3, r30			# Original operation
}

HOOK @ $80871DF0		# Falling. We want a counter for how long we've been in this state!
{
	lwz r3, 0x64(r3)	# Original operation
	lwz r5, 0x24(r3)	# \ RA
	lwz r5, 0x0C(r5)	# | Basic
	lwz r6, 0x28(r5)	# / 10
	addi r6, r6, 1		# Increment every frame!
	stw r6, 0x28(r5)	#
}

HOOK @ $80868034		# Workaround for Brawl not expecting gravity to apply frame 1
{
	lwz r4, 0x7C(r30)
	lhz r3, 0x3A(r4)	# Current Action
	lhz r4, 0x06(r4)	# Previous Action
	cmpwi r3, 0xE;  bne+ normal	# Falling    \ We're only modifying the frame of ledge release!
	cmpwi r4, 0x75; bne+ normal # Ledge Hold /
	
	lwz r3, 0x70(r30)	# \
	lwz r3, 0x24(r3)	# | RA
	lwz r3, 0x0C(r3)	# | Basic
	lwz r3, 0x28(r3)	# / 10
	cmpwi r3, 1			# 
	blt- %END%			# We already applied gravity on the first frame
						# of falling from holding a ledge elsewhere!
normal:
	fadds f0, f0, f30 	# Apply gravity! Original operation
}

####################################################################
Air Dodges Calculate One Frame Earlier [DukeItOut, Fudgepop01, Eon]
####################################################################
#
# Ported from physics.rel to somewhere more consistent but harder
# to write as C++. Is dependent on Eon's air dodge codes to know
# about movement speed from a directional air dodge.
#
# Now is capable of landing even when not performed perfectly and
# no longer has characters clip into the ground for one frame.
#
# In addition, air dodges now move on the first frame.
#
# V2: Made the aerial item grab box fake interpolation to counter
#	that this code change reduces the range
# V2.1: Different initial frame raytrace math tested for consistency
# V2.2: Altered based on airtime to better improve feel
# V2.3: Uses ledge intangibiliity counter instead of airborne frames
# V2.4: Disabled Alloys doing this due to related crash
# V2.5: Altered feel again to not be dependent on either.
# V2.6: Further stability adjustments.
# V2.7: Addressed oversight that could prevent landing being detected.
######################################################################
op b 0x70 @ $80884F68	# \
op b 0x64 @ $80884F74	# |
op b 0x40 @ $80884F98	# |
HOOK @ $80884FD8		# / Air Dodges
{
	lwz r5, 0x8(r30)
	lwz r5, 0x110(r5)	# Character ID
	cmpwi r5, 0x32; blt+ RealChar
	cmpwi r5, 0x35; bgt+ RealChar
Alloy:
	ba 0x885024	# Finish behavior
RealChar:
	#### Rayscan to fix glitch where the below will clip through stage corners. Very annoying!
	stwu r1, -0x80(r1)
	
	lwz r5, 0x88(r30)	# speed
	lwz r4, 0x4C(r5)
	psq_l f1, 0x8(r4), 0, 0	# XY speed of air dodge
	psq_st f1, 0x8(r1), 0, 0

	lfs f0, 0x10(r13)	# 0.0
	stfs f0, 0x8(r1)	# 0 X Speed for Ray Scan
	lfs f1, 0x8(r4)		# X Speed
	lfs f2, 0xC(r4)		# Y Speed
	stfs f2, 0xC(r1) 	# Y Speed still normally used!	
	
	lwz r3, 0x1C(r30)
	lwz r3, 0x28(r3)
	lwz r3, 0x10(r3)
	lwz r4, 0x60(r3)	# Current Diamond
	lfs f4, 0x14(r4)	#	Diamond Bottom X
	fadds f4, f1, f4	
	stfs f4, 0x20(r1)	# Test 3
	lfs f4, 0x18(r4)	#	Diamond Bottom Y
	stfs f4, 0x24(r1)	# Test 3
	lwz r3, 0x5C(r3)	# Prev Diamond
	lfs f3, 0x14(r3)	# 	Diamond Bottom X
	stfs f3, 0x18(r1)	# Test 2
	fadds f3, f1, f3
	stfs f3, 0x10(r1)	# Test 1
	lfs f3, 0x18(r3) 	#	Diamond Bottom Y
	stfs f3, 0x1C(r1)  	# Test 2
	stfs f3, 0x14(r1)	# Test 1

	## Test True Collision	##
	addi r3, r1, 0x10	# Test 1
	addi r4, r1, 0x8	# X = 0, Y Speed for rayscan
	addi r5, r1, 0x30	# Collision Intersection Point (if any)
	addi r6, r1, 0x3C	# Collision Normal Vector
	li r7, 1			# 1 = Check Soft Platforms
	li r8, 0
	li r9, 0
	li r10, 1			# 1 = Test for Platforms at all
	bla 0x9326d8		# Test for Collision!
	cmpwi r3, 0
	bne- contactFound
	addi r3, r1, 0x18	# Test 2
	addi r4, r1, 0x8	# XY speed
	addi r5, r1, 0x30	# Collision Intersection Point (if any)
	addi r6, r1, 0x3C	# Collision Normal Vector
	li r7, 1			# 1 = Check Soft Platforms
	li r8, 0
	li r9, 0
	li r10, 1			# 1 = Test for Platforms at all
	bla 0x9326d8		# Test for Collision!
	cmpwi r3, 0
	bne- contactFound
	addi r3, r1, 0x20	# Test 3
	addi r4, r1, 0x8	# XY speed
	addi r5, r1, 0x30	# Collision Intersection Point (if any)
	addi r6, r1, 0x3C	# Collision Normal Vector
	li r7, 1			# 1 = Check Soft Platforms
	li r8, 0
	li r9, 0
	li r10, 1			# 1 = Test for Platforms at all
	bla 0x9326d8		# Test for Collision!
	cmpwi r3, 0
	beq+ noContact	
contactFound:
	lwz r3, 0x18(r30)	# Position info
	psq_l f1, 0x30(r1), 0, 0	# Collision Point
	psq_st f1, 0x0C(r3), 0, 0	# XY
	lwz r3, 0x70(r30)
	lwz r3, 0x20(r3)
	lwz r3, 0x0C(r3)
	lwz r3, 0x2D0(r3)
	li r4, 0			# Clear frames airborne!
	stw r4, 0x10(r3)	# Frames airborne (I am forcing the collision diamond to match the position)
	stw r4, 0x14(r3)	# Frames grounded

	lwz r3, 0x1C(r30)
	lwz r3, 0x28(r3)
	lwz r3, 0x10(r3)
	bla 0x134CA0		# collision test (see 80112BE4)
	addi r1, r1, 0x80
	lwz r5, 0x88(r30)	# speed
	lfs f2, 0x10(r13)	# 0.0
	b setPosition
noContact:
	addi r1, r1, 0x80
	####
	lwz r5, 0x88(r30)	# speed
	lwz r4, 0x4C(r5)
	psq_l f2, 0x08(r4), 0, 0	# XY speed of air dodge
	lwz r3, 0x18(r30)
	psq_l f1, 0x18(r3), 0, 0	# Prev XY position
	ps_add f1, f1, f2
	psq_st f1, 0x0C(r3), 0, 0
setPosition:
	lfs f1, 0x10(r13)	# 0.0
	lwz r4, 0x58(r5)
	psq_st f1, 0x08(r4), 0, 0	# Clear normal speed!
	
	
	### Part for item logic ###
	# Premise: to fake interpolation, expand by air dodge speed and move forward by half, but only do these for negative relative speeds!
	
	lwz r4, 0x18(r30)			# \ Character direction in paired single 0, 1.0 in single 1
	psq_l f1, 0x40(r4), 1, 0	# /
	ps_mul f1, f1, f2	# Relative XY speed
	lfs f3, 0x10(r13)	# 0.0
	ps_sel f4, f1, f3, f1	# if X or Y is negative, use that relative XY speed, otherwise use 0 to not change it!
							# Logic: if relatively not negative, be 0.0, if relatively negative, use the non-relative speed
							# In one operation, I am capping the minimum size the box can be modified into by the below!

	lwz r3, 8(r30)		# \
	lwz r3, 0x60(r3)	# | Area logic
	lwz r3, 0x9C(r3)	# |
	lwz r3, 0x30(r3)	# /
	li r4, 7			# 6 = Grounded, 7 = Aerial
	lwz r12, 0(r3)
	lwz r12, 0xC(r12)
	mtctr r12
	bctrl				# get area	

	lfs f3, 0x14(r13)	# 0.5
	ps_mul f1, f4, f3	# We want the X offset to be moved by half of the speed to fake interpolation!
	
	psq_l f0, 0xC(r3), 0, 0	# X&Y offsets of item grab box
	ps_sub f0, f0, f1	# Subtract half of the backwards speed
	psq_st f0, 0xC(r3), 0, 0
	
	psq_l f0, 0x14(r3), 0, 0 # W&H of item grab box
	ps_sub f0, f0, f4	# Subtract the backwards speed
	psq_st f0, 0x14(r3), 0, 0	
	###
noItemInterpolation:
	mr r3, r30
	li r4, 3
	bla 0x132BA0	# Custom function to update collisions! See top of file!

	mr r4, r30				# \
	mr r3, r31				# |
	lwz r0, 0x14(r1)		# |
	lwz r31, 0x0C(r1)		# | Restore register info
	lwz r30, 0x08(r1)		# |
	mtlr r0					# |
	addi r1, r1, 0x10		# /
	lis r12, 0x8088
	ori r12, r12, 0x503C
	mtctr r12
	bctr				# Force air dodge execStatus to calculate next air dodge frame.
}

HOOK @ $80885040 # Reset air item grab box to normal when leaving the air dodge state.
{
	stwu r1, -0x20(r1)
	mflr r0
	stw r0, 0x24(r1)
	stw r31, 0x8(r1)
	stw r30, 0xC(r1)
	stw r29, 0x10(r1)
	
	lwz r31, 8(r4)
	lwz r3, 0x110(r31)	# Character ID
	cmpwi r3, 0x32; blt+ normalFighter  # Alloys can't tolerate item search changes, they have less detection boxes than normal fighters!
	cmpwi r3, 0x35; ble- finish			#
normalFighter:	
	lwz r30, 0x60(r31)
	lwz r30, 0x9C(r30)
	
	lwz r3, 0x60(r31)
	lwz r3, 0x7C(r3)
	lhz r3, 0x6(r3)		# Previous action
	cmpwi r3, 0x21		# Was it an air dodge we're leaving?
	bne+ finish			# Then do nothing if it wasn't!	
	
	lwz r3, 0x30(r30)	# info for areas
	li r4, 7			# 6 = Grounded, 7 = Aerial
	lwz r12, 0(r3)
	lwz r12, 0xC(r12)
	mtctr r12
	bctrl				# get area
	mr r31, r3			# We'll need this again!
	lwz r29, 0x4(r31)				# \
	lbz r29, 0x1C(r29)				# / (See 807B1FE4). Relates to enabled statuses
	rlwinm. r29, r29, 25, 31, 31	# If 0x80 was set, make r29 1 for enabled!
	lwz r4, 0x48(r30)
	bla 0x7B1694		# reset area	
	mr r3, r31
	mr r4, r29			# The enabled status
	bla 0x7B1FE4		# Enable/Disable
finish:	
	lwz r29, 0x10(r1)
	lwz r30, 0xC(r1)
	lwz r31, 0x8(r1)
	lwz r0, 0x24(r1)
	mtlr r0
	addi r1, r1, 0x20
	blr
}

###################################
Landing Fix [Fudgepop01, DukeItOut]
###################################
# Fixes an issue where a character
# that is entering a falling state
# won't check that first frame if
# they are trying to land.
###################################
HOOK @ $8077F21C
{
	lwz r3, 0x8(r31)
	lwz r3, 0x3C(r3)
	lwz r3, 0xA4(r3)
	mtctr r3
	bctrl
	cmpwi r3, 0
	bne normal				# Only do the following to a fighter!
	lwz r3, 0x7C(r31)
	lhz r4, 0x3A(r3)	# Action to change to 
	lhz r3, 0x06(r3)	# Action to change from
	cmpwi r3, 0xE7; blt+ notGanonChoke # \ Don't do anything to victims of Ganon's side special!
	cmpwi r3, 0xEA; ble- normal		   # /
notGanonChoke:
	cmpwi r4, 0xE; blt+ normal	# Falling while having jumps left
	cmpwi r4, 0x10; ble- fall	# Falling after using all mid-air jumps or into freefall after a recovery
	cmpwi r4, 0x49; bne+ normal # Falling while damaged
fall:
	lwz r3, 0x1C(r31)
	lwz r4, 0x28(r3)
	lwz r4, 0x10(r4)
	lbz r4, 0x08(r4)
	cmpwi r4, 1; bne+ normal	# 1 = grounded
	# r3 is the above
	# r4 happens to need to be 1 so don't need to set that in this specific context
	li r5, 0			
	lwz r12, 8(r3)
	lwz r12, 0x54(r12)
	mtctr r12
	bctrl				# correct position

	li r29, 0x18		# PreMap
	lwz r28, 0x8(r31)
processLoop:	
	mr r3, r28
	lwz r12, 0x3C(r28)
	lwzx r12, r12, r29
	mtctr r12
	bctrl
	addi r29, r29, 4	# PreMap, Map, FixPosition
	cmpwi r29, 0x20
	ble+ processLoop
normal:
	li r3, 1			# Original operaton
}

#############################################
Jumps Calculate One Frame Earlier [DukeItOut]
#############################################
#
# Fakes out the physics delay by calculating
# gravity, jump speed and position in advance
#
# Also makes jumping out of water easier
# by increasing jump height in that context
#
# V1.1: No longer affects footstools
#############################################
HOOK @ $8086BD34	# Grounded or Swimming
{
    lwz r29, 0xD0(r30)   # \ Retrieve the gravity for the character
    lfs f31, 0x70(r29)   # /
	
	lwz r29, 0x7C(r30)	 # \ Get previous action
	lhz r29, 0x06(r29)	 # /
	cmpwi r29, 0x6D		 # Check if footstooling
	beq- normal			 # Avoid messing with footstool heights!
	
	lfs f0, 0x24(r1)	 # Desired movement Y speed. Some branches don't have this set.

	cmpwi r29, 0xBA		 # Check if we are trying to leap out of water

    lwz r29, 0x18(r30)   # \
    lfs f1, 0x1C(r29)    # | Simulate one frame of vertical movement
    fadds f1, f0, f1     # |
	bne+ notSwimming	 # |
	fadds f1, f0, f1	 # | We want to make it easier to get out of the water, so let's boost it a bit!
notSwimming:			 # |
	fsubs f1, f1, f31	 # |
    stfs f1, 0x10(r29)   # / 
    fsubs f1, f0, f31    # \ Jump/Hop "Velocity" now calculates as if it is the second frame, because . . . .
    stfs f1, 0x24(r1) 	# /
	
	mr r3, r30
	li r4, 2
	bla 0x132BA0		# Update model and collisions!
normal:
    lis r29, 0x80AE     # Original operation
}

HOOK @ $8086BE60	# Mid-Air Jump
{
    lwz r31, 0xD0(r30)   # \ Retrieve the gravity for the character
    lfs f31, 0x70(r31)   # / 

	lwz r31, 0x18(r30)   # \
    lfs f0, 0x1C(r31)    # | Simulate one frame of vertical movement
    fadds f0, f0, f1     # |
	fsubs f0, f0, f31	 # |
    stfs f0, 0x10(r31)   # /

    fsubs f1, f1, f31    # Jump/Hop "Velocity" now calculates as if it is the second frame
	stfs f1, 0x1C(r1)	 # Where f1 will be stored in a little while anyway
	
	mr r3, r30
	li r4, 2
	bla 0x132BA0		 # Update model and collisions!
	
	lfs f1, 0x1C(r1)	 # Restore
    lis r31, 0x80AE      # Original operation
}

HOOK @ $8086C28C	# Multi-Jump
{
    lwz r5, 0xD0(r31)   # \ Retrieve the gravity for the character
    lfs f31, 0x70(r5)   # / 
	
	lwz r5, 0x18(r31)   # \
    lfs f2, 0x1C(r5)    # | Simulate one frame of vertical movement
    fadds f2, f2, f1    # |
	fsubs f2, f2, f31	# |
    stfs f2, 0x10(r5)   # /
	
	fsubs f1, f1, f31	 # Jump/Hop "Velocity" now calculates as if it is the second frame
	li r3, 1			 # Original operation
}

HOOK @ $8086C2E8	# For unknown reasons, multi-jumps don't move the first frame
{					# This is an attempt to rectify that visually.
	mr r3, r31
	li r4, 2
	bla 0x132BA0	# Update model and collisions!
	psq_l f31, 0x58(r1), 0, 0	# Original operation
}

####################################
Shield Forward Angle Fix [DukeItOut]
####################################
# Fixes issue where precision
# overwhelmed the pose calculation
# and would break the animation
####################################
HOOK @ $80874BBC
{
    li r4, 6
    sth r4, 0x10(r1)
    psq_l f2, 0x10(r1), 1, 7 # 6 * 2^-8
    fmuls f2, f2, f2           # ~0.0005
    fabs f3, f1
    fcmpu cr0, f3, f2
    bge+ normal
    fadds f1, f1, f1        #
    fadds f1, f31, f1        # Double the movement to guarantee it does not have imprecision
    stfs f1, 0x70(r3)         # Set the frame for the tilt animation.
    lfs f1, 0(r30) # 0.0
normal:
    bctrl # Original Op. Set shield tilt animation speed (yes, speed, not frame)
}

#################################
Duo Sticky Object Fix [DukeItOut]
#################################
# Nana doesn't know to remove
# objects stuck to her when deactivated. This forces them to drop off.
#
# In Brawl, if a C4 is attached to Nana and Popo is KO'd, Nana will "respawn"
# with the C4 still! This is why this code was asked for.
#################################
HOOK @ $80837B3C
{
    bctrl        # Original operation. Set fighter to standby mode. (Used for duos and transforming characters.)
    # The below makes it so Nana gets rid of objects attached to her as she simply doesn't in Brawl.
    
    stwu r1, -0x20(r1)
    li r3, 2            # Based on KO logic. See 8083b670-to-80B3B6A4 as this is basically a copy of that.
    stw r3, 0x8(r1)
    li r0, 0
    stb r0, 0xC(r1)
    stw r31, 0x10(r1)    # r27 in KO logic. What is it? Typically 1.
    li r4, -1
    li r6, 0
    addi r5, r1, 0x8
    lwz r3, 0xD8(r29)
    lwz r3, 0x54(r3)
    lwz r12, 0(r3)
    lwz r12, 0x48(r12)
    mtctr r12
    bctrl            # Inform objects attached to no longer do so!
    addi r1, r1, 0x20
}

#########################################
Instant Fastfalls [Fudgepop01, DukeItOut]
#########################################
HOOK @ $8083A328
{
	lis r4, 0x2200		# \ RA-Bit 2
	ori r4, r4, 2		# /	
	lwz r3, 0xD8(r28)
	lwz r3, 0x64(r3)
	lwz r12, 0(r3)
	lwz r12, 0x4C(r12)	# Get Bit
	mtctr r12
	bctrl				# Check for if RA-Bit 2 is set. This is the fastfall flag!
	cmplwi r3, 1
	bne+ noFastfall

	lwz r5, 0xD8(r28)
	lwz r6, 0x70(r5)	#
	lhz r4, 0x3A(r6)	# Current action. Some "falling" actions still go through this when not expected to!
	cmpwi r4, 0x75; beq- noFastfall	# Grabbing a ledge
	
	mr r4, r28
	lwz r3, 0x7C(r5)	# Speed
	lwz r25, 0x58(r3)	# Gravity
	mr r3, r25
	lfs f31, 0x0C(r25)	# Y speed of gravity
	lwz r12, 0(r3)
	lwz r12, 0x0C(r12)
	mtctr r12
	bctrl				# Update the gravity if so!
	lfs f1, 0x0C(r25)	# Y speed of gravity
	fcmpu cr0, f1, f31
	beq+ noFastfall		# Only fix the position if this is the first fastfall frame!

	lwz r4, 0x18(r28)
	psq_l f2, 0x18(r4), 0, 0		# Prev XY
	psq_l f1, 0x08(r25), 0, 0		# Gravitational speed used as an offset
	ps_add f3, f2, f1
	psq_st f3, 0x0C(r4), 0, 0		# Replace Current XY

	mr r3, r28
	li r4, 3
	bla 0x132BA0			# Update model, collisions and state!
	lwz r3, 0x08(r28)
	lis r12, 0x8070			# \ Fix position 
	ori r12, r12, 0xFF50	# /	(done this way to avoid recursion)
	mtctr r12
	bctrl				# This is needed to change the animation this late into the frame.
noFastfall:
	lis r3, 0x80B8		# Original operation
	li r0, 5			# Restore value!?
}
op psq_st f0, 0x8(r3), 0, 0 @ $80867EF0 # Initialize both X and Y for gravity on spawn!

################################################################
Aerial/Onstage State 8 uses Momentum to Decide [DukeItOut]
################################################################
# Command 08000100 using value 8 in Brawl decides if it
# should leave the platform based on if having forward momentum
#
# Instead of that momentum being damage as the base game does,
# type 8 uses the type of momentum that wavedashes try to use.
################################################################
HOOK @ $8089DB48
{
    li r4, 4            # Original operation. Get damage knockback.
    lwz r5, 0x1C(r30)    # \
    lwz r5, 0x28(r5)    # | Air/Ground Ledge Slide State
    lbz r5, 0x44(r5)    # /
    cmpwi r5, 8; bne+ %END% # Behave normally for all but type 8!
    
    lwz r5, 0x28(r30)    # \ X Speed
    lfs f1, 0x40(r5)    # /
    lwz r5, 0x18(r30)    # \ X Direction
    lfs f2, 0x40(r5)    # /
    fmuls f1, f1, f2    # Relative X Speed!
    lfs f2, 0x10(r13)    # 0.0
    li r3, 1
    fcmpu cr0, f1, f2# Is the relative speed 0.0 or higher?
    blt+ 0x8
    li r3, 0            # Then still consider the ledge!
    
    ba 0x89DC14    # Restore stack and return!    
}

################################
Teeter Trigger Tweak [DukeItOut]
################################
# The game had a hard limit of 1.5 from a ledge to trigger teeter regardless of other prerequisites.
# This takes horizontal speed into account since wavedashing can exceed 1.5 but raising it too high
# broke standing animations.
HOOK @ $80782648
{
    lwz r5, 0x28(r28)    # \ X Speed
    lfs f2, 0x40(r5)    # /
    lwz r5, 0x18(r28)    # \ Direction
    lfs f1, 0x40(r5)    # /
    fmuls f2, f2, f1    # Get X relative speed
    
    lfs f1, 0x134(r31)    # Original operation. Gets 1.5, Brawl's limit for X speed distance to teeter.

    fcmpu cr0, f1, f2    # \
    bge+ 0x8            # | If relative X Speed is over 1.5, use that instead!
    fmr f1, f2            # /
}

###################################################################
!Windbox Stacking For Fighter Hitboxes [DukeItOut]
###################################################################
#
# Still not treated as standard knockback, but doesn't
# remove existing knockback in normal conditions.
#
# Treated as knockback stack avoidance in the first 12 frames
# of knockback an opponent is in with an extra 3 frames of leniency
# if the opponent is moving downwards.
#
# Does not stack if the windbox is appreciably moving downwards.
#
###################################################################
HOOK @ $8076C988
{
	lwz r12, 0x8(r28)	# \
	lwz r12, 0x3C(r12)	# | Get the object type!
	lwz r12, 0xA4(r12)	# |
	mtctr r12			# |
	bctrl				# |
	mr r7, r3			# /
	lwz r12, 0(r27) 	# Original operation
}
HOOK @ $8076C9A4
{
	cmpwi r7, 0; bne- skip		# This stuff is ONLY supposed to be for fighters!
								# Interestingly, items don't have this bug anyway.

	lwz r12, 0x44(r28)			# \
	lwz r12, 0x40(r12)			# | Hitbox Angle
	lwz r12, 0x5C(r12)			# /
	cmpwi r12, 0; beq- skip		# Brawl's non-fighter windboxes use angle 0

	stwu r1, -0x20(r1)
	

	lfs f1, 0x90(r29)	# Y Speed of Hitbox
	lfs f2, -0x90(r13)	# -1.0
	fcmpu cr1, f1, f2	# Checking if hitbox is moving downwards

	lwz r12, 0x7C(r28)	#
	lhz r7, 0x3A(r12)	# Current Action
	cmpwi r7, 0x45; bne+ normal	# Knockback Action
calculate:	
	lwz r12, 0x70(r28)
	lwz r12, 0x20(r12)
	lwz r12, 0x0C(r12)
	lwz r3, 0x14C(r12)	# LA-Basic[83] (KB Stacking timer. Also used for Up Special timings outside of this action's context)
	bge cr1, notDownwards	# They're falling at a rate that even is lenient enough for what
							# you are at after pausing in mid-air from charging Offense Up (-1.25)	
	cmpwi r3, -5
	bge normal			# Allow for stacking under 15 frames if moving downwards!
notDownwards:
	cmpwi r3, -2
	bge normal			# Allow for stacking under 12 frames otherwise!
	
	lwz r12, 0x88(r28)	# \
	lwz r12, 0x14(r12)	# | Knockback Info
	lwz r12, 0x4C(r12)	# /
gotKnockbackPointer:
	stw r12, 0x10(r1)	# Pointer will come in handy in a bit.
	psq_l f1, 0x8(r12), 0, 1 # \ X&Y Knockback
	psq_st f1, 0x8(r1), 0, 1 # /
	bctrl				# Original operation. Reset knockback
				
	# This formula progressively weakens the windbox the stronger
	# the original knockback is
	
	lwz r12, 0x10(r1)
	
	psq_l f1, 0x8(r12), 0, 1	# New X&Y
	psq_l f0, 0x8(r1), 0, 1		# Old X&Y
	
	ps_add f2, f1, f0			# sum of new and old
	
	ps_abs f3, f2				# \ Get the sign
	ps_div f3, f2, f3			# / We have a safety if this result is NaN below.
	
	ps_abs f4, f1		# \
	ps_abs f5, f0		# |
	ps_mul f1, f1, f4	# | New X&Y squared (retaining sign)
	ps_mul f2, f0, f5	# | Old X&Y squared (retaining sign)
	ps_add f1, f1, f2	# / merged
	
	ps_abs f1, f1
	ps_rsqrte f1, f1	# \ reciprocal of reciprocal square root is
	ps_res f1, f1		# / square root
	ps_mul f1, f1, f3	# Restore sign
	
	lfs f3, -0xDC8(r13)	# \ 0.85 for calibration of result
	ps_mul f1, f1, f3	# /
	ps_abs f3, f1		# NaN tester
	
	ps_sel f1, f3, f1, f0 # Sets f1 to a default of f0 if NaN, otherwise proceeds to use f1 
	
	psq_st f1, 0x8(r12), 0, 1 # store X and Y	
normal:
	addi r1, r1, 0x20
skip:	
	bctrl				# Original operation. Reset knockback.
}
