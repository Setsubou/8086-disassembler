#+private
package Mnemonic

import "core:strings"
import "core:fmt"
import "core:log"
import "../../Common"

_is_dynamic_register :: proc(input: Common.Operand_address) -> bool {
    _, is_dynamic_register := input.([dynamic]Common.Register)
    return is_dynamic_register
}

_build_memory_mnemonic :: proc(input: Common.Operand_address, displacement_value: u16 = 0) -> string {
    defer free_all()
    
    builder := strings.builder_make()
    register_array, _ := input.([dynamic]Common.Register)
    string_array: [dynamic]string
    
    for value in register_array {
        enum_string, _ := fmt.enum_value_to_string(value)
        append(&string_array, enum_string)
    }
    register := strings.join(string_array[:], " + ")
    
    strings.write_string(&builder, "[")
    strings.write_string(&builder, register)
    
    if displacement_value > 0 {
        strings.write_string(&builder, " + ")
        strings.write_string(&builder, fmt.tprint(displacement_value))
    }
    
    if displacement_value < 0 {
        strings.write_string(&builder, " - ")
        strings.write_string(&builder, fmt.tprint(displacement_value))
    }
    
    strings.write_string(&builder, "]")
    
    return strings.to_string(builder)
}