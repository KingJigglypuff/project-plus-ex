##############################################################
Codes Sent with USB Gecko Append Existing Codeset v2.2 [Magus]
##############################################################
HOOK @ $80001CE0
{
  	lis r12, 0x8058
  	ori r12, r12, 0x0FE0
  	lwz r12, 0(r12)
}
HOOK @ $80001ECC
{
  lis r4, 0x8058
	ori r4, r4, 0x0FE0
	lwz r3, 0(r4)
	cmpwi r3, 0x0
	bne+ noneSent
	subi r3, r15, 0x8
	stw r3, 0(r4)
noneSent:
	lwz r4, 0(r18)
}