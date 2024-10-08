#######################################################################
ThrowN Fix and Throw Release Points v1.1c (Throw Animation Fix) [Magus]
#######################################################################
HOOK @ $8076CCE4
{
  lwz r10, 0x70(r18)
  lwz r10, 0x24(r10)
  lwz r10, 0xC(r10)
  lwz r9, 4(r10)
  cmpwi r9, 0x2329
  bne+ loc_0x1C
  li r3, 0x3

loc_0x1C:
  lwz r4, 0x8C(r19)
}
HOOK @ $80771688
{
  stfd f1, 0x18(r2)
  lwz r3, 0x10(r31)
  lwz r3, 0x60(r3)
  addi r4, r2, 0x20
  li r5, 0x0
  lis r10, 0x8077
  ori r10, r10, 0x866C
  mtctr r10
  bctrl 
  lfd f1, 0x18(r2)
  lfs f2, 0x20(r31)
  lwz r10, 0x10(r31)# \
  lwz r9, 8(r10)	# | Char ID retrieval
  lwz r9, 0x110(r9)	# /
  cmpwi r9, 0x0;  blt- finish
  cmpwi r9, 0x80; bgt- finish	# Change this if using Brawl EX
  
  lis r8, 0x8077		# \ Pointer to offset table, below
  lwz r8, 0x1690(r8)	# /
  mulli r9, r9, 0x8
  lfsux f0, r8, r9
  fmuls f0, f0, f1
  lwz r7, 0x18(r10)
  lfs f2, 0x40(r7)
  fmuls f0, f0, f2
  lfs f2, 0x2C(r2)
  fadds f0, f2, f0
  stfs f0, 0x14(r1)
  lfs f2, 0x3C(r2)
  stfs f2, 0xC(r1)
  lfs f2, 4(r8)
finish:  
  addi r4, r1, 0x14		# \ Operations displaced by the below
  lfs f0, 0xC(r1)		# /
}
op b 0x8 @ $8077168C

	.BA<-ThrowReleaseTable
	.BA->$80771690
	.GOTO->SkipTable

#Throw Release Offset Data
ThrowReleaseTable:
float[256] |		# 0x80 * 2
	0.0, 		7.2672,	| # Mario
	-0.5, 		13.0311,| # Donkey Kong
	0.2257, 	8.5516,	| # Link
	-0.4884,	11.3475,| # Samus
	0.0,		7.0,	| # Yoshi
	0.0,		5.0,	| # Kirby
	0.0,		8.3,	| # Fox
	0.0,		5.7997, | # Pikachu
	0.0,		7.2672, | # Luigi
	-0.4884,	11.3475,| # Captain Falcon
	0.0,		6.0042, | # Ness
	-0.6,		13.725, | # Bowser
	0.0,		9.4,	| # Peach
	0.0,		9.4,	| # Zelda
	0.3466,		8.2405, | # Sheik
	0.0,		6.0042, | # Ice Climbers
	0.0,		0.0,	| # (Empty Slot) "Nana"
	0.4263,		9.8485, | # Marth
	0.0,		5.1937, | # Mr. Game & Watch
	0.0,		8.3,	| # Falco
	-0.4884,	12.3475,| # Ganondorf
	0.0,		7.0,	| # Wario
	0.0,		5.0,	| # Meta Knight
	0.2257,		8.5516, | # Pit
	0.3466,		8.2405, | # Zero Suit Samus
	0.0,		6.0042, | # Olimar
	0.0,		6.0042, | # Lucas
	0.0,		7.2672, | # Diddy Kong
	0.0,		0.0,	| # (Unusable Slot for Pokemon Trainer)
	-0.6,		9.5311, | # Charizard
	0.0,		5.0,	| # Squirtle
	0.0,		5.7997, | # Ivysaur
	-0.6,		13.725, | # Dedede
	0.0,		8.3,	| # Lucario
	0.4263,		9.8485, | # Ike
	0.2257,		10.3076,| # R.O.B.
	0.0,		9.4,	| # "PraMai"????? Is this leftover Lyn data?
	0.0,		5.0,	| # Jigglypuff
	0.2257,		10.3076,| # Mewtwo
	0.4263,		9.8485, | # Roy
	0.2257,		8.5516,	| # Waluigi ("Dr_Mario")
	0.0,		6.0042, | # Toon Link
	-0.6,		13.725,	| # Ridley ("ToonZelda")
	0.2257,		8.5516, | # "ToonSheik"????? Is this leftover Isaac data?
	0.0,		8.3,	| # Wolf
	0.0,		8.3,	| # Knuckles
	-0.4884,	11.3475,| # Snake
	0.0,		7.2672, | # Sonic
	0.0,		0.0,	| # Giga Bowser
	0.0,		7.0,	| # Wario-Man
	-0.4884,	11.3475,| # Red Alloy
	0.0,		9.4,	| # Blue Alloy	
	0.0, 		7.2672,	| # Yellow Alloy
	0.0,		5.0,	| # Green Alloy
	0.0,		0.0,	| # (Empty Slot) "Mario_Debug"
	0.0,		0.0,	| # EXFighter37
	0.0,		0.0,	| # EXFighter38
	0.0,		0.0,	| # EXFighter39
	0.0,		0.0,	| # EXFighter3A
	0.0,		0.0,	| # EXFighter3B
	0.0,		0.0,	| # EXFighter3C
	0.0,		0.0,	| # EXFighter3D
	0.0,		0.0,	| # EXFighter3E
	0.0,		0.0,	| # EXFighter3F
	0.0,		0.0,	| # EXFighter40
	0.0,		0.0,	| # EXFighter41
	0.0,		0.0,	| # EXFighter42
	0.0,		0.0,	| # EXFighter43
	0.0,		0.0,	| # EXFighter44
	0.0,		0.0,	| # EXFighter45
	0.0,		0.0,	| # EXFighter46
	0.0,		0.0,	| # EXFighter47
	0.0,		0.0,	| # EXFighter48
	0.0,		0.0,	| # EXFighter49
	0.0,		0.0,	| # EXFighter4A
	0.0,		0.0,	| # EXFighter4B
	0.0,		0.0,	| # EXFighter4C
	0.0,		0.0,	| # EXFighter4D
	0.0,		0.0,	| # EXFighter4E
	0.0,		0.0,	| # EXFighter4F
	0.0,		0.0,	| # EXFighter50
	0.0,		0.0,	| # EXFighter51
	0.0,		0.0,	| # EXFighter52
	0.0,		0.0,	| # EXFighter53
	0.0,		0.0,	| # EXFighter54
	0.0,		0.0,	| # EXFighter55
	0.0,		0.0,	| # EXFighter56
	0.0,		0.0,	| # EXFighter57
	0.0,		0.0,	| # EXFighter58
	0.0,		0.0,	| # EXFighter59
	0.0,		0.0,	| # EXFighter5A
	0.0,		0.0,	| # EXFighter5B
	0.0,		0.0,	| # EXFighter5C
	0.0,		0.0,	| # EXFighter5D
	0.0,		0.0,	| # EXFighter5E
	0.0,		0.0,	| # EXFighter5F
	0.0,		0.0,	| # EXFighter60
	0.0,		0.0,	| # EXFighter61
	-0.6,		9.5311,	| # Sceptile (EXFighter62)
	0.0,		0.0,	| # EXFighter63
	0.0,		0.0,	| # EXFighter64
	0.0,		0.0,	| # EXFighter65
	0.0,		0.0,	| # EXFighter66
	0.0,		0.0,	| # EXFighter67
	0.0,		0.0,	| # EXFighter68
	0.0,		0.0,	| # EXFighter69
	-0.4884,	11.3475,| # Red Alloy Ex(EXFighter6A)
	0.0,		9.4,	| # Blue Alloy Ex (EXFighter6B)
	0.0, 		7.2672,	| # Yellow Alloy Ex (EXFighter6C)
	0.0,		5.0,	| # Green Alloy Ex (EXFighter6D)
	0.0,		0.0,	| # EXFighter6E
	0.0,		0.0,	| # EXFighter6F
	0.0,		0.0,	| # EXFighter70
	0.0,		0.0,	| # EXFighter71
	0.0,		0.0,	| # EXFighter72
	0.0,		0.0,	| # EXFighter73
	0.0,		0.0,	| # EXFighter74
	0.0,		0.0,	| # EXFighter75
	0.0,		0.0,	| # EXFighter76
	0.0,		0.0,	| # EXFighter77
	0.0,		0.0,	| # EXFighter78
	0.0,		0.0,	| # EXFighter79
	0.0,		0.0,	| # EXFighter7A
	0.0,		0.0,	| # EXFighter7B
	0.0,		0.0,	| # EXFighter7C
	0.0,		0.0,	| # EXFighter7D
	0.0,		0.0,	| # EXFighter7E
	0.0,		0.0 	| # EXFighter7F
	
	
SkipTable:
	.RESET