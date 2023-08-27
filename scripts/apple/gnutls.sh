#!/bin/bash

# INIT SUBMODULES
${SED_INLINE} 's|openssl/openssl|arthenica/openssl|g' "${BASEDIR}"/src/"${LIB_NAME}"/.gitmodules || return 1
${SED_INLINE} 's|tomato42|arthenica|g' "${BASEDIR}"/src/"${LIB_NAME}"/.gitmodules || return 1
${SED_INLINE} 's|warner|arthenica|g' "${BASEDIR}"/src/"${LIB_NAME}"/.gitmodules || return 1
${SED_INLINE} 's|gitlab.com/libidn/gnulib-mirror|github.com/arthenica/gnulib|g' "${BASEDIR}"/src/"${LIB_NAME}"/.gitmodules || return 1
${SED_INLINE} 's|gitlab.com/gnutls/libtasn1|github.com/arthenica/libtasn1|g' "${BASEDIR}"/src/"${LIB_NAME}"/.gitmodules || return 1
${SED_INLINE} 's|gitlab.com/gnutls/nettle|github.com/arthenica/nettle|g' "${BASEDIR}"/src/"${LIB_NAME}"/.gitmodules || return 1
${SED_INLINE} 's|gitlab.com/gnutls/abi-dump|github.com/arthenica/abi-dump|g' "${BASEDIR}"/src/"${LIB_NAME}"/.gitmodules || return 1
${SED_INLINE} 's|gitlab.com/gnutls/cligen|github.com/arthenica/cligen|g' "${BASEDIR}"/src/"${LIB_NAME}"/.gitmodules || return 1
${SED_INLINE} 's|gitlab.com/redhat-crypto/tests/interop|github.com/arthenica/redhat-crypto-tests-interop|g' "${BASEDIR}"/src/"${LIB_NAME}"/.gitmodules || return 1

# UPDATE BUILD FLAGS
export CFLAGS="$(get_cflags ${LIB_NAME}) -I${SDK_PATH}/usr/include"
export CXXFLAGS=$(get_cxxflags "${LIB_NAME}")
export LDFLAGS="$(get_ldflags ${LIB_NAME}) -L${SDK_PATH}/usr/lib"

export NETTLE_CFLAGS="-I${LIB_INSTALL_BASE}/nettle/include"
export NETTLE_LIBS="-L${LIB_INSTALL_BASE}/nettle/lib -lnettle -L${LIB_INSTALL_BASE}/gmp/lib -lgmp"
export HOGWEED_CFLAGS="-I${LIB_INSTALL_BASE}/nettle/include"
export HOGWEED_LIBS="-L${LIB_INSTALL_BASE}/nettle/lib -lhogweed -L${LIB_INSTALL_BASE}/gmp/lib -lgmp"
export GMP_CFLAGS="-I${LIB_INSTALL_BASE}/gmp/include"
export GMP_LIBS="-L${LIB_INSTALL_BASE}/gmp/lib -lgmp"

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_gnutls} -eq 1 ]]; then
  ./bootstrap --skip-po || return 1
  git submodule update --remote gnulib || return 1
  overwrite_file ./gnulib/lib/fpending.c ./src/gl/fpending.c || return 1
fi

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --with-sysroot="${SDK_PATH}" \
  --with-included-libtasn1 \
  --with-included-unistring \
  --without-idn \
  --without-p11-kit \
  --enable-hardware-acceleration \
  --enable-static \
  --disable-openssl-compatibility \
  --disable-shared \
  --disable-fast-install \
  --disable-code-coverage \
  --disable-doc \
  --disable-manpages \
  --disable-guile \
  --disable-tests \
  --disable-tools \
  --disable-maintainer-mode \
  --disable-full-test-suite \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
if [[ ${FFMPEG_KIT_BUILD_TYPE} == "macos" ]]; then
  create_gnutls_package_config "3.7.9" "-framework Security" || return 1
else
  create_gnutls_package_config "3.7.9" || return 1
fi
