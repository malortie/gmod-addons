-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

DEFINE_BASECLASS( 'ent_hl1_ammo_base' )

ENT.Base	= 'ent_hl1_ammo_base'
ENT.Spawnable	= true

ENT.Model = 'models/th/w_ap9clip/w_ap9clip.mdl'