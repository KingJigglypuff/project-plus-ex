######################################
Grabboxes work out of any action [Eon]
######################################
op nop @ $8083D250
op nop @ $8083D25C

###################################################
Falco can use his own final smash files [DukeItOut]
###################################################
op b 0x58 @ $8084D5B8
op b 0x5C @ $8084D450

########################################
!RSP Load Character Swap Fix [DukeItOut]
########################################
op NOP  @ $8069705C			# Disabled by default. Taken from "CostumeAddition.asm". Suppress an unnecessary character texture read that would otherwise double load times! Use only if utilizing RSP loading with an Ex build.

###############################################
Mario Fireballs are Costume Based [codes, ds22]
###############################################
# Prevent storing resource ID for textures, as the hijack below sets it
op nop @ $809E8138

# Hijacks the function active/[wnMarioFireball]
HOOK @ $809E8124
{
  start:
    # get player index (0-3 for players 1-4)
    lwz r31, 0x18(r25)
    lwz r31, 0x18(r31)
    lwz r31, 0x5C(r31)
    lwz r31, 0xC4(r31)
    lbz r31, 0x55(r31)
    
    # follow pointer chain to get fighter ID
    lwz r25, 0x18(r25)
    lwz r25, 0x8(r25)
    lwz r25, 0x110(r25)

    # check if the fighter IDs are the ones we care about
    cmpwi r25, 0x4A			#Merkava
    beq- be_costume_based	#If you wish to add more Mario Clone IDs to the check, copy these two lines, and paste them underneath this line, then edit the ID to check for.
    b act_normally

  be_costume_based:
    # read into the resources list for the fighter,
    # indexing with our player index,
    # as well as a small offset which should be near where we're looking for
    lis r25, 0x80B8
    lwz r25, 0x7C50(r25)
    lwz r25, 0(r25)
    mulli r31, r31, 0x4D4
    add r25, r25, r31
    addi r25, r25, 0x18

  search_loop:
    # loop through until we pass over a value less than 0xFF.
    # words around this place can often be 0xFFFF 
    lwzu r4, 4(r25)
    cmpwi r4, 0xFF
    bge+ search_loop

    # store a value indicating the resource ID for the costume file
    # in place of the one for the MotionEtc
    stw r4, 0x2C(r1)
    b end

  act_normally:
    # this is the line NOP'd by the gecko write
    stw r5, 0x2C(r1)

  end:
    # restore hijacked code
    mr r31, r3
}

###############################
Custom IC-Variable Engine [Eon]
###############################
#exposes a range from IC-Basic[30000] to IC-Basic[30031]
#writes a pointer at 0x80548D00 to the function array.

#write pointer to function for IC-variable, e.g. to add IC-Basic[30000+i] write function pointer at (0x80548D00) + i*0x4

HOOK @ $8079721C
{
  cmpwi r4, 30000
  blt original
  subi r0, r4, 30000
  rlwinm r0, r0, 2, 0, 29
  lis r3, 0x8054
  ori r3, r3, 0x8D00
  lwz r3, 0x0(r3)
  lwzx r12, r3, r0
  cmpwi r12, 0
  beq exit  #if unset, return 0
  mr r3, r29  #r3 = soModuleAccessor of object
              #r4 = the IC-Basic requested
  mr r5, r31  #r5 = i honestly dont know but this is important enough to be passed through function calls in the other accessors so you get it too
  mtctr r12
  bctrl

exit:
  lis r12, 0x8079
  ori r12, r12, 0x72B4
  mtctr r12
  bctr
original:
  lwz r3, 0x8(r3)
}

  .BA<-functions  
  .BA->$80548D00 #function array pointer
  .RESET
  .GOTO->end
functions:
int[32] 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
end:

##################################
Timestamp at IC-Basic[30000] [Eon]
##################################
#first two lines get function pointer
  .BA<-CustomCommand
* 42100000 00000008 #BA+=8 to abuse Pulse command as an easy way to write a block of code
#get function array, write to wanted index, in this case 4*0x0 = 0x0
* 48000000 80548D00
* 54010000 00000000 #set second word to 4*IC-variable you want it to be
  .RESET
  .GOTO->end

CustomCommand:
PULSE
{
    stwu r1, -0x10(r1)
    mflr r0
    stw r0, 0x14(r1)

    #gfSceneManager.getInstance() static function
    #could just be replaced by `lwz r3, -0x43C0(r13)` if you feel like it`
    lis r12, 0x8002
    ori r12, r12, 0xD018
    mtctr r12 
    bctrl 

    #r4 = "scMelee"
    lis r4, 0x8070
    addi r4, r4, 0x1B50
    addi r4, r4, 64

    lis r12, 0x8002
    ori r12, r12, 0xD3F4
    mtctr r12 
    bctrl #gfSceneManager.searchScene("scMelee")

    lwz r3, 0x54(r3) #\scMelee.stOperatorRuleMelee.currentFrameCounter 
    lwz r3, 0xE8(r3) #/
    
    lwz r0, 0x14(r1)
    mtlr r0
    addi r1, r1, 0x10
    blr
}
end: