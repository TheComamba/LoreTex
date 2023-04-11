echo off

FOR /D %%d IN (*) DO (
	echo Entering folder %%d...
	cd %%d
	FOR %%f IN ( *.tex ) DO (
		echo Compiling %%f...
		lualatex --interaction=batchmode --shell-escape %%f || goto :error
	)
	cd ..
)

echo "All .tex files were successfully compiled."
exit 0
:error
cd ..
echo "An error occurred during compilation."
exit 1
