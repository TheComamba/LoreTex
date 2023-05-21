echo off

cd tests
echo ""
echo "Running tests..."
lualatex --interaction=batchmode --shell-escape run_tests.tex || goto :error
cd ..

for folder in examples tutorials; do
    cd $folder
	echo ""
    echo "Compiling documents in $folder..."
    compile_all.bat || goto :error
    cd ..
done

exit 0
:error
cd ..
echo "Some part of the pipeline failed."
exit 1
