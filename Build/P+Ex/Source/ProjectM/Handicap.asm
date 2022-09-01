######################
Ignore Handicap [Y.S.]
######################
op li r0, 0 @ $80050550

#######################################################
Handicap = Stock Count v1.6 [InternetExplorer, wiiztec]
#######################################################
HOOK @ $8094690C
{
  lis r12, 0x9017;  ori r12, r12, 0xF37A
  lbz r12, 0(r12)
  cmpwi r12, 0x2;  beq- %END%
  extsb r4, r4
  lwz r12, 0x48(r26)
  mulli r11, r12, 0x5C
  lis r12, 0x9018;  ori r12, r12, 0xFDE
  lhzx r12, r12, r11
  li r11, 0xA
  divw r12, r12, r11
  cmpwi r12, 0x0;  beq- loc_0x40
  mr r4, r12

loc_0x40:
  lwz r3, 0(r3)
  stw r4, 0x34(r3)
  li r8, 0x3FED
}
HOOK @ $80693138
{
  lis r12, 0x9018;  lbz r12, -0xC86(r12);  
  cmpwi r12, 0x2;  beq- loc_0x30
  cmplwi r3, 2;    bne- loc_0x30
  lis r4, 0x9017;  ori r4, r4, 0xF360
  lbz r4, 2(r4);  
  cmplwi r4, 1;  beq- loc_0x30
  li r3, 0x0
loc_0x30:
  cmpw r3, r29
}

##################################################
Auto Handicap = Crew Mode v1.02 [InternetExplorer]
##################################################
HOOK @ $8081C538
{
  rlwinm r12, r1, 16, 0, 15
  rlwinm r12, r12, 16, 16, 31
  cmplwi r12, 0x4DE0;  beq- loc_0x2C
  lwz r8, 0(r3)
  mulli r8, r8, 0x2
  lis r14, 0x9018;  ori r14, r14, 0x1260
  add r14, r14, r8
  mulli r11, r4, 0xA
  sth r11, 0(r14)
loc_0x2C:
  stw r4, 52(r3)
}
op li r0, 0x3	@ $80053E8C
op NOP 			@ $8004DA18
// modified for compatibility by wiiztec

##############################################
Ignore Damage Gauge Setting [InternetExplorer]
##############################################
op li r3, 1 @ $8005063C

######################################################
Damage Gauge Toggles 3-Frame Buffer [InternetExplorer]
######################################################
HOOK @ $8085B784
{
  lis r3, 0x9017;  ori r3, r3, 0xF36C
  lbz r3, 0(r3)
  cmpwi r3, 0x1	# \
  li r3, 0x0	# | If the handicap damage gauge is enabled . . . 
  bne- %END%	# /
  li r3, 0x3	# Set the buffer to 3 frames instead of 0
}