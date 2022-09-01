#############################################
[Legacy TE] Default CPU level is 9 v2 [codes]
#############################################
HOOK @ $8004C8B4
{
  li r29, 8
  stb r29, 0xD7(r24)
}
HOOK @ $8004C908
{
  stb r29, 0x1EB(r24)
  li r29, 0x2
}
op li r0, 8 @ $8004D058

