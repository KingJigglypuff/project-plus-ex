##################################################################
[Project+] 1-P Battles Don't Use Start Countdown [JOJI, DukeItOut]
##################################################################
HOOK @ $806D182C
{
  cmpwi r0, 0;  bne- normal	# not multiplayer if non-zero
  lis r12, 0x9018;  ori r12, r12, 0xF5D	# 90180F5D+5C= 90180FB9, the first address we need, with each port separated by 0x5C bytes
  lbzu r3, 0x5C(r12)	# note that is a load with update and not a load, reading port 1
  lbzu r5, 0x5C(r12)	# reading port 2
  add r3, r3, r5
  lbzu r5, 0x5C(r12)	# reading port 3
  add r3, r3, r5
  lbzu r5, 0x5C(r12)	# reading port 4
  add r3, r3, r5
  cmplwi r3, 9;  blt+ normal
  li r0, 0x2		# force to skip countdown if the sum suggests that more than 2 ports are inactive
normal:
  mulli r0, r0, 0x14
}
# Removed from main codeset due to replay incompatibility.