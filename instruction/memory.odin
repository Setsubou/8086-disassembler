#+private
package instruction

import "core:fmt"

@(private)
_calculate_effective_address :: proc() -> (operand_address: Operand_address, error: Error) {
	return nil, UNIMPLEMENTED_ERROR {
		message = "Effective Address Calculation is not implemented yet",
	}
}