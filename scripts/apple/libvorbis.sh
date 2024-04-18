#!/bin/bash

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# WORKAROUNDS
# -mno-ieee-fp OPTION IS NOT COMPATIBLE WITH clang. REMOVING IT
${SED_INLINE} 's/\-mno-ieee-fp//g' "${BASEDIR}"/src/"${LIB_NAME}"/configure.ac || return 1

# ALWAYS REGENERATE BUILD FILES - NECESSARY TO APPLY THE WORKAROUNDS
autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1

# WORKAROUND TO REMOVE -force_cpusubtype_ALL FLAG DUE TO THE FOLLOWING ERROR
# ld: -force_cpusubtype_ALL and -bitcode_bundle (Xcode setting ENABLE_BITCODE=YES) cannot be used together
${SED_INLINE} 's/-force_cpusubtype_ALL//g' ${BASEDIR}/src/${LIB_NAME}/configure

PKG_CONFIG= ./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${SDK_PATH}" \
  --with-ogg-includes="${LIB_INSTALL_BASE}"/libogg/include \
  --with-ogg-libraries="${LIB_INSTALL_BASE}"/libogg/lib \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --disable-docs \
  --disable-examples \
  --disable-oggtest \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_libvorbis_package_config "1.3.7" || return 1
