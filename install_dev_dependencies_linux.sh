#!/bin/bash
set -e

if ! command -v rustup &> /dev/null
then
    echo Installing rust...
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

rust_diesel_req=libsqlite3-dev
rust_rfd_req=libgtk-3-dev

sudo apt install $rust_diesel_req $rust_rfd_req