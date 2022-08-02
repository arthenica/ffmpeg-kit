#!/bin/bash
#
# Generates docs for C++ library
#

CURRENT_DIR="`pwd`"

cd "${CURRENT_DIR}"/../linux

doxygen
