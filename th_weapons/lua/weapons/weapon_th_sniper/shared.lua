-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.BaseClass		= 'weapon_th_base'
SWEP.PrintName		= "HKG36"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= '+attack: Fire.\n+attack2: Toggle Zoom.\n+reload: Reload.'
SWEP.Category		= 'They Hunger'
SWEP.Slot				= 3
SWEP.SlotPos			= 2

SWEP.ViewModelFOV	= 90
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/th/v_hkg36/v_hkg36.mdl"
SWEP.WorldModel		= "models/th/w_hkg36/w_hkg36.mdl"
SWEP.PModel			= "models/th/p_hkg36/p_hkg36.mdl"

SWEP.Spawnable			= true
SWEP.AdminOnly			= false

SWEP.Primary.ClipSize		= 5
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= AMMO_CLASS_TH_SNIPER
SWEP.Primary.FireRate		= 0.1

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

-- The sound to play on primary attack.
SWEP.ShootSound = 'weapon_th_sniper.single'

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local sniper_damage = GetConVar( 'sk_th_plr_dmg_sniper' ) or CreateConVar( 'sk_th_plr_dmg_sniper', '40' )

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()

	BaseClass.SetupDataTables( self )

	self.Weapon:NetworkVar( 'Bool', 1, 'InZoom' )
	self.Weapon:NetworkVar( 'Float', 3, 'ViewPunchScale' )
	self.Weapon:NetworkVar( 'Float', 4, 'ViewPunchTime' )
	self.Weapon:NetworkVar( 'Float', 5, 'LastFireTime' )
	self.Weapon:NetworkVar( 'Int', 3, 'NumShotsFired' )
end

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )

	self.Weapon:SetInZoom( false )
	self.Weapon:SetViewPunchScale( 0 )
	self.Weapon:SetViewPunchTime( 0 )
	self.Weapon:SetLastFireTime( 0 )
	self.Weapon:SetNumShotsFired( 0 )

	self.Weapon:SetMuzzleFlashType( MUZZLEFLASH_TH_HKG36 )
	self.Weapon:SetMuzzleFlashScale( 1 )
	
	self:SetHoldType( 'ar2' )
end


--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	if ( !self:CanPrimaryAttack() ) then return end
	
	if ( CurTime() - self.Weapon:GetLastFireTime() ) > 1.0 then
		self.Weapon:SetViewPunchScale(0)
		self.Weapon:SetNumShotsFired(0)
	end
	
	self:TakePrimaryAmmo( 1 )
	
	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= self.Owner:GetShootPos()
	bullet.Dir 		= self.Owner:GetAimVector()
	if self:IsZoomed() then
		bullet.Spread 	= VECTOR_CONE_1DEGREES
	else
		bullet.Spread 	= VECTOR_CONE_4DEGREES
	end
	bullet.Tracer	= 0 
	bullet.Force	= 1
	bullet.Damage	= sniper_damage:GetFloat()
	bullet.AmmoType = self:GetPrimaryAmmoType()
	
	self.Owner:FireBullets( bullet )
	
	--
	self:DefaultShellEject()
	--
	
	self.Weapon:EmitSound( self.ShootSound )
	
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )

	-- Do a muzzleflash effect.
	self:MuzzleEffect()

	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	local viewpunch = self.Owner:GetViewPunchAngles()
	viewpunch.p = viewpunch.p - 0.25
	viewpunch.r = 0
	
	self.Owner:ViewPunch( viewpunch )
	
	viewpunch = self.Owner:EyeAngles()
	viewpunch.p = viewpunch.p - self.Weapon:GetViewPunchScale() * 2
	viewpunch.r = 0
	
	self.Owner:SetEyeAngles( viewpunch )
	
	self.Owner:SetEyeAngles( viewpunch )
	
	if self:IsZoomed() then
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireRate + 0.7 )
	else
	self:SetNextPrimaryFire( CurTime() + self.Primary.FireRate )
	end
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
	
	self.Weapon:SetLastFireTime( CurTime() )
	self.Weapon:SetNumShotsFired( self.Weapon:GetNumShotsFired() + 1 )
end

--[[---------------------------------------------------------
	Check if the weapon can do a secondary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()
	return true
end

--[[---------------------------------------------------------
	Secondary weapon attack.
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()

	if !self:CanSecondaryAttack() then return end

	self:ToggleZoom()

	self:SetNextPrimaryFire( CurTime() + 0.5 )
	self:SetNextSecondaryFire( CurTime() + 0.5 )
end

--[[---------------------------------------------------------
	Called when the reload key is pressed.
-----------------------------------------------------------]]
function SWEP:Reload()

	self.Weapon:SetNumShotsFired(0)

	if self:IsZoomed() then
		self:ZoomOut()
	end

	BaseClass.Reload( self )
end

--[[---------------------------------------------------------
	Called when weapon tries to holster.
	
	@param wep The weapon we are trying switch to.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:Holster( wep )

	self.Weapon:SetNumShotsFired( 0 )
	self.Weapon:SetLastFireTime( 0 )
	self.Weapon:SetViewPunchScale( 0 )
	self.Weapon:SetViewPunchTime( 0 )

	if self:IsZoomed() then
		self:ZoomOut()
	end

	return BaseClass.Holster( self, wep )
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function SWEP:Think()

	self:UpdateViewPunchDecay()
	
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
	Called every frame to update the viewpunch decay.
-----------------------------------------------------------]]
function SWEP:UpdateViewPunchDecay()

	if ( CurTime() - self.Weapon:GetLastFireTime() ) < 0.1 then
		self.Weapon:SetViewPunchScale( math.Clamp( self.Weapon:GetViewPunchScale() + 0.1, 0, 1 ) )
		self.Weapon:SetViewPunchTime( CurTime() + 0.1 )
	elseif self.Weapon:GetViewPunchScale() > 0 then
		self.Weapon:SetViewPunchScale( math.Clamp( self.Weapon:GetViewPunchScale() - 0.1, 0, 1 ) )
		self.Weapon:SetViewPunchTime( CurTime() + 0.5 )
	end

end

--[[---------------------------------------------------------
	Check if the weapon is zoomed.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:IsZoomed() return self.Weapon:GetInZoom() end

--[[---------------------------------------------------------
	Zoom in.
-----------------------------------------------------------]]
function SWEP:ZoomIn()

	self.Owner:DrawViewModel( false )

	self.Weapon:SetInZoom( true )
	
	self:EnableMuzzleFlash( false )
end

--[[---------------------------------------------------------
	Zoom out.
-----------------------------------------------------------]]
function SWEP:ZoomOut()

	self.Owner:DrawViewModel( true )

	self.Weapon:SetInZoom( false )
	
	self:EnableMuzzleFlash( true )
end

--[[---------------------------------------------------------
	Either zoom in or zoom out.
-----------------------------------------------------------]]
function SWEP:ToggleZoom()
	if !self:IsZoomed() then
		self:ZoomIn()
	else
		self:ZoomOut()
	end
end

--[[---------------------------------------------------------
	Test if the muzzle flash should be drawn.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:ShouldDrawMuzzleFlash()
	
	if self:IsZoomed() then return false end

	return BaseClass.ShouldDrawMuzzleFlash( self )
end
