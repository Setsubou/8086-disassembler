package instruction

import "core:fmt"
import "core:log"
import "core:strings"

@(private)
Opcode :: enum {
	MOV,
}

@(private)
_mov_rm_f_r :: proc(instruction_bytes: []u8) -> Instruction {
    flags: bit_set[Instruction_flag]
    
    if cast(bool)(WIDE_INSTRUCTION_MASK & instruction_bytes[0]) {
    	flags += {.Wide}
    }
    
    if cast(bool)(DIRECTION_MASK & instruction_bytes[0]) {
    	flags += {.Direction}
    }
    
    instruction := Instruction {
    	opcode          = .MOV,
    	size            = 2,
    	addressing_mode = .RM_TF_R,
    	flags           = flags,
    }
    
    return instruction
}

@(private)
_decode_opcode :: proc(instruction_bytes: []u8) -> (instruction: Instruction, error: Error) {
	// Since opcodes are varying in length, we try to match the whole bytes, if nothing is found, we mask the last
	// bit so we only need to search for 7 bit, keep doing that until we terminate at 5th bit.

	decode_mask := OPCODE_DECODE_MASK
	for i := 0; i < 4; i += 1 {
		masked_input := instruction_bytes[0] & decode_mask[i]

		switch masked_input {
		    case 0b10001000: return _mov_rm_f_r(instruction_bytes[:]), ERROR_NONE
		}
	}

	return Instruction{}, DECODE_ERROR{message=fmt.tprintf("Unable to decode opcode %b", instruction_bytes)}
}
