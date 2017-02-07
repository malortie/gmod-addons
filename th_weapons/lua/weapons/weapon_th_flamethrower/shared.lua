-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base = 'weapon_th_base'
SWEP.PrintName = 'Flamethrower'
SWEP.Author = 'Marc-Antoine (malortie) Lortie'
SWEP.Contact = ''
SWEP.Purpose = ''
SWEP.Instructions	= '+attack: Fire.\n+reload: Reload.'
SWEP.Category = 'They Hunger'

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.ViewModel = 'models/th/v_egon/v_egon.mdl'
SWEP.WorldModel = 'models/w_egon.mdl'

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = AMMO_CLASS_TH_GAS
SWEP.Primary.FireRate = 0.22

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 'none'

-- The sound to play when shooting.
SWEP.ShootSound	= 'weapon_th_flamethrower.single'

-- The flame class name to use with the
-- entity factory.
SWEP.FlameClassName = 'ent_th_flame'

-- All four shoot sequences.
SWEP.ShootSequences = {
	'fire1',
	'fire2',
	'fire3',
	'fire4'
}

-- Flame trace length.
local FLAME_TRACE_LENGTH	= 32

-- The minimum length away from the wall at
-- which to stick the flame in place.
local FLAME_FORWARD_OFFSET	= 16

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()
	BaseClass.SetupDataTables( self )
	
	self.Weapon:NetworkVar( 'Float', 3, 'SequenceResetTime' )
	self.Weapon:NetworkVar( 'Int', 3, 'SequenceNumber' )
end

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )
	
	self.Weapon:SetSequenceResetTime( 0 )
	self.Weapon:SetSequenceNumber( 0 )

	self:SetHoldType( 'ar2' )
end

--[[---------------------------------------------------------
	Check if the weapon can do a primary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()

	if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		self:SetNextPrimaryFire( CurTime() + self.Primary.FireRate )
		return false
	end

	if self.Owner:WaterLevel() == 3 then
		self:SetNextPrimaryFire( CurTime() + self.Primary.FireRate )
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
	
	self:ThrowFlame()
	
	self.Weapon:EmitSound( self.ShootSound )
	
	local index = (self.Weapon:GetSequenceNumber() % (#self.ShootSequences) )

	local seq = self:LookupSequence( self.ShootSequences[ index + 1 ] )
	if seq != -1 then
		local vm = self.Owner:GetViewModel()
		vm:SendViewModelMatchingSequence( seq )
	end	
	
	self.Weapon:SetSequenceNumber( self.Weapon:GetSequenceNumber() + 1 )
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireRate )
	
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
	
	self.Weapon:SetSequenceResetTime( CurTime() + self:ViewModelSequenceDuration() ) 
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

	self:FixupSequence()

	BaseClass.Think( self )
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()
	
	if !self:CanIdle() then return end

	local seq
	local flRand = RandomFloat(0,1)
	
	if flRand <= 0.5 then
		seq = self:LookupSequence( 'idle1' )
		self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
	else
		seq = self:LookupSequence( 'fidget1' )
		self.Weapon:SetNextIdle( CurTime() + 3 )
	end
	
	local vm = self.Owner:GetViewModel()
	vm:SendViewModelMatchingSequence( seq )
end

--[[---------------------------------------------------------
	Called every frame to check and stop the shoot
	sequence after firing.
-----------------------------------------------------------]]
function SWEP:FixupSequence()

	if ( self.Weapon:GetSequenceResetTime() != 0 && self.Weapon:GetSequenceResetTime() <= CurTime() ) then
		self:ResetSequenceInfo()
		self:SendWeaponAnim( ACT_VM_IDLE )
		self.Weapon:SetSequenceResetTime( 0 )
	end
end

--[[---------------------------------------------------------
	Create and throw a flame.
-----------------------------------------------------------]]
function SWEP:ThrowFlame()

if ( SERVER ) then

	local angles = self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles()
	
	local forward = angles:Forward()
	local right = angles:Right()
	local up = angles:Up()
	
	local vecSrc, vecEnd
	
	vecSrc = self.Owner:GetShootPos()
	vecSrc = vecSrc + right * RandomFloat( 1, 2 ) * 4
	vecSrc = vecSrc + up * RandomFloat( -2, -1 ) * 4
	
	local tr = util.TraceLine({
		start = vecSrc,
		endpos = vecSrc + forward * FLAME_TRACE_LENGTH,
		filter = { self, self.Owner },
		mask = MASK_SHOT_HULL
	})
	
	local minFractionDistance = math.min( tr.Fraction, 1.0 )
	local forwardLength = FLAME_FORWARD_OFFSET * minFractionDistance
	local normalLength = FLAME_FORWARD_OFFSET * ( 1.0 - minFractionDistance )

	vecSrc = tr.StartPos + forward * forwardLength + tr.HitNormal * normalLength
	
	local flame = ents.Create( self.FlameClassName )

	if IsValid( flame ) then
		flame:SetPos( vecSrc )
		flame:SetAngles( angle_zero )
		flame:SetOwner( self.Owner )
		flame:Spawn()
		flame:Activate()
		
		flame:SetVelocity( forward * 250 )
	end

end -- end ( SERVER )

end