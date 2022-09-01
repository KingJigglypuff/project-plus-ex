################################################
[Project+] Fixed Camera -> Bomb Rain [DukeItOut]
################################################
op b 0x8 @ $806CF5EC
op b 0x8 @ $806D3A68
HOOK @ $80951FBC
{
  stw r29, 0xC0(r3)		# Original operation
  lis r12, 0x9018
  lbz r0, -0xC81(r12)
  cmplwi r0, 1
  bne- %END%
  lis r12, 0x8095			# \
  ori r12, r12, 0x2140		# | Go straight to sudden death bomb drops if enabled via Special Brawl
  mtctr r12					# |
  bctr 						# /
}
HOOK @ $80952144
{
  lfs f0, 0x20(r31)		# Original operation
  lis r12, 0x9018
  lbz r0, -0xC81(r12)
  cmplwi r0, 1
  bne- %END%
  lis r12, 0x8095			# \
  ori r12, r12, 0x2154		# | Skip Sudden Death timer check, go straight to dropping bombs.
  mtctr r12					# | 
  bctr 						# /
}