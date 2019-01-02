#!/usr/bin/env bash

recipes() {
    # Main recipes (root folder)

    recipe1() {
        #recipes: User defined recipe
        success message "this is an user defined recipe"

        fail "That will fail :)"

        success
    }

    recipe2() {
        #recipes: User defined recipe2
        success message "this is an user defined recipe"

        fail "That will fail :)"

        success
    }

    # Ensure multilevel
    checkOptions "$@"
}
