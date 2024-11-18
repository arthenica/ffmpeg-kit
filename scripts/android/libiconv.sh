#!/bin/bash

# FIX HARD-CODED PATHS
${SED_INLINE} 's|git://git.savannah.gnu.org|https://github.com/arthenica|g' "${BASEDIR}"/src/"${LIB_NAME}"/.gitmodules || return 1
ln -s -f $(which aclocal) ${BASEDIR}/.tmp/aclocal-1.16
ln -s -f $(which automake) ${BASEDIR}/.tmp/automake-1.16
PATH="${BASEDIR}/.tmp":$PATH

if [[ ! -d "${BASEDIR}"/src/"${LIB_NAME}"/gnulib ]]; then

  # INIT SUBMODULES
  ./gitsub.sh pull || return 1
  ./gitsub.sh checkout gnulib 485d983b7795548fb32b12fbe8370d40789e88c4 || return 1
fi

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_libiconv} -eq 1 ]]; then
  ./autogen.sh || return 1
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${ANDROID_SYSROOT}" \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --disable-rpath \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
create_libiconv_package_config "1.17" || return 1
