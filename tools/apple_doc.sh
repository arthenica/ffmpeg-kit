#!/bin/bash
#
# Generates docs for Objective-C library
#

CURRENT_DIR="`pwd`"

cd "${CURRENT_DIR}"/../apple

doxygen
