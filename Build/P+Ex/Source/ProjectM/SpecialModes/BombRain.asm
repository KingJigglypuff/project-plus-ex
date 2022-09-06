################################################
[Project+] Fixed Camera -> Bomb Rain [DukeItOut]
################################################
op b 0x8 @ $806CF5EC
op b 0x8 @ $806D3A68
HOOK @ $80951FBC
{
  stw r29, 0xC0(r3)		# Original operation
  lis r12, 0x9018
  lbz r0, 0xF36(r12);  cmplwi r0, 6; beq- Bob-Omb # Item Frequency setting
  lbz r0, -0xC81(r12); cmplwi r0, 1; bne- %END%   # Check Special Mode setting
Bob-Omb: 
  lis r12, 0x8095			# \
  ori r12, r12, 0x2154		# | Go straight to sudden death bomb drops if enabled via Special Brawl
  mtctr r12					# | or the Item Frequency setting
  bctr 						# /
}