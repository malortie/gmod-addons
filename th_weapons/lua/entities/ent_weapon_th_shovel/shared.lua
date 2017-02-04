-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

DEFINE_BASECLASS( 'base_point' )

ENT.Base	= 'base_point'
ENT.Spawnable	= true