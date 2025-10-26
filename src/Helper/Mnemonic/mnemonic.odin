package Mnemonic

import "core:log"
import "core:fmt"
import "core:strings"
import "../../Common"

build_mnemonic :: proc(opcode: Common.Opcode, input_destination: Common.Operand_address, input_source: Common.Operand_address, displacement_value: u16 = 0) -> string {
    defer free_all()
    
    destination: string
    source: string
    
    if _is_dynamic_register(input_source) {
        source = _build_memory_mnemonic(input_source, displacement_value)
    } else {
        source = fmt.tprint(input_source)
    }
    
    if _is_dynamic_register(input_destination) {
        destination = _build_memory_mnemonic(input_destination, displacement_value)
    } else {
        destination = fmt.tprint(input_destination)
    }
    
    return strings.to_lower(fmt.tprintf("%v %v, %v", opcode, destination, source))
}