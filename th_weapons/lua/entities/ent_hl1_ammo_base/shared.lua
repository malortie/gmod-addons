-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

DEFINE_BASECLASS( 'base_anim' )

ENT.Base	= 'base_anim'
ENT.Type	= 'anim'

ENT.Spawnable	= false
ENT.AdminOnly	= false

function ENT:SetupDataTables()
end

function ENT:Initialize()

if ( CLIENT ) then
	self:InitializeClientSide()
else
	self:InitializeServerSide()
end -- end ( CLIENT )

end