#########################################################################################
Manual Clone Soundbank Unload Fix + Macro [codes, ds22, Desi]
#Following link contains original code. 
#https://smashboards.com/threads/ds22s-code-showcase.428060/#post-20793302
#########################################################################################
#Note: If you are including a manual fix, you will have to add it to both hootks.
.Macro ManualUnloadFix(<CloneID>,<BaseID>)
{
	cmpwi r4,<CloneID>
	bne+ 0xC		#If its not the clone, start the check from the base
	cmpwi r0, <BaseID>
	beq- MOVE 		#If the clone and base match, go to MOVE. 
	
	cmpwi r4,<BaseID>
	bne+ 0xC		#If its not the base, start the next check.
	cmpwi r0, <CloneID>
	beq- MOVE 		#If the base and clone match, got to MOVE.
}

HOOK @ $8084C30C
{
START:
	cmpwi  r7,3
	bne-  EXIT  	#Skip if not soundbank loader routine

	cmpw  r0,r4
	beq-  EXIT  	#Skip if instance IDs match

#Insert Manual Unload Fixes here.
	ManualUnloadFix(0x6A, 0x09)		#Red Alloy Ex/Captain Falcon
	ManualUnloadFix(0x6B, 0x0D)		#Blue Alloy Ex/Zelda
	ManualUnloadFix(0x6C, 0x00)		#Yellow Alloy Ex/Mario
	ManualUnloadFix(0x6D, 0x05)		#Green Alloy Ex/Kirby


    b EXIT

MOVE:
	mr r0,r4 		#Make loader EXIST

EXIT:
	cmpw r0, r4		#Original Function

}

HOOK @ $8084C9D4
{
START:
	cmpwi  r7,3
	bne-  EXIT  	#Skip if not soundbank loader routine

	cmpw  r0,r4
	beq-  EXIT  	#Skip if instance IDs match

#Insert Manual Unload Fixes here.
	ManualUnloadFix(0x6A, 0x09)		#Red Alloy Ex/Captain Falcon
	ManualUnloadFix(0x6B, 0x0D)		#Blue Alloy Ex/Zelda
	ManualUnloadFix(0x6C, 0x00)		#Yellow Alloy Ex/Mario
	ManualUnloadFix(0x6D, 0x05)		#Green Alloy Ex/Kirby

    b EXIT

MOVE:
	mr r0,r4 		#Make loader EXIST

EXIT:
	cmpw r0, r4		#Original Function

}