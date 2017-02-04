-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Flamethrower Flame Entity"
ENT.Author = ""
ENT.Information = ""
ENT.Category = 'They Hunger'

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()

	self:NetworkVar( 'Float', 0, 'LifeTime' )
	self:NetworkVar( 'Float', 1, 'LifeDuration' )
	self:NetworkVar( 'Float', 2, 'Radius' )

end

function ENT:Initialize()

if ( CLIENT ) then
	self:InitializeClientSide()
else
	self:InitializeServerSide()
end	-- end ( CLIENT )

end