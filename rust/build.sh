#!/bin/bash
cargo fmt
cargo build
cbindgen --config cbindgen.toml --crate loretex --output loretex_api.h