-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

SWEP.PrintName		= "They Hunger Base SWEP"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 90
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"

SWEP.Spawnable			= false
SWEP.AdminOnly			= false

SWEP.Primary.ClipSize		= 8
SWEP.Primary.DefaultClip	= 32
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Pistol"
SWEP.Primary.FireRate		= 0.5

SWEP.Secondary.ClipSize		= 8
SWEP.Secondary.DefaultClip	= 32
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "Pistol"
SWEP.Secondary.FireRate		= 0.5

SWEP.m_WeaponDeploySpeed = 1.0

SWEP:SetWeaponHoldType( 'pistol' )

-- Specify whether or not this weapon can perform
-- primary attacks underwater.
SWEP.FiresUnderwater = false

-- Specify whether or not this weapon can perform
-- secondary attacks underwater.
SWEP.AltFiresUnderwater = false

-- The sound to play when empty.
SWEP.EmptySound = 'weapon_th_base.empty'

--[[---------------------------------------------------------
	Setup networked variables.
-----------------------------------------------------------]]
function SWEP:SetupDataTables()

	self.Weapon:NetworkVar( 'Float', 0, 'NextIdle' )
	self.Weapon:NetworkVar( 'Float', 1, 'StartThrow' )
	self.Weapon:NetworkVar( 'Float', 2, 'ReleaseThrow' )
	self.Weapon:NetworkVar( 'Int', 0, 'InAttack' )
	self.Weapon:NetworkVar( 'Int', 1, 'InSpecialReload' )
	self.Weapon:NetworkVar( 'Int', 2, 'ChargeReady' )
	self.Weapon:NetworkVar( 'Bool', 0, 'DrawMuzzleFlash' )
	
	self.Weapon:NetworkVar( 'Float', 27, 'MuzzleFlashTime' )
	self.Weapon:NetworkVar( 'Float', 28, 'MuzzleFlashScale' )
	self.Weapon:NetworkVar( 'Int', 28, 'MuzzleFlashType' )

end

--[[---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]
function SWEP:Initialize()

	self.Weapon:SetNextIdle( 0 )
	self.Weapon:SetStartThrow( 0 )
	self.Weapon:SetReleaseThrow( 0 )
	self.Weapon:SetNextIdle( 0 )
	self.Weapon:SetInAttack( 0 )
	self.Weapon:SetInSpecialReload( 0 )
	self.Weapon:SetChargeReady( 0 )
	self.Weapon:SetDrawMuzzleFlash( true )
	
	--
	self.Weapon:SetMuzzleFlashTime( 0 )
	self.Weapon:SetMuzzleFlashType( MUZZLEFLASH_HL1_GLOCK )
	self.Weapon:SetMuzzleFlashScale( 1 )
	--
end


--[[---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()
end


--[[---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
end

function SWEP:CanReload()
	return true
end

--[[---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
-----------------------------------------------------------]]
function SWEP:Reload()

	if !self:CanReload() then return end

	self.Weapon:DefaultReload( ACT_VM_RELOAD );
	
	-- Update idle time.
	self.Weapon:SetNextIdle( CurTime() + self:ViewModelSequenceDuration() + 0.01 )
end


--[[---------------------------------------------------------
   Name: SWEP:Think( )
   Desc: Called every frame
-----------------------------------------------------------]]
function SWEP:Think()
	self:UpdateMuzzleFlash()
	self:WeaponIdle()
end

--[[---------------------------------------------------------
	Check if this weapon can be holstered.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanHolster()
	return true
end

--[[---------------------------------------------------------
   Name: SWEP:Holster( weapon_to_swap_to )
   Desc: Weapon wants to holster
   RetV: Return true to allow the weapon to holster
-----------------------------------------------------------]]
function SWEP:Holster( wep )
	
	if !self:CanHolster() then return false end

	return true
end

--[[---------------------------------------------------------
	Check if this weapon can be deployed.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanDeploy()
	return true
end

--[[---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
-----------------------------------------------------------]]
function SWEP:Deploy()

	if !self:CanDeploy() then return false end
	
	-- Perform muzzle flash checking.
	self:CheckMuzzleFlash()
	
	self.Weapon:SetNextIdle( CurTime() + 5.0 )
	
	self:ResetBodygroups()
	
	return true
end

--[[---------------------------------------------------------
	Test if this weapon uses clips for ammo 1.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:UsesClipsForAmmo1()
	return self.Weapon:GetMaxClip1() != -1
end

--[[---------------------------------------------------------
	Test if this weapon uses clips for ammo 2.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:UsesClipsForAmmo2()
	return self.Weapon:GetMaxClip2() != -1
end

--[[---------------------------------------------------------
	Test if this weapon has primary ammo.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:HasPrimaryAmmo()
	-- If I use a clip, and have some ammo in it, then I have ammo
	if self:UsesClipsForAmmo1() then
		if self.Weapon:Clip1() > 0 then
			return true
		end
	end
	
	-- Otherwise, I have ammo if I have some in my ammo counts
	if IsValid( self.Owner ) then
		if self:Ammo1() > 0 then
			return true
		end
	else
		-- No owner, so return how much primary ammo I have along with me.
		if( self:HasAmmo() ) then
			return true
		end
	end
	
	return false
end

--[[---------------------------------------------------------
	Test if this weapon has secondary ammo.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:HasSecondaryAmmo()
	-- If I use a clip, and have some ammo in it, then I have ammo
	if self:UsesClipsForAmmo2() then
		if self.Weapon:Clip2() > 0 then
			return true
		end
	end
	
	-- Otherwise, I have ammo if I have some in my ammo counts
	if IsValid( self.Owner ) then
		if self:Ammo2() > 0 then
			return true end
	else
		-- No owner, so return how much secondary ammo I have along with me.
		if( self:HasAmmo() ) then
			return true end
	end
	
	return false
end

--[[---------------------------------------------------------
	Test if this weapon uses primary ammo.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:UsesPrimaryAmmo()
	if self:GetPrimaryAmmoType() < 0 then return false end

	return true
end

--[[---------------------------------------------------------
	Test if this weapon uses secondary ammo.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:UsesSecondaryAmmo()
	if self:GetSecondaryAmmoType() < 0 then return false end

	return true
end

--[[---------------------------------------------------------
   Name: SWEP:TakePrimaryAmmo(   )
   Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakePrimaryAmmo( num )
	
	-- Doesn't use clips
	if ( self.Weapon:Clip1() <= 0 ) then 
	
		if ( self:Ammo1() <= 0 ) then return end
		
		self.Owner:RemoveAmmo( num, self.Weapon:GetPrimaryAmmoType() )
	
	return end
	
	self.Weapon:SetClip1( self.Weapon:Clip1() - num )	
	
end


--[[---------------------------------------------------------
   Name: SWEP:TakeSecondaryAmmo(   )
   Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakeSecondaryAmmo( num )
	
	-- Doesn't use clips
	if ( self.Weapon:Clip2() <= 0 ) then 
	
		if ( self:Ammo2() <= 0 ) then return end
		
		self.Owner:RemoveAmmo( num, self.Weapon:GetSecondaryAmmoType() )
	
	return end
	
	self.Weapon:SetClip2( self.Weapon:Clip2() - num )	
	
end


--[[---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack( )
   Desc: Helper function for checking for no ammo
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()

	if self.Weapon:GetInSpecialReload() != 0 then return false end
	
	if ( self:UsesClipsForAmmo1() && self.Weapon:Clip1() <= 0 ) or
	   ( !self:UsesClipsForAmmo1() && self:Ammo1() <= 0 ) then
		self:PlayEmptySound()
		self:SetNextPrimaryFire( CurTime() + self.Primary.FireRate )
		self:Reload() 
		return false
	end
	
	if !self.FiresUnderwater && self.Owner:WaterLevel() == 3 then
		self:PlayEmptySound()
		self:SetNextPrimaryFire( CurTime() + self.Primary.FireRate )
		return false
	end

	return true

end

--[[---------------------------------------------------------
   Name: SWEP:CanSecondaryAttack( )
   Desc: Helper function for checking for no ammo
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()

	if self.Weapon:GetInSpecialReload() != 0 then return false end

	if ( self:UsesClipsForAmmo2() && self.Weapon:Clip2() <= 0 ) or
	   ( !self:UsesClipsForAmmo2() && self:Ammo2() <= 0 ) then
		self:PlayEmptySound()
		self:SetNextSecondaryFire( CurTime() + self.Secondary.FireRate )
		return false
	end
	
	if !self.AltFiresUnderwater && self.Owner:WaterLevel() == 3 then
		self:PlayEmptySound()
		self:SetNextSecondaryFire( CurTime() + self.Secondary.FireRate )
		return false
	end

	return true

end


--[[---------------------------------------------------------
   Name: OnRemove
   Desc: Called just before entity is deleted
-----------------------------------------------------------]]
function SWEP:OnRemove()
end


--[[---------------------------------------------------------
   Name: OwnerChanged
   Desc: When weapon is dropped or picked up by a new player
-----------------------------------------------------------]]
function SWEP:OwnerChanged()
end


--[[---------------------------------------------------------
   Name: Ammo1
   Desc: Returns how much of ammo1 the player has
-----------------------------------------------------------]]
function SWEP:Ammo1()
	return self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() )
end


--[[---------------------------------------------------------
   Name: Ammo2
   Desc: Returns how much of ammo2 the player has
-----------------------------------------------------------]]
function SWEP:Ammo2()
	return self.Owner:GetAmmoCount( self.Weapon:GetSecondaryAmmoType() )
end

--[[---------------------------------------------------------
   Name: SetDeploySpeed
   Desc: Sets the weapon deploy speed. 
		 This value needs to match on client and server.
-----------------------------------------------------------]]
function SWEP:SetDeploySpeed( speed )
	self.m_WeaponDeploySpeed = tonumber( speed )
end

--[[---------------------------------------------------------
   Name: DoImpactEffect
   Desc: Callback so the weapon can override the impact effects it makes
		 return true to not do the default thing - which is to call UTIL_ImpactTrace in c++
-----------------------------------------------------------]]
function SWEP:DoImpactEffect( tr, nDamageType )
		
	return false;
	
end

--[[---------------------------------------------------------
	Test if this weapon can play idle activity.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanIdle()

	if self.Weapon:GetNextIdle() > CurTime() then return false end

	return true
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()
	
	if !self:CanIdle() then return end
	
	local anim = ACT_VM_IDLE
	
	-- Sometimes, play a fidget activity.
	if RandomInt( 0, 3 ) == 1 then
		anim = ACT_VM_FIDGET
	end
	
	self:SendWeaponAnim( anim )
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )
end

--[[---------------------------------------------------------
	Play empty weapon sound.
-----------------------------------------------------------]]
function SWEP:PlayEmptySound()
	self.Weapon:EmitSound( self.EmptySound )
end

--[[---------------------------------------------------------
	Remove this weapon from the player's inventory.
-----------------------------------------------------------]]
function SWEP:RetireWeapon()

if ( SERVER ) then
	self.Owner:StripWeapon( self.Weapon:GetClass() )
end -- end ( SERVER )

end

--[[---------------------------------------------------------
	Return the sequence duration of the viewmodel at a
	specified index.
	
	@param index ViewModel index. (must be between 0 and 2)
	
	@return ViewModel sequence duration.
-----------------------------------------------------------]]
function SWEP:ViewModelSequenceDuration( index )

	index = index or 0
	
	assert( index >= 0 && index <= 2 )

	local owner = self.Owner
	if !IsValid( owner ) then return false end
	
	return owner:GetViewModel(index):SequenceDuration()
end

--[[---------------------------------------------------------
	Return the sequence duration of the viewmodel at a
	specified index.
	
	@param index ViewModel index. (must be between 0 and 2)
	
	@return true on if the ViewModel sequence is finished.
	@return false otherwise.
-----------------------------------------------------------]]
function SWEP:IsViewModelSequenceFinished( index )

	index = index or 0

	assert( index >= 0 && index <= 2 )

	local owner = self.Owner
	if !IsValid( owner ) then return false end
	
	return owner:GetViewModel(index):GetCycle() >= 1
end

--[[---------------------------------------------------------
	Do a shell ejection effect.
	
	@param origin Spawn position of the shell.
	@param velocity Shell velocity.
	@param rotation Yaw angle at which to throw the shell.
	@param shellType Shell type.
	@param bounceSound bound sound. (unused)
	
-----------------------------------------------------------]]
function SWEP:EjectBrass( origin, velocity, rotation, shellType, bounceSound )
	
if ( SERVER ) then
	
	local effectName = 'ShellEject'

	if shellType == SHELL_PISTOL then
		effectName = 'ShellEject'
	elseif shellType == SHELL_RIFLE then
		effectName = 'RifleShellEject'
	elseif shellType == SHELL_SHOTGUN then
		effectName = 'ShotgunShellEject'
	end
	
	local angles = self.Owner:GetLocalAngles()
	angles.y = rotation
	
	local effectdata = EffectData()
	effectdata:SetOrigin( origin )
	effectdata:SetNormal( angles:Forward() )
	effectdata:SetAngles( ( angles:Up() + angles:Right() ):Angle() )
	
	util.Effect( effectName, effectdata, true, true )
	
end -- end ( SERVER )

end

--[[---------------------------------------------------------
	This method returns the shell eject offset.
	
	@return A vector reprensenting the shell eject offset.
-----------------------------------------------------------]]
function SWEP:GetShellEjectOffset()
	return Vector( 32, 6, -12 )
end

--[[---------------------------------------------------------
	Retrieve appropriate values for shell position, velocity
	and direction.
	
	@param entity Used to determine if this is a player. 
	@param origin Spawn position.
	@param velocity Entity velocity.
	@param ShellVelocity Result shell velocity.
	@param ShellOrigin Result shell origin.
	@param forward Forward direction.
	@param right Right direction.
	@param up Up direction.
	@param forwardScale The length along forward vector.
	@param rightScale The length along right vector.
	@param upScale The length along up vector.
-----------------------------------------------------------]]
local function GetDefaultShellInfo( entity, origin, velocity, ShellVelocity, ShellOrigin, forward, right, up, forwardScale, rightScale, upScale )

	local view_ofs = Vector( 0, 0, 64 ) -- 28

	if entity:IsPlayer() then
		if entity:Crouching() then
			view_ofs[3] = 28 -- 12
		end
	end

	local fR = RandomFloat( 50, 70 )
	local fU = RandomFloat( 100, 150 )
	
	for i = 1, 3 do
		ShellVelocity[i] = velocity[i] + right[i] * fR + up[i] * fU + forward[i] * 25
		ShellOrigin[i]   = origin[i] + view_ofs[i] + up[i] * upScale + forward[i] * forwardScale + right[i] * rightScale
	end
end

--[[---------------------------------------------------------
	Perform a default shell ejection effect.
	
	@param shellType Shell type.
	@param bounceSound bound sound. (unused)
-----------------------------------------------------------]]
function SWEP:DefaultShellEject( shellType, bounceSoundType )

	shellType = shellType or SHELL_PISTOL
	bounceSoundType = bounceSoundType or TE_BOUNCE_SHELL

	local angles = self.Owner:EyeAngles() + self.Owner:GetViewPunchAngles()
	
	local forward, right, up = angles:Forward(), angles:Right(), angles:Up()
	
	local offset = self:GetShellEjectOffset()

	local shellOrigin, shellVelocity = Vector(), Vector()
	
	GetDefaultShellInfo( self.Owner, self:GetPos(), self.Owner:GetVelocity(), shellVelocity, shellOrigin, forward, right, up, offset.x, offset.y, offset.z )
	
	self:EjectBrass( shellOrigin, shellVelocity, angles.y, shellType, bounceSoundType )
end

local ConcreteShotDecals = {
	'decals/concrete/shot1',
	'decals/concrete/shot2',
	'decals/concrete/shot3',
	'decals/concrete/shot4',
	'decals/concrete/shot5'
}

local MetalShotDecals = {
	'decals/metal/shot1',
	'decals/metal/shot2',
	'decals/metal/shot3',
	'decals/metal/shot4',
	'decals/metal/shot5',
}

local WoodShotDecals = {
	'decals/wood/shot1',
	'decals/wood/shot2',
	'decals/wood/shot3',
	'decals/wood/shot4',
	'decals/wood/shot5',
}

--[[---------------------------------------------------------
	Given a surface id, return an appropriate impact decal
	material name.
	
	@param surfaceid Surface Id.
	
	@return A decal name.
-----------------------------------------------------------]]
function SWEP:GetIdealSurfaceDecalMaterialName( surfaceid )
	if surfaceid == 'metal' then
		return MetalShotDecals[ RandomInt( 1, #MetalShotDecals ) ]
	elseif surfaceid == 'wood' then
		return WoodShotDecals[ RandomInt( 1, #WoodShotDecals ) ]	
	else
		return ConcreteShotDecals[ RandomInt( 1, #ConcreteShotDecals ) ]
	end
end

--[[---------------------------------------------------------
	Paint a decal on a surface, given a start and end
	position of the trace.
	
	@param traceStart Trace start position.
	@param traceStart Trace end position.
	
-----------------------------------------------------------]]
function SWEP:DoImpactDecal( traceStart, traceEnd )

--if ( SERVER ) then

	local tr = util.TraceLine({
		start = traceStart,
		endpos =  traceEnd,
		filter = { self, self.Owner },
		mask = MASK_SHOT_HULL
	})
	
	if !tr or !tr.Hit then return end
	
	local name = util.GetSurfacePropName( tr.SurfaceProps )
		
	local data = EffectData()
	data:SetOrigin( tr.HitPos )
	data:SetNormal( tr.HitNormal )
	data:SetScale( 1 )
	
	util.Effect( 'Impact', data )
	
	util.Decal( self:GetIdealSurfaceDecalMaterialName( name ), traceStart, traceEnd )
	
--end -- end ( SERVER )	
	
end

--[[---------------------------------------------------------
	Ensure that the weapon should be drawing a
	muzzle flash effect if it needs to
-----------------------------------------------------------]]
function SWEP:CheckMuzzleFlash()
	if self:ShouldDrawMuzzleFlash() then
		self:EnableMuzzleFlash( true )
	else
		self:EnableMuzzleFlash( false )
	end
end

--[[---------------------------------------------------------
	Test if the muzzle flash should be drawn.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:ShouldDrawMuzzleFlash()
	return self.Weapon:GetDrawMuzzleFlash()
end

--[[---------------------------------------------------------
	Either enable or disable muzzle flash drawing.
	
	@param state New muzzle flash state.
		   Can be true or false.
-----------------------------------------------------------]]
function SWEP:EnableMuzzleFlash( state )
	self.Weapon:SetDrawMuzzleFlash( state )
end

function SWEP:MuzzleEffect( type, scale )

	self.Weapon:SetMuzzleFlashTime( CurTime() )
	if ( type != nil ) then self.Weapon:SetMuzzleFlashType( type ) end
	if ( scale != nil ) then self.Weapon:SetMuzzleFlashScale( scale ) end
end

function SWEP:GetMuzzleFlashMaterialIndex( muzzleFlashType )

	local materialIndex = 1

	if muzzleFlashType == MUZZLEFLASH_HL1_GLOCK then
		materialIndex = 1
	elseif muzzleFlashType == MUZZLEFLASH_HL1_MP5 then
		materialIndex = 2
	elseif muzzleFlashType == MUZZLEFLASH_HL1_357 then
		materialIndex = 3
	elseif muzzleFlashType == MUZZLEFLASH_HL1_SHOTGUN_DOUBLE then
		materialIndex = 3
	elseif muzzleFlashType == MUZZLEFLASH_TH_AP9 then
		materialIndex = 4
	elseif muzzleFlashType == MUZZLEFLASH_TH_HKG36 then
		materialIndex = 4
	elseif muzzleFlashType == MUZZLEFLASH_TH_CHAINGUN then
		materialIndex = 3
	elseif muzzleFlashType == MUZZLEFLASH_TH_EINAR1 then
		materialIndex = 2
	end
	
	return materialIndex
end

function SWEP:DoMuzzleFlash()
	
	if CLIENT then
		if self:IsCarriedByLocalPlayer() and !self.Owner:ShouldDrawLocalPlayer() then
			return
		end
		local data = EffectData()
		data:SetEntity( self )
		data:SetMaterialIndex( self:GetMuzzleFlashMaterialIndex( self:GetMuzzleFlashType() or MUZZLEFLASH_HL1_GLOCK ) )
		data:SetScale( self.Weapon:GetMuzzleFlashScale() )
		util.Effect( "hl1_muzzleflash", data, true, true )
	end
	
	self.Owner:MuzzleFlash()
end

function SWEP:UpdateMuzzleFlash()
	if self.Weapon:GetMuzzleFlashTime() != 0 and self.Weapon:GetMuzzleFlashTime() <= CurTime() then
		self.Weapon:SetMuzzleFlashTime( 0 )
		self:DoMuzzleFlash()
	end
end

function SWEP:ResetBodygroups()
	local owner = self.Owner
	if !IsValid( owner ) then return false end

	local vm = owner:GetViewModel()
	if !vm then return false end

	vm:SetBodygroup( 0, 0 )
	return true
end