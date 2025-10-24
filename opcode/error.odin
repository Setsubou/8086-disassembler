package opcode

ERROR_NONE :: Error{}

DECODE_ERROR :: struct {
    message: string
}

UNIMPLEMENTED_ERROR :: struct {
    message: string
}

Error :: union {
    DECODE_ERROR,
    UNIMPLEMENTED_ERROR
}