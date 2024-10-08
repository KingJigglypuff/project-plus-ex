####################################################
All Characters Unlock Checks Are Unlocked [Kapedani]
####################################################
CODE @ $8004f4a0  # gmCheckChKindUseEnable
{
  li r3, 0x1 
  blr
}

CODE @ $8004f654  # gmCheckChKindUseEnableAll
{
  li r3, 0x1 
  blr 
}

###############################################
All Target Smash Levels are Unlocked [Kapedani]
###############################################
CODE @ $806838e8  # muSelCharTask::initProc
{
  nop 
  li r0, 5
}

#########################################################################
More Rules & Random Stage Switch are Selectable without Unlocking [Magus]
#########################################################################
op li r3, 1 @ $8004E818
op li r3, 1 @ $8004E83C

######################################################################
All Stages Selectable on Random Stage Switch without Unlocking [Magus]
######################################################################
op li r0, 0xFFF @ $806AB860
op li r0, 0xFFF @ $806AB8DC

######################################################
All-Star Mode is Selectable without Unlocking [Spigel]
######################################################
op li, r3, 1 @ $8004E7D0

##########################################################
Boss Battles Mode is Selectable without Unlocking [Spigel]
##########################################################
op li, r3, 1 @ $8004E7F4

