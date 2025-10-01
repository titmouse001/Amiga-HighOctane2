cd palettes
dir *.lbm /b >list
lbm2gfx amiga -w16 -h16 -p16 @list
move *.pal ..
del *.gfx
cd ..

lbm2gfx amiga -o000044 -A Title.lbm
lbm2gfx amiga -o000044 -A menu.lbm
lbm2gfx amiga -o000024 -w320 -h48 panel.lbm
REM lbm2gfx amiga -o000042 -x1 -y1 -w32 -h32 -c0,16,palettes\game.lbm exp_new.tga
REM lbm2gfx amiga -o000048 -x20 -y9 -w16 -h20 -c0,16,palettes\game.lbm spr_car.lbm
lbm2gfx amiga -o000048 -x1 -y1 -w16 -h20 -c0,16,palettes\game.lbm mouse.lbm


lbm2gfx amiga -o000014 -x1 -y1 -w16 -h8 font.lbm
copy font.gfx fontfix.gfx
lbm2gfx amiga -o000014 -x40 -y7 -w16 -h8 font.lbm
copy font.gfx font_a.gfx
copy /b fontfix.gfx+font_a.gfx font.gfx
del font_a.gfx
del fontfix.gfx


LBM2GFX amiga -o000044 -x20 -y59 -w16 -h16 -c0,16,palettes\game.lbm blocks.bmp

cd exp0001
..\gfxgrid exp01.tga Exp2*.tga
move exp01.tga ..\exp01.tga
cd..
lbm2gfx amiga -o000042 -x1 -y10 -w32 -h32 -c0,16,palettes\game.lbm exp01.tga

cd exp0002
..\gfxgrid exp02.tga Exp00*.tga
move exp02.tga ..\exp02.tga
cd..
lbm2gfx amiga -o000042 -x1 -y10 -w32 -h32 -c0,16,palettes\game.lbm exp02.tga

copy /b exp01.gfx+exp02.gfx exp.gfx
del exp01.gfx
del exp02.gfx

cd car32x20
..\gfxgrid carfrms.tga car*.tga
pause
move carfrms.tga ..\carfrms1.tga
cd..
lbm2gfx amiga -o000042 -x1 -y64 -w32 -h20 -c0,16,palettes\carpal.lbm carfrms1.tga
pause

cd car32x20_red
..\gfxgrid carfrms.tga car*.tga
move carfrms.tga ..\carfrms2.tga
cd..
lbm2gfx amiga -o000042 -x1 -y64 -w32 -h20 -c0,16,palettes\carpal.lbm carfrms2.tga

cd SKIDS
del MARK.tga
gfxgrid MARK.tga MARK*.tga
copy MARK.tga ..
cd ..
lbm2gfx amiga -o000014 -x1 -y64 -w16 -h20 -c0,16,palettes\carpal.lbm MARK.tga

cd rocket
del rocket.tga
gfxgrid rocket.tga rock*.tga
copy rocket.tga ..
cd ..
lbm2gfx amiga -o000042 -x1 -y64 -w16 -h11 -c0,16,palettes\carpal.lbm rocket.tga

cd car32x20
..\gfxgrid carfrms.tga car*.tga
move carfrms.tga ..\spr_car.tga
cd..
lbm2gfx amiga -o000048 -x2 -y64 -w16 -h20 -c0,16,palettes\carpal.lbm spr_car.tga

move /Y *.pal ..\..\data\gfx
move /Y *.gfx ..\..\data\gfx
