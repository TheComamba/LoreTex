#!/bin/bash

if ! command -v lualatex &> /dev/null
then
    echo "Installing lualatex"
    sudo aptitude install lualatex
fi

url=$(<required_lorecore_release.txt)
wget -O dependencies.zip "$url/binariesMacOS.zip"
unzip dependencies.zip -d tmp
mkdir -p dependencies
mv tmp/*/* dependencies/
rm -rf dependencies.zip tmp
