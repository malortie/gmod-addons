-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base = 'weapon_th_base'
SWEP.PrintName = 'Taurus'
SWEP.Author = 'Marc-Antoine (malortie) Lortie'
SWEP.Contact = ''
SWEP.Purpose = ''
SWEP.Instructions	= '+attack: Fire.\n+reload: Reload.'
SWEP.Category = 'They Hunger'
SWEP.Slot			= 1
SWEP.SlotPos			= 3

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.ViewModel = 'models/th/v_taurus/v_taurus.mdl'
SWEP.WorldModel = 'models/th/w_taurus/w_taurus.mdl'
SWEP.PModel = 'models/th/p_taurus/p_taurus.mdl'

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = AMMO_CLASS_TH_TAURUS
SWEP.Primary.FireRate = 0.25

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = 'none'

-- The sound to play on primary attack.
SWEP.ShootSound = 'weapon_th_taurus.single'

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local taurus_damage = GetConVar( 'sk_th_plr_dmg_taurus' ) or CreateConVar( 'sk_th_plr_dmg_taurus', '10' )	

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()
	
	BaseClass.Initialize( self )
	
	self.Weapon:SetMuzzleFlashType( MUZZLEFLASH_HL1_GLOCK )
	self.Weapon:SetMuzzleFlashScale( 0.5 )

	self:SetHoldType( 'pistol' )
end

--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return end
	
	self:TakePrimaryAmmo( 1 )

	-- Do a muzzleflash effect.
	self:MuzzleEffect()
	
	-- player "shoot" animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )
	
	local vecSrc = self.Owner:GetShootPos()
	local vecAiming = self.Owner:GetAimVector()

	self.Owner:ViewPunch( Angle( -2.0, 0, 0 ) )
	
	self.Weapon:EmitSound( self.ShootSound )
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= vecSrc
	bullet.Dir 		= vecAiming
	bullet.Spread 	= VECTOR_CONE_2DEGREES
	bullet.Tracer	= 0
	bullet.Force	= 1
	bullet.Damage	= taurus_damage:GetFloat()
	bullet.AmmoType = self:GetPrimaryAmmoType()
	bullet.Distance = 8192
	
	self.Owner:FireBullets( bullet )
	
	self:DefaultShellEject()
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireRate )

	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
end

--[[---------------------------------------------------------
	Check if the weapon can do a secondary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()
	return false
end

--[[---------------------------------------------------------
	This method returns the shell eject offset.
	
	@return A vector reprensenting the shell eject offset.
-----------------------------------------------------------]]
function SWEP:GetShellEjectOffset()
	return Vector( 22, 8, -8 )
end
