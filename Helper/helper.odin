package Helper

bool_extract :: proc(input: u8, mask: u8, shift_offset: u8 = 0) -> bool {
    return cast(bool) ((mask & input) >> shift_offset)
}

u8_extract :: proc(input: u8, mask: u8, shift_offset: u8 = 0) -> u8 {
    return cast(u8) ((mask & input)) >> shift_offset
}