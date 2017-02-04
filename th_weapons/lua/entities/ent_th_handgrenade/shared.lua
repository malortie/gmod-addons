-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

DEFINE_BASECLASS( 'base_anim' )

ENT.Base	= 'base_anim'
ENT.Type 	= "anim"

ENT.PrintName	= 'Hand grenade Entity'
ENT.Category	= 'They Hunger'

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Model = 'models/grenade.mdl'

function ENT:SetupDataTables()

	self:NetworkVar( 'Float', 0, 'DetonateTime' )
	self:NetworkVar( 'Float', 1, 'BlastDamage' )
	self:NetworkVar( 'Float', 2, 'BlastRadius' )
	self:NetworkVar( 'Float', 3, 'NextAttack' )
	self:NetworkVar( 'Bool', 0, 'RegisteredSound' )
end

function ENT:Initialize()

	self:SetDetonateTime( 0 )
	self:SetBlastDamage( 0 )
	self:SetBlastRadius( 0 )
	self:SetNextAttack( 0 )
	self:SetRegisteredSound( false )

if ( CLIENT ) then
	self:InitializeClientSide()
else
	self:InitializeServerSide()
end	-- end ( CLIENT )

end