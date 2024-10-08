####################################################################################
[CM_Addons] Melee-style Camera Freeze on Game Finish v1.0.0 [Eon, QuickLava]
# Original Code by Eon
# Addon adaption provided by QuickLava
####################################################################################
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

# Pause type 0 doesnt lock camera [Eon]
op rlwinm r3, r3, 5, 27, 30 @ $8009CAB8

# End game screen freezes [Eon]
# Requires pause code above for camera to not freeze
HOOK @ $806D34EC
{
  li r3, 0x4                         # Restore Original Instruction
  %lwd (r12, MLEEFREZ_ONOFF_LOC)     # \ Load the value at this line's LOC Address...
  lwz r12, 0x8(r12)                  # | ... then grab the current state of the Toggle.
  cmplwi r12, 0x00                   # | If it's disabled...
  beq %END%                          # / ... skip the code.
  lis r3, 0x805A                     # \
  lwz r3, -0x54(r3)                  # / Get gfApplication address
  li r4, 1                           # Enable pause
  li r5, 0                           # Pause type 0
  lis r12, 0x8001                    # \
  ori r12, r12, 0x6900               # |
  mtctr r12                          # |
  bctrl                              # / Run setPause
}