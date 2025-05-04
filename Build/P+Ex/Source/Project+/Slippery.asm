################################################
Slippery Walk Animation Speed Change [DukeItOut]
################################################
.alias MultSpeed = 0x4010 # 2.25
.alias MaxMultSpeed = 0x3FA0 # 1.25
.alias MultThreshold = 0x3F40 # 0.75

HOOK @ $8086FC80 # This part affects the animation speed of walking.
{
	lwz r12, 0x18(r31)
	lbz r12, 0xB8(r12)
	cmpwi r12, 12		# Is this slippery?
	beq- slippery
	cmpwi r12, 14		# Is this ice?
	beq- slippery
	cmpwi r12, 16		# Is this also ice?
	bne+ setWalkSpeed
slippery:
	lwz r12, 0x08(r31)
	lwz r12, 0x110(r12)
	cmpwi r12, 0xF		# Are these the Ice Climbers?
	beq- setWalkSpeed	# They have normal grip on ice!
	cmpwi r12, 0x23		# Are they R.O.B.?
	beq- setWalkSpeed	# because you sure as heck don't want to hear that walk sfx spam!

	lwz r12, 0xD0(r31)	# \
	lfs f0, 0x20(r12)	# / Max Walk Speed

	lis r12, MultThreshold	# \
	stw r12, 0x8(r1)		# | Multiply by a threshold
	lfs f2, 0x8(r1)			# |
	fmuls f0, f0, f2		# /	

	lwz r12, 0x28(r31)	# \
	lfs f2, 0x40(r12)	# | Current absolute X Speed
	fabs f2, f2			# /

	fcmpu cr0, f2, f0		# \
	lis r12, MaxMultSpeed	# |
	bge+ maxWalkSpeed		# / If it matches the walk speed limit, do a lower multiplier!
	lis r12, MultSpeed		# \
maxWalkSpeed:				# |
	stw r12, 0x8(r1)		# | Multiply speed
	lfs f0, 0x8(r1)			# |
	fmuls f1, f1, f0		# /
setWalkSpeed:
	bctrl			# Original operation
}
HOOK @ $80870D64 # This part affects the animation speed of running.
{
	lwz r12, 0x18(r30)		# \
	lbz r12, 0xB8(r12)		# | Are we on ice or something slick?
	cmpwi r12, 12			# | Is this slippery?
	beq- slippery			# |
	cmpwi r12, 14			# | Is this ice?
	beq- slippery			# |
	cmpwi r12, 16			# | Is this also ice?
	bne+ setSpeed			# /
slippery:
	lwz r12, 0x8(r30)		# \
	lwz r12, 0x110(r12)		# \ Are these the Ice Climbers? 
	cmpwi r12, 0xF			# | These have no silly ice animation shenanigans!
	beq- setSpeed			# /
	cmpwi r12, 0x23			# Are they R.O.B.?
	beq- setSpeed			# because you sure as heck don't want to hear that walk sfx spam!

	lfs f0, 0x250(r13)		# 1.2
	fmuls f1, f1, f0
setSpeed:
	bctrl	
}
HOOK @ $808686DC # This part manipulates the TransN movement to basically make the actual motion across the stage the same rate.
{
	lwz r3, 0x18(r29)		# \
	lbz r3, 0xB8(r3)		# | Are we on ice or something slick?
	cmpwi r3, 12			# | Is this slippery?
	beq- slippery			# |
	cmpwi r3, 14			# | Is this ice?
	beq- slippery			# |
	cmpwi r3, 16			# | Is this also ice?
	bne+ normal				# /
slippery:
	lwz r3, 0x8(r29)		# \
	lwz r3, 0x110(r3)		# \ Are these the Ice Climbers? 
	cmpwi r3, 0xF			# | These have no silly ice animation shenanigans!
	beq- normal				# /
	cmpwi r3, 0x23			# \ Are they R.O.B.?
	beq- normal				# / because you sure as heck don't want to hear that walk sfx spam!

	lwz r3, 0x7C(r29)		# \
	lhz r3, 0x3A(r3)		# | Are we running or walking?
	cmpwi r3, 4				# |
	beq- run				# |
	cmpwi r3, 1				# |
	bne+ normal				# /
checkWalk:
	lwz r12, 0xD0(r29)	# \
	lfs f0, 0x20(r12)	# / Max Walk Speed

	lis r12, MultThreshold	# \
	stw r12, 0x124(r1)		# | Multiply by a threshold
	lfs f2, 0x124(r1)		# | (this point on the stack should be safe as it isn't used until later)
	fmuls f0, f0, f2		# /

	lwz r12, 0x28(r29)	# \
	lfs f2, 0x40(r12)	# | Current absolute X Speed
	fabs f2, f2			# /

	fcmpu cr0, f2, f0		# \
	lis r12, MaxMultSpeed	# | If it matches walk speed threshold, do a lower multiplier!
	bge+ calcSpeed			# / 
	lis r12, MultSpeed		#
	b calcSpeed
run:
	lwz r12, 0x250(r13)		# 1.2
calcSpeed:
	lwz r3, 0x14(r29)		# \ Get TransN X calculation for this frame	
	lfs f0, 0xAC(r3)		# /
	stw r12, 0xAC(r3)		# \ Use this as temporary scratch as f0 still has it
	lfs f2, 0xAC(r3)		# /
	fdivs f0, f0, f2		# Divide what the animation was multiplied by!
	lfs f2, -0x6C8(r13)		# 0.75
	fmuls f0, f0, f2		# Reduce the maximum run speed possible!
	stfs f0, 0xAC(r3)		# Calculated compensation for animation manipulation!

normal:
  	lwz r4, 0xD8(r29)		# Original operation
}
HOOK @ $80870738 # Related to altering dash speeds on slick surfaces.
{
	lwz r3, 0x14(r31)	# \ 
	lwz r3, 0x40(r3)	# | Check if first frame of dash activity
	cmpwi r3, 0			# |
	bne+ finish			# /
	
	lwz r3, 0x08(r31)
	lwz r3, 0x110(r3)
	cmpwi r3, 0xF		# Is this the Ice Climbers?
	beq- finish

	lwz r3, 0xD8(r31)		# \
	li r4, 0				# |
	lwz r3, 0x10(r3)		# |
	lwz r12, 0x8(r3)		# | Get the terrain friction coefficient
	lwz r12, 0x170(r12)		# |
	mtctr r12				# |
	bctrl					# /
	
	lis r3, 0x80AD		# \ 1.0
	lfs f0, 0x792C(r3)	# /



	lfs f2, 0x7930(r3)	# 2.0
	
	fmuls f2, f1, f2	# 2x friction value of terrain for this calculation	


	lwz r3, 0x88(r31)	# \ Character Momentum X Speed
	lwz r6, 0x64(r3)	# |
	lfs f3, 0x08(r6)	# /	
	
	fcmpu cr0, f2, f0	# \ if Friction Coefficient * 2.0 >= 1.0
	bge+ finish			# / treat normally 
						# (no official terrain value should apply between 
						#  0.4 and 1.0, but just in case)
	
	fmuls f3, f3, f1	# Dash Speed * Friction Coefficient
	stfs f3, 0x08(r6)	# Multiply by friction on ice and slick surfaces!
	
	lwz r3, 0x14(r31)	# \
	lfs f0, 0x4C(r3)	# | Also provide the inverse as a playspeed!
	fdivs f0, f0, f2	# |
	stfs f0, 0x4C(r3)	# /
finish:	
	lwz r0, 0x24(r1)	# Original operation
}