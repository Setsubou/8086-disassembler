package main

import "core:log"
import "core:time"
import "core:os"
import "opcode"
import "app"

main :: proc() {
    Logger_Options :: log.Options {
        .Level,
        .Terminal_Color,
    }
    context.logger = log.create_console_logger(opt = Logger_Options)
    
    if len(os.args[1:]) < 1 {
        log.error("You must provide an argument for the file name to be run")
        os.exit(-1)
    }
    
    start := time.now() 
    
    app, open_success := app.open_file(os.args[1])
    if !open_success {
        log.error("Error opening file, make sure file path is correct")
        os.exit(-1)
    }
    
    for ;app.instruction_pointer < app.len; {
        lower_bound := app.instruction_pointer
        upper_bound: u16
        
        if app.instruction_pointer + 6 > app.len {
            upper_bound = app.len // Clamp it to the max value to prevent overflow.
        } else {
            upper_bound = app.instruction_pointer + 6
        }
        
        instruction, decode_error := opcode.decode_instruction(app.opcodes[lower_bound:upper_bound])
        if decode_error != opcode.ERROR_NONE {
            log.error(decode_error)
            os.exit(-1)
        }
        
        app.instruction_pointer += cast(u16) instruction.size
        
        when !ODIN_DEBUG {
            log.info(instruction.mnemonic)
        }
    }
    
    end := time.now()
    duration := time.duration_seconds(time.diff(start, end))
        
    log.infof("Managed to decode %f instructions /second", cast(f64) app.len / duration)
}