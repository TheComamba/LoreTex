echo off

FOR /D %%d IN (*) DO (
	echo Entering folder %%d...
	cd %%d
	FOR %%f IN ( *.tex ) DO (
		echo Compiling %%f...
		lualatex --interaction=batchmode %%f || goto :error
	)
	cd ..
)

echo "All .tex files were successfully compiled."

exit
:error
cd ..
set /p DUMMY=An error occurred. Press [Enter] to continue...