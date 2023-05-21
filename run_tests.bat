echo off

cd tests
echo "Running tests..."
lualatex --interaction=batchmode --shell-escape run_tests.tex || goto :error
cd ..

for folder in examples tutorials; do
    cd $folder
    echo "Compiling $folder..."
    compile_all.bat || goto :error
    cd ..
done

exit 0
:error
cd ..
echo "Some part of the pipeline failed."
exit 1
