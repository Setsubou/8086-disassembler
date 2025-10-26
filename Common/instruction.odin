package Common

Instruction_flag :: enum {
    Signed,
    Wide,
    Direction
}

Memory_address :: distinct u16
Data :: distinct u16
Operand_address :: union {
	Register,
	[dynamic]Register,
	Memory_address,
	Data
}

Displacement :: struct {
    displacement_mode: Displacement_Mode,
    displacement_value: u16
}

Instruction :: struct {
	opcode:          Opcode,
	size:            u8,
	destination:        Operand_address,
	source: Operand_address,
	displacement: Displacement,
	mnemonic:        string,
}