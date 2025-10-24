package instruction

import "core:fmt"
import "core:strings"

Instruction_flag :: enum {
    Signed,
    Wide,
    Direction
}

Operand_address :: union {
	Register,
	u16,
}

Instruction :: struct {
	opcode:          Opcode,
	flags: bit_set[Instruction_flag],
	size:            u8,
	displacement:    u16,
	addressing_mode: Addressing_Mode,
	register:        Register,
	register_memory: Operand_address,
	mode:            Displacement_Mode,
	mnemonic:        string,
}

@(private)
_build_mnemonic :: proc(instruction: ^Instruction) {
	// This somehow took a lot of processing time
	defer free_all() //Use arena allocator for strings maybe?

	mnemonic: string
	opcode := instruction^.opcode
	register := instruction^.register
	register_memory := instruction^.register_memory

	if .Direction in instruction^.flags {
		mnemonic = strings.to_lower(fmt.tprintf("%s %s, %s", opcode, register, register_memory))
	} else {
		mnemonic = strings.to_lower(fmt.tprintf("%s %s, %s", opcode, register_memory, register))
	}

	instruction^.mnemonic = mnemonic
}

decode_instruction :: proc(instruction_bytes: []u8) -> (Instruction, Error) {
	instruction, decode_instruction_result := _decode_opcode(instruction_bytes[:])
	if decode_instruction_result != ERROR_NONE {
	    return Instruction{}, decode_instruction_result
	}
	
	decode_operand_result := _decode_operand_address(&instruction, instruction_bytes[:])
	if decode_operand_result != ERROR_NONE {
	    return Instruction{}, decode_operand_result
	}
	
	_build_mnemonic(&instruction)
	
	return instruction, ERROR_NONE
}