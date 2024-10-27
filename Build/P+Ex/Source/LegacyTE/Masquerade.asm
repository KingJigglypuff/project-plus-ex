#########################################################
[Legacy TE] Masquerade Costume Flags V2 [ds22, DukeItOut]
#########################################################
op subi r0, r31, 0x32 @ $8084CD48
* 02AD817C 003200FF

############################################################################################
[Legacy TE] Set Masquerade Costume Count to Zero to have up to 50 costumes v1.1b [DukeItOut]
v1.1a - Updated to Support 128 Unique Costume IDs per character
v1.1b - Fixed 128 ID Support for Kirby Hats
############################################################################################
HOOK @ $8084CFFC
{
  andi. r12, r0, 0xFFFE
  beq- masqueradeBypass
  lis r12, 0x8084
  ori r12, r12, 0xD004
  mtctr r12
  bctr 
masqueradeBypass:
  and. r0, r3, r0
}
op rlwinm r5, r23, 0, 25, 31 @ $8084D00C # Ghidra: $8085AF98 \ 
op rlwinm r5, r23, 0, 25, 31 @ $8084DED4 # Ghidra: $8085BE60 | Changed to support 128 costume IDs per char.
op rlwinm r3, r0,  0, 25, 31 @ $8081C3D4 # Ghidra: $8082A360 / 
byte 0x34		     @ $8045A374	// '4'
half 0xBB9 		     @ $800E1F0E
HOOK @ $800E1F24
{
  	cmpwi r31, 0x2D;   bne+ notWarioman
 	li r3, 9000; b %END%
notWarioman:
 	mulli r3, r3, 50
}
HOOK @ $800E8B08
{
  	cmpwi r5, 0x35;   bne+ notWarioman
 	li r3, 9000; b %END%
notWarioman:
 	mulli r3, r3, 50
}
HOOK @ $800E8C04
{
  	cmpwi r5, 0x35;   bne+ notWarioman
 	li r3, 9000; b %END%
notWarioman:
 	mulli r3, r3, 50
}
op rlwinm r6, r23, 0, 26, 31 @ $8084D518
op rlwinm r6, r23, 0, 26, 31 @ $8084D814
op rlwinm r6, r23, 0, 26, 31 @ $8084DAF0
op rlwinm r0, r23, 0, 26, 31 @ $8084CC28
op rlwinm r5, r23, 0, 26, 31 @ $8084CB6C
HOOK @ $800E1F24
{
  	cmpwi r31, 0x2D; # WARIO ->MAN<- 
	bne+ notWAH
WAH: 	li r3, 9000	 # EH HEH
  	b %END%
notWAH:
 	mulli r3, r3, 50
}
op rlwinm r0, r6, 2, 26, 29 @ $8082A830
op rlwinm r0, r6, 2, 26, 29 @ $8082AB20
op rlwinm r0, r6, 0, 28, 31 @ $8082AB3C
op rlwinm r0, r6, 0, 28, 31 @ $8082AB5C
op rlwinm r0, r6, 0, 28, 31 @ $8082AB6C
op rlwinm r0, r6, 0, 28, 31 @ $8082AB8C
op rlwinm r0, r6, 0, 28, 31 @ $8082ABAC
op rlwinm r0, r6, 0, 28, 31 @ $8082ABBC
op rlwinm r0, r6, 0, 28, 31 @ $8082ABDC
op rlwinm r0, r6, 0, 28, 31 @ $8082ABFC
op rlwinm r0, r6, 0, 28, 31 @ $8082AC0C
op rlwinm r0, r6, 0, 28, 31 @ $8082A84C
op rlwinm r0, r6, 0, 28, 31 @ $8082A86C
op rlwinm r0, r6, 0, 28, 31 @ $8082A87C
op rlwinm r0, r6, 0, 28, 31 @ $8082A89C
op rlwinm r0, r6, 0, 28, 31 @ $8082A8BC
op rlwinm r0, r6, 0, 28, 31 @ $8082A8CC
op rlwinm r0, r6, 0, 28, 31 @ $8082A8EC
op rlwinm r0, r6, 0, 28, 31 @ $8082A90C
op rlwinm r0, r6, 0, 28, 31 @ $8082A91C
byte 50 		    @ $80692DA7
byte 50 		    @ $80692507
byte[4] 0x30, 0x34, 0x64, 0 @ $806A17D8

################################################################
[Brawl-Themed Project+] Stage Select Screen Supports 50CC [QuickLava]
################################################################
# Stage Select Stock Icons 50CC Fix
HOOK @ $806B2FFC
{
  	cmpwi r25, 0x36;   bne+ notWarioman		# 0x36 isn't a mistake.
 	li r3, 9000; b %END%					# Not sure why it's not 0x35 like in the above codes.
notWarioman:
 	mulli r3, r3, 50
}
# Overwrites the old constants the game used as the frames for Random Icons with 50CC compliant ones.
# First value should be left as is, second value should be the first plus how many colored random icons you need!
float[2] 9051.0f, 9055.0f @ $806B91B0