#############################################################
[Project+] Bomb Rain is an Item Frequency Setting [DukeItOut]
#############################################################
#op b 0x8 @ $806CF5EC
#op b 0x8 @ $806D3A68
HOOK @ $80951FBC
{
  stw r29, 0xC0(r3)		# Original operation
  lis r12, 0x9018
  lbz r0, 0xF36(r12);  cmplwi r0, 6; bne- %END% # Item Frequency setting
Bob-Omb: 
  lis r12, 0x8095			# \
  ori r12, r12, 0x2154		# | Go straight to sudden death bomb drops if enabled
  mtctr r12					# | as an Item Frequency setting
  bctr 						# /
}