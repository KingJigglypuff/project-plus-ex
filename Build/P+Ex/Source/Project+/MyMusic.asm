##########################################
CMM:Custom My Music V2 	 [JOJI, DukeItOut]
##########################################
.alias tlstHeaderSize = 0xC		# Data block size for the header
.alias tlstSongSize = 0x10		# Data block size for each available song

int16_t 0x00FF @ $8117E12A		# \ Amount of tracklists available. (Normally 0x2D, or 45, used as a safety)
int16_t 0x00FF @ $8117E102		# /
### Get the frequency of the song
HOOK @ $80078D30		
{
	lis r12, 0x8053					# \ Pointer to tracklist file
	ori r12, r12, 0xF200			# /
	lwz r8, 0x4(r12)				# \ Song count
	mtctr r8						# /
	addi r12, r12, tlstHeaderSize	# Move to the song list
	li r7, 0
songLoop:	
	lwzx r0, r12, r7			# \
	cmpw r5, r0					# | Is this the right song?
	beq- foundSong				# /
	addi r7, r7, tlstSongSize	# Size of each song block
	bdnz+ songLoop
	b notFoundInTLST
foundSong:
	add r3, r12, r7
	lbz r3, 0x7(r3)				# Get the frequency of this song
	blr
notFoundInTLST:
	rlwinm r0, r4, 2, 0, 29		# original operation
}
### Set the frequency of the song
HOOK @ $80078CD8
{
	lis r12, 0x8053					# \ Pointer to tracklist file
	ori r12, r12, 0xF200			# /
	lwz r8, 0x4(r12)				# \ Song count
	mtctr r8						# /
	addi r12, r12, tlstHeaderSize	# Move to the song list
	li r7, 0
songLoop:	
	lwzx r0, r12, r7			# \
	cmpw r5, r0					# | Is this the right song?
	beq- foundSong				# /
	addi r7, r7, tlstSongSize	# Size of each song block
	bdnz+ songLoop
	b notFoundInTLST
foundSong:
	add r3, r12, r7
	stb r6, 0x7(r3)				# Set the frequency of this song, which is in r6
	blr
notFoundInTLST:
	rlwinm r0, r4, 2, 0, 29		# original operation
}


###################################
.macro LoadSongCount(<arg1>)
{
	lis r12, 0x8053				# \ Pointer to tracklist file
	ori r12, r12, 0xF200		# /
	lwz <arg1>, 0x4(r12)		# Get song count (for initializing song list)
}
###
HOOK @ $80078D8C				# Alter how the song ID is obtained
{
	lis r12, 0x8053				# Offset of tracklist file's songs
	ori r12, r12, tlstHeaderSize+0xF200	
	mulli r4, r5, tlstSongSize	# Size of each song's section
	lwzx r3, r12, r4			# Get the song ID
	add r4, r12, r4				# \
	blr
}
### 
op NOP @ $800786E8
HOOK @ $800786EC
{
	lis r4, 0x8054			# \ Pull up startup delay from file data. More aggressive than the below, used for swapping songs mid-match!
	lhz r4, -0x1024(r4)		# /
}
CODE @ $800791F0
{
	lis r3, 0x8054			# \ Pull up startup delay from file data. Used for handling timing when starting a match.
	lhz r3, -0x1024(r3)		# /
}
###
HOOK @ $8010F9F4
{
	stwu r1, -0x20(r1)
	stw r4, 0x8(r1)
	stw r5, 0xC(r1)
	stw r6, 0x10(r1)
	
	lis r12, 0x8053
	ori r12, r12, 0xF200

	lwz r0, 4(r12)					# \ Get songcount
	mtctr r0						# /
	addi r5, r12, tlstHeaderSize	# Go past header
	li r6, 0
songLoop:
	lwzx r4, r5, r6
	cmpw r3, r4
	beq foundSong
	addi r6, r6, tlstSongSize
	bdnz+ songLoop
	li r3, 0
foundSong:
	add r4, r5, r6
	lwz r6, 0x10(r1)
	lwz r5, 0xC(r1)
	lwz r4, 0x8(r1)
	addi r1, r1, 0x20
	rlwinm r0, r28, 24, 0, 7	# Original operation
}
###
HOOK @ $8117E144
{
	%LoadSongCount(r27)
}
op NOP @ $8117E168				#\
op NOP @ $8117E170				#/ Disable check for if the song is hidden.
###
HOOK @ $8117E0A8
{
	%LoadSongCount(r28)
}
op NOP @ $8117E0C4				#\
op NOP @ $8117E0CC				#/ Disable check for if the song is hidden.
###
HOOK @ $8117E04C
{
	%LoadSongCount(r28)
}
op NOP @ $8117E068				#\
op NOP @ $8117E070				#/ Disable check for if the song is hidden.

### Obtain the song frequency when rolling RNG
half 1 @ $800792BA				# Increment by 1 to make it easier to track the song count
op li r26, 0 @ $80079290
HOOK @ $800792C0
{
	lis r12, 0x8053				
	ori r12, r12, tlstHeaderSize+0xF200
	mulli r3, r26, tlstSongSize
	add r3, r12, r3
}
HOOK @ $800792AC
{
	lis r12, 0x8053
	ori r12, r12, tlstHeaderSize+0xF200
	mulli r3, r26, tlstSongSize	# Size of each song list member
	add r3, r12, r3				# Get the address for the song
}
HOOK @ $800792C8
{
	lwz r0, -0x8(r12)			# Song count at 805EF204
	cmpw r26, r0				# Check if we reached the tracklist size, yet.
}
op blt+ -0x34 @ $800792CC		# Change how the loop is interpreted
op NOP @ $8007929C				#\
op NOP @ $800792A4				#/ Disable check for if the song is hidden.

### Check if the song matches the RNG range
op li r27, 0 @ $80079300					# Tracklists are no longer offset from each other
op mr 0, r27 @ $8007932C					# Get an offset to the next song
op addi r27, r27, tlstSongSize @ $8007935A	# Songs are separated by 0x10, not 0x8 

### Obtain the song that RNG suggests via the frequencies brought up, above
op b -0x68  @ $80079370		# Optimizes out a loop for easier reading
op NOP @ $8007930C				#\
op NOP @ $80079314				#/ Disable check for if the song is hidden.
HOOK @ $80079360
{
	lis r12, 0x8053			# Offset past TLST header
	ori r0, r12, tlstHeaderSize+0xF200
}
HOOK @ $80079318
{
	lis r12, 0x8053			# Offset past TLST header
	ori r4, r12, tlstHeaderSize+0xF200
}
half 0x3458 @ $80454500			# Display the song ID in hex
###
op b 0x30   @ $8117DFA0		# \ Disable checks for values related to unlocking songs
op b 0x30   @ $8117DFE8		# | 
op b 0x48   @ $8117E0AC		# |
op li r0, 0 @ $8117E040		# /
### Forces the menu to load the config param, which houses menu music
HOOK @ $8068391C	# Main Menu
{
	li r3, 0x26		# Config/Menu tlst
	lis r12, 0x8053
	ori r12, r12, 0xE000
	mtctr r12
	bctrl
	lis r3, 0x805A		# Original operation
}
HOOK @ $806CE18C	# Lower Menus
{
	li r3, 0x26		# Config/Menu tlst
	lis r12, 0x8053
	ori r12, r12, 0xE000
	mtctr r12
	bctrl
	li r3, 0x1		# Original operation
}


##################################
Enable Hanenbow in My Music [Desi]
##################################
op NOP @ $806B1E80


#########################################################################################################
[Legacy TE] My Music track frequency button shortcuts V2.1 (TLST file support) [Fracture, DukeItOut, Eon]
#########################################################################################################
HOOK @ $8117E698
{
  stw r0, -4(r1)
  mflr r0
  stw r0, 4(r1)
  mfctr r0
  stw r0, -8(r1)
  stfd f0, -0x10(r1)
  stwu r1, -0x8C(r1)
  stmw r3, 8(r1)
  li r28, 0x0
  lis r29, 0x805B
  ori r29, r29, 0xAD04
  li r31, 0x0
  cmpwi r31, 0x100
  bge- loc_0x4C

loc_0x38:
  lwzx r30, r29, r31
  or r28, r28, r30
  addi r31, r31, 0x40
  cmpwi r31, 0x100
  blt+ loc_0x38

loc_0x4C:
  lis r12, 0x8054		# 8053EF70 Holds last input when doing My Music
  lwz r11, -0x1090(r12) #
  and. r11, r28, r11	# Filter the shoulder buttons
  stw r11, -0x1090(r12)	#
  bne skip				# Prevents them being sticky on selecting an L/R tracklist.


  andi. r31, r28, 0x40;  beq- loc_0x68		# Check for L
  li r6, 0x0
  lis r29, 0x42C8
  stw r29, -0x10(r1)
  lfs f1, -0x10(r1)

loc_0x68:
  andi. r31, r28, 0x20;  beq- loc_0x84		# Check for R
  li r6, 0x64
  li r29, 0x0
  stw r29, -0x10(r1)
  lfs f1, -0x10(r1)

loc_0x84:
  andi. r30, r28, 0x60;  beq- loc_0xE0		# Check for L+R
  mr r29, r3
  lwz r4, 0x670(r3)
  lhz r3, 0x42(r3)
  rlwinm r3, r3, 2, 0, 29
#Fixed to work with My Music System
  mulli r3, r3, 4
  lis r5, 0x8053
  ori r5, r5, 0xF20C
  add r5, r3, r5
  lwz r5, 0(r5)

  lis r3, 0x805A
  lwz r3, 0x1D8(r3)
  lis r0, 0x8007
  ori r0, r0, 0x8CD8
  mtctr r0
  bctrl 
  mr r3, r29
  lhz r4, 0x678(r29)
  addi r4, r4, 0x5C
  li r5, 0x9
  lis r0, 0x806A
  ori r0, r0, 0x52D4
  mtctr r0
  bctrl 

loc_0xE0:
skip:
finish:
  lmw r3, 8(r1)
  addi r1, r1, 0x8C
  lfd f0, -0x10(r1)
  lwz r0, -8(r1)
  mtctr r0
  lwz r0, 4(r1)
  mtlr r0
  lwz r0, -4(r1)
  
  stwu r1, -0x70(r1)	# Original operation
}

############################################################
Force My Music's Menu slot to load its tracklist [DukeItOut]
############################################################
CODE @ $8117DEE8		# Makes the menu load a file to access its tracklist in My Music
{
	li r7, 0x26			# Menu tracklist ID
	stw r7, 0x670(r3)	# Set it as the current
	b 0x58				# Prepare to load it
}


#############################################################
Mushroomy Kingdom's slot only loads one tracklist [DukeItOut]
#############################################################
op b 0x174	@ $8117DF88

##################################################################################
Hanenbow can display song titles, but stage builder stages can't [JOJI, DukeItOut]
##################################################################################
op cmplwi r0, 0x35 @ $80951198		# 0x35 = Stage Builder stage

##########################################
Miscellaneous Music Customizer [DukeItOut]
##########################################
.alias VSResults 		= 0xF400	# Song ID to play (0x2700 in Brawl)
.alias AllStarRest		= 0xF400	# Song ID to play (0x2707 in Brawl)
.alias BreakTheTargets	= 0x2712	# Song ID to play (0x2712 in Brawl)
CODE @ $800EB14C			# VS. Results Theme
{
	li r5, 0
	ori r4, r5, VSResults		
}
op NOP	@ $806E13B8	# Makes Classic Mode Stage 13 read the tracklist instead of always guarantee a song that may or may not be on said tracklist
op ori r0, r3, AllStarRest		@ $8010FDF0 
op ori r0, r3, BreakTheTargets	@ $8010FE18

################################
CMM Option:Special Stages [JOJI]
################################
HOOK @ $8010F9DC
{
  lbz r28, 1(r4)
  cmpwi r27, 0x34;  blt- %END%		# If ID <34 (Normal stages), then skip
  cmpwi r27, 0x35;  beq- %END%		# If ID 35 (Stage Builder Stage), then skip
  li r27, 0x0
}

#############################################################################
CMM SD File Saver (Uses SD Root Code’s Directory) [Desi, Fracture, DukeItOut]
#############################################################################
HOOK @ $8117E5C0
{
  stwu r1, -0xA0(r1)
  lis r4, 0x8053;  ori r4, r4, 0xCFF8		# 
  lwz r5, 0(r4)				# "sound/tracklist/"
  lwz r4, 4(r4)				# "%s%s.tlst"	# "sound/tracklist/" + filename + ".tlst"
  lis r12, 0x8053			# \
  ori r12, r12, 0xF000		# | Get the tracklist file name
  lwz r8, 0x18(r12)			# |
  lwz r7, 0x4(r12)			# |
  add r7, r7, r12			# |
  add r6, r8, r7			# /
  addi r3, r1, 0x40
  lis r12, 0x803F			# \
  ori r12, r12, 0x89FC		# | Create the filename string
  mtctr r12					# |
  bctrl						# /
  # string at r3 + 0x24
  addi r7, r1, 0x40		# Filename to write
  stwu r1, -0x200(r1)
  lis r4, 0x8048		# \
  ori r4, r4, 0xEFF6	# / "%s%s%s%s"
  lis r5, 0x8040		# \ Mod name
  ori r5, r5, 0x6920	# /
  lis r6, 0x7066		# \ "pf"
  stw r6, 0x10(r1)		# |
  addi r6, r1, 0x10		# /
  addi r3, r1, 0x40
  lis r12, 0x803F			# \
  ori r12, r12, 0x89FC		# | Create the filename string
  mtctr r12					# |
  bctrl						# /
  addi r3, r1, 0x10
  li r5, 0
  stw r5, 0x4(r3)
  stw r5, 0x10(r3)
  lis r4, 0x8053;  ori r4, r4, 0xF200		#\ File size and location to write
  stw r4, 0xC(r3)							# | 
  lhz r4, 0x8(r4)							#/
  stw r4, 0x8(r3)
  li  r4, -1
  stw r4, 0x14(r3)
  addi r4, r1, 0x40
  stw r4, 0(r3)
  lis r0, 0x8001		# \  
  ori r0, r0, 0xD740	# |	write to file on SD card!
  mtctr r0				# |
  bctrl 				# /
  lwz r1, 0(r1)
  lwz r1, 0(r1)
  li r26, 0x0
}

##########################################################################################################
MyMusic loads from 8053F200 instead of 81521F18 [Desi]
#
#The goal of each of these hook points is to make MyMusic read Song IDs from 8053F200 instead of 81521F18. 
#By doing this, 8117E180 can be NOP and not overwrite the Song Count at 81521F54.
##########################################################################################################
HOOK @ $8117E7B8
{
	lis r5, 0x8152
	ori r5, r5, 0x1880
	sub r3, r3, r5
	mulli r3, r3, 0x4
	lis r5, 0x8053
	ori r5, r5, 0xF20C
	add r3, r5, r3
	lwz r30, 0(r3)
}

HOOK @ $8117f0E0
{
	lis r29, 0x8152
	ori r29, r29, 0x1880
	subf r29, r28, r6
	mulli r29, r29, 0x4
	lis r6, 0x8053
	ori r6, r6, 0xF20C
	add r6, r29, r6
	lwz r6, 0(r6)
}

HOOK @ $8117F1E8
{
	lis r21, 0x8053
	ori r21, r21, 0xF20C
	mulli r9, r0, 0x4
	add r21, r21, r9
	lwz r9, 0(r21)
}

HOOK @ $8117F2E8
{
	sub r3, r25, r19
	mulli r3, r3, 0x4
	lis r5, 0x8053
	ori r5, r5, 0xF20C
	add r5, r3, r5
	lwz r5, 0 (r5)
}

HOOK @ $8117F408
{
	sub r4, r25, r19
	mulli r4, r4, 0x4
	lis r5, 0x8053
	ori r5, r5, 0xF20C
	add r5, r4, r5
	lwz r4, 0 (r5)
}
.macro Scrolling() #Scrolling and changing Odds share alot in common.
{
	sub r3, r3, r28
	mulli r3, r3, 0x4
	lis r5, 0x8053
	ori r5, r5, 0xF20C
	add r5, r3, r5
	lwz r5, 0 (r5)
}

#Scrolling Up
HOOK @ $8117EB38
{
%Scrolling()
}

#Scrolling Down
HOOK @ $8117E85C
{
%Scrolling()
}

#Lowering Odds
HOOK @ $8117EE18
{
%Scrolling()
}

#Increasing Odds
HOOK @ $8117EF50
{
%Scrolling()
}

op NOP @ $8117E180