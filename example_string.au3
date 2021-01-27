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

; read a string at $baseAddress
Local $string_at_baseAddress = demem_readString($hProcess, $baseAddress)
ConsoleWrite(StringFormat("String at $baseAddress: %s\n", $string_at_baseAddress))

; write a string to $baseAddress
demem_writeString($hProcess, $baseAddress, "Hello World!")

; read the string again
$value_of_baseAddress = demem_readString($hProcess, $baseAddress)
ConsoleWrite(StringFormat("New string: %s\n", $value_of_baseAddress))


; read with a length of 8
$value_of_baseAddress = demem_readString($hProcess, $baseAddress, 8)
ConsoleWrite(StringFormat("Read with a length of 8: %s\n", $value_of_baseAddress))

; close the handle and the process
; upon termination, it will automatically closes any handles it opened but calling demem_close() is still a good idea.
demem_close($hProcess)
ProcessClose($pid)

