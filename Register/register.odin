package Register

import "../Common"

decode_register :: proc(input: u8, wide_flag: bool) -> (register: Common.Register, error: Common.Error) {
	if wide_flag {
	    return _decode_wide_register(input)
	} else {
		return _decode_non_wide_register(input)
	}
}