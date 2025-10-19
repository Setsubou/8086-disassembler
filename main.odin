package main

import "core:os"
import "core:fmt"

main :: proc() {
    if len(os.args[1:]) < 1 {
        fmt.println("You must provide an argument for the file name to be run")
        os.exit(1)
    }
    
    app := open_file(os.args[1])
    
    // Unit testing
    // Cleanup
    // Calculate time by decode / second
    for ;app.instruction_pointer < app.len; {
        lower_bound := app.instruction_pointer
        upper_bound: u16
        
        if app.instruction_pointer + 6 > app.len {
            upper_bound = app.len
        } else {
            upper_bound = app.instruction_pointer + 6
        }
        
        instruction := decode_instruction(app.opcodes[lower_bound:upper_bound])
        app.instruction_pointer += cast(u16) instruction.size
        
        fmt.println(instruction.mnemonic)
    }
}

decode_instruction :: proc(instruction_bytes: []u8) -> Instruction {
    instruction := decode_opcode(instruction_bytes[0])
    decode_operand_address(&instruction, instruction_bytes[:])
    build_mnemonic(&instruction)
    
    return instruction
}