-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

AddCSLuaFile()

sound.AddSoundOverrides( 'scripts/vehicles/game_sounds_weapons_th.txt' )