#######################################################################################################
Load CSPs from RSP files [Phantom Wings, DukeItOut]
#
# Accesses portrait files from the results screen files 
# instead of sc_selcharacter.pac, at the cost of performance
#
# Likely will improve in speed if the first costume for characters
# are coded to be loaded from the CSPs and the RSPs are loaded for 
# other values, but has not been done, yet.
#
# Note that additional code work applied to this will need to be done
# to remove skin limitations, unfortunately, which has not been done
# yet!
#
# TODO: Make CSPs and RSPs have partitions at every 8th costume such that each brres loads separately
#
# PMEX will need to alter this code and whatever RSP code is also made to read from the costume set
# as the CSS does not inherently have access to the current costume desired by filename, just the 
# ofset within the total amount.
#
# r24 contains the costume (i.e. first is 0, second is 1, third is 2, etc.)
#######################################################################################################
HOOK @ $80693960
{
  cmpwi r24, 4				# \ Optional method to reduce scroll times on the CSS. Requires 4 costumes
  blt skipBypass			# / per character to be within selcharacter.pac. The rest will be loaded from RSPs.
  stwu r1, -0x150(r1)		
  addi r11, r1, 0x140		# \
  lis r12, 0x803F			# | preserve registers 3, 23-31
  ori r12, r12, 0x1310		# |
  mtctr r12					# |
  bctrl						# |
  stw r3,  0x110(r1)		# /
  
  mr r30, r3
  addi r3, r1, 0xA0
  lis r4, 0x8045
  ori r4, r4, 0x6ED0
  mr r5, r30
  lis r12, 0x803F			# \
  ori r12, r12, 0x89FC		# | Write string "/menu/common/char_bust_tex/MenSelchrFaceB%02d0.brres"
  mtctr r12					# |
  bctrl 					# /
  addi r3, r1, 0x8
  addi r4, r1, 0xA0
  lwz r5, 0x438(r31)
  li r6, 0x0
  li r7, 0x0
  lis r12, 0x8002			# \
  ori r12, r12, 0x239C		# | Set up this file to be read.
  mtctr r12					# |
  bctrl 					# /
  addi r3, r1, 0x8
  li r18, 0					# It's possible to trigger the offset coding in the FPC while loading the CSS, prevent that!
  lis r12, 0x8001			# \
  ori r12, r12, 0xBF0C		# | Read the file
  mtctr r12					# |
  bctrl 					# /
  cmpwi r3, 0
  lwz r3,  0x110(r1)		# \
  addi r11, r1, 0x140		# |
  lis r12, 0x803F			# | restore registers 1, 3, 23-31
  ori r12, r12, 0x135C		# |
  mtctr r12					# |
  bctrl						# |
  lwz r1, 0(r1)  			# /
  bne skipBypass			# If you didn't find the file, attempt to load it from selcharacter.pac
							# This allows you to customize the string that it loads from, should you want separate CSPs and RSPs
  lis r12, 0x8069 			  
  ori r12, r12, 0x3988
  mtctr r12
  bctr
  
complete:
skipBypass:
  lis r4, 0x1				# Original operation
}
op NOP @ $8069705C			# Suppress an unnecessary character texture read that would otherwise double load times!