#!/bin/bash
set -e
cd $(git rev-parse --show-toplevel)

cp ../LoreCore/target/debug/liblorecore.so dependencies/
cp ../LoreCore/lorecore_api.h dependencies/
