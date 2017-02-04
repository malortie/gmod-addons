-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-------------------------------------
-- Base ammunition class.
-------------------------------------
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'base_anim' )

--[[---------------------------------------------------------
	Perform Server-side initialization.
-----------------------------------------------------------]]
function ENT:InitializeServerSide()
	
	-- Make this entity immobile.
	self:SetMoveType( MOVETYPE_NONE )
	
	-- Make this entity receptible to touching.
	-- Enable touching.
	self:SetTrigger( true )
	self:UseTriggerBounds( true, 24 )
	
	-- Set the collision volume.
	self:SetCollisionBounds( Vector( -16, -16, 0 ), Vector( 16, 16, 16 ) )
end

--[[---------------------------------------------------------
	Called when touched by another entity.
		
	@param other The entity that we are touching.
-----------------------------------------------------------]]
function ENT:Touch( other )

	-- if it's not a player, ignore
	if !other:IsPlayer() then return end
	
	-- Give ammo to the player.
	if self:AddAmmo( other ) then
		-- Disable touching.
		self:SetTrigger( false )
		-- Remove itself after a brief instant.
		SafeRemoveEntityDelayed( self, 0.1 )
	end
end

--[[---------------------------------------------------------
	Give the player ammunition.
		
	@param player The player to whom to give ammo to.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function ENT:AddAmmo( player ) return true end

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

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent
end
