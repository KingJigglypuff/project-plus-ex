#########################################################
[Legacy TE] Masquerade Costume Flags V2 [ds22, DukeItOut]
#########################################################
op subi r0, r31, 0x32 @ $8084CD48
* 037C8500 007F00FF

###########################################################################################
[Legacy TE] Set Masquerade Costume Count to Zero to have up to 50 costumes v1.1 [DukeItOut]
###########################################################################################
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
op rlwinm r5, r23, 0, 26, 31 @ $8084D00C
op rlwinm r3, r0, 0, 26,  31 @ $8081C3D4
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
op rlwinm r5, r23, 0, 26, 31 @ $8084DED4
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