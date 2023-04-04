#!/bin/bash

for dir in */ ; do
	echo Entering folder "$dir"...
    cd "$dir"
    for file in *.tex ; do
		echo Compiling "$file"...
        lualatex --interaction=batchmode --enable-write18 "$file"

        if [ $? -ne 0 ] ; then
            echo "An error occurred during compilation."
            exit 1
        fi
    done

    cd ..
done

echo "All .tex files were successfully compiled."
