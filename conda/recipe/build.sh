
if [ "$(uname)" == "Darwin" ]; then
    OPTS="-msse4.1"


    # for FortranCInterface
    CMAKE_Fortran_FLAGS="${FFLAGS} -L${CONDA_BUILD_SYSROOT}/usr/lib/system/ ${OPTS} -O0"

    # configure
    ${BUILD_PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_Fortran_COMPILER=${GFORTRAN} \
        -DCMAKE_Fortran_FLAGS="${CMAKE_Fortran_FLAGS}" \
        -DENABLE_XHOST=OFF
fi


if [ "$(uname)" == "Linux" ]; then
    OPTS="-msse2 -axCORE-AVX512,CORE-AVX2,AVX -Wl,--as-needed -static-intel -wd10237"

    # load Intel compilers
    set +x
    source /opt/intel/oneapi/setvars.sh intel64
    set -x

    # link against conda GCC
    ALLOPTS="-gnu-prefix=${HOST}- ${OPTS}"

    # configure
    ${BUILD_PREFIX}/bin/cmake \
        -H${SRC_DIR} \
        -Bbuild \
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_Fortran_COMPILER=ifort \
        -DCMAKE_Fortran_FLAGS="${ALLOPTS}" \
        -DENABLE_XHOST=OFF
fi

# build
cd build
make -j${CPU_COUNT}

# install
make install

# test
# no independent tests

# NOTES
#
# * added O0 to Mac after some segfault problems hokru reported
#
# removed b/c WSL and some Linux segfaulted
#   -DCMAKE_Fortran_FLAGS="${ALLOPTS} -static" \
