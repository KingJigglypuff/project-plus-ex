##########################################
CMM:Custom My Music V2 	 [JOJI, DukeItOut]
##########################################
.alias tlstHeaderSize = 0xC		# Data block size for the header
.alias tlstSongSize = 0x10		# Data block size for each available song

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
### Song IDs above 0xFE00 are hidden from being picked on random
CODE @ $8004f978	# gmCheckBGMIDUseEnable
{
	cmplwi r3, 0xFE00
	li r3, 1
	bltlr+
	li r3, 0
	blr
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
HOOK @ $806c44b4	# scSelEvent::start
{
	mr r30, r3
	li r3, 0x26		# Config/Menu tlst
	lis r12, 0x8053
	ori r12, r12, 0xE000
	mtctr r12
	bctrl
}

##################################
Enable Hanenbow in My Music [Desi]
##################################
op NOP @ $806B1E80

###################################################
Salty Runback Expansion Stage Music Fix [DukeItOut]
###################################################
# Fixes Salty Runback music not working 
# appropriately with expansion stages due to 
# higher values not being checked for music
###################################################
op NOP @ $8010F9C0

################################################
#Salty Runback Always Shuffles Music [DukeItOut]
# 
# Disabled on purpose, but left here for builds that want to make it shuffle.
#
#op b 0x68 @ $8010F9A8

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
