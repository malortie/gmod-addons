-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.BaseClass		= 'weapon_th_base'
SWEP.PrintName		= "Medkit"
SWEP.Author			= ''
SWEP.Contact		= ''
SWEP.Purpose		= ''
SWEP.Instructions	= '+attack: Heal.'
SWEP.Category		= 'They Hunger'
SWEP.Slot				= 0
SWEP.SlotPos			= 5

SWEP.ViewModelFOV	= 90
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/th/v_tfc_medic/v_tfc_medkit.mdl"
SWEP.WorldModel		= "models/th/w_tfc_medkit/w_tfc_medkit.mdl"
SWEP.PModel			= 'models/th/p_medkit/p_medkit.mdl'

SWEP.Spawnable			= true
SWEP.AdminOnly			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 12
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= AMMO_CLASS_TH_MEDKIT

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

-- The sound to play when healing.
SWEP.HealSound	= 'weapon_th_medkit.single'

-- The sound to play when out of medical supplies.
SWEP.EmptySound = 'weapon_th_medkit.empty'

-- The delay before administering health.
SWEP.HealDelay = 38.0 / 30.0

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of health to give to the owner.
local heal_amount = GetConVar( 'sk_th_medkit_heal' ) or CreateConVar( 'sk_th_medkit_heal', '15' )

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()

	BaseClass.SetupDataTables( self )
	
	self.Weapon:NetworkVar('Float', 3, 'HealTime')
	self.Weapon:NetworkVar('Bool', 1, 'Healing')
end

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )

	self:SetHoldType( 'slam' )

	self:ResetHealing()
end

--[[---------------------------------------------------------
	Check if the weapon can do a primary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()
	
	if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		self:PlayEmptySound()
		self:SetNextPrimaryFire( CurTime() + 1.0 )
		return false
	end	
		
	if self.Owner:Health() >= self.Owner:GetMaxHealth() then
		return false
	end
		
	if self:IsHealing() then return false end	
	
	return true
end

--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	self:StartHealing()
	
	self:SetNextPrimaryFire( CurTime() + self:ViewModelSequenceDuration() )
	self:SetNextSecondaryFire( CurTime() + self:ViewModelSequenceDuration() )
	self.Weapon:SetNextIdle( CurTime() + self:ViewModelSequenceDuration() )
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
	Called when weapon tries to holster.
	
	@param wep The weapon we are trying switch to.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:Holster( wep )

	self:ResetHealing()

	return BaseClass.Holster( self, wep )
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function SWEP:Think()

	if self:IsHealing() && self.Weapon:GetHealTime() <= CurTime() then
		self:Heal()
		self:ResetHealing()
	end
	
	BaseClass.Think( self )
end

--[[---------------------------------------------------------
	Test healing state.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:IsHealing() return self.Weapon:GetHealing() end

--[[---------------------------------------------------------
	Start healing.
-----------------------------------------------------------]]
function SWEP:StartHealing()

	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	self.Weapon:SetHealing( true )
	self.Weapon:SetHealTime( CurTime() + self.HealDelay )
end

--[[---------------------------------------------------------
	Reset healing variables.
-----------------------------------------------------------]]
function SWEP:ResetHealing()
	self.Weapon:SetHealTime( 0 )
	self.Weapon:SetHealing( false )
end

--[[---------------------------------------------------------
	Heal the owner and play the heal sound.
-----------------------------------------------------------]]
function SWEP:Heal()
	
	local owner = self.Owner
	if !IsValid( owner ) then return end

	self:TakePrimaryAmmo( 1 )
	
	local oldHealth = owner:Health()
	local health = owner:Health()
	health = math.Clamp( health + heal_amount:GetFloat(), 0, owner:GetMaxHealth() )

	owner:SetHealth( health )
	
	self.Weapon:EmitSound( self.HealSound )
	
	owner:SetAnimation( PLAYER_ATTACK1 )
	
	owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()

	if !self:CanIdle() then return end
	
	local seq
	local flRand = RandomFloat( 0.0, 1.0 )

	if (flRand <= 0.75) then
		seq = self:LookupSequence( 'idle' )
		self.Weapon:SetNextIdle( CurTime() + 35.0 / 30.0 )
	else
		seq = self:LookupSequence( 'longidle' )
		self.Weapon:SetNextIdle( CurTime() + 71.0 / 30.0 )
	end
	
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( seq )
end
