-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

include('shared.lua')

ENT.PrintName	= 'MP5 Clip'
ENT.Author		= 'Marc-Antoine (malortie) Lortie'
ENT.Category	= 'Half-Life: Source'

ENT.RenderGroup	= RENDERGROUP_BOTH


function ENT:InitializeClientSide() end