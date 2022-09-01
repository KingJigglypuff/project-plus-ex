#######################################
[Project+] Kirby CE Hat Prop Fix [ds22]
#######################################
.macro KirbyCEHatPropFix
{
  lwz r4, 8(r3)
  lwz r4, 0x70(r4)
  lwz r4, 0x20(r4)
  lwz r4, 0xC(r4)
  lwz r4, 0x120(r4)
}

HOOK @ $80A58448	#Roy Fix
{
	%KirbyCEHatPropFix
}

HOOK @ $80A64D74	#Pit Fix 1
{
	%KirbyCEHatPropFix
}

HOOK @ $80A64E08	#Pit Fix 2
{
	%KirbyCEHatPropFix
}
HOOK @ $80A0B140    #Zero Suit Samus Fix
{
    %KirbyCEHatPropFix
}

######################################
Weapon Data Fix Automatic [ds22, Desi]
######################################
#Move the CharacterID from another register to R4 for when the game gets the KirbyBinID
#The Lucario one is by ds22 and was in another code, and it did the same thing as these so it's also here.
#I'm hoping to use that method for future hats as it's more consistent.

op lwz r4, 0x24(r1) @ $80853F00		#Lucario Fix
op lwz r4, 0x24(r1) @ $80853D28 	#Samus Fix
op mr r4, r25 @ $80854144			#Bowser Fix
op mr r4, r25 @ $808526F4			#Mario Fix
op mr r4, r25 @ $80853ABC			#Pit Fix
op lwz r4, 0x24(r1) @ $80853B54		#Pit Fix 2
op lwz r4, 0x24(r1) @ $80854298     #Zero Suit Samus Fix
#op lwz r4, 0x24(r1) @ $808536AC	#Sheik Fix
#op lwz r4, 0x24(r1) @ $8085373C	#Sheik Fix 2

###############################
Kirby Hat Float Fix [dantarion]
###############################
.macro HatFloatFix(<CloneID>,<BaseID>)
{
	cmpwi r6, <CloneID>
	bne- 0x8
	li r6, <BaseID>
}	

#Edit here by copy/pasting the Macro and putting in your own IDs
HOOK @ $80A1A5B0
{
	%HatFloatFix(0x27, 0x11)	#Roy/Marth
	%HatFloatFix(0x26, 0x21)	#Mewtwo/Lucario
	%HatFloatFix(0x2A, 0x21)	#Ridley/Lucario
	%HatFloatFix(0x28, 0x17)	#Waluigi/Pit
	%HatFloatFix(0x40, 0x03)	#Dark Samus/Samus
	%HatFloatFix(0x6A, 0x09)	#Red Alloy/Captain Falcon
	mulli r0, r4, 0xDC
}

####################################
KirbyID Conversion Fix for EX [Desi]
####################################
op cmpwi r6, 0x80 @ $80A1A5A0

####################################
Kirby Hats EX Shadow Fix [Desi]
####################################
#Some EX Hats don't like shadows. Optimally, this will disable the problamatic shadows instead of all the shadows.
HOOK @ $80047670
{
	mflr r21 			#Backup Link Register in R21
	bl 0x4               #Set current code location in Link Register 
	mflr r23             #Move Link Register to R23
	addi r23, r23, 0xC   #Set r23 to Stored Data
	b Postdata
	nop					#5 lines of code to store 1 word in the GCT. Worth.
Postdata:
	mtlr r21			#Restore Link Register
	lis r22, 0x8000
	ori, r22, r22, 0x0000
	cmpw r5, r22		#Comfirm that r5 is an acceptable range part 1
	ble- mem2
	lis r22, 0x817F
	ori, r22, r22, 0xFFFF 
	cmpw r5, r22		#Comfirm that r5 is an acceptable range part 1
	bge- mem2
	nop 	#Mem 1 sucesss
	b complete
mem2:
	lis r22, 0x9000
	ori, r22, r22, 0x0000
	cmpw r5, r22		#Comfirm that r5 is an acceptable range part 1
	ble- fail
	lis r22, 0x93FF
	ori, r22, r22, 0xFFFF 
	cmpw r5, r22		#Comfirm that r5 is an acceptable range part 1
	bge- fail
	nop		#Mem 2 sucess
	b complete
fail:
	lwz r5, 0 (r23)
	b hookpoint:
complete:
	stw r5, 0 (r23)
hookpoint:
	lwz r7, 0xE8 (r3)	#Hook Point
end:
}

HOOK @ $8004774C
{
	mflr r5 			#Backup Link Register in R5
	bl 0x4             #Set current code location in Link Register 
	mflr r7            #Move Link Register to R7
	addi r7, r7, 0xC   #Set r7 to Storage Data and Stupid Stack
	b Postdata
	nop					#Storage	
	nop					#Storage 2
	nop					#Stupid Stack 
Postdata:
	mtlr r5		#Restore Link Register
	stw r4, 8 (r7)	#Store in Stupid Stack
	lis r4, 0x8000
	ori, r4, r4, 0x0000
	cmpw r6, r4		#Comfirm that r6 is an acceptable range part 1
	ble- mem2
	lis r4, 0x817F
	ori, r4, r4, 0xFFFF 
	cmpw r6, r4		#Comfirm that r6 is an acceptable range part 1
	bge- mem2
	nop 	#Mem 1 sucesss
	b complete
mem2:
	lis r4, 0x9000
	ori, r4, r4, 0x0000
	cmpw r6, r4		#Comfirm that r6 is an acceptable range part 1
	ble- fail
	lis r4, 0x93FF
	ori, r4, r4, 0xFFFF 
	cmpw r6, r4		#Comfirm that r6 is an acceptable range part 1
	bge- fail
	nop		#Mem 2 sucess
	b complete
fail:
	lwz r6, 0 (r7)
	lwz r5, 4 (r7)
	lwz r4, 8 (r7)	#Restore r4 from Stupid Stack
	li r3, 0
	b end
complete:
	stw r6, 0 (r7)
	stw r5, 4 (r7)
	lwz r4, 8 (r7)	#Restore r4 from Stupid Stack
	lwzx r5, r27, r4
end:
}

#########################
EX Hat DESTROY Fix [Desi]
#########################
#Again, couldn't tell you why, but this works.
#This fixes something related to the game unloading assets related to kirby characters, and increases the mask from 40 to 80.
#Thing is, i don't think it's masking the character ID, so i don't know why this works, but it does.
op rlwinm. r0, r3, 26, 30, 30 @ $800273F4

##########################
KirbyHat.kbx Loader [Desi]
##########################
# This loads the file that contains the action/subaction stuff for Kirby Hats
# I was gonna move the transactors into the beginning of the file, but i learned that it was easier to just load them from the module with a slight code edit.
# Module Changes: 0x1DD8C and 0x1D7BC had their comparison range changed from 0x37 to 0x80. 0x1C78C branches to code that loads the Transactor Offset from KirbyHat.kbx, then loads the transactor from Section 4. Offset 0xD4F0 had its comparison range changed to 80 (KJP found this one).
# The Module Command Info for 0x1D7C4/1D7C8/1D7D4/1D7D8/1DDA0/1DDA4 were deleted, and these all directely point to the KirbyHat.kbx file.
# The transactor/article stuff locations are now packed in where the SubActions were previously in section 4, and are retrieved via an offset set inside the file.
# 0x1FA20 branches out to the cleared out subaction area in Section 4. These are related to transactors.
# The folowing is what i had used to move the transactors. Its a good reference for what offset should be used.
# https://docs.google.com/spreadsheets/d/1h1MkPS2WvEdyoRYMBwuVVkqzt0vogRxnZDXLnmZzUpo/edit?usp=sharing
# The following is the quick start guide for adding hats.
# https://docs.google.com/document/d/17B462eugiS45PcSsie1iIr8gDl-bQM-gjIT17TIfl6Q/edit?usp=sharing
	.BA<-FileName
	.BA->$80562200
	.RESET
	.GOTO->LoadFile
	
	FileName:
	string "P+EX/././pf/BrawlEX/KirbyHat.kbx"
	
LoadFile:

HOOK @ $8002D514
{
stw r0, -4(r1)         #\Stack Frame 
mflr r0                #|
stw r0, 4(r1)          #|
mfctr r0               #|
stw r0, -8(r1)         #|
stwu r1, -132(r1)      #|
stmw r3, 8(r1)         #/

lis r31, 0x8056			#\Setup File Loader at 80564880
ori r31, r31, 0x2200	#|
lis r30, 0x8056			#|
ori r30, r30 0x2220		#|
stw r30, 12(r31)		#/

li r30, 0x0				#\Initialize Data
stw r30, 4(r31)			#|
stw r30, 8(r31)			#|
stw r30, 16(r31)		#/

mr r3, r31				#\Load File (KirbyHat.kbx)
lis r0, 0x8001			#|
ori r0, r0, 0xCBF4		#|
mtctr r0				#|
bctrl 					#/

lmw r3, 8(r1)			#\Return Stack Frame
addi r1, r1, 0x84		#|
lwz r0, -8(r1)			#|
mtctr r0				#|
lwz r0, 4(r1)			#|
mtlr r0					#|
lwz r0, -4(r1)			#/

mr r27, r4				#Original function
}


############################################
!Weapon Data Fix Manual (Broken Hats) [Desi]
############################################
#This code is disabled, and is primarily for debugging purposes. 
.macro GetKirbyBinId(<arg1>)
{
lis r3, 0x80B8
lwz r3, 0x7C50 (r3)
li r4, <arg1>
rlwinm r0, r4, 2, 0, 29
add r3, r3, r0
lwz r3, 0x460 (r3)
li r31, 0x0
ori r31, r31, 0xFFFF
cmpw r3, r31
bne- end
}

HOOK @ $80853804	#Luigi. Air N-B works, grounded does not.
{
	%GetKirbyBinId(0x08)
	%GetKirbyBinId(0x5A)
	end:
}

HOOK @ $8085399C	#Peach. Part 1. Press B to Freeze.
{
	%GetKirbyBinId(0x0C)
	%GetKirbyBinId(0x5A)
	end:
}

HOOK @ $80853A1C	#Peach. Part 2.
{
	%GetKirbyBinId(0x0C)
	%GetKirbyBinId(0x5A)
	end:
}

HOOK @ $8085350C	#Yoshi. Press B to Freeze
{
	%GetKirbyBinId(0x04)
	%GetKirbyBinId(0x5A)
	end:
}

#####################################
!Weapon Data Fix Manual Double [Desi]
#####################################
.macro GetKirbyBinId(<arg1>, <arg2>)
{
lis r3, 0x80B8
lwz r3, 0x7C50 (r3)
li r4, <arg1>
rlwinm r0, r4, 2, 0, 29
add r3, r3, r0
lwz r3, 0x460 (r3)
li r31, 0x0
ori r31, r31, 0xFFFF
cmpw r3, r31
li r4, <arg2>
bne- end
}


HOOK @ $808536B0	#Shiek Part 1. Press B to Freeze.
{
	%GetKirbyBinId(0x0E, 0x0E)
	%GetKirbyBinId(0x5A, 0x0E)
	end:
}

HOOK @ $80853744	#Shiek Part 2. Press B to Freeze.
{
	%GetKirbyBinId(0x0E, 0x0E)
	%GetKirbyBinId(0x5A, 0x0E)
	end:
}