package Opcode

import "core:fmt"
import "../Common"
import mov_imm_t_r "../Instruction/Mov/imm_t_r"
import mov_rm_tf_r "../Instruction/Mov/rm_tf_r"

OPCODE_DECODE_MASK :: [5]u8{0b11111111, 0b11111110, 0b11111100, 0b11111000, 0b11110000}

decode_instruction :: proc(instruction_bytes: []u8) -> (instruction: Common.Instruction, error: Common.Error) {
	// Since opcodes are varying in length, we try to match the whole bytes, if nothing is found, we mask the last
	// bit so we only need to search for 7 bit, keep doing that until we terminate at 5th bit.

	decode_mask := OPCODE_DECODE_MASK
	for i := 0; i < 5; i += 1 {
		masked_input := instruction_bytes[0] & decode_mask[i]

		switch masked_input { 
		// This will get messy real quick when there's a ton of instructions.
		// Maybe move it to a separate hashmap?
		    case 0b10001000:
				instruction, result := mov_rm_tf_r.run(instruction_bytes)
				if result != Common.ERROR_NONE {
				    return Common.Instruction{}, result
				}
				return instruction,Common. ERROR_NONE
			
			case 0b10110000:
			    instruction, result := mov_imm_t_r.run(instruction_bytes)
			    if result != Common.ERROR_NONE {
					return Common.Instruction{}, result
				}
				return instruction, Common.ERROR_NONE
		}
	}

	return Common.Instruction{}, Common.DECODE_ERROR{message=fmt.tprintf("Unable to decode opcode %b", instruction_bytes)}
}
