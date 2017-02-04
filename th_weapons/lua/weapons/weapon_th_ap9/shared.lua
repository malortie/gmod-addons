-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base = 'weapon_th_base'

SWEP.PrintName = 'AP9'
SWEP.Author = 'Marc-Antoine (malortie) Lortie'
SWEP.Contact = ''
SWEP.Purpose = ''
SWEP.Instructions	= '+attack: Fire.\n+attack2: Burst fire.\n+reload: Reload.'
SWEP.Category = 'They Hunger'

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.ViewModel = 'models/th/v_ap9/v_ap9.mdl'
SWEP.WorldModel = 'models/th/w_ap9/w_ap9.mdl'

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 40
SWEP.Primary.DefaultClip = 40
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = AMMO_CLASS_TH_AP9
SWEP.Primary.FireRate = 0.16

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = 'none'

-- The sound to play on primary attack.
SWEP.ShootSound = 'weapon_th_ap9.single'

SWEP.BurstFireRate	= 0.05
SWEP.BurstCount 	= 3

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local ap9_damage = GetConVar( 'sk_th_plr_dmg_ap9' ) or CreateConVar( 'sk_th_plr_dmg_ap9', '9' )

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()

	BaseClass.SetupDataTables( self )

	self.Weapon:NetworkVar('Float', 4, 'NextBurst')
	self.Weapon:NetworkVar('Int', 4, 'NumBurstFire')
	self.Weapon:NetworkVar('Bool', 1, 'InBurstFire')

end

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )

	self.Weapon:SetNumBurstFire( 0 )
	self.Weapon:SetNextBurst( 0 )
	self.Weapon:SetInBurstFire( false )
end

--[[---------------------------------------------------------
	Called when the reload key is pressed.
-----------------------------------------------------------]]
function SWEP:Reload()

	self:ResetBurstFire()
	
	BaseClass.Reload( self )
end

--[[---------------------------------------------------------
	Check if the weapon can do a primary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()

	if self.Weapon:GetInBurstFire() then return false end

	return BaseClass.CanPrimaryAttack( self )
end

--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()
	
	-- Ensure that we are able to do primary attack.
	if !self:CanPrimaryAttack() then return end
	
	local owner = self.Owner
	if !IsValid( owner ) then return end

	local pos = owner:GetShootPos()
	local vecAiming = owner:GetAimVector()
	
	-- Fire a bullet.
	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= owner:GetShootPos()
	bullet.Dir 		= owner:GetAimVector()
	bullet.Spread 	= VECTOR_CONE_6DEGREES
	bullet.Tracer	= 2
	bullet.Force	= 1
	bullet.Damage	= ap9_damage:GetFloat()
	bullet.AmmoType = self:GetPrimaryAmmoType()
	
	owner:FireBullets( bullet )
	
	-- Eject a shell.
	self:DefaultShellEject()
	
	-- Remove one primary ammo instance.
	self:TakePrimaryAmmo( 1 )
	
	-- Do a muzzleflash effect.
	owner:MuzzleFlash()
	
	-- Play primary attack sound.
	self.Weapon:EmitSound( self.ShootSound )
	
	-- Send weapon animation.
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	-- Player 'shoot' animation.
	owner:SetAnimation( PLAYER_ATTACK1 )
	
	owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )
	
	-- Kick the player's view angles.
	owner:ViewPunch( Angle( RandomFloat( -0.5, 0.5 ), RandomFloat( -0.5, 0.5 ), 0 ) )
	
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireRate )
	self:SetNextSecondaryFire( CurTime() + self.Primary.FireRate + 0.1 )
	 
	 -- Delay next weapon idle time.
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
end

--[[---------------------------------------------------------
	Check if the weapon can do a secondary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()
	return self:CanPrimaryAttack()
end

--[[---------------------------------------------------------
	Secondary weapon attack.
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()

	-- Ensure that we are able to do secondary attack.
	if !self:CanSecondaryAttack() then return false end

	self:StartBurstFire()	

	self:SetNextPrimaryFire( CurTime() + math.huge )
	self:SetNextSecondaryFire( CurTime() + math.huge )
	self.Weapon:SetNextIdle( CurTime() + math.huge )
	
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function SWEP:Think()

	-- Update burst fire.
	self:UpdateBurstFire()	
	
	BaseClass.Think( self )
end

--[[---------------------------------------------------------
	This method returns the shell eject offset.
	
	@return A vector reprensenting the shell eject offset.
-----------------------------------------------------------]]
function SWEP:GetShellEjectOffset()
	return Vector( 24, 8, -8 )
end

--[[---------------------------------------------------------
	Check if this weapon can shoot while in burst fire.
-----------------------------------------------------------]]
function SWEP:CanDoBurstFire()

	if self:Clip1() <= 0 then
		return false
	end

	if self.Weapon:GetNumBurstFire() >= self.BurstCount then
		return false
	end

	return true
end

--[[---------------------------------------------------------
	Shoot a bullet in burst fire.
-----------------------------------------------------------]]
function SWEP:DoBurstFire()

	local owner = self.Owner
	if !IsValid( owner ) then return end

	-- Fire a bullet.
	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= owner:GetShootPos()
	bullet.Dir 		= owner:GetAimVector()
	bullet.Spread 	= VECTOR_CONE_8DEGREES
	bullet.Tracer	= 0
	bullet.Force	= 1
	bullet.Damage	= 5
	bullet.AmmoType = self:GetPrimaryAmmoType()
	
	owner:FireBullets( bullet )
	
	-- Eject a shell.
	self:DefaultShellEject()
	
	-- Remove one primary ammo instance.
	self:TakePrimaryAmmo( 1 )
	
	-- Do a muzzleflash effect.
	owner:MuzzleFlash()
	
	-- Play primary attack sound.
	self.Weapon:EmitSound( self.ShootSound )
	
	-- Send weapon animation.
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	
	-- Player 'shoot' animation.
	owner:SetAnimation( PLAYER_ATTACK1 )
	
	owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_SECONDARY )
	
	-- Kick the player's view angles.
	owner:ViewPunch( Angle( -1, 0, 0 ) )
	
	-- Delay next weapon idle time.
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
end

--[[---------------------------------------------------------
	Start burst fire.
-----------------------------------------------------------]]
function SWEP:StartBurstFire()

	self.Weapon:SetInBurstFire( true )
	self.Weapon:SetNumBurstFire( 0 )
	self.Weapon:SetNextBurst( CurTime() )
end

--[[---------------------------------------------------------
	Reset all burst fire variables.
-----------------------------------------------------------]]
function SWEP:ResetBurstFire()
	
	self.Weapon:SetInBurstFire( false )
	self.Weapon:SetNumBurstFire( 0 )
	self.Weapon:SetNextBurst( 0 )

end

--[[---------------------------------------------------------
	Called every frame to update burst fire.
-----------------------------------------------------------]]
function SWEP:UpdateBurstFire()

	if self:GetInBurstFire() then
	
		if self:CanDoBurstFire() then
			if self.Weapon:GetNextBurst() <= CurTime() then		
				self:DoBurstFire()
				
				self.Weapon:SetNumBurstFire( self.Weapon:GetNumBurstFire() + 1 )
				self.Weapon:SetNextBurst( CurTime() + self.BurstFireRate )
			end	
		else
			self:ResetBurstFire()
			
			self:SetNextPrimaryFire( CurTime() + 0.4 )
			self:SetNextSecondaryFire( CurTime() + 0.4 )
			self.Weapon:SetNextIdle( CurTime() + 5.0 )
		end
	end
	
end
