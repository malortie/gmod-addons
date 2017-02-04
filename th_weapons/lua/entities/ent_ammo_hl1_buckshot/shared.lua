-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-------------------------------------
-- Buckshot ammunition.
-------------------------------------

DEFINE_BASECLASS( 'ent_hl1_ammo_base' )

ENT.Base	= 'ent_hl1_ammo_base'
ENT.Spawnable	= true

ENT.Model = 'models/w_shotbox.mdl'