@echo off
if not exist %1.c goto usage
call cc %1 %2 %3 %4 %5
if errorlevel 1 goto exit
sim68k %1
goto exit
:usage
echo USAGE: CCG file [options]
:exit
