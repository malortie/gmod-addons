-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-- Define a global variable to ease calling base class methods.
DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.Base			= 'weapon_th_base'
SWEP.PrintName		= "Satchel"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= '+attack: Toss satchel.\n+attack2: Detonate satchel.\n+reload: Reload.'
SWEP.Category		= 'They Hunger'
SWEP.Slot				= 4
SWEP.SlotPos			= 2

SWEP.ViewModelFOV	= 90
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/th/v_satchel/v_satchel.mdl"
SWEP.ViewModelRadio	= "models/th/v_satchel_radio/v_satchel_radio.mdl"
SWEP.WorldModel		= "models/w_satchel.mdl"

SWEP.Spawnable			= true
SWEP.AdminOnly			= false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 5
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= AMMO_CLASS_HL1_SATCHEL

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.GrenadeClassName	= 'ent_th_satchel'

--[[---------------------------------------------------------
	Perform Client/Server initialization.
-----------------------------------------------------------]]
function SWEP:Initialize()

	BaseClass.Initialize( self )

	self:SetHoldType( 'slam' )
end

function SWEP:Deploy()

	if self.Weapon:GetChargeReady() != 0 then
		self:SetViewModel( self.ViewModelRadio )
	else
		self:SetViewModel( self.ViewModel )
	end

	return BaseClass.Deploy( self )
end

--[[---------------------------------------------------------
	Check if this weapon is useable.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:IsUseable()
	
	if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 then
		-- player is carrying some satchels
		return true
	end

	if self.Weapon:GetChargeReady() != 0 then
		-- player isn't carrying any satchels, but has some out
		return true
	end

	return false

end

--[[---------------------------------------------------------
	Check if this weapon can be deployed.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:CanDeploy()

	if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 then
		-- player is carrying some satchels
		return true
	end

	if self.Weapon:GetChargeReady()  != 0 then
		-- player isn't carrying any satchels, but has some out
		return true
	end

	return false
end

--[[---------------------------------------------------------
	Called when player has just switched to this weapon.
	
	@return true to allow switching away from this weapon 
			using lastinv command.
-----------------------------------------------------------]]
function SWEP:Deploy()
	
	if !self:CanDeploy() then return false end
	
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) )

	return true
end

--[[---------------------------------------------------------
	Called when weapon tries to holster.
	
	@param wep The weapon we are trying switch to.
	
	@return true on success.
	@return false on failure.
-----------------------------------------------------------]]
function SWEP:Holster()

	if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		-- no more grenades!
		self:RetireWeapon()
	end

	return true
end

--[[---------------------------------------------------------
	Primary weapon attack.
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	if self.Weapon:GetChargeReady() == 0 then
	
		self:Throw()
		
	elseif self.Weapon:GetChargeReady() == 1 then
	
		self:PlayViewModelSequence( 'fire' )
		
		local entities = ents.FindInSphere( self.Owner:GetPos(), 4096 )
		
		for _, satchel in pairs( entities ) do
			if satchel:GetClass() == self.GrenadeClassName then
				if satchel:GetOwner() == self.Owner then
if ( SERVER ) then				
					satchel:Use( self.Owner, self.Owner, USE_ON, 0 )
end -- end ( SERVER )					
					self.Weapon:SetChargeReady(2)
				end
			end
		end

		self.Weapon:SetChargeReady(2)
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self:SetNextSecondaryFire( CurTime() + 0.5 )
		self.Weapon:SetNextIdle( CurTime() + 0.5 )	
			
	elseif self.Weapon:GetChargeReady() == 2 then
		-- we're reloading, don't allow fire
	end

end

--[[---------------------------------------------------------
	Secondary weapon attack.
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
	if self.Weapon:GetChargeReady() != 2 then
		self:Throw()
	end
end

--[[---------------------------------------------------------
	Create and throw a satchel charge.
-----------------------------------------------------------]]
function SWEP:Throw()

	if self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) > 0 then

		local vecSrc = self.Owner:GetShootPos()

		local forward = self.Owner:EyeAngles():Forward()
		local vecThrow = forward * 274 + self.Owner:GetVelocity()

if ( SERVER ) then
		local satchel = ents.Create( self.GrenadeClassName )
		if IsValid( satchel ) then
			satchel:SetPos( vecSrc )
			satchel:SetAngles( angle_zero )
			satchel:SetOwner( self.Owner )
			satchel:Spawn()
			satchel:Activate()

			satchel:SetVelocity( vecThrow )
			
			local angvel = satchel:GetLocalAngularVelocity()
			angvel.y = 400
			satchel:SetLocalAngularVelocity( angvel )
		end
end -- end ( SERVER )

		self:SetViewModel( self.ViewModelRadio )
if ( CLIENT ) then
		self:InvalidateBoneCache()
end	
		
		self:SendWeaponAnim( ACT_VM_DRAW )
	
		-- player "shoot" animation
		self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
		self.Owner:DoAnimationEvent( PLAYERANIMEVENT_ATTACK_PRIMARY )
	
		self.Weapon:SetChargeReady(1)
		
		self.Owner:RemoveAmmo( 1, self:GetPrimaryAmmoType() )
		
		self:SetNextPrimaryFire( CurTime() + 1 )
		self:SetNextSecondaryFire( CurTime() + 0.5 )
	end
end

--[[---------------------------------------------------------
	Play weapon idle animation.
-----------------------------------------------------------]]
function SWEP:WeaponIdle()

	if !self:CanIdle() then return end

	if self.Weapon:GetChargeReady() == 0 then
		
		self:SendWeaponAnim( ACT_VM_FIDGET )
		
	elseif self.Weapon:GetChargeReady() == 1 then
	
		self:SendWeaponAnim( ACT_VM_FIDGET )
	
	elseif self.Weapon:GetChargeReady() == 2 then
	
		if ( self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 ) then
			self.Weapon:SetChargeReady(0)		
			self.Weapon:RetireWeapon()
			return
		end

		--
		self:SetViewModel( self.ViewModel )
if ( CLIENT ) then
		self:InvalidateBoneCache()
end		
		--
		
		self:SendWeaponAnim( ACT_VM_DRAW )
		
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self:SetNextSecondaryFire( CurTime() + 0.5 )
		self:SetNextSecondaryFire( CurTime() + 0.5 )
		self.Weapon:SetChargeReady(0)
	end
	
	self.Weapon:SetNextIdle( CurTime() + RandomFloat( 10, 15 ) ) -- how long till we do this again.

end

--[[

	DeactivateSatchels - removes all satchels owned by
	the provided player. Should only be used upon death.
	
--]]
function DeactivateSatchels( pOwner )
	for _, satchel in pairs( ents.FindByClass( 'monster_th_satchel' ) ) do
		if satchel:GetOwner() == pOwner then
			satchel:Deactivate()
		end
	end
end

--[[---------------------------------------------------------
	This method provides an easier way to change
	viewmodel.
	
	@param name Model name to change to.
-----------------------------------------------------------]]
function SWEP:SetViewModel( name )

	if !name then
		error( Format("%s:SetViewModel: Invalid parameter 'name' specified.", self:GetClass()) )
		return
	end

	local vm = self.Owner:GetViewModel()
	if !vm then
		error( Format("%s:SetViewModel: Weapon has no valid ViewModel.", self:GetClass() ) )
		return
	end
	
	vm:SetModel( name )
end

--[[---------------------------------------------------------
	This method provides an easier way to play custom
	viewmodel sequences.
	
	@param name Sequence name to play.
-----------------------------------------------------------]]
function SWEP:PlayViewModelSequence( name )

	if !name then
		error( Format("%s:PlayViewModelSequence: Invalid parameter 'name' specified.", self:GetClass()) )
		return
	end

	local vm = self.Owner:GetViewModel()
	if !vm then
		error( Format("%s:PlayViewModelSequence: Weapon has no valid ViewModel.", self:GetClass() ) )
		return
	end
	
	local seq = vm:LookupSequence( name )
	if seq == -1 then
		error( Format("%s:PlayViewModelSequence: ViewModel has no sequence named %s.", self:GetClass(), name ) )
		return
	end
	
	vm:ResetSequenceInfo()
	vm:SendViewModelMatchingSequence( seq )
end
