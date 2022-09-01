###################################################################################
Custom Physics Engine (Actions, Subactions FastFall) V1.3 [Magus, Almas, DukeItOut]
###################################################################################
HOOK @ $8085765C
{
  lwz r31, 0x70(r29)
  lwz r31, 0x20(r31)
  lwz r31,0x0C(r31)
  lwz r31,0x2D0(r31)
  lwz r31, 0x08(r31)
  lis r30, 0x9000; cmpw r31, r30; bgtlr
  lwz r31,0x110(r31)
  
  cmplwi r31, 0x7F    # \ Change this ID if using Brawl EX
  bgtlr

  lwz r30, 0x14(r29)
  lhz r30, 0x5A(r30)
  ori r30, r30, 0x8000
  lwz r29, 0x7C(r29)
  lhz r29, 0x36(r29)
  mr r12, r0
  subi r12, r12, 0x2EE0
  li r4, 0x4
  divw r12, r12, r4
  lis r4, 0x8058
  ori r4, r4, 0x5270
  mulli r5, r31, 0x4
  lwzx r4, r4, r5
  lis r0, 0x9340;  cmpw r4, r0;  bgelr

loc_0x5C:
  subi r5, r4, 0x8

loc_0x60:
  lwzu r4, 8(r5);  cmpwi r4, 0x0;  blelr

loc_0x70:
  srawi. r0, r4, 24;  cmpw r0, r31;  bnelr

loc_0x80:
  rlwinm r0, r4, 16, 24, 31;  cmpw r0, r12;  bne+ loc_0x60
  rlwinm r0, r4, 0, 16, 31;  cmpw r0, r29;  beq- loc_0xA8
  cmpwi r12, 0x1F;  bne+ loc_0x60
  cmpw r0, r30;  bne+ loc_0x60

loc_0xA8:
  lfs f1, 4(r5)
  blr 
}
############################################################
Custom Physics Engine (Subactions Other) v1.2 [Magus, Almas]
############################################################
.alias codeLoc = 0x8058549C
.macro SubAddress(<arg1>)
{
.alias temp_Hi = <arg1> / 0x10000
.alias temp_Lo = <arg1> & 0xFFFF

	lis 24, temp_Hi
	ori r24, r24, temp_Lo
	mtctr r24
	bctrl 
}
CODE @ $8058549C
{
  lis r25, 0x8120		# \
  lis r31, 0x9380		# / Safety
  cmpw r30, r31
  bgelr
  lwz r27, 0x08(r30)	# \
  lwz r27, 0x110(r27)	# / Access character ID
  cmplwi r27, 0x7F		# \ Change this ID if using Brawl EX
  bgtlr
loc_0x18:
  lwz r30, 0x14(r30)
  lhz r30, 0x5A(r30);  ori r30, r30, 0x8000
  lis r25, 0x8058;  ori r25, r25, 0x5270
  mulli r26, r27, 0x4
  lwzx r25, r25, r26
  lis r24, 0x9340;  cmpw r25, r24;  bgelr- 

loc_0x44:
  subi r26, r25, 0x8

loc_0x48:
  lwzu r25, 8(r26);  cmpwi r25, 0x0;  blelr- 
loc_0x58:
  srawi. r24, r25, 24;  cmpw r24, r27;  bnelr- 

loc_0x68:
  rlwinm r24, r25, 16, 24, 31;  cmpw r24, r29;  bne+ loc_0x48
  rlwinm r24, r25, 0, 16, 31;  cmpw r24, r30;  bne+ loc_0x48
  lwz r28, 4(r26)
  blr 
}

HOOK @ $80794B18
{
  stwu r1, -0x40(r1)
  stmw r24, 8(r1)
  lwz r28, 0x20(r3)
  mr r30, r4
  lis r25, 0x8180;  cmpw r30, r25;  bge- loc_0x68
  lwz r24, 0x1C(r30);  cmpw r24, r25;  bge- loc_0x68
  lwz r24, 0x28(r24);  cmpw r24, r25;  bge- loc_0x68
  lwz r24, 0x10(r24);  cmpw r24, r25;  bge- loc_0x68
  lbz r24, 0x08(r24);  cmpwi r24, 0x1;  bne+ loc_0x54
  li r29, 0x4
  b loc_0x58

loc_0x54:
  li r29, 0x1E

loc_0x58:	
  %SubAddress(codeLoc)

loc_0x68:
  mr r5, r28
  lmw r24, 8(r1)
  addi r1, r1, 0x40
}

HOOK @ $80867F8C
{
  stwu r1, -0x28(r1)
  stmw r24, 8(r1)
  lfs f1, 0x10(r29)
  fneg f1, f1
  stfs f1, 0x10(r2)
  lwz r28, 0x10(r2)
  li r29, 0x17
  %SubAddress(codeLoc)
skip:
  stw r28, 0x10(r2)
  lfs f1, 0x10(r2)
  fneg f1, f1
  lmw r24, 8(r1)
  addi r1, r1, 0x28
}

###################################################################
#Custom Physics Engine Initialization 1.1 [Magus, Almas, DukeItOut]
#
#1.1: Moved data out of sound resource
###################################################################
HOOK @ $80868010
{
  stwu r1, -0x28(r1)
  stmw r24, 8(r1)
  lwz r28, 0x14(r29)
  li r29, 0x18
  %SubAddress(codeLoc)
  stw r28, 0x10(r2)
  lfs f3, 0x10(r2)
  lmw r24, 8(r1)
  addi r1, r1, 0x28
}
HOOK @ $80867550
{
  stwu r1, -0x28(r1)
  stmw r24, 8(r1)
  lwz r28, 0x3C(r29)
  li r29, 0x1B
  %SubAddress(codeLoc)
  stw r28, 0x10(r2)
  lfs f1, 0x10(r2)
  lmw r24, 8(r1)
  addi r1, r1, 0x28
}
HOOK @ $80867510
{
  stwu r1, -0x28(r1)
  stmw r24, 8(r1)
  lwz r28, 0x40(r29)
  li r29, 0x1C
  mflr r12
  %SubAddress(codeLoc)
  mtlr r12
  stw r28, 0x10(r2)
  lfs f28, 0x10(r2)
  lmw r24, 8(r1)
  addi r1, r1, 0x28
}
HOOK @ $80867478
{
  stwu r1, -0x28(r1)
  stmw r24, 8(r1)
  lwz r28, 0x18(r3)
  mr r30, r4
  li r29, 0x1D
  %SubAddress(codeLoc)
  mr r6, r28
  lmw r24, 8(r1)
  addi r1, r1, 0x28
}
HOOK @ $808678E8
{
  stwu r1, -0x28(r1)
  stmw r24, 8(r1)
  lwz r28, 0x18(r29)
  li r29, 0x1D
  %SubAddress(codeLoc)
  stw r28, 0x10(r2)
  lfs f0, 0x10(r2)
  lmw r24, 8(r1)
  addi r1, r1, 0x28
}

* 205A91F8 00000001		# Only run once, even though it is a pulse command
PULSE					# Basically makes a series of pointers for each character to check for at 80585380???
{
  stwu r1, -0x20(r1)
  stmw r26, 8(r1)
//  lis r31, 0x901B;  ori r31, r31, 0x4000	# Pointer to table, below
  lis r31, 0x8058;	lwz r31, 0x5520(r31)	# Pointer to table, below
  lis r30, 0x8058;  ori r30, r30, 0x5270	# Where to write pointers to.
  lwz r26, 0(r31);  cmpwi r26, 0x0;  ble- loc_0x50	# Prevent from accessing table if it doesn't exist yet or has been written???
  srawi r26, r26, 24

loc_0x28:
  mr r27, r26			
  mulli r28, r26, 0x4
  stwx r31, r30, r28

loc_0x34:
  lwzu r26, 8(r31);  	cmpwi r26, 0x0;  ble- loc_0x50
  srawi r26, r26, 24;	cmpw r26, r27;  beq+ loc_0x34
  b loc_0x28

loc_0x50:
  lmw r26, 8(r1)
  addi r1, r1, 0x20
  blr 
}
int 2 @ $805A91F8		# Don't run this again
.RESET

Custom Physics Data
.BA<-PHYSICS_DATA
.BA->$80585520
.GOTO->Skip


# if the half is is a four-digit value led by an 8, it's a subaction. Otherwise, it is an action.
# action 0x03: Dash
# action 0x04: Run
# action 0x08: TurnRun
# action 0x0D: Multijump
# action >0x111: Special move
# first byte for each block is the character
# second byte is ???
# half is the action/subaction
# float is the value to modify into
PHYSICS_DATA:
	byte[2] 0x00, 0x06; half 4; float 0.38			# Mario
	byte[2] 0x01, 0x06; half 4; float 0.33			# Donkey Kong
	byte[2] 0x02, 0x06; half 4; float 0.58			# Link
	byte[2] 0x03, 0x06; half 4; float 0.58			# Samus
	byte[2] 0x04, 0x06; half 4; float 0.48			# Yoshi
	byte[2] 0x05, 0x06; half 4; float 0.48			# Kirby
	byte[2] 0x06, 0x06; half 4; float 0.58			# Fox
	
	byte[2] 0x07, 0x06; half 4; float 0.48			# Pikachu
	byte[2] 0x07, 0x1B; half 0x81DB; float 0		# \ Quick Attack aerial start physics
	byte[2] 0x07, 0x1C; half 0x81DB; float 0		# |
	byte[2] 0x07, 0x1E; half 0x81DB; float 0		# /
	byte[2] 0x07, 0x1B; half 0x81DA; float 0		# \ Quick Attack grounded end physics
	byte[2] 0x07, 0x1C; half 0x81DA; float 0		# /
	byte[2] 0x07, 0x1B; half 0x81DC; float 0		# \ Quick Attack aerial end physics
	byte[2] 0x07, 0x1C; half 0x81DC; float 0		# /
	byte[2] 0x07, 0x1E; half 0x0118; float 0		# Quick Attack ending physics
	
	byte[2] 0x08, 0x06; half 4; float 0.38			# Luigi
	
	byte[2] 0x09, 0x06; half 4; float 0.59			# Captain Falcon
	byte[2] 0x09, 0x1B; half 0x81D6; float 0.024	# \
	byte[2] 0x09, 0x1B; half 0x81D7; float 0.024	# |
	byte[2] 0x09, 0x1D; half 0x81D6; float 0.952	# | Falcon Dive physics
	byte[2] 0x09, 0x1D; half 0x81D7; float 0.952	# |
	byte[2] 0x09, 0x1E; half 0x81D6; float 1.12		# |
	byte[2] 0x09, 0x1E; half 0x81D7; float 1.12		# /
	
	byte[2] 0x0A, 0x06; half 4; float 1.12			# Ness
	byte[2] 0x0B, 0x06; half 4; float 1.12			# Bowser
	
	byte[2] 0x0C, 0x06; half 4; float 0.58			# Peach
	byte[2] 0x0C, 0x1C; half 0x11A; float 0			#	Parasol physics
	
	byte[2] 0x0D, 0x06; half 4; float 0.58			# Zelda
	byte[2] 0x0E, 0x06; half 4; float 0.58			# Sheik
	byte[2] 0x0F, 0x06; half 4; float 0.33			# Ice Climbers
	byte[2] 0x11, 0x06; half 4; float 0.3			# Marth
	byte[2] 0x12, 0x06; half 4; float 0.38			# Mr. Game & Watch
	byte[2] 0x13, 0x06; half 4; float 0.58			# Falco
	
	byte[2] 0x14, 0x06; half 4; float 0.44			# Ganondorf
	byte[2] 0x14, 0x1B; half 0x112; float 0			# \
	byte[2] 0x14, 0x1C; half 0x112; float 1.0		# | Cape physics
	byte[2] 0x14, 0x1D; half 0x112; float 0			# |
	byte[2] 0x14, 0x1E; half 0x112; float 0			# /
	byte[2] 0x14, 0x1B; half 0x117; float 0			# \
	byte[2] 0x14, 0x1C; half 0x117; float 0			# | Cape reflect attack physics
	byte[2] 0x14, 0x1D; half 0x117; float 0			# |
	byte[2] 0x14, 0x1E; half 0x117; float 0			# /
	byte[2] 0x14, 0x1B; half 0x81D8; float 0.024	# \ Dark Dive physics
	byte[2] 0x14, 0x1B; half 0x81D9; float 0.024	# |
	byte[2] 0x14, 0x1E; half 0x114; float 0.78		# /
	
	byte[2] 0x15, 0x06; half 4; float 0.38			# Wario
	
	byte[2] 0x16, 0x06; half 4; float 0.48			# Meta-Knight
	byte[2] 0x16, 0x1B; half 0x118; float 0.02		# \
	byte[2] 0x16, 0x1C; half 0x118; float 0.02		# |
	byte[2] 0x16, 0x1E; half 0x118; float 0.05		# /
	
	byte[2] 0x17, 0x06; half 4; float 0.58			# Pit
	byte[2] 0x17, 0x1B; half 0x0D; float 0.0797546	# \
	byte[2] 0x17, 0x1C; half 0x0D; float 0			# | Multi-jump physics
	byte[2] 0x17, 0x1D; half 0x0D; float 0.875		# /
	byte[2] 0x17, 0x1B; half 0x114; float 0.02		#
	
	byte[2] 0x18, 0x06; half 4; float 0.48			# Zero Suit Samus
	byte[2] 0x19, 0x06; half 4; float 0.33			# Olimar
	byte[2] 0x1A, 0x06; half 4; float 0.28			# Lucas
	byte[2] 0x1B, 0x06; half 4; float 0.58			# Diddy Kong
	
	byte[2] 0x1D, 0x06; half 4; float 0.33			# Charizard
	byte[2] 0x1D, 0x1B; half 0x0D; float 0.0536278	# \
	byte[2] 0x1D, 0x1C; half 0x0D; float 0			# | Multi-jump physics
	byte[2] 0x1D, 0x1D; half 0x0D; float 0.925		# /
	
	byte[2] 0x1E, 0x06; half 4; float 0.59			# Squirtle
	byte[2] 0x1E, 0x06; half 8; float 0.215			# 	Turning around
	
	byte[2] 0x1F, 0x06; half 4; float 0.38			# Ivysaur
	
	byte[2] 0x20, 0x06; half 4; float 0.28			# Dedede
	byte[2] 0x20, 0x1B; half 0x0D; float 0.04		# \
	byte[2] 0x20, 0x1C; half 0x0D; float 0			# | Multi-jump physics
	byte[2] 0x20, 0x1D; half 0x0D; float 0.85		# /
	
	byte[2] 0x21, 0x06; half 4; float 0.58			# Lucario
	byte[2] 0x22, 0x06; half 4; float 0.325			# Ike
	byte[2] 0x23, 0x06; half 4; float 0.58			# R.O.B.
	byte[2] 0x24, 0x06; half 4; float 0.48			# (Unused) PM Lyn data
	
	byte[2] 0x25, 0x06; half 4; float 0.405			# Jigglypuff
	byte[2] 0x25, 0x1B; half 0x0D; float 0.125874	# \
	byte[2] 0x25, 0x1C; half 0x0D; float 0			# | Multi-jump physics
	byte[2] 0x25, 0x1D; half 0x0D; float 1.08		# /
	
	byte[2] 0x26, 0x06; half 4; float 0.65			# Mewtwo
	byte[2] 0x26, 0x18; half 0x114; float 0.75		# 	Teleport physics
	byte[2] 0x26, 0x04; half 0x11C; float 0.02		# 	Teleport end physics
	
	byte[2] 0x27, 0x06; half 4; float 0.35			# Roy
	byte[2] 0x29, 0x06; half 4; float 0.58			# Toon Link
	byte[2] 0x2B, 0x06; half 4; float 0.465			# (unused) PM Isaac data
	
	byte[2] 0x2C, 0x06; half 4; float 0.58			# Wolf
	byte[2] 0x2C, 0x1B; half 0x81DA; float 0.02		# \ Fire Wolf end physics
	byte[2] 0x2C, 0x1D; half 0x81DA; float 0.9		# /
	
	byte[2] 0x2D, 0x06; half 4; float 0.68			# Knuckles
	byte[2] 0x2E, 0x06; half 4; float 0.58			# Snake
	
	byte[2] 0x2F, 0x06; half 4; float 0.28			# Sonic
	byte[2] 0x2F, 0x06; half 8; float 0.175			#	Turning around
	byte[2] 0x2F, 0x08; half 3; float 2.5			#	Dashing
	
Skip:
.RESET
* 205A91F8 00000000
* 045A91F8 00000001
* E0000000 80008000

/*
* 205A91F8 00000000
* 4A000000 90000000
* 161B4000 0000030A
* 00060004 3EC28F5C
* 01060004 3EA8F5C3
* 02060004 3F147AE1
* 03060004 3F147AE1
* 04060004 3EF5C28F
* 05060004 3EF5C28F
* 06060004 3F147AE1
* 07060004 3EF5C28F

* 071B81DB 00000000
* 071C81DB 00000000
* 071E81DB 00000000
* 071B81DA 00000000
* 071C81DA 00000000
* 071B81DC 00000000
* 071C81DC 00000000
* 071E0118 00000000

* 08060004 3EC28F5C
* 09060004 3F170A3D
* 091B81D6 3CC49BA6
* 091B81D7 3CC49BA6
* 091D81D6 3F73B646
* 091D81D7 3F73B646
* 091E81D6 3F8F5C29
* 091E81D7 3F8F5C29

* 0A060004 3E8F5C29
* 0B060004 3E8F5C29
* 0C060004 3F147AE1
* 0C1C011A 00000000

* 0D060004 3F147AE1
* 0E060004 3F147AE1
* 0F060004 3EA8F5C3
* 11060004 3E99999A
* 12060004 3EC28F5C
* 13060004 3F147AE1
* 14060004 3EE147AE

* 141B0112 00000000
* 141C0112 00000000
* 141D0112 3F800000
* 141E0112 00000000

* 141B0117 00000000
* 141C0117 00000000
* 141D0117 3F800000
* 141E0117 00000000

* 141B81D8 3CC49BA6
* 141B81D9 3CC49BA6

* 141E0114 3F47AE14

* 15060004 3EC28F5C
* 16060004 3EF5C28F
* 161B0118 3CA3D70A
* 161C0118 3C23D70A
* 161E0118 3D4CCCCD

* 17060004 3F147AE1
* 171B000D 3DA35661
* 171C000D 00000000
* 171D000D 3F600000
* 171B0114 3CA3D70A

* 18060004 3EF5C28F
* 19060004 3EA8F5C3
* 1A060004 3E8F5C29
* 1B060004 3F147AE1

* 1D060004 3EA8F5C3
* 1D1B000D 3D5BA8D3
* 1D1C000D 00000000
* 1D1D000D 3F6CCCCD

* 1E060004 3F170A3D
* 1E060008 3E5C28F6
* 1F060004 3EC28F5C
* 20060004 3E8F5C29
* 201B000D 3D23D70A
* 201C000D 00000000
* 201D000D 3F59999A

* 21060004 3F147AE1
* 22060004 3EA66666
* 23060004 3F147AE1
* 24060004 3EF5C28F

* 25060004 3ECF5C29
* 251B000D 3E00E526
* 251C000D 00000000
* 251D000D 3F8A3D71

* 26060004 3F266666
* 26180114 3F400000
* 2604011C 3CA3D70A

* 27060004 3EB33333
* 29060004 3F147AE1
* 2B060004 3EEE147B
* 2C060004 3F147AE1
* 2C1B81DA 3CA3D70A
* 2C1D81DA 3F666666

* 2D060004 3F2E147B
* 2E060004 3F147AE1
* 2F060004 3E8F5C29
* 2F060008 3E333333
* 2F080003 40200000
* 045A91F8 00000001
* E0000000 80008000
*/