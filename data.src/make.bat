md ..\data
md ..\data\gfx
md ..\data\mods
md ..\data\sfx
md ..\data\maps

cd gfx
call make.bat
cd ..

cd maps
call make.bat
cd ..

cd mods
call make.bat
cd ..

cd sfx
call make.bat
cd ..
