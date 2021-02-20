REM SPDX-FileCopyrightText: 2020 Intel Corporation
REM
REM SPDX-License-Identifier: MIT

set LANGUAGE=%1
set VS_VER=%2

IF "%VS_VER%"=="2017_build_tools" (
@call "C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
)

IF "%VS_VER%"=="2019_build_tools" (
@call "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
)
for /f "tokens=* usebackq" %%f in (`dir /b "C:\Program Files (x86)\Intel\oneAPI\compiler\" ^| findstr /V latest ^| sort`) do @set "LATEST_VERSION=%%f"
@call "C:\Program Files (x86)\Intel\oneAPI\compiler\%LATEST_VERSION%\env\vars.bat"

git clone --depth 1 https://github.com/oneapi-src/oneAPI-samples.git

if "%LANGUAGE%" == "c++" goto cpp
if "%LANGUAGE%" == "fortran" goto fortran
if "%LANGUAGE%" == "dpc++" goto dpcpp
goto exit

:cpp
cd oneAPI-samples\DirectProgramming\C++\CompilerInfrastructure\Intrinsics
icl -O2 src\intrin_dot_sample.cpp
icl -O2 src\intrin_double_sample.cpp
icl -O2 src\intrin_ftz_sample.cpp
intrin_dot_sample.exe && intrin_double_sample.exe && intrin_ftz_sample.exe
set RESULT=%ERRORLEVEL%
del intrin_dot_sample.exe intrin_double_sample.exe intrin_ftz_sample.exe
icx -O2 -msse3 src\intrin_dot_sample.cpp
icx -O2 -msse3 src\intrin_double_sample.cpp
icx -O2 -msse3 src\intrin_ftz_sample.cpp
intrin_dot_sample.exe && intrin_double_sample.exe && intrin_ftz_sample.exe
set /a RESULT=%RESULT%+%ERRORLEVEL%
goto exit

:fortran
which ifort
which conda python cmake ninja
cmake -GNinja -H. -Bobjdir -DCMAKE_BUILD_TYPE=Release -DINTEL=ON -DBLAS=MKL -DCMAKE_Fortran_COMPILER=ifort
set RESULT=%ERRORLEVEL%
cmake --build objdir --verbose
set RESULT=%ERRORLEVEL%
dir
set /a RESULT=%RESULT%+%ERRORLEVEL%
goto exit

REM          cmake -G Ninja ^
REM                -DCMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE% ^
REM                -DCMAKE_INSTALL_PREFIX=../install ^
REM                -DCMAKE_C_COMPILER=clang-cl ^
REM                -DCMAKE_CXX_COMPILER=clang-cl ^
REM                -DENABLE_XHOST=!ENABLE_XHOST! ^
REM                -DMAX_AM_ERI=!MAX_AM_ERI! ^
REM                -DPython_EXECUTABLE="C:/tools/miniconda3/python.exe" ^
REM                -DMPFR_ROOT="C:/tools/miniconda3/Library" ^
REM                -DEigen_ROOT="C:/tools/miniconda3/Library" ^
REM                -DBUILD_Libint2_GENERATOR=OFF ^
REM                -DCMAKE_INSIST_FIND_PACKAGE_gau2grid=ON ^
REM                -DCMAKE_INSIST_FIND_PACKAGE_Libint2=ON ^
REM                -DCMAKE_INSIST_FIND_PACKAGE_Libxc=ON ^
REM                -DBUILD_SHARED_LIBS=OFF ^
REM                $(Build.SourcesDirectory)
REM        displayName: "Configure Psi4"
REM        workingDirectory: $(Build.BinariesDirectory)
REM
REM      # Build
REM      - script: |
REM          call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86_amd64
REM          cmake --build . ^
REM                --config %CMAKE_BUILD_TYPE% ^
REM                -- -j %NUMBER_OF_PROCESSORS%
REM        displayName: "Build Psi4"
REM        workingDirectory: $(Build.BinariesDirectory)/build


:dpcpp
for /f "tokens=* usebackq" %%f in (`dir /b "C:\Program Files (x86)\Intel\oneAPI\tbb\" ^| findstr /V latest ^| sort`) do @set "LATEST_VERSION=%%f"
@call "C:\Program Files (x86)\Intel\oneAPI\tbb\%LATEST_VERSION%\env\vars.bat"
cd oneAPI-samples\DirectProgramming\DPC++\DenseLinearAlgebra\vector-add
nmake -f Makefile.win
nmake -f Makefile.win run
set RESULT=%ERRORLEVEL%
goto exit

:exit
exit /b %RESULT%
