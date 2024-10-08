##############################################################
PSA command 11210X00 sets next GFX anim index [Eon, DukeItOut]
#
# 11210100: sets GFX index for all graphic types
# 11210200: VIS, PAT and CLR on arg 2
# 11210300: VIS and PAT arg 2, CLR arg 3
# 11210400: PAT arg 2, CLR arg 3, VIS arg 4
#
# When options 200, 300 and 400 are used, the VIS, PAT and CLR
# animations will frozen in place and use the value as a frame
# index to the first animation instead of as an animation ID!
##############################################################
HOOK @ $807A55F0
{
    li r3, 0
    bne %end%
	
    lwz r12, 0(r21)
    mr r4, r21
    addi r3, r1, 0x818
	
	lwz r12, 0x1C(r12)
    mtctr r12 
    bctrl 
	mr r26, r3				# save amount of arguments
	li r27, 0
argLoop:
    addi r3, r1, 0x818
    stw r31, 0x10(r3) #store moduleAccesser for getInt to use
    mr r4, r27
    #soAnimCmdArgList.getInt(animArgList, index) #static function
    lis r12, 0x8077 
    ori r12, r12, 0xDFDC
    mtctr r12 
    bctrl
	addi r27, r27, 1
	cmpw r26, r27;	blt+ Finished
	cmpwi r27, 2; beq+ TwoTypes
	cmpwi r27, 3; beq+ ThreeTypes
	cmpwi r27, 4; bge+ FourTypes
OneForAll:
	stw r3, 0x360(r1)	# \
	stw r3, 0x364(r1)	# |
	stw r3, 0x368(r1)	# | Set all animation types
	stw r3, 0x36C(r1)	# |
	stw r3, 0x370(r1)	# |
	stw r3, 0x374(r1)	# /
	b argLoop
TwoTypes:
	stw r3, 0x364(r1)	# \
	stw r3, 0x368(r1)	# | VIS, PAT and CLR
	stw r3, 0x370(r1)	# /
	li r12, 128
	stw r12, 0x374(r1)	# SHP is being used as an indicator flag here.
	b argLoop
ThreeTypes:
	stw r3, 0x370(r1)	#
	b argLoop
FourTypes:
	stw r3, 0x364(r1)	#
	li r12, 0
	stw r12, 0x374(r1)	# Don't use a custom indicator flag for when all 4 are assigned
Finished:
    #ecMgr.getInstance() #static function
    #lis r12, 0x807A
    #ori r12, r12, 0x2874
    #mtctr r12 
    #bctrl
	
	lwz r4, 0x360(r1)	# CHR 20
	lwz r5, 0x364(r1)	# VIS 21
	lwz r6, 0x368(r1)	# PAT 22
	lwz r7, 0x36C(r1)	# SRT 23
	lwz r8, 0x370(r1)	# CLR 24
	lwz r9, 0x374(r1)	# SHP 25
    #ecMgr.presetAnimIdx(i, i, i, i, i, i, i) #static function
    lis r12, 0x8006
    ori r12, r12, 0x06A8
    mtctr r12 
    bctrl
    li r3, 1
}
#######
# Makes it so that VIS, PAT and CLR animations will use a static frame index
# in a single animation rather than over multiple if their effect
# call set the SHP animation to 0x80 | 128, which is only possible
# if custom animation calls purposefully use separate animations
#######
# Suppress forcing effect animations to 1.0 speed each frame.
# It initializes them to 1.0 anyway!
.macro CheckStopped()
{
	lwz r4, 0x1C(r3)
	xoris r4, r4, 0x8000	# Flip negative bit
	cmpwi r4, 0		# is it a speed of 0.0?
	beq- %END%		# Remove this line if animation issues necessitate the below
	# bne+ Play		# If not, a normal animation!
	# lis r4, 0x805B			# Not needed for right now but might be in the future
	# lwz r4, 0x50AC(r4)		# as an exception if things fail to work as anticipated
	# lwz r4, 0x10(r4)
	# lwz r4, 0x08(r4)
	# cmpwi r4, 10; beq+ %END%	# Multiplayer
	# cmpwi r4,  8; beq+ %END%	# Single-Player
	# cmpwi r4,  6; beq+ %END%	# Replays
Play:	
	bctrl
}
HOOK @ $800286A8	# VIS
{
	%CheckStopped()
}
HOOK @ $800286C8	# PAT
{
	%CheckStopped()
}
HOOK @ $80028708	# CLR
{
	%CheckStopped()
}
####
HOOK @ $8005FB1C
{
	lwz r6, -0x42C0(r13) # Original operation, gets SHP index
	cmpwi r6, 128
	bne %END%
	li r6, 0			# Force into the first animation for the following
	stw r6, 0x14(r1)	# CLR
	stw r6, 0x0C(r1)	# PAT
	stw r6, 0x08(r1)	# VIS
}
HOOK @ $8005FB44
{
	lwz r0, -0x42C0(r13)	# Get SHP value
	cmpwi r0, 128			# Is it our special flag?
	bne Normal
	
customEffectAnimationStop:
	li r4, 0
	
checkLoop:	
	lwz r12, 0x2C(r1)		# animation controller for this effect model
	cmpwi r4, 1; beq- checkSRT
	cmpwi r4, 2; beq- checkCLR
checkVIS:
	lwz r3, 0x08(r12); lwz r5, -0x42D0(r13); b proceed	# VIS
checkSRT:
	lwz r3, 0x10(r12); lwz r5, -0x42CC(r13); b proceed 	# PAT
checkCLR:
	lwz r3, 0x18(r12); lwz r5, -0x42C4(r13)				# CLR

proceed:
	cmpwi r3, 0 
	beq- noAnim				# Skip if no animation present!
	lwz r8, 0x00(r3)		# List of functions to access as an animation.
	fsub f1, f1, f1			# Easy -0.0. The negative is to make it implausible be accidental
	fneg f1, f1				# 
	lwz r12, 0x28(r8)
	mtctr r12
	bctrl					# Set animation speed!

intToFloat:
	lfd f2, -0x79A8(r2)		# 43300000 80000000
	lwz r0, -0x79A8(r2)		# 43300000
	stw r0, 0x10(r1)		# these stack offsets will be overwritten shortly after this code
	xoris r5, r5, 0x8000	# integer value with highest bit flipped
	stw r5, 0x14(r1)		#
	lfd f1, 0x10(r1)		#
	fsub f1, f1, f2			# Converted the integer!

	lwz r12, 0x1C(r8)
	mtctr r12
	bctrl					# Set animation frame!

noAnim:
	addi r4, r4, 1
	cmpwi r4, 3
	blt+ checkLoop
	
Normal:
	cmpwi r24, 20		# Original operation, checks for effect 20
}