-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base = 'weapon_th_base'
SWEP.PrintName = 'Spanner'
SWEP.Author = 'Marc-Antoine (malortie) Lortie'
SWEP.Contact = ''
SWEP.Purpose = ''
SWEP.Instructions = '+attack: Swing.'
SWEP.Category = 'They Hunger'

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.ViewModel		= "models/th/v_tfc_spanner/v_tfc_spanner.mdl"
SWEP.WorldModel		= "models/th/backpack/backpack.mdl"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = 'none'

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = 'none'

SWEP.MissFireRate	= 0.38
SWEP.HitFireRate	= 0.2

-- The sound to play when missing a target.
SWEP.MissSound 		= 'weapon_th_spanner.single'

-- The sound to play when hitting a living entity. .i.e: player; npc.
SWEP.HitSound 		= 'weapon_th_spanner.melee_hit'

-- The sound to play when hitting a non living entity. .i.e: world
SWEP.HitWorldSound 	= 'weapon_th_spanner.melee_hitworld'

-- Miss sequences.
SWEP.MissSequences = {
	'attack1',
	'attack2',
}

-- Hit sequences.
SWEP.HitSequences = {
	'attack1',
	'attack2',
}

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local spanner_damage = GetConVar( 'sk_th_plr_dmg_spanner' ) or CreateConVar( 'sk_th_plr_dmg_spanner', '7' )	

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()

	BaseClass.SetupDataTables( self )

	self.Weapon:NetworkVar( 'Float', 3, 'DecalTime' )
	self.Weapon:NetworkVar( 'Vector', 0, 'HitPos' )
	self.Weapon:NetworkVar( 'Vector', 1, 'HitNormal' )
	self.Weapon:NetworkVar( 'Int', 3, 'SwingCount' )
end

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )

	self.Weapon:SetDecalTime( 0 )
	self.Weapon:SetHitPos( vector_origin )
	self.Weapon:SetHitNormal( vector_origin )
	self.Weapon:SetSwingCount( 0 )
	
	self:SetHoldType( "melee" )
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

	self.Owner:LagCompensation( true )

	self:Swing()
	
	self.Owner:LagCompensation( false )
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function SWEP:Think()

	if self.Weapon:GetDecalTime() != 0 && self.Weapon:GetDecalTime() <= CurTime() then
		self:Smack()
		self.Weapon:SetDecalTime( 0 )
	end
	
	BaseClass.Think( self )
end

--[[---------------------------------------------------------
	Called after hitting a target.
-----------------------------------------------------------]]
function SWEP:Smack()
	self:DoImpactDecal( self.Weapon:GetHitPos() + self.Weapon:GetHitNormal(), 
						self.Weapon:GetHitPos() - self.Weapon:GetHitNormal() )
end

--[[---------------------------------------------------------
	Perform a melee attack swing.
	
	Attempt to calculate the intersection point, apply
	damage to the hit entity (if any), play appropriate
	sounds (if any).
-----------------------------------------------------------]]
function SWEP:Swing()
	local fDidHit = false

	local angles = self.Owner:EyeAngles()
	local forward = angles:Forward()
	local vecSrc	= self.Owner:GetShootPos()
	local vecEnd	= vecSrc + forward * 32

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
			mins = Vector(-16,-16,-16),
			maxs = Vector(16, 16, 16),	
			filter = {self, self.Owner},
			mask = MASK_SHOT_HULL
		})
		if tr.Fraction < 1.0 then
			-- Calculate the point of intersection of the line (or hull) and the object we hit
			-- This is and approximation of the "best" intersection
			if !tr.Hit || tr.HitWorld then
				tr = FindHullIntersection( vecSrc, tr, VEC_DUCK_HULL_MIN, VEC_DUCK_HULL_MAX, self.Owner )
			end	
			vecEnd = tr.HitPos -- This is the point on the actual surface (the hull could have hit space)
		end
	end

	if tr.Fraction >= 1.0 then
	
		self.Weapon:EmitSound( self.MissSound )
	
		local swing = RandomInt( 1, #self.MissSequences )
		local seq = self:LookupSequence( self.MissSequences[ swing ] )
	
		self:SetSwingCount( self:GetSwingCount() + 1 )
	
		if seq != -1 then
			local vm = self.Owner:GetViewModel()
			vm:SendViewModelMatchingSequence( seq )
		end	
		
		-- miss
		self:SetNextPrimaryFire( CurTime() + self.MissFireRate )
		
		-- player "shoot" animation
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
		self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )
	else

		local swing = ( self:GetSwingCount() % #self.HitSequences )
		local seq = self:LookupSequence( self.HitSequences[ swing + 1 ] )
		
		self:SetSwingCount( self:GetSwingCount() + 1 )
	
		if seq != -1 then
			local vm = self.Owner:GetViewModel()
			vm:SendViewModelMatchingSequence( seq )
		end

		-- player "shoot" animation
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
			
		self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )

		--hit
		fDidHit = true
		local pEntity = tr.Entity 

		-- ClearMultiDamage( );
		
		local dmgInfo = DamageInfo()
		dmgInfo:SetInflictor( self )
		dmgInfo:SetAttacker( self.Owner )
		dmgInfo:SetDamage( spanner_damage:GetFloat() )
		dmgInfo:SetDamagePosition( tr.HitPos )
		dmgInfo:SetDamageForce( self.Owner:EyeAngles():Forward() )
		dmgInfo:SetDamageType( DMG_CLUB )

		if ( ( self:GetNextPrimaryFire() + 1 < CurTime() ) || !game.SinglePlayer() ) then
			-- first swing does full damage
			pEntity:DispatchTraceAttack( dmgInfo, tr )
		else
			-- subsequent swings do half
			dmgInfo:ScaleDamage( 0.5 )
			pEntity:DispatchTraceAttack( dmgInfo, tr )
		end
		-- ApplyMultiDamage( m_pPlayer->pev, m_pPlayer->pev );

		-- play thwack, smack, or dong sound
		local flVol = 1.0;
		local fHitWorld = true;

		if pEntity && !pEntity:IsWorld() then
			-- if ( pEntity->Classify() != CLASS_NONE && pEntity->Classify() != CLASS_MACHINE ) then

				-- play thwack or smack sound
				self.Weapon:EmitSound( self.HitSound )
				
				-- m_pPlayer->m_iWeaponVolume = CROWBAR_BODYHIT_VOLUME;
				if pEntity:Health() <= 0 then
					self:SetNextPrimaryFire( CurTime() + self.HitFireRate )
					return true
				else
					flVol = 0.1
				end  

				fHitWorld = false
			-- end
		end

		-- play texture hit sound
		-- UNDONE: Calculate the correct point of intersection when we hit with the hull instead of the line

		if fHitWorld then
			--float fvolbar = TEXTURETYPE_PlaySound(&tr, vecSrc, vecSrc + (vecEnd-vecSrc)*2, BULLET_PLAYER_CROWBAR);
			local fvolbar
			
			if !game.SinglePlayer() then
				-- override the volume here, cause we don't play texture sounds in multiplayer, 
				-- and fvolbar is going to be 0 from the above call.

				fvolbar = 1
			end

			-- also play crowbar strike
			self.Weapon:EmitSound( self.HitWorldSound )

			-- delay the decal a bit
			self.Weapon:SetHitPos( tr.HitPos )
			self.Weapon:SetHitNormal( tr.HitNormal )
		end

		self:SetNextPrimaryFire( CurTime() + self.HitFireRate )
		self.Weapon:SetDecalTime( CurTime() + 0.2 )
		
		self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
	end
	return fDidHit
end