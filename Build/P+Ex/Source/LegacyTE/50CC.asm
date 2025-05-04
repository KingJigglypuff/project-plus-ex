######################################################################
Individual Stock Icons (info.pac) v3.1 50CC [ds22, wiiztec, DukeItOut]
######################################################################
# V3: No longer uses a PAT animation to change textures.
# 3.1: Adapted to use a unified stock archive.
######################################################################
HOOK @ $800E2168
{
  lwz r12, 0xE8(r1) # Current fighter instance ID
  lis r11, 0x9018;  lbz r11, -0xC81(r11);  cmpwi r11, 0x2;  bne- skipASV
  
  # Checking if in All-Star Vs.?
  li r9, 0xA5
  lis r10, 0x8058;  ori r10, r10, 0x8000
  lbz r11, 2(r31)
  mulli r11, r11, 0xA0 # Each player slot is separated by 160?
  add r10, r10, r11
  lbz r11, 0x9E(r10)
  lwz r5, 0x20(r31) 
  cmpwi r5, 0x6;  bgt- loc_0x58 # More than 6 stocks?
  cmpwi r5, 0x0;  bne- ASVloop  # 0 stocks?

  lis r5, 0x8128;  ori r5, r5, 0xAE64;  lwz r5, 0(r5)
  cmpwi r5, 0x6;  ble- ASVloop # Check if 6 or less

loc_0x58:
  lbzx r12, r10, r11
  cmpwi r12, 0xCC;  bne- loc_0x6C
  li r11, 0x3
  b ASVloop

loc_0x6C:
  addi r11, r11, 0x3

ASVloop:
  lbzx r12, r10, r11
  cmpwi r12, 0xCC;  bne- skipASV # Check until invalid selection found?
  cmpwi r11, 0x0;  beq- skipASV
  li r11, 0x0
  b ASVloop

skipASV:
  mr r3, r12   # character instance ID
  bla 0x0AF5B4 # \ Get cosmetic ID
  bla 0x0AF600 # / 
  
  lbz r6, 0xED(r1)
  cmpwi r9, 0xA5;  bne- loc_0x10C	# More All-Star Vs. shenanigans?
  
  lwzx r6, r10, r11					
  rlwinm r6, r6, 16, 0, 15
  rlwinm r6, r6, 8, 24, 31
  addi r11, r11, 0x3
  stb r11, 0x9E(r10)

  cmpwi r27, 0x4;  bne- loc_0x10C	# The 5th index relative to 0?
  
  lbz r9, 0x9C(r10)
  addi r9, r9, 0x3
  stb r9, 0x9E(r10)

loc_0x10C:
  mulli r12, r3, 50				# Multiply costume separation by 50 (instead of 10)!

  add r12, r12, r6
  addi r7, r12, 0x1
  cmpwi r27, 0x0;  bne- loc_0x134
  mr r8, r4
  mr r28, r31

loc_0x134:
  mr r30, r7
loc_0x154:
  lwz r29, 0x8C(r28) # Original operation
}
op NOP @ $800E215C # normally mr r28, r31
op NOP @ $800E2160 # normally xoris r30, r4, 0x8000
op NOP @ $800E2174 # \ Suppress animation requests
op NOP @ $800E2188 # / for the stock icons.
HOOK @ $800E216C
{
	mr r3, r29		# Menu Object
	mr r4, r30		# Stock icon index
	lis r12, 0x800E
	ori r12, r12, 0x20C8
	mtctr r12
	bctrl			# Custom routine for changing a stock icon!
}

# While Effect works while shrunk, Fighter.pac injections
# make this impossible to return InfoResource to default AND shrink this.
# Maybe at a later date this will be doable.

# * 044218EC 00095F00 # Effect resource (9ED00 -> 95F00)
# * 0442190C 00180000 # InfoResource size (177200 -> 180000)

# * 04494990 00095F00 # Effect resource
# * 044949EC 80C23A60 # Force position of InfoResource in Memory???? (80C2C860 in SSBB)
# * 044949F0 00180000 # InfoResource size

#############################################################################
[Legacy TE] Transforming Characters Switch Stocks V2 [PyotrLuzhin, DukeItOut]
#
# V2: added support for reading the texture directly instead of relying upon
#	an animation.
#############################################################################
HOOK @ $800E2098
{
  lwz r12, 0x94(r1) # Try to see which function called this.
  lis r27, 0x8098;  ori r27, r27, 0x8E8C;  cmpw r12, r27;  bne- skip 	# Check summoning routine
  lis r27, 0x9018;  lbz r27, -0xC81(r27);  cmpwi r27, 0x2;  bne- NotASV # Is it All-Star Vs.?
  li r27, 0x1 # Only modify the first stock
  b GetStock

NotASV:
  li r27, 0x5 # Modify all 5 if possible!

GetStock:
  mr r28, r29

stockChangeLoop:
  lwz r3, 0x8C(r28)		# Menu Object
  mr r4, r26			# Stock icon index
  lis r12, 0x800E
  ori r12, r12, 0x20C8
  mtctr r12
  bctrl					# Custom routine for changing a stock icon!
  
  addi r28, r28, 0x4	# Move one menu object forward, as the stock icons are consecutive!
  subi r27, r27, 0x1
  cmpwi r27, 0x0		# Do what's needed for as many stocks as necessary!
  bgt- stockChangeLoop

skip:
  li r0, 2				# Original operation
}

############################################################
Stock Icons Are Universally Stored in a New Heap [DukeItOut]
############################################################
.macro stockResourcePointer(<reg>) # Currently, info is stored at 8053EEC0.
{
	lis <reg>, 0x8054			# \ StockResource
	lwz <reg>, -0x1140(<reg>)	# / 
}
.macro getStockResource()
{
	%stockResourcePointer(r3)
	lwz r3, 0xC(r3)				# pointer to textures	
}
.macro stgResultStockInit(<offset>)
{
	addi r4, r3, 1			# Stock icon ID
	lbz r3, <offset>(r16)	# Stock index.
	add r4, r4, r3			# Add that in!
	lwz r3, 0xE8(r17)		# Menu object
	bla 0x0E20C8			# See below
	lwz r3, 0xE8(r17)		# Menu object
	lfs f1, 0x18(r13)		# 1.0
	bla 0x0B784C			# Set to frame 1 (on) of VIS
}
HOOK @ $800E6998 # STGRESULT.PAC looks in StockResource
{
	%getStockResource()
} 
HOOK @ $806C899C # SelCharacter.pac looks in StockResource
{
	%getStockResource()
}
HOOK @ $806C9188 # SelMap.pac looks in StockResource
{
	%getStockResource()	
}
HOOK @ $800E20C4
{
	addi r1, r1, 0x90	# Original operation
	blr					# Make space for the below.
}
HOOK @ $800E8B0C		# STGRESULT Falls no longer use an animation
{
	%stgResultStockInit(0x98)
}
op b 0x30 @ $800E8B10		# Skip animation setting for the stock icons!
HOOK @ $800E8C08		# STGRESULT KOs no longer use an animation
{
	%stgResultStockInit(0x160)
}
op b 0x30 @ $800E8C0C		# Skip animation setting for the stock icons!

op bl -0x30A98 @ $800E82E4	# turn off visibility (going from page 2 to ready to leave) 
op bl -0x30D94 @ $800E85E0  # turn off visibility (going from page 2 to page 1 for others' falls)
op bl -0x3120C @ $800E8A58	# instead of setFrameTex, use setFrameVisible to initialize to off!

op bl -0x34CBC @ $800EC508	# turn off visibility instead of changing to an invisible texture!
op bl -0x34DC8 @ $800EC614	# turn off visibility (going from page 2 to page 1 for KOs)
op bl -0x34F00 @ $800EC74C	# turn off visibility (going from page 2 to page 1 for falls)

op bl -0x356B0 @ $800ECEFC  # turn off visibility instead of changing to an invisible texture!
op bl -0x357E0 @ $800ED02C	# turn off visibility (going from page 1 to ready to leave)
op bl -0x35904 @ $800ED150	# turn off visibility (going from page 3 to page 2)

byte 6 @ $8045A9D0 # Specific result screen props can use PAT AND VIS (and not just PAT!)


HOOK @ $800E20C8
{
	stwu r1, -0x80(r1)
	mflr r0
	stw r0, 0x84(r1)
	addi r11, r1, 0x60
	bla 0x3F131C			# Preserve r26-r31
	
	mr r29, r3				# Menu Object
	mr r5, r4				# Stock Icon ID
	li r28, 0
	
defaultToInterrogation:
	lis r4, 0x806A			# \ "InfStc.%04d"
	ori r4, r4, 0x17D0		# /
	addi r3, r1, 8			# Write string name
	bla 0x3F89FC			# sprintf
	%stockResourcePointer(r3)	# \
	addi r3, r3, 0xC			# / pointer to textures
	addi r4, r1, 8		# stock icon name
	bla 0x18D3F0		# check if the texture is in there.
	cmpwi r3, 0; bne+ Found
	addi r28, r28, 1

	li r5, 2500			# ? symbol texture ID. If not found again, bail!
	cmpwi r28, 2; bgt- Bail # Set to 2 to confirm in error check mode
	b defaultToInterrogation	# Person isn't making their build correctly.
Found:	
	addi r3, r29, 8		# the menu object's MDL0 pointer
	lis r4, 0x8045		# \ "lambert87" The material for a stock icon in info.pac.
	ori r4, r4, 0xD456	# /
	bla 0x18F258		# GetResMat
		
	mr r4, r3			# Pointer to the material
	lwz r4, 0xC(r4)		# material ID
	mr r3, r29			# the menu object
	addi r5, r1, 8		# Name of texture to change to
	# addi r6, r29, 4		# For now, assume the textures come from a bres in Info.pac!
	%stockResourcePointer(r6)	# \
	addi r6, r6, 0xC			# / pointer to textures
	bla 0x0B7224
Bail:
	addi r11, r1, 0x60
	bla 0x3F1368		# Restore r26-r31
	lwz r0, 0x84(r1)
	mtlr r0
	addi r1, r1, 0x80
	blr
}
# Shrink FighterEffect. There's a safety check that softlocks the game
# if it isn't present at all, so I had to make it really small, instead.
int 0x100 @ $80421B04	# \ Shrink Heap 26 (FighterEffect) to something silly.
int 0x100 @ $80421DCC	# | (during boss battles and subspace)
int 0x100 @ $80422434	# / (Where is this used?)
# int 0x0D00100 @ $804224B4 # 12MB -> 13MB character roll memory allocation (see below)
int 0x0E00100 @ $804224C4 # Size of Menu Resource in Credits. (16MB -> 14MB)
		# It is too big when accounting for StockResource being present! Had to shrink by at least 0.35MB
HOOK @ $80016C70 # Heaps that will always be in memory.
{
	lis r12, 0x8053		# Creating StockResource
	ori r12, r12, 0xEF00
	lwz r3, 0x04(r12)	# heap number
	lwz r4, 0x00(r12)	# name
	lwz r5, 0x08(r12)	# memory number
	lwz r6, 0x0C(r12)	# size
	bla 0x024544		# create the heap!
	mr r3, r31 		# Original operation
}
HOOK @ $806CAB2C
{
	stw r3, 0x8(r1)
	lis r3, 0x8053
	ori r3, r3, 0xEEC0	# Where to write referential pointer	
	lis r4, 0x8045
	ori r4, r4, 0xAA60	# "/menu/common/StockFaceTex.bres"
	li r5, 61			# 61: StockResource
	li r6, 0	
	li r7, 0
	bla 0x021498 		# readRequest/gfFileIOHandle
	
	lwz r3, 8(r1)	# Restore r3
	lis r5, 0x8070	# Original operation
}

.BA<-TexHeapName
.BA->$8053EF00
.GOTO->SkipHeaps
TexHeapName:
	string "StockResource"
SkipHeaps:
.RESET
int 61				@ $8053EF04	# Heap 61: StockResource
int 1 				@ $8053EF08 # MEM-2
uint32_t 0x74000 	@ $8053EF0C # (59B00 = 0.35MB) 0x74000 = 0.45MB
uint32_t 0x143800   @ $804218AC # Reduced network size slightly (1.4MB -> 1.26MB)
# 0.04MB leftover, but I may use that later for the item resource or otherwise
op li r3, 51 @ $800F1C00 # The heap to set the picture up in!
# We're using OverlayStage because it in battle is never full!