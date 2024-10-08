################################################################################
PM Replay Fix V2.3 [Fracture, Stage Reload Fix by Kapedani, Recode by DukeItOut]
#
# 1.1: 
# Updated to account for ASL
#
# 1.2:
# Updated to not use rigid pointers, as this affected memory allocation
# Require's Eon's bla function support to work.
#
# 2.0:
# Fixed issue where Wiimote controllers could not record replays.
#
# 2.0b:
# Got ASL value from a new pointer location for more stability.
#
# 2.1:
# Fixed issue where controllers in unexpected arrangements could influence 
# Wiimotes or CPUs
#
# 2.1b:
# Adjusted based on an oversight where player slots were always assumed to be in
# a specific order
#
# 2.2:
# Fixed issue where sharing stocks was never recognized during a replay
#
# 2.3:
# Handled oversight in custom replay system that misinterpreted a special command
# as a command size instead, causing cinematic freezes to skip over copious
# amounts of bytes in the replay.
######################################################################################
HOOK @ $8004BB04
{
	li r3, 11				# \
	bla 0x0249CC			# / Get replay heap offset
	lwz r4, 0x8(r3)			# Get end of replay heap
	
	li r5, 0
	stw r5, -0x2F4(r4) # previously 9134C90C
	stw r5, -0x25C(r4)	# previously 9134C9A4
	lwz r5, 0x28(r30)
	stw r5, -0x22C(r4)	# previously 9134C9D4
	addi r5, r5, 2
	stw r5, -0x234(r4)	# previously 9134C9CC
  
	lbz r0, 0x7A(r30)	# Original operation
}

HOOK @ $8004BB18
{
	mr r11, r0				# preserve for below
	li r3, 11				# \
	bla 0x0249CC			# / Get replay heap offset
	lwz r4, 0x8(r3)			# Get end of replay heap
	lwz r3, -0x22C(r4)		# previously 9134C9D4
	
  li r5, 0x6
  stb r5, 1(r3)
  lis r5, 0x600
  stw r5, 2(r3)
  rlwinm r5, r11, 2, 22, 29	# Modification of Original operation rlwinm r5, r0, 2, 22, 29
  stw r5, -0x25C(r4)	# previously 9134C9A4
  subi r3, r4, 0x258	# prevuiusly 9134C9A8
  sub r27, r27, r5
  # why is r3 not matching r27 here? It normally does via mr r3, r27
  addi r4, r30, 94 # needed restored value, previous operation before hook
}

HOOK @ $8004BA84
{
	mr r12, r3
	li r3, 11				# \
	bla 0x0249CC			# / Get replay heap offset
	lwz r4, 0x8(r3)			# Get end of replay heap
	li r0, 0
	stw r0, -0x2F8(r4)		# previously 9134C908
	subi r0, r4, 0x404		# previously 9134C7FC
	mr r3, r12				# restore r3
}
HOOK @ $8004BA9C
{
	mr r12, r3
	li r3, 11				# \
	bla 0x0249CC			# / Get replay heap offset
	lwz r4, 0x8(r3)			# Get end of replay heap
	li r0, 1
	stw r0, -0x2F8(r4)		# previously 9134C908
	mr r3, r12
}


HOOK @ $80764F18
{
#PRESERVE

	li r3, 11				# \
	bla 0x0249CC			# / Get replay heap offset
	lwz r4, 0x8(r3)			# Get end of replay heap    
  
  stwu r1, -0x30(r1)
  stw r31, 0x8(r1)
  stw r30, 0xC(r1)
  stw r29, 0x10(r1)
  stw r26, 0x14(r1)
  stw r25, 0x18(r1)
  stw r24, 0x1C(r1)
    
  
  lis r12, 0x805C;  lwz r12, -0x4040(r12);  cmpwi r12, 0x2;  bne- loc_0x230
  # 2 = Battles
  # 1 = Replay
  
  	lis r12, 0x8054			#
	lhz r12, -0x1046(r12)   # Get ASL input from 8053EFBA (copied from 800B9EA2)
	
	sth r12,  0x44A(r3) # previously 91301F4A. Sets replay ASL input.
	lwz r12, -0x2F8(r4) # previously 9134C908
	cmpwi r12, 0
	bne- loc_0x230			# Only activate if it went through hook 8004BA84 and not 8004BA9C?

	subi r12, r4, 0x2AC	# previously 9134C954
	lwz r31, -0x2F4(r4) # previously 9134C90C
	add r12, r12, r31
	
	
	li r31, 0		   # \
	stw r31, 0x00(r12) # |
	stw r31, 0x04(r12) # | Reset replay values so that they can't be uninitialized
	stb r31, 0x08(r12) # /
	
  addi r4, r28, 0x42    # \
  lis r3, 0x80B9        # | Check if a CPU
  lwz r3, -0x5D28(r3)   # |
  bla 0x8FC8A4          # |
  cmpwi r3, 0           # |
  beq is_CPU            # /
  
  lbz r31, 0x42(r28) # Which player slot this is.
  lis r30, 0x805B;  ori r30, r30, 0xC068	# Something related to the Code Menu?
  rlwinm r31, r31, 2, 28, 29		# was previously rlwinm r31, r31, 2, 0, 1, which broke it
  add r31, r31, r30
  lwz r30, 0(r31)
  stw r30, 0(r12)

loc_0xA0:
is_CPU:
  lwz r31, 0x78(r27)
  sth r31, 0x04(r12)
  
  lwz r31, 0x2C(r27)		#
  lwz r31, 0x70(r31)		#
  lwz r31, 0x20(r31)		# LA
  lwz r31, 0x14(r31)		# Float
  
 
  lis r29, 0x42AA;  	# 85.0
  stw r29, 0x20(r1) # previously 9134C99C
  lfs f0, 0x20(r1)

  lfs f1, 0x88(r31)			# LA-Float[34] (C-Stick X)
  fmul f1, f1, f0
  fctiw f1, f1
  stfd f1, 0x20(r1) # previously 9134C99C
  lbz r30, 0x27(r1) # previously 9134C99C+7
  stb r30, 6(r12)
  
  lfs f1, 0x8C(r31)			# LA-Float[35] (C-Stick Y)
  fmul f1, f1, f0
  fctiw f1, f1
  stfd f1, 0x20(r1) # previously 9134C99C
  lbz r30, 0x27(r1) # previously 9134C99C+7
  stb r30, 7(r12)
  lwz r30, -0x5C(r31)		# LA-Basic[77]
  stb r30, 8(r12)
   
  # r12 = address at 9134C954 + offset pointed to by 9134C90C
  # (word) 0x0(r12) = Button Inputs (half) + Control X (byte) + Control Y (byte)
  # (half) 0x4(r12) = Previous Button Inputs
  # (byte) 0x6(r12) = LA-Float[34] (C-Stick X as an integer)
  # (byte) 0x7(r12) = LA-Float[35] (C-Stick Y as an integer)
  # (byte) 0x8(r12) = LA-Basic[77] (L/R analog status)
  
	li r3, 11				# \
	bla 0x0249CC			# / Get replay heap offset
	lwz r4, 0x8(r3)			# Get end of replay heap     
  
  
  lwz r30, -0x2F4(r4) # previously 9134C90C
  subi r12, r4, 0x2AC  # previously 9134C954
  subi r31, r4, 0x2F0  # previously 9134C910
  
  add r12, r12, r30
  add r31, r31, r30
  
  lwz r24, -0x234(r4) # previously 9134C9CC

  #lwz r29, -0x4340(r13)	# Match timer alt way to get it 
  #lwz r29, 0(r29)
  #lwz r29, 4(r29)		# Get current frame 
  
  lis r29, 0x9018
  lwz r29, 0x12A4(r29)  # Get current frame

###
# The below was supposed to be a new check 
# for 1-P matches, but something else is
# breaking it as well.
#
# For now, it is left in the comments for
# when someone can figure out why it 
# is incompatble with replays.
#
# In the meanwhile, it is recommended to
# have disabled the quick start code
# that skips the countdown for 1-P
# matches.
###
  
#  lis r25, 0x805C
#  lwz r25, -0x745C(r25)	# 805B8BA4
#  lwz r25, 0x48(r25)
#  lbz r25, 0x54(r25)	# Get game start status
#  andi. r25, r25, 0x70	# 0x70 is set if it is a normal match. (0x40 for 3, 0x20 for 2, 0x10 for 1)
						# 0x4 and 0x8 set for "Ready GO!"
#  li r25, 64		# 66 frames before a quick start for "Ready. GO!" 2-frame leniency.
#  beq QuickStart
  li r25, 212		# 214 frames before normal match starts. 2-frame leniency.
QuickStart:
  cmpw r29, r25; bge+ GameReady
  
  li r25, 0xFF
  lwz r29, 0(r12)
  stw r29, 1(r24)
  stw r29, 0(r31)
  lwz r29, 4(r12)
  stw r29, 5(r24)
  stw r29, 4(r31)
  addi r24, r24, 8
  b loc_0x1A4
  
GameReady:
loc_0x168:
  li r30, 0x0
  li r25, 0x0

loc_0x178:
  rlwinm r25, r25, 1, 1, 0
  lbzx r29, r12, r30
  lbzx r26, r31, r30
  cmpw r29, r26
  beq- loc_0x198
  stbu r29, 1(r24)
  stbx r29, r31, r30
  ori r25, r25, 0x1

loc_0x198:
  addi r30, r30, 1
  cmpwi r30, 8
  blt+ loc_0x178

loc_0x1A4:
  lbz r30, 8(r12)
  stbu r30, 1(r24)
  
  lwz r12, -0x234(r4) # previously 9134C9CC
  stb r25, 0(r12)
  addi r24, r24, 1
  lwz r29, -0x2F4(r4) # previously 9134C90C
  addi r29, r29, 8
  stw r29, -0x2F4(r4) # previously 9134C90C
  
  lwz r30, -0x25C(r4) # previously 9134C9A4
  subi r29, r4, 0x258 # previously 9134C9A8 
  
  mr r25, r24
  cmpwi r30, 0x0;  ble- loc_0x208

loc_0x1EC:
  lwz r26, 0(r29)
  stw r26, 0(r25)
  addi r29, r29, 4
  addi r25, r25, 4
  subi r30, r30, 4
  cmpwi r30, 0x0;  bgt+ loc_0x1EC

loc_0x208:
  lis r30, 0x805B;  ori r30, r30, 0xBFE8
  stw r25, 0(r30)
  lwz r30, -0x22C(r4) # previously 9134C9D4
  sub r25, r25, r30
  stb r25, 1(r30)
  stw r24, -0x234(r4) # previously 9134C9CC

loc_0x230:
# RESTORE
  lwz r31, 0x8(r1)
  lwz r30, 0xC(r1)
  lwz r29, 0x10(r1)
  lwz r26, 0x14(r1)
  lwz r25, 0x18(r1)
  lwz r24, 0x1C(r1)
  addi r1, r1, 0x30
  
  mr r3, r28		# previous operation
  lwz r12, 4(r28)	# Original operation

}





HOOK @ $8004BD6C
{
	li r3, 11				# \
	bla 0x0249CC			# / Get replay heap offset
	lwz r3, 0x8(r3)		# Get end of replay heap  
	
	li r0, 0
	stw r0, -0x2F4(r3)	# previously 9134C90C
	stw r0, -0x23C(r3)	# previously 9134C9C4
	lwz r0, -0x230(r3)	# previously 9134C9D0
	stw r0, -0x234(r3)  # previously 9134C9CC
	addi r0, r30, 2
	stw r0, -0x230(r3)	# previously 9134C9D0
	lwz r0, -0x234(r3)	# previously 9134C9CC
	stw r0, -0x238(r3)	# previously 9134C9C8
	lbz r20, 1(r30)
	add r20, r20, r30
	rlwinm 0, 31, 2, 1, 0
	sub r20, r20, r0
}
HOOK @ $8004BE50
{
    mr r12, r4				# r4 is needed
	li r3, 11				# \
	bla 0x0249CC			# / Get replay heap offset
	lwz r3, 0x8(r3)			# Get end of replay heap  
    mr r4, r12
	lwz r0, 0x2C(r24)		# previous command 
	lwz r3, -0x304(r3)	# previously 9134C8FC
	
  lis r8, 0x9018
  lwz r8, 0x12A4(r8)
  or. r3, r3, r8;  beq- %END%	# Skip if this is in a replay viewing or not frame 0.
  lbz r4, 1(r6)
  cmpwi r4, 0x80		# Typically if frozen for a cinematic this is 0x80, 
  bne %END%				# but this will mess up calculations! We don't want that!
  li r4, 5				# Frozen gameplay uses 5 bytes to calculate!
						# For Fracture replay info, non-frozen is typically 4+2*playercount
  
  # Normally the operation here is add r4, r4, r3. Why is it not included?
}

# Used for share stock during team battles
HOOK @ $80958558
{
	lhz r0, 0x8(r1)			# Original operation. Gets button inputs
	lis r12, 0x805C;  lwz r12, -0x4040(r12);  cmpwi r12, 0x1;  bne- %END%
  # 2 = Battles
  # 1 = Replay (we need to make sure that the replay uses the information correctly)
	li r3, 11				# \
	bla 0x0249CC			# / Get replay heap offset
	lwz r3, 0x8(r3)			# Get end of replay heap
	subi r4, r3, 0x2AC 	# previously 9134C954
	lwz r5, -0x23C(r3) 	# previously 9134C9C4
	rlwinm r5, r5, 3, 1, 0
	add r3, r4, r5
	lhz r0, 0(r3)		# Get normal button info
}

# Used for reading replay info
HOOK @ $8091319C
{  
# PRESERVE  

	stwu r1, -0x30(r1)
	mflr r0
	stw r0, 0x34(r1)
	stw r3, 0x8(r1)
	stw r4, 0xC(r1)
	stw r31, 0x10(r1)
	stw r30, 0x14(r1)
	stw r29, 0x18(r1)
	stw r26, 0x1C(r1)
	stw r25, 0x20(r1)

  
  lis r12, 0x805C;  lwz r12, -0x4040(r12);  cmpwi r12, 0x1;  bne- loc_0x220
  
	lis r3, 0x805A			# \
	lwz r3, 0x60(r3)		# |
	lwz r3, 4(r3)			# | Force replays to check for share stock a frame earlier
	lwz r3, 0x54(r3)		# | than normal
	bla 0x9583EC			# /
  
	li r3, 11				# \
	bla 0x0249CC			# / Get replay heap offset
	lwz r3, 0x8(r3)		# Get end of replay heap   
    lwz r12, -0x238(r3)	# previously 9134C9C8
  
  lwz r31, 112(r21)
  lwz r31, 32(r31)
  lwz r31, 20(r31)
  li r29, 0x0
  li r26, 0x1
  lbz r30, 0(r12)

loc_0x5C:
  andi. r25, r30, 0x80;  beq- loc_0x6C
  addi r26, r26, 0x1

loc_0x6C:
  rlwinm r30, r30, 1, 1, 0
  addi r29, r29, 0x1
  cmpwi r29, 6;  blt+ loc_0x5C		# Loop 6 times

loc_0x7C:
  andi. r25, r30, 0x80;    beq- loc_0x94
  lbzx r29, r12, r26
  addi r26, r26, 0x1
  b loc_0xB0

loc_0x94:
  subi r29, r3, 0x2AC # previously 9134C954
  lwz r25, -0x23C(r3) # previously 9134C9C4
  rlwinm r25, r25, 3, 1, 0
  add r29, r29, r25		# C-Stick X Replay Data
  lbz r29, 6(r29)
loc_0xB0:  
  rlwinm r30, r30, 1, 1, 0
  andi. r25, r30, 0x80;  beq- loc_0xCC
  lbzx r30, r12, r26
  addi r26, r26, 0x1
  b loc_0xE8

loc_0xCC:
  subi r30, r3, 0x2AC # previously 9134C954
  lwz r25, -0x23C(r3) # previously 9134C9C4
  rlwinm r25, r25, 3, 1, 0
  add r30, r30, r25	# C-Stick Y Replay Data
  lbz r30, 7(r30)
loc_0xE8: 
  add r12, r12, r26
  addi r12, r12, 0x1
  stw r12, -0x238(r3) # previously 9134C9C8
  lwz r12, -0x23C(r3) # previously 9134C9C4
  addi r12, r12, 1
  stw r12, -0x23C(r3) # previously 9134C9C4
  
  lis r25, 0x3C40; ori r25, r25, 0xEBEE   	# 0.011775  # C-Stick Multiplier
  stw r25, 0x24(r1) # previously 9134C99C
  lfs f0, 0x24(r1)

  cmpwi r29, 85;  bne- loc_0x144
  lis r29, 0x3F80	# 1.0
  stw r29, 0x88(r31)	# LA-Float[34] C-Stick X Relative
  b loc_0x1A8

loc_0x144:
  cmpwi r29, 171;  bne- loc_0x158
  lis r29, 0xBF80	# -1.0
  stw r29, 0x88(r31)	# LA-Float[34] C-Stick X Relative
  b loc_0x1A8

loc_0x158:
  extsb r29, r29
  li r26, 0x0		# 0.0
  cmpwi r29, 0x0;  	beq- loc_0x198
					bge- loc_0x178
  lis r26, 0x8000	# -0.0?	(Left 0)
  neg r29, r29

loc_0x178:
  cntlzw r12, r29
  subi r12, r12, 0x8
  rlwnm r29, r29, r12, 9, 31
  or r26, r26, r29
  subi r12, r12, 150
  neg r12, r12
  rlwinm r12, r12, 23, 1, 0
  or r26, r26, r12

loc_0x198:
  stw r26, 0x24(r1) # previously 9134C99C
  lfs f1, 0x24(r1)

  fmul f1, f1, f0
  stfs f1, 0x88(r31)	# LA-Float[34] C-Stick X Relative
loc_0x1A8: 
  cmpwi r30, 85; bne- loc_0x1BC
  lis r30, 0x3F80	# 1.0
  stw r30, 0x8C(r31)	# LA-Float[35] C-Stick Y
  b loc_0x220

loc_0x1BC:
  cmpwi r30, 171;  bne- loc_0x1D0
  lis r30, 0xBF80	# -1.0
  stw r30, 0x8C(r31)	# LA-Float[35] C-Stick Y
  b loc_0x220

loc_0x1D0:
  extsb r30, r30
  li r26, 0x0
  cmpwi r30, 0x0;  	beq- loc_0x210
					bge- loc_0x1F0
  lis r26, 0x8000	# -0.0?
  neg r30, r30

loc_0x1F0:
  cntlzw r29, r30
  subi r29, r29, 8
  rlwnm r30, r30, r29, 9, 31
  or r26, r26, r30
  subi r29, r29, 150		
  neg r29, r29
  rlwinm r29, r29, 23, 1, 0
  or r26, r26, r29

loc_0x210:
  stw r26, 0x24(r1) # previously 9134C99C
  lfs f1, 0x24(r1)
  fmul f1, f1, f0
  stfs f1, 0x8C(r31)	# LA-Float[35] C-Stick Y

loc_0x220:
# RESTORE 
	lwz r0, 0x34(r1)
	mtlr r0
	lwz r3, 0x8(r1)
	lwz r4, 0xC(r1)
	lwz r31, 0x10(r1)
	lwz r30, 0x14(r1)
	lwz r29, 0x18(r1)
	lwz r26, 0x1C(r1)
	lwz r25, 0x20(r1)
	addi r1, r1, 0x30
	
  lwz r12, 0(r20)	# Original operation
}

HOOK @ $8004B1D4
{
  	li r11, 0x52			    # \ Added writing R to P+'s stage system to signify load stage
	lis r12, 0x8054 	    # |
	stb r11, -0xFFD(r12)  # / 8053F003 
  	lhz r0, 0xEE3(r3)
}

HOOK @ $8004ACC8
{
	li r3, 0
	lis r12, 0x805C
	stw r3, -0x75F8(r12) # 805B8A08
	mr r3, r0		# Original operation
}
HOOK @ $80764E88
{
	li r3, 11			# \
	bla 0x0249CC		# / Get replay heap offset
	lwz r12, 0x8(r3)	# Get end of replay heap 
    
  stwu r1, -0x30(r1)
  # PRESERVE
  stw r31, 0x8(r1)
  stw r30, 0xC(r1)
  stw r29, 0x10(r1)
  stw r26, 0x14(r1)
  stw r25, 0x18(r1)
  
  
  
  
  lis r3, 0x805C;  lwz r3, -0x4040(r3);  cmpwi r3, 0x1;  bne- Not_Replay
  # 2 for Battles
  # 1 for Replays
  
  lwz r29, -0x2F4(r12) # previously 9134C90C
  lwz r3,  -0x234(r12) # previously 9134C9CC
  subi r31, r12, 0x2AC # previously 9134C954
  add r31, r31, r29 
  lbz r30, 0(r3)
  li r29, 0

loc_0x60:
  andi. r26, r30, 0x80;  beq- loc_0x74		# check if 80 is set?
  lbzu r26, 1(r3)
  stbx r26, r31, r29

loc_0x74:
  addi r29, r29, 0x1
  rlwinm r30, r30, 1, 1, 0
  cmpwi r29, 0x8 
  blt+ loc_0x60

loc_0x84:
  lbz r30, 1(r3)
  stw r30, 0x1C(r1)	   # previously 9134C998
  addi r3, r3, 2
  stw r3,  -0x234(r12) # previously 9134C9CC
  lwz r29, -0x2F4(r12) # previously 9134C90C
  addi r29, r29, 8
  stw r29, -0x2F4(r12) # previously 9134C90C 
  mr r3, r31
  rlwinm. r31, r28, 0, 24, 24; bne- loc_0xF0		# Odd operation?
  
  lbz r31, 0xB(r28);  cmpwi r31, 0xFF;  beq- loc_0xF0 # Check if this is an AI 
 
  rlwinm r31, r31, 0, 29, 31
  lis r30, 0x805B;  ori r30, r30, 0xC068
  rlwinm r31, r31, 2, 1, 0
  add r31, r31, r30
  lwz r30, 0(r3)
  stw r30, 0(r31)

loc_0xF0:
  lhz r31, 4(r3)
  stw r31, 0x78(r27)
  
  lwz r31, 0x2C(r27)
  lwz r31, 0x70(r31)
  lwz r31, 0x20(r31)	# LA
  lwz r31, 0x14(r31)	# Float
  
  lis r29, 0x3C40;  ori r29, r29, 0xEBEE	# 0.011775	# Minimum detectable. C-Stick Multiplier
  
  stw r29, 0x20(r1) # previously 9134C99C
  lfs f0, 0x20(r1)
  
  lbz r30, 6(r3)
  extsb r30, r30
  li r26, 0x0	# 0?
  cmpwi r30, 0x0;  	beq- loc_0x16C
					bge- loc_0x14C
  lis r26, 0x8000 # -0.0?	(Left 0)
  neg r30, r30

loc_0x14C:
  cntlzw r29, r30
  subi r29, r29, 0x8
  rlwnm r30, r30, r29, 9, 31
  or r26, r26, r30
  subi r29, r29, 0x96
  neg r29, r29
  rlwinm r29, r29, 23, 1, 0
  or r26, r26, r29

loc_0x16C:
  stw r26, 0x20(r1)		# previously 9134C99C
  lfs f1, 0x20(r1)		#
  
  
  fmul f1, f1, f0
  stfs f1, 0x88(r31)	# LA-Float[34] C-Stick X Relative
  lbz r30, 7(r3)
  extsb r30, r30
  li r26, 0x0
  cmpwi r30, 0x0;  beq- loc_0x1C0
  cmpwi r30, 0x0;  bge- loc_0x1A0
  lis r26, 0x8000
  neg r30, r30

loc_0x1A0:
  cntlzw r29, r30
  subi r29, r29, 0x8
  rlwnm r30, r30, r29, 9, 31
  or r26, r26, r30
  subi r29, r29, 0x96
  neg r29, r29
  rlwinm r29, r29, 23, 1, 0
  or r26, r26, r29

loc_0x1C0:
  stw r26, 0x20(r1)		# previously 9134C99C
  lfs f1, 0x20(r1)		#

  fmul f1, f1, f0
  stfs f1, 0x8C(r31)   # LA-Float[35] C-Stick Y
  
  lwz r30, 0x1C(r1)		# previously 9134C998
  stw r30, -0x5C(r31)  	# Awkward way of saving LA-Basic[77] ? (0x190 bytes for Basic right before Float)
						# LA-Basic[77] is used for new L/R presses in PM
loc_0x1DC:
Not_Replay:


#RESTORE
  lwz r31, 0x8(r1)
  lwz r30, 0xC(r1)
  lwz r29, 0x10(r1)
  lwz r26, 0x14(r1)
  lwz r25, 0x18(r1)
  addi r1, r1, 0x30
  
  lwz r12, 0x4(r28)	# Original operation
}
HOOK @ $80152C74
{
	mr r28, r3		# Original operation
 
	li r3, 11			# \
	bla 0x0249CC		# / Get replay heap offset
	lwz r12, 0x8(r3)	# Get end of replay heap
	addi r30, r3, 0x100	# previously 91301C00. Start of replay heap + 0x100
	lwz r5, -0x234(r12)	# previously 9134C9CC
	addi r5, r5, 0xA
	sub r5, r5, r30
	 
	mr r30, r5			# Operation that was previously hooked. Need to replace r30
	mr r3, r28			# restore r3
}

HOOK @ $803E16C8		# PFFat_CountFreeClusters
{
  li r3, 0x0
  blr 				# Force disabling new file saving on the NAND?	
}
op li r27, 1337 @ $8001EFDC # Gamer.	
HOOK @ $80017388	# Someone, please move this to somewhere not so low-level.
{
	cmpwi r3, 1;  bne- end		# Only modify things if it thinks we are paused
	li r3, 11			# \
	bla 0x0249CC		# | Get replay heap offset
	lwz r12, 0x8(r3)	# / Get end of replay heap
	
	lis r3, 0x805C; lwz r3, -0x4040(r3)
	xori r3, r3, 1;	cmpwi r3, 0
	bne- end
	
	stw r31, -0x228(r12)	# \ Dangerous way to save memory?
	stw r30, -0x224(r12)	# /
    stw r30, 0x20(r1)		# \ Save better
    stw r31, 0x24(r1)		# /
	
	
	lis r3, 0x805B; ori r3, r3, 0xAD04		
	
	lwz r31, 0x00(r3)						# Check previous input of GC Controllers
	lwz r30, 0x40(r3); or r31, r31, r30 
	lwz r30, 0x80(r3); or r31, r31, r30
	lwz r30, 0xC0(r3); or r31, r31, r30
	lwz r30, 0x100(r3); or r31, r31, r30	# Check previous input of Wii Controllers
	lwz r30, 0x140(r3); or r31, r31, r30 
	lwz r30, 0x180(r3); or r31, r31, r30
	lwz r30, 0x1C0(r3); or r31, r31, r30
	andi. r31, r31, 0x100; beq- setSpeed
	
	li r30, 2

setSpeed:
  li r3, 1
  cmpw r19, r30;  bge- loc_0x70
  li r3, 0

loc_0x70:
  subi r30, r12, 0x228	# previously 9134C9D8
  stw r31, -0x228(r12)	# \ This used to overwrite r30 and r31!
  stw r30, -0x224(r12)	# /
  lwz r30, 0x20(r1)		# \ Restore
  lwz r31, 0x24(r1)		# /

end:
  cmpwi r3, 0			# Original operation
}

HOOK @ $8004B9E0
{
  lis r30, 0x805C; lbz r30, -0x75F6(r30)
  cmpwi r30, 0;    bne- loc_0x28 		# Unk Pause Status
  lis r30, 0x805C; lbz r30, -0x75F5(r30)
  cmpwi r30, 0;    beq+ loc_0x28 		# Code Menu/Frame Advance active
  li r0, 0; b %END%

loc_0x28:
  lwz r0, 0(r3)				# Original operation
}

HOOK @ $8004BCB8
{
	mr r26, r4
	mr r25, r3
	li r3, 11			# \
	bla 0x0249CC		# | Get end of replay heap offset
	lwz r12, 0x8(r3)	# / Get end of replay heap
	
	lis r24, 0x805B; ori r24, r24, 0xAD04	# \
	lwz r31, 0x00(r24)						# |
	lwz r30, 0x40(r24);	or r31, r31, r30	# | Check previous input of 
	lwz r30, 0x80(r24); or r31, r31, r30	# | GC player slots.
	lwz r30, 0xC0(r24); or r31, r31, r30	# |
	andi. r0, r31, 0x200; bne- pressedB		# /	Check if B is pressed during a replay
	
	lwz r31, 0x100(r24)						# \
	lwz r30, 0x140(r24); or r31, r31, r30	# | Check previous input of 
	lwz r30, 0x180(r24); or r31, r31, r30	# | Wii player slots.
	lwz r30, 0x1C0(r24); or r31, r31, r30	# |
	andi. r0, r31, 0x200; bne- pressedB		# |	Check if B is pressed during a replay
	andis. r0, r31, 0x40; beq+ noInput		# /
	
pressedB:
	
	lhz r24, -0x2FC(r12)	# previously 9134C904
	andi. r0, r24, 0x100	# Check if A was also pressed
	bne- notPressedA		# during replay mode?  
	
	lis r31, 0x805C; 
	lhz r31, -0x75F6(r31)
	sth r31, -0x2FA(r12)	# previously 9134C906
	li r24, 0x100			# Fake it if it isn't if B was pressed(?)
notPressedA:
	andi. r24, r24, 0x103
	cmpwi r24, 0x100
	bne- addOne
	
	lis r31, 0x805B; ori r31, r31, 0x8A08
	li r30, 0x102
	sth r30, 2(r31)			# Load the pause state
	
addOne:
	addi r24, r24, 1
	b checkFrameAdvance

noInput:
	lbz r24, -0x2FC(r12)			# previously 9134C904
	cmpwi r24, 1; bne- setZero
	lhz r24, -0x2FA(r12)			# previously 9134C906
	lis r31, 0x805C; sth r24, -0x75F6(r31) # 805B8A0A
	
setZero:
  li r24, 0

checkFrameAdvance:
  sth r24, -0x2FC(r12)				# previously 9134C904
  lis r3, 0x805C											# \ added check for frame advance state
  lbz r24, -0x75F6(r3); cmpwi r24, 0; bne- storeSpeed		# /
  lbz r24, -0x75F5(r3); cmpwi r24, 0; beq- storeSpeed		# \ updated pause check to detect all IDs	
  li r0, 0; b end											# /
  
storeSpeed:
  lwz r0, 0(r25)		# Modification of original operation which used r3
  
end:
  mr r3, r25		   # \ Restore
  mr r4, r26		   # /
}
###
op NOP      @ $8004AB7C	# normally bl 8004bfa0
op li r5, 0 @ $8004C11C #
HOOK @ $806F14C8		#
{
	mr r31, r3			# Original operation 
	li r3, 11			# \
	bla 0x0249CC		# / Get replay heap offset
	li r0, 0			# \ Set to 0 if training is starting to disable alts?
	sth r0, 0x44A(r3)	# / Previously 91301F4A
}
HOOK @ $8009C984
{
	mr r30, r3			# Original operation
	li r3, 11			# \
	bla 0x0249CC		# | Get replay heap offset
	lwz r3, 0x8(r3)		# / Get end of replay heap
	stw r31, -0x304(r3)	# Previously 9134C8FC
	mr r3, r30			# r3 is still needed
}