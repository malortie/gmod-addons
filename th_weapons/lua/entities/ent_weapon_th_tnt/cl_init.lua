-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

include('shared.lua')

ENT.PrintName	= 'TNT'
ENT.Author		= 'Marc-Antoine (malortie) Lortie'
ENT.Category	= 'They Hunger'

ENT.RenderGroup	= RENDERGROUP_BOTH