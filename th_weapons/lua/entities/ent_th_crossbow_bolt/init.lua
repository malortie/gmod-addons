-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-------------------------------------
-- Projectile fired by the crossbow.
-------------------------------------
AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )

include( 'shared.lua' )

ENT.HitSound 		= 'weapon_th_crossbow.bolthitbody'
ENT.HitWorldSound 	= 'weapon_th_crossbow.bolthitworld'

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local bolt_player_damage 	= GetConVar( 'sk_th_plr_dmg_xbow_bolt_plr' ) or CreateConVar( 'sk_th_plr_dmg_xbow_bolt_plr', '10' )

-- Represents the amount of damage casted to an NPC.
local bolt_npc_damage 		= GetConVar( 'sk_th_plr_dmg_xbow_bolt_npc' ) or CreateConVar( 'sk_th_plr_dmg_xbow_bolt_npc', '50' )

--[[---------------------------------------------------------
	Perform Server-side initialization.
-----------------------------------------------------------]]
function ENT:InitializeServerSide()

	-- Make this entity moveable, and aftected by gravity.
	self:SetMoveType( MOVETYPE_FLYGRAVITY )
	-- Set the solidity of the NPC.
	self:SetSolid( SOLID_BBOX )

	-- Half gravity scale.
	self:SetGravity( 0.5 )
	
	-- Set entity's model.
	self:SetModel( self.Model )
	
	-- Make this entity receptible to touching.
	-- Enable touching.
	self:SetTrigger(true)
	self:UseTriggerBounds(true, 1)
	
	-- Set the collision volume.
	self:SetCollisionBounds( vector_origin, vector_origin )
	
	-- Setup touch and think function pointers.
	self.m_pfnTouch = self.BoltTouch
	self.m_pfnThink = self.BubbleThink
	self:NextThink( CurTime() + 0.2 )
end

--[[---------------------------------------------------------
	Called when touched by another entity.
		
	@param other The entity that we are touching.
-----------------------------------------------------------]]
function ENT:BoltTouch( other )

	self.m_pfnThink = nil
	self.m_pfnTouch = nil

	if ( other:IsPlayer() || other:IsNPC() ) then

		local tr = self:GetTouchTrace()

		local owner = self.Owner

		--ClearMultiDamage( );

		local dmginfo = DamageInfo()
		dmginfo:SetInflictor( self )
		dmginfo:SetAttacker( owner )
		dmginfo:SetDamagePosition( tr.HitPos )
		dmginfo:SetDamageForce( self:GetVelocity() )
		
		if other:IsPlayer() then
			dmginfo:SetDamage( bolt_player_damage:GetFloat() )
			dmginfo:SetDamageType( DMG_NEVERGIB )
		else
			dmginfo:SetDamage( bolt_npc_damage:GetFloat() )
			dmginfo:SetDamageType( bit.bor( DMG_BULLET, DMG_NEVERGIB ) )
		end
		
		other:DispatchTraceAttack( dmginfo, tr )

		--ApplyMultiDamage( pev, pevOwner );

		self:SetVelocity( vector_origin )
		
		-- play body "thwack" sound
		self:EmitSound( self.HitSound )

		if game.SinglePlayer() then
			self:Remove()
		end
	else

		self:EmitSound( self.HitWorldSound )
		
		SafeRemoveEntityDelayed( self, 10 ) -- this will get changed below if the bolt is allowed to stick in what it hit.
		
		if other:IsWorld() then
			-- if what we hit is static architecture, can stay around for a while.
			local vecDir = self:GetVelocity():GetNormalized()
			self:SetPos( self:GetPos() - vecDir * 12 )
			
			self:SetAngles( vecDir:Angle() )
			self:SetSolid( SOLID_NONE )
			self:SetMoveType( MOVETYPE_NONE )
			self:SetVelocity( vector_origin )
			
			local angvel = self:GetLocalAngularVelocity()
			angvel.r = RandomInt( 0, 360 )
			self:SetLocalAngularVelocity( angvel )
		end
		
		if util.PointContents( self:GetPos() ) != CONTENTS_WATER then
			local tr = self:GetTouchTrace()
			UTIL_Sparks( self:GetPos(), tr, 1 )
		end
	end

	if !game.SinglePlayer() then
		self.m_pfnThink = self.ExplodeThink
		self:NextThink( CurTime() + 0.1 )
	end
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function ENT:BubbleThink()

	self:NextThink( CurTime() + 0.1 )
	
	--
	-- NEW
	self:SetAngles( self:GetVelocity():Angle() )
	--	
	
	if self:WaterLevel() == 0 then
		return end

	-- UTIL_BubbleTrail( pev->origin - pev->velocity * 0.1, pev->origin, 1 );
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function ENT:ExplodeThink()

	-- Trace a line forward, using this entity's angles.
	local direction = self:GetAngles():Forward()
	local tr = util.TraceLine({
		start = self:GetPos() - direction * 10,
		endpos = self:GetPos() + direction * 10,
		filter = self,
		mask = MASK_SOLID_BRUSHONLY
	})

	local iContents = util.PointContents( tr.HitPos )
	
	-- Explosion damage.
	local damage = 40
	
	-- Make an explosion effect.
	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos )
	if iContents != CONTENTS_WATER then
		-- Normal explosion effect.
		util.Effect( "Explosion", effectdata, true, true )
	else
		-- Underwater explosion effect.
		util.Effect( "WaterSurfaceExplosion", effectdata, true, true )
	end

	-- Make a backup of this entity's owner ( if any ).
	local owner

	if self:GetOwner() then
		owner = self:GetOwner() 
	else
		owner = nil
	end
	
	self:SetOwner( nil )

	-- Cast radial damage.
	local dmginfo = DamageInfo()
	dmginfo:SetInflictor( self )
	if IsValid( owner ) then
		dmginfo:SetAttacker( owner )
	else
		dmginfo:SetAttacker( self )
	end
	dmginfo:SetDamage( damage )
	dmginfo:SetDamagePosition( tr.HitPos )
	dmginfo:SetDamageType( bit.bor( DMG_BLAST, DMG_ALWAYSGIB ) )
	
	util.BlastDamageInfo( dmginfo, dmginfo:GetDamagePosition(), 128 )
	
	-- Remove this entity.
	self:Remove()
end

--[[---------------------------------------------------------
	Called when touched by another entity.
		
	@param other The entity that we are touching.
-----------------------------------------------------------]]
function ENT:Touch( other )

	-- Do not collide with bolt owner/thrower.
	if IsValid( self:GetOwner() ) && self:GetOwner() == other then return end

	if self.m_pfnTouch then
		-- If this entity has a touch function, call it.
		self:m_pfnTouch( other )
		return true
	end	
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function ENT:Think()

	if self.m_pfnThink then
		-- If this entity has a think function, call it.
		self:m_pfnThink()
		return true
	end	
end
