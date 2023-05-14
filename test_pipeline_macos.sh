#!/bin/bash
set -e

./install_build_dependencies_macos.sh

cd tests
echo "Running tests..."
lualatex --interaction=batchmode --shell-escape run_tests.tex
if [ $? -ne 0 ] ; then
    echo "Some tests failed."
    exit 1
fi
cd ..

cd tutorials
echo "Compiling tutorials..."
./compile_all.sh
if [ $? -ne 0 ] ; then
    echo "Some tutorials did not compile."
    exit 1
fi
cd ..
