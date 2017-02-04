-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

include('shared.lua')

function SWEP:TranslateFOV( current_fov )

	if self.Weapon:GetInZoom() then
		current_fov = 20
	end

	return current_fov
end