echo off

FOR /D %%d IN (*) DO (
	echo Going to folder %%d...
	cd %%d || goto :patherror
	FOR %%f IN ( *.tex ) DO (
		echo Compiling %%f...
		lualatex --interaction=batchmode %%f || goto :error
		echo Compiling once again to get references right...
		lualatex --interaction=batchmode %%f || goto :error
	)
	cd ..
)

exit
:error
cd ..
:patherror
echo Something went wrong during compilation 1>&2
set /p DUMMY=Press ENTER to continue...