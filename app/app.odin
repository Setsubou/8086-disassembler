package app

import "core:log"
import "core:os"

App :: struct {
    instruction_pointer: u16,
    opcodes: []u8,
    len: u16,
}

open_file :: proc(file_path: string) -> (App, bool) {
    f, err := os.open(file_path)
    defer {
        os.close(f)
        free_all()
    }
    
    if err != os.ERROR_NONE {
        return App{}, false
    }
    
    data, _ := os.read_entire_file_from_handle(f)
    
    app := App {
        instruction_pointer = 0,
        opcodes = data,
        len = cast(u16) len(data)
    }
    
    return app, true
}