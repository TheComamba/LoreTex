echo off

.\install_build_dependencies_windows.bat || goto :error

cd tests
echo "Running tests..."
lualatex --interaction=batchmode --shell-escape run_tests.tex || goto :error
cd ..

cd tutorials
echo "Compiling tutorials..."
compile_all.bat || goto :error
cd ..

exit 0
:error
cd ..
echo "Some part of the pipeline failed."
exit 1
