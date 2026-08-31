#!/bin/bash

# Run to auto move @2x & @3x image file to each folder

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the project root directory (parent of scripts folder)  
PROJECT_ROOT="$(cd "$SCRIPT_DIR/" && pwd)"

echo "Bash source: $PROJECT_ROOT"

# Change to assets/images directory
cd "$PROJECT_ROOT/assets/images"

#print 1x
for f in *@2x.png 
do  
    echo "- assets/images/${f/@2x/}"
done

#Move @2x.png
for f in *@2x.png 
do  
    name=${f/@2x/}
    mv "$f" "2.0x/$name"
    echo "- assets/images/2.0x/$name"
done

#Move @3x.png
for f in *@3x.png 
do  
    name=${f/@3x/}
    mv "$f" "3.0x/$name"
    echo "- assets/images/3.0x/$name"
done