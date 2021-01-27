#cs ---------------------------------------------------------------------------

library:							demem
.						a simple memory library for autoit

author:         thedemons
discord:		thedemons#8671
facebook:		/demonsmsc


functions:

	demem_open
	demem_close

	demem_read
	demem_write

	demem_readInt
	demem_readFloat
	demem_readDouble
	demem_readWord
	demem_readByte

	demem_writeInt
	demem_writeFloat
	demem_writeDouble
	demem_writeWord
	demem_writeByte

	demem_readString
	demem_readStringUnicode
	demem_writeString
	demem_writeStringUnicode
	
	demem_getBaseAddress
	demem_getModuleAddress

	// requires loading the demem.dll library
	demem_dllOpen
	demem_dllClose
	demem_isDllLoaded

	demem_scanAOB
	demem_scanValue
	demem_scanString
	demem_scanStringUTF8
	demem_scanStringUnicode


#ce ----------------------------------------------------------------------------


#include-once
#include <ProcessConstants.au3>
#include <WinAPI.au3>

Global Const $PROCESS_DEMEM_ACESS = BitOR($PROCESS_QUERY_INFORMATION, $PROCESS_VM_OPERATION, $PROCESS_VM_READ, $PROCESS_VM_WRITE)
Global $__dedmem_handle = -1
Global $__kernel_handle = -1





; Return handle to a process
;
; $pid:				the id of the target process
; $desiredAccess:	the access permission
;					default: $PROCESS_ALL_ACCESS
;					see more in https://docs.microsoft.com/en-us/windows/win32/procthread/process-security-and-access-rights
; [Return]
;	success:		a handle to the target process
;	failed:			false, OpenProcess failed, call _WinAPI_GetLastErrorMessage() for more details
;
; [Remarks]:			see _WinAPI_OpenProcess in the help file.
Func demem_open($pid, $desiredAccess = $PROCESS_ALL_ACCESS)

	Local $hProcess = _WinAPI_OpenProcess($desiredAccess, false, $pid)
	If @error Then $hProcess = _WinAPI_OpenProcess($PROCESS_DEMEM_ACESS, false, $pid)

	Return SetError(@error, 0, $hProcess)
EndFunc



; Close the process handle
;
; $hProcess:		the process handle returned by demem_open
;
; [Return]
;	success:		true
;	failed:			false, CloseHandle failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_close($hProcess)
	Return _WinAPI_CloseHandle($hProcess)
EndFunc



; Read memory
;
; $type:	type of the value
;			-	int, byte, float, double..
;			-	see more types in DllStructCreate help file.
;
; [Return]
;	success:	the memory value
;	failed:		false, ReadProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_read($hProcess, $address, $type = "int")

	Local $buffer = DllStructCreate($type)
	Local $iRead = 0
	Local $result = __demem_rpm($hProcess, $address, $buffer, $iRead)
	
	Return $result ? DllStructGetData($buffer, 1) : False
EndFunc



; Write to memory
;
; $type:	type of the value
;			-	int, byte, float, double..
;			-	see more types in DllStructCreate help file.
;
; [Return]
;	success:	the number of bytes written
;	failed:		false, WriteProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_write($hProcess, $address, $value, $type = "int")

	Local $buffer = DllStructCreate($type)
	DllStructSetData($buffer, 1, $value)
	Local $iWritten = 0

	Local $result = __demem_wpm($hProcess, $address, $buffer, $iWritten)
	Return $result ? $iWritten : False
EndFunc



; Read an int (4 bytes) from memory
;
; [Return]
;	success:	the memory value
;	failed:		false, ReadProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_readInt($hProcess, $address)

	Local $result = demem_read($hProcess, $address, "int")
	Return SetError(@error, 0, $result)
EndFunc



; Read a float (4 bytes) from memory
;
; [Return]
;	success:	the memory value
;	failed:		false, ReadProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_readFloat($hProcess, $address)

	Local $result = demem_read($hProcess, $address, "float")
	Return SetError(@error, 0, $result)
EndFunc



; Read a double (8 bytes) from memory
;
; [Return]
;	success:	the memory value
;	failed:		false, ReadProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_readDobule($hProcess, $address)

	Local $result = demem_read($hProcess, $address, "double")
	Return SetError(@error, 0, $result)
EndFunc



; Read a word (2 bytes) from memory
;
; [Return]
;	success:	the memory value
;	failed:		false, ReadProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_readWord($hProcess, $address)

	Local $result = demem_read($hProcess, $address, "word")
	Return SetError(@error, 0, $result)
EndFunc



; Read a byte from memory
;
; [Return]
;	success:	the memory value
;	failed:		false, ReadProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_readByte($hProcess, $address)

	Local $result = demem_read($hProcess, $address, "byte")
	Return SetError(@error, 0, $result)
EndFunc



; Write an int (4 bytes) to memory
;
; [Return]
;	success:	the number of bytes written
;	failed:		false, WriteProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_writeInt($hProcess, $address, $value)

	Local $result = demem_write($hProcess, $address, $value, "int")
	Return SetError(@error, 0, $result)
EndFunc



; Write a float (4 bytes) to memory
;
; [Return]
;	success:	the number of bytes written
;	failed:		false, WriteProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_writeFloat($hProcess, $address, $value)

	Local $result = demem_write($hProcess, $address, $value, "float")
	Return SetError(@error, 0, $result)
EndFunc



; Write a double (8 bytes) to memory
;
; [Return]
;	success:	the number of bytes written
;	failed:		false, WriteProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_writeDouble($hProcess, $address, $value)

	Local $result = demem_write($hProcess, $address, $value, "double")
	Return SetError(@error, 0, $result)
EndFunc



; Write a word (2 bytes) to memory
;
; [Return]
;	success:	the number of bytes written
;	failed:		false, WriteProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_writeWord($hProcess, $address, $value)

	Local $result = demem_write($hProcess, $address, $value, "word")
	Return SetError(@error, 0, $result)
EndFunc



; Write a byte to memory
;
; [Return]
;	success:	the number of bytes written
;	failed:		false, WriteProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_writeByte($hProcess, $address, $value)

	Local $result = demem_write($hProcess, $address, $value, "byte")
	Return SetError(@error, 0, $result)
EndFunc



; Read a string from memory
;
; $len:		length of the string you need to read
;			default: 0 - auto detect the length of the string, max length for this is 32kb
;
; [Return]
;	success:	the string
;	failed:		false, ReadProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_readString($hProcess, $address, $len = 0)
	
	If $len < 0 Then Return False

	If $len <> 0 Then
			
		Local $buffer = DllStructCreate(StringFormat("char[%d]", $len))
		Local $iRead = 0
		Local $result = __demem_rpm($hProcess, $address, $buffer, $iRead)

		Return $result ? DllStructGetData($buffer, 1) : False

	Else
		
		Local $string = ""
		Local $old_strlen = 0, $strlen = 0
		Local $buffer_len = 8
		Local $loop_ = 0 

		While True
				
			Local $buffer = DllStructCreate(StringFormat("char[%d]", $buffer_len))
			Local $iRead = 0
			Local $result = __demem_rpm($hProcess, $address + $loop_ * $buffer_len, $buffer, $iRead)
			
			$string &= DllStructGetData($buffer, 1)
			$strlen = StringLen($string)
			
			If ($strlen - $old_strlen) < $buffer_len Then ExitLoop
			If $strlen >= (1024*32 - $buffer_len) Then ExitLoop
			If $result = False Then ExitLoop
			
			$old_strlen = $strlen
			$loop_ += 1
		WEnd

		Return ($strlen == 0) ? False : _WinAPI_MultiByteToWideChar($string, 65001, 0, True)
	EndIf

EndFunc



; Read a unicode string from memory
;
; $len:		length of the string you need to read
;			default: 0 - auto detect the length of the string, max length for this is 32kb
;
; [Return]
;	success:	the string
;	failed:		false, ReadProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
Func demem_readStringUnicode($hProcess, $address, $len = 0)
	
	If $len < 0 Then Return False

	If $len <> 0 Then
			
		Local $buffer = DllStructCreate(StringFormat("wchar[%d]", $len))
		Local $iRead = 0
		Local $result = __demem_rpm($hProcess, $address, $buffer, $iRead)
			
		Return $result ? DllStructGetData($buffer, 1) : False

	Else
		
		Local $string = ""
		Local $old_strlen = 0, $strlen = 0
		Local $buffer_len = 1024
		Local $loop_ = 0 

		While True
				
			Local $buffer = DllStructCreate(StringFormat("wchar[%d]", $buffer_len))
			Local $iRead = 0
			Local $result = __demem_rpm($hProcess, $address + $loop_ * $buffer_len*2, $buffer, $iRead)
			
			$string &= DllStructGetData($buffer, 1)
			$strlen = StringLen($string)
			
			If ($strlen - $old_strlen) < $buffer_len Then ExitLoop
			If $strlen >= (1024*32 - $buffer_len) Then ExitLoop
			If $result = False Then ExitLoop
			
			$old_strlen = $strlen
			$loop_ += 1
		WEnd

		Return ($strlen == 0) ? False : $string
	EndIf

EndFunc



; Write a string to memory
;
; $string:	string to write
; $len:		length of the string, 
;			0:		write the string with a NULL byte at the end
;			-1:		write the string without a NULL byte
;			default: 0
;			custom:	the length in bytes
;					if bigger than the actual length of the string in bytes,
;					it will replace those bytes with NULL
;
; [Return]
;	success:	the number of bytes written
;	failed:		false
;
; @error	1: WriteProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
;			2: the string is invalid
Func demem_writeString($hProcess, $address, $string, $len = 0)

	Local $strlen = StringLen($string)
	If $strlen <= 0 Then Return SetError(2, 0, False)
		

	Local $struct_str = _WinAPI_WideCharToMultiByte($string, 65001, False)

	Local $struct_size = DllStructGetSize($struct_str)
	If $len = 0 Then 
		$len = $struct_size
	ElseIf $len = -1 Then
		$len = $struct_size - 1
	EndIf

	Local $struct_str_final = DllStructCreate(StringFormat("char[%d]", $len), DllStructGetPtr($struct_str))
	Local $iWritten = 0

	Local $result = __demem_wpm($hProcess, $address, $struct_str_final, $iWritten)

	Return $result ? $iWritten : False
EndFunc



; Write a unicode string to memory
;
; $string:	string to write
; $len:		length of the string, 
;			0:		write the string with a NULL byte at the end
;			-1:		write the string without a NULL byte
;			default: 0
;			custom:	the length in bytes
;					if bigger than the actual length of the string in bytes,
;					it will replace those bytes with NULL
;
; [Return]
;	success:	the number of bytes written
;	failed:		false
;
; @error	1: WriteProcessMemory failed, call _WinAPI_GetLastErrorMessage() for more details
;			2: the string is invalid
Func demem_writeStringUnicode($hProcess, $address, $string, $len = 0)

	Local $strlen = StringLen($string)
	If $strlen <= 0 Then Return SetError(2, 0, False)
		
	If $len = 0 Then 
		$len = $strlen + 1
	ElseIf $len = -1 Then
		$len = $strlen
	EndIf

	Local $struct_str = DllStructCreate(StringFormat("wchar[%d]", $len))
	DllStructSetData($struct_str, 1, $string)
	Local $iWritten = 0

	Local $result = __demem_wpm($hProcess, $address, $struct_str, $iWritten) 

			
	Return $result ? $iWritten: False
EndFunc



; Load the demem library
;
; $dll_path:		path to the library
;
; [Return]
;	success:		true
;	failed:			false
Func demem_dllOpen($dll_path)

	$__dedmem_handle = DllOpen($dll_path)
	Return ($__dedmem_handle = -1) ? False : True
EndFunc



; Close the demem library
;
; [Return]			none
Func demem_dllClose()
	DllClose($__dedmem_handle)
	$__dedmem_handle = -1
EndFunc


; Return true if the demem library is loaded
Func demem_isDllLoaded()
	Return ($__dedmem_handle <> -1)
EndFunc



; Scan an array of bytes (pattern)
;
; $AOB:				the array of bytes
;					example format: "48 93 ?? 90 D8 ?? 75"
; $result_count:	max number of results
;					default: 0  -  return 1 result
;
; [Return]
;	success:	the first address found, if $result_count is specified then return an array of results
;	failed:		false and set the @error to non-zero
;
; @error	1: demem library isn't loaded
;			2: DllCall to demem failed, @extended is the @error of DllCall
;			3: the pattern is invalid
Func demem_scanAOB($hProcess, $AOB, $result_count = 0, $addrStart = 0, $addrEnd = 0)

	If $__dedmem_handle = -1 Then Return SetError(1, 0, False)

	; replace multiple ??? with a single ?
	$AOB = StringStripWS(StringRegExpReplace($AOB, "\?+", "?"), 8)

	; replace ? in the AOB with 00 byte
	Local $pattern = StringReplace($AOB, "?", "00")

	; if the pattern isn't valid
	If Mod(StringLen($pattern), 2) == 1 Then return SetError(3, 0, False)

	; create pattern struct
	$struct_pattern = DllStructCreate(StringFormat("byte[%d]", StringLen($pattern)/2))
	DllStructSetData($struct_pattern, 1, ("0x" & $pattern))

	; create a mask for the pattern
	Local $mask = ""
	For $i = 0 To StringLen($AOB)-1 Step 2
		If StringMid($AOB, $i+1, 1) == "?" Then
			$i -= 1
			$mask &= "?"
		Else
			$mask &= "x"
		EndIf
	Next

	Local $result = __demem_internal_scanstruct($hProcess, $struct_pattern, $mask, $result_count, $addrStart, $addrEnd, false)
	
	If @error Then Return SetError(2, @extended, $result)
	Return $result
EndFunc



; Scan a value
;
; $value:		the value you want to scan
; $type:		type of the value
;				-	int, byte, float, double,..
;				-	see more types in DllStructCreate help file.
; $fast_scan:	true - scan 4 bytes allignment
;				false - scan 1 bytes allignment
;
; [Return]
;	success:	the first address found, if $result_count is specified then return an array of results
;	failed:		false and set the @error to non-zero
;
; @error	1: demem library isn't loaded
;			2: DllCall to demem failed, @extended is the @error of DllCall
Func demem_scanValue($hProcess, $value, $type = "int", $result_count = 0, $addrStart = 0, $addrEnd = 0, $fast_scan = true)

	If $__dedmem_handle = -1 Then Return SetError(1, 0, False)

	; create pattern struct
	Local $struct_pattern = DllStructCreate($type)
	DllStructSetData($struct_pattern, 1, $value)

	Local $result = __demem_internal_scanstruct($hProcess, $struct_pattern, "", $result_count, $addrStart, $addrEnd, $fast_scan)

	If @error Then Return SetError(2, @extended, $result)
	Return $result
EndFunc



; Find a string (ascii)
;
; $string:		the string
; $fast_scan:	true - scan 4 bytes allignment
;				false - scan 1 bytes allignment
;				default: false
;
; [Return]
;	success:	the first address found, if $result_count is specified then return an array of results
;	failed:		false and set the @error to non-zero
;
; @error	1: demem library isn't loaded
;			2: DllCall to demem failed, @extended is the @error of DllCall
Func demem_scanString($hProcess, $string, $result_count = 0, $addrStart = 0, $addrEnd = 0, $fast_scan = false)

	If $__dedmem_handle = -1 Then Return SetError(1, 0, False)
	
	Local $type = StringFormat("char[%d]", StringLen($string) )
	Local $result = demem_scanValue($hProcess, $string, $type, $result_count, $addrStart, $addrEnd, $fast_scan)
	Return SetError(@error, 0, $result)
EndFunc



; Find a string (unicode)
;
; $string:		the string
; $fast_scan:	true - scan 4 bytes allignment
;				false - scan 1 bytes allignment
;				default: false
;
; [Return]
;	success:	the first address found, if $result_count is specified then return an array of results
;	failed:		false and set the @error to non-zero
;
; @error	1: demem library isn't loaded
;			2: DllCall to demem failed, @extended is the @error of DllCall
Func demem_scanStringUnicode($hProcess, $string, $result_count = 0, $addrStart = 0, $addrEnd = 0, $fast_scan = false)

	If $__dedmem_handle = -1 Then Return SetError(1, 0, False)
	
	Local $type = StringFormat("wchar[%d]", StringLen($string) )
	Local $result = demem_scanValue($hProcess, $string, $type, $result_count, $addrStart, $addrEnd, $fast_scan)
	Return SetError(@error, 0, $result)
EndFunc



; Find a string (utf-8)
;
; $string:		the string
; $fast_scan:	true - scan 4 bytes allignment
;				false - scan 1 bytes allignment
;				default: false
;
; [Return]
;	success:	the first address found, if $result_count is specified then return an array of results
;	failed:		false and set the @error to non-zero
;
; @error	1: demem library isn't loaded
;			2: DllCall to demem failed, @extended is the @error of DllCall
Func demem_scanStringUTF8($hProcess, $string, $result_count = 0, $addrStart = 0, $addrEnd = 0, $fast_scan = false)

	If $__dedmem_handle = -1 Then Return SetError(1, 0, False)
	
	Local $struct_str = _WinAPI_WideCharToMultiByte($string, 65001, False)

	; remove the null byte at the end of string
	Local $struct_str_final = DllStructCreate(StringFormat("char[%d]", DllStructGetSize($struct_str)  - 1 ), DllStructGetPtr($struct_str))
	
	Local $result = __demem_internal_scanstruct($hProcess, $struct_str_final, 0, $result_count, $addrStart, $addrEnd, $fast_scan)

	Return SetError(@error, 0, $result)
EndFunc



; Get the process base address
;
; $moduleName:		name of the module to get base address
;
; [Return]
;	success:	the base address of the module
;	failed:		false and set the @error to non-zero
;
; @error	1: DllCall to demem failed, @extended is the @error of DllCall
;			2: K32EnumProcessModules failed,  call _WinAPI_GetLastErrorMessage() for more details
;			3: K32GetModuleBaseNameW failed,  call _WinAPI_GetLastErrorMessage() for more details
Func demem_getBaseAddress($hProcess)

	If $__dedmem_handle = -1 Then
		Local $result = __demem_getModuleAddress($hProcess, 0)
		Return SetError(@error, 0, $result)
	EndIf
	
	Local $result = DllCall($__dedmem_handle, "ptr:cdecl", "GetModuleAddress", "HANDLE", $hProcess, "ptr", 0)
	If @error Or IsArray($result) == False Then Return SetError(1, @error, False)

	return $result[0]
EndFunc



; Get module base address
;
; $moduleName:		name of the module to get base address
;
; [Return]
;	success:	the base address of the module
;	failed:		false and set the @error to non-zero
;
; @error	1: Can not find the specific module
;			2: K32EnumProcessModules failed,  call _WinAPI_GetLastErrorMessage() for more details
;			3: K32GetModuleBaseNameW failed,  call _WinAPI_GetLastErrorMessage() for more details
;			4: DllCall to demem failed, @extended is the @error of DllCall
Func demem_getModuleAddress($hProcess, $moduleName)

	If $__dedmem_handle = -1 Then
		Local $result = __demem_getModuleAddress($hProcess, $moduleName)
		Return SetError(@error, 0, $result)
	EndIf
	
	Local $result = DllCall($__dedmem_handle, "ptr:cdecl", "GetModuleAddress", "HANDLE", $hProcess, "wstr", $moduleName)
	If @error Or IsArray($result) == False Then Return SetError(4, @error, False)
	
	return ($result[0] == 0) ? SetError(1, 0, False) : $result[0]
EndFunc







#cs ----------------===== INTERNAL FUNCTIONS - undocumented =====--------------

author:         thedemons
discord:		thedemons#8671
facebook:		/demonsmsc

06:17 AM >  it's early morning and i'm talking to a machine

#ce ----------------------------------------------------------------------------

Func __demem_rpm($hProcess, $address, $struct, ByRef $iRead)
	Local $result = _WinAPI_ReadProcessMemory($hProcess, $address, DllStructGetPtr($struct), DllStructGetSize($struct), $iRead)
	If $result = False Then ConsoleWrite(StringFormat("!> Memory read failed at: 0x%s  -  handle: 0x%x\n!> %s\n", Hex($address), $hProcess, _WinAPI_GetLastErrorMessage()))

	Return $result
EndFunc

Func __demem_wpm($hProcess, $address, $struct, ByRef $iWritten)

	Local $size = DllStructGetSize($struct)
	Local $result = _WinAPI_WriteProcessMemory($hProcess, $address, DllStructGetPtr($struct), $size, $iWritten)
	Local $err_code = _WinAPI_GetLastError()

	; try to virtual protect it and write again
	If $result = False Then

		ConsoleWrite(StringFormat("!> Cannot write at: 0x%s, trying to use VirtualProtect  -  %s\n", Hex($address), _WinAPI_GetErrorMessage($err_code)))

		Local $oldProtect = __demem_virtualprotect($hProcess, $address, $size, 0x40) ; PAGE_EXECUTE_READWRITE 0x40
		If @error Then
			ConsoleWrite(StringFormat("!> Failed to use VirtualProtect  -  %s\n", _WinAPI_GetLastErrorMessage()))
			_WinAPI_SetLastError($err_code)
			Return False
		EndIf

		$result = _WinAPI_WriteProcessMemory($hProcess, $address, DllStructGetPtr($struct), $size, $iWritten)
		If $result Then
			$err_code = 0
			ConsoleWrite(StringFormat("> Write success, restoring page protection..\n"))
		EndIf

		; backup old protect
		__demem_virtualprotect($hProcess, $address, $size, $oldProtect)
	EndIf

	_WinAPI_SetLastError($err_code)
	Return $result
EndFunc

Func __demem_virtualprotect($hProcess, $address, $size, $protect)

	If $__kernel_handle = -1 Then __demem_openkernel32()

	; have fun hacking ;)
	Local $struct_oldprotect = DllStructCreate("dword")
	Local $result = DllCall($__kernel_handle, "bool", "VirtualProtectEx", _
					"handle", $hProcess, _
					"ptr", $address, _
					"ptr", $size, _
					"dword", $protect, _
					"ptr", DllStructGetPtr($struct_oldprotect))

	Return (IsArray($result) And $result[0] = True) ? DllStructGetData($struct_oldprotect, 1) : SetError(1, 0 , False)
EndFunc

Func __demem_openkernel32()
	$__kernel_handle = DllOpen("kernel32.dll")
EndFunc

Func __demem_getModuleAddress($hProcess, $moduleName = 0)

	If $__kernel_handle = -1 Then __demem_openkernel32()
	
	Local $lpcbNeeded = DllStructCreate("dword")
	Local $result = DllCall($__kernel_handle, "bool", "K32EnumProcessModules", "handle", $hProcess, "ptr", 0, "dword", 0, "ptr", DllStructGetPtr($lpcbNeeded))
	If @error Or $result[0] = False Then Return SetError(2, 0, False)
		
	Local $bytesRequired = DllStructGetData($lpcbNeeded, 1)
	Local $modulesCount = $bytesRequired / (@AutoItX64 ? 8 : 4)
	Local $modules_struct = DllStructCreate(StringFormat("ptr[%d]", $modulesCount))
	
	$result = DllCall($__kernel_handle, "bool", "K32EnumProcessModules", "handle", $hProcess, "ptr", DllStructGetPtr($modules_struct), "dword", $bytesRequired, "ptr", DllStructGetPtr($lpcbNeeded))
	If @error Or $result[0] = False Then Return SetError(2, 0, False)
		
	If $moduleName = 0 Then Return DllStructGetData($modules_struct, 1, 1)
	
	Local $buffer_name = DllStructCreate("wchar[1024]")
	For $i = 0 To $modulesCount - 1
		$result = DllCall($__kernel_handle, "dword", "K32GetModuleBaseNameW", "handle", $hProcess, "ptr", DllStructGetData($modules_struct, 1, $i + 1), "ptr", DllStructGetPtr($buffer_name), "dword", DllStructGetSize($buffer_name)/2)
		If @error Or $result[0] = 0 Then Return SetError(3, 0, False)
		
		If DllStructGetData($buffer_name, 1) = $moduleName Then Return DllStructGetData($modules_struct, 1, $i + 1)
	Next

	Return SetError(1, 0, False)
EndFunc

Func __demem_internal_scanstruct($hProcess, $struct, $mask, $result_count, $addrStart, $addrEnd, $fast_scan)
	
	; if $result_count > 0 then return an array of results
	Local $lpResults = 0
	Local $struct_results
	If $result_count > 0 Then
		$struct_results = DllStructCreate(StringFormat("ptr[%d]", $result_count))
		$lpResults = DllStructGetPtr($struct_results)
	EndIf
	
	; $mask = 0 then create a mask based on struct size with all 'x'
	If $mask = "" Then
		$mask = ""
		For $i = 0 To DllStructGetSize($struct) - 1
			$mask &= "x"
		Next
	EndIf
	
	Local $result = DllCall($__dedmem_handle, "ptr:cdecl", "FindPattern", "HANDLE", $hProcess, "ptr", DllStructGetPtr($struct), _
		"str", $mask, "ptr", $lpResults, "int", $result_count, "ptr", $addrStart, "ptr", $addrEnd, "bool", $fast_scan)

	If @error Or IsArray($result) == False Then Return SetError(1, @error, False)
	If $result_count == 0 Then Return $result[0]

	; $result[0] is the number of results
	Local $array_results[$result[0]]
	For $i = 0 To $result[0] - 1
		$array_results[$i] = DllStructGetData($struct_results, 1, $i+1)
	Next

	Return $array_results
EndFunc



; NOT MY CODE, JUST COPY SOMEWHERE ON THE INTERNET YEARS AGO AND I CAN'T REMEMBER THE AUTHOR
Func _GetPrivilege_SEDEBUG()
    Local $tagLUIDANDATTRIB = "int64 Luid;dword Attributes"
    Local $count = 1
    Local $tagTOKENPRIVILEGES = "dword PrivilegeCount;byte LUIDandATTRIB[" & $count * 12 & "]" ; count of LUID structs * sizeof LUID struct
    Local $TOKEN_ADJUST_PRIVILEGES = 0x20
    Local $call = DllCall("advapi32.dll", "int", "OpenProcessToken", "ptr", _WinAPI_GetCurrentProcess(), "dword", $TOKEN_ADJUST_PRIVILEGES, "ptr*", "")
    Local $hToken = $call[3]
    $call = DllCall("advapi32.dll", "int", "LookupPrivilegeValue", "str", Chr(0), "str", "SeDebugPrivilege", "int64*", "")
    ;msgbox(0,"",$call[3] & " " & _WinAPI_GetLastErrorMessage())
    Local $iLuid = $call[3]
    Local $TP = DllStructCreate($tagTOKENPRIVILEGES)
    Local $LUID = DllStructCreate($tagLUIDANDATTRIB, DllStructGetPtr($TP, "LUIDandATTRIB"))
    DllStructSetData($TP, "PrivilegeCount", $count)
    DllStructSetData($LUID, "Luid", $iLuid)
    DllStructSetData($LUID, "Attributes", $SE_PRIVILEGE_ENABLED)
    $call = DllCall("advapi32.dll", "int", "AdjustTokenPrivileges", "ptr", $hToken, "int", 0, "ptr", DllStructGetPtr($TP), "dword", 0, "ptr", Chr(0), "ptr", Chr(0))
    Return ($call[0] <> 0) ; $call[0] <> 0 is success
EndFunc   ;==>_GetPrivilege_SEDEBUG