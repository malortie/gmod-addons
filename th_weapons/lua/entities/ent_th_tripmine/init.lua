-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-------------------------------------
-- Laser Tripmine.
-------------------------------------
AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

include('shared.lua')

-- The sound to play after spawning.
ENT.DeploySound = 'ent_th_tripmine.deploy'

-- The sound to play when charging, before creating the beam.
ENT.ChargeSound = 'ent_th_tripmine.charge'

-- The sound to play right after this tripine went live.
ENT.ActivateSound = 'ent_th_tripmine.activate'

-- The class name associated to our weapon counter-part.
ENT.WeaponClassName	= 'weapon_th_tripmine'

local BeamClassName 	= 'env_beam'
local BeamEndClassName 	= 'info_target'

-- The maximum traceable beam length.
local TRIPMINE_TRACE_LENGTH	= 16384

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local tripmine_blast_damage = GetConVar('sk_th_plr_dmg_tripmine') or CreateConVar( 'sk_th_plr_dmg_tripmine', '150' )

--[[---------------------------------------------------------
	Perform Server-side initialization.
-----------------------------------------------------------]]
function ENT:InitializeServerSide()

	self:SetMoveType( MOVETYPE_FLY )
	self:SetSolid( SOLID_NONE )

	self:SetModel( self.Model )

	self:SetCycle(0)
	self:SetSequence(0)
	self:ResetSequenceInfo(0)
	
	self:SetPlaybackRate(0)
	
	self:SetTrigger(true)
	self:UseTriggerBounds(true, 1)
	
	self:SetCollisionBounds( Vector(-8,-8,-8), Vector(8, 8, 8) )
	self:SetPos( self:GetPos() )

	if self:HasSpawnFlags(1) then
		-- power up quickly
		self:SetPowerUp( CurTime() + 1.0 )
	else
		-- power up in 2.5 seconds
		self:SetPowerUp( CurTime() + 2.5 )
	end
	
	self.m_pfnThink = self.PowerupThink
	self:NextThink( CurTime() + 0.2 )
	
	--pev->takedamage = DAMAGE_YES;
	--pev->dmg = gSkillData.plrDmgTripmine;
	self:SetBlastDamage( tripmine_blast_damage:GetFloat() )
	self:SetBlastRadius( self:GetBlastDamage() )
	self:SetHealth(1) -- don't let die normally

	if IsValid( self:GetOwner() ) then
		-- play deploy sound
		self:EmitSound( self.DeploySound )
		self:EmitSound( self.ChargeSound ) -- chargeup
		
		self:SetRealOwner( self:GetOwner() )
	end
	
	local angles = self:GetAngles()
	
	self:SetBeamDir( angles:Forward() )
	self:SetBeamEnd( self:GetPos() + self:GetBeamDir() * TRIPMINE_TRACE_LENGTH ) -- 2048
end

function ENT:WarningThink()

	-- set to power up
	self.m_pfnThink = self.PowerupThink 
	self:NextThink( CurTime() + 1.0 )
end

--[[---------------------------------------------------------
	Called right after spawn, before beam creation.
-----------------------------------------------------------]]
function ENT:PowerupThink()

	if !IsValid( self:GetTripmineOwner() ) then
	
		-- find an owner
		local oldowner = self:GetOwner()
		self:SetOwner( nil )

		local tr = util.TraceLine({
			start = self:GetPos() + self:GetBeamDir() * 8,
			endpos = self:GetPos() - self:GetBeamDir() * 32,
			filter = self,
			mask = MASK_SHOT_HULL
		})
		
		if (tr.StartSolid || ( IsValid( oldowner ) && tr.Entity == oldowner) ) then

			self:SetOwner( oldowner )
			self:SetPowerUp( self:GetPowerUp() + 0.1 )
			self:NextThink( CurTime() + 0.1 )
			return;
		end
		if tr.Fraction < 1.0 then

			self:SetOwner( tr.Entity )
			self:SetTripmineOwner( self:GetOwner() )
			self:SetPosOwner( self:GetTripmineOwner():GetPos() )
			self:SetAngleOwner( self:GetTripmineOwner():GetAngles() )

		else
			self:StopSound( self.DeploySound )
			self:StopSound( self.ChargeSound )
			SafeRemoveEntityDelayed( self, 0.1 )	
			self.m_pfnThink = nil
			--ALERT( at_console, "WARNING:Tripmine at %.0f, %.0f, %.0f removed\n", pev->origin.x, pev->origin.y, pev->origin.z );
			self:KillBeam()	
			return
		end

	elseif ( self:GetPosOwner() != self:GetTripmineOwner():GetPos() or self:GetAngleOwner() != self:GetTripmineOwner():GetAngles() ) then

		-- disable
		self:StopSound( self.DeploySound )
		self:StopSound( self.ChargeSound )

		local mine = ents.Create( self.WeaponClassName )
		--mine:SetKeyValue( 'spawnflags', bit.bor( mine:GetSpawnFlags(), SF_NORESPAWN ) )
		mine:SetPos( self:GetPos() + self:GetBeamDir() * 24 )
		mine:SetAngles( self:GetAngles() )

		SafeRemoveEntityDelayed( self, 0.1 )	
		self.m_pfnThink = nil
		self:KillBeam()
		return;
	end
	-- ALERT( at_console, "%d %.0f %.0f %0.f\n", pev->owner, m_pOwner->pev->origin.x, m_pOwner->pev->origin.y, m_pOwner->pev->origin.z );
 
 
	if CurTime() > self:GetPowerUp() then

		-- make solid
		self:SetSolid( SOLID_BBOX )
		self:SetPos( self:GetPos() )

		self:MakeBeam( )

		-- play enabled sound
		self:EmitSound( self.ActivateSound )
	end
	self:NextThink( CurTime() + 0.1 )

end

--[[---------------------------------------------------------
	Destroy the beam.
-----------------------------------------------------------]]
function ENT:KillBeam()
	if IsValid( self:GetBeam() ) then
		self:GetBeam():Remove()
		self:SetBeam( nil )
	end
end

--[[---------------------------------------------------------
	Create the beam.
-----------------------------------------------------------]]
function ENT:MakeBeam()

	-- ALERT( at_console, "serverflags %f\n", gpGlobals->serverflags );

	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetBeamEnd(),
		filter = self,
		mask = MASK_SOLID_BRUSHONLY
	})
	
	self:SetBeamLength( tr.Fraction )
	
	-- set to follow laser spot
	self.m_pfnThink = self.BeamBreakThink
	self:NextThink( CurTime() + 0.1 )

	local vecTmpEnd = self:GetPos() + self:GetBeamDir() * TRIPMINE_TRACE_LENGTH * self:GetBeamLength() -- 2048

	local beam = ents.Create( BeamClassName )
	
	local target = ents.Create( BeamEndClassName )
	target:SetKeyValue( 'targetname', '_tripmine_beam_1_' .. self:EntIndex()  )
	target:SetPos( self:GetPos() )
	target:Spawn()
	target:Activate()
	self:SetBeamEndEntity1( target )
	
	beam:SetKeyValue( 'LightningStart', target:GetName() )
	
	target = ents.Create( BeamEndClassName )
	target:SetKeyValue( 'targetname', '_tripmine_beam_2_' .. self:EntIndex() )
	target:SetPos( vecTmpEnd )
	target:Spawn()
	target:Activate()
	self:SetBeamEndEntity2( target )
	
	beam:SetKeyValue( 'LightningEnd', target:GetName() )
	
	beam:SetKeyValue( 'spawnflags', 1 ) -- SF_BEAM_STARTON
	beam:SetKeyValue( 'life', 0 )
	beam:SetKeyValue( 'BoltWidth', 1 ) -- 10
	beam:SetKeyValue( 'TextureScroll', 255 )
	beam:SetKeyValue( 'texture', "sprites/laserbeam.spr" )
	beam:SetKeyValue( 'rendercolor', '0, 214, 198' )
	beam:SetKeyValue( 'renderamt', 64 )
	beam:Spawn()
	beam:Activate()
	beam:Input( 'TurnOn', self, self )
	
	self:SetBeam(beam)
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function ENT:BeamBreakThink()

	local bBlowup = 0;

	-- HACKHACK Set simple box using this really nice global!
	-- gpGlobals->trace_flags = FTRACE_SIMPLEBOX;
	local tr = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetBeamEnd(),
		filter = self,
		mask = MASK_SHOT_HULL
	})

	-- ALERT( at_console, "%f : %f\n", tr.flFraction, m_flBeamLength );

	-- respawn detect. 
	if !IsValid( self:GetBeam() ) then
		self:MakeBeam()
		if tr.Entity then
			self:SetTripmineOwner( tr.Entity ) -- reset owner too
		end
	end
	
	if math.abs( self:GetBeamLength() - tr.Fraction ) > 0.001 then
		bBlowup = 1
	else
		--[[
		if !IsValid( self:GetTripmineOwner() ) then
			bBlowup = 1
		elseif self:GetPosOwner() != self:GetTripmineOwner():GetPos() then
			bBlowup = 1
		elseif self:GetAngleOwner() != self:GetTripmineOwner():GetAngles() then
			bBlowup = 1
		end	
		--]]
	end

	if (bBlowup == 1) then
		--[[
			a bit of a hack, but all CGrenade code passes pev->owner along to make sure the proper player gets credit for the kill
			so we have to restore pev->owner from pRealOwner, because an entity's tracelines don't strike it's pev->owner which meant
			that a player couldn't trigger his own tripmine. Now that the mine is exploding, it's safe the restore the owner so the 
			CGrenade code knows who the explosive really belongs to.
		--]]
		self:SetOwner( self:GetRealOwner() )
		self:SetHealth(0)

		local dmginfo = DamageInfo()
		
		if IsValid( self:GetOwner() ) then
			dmginfo:SetInflictor( self:GetOwner() )
			dmginfo:SetAttacker( self:GetOwner() )
		end
		
		self:Event_Killed( dmginfo )
		--self:Killed( VARS( pev->owner ), GIB_NORMAL );
		return
	end

	self:NextThink( CurTime() + 0.01 ) -- o.1
end

--[[---------------------------------------------------------
	Called when the entity is taking damage.
	
	@param dmginfo The damage to be applied to the entity.
-----------------------------------------------------------]]
function ENT:OnTakeDamage( dmginfo )

	if ( CurTime() < self:GetPowerUp() and dmginfo:GetDamage() < self:Health() ) then

		-- disable
		-- Create( "weapon_tripmine", pev->origin + m_vecDir * 24, pev->angles );
		SafeRemoveEntityDelayed( self, 0.1 )
		self.m_pfnThink = nil
		self:KillBeam()
		return false
	end
	
	self:Event_Killed( dmginfo )
end

--[[---------------------------------------------------------
	Called upon death.
	
	@param dmginfo The damage to be applied to the entity.
-----------------------------------------------------------]]
function ENT:Event_Killed( dmginfo )

	-- pev->takedamage = DAMAGE_NO;
	
	if ( IsValid( dmginfo:GetAttacker() ) && (  bit.band( dmginfo:GetAttacker():GetFlags(), FL_CLIENT ) ) ) then
		-- some client has destroyed this mine, he'll get credit for any kills
		self:SetOwner( dmginfo:GetAttacker() )
	end

	self.m_pfnThink = self.DelayDeathThink
	self:NextThink( CurTime() + RandomFloat( 0.1, 0.3 ) )
	
	-- EMIT_SOUND( ENT(pev), CHAN_BODY, "common/null.wav", 0.5, ATTN_NORM ); // shut off chargeup
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function ENT:DelayDeathThink()

	self:KillBeam();
	local tr = util.TraceLine({
		start = self:GetPos() + self:GetBeamDir() * 8,
		endpos = self:GetPos() - self:GetBeamDir() * 64,
		filter = self,
		mask = MASK_SHOT_HULL
	})
	
	self:Explode( tr, DMG_BLAST );
end

--[[---------------------------------------------------------
	Cause this satchel to explode.
-----------------------------------------------------------]]
function ENT:Explode( tr, bitsDamageType )

	local dmginfo = DamageInfo()
	dmginfo:SetInflictor( self )
	if IsValid( self.Owner ) then
		dmginfo:SetAttacker( self.Owner )
	else
		dmginfo:SetAttacker( self )
	end
	dmginfo:SetDamage( tripmine_blast_damage:GetFloat() )
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
function ENT:Think()
	if self.m_pfnThink then
		-- If this entity has a think function, call it.
		self:m_pfnThink()
		return true
	end
end

--[[---------------------------------------------------------
	Called when the entity is about to be removed. 
-----------------------------------------------------------]]
function ENT:OnRemove()

	-- Delete the beam.
	self:KillBeam()
	
	-- Delete beam start entity.
	if IsValid( self:GetBeamEndEntity1() ) then
		self:GetBeamEndEntity1():Remove()
	end
	-- Delete beam end entity.
	if IsValid( self:GetBeamEndEntity2() ) then
		self:GetBeamEndEntity2():Remove()
	end
end