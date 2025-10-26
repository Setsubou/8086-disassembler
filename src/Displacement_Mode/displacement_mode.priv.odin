#+private
package Displacement_Mode

import "core:fmt"
import "../Common"

_decode_base_register :: proc(rm_bits: u8, displacement_mode: Common.Displacement_Mode) -> (Common.Operand_address, Common.Error) {
    switch rm_bits {
        case 0b000: {
            registers: [dynamic]Common.Register
            append(&registers, Common.Register.BX, Common.Register.SI)
            return registers, Common.ERROR_NONE
        }
        case 0b001: {
            registers: [dynamic]Common.Register
            append(&registers, Common.Register.BX, Common.Register.DI)
            return registers, Common.ERROR_NONE
        }
        case 0b010: {
            registers: [dynamic]Common.Register
            append(&registers, Common.Register.BP, Common.Register.SI)
            return registers, Common.ERROR_NONE
        }
        case 0b011: {
            registers: [dynamic]Common.Register
            append(&registers, Common.Register.BP, Common.Register.DI)
            return registers, Common.ERROR_NONE
        }
        case 0b100: {
            registers: [dynamic]Common.Register
            append(&registers, Common.Register.SI)
            return registers, Common.ERROR_NONE
        }
        case 0b101: {
            registers: [dynamic]Common.Register
            append(&registers, Common.Register.DI)
            return registers, Common.ERROR_NONE
        }
        case 0b110: {
            if displacement_mode == .NO_DISPLACEMENT {
                return nil, Common.UNIMPLEMENTED_ERROR {
                    message = "Direct address is not implemented yet",
                }  
            }
            
            registers: [dynamic]Common.Register
            append(&registers, Common.Register.BP)
            return registers, Common.ERROR_NONE
        }
        case 0b111: {
            registers: [dynamic]Common.Register
            append(&registers, Common.Register.BX)
            return registers, Common.ERROR_NONE
        }
        case: {
            return nil, Common.DECODE_ERROR {
                message=fmt.tprintf("Can't decode displacement for %b", rm_bits)
            }
        }
    }
}