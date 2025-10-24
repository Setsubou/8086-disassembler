package opcode

import "core:fmt"
import "core:log"
import "core:strings"

WIDE_INSTRUCTION_MASK :: 0b00000001

REGISTER_MASK :: 0b00111000
REGISTER_SHIFT_OFFSET :: 3

RM_MASK :: 0b00000111

MODE_MASK :: 0b11000000
MODE_SHIFT_OFFSET :: 6

SIGN_MASK :: 0b00000010

DIRECTION_MASK :: 0b00000010
DIRECTION_SHIFT_OFFSET :: 1

OPCODE_DECODE_MASK :: [5]u8{0b11111111, 0b11111110, 0b11111100, 0b11111000, 0b11110000}

@(private)
Addressing_Mode :: enum {
	// The problem with this is that some opcodes has the same addressing modes, yet different opcode format
	// For now I'm only handling MOV, but this might change in the future
	RM_TF_R,
}

@(private)
Address :: distinct u16

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
Displacement_Mode :: enum {
	NO_DISPLACEMENT,
	REGISTER_MODE,
	DISPLACEMENT_8BIT,
	DISPLACEMENT_16BIT,
}

@(private)
Opcode :: enum {
	MOV,
}

@(private)
Operand_address :: union {
	Register,
	Address,
}

Instruction_flag :: enum {
    Signed,
    Wide,
    Direction
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
_decode_operand_address :: proc(instruction: ^Instruction, instruction_bytes: []u8) -> (error: Error) {
	switch instruction^.addressing_mode {
	case .RM_TF_R:
		{
			wide_flag := .Wide in instruction^.flags
			mode_flag := (instruction_bytes[1] & MODE_MASK) >> MODE_SHIFT_OFFSET
			register_flag := (instruction_bytes[1] & REGISTER_MASK) >> REGISTER_SHIFT_OFFSET
			register_memory_flag := instruction_bytes[1] & RM_MASK

			mode, mode_success := _decode_mode(mode_flag)
			if mode_success != ERROR_NONE {
			    return DECODE_ERROR {message = fmt.tprintf("Failed to decode mode %b", mode_flag)}
			}
			
			register, register_success := _decode_register(register_flag, wide_flag)
			if register_success != ERROR_NONE {
			   return DECODE_ERROR {message = fmt.tprintf("Failed to decode register %b with wide flag %b", register, wide_flag)} 
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
		
	    case: {
			return ERROR_NONE	
		}
	}	
}

@(private)
_decode_mode :: proc(input: u8) -> (displacement: Displacement_Mode, error: Error) {
	switch input {
    	case 0b00:
    		return .NO_DISPLACEMENT, ERROR_NONE
    	case 0b01:
    		return .DISPLACEMENT_8BIT, ERROR_NONE
    	case 0b10:
    		return .DISPLACEMENT_16BIT, ERROR_NONE
    	case 0b11:
    		return .REGISTER_MODE, ERROR_NONE
    
    	case: {
    	    return nil, DECODE_ERROR{message=fmt.tprintf("Failed to decode mode %b", input)}
    	}
	}
}

@(private)
_decode_opcode :: proc(instruction_bytes: []u8) -> (instruction: Instruction, success: bool) {
	// Since opcodes are varying in length, we try to match the whole bytes, if nothing is found, we mask the last
	// bit so we only need to search for 7 bit, keep doing that until we terminate at 5th bit.

	decode_mask := OPCODE_DECODE_MASK
	for i := 0; i < 4; i += 1 {
		masked_input := instruction_bytes[0] & decode_mask[i]

		switch masked_input {
		case 0b10001000: { 	// MOV R/M To/From Register
				flags: bit_set[Instruction_flag]
				
				if cast(bool)(WIDE_INSTRUCTION_MASK & instruction_bytes[0]) {
				    flags += {.Wide}
				}
				
				if cast(bool)(DIRECTION_MASK & instruction_bytes[0]) {
				    flags += {.Direction}
				}
				
				instruction := Instruction {
					opcode = .MOV,
					size = 2,
					addressing_mode = .RM_TF_R,
					flags = flags,
				}
				
				return instruction, true
			}
		}
	}
	
	return Instruction{}, false
}

@(private)
_decode_register_memory :: proc(rm_field: u8, wide: bool, displacement_mode: Displacement_Mode) -> (operand_address: Operand_address, error: Error) {
	switch displacement_mode {
    	case .REGISTER_MODE: return _decode_register(rm_field, wide)
    
    	case .DISPLACEMENT_16BIT, .DISPLACEMENT_8BIT, .NO_DISPLACEMENT: return _calculate_effective_address()
    
    	case: return nil, DECODE_ERROR{message = fmt.tprintf("Uknown mode %b", displacement_mode)}
    }
}

@(private)
_calculate_effective_address :: proc() -> (operand_address: Operand_address, error: Error) {
    return nil, UNIMPLEMENTED_ERROR{message="Effective Address Calculation is not implemented yet"}
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
	instruction, decode_instruction_success := _decode_opcode(instruction_bytes[:])
	if !decode_instruction_success {
	    return Instruction{}, DECODE_ERROR {message = fmt.tprintf("Unable to decode opcode %b", instruction_bytes)}
	}
	
	decode_operand_success := _decode_operand_address(&instruction, instruction_bytes[:])
	if decode_operand_success != ERROR_NONE {
	    return Instruction{}, decode_operand_success
	}
	
	_build_mnemonic(&instruction)
	
	return instruction, ERROR_NONE
}
