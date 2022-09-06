###############################################################################
On the Fly Attribute Modification (Item Crash Fix) [codes, Mawootad, DukeItOut]
#
# Allows Attribute Range custom PSA commands to trigger:
#
# Attribute Range Set 		(12200200)
# Attribute Range Add	 	(12210200)
# Attribute Range Subtract	(12220200)
# Attribute Range Multiply	(12230200)
# Attribute Range Divide	(12240200)
###############################################################################
HOOK @ $807AD58C
{
  cmplwi r0, 0x20;  blt- skip	# \ Only trigger this custom code for options 0x20-0x24 (5 in total)
  cmplwi r0, 0x25;  bge- skip	# /
  mulli r29, r0, 8		    # r29 type is used to separate by 2 operations (8 bytes), look for the switch case
  subi r29, r29, 0x100		# Discard 0x00-0x1F, only 0x20-0x24 are used here (0x20 * 8)
  lwz r7, 0xD8(r31)			#
  lis r3, 0x80B8			# \ get value located at 80B868D8
  lwz r4, 0x68D8(r3)		# /
  lwz r3, 0xC4(r7)			#
  mulli r4, r4, 0x1C8		# r4 *= 0x1C8
  add r3, r3, r4			#
  addi r28, r3, 0x18		# r28 becomes the location of relevant float-based attribute values to use later
  
  rlwinm r31, r30, 20, 20, 31 # r31 contains the top half of the six-digit BBBAAA value (BBB)
  rlwinm r30, r30, 0, 20, 31  # r30 contains the bottom half of the six-digit BBBAAA value (AAA)
  bl forceOffset			# \
							# |
forceOffset:				# | Abuse link register logic to use the original r0 * 0xC (r29) and the
  mflr r0					# | current code's position in memory as an index and switch statement!
  addi r29, r29, 0x1C		# |
  add r29, r29, r0			# |
  mtctr r29					# /

writeLoop:
  rlwinm r0, r30, 2, 0, 29	# r0 = IC-Basic index * 4 to be spaced by words
  lfsx f0, r28, r0			# r28 = location of early IC-Basics on the assumption they're all floats
  bctr 						# TERRIFYING SWITCH CASE, GO!
case_0x20:  nop;				 b AttributeSet # Attribute Range Set
case_0x21:  fadds f31, f0, f31;  b AttributeSet # Attribute Range Add
case_0x22:  fsubs f31, f0, f31;  b AttributeSet # Attribute Range Subtract
case_0x23:  fmuls f31, f0, f31;  b AttributeSet # Attribute Range Multiply
case_0x24:  fdivs f31, f0, f31;  				# Attribute Range Divide

AttributeSet:
  stfsx f31, r28, r0		# Apply changed value to attribute
  addi r30, r30, 0x1		# \ increment AAA to potentially write consecutive attributes the same value
  cmpw r30, r31				# | if AAA < BBB, then we still need to write to consecutive members internal constants
  ble+ writeLoop			# / 
  
  lis r12, 0x807B			# \
  subi r12, r12, 0x2A44		# | finish custom command
  mtctr r12					# |
  bctr 						# /

skip:
  lis r3, 0x80AD			# Original operation
}

op cmpwi r0, 0x25 @ $807ACE78	# check range of operation types for command 12xxyyzz00)
HOOK @ $807ACEA0
{
  cmplwi r0, 0x25;  bge- %END%	# \ only modify if in range 0x20-x24
  cmplwi r0, 0x20;  blt+ %END%	# /
  lis r3, 0x807B				# \
  subi r3, r3, 0x2D60			# | Skip to here if in range 0x20-x24
  mtctr r3						# |
  bctr 							# /
}