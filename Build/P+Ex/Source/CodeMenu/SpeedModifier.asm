###################################
Speed Modifier for Code Menu [Desi]
###################################

  .alias CodeMenuStart = 0x804E
  .alias CodeMenuHeader = 0x02D8      #Offset of word containing location of the speed modifier. Source is compiled with headers for this.

HOOK @ $8001730C
{
  lis r3, 0x8058
  lwz r3, 0x4084 (r3)
  cmpwi r3, 1           #Pause to Hold. If not in game, run original instruction
  bne Off
  lis r3, CodeMenuStart
  lwz r3, CodeMenuHeader(r3)
  cmpwi r3, 0           #If code menu isn't loaded, run original instruction
  beq Off
  lbz r3, 0xB (r3)
  cmpwi r3, 0
  beq Off
  cmpwi r3, 1
  beq ONEPOINTTWOFIVEX
  cmpwi r3, 2
  beq ONEPOINTFIVEX
  cmpwi r3, 3
  beq TWOX
  cmpwi r3, 4
  beq ONEHALFX
  cmpwi r3, 5
  beq THREEFOURTHSX
ONEPOINTTWOFIVEX:
    li r3, 75
    b %END%
ONEPOINTFIVEX:
    li r3, 90
    b %END%
TWOX:
    li r3, 120
    b %END%
ONEHALFX:
    li r3, 30
    b %END%
THREEFOURTHSX:
    li r3, 45
    b %END%
Off:
    lhz r3, 0xF8 (r23)  #Original Instruction. Load Frame Rate from 805850D0
}