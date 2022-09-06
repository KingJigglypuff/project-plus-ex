###################################################################
Y+X on GameCube Controller = short hop [DukeItOut]
#
# Modifies how controller bits 0x40 and 0x80
# are interpreted to facilitate new contexts
#
# 0x40 = X+Y (PSA Button 0xB. Made more applicable with this code.)
# 0x80 = X OR Y (PSA Button 0xC. Works like in Brawl.)
# 0x200 = L+R (PSA Button 0x11. New with this code.)
###################################################################
op b 0x10 @ $80048F3C # Disable D-Pad Up setting 8th bit (normal D-Pad Up check still exists)
op b 0x10 @ $80048F54 # Disable D-Pad Right setting 7th and 8th bits (normal D-Pad Right check still exists)
op rlwinm. r0, r0, 0, 20, 21 @ $80048EF0 # Y and X both can separately set the 8th bit
HOOK @ $80048F20	# Confirms BOTH Y and X were pressed. Replaces odd D-Pad Left check (normal D-Pad Left check still exists) 
{
	rlwinm. r0, r0, 0, 20, 21 # Mask for Y and X
	cmpwi r0, 0xC00		# were Y AND X pressed? If so, sets 0x0040
	crnot 2, 2			# invert cr0 eq flag
}
HOOK @ $80048ED8	# Normally registers the B press, but that's covered by input 2 for specials
{
	rlwinm. r0, r0, 0, 25, 26 # Mask for L and R
	cmpwi r0, 0x0060	# \ were L AND R pressed? If so, sets 0x0200 
	crnot 2, 2			# | invert cr0 eq flag
} 						# |
half 0x0200 @ $80048EE6	# /
half 0x0080 @ $80048F16 # Set to 0x40 or disable to split Y and X, making X a short hop button
HOOK @ $8076545C	# New button mask option 0x11 = 0x200 (L+R)
{
	li r3, 0	 # Original operation
	bne+ %END%	 # Compared with option 0x11
	li r3, 0x200 # New. Sets to added L+R mask.
}
CODE @ $80FAD86C
{
	word 0x000A0200; word 0x80FAD814 # if Bit is Set: RA-Bit[16]
	word 0x000A0200; word 0x80FAD824 # if a jump button is not held
	word 0x000E0000; word 0			 # else to invert the above and save space
	word 0x000A0200; word 0x80FAD89C # custom check: if Button(s) X+Y are both held down
	word 0x120A0100; word 0x80FAD834 # Bit variable Set: RA-Bit[6] = true
	word 0x00000000; word 0			 # ends check (clears out three end if on its own)
	word 0x6; word 0x32		# if Button is Held Down
	word 0x0; word 0x0B		# Button 0xB: X AND Y	
}

###################################################################
Y+X on Classic Controller = short hop [DukeItOut]
#
# Modifies how controller bits 0x40 and 0x80
# are interpreted to facilitate new contexts
#
# 0x40 = X+Y (PSA Button 0xB. Made more applicable with this code.)
# 0x80 = X OR Y (PSA Button 0xC. Works like in Brawl.)
# 0x200 = L+R (PSA Button 0x11. New with this code.)
#
# This is basically the GC one but addresses are increased by 0xE50
###################################################################
op b 0x10 @ $80049D8C # Disable D-Pad Up setting 8th bit (normal D-Pad Up check still exists)
op b 0x10 @ $80049DA4 # Disable D-Pad Right setting 7th and 8th bits (normal D-Pad Right check still exists)
op rlwinm. r0, r0, 0, 20, 21 @ $80049D40 # Y and X both can separately set the 8th bit
HOOK @ $80049D70	# Confirms BOTH Y and X were pressed. Replaces odd D-Pad Left check (normal D-Pad Left check still exists) 
{
	rlwinm. r0, r0, 0, 20, 21 # Mask for Y and X
	cmpwi r0, 0xC00		# were Y AND X pressed? If so, sets 0x0040
	crnot 2, 2			# invert cr0 eq flag
}
HOOK @ $80049D28	# Normally registers the B press, but that's covered by input 2 for specials
{
	rlwinm. r0, r0, 0, 25, 26 # Mask for L and R
	cmpwi r0, 0x0060	# \ were L AND R pressed? If so, sets 0x0200 
	crnot 2, 2			# | invert cr0 eq flag
} 						# |
half 0x0200 @ $80049D36	# /
half 0x0080 @ $80049D66 # Set to 0x40 or disable to split Y and X, making X a short hop button