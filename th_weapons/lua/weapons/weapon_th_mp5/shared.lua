-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base = 'weapon_th_base'
SWEP.PrintName = 'MP5'
SWEP.Author = 'Marc-Antoine (malortie) Lortie'
SWEP.Contact = ''
SWEP.Purpose = ''
SWEP.Instructions	= '+attack: Fire.\n+attack2: Launch grenade.\n+reload: Reload.'
SWEP.Category = 'They Hunger'
SWEP.Slot				= 2
SWEP.SlotPos			= 1

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.ViewModel = 'models/th/v_9mmar/v_9mmAR.mdl'
SWEP.WorldModel = 'models/th/w_9mmar/w_9mmar.mdl'
SWEP.PModel = 'models/th/p_9mmar/p_9mmar.mdl'

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 25
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = AMMO_CLASS_HL1_9MM

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = AMMO_CLASS_HL1_MP5GRENADE

-- The sound to play on primary attack.
SWEP.ShootSound 	= 'weapon_th_mp5.single'

-- The sound to play on secondary attack.
SWEP.Shoot2Sound 	= 'weapon_th_mp5.double'

SWEP.MuzzleFlashOffset = Vector( 0, 0, 0 )

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local mp5_damage = GetConVar( 'sk_th_plr_dmg_9mm_bullet' ) or CreateConVar( 'sk_th_plr_dmg_9mm_bullet', '8' )	

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )
	
	self.Weapon:SetMuzzleFlashType( MUZZLEFLASH_HL1_MP5 )
	self.Weapon:SetMuzzleFlashScale( 1.5 )

	self:SetHoldType( 'ar2' )
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

	self.Owner:ViewPunch( Angle( RandomFloat( -1.5, 1.5 ), 0, 0 ) )
	
	self.Weapon:EmitSound( self.ShootSound )
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= vecSrc
	bullet.Dir 		= vecAiming
	if !game.SinglePlayer() then
		-- optimized multiplayer. Widened to make it easier to hit a moving player
		bullet.Spread 	= VECTOR_CONE_6DEGREES
	else
		-- single player spread
		bullet.Spread 	= VECTOR_CONE_3DEGREES
	end
	bullet.Tracer	= 0
	bullet.Force	= 1
	bullet.Damage	= mp5_damage:GetFloat()
	bullet.AmmoType = self:GetPrimaryAmmoType()
	bullet.Distance = 8192
	
	self.Owner:FireBullets( bullet )
	
	self:DefaultShellEject()
	
	self:SetNextPrimaryFire( CurTime() + 0.08 )

	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
end

local GrenadeUtils = FindMetaTable( 'CGrenade' )

--[[---------------------------------------------------------
	Secondary weapon attack.
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()

	if !self:CanSecondaryAttack() then return end
	
	self:TakeSecondaryAmmo( 1 )
	
	-- player "shoot" animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_SECONDARY )
	
if ( SERVER ) then	
	
	-- we don't add in player velocity anymore.
	local forward = self.Owner:EyeAngles():Forward()
	GrenadeUtils.ShootContact( self.Owner,
						   self.Owner:GetShootPos() + forward * 16,
						   forward * 800 )
end -- end ( SERVER )						   

	self.Owner:ViewPunch( Angle( -10, 0, 0 ) )
	
	self.Weapon:EmitSound( self.Shoot2Sound )
	
	self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	
	
	self:SetNextPrimaryFire( CurTime() + 1 )
	self:SetNextSecondaryFire( CurTime() + 1 )
	self.Weapon:SetNextIdle( CurTime() + 5 ) -- idle pretty soon after shooting.
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()
	
	if !self:CanIdle() then return end

	local seq

	if RandomInt( 0, 1 ) == 1 then
		seq = self:LookupSequence( 'longidle' )
	else
		seq = self:LookupSequence( 'idle1' )
	end
	
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( seq )
	
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) ) -- how long till we do this again.
end

--[[---------------------------------------------------------
	This method returns the shell eject offset.
	
	@return A vector reprensenting the shell eject offset.
-----------------------------------------------------------]]
function SWEP:GetShellEjectOffset()
	return Vector( 20, 4, -12 )
end
