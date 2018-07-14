-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base = 'weapon_th_base'

SWEP.PrintName = 'Shotgun'
SWEP.Author = 'Marc-Antoine (malortie) Lortie'
SWEP.Contact = ''
SWEP.Purpose = ''
SWEP.Instructions	= '+attack: Fire using one barrel.\n+attack2: Fire using two barrels.\n+reload: Reload.'
SWEP.Category = 'They Hunger'
SWEP.Slot				= 2
SWEP.SlotPos			= 2

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.ViewModel = 'models/th/v_shotgun/v_shotgun.mdl'
SWEP.WorldModel = 'models/th/w_shotgun/w_shotgun.mdl'
SWEP.PModel = 'models/th/p_shotgun/p_shotgun.mdl'

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize 		= 8
SWEP.Primary.DefaultClip 	= 12
SWEP.Primary.Automatic 		= true
SWEP.Primary.Ammo 			= AMMO_CLASS_HL1_BUCKSHOT
SWEP.Primary.FireRate 		= 0.75

SWEP.Secondary.ClipSize 	= -1
SWEP.Secondary.DefaultClip 	= -1
SWEP.Secondary.Automatic 	= true
SWEP.Secondary.Ammo 		= 'none'
SWEP.Secondary.FireRate 	= 1.5

-- The sound to play on primary attack.
SWEP.ShootSound = 'weapon_th_shotgun.single'

-- The sound to play on secondary attack.
SWEP.Shoot2Sound = 'weapon_th_shotgun.double'

-- The sound to play when reloading.
SWEP.ReloadSound = 'weapon_th_shotgun.reload'

-- The sound to play when pumping.
SWEP.PumpSound = 'weapon_th_shotgun.special1'

SWEP.MuzzleFlashOffset = Vector( 0, 0, 0 )

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local shotgun_damage = GetConVar( 'sk_th_plr_dmg_buckshot' ) or CreateConVar( 'sk_th_plr_dmg_buckshot', '5' )	

local VECTOR_CONE_DM_SHOTGUN		= Vector( 0.08716, 0.04362, 0.00  ) -- 10 degrees by 5 degrees
local VECTOR_CONE_DM_DOUBLESHOTGUN  = Vector( 0.17365, 0.04362, 0.00 ) -- 20 degrees by 5 degrees

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()

	BaseClass.SetupDataTables( self )

	self.Weapon:NetworkVar( 'Float', 3, 'PumpTime' )

	self:SetHoldType( 'shotgun' )
end

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )
	
	self.Weapon:SetPumpTime( 0 )
	
	self:SetHoldType( 'shotgun' )
end

--[[---------------------------------------------------------
	Check if the weapon can do a primary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()

	if ( self.Weapon:Clip1() <= 0 ) then
		self:PlayEmptySound()
		self:SetNextSecondaryFire( CurTime() + self.Secondary.FireRate )
		self:Reload()
		return false
		
	end
	
	if self.Owner:WaterLevel() == 3 then
		self:PlayEmptySound()
		seff:SetNextSecondaryFire( CurTime() + self.Secondary.FireRate )
		return false
	end

	return true
end

--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return end
	
	self:TakePrimaryAmmo( 1 )

	-- Do a muzzleflash effect.
	self:MuzzleEffect( MUZZLEFLASH_HL1_357, 1.5 )
	
	-- player "shoot" animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )
	
	local vecSrc = self.Owner:GetShootPos()
	local vecAiming = self.Owner:GetAimVector()

	self.Owner:ViewPunch( Angle( -5, 0, 0 ) )
	
	self.Weapon:EmitSound( self.ShootSound )
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	local bullet = {}
	bullet.Src 		= vecSrc
	bullet.Dir 		= vecAiming
	if !game.SinglePlayer() then
		bullet.Num 		= 4
		bullet.Spread 	= VECTOR_CONE_DM_SHOTGUN
	else
		bullet.Num 		= 6
		-- regular old, untouched spread. 
		bullet.Spread 	= VECTOR_CONE_10DEGREES
	end
	bullet.Tracer	= 0
	bullet.Force	= 1
	bullet.Damage	= shotgun_damage:GetFloat()
	bullet.AmmoType = self:GetPrimaryAmmoType()
	bullet.Distance = 8192
	
	self.Owner:FireBullets( bullet )
	
	self:DefaultShellEject( SHELL_SHOTGUN, TE_BOUNCE_SHOTSHELL )
	
	if self.Weapon:Clip1() != 0 then
		self.Weapon:SetPumpTime( CurTime() + 0.5 )
	end	
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireRate )
	self:SetNextSecondaryFire( CurTime() + self.Primary.FireRate )
	
	if self:Clip1() != 0 then
		self.Weapon:SetNextIdle( CurTime() + 5.0 )
	else
		self.Weapon:SetNextIdle( CurTime() + self.Primary.FireRate )
	end
	
	self.Weapon:SetInSpecialReload(0)	
end

--[[---------------------------------------------------------
	Check if the weapon can do a secondary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()

	if ( self.Weapon:Clip1() <= 1 ) then
		self:PlayEmptySound()
		self:SetNextSecondaryFire( CurTime() + self.Secondary.FireRate )
		self:Reload()
		return false
		
	end
	
	if self.Owner:WaterLevel() == 3 then
		self:PlayEmptySound()
		seff:SetNextSecondaryFire( CurTime() + self.Secondary.FireRate )
		return false
	end

	return true
end

--[[---------------------------------------------------------
	Secondary weapon attack.
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()

	if !self:CanSecondaryAttack() then return end
	
	self:TakePrimaryAmmo( 2 )

	-- Do a muzzleflash effect.
	self:MuzzleEffect( MUZZLEFLASH_HL1_SHOTGUN_DOUBLE, 1.5 )
	
	-- player "shoot" animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_SECONDARY )
	
	local vecSrc = self.Owner:GetShootPos()
	local vecAiming = self.Owner:GetAimVector()

	self.Owner:ViewPunch( Angle( -10, 0, 0 ) )
	
	self.Weapon:EmitSound( self.Shoot2Sound )
	
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	
	local bullet = {}
	bullet.Src 		= vecSrc
	bullet.Dir 		= vecAiming
	if !game.SinglePlayer() then
		bullet.Num 		= 8
		bullet.Spread 	= VECTOR_CONE_DM_DOUBLESHOTGUN
	else
		bullet.Num 		= 12
		-- regular old, untouched spread. 
		bullet.Spread 	= VECTOR_CONE_10DEGREES
	end
	bullet.Tracer	= 0
	bullet.Force	= 1
	bullet.Damage	= shotgun_damage:GetFloat() * 2
	bullet.AmmoType = self:GetPrimaryAmmoType()
	bullet.Distance = 8192
	
	self.Owner:FireBullets( bullet )
	
	for i = 0, 1 do
		self:DefaultShellEject( SHELL_SHOTGUN, TE_BOUNCE_SHOTSHELL )
	end
	
	if self.Weapon:Clip1() != 0 then
		self.Weapon:SetPumpTime( CurTime() + 0.95 )
	end	
	
	self:SetNextPrimaryFire( CurTime() + self.Secondary.FireRate )
	self:SetNextSecondaryFire( CurTime() + self.Secondary.FireRate )
	
	if self:Clip1() != 0 then
		self.Weapon:SetNextIdle( CurTime() + 6.0 )
	else
		self.Weapon:SetNextIdle( CurTime() + self.Secondary.FireRate )
	end	
	
	self.Weapon:SetInSpecialReload(0)
end

--[[---------------------------------------------------------
	Called when the reload key is pressed.
-----------------------------------------------------------]]
function SWEP:Reload()

	if ( self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 || self:Clip1() == self:GetMaxClip1()) then
		return
	end	

	-- don't reload until recoil is done
	if ( self:GetNextPrimaryFire() > CurTime()) then
		return
	end	

	-- check to see if we're ready to reload
	if self.Weapon:GetInSpecialReload() == 0 then
		self:SendWeaponAnim( ACT_SHOTGUN_RELOAD_START )
		self.Weapon:SetInSpecialReload(1)
		self.Weapon:SetNextIdle( CurTime() + 0.6 )
		self:SetNextPrimaryFire( CurTime() + 1.0 )
		self:SetNextSecondaryFire( CurTime() + 1.0 )
		
		-- player "reload" animation
		self.Owner:SetAnimation( PLAYER_RELOAD )
		self.Owner:DoAnimationEvent( PLAYERANIMEVENT_RELOAD )
		
		return;

	elseif self.Weapon:GetInSpecialReload() == 1 then
		if self.Weapon:GetNextIdle() > CurTime() then
			return
		end	
		-- was waiting for gun to move to side
		self.Weapon:SetInSpecialReload(2)

		self.Weapon:EmitSound( self.ReloadSound )
		
		self:SendWeaponAnim( ACT_VM_RELOAD )

		-- m_flNextReload = UTIL_WeaponTimeBase() + 0.5;
		self.Weapon:SetNextIdle( CurTime() + 0.5 )
	else
		-- Add them to the clip
		self:SetClip1( self:Clip1() + 1 )
		self.Owner:RemoveAmmo( 1, self:GetPrimaryAmmoType() )
		self.Weapon:SetInSpecialReload(1)
	end
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()

	if self.Weapon:GetPumpTime() != 0 && self.Weapon:GetPumpTime() < CurTime() then
		-- play pumping sound
		self.Weapon:EmitSound( self.PumpSound )
		self.Weapon:SetPumpTime( 0 )	
	end

	if !self:CanIdle() then return end

	if (self:Clip1() == 0 && self.Weapon:GetInSpecialReload() == 0 && self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 ) then
		self:Reload( )
	elseif ( self.Weapon:GetInSpecialReload() != 0) then

		if (self:Clip1() != self:GetMaxClip1() && self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 ) then
			self:Reload( )
		else
			-- reload debounce has timed out
			self:SendWeaponAnim( ACT_SHOTGUN_PUMP )
			
			--  play cocking sound
			self.Weapon:EmitSound( self.PumpSound )
			self.Weapon:SetInSpecialReload(0)
			self.Weapon:SetNextIdle( CurTime() + 1.5 )
		end
	else
		local seq
		local flRand = RandomFloat( 0.0, 1.0 )

		if (flRand <= 0.8) then
			seq = self:LookupSequence( 'deepidle' )
			self.Weapon:SetNextIdle( CurTime() + 60.0 / 12.0)
		elseif (flRand <= 0.95) then
			seq = self:LookupSequence( 'sm_idle' )
			self.Weapon:SetNextIdle( CurTime() + 20.0 / 9.0)
		else
			seq = self:LookupSequence( 'idle4' )
			self.Weapon:SetNextIdle( CurTime() + 20.0 / 9.0 )
		end
		
		local vm = self.Owner:GetViewModel()
		vm:SendViewModelMatchingSequence( seq )
	end
end

--[[---------------------------------------------------------
	This method returns the shell eject offset.
	
	@return A vector reprensenting the shell eject offset.
-----------------------------------------------------------]]
function SWEP:GetShellEjectOffset()
	return Vector( 32, 6, -12 )
end
