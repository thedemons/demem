#include "demem.au3"
#AutoIt3Wrapper_UseX64=Y


; open notepad and get its pid
Local $pid = Run("notepad.exe")
ProcessWait($pid)

; open handle to the process by demem_open()
Local $hProcess = demem_open($pid)
If $hProcess = False Then
	ConsoleWrite(StringFormat("!> Failed to open the process\n"))
	Exit
EndIf

; get the base address
Local $baseAddress = demem_getBaseAddress($hProcess)
ConsoleWrite(StringFormat("Base address: 0x%s\n", $baseAddress))

; read an int value at the base address
Local $value_of_baseAddress = demem_readInt($hProcess, $baseAddress)
ConsoleWrite(StringFormat("Value of the base address: %d\n", $value_of_baseAddress))

; write an int value to the base address
demem_writeInt($hProcess, $baseAddress, 999999)

; read the value again
$value_of_baseAddress = demem_readInt($hProcess, $baseAddress)
ConsoleWrite(StringFormat("New value of the base address: %d\n", $value_of_baseAddress))

; close the handle and the process
; upon termination, it will automatically closes any handles it opened but calling demem_close() is still a good idea.
demem_close($hProcess)
ProcessClose($pid)

