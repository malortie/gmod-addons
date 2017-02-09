-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base = 'weapon_th_base'
SWEP.PrintName = 'Glock'
SWEP.Author = 'Marc-Antoine (malortie) Lortie'
SWEP.Contact = ''
SWEP.Purpose = ''
SWEP.Instructions	= '+attack: Fire.\n+attack2: Toggle silencer.\n+reload: Reload'
SWEP.Category = 'They Hunger'
SWEP.Slot			= 3
SWEP.SlotPos			= 4

SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = false
SWEP.ViewModel = 'models/th/v_9mmhandgun/v_9mmhandgun.mdl'
SWEP.WorldModel = 'models/th/w_silencer/w_silencer.mdl'

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 17
SWEP.Primary.DefaultClip = 17
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = AMMO_CLASS_HL1_9MM

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = 'none'

SWEP.FiresUnderwater = true
SWEP.AltFiresUnderwater = true

-- The sound to play when unsilenced.
SWEP.ShootSound = 'weapon_th_glock.single'

-- The sound to play when silenced.
SWEP.ShootSilencedSound = 'weapon_th_glock.double'

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted to a player.
local glock_damage = GetConVar( 'sk_th_plr_dmg_9mm_bullet' ) or CreateConVar( 'sk_th_plr_dmg_9mm_bullet', '8' )	

-------------------------------------
-- Bodygroups
-------------------------------------
local BODYGROUP_SILENCER = 2
local BODYGROUP_SILENCER_OFF = 0
local BODYGROUP_SILENCER_ON = 1

local SILENCER_DETACH_TIME  = 49.0 / 18.0	-- Sequence duration when detaching the silencer.
local SILENCER_ATTACH_BODYGROUP_EVENT_TIME = 15.0 / 16.0 -- Delay before toggling silencer state, when attaching.
local SILENCER_DETACH_BODYGROUP_EVENT_TIME = 49.0 / 18.0 -- Delay before toggling silencer state, when detaching.

-- Silencer toggle states.
local SilencerStates = {

	None = 0,
	AttachSilencer = 1,
	DetachSilencer = 2,
	Redraw = 3,
}

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()	

	BaseClass.SetupDataTables( self )

	self.Weapon:NetworkVar( 'Float', 3, 'SilencerBodygroupSwapEventTime' )
	self.Weapon:NetworkVar( 'Int', 3, 'SilencerState' )
	self.Weapon:NetworkVar( 'Bool', 1, 'Silenced' )
	self.Weapon:NetworkVar( 'Bool', 2, 'ShouldDrawMuzzleFlash' )
end

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )

	self.Weapon:SetSilencerBodygroupSwapEventTime( 0 )
	self.Weapon:SetSilencerState( SilencerStates.None )
	self.Weapon:SetSilenced( true )
	
	self:EnableMuzzleFlash( !self:GetSilenced() )
	
	self:SetHoldType( 'pistol' )
end

--[[---------------------------------------------------------
	Called when weapon tries to holster.
	
	@param wep The weapon we are trying switch to.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:Holster( wep )

	self:ResetWeaponSilencer()
	
	return BaseClass.Holster( self, wep )
end

--[[---------------------------------------------------------
	Called when player has just switched to this weapon.
	
	@return true to allow switching away from this weapon 
			using lastinv command.
-----------------------------------------------------------]]
function SWEP:Deploy()

	-- Perform silencer checking.
	self:CheckSilencerVisibility()
	
	return BaseClass.Deploy( self )
end

--[[---------------------------------------------------------
	Check if this weapon can reload.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanReload()

	if self:IsSwitchingBetweenSilencerStates() then return false end
	
	return BaseClass.CanReload( self )
end

--[[---------------------------------------------------------
	Called when the reload key is pressed.
-----------------------------------------------------------]]
function SWEP:Reload()

	if !self:CanReload() then return end

	if self.Weapon:Clip1() == 0 then
		self.Weapon:DefaultReload( ACT_GLOCK_SHOOT_RELOAD )
	else
		self.Weapon:DefaultReload( ACT_VM_RELOAD )
	end	
end

--[[---------------------------------------------------------
	Check if the weapon can do a primary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()
	
	if self:IsSwitchingBetweenSilencerStates() then return false end
	
	return BaseClass.CanPrimaryAttack( self )
end

--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	if !self:CanPrimaryAttack() then return end

	if self:IsSilenced() then
		self:GlockFire( 0.01, 0.3, true )
	else
		self:GlockFire( 0.1, 0.2, false )
	end
end

--[[---------------------------------------------------------
	Check if the weapon can do a secondary attack.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()

	if self:IsSwitchingBetweenSilencerStates() then return false end
	
	return true
end

--[[---------------------------------------------------------
	Secondary weapon attack.
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()

	if !self:CanSecondaryAttack() then return end

	self:ToggleSilencer()
	
	self:SetNextSecondaryFire( CurTime() + math.huge )
end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function SWEP:Think()

	self:UpdateWeaponSilencer()
	
	BaseClass.Think( self )
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()

	if !self:CanIdle() then return end
	
	-- only idle if the slid isn't back
	if self.Weapon:Clip1() != 0 then

		local seq
		local flRand = RandomFloat( 0.0, 1.0 )

		if (flRand <= 0.3 + 0 * 0.75) then
			seq = self:LookupSequence( 'idle3' )
			self.Weapon:SetNextIdle( CurTime() + 49.0 / 16 )
		elseif (flRand <= 0.6 + 0 * 0.875) then
			seq = self:LookupSequence( 'idle1' )
			self.Weapon:SetNextIdle( CurTime() + 60.0 / 16.0 )
		else
			seq = self:LookupSequence( 'idle2' )
			self.Weapon:SetNextIdle( CurTime() + 40.0 / 16.0 )
		end
		
		local vm = self.Owner:GetViewModel()
		vm:SendViewModelMatchingSequence( seq )
	end
end

--[[---------------------------------------------------------
	Shoot a bullet.
	
	@param flSpread Amount of spread in cone.
	@param flCycleTime Delay between attack times.
	@param fUseAutoAim Unused.
-----------------------------------------------------------]]
function SWEP:GlockFire( flSpread , flCycleTime, fUseAutoAim )

	self:TakePrimaryAmmo( 1 )

	if !self:IsSilenced() then
		self.Owner:MuzzleFlash()
	end	
	
	-- player "shoot" animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )

	local vecSrc = self.Owner:GetShootPos()
	local vecAiming
	
	if fUseAutoAim then
		--vecAiming = m_pPlayer->GetAutoaimVector( AUTOAIM_10DEGREES );
		vecAiming = self.Owner:EyeAngles():Forward()
	else
		vecAiming = self.Owner:EyeAngles():Forward()
	end

	self.Owner:ViewPunch( Angle( -2, 0, 0 ) )
	
	if self:IsSilenced() then
		self.Weapon:EmitSound( self.ShootSound )
	else
		self.Weapon:EmitSound( self.ShootSilencedSound )
	end
	
	if self.Weapon:Clip1() == 0 then
		self:SendWeaponAnim( ACT_GLOCK_SHOOTEMPTY )
	else
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end	
	
	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= vecSrc
	bullet.Dir 		= self.Owner:GetAimVector()
	bullet.Spread 	= Vector( flSpread, flSpread, flSpread )
	bullet.Tracer	= 5
	bullet.Force	= 1
	bullet.Damage	= glock_damage:GetFloat()
	bullet.AmmoType = self:GetPrimaryAmmoType()
	bullet.Distance = 8192
	
	self.Owner:FireBullets( bullet )
	
	--
	self:DefaultShellEject()
	--
	
	self:SetNextPrimaryFire( CurTime() + flCycleTime )
	self:SetNextSecondaryFire( CurTime() + flCycleTime )

	self:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
end

function SWEP:GetShellEjectOffset()
	return Vector( 20, 4, -12 )
end

--[[---------------------------------------------------------
	Test if the weapon is silenced.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:IsSilenced() return self.Weapon:GetSilenced() end

--[[---------------------------------------------------------
	Test if the owner is toggling the silencer.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:IsSwitchingBetweenSilencerStates() return self.Weapon:GetSilencerState() != SilencerStates.None end

--[[---------------------------------------------------------
	Test if the owner is attaching the silencer. 
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:SilencerWasAttached() return self.Weapon:GetSilencerState() == SilencerStates.AttachSilencer end

--[[---------------------------------------------------------
	Test if the owner is detaching the silencer. 
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:SilencerWasDetached() return self.Weapon:GetSilencerState() == SilencerStates.DetachSilencer end

--[[---------------------------------------------------------
	Test if the weapon is redrawing. 
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:WeaponRedrawnAfterSwitchingSilencerState() return self.Weapon:GetSilencerState() == SilencerStates.Redraw end

--[[---------------------------------------------------------
	Test if the silencer bodygroup is active.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:IsSilencerVisible()
	local owner = self.Owner
	if !IsValid( owner ) then return false end

	return owner:GetViewModel():GetBodygroup( BODYGROUP_SILENCER ) == BODYGROUP_SILENCER_ON
end

--[[---------------------------------------------------------
	Set silencer bodygroup state.
	
	@param state New state of the bodygroup visibility.
		   Can be either true or false.
-----------------------------------------------------------]]
function SWEP:SetSilencerVisible( state )

	local owner = self.Owner
	if !IsValid( owner ) then return end
	
	local vm = owner:GetViewModel()
	if !vm then return end
	if state == true then
		vm:SetBodygroup( BODYGROUP_SILENCER, BODYGROUP_SILENCER_ON )
	else
		vm:SetBodygroup( BODYGROUP_SILENCER, BODYGROUP_SILENCER_OFF )
	end
end

--[[---------------------------------------------------------
	Ensure that the silencer's bodygroup visibility has
	the correct value.
-----------------------------------------------------------]]
function SWEP:CheckSilencerVisibility()

	if self:IsSilenced() then
		self:SetSilencerVisible( true )
	else
		self:SetSilencerVisible( false )
	end
end

--[[---------------------------------------------------------
	Called after the silencer state has changed.
	
	@param state Silencer state.
-----------------------------------------------------------]]
function SWEP:AdjustWeaponBodygroupForSilencer( state )
	
	self.Weapon:SetSilencerBodygroupSwapEventTime( 0 )
	
	if state == SilencerStates.AttachSilencer then
		self:SetSilencerVisible( true )
	elseif state == SilencerStates.DetachSilencer then
		self:SetSilencerVisible( false )
	end
end

--[[---------------------------------------------------------
	Either start attaching or detaching silencer.
-----------------------------------------------------------]]
function SWEP:ToggleSilencer()

	if !self:IsSilenced() then
		self:AttachSilencer()
	else
		self:DetachSilencer()
	end

end

--[[---------------------------------------------------------
	Either Start attaching weapon silencer.
-----------------------------------------------------------]]
function SWEP:AttachSilencer()

	self:SendWeaponAnim( ACT_VM_HOLSTER )

	self.Weapon:SetSilencerState( SilencerStates.AttachSilencer )
	
	self.Weapon:SetSilencerBodygroupSwapEventTime( CurTime() + SILENCER_ATTACH_BODYGROUP_EVENT_TIME )
	
	self:SetNextPrimaryFire( CurTime() + self:ViewModelSequenceDuration() )
	self.Weapon:SetNextIdle( CurTime() + math.huge )
end

--[[---------------------------------------------------------
	Either Start detaching weapon silencer.
-----------------------------------------------------------]]
function SWEP:DetachSilencer()
	
	self:SendWeaponAnim( ACT_VM_ATTACH_SILENCER )

	self.Weapon:SetSilencerState( SilencerStates.DetachSilencer )
	
	self.Weapon:SetSilencerBodygroupSwapEventTime( CurTime() + SILENCER_DETACH_BODYGROUP_EVENT_TIME )
	
	self:SetNextPrimaryFire( CurTime() + SILENCER_DETACH_TIME )
	self.Weapon:SetNextIdle( CurTime() + math.huge )
	
end

--[[---------------------------------------------------------
	Either Start redrawing the weapon.
-----------------------------------------------------------]]
function SWEP:RedrawWeapon()
	self:SendWeaponAnim( ACT_VM_DRAW )
	
	self.Weapon:SetSilencerState( SilencerStates.Redraw )
	
	self:SetNextPrimaryFire( CurTime() + self:ViewModelSequenceDuration() )
	self.Weapon:SetNextIdle( self:GetNextPrimaryFire() )
end

--[[---------------------------------------------------------
	Reset silencer switching variables.
-----------------------------------------------------------]]
function SWEP:ResetWeaponSilencer()
	self.Weapon:SetSilencerState( SilencerStates.None )
	
	self:SetNextPrimaryFire( CurTime() )
	self:SetNextSecondaryFire( CurTime() )
	self.Weapon:SetNextIdle( CurTime() )
end

--[[---------------------------------------------------------
	Finish switching silencer and perform final
	tasks.
-----------------------------------------------------------]]
function SWEP:FinishSwitchingSilencer()
	self.Weapon:SetSilenced( !self:IsSilenced() )
	
	self:EnableMuzzleFlash( !self:IsSilenced() )
end

--[[---------------------------------------------------------
	Called every frame to update the silencer bodygroup.
-----------------------------------------------------------]]
function SWEP:UpdateSilencerBodygroup()
	
	if self.Weapon:GetSilencerBodygroupSwapEventTime() == 0 then return end 
	if self.Weapon:GetSilencerBodygroupSwapEventTime() > CurTime() then return end
	
	self:AdjustWeaponBodygroupForSilencer( self.Weapon:GetSilencerState() )
end

--[[---------------------------------------------------------
	Called every frame to update the silencer state.
-----------------------------------------------------------]]
function SWEP:UpdateSilencerState()

	if self:GetNextPrimaryFire() > CurTime() then return end

	if ( self:SilencerWasAttached() or self:SilencerWasDetached() ) then
		self:FinishSwitchingSilencer()
		self:RedrawWeapon()
	elseif self:WeaponRedrawnAfterSwitchingSilencerState() then
		self:ResetWeaponSilencer()
	end	
end

--[[---------------------------------------------------------
	Called every frame to update all silencer related
	operations.
-----------------------------------------------------------]]
function SWEP:UpdateWeaponSilencer()

	if !self:IsSwitchingBetweenSilencerStates() then return end

	self:UpdateSilencerBodygroup()
	
	self:UpdateSilencerState()
end

--[[---------------------------------------------------------
	Test if the muzzle flash should be drawn.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:ShouldDrawMuzzleFlash()
	
	if self:IsSilenced() then return false end

	return BaseClass.ShouldDrawMuzzleFlash( self )
end
