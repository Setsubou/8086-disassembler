#+private
package instruction

import "core:fmt"

Addressing_Mode :: enum {
	// The problem with this is that some opcodes has the same addressing modes, yet different opcode format
	// For now I'm only handling MOV, but this might change in the future
	RM_TF_R,
}

_rm_tf_r :: proc(instruction: ^Instruction, instruction_bytes: []u8) -> Error {
    // Missing code for decoding optional data
    
    wide_flag := .Wide in instruction^.flags
    mode_flag := (instruction_bytes[1] & MODE_MASK) >> MODE_SHIFT_OFFSET
	register_flag := (instruction_bytes[1] & REGISTER_MASK) >> REGISTER_SHIFT_OFFSET
	register_memory_flag := instruction_bytes[1] & RM_MASK
 
	mode, mode_success := _decode_displacement_mode(mode_flag)
	if mode_success != ERROR_NONE {
		return DECODE_ERROR{message = fmt.tprintf("Failed to decode mode %b", mode_flag)}
	}

	register, register_success := _decode_register(register_flag, wide_flag)
	if register_success != ERROR_NONE {
		return DECODE_ERROR {
			message = fmt.tprintf("Failed to decode register %b with wide flag %b", register, wide_flag)
		}
	}

	register_memory, register_memory_success := _decode_register_memory(register_memory_flag, wide_flag, mode)
	if register_memory_success != ERROR_NONE {
		return register_memory_success
	}

	instruction^.mode = mode
	instruction^.register = register
	instruction^.register_memory = register_memory

	return ERROR_NONE
}

_decode_register_memory :: proc(rm_field: u8, wide: bool, displacement_mode: Displacement_Mode) ->
(operand_address: Operand_address, error: Error) {
	switch displacement_mode {
    	case .REGISTER_MODE: return _decode_register(rm_field, wide)
    	case .DISPLACEMENT_16BIT, .DISPLACEMENT_8BIT, .NO_DISPLACEMENT: return _calculate_effective_address()
    	case: return nil, DECODE_ERROR{message = fmt.tprintf("Uknown mode %b", displacement_mode)}
   	}
}

_decode_operand_address :: proc(instruction: ^Instruction, instruction_bytes: []u8) -> (error: Error) {
	switch instruction^.addressing_mode {
	    case .RM_TF_R: return _rm_tf_r(instruction, instruction_bytes)
		case: return DECODE_ERROR{message=fmt.tprint("Unable to parse addressing mode")}
	}
}