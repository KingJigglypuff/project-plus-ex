################################################################
L+R+A during Stage Select goes to CSS V2 (GC & CC) [ds22, Magus]
################################################################
HOOK @ $806DCC9C
{
 	cmpwi r0, 0x1
  	bne- %END%		//skip if not on SSS
  	li r0, 0x0
  	li r11, 0x0		//used to track loop count
  	lis r12, 0x805C
  	subi r12, r12, 0x5340
controllerLoop:
  	lwzu r3, 0x40(r12)	//checking button presses, assumes GC hex format
  	rlwinm. r0, r3, 0, 23, 23	//0x100 (A)
  	beq- checkCtrlrTally
  	rlwinm. r0, r3, 0, 25, 25	//0x40 (L)
  	beq- checkCtrlrTally
  	rlwinm. r0, r3, 0, 26, 26	//0x20 (R)
  	bne- LRApressed
checkCtrlrTally:
  	addi r11, r11, 0x1	//increment once per loop
  	cmpwi r11, 0x8		//
  	bne- controllerLoop	//checks all 8 controller ports
 	li r0, 0x1		// 1 if L+R+A not pressed
  	b done
LRApressed:
  	li r0, 0x0		//clear r0 if the combination is pressed!
done:
  	cmpwi r0, 0x2		
}