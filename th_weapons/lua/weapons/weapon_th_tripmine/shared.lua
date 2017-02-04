-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base			= 'weapon_th_base'
SWEP.PrintName		= "Tripmine"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= '+attack: Place tripmine.'
SWEP.Category		= 'They Hunger'

SWEP.ViewModelFOV	= 90
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/th/v_tripmine/v_tripmine.mdl"
SWEP.WorldModel		= "models/w_tripmine.mdl"

SWEP.Spawnable			= false
SWEP.AdminOnly			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= AMMO_CLASS_HL1_TRIPMINE

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.m_WeaponDeploySpeed = 1.0

SWEP.GrenadeClassName = 'ent_th_tripmine'

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()
	
	BaseClass.Initialize( self )
	
	self:SetHoldType( 'slam' )
end

--[[---------------------------------------------------------
	Called when weapon tries to holster.
	
	@param wep The weapon we are trying switch to.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:Holster()

	if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		-- out of mines
		self.Weapon:RetireWeapon()
	end

	return true
end

--[[---------------------------------------------------------
	Check if the weapon can do a primary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()

	if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		return false
	end

	if self.Owner:WaterLevel() == 3 then
		self:PlayEmptySound()
		seff:SetNextPrimaryFire( CurTime() + self.Primary.FireRate )
		return false
	end
	
	return true
end

--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return end
	
	local angles = self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles()
	local vecSrc = self.Owner:GetShootPos()
	local vecAiming = angles:Forward()
	
	local tr = util.TraceLine({
		start = vecSrc,
		endpos = vecSrc + vecAiming * 128,
		filter = {self, self.Owner},
		mask = MASK_SHOT_HULL
	})
	
	if tr.Fraction < 1.0 then

		-- if ( tr.Entity && bit.band( tr.Entity:GetFlags(), FL_CONVEYOR ) == 0 ) then
		if ( tr.Entity && bit.band( tr.Entity:GetFlags(), FL_CONVEYOR ) == 0 && !tr.HitSky ) then
		
if ( SERVER ) then
			local angles = tr.HitNormal:Angle()
			
			local pEnt = ents.Create( self.GrenadeClassName )
			if IsValid( pEnt ) then
			
				pEnt:SetPos( tr.HitPos + tr.HitNormal * 8 )
				pEnt:SetAngles( angles )
				pEnt:SetOwner( self.Owner )
				pEnt:Spawn()
				pEnt:Activate()
			end
		
end	-- end ( SERVER )	

			self:TakePrimaryAmmo( 1 )
			
			self:SendWeaponAnim( ACT_VM_DRAW )
			
			-- player "shoot" animation
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )
			
			if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
				-- no more mines! 
				self.Weapon:RetireWeapon()		
				return
			end
		else
			-- print("no deploy\n" );
		end
	else

	end
	
	self:SetNextPrimaryFire( CurTime() + 0.3 )
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
end

--[[---------------------------------------------------------
	Check if the weapon can do a secondary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack() return false end

--[[---------------------------------------------------------
	Secondary weapon attack.
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()

	if !self:CanIdle() then return end
	
	if ( self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 ) then
		self:SendWeaponAnim( ACT_VM_DRAW )
	else
		self.Weapon:RetireWeapon()
		return
	end

	local seq
	local flRand = RandomFloat( 0.0, 1.0 )

	if (flRand <= 0.25) then
		seq = self:LookupSequence( 'idle1' )
		self.Weapon:SetNextIdle( CurTime() + 90.0 / 30.0 )
	elseif (flRand <= 0.75) then
		seq = self:LookupSequence( 'idle2' )
		self.Weapon:SetNextIdle( CurTime() + 60.0 / 30.0 )
	else
		seq = self:LookupSequence( 'fidget' )
		self.Weapon:SetNextIdle( CurTime() + 100.0 / 30.0 )
	end
	
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( seq )
end