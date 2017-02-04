-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')