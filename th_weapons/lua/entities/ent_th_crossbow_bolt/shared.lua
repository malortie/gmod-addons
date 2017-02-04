-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

DEFINE_BASECLASS( 'base_anim' )

ENT.Base	= 'base_anim'
ENT.Type 	= "anim"

ENT.PrintName	= 'Crossbow Bolt Entity'
ENT.Category	= 'They Hunger'

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Model = 'models/th/crossbow_bolt/crossbow_bolt.mdl'

function ENT:Initialize()

if ( CLIENT ) then
	self:InitializeClientSide()
else
	self:InitializeServerSide()
end	-- end ( CLIENT )

end