#########################################################################
[lavaInjectLoader] Inject Load Bootstrap v1.0.0 [QuickLava]
# Provides an entrypoint for the injection GCTs loaded in at runtime!
# Inspired by the Multi-GCT approach, hijacks the codehandler's r15 value
# to force it to run over each new GCT as it loads in, then branch back!
#########################################################################
PULSE
{
  lwz r12, 0x17F4(r31)           # Load current inject GCT's location.
  cmplwi r12, 0x00               # Check if loaded address was zero...
  beq+ exit                      # ... and exit if it was.
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