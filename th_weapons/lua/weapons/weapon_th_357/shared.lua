-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base = 'weapon_th_base'

SWEP.PrintName = '.357 Python'
SWEP.Author = 'Marc-Antoine (malortie) Lortie'
SWEP.Contact = ''
SWEP.Purpose = ''
SWEP.Instructions	= '+attack: Fire.\n+attack2: Toggle Zoom (Multiplayer only).\n+reload: Reload.'
SWEP.Category = 'They Hunger'
SWEP.Slot			= 1
SWEP.SlotPos			= 2

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.ViewModel = 'models/th/v_357/v_357.mdl'
SWEP.WorldModel = 'models/w_357.mdl'
SWEP.PModel = 'models/th/p_357/p_357.mdl'

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = AMMO_CLASS_HL1_PYTHON

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = 'none'

-- The sound to play on primary attack.
SWEP.ShootSound = 'weapon_th_357.single'

SWEP.MuzzleFlashOffset = Vector( 0, 0, 0 )

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local python_damage = GetConVar( 'sk_th_plr_dmg_357_bullet' ) or CreateConVar( 'sk_th_plr_dmg_357_bullet', '40' )	

-------------------------------------
-- Bodygroups
-------------------------------------
local BODYGROUP_SCOPE = 4
local BODYGROUP_SCOPE_ON = 1
local BODYGROUP_SCOPE_OFF = 0

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()

	BaseClass.SetupDataTables( self )
	
	self.Weapon:NetworkVar( 'Bool', 1, 'InZoom' )
end

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )
	
	self.Weapon:SetInZoom( false )
	self.Weapon:SetMuzzleFlashType( MUZZLEFLASH_HL1_357 )
	self.Weapon:SetMuzzleFlashScale( 1.2 )

	self:SetHoldType( "revolver" )
end

--[[---------------------------------------------------------
	Called when weapon tries to holster.
	
	@param wep The weapon we are trying switch to.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:Holster( wep )

	if self.Weapon:GetInZoom() then
		self:SecondaryAttack()
	end
	
	return BaseClass.Holster( self, wep )
end

--[[---------------------------------------------------------
	Called when player has just switched to this weapon.
	
	@return true to allow switching away from this weapon 
			using lastinv command.
-----------------------------------------------------------]]
function SWEP:Deploy()

	local result = BaseClass.Deploy( self )

	if result then
		if !game.SinglePlayer() then
			-- enable laser sight geometry.
			self.Owner:GetViewModel():SetBodygroup( BODYGROUP_SCOPE, BODYGROUP_SCOPE_ON )
		else
			self.Owner:GetViewModel():SetBodygroup( BODYGROUP_SCOPE, BODYGROUP_SCOPE_OFF )
		end
	end
	
	return result
end

--[[---------------------------------------------------------
	Called when the reload key is pressed.
-----------------------------------------------------------]]
function SWEP:Reload()

	if self.Weapon:GetInZoom() then
		self.Weapon:SetInZoom( false )
	end
	
	BaseClass.Reload( self )
end

--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	-- Ensure that we are able to do primary attack.
	if !self:CanPrimaryAttack() then return end

	self:TakePrimaryAmmo( 1 )

	-- Do a muzzleflash effect.
	self:MuzzleEffect()
	
	-- player "shoot" animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )
	
	local vecSrc = self.Owner:GetShootPos()
	local vecAiming = self.Owner:GetAimVector()

	self.Owner:ViewPunch( Angle( -10.0, 0, 0 ) )
	
	self.Weapon:EmitSound( self.ShootSound )
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= vecSrc
	bullet.Dir 		= vecAiming
	bullet.Spread 	= VECTOR_CONE_1DEGREES
	bullet.Tracer	= 0
	bullet.Force	= 1
	bullet.Damage	= python_damage:GetFloat()
	bullet.AmmoType = self:GetPrimaryAmmoType()
	bullet.Distance = 8192
	
	self.Owner:FireBullets( bullet )
	
	self:SetNextPrimaryFire( CurTime() + 0.75 )

	self:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
end

--[[---------------------------------------------------------
	Check if the weapon can do a secondary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()
	
	-- In order to zoom, the client must be running
	-- a multiplayer session.
	if game.SinglePlayer() then return false end

	return true
end

--[[---------------------------------------------------------
	Secondary weapon attack.
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()

	-- Ensure that we are able to do secondary attack.
	if !self:CanSecondaryAttack() then return end
	
	self.Weapon:SetInZoom(!self.Weapon:GetInZoom())
	
	self:SetNextSecondaryFire( CurTime() + 0.5 )
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()

	if !self:CanIdle() then return end
	
	local seq
	local flRand = RandomFloat( 0.0, 1.0 )

	if (flRand <= 0.5) then
		seq = self:LookupSequence( 'idle1' )
		self.Weapon:SetNextIdle( CurTime() + 70.0 / 30.0 )
	elseif (flRand <= 0.7) then
		seq = self:LookupSequence( 'idle2' )
		self.Weapon:SetNextIdle( CurTime() + 60.0 / 30.0 )
	elseif (flRand <= 0.9) then
		seq = self:LookupSequence( 'idle3' )
		self.Weapon:SetNextIdle( CurTime() + 88.0 / 30.0 )
	else
		seq = self:LookupSequence( 'fidget1' )
		self.Weapon:SetNextIdle( CurTime() + 170.0 / 30.0 )
	end
	
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( seq )
end
