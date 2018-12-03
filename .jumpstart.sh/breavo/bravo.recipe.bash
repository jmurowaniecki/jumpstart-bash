#!/usr/bin/env bash

bravo() {
    # Prototipe recipe subfolder.

    recipe1() {
        #bravo: Brvvo defined recipe
        success message "this is an user defined recipe"

        fail "That will fail :)"

        success
    }

    recipe2() {
        #bravo: Brvvo defined recipe2
        success message "this is an user defined recipe"

        fail "That will fail :)"

        success
    }

    # Ensure multilevel
    checkOptions "$@"
}
