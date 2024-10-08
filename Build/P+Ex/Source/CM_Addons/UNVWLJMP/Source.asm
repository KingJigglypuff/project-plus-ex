####################################################################################
[CM_Addons] Universal Walljumps v1.0.1 [QuickLava]
# Original code by Dantarion!
####################################################################################
.include "Source/CM_Addons/AddonAliases.asm"

.macro lwd(<reg>, <addr>)
{
    .alias  temp_Lo = <addr> & 0xFFFF
    .alias  temp_Hi_ = <addr> / 0x10000
    .alias  temp_r = temp_Lo / 0x8000
    .alias  temp_Hi = temp_Hi_ + temp_r
    lis     <reg>, temp_Hi
    lwz     <reg>, temp_Lo(<reg>)
}

#Specific GetValueFloat is at 0x807827BC, Ghidra: 0x80790748 
HOOK @ $8085893C                  # Address = $(ba + 0x0085893C) [in "getConstInt/[ftInfo]/ft_info.o" @ $80858928]
{                                 
  cmpwi r3, 0x24                  # Before we overwrite r3, check if we're currently looking for the Walljump flag.
  lwzx r3, r3, r0                 # Then do the original operation to get the flag in the usual way.
                                  
  bne+ %END%                      # If we aren't looking at the flag for being able to Walljump, skip!
  
  %lwd(r12, UNVWLJMP_SETTING_LOC) # \ 
  lwz r12, 0x8(r12)               # / Otherwise, load the line's current setting.
  cmplwi r12, 0x02                # If the setting is set to default...
  beq+ %END%                      # ... then leave the value alone.
  mr r3, r12                      # Otherwise, override the flag with our own setting!
}