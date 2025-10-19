package main

import "core:strings"
import "core:fmt"
import "core:os"

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

Addressing_Mode :: enum {
	// The problem with this is that some opcodes has the same addressing modes, yet different opcode format
	// For now I'm only handling MOV, but this might change in the future
	RM_TF_R,
}

Address :: distinct u16

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

Mode :: enum {
	NO_DISPLACEMENT,
	REGISTER_MODE,
	DISPLACEMENT_8BIT,
	DISPLACEMENT_16BIT,
}

Opcode :: enum {
	MOV,
}

Operand_address :: union {
	Register,
	Address,
}

Instruction :: struct {
	opcode:          Opcode,
	size:            u8,
	addressing_mode: Addressing_Mode,
	register:        Operand_address,
	register_memory: Operand_address,
	displacement:    u16,
	mode:            Mode,
	mnemonic:        string,

	// Can probably pack these into single bitfield values
	sign_extension:  bool,
	wide:            bool,
	direction:       bool,
}

decode_opcode :: proc(input: u8) -> Instruction {
	// Debating whether to use slices or fixed u8, for now we know that an opcode is only a single byte
	// But it might change in the future as we get deeper

	// Since opcodes are varying in length, we try to match the whole bytes, if nothing is found, we mask the last
	// bit so we only need to search for 7 bit, keep doing that until we terminate at 5th bit.
	// 
	// As far as I'm aware opcodes only go as low as 5 bit, which mean opcode is probably invalid if we still can't
	// find a match.
	for i := 0; i < 4; i += 1 {
		decode_mask := OPCODE_DECODE_MASK
		masked_input := input & decode_mask[i]

		switch masked_input {
		case 0b10001000: // MOV R/M To Register
			{
				wide := cast(bool)(WIDE_INSTRUCTION_MASK & input)
				direction := cast(bool)(DIRECTION_MASK & input)

				return Instruction {
					opcode = .MOV,
					size = 2,
					addressing_mode = .RM_TF_R,
					wide = wide,
					direction = direction,
				}
			}
		}
	}

	fmt.println("Unable to decode opcode")
	os.exit(1)
}

decode_mode :: proc(input: u8) -> Mode {
	switch input {
	case 0b00:
		return .NO_DISPLACEMENT
	case 0b01:
		return .DISPLACEMENT_8BIT
	case 0b10:
		return .DISPLACEMENT_16BIT
	case 0b11:
		return .REGISTER_MODE

	case:
		{
			fmt.println("Invalid mode")
			os.exit(1)
		}
	}
}

decode_register_memory :: proc(rm_field: u8, wide: bool, mode: Mode) -> Operand_address {
	switch mode {
	case .REGISTER_MODE:
		{
			return decode_register(rm_field, wide)
		}

	case .DISPLACEMENT_16BIT, .DISPLACEMENT_8BIT, .NO_DISPLACEMENT:
		{
			return calculate_effective_address()
		}

	case:
		{
			fmt.println("Uknown mode")
			os.exit(1)
		}
	}
}

calculate_effective_address :: proc() -> Operand_address {
	fmt.println("Unimplemented r/m")
	os.exit(1)
}

decode_register :: proc(input: u8, wide_flag: bool) -> Register {
	// Input param might be able to be packed together into one value instead.
	// Input is 3 bits, if value overflow, then exit program

	if wide_flag {
		switch input {
		case 0b000:
			return .AX
		case 0b001:
			return .CX
		case 0b010:
			return .DX
		case 0b011:
			return .BX
		case 0b100:
			return .SP
		case 0b101:
			return .BP
		case 0b110:
			return .SI
		case 0b111:
			return .DI
		case:
			{
				fmt.println("Invalid register encoding")
				os.exit(1)
			}
		}
	} else {
		switch input {
		case 0b000:
			return .AL
		case 0b001:
			return .CL
		case 0b010:
			return .DL
		case 0b011:
			return .BL
		case 0b100:
			return .AH
		case 0b101:
			return .CH
		case 0b110:
			return .DH
		case 0b111:
			return .BH
		case:
			{
				fmt.println("Invalid register encoding")
				os.exit(1)
			}


		}
	}
}

build_mnemonic :: proc(instruction: ^Instruction) {
    // This somehow took a lot of processing time
    mnemonic: string
    
    if instruction^.direction {
        mnemonic = strings.to_lower(fmt.tprintf("%s %s, %s", instruction^.opcode, instruction^.register, instruction^.register_memory))
    } else {
        mnemonic = strings.to_lower(fmt.tprintf("%s %s, %s", instruction^.opcode, instruction^.register_memory, instruction^.register))
    }
    
    instruction^.mnemonic = mnemonic
}

decode_operand_address :: proc(instruction: ^Instruction, instruction_bytes: []u8) {
    switch instruction^.addressing_mode {
        case .RM_TF_R: {            
            wide_flag := instruction^.wide
            mode_flag := (instruction_bytes[1] & MODE_MASK) >> MODE_SHIFT_OFFSET
            register_flag := (instruction_bytes[1] & REGISTER_MASK) >> REGISTER_SHIFT_OFFSET
            register_memory_flag := instruction_bytes[1] & RM_MASK
            
            mode := decode_mode(mode_flag)
            register := decode_register(register_flag, wide_flag)
            register_memory := decode_register_memory(register_memory_flag, wide_flag, mode)

            instruction^.mode = mode
            instruction^.register = register
            instruction^.register_memory = register_memory
        }
    }
}