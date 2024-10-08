################################################################################
Texture Archives can be different from Model Archives for Characters [DukeItOut]
#
# Checks if a Texture Archive is Loaded
# If not, access from the Model Archive like in Brawl
# This repurposes archive flag 15 (is Alloy) to be for texture archives
################################################################################
HOOK @ $80858860
{
	stwu r1, -0x10(r1)		# We're encapsulating this texture check
	mflr r0					# That way, it can check for a split character texture archive
	stw r0, 0x14(r1)		# (Normally, it just checks the model archive)
	stw r12, 0x8(r1)		# WILL be 80858860 if you used a bctrl to get here. Doesn't matter if not.
	lwz r12, 0(r3)			# Original operation. 
}
HOOK @ $8085886C
{
	bctrl					# Using a link this time so that it can reference the stack here.
	lwz r0, 0x14(r1)
	mtlr r0
	addi r1, r1, 0x10
	blr
}
HOOK @ $80850150
{
	li r4, 8			# Model Archive
	lwz r8, 0(r1)		#
	lwz r8, 8(r8)		# Check for if this was a texture request
		
	lis r7, 0x8085		#
	ori r7, r7, 0x8860	#
	cmpw r7, r8			#
	bne+ %END%			# Not a texture archive request if different.
TextureArcReq:
	li r4, 15			# Texture Archive (Custom)
}
HOOK @ $8082AAA0	# Allow type 15 and type 8 to use the same operation 
{
	mr r12, r4			# Preserve ID. No bctrls exist in this area.
	cmpwi r4, 15		# \ Force to use Model Archive ID 8 branch if custom ID 15
	beq %END%			# /
	cmpwi r4, 8			# Original operation. Model Archive ID is 8
}
HOOK @ $8082A774	
{
	mr r12, r4
	cmpwi r4, 15
	beq %END%
	cmpwi r4, 8			# Original operation
}
# Conveniently, allocation for these is terrible and they gave
# one slot for each costume ID that was usable in Brawl, despite also separating
# characters by port anyway.
# Thus, there are actually a lot of archive slots available after 0x14 and before
# 0x44. (0x44, 0x48 and 0x4C were used for Dark, Fake and Spy/Clear, respectively)
op b 0x30 @ $8082AAF4	# \ Suppresses checks for Dark, Fake and Spy
op b 0x30 @ $8082A804	# /

HOOK @ $8082AB28 #TODO: Check for costume ID and remove that check!
{
	cmpwi r12, 8;	beq+ Model
Texture:
	lwz r3, 0x18(r3); blr	# Index for Texture archive
Model:
	lwz r3, 0x14(r3)		# Original operation. Index for Model archive.
}
HOOK @ $8082A838
{
	cmpwi r12, 8;	beq+ Model
Texture:
	stw r7, 0x18(r3); blr	# Index for Texture archive
Model:
	stw r7, 0x14(r3)		# Original operation. Index for Model archive.
	lwz r12, 0x18(r3)	
	cmplwi r12, 0xFFFF		# \ Make the texture archive check the same as the model one if a tex archive
	bne NoTexArc			# /
TexArcStatus:
	stw r7, 0x18(r3)		# The texture archive is set first if split.
	b %END%					# but the model archive needs to set it to -1 if there wasn't one!
NoTexArc:
	cmplwi r7, 0xFFFF
	beq+ TexArcStatus 
}
address $8082CC04 @ $80B07720 # make ID 15 behave like 8!
op NOP @ $8082ABC4  # Do not offset based on costume ID!
op NOP @ $8082A834	# Do not offset based on costume ID!
op NOP @ $8082AB24	# Do not offset based on costume ID!
op bgt- 0x74C @ $8084C3B0	# \
op bgt- 0x150 @ $8084EB84	#  | Make ID 15 behave like 8!
op bgt- 0x214 @ $8084E580	# /
op ori r26, r26, 0x8100 @ $80823198	# Check for texture arc when transforming out
op andi. r5, r26, 0xFEFF @ $808231D4 # But not yet when transforming in! 
HOOK @ $808231EC
{
	mr r3, r27
	lbz r4, 0xA(r29)
	andi. r5, r26, 0x0100	# NOW check for it!
	li r6, 0
	lis r12, 0x8082
	ori r12, r12, 0x7D40
	mtctr r12
	bctrl
	lbz r3, 0xA(r29)	# Original operation
}
string "tex.pac" @ $80B0A6F0	# Partially overwrite MarioD debug reference
HOOK @ $8084D098
{
	cmpwi r22, 15; bne notTex
	lis r7, 0x80B0			# \ "tex.pac" instead of ".pac"
	ori r7, r7, 0xA6F0		# /
notTex:
	crclr 6, 6		# Original operation
}
HOOK @ $8084D004
{	
	cmpwi r23, 62; beq- noTexSplit	# \ At least for now, we're keeping hidden alts unsplit
	cmpwi r23, 61; beq- noTexSplit	# /
CheckForTex:
	
	lis r12, 0x80AD
	ori r12, r12, 0x8254		# 4 before slot table. Modify to Slot for P+EX!
	addi r11, r12, 4			# Get the exact table start into r11

slotLoop:	
	lwzu r3, 0x4(r12)			# Increment r12 by 4 each read
	cmpw r3, r31
	bne slotLoop				# This will be safe because it is impossible for that table
								# to NOT have this value given circumstances
	sub r11, r12, r11			# Get the difference between these two
	srwi r3, r11, 4				# Divide by 0x10 and filter out lowest bytes
	bla 0x0AF708				# Convert to CSS slot 
	
	rlwinm r3, r3, 4, 0, 27		# Each block is separated by 0x10. 
	addi r3, r3, 8				# It will be offset 8 for each 0x10 block	
	
	lis r12, 0x8058				# \ Character table. Change to CSSSlot for P+EX!
	ori r12, r12, 0x5B00		# /
	lwzx r12, r12, r3			# pointer to costume masq table
	mr r11, r12
	rlwinm r5, r23, 0, 26, 31	# NOP'd out operation below this hook
	li r6, 0					# Starting default: 00
loop:
	lbz r3, 0x0(r12)
	lbz r4, 0x1(r12)
	cmpwi r3, 0xC			# table terminator
	beq notFound			# Won't actually trigger for a real costume but a safety check anyway
	andi. r0, r3, 0x80
	beq+ notParentModel
	mr r6, r4				# Most recent model reference found
notParentModel:
	cmpw r4, r5				# Is it the costume ID in r8?
	addi r12, r12, 2
	bne+ loop
	
	andi. r0, r3, 0xC0		# Upper nybble
	beq noTexSplit
	andi. r0, r3, 0x80
	bne hasMdl
	cmpwi r22, 8
	bne hasMdl
	mr r5, r6				# Use this ID instead of the costume ID
hasMdl:	
	b hasTex
###
noTexSplit:
	rlwinm r5, r23, 0, 26, 31	# NOP'd out operation below this hook
	cmpwi r22, 8
	beq unsplitMdlTex
notFound:
	lis r12, 0x8084			# \
	ori r12, r12, 0xE474	# | Abort trying to spawn the tex.pac if it doesn't exist!
	mtctr r12				# |
	bctr					# /
###
hasTex:
unsplitMdlTex:
	addi r3, r1, 0x60		# Original operation
	
}
op NOP @ $8084D00C			# We're accounting for this above. Normally sets r5 to the costume.
HOOK @ $8084C368
{
	cmplwi r7, 15;				bne Normal			# Only Check for Tex Archives!

	rlwinm. r12, r8, 0, 24, 24; bne- NoTexOption	# Spy
	cmpwi r8, 61; 				beq- NoTexOption	# AltR
	cmpwi r8, 62;				beq- NoTexOption	# AltZ
	lis r12, 0x805B			# \
	lwz r12, 0x50AC(r12)	# | Retrieve the game mode name
	lwz r12, 0x10(r12)		# |
	lwz r12, 0x0(r12)		# /
	lis r11, 0x8070; ori r11, r11, 0x2B60;	# \
	cmpw r11, r12;   bne+ Normal			# / Check for Dark/Fake if this is "sqAdventure"
	cmpwi r8, 12;				beq- NoTexOption	# Dark
	cmpwi r8, 13;				bne+ Normal			# Fake

NoTexOption:	
	li r3, 0
	blr
Normal:
	stwu r1, -0xFD0(r1)	# Original operation
}
HOOK @ $80829874		# Push Texture, Then Model, So Texture Access attempt is visible to Model Check!
{	
	li r3, 0
	ori r0, r3, 0x8000
	stw r3, 0x10(r1)
	addi r3, r26, 0x178
	addi r4, r1, 0x10
	stb r27, 0x10(r1)
	stw r0, 0x14(r1)
	lwz r12, 0x178(r26)
	lwz r12, 0x30(r12)
	mtctr r12
	bctrl				# Push Tex check (0x8000)
noTexSplit:
notFound:
	li r3, 0			# Original operation, get ready to push costume model check (0x100)

}
HOOK @ $8084E94C
{
	cmpwi r0, 15			# Original operation
	bne+ %END%
	lis r5, 0x80B8
	lwz r5, 0x7AA0(r5)		# the common parameter for fighters happened to use 15
	cmpwi r5, 0				# let's not load it multiple times, it will fail
	crnot 0, 0				# the bne branch goes the same location as 8
}

###########################################
Larger Costume Sizes Are Usable	[DukeItOut]
###########################################
#
# Allows character model polygons to reside
# in the secondary resource instead of
# the first if the first is too full.
#
# This was necessary for certain fighters
# to be compatible with tex files, such
# as Peach.
#
# In some cases, gains of 0.1MB-0.2MB
# are achieved with this.
###########################################
HOOK @ $8071358C
{
	cmpwi r3, 0; bne+ finish	# If a model was constructed, we don't need to assess alternative resources
	stw r3, 0x1C(r1)	# Clear out value that will be used for filesize of compiled model object
	lwz r12, 0xC8(r27)
	lwz r12, 0xD8(r12)
	lwz r12, 0xC0(r12)
	lwz r12, 0x0C(r12)	# For fighters, this is the resource that usually contains Fit<char>.pac
						# Normally, they'd instead use a different one shared with the Motion, Etc and costume model archives.
	addi r12, r12, 4	#	 but we'll cheat and use a different one since the other four for fighters come right after.
	cmpwi r12, 22; blt+ skip 	#\ We are NOT going to experiment with other object model types
	cmpwi r12, 25; bgt+ skip 	#/ trying to do this. Only fighters!
	mr r3, r12			# We wanted to wait on using r3 so that zero was correctly applied to other cases
	lis r12, 0x8002
	ori r12, r12, 0x4430
	mtctr r12
	bctrl				# Get the allocator for that fighter heap
	addi r4, r1, 0x1C	# Where we will be storing the memory allocation size of the resulting object
	addi r5, r1, 0x08	# Pointer to MDL0 we'll be creating a visual of
	mr r6, r29
	li r7, 1
	lis r8, 0x8004
	ori r8, r8, 0x7FCC
	lis r12, 0x801B
	ori r12, r12, 0x0B40
	mtctr r12			# Try to make the model again
	bctrl				# if this fails, it will crash anyway
skip:
finish:	
	li r0, 1			# Original operation
}