-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

include('shared.lua')

DEFINE_BASECLASS( 'weapon_th_base' )

function SWEP:ShouldDrawMuzzleFlash()
	if self.Weapon:GetSilenced() then return false end
	
	return BaseClass.ShouldDrawMuzzleFlash( self )
end
