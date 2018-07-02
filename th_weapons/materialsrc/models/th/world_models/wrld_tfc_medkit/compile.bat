prompt $
@echo off
cls

setlocal EnableExtensions EnableDelayedExpansion

set vtex="C:\Program Files (x86)\Steam\steamapps\common\Source SDK Base 2013 Singleplayer\bin\vtex.exe"
set file="C:\dev\Gmod addons\th_weapons\materialsrc\models\th\world_models\wrld_tfc_medkit\medkit_bottom.tga"

%vtex% -i %file% -out "medkit_bottom.tga"

pause
endlocal