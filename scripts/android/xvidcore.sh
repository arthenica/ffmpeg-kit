#!/bin/bash

cd "${BASEDIR}"/src/"${LIB_NAME}"/"${LIB_NAME}"/build/generic || return 1

# SET BUILD OPTIONS
ASM_OPTIONS=""
case ${ARCH} in
x86)

  # please note that asm is disabled
  # enabling asm for x86 causes text relocations in libavcodec.so
  ASM_OPTIONS="--disable-assembly"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/"${LIB_NAME}"/build/generic/configure ]] || [[ ${RECONF_xvidcore} -eq 1 ]]; then
  ./bootstrap.sh
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  ${ASM_OPTIONS} \
  --host="${HOST}" || return 1

make || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_xvidcore_package_config "1.3.7" || return 1

# WORKAROUND TO REMOVE DYNAMIC LIBS
rm -f "${LIB_INSTALL_PREFIX}"/lib/libxvidcore.so*
