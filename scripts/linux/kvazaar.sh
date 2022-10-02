#!/bin/bash

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_kvazaar} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

# WORKAROUND TO DISABLE LINKING TO -lrt
## ${SED_INLINE} 's/\-lrt//g' "${BASEDIR}"/src/"${LIB_NAME}"/configure || return 1

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-pic \
  --enable-static \
  --disable-shared \
  --disable-fast-install \
  --host="${HOST}" || return 1

# NOTE THAT kvazaar DOES NOT SUPPORT PARALLEL EXECUTION
make || return 1

make install || return 1

# MANUALLY COPY PKG-CONFIG FILES
cp ./src/kvazaar.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
