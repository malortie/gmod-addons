-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

include('shared.lua')

DEFINE_BASECLASS( 'weapon_th_base' )

local BODYGROUP_SILENCER = 1
local BODYGROUP_SILENCER_OFF = 0
local BODYGROUP_SILENCER_ON = 1

function SWEP:PreDrawWorldModel()
	-- Set the appropriate bodygroup while in third person.
	if IsValid( self.Owner ) then
		if self.Weapon:GetSilenced() then
			self:SetBodygroup( BODYGROUP_SILENCER, BODYGROUP_SILENCER_ON )
		else
			self:SetBodygroup( BODYGROUP_SILENCER, BODYGROUP_SILENCER_OFF )
		end
	end
end

function SWEP:ShouldDrawMuzzleFlash()
	if self.Weapon:GetSilenced() then return false end
	
	return BaseClass.ShouldDrawMuzzleFlash( self )
end
