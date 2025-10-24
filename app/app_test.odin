#+test
package app

import "core:testing"

@(test)
open_file_test :: proc(t: ^testing.T) {
    app, success := open_file("asm/listing_37")
    
    if !success {
        testing.fail_now(t, "Failed to open file")
    }
}