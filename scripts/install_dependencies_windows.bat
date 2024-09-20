@echo off
rem go to git root directory
for /f "delims=" %%i in ('git rev-parse --show-toplevel') do cd %%i

if not exist "C:\texlive\2019\bin\win32\lualatex.exe" (
    echo "Installing lualatex..."
    choco install texlive || goto :error
)

set /p url=<scripts\required_lorecore_release.txt
curl -L -o lorecore.zip %url%/binariesWindows || goto :error

rem Check if the file was downloaded successfully
if not exist lorecore.zip (
    echo "Download failed: lorecore.zip not found."
    goto :error
)

rem Verify the file format (optional, requires certutil)
certutil -hashfile lorecore.zip MD5 || goto :error

rem Extract the ZIP file using unzip
mkdir tmp
unzip lorecore.zip -d tmp || goto :error
mkdir -p dependencies
move tmp\* dependencies || goto :error
rmdir /s /q tmp
del lorecore.zip

exit 0
:error
cd ..
echo "Installation failed."
exit 1