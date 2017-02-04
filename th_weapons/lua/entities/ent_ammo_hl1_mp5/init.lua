-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-------------------------------------
-- MP5 ammunition.
-------------------------------------
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'ent_hl1_ammo_base' )

-- The sound to play when picked up by a player.
ENT.PickupSound = "hl1_player.ammopickup"

--[[---------------------------------------------------------
	Perform Server-side initialization.
-----------------------------------------------------------]]
function ENT:InitializeServerSide()
	
	-- Set entity's model.
	self:SetModel( self.Model )
	
	-- Call base class initialization.
	BaseClass.InitializeServerSide( self )
end

function ENT:AddAmmo( player )
	
	-- Give to the player, 12 shotgun shells.
	if player:GiveAmmo( 50, AMMO_CLASS_HL1_9MM, false ) != -1 then
		-- Play pickup sound.
		self:EmitSound( self.PickupSound )
		return true
	end
	return false
end

