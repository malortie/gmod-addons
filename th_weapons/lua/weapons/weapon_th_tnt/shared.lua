-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base			= 'weapon_th_base'
SWEP.PrintName		= "TNT"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= '+attack: Toss grenade.'
SWEP.Category		= 'They Hunger'

SWEP.ViewModelFOV	= 90
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/th/v_tnt/v_tnt.mdl"
SWEP.WorldModel		= "models/th/w_tnt/w_tnt.mdl"

SWEP.Spawnable			= true
SWEP.AdminOnly			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= AMMO_CLASS_TH_TNT

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )

	self.Weapon:SetStartThrow( 0 )
	self.Weapon:SetReleaseThrow( -1 )
	
	self:SetHoldType( 'grenade' )
end

--[[---------------------------------------------------------
	Called when player has just switched to this weapon.
	
	@return true to allow switching away from this weapon 
			using lastinv command.
-----------------------------------------------------------]]
function SWEP:Deploy()
	self.Weapon:SetReleaseThrow( -1 )
	return BaseClass.Deploy( self )
end

--[[---------------------------------------------------------
	Check if this weapon can be holstered.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanHolster()
	return self.Weapon:GetStartThrow() == 0
end

--[[---------------------------------------------------------
	Called when weapon tries to holster.
	
	@param wep The weapon we are trying switch to.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:Holster()

	if !self:CanHolster() then return false end
	
	if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		-- no more grenades!	
		self:RetireWeapon()
	end
	
	return BaseClass.Holster( self )
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

	return true
end

--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return false end

	if ( self.Weapon:GetStartThrow() == 0 && self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 ) then
	
		self.Weapon:SetStartThrow( CurTime() )
		self.Weapon:SetReleaseThrow( 0 )

		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Weapon:SetNextIdle( CurTime() + 0.5 )
	end
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function SWEP:Think()
	local owner = self.Owner
	if !IsValid( owner ) then return end
	
	if self.Weapon:GetStartThrow() != 0 then
		if !owner:KeyDown( IN_ATTACK ) then
			self:WeaponIdle()
		end
	else
		self:WeaponIdle()
	end
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()

	if ( self.Weapon:GetReleaseThrow() == 0 && self.Weapon:GetStartThrow() > 0 ) then
		self.Weapon:SetReleaseThrow( CurTime() )
	end
	
	if self.Weapon:GetNextIdle() > CurTime() then return end

	if self.Weapon:GetStartThrow() != 0 then
		
		local angThrow = self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles()

		if angThrow.p < 0 then
			angThrow.p = -10 + angThrow.p * ( ( 90 - 10 ) / 90.0 )
		else
			angThrow.p = -10 + angThrow.p * ( ( 90 + 10 ) / 90.0 )
		end	

		local flVel = ( 90 - angThrow.p ) * 4
		if flVel > 500 then
			flVel = 500 end
			
		local forward = angThrow:Forward()
		
		local vecSrc = self.Owner:GetShootPos() + forward * 16

		local vecThrow = forward * flVel + self.Owner:GetVelocity()

		-- alway explode 3 seconds after the pin was pulled
		local flTime = self.Weapon:GetStartThrow() - CurTime() + 3.0
		if flTime < 0 then
			flTime = 0 end
			
if ( SERVER ) then	
		GrenadeUtils.ShootTimedTNT( self.Owner, vecSrc, vecThrow, flTime )
end -- end ( SERVER )		
		
		local vm = self.Owner:GetViewModel()
		if flVel < 500 then
			vm:SendViewModelMatchingSequence(self:LookupSequence('throw1'))
		elseif flVel < 1000 then
			vm:SendViewModelMatchingSequence(self:LookupSequence('throw2'))
		else
			vm:SendViewModelMatchingSequence(self:LookupSequence('throw3'))
		end

		-- player "shoot" animation
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
		self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )

		--self.Weapon:SetReleaseThrow(0)
		self.Weapon:SetReleaseThrow(1)
		self.Weapon:SetStartThrow(0)
		
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self.Weapon:SetNextIdle( CurTime() + 0.5 )
		
		self.Owner:RemoveAmmo( 1, self:GetPrimaryAmmoType() )

		if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
			--[[
				just threw last grenade
				set attack times in the future, and weapon idle in the future so we can see the whole throw
				animation, weapon idle will automatically retire the weapon for us.
			--]]
			self:SetNextPrimaryFire( CurTime() + 0.5 ) -- ensure that the animation can finish playing
			self:SetNextSecondaryFire( CurTime() + 0.5 )
			self.Weapon:SetNextIdle( CurTime() + 0.5 )
		end
		return
		
	elseif self.Weapon:GetReleaseThrow() > 0 then
		-- we've finished the throw, restart.
		self.Weapon:SetStartThrow(0)

		if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 then
			self:SendWeaponAnim( ACT_VM_DRAW )
		else
if ( SERVER ) then
			self.Owner:StripWeapon( self:GetClass() )
end -- end ( SERVER )			
			return
		end

		self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
		self.Weapon:SetReleaseThrow( -1 )
		return
	end

	if ( self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 ) then

		local seq
		local flRand = RandomFloat( 0, 1 )
	
		if flRand <= 0.75 then
			seq = self:LookupSequence('idle')
			self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) ) -- // how long till we do this again.
		else
			seq = self:LookupSequence('fidget')
			self.Weapon:SetNextIdle( CurTime() + 75.0 / 30.0 )
		end
		
		local vm = self.Owner:GetViewModel()
		vm:SendViewModelMatchingSequence(seq)
	end
	
end

