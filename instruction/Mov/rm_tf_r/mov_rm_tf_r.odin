package mov_rm_tf_r

import "core:log"
import "core:fmt"
import "../../../Common"
import "../../../Helper/Mnemonic"
import Reg "../../../Register"
import Disp "../../../Displacement_Mode"
import "../../../Helper"

run :: proc(instruction_bytes: []u8) -> (Common.Instruction, Common.Error) {
    wide_flag := Helper.bool_extract(instruction_bytes[0], WIDE_MASK)
    direction_flag := Helper.bool_extract(instruction_bytes[0], DIRECTION_MASK, DIRECTION_SHIFT_OFFSET)
    
    mode_bits := Helper.u8_extract(instruction_bytes[1], MODE_MASK, MODE_SHIFT_OFFSET)
    mode, mode_result := Disp.decode_displacement_mode(mode_bits)
    if mode_result != Common.ERROR_NONE {
        return Common.Instruction{}, mode_result
    }
    
    destination: Common.Operand_address
    destination_bits := Helper.u8_extract(instruction_bytes[1], REGISTER_MASK, REGISTER_SHIFT_OFFSET)
    register, destination_result := Reg.decode_register(destination_bits, wide_flag)
    if destination_result != Common.ERROR_NONE {
        return Common.Instruction{}, destination_result
    }
    destination = register
    
    source: Common.Operand_address
    displacement_value: u16 = 0
    memory_mnemonic: string
    source_bits := Helper.u8_extract(instruction_bytes[1], REGISTER_MEMORY_MASK)
    if mode == .REGISTER_MODE {
        register, destination_result := Reg.decode_register(source_bits, wide_flag)
        if destination_result != Common.ERROR_NONE {
            return Common.Instruction{}, destination_result
        }
        source = register
    }
    if mode != .REGISTER_MODE {
        memory, displacement, memory_result := Disp.decode_memory(instruction_bytes, source_bits, mode)
        if memory_result != Common.ERROR_NONE {
            return Common.Instruction{}, memory_result
        }
        source = memory
        displacement_value = displacement
    }
    
    if !direction_flag {
        destination, source = source, destination
   	}
    
    displacement := Common.Displacement {
        displacement_mode = mode,
        displacement_value = displacement_value
    }
    
    size := BASE_SIZE + Disp.calculate_additional_data_size(mode)
    mnemonic := Mnemonic.build_mnemonic(.MOV, destination, source, displacement_value)
    
    return Common.Instruction {
        opcode          = .MOV,
    	size            = size,
        displacement = displacement,
        destination = destination,
        source = source,
        mnemonic = mnemonic,
    }, Common.ERROR_NONE
}