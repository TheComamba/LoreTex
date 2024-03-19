#!/bin/bash
set -e
cd $(git rev-parse --show-toplevel)

if [ "$(uname)" == "Darwin" ]; then
    cp ../LoreCore/target/debug/liblorecore.dylib dependencies/
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    cp ../LoreCore/target/debug/liblorecore.so dependencies/
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    cp ../LoreCore/target/debug/lorecore.dll dependencies/
elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
    cp ../LoreCore/target/debug/lorecore.dll dependencies/
fi
cp ../LoreCore/lorecore_api.h dependencies/
