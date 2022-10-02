#!/bin/bash
#
# Generates docs for Apple Objective-C library
#

CURRENT_DIR="`pwd`"

cd "${CURRENT_DIR}"/../../apple

doxygen
