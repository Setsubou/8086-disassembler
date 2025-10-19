package main

import "core:fmt"
import "core:os"

app :: struct {
    instruction_pointer: u16,
    opcodes: []u8,
    len: u16,
}

open_file :: proc(file_path: string) -> app {
    f, err := os.open(file_path)
    if err != os.ERROR_NONE {
        fmt.println("Error opening file, make sure file path is correct")
        os.exit(1)
    }
    defer os.close(f)
    
    data, _ := os.read_entire_file_from_handle(f)
    
    return app {
        instruction_pointer = 0,
        opcodes = data,
        len = cast(u16) len(data)
    }
}