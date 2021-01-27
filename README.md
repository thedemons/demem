# demem

### Description
demem is a simple memory library for AutoIt that features:
- Basic memory manipulation
- Read and write with simple usages
- Scan AOB (pattern), value, and string
- Auto handle access permission error
### Functions

```autoit
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

	demem_dllOpen
	demem_dllClose
	demem_isDllLoaded

	demem_scanAOB
	demem_scanValue
	demem_scanString
	demem_scanStringUTF8
	demem_scanStringUnicode
```
