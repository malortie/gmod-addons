-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

DEFINE_BASECLASS( 'base_anim' )

ENT.Base	= 'base_anim'
ENT.Type 	= "anim"

ENT.PrintName	= 'Satchel Entity'
ENT.Category	= 'They Hunger'

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Model	= 'models/w_satchel.mdl'

function ENT:SetupDataTables()

	self:NetworkVar( 'Float', 0, 'BlastDamage' )
	self:NetworkVar( 'Float', 1, 'BlastRadius' )
end

function ENT:Initialize()

	self:SetBlastDamage( 0 )

if ( CLIENT ) then
	self:InitializeClientSide()
else
	self:InitializeServerSide()
end	-- end ( CLIENT )

end