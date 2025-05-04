#######################################################################
Variable Set on Air/Ground State Change Engine v1.3a [Magus, DukeItOut]
#######################################################################
HOOK @ $80762694
{
  stwu r1, -0x10(r1)
  mflr r0
  stw r0, 0x14(r1)
	
  subi r3, r3, 0x28		# original operation
  stw r3, 0x8(r1)
	
  lwz r12, 0x08(r6)		# \
  lwz r10, 0x110(r12)	# | (if this is a fighter, get the ID now anyway)
  lwz r12, 0x3C(r12)	# |
  lwz r12, 0xA4(r12)	# | Check if this is a fighter
  mtctr r12				# |
  bctrl					# |
  cmpwi r3, 0			# |
  bne+ notFighter		# /
	
  mulli r8, r4, 0x2
  cmpwi r8, 0x0
  bne- loc_0x1C
  li r8, 0x1			# if it is 0, make it 1

loc_0x1C:
  mulli r9, r5, 0x2
  cmpwi r9, 0x0
  bne- loc_0x2C
  li r9, 0x1			# if it is 0, make it 1

loc_0x2C:
  lis r12, 0x8076			# \ Address of table . . . minus eight.
  lwz r12, 0x26AC(r12)		# |
  subi r12, r12, 8			# /
loc_0x34:
  lwzu r11, 8(r12);  cmpwi r11, 0xFFFF;  beq- loc_0xD8 # End of table. Leave loop.
  srawi r0, r11, 24;  cmpw r0, r10;  beq- loc_0x54   # check if the first byte is the character ID
					cmpwi r0, 0xFFFF;  bne+ loc_0x34 # check if it applies to all characters

loc_0x54:
  rlwinm r0, r11, 12, 28, 31;  and. r0, r0, r8;  beq+ loc_0x34 # 27171273 -> 71273271 filter 0xF # Check 3rd digit
  rlwinm r0, r11, 16, 28, 31;  and. r0, r0, r9;  beq+ loc_0x34 # 27171273 -> 12732717 filter 0xF # Check 4th digit 
	# i.e. 1 in the 1st checks for if r4 is 0, 7 in the 2nd checks if r5 is 0 OR 3
  
  lwz r7, 0x70(r6)		#LA
  rlwinm r0, r11, 22, 26, 29 # 0x3C = 0xF * 4. Checking for 5th digit, but the result is * 4
  add r7, r7, r0
  lwz r7, 0x1C(r7)		# if r0 = 0, UNK, r0 = 4, RA, r0 = 8, LA
  rlwinm r0, r11, 27, 25, 28 # 0x78 = 0xF * 8. Checking for 6th digit, but the result is * 8
  add r7, r7, r0
  lwz r7, 0xC(r7)		# if r0 = 0, Basic, if r0 = 8, Float, if r0 = 0x10, Bit
  cmpwi r0, 0x10		# \
  beq+ loc_0xA0			# / branch if Bit
  lwz r0, 4(r12)		# Basic or Float
  rlwinm r11, r11, 2, 22, 29 # lowest byte but multiplied by 4 for offset
  stwx r0, r7, r11
  b loc_0x34

loc_0xA0:				# Bit
  rlwinm r0, r11, 29, 27, 29 # \ Lowest byte is the value of the [x]-bit to set/clear
  add r7, r7, r0			 # |
  rlwinm r0, r11, 0, 27, 31  # /
  li r11, 0x1
  slw r11, r11, r0
  lwz r0, 4(r12)		# check if 0 (clear) or 1 (set)
  cmpwi r0, 0x0
  lwz r0, 0(r7)
  beq- loc_0xCC
  or r0, r0, r11		# set
  b loc_0xD0	

loc_0xCC:
  andc r0, r0, r11		# clear

loc_0xD0:
  stw r0, 0(r7)
  b loc_0x34

loc_0xD8:
  
  lwz r3, 0x08(r1)
  lwz r0, 0x14(r1)
  mtlr r0
  addi r1, r1, 0x10
}
HOOK @ $807626A4 # Moved to set up pointer to table below.
{
	stw r0, 0x24(r1)
	stw r31, 0x1C(r1)
	stw r30, 0x18(r1)		 
}
op b 0x8 @ $807626A8

	.BA<-VariableTable
	.BA->$807626AC
	.GOTO->VariableTableSkip
# Variable Set on Air/Ground State Change Data
VariableTable:
* 00171271 00000000 # LA-Bit[113] Off - Mario 					# Landing
* 00171274 00000000 # LA-Bit[116] Off - Mario					# Landing
* 04171270 00000000 # LA-Bit[112] Off - Yoshi					# Landing
* 04171271 00000000 # LA-Bit[113] Off - Yoshi					# Landing
* 08171273 00000000 # LA-Bit[115] Off - Luigi					# Landing
* 0D17127E 00000000 # LA-Bit[126] Off - Zelda					# Landing
* 11171273 00000001 # LA-Bit[115] On  - Marth					# Landing
* 12171272 00000000 # LA-Bit[114] Off - Mr. Game & Watch		# Landing
* 14171273 00000000 # LA-Bit[115] Off - Ganondorf				# Landing
* 14171278 00000001 # LA-Bit[120] On  - Ganondorf				# Landing
* 14171062 00000000 # LA-Basic[98] 0  - Ganondorf				# Landing	
* 16371273 00000000 # LA-Bit[115] Off - Meta Knight				# Ground+Air
* 17171271 00000000 # LA-Bit[113] Off - Pit						# Landing
* 17171272 00000001 # LA-Bit[114] On  - Pit						# Landing
* 18171271 00000000 # LA-Bit[113] Off - Zero Suit Samus			# Landing
* 1917127A 00000001 # LA-Bit[122] On  - Olimar					# Landing
* 1E171273 00000000 # LA-Bit[115] Off - Squirtle				# Landing
* 1F17104B 00000000 # LA-Basic[75] 0  - Ivysaur					# Landing
* 21171242 00000000 # LA-Bit[66] Off  - Lucario					# Landing
* 2217105B 00000001 # LA-Basic[91] 1  - Ike						# Landing
* 23171272 00000000 # LA-Bit[114] Off - R.O.B.					# Landing
* 2317104B 00000003 # LA-Basic[75] 3  - R.O.B.					# Landing
* 2417123D 00000000 # LA-Bit[61] Off  - "PraMai" PM Lyn (beta)	# Landing
* 24171271 00000000 # LA-Bit[113] Off - "PraMai" PM Lyn (beta)	# Landing
* 24171272 00000000 # LA-Bit[114] Off - "PraMai" PM Lyn (beta)	# Landing
* 26171272 00000000 # LA-Bit[114] Off - Mewtwo					# Landing
* 26171273 00000000 # LA-Bit[115] Off - Mewtwo					# Landing
* 26371275 00000000 # LA-Bit[117] Off - Mewtwo					# Landing
* 26171276 00000000 # LA-Bit[118] Off - Mewtwo 					# Landing
* 26171062 00000000 # LA-Basic[98] 0  - Mewtwo					# Landing
* 27171273 00000001 # LA-Bit[115] On  - Roy						# Landing
* 2D17105B 00000000 # LA-Basic[91] 0  - "Dixie" Knuckles		# Landing
* 2D17105C 00000000 # LA-Basic[92] 0  - "Dixie" Knuckles		# Landing
* 2D17105D 00000000 # LA-Basic[93] 0  - "Dixie" Knuckles 		# Landing	
* 2E171134 00000000 # LA-Float[52] 0.0- Snake 					# Landing
* 2E371271 00000000 # LA-Bit[113] Off - Snake 					# Ground+Air
* 2F341271 00000000 # LA-Bit[113] Off - Sonic 					# Landing or Ledgegrab
* 2F341272 00000000 # LA-Bit[114] Off - Sonic 					# Landing or Ledgegrab
* 2F34123D 00000000 # LA-Bit[61] Off  - Sonic 					# Landing or Ledgegrab
* FF371051 00000000 # All LA-Basic[81] 0 (Aerial Glide Toss #)	# Ground+Air
* FFFFFFFF FFFFFFFF # Footer
VariableTableSkip:
	.RESET

# WWabcdxyZZ
# WW = character instance ID
# a can be 1 or 3 (1+2). 1 sets if r4 = 0, 3 sets if r4 = 0 or 1
# b can be 4 or 7 (1+6)  4 sets if r5 = 2, 7 sets if r5 = 0, 1, 2 or 3
# b is the state that is being left, a is the state being entered
# c should always be 1 (LA) but can be 2 (RA)
# d 0 = Basic, 1 = Float, 2 = Bit
# ZZ = variable to set
#
# if a is 1, it is landing, if a is 3, it is landing OR entering the air
# if b is 4, it is leaving the air, if it is 7, 
#		it is leaving the AIR, already grounded OR leaving a ledge
# ergo 
# 17 = if landing or getting up from the ledge, but NOT grabbing the ledge or leaving the ground
# 34 = if landing or grabbing the ledge, but NOT leaving the ground
# 37 = if landing, leaving the ground, getting up from a ledge or grabbing a ledge
