-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-------------------------------------
-- Remotely controlled explosive.
-------------------------------------
AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )

include( 'shared.lua' )

ENT.BoundSound = 'ent_th_satchel.bounce'

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local satchel_blast_damage = GetConVar('sk_th_plr_dmg_satchel') or CreateConVar( 'sk_th_plr_dmg_satchel', '150' )

-- Blast radius scale factor
local satchel_radius_factor = GetConVar( 'sk_hl1_grenade_radius_factor' ) or CreateConVar( 'sk_hl1_grenade_radius_factor', '2.5' )

--[[---------------------------------------------------------
	Perform Server-side initialization.
-----------------------------------------------------------]]
function ENT:InitializeServerSide()

	self:SetMoveType( MOVETYPE_FLYGRAVITY )
	self:SetSolid( SOLID_BBOX )

	self:SetModel( self.Model )
	
	self:SetTrigger(true)
	self:UseTriggerBounds(true, 1)
	
	self:SetCollisionBounds( Vector(-4,-4,-4), Vector(4, 4, 4) )
	self:SetPos( self:GetPos() )
	
	self.m_pfnThink = self.SatchelSlide
	self:NextThink( CurTime() + 0.1 )
	
	self:SetBlastDamage( satchel_blast_damage:GetFloat() )
	self:SetBlastRadius( self:GetBlastDamage() * satchel_radius_factor:GetFloat() )
	self:SetGravity( 0.5 )
	self:SetFriction( 0.8 )

	self:SetSequence( 1 )

end

--[[---------------------------------------------------------
	Deactivate this satchel.
-----------------------------------------------------------]]
function ENT:Deactivate()
	self:SetSolid( SOLID_NONE )
	self:Remove()
end

--[[---------------------------------------------------------
	Called when used by a player or when called 
	by another entity.
		
	@param activator The initial cause for the input getting triggered.
	@param caller The entity that directly triggered the input.
	@param useType Use type.
	@param value Any passed value.
-----------------------------------------------------------]]
function ENT:Use( activator, caller, useType, value )

	self.m_pfnThink = self.Detonate
	self:NextThink( CurTime() )

end

--[[---------------------------------------------------------
	Called when touched by another entity.
		
	@param other The entity that we are touching.
-----------------------------------------------------------]]
function ENT:Touch( other )

	-- don't hit the guy that launched this grenade
	if other == self:GetOwner() then return end

	self:SetGravity( 1 ) -- normal gravity now

	-- HACKHACK - On ground isn't always set, so look for ground underneath
	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() - Vector(0, 0, 10),
		filter = self,
		mask = MASK_SHOT_HULL
	})
	
	if tr.Fraction < 1.0 then
	
		-- add a bit of static friction
		self:SetVelocity( self:GetVelocity() * 0.95 )
		self:SetLocalAngularVelocity( self:GetLocalAngularVelocity() * 0.9 )
		-- play sliding sound, volume based on velocity
	end
	if ( !self:IsOnGround() && self:GetVelocity():Length2D() > 10 ) then
		self:PlayBounceSound()
	end
end

--[[---------------------------------------------------------
	Cause this satchel to explode.
-----------------------------------------------------------]]
function ENT:Detonate()

	self.m_pfnThink = nil

	local 		vecSpot -- trace starts here!
	
	vecSpot = self:GetPos() + Vector( 0, 0, 8 )
	local tr = util.TraceLine({
		start = vecSpot,
		endpos = vecSpot + Vector ( 0, 0, -40 ),
		filter = self,
		mask = MASK_SOLID_BRUSHONLY
	})
	
	self:Explode( tr, DMG_BLAST )
end

function ENT:Explode( tr, bitsDamageType )

	local dmginfo = DamageInfo()
	dmginfo:SetInflictor( self )
	if IsValid( self.Owner ) then
		dmginfo:SetAttacker( self.Owner )
	else
		dmginfo:SetAttacker( self )
	end
	dmginfo:SetDamage( satchel_blast_damage:GetFloat() )
	dmginfo:SetDamagePosition( tr.HitPos )
	dmginfo:SetDamageForce( vector_origin )
	dmginfo:SetDamageType( DMG_BLAST )

	util.BlastDamageInfo( dmginfo, tr.HitPos, self:GetBlastRadius() )

	local effectdata = EffectData()
	effectdata:SetOrigin( tr.StartPos )
	util.Effect( "explosion", effectdata, true, true )

	self:Remove()
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function ENT:SatchelSlide()

	self:NextThink( CurTime() + 0.1 )
	
	if !self:IsInWorld() then
		self:Remove()
		return
	end
	
	local velocity = self:GetVelocity()
	
	if self:WaterLevel() == 3 then
		self:SetMoveType( MOVETYPE_FLY )
		velocity = velocity * 0.8
		self:SetLocalAngularVelocity( self:GetLocalAngularVelocity() * 0.9 )
		velocity.z = velocity.z + 8
	elseif self:WaterLevel() == 0 then
		self:SetMoveType( MOVETYPE_FLYGRAVITY )
	else
		velocity.z = velocity.z - 8
	end

	return true
end

--[[---------------------------------------------------------
	Play a sound when bouncing off a wall.
-----------------------------------------------------------]]
function ENT:PlayBounceSound()

	self:EmitSound( self.BoundSound )
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