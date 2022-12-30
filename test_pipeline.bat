echo off

cd tests
echo "Running tests..."
lualatex --interaction=batchmode run_tests.tex || goto :error
cd ..

cd tutorials
echo "Compiling tutorials..."
./compile_all.sh || goto :error
cd ..

exit 0
:error
cd ..
echo "Some part of the pipeline failed."
exit 1
