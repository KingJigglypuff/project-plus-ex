##############################################################
Teams Options v2 [PyotrLuzhin, Fracture, Yohan1044, Kapedani]
##############################################################
# Increase Vis0 frames and add to pat0 frame for MenSelchRFont in Misc Data[30]

.alias NUM_TEAM_OPTIONS     = 0x4

op stw r31, 0x5C8(r30) @ $806829b8  # initialize all bytes from 0x5C8 - 0x5CB to zero

HOOK @ $8068a48c    # muSelCharTask::buttonProcInAllArea
{
    lbz r12, 0x5CB(r31)         # \
    addi r12, r12, 0x1          # |
    cmpwi r12, NUM_TEAM_OPTIONS # | Increment teams option
    blt+ notMax                 # |
    li r12, 0x0                 # |
notMax:                         # /
    li r3, 0x1      # \
    cmpwi r12, 0x0  # | Check if should transition to team or no team
    beq+ notTeam    # |
    li r3, 0x0      # /
notTeam:
    stb r12, 0x5CB(r31)
}

HOOK @ $8068eea4    # muSelCharTask::setMeleeKind
{   
    lbz r12, 0x5CB(r28)   # \
    cmpwi r12, 0x0        # | check if teams
    beq+ %end%            # /
    addi r12, r12, 0x1    
    cmpwi r12, 0x2        # \ 
    beq+ isRegularTeams   # | check if regular teams
    addi r12, r12, 0x3    # |
isRegularTeams:           # /
    lis r11, 0x4330     # \ 
    stw r11, 0x8(r1)    # |
    stw r12, 0xC(r1)    # | frame = option + 4
    lfd f1, 0x270(r31)  # |
    lfd f0, 0x8(r1)     # |
    fsubs f31, f0, f1   # /
}

HOOK @ $80684720    # muSelCharTask::setToGlobal
{
    rlwinm. r0, r0, 1, 31, 31 # Original operation
    beq- %end%
    lbz r0, 1483(r26)
}
HOOK @ $806def0c    # sqSpMelee::setupSpMelee
{
    lbz	r12, 0x33(r25)   # Original operation
    addic r11,r12,-1    # \ selCharData.isTeams != 0
    subfe r0,r11,r12    # / 
}
HOOK @ $806dcef8    # sqVsMelee::setupMelee
{
    lbz	r12, 0x33(r30)   # Original operation
    addic r11,r12,-1    # \ selCharData.isTeams != 0
    subfe r0,r11,r12    # /
}
HOOK @ $806de83c    # sqToMelee::setupMelee
{
    lbz	r12, 0x33(r29)   # Original operation
    addic r11,r12,-1    # \ selCharData.isTeams != 0
    subfe r0,r11,r12    # /
}
CODE @ $80683cbc    # muSelCharTask::getDefaultFromGlobal
{
    stb r0, 0x5CB(r30) # store in unused byte
    addic r11,r0,-1    # \ selCharData.isTeams != 0
    subfe r0,r11,r0    # /
}
CODE @ $806b2fb8    # muSelectStageTask::dispPlayerFace
{
    cmpwi r27, 0x0
    beq+ 0xc
}
CODE @ $806b2d68    # muSelectStageTask::getRuleDispKind
{
    cmplwi r0, 0x0
    beqlr+
} 


################################################################################
[Legacy TE] Team Glow CSS Toggle v2 [PyotrLuzhin, Fracture, Yohan1044, Kapedani]
################################################################################
.alias g_GameGlobal                         = 0x805a00E0
.alias Fighter__getOwner                    = 0x8083ae24
.alias ftOwner__getPointTeam                = 0x8081bd90

.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}
.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro call(<addr>)
{
  	%lwi(r12, <addr>)
  	mtctr r12
  	bctrl    
}

HOOK @ $806895F4    # muSelCharPlayerArea::moveCoin
{
loc_0x0:
  lwz r3, 500(r27)
  lbz r3, 0x5C8(r3)
  cmpwi r3, 0x0
  beq- loc_0x18
  li r3, 0x0
  stb r3, 452(r27)

loc_0x18:
  mr r3, r27
}

HOOK @ $80689B90    # muSelCharTask::buttonProc
{
  li r0, 0x0
  lbz r12, 0x5CB(r24) # \
  cmpwi r12, 0x0      # |
  beq+ %end%          # | check if team glow
  cmpwi r12, 0x2      # | 
  beq- %end%          # /
  li r0, 0x1
}

HOOK @ $8069A2E0    # muSelCharPlayerArea::incCharColorNo
{
  li r27, 0x0
  lbz r12, 0x5CB(r8)  # \
  cmpwi r12, 0x0      # |
  beq+ %end%          # | check if team glow
  cmpwi r12, 0x2      # | 
  beq- %end%          # /
  li r27, 0x1
}

HOOK @ $8069A3F0    # muSelCharPlayerArea::decCharColorNo
{
  li r27, 0x0
  lbz r12, 0x5CB(r8)  # \
  cmpwi r12, 0x0      # |
  beq+ %end%          # | check if team glow
  cmpwi r12, 0x2      # | 
  beq- %end%          # /
  li r27, 0x1
}

HOOK @ $806974D0    # muSelCharPlayerArea::setCharPic
{
loc_0x0:
  cmpwi r27, 0x0  # Original operation
  beq- %end%
  lwz r12, 500(r30)   # \
  lbz r12, 0x5CB(r12) # | check if team glow
  cmpwi r12, 0x2      # /
}

HOOK @ $8068496c    # muSelCharTask::setToGlobal
{
  cmpwi r0, 0x0  # Original operation
  beq- %end%
  lbz r12, 0x5CB(r26) # \ check if team glow
  cmpwi r12, 0x2      # /
}

HOOK @ $80835f7c    # Fighter::start
{
  bctrl   # Original operation
  %lwd(r12, g_GameGlobal) # \
  lwz r12, 0x10(r12)      # |
  lbz r12, 0x33(r12)      # | check if g_GameGlobal->selCharData->teamType == 0x2
  cmpwi r12, 0x2          # |
  bne+ %end%              # /
  mr r3, r28
  %call (Fighter__getOwner)
  %call (ftOwner__getPointTeam)
  li r5, 0x10                 # \
  li r4, 0x88 # base gfx id   # |
  add r4, r4, r3              # |
  lwz r3, 0x60(r28)           # |
  lwz r3, 0xd8(r3)            # | fighter->moduleAccesser->moduleEnumeration->effectModule->reqEmit(team + 0x88, 0x10)
  lwz r3, 0x88(r3)            # |
  lwz r12, 0x0(r3)            # |
  lwz r12, 0x54(r12)          # |
  mtctr r12                   # |
  bctrl                       # /
}

HOOK @ $808364ec  # Fighter::restart
{
  bctrl   # Original operation
  %lwd(r12, g_GameGlobal) # \
  lwz r12, 0x10(r12)      # |
  lbz r12, 0x33(r12)      # | check if g_GameGlobal->selCharData->teamType == 0x2
  cmpwi r12, 0x2          # |
  bne+ %end%              # /
  mr r3, r30
  %call (Fighter__getOwner)
  %call (ftOwner__getPointTeam)
  li r5, 0x10                 # \
  li r4, 0x88 # base gfx id   # |
  add r4, r4, r3              # |
  lwz r3, 0x60(r30)           # |
  lwz r3, 0xd8(r3)            # | fighter->moduleAccesser->moduleEnumeration->effectModule->reqEmit(team + 0x88, 0x10)
  lwz r3, 0x88(r3)            # |
  lwz r12, 0x0(r3)            # |
  lwz r12, 0x54(r12)          # |
  mtctr r12                   # |
  bctrl                       # /
}

#####################################################################
Reset Teams on re-enter CSS if RandomTeams is Enabled [Eon, Kapedani]
#####################################################################
#Calls assignTeams if Random Teams is enabled
HOOK @ $80683634
{  
  lbz r12, 0x5C8(r30)
  cmpwi r12, 0 #if is teams (if not go to vanilla code)
  beq+ end 
  #if not third teams option added
  lbz r12, 0x5CB(r30)
  cmpwi r12, 3
  bne+ end
  mr r3, r30 #assign random teams
  lis r12, 0x8068
  ori r12, r12, 0xAC4C
  mtctr r12 
  bctrl 
end:
  li r3, 42
}

############################################
Assign Teams randomises colour & order [Eon]
############################################
.macro randi(<i>)
{
  li r3, <i> 
  lis r12, 0x8003
  ori r12, r12, 0xfc7c
  mtctr r12 
  bctrl 
}
.alias totalTeams = 3 #assumes this is prime (since all values less than it create a loop len totalTeams when adding and modulo'ing)
.alias totalTeamsSubOne = totalTeams-1
HOOK @ $8068ACD0
{
  cmpwi r6, 1 #r6 = number of chars to give each team, but i want how many teams to assign
  bne 0x8 
  li r6, totalTeams
  mr r30, r6  
 
  #initialise list filled with one random team 
  %randi(totalTeams) 
  li r4, 0x8
initialLoop:   #set everyone to base team 
  stwx r3, r1, r4 
  addi r4, r4, 0x4
  cmpwi r4, 0x14
  ble initialLoop
 
  %randi(totalTeamsSubOne)
  addi r29, r3, 1   #teamTwoOffset, loop through teams available by doing team = (team[0] + teamsTwoOffset*teamNum) % totalTeams
  li r28, 0
assignTeams:
  addi r28, r28, 1 #start at team 1 since team 0 is filled out already
  cmpw r28, r30
  bge end
  li r3, -1
  cmpwi r30, 2
  bne calcTeam
  %randi(3) #selects a random port from remaining ones to ignore
calcTeam:
  lwz r4, 0x8(r1) #teamOne
  mullw r5, r28, r29
  add r4, r5, r4
moduloTeams:
  cmpwi r4, totalTeams
  blt moduloDone
  subi r4, r4, totalTeams
  b moduloTeams
moduloDone:
  #r3 = gap
  #r4 = team
  #r5 = where to store into array
  mulli r5, r28, 4
  addi r5, r5, 0x4
assignTeamLoop:
  addi r5, r5, 4
  cmpwi r5, 0x14
  bgt assignTeams
  cmpwi r3, 0
  subi r3, r3, 1
  beq assignTeamLoop
  stwx r4, r1, r5
  b assignTeamLoop
end:
  lis r12, 0x8068
  ori r12, r12, 0xAD1C
  mtctr r12
  bctr   
}

####################################################
CPU Level 0 is Controlled by Team Member [Kapedani]
####################################################
.alias muSelCharPlayerArea__dispName    = 0x8069b1cc
.alias randi                            = 0x8003fc7c
.alias memcpy                           = 0x80004338

.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro call(<addr>)
{
  	%lwi(r12, <addr>)
  	mtctr r12
  	bctrl    
}

HOOK @ $80684c24  # muSelCharTask::setToGlobal
{
  lwz r28, 0xE0(r3)  # Original operation
  lbz r12, 0x33(r14)  # \
  cmpwi r12, 0x0      # | check if team mode
  beq+ end            # /
teamDouble:
  lwz r4, 0x10(r28)
  addi r29, r4, 0xb8
  addi r3, r1, 0x8
  li r4, 0x0
  stw r4, 0x8(r1)
  mr r17, r29
  li r18, 0x0
  addi r15, r1, 0x8
  addi r16, r1, 0xC
humanTrackLoop:   
  li r12, 0x0
  stb r12, 0x3d(r17)

  lbz r12, 0x1(r17) # \
  cmpwi r12, 0x0    # | check if human
  bne+ notHuman     # /
  lbz r9, 0xb(r17) # get team
  lbzx r11, r15, r9  # get num humans in team
  mulli r8, r9, 7  # \
  add r7, r16, r8   # | store player id in team array
  stbx r18, r7, r11  # /
  addi r11, r11, 0x1  # \ increment num in team
  stbx r11, r15, r9    # /
notHuman:
  addi r17, r17, 0x5C
  addi r18, r18, 0x1
  cmpwi r18, 0x7
  blt+ humanTrackLoop
  mr r17, r29
  li r18, 0x0 
cpuTrackLoop:
  lbz r12, 0x1(r17) # \
  cmpwi r12, 0x1    # | check if cpu
  bne+ notCpu       # /
  lbz r12, 0x1f(r17)  # \
  cmpwi r12, 0xff     # | check if ally cpu
  bne+ notCpu         # /
  lbz r19, 0xb(r17)  # get team
  lbzx r3, r15, r19  # get num in team
  cmpwi r3, 0x0    # \ check if no humans on team
  beq+ notCpu      # /
  %call(randi)
  mulli r8, r19, 7  # \
  add r7, r16, r8  # | get picked human
  lbzx r10, r7, r3  # /
  mulli r12, r10, 0x5C
  add r12, r12, r29
  lbz r11, 0x7(r12) # \ copy controllerNo
  stb r11, 0x7(r17) # /
  lbz r11, 0x18(r12)  # \ copy name index
  stb r11, 0x18(r17)  # /
  addi r3, r12, 0xc   # \
  addi r4, r17, 0xc   # | copy name tag
  li r5, 0xc          # |
  %call(memcpy)       # /
  li r12, 0x0         # \ set as human
  stb r12, 0x1(r17)   # /
  li r12, -1          # \ set controller id to be -1 to signify cpu player
  stb r12, 0x3d(r17)  # /
notCpu:
  addi r17, r17, 0x5C
  addi r18, r18, 0x1
  cmpwi r18, 0x7
  blt+ cpuTrackLoop
end:
  mr r3, r28
}

HOOK @ $80685210  # muSelCharTask::initControllerAssign
{
  lbz r12, 0xF5(r8) # \
  cmpwi r12, 0xff   # | check if controller id idx is -1
  bne+ end          # /
  li r12, 0x0         # \ set controllerNo to 0
  stb r12, 0xBF(r8)   # /
end:
  cmpwi	r10, 0  # Original operation
}

HOOK @ $806858f0  # muSelCharTask::initPlayerArea
{
  add	r31, r29, r0 # Original operation
  lbz r12, 0xF5(r31)  # \
  cmpwi r12, 0xff     # | check if controller id is -1
  bne+ %end%          # /
  li r12, 0x1         # \ set state to cpu player
  stb r12, 0xb9(r31)  # /
}

### Update UI to say "Ally"
HOOK @ $8069b2e8  # muSelCharPlayerArea::dispName
{
  li r31, 2  # Original operation
  lwz r12, 0x1F4(r27) # \
  lbz r12, 0x5CB(r12) # | check if team mode
  cmpwi r12, 0x0      # |
  beq+ %end%          # /
  lwz	r12, 0x1D4(r27) # \
  cmpwi r12, -1       # | check if ally cpu
  bne+ %end%          # /
isAlly:               
  li r31, 36  # set to custom msg line
}
HOOK @ $80698e34  # muSelCharPlayerArea::updateMeleeKind
{
  mr r3, r26                            # \
  lwz r4, 0x1c8(r26)                    # |
  lwz r5, 0x1b4(r26)                    # |
  lwz r6, 0x1F4(r26)                    # | this->dispName(nameID, playerKind, isTeamBattle, teamColor)
  lbz r6, 0x5C8(r6)                     # |
  lwz r7, 0x1c0(r26)                    # |
  %call(muSelCharPlayerArea__dispName)  # /
  lwz	r0, 0x1B4(r26)  # Original operation
}
HOOK @ $8069b050  # muSelCharPlayerArea::cpLeveListMain
{
  stw	r22, 0x1D4(r30) # Original operation
  mr r3, r30                            # \
  lwz r4, 0x1c8(r30)                    # |
  lwz r5, 0x1b4(r30)                    # |
  lwz r6, 0x1F4(r30)                    # | this->dispName(nameID, playerKind, isTeamBattle, teamColor)
  lbz r6, 0x5C8(r6)                     # |
  lwz r7, 0x1c0(r30)                    # |
  %call(muSelCharPlayerArea__dispName)  # /
}

### Expand cpu list
op li r30, 10 @ $8069f3c4 # \
op li r29, 10 @ $8069f518 # |
op li r30, 10 @ $8069f888 # | 
op li r30, 10 @ $806a0590 # |
op li r0, 10 @ $8069ff30  # | Increase cpu list size to 10
op li r30, 10 @ $806a0268 # |
op li r29, 10 @ $806a0340 # |
op li r29, 10 @ $806a03e8 # |
op li r31, 10 @ $8069fdc4 # /

op mr r6, r27 @ $8069fabc  # \ Shift index down
op nop @ $806a0654         # /
op addi r31, r5, 36 @ $8069f6d8 # Set starting msg line index to 36
HOOK @ $8069aef4  # muSelCharPlayerArea::openCpLevelList
{
  lwz	r5, 0x1D4(r3) # Original operation
  addi r5, r5, 0x1 # shift index up
}
HOOK @ $8069b018  # muSelCharPlayerArea::cpLevelListMain
{
  lwz	r22, 0x8(r1) # Original operation
  subi r22, r22, 0x1  # shift index down
}
HOOK @ $80693a70  # muSelCharPlayerArea::initDisp
{
  extsb r4, r4
  stw	r4, 0x01D4(r30) # Original operation
}
