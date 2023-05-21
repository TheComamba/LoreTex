#!/bin/bash
set -e

cd tests
echo "Running tests..."
lualatex --interaction=batchmode --shell-escape run_tests.tex
cd ..

for folder in examples tutorials
do
    cd $folder
    echo "Compiling $folder..."
    ./compile_all.sh
    cd ..
done
