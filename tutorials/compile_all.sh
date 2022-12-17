#!/bin/bash

for dir in */ ; do
	echo Entering folder "$dir"...
    cd "$dir"
    for file in *.tex ; do
		echo Compiling "$file"...
        lualatex --interaction=batchmode "$file"

        if [ $? -ne 0 ] ; then
            read -p "An error occurred. Press [Enter] to continue."
            exit 1
        fi
    done

    cd ..
done

echo "All .tex files were successfully compiled."
