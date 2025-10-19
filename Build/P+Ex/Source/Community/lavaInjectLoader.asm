######################################################################################
[lavaInjectLoader] Inject Load Bootstrap v1.0.1 [QuickLava]
# Provides an entrypoint for the injection GCTs loaded in at runtime!
# Inspired by the Multi-GCT approach, hijacks the codehandler's r15 value
# to force it to run over each new GCT as it loads in, then branch back!
# v1.0.1 - Properly validates the inject GCT's location, to avoid crashes on hackless.
######################################################################################
PULSE
{
  lwz r12, 0x17F4(r31)           # Load current inject GCT's location.
  andis. r0, r12, 0xEC00        # |\ Validate Address: Specifically, checks if address is within
  rlwinm r0, r0, 16, 16, 31     # || 0x80000000 - 0x84000000
  cmplwi r0, 0x8000             # || 0x90000000 - 0x94000000
  bne- exit                     # |/ ... and exit if it isn't.
  mr r15, r12                    # Otherwise, put that new address into r15 to force execution over to it...
  li r4, 0x08                    # ... and set r4 to 0x8, so we hop over the incoming GCT's header.
  li r12, 0x00                   # \
  stw r12, 0x17F4(r31)           # / Zero out the GCT location word, to ensure we don't try to run it again.
exit:
  blr                            # Return.
}
* 4E000008 00000000              # Write the address of the following .RESET into PO...
* 4C000000 000017F0              # ... and write it to 0x800017F0, to signal where incoming GCTs should return to!
.RESET