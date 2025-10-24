#+test
package opcode

import "core:testing"

@(test)
test_decode_all_modes :: proc(t: ^testing.T) {
    test_struct :: struct {
        to_decode: u8,
        expected_result: Displacement_Mode,
    }
    
    test_table := []test_struct {
        {
            expected_result = .NO_DISPLACEMENT,
            to_decode = 0b00
        },
        {
            expected_result = .DISPLACEMENT_8BIT,
            to_decode = 0b01
        },
        {
            expected_result = .DISPLACEMENT_16BIT,
            to_decode = 0b10
        },
        {
            expected_result = .REGISTER_MODE,
            to_decode = 0b11
        }
    }
    
    for test in test_table {  
        result, error := _decode_mode(test.to_decode)
        if error != ERROR_NONE {
            testing.fail_now(t)
        }
        
        testing.expectf(t, result == test.expected_result, "%b should equals to %s", test.to_decode, test.expected_result)
    }
}

@(test)
test_decode_registers :: proc(t: ^testing.T) {
    test_struct :: struct {
        wide_flag: bool,
        to_decode: u8,
        expected_result: Register,
    }
    
    test_table := []test_struct {
        {
            wide_flag = true,
            to_decode = 0b000,
            expected_result = .AX
        },
        {
            wide_flag = true,
            to_decode = 0b001,
            expected_result = .CX
        },
        {
            wide_flag = true,
            to_decode = 0b010,
            expected_result = .DX
        },
        {
            wide_flag = true,
            to_decode = 0b011,
            expected_result = .BX
        },
        {
            wide_flag = true,
            to_decode = 0b100,
            expected_result = .SP
        },
        {
            wide_flag = true,
            to_decode = 0b101,
            expected_result = .BP
        },
        {
            wide_flag = true,
            to_decode = 0b110,
            expected_result = .SI
        },
        {
            wide_flag = true,
            to_decode = 0b111,
            expected_result = .DI
        },
        {
            wide_flag = false,
            to_decode = 0b000,
            expected_result = .AL
        },
        {
            wide_flag = false,
            to_decode = 0b001,
            expected_result = .CL
        },
        {
            wide_flag = false,
            to_decode = 0b010,
            expected_result = .DL
        },
        {
            wide_flag = false,
            to_decode = 0b011,
            expected_result = .BL
        },
        {
            wide_flag = false,
            to_decode = 0b100,
            expected_result = .AH
        },
        {
            wide_flag = false,
            to_decode = 0b101,
            expected_result = .CH
        },
        {
            wide_flag = false,
            to_decode = 0b110,
            expected_result = .DH
        },
        {
            wide_flag = false,
            to_decode = 0b111,
            expected_result = .BH
        },
    }
    
    for test in test_table {
        result, error := _decode_register(test.to_decode, test.wide_flag)
        if error != ERROR_NONE {
            testing.fail_now(t)
        }
        
        testing.expectf(t, result == test.expected_result, "%b should equals to %s", test.to_decode, test.expected_result)
    }
}

// Test Deecoding Effective address
@(test)
test_decode_effective_address :: proc(t: ^testing.T) {
    // WIP
}

@(test)
test_decode_instruction :: proc(t: ^testing.T) {
    // Test to decode instruction from all available addressing modes and opcodes.
    // Still WIP, not all instructions are decoded yet.
    
    test_struct :: struct {
        test_name: string,
        to_decode: []u8,
        expected_opcode: Opcode,
        expected_addressing_mode: Addressing_Mode,
        expected_size: u8,
        expected_mnemonic: string
    }
    
    test_table := []test_struct {
        {
            test_name = "Register/Memory To/From Register - Register Mode",
            to_decode = []u8{0x89, 0xD9},
            expected_opcode = .MOV,
            expected_addressing_mode = .RM_TF_R,
            expected_size = 2,
            expected_mnemonic = "mov cx, bx"            
        },
    }
    
    for test in test_table {
        instruction, error := decode_instruction(test.to_decode)
        if error != ERROR_NONE {
            testing.fail_now(t)
        }
        
        
        testing.expectf(t, instruction.opcode == test.expected_opcode, "Expected Opcode %s, yet received %s instead", test.expected_opcode, instruction.opcode)
        testing.expectf(t, instruction.addressing_mode == test.expected_addressing_mode, "Expected Addressing mode %s, yet received %s instead", test.expected_addressing_mode, instruction.addressing_mode)
        testing.expect_value(t, instruction.size, test.expected_size)
        testing.expect_value(t, instruction.mnemonic, test.expected_mnemonic) 
    }
}