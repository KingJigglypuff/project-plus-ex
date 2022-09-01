##############################################
[Project+]Slow Brawl -> Wild Brawl [DukeItOut]
##############################################
HOOK @ $80951454
{
    lis r12, 0x9018
    lbz r3, -0xC82(r12)    	# \
    cmpwi r3, 1        		# | The below only comes into play if it is the "Slow" special Brawl
    bne+ skip        		# /
    lwz r4, 0xE0(r29)
    lwz r4, 0x44(r4)
    lis r3, 0x3F80        	# \ 1.0
    stw r3, -0x4(r1)    	# /
    lis r3, 0x4100        	# \ 8.0, default speed
    stw r3, -0x8(r1)    	# /
	lis r12, 0x8054			# \ Load form 8053F028
	lwz r12, -0xFD8(r12)	# /
	cmpwi r12, 0
	beq defaultWildSetting	# Don't overwrite the default if it was left blank!
	stw r12, -0x8(r1)
defaultWildSetting:
	lis r12, 0x805E
    lfs f1, 0x4(r4)        	# Get game speed
    lfs f0, -0x4(r1)    	# Get "1.0"
    fcmpo cr0, f1, f0
    bne skip     		# It's either set or not ready to be.
    lfs f0, -0x8(r1) 	# Set the game to play at 5.0 (possibly will add customizable float to STEX files? 12.0 Spear Pillar is quite special.)
    stfs f0, 0x4(r4) 	#
skip:
    lis r3, 0x805A    	# Original operation
}
CODE @ $806DF2F0
{
    NOP; bgt- 0x10    	# Disable Slow Brawl
}