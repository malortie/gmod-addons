-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-------------------------------------
-- Weapon HKG36 spawning.
-------------------------------------
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'base_point' )

--[[---------------------------------------------------------
	Called to spawn this entity.
		
	@param ply The player spawner.
	@param tr The trace result from player's eye to the spawn point.
	@param ClassName The entity's class name.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function ENT:SpawnFunction( ply, tr, ClassName )

	-- Do not spawn at an invalid position.
	if ( !tr.Hit ) then return end

	-- Spawn the entity at the hit position,
	-- facing toward the player.
	local SpawnPos = tr.HitPos + tr.HitNormal
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( 'weapon_th_sniper' )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent
end
