package Displacement_Mode

import "core:log"
import "core:fmt"
import "../Common"

decode_memory :: proc(instruction_bytes: []u8, rm_bits: u8, displacement_mode: Common.Displacement_Mode) -> (Common.Operand_address, u16, Common.Error) {
    base_register, decode_result := _decode_base_register(rm_bits, displacement_mode)
    if decode_result != Common.ERROR_NONE { 
        return nil, 0, decode_result
    }
    
    // Fetch optional displacement if needed
    switch displacement_mode {
        case .NO_DISPLACEMENT:
            return base_register, 0, Common.ERROR_NONE
        
        case .DISPLACEMENT_8BIT: 
            displacement := cast(u16) instruction_bytes[2]
            return base_register, displacement, Common.ERROR_NONE
        
        case .DISPLACEMENT_16BIT: 
            displacement := cast(u16) instruction_bytes[3] << 8 | cast(u16)(instruction_bytes[2])
            return base_register, displacement, Common.ERROR_NONE
    
        case .REGISTER_MODE:
            return nil, 0, Common.DECODE_ERROR{message="Register mode shouldn't even touch memory displacement, wtf?"}
        
        case:
            return nil, 0, Common.DECODE_ERROR{message=fmt.tprintf("Unknown Displacement Mode %v, RM Field %b", displacement_mode, rm_bits)}
    }    
}

calculate_additional_data_size :: proc(displacement: Common.Displacement_Mode) -> u8 {
    switch displacement {
        case .NO_DISPLACEMENT, .REGISTER_MODE: return 0
        case .DISPLACEMENT_8BIT: return 1
        case .DISPLACEMENT_16BIT: return 2
        case: return 0
    }
}

decode_displacement_mode :: proc(input: u8) -> (displacement: Common.Displacement_Mode, error: Common.Error) {
	switch input {
    	case 0b00: return .NO_DISPLACEMENT, Common.ERROR_NONE
    	case 0b01: return .DISPLACEMENT_8BIT, Common.ERROR_NONE
    	case 0b10: return .DISPLACEMENT_16BIT, Common.ERROR_NONE
    	case 0b11: return .REGISTER_MODE, Common.ERROR_NONE
    
    	case: return nil, Common.DECODE_ERROR{message = fmt.tprintf("Failed to decode mode %b", input)}
	}
}