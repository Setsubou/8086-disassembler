package main

import "core:time"
import "core:os"
import "core:fmt"

main :: proc() {
    if len(os.args[1:]) < 1 {
        fmt.println("You must provide an argument for the file name to be run")
        os.exit(1)
    }
    
    app := open_file(os.args[1])
    
    // Unit testing
    // Better naming, and consolidate what we can
    when ODIN_DEBUG {
        start := time.now()
        
        defer {
            end := time.now()
            duration := time.duration_seconds(time.diff(start, end))
            
            fmt.printfln("Managed to decode %f instructions /second", cast(f64) app.len / duration)
        }
    }
    
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
        
        when !ODIN_DEBUG {
            fmt.println(instruction.mnemonic)
        }
    }
}