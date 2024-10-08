######################################################################################################
[Legacy TE] Holding L when new name at CSS goes to custom controls & back to CSS v1.21 [ChaseMcDizzle]
######################################################################################################
HOOK @ $8069B860
{
  lis r17, 0x8000
  lwz r18, 0x2800(r17)
  cmpwi r18, 0x0
  beq- loc_0x28
  
  li r19, -1
  
  lis r17, 0x8069  
  ori r17, r17, 0xB890
  mtctr r17
  bctr 

loc_0x28:
  li r18, -1
  cmpw r3, r18
  bne- loc_0x60
  lwz r15, 0xC(r29)
  andi. r15, r15, 0x40
  beq- loc_0x60
  
  li r18, 0x1
  stw r18, 0x2800(r17)
  lis r8, 0x805A
  lwz r8, 224(r8)
  lwz r8, 28(r8)
  stb r19, 40(r8)

loc_0x60:
  cmpwi r3, 0x0

}
HOOK @ $8068D7C0
{
  lis r8, 0x8000
  lwz r8, 0x2800(r8)
  cmpwi r8, 0x0
  beq- loc_0x3C
  li r0, 0xC
  li r3, 0x4
  li r6, 0x4
  li r29, 0x4
  li r30, 0x55
  li r31, 0x3
  
  lis r16, 0x8068
  ori r16, r16, 0xD7F4
  mtctr r16
  bctr 

loc_0x3C:
  cmpw r0, r30
}
HOOK @ $8002D654
{
  lis r8, 0x8000
  lwz r12, 0x2800(r8)
  cmpwi r12, 0x0;  beq- loc_0x58
  cmpwi r12, 0x1;  beq- loc_0x24
  cmpwi r12, 0x2;  beq- loc_0x40

loc_0x24:
  lis r4, 0x8070
  ori r4, r4, 0x18EC
  li r7, 0x2
  b loc_0x4C

loc_0x40:
  lis r4, 0x8070
  ori r4, r4, 0x17E0
  li r7, 0x0
  
loc_0x4C:
  stw r7, 0x2800(r8)

loc_0x58:
  mr r26, r3

}


#################################################################################################################
[Project+] X To toggle Rumble V1.3 (requires Fracture's Controls) [ChaseMcDizzle, Fracture, Yohan1044, DukeItOut]
#
# 1.3: Moved slot rumble from Fracture's Controls and added rumble and sound effect support.
#################################################################################################################
.alias SFX_ToggleRumble	= 	0x24	# (Menu 15)
.alias TagSize			=	0x124	# Assumed size of each tag
.macro playRumble()
{
	lwz r4, -0x20(r3)		# Controller ID number
	lwz r3, -0x43E0(r13)	# Controller manager
	li r5, 10				# Rumble Type
	bla 0x02A9E8			# Cause controller rumble 
}
#Alters Rumble of tag AND slot
HOOK @ $8069FEC8
{
  
  
	lbz r14, 0x60(r3);  	cmpwi r14, 0x1;  bne- customPage	# Is this the normal tag menu?
	andi. r14, r6, 0x400;  	beq- noXPress					# Was X pressed?
	
	
	lis r4, 0x9017;  ori r4, r4, 0xBE60	# Where player slot rumble info is placed
	lbz r27, 0x57(r3);  subi r27, r27, 0x31	# Check for player slot
	
	
	lwz r14, 0x44(r3);  cmpwi r14, 0;  	blt- notSlot		# Is this an invalid slot?
										beq- notTag			# Is this the player slot?
	lwz r12, 0x6C(r3);	cmpw r14, r12;  bgt- notSlot		# Is this an invalid slot?
  subi r14, r14, 0x1
  mulli r14, r14, 0x2
  addi r14, r14, 0x70
  lhzx r14, r3, r14
  mulli r23, r14, TagSize
  lis r15, 0x805A
  lwz r15, 0xE0(r15)
  lwz r15, 0x28(r15)
  add r15, r15, r23
  lbz r24, 0xEC(r15)
  xori r24, r24, 1			# Toggle the tag's rumble!
  stb r24, 0xEC(r15)
  b finishToggle
notTag:  
	lbzx r14, r4, r27;  xori r14, r14, 1;  stbx r14, r4, r27
	li r24, 1		# Always make it assume rumble for the below context if no tag!
finishToggle:
	lbzx r14, r4, r27	# Check player rumble slot (again)
	mr r27, r5
	cmpwi r24, 1; bne+ noRumbleShake	# Does the tag allow rumble?
	cmpwi r14, 1; bne+ noRumbleShake	# Does the slot allow rumble?

	%playRumble()
noRumbleShake:
	li r4, SFX_ToggleRumble	# \
	lis r3, 0x805A			# | Play Sound Effect!
	bla 0x6A83F4			# /	
	mr r3, r26		# restore r3
	mr r5, r27		# restore r5
noXPress:
notSlot:
customPage:
  lwz r0, 0xC(r28)	# Most recent input
  mr r4, r28		# Restore r4
  mr r24, r7		# Original operation
}
#Scrolls Through list
HOOK @ $806A01D0
{
  andi. r24, r24, 0xF
  cmpwi r24, 0x2
  bgt- loc_0x14
  li r19, 0x421
  b %END%

loc_0x14:
  rlwinm. r0, r0, 0, 28, 28
  bne- %END%
  lis r24, 0x806A
  ori r24, r24, 0x2FC
  mtctr r24
  bctr 
}
HOOK @ $806A0518
{
  cmpwi r19, 0x421; beq- %END%
  lis r19, 0x800B
  ori r19, r19, 0x3C5C
  mtctr r19
  bctrl 
}
#SetFrameMatCol on scroll
HOOK @ $806A0548
{
  cmpwi r19, 0x421;  beq- %END%
  lis r19, 0x800B
  ori r19, r19, 0x7A18
  mtctr r19
  bctrl 
}
#setFontColor on scroll
HOOK @ $806A05CC
{
  cmpwi r19, 0x421;  beq- %END%
  lis r19, 0x800B
  ori r19, r19, 0x93A4
  mtctr r19
  bctrl 
}
#playSoundEffect on scroll
HOOK @ $806A02F8
{
  cmpwi r19, 0x421
  beq- loc_0x1C
  lis r19, 0x8007
  ori r19, r19, 0x42B0
  mtctr r19
  bctrl 
  b loc_0x24

loc_0x1C:
  lwz r19, 0x48(r26)
  stw r19, 0x44(r26)

loc_0x24:
  li r19, 0x0
}

##################################################
[Project+] CSS Tags with Rumble are Coloured [Eon] 
##################################################
#Logic to find if rumble on for tag from `CSS Tags with Rumble are teal, X To toggle V1.2 [ChaseMcDizzle, Fracture, Yohan1044]`
#Logic to find if rumble on for port from `[Project+] Customize Controls on CSS V9.1 + C-stick taunts renamed [Fracture]`
HOOK @ $8069f9fc
{
  cmpwi r19, -1   #makes sure CSS custom control menu isnt open, remove top 5 lines if that code isnt included in your build
  beq renderColours
  li r16, 0
  li r17, 0
  b end
renderColours:

  #getTagNo
  subi r15, r27, 0x1
  cmpwi r15, -1
  beq portRumble

#checks tag ordering, finds current working tag
  mulli r15,r15, 0x2 
  addi r15, r15, 0x68
  lhzx r15, r3, r15

  mulli r15, r15, 0x124
  #Is rumble enabled?
  lis r16, 0x805A
  lwz r16, 0xE0(r16)
  lwz r16, 0x28(r16)
  add r16,r16,r15
  lbz r16, 0xEC(r16)
  b storeCentre

  #specific rumble check for player port
portRumble:
  lbz r16, 0x60(r24)
  cmpwi r16, 1;  bgt- 0x24
  lbz r16, 0x57(r24)
  subi r16,r16,49
  lis r15, 0x9017;  ori r15,r15, 0xBE60
  lbzx r16,r15,r16

  #if current working tag is centre tag, remember its value for if going off-centre
storeCentre:
  cmpw r25, r27;  bne end
  mr r17, r16

  #original command (is working tag centred)
end:
  cmpwi r26, 4
}
#Centred Tag
HOOK @ $8069fa0c 
{
  li r18, 0x0

  cmpwi r16, 1
  bne %end%
  li r20, 0x00  #red
  li r19, 0x90  #green
  li r18, 0x90  #blue
}
#Off Centre Tag
HOOK @ $8069fa1c
{
  li r18, 0x50
  cmpwi r16, 1
  bne %end%
  li r20, 0x10  #red
  li r19, 0x80  #green
  li r18, 0x80  #blue
}
#Changing from Centred to Off Centre
HOOK @ $806a05c8 
{
  li r8, 0xFF
  cmpwi r17, 1
  bne %end%
  li r5, 0x10
  li r6, 0x80
  li r7, 0x80
}

###########################################################
[Legacy TE] Load Player Tags on Win Screen v2 [PyotrLuzhin]
###########################################################
HOOK @ $800E7C5C
{
  stw r5, 0(r2)
  lwz r12, -0x4340(r13)
  lwz r12, 8(r12)
  lwz r0, 0xB8(r30)
  mulli r0, r0, 0x5C
  add r12, r12, r0
  addi r12, r12, 0x98
  lhz r0, 12(r12)
  cmpwi r0, 0x0
  beq- loc_0x48
  addi r4, r12, 0xC
  addi r3, r2, 0x4
  lis r11, 0x8006		# \
  ori r11, r11, 0xBCA8	# | utf16to8
  mtctr r11				# |
  bctrl 				# /
  addi r5, r2, 0x4
  b loc_0x4C

loc_0x48:
  lwz r5, 0(r2)

loc_0x4C:
  li r4, 0x0
  lwz r3, 0x654(r30)
}
