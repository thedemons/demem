#include <Array.au3>
#include "demem.au3"
#AutoIt3Wrapper_UseX64=Y


; we need to load the demem.dll library in order to use scan functions

If @AutoItX64 Then
	demem_dllOpen("demem64.dll")
Else
	demem_dllOpen("demem.dll")
EndIf


If Not demem_isDllLoaded() Then
	ConsoleWrite(StringFormat("!> Failed to load demem library\n"))
	Exit
EndIf

; open notepad and get its pid
Local $pid = Run("notepad.exe")
ProcessWait($pid)

; open handle to the process by demem_open()
Local $hProcess = demem_open($pid)
If $hProcess = False Then
	ConsoleWrite(StringFormat("!> Failed to open the process\n"))
	Exit
EndIf


; scan 69 and get the first result
Local $result = demem_scanValue($hProcess, 69, "int")

; read the value at that address
Local $value = demem_readInt($hProcess, $result)
ConsoleWrite(StringFormat("Found a result at: 0x%s  -  value: %d\n", $result, $value))


; scan 69 (int) and get multiple results, with the maximum of 1000 results
Local $results = demem_scanValue($hProcess, 69, "int", 1000)
_ArrayDisplay($results)

; scan 69 (float) from base address to the end
Local $baseAddress = demem_getBaseAddress($hProcess)
$results = demem_scanValue($hProcess, 69, "float", 1000, $baseAddress, 0)
_ArrayDisplay($results)

; scan 69 (float) from the start to base address
$results = demem_scanValue($hProcess, 69, "float", 1000, 0, $baseAddress)
_ArrayDisplay($results)


; close the handle and the process
; upon termination, it will automatically closes any handles it opened but calling demem_close() is still a good idea.
demem_close($hProcess)
demem_dllClose()
ProcessClose($pid)



