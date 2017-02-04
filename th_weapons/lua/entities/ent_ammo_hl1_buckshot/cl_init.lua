-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

include('shared.lua')

ENT.PrintName	= '.12 Gauge'
ENT.Author		= 'Marc-Antoine (malortie) Lortie'
ENT.Category	= 'Half-Life: Source'

ENT.RenderGroup	= RENDERGROUP_BOTH


function ENT:InitializeClientSide() end