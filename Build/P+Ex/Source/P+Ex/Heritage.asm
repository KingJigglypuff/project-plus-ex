###################################
Access Fighter Ancestor [DukeItOut]
###################################
# Allows weapons and items
# to access the parent fighter.
#
# Even works for ones spawned by
# other weapons and items!
###################################
HOOK @ $80003FF0
{
	stwu r1, -0x20(r1)
	mflr r0
	stw r0, 0x24(r1)
	stw r31, 0x10(r1)
	mr r31, r3
AncestryLoop:
	cmpwi r31, 0	# \ In case the founder doesn't exist at all.
	beq- null		# /
	cmpwi r31, -1	# Default for founder code if not added.
	beq- null
	
	lwz r3, 8(r31)
	lwz r12, 0x3C(r3)
	lwz r12, 0xA4(r12)
	mtctr r12
	bctrl
	cmpwi r3, 0
	beq isFighter
	cmpwi r3, 4
	beq isItem
	cmpwi r3, 2
	bne null
isWeapon:
	lwz r3, 8(r31)
	lwz r12, 0x90(r3)
	lwz r12, 0xC4(r12)	# get founder task ID
	mtctr r12
	bctrl
	b findFounder	
isItem:
	lwz r3, 8(r31)
	lwz r3, 0x8C8(r3)	# Proof: 8098D538 Tested to confirm founder and not owner.
						# Also tested with fire flower shots. Returns fire flower.
findFounder:
	cmpwi r3, -1; beq- null	
	bla 0x2DC40 # get task pointer
	cmpwi r3, 0; beq- null
	lwz r31, 0x60(r3)
	b AncestryLoop
isFighter:
	mr r3, r31
	b end
null:
	li r3, 0
end:
	lwz r31, 0x10(r1)
	lwz r0, 0x24(r1)
	mtlr r0
	addi r1, r1, 0x20
	blr
}