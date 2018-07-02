-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base = 'weapon_th_base'
SWEP.PrintName = 'Chaingun'
SWEP.Author = 'Marc-Antoine (malortie) Lortie'
SWEP.Contact = ''
SWEP.Purpose = ''
SWEP.Instructions	= '+attack: Fire.\n+reload: Reload.'
SWEP.Category = 'They Hunger'
SWEP.Slot			= 3
SWEP.SlotPos			= 4

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.ViewModel = 'models/th/v_tfac/v_tfac.mdl'
SWEP.WorldModel = 'models/th/w_tfac/w_tfac.mdl'
SWEP.PModel = 'models/th/p_mini2/p_mini2.mdl'

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = AMMO_CLASS_HL1_9MM
SWEP.Primary.FireRate = 0.1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = 'none'

-- The rate at which to decrement ammunition when
-- the player is firing.
SWEP.AmmoDrainRate = 0.1

-- The sound to play when shooting.
SWEP.ShootSound 	= 'weapon_th_chaingun.single'

-- The sound to play when reloading.
SWEP.ReloadSound	= 'weapon_th_chaingun.reload'

-- The Chaingun cannon's spin down sound.
SWEP.SpindownSound 	= 'weapon_th_chaingun.spindown'

-- The Chaingun cannon's spin up sound.
SWEP.SpinupSound 	= 'weapon_th_chaingun.spinup'

-- The Chaingun cannon's spin sound.
SWEP.SpinSound 		= 'weapon_th_chaingun.spin'

-- The speed factor to use when the player is firing.
SWEP.OwnerSpeedScale = 0.25

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local chaingun_damage = GetConVar( 'sk_th_plr_dmg_9mm_bullet' ) or CreateConVar( 'sk_th_plr_dmg_9mm_bullet', '8' )	

-- Attack states.
local AttackStates = {
	None = 0,		-- Chaingun cannon is at rest.
	Spinup = 1,		-- Chaingun cannon is spinning up.
	Spin = 2,		-- Chaingun cannon is spinning.
	Spindown = 3	-- Chaingun cannon is spinning down.
}

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()

	BaseClass.SetupDataTables( self )

	self.Weapon:NetworkVar( 'Float', 3, 'NextAmmoDrain' )
	self.Weapon:NetworkVar( 'Float', 4, 'NextSpinSound' )
	self.Weapon:NetworkVar( 'Float', 5, 'OriginalOwnerRunSpeed' )
	self.Weapon:NetworkVar( 'Float', 6, 'OriginalOwnerWalkSpeed' )
end

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )

	self.Weapon:SetNextAmmoDrain( 0 )
	self.Weapon:SetNextSpinSound( 0 )
	self.Weapon:SetOriginalOwnerRunSpeed( -1 )
	self.Weapon:SetOriginalOwnerWalkSpeed( -1 )
	
	self.Weapon:SetMuzzleFlashType( MUZZLEFLASH_TH_CHAINGUN )
	self.Weapon:SetMuzzleFlashScale( 1.5 )
	
	self:SetHoldType( 'shotgun' )
end

--[[---------------------------------------------------------
	Called when weapon tries to holster.
	
	@param wep The weapon we are trying switch to.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:Holster( wep )
	
	self.Weapon:SetInSpecialReload( 0 )
	
	self:ResetWeaponStates()
	
	self:StopLoopingSounds()
	
	return BaseClass.Holster( self, wep )
end

--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()
	
	if !self:CanPrimaryAttack() then
		self:Spindown()
		return
	end

	if self:CannonIsAtRest() then
		self:Spinup()
	elseif self:CannonHasSpinUp() or self:CannonIsSpinning() then
		self:Spin()
	end
end

--[[---------------------------------------------------------
	Check if the weapon can do a secondary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack() return false end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function SWEP:Think()

	BaseClass.Think( self )

	self:UpdateWeaponCannon()
end

--[[---------------------------------------------------------
	Called when the reload key is pressed.
-----------------------------------------------------------]]
function SWEP:Reload()

	if self:Clip1() == self:GetMaxClip1() or self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		return
	end
	
	-- don't reload until recoil is done
	if self:GetNextPrimaryFire() > CurTime() then
		return end
	
	-- check to see if we're ready to reload
	if self.Weapon:GetInSpecialReload() == 0 then

		self:ResetWeaponStates()

		self:StopLoopingSounds()
	
		self.Weapon:SetInSpecialReload(1)
		
		self:SendWeaponAnim( ACT_VM_HOLSTER )
	
		self.Weapon:SetNextIdle( CurTime() + self:ViewModelSequenceDuration() )
		self:SetNextPrimaryFire(CurTime() + self:ViewModelSequenceDuration())
		self:SetNextSecondaryFire(CurTime() + self:ViewModelSequenceDuration())
		return;
	elseif self.Weapon:GetInSpecialReload() == 1 then
		if self.Weapon:GetNextIdle() > CurTime() then return end

		self.Weapon:SetInSpecialReload(2)

		self.Weapon:EmitSound( self.ReloadSound )
		
		self.Weapon:SetNextIdle( CurTime() + 0.7 )
		self:SetNextPrimaryFire(CurTime() + 0.7)
		self:SetNextSecondaryFire(CurTime() + 0.7)
	elseif self.Weapon:GetInSpecialReload() == 2 then
		if self.Weapon:GetNextIdle() > CurTime() then return end

		-- Add them to the clip
		local j = math.min( self:GetMaxClip1() - self:Clip1(), self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) )	
			
		self:SetClip1( self:Clip1() + j )
		self.Owner:RemoveAmmo( j, self:GetPrimaryAmmoType() )
		
		self:SendWeaponAnim( ACT_VM_DRAW )
		
		self.Weapon:SetNextIdle( CurTime() + self:ViewModelSequenceDuration() )
		self:SetNextPrimaryFire(CurTime() + self:ViewModelSequenceDuration() )
		self:SetNextSecondaryFire(CurTime() + self:ViewModelSequenceDuration() )
		
		self.Weapon:SetInSpecialReload(0)
	end
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()

	if !self:CanIdle() then return end

	if ( self.Weapon:Clip1() == 0 && self.Weapon:GetInSpecialReload() == 0 && self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 ) then
		self:Reload()
	elseif self.Weapon:GetInSpecialReload() != 0 then
		self:Reload()
	else
		self:SendWeaponAnim( ACT_VM_IDLE )
		self.Weapon:SetNextIdle( CurTime() + self:ViewModelSequenceDuration() )
	end
end

--[[---------------------------------------------------------
	This method returns the shell eject offset.
	
	@return A vector reprensenting the shell eject offset.
-----------------------------------------------------------]]
function SWEP:GetShellEjectOffset()
	return Vector( 20, 8, -12 )
end

--[[---------------------------------------------------------
	Start spinning down chaingun cannon.
-----------------------------------------------------------]]
function SWEP:Spindown()

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_2 )

	self.Weapon:SetInAttack( AttackStates.Spindown )

	self:SetNextPrimaryFire( CurTime() + self:ViewModelSequenceDuration() )
	
	self.Weapon:StopSound( self.SpinSound )
	self.Weapon:StopSound( self.ShootSound )
	
	self.Weapon:EmitSound( self.SpindownSound )
	
	self:RestoreOwnerSpeed()
end

--[[---------------------------------------------------------
	Start spinning up chaingun cannon.
-----------------------------------------------------------]]
function SWEP:Spinup()

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_1 )

	self.Weapon:SetInAttack( AttackStates.Spinup )

	self:SetNextPrimaryFire( CurTime() + self:ViewModelSequenceDuration() )
	
	self.Weapon:EmitSound( self.SpinupSound )
	
	self:CheckOwnerSpeed()
	
	self:SlowOwnerDown()
end

--[[---------------------------------------------------------
	Called every frame.
	Spin chaingun cannon.
-----------------------------------------------------------]]
function SWEP:Spin()

	self:DoFire()

	if self:IsViewModelSequenceFinished() then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK_3 )
	end

	self.Weapon:SetInAttack( AttackStates.Spin )

	self.Weapon:StopSound( self.SpinupSound )
	
	if self.Weapon:GetNextSpinSound() <= CurTime() then
		self.Weapon:EmitSound( self.SpinSound )
		self.Weapon:SetNextSpinSound( CurTime() + SoundDuration( self.SpinSound ) )
	end
end

--[[---------------------------------------------------------
	Shoot a bullet.
-----------------------------------------------------------]]
function SWEP:DoFire()

	local owner = self.Owner
	if !IsValid( owner ) then return end
	
	if self.Weapon:GetNextAmmoDrain() > CurTime() then return end
	
	self.Weapon:SetNextAmmoDrain( CurTime() + self.AmmoDrainRate )
	
	-- Do a muzzleflash effect.
	self:MuzzleEffect()
	
	local bullet = {}
	bullet.Num 		= 4
	bullet.Src 		= owner:GetShootPos()
	bullet.Dir 		= owner:GetAimVector()
	bullet.Spread 	= VECTOR_CONE_10DEGREES
	bullet.Tracer	= 0
	bullet.Force	= 1
	bullet.Damage	= chaingun_damage:GetFloat()
	bullet.AmmoType = self:GetPrimaryAmmoType()
	
	owner:FireBullets( bullet )

	self:DefaultShellEject()
	
	self:TakePrimaryAmmo( 2 )
	
	owner:SetAnimation( PLAYER_ATTACK1 )
	
	owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )
	
	-- Kick the player's view angles.
	owner:ViewPunch( Angle( RandomFloat( -0.1, 0.1 ), RandomFloat( -0.1, 0.1 ), 0 ) )
	
	self.Weapon:EmitSound( self.ShootSound )
end

--[[---------------------------------------------------------
	Stop all weapons sounds.
-----------------------------------------------------------]]
function SWEP:StopLoopingSounds()

	self.Weapon:StopSound( self.ShootSound )
	self.Weapon:StopSound( self.SpindownSound )
	self.Weapon:StopSound( self.SpinSound )
	self.Weapon:StopSound( self.SpinupSound )
end

--[[---------------------------------------------------------
	Reset weapon state variables.
-----------------------------------------------------------]]
function SWEP:ResetWeaponStates()

	self.Weapon:SetInAttack( AttackStates.None )
end

--[[---------------------------------------------------------
	This method is used to either slowdown or restore
	the owner's original speed before/after firing.
-----------------------------------------------------------]]
function SWEP:CheckOwnerSpeed()

	local owner = self.Owner
	if !IsValid( owner ) then return end
	
	if self.Weapon:GetOriginalOwnerRunSpeed() == -1 then
		self.Weapon:SetOriginalOwnerRunSpeed( self.Owner:GetRunSpeed() )
	end
	
	if self.Weapon:GetOriginalOwnerWalkSpeed() == -1 then
		self.Weapon:SetOriginalOwnerWalkSpeed( self.Owner:GetWalkSpeed() )
	end
end

--[[---------------------------------------------------------
	Reduce owner's speed.
-----------------------------------------------------------]]
function SWEP:SlowOwnerDown()
	
	local owner = self.Owner
	if !IsValid( owner ) then return end
	
	local runspeed = self.Weapon:GetOriginalOwnerRunSpeed() 
	local walkspeed = self.Weapon:GetOriginalOwnerWalkSpeed() 
	
	--[[
	It is possible that the walk/run speed are different.
	
	Therefore, calculate the ratio between the two speeds and
	adjust each other in consequence.
	
	This gives the illusion of a single move speed.
	--]]
	
	local speedRadio
	
	if runspeed > walkspeed then
		speedRadio = runspeed / walkspeed
		owner:SetRunSpeed( runspeed * self.OwnerSpeedScale )
		owner:SetWalkSpeed( walkspeed * self.OwnerSpeedScale * speedRadio )
	else
		speedRadio = walkspeed / runspeed
		owner:SetRunSpeed( runspeed * self.OwnerSpeedScale * speedRadio )
		owner:SetWalkSpeed( walkspeed * self.OwnerSpeedScale )
	end
end

--[[---------------------------------------------------------
	Restore owner's speed to it's original value.
-----------------------------------------------------------]]
function SWEP:RestoreOwnerSpeed()
	
	local owner = self.Owner
	if !IsValid( owner ) then return end
	
	-- Restore original owner speed.
	owner:SetRunSpeed( self.Weapon:GetOriginalOwnerRunSpeed() )
	owner:SetWalkSpeed( self.Weapon:GetOriginalOwnerWalkSpeed() )
end

--[[---------------------------------------------------------
	Check if the cannon is at rest.
	
	@return true if the cannon is at rest.
	@return false otherwise.
-----------------------------------------------------------]]
function SWEP:CannonIsAtRest() return self.Weapon:GetInAttack() == AttackStates.None end

--[[---------------------------------------------------------
	Check if the cannon is spinning down.
	
	@return true if the cannon is spinning down.
	@return false otherwise.
-----------------------------------------------------------]]
function SWEP:CannonHasSpinDown() return self.Weapon:GetInAttack() == AttackStates.Spindown end

--[[---------------------------------------------------------
	Check if the cannon is spinning up.
	
	@return true if the cannon is spinning up.
	@return false otherwise.
-----------------------------------------------------------]]
function SWEP:CannonHasSpinUp() return self.Weapon:GetInAttack() == AttackStates.Spinup end

--[[---------------------------------------------------------
	Check if the cannon is spinning.
	
	@return true if the cannon is spinning.
	@return false otherwise.
-----------------------------------------------------------]]
function SWEP:CannonIsSpinning() return self.Weapon:GetInAttack() == AttackStates.Spin end

--[[---------------------------------------------------------
	Called every frame. Update the chaingun cannon.
-----------------------------------------------------------]]
function SWEP:UpdateWeaponCannon()

	local owner = self.Owner
	if !IsValid( owner ) then return false end
	
	if !self:CannonIsAtRest() && self:GetNextPrimaryFire() <= CurTime() then
		
		if !owner:KeyDown( IN_ATTACK ) then
			if self:CannonHasSpinUp() || self:CannonIsSpinning() then
				self:Spindown()
			end	
		end
		
		if self:CannonHasSpinDown() then
			self:ResetWeaponStates()
		end
	end	
end
