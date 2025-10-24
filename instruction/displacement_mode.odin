#+private
package instruction

import "core:fmt"

Displacement_Mode :: enum {
	NO_DISPLACEMENT,
	REGISTER_MODE,
	DISPLACEMENT_8BIT,
	DISPLACEMENT_16BIT,
}

_decode_displacement_mode :: proc(input: u8) -> (displacement: Displacement_Mode, error: Error) {
	switch input {
    	case 0b00: return .NO_DISPLACEMENT, ERROR_NONE
    	case 0b01: return .DISPLACEMENT_8BIT, ERROR_NONE
    	case 0b10: return .DISPLACEMENT_16BIT, ERROR_NONE
    	case 0b11: return .REGISTER_MODE, ERROR_NONE
    
    	case: return nil, DECODE_ERROR{message = fmt.tprintf("Failed to decode mode %b", input)}
	}
}