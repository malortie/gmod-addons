-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

include('shared.lua')

ENT.PrintName	= 'Base HL1 item'
ENT.Category	= 'They Hunger'

ENT.RenderGroup	= RENDERGROUP_BOTH


function ENT:InitializeClientSide() end