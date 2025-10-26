#+private
package Register

import "core:fmt"
import "../Common"

_decode_wide_register :: proc(input: u8) -> (register: Common.Register, error: Common.Error) {
    switch input {
        case 0b000: return .AX, Common.ERROR_NONE
        case 0b001: return .CX, Common.ERROR_NONE
        case 0b010: return .DX, Common.ERROR_NONE
        case 0b011: return .BX, Common.ERROR_NONE
        case 0b100: return .SP, Common.ERROR_NONE
        case 0b101: return .BP, Common.ERROR_NONE
        case 0b110: return .SI, Common.ERROR_NONE
        case 0b111: return .DI, Common.ERROR_NONE
        case: {
            return nil, Common.DECODE_ERROR{message = fmt.tprintf("Unable to decode register %b with wide flag: true", input)}
        }
    }
}

_decode_non_wide_register :: proc(input: u8) -> (register: Common.Register, error: Common.Error) {
    switch input {
   	    case 0b000: return .AL, Common.ERROR_NONE
      		case 0b001: return .CL, Common.ERROR_NONE
      		case 0b010: return .DL, Common.ERROR_NONE
      		case 0b011: return .BL, Common.ERROR_NONE
      		case 0b100: return .AH, Common.ERROR_NONE
      		case 0b101: return .CH, Common.ERROR_NONE
      		case 0b110: return .DH, Common.ERROR_NONE
      		case 0b111: return .BH, Common.ERROR_NONE
  		case: {
            return nil, Common.DECODE_ERROR{message = fmt.tprintf("Unable to decode register %b with wide flag: false", input)}
        }
   	}
}