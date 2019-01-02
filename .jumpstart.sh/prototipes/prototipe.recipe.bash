#!/usr/bin/env bash

proto() {
    # Prototipe recipe subfolder.

    recipe1() {
        #proto: Prototipe defined recipe
        success message "this is an user defined recipe"

        fail "That will fail :)"

        success
    }

    recipe2() {
        #proto: Prototipe defined recipe2
        success message "this is an user defined recipe"

        fail "That will fail :)"

        success
    }

    # Ensure multilevel
    checkOptions "$@"
}
