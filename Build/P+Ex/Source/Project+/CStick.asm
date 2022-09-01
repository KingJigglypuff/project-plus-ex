###################################################################################
C-stick Smash Fixes + functional tilt stick (reverse ftilt included) [camelot, Eon]
###################################################################################
#original moved address were 
#.alias C_Stick_Off  = 0x80546C38
#.alias C_Stick_Off2 = 0x80546C88

.alias C_Stick_Off  = 0x805410A0
.alias C_Stick_Off2 = 0x80541120
.alias C_Stick_Off3 = 0x80541190
#utilt to usmash (up + smashstick up != utilt)
CODE @ $805410A0
{
	#If: Requirement Value Button Press Occurs: F (cstick used to initate move) 
	word 6; word 0x30
	word 0; word 0xF
	#Change Action: Requirement: Action=30, Requirement=Character Exists?
	word 0; word 0x30
	word 6; word 0
	#And: Comparison Compare: IC-Basic[1018] >= IC-Basic[3158]
	word 6; word 7 			#Compare
	word 5; IC_Basic 1018 	#Control Stick Y Axis
	word 0; word 4 			#>=
	word 5; IC_Basic 3158 	#Upsmash Sensitivity

	word 2; word C_Stick_Off+0x48

	word 0x02010200; word 0x80FABAF4		#Change Action: Requirement: Action=E, Requirement=In Air
	word 0x000A0200; word C_Stick_Off 		#If: Requirement Value Button Press Occurs: F
	word 0x000B0400; word C_Stick_Off+0x20 	#And: Comparison Compare: IC-Basic[1018] >= IC-Basic[3158]
	word 0x02010200; word C_Stick_Off+0x10 	#Change Action: Requirement: Action=30, Requirement=Character Exists?
	word 0x000F0000; word 0 				#endif
	word 0x00080000; word 0 				#return
}
CODE @ $80FB29CC
{
	word 0x00070100; word C_Stick_Off+0x40
}
#dtilt to dsmash (down + smashstick down != dtilt)
CODE @ $80541120
{
	#Change Action: Requirement: Action=2D, Requirement=Character Exists?
	word 0; word 0x2D
	word 6; word 0
	#And: Comparison Compare: IC-Basic[1018] <= IC-Basic[3160]
	word 6; word 7 			#Compare
	word 5; IC_Basic 1018 	#Control Stick Y Axis
	word 0; word 1 			#<=
	word 5; IC_Basic 3160 	#Dsmash Sensitivity

	word 2; word C_Stick_Off2+0x38

	word 0x02010200; word 0x80FABAF4 		#Change Action: Requirement: Action=E, Requirement=In Air
	word 0x000A0200; word C_Stick_Off 		#If: Requirement Value Button Press Occurs: F
	word 0x000B0400; word C_Stick_Off2+0x10	#And: Comparison Compare: IC-Basic[1018] <= IC-Basic[3160]
	word 0x02010200; word C_Stick_Off2 		#Change Action: Requirement: Action=2D, Requirement=Character Exists?
	word 0x000F0000; word 0 				#endif
	word 0x00080000; word 0 				#return
}
CODE @ $80FC2498
{
	word 0x00070100; word C_Stick_Off2+0x30
}
#jab to reverse ftilt (tilt stick backwards != jab forwards)
CODE @ $80541190
{
	#Change Action: Requirement: Action=27, Requirement=Character Exists?
	word 0; word 0x27
	word 6; word 0x00
	#And: Comparison Compare: IC-Basic[1012] >= IC-Basic[3151]
	word 6; word 7 			#Compare
	word 5; IC_Basic 1012 	#Control Stick Relative X Axis (-1 Forward, 1 Backward)
	word 0; word 4 			#>=
	word 5; IC_Basic 3151 	#Ftilt Threshold

	word 2; word C_Stick_Off3+0x38 

	word 0x02010200; word 0x80FABAF4 		#Change Action: Requirement: Action=E, Requirement=In Air
	word 0x000A0200; word C_Stick_Off 		#If: Requirement Value Button Press Occurs: F
	word 0x000B0400; word C_Stick_Off3+0x10	#And: Comparison Compare: IC-Basic[1012] >= IC-Basic[3151]
	word 0x05000000; word 0 				#Reverse Direction
	word 0x02010200; word C_Stick_Off3 		#Change Action: Requirement: Action=27, Requirement=Character Exists?
	word 0x000F0000; word 0 				#endif
	word 0x00080000; word 0 				#return
}
CODE @ $80FB203C
{
	word 0x00070100; word C_Stick_Off3+0x30
}

###############################################################################
[Project+] C-Stick Debug Mode and Slow Mode fix v4.3 [Fracture, DukeItOut, Eon]
###############################################################################
HOOK @ $800489f8
{
    mr r12, r6
    lis r6, 0x80B8; lwz r6, 0x4EB0(r6)
    lis r7, 0x8000
    cmplw r6, r7    //check if r6 is a real address
    li r7, 0x1    //we no longer need r7 for comparison, so we can change it before the verdict
    blt- finish    //Don't execute if the functionality isn't loaded, yet.
    lbz r0, 0x48(r6); cmpwi r0, 0x0; beq- additionalCheck
    lwz r0, 0x40(r6); cmpwi r0, 0x0; bne- additionalCheck
    li r7, 0
additionalCheck:
    lis r6, 0x805C; lbz r6, -0x75F5(r6)    #debug pause
    cmpwi r6, 0x0;    beq- isJustGameFrameCheck 	
    lis r6, 0x805C; lbz r6, -0x75F6(r6)    #debug frame advance
	cmpwi r6, 0; bne isJustGameFrameCheck
    li r7, 0
isJustGameFrameCheck:
	lis r6, 0x9018
	ori r6, r6, 0x12A0
	lbz r6, 0xA(r6)
	cmpwi r6, 0
	beq finish
	li r7, 0
finish:
    cmpwi r29, 2500
    mr r6, r12

}
HOOK @ $80048bc4
{
    cmpwi r7, 1
    bne _end
    stb	r27, 0 (r25)
_end:
    cmplwi	r24, 5
}

HOOK @ $80048b74
{
    cmpwi r7, 1
    bne _end
    stb	r3, 0x0003 (r25)
_end:
}

HOOK @ $80048bdc
{
    cmpwi r7, 1
    bne _end
    stb	r0, 0x0003 (r25)
_end:
}

#######################################
[Project+] Custom C-stick options [Eon]
#######################################

#Utaunt replaced by general Taunt Stick
#STaunt replaced by smashstick with charging smashes allowed

HOOK @ $80048BB0
{
  cmpwi r24, 0xa #utaunt
  beq taunt
  cmpwi r24, 0xb #staunt
  beq smashCharge
  cmpwi r24, 0xc #dtaunt
  beq tiltstick
  b end


taunt:
.alias uTaunt = 0x0580
.alias lTaunt = 0x2940
.alias rTaunt = 0x49C0
.alias dTaunt = 0x1100

  lhz r0, 0 (r23)

  cmpwi r4, 75
  blt 0xC
  ori r0, r0, rTaunt
  b tauntstickEnd

  cmpwi r4, -75
  bgt 0xC
  ori r0, r0, lTaunt
  b tauntstickEnd

  cmpwi r5, 0
  blt 0xC
  ori r0, r0, uTaunt
  b tauntstickEnd

  ori r0, r0, dTaunt
  b tauntstickEnd
tauntstickEnd:
  sth r0, 0 (r23)
  b end

smashCharge:
  cmpwi r22, 0
  beq 0x14 #stick input only first active frame
  stb r4, 0x0004 (r25)
  stb r5, 0x0005 (r25)
  stb r4, 0x0002 (r23)
  stb r5, 0x0003 (r23)

  #a input every frame
  lhz r0, 0 (r23)
  ori r0, r0, 0x0021
  sth r0, 0 (r23)

  b end

tiltstick:
  cmpwi r22, 0
  beq end
  li r24, 0 #spoof attack stick for when this code is returned to

  #loads buttons held 
  lhz r0, 0(r23)
  #enables control-stick override 
  li r26, 1
  #load 0.5 to the float that usually is 0.35 for attack stick, this allows angled ftilt instead of jab
  lis r12, 0x3f00
  ori r12, r12, 0x999A
  stw r12, 0x30(r1)
  lfs f2, 0x30(r1) 


  #jump into attack stick coding at appropriate place
  lis r12, 0x8004
  ori r12, r12, 0x8adc 
  mtctr r12 
  bctr

end:
  cmpwi r26,0
}


[Project+] C-stick mushing Fix [Eon]
op andi. r16, r27, 2 @ $80048a10


###############################################################
[Project+] C-Stick throws 2.0 [Eon, Dantarion, standardtoaster]
###############################################################
.alias C_Stick_off = 0x805480F0
.alias C_Stick_off2 = 0x80548220

#override original action exit of action 0x39 and 0x3A
word 0x80548178 @ $80FC04B8 
word 0x80548178 @ $80FC04BC

CODE @ $805480F0
{

	#0x00 if button press occurs Cstick 
	word 6; word 0x30
	word 0; word 0xF
	#0x10 if LA-Float[34] >= 0.8
	word 6; word 7
	word 5; LA_Float 34
	word 0; word 4
	word 1; scalar 0.5
	#0x30 elseif LA-Float[34] <= -0.8
	word 6; word 7
	word 5; LA_Float 34
	word 0; word 1
	word 1; scalar -0.5
	#0x50 elseif LA-Float[35] >= 0
	word 6; word 7
	word 5; LA_Float 35
	word 0; word 4
	word 1; scalar 0
	#0x70 goto original code
	word 2; word 0x80FC1E70
	#0x78
	word 6; word 0x80000008
	word 5; RA_Bit 16

	word 0x000A0200; word C_Stick_off+0x00 	#If Button Press Occurs F:
	word 0x000B0200; word C_Stick_off+0x78  #and bit not set RA-Bit[16]
	word 0x000A0400; word C_Stick_off+0x10 	#	if LA-Float[34] >= 0.75
	word 0x12000200; word 0x80faf97c 		# 		Basic Variable set RA-Basic[0] = 0x73 #fthrow
	word 0x000D0400; word C_Stick_off+0x30 	# 	elseif LA-Float[34] <= -0.75
	word 0x12000200; word 0x80faf96c 		#		Basic Variable set RA-Basic[0] = 0x72 #bthrow
	word 0x000D0400; word C_Stick_off+0x50 	# 	elseif LA-Float[35] >= 0 
	word 0x12000200; word 0x80faf9ac 		# 		Basic Variable set RA-Basic[0] = 0x74 #uthrow
	word 0x000E0000; word 0					# 	else
	word 0x12000200; word 0x80faf9dc		# 		Basic Variable set RA-Basic[0] = 0x75 #dthrow
	word 0x000F0000; word 0 				# 	endif
	word 0x000E0000; word 0					#else
	word 0x00070100; word C_Stick_off+0x70 	#	goto original action exit
	word 0x000F0000; word 0					#endif
}
CODE @ $80548220
{
	word 2; word C_Stick_Off2+0x20
	word 0; word 0x3C 
	word 6; word 0x30
	word 0; word 0xF 
	word 0x02010300; word C_Stick_Off2+0x08
	word 0x02000600; word 0x80FAF754
	word 0x02040400; word 0x80FAF784
	word 0x02040100; word 0x80FAF7A4
	word 0x02000600; word 0x80FAF7AC
	word 0x02040400; word 0x80FAF7DC
	word 0x02040100; word 0x80FAF7FC
	word 0x02000600; word 0x80FAF804
	word 0x02040400; word 0x80FAF834
	word 0x02040100; word 0x80FAF854
	word 0x02010300; word 0x80FAF734
	word 0x02040100; word 0x80FAF74C
}

word 0x00020000 @ $80FC1E70
word 0x00020000 @ $80FC1F60

CODE @ $80FAF85C 
{
	word 0x00090100; word C_Stick_Off2
}

Cstick Neutral range = Cstick input range [Eon]
#removes where cstick is in neutral but not close enough to allow a new cstick input
op cmpwi r29, 2500 @ $80048bd0
