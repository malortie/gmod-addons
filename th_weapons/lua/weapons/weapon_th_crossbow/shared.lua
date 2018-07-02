-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.BaseClass		= 'weapon_th_base'
SWEP.PrintName		= "Crossbow"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= '+attack: Fire.\n+attack2: Toggle Zoom.\n+reload: Reload.'
SWEP.Category		= 'They Hunger'
SWEP.Slot			= 2
SWEP.SlotPos			= 3

SWEP.ViewModelFOV	= 90
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/th/v_crossbow/v_crossbow.mdl"
SWEP.WorldModel		= 'models/w_crossbow.mdl'
SWEP.PModel			= 'models/th/p_crossbow/p_crossbow.mdl'

SWEP.Spawnable			= true
SWEP.AdminOnly			= false

SWEP.Primary.ClipSize		= 5
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= AMMO_CLASS_HL1_BOLT

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.FiresUnderwater = true

-- The sound to play in primary attack.
SWEP.ShootSound 	= 'weapon_th_crossbow.single'

-- The sound to play in secondary attack.
SWEP.Shoot2Sound 	= 'weapon_th_crossbow.single'

-- The sound to play when reloading.
SWEP.ReloadSound 	= 'weapon_th_crossbow.reload'

-- The class name of the bolt entity to use with
-- entity factory.
SWEP.BoltClassName	= 'ent_th_crossbow_bolt'

-- The Speed at which to throw the bolt when not underwater.
local BOLT_AIR_VELOCITY		= 2000

-- The Speed at which to throw the bolt when underwater.
local BOLT_WATER_VELOCITY	= 1000

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()
	
	BaseClass.SetupDataTables( self )

	self.Weapon:NetworkVar('Bool', 1, 'InZoom')
end

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )

	self.Weapon:SetInZoom( false )
	
	self:SetHoldType( 'crossbow' )
end

--[[---------------------------------------------------------
	Called when player has just switched to this weapon.
	
	@return true to allow switching away from this weapon 
			using lastinv command.
-----------------------------------------------------------]]
function SWEP:Deploy()

	local result = BaseClass.Deploy( self )

	if result then
		if self:Clip1() == 0 then
			self:SendWeaponAnim( ACT_CROSSBOW_DRAW_UNLOADED )
		else
			self:SendWeaponAnim( ACT_VM_DRAW )
		end
	end
	
	return result
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
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	
	if self.Weapon:GetInZoom() && !game.SinglePlayer() then
		self:FireSniperBolt()
		return
	end
	
	self:FireBolt()
end

-- this function only gets called in multiplayer
function SWEP:FireSniperBolt()

	self:TakePrimaryAmmo(1)
	
	self:EmitSound( self.ShootSound )
	self:EmitSound( self.ReloadSound )
	
	if self:Clip1() == 0 then
		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	else
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end
	
	-- player "shoot" animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )

	local anglesAim = self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles()

	local forward, up = anglesAim:Forward(), anglesAim:Up()
	
	--local vecSrc = self.Owner:GetShootPos() - up * 2
	local vecSrc = self.Owner:GetShootPos()
	local vecDir = forward

	local tr = util.TraceLine({
		start = vecSrc,
		endpos = vecSrc + vecDir * 8192,
		filter = {self, self.Owner},
		mask = MASK_SHOT_HULL
	})
	
if ( SERVER ) then
	--if ( tr.pHit->v.takedamage )
	if tr.HitNonWorld && IsValid( tr.Entity ) --[[ tr.Entity && !tr.Entity:IsWorld() --]] then
	
		local dmginfo = DamageInfo()
		dmginfo:SetInflictor( self )
		dmginfo:SetAttacker( self.Owner )
		dmginfo:SetDamage( 120 )
		dmginfo:SetDamagePosition( tr.HitPos )
		dmginfo:SetDamageForce( vecDir )
		dmginfo:SetDamageType( bit.bor( DMG_BULLET, DMG_NEVERGIB ) )
		
		tr.Entity:DispatchTraceAttack( dmginfo, tr )
	end
end -- end ( SERVER )

	self:SetNextPrimaryFire( CurTime() + 0.75 )
	self:SetNextSecondaryFire( CurTime() + 0.75 )
		
	if self:Clip1() != 0 then
		self.Weapon:SetNextIdle( CurTime() + 5.0 )
	else
		self.Weapon:SetNextIdle( CurTime() + 0.75 )
	end
end

--[[---------------------------------------------------------
	Shoot a bolt.
-----------------------------------------------------------]]
function SWEP:FireBolt()

	self:TakePrimaryAmmo(1)
	
	self:EmitSound( self.ShootSound )
	self:EmitSound( self.ReloadSound )
	
	if self:Clip1() == 0 then
		self:SendWeaponAnim( ACT_VM_SECONDARYATTACK )
	else
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	end
	
	self.Owner:ViewPunch( Angle( -2, 0, 0 ) )
	
	-- player "shoot" animation
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )

	local anglesAim = self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles()

	local forward, up = anglesAim:Forward(), anglesAim:Up()
	
	--anglesAim.p	= -anglesAim.p
	
	local right = anglesAim:Right()
	local vecSrc = self.Owner:GetShootPos() + right * 4 - up * 4
	--local vecSrc = self.Owner:GetShootPos() - up * 2
	local vecDir = forward

if ( SERVER ) then
	local bolt = ents.Create( self.BoltClassName )

	if IsValid( bolt ) then
	
		bolt:SetPos( vecSrc )
		bolt:SetAngles( anglesAim )
		bolt:SetOwner( self.Owner )
		bolt:Spawn()
		bolt:Activate()
	
		if self.Owner:WaterLevel() == 3 then
			bolt:SetVelocity( vecDir * BOLT_WATER_VELOCITY )
		else
			bolt:SetVelocity( vecDir * BOLT_AIR_VELOCITY )
		end
		
		local angvel = bolt:GetLocalAngularVelocity()
		angvel.r = 10
		bolt:SetLocalAngularVelocity( angvel )
	end
end -- end ( SERVER )

	self:SetNextPrimaryFire( CurTime() + 0.75 )
	self:SetNextSecondaryFire( CurTime() + 0.75 )
		
	if self:Clip1() != 0 then
		self.Weapon:SetNextIdle( CurTime() + 5.0 )
	else
		self.Weapon:SetNextIdle( CurTime() + 0.75 )
	end
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

	self.Weapon:SetInZoom( !self.Weapon:GetInZoom() )
	
	self:SetNextSecondaryFire( CurTime() + 1 )
end

--[[---------------------------------------------------------
	Called when the reload key is pressed.
-----------------------------------------------------------]]
function SWEP:Reload()

	if self.Weapon:GetInZoom() then
		self:SecondaryAttack()
	end
	
	BaseClass.Reload( self )
	
	if self:Ammo1() > 0 then
		self:EmitSound( self.ReloadSound )
	end	
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()

	if !self:CanIdle() then return end

	local flRand = RandomFloat( 0, 1 )
		
	if flRand <= 0.75 then
		if self:Clip1() > 0 then
			self:SendWeaponAnim( ACT_VM_IDLE )
		else
			self:SendWeaponAnim( ACT_CROSSBOW_IDLE_UNLOADED )
		end
		self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
	else
		if self:Clip1() > 0 then
			self:SendWeaponAnim( ACT_VM_FIDGET )
			self.Weapon:SetNextIdle( CurTime() + 90.0 / 30.0 )
		else
			self:SendWeaponAnim( ACT_CROSSBOW_FIDGET_UNLOADED )
			self.Weapon:SetNextIdle( CurTime() + 80.0 / 30.0 )
		end
	end
end

