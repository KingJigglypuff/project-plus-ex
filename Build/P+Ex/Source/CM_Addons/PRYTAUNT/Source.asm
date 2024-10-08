##################################################################################################
Parry Taunts (Addon Version) v1.0.0 [QuickLava]
# Getting hit within the first 10.0f frames of a taunt will leave you actionable!
# Getting hit within frames 11.0f - 20.0f will instead partially negate received knockback!
##################################################################################################
.include "Source/CM_Addons/AddonAliases.asm"

.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}

.alias playSE = 0x800742B0
.alias successSoundInfoIndex = 0x01
.alias perfectSoundInfoIndex = 0x1D
.alias failSoundInfoIndex = 0x20

HOOK @ $8077F9D8
{
  mr r29, r3                     # \
  mr r30, r4                     # | Backup argument registers, since we're gonna be doing some function calls.
  mr r31, r5                     # /

  %lwd(r12, PRYTAUNT_ONOFF_LOC)
  lwz r12, 0x8(r12)
  cmplwi r12, 0x00
  beq exit
  
  lwz r12, 0x34(r3)              # \
  cmplwi r12, 0x10C              # | If we're not currently taunting...
  bne+ exit                      # / ... skip.

  cmplwi r4, 0x43                # \
  blt+ exit                      # |
  cmplwi r4, 0x4C                # | If target action is between 0x45 and 0x4C (ie. we're getting hit)...
  bgt+ exit                      # /


  lwz r11, 0xD8(r5)              # Get soModuleEnumeration ptr (leaving enum in r11!).
  lwz r12, 0x08(r11)             # Get soMotionModuleImpl ptr.
  lfs f13, 0x40(r12)             # Get current frame.
  lfs f12, -0x2DD4(r13)          # Load 10.0f in f12...
  fadds f11, f12, f12            # ... and double it into f11 for 20.0f.
  fcmpo cr1, f13, f11            # Compare the current frame against 20.0f...
  blt+ cr1, parrySuccessful      # ... and if we're below that, we succeded! Jump to parry code!

  li r4, failSoundInfoIndex      # \ Otherwise, we failed...
  bl playSoundSubroutine         # / ... so play fail sound...
  b exit                         # ... and exit!

parrySuccessful:

  lwz r12, 0x5C(r11)

  li r4, successSoundInfoIndex   # \
  bl playSoundSubroutine         # / Otherwise, we've succeeded! play the success sound!

  fcmpo cr1, f13, f12            # Compare current frame against 10.0f...
  bgt+ cr1, parryImperfect       # ... and if we're above that, we missed the perfect parry, so skip!

                                 # Otherwise, we were perfect!
  li r4, perfectSoundInfoIndex   # \
  bl playSoundSubroutine         # / So, we'll play the perfect sound too!
                                 #
  li r4, 0x1                     # \
  bl enableTermSubroutine        # / Enable Special Cancels
  li r4, 0x2                     # \
  bl enableTermSubroutine        # / Enable Item Cancels
  li r4, 0x3                     # \
  bl enableTermSubroutine        # / Enable Grab Cancels
  li r4, 0x4                     # \
  bl enableTermSubroutine        # / Enable Attack Cancels
  li r4, 0x7                     # \
  bl enableTermSubroutine        # / Enable Jump Cancels
  li r4, 0x8                     # \
  bl enableTermSubroutine        # / Enable Movement Cancels!
                                 #
                                 # Cancel Status Change!
  lwz r12, 0x44(r1)              # Recover LR from the stack...
  mtlr r12                       # ... and restore it to LR.
  addi r1, r1, 0x40              # Deallocate the stack...
  blr                            # ... and return so we stay in taunt!

parryImperfect:
  li r4, 0x41                    # \ 
  b exitWithoutStatusRestore     # / Cancel into CaptureJump on imperfect parries!

exit:
  mr r4, r30                　    # Restore Status ID register.
exitWithoutStatusRestore:
  mr r3, r29                　    # \ Restore Status Module Register.
  mr r5, r31                　    # / Restore Module Accessor Reg.
  cmpwi r4, -1                   # Restore Original Instruction.
  b %END%                        # Exit HOOK!

enableTermSubroutine:
  lwz r3, 0x2C(r29)        　     # Get Transition Module Entity ptr in r3 in preparation for function call.
  lwz r12, 0x00(r3)              # Load Transition Module vTable...
  lwz r12, 0x1C(r12)             # Load enableTermGroup func ptr!
  mtctr r12                      # \
  bctr                           # / Call! Don't set LR, so we branch back to where we were.

playSoundSubroutine:
  lwz r3, -0x4250(r13)           # Load g_sndSystem pointer
  li r5, -0x1
  li r6, 0x0
  li r7, 0x0
  %lwi(r12, playSE)              # \
  mtctr r12                      # / Play sound effect!
  bctr                           # Don't set LR, so we branch back to where we were.
}