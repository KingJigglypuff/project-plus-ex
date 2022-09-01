###################################################################
[Project+] Normal Ledge Getup Eliminates Ledge Cooldown [DukeItOut]
###################################################################
HOOK @ $8087B078
{
  mr r4, r3			# Original operation
  lwz r3, 0x7C(r30)	# \
  lhz r3, 6(r3)		# / Get the current action
  cmpwi r3, 0x77	# \
  bne+ %END%		# | Clear the timer if it is a normal ledge climbing animation
  li r4, 0x0		# /
}

###########################################
[Project+] Ledgedash Stabilizer [DukeItOut]
###########################################
HOOK @ $808386E0
{
  lwz r11, 0x60(r3)
  lwz r11, 0x1C(r11)
  lwz r11, 0x28(r11)
  lwz r11, 0x10(r11)
  lbz r0,  0x08(r11);  cmplwi r0, 3;  bne- notOnLedge	// is 3 if simultaneously in the air and on the ground, which only happens on the ledge
  lwz r11, 0x60(r3)
  lwz r11, 0x68(r11)
  lwz r11, 0x17C(r11)
  lwz r0, 0xBC(r11);  cmplwi r0, 9;  bge+ notOnLedge	
  li r0, 10				// Force it to behave as if 10 frames have passed if it is less than 10 and a ledgegrab occurs, otherwise don't modify
  stw r0, 0xBC(r11)
notOnLedge:
  addi r11, r1, 0x20	// restore the operation that was there
}

##############################
Tether LedgeGrab fix 2.0 [Eon]
##############################
#removing original fail situation
op b 0xB0 @ $808E91CC
#tether fail from inside stage, not tried to grab ledge
HOOK @ $808e951C
{
  lwz r12, 0x0(r31)
  mr r3, r31
  lis r4, 0x2200
  lwz r12, 0x4C(r12)
  mtctr r12
  bctrl
  cmpwi r3, 0
  beq end
  lis r26, 0x2200
  lis r12, 0x808E
  ori r12, r12, 0x91D0
  mtctr r12
  bctr
end:
  lwz r12, 0x0(r31)
}
#tether fail from repeated ledgegrab/whatever else, tried to grab ledge
HOOK @ $808e94B0
{
  lwz r12, 0x0(r31)
  mr r3, r31
  lis r4, 0x2200
  lwz r12, 0x4C(r12)
  mtctr r12
  bctrl
  cmpwi r3, 0
  beq end
  lis r26, 0x2200
  lis r12, 0x808E
  ori r12, r12, 0x91D0
  mtctr r12
  bctr
end:
  lwz r3, 0xD8(r27)
}


#####################################################################
[Project+] Tethers can connect to ledge through passable floors [Eon]
#####################################################################
HOOK @ $80120f6c
{
  lbz r0, 0x10(r5)
  andi. r0, r0, 0x1
  beq _end
  li r4, 1
_end:
  cmpwi r4, 0
}

###############################################
[Project+] Tether Displacement Glitch Fix [Eon]
###############################################

#on exit by getting hit from a tether
HOOK @ $80894fa8
{
  lis r12, 0x8089     #calls the execute function that positions the tether-er where they should be
  ori r12, r12, 0x4cb4
  mtctr r12
  bctrl


  mr r4, r31        #brings back correct r4 value 
  lwz r3, 0x00D8 (r4)   #original command
}