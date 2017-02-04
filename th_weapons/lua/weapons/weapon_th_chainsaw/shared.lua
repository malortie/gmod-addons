-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base = 'weapon_th_base'

SWEP.PrintName = 'Chainsaw (Cut)'
SWEP.Author = 'Marc-Antoine (malortie) Lortie'
SWEP.Contact = ''
SWEP.Purpose = ''
SWEP.Instructions	= ''
SWEP.Category = 'They Hunger'

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.ViewModel = 'models/th/v_chainsaw/v_chainsaw.mdl'
SWEP.WorldModel = 'models/th/w_chainsaw/w_chainsaw.mdl'

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = AMMO_CLASS_TH_SAWGAS

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = 'none'

SWEP.PullbackSound			= 'weapon_th_chainsaw.pullback'
SWEP.EngineStartSound		= 'weapon_th_chainsaw.engine_start'
SWEP.EngineRunSound			= 'weapon_th_chainsaw.engine_run'
SWEP.EngineShutdownSound	= 'weapon_th_chainsaw.engine_shutdown'
SWEP.AttackSound			= 'weapon_th_chainsaw.attack'
SWEP.SwingSound				= 'weapon_th_chainsaw.swing'
SWEP.SwingOffSound			= 'weapon_th_chainsaw.swingoff'

-- The rate at which to decrement gas when
-- the chainsaw is on.
SWEP.AmmoDrainRate			= 0.8

-- The rate at which to inflict damage when
-- the chainsaw is on.
SWEP.AttackRate				= 0.1

-- The minimum facing to inflict damage to a
-- target (as a dot product result).
SWEP.FacingDotMin			= 0.5

-- The chainsaw trace length.
SWEP.TraceDistance			= 32

-- Minimum and maximum hull size to perform
-- trace attack.
SWEP.TraceHullMins			= Vector( -16, -16, -16 )
SWEP.TraceHullMaxs			= Vector( 16, 16, -16 )

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted.
local chainsaw_damage_idle = GetConVar( 'sk_th_plr_dmg_chainsaw_idle' ) or CreateConVar( 'sk_th_plr_dmg_chainsaw_idle', '2' )
local chainsaw_damage_swing = GetConVar( 'sk_th_plr_dmg_chainsaw_swing' ) or CreateConVar( 'sk_th_plr_dmg_chainsaw_swing', '10' )

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()

	BaseClass.SetupDataTables( self )
	
	self.Weapon:NetworkVar( 'Float', 3, 'PowerupTime' )
	self.Weapon:NetworkVar( 'Float', 4, 'NextAmmoDrainTime' )
	self.Weapon:NetworkVar( 'Float', 5, 'NextAttackTime' )
	self.Weapon:NetworkVar( 'Float', 6, 'LastFireTime' )
	self.Weapon:NetworkVar( 'Float', 7, 'PullbackSoundTime' )
	self.Weapon:NetworkVar( 'Float', 8, 'NextAttackSoundTime' )
	self.Weapon:NetworkVar( 'Float', 9, 'NextEngineSoundTime' )
	self.Weapon:NetworkVar( 'Float', 10, 'NextViewPunchTime' )
	self.Weapon:NetworkVar( 'Float', 11, 'SwingAttackTime' )

	self.Weapon:NetworkVar( 'Bool', 1, 'EngineOn' )
end

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )
	
	self.Weapon:SetPowerupTime( 0 )
	self.Weapon:SetNextAmmoDrainTime( 0 )
	self.Weapon:SetNextAttackTime( 0 )
	self.Weapon:SetLastFireTime( 0 )
	self.Weapon:SetPullbackSoundTime( 0 )
	self.Weapon:SetNextAttackSoundTime( 0 )
	self.Weapon:SetNextEngineSoundTime( 0 )
	self.Weapon:SetNextViewPunchTime( 0 )
	self.Weapon:SetSwingAttackTime( 0 )
	self.Weapon:SetEngineOn( false )

	self:SetHoldType( "melee2" )
end

--[[---------------------------------------------------------
	Called when weapon tries to holster.
	
	@param wep The weapon we are trying switch to.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:Holster( wep )

	if self:IsEngineOn() then
		self:ToggleEngine()
	end
	self:ResetAttackSwing()
	
	return BaseClass.Holster( self, wep )
end

--[[---------------------------------------------------------
	Called when player has just switched to this weapon.
	
	@return true to allow switching away from this weapon 
			using lastinv command.
-----------------------------------------------------------]]
function SWEP:Deploy()
	return BaseClass.Deploy( self )
end

--[[---------------------------------------------------------
	Called when the reload key is pressed.
-----------------------------------------------------------]]
function SWEP:Reload()
	return true
end

--[[---------------------------------------------------------
	Check if the weapon can do a primary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()
	return true
end

--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return end

	self:AttackSwing( self:IsEngineOn() )
end

--[[---------------------------------------------------------
	Check if the weapon can do a secondary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()

	if self:Ammo1() <= 0 then return false end
	
	if self:IsStartingUp() then return true end
	
	return true
end

--[[---------------------------------------------------------
	Secondary weapon attack.
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
	
	if !self:CanSecondaryAttack() then return end
	
	self:ToggleEngine()
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function SWEP:Think()

	local owner = self.Owner
	if !IsValid( owner ) then return end
	
	self:UpdateChainsaw( self:IsEngineOn() )
	
	self:WeaponIdle()
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()

	if !self:CanIdle() then return end

	local seq = self:LookupSequence( 'idle1' )

	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( seq )
	
	self.Weapon:SetNextIdle( CurTime() + self:ViewModelSequenceDuration() )
end

--[[---------------------------------------------------------
	Return engine state.
	
	@return true if the chainsaw engine is running.
	@return false otherwise.
-----------------------------------------------------------]]
function SWEP:IsEngineOn() return self.Weapon:GetEngineOn() end

--[[---------------------------------------------------------
	Return startup state.
	
	@return true if the chainsaw engine is starting up.
	@return false otherwise.
-----------------------------------------------------------]]
function SWEP:IsStartingUp() return self.Weapon:GetPowerupTime() != 0 end

--[[---------------------------------------------------------
	Return swing attack state.
	
	@return true if the owner is performing the swing attack.
	@return false otherwise.
-----------------------------------------------------------]]
function SWEP:IsInSwingAttack() return self.Weapon:GetInAttack() == 1 end

--[[---------------------------------------------------------
	Start pulling back the chainsaw handle.
-----------------------------------------------------------]]
function SWEP:Pullback()

	self:SendWeaponAnim( ACT_VM_PULLBACK )
	
	self.Weapon:SetPowerupTime( CurTime() + self:ViewModelSequenceDuration() )
	self.Weapon:SetPullbackSoundTime( CurTime() + 78.0 / 60.0 )
	self.Weapon:SetEngineOn( false )
	
	self.Weapon:SetNextPrimaryFire( self:GetPowerupTime() )
	self.Weapon:SetNextSecondaryFire( self:GetPowerupTime() )
	self.Weapon:SetNextIdle( self:GetPowerupTime() )
end

--[[---------------------------------------------------------
	Called when the startup is finished.
-----------------------------------------------------------]]
function SWEP:FinishStartup()

	self.Weapon:SetPowerupTime( 0 )
	self.Weapon:SetPullbackSoundTime( 0 )
end

--[[---------------------------------------------------------
	Called every frame to update the startup.
-----------------------------------------------------------]]
function SWEP:UpdateStartup()

	-- Play pullback sound.
	if self.Weapon:GetPullbackSoundTime() != 0 && self.Weapon:GetPullbackSoundTime() <= CurTime() then
		self.Weapon:EmitSound( self.PullbackSound )
		self.Weapon:SetPullbackSoundTime( 0 )
	end
	
	if self:GetPowerupTime() > CurTime() then return end
	
	self:FinishStartup()
	
	self:StartEngine()

end

--[[---------------------------------------------------------
	Start the chainsaw's engine.
-----------------------------------------------------------]]
function SWEP:StartEngine()

	self.Weapon:EmitSound( self.EngineStartSound )
	
	self.Weapon:SetNextAttackTime( 0 )
	self.Weapon:SetNextAmmoDrainTime( CurTime() ) -- Start using ammo as soon as possible.
	self.Weapon:SetEngineOn( true )
	
	self:SetNextPrimaryFire( CurTime() + 0.25 )
	self:SetNextSecondaryFire( CurTime() + 0.25 )
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
end

--[[---------------------------------------------------------
	Shutdown the chainsaw's engine.
-----------------------------------------------------------]]
function SWEP:ShutdownEngine()

	self:StopLoopingSounds()

	self.Weapon:EmitSound( self.EngineShutdownSound )

	self.Weapon:SetNextAttackTime( 0 )
	self.Weapon:SetNextAmmoDrainTime( 0 )
	self.Weapon:SetLastFireTime( 0 )
	self.Weapon:SetEngineOn( false )
	
	self:SetNextPrimaryFire( CurTime() + 0.5 )
	self:SetNextSecondaryFire( CurTime() + 0.5 )
	self.Weapon:SetNextIdle( CurTime() )
	
end

--[[---------------------------------------------------------
	Either start or shutdown the chainsaw's engine.
-----------------------------------------------------------]]
function SWEP:ToggleEngine()
	if !self:IsEngineOn() then
		self:Pullback()
	else
		self:ShutdownEngine()
	end
end

--[[---------------------------------------------------------
	Return the secondary attack activity.
	
	@return The activity to use for secondary attack.
-----------------------------------------------------------]]
function SWEP:GetPrimaryAttackActivity() return ACT_VM_SECONDARYATTACK end

--[[---------------------------------------------------------
	Perform the same task as @SendWeaponAnim, but only
	resets the animation if finished.
	
	@param activity Activity to play.
-----------------------------------------------------------]]
function SWEP:SendWeaponAnimRepeat( activity )
	if self:GetActivity() != activity || self:IsViewModelSequenceFinished() then
		self:SendWeaponAnim( activity )
	end
end

--[[---------------------------------------------------------
	Obtain the tip position and angles, relative to the
	owner's shoot position.
	
	@param position Output resulting position.
	@param angles Output resulting angles.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:GetTipPositionAndAngles( position, angles )

	local vm = self.Owner:GetViewModel()
	if !vm then return false end

	assert( isvector( position ) )
	assert( isangle( angles ) )
	
--[[ 	Buggy!! --]]
	--local attach = vm:GetAttachment( 1 )
	--if !attach then return false end
--]]

	local pos = self.Owner:GetShootPos()
	local ang = self.Owner:EyeAngles()
	
	pos = pos + ang:Forward() * 32 + ang:Right() * 2 - ang:Up() * 6
	
	-- debugoverlay.Box( pos, Vector(-4,-4,-4), Vector(4, 4, 4), 0.02, Color( 255, 255, 0, 1 ) )
	
	angles.p 	= ang.p
	angles.y 	= ang.y
	angles.r 	= ang.r
	
	position.x 	= pos.x
	position.y  = pos.y
	position.z  = pos.z
	
	return true
end

--[[---------------------------------------------------------
	Obtain the tip position and vectors, relative to the
	owner's shoot position.
	
	@param position Output resulting position.
	@param forward Output forward directional vector.
	@param right Output right directional vector.
	@param up Output up directional vector.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:GetTipPositionAndVectors( position, forward, right, up )

	local angles = Angle() 
	if !self:GetTipPositionAndAngles( position, angles ) then return false end
	
	local f, r, u = angles:Forward(), angles:Right(), angles:Up()
	
	forward.x = f.x; forward.y = f.y; forward.z = f.z;
	right.x	  = r.x; right.y   = r.y; right.z 	= r.z;
	up.x 	  = u.x; up.y 	   = u.y; up.z 		= u.z;
	
	return true
end

--[[---------------------------------------------------------
	Inflict damage to an entity.
	
	@param tr Trace result.
	@param victim Entity to apply damage to.
	@param damage Amount of damage to inflict.
	@param damageType Type of damage to inflict.
-----------------------------------------------------------]]
function SWEP:InflictDamage( tr, victim, damage, damageType )

	local dmginfo = DamageInfo()
	dmginfo:SetInflictor( self )
	dmginfo:SetAttacker( self.Owner )
	dmginfo:SetDamage( damage )
	dmginfo:SetDamagePosition( tr.HitPos )
	dmginfo:SetDamageType( damageType )
	
	victim:DispatchTraceAttack( dmginfo, tr )
	
end

--[[---------------------------------------------------------
	Start chainsaw swing attack.
	
	@param EngineOn Engine state, either true or false.
-----------------------------------------------------------]]
function SWEP:AttackSwing( EngineOn )
	local owner = self.Owner
	if !IsValid( owner ) then return end
	
	self:SendWeaponAnim( self:GetPrimaryAttackActivity() )
	
	if EngineOn then
		self.Weapon:EmitSound( self.SwingSound )
		
		self.Weapon:SetInAttack( 1 )
		self.Weapon:SetSwingAttackTime( CurTime() + self:ViewModelSequenceDuration() )
	else
		self.Weapon:EmitSound( self.SwingOffSound )
	end
	
	self.Weapon:SetNextPrimaryFire( CurTime() + self:ViewModelSequenceDuration() )
	self.Weapon:SetNextSecondaryFire( CurTime() + self:ViewModelSequenceDuration() )
	self.Weapon:SetNextIdle( CurTime() + self:ViewModelSequenceDuration() )
end

--[[---------------------------------------------------------
	Reset chainsaw swing variables.
-----------------------------------------------------------]]
function SWEP:ResetAttackSwing()

	self.Weapon:SetInAttack( 0 )
	self.Weapon:SetSwingAttackTime( 0 )
	self.Weapon:SetNextIdle( CurTime() )
end

--[[---------------------------------------------------------
	Called every frame to update the swing attack.
	
	PRECONDITION: The chainsaw engine must be on.
-----------------------------------------------------------]]
function SWEP:UpdateAttackSwing()

	assert( self:IsEngineOn() )

	if self.Weapon:GetNextAttackTime() > CurTime() then return end
	
	self.Weapon:SetNextAttackTime( CurTime() + self.AttackRate )

	local position, forward, right, up = Vector(), Vector(), Vector(), Vector()
	
	if !self:GetTipPositionAndVectors( position, forward, right, up ) then
		--print( Format( '%s:UpdateAttackSwing: Unable to get tip attachment. Returning...', self:GetClass() ) )
		return
	end

	local pHurt = self:ChainsawTraceHullAttack( position, self.TraceDistance, Vector( -32, -32, -32 ), Vector( 32, 32, 32 ), chainsaw_damage_swing:GetFloat(), DMG_SLASH )

	if IsValid( pHurt ) then
	
	end
	
end

--[[---------------------------------------------------------
	Check if the owner is facing the entity.
	
	@param entity Entity to test dot product against with.
	
	@return true if entity is in view field.
	@return false if entity is not in view field.
-----------------------------------------------------------]]
function SWEP:IsOwnerFacingEntity( entity )
	
	local eyeDir2D, entityDir2D
		
	eyeDir2D = self.Owner:EyeAngles():Forward()
	eyeDir2D.z = 0; eyeDir2D:Normalize()
	
	entityDir2D = entity:GetPos() - self.Owner:GetPos()
	entityDir2D.z = 0; entityDir2D:Normalize()
	
	local dot = eyeDir2D:Dot( entityDir2D )

	return dot > self.FacingDotMin
end

--[[---------------------------------------------------------
	Perform a trace attack and apply damage to any touched
	entity.
	
	@param vecSrc The position to trace from.
	@param distance The trace length.
	@param mins Minimum trace volume.
	@param mins Maximum trace volume.
	@param damage Amount of damage to apply.
	@param damageType Type of damage to apply.
	
	@return Entity that was hit.
	@return Trace result structure.
-----------------------------------------------------------]]
function SWEP:ChainsawTraceHullAttack( vecSrc, distance, mins, maxs, damage, damageType )

	vecSrc		= vecSrc		or self.Owner:GetShootPos()
	distance	= distance		or 0
	mins 		= mins 			or Vector( -2, -2, -1 )
	maxs 		= maxs 			or Vector( 2, 2, 1 )
	damage 		= damage 		or 0
	damageType 	= damageType 	or DMG_SLASH

	local angles 	= self.Owner:EyeAngles()
	local forward  	= angles:Forward()
	local vecEnd	= vecSrc + forward * distance

	local tr = util.TraceLine({
		start = vecSrc,
		endpos = vecEnd,
		filter = {self, self.Owner},
		mask = MASK_SHOT_HULL
	})
	
	if tr.Fraction >= 1.0 then

		tr = util.TraceHull({
			start = vecSrc,
			endpos = vecEnd,
			mins = mins,
			maxs = maxs,	
			filter = {self, self.Owner},
			mask = MASK_SHOT_HULL
		})
		if tr.Fraction < 1.0 then
			-- Calculate the point of intersection of the line (or hull) and the object we hit
			-- This is and approximation of the "best" intersection
			if !tr.Hit || tr.HitWorld then
				tr = FindHullIntersection( vecSrc, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, { self, self.Owner } )
			end	
			vecEnd = tr.HitPos -- This is the point on the actual surface (the hull could have hit space)
		end
	end

	if IsValid( tr.Entity ) && self:IsOwnerFacingEntity( tr.Entity ) then
		self:InflictDamage( tr, tr.Entity, damage, damageType )
	end
	
	return tr.Entity, tr
end

--[[---------------------------------------------------------
	Punch the player's angles.
-----------------------------------------------------------]]
function SWEP:AddViewKick()

	local owner = self.Owner
	if !IsValid( owner ) then return end
	
	owner:ViewPunch( Angle( RandomFloat( -2, 2 ), RandomFloat( -2, 2 ), 0 ) )
end

--[[---------------------------------------------------------
	Called when the chainsaw hit a non living entity.
	
	@param tr Trace result.
-----------------------------------------------------------]]
function SWEP:OnHitNonLiving( tr )

	self:AddViewKick()

	UTIL_ImpactEffect( tr.HitPos, tr )

	if self.Weapon:GetNextPrimaryFire() <= CurTime() && self.Weapon:GetNextSecondaryFire() <= CurTime() then
		self:SendWeaponAnimRepeat( ACT_VM_PRIMARYATTACK_1 )
	end
	
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
end

--[[---------------------------------------------------------
	Called when the chainsaw hit a living entity.
	
	@param tr Trace result.
	@param entity Hit entity.
-----------------------------------------------------------]]
function SWEP:OnHitLiving( tr, entity )

	if self.Weapon:GetNextPrimaryFire() <= CurTime() && self.Weapon:GetNextSecondaryFire() <= CurTime() then
		self:SendWeaponAnimRepeat( ACT_VM_PRIMARYATTACK_2 )
	end
	
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
end

--[[---------------------------------------------------------
	Called every frame to make additional impact effect.
	
	@param materialName Name of the surface material.
-----------------------------------------------------------]]
function SWEP:DoSurfaceImpactEffect( materialName )

	if surfaceName == 'metal' then
		UTIL_Sparks( tr.HitPos, tr )	
	end
end

--[[---------------------------------------------------------
	Called every frame to update the viewpunch caused by
	the chainsaw engine.
-----------------------------------------------------------]]
function SWEP:UpdateIdleViewPunch()

	if self.Weapon:GetNextViewPunchTime() > CurTime() then return end

	self.Weapon:SetNextViewPunchTime( CurTime() +  0.1 )
	
	local owner = self.Owner
	if !IsValid( owner ) then return end
	
	owner:ViewPunch( Angle( RandomFloat( -0.1, 0.1 ), RandomFloat( -0.1, 0.1 ), 0 ) )

end

--[[---------------------------------------------------------
	Called every frame to check if the chainsaw is hitting
	an entity.
-----------------------------------------------------------]]
function SWEP:IdleCastRadialDamage()

	if self.Weapon:GetNextAttackTime() > CurTime() then return end
	
	self.Weapon:SetNextAttackTime( CurTime() + self.AttackRate )

	local position, forward, right, up = Vector(), Vector(), Vector(), Vector()
	
	if !self:GetTipPositionAndVectors( position, forward, right, up ) then
		--print( Format( '%s:UpdateAttackSwing: Unable to get tip attachment. Returning...', self:GetClass() ) )
		return
	end

	local pHurt, tr = self:ChainsawTraceHullAttack( position, self.TraceDistance, self.TraceHullMins, self.TraceHullMaxs, chainsaw_damage_idle:GetFloat(), DMG_SLASH )

	if tr.Hit then
	
		local surfaceName = util.GetSurfacePropName( tr.SurfaceProps )

		self:DoSurfaceImpactEffect( surfaceName )
		
		if pHurt:IsWorld() || IsProp( pHurt ) then
			self:OnHitNonLiving( tr )	
		else
			self:OnHitLiving( tr, pHurt )
		end
	end

end

--[[---------------------------------------------------------
	Called every frame to check the ammo consumption.
-----------------------------------------------------------]]
function SWEP:UpdateGasConsumption()

	if self.Weapon:GetNextAmmoDrainTime() > CurTime() then return end
	
	self.Weapon:SetNextAmmoDrainTime( CurTime() + self.AmmoDrainRate )
	
	self:TakePrimaryAmmo( 1, self.Weapon:GetPrimaryAmmoType() )
end

--[[---------------------------------------------------------
	Check if the chainsaw can still be active.
	
	@return true to keep the chainsaw engine active.
	@return false to shutdown the chainsaw engine.
-----------------------------------------------------------]]
function SWEP:CheckChainsawCanRunAgain()

	if self:Ammo1() <= 0 then
		return false end

	return true
end

--[[---------------------------------------------------------
	Called every frame to update the attack sound.
-----------------------------------------------------------]]
function SWEP:UpdateAttackSound()

	if self.Weapon:GetNextAttackSoundTime() > CurTime() then return end
	
	self.Weapon:SetNextAttackSoundTime( CurTime() + SoundDuration( self.AttackSound ) )

	self.Weapon:EmitSound( self.AttackSound )
end

--[[---------------------------------------------------------
	Called every frame to update the engine sound.
-----------------------------------------------------------]]
function SWEP:UpdateEngineSound()

	if self.Weapon:GetNextEngineSoundTime() > CurTime() then return end
	
	self.Weapon:SetNextEngineSoundTime( CurTime() + SoundDuration( self.EngineRunSound ) )

	self.Weapon:EmitSound( self.EngineRunSound )
end

--[[---------------------------------------------------------
	Stop all weapons sounds.
-----------------------------------------------------------]]
function SWEP:StopLoopingSounds()

	self.Weapon:StopSound( self.AttackSound )
	self.Weapon:StopSound( self.EngineRunSound )
end

--[[---------------------------------------------------------
	Called every frame to update the chainsaw.
	
	@param EngineOn Engine state, either true or false.
-----------------------------------------------------------]]
function SWEP:UpdateChainsaw( EngineOn )

	-- Play pullback sound.
	if self.Weapon:GetPullbackSoundTime() != 0 && self.Weapon:GetPullbackSoundTime() <= CurTime() then
		self.Weapon:EmitSound( self.PullbackSound )
		self.Weapon:SetPullbackSoundTime( 0 )
	end

	if EngineOn then

		local position, forward, right, up = Vector(), Vector(), Vector(), Vector()
	
		if !self:GetTipPositionAndVectors( position, forward, right, up ) then return end
		
		if !self:CheckChainsawCanRunAgain() then
			self:ToggleEngine()
		else
			if self:IsInSwingAttack() then
				if self.Weapon:GetSwingAttackTime() > CurTime() then
					self:UpdateAttackSwing()
				else
					self:ResetAttackSwing()
				end
			else
				self:UpdateIdleViewPunch()
			
				self:IdleCastRadialDamage()
			end
			
			self:UpdateGasConsumption()
	
			self:UpdateEngineSound()
		end
		
	elseif self:IsStartingUp() then
		self:UpdateStartup()
	end
end
