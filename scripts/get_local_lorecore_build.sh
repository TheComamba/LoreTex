#!/bin/bash
set -e
cd "$(git rev-parse --show-toplevel)"

mkdir -p dependencies

if [ "$(uname)" == "Darwin" ]; then
    cp ../lore_core/target/debug/liblorecore.dylib dependencies/
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    cp ../lore_core/target/debug/liblorecore.so dependencies/
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    cp ../lore_core/target/debug/lorecore.dll dependencies/
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    cp ../lore_core/target/debug/lorecore.dll dependencies/
fi
cp ../lore_core/lorecore_api.h dependencies/
