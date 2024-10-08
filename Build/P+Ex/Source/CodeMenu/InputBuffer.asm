
################################
Per Player Input Buffer [Desiac]
################################

  .alias CodeMenuStart = 0x804E
  .alias CodeMenuHeader = 0x02C4       #Offset of word containing location of the player 1 toggle. Source is compiled with headers for this.

HOOK @ $8085B788
{  
  stw r3, 0x015C (r31)    #Store Original input buffer.
  b AccessStoredData
CodeStart:
  mtlr r3 #Restore Link Register
  lwz r3, 44(r31)       
  lwz r3, 244(r3)       #Obtain Player ID by means beyond me.
  mulli r3, r3, 0x4
  lwzx r3, r3, r4     #Load Stored Option Selection  
  cmpwi r3, 0         #If selected input buffer is not 0, override.
  beq END
  stw r3, 0x015C (r31)
  b END
AccessStoredData:
  mflr r3
  bl 0x4
  mflr r4
  addi r4, r4, 0x30    #Access Storage Area in following Pulse Code
  b CodeStart
END:
}

PULSE
{
CreateStorage:
  mflr r6
  bl 0x4
  mflr r16
  addi r16, r16, 0xC   #Create a storage area
  b Initialize
  nop #Player1 Storage 
  nop #Player2 Storage
  nop #Player3 Storage
  nop #Player4 Storage
  nop #InitializeState
  nop #Temp Storage
  nop #Temp Storage 2
Initialize:
  mtlr r6 #Restore Link Register, free up R6
  stw r7, 0x14 (r16)  #Store R7
  stw r8, 0x18 (r16)  #Store R8
  lwz r6, 16 (r16)
  li r7, 1
  cmpw r6, r7
  beq CodeStart
  li r6, 0
  stw r6, 0(r16)
  stw r6, 4(r16)
  stw r6, 8(r16)
  stw r6, 12(r16)
  stw r7, 16(r16)
CodeStart:
  lis r6, 0x8058
  ori r6, r6, 0x4084    #Pause to Hold. This is 1 when in Game. Input Buffer changing in game crashes
  lwz r6, 0 (r6)
  cmpwi r6, 1
  beq LockCodeMenu
  lis r6, 0x804E
  ori r6, r6, 0x0034    #Code Menu On/Off. If Code Menu is off, do not update.
  lwz r6, 0 (r6)
  cmpwi r6, 0
  bne StoreBufferData
  b Restore
LockCodeMenu:
  lis r6, CodeMenuStart
  ori r6, r6, CodeMenuHeader
  lwz r7, 0x0 (r6)  #Lock Code Menu if in game.
  lwz r8, 0x0 (r16)
  stb r8, 0xB (r7)
  lwz r7, 0x4 (r6) 
  lwz r8, 0x4 (r16)
  stb r8, 0xB (r7)
  lwz r7, 0x8 (r6) 
  lwz r8, 0x8 (r16)
  stb r8, 0xB (r7)
  lwz r7, 0xC (r6) 
  lwz r8, 0xC (r16)
  stb r8, 0xB (r7)
  b Restore
StoreBufferData:
  lis r6, CodeMenuStart
  ori r6, r6, CodeMenuHeader
  lwz r7, 0x0 (r6)  #Load from Code Menu Toggles, move to Storage
  lbz r7, 0xB (r7)
  stw r7, 0x0 (r16)
  lwz r7, 0x4 (r6)
  lbz r7, 0xB (r7)
  stw r7, 0x4 (r16)
  lwz r7, 0x8 (r6)
  lbz r7, 0xB (r7)
  stw r7, 0x8 (r16)
  lwz r7, 0xC (r6)
  lbz r7, 0xB (r7)
  stw r7, 0xC (r16)
Restore:
  lwz r7, 0x14 (r16)  #Restore R7
  lwz r8, 0x18 (r16)  #Restore R7
return:
  blr
}
.RESET