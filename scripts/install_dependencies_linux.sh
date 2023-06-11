#!/bin/bash
set -e
cd $(git rev-parse --show-toplevel)

if ! command -v lualatex &> /dev/null
then
    echo "Installing lualatex"
    sudo apt-get install texlive-full
fi

url=$(<scripts/required_lorecore_release.txt)
wget -O dependencies.zip "$url/binariesLinux.zip"
unzip dependencies.zip -d tmp
mkdir -p dependencies
mv tmp/*/* dependencies/
rm -rf dependencies.zip tmp
