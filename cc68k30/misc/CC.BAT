@echo off
if not exist %1.c goto usage
cc68k %1 %2 %3 %4 %5
if errorlevel 1 goto exit
asm68k -nl %LIB%\cstart -l %1 -nl %LIB%\clib -o%1
goto exit
:usage
echo USAGE: CC file [options]
:exit

