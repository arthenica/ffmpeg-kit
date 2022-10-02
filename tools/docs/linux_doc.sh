#!/bin/bash
#
# Generates docs for Linux C++ library
#

CURRENT_DIR="`pwd`"

cd "${CURRENT_DIR}"/../../linux

doxygen
