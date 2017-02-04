-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

DEFINE_BASECLASS( 'base_anim' )

ENT.Base	= 'base_anim'
ENT.Type 	= "anim"

ENT.PrintName	= 'Tripmine Entity'
ENT.Category	= 'They Hunger'

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Model = 'models/w_tripmine.mdl'

function ENT:SetupDataTables()

	self:NetworkVar( 'Float', 0, 'PowerUp' )
	self:NetworkVar( 'Vector', 0, 'BeamDir' )
	self:NetworkVar( 'Vector', 1, 'BeamEnd' )
	self:NetworkVar( 'Float', 1, 'BeamLength' )
	self:NetworkVar( 'Entity', 0, 'TripmineOwner' )
	self:NetworkVar( 'Entity', 1, 'Beam' )
	self:NetworkVar( 'Vector', 2, 'PosOwner' )
	self:NetworkVar( 'Angle', 0, 'AngleOwner' )
	self:NetworkVar( 'Entity', 2, 'RealOwner' )
	self:NetworkVar( 'Float', 3, 'BlastDamage' )
	self:NetworkVar( 'Float', 4, 'BlastRadius' )
	
	self:NetworkVar( 'Entity', 3, 'BeamEndEntity1' )
	self:NetworkVar( 'Entity', 4, 'BeamEndEntity2' )

end

function ENT:Initialize()

	self:SetPowerUp( 0 )
	self:SetBeamDir( vector_origin )
	self:SetBeamEnd( vector_origin )
	self:SetBeamLength( 0 )
	self:SetTripmineOwner( nil )
	self:SetBeam( nil )
	self:SetPosOwner( vector_origin )
	self:SetAngleOwner( angle_zero )
	self:SetRealOwner( nil )
	self:SetBlastDamage( 0 )
	self:SetBlastRadius( 0 )
	
	self:SetBeamEndEntity1( nil )
	self:SetBeamEndEntity2( nil )
	
if ( CLIENT ) then
	self:InitializeClientSide()
else
	self:InitializeServerSide()
end	-- end ( CLIENT )

end