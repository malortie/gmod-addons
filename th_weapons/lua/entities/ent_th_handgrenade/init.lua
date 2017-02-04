-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )

include( 'shared.lua' )

-- The sound to play when bouncing off a wall.
ENT.BounceSound = 'ent_th_handgrenade.grenadebounce'

-------------------------------------
-- Grenade class names.
-------------------------------------
local GrenadeContactClassName	= 'ent_th_handgrenade'
local GrenadeTimedClassName		= 'ent_th_handgrenade'
local GrenadeSatchelClassName	= 'ent_th_satchel'
local GrenadeTNTClassName		= 'ent_th_handgrenade'

local SatchelCode = { SATCHEL_DETONATE = 0, SATCHEL_RELEASE = 1  }

--[[---------------------------------------------------------
	Perform Server-side initialization.
-----------------------------------------------------------]]
function ENT:InitializeServerSide()

	self:SetMoveType( MOVETYPE_FLYGRAVITY )
	self:SetSolid( SOLID_BBOX )
	
	self:SetModel( self.Model )
	self:SetTrigger( true )
	self:UseTriggerBounds( true, 1 )
	
	self:SetCollisionBounds( vector_origin, vector_origin )

	self:SetBlastDamage( 100 )
	self:SetRegisteredSound( false )
end

--
-- Grenade Explode
--
--[[---------------------------------------------------------
	Main explode method.
-----------------------------------------------------------]]
function ENT:Explode( vecSrc, vecAim )

	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + Vector(0, 0, -32),
		filter = self,
		mask = MASK_SOLID_BRUSHONLY
	})
	
	self:Explode2( tr, DMG_BLAST );
end

--[[---------------------------------------------------------
	Helper explode method.
-----------------------------------------------------------]]
function ENT:Explode2(pTrace, bitsDamageType )

	self:AddEffects( EF_NODRAW ) -- invisible
	self:SetSolid( SOLID_NONE ) -- intangible

	-- Pull out of the wall a bit
	if pTrace.Fraction != 1.0 then
		self:SetPos( pTrace.HitPos + (pTrace.HitNormal * (self:GetBlastDamage() - 24) * 0.6) )
	end

	local iContents = util.PointContents ( self:GetPos() )
	
	local effectdata = EffectData()
	effectdata:SetOrigin( pTrace.StartPos )
	
	if (iContents != CONTENTS_WATER) then
		util.Effect( "Explosion", effectdata, true, true )
	else
		util.Effect( "WaterSurfaceExplosion", effectdata, true, true )
	end
	
	local owner
	if self:GetOwner() then
		owner = self:GetOwner()
	else
		owner = nil
	end
	
	self:SetOwner( nil ) -- can't traceline attack owner if this is set

	local dmginfo = DamageInfo()
	dmginfo:SetInflictor( self )
	if IsValid( owner ) then
		dmginfo:SetAttacker( owner )
	end	
	dmginfo:SetDamagePosition( pTrace.HitPos )
	dmginfo:SetDamageType( bitsDamageType )
	dmginfo:SetDamage( self:GetBlastDamage() )
	
	util.BlastDamageInfo( dmginfo, pTrace.HitPos, self:GetBlastRadius() )

	if RandomFloat( 0, 1 ) < 0.5 then
		util.Decal( "Scorch", pTrace.HitPos + pTrace.HitNormal, pTrace.HitPos - pTrace.HitNormal )
	else
		util.Decal( "Scorch", pTrace.HitPos + pTrace.HitNormal, pTrace.HitPos - pTrace.HitNormal )
	end

	self:EmitSound( "BaseGrenade.Explode" )

	self:AddEffects( EF_NODRAW )
	self.m_pfnThink = self.Smoke
	self:SetVelocity( vector_origin )
	self:NextThink( CurTime() + 0.3 )

	if (iContents != CONTENTS_WATER) then

		local effectdata = EffectData()
		effectdata:SetOrigin( pTrace.HitPos )
		effectdata:SetNormal( pTrace.HitNormal )
		
		local i = 1
		local sparkCount = RandomInt(0,3)
		
		while i < sparkCount do
			util.Effect( "cball_explode", effectdata, true, true )
			i = i + 1
		end
	end
end

--[[---------------------------------------------------------
	Spawn smoke effects.
-----------------------------------------------------------]]
function ENT:Smoke()

	if util.PointContents( self:GetPos() ) == CONTENTS_WATER then
		-- UTIL_Bubbles( pev->origin - Vector( 64, 64, 64 ), pev->origin + Vector( 64, 64, 64 ), 100 );
	else
		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		util.Effect( "ElectricSpark", effectdata, true, true )
	end
	self:Remove()
end

--[[---------------------------------------------------------
	Called upon death.
		
	@param other The entity that we are touching.
-----------------------------------------------------------]]
function ENT:Event_Killed( dmginfo )
	self:Detonate()
end


-- Timed grenade, this think is called when time runs out.
function ENT:DetonateUse( activator, caller, useType, value )

	self.m_pfnThink = self.Detonate
	self:NextThink( CurTime() )
end

--[[---------------------------------------------------------
	Called before this grenade detonation.
-----------------------------------------------------------]]
function ENT:PreDetonate()

	self.m_pfnThink = self.Detonate
	self:NextThink( CurTime() + 1 )
end

--[[---------------------------------------------------------
	Cause this grenade to explode.
-----------------------------------------------------------]]
function ENT:Detonate()
	
	local		vecSpot -- trace starts here!
	vecSpot = self:GetPos() + Vector( 0, 0, 8 )
	
	local tr = util.TraceLine({
		start = vecSpot,
		endpos = vecSpot + Vector (0, 0, -40),
		filter = self,
		mask = MASK_SOLID_BRUSHONLY
	})

	self:Explode( tr, DMG_BLAST )
end


--
-- Contact grenade, explode when it touches something
--
function ENT:ExplodeTouch( other )
	--
	if self:GetOwner() == other then return end
	
	
	self.m_pfnTouch = nil
	--
	
	local		vecSpot -- trace starts here!

	vecSpot = self:GetPos() - self:GetVelocity():GetNormalized() * 32
	local tr = util.TraceLine({
		start = vecSpot,
		endpos = vecSpot + self:GetVelocity():GetNormalized() * 64,
		filter = self,
		mask = MASK_SOLID_BRUSHONLY
	})

	self:Explode( tr, DMG_BLAST )
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function ENT:DangerSoundThink()

	if !self:IsInWorld() then
		self:Remove()
		return
	end

	self:NextThink( CurTime() + 0.2 )

	if self:WaterLevel() != 0 then
		self:SetVelocity( self:GetVelocity() * 0.5 )
	end
end

--[[---------------------------------------------------------
	Called when touched by another entity.
		
	@param other The entity that we are touching.
-----------------------------------------------------------]]
function ENT:BounceTouch( other )

	-- don't hit the guy that launched this grenade
	if other == self:GetOwner() then return end	

	-- only do damage if we're moving fairly fast
	if (self:GetNextAttack() < CurTime() && self:GetVelocity():Length() > 100) then

		local owner = self:GetOwner()
		if IsValid( owner ) then
			local tr = self:GetTouchTrace()
			-- ClearMultiDamage( );
			local dmgInfo = DamageInfo()
			dmgInfo:SetInflictor( self )
			dmgInfo:SetAttacker( owner )
			dmgInfo:SetDamageForce( self:GetVelocity():GetNormalized() )
			dmgInfo:SetDamageType( DMG_CLUB )
			dmgInfo:SetDamage( 1 )
			
			other:DispatchTraceAttack( dmgInfo, tr )
			-- ApplyMultiDamage( pev, pevOwner);
		end
		self:SetNextAttack( CurTime() + 1.0 ) -- debounce
	end

	local vecTestVelocity

	--[[
		this is my heuristic for modulating the grenade velocity because grenades dropped purely vertical
		or thrown very far tend to slow down too quickly for me to always catch just by testing velocity. 
		trimming the Z velocity a bit seems to help quite a bit.
	--]]
	vecTestVelocity = self:GetVelocity()
	vecTestVelocity.z = vecTestVelocity.z * 0.45

	if ( !self:GetRegisteredSound() && vecTestVelocity:Length() <= 60 ) then
	
		-- ALERT( at_console, "Grenade Registered!: %f\n", vecTestVelocity.Length() );

		-- grenade is moving really slow. It's probably very close to where it will ultimately stop moving. 
		-- go ahead and emit the danger sound.
		
		-- register a radius louder than the explosion, so we make sure everyone gets out of the way
		--CSoundEnt::InsertSound ( bits_SOUND_DANGER, pev->origin, pev->dmg / 0.4, 0.3 );
		self:SetRegisteredSound( true )
	end

	if self:GetGroundEntity() then
		-- add a bit of static friction
		--self:SetVelocity( self:GetVelocity() * 0.8 )

		self:SetSequence( RandomInt(1, 1) )
	else
		-- play bounce sound
		self:PlayBounceSound()
	end
	
	local playbackrate = self:GetVelocity():Length() / 200.0

	if (playbackrate > 1.0) then
		playbackrate = 1
	elseif (playbackrate < 0.5) then
		playbackrate = 0
	end	

	self:SetPlaybackRate( playbackrate )
end

--[[---------------------------------------------------------
	Called when touched by another entity.
		
	@param other The entity that we are touching.
-----------------------------------------------------------]]
function ENT:SlideTouch( other )

	-- don't hit the guy that launched this grenade
	if other == self:GetOwner() then return end		

	if self:IsOnGround() then
		-- add a bit of static friction
		local velocity = self:GetVelocity()
		velocity = velocity * 0.95

		if velocity.x != 0 || velocity.y != 0 then
			-- maintain sliding sound
		end
		
		self:SetVelocity( velocity )
	else
		self:PlayBounceSound()
	end
end

--[[---------------------------------------------------------
	Play a sound when bouncing off a wall.
-----------------------------------------------------------]]
function ENT:PlayBounceSound()
	self:EmitSound( self.BounceSound )
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function ENT:TumbleThink()

	if !self:IsInWorld() then
		self:Remove()
		return
	end
	
	--
	-- NEW
	if self:GetGroundEntity() then
		self:SetVelocity( self:GetVelocity() * 0.001 )
	end
	--
	
	self:NextThink( CurTime() + 0.1 )

	if ( self:GetDetonateTime() - 1 < CurTime() ) then
		-- CSoundEnt::InsertSound ( bits_SOUND_DANGER, pev->origin + pev->velocity * (pev->dmgtime - gpGlobals->time), 400, 0.1 );
	end

	if self:GetDetonateTime() <= CurTime() then
		self.m_pfnThink = self.Detonate
	end
	if self:WaterLevel() != 0 then
		self:SetVelocity( self:GetVelocity( 0.5 ) )
		self:SetPlaybackRate( 0.2 )
	end
end

--[[---------------------------------------------------------
	Name: PhysicsCollide
	Desc: Called when physics collides. The table contains 
			data on the collision
-----------------------------------------------------------]]
function ENT:PhysicsCollide( data, physobj )

	-- Play sound on bounce
	if ( data.Speed > 60 && data.DeltaTime > 0.2 ) then
		self:PlayBounceSound()
	end

	local LastSpeed = math.min( data.OurOldVelocity:Length(), data.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()
	
	local TargetVelocity = NewVelocity * LastSpeed * 0.8

	physobj:SetVelocity( TargetVelocity )

end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function ENT:Think()
	if self.m_pfnThink then
		-- If this entity has a think function, call it.
		self:m_pfnThink()
	end
end

--[[---------------------------------------------------------
	Called when touched by another entity.
		
	@param other The entity that we are touching.
-----------------------------------------------------------]]
function ENT:Touch( other )
	if self.m_pfnTouch then
		-- If this entity has a touch function, call it.
		self:m_pfnTouch( other )
	end
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
	if self.m_pfnUse then
		-- If this entity has a use function, call it.
		self:m_pfnUse( activator, caller, useType, value )
	end
end