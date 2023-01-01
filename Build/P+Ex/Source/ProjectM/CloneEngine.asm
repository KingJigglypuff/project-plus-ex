###################################
Clone Engine Data Saving Fix [ds22]
###################################
op cmpwi r3, 0x3A @ $80952AEC
op cmpwi r3, 0x3A @ $80952B2C
half[2] 0x2C0B, 0x3068 @ $80B2DD3C
half[2] 0x2D11, 0x356F @ $80B2DD40
byte[24] |
0x32, 0x1D, 0x24, 0x21, |
0x33, 0x1C, 0x2D, 0x4B, |
0x34, 0x13, 0x2E, 0x2D, |
0x35, 0x22, 0x2F, 0x5B, |
0x36, 0x0B, 0x0B, 0x17, |
0x37, 0x20, 0x25, 0x55  |
@ $80B2DD54 

###################################################################################
Clone Engine Corps Stock Fix + BrawlEX Corps Fix v1 + Exception Macro [ds22, Desi]
###################################################################################
#If the SlotID is too high, sometimes it doesn't grab the cosmetic ID correctly. This is used to fix that.
.macro StockException (<SlotID>, <CosmeticID>)
{
cmpwi r4, <SlotID>                    #If SlotID is not for the exception, go to next check or end
bne- 0xC
li r0, <CosmeticID>                    #Set CosmeticID to correctID
b %END%
}
op cmpwi r4, 0x38 @ $80952F14        #Clone Engine Corps Stock Fix [ds22] modified from 3A to 38

HOOK @ $80952F38
{
    %StockException (0x38, 0x32)    #Ridley
    %StockException (0x39, 0x33)    #Waluigi
    mr r0, r4                        #BrawlEX Corps Fix v1 [ds22]
    b %END%
}

##############################
Mewtwo Fixes [Dantarion, ds22]
##############################
.macro AFix()
{
  stw r0, 0(r2)
  mulli r0, r4, 0xC
  lwzx r3, r3, r0
  lwz r0, 0(r2)
}
HOOK @ $80853FA4
{
  %AFix()
}
HOOK @ $80853F44
{
  %AFix()			// Yes, this is the same as the above outside of hookpoint
}
HOOK @ $80853F7C
{
  %AFix()			// Likewise.
}
op cmpwi r30, 5 @ $80AA95A8
op beq- 0xC     @ $80AA95B4
CODE @ $80AA9D64
{
  lwz r12, 0(r23)
  mr r4, r23
  addi r3, r1, 0x68
  li r5, 0x3
  lwz r12, 152(r12)
}
CODE @ $80AAA76C
{
  lwz r12, 0(r27)
  mr r4, r27
  addi r3, r1, 0x14
  li r5, 0x3
  lwz r12, 0x98(r12)
}

############################################################
Lucario Clone Aura Sphere GFX Fix [Dantarion, ds22, DesiacX]
############################################################
.macro GFXFix(<FighterID>,<Effect.pacID>)
{
    cmpwi r30, <FighterID>
    bne- 0x0C
    lis r3, <Effect.pacID>
    b %END%
}
HOOK @ $80AA95B8    #Uses Fighter ID followed by Effect.pac ID
{
    %GFXFix (0x26, 0x27)    #Mewtwo
	%GFXFix (0x2A, 0x187)   #Ridley
    lis r3, 0x22            #If no fix is specified, use Lucario's
}

############################################################
Kirby Lucario Clone Aura Sphere GFX Fix [ds22, DesiacX, Eon]
############################################################
.macro GFXFix(<FighterID>,<Effect.pacID>)
{
    cmpwi r3, <FighterID>
    bne- 0xC
    lis r3, <Effect.pacID>
    b end
}
HOOK @ $80AA95AC
{
  bne notKirby
#awkward memory stuff to get to LA-Basic[72] of the projectile
  lwz r3, -8(r20) #get module accessor
  lwz r3, 0x64(r3) #get work module
  lwz r3, 0x20(r3) #get LA's
  lwz r3, 0xC(r3) #get Basic's
  lwz r3, 0x120(r3) #get LA-Basic[72] (*0x4 = 0x120)
  %GFXFix(0x26, 0x96) #MewtwoHat
  %GFXFix(0x2A, 0x97) #RidleyHat
lucarioHat:
notKirby:
  lis r3, 0x123

end:
  cmpwi r30, 0x5

}

#####################################################################################################
Lucario Clone Aura Sphere Bone ID Fix [Dantarion, ds22, PyotrLuzhin, Yohan1044, KingJigglypuff, Desi]
#####################################################################################################
.macro BoneIDFixA(<Register>,<FighterID>,<BoneID>)
{
	cmpwi <Register>, <FighterID>
	bne- 0x0C
	li r6, <BoneID>
	b %END%
}
HOOK @ $80AA9D60		#Use Register 3, followed by Fighter ID and Bone ID
{
	%BoneIDFixA(r3, 0x26, 0x24)		#Mewtwo
	%BoneIDFixA(r3, 0x2A, 0x1A)		#Ridley
	li r6, 0x1F						#If not defined, use Lucario
}
* 06AA9D64 00000014
* 81970000 7EE4BB78
* 38610068 38A00003
* 818C0098 00000000
HOOK @ $80AA9D98		#Use Register 7, followed by Fighter ID and Bone ID
{
	lwz r7, 0x20 (r26)
	lwz r7, 0x0C (r7)
	lwz r7, 0x24 (r7)
	%BoneIDFixA(r7, 0x26, 0x24)		#Mewtwo
	%BoneIDFixA(r7, 0x2A, 0x1A)		#Ridley
	li r6, 0x35						#If not defined, use Lucario
}
HOOK @ $80AAA768		#Use Register 3, followed by Fighter ID and Bone ID
{
	%BoneIDFixA(r3, 0x26, 0x24)		#Mewtwo
	%BoneIDFixA(r3, 0x2A, 0x1A)		#Ridley
	li r6, 0x1F						#If not defined, use Lucario
}
* 06AAA76C 00000014
* 819B0000 7F64DB78
* 38610014 38A00003
* 818C0098 00000000
HOOK @ $80AAA7A0	#Use Register 7, followed by Fighter ID and Bone ID
{
	lwz r7, 0xD8 (r31)
	lwz r7, 0x64 (r7)
	lwz r7, 0x20 (r7)
	lwz r7, 0x0C (r7)
	lwz r7, 0x24 (r7)
	%BoneIDFixA(r7, 0x26, 0x3D)		#Mewtwo
	%BoneIDFixA(r7, 0x2A, 0x1A)		#Ridley
	li r6, 0x35						#If not defined, use Lucario
}

Knuckles Fixes
* 064559C8 0000000C
* 2A0135FF 12000000
* 00001FF0 00000000
string "Knuckles" @ $80456534

Lyn Fixes [ds22]
* 04853A8C 40800014
* 04853B24 40800014

#####################################################
Samus Clone Charge Shot GFX Fix [Eon, KingJigglypuff]
#####################################################
.macro GFXFix(<FighterID>, <Effect.pacID>)
{
    cmpwi r3, <FighterID>
    bne 0x0C
    lis r4, <Effect.pacID>
    b end
}
op cmpwi r3, 5 @ $80A0AA5C
op beq 0x78 @ $80A0AA60
HOOK @ $80A0AAA8
{
	lwz r3, 0xD8(r31)			#\
	lwz r3, 0x64(r3)			#|
	lis r4, 0x1000				#|
	addi r4, r4, 7				#| This entire sequence grabs the Fighter ID.
	lwz r12, 0x0(r3)			#|
	lwz r12, 0x18(r12)			#|
	mtctr r12					#|
	bctrl 						#/
FighterIDCheck:
    %GFXFix(0x69, 0x169)		#Samus Clone Test, ef_custom32
    lis r4, 0x04				#If not defined, use ef_samus
end:
	lwz r12, 0x0(r30)
}

##########################################################################
Kirby Samus Clone Charge Shot GFX Fix [ds22, DesiacX, Eon, KingJigglypuff]
##########################################################################
.macro GFXFix(<FighterID>,<Effect.pacID>)
{
    cmpwi r3, <FighterID>
    bne 0xC
    lis r4, <Effect.pacID>
    b end
}
HOOK @ $80A0AB1C
{
	lwz r3, 0xD8(r31)				#\
	lwz r3, 0x54(r3)				#|
	li r4, 3						#|
	lwz r12, 0x0(r3)				#| Get Link Parent[3] (IE: Who owns the projectile)
	lwz r12, 0x34(r12)				#|
	mtctr r12						#|
	bctrl 							#/
	lwz r3, 0x60(r3)				#\
	lwz r3, 0xD8(r3)				#|
	lwz r3, 0x64(r3)				#|
	lis r4, 0x1000					#|
	addi r4, r4, 72					#| Get Kirby's LA-Basic[72] (Hat ID)
	lwz r12, 0x0(r3)				#|
	lwz r12, 0x18(r12)				#|
	mtctr r12						#|
	bctrl 							#/
HatIDCheck:
    %GFXFix(0x40, 0x95)				#Dark Samus, ef_tautau
    lis r4, 0x108					#If not defined, use ef_KbSamus
end:
	lwz r12, 0x0(r30)
}

##################################################
Jigglypuff Clone Rollout Bone Fix [codes, DesiacX]
##################################################
.Macro CloneBones(<CloneID>,<BoneID>,<WriteRegister>)
{
  cmpwi r3, <CloneID>
  bne+ 0x8
  li <WriteRegister>, <BoneID>
}

################
HOOK @ $80AC9F9C
{
    %CloneBones(0x6D, 0x7, r28)	#Green Alloy
    lwz r4, 216(r30)
}
################
HOOK @ $80ACA3A4
{
    %CloneBones(0x6D, 0x7, r27)	#Green Alloy  
    lwz r4, 216(r28)
}
################
HOOK @ $80ACA414
{
    %CloneBones(0x6D, 0x7, r27)	#Green Alloy
    lwz r4, 216(r28)
}
################
HOOK @ $80ACA7E8
{
    %CloneBones(0x6D, 0x7, r31)	#Green Alloy    
    lwz r4, 216(r29)
}
################
HOOK @ $80ACA858
{
    %CloneBones(0x6D, 0x7, r31)	#Green Alloy    
    lwz r4, 216(r29)
}
################
HOOK @ $80ACAC2C
{
    %CloneBones(0x6D, 0x7, r28)	#Green Alloy    
    lwz r4, 216(r30)

}
################
HOOK @ $80ACB050
{
    %CloneBones(0x6D, 0x7, r27)	#Green Alloy    
    lwz r4, 216(r28)
}
################
HOOK @ $80ACB0c0
{
    %CloneBones(0x6D, 0x7, r27)	#Green Alloy    
    lwz r4, 216(r28)
}
################
HOOK @ $80ACB6A0
{
    %CloneBones(0x6D, 0x9, r5)	#Green Alloy
    lfs f0, 4(r31)
}
################
HOOK @ $80ACB7BC
{
    %CloneBones(0x6D, 0x7, r31)	#Green Alloy    
    lwz r4, 216(r29)
}
################
HOOK @ $80ACB81C
{
    %CloneBones(0x6D, 0x7, r31)	#Green Alloy    
    lwz r4, 216(r29)
}
################
HOOK @ $80ACBE9C
{
    %CloneBones(0x6D, 0x7, r28)	#Green Alloy    
    lwz r4, 216(r30)
}
################
op NOP @ $80ACC0B8
################
HOOK @ $80ACC0C4
{
    %CloneBones(0x6D, 0x6, r4)	#Green Alloy    
    lwz r3, 4(r5)
    lwz r12, 8(r3)
}
################
HOOK @ $80ACC9C4
{
    %CloneBones(0x6D, 0x7, r27)	#Green Alloy    
    lwz r4, 216(r28)
}
################
HOOK @ $80ACCA34
{
    %CloneBones(0x6D, 0x7, r26)	#Green Alloy    
    lwz r4, 216(r28)
}
################
HOOK @ $80ACD178
{
    %CloneBones(0x6D, 0x9, r28)	#Green Alloy    
    lwz r3, 216(r30)
}
################
HOOK @ $80ACD53C
{
    %CloneBones(0x6D, 0x7, r31)	#Green Alloy    
    lwz r4, 216(r29)
}
################
HOOK @ $80ACD5AC
{
    %CloneBones(0x6D, 0x7, r31)	#Green Alloy    
    lwz r4, 216(r29)
}
################
HOOK @ $80ACD93C
{
    %CloneBones(0x6D, 0x7, r30)	#Green Alloy    
    lwz r4, 216(r29)
}
################
op NOP @ $80ACDB54
################
HOOK @ $80ACDB60
{
    %CloneBones(0x6D, 0x6, r4)	#Green Alloy    
    lwz r3, 4(r5)
    lwz r12, 8(r3)
}
################
HOOK @ $80ACE580
{
    %CloneBones(0x6D, 0x7, r28)	#Green Alloy    
    lwz r4, 216(r27)
}
################
HOOK @ $80ACE5F0
{
    %CloneBones(0x6D, 0x7, r26)	#Green Alloy    
    lwz r4, 216(r27)
}
################
HOOK @ $80ACEBF0
{
    %CloneBones(0x6D, 0x7, r29)	#Green Alloy    
    lwz r4, 216(r30)
}
################
HOOK @ $80ACEDF4
{
    %CloneBones(0x6D, 0x9, r28)	#Green Alloy    
    lwz r3, 216(r30)
}
################
op NOP @ $80ACF8A4
################
HOOK @ $80ACF8B0
{
    %CloneBones(0x6D, 0x6, r4)	#Green Alloy    
    lwz r3, 4(r5)
    lwz r12, 8(r3)
}
################
HOOK @ $80ACFCD4
{
    %CloneBones(0x6D, 0x7, r25)	#Green Alloy    
    lwz r4, 216(r27)
}
################
HOOK @ $80ACFD94
{
    %CloneBones(0x6D, 0x7, r26)	#Green Alloy    
    lwz r4, 216(r27)
}
################
HOOK @ $80AD02C8
{
    %CloneBones(0x6D, 0x7, r31)	#Green Alloy    
    lwz r4, 216(r29)
}
################
HOOK @ $80AD0338
{
    %CloneBones(0x6D, 0x7, r31)	#Green Alloy    
    lwz r4, 216(r29)
}
################
op NOP @ $80AD0AD4
################
HOOK @ $80AD0AE0
{
    %CloneBones(0x6D, 0x6, r4)	#Green Alloy    
    lwz r3, 4(r5)
    lwz r12, 8(r3)
}
################
CODE @ $80AD0B14
{
    nop 
    nop 
    nop 
}
################
#Yes, this is the only one that checks for Jigglypuff.
HOOK @ $80AD0B20
{
    %CloneBones(0x25, 0x197, r28)	#Jigglypuff
    %CloneBones(0x6D, 0x7, r28)	    #Green Alloy    
    lwz r3, 4(r5)
    lwz r12, 8(r3)
}
################
op NOP @ $80AD0B50
################
HOOK @ $80AD0B5C
{
    %CloneBones(0x6D, 0x6, r4)	#Green Alloy    
    lwz r3, 4(r5)
    lwz r12, 8(r3)
}
################
op NOP @ $80AD0D88
################
HOOK @ $80AD0D94
{
    %CloneBones(0x6D, 0x6, r4)	#Green Alloy    
    lwz r3, 4(r5)
    lwz r12, 8(r3)
}
################
op NOP @ $80AD13F8
################
HOOK @ $80AD1404
{
    %CloneBones(0x6D, 0x6, r4)	#Green Alloy    
    lwz r3, 4(r5)
    lwz r12, 8(r3)
}
################
HOOK @ $80AD1628
{
    %CloneBones(0x6D, 0x7, r28)	#Green Alloy    
    lwz r4, 216(r29)
}
################
HOOK @ $80AD1698
{
    %CloneBones(0x6D, 0x7, r28)	#Green Alloy    
    lwz r4, 216(r29)
}
################
HOOK @ $80AD17D8
{
    %CloneBones(0x6D, 0x7, r31)	#Green Alloy    
    lwz r4, 216(r29)
}
################
HOOK @ $80AD1848
{
    %CloneBones(0x6D, 0x7, r31)	#Green Alloy    
    lwz r4, 216(r29)
}
############################################################
Jigglypuff Clone Rollout Max Charge GFX Fix [Codes, DesiacX]
############################################################
.Macro CloneGFX(<CloneID>,<GFXID>,<GFXID2>,<WriteRegister>)
{
  cmpwi r3, <CloneID>
  bne+ 0xC
  lis <WriteRegister>, <GFXID>
  addi <WriteRegister>, <WriteRegister>, <GFXID2>
}
################
CODE @ $80ACB668
{
    lis r29, 0x26
    addi r29, r29, 0x2
    bne- 0xC
    lis r29, 0x126
    addi r29, r29, 0x1
}
HOOK @ $80ACB67C
{
    %CloneGFX(0x6D, 0x130, 0xF, r29)	#Green Alloy    
    lwz r3, 8(r30)
}
################
CODE @ $80ACD1D8
{
    lis r4, 0x26
    addi r4, r4, 0x2
    bne- 0xC
    lis r4, 0x126
    addi r4, r4, 0x1
}
HOOK @ $80ACD1EC
{
    %CloneGFX(0x6D, 0x130, 0xF, r4)	#Green Alloy   
      lfs f0, 4(r31)
}
################
CODE @ $80ACEE54
{
    lis r4, 0x26
    addi r4, r4, 0x2
    bne- 0xC
    lis r4, 0x126
    addi r4, r4, 0x1
}
HOOK @ $80ACEE68
{
    %CloneGFX(0x6D, 0x130, 0xF, r4)	#Green Alloy  
    lfs f0, 4(r31)
}
################

#################################################
Jigglypuff Clone Rollout SFX Fix [codes, DesiacX]
#################################################
#Logic changed to suit macro [Desi]
#Previous, it checked the CloneID. If it wasn't the Clone Id, it'd write Jigglypuffs
#Now it manualy checks Jigglypuff and any clones.
.Macro CloneSFX(<CloneID>,<SFXID>,<ComparisonRegister>)
{
  cmpwi <ComparisonRegister>, <CloneID>
  bne+ 0x8
  li r4, <SFXID>
}
################
HOOK @ $80ACAE38
{
  stwu r1, -12(r1)
  stw r3, 8(r1)
  lwz r3, 216(r30)
}
################
HOOK @ $80ACAE3C
{
    lwz r4, 8(r1)
    %CloneSFX(0x25, 0x17A1, r4)	#Jigglypuff
    %CloneSFX(0x6D, 0xC43, r4)	#Green Alloy  
}
################
HOOK @ $80ACAE60
{
    lwz r4, 8(r1)
    lwz r1, 0(r1)
    %CloneSFX(0x25, 0x9B5, r4)	#Jigglypuff
    %CloneSFX(0x6D, 0x4BD, r4)	#Green Alloy  
}
################
op NOP @ $80ACF700
################
HOOK @ $80ACF704
{
    %CloneSFX(0x25, 0x179F, r3)	#Jigglypuff
    %CloneSFX(0x6D, 0xC41, r3)	#Green Alloy  
    lwz r3, 216(r31)
}
################
op NOP @ $80ACA098
################
HOOK @ $80ACA09C
{
    %CloneSFX(0x25, 0x17A0, r3)	#Jigglypuff
    %CloneSFX(0x6D, 0xC42, r3)	#Green Alloy  
    lwz r3, 216(r30)
}
################

############################
Dedede Clones Fix [MarioDox]
############################
.Macro DededeFix(<CloneID>)
{
  cmpwi r3, <CloneID>
  beq %END%
}

HOOK @ $80aa1544
{
  %DededeFix(0x20) //Dedede
}
HOOK @ $80aa0af0
{
  %DededeFix(0x20) //Dedede
}
HOOK @ $80aa0d4c
{
  %DededeFix(0x20) //Dedede
}
HOOK @ $8088f768
{
  %DededeFix(0x20) //Dedede
}
HOOK @ $8088e758
{
  %DededeFix(0x20) //Dedede
}
HOOK @ $8088f120
{
  %DededeFix(0x20) //Dedede
}
HOOK @ $8088fa50
{
  %DededeFix(0x20) //Dedede
}
HOOK @ $80890050
{
  %DededeFix(0x20) //Dedede
}

##################################################
Bowser Clone Fire Breath Bone Fix [KingJigglypuff]
##################################################
.macro BoneIDFix(<FighterID>, <BoneID>)
{
    cmpwi r28, <FighterID>
    bne- 0x0C
    li r5, <BoneID>
    b %END%
}
HOOK @ $80A391F8        #Use Register 28, followed by Fighter ID and Bone ID
{
    %BoneIDFix(0x69, 0x21)        #Bowser Clone Test
    li r5, 0x33                   #If not defined, use Bowser
}
* 06A391FC 0000000C
* 809B00d8 38610008
* 38C10020 00000000

.include source/P+Ex/KirbyHatEx.asm

###############################################################################################
Classic and All-Star Ending Choice Engine v1.1d [DukeItOut]
#
# v1.1: addresses quirk where Wario-Man would be misinterpreted as ZSS due to range limitations
#			This version is more robust about understanding if it is in Classic or All-Star
# v1.1b: fixed misinterpretation of the default value
# v1.1c: fixes compatibility with Boss Battles
# v1.1d: rewrote to remove ambiguity for Boss Battles to prevent issues
################################################################################################
# r29 = r30 if in Classic (r30 holds cosmetic ID of character)
# r29 = r30 + 50 in All-Star as a roundabout way to get to strings in the same table, equivalent to +0x960 within the table
CODE @ $806C1428
{
	andis. r0, r0, 0x8000
	bne- 0x10
}
op NOP @ $806C14A4 # Redundant code split that makes this code unstable if not NOP'd
CODE @ $806C148C
{
	andis. r0, r0, 0xC000
	beq+ 0x08
}
CODE @ $806C14DC	
{
	andis. r12, r0, 0x8000		# Determines if a video should play. r0 will be useful in a bit, so don't clear it!
	bne- 0x10					# Make this "b 0x10" to always skip playing a video at the end of Classic/All-Star!
}
CODE @ $806C151C
{
	andis. r0, r0, 0x8000
	bne- 0x1C
}
CODE @ $806C155C
{
	andis. r0, r0, 0x8000
	bne- 0x10
}
CODE @ $806C15A0
{
	andis. r0, r0, 0x8000
	bne- 0x10
}

op oris r5, r5, 0x4000 @ $806E36B8	# Instead of adding 50, use 4000 as an All-Star flag for how to load the imagery
op oris r5, r5, 0x8000 @ $806E4E54	# Instead of adding 100, use 8000 as a Boss Battles flag for how to load the imagery
op NOP @ $806C1460
CODE @ $806C146C
{
	lhz r3, 0x282(r3)	# Avoid custom All-Star flag
	NOP
	NOP
}	// Force an ID check for a character

HOOK @ $806C14B0
{
	andi. r3, r29, 0xFFFF
	andis. r12, r29, 0x8000
	beq+ notBoss
	addi r3, r3, 100		# Compensation for removing 100 before
notBoss:
	mulli r0, r3, 0x30
}
HOOK @ $806C14C0		
{
	andi. r6, r29, 0xFFFF  # Force to read normally
	andis. r7, r29, 0x8000
	bne- BossBattles

	lis r12, 0x806C        	# \
	lwz r12, 0x14C8(r12)	# | Access ending ID from the table that has a pointer at $806C14C8!
	lbzx r5, r12, r6       	# /
	cmplwi r5, 0xFF;bne+ notDefault	# Use -1 (0xFF) as a value when you don't have Classic or All-Star results ready for the character!
default:
	addi r4, r31, 8
	andis. r12, r29, 0x4000; beq Classic_a
AllStar_a:
	addi r4, r4, 0x960		# Go to All-Star section
Classic_a:
	b setString
notDefault:
	addi r3, r31, 0x57
	andis. r12, r29, 0x4000; beq Classic_b
AllStar_b:
	addi r3, r31, 0x9B4		# Go to All-Star section
Classic_b:

	lis r4, 0x8048;	 ori r4, r4, 0xD9F8		# "%02d"	
	lis r12, 0x803F; ori r12, r12, 0x89FC 	# \ sprintf
	mtctr r12								# |
	bctrl									# /
	li r3, 0x2E								# \ "."					 
	andis. r12, r29, 0x4000; beq Classic_c	# |
AllStar_c:									# |
	addi r4, r31, 0x998						# Go to All-Star section to replace the period
	stb r3, 0x1E(r4)						# |
	b setString								# |
Classic_c:									# |
	addi r4, r31, 0x38						# | Replace the period lost	
	stb r3, 0x21(r4)						# /	
	b setString 
BossBattles:
	add r4, r31, r0							# Original operation
	addi r4, r4, 8
setString:	
	lwz r3, 0x14A8(r31)	# restore r3
	li r5, 43
	li r6, 0		# This was originally cleared before this set of hooks was made
	li r7, 0
}
op b 0x8 @ $806C14C4
	.BA<-ENDINGTABLE
	.BA->$806C14C8
	.GOTO->ENDINGTABLESKIP
ENDINGTABLE:
	byte[128] |	
		 1,  2,  3,  4,  5,  6,  7,  8, |	# These are based on the cosmetic ID
		 9, 10, 11, 12, 13, 42, 42, 16, |	# Zelda and Sheik use 42
		17, 18, 19, 20, 38, 22, 23, 24, |	#
		25, 26, 27, 28, 28, 28, 28, 32, |	# Mewtwo is 31 instead of 28 so Pokemon Trainer monsters can access PT's.
		33, 34, 35, 37, 40, 41, -1, 44, |	# 40 used by Roy!
		46, 47, -1, -1, -1, 31, -1, 43, |   # 31 used by Mewtwo, 43 used by Knuckles!
    	12, -1, 39, 36, -1, 38, -1, -1, |	# 36 used by Waluigi! 39 used by Ridley!
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1, |
		-1, -1, -1, -1, -1, -1, -1, -1  |  

# Unused slots: 14, 15, 21, 29, 30, 31*, 36*, 39*, 40*, 43*, 45		*= Used by Project+ or P+Ex

ENDINGTABLESKIP:
	.RESET

#######################################################################
Clone Classic & All-Star Result Data V1.21 [ds22, Dantarion, DukeItOut]
#######################################################################
# Note: Cosmetic slots for clone/ex characters exceeding 
# 50/0x32 need to alter code at 806C148C if they are to have Classic Congrats screens
#
# Useful trophy IDs for general modders that stumble across this asm file:
#
# 0x145 = Mewtwo
# 0x113 = Isaac
# 0x10A = Lyn
# 0x116 = Shadow
# 0x0FF = Waluigi
# 0x1A8 = Toad
# 0x1E6 = Dark Samus
# 0x224 = Blood Falcon
# 0x225 = Black Shadow
# 0x22C = Roy (Ashnard in Brawl)
# 0x24E = Knuckles
#
# To find more, locate figdisp.pac and rummage through the texture data
# Convert the decimal value to hex to get the trophy ID
####################################################################################
.alias Roy_Slot = 0x32
.alias Mewtwo_Slot = 0x33
.alias Knuckles_Slot = 0x35
.alias Giga_Bowser_Slot = 0x2C
.alias Wario_Man_Slot = 0x2D
.alias Ridley_Slot = 0x38
.alias Waluigi_Slot = 0x39
.alias Charizard_Slot = 0x1D
.alias Squirtle_Slot = 0x1F
.alias Ivysaur_Slot = 0x20
.alias Mewtwo_Trophy = 0x145
.alias Roy_Trophy = 0x22C
.alias Knuckles_Trophy = 0x24E
.alias Giga_Bowser_Trophy = 0x17
.alias Giga_Bowser_Trophy_AllStar = 0x68
.alias Wario_Man_Trophy = 0x29
.alias Wario_Man_Trophy_AllStar = 0x6F
.alias Ridley_Trophy = 0x184
.alias Ridley_Trophy_AllStar = 0x186
.alias Waluigi_Trophy = 0xFF
.alias Charizard_Trophy = 0x75
.alias Squirtle_Trophy = 0x75
.alias Ivysaur_Trophy = 0x75

op b 0x34 @ $806E29DC	#Disables vBrawl Classic Mode trophy replacement behavior for the Poke Trio.

HOOK @ $800791F0		# Music-related?
{
  lwz r12, 0x170(r3)
  cmpwi r12, 0x0;  beq- loc_0x14
  mr r3, r12;  b %END%
loc_0x14:
  lwz r3, 0x194(r3)
}
HOOK @ $806E29D0		# Character trophy to load for Classic
{
  cmpwi r28, 0x2B;  ble+ GotTrophy
  li r29, Mewtwo_Trophy;  cmpwi r28, Mewtwo_Slot;  beq+ GotTrophy	# If it's Mewtwo's PM slot
  li r29, Roy_Trophy; 	  cmpwi r28, Roy_Slot;	   beq+ GotTrophy	# If it's Roy's PM slot
  li r29, Knuckles_Trophy;cmpwi r28, Knuckles_Slot;beq+ GotTrophy	# if it's Knuckles' P+ slot 
  li r29, Giga_Bowser_Trophy;cmpwi r28, Giga_Bowser_Slot;beq+ GotTrophy	# if it's Giga Bowser's slot 
  li r29, Wario_Man_Trophy;cmpwi r28, Wario_Man_Slot;beq+ GotTrophy	# if it's Wario-Man's slot 
  li r29, Ridley_Trophy;cmpwi r28, Ridley_Slot;beq+ GotTrophy	# if it's Ridley's P+Ex slot 
  li r29, Waluigi_Trophy;cmpwi r28, Waluigi_Slot;beq+ GotTrophy	# if it's Waluigi's P+Ex slot 
  li r29, 0x1		# Default to Mario!!!
GotTrophy:
  rlwinm r3, r29, 0, 16, 31
}
HOOK @ $806E47D8	# Character trophy to load for All-Star 
{
  cmpwi r4, Squirtle_Slot; beq- SquirtleTrophy
  cmpwi r4, Ivysaur_Slot; beq- IvysaurTrophy
  cmpwi r4, Charizard_Slot; beq- CharizardTrophy
  cmpwi r4, 0x2B;  ble+ GotTrophy
  li r26, Mewtwo_Trophy;  cmpwi r4, Mewtwo_Slot;   beq+ GotTrophy	# If it's Mewtwo's PM slot
  li r26, Roy_Trophy; 	  cmpwi r4, Roy_Slot;	   beq+ GotTrophy	# If it's Roy's PM slot
  li r26, Knuckles_Trophy;cmpwi r4, Knuckles_Slot; beq+ GotTrophy	# if it's Knuckles' P+ slot 
  li r26, Giga_Bowser_Trophy_AllStar;cmpwi r4, Giga_Bowser_Slot; beq+ GotTrophy	# if it's Giga Bowser's slot 
  li r26, Wario_Man_Trophy_AllStar;cmpwi r4, Wario_Man_Slot; beq+ GotTrophy	# if it's Wario-Man's slot 
  li r26, Ridley_Trophy_AllStar;cmpwi r4, Ridley_Slot; beq+ GotTrophy	# if it's Ridley's P+Ex slot
  li r26, Waluigi_Trophy;cmpwi r4, Waluigi_Slot; beq+ GotTrophy	# if it's Waluigi's P+Ex slot  
  li r26, 0x5D		# Default to Mario Finale!!!
  b GotTrophy
SquirtleTrophy:
  li r26, Squirtle_Trophy; b gotTrophy
IvysaurTrophy:
  li r26, Ivysaur_Trophy; b GotTrophy
CharizardTrophy:
  li r26, Charizard_Trophy
GotTrophy:
  rlwinm r3, r26, 0, 16, 31
}

#########################################################
BrawlEx Classic/All-Star Cosmetic ID Fix [KingJigglypuff]
#########################################################
op cmpwi r0, 0x80 @ $806C148C