#!/bin/bash

cd "${BASEDIR}"/src/"${LIB_NAME}"/"${LIB_NAME}"/build/generic || return 1

# SET BUILD OPTIONS
ASM_OPTIONS=""
case ${ARCH} in
i386 | x86-64*)
  ASM_OPTIONS="--disable-assembly"
  ;;
esac

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# WORKAROUNDS
git checkout configure.in 1>>"${BASEDIR}"/build.log 2>&1
if [[ ${FFMPEG_KIT_BUILD_TYPE} != "macos" ]]; then

  # WORKAROUND TO FIX THE FOLLOWING ERROR
  # ld: -flat_namespace and -bitcode_bundle (Xcode setting ENABLE_BITCODE=YES) cannot be used together
  ${SED_INLINE} 's/ -flat_namespace//g' configure.in

  # WORKAROUND TO FIX THE FOLLOWING ERROR
  # ld: -read_only_relocs and -bitcode_bundle (Xcode setting ENABLE_BITCODE=YES) cannot be used together
  ${SED_INLINE} 's/-Wl,-read_only_relocs,suppress//g' configure.in
fi

# ALWAYS REGENERATE BUILD FILES - NECESSARY TO APPLY THE WORKAROUNDS
./bootstrap.sh

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  ${ASM_OPTIONS} \
  --host="${HOST}" || return 1

make || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_xvidcore_package_config "1.3.7" || return 1

# WORKAROUND TO REMOVE DYNAMIC LIBS
rm -f "${LIB_INSTALL_PREFIX}"/lib/libxvidcore.dylib*
