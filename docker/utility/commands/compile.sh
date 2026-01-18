#!/bin/sh
set -e

# --- Default variables ---
PROJECT_NAME="${PROJECT_NAME:-Pandaria}"
INSTALL_PREFIX="${INSTALL_PREFIX:-/app}"
SOURCE_PREFIX="${SOURCE_PREFIX:-/src/pandaria_5.4.8}"
BUILD_DIR="$SOURCE_PREFIX/build"

echo "=== Compiling Project $PROJECT_NAME ==="

# Compiler defaults
CMAKE_C_COMPILER="${CMAKE_C_COMPILER:-/usr/bin/clang}"
CMAKE_CXX_COMPILER="${CMAKE_CXX_COMPILER:-/usr/bin/clang++}"
CMAKE_DISABLE_PCH="${CMAKE_DISABLE_PCH:-ON}"
BUILD_CORES="${BUILD_CORES:-0}"

# --- CXX FLAGS ---
if [ -z "$CMAKE_CXX_FLAGS" ]; then
    CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo || true)
    BASE_FLAGS="-pthread -O2"

    if echo "$CPU_MODEL" | grep -Eq "i[357]-[23]"; then
        echo "Old CPU detected ($CPU_MODEL). Lowering optimization..."
        CMAKE_CXX_FLAGS="-pthread -O1"
    else
        CMAKE_CXX_FLAGS="$BASE_FLAGS -march=native"
    fi

    # 🔥 CLANG FIXES (CRITICAL)
    CMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS \
-Wno-error \
-Wno-error=inconsistent-missing-override \
-Wno-error=undefined-var-template \
-Wno-inconsistent-missing-override \
-Wno-undefined-var-template \
-Wno-deprecated-declarations \
-Wno-unused-value \
-Wno-parentheses"
fi

export CMAKE_CXX_FLAGS
export LDFLAGS="-Wl,--copy-dt-needed-entries"

echo "Compiler: $CMAKE_CXX_COMPILER"
echo "CXX Flags: $CMAKE_CXX_FLAGS"
echo "Project: $PROJECT_NAME"

# --- Ensure directories ---
mkdir -p "$INSTALL_PREFIX/logs" "$INSTALL_PREFIX/etc" "$INSTALL_PREFIX/bin" \
         "$INSTALL_PREFIX/sql" "$INSTALL_PREFIX/data" "$INSTALL_PREFIX/lib"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# --- Run CMake ---
cmake .. \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DCMAKE_C_COMPILER="$CMAKE_C_COMPILER" \
  -DCMAKE_CXX_COMPILER="$CMAKE_CXX_COMPILER" \
  -DSCRIPTS="${SCRIPTS:-ON}" \
  -DWITH_WARNINGS=OFF \
  -DTOOLS="${EXTRACTORS:-ON}" \
  -DCMAKE_CXX_FLAGS="$CMAKE_CXX_FLAGS" \
  -DCMAKE_DISABLE_PRECOMPILE_HEADERS="$CMAKE_DISABLE_PCH" \
  -DACE_INCLUDE_DIR="${ACE_INCLUDE_DIR:-/usr/include}" \
  -DACE_LIBRARY="${ACE_LIBRARY:-/usr/lib/x86_64-linux-gnu/libACE.so}"

# --- Clean old build ---
make clean

# --- Build & install ---
if [ "${MAKE_INSTALL:-1}" -eq 1 ]; then
    TOTAL_CORES=$(nproc)
    CORES="$TOTAL_CORES"
    [ "$BUILD_CORES" -ne 0 ] && CORES="$BUILD_CORES"
    echo "Building with $CORES cores"
    make -j"$CORES" install
fi

echo "=== Compile complete for $PROJECT_NAME ==="
