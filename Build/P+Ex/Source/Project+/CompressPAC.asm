##################################################
Costume PAC files can be compressed V2 [DukeItOut]
##################################################
HOOK @ $8084CB10
{
	li r26, 1			# Force it to think there is compression
	li r15, -0xC0DE 	# Act as an identifier
}
HOOK @ $800453F0
{
	mr r5, r22			# Original operation
	cmpwi r15, -0xC0DE 	# Identifier check for costumes
	bne+ %END%
	li r15, -1
	lis r3, 0x8004		# \
	ori r3, r3, 0x5448	# | Force costume file to not clone.
	mtctr r3			# | This avoids a bug where uncompressed costumes can freeze when cloning. 
	bctr				# / 
}
op b 0x20 	@ $8084D068
half 0x6163	@ $80B0A652
HOOK @ $80015CAC
{
  mr r22, r3
  cmplwi r22, 0x4352
  bne+ %END%
Decompress:
  lis r12, 0x8001
  ori r12, r12, 0x5D0C
  mtctr r12
  bctr 
}

##############################################################
Costume decompression possible during boss battles [DukeItOut]
##############################################################
.macro Load()
{
    lis r3, 0x8042        # Enforce FighterTechniq, which is the decompression buffer
    ori r3, r3, 0x1BB8
    lis r12, 0x8002
    ori r12, r12, 0x44C4
    mtctr r12
    bctrl

    lis r12, 0x806B
    ori r12, r12, 0xE080
    mtctr r12
    bctr 
}
.macro Unload()
{
    lis r3, 0x8042        # make sure FighterTechniq is deallocated when done
    ori r3, r3, 0x1BB8
    lis r12, 0x8002
    ori r12, r12, 0x4790
    mtctr r12
    bctrl
    lis r3, 0x8042
}

HOOK @ $806BD714
{
	%Load()
}
HOOK @ $806BDEDC
{
	%Unload()
}
HOOK @ $806BCBBC
{
	%Unload()
}
HOOK @ $806BD284
{
	%Unload()
}
HOOK @ $806BCF8C
{
	%Unload()
}
HOOK @ $806BD9D0
{
	%Unload()
}

word 0x00F00100 @ $80421FAC # normally 16.0MB instead of 15.0MB, freed 1.0MB so there is room for decompression (1.1MB)

#####################################################################
SSE P2 Always Uses The First Costume V1.1 [DukeItOut]
#
# v1.1: Fixed issue where the first battle in the SSE could crash
#####################################################################
byte 00 @ $806DA4E3
byte 00 @ $806EBA8F
byte 00 @ $806DAFCB