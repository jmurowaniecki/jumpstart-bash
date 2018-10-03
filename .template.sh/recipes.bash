#!/usr/bin/env bash

function recipes {
    # Main recipes (root folder)

    function recipe1 {
        #recipes: User defined recipe
        success message "this is an user defined recipe"

        fail "That will fail :)"

        success
    }

    function recipe2 {
        #recipes: User defined recipe2
        success message "this is an user defined recipe"

        fail "That will fail :)"

        success
    }

    # Ensure multilevel
    checkOptions "$@"
}
