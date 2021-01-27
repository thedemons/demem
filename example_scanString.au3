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


; scan to find "test" string
Local $results = demem_scanString($hProcess, "test", 1000)

; scan for unicode strings
Local $results_unicode = demem_scanStringUnicode($hProcess, "test", 1000)

For $i = 0 To UBound($results) -1

	Local $readString = demem_readString($hProcess, $results[$i])
	ConsoleWrite(StringFormat("[0x%s] ascii: %s\n", $results[$i], $readString))
Next


For $i = 0 To UBound($results_unicode) -1

	Local $readString = demem_readStringUnicode($hProcess, $results_unicode[$i])
	ConsoleWrite(StringFormat("[0x%s] unicode: %s\n", $results_unicode[$i], $readString))
Next


; close the handle and the process
; upon termination, it will automatically closes any handles it opened but calling demem_close() is still a good idea.
demem_close($hProcess)
demem_dllClose()
ProcessClose($pid)



