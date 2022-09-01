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

#Insert Manual Unload Fixes here. vPM example below.
	#%ManualUnloadFix(0x27, 0x11)	#Roy/Marth
	#%ManualUnloadFix(0x26, 0x21)	#Mewtwo/Lucario
#Common EX Example below	
	#%ManualUnloadFix(0x41, 0x07)	#Pichu/Pikachu


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

#Insert Manual Unload Fixes here. vPM example below.
	#%ManualUnloadFix(0x27, 0x11)	#Roy/Marth
	#%ManualUnloadFix(0x26, 0x21)	#Mewtwo/Lucario
#Common EX Example below
	#%ManualUnloadFix(0x41, 0x07)	#Pichu/Pikachu

    b EXIT

MOVE:
	mr r0,r4 		#Make loader EXIST

EXIT:
	cmpw r0, r4		#Original Function

}