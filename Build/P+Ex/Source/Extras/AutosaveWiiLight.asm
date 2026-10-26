###############################################################
Force Wii Light on When Autosave Replays is On [Eon, QuickLava]
###############################################################
# Currently only works during a match, not in menus
.alias CM_AUTOSAVE_REPLAYS_FLAG_HI = 0x804E
.alias CM_AUTOSAVE_REPLAYS_FLAG_LO = 0x003C
.alias DISC_LIGHT_REG_ADDR_HI = 0xCD00
.alias DISC_LIGHT_REG_ADDR_LO = 0x00C0
PULSE
{
  lis r11, CM_AUTOSAVE_REPLAYS_FLAG_HI         # \ Verify that the code menu is loaded before we continue!
  lhz r12, 0x0004(r11)                         # | Load the upper two bytes of the Code Menu's Main Page pointer...
  cmplwi r12, CM_AUTOSAVE_REPLAYS_FLAG_HI      # | ... and check if it's the expected value.
  bne- exit                                    # / If it isn't, menu isn't loaded, skip the following.
  
  lwz r12, CM_AUTOSAVE_REPLAYS_FLAG_LO(r11)    # Load the state of the flag, it'll be 2 if Autosave is on and we're in a match!        
  lis r11, DISC_LIGHT_REG_ADDR_HI              # \ 
  lwz r0, DISC_LIGHT_REG_ADDR_LO(r11)          # / Load the value of the disc light register...
  rlwimi r0, r12, 4, 26, 26                    # ... mask the current value of the auto save line as the light state value.
  stw r0, DISC_LIGHT_REG_ADDR_LO(r11)          # Store the resulting register value back where it belongs.
  
exit:
  blr                                          # Return!
}