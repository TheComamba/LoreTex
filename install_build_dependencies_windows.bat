echo off

if not exist "C:\texlive\2019\bin\win32\lualatex.exe" (
    echo "Installing lualatex..."
    tlmgr install luatex
)

set /p url=<required_lorecore_release.txt
curl -L -o lorecore.zip %url%/binariesWindows || goto :error
tar -xf lorecore.zip -C tmp || goto :error
mkdir -p dependencies
mv tmp\*\* dependencies || goto :error
rm -rf dependencies.zip tmp || goto :error

exit 0
:error
cd ..
echo "Installation failed."
exit 1
