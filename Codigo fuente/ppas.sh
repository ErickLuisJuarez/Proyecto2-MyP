#!/bin/sh
DoExitAsm ()
{ echo "An error occurred while assembling $1"; exit 1; }
DoExitLink ()
{ echo "An error occurred while linking $1"; exit 1; }
echo Linking Programa
OFS=$IFS
IFS="
"
/usr/bin/ld -b elf64-x86-64 -m elf_x86_64  --build-id    -s  -L. -o Programa -T link5511.res -e _start
if [ $? != 0 ]; then DoExitLink Programa; fi
IFS=$OFS
