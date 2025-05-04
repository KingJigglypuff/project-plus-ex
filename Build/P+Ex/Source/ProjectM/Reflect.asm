#####################################################################
Power Shield Reflect Collision Modifier Engine 2.4 [Magus, DukeItOut]
#####################################################################
# A redesign of the existing code to allow
# powershields with the following benefits:
#
# -works in subspace
# -doesn't break Franklin Badges
# -is more stable and less vulnerable to
# 	crashes
# -supports EX characters
#####################################################################
.macro FilterBone()
{
	lwz r5, 0x1C(r3)	# \ Get the extra flags
	lwz r6, 0x1C(r4)	# /
	lis r7, 0x7F		# \ Top 0xFF8zzzzz
	ori r7, r7, 0xFFFF	# / contain the bone ID
	and r5, r5, r7		# filter out bones
	not r7, r7			# \ filter for only bones 
	and r6, r6, r7		# /
	or r5, r5, r6		# Splice bone ID in
	stw r5, 0x1C(r3)	# New bone ID for reflect box
	
	li r5, 28			# 28 bytes
	bla 0x004338		# Copy 28 more bytes over	
}


HOOK @ $80875094
{
	stwu r1, -0x10(r1)
	
	lwz r3, 0x30(r31)	# \
	lwz r3, 0x20(r3)	# |
	li r4, 0			# | Pointer to the first shieldbox
	lwz r12, 0x0(r3)	# |
	lwz r12, 0xC(r12)	# |
	mtctr r12			# |
	bctrl				# /
	stw r3, 0x8(r1)		# Store the pointer
	lwz r3, 0x34(r31)	# \ 
	lwz r3, 0x20(r3)	# |
	li r4, 0			# |
	lwz r12, 0x0(r3)	# | Pointer to the first reflectbox
	lwz r12, 0xC(r12)	# |
	mtctr r12			# |
	bctrl				# /
	lwz r4, 0x8(r1)		# Get the first shieldbox pointer again
	
	%FilterBone()

	lis r5, 0x3F42		# \
	ori r5, r5, 0x8F5C	# | 0.76
	stw r5, 0x8(r1)		# /
	lfs f0, 0x18(r3)	# Reflector Scale Size
	lfs f1, 0x8(r1)		# \
	fmuls f0, f0, f1	#  | Make it 0.76x of that!
	stfs f0, 0x18(r3)	# /
	
	addi r1, r1, 0x10	
	
	li r6, 0			# Restore a value overwritten
	lwz r5, 0xD8(r31)	# Variation of original operation
}
HOOK @ $808751A0
{
	stwu r1, -0x20(r1)
	mflr r0
	stw r0, 0x24(r1)
	stw r3, 0x8(r1)		# We'll need this, but not yet.
	stw r4, 0xC(r1)		# For readability purposes.
	
	lwz r3, 0x2C(r4)	# \
	lwz r3, 0x30(r3)	# |
	li r4, 0			# | Pointer to the first hurtbox
	lwz r12, 0x0(r3)	# |
	lwz r12, 0xC(r12)	# |
	mtctr r12			# |
	bctrl				# /
	stw r3, 0x10(r1)	# Store the pointer
	lwz r3, 0x0C(r1)	# \
	lwz r3, 0x34(r3)	# | Pointer to the first reflectbox
	lwz r3, 0x20(r3)	# |
	li r4, 0			# |
	lwz r12, 0x0(r3)	# |
	lwz r12, 0xC(r12)	# |
	mtctr r12			# |
	bctrl				# /
	lwz r4, 0x10(r1)	# Get the first hurtbox pointer again
	addi r4, r4, 0x8
	
	%FilterBone()

	lwz r12, 0xC(r1)	# \
	lwz r4, 0x70(r12)	# |
	lwz r4, 0x20(r4)	# | access LA-Bit
	lwz r4, 0x1C(r4) 	# /
	lwz r5, 0x04(r4) 	# LA-Bits 32-63
	andis. r5, r5, 0x20 # Wearing a Franklin Badge?
	beq- noBadges		# if not, we don't have to worry
	
	li r4, 2			# \ Set the status to reflect!
	stw r4, 0x5C(r3)	# | A command to make the powershield
						# / go away messed this up!
	  	
noBadges:		# No badges? :<	
	lwz r3, 0x8(r1)		# r3 is important
	
	lwz r0, 0x24(r1)
	mtlr r0
	addi r1, r1, 0x20
	
	li r4, 0			# Original operation
}
