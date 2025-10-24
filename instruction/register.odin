package instruction

import "core:fmt"
@(private)
Register :: enum {
	AX,
	AH,
	AL,
	BX,
	BH,
	BL,
	CX,
	CH,
	CL,
	DX,
	DH,
	DL,
	SP,
	SI,
	DI,
	BP,
}

@(private)
_decode_wide_register :: proc(input: u8) -> (register: Register, error: Error) {
    switch input {
        case 0b000: return .AX, ERROR_NONE
        case 0b001: return .CX, ERROR_NONE
        case 0b010: return .DX, ERROR_NONE
        case 0b011: return .BX, ERROR_NONE
        case 0b100: return .SP, ERROR_NONE
        case 0b101: return .BP, ERROR_NONE
        case 0b110: return .SI, ERROR_NONE
        case 0b111: return .DI, ERROR_NONE
        case: {
            return nil, DECODE_ERROR{message = fmt.tprintf("Unable to decode register %b with wide flag: true", input)}
        }
    }
}

@(private)
_decode_non_wide_register :: proc(input: u8) -> (register: Register, error: Error) {
    switch input {
   	    case 0b000: return .AL, ERROR_NONE
  		case 0b001: return .CL, ERROR_NONE
  		case 0b010: return .DL, ERROR_NONE
  		case 0b011: return .BL, ERROR_NONE
  		case 0b100: return .AH, ERROR_NONE
  		case 0b101: return .CH, ERROR_NONE
  		case 0b110: return .DH, ERROR_NONE
  		case 0b111: return .BH, ERROR_NONE
  		case: {
            return nil, DECODE_ERROR{message = fmt.tprintf("Unable to decode register %b with wide flag: false", input)}
        }
   	}
}

@(private)
_decode_register :: proc(input: u8, wide_flag: bool) -> (register: Register, error: Error) {
	if wide_flag {
	    return _decode_wide_register(input)
	} else {
		return _decode_non_wide_register(input)
	}
}