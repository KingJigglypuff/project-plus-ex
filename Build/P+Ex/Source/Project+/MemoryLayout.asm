#####################################################################
Memory Extension for FighterXResource1 [Dantarion, ASF1nk, DukeItOut]
#
# 5.33MB -> 5.57MB
#####################################################################
int 0x592000 @ $80421B44
int 0x592000 @ $80421B64
int 0x592000 @ $80421B84
int 0x592000 @ $80421BA4
int 0x592000 @ $80421E0C
int 0x592000 @ $80421E2C
int 0x592000 @ $80421EAC
int 0x592000 @ $80421ECC

##################################################
Memory Extension for FighterXResource2 [Dantarion]
#
# 0.53MB -> 0.6MB
##################################################
int 0x999A0 @ $80421B54
int 0x999A0 @ $80421B74
int 0x999A0 @ $80421B94
int 0x999A0 @ $80421BB4
int 0x999A0 @ $80421E1C
int 0x999A0 @ $80421E3C
int 0x999A0 @ $80421EBC
int 0x999A0 @ $80421EDC

#########################################
Stage Resource 6.4MB -> 6.1MB [DukeItOut]
#########################################
int 0x6199a0 @ $80421D64 # 6.1MB

###############################################################
Memory Extension for CSS/SSS MenuResource (+0.58MB) [DukeItOut]
###############################################################
#int 0x73EA00 @ $80422384 #+0.88MB version. Disabled for now so characters can take advanage of an extra 0.3MB due to the above code
int 0X6F1CA0 @ $80422384  #+0.58MB version. Keep this size synchronized with the Stage Resource change! (i.e. if Stage Resource = 6.4MB, this can be made +0.88)

###########################################
!Network Resource 1.4MB -> 1.1MB [DukeItOut]
###########################################
#Currently disabled, as with this active, entering the Home menu crashes. May consider just disabling the Home menu if things get desperate in terms of memory.
int 0x119B00 @ $804218AC

#############################################
Sound Resource 12.76MB -> 10.92MB [DukeItOut]
#
# Space used: 12.06MB (94%) -> 10.92MB (100%)
#############################################
.alias size = 0x28000    # Normally E6000
.alias size_hi = size / 0x10000
.alias size_lo = size & 0xFFFF
op li r4, 0x880 @ $8007A0D8    # \ 0x66680 block -> 0x880
op li r5, 0x880 @ $8007A0EC    # /
CODE @ $8007326C
{
    lis r31, size_hi
    ori r4, r31, size_lo
}
op ori r8, r31, size_lo @ $800732A4
int 0xAEBC00 @ $804217B4    # Normally 0xCC7C00
op li r31, 4 @ $801C8B8C    # \ Reduced from 8 music buffers to 4. (2 stereo tracks to allow music switches)
op li r31, 4 @ $801C8BC4    # /
HOOK @ $801C32C4
{
	lis r11, 0xCCCC			# \
	ori r11, r11, 0xCCCC	# | Failsafe for inaccessible SEQ files.
	cmplw r4, r11			# |
	bgelr-					# |
	cmpwi r4, 0				# |
	bgelr-					# /
	stwu r1, -0x30(r1)		# Original operation
}
HOOK @ $80079578			# Where to place new 3D sound actors
{
	li r3, 5				# 5: Sound Resource
	bla 0x0249CC			# Get pointer to it
	li r4, 5				# 5: Sound Resource
	lhz r12, 0x14(r3)		# Amount of allocations
	cmpwi r12, 162			# Of normal stages, the largest overall do not go higher than this
	blt Finish				#
	li r4, 17				# 17: Stage Resource	# SSE can generate a lot, so place in here!
Finish:
	li r3, 196				# Original operation. Allocation size.
}