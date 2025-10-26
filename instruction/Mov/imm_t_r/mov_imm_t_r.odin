package mov_imm_t_r

import "core:fmt"
import "../../../Common"
import "../../../Helper"
import "../../../Helper/Mnemonic"
import Reg "../../../Register"

run :: proc(instruction_bytes: []u8) -> (Common.Instruction, Common.Error) {    
    wide_flag := Helper.bool_extract(instruction_bytes[0], WIDE_MASK)
    
    register_bits := Helper.u8_extract(instruction_bytes[0], REGISTER_MASK)
   	destination, destination_result := Reg.decode_register(register_bits, wide_flag)
    if destination_result != Common.ERROR_NONE {
		return Common.Instruction{}, destination_result
	}
    
	data, additional_size := _get_data(instruction_bytes, wide_flag)
	size := BASE_SIZE + additional_size
    
	mnemonic := Mnemonic.build_mnemonic(Common.Opcode.MOV, destination, data)
	
    return Common.Instruction {
        opcode = .MOV,
        size = size,
        destination = destination,
        source = cast(Common.Data)data,
        mnemonic = mnemonic,
    }, Common.ERROR_NONE   
}