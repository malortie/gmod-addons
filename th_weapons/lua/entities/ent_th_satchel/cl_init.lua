-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

include( 'shared.lua' )

ENT.AutomaticFrameAdvance = true

function ENT:InitializeClientSide() end