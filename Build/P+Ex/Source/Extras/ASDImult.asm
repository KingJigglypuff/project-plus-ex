###########################################
ASDI SDI multiplier conditional [DukeItOut]
###########################################
#
# Makes negative SDI Multipliers identical
# to positive ones BUT with the following
# exception:
#
# The base ASDI properties are retained
# and are not multiplied
###########################################
HOOK @ $80876BF8 # SDI
{
	fabs f0, f0			# Remove negative SDI mult component if present
	fmuls f0, f31, f0	# Original operation
}
HOOK @ $80874F9C	# Shield SDI
{
	bctrl				# Original Operation.
	fabs f1, f1			# Remove negative component if present
}
HOOK @ $80876F68 # ASDI
{
	fmuls f0, f31, f0	# Original operation.
	lfs f2, 0x10(r13)	# 0.0
	fcmpu cr0, f0, f2	# check if the SDI mult is negative or not
	bge+ %END%			# Act normally if so!
	fmr f0, f31			# Just make it the base ASDI value if negative
}