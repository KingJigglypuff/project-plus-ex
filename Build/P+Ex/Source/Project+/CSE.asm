###################
# TLST file format
###################
# 0xC byte header:
# 0x0 - "TLST" 
# 0x4 - Song Count
# 0x8 - File Size (16-bit)
# 0xA - Title Block Offset (16-bit)
###################
# Song block addresses per song
#	0x00	-	Word	-	Song ID
#	0x04	-	Half	-	Song Delay (How many frames to wait before playing this song at the start of a match) -1 guarantees at the end of the countdown.
#	0x06	-	Byte	-	Song Volume (0-7F in hex or 0-127 in dec)
#	0x07	-	Byte	-	Frequency 
#	0x08	-	Half	-	Filename Offset [within Title Block]
#	0x0A	-	Half	-	Title Offset [within Title Block]
#	0x0C	-	Half	-	Song Switch Time Point (How many frames before the game ends that it switches to a pinch mode song)
#								(if 0, it never switches)
#	0x0E	-	Byte	-	Disable Stock Pinch (if non-zero, only triggers pinch themes via time)
#	0x0F	-	Byte	-	Disable Tracklist Inclusion (glosses over this song when working on a tracklist)
##################
# Block of strings [Title Block]
##################
# Commands for STNSL-TLST.exe:
#
# "song<number>_ID"
# "song<number>_volume"
# "song<number>_delay"
# "song<number>_frequency"
# "song<number>_filename"
# "song<number>_title"
# "song<number>_pinchswitchtime"
# "song<number>_nostockpinch" 
# "song<number>_hidden"
#################
# Volume does not need to be set for brstm files read off of the disc. Song start delays, however, must be manually
#	set for all song IDs that utilize them!
####################################################################################################
[Project+] Custom Sound Engine v4.2 [Dantarion, PyotrLuzhin, DukeItOut]
# 
# Allows song IDs from 0xF000 through 0xFFFF to be loaded from IDs EX_000.brstm through EX_FFF.brstm 
####################################################################################################
.alias exMusicRange_Lo = 0xF000 # lowest custom music ID possible 
.alias exMusicRange_Hi = 0xFFFF # highest custom music ID possible
.alias songFadeOutLength = 18
.alias songFadeOutStartFrame = 12 
.alias songFadeInDelay = 1

op li r3, 2 @ $801C72DC
HOOK @ $801C805C				# GetSoundType/[nw4r3snd6detail22SoundArchiveFileReaderCFUI]
{
  lis r3, 0x801C;  ori r12, r3, 0x80A8
  cmplwi r31, exMusicRange_Hi; bgt- notCustomMusic
  cmplwi r31, exMusicRange_Lo; blt+ notCustomMusic
CustomMusic:
  ori r12, r3, 0x80B0 			# Move two operations forward, relative to custom sound effects
  lis r4, 8						# \ Parameter 0x00084080 stored into 0x14(r1) (normally loaded from 0x1C(r3))
  ori r0, r4,  0x4080  			# /
  lis r4, 0x0103				# Parameter 0x01030000 stored into 0x10(r1) (normally loaded from 0x18(r3))
notCustomMusic:
  mtctr r12 
  bctr
  
}
HOOK @ $801C73D8			# ReadSoundInfo/[nw4r3snd6detail22SoundArchiveFileReaderCFUIP]
{  
  cmplwi r30, exMusicRange_Hi; bgt- notCustomMusic
  cmplwi r30, exMusicRange_Lo; bge- CustomMusic 
notCustomMusic:
  li r3, 0					# normal operation 
  b %END%
customMusic:
  lis r12, 0x801C; ori r12, r12, 0x7484
  mtctr r12
  
				stw r4, 0x00(r31) 	# \ (Brstm Information)
  li r0, 6;		stw r0, 0x04(r31)	# | (Stream ID. 6 for game music.)
  li r0, 0x40;	stw r0, 0x08(r31)	# | (Priority)
  lis r12, 0x8054					# | \
  lbz r0, -0x1022(r12)				# | |
				stw r0, 0x0C(r31)	# | / (Volume)		Configure song parameters 
  li r0, 0;		stw r0, 0x10(r31)	# |
				stw r0, 0x14(r31)	# |
				stw r0, 0x18(r31)	# /
  bctr								# Jump to after where song parameters are set
}

HOOK @ $801BD01C	# Related to calculating volume alteration for a stream
{
	lwz r12, 0x78(r29)				# Get sound ID, this special status only applies to expansion song slots!
	cmplwi r12, exMusicRange_Lo;		blt+ normalVolumeBehavior
	lwz r12, 0x4C(r29)				# Length of fade time
	cmpwi r12, songFadeOutLength;		bne+ normalVolumeBehavior
	lwz r28, 0x50(r29)				# Current fade frame
	cmpwi r28, songFadeOutStartFrame;	blt+ %END%		# Skip if too short for what is desired
	sub r12, r12, r28
	stw r12, 0x4C(r29)
	li r12, 1
	stw r12, 0x50(r29)
normalVolumeBehavior:	
	stfs f31, 0x8(r31)				# Original operation, sets stream volume
}
HOOK @ $801BD078	# This code fixes an issue where music fade outs that are too rapid make a pop sound
{
	li r0, 0		# Original operation
	lwz  r3, 0x8(r31)	# Song volume. Stored as float, but ints and floats both store 0 the same way.
	cmpwi r3, 0		# Check if non-zero. If it is non-zero, the sound will make a pop noise 
	beq+ %END%		# 	on termination. We don't want that! If it is 0, though, proceed!
	stw r0, 0x8(r31)	# Blank out volume
	li r12, 1
	stw r12, 0x50(r29)	# Reset time to start fade
	li r12, 60
	stw r12, 0x4C(r29)	# Require a second of silence before dropping out!
	lis r12, 0x801B			# \
	ori r12, r12, 0xD098	# |
	mtctr r12				# | Branch as if it hasn't been long enough!
	bctr					# /
}
op b    0x18 @ $80073E30	# Forces song streams to not be terminated when transitioning unless meeting the desired fade 


HOOK @ $806D2164			# process/scMelee
{

	lis r12, 0x9018				# \ 
	lbz r0, -0xC88(r12)			# | Super Sudden Death automatically makes the pinch song play! Don't calculate!
	cmpwi r0, 1					# |
	beq skipToggle 				# /	
	lbz r0, -0xC82(r12)    		# \
	cmpwi r0, 1        			# | The above also applies to Wild Brawl
	beq skipToggle        		# /
    lbz r0, -0xC81(r12)			# \
    cmpwi r0, 1					# | As well as Bomb Rain Mode
    beq skipToggle				# /
	
	lis r12, 0x805A				# \
	lwz r12, 0x60(r12)			# |
	lwz r12, 0x4(r12)			# |
	lwz r4, 0x54(r12)			# |
	lwz r12, 0x4C(r12)			# |\
	cmpwi r12, 0				# || Check if valid
	beq skipToggle				# |/
	lwz r12, 0x40(r12)			# |\ Check if in Sudden Death
	cmpwi r12, 0				# ||
	bne skipToggle				# |/
	lwz r4, 0xE4(r4)			# | Frames into match
	cmpwi r4, 0					# |
	lis r12, 0x8054				# |	
	bne+ noReset				# / Reset pinch mode status if loading a stage!

	lis r3, 0x80B9				# \
	lwz r3, -0x5898(r3)			# |
	cmpwi r3, 0					# | Don't trigger too early! Characters should be loaded, first!
	beq skipToggle				# /
	lbz r3, -0x1040(r12)		# \
	andi. r0, r3, 1				# |
	beq+ noReset				# /
	li r0, 0					# \
	stb r0, -0x1040(r12)		# |
	andi. r0, r3, 2				# | CSE sets the second bit if an alternative song is found
	li r3, 0					# |
	bne+ forceSongReset			# /
noReset:
	lhz r3, -0x1054(r12)		# \ Don't trigger if the value suggests it never should!
	cmpwi r3, 0					# |
	beq+ noPinchMode			# /
checkPinchRange:
	lwz r3, -0x4250(r13)		# \
	lwz r0, 0x6E4(r3)			# / Retrieve song ID
	cmplwi r0, exMusicRange_Lo	# \ Don't use this on Brawl disc brstms!
	blt+ skipToggle				# /
	lbz r3, -0x1040(r12)		#  Check if pinch mode is enabled.
	cmpwi r3, 0					# \ If a pinch mode song is enabled already, don't re-enable it!
	bne skipToggle				# /
	
	lis r12, 0x8063				# \
	lwz r12, -0x4C4C(r12)		# / Get the stage ID
	cmpwi r12, -1				# \ Pinch mode songs can only activate when inside a stage!
	beq skipToggle				# /
checkSuddenDeath:
	cmpwi r4, 0x0				# \ Only run when the match has started!
	beq- skipToggle				# /	
checkStockMatch:
	lis r12, 0x9018				# \ Load rule mode
	lbz r12, -0xC9E(r12)		# /
	cmpwi r12, 1				# \ Only stock matches check stock counts!
	bne+ checkTime				# /
	lis r12, 0x8054				# \
	lbz r12, -0x1052(r12)		# | Don't trigger if it is set to not occur due to stock counts!
	andi. r12, r12, 1			# |
	bne- checkTime				# /
checkPlayerCount:
	li r6, 0
	li r7, 0
	li r8, 0
stockCheckLoop:
	lis r3, 0x80B9				# \
	lwz r3, -0x5898(r3)			# |
	cmpwi r3, 0					# |\Prevents stage load crash
	beq skipToggle				# |/
	lis r12, 0x8095				# |
	ori r12, r12, 0x7D7C		# | Get the stock count for this port
	mr r4, r6					# |
	mtctr r12					# |	
	bctrl						# /
	cmpwi r3, 0
	beq- no_stocks
	addi r8, r8, 1
no_stocks:			
	cmpwi r3, 1
	bne+ notOneStock			# Only triggers based on stock count if a player has only a stock left!
checkStamina:
	lis r12, 0x9018				# \ 
	lbz r12, -0xC88(r12)		# | Stamina mode has another prerequisite: the player being under 100HP!
	cmpwi r12, 2				# |
	bne+ not_stamina			# /
stamina:
	lis r3, 0x805A				# \
	lwz r3, 0x60(r3)			# |
	lwz r3, 0x4(r3)				# |
	lwz r3, 0x68(r3)			# | Get the stamina health for this port.
	mulli r4, r6, 4				# |
	addi r4, r4, 0xD0			# |
	lwzx r3, r3, r4				# |
	cmpwi r3, 100				# |
	bge+ notBelow100HP			# /
not_stamina:	
	addi r7, r7, 1				# Increment count of amount of players at 1 stock, currently.
notOneStock:
notBelow100HP:
	addi r6, r6, 1				# \
	cmpwi r6, 4					# | Do the loop for all four ports
	blt stockCheckLoop			# /
	cmpwi r8, 2					# \ Only trigger based on stock scenario if it is at or down to two characters!
	bne+ checkTime				# /
	cmpwi r7, 1					# \
	bge+ skipTime				# / Force it to happen during stock matches if at least one of these two is down to their final stock!
checkTime:
	lis r12, 0x805A				# \
	lwz r12, 0x60(r12)			# |
	lwz r12, 0x4(r12)			# | Get decrementing stage timer
	lwz r12, 0x54(r12)			# |
	lwz r12, 0xE0(r12)			# /
	lis r4, 0x8054				# \ Get the timer for changing that the song uses
	lhz r4, -0x1054(r4)			# /
	cmpwi r12, 0				# \ Ignore time if disabled.
	beq skipToggle				# / 
	cmpw r12, r4				# \ Check if the timer is less than the change position
	bge+ skipToggle				# / if not, don't activate.
skipTime:
switchSongs:
	li r3, 1
forceSongReset:
	lis r12, 0x8054
	stb r3, -0x1040(r12)
	stwu r1, -0x10(r1)
	lwz r3, -0x4250(r13)		# \
	lwz r0, 0x6E4(r3)			# | \ Preserve song ID
	stw r0, 0x8(r1)				# | /
	li r4, songFadeOutLength	# Fadeout time in frames. 
	lis r12, 0x8007				# |
	ori r12, r12, 0x3F84		# | Stop the music!
	mtctr r12					# |
	bctrl						# /

skipJank:	
	lwz r5, 0x8(r1)				# Retrieve song ID
	lis r6, 0x805A				# \ Retrieve song object
	lwz r6, 0x1D8(r6)			# /
	li r4, 0					# \ Reset the counter for how long the current stage song has been playing.
	li r3, 1					# | Stop the song.
	li r0, songFadeInDelay		# | Startup delay time in frames. 1 is the soonest a song can start. If it is 0, it will never play!
								# | 
	lwz r1, 0(r1)				# | 
	stw r5, 0x178(r6)			# | set the song ID
	stw r4, 0x180(r6)			# |
	stb r3, 0x18C(r6)			# |
	stw r0, 0x17C(r6)			# /

setSong:
	lis r3, 0x80B9
	lwz r3, -0x5BD8(r3)
	cmpwi r3, 0; beq skipToggle	# Avoid this if it is blank due to deallocation of the music going on
	li r4, 0
	lis r5, 0x80AE
	lfs f1, -0x54C8(r5)
	stb r4, 0x184(r3)
	stw r4, 0x188(r3)
	stfs f1, 0x18C(r3)

noPinchMode:
skipToggle:	
	mr r3, r29					# Restore r3
	lwz r5, 0x64(r3)			# Restore r5
	lhz r4, 0xF4(r3)			# Original operation
}



HOOK @ $801C7D00 		# ReadSoundInfo/[nw4r3snd6detail22SoundArchiveFileReaderCFUI]
{
  lwz r12, 0x78(r24) # Get the song ID
  cmplwi r12, exMusicRange_Hi; bgt- notCustomMusic
  cmplwi r12, exMusicRange_Lo; bge- CustomMusic
notCustomMusic:
  li r3, 0x0			# normal operation, read if the sound info is an inappropriate range
  b %END%
CustomMusic:
  lis r3, 0xC; ori r3, r3, 0xDE3C;  stw r3, 0x0(r29)	# \ Parameters 
  lis r0, 0x0100;    			    stw r0, 0x4(r29)	# /
  stwu r1, -0x280(r1)
  stw r8, 0x08(r1)
  stw r5, 0x0C(r1)
  stw r6, 0x10(r1)
  stw r7, 0x14(r1)
  
    mr r4, r12
    lis r12, 0x8053				# Custom song filename
    ori r12, r12, 0xF200 
	stw r4, -0x22C(r12)
	addi r6, r12, 0xC			# Go past header
	li r7, 0
	lwz r8, 0x4(r12)			# \ Song count
	mtctr r8					# /
	cmpwi r8, 0					# \
	beq didNotFind				# / Avoids feedback loop error
songLoop:	
	lwzx r0, r6, r7				# \
	cmpw r4, r0					# | Is this the right song?
	beq- foundSong				# /
	addi r7, r7, 0x10			# Size of each song block
	bdnz+ songLoop
	b didNotFind				# Write default info in this case

foundSong:
	add r4, r6, r7	
	lbz r0, 0x6(r4)				# \ (Song Volume)
	stb r0, -0x222(r12)			# |
	lwz r3, -0x10(r11)			# |Really hacky design, but should work
	stw r0, 0xC(r3)				# /
	lhz r0, 0x8(r4)				# Load filename
	cmplwi r0, 0xFFFF
	beq- noFilename
	lhz r5, 0xA(r12)			# \ Get offset to string table
	add r5, r5, r12				# |
	add r5, r5, r0				# | and store filename to 805ECFD0
	stw r5, -0x230(r12)			# /
noFilename:
	lhz r0, 0xA(r4)
	cmplwi r0, 0xFFFF
	beq- noTitle
	lhz r5, 0xA(r12)			# \ Get offset to string table
	add r5, r5, r12				# \ Get offset to string table
	add r5, r5, r0				# | and store title to 805ECFD8
	stw r5, -0x228(r12)			# /
noTitle:
	lwz r5, -0x230(r12)
	lwz r0, -0x228(r12)
	cmpwi r5, 0
	bne hasFilename
	stw r0, -0x230(r12)			# Place the title in the filename
	cmpwi r0, 0
	bne hasFilename
didNotFind:	
	lis r5, 0x817F				# \ "000.brstm" default stream
	ori r5, r5, 0x7E28			# |
	stw r5, -0x230(r12)			# /	
	lis r5, 0x8047				# \ "ERROR" title
	ori r5, r5, 0xF4E9			# |
	stw r5, -0x228(r12)			# /
hasFilename:
didNotFind:

  addi r3, r1, 0x30 
  stw r3, 0x8(r29)	# filename pointer for later  
  addi r4, r1, 0x20	 # pointer to "%s/%s%s"
  lis r7, 0x2573; ori r7, r7, 0x2F25; stw r7, 0x00(r4)		#\ "%s/% s%s"
  lis r7, 0x7325; ori r7, r7, 0x7300; stw r7, 0x04(r4)		# /
  lis r8, 0x817F 
  ori r5, r8, 0x7E23				# pointer to "strm"
  lis r12, 0x8054					# \ Access custom song filename
  lwz r6, -0x1030(r12)				# /
  ori r7, r8, 0x7E2B				# pointer to ".brstm"
  ori r8, r8, 0x7E28				# "000.brstm"
  cmpw r6, r8						# if trying to access the blank brstm
  bne+ actualFile
  addi r7, r8, 9					# Just nullify r7
  b normalSongMode
actualFile:
	lis r12, 0x805A				# \
	lwz r12, 0x60(r12)			# |
	lwz r12, 0x4(r12)			# |
	lwz r12, 0x4C(r12)			# |
	cmpwi r12, 0				# |
	beq doNotForce				# |
	lwz r12, 0x40(r12)			# |\
	cmpwi r12, 0				# ||Check if in Sudden Death
	bne startWithPinch			# //
	
  lis r12, 0x9018				# \ 
  lbz r0, -0xC88(r12)			# | Super Sudden Death automatically makes the pinch song play!
  cmpwi r0, 1					# |
  beq startWithPinch			# /	
  lbz r0, -0xC82(r12)    		# \
  cmpwi r0, 1        			# | The above also applies to Wild Brawl
  beq startWithPinch        	# /
  lbz r0, -0xC81(r12)			# \
  cmpwi r0, 1					# | As well as Bomb Rain Mode
  bne doNotForce				# /
startWithPinch:  
  li r0, 1						# \
  lis r12, 0x8054				# | Set to pinch status
  stb r0, -0x1040(r12)			# /
doNotForce:
  lwz r3, 0x8(r29)					# Restore r3
  lis r12, 0x8054					# \ Check if pinch mode is enabled.
  lbz r8, -0x1040(r12)				# |
  cmpwi r8, 1						# |
  bne normalSongMode				# /
  stwu r1, -0xD0(r1)
  stw r4, 0x8(r1)					# \
  stw r5, 0xC(r1)					# |
  stw r6, 0x10(r1)					# | Preserve old filename
  stw r7, 0x14(r1)					# /
  lis r12, 0x8054					# \ load "_b.brstm" from 8053EFB0
  lwz r7, -0x1050(r12)				# /					
  lis r12, 0x803F;  ori r12, r12, 0x89FC	# sprintf
  mtctr r12									#
  bctrl										#  
  addi r3, r1, 0x30
  lis r4, 0x8048			#
  ori r4, r4, 0xEFF4		# %s%s%s%s
  lis r5, 0x8059							# \ "sd:"
  ori r5, r5, 0xC568						# /
  lis r6, 0x8040							# \ pointer to mod folder name
  ori r6, r6, 0x6920						# /
  lis r7, 0x8053							# \ "pf/sound/"
  ori r7, r7, 0xEFB4						# /
  lwz r7, 0(r7)
  lwz r8, 0x8(r29)							# string pointer above

  lis r12, 0x803F;  ori r12, r12, 0x89FC	# sprintf
  mtctr r12									#
  bctrl										#  
  addi r3, r1, 0x30
  lis r12, 0x8001; ori r12, r12, 0xF084		# \
  mtctr r12									# | Check if the file is on the DVD 
  bctrl										# |
  cmpwi r3, 0								# | if it is, use that, don't bother with what is on the SD
  beq+ noPinchModeSong 						# /
  lwz r1, 0(r1)  
  lis r12, 0x8054
  li r8, 3
  stb r8, -0x1040(r12)  
  b utilizePinchModeSong  
noPinchModeSong:
  lwz r4, 0x8(r1)			# Restore name for brstm file
  lwz r5, 0xC(r1)
  lwz r6, 0x10(r1)
  lwz r7, 0x14(r1)
  lwz r1, 0(r1)  
  lwz r3, 0x8(r29)
  addi r4, r1, 0x20
normalSongMode:
  lis r12, 0x803F;  ori r12, r12, 0x89FC	# sprintf
  mtctr r12									#
  bctrl  #
utilizePinchModeSong:
  lwz r8, 0x08(r1)
  lwz r5, 0x0C(r1)
  lwz r6, 0x10(r1)
  lwz r7, 0x14(r1)
  addi r1, r1, 0x280 
  li r3, 0x1
  li r0, 0x0			
  stw r0, 0xC(r29)
}

HOOK @ $801C6CE8		# detail_OpenFileStream/[nw4r3snd12SoundArchiveCFUIPvi]
{
  lis r12, 0x8001; ori r12, r12, 0xF084		# \
  mtctr r12									# | Check if the file is on the DVD 
  bctrl										# |
  cmpwi r3, 1								# | if it is, use that, don't bother with what is on the SD
  beq+ discFileSkip 						# /
  lis r6, 0x8000; ori r6, r6, 0x3140
  lhz r6, 0(r6)
  cmpwi r6, 0x25; beq- homebrewSkip		# Inexplicably, homebrew does not interpret this the same way as hackless
  lwz r12, 0x78(r24) # Get the song ID
  cmplwi r12, exMusicRange_Hi; bgt- notCustomMusic
  cmplwi r12, exMusicRange_Lo; blt+ notCustomMusic
  addi r3, r27, 0xC 
  lis r4, 0x817F; ori r4, r4, 0x7E28 		# "000.brstm"
  lis r12, 0x803F;  ori r12, r12, 0xA280	# strcpy
  mtctr r12									#
  bctrl										# Spoof a brstm on the DVD 
homebrewSkip:
discFileSkip:
notCustomMusic:
  lwz r12, 0(r29)							# Original operation
}