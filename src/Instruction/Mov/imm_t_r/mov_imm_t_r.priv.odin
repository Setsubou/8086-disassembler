#+private
package mov_imm_t_r

import "../../../Common"

_get_data :: proc(instruction_bytes: []u8, wide_flag: bool) -> (data: Common.Data, additional_size: u8 = 0) {
    if wide_flag {
	    data = cast(Common.Data) instruction_bytes[2] << 8 | cast(Common.Data)(instruction_bytes[1])
		additional_size += 1
	} else {
	    data = cast(Common.Data) instruction_bytes[1]
	}
	
	return
}