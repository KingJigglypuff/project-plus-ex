##############################################################
[CM_Addons] Hitfall Addon v1.0.1 [Eon, mawwwk, QuickLava]
# Original Code Menu version provided by mawwwk
# Addon adaption provided by QuickLava
##############################################################
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

.alias fallFrameBuffer = 5

HOOK @ $8077E8D4                # "First hook is innocuous on its own"
{
  stw r3, 0x10(r1)
  cmpwi r3, 0
}

HOOK @ $8077E8F4
{  
    lwz r31, 0x1C(r1)           # Original instr
	%lwd(r4, WIPMHTFL_ONOFF_LOC)
	lwz r4, 0x8(r4)
	
    cmpwi r4, 0                 # / Skip if toggled off
    beq end
    
    lwz r3, 0x10(r1)            # If hitstun/SDI-able code, just jump out its not worth it
    %lwi(r4, 0x80B897BC)
    cmpw r3, r4
    beq end

    lwz r3, 0xD8(r30)
    lwz r3, 0x5C(r3)
    lwz r12, 0x0(r3)
    lwz r12, 0x6C(r12)
    mtctr r12 
    bctrl                       # getFlickY 
    cmpwi r3, fallFrameBuffer   # Input window for tap input
    bge end
    
    lwz r3, 0xD8(r30)
    lwz r3, 0x5C(r3)
    lwz r12, 0x0(r3)
    lwz r12, 0x50(r12)
    mtctr r12 
    bctrl #getStickY
    lis r3, 0xbf1A
    stw r3, 0x1C(r1)
    lfs f2, 0x1C(r1)
    fcmpo cr0, f1, f2       # If stick not below threshold this frame
    bgt end                 # stop
    
    #set fastfall bit, if the move can fastfall, it will, even if you normally never would
    lwz r3, 0xD8(r30)
    lwz r3, 0x64(r3)
    lis r4, 0x2200          #ra-bit
    ori r4, r4, 0x2 #2
    lwz r12, 0x0(r3)
    lwz r12, 0x50(r12)
    mtctr r12 
    bctrl                   #onFlag   
    
end:
    lwz r0, 0x24(r1)
}