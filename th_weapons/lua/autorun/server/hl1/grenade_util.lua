-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

local grenade_contact_damage = GetConVar( 'sk_hl1_plr_dmg_grenade' ) or CreateConVar( 'sk_hl1_plr_dmg_grenade', '100' )

-- Blast radius scale factor
local grenade_radius_factor = GetConVar( 'sk_hl1_grenade_radius_factor' ) or CreateConVar( 'sk_hl1_grenade_radius_factor', '2.5' )

local GrenadeContactModel	= 'models/grenade.mdl'
local GrenadeTimedModel 	= 'models/w_grenade.mdl'
local GrenadeSatchelModel 	= 'models/w_satchel.mdl'
local GrenadeTNTModel 		= 'models/th/w_tnt/w_tnt.mdl'

local GrenadeContactClassName	= 'ent_th_handgrenade'
local GrenadeTimedClassName		= 'ent_th_handgrenade'
local GrenadeSatchelClassName	= 'ent_th_satchel'
local GrenadeTNTClassName		= 'ent_th_handgrenade'

local SatchelCode = { SATCHEL_DETONATE = 0, SATCHEL_RELEASE = 1  }

local CGrenade = {}
GrenadeUtils = CGrenade

debug.getregistry().CGrenade = CGrenade

function CGrenade.ShootContact( owner, vecStart, vecVelocity )

	local grenade = ents.Create( GrenadeContactClassName )
	
	grenade:Spawn()
	grenade:Activate()
	-- contact grenades arc lower
	grenade:SetGravity( 0.5 ) -- lower gravity since grenade is aerodynamic and engine doesn't know it.
	grenade:SetPos( vecStart )
	grenade:SetVelocity( vecVelocity )
	grenade:SetAngles( vecVelocity:Angle() )
	grenade:SetOwner( owner )
	--
	-- New
	grenade:SetModelScale( grenade:GetModelScale() * 0.5, 0 )
	--
	
	-- make monsters afaid of it while in the air
	grenade.m_pfnThink = grenade.DangerSoundThink
	grenade:NextThink( CurTime() )
	
	-- Tumble in air
	local angvel = grenade:GetLocalAngularVelocity()
	angvel.p = RandomFloat( -100, -500 )
	grenade:SetLocalAngularVelocity( angvel )
	
	-- Explode on contact
	grenade.m_pfnTouch = grenade.ExplodeTouch

	grenade:SetBlastDamage( grenade_contact_damage:GetFloat() )
	grenade:SetBlastRadius( grenade:GetBlastDamage() * grenade_radius_factor:GetFloat() ) 

	return grenade
end

function CGrenade.ShootTimed( owner, vecStart, vecVelocity, time )
	
	local grenade = ents.Create( GrenadeTimedClassName )
	
	grenade:Spawn()
	grenade:Activate()
	grenade:SetPos( vecStart )
	grenade:SetVelocity( vecVelocity )
	grenade:SetAngles( vecVelocity:Angle() )
	grenade:SetOwner( owner )
	
	--grenade.m_pfnTouch = grenade.BounceTouch -- Bounce if touched
	
	--[[
		Take one second off of the desired detonation time and set the think to PreDetonate. PreDetonate
		will insert a DANGER sound into the world sound list and delay detonation for one second so that 
		the grenade explodes after the exact amount of time specified in the call to ShootTimed(). 
	--]]
	
	grenade:SetDetonateTime( CurTime() + time )
	grenade.m_pfnThink = grenade.TumbleThink
	grenade:NextThink( CurTime() + 0.1 )
	
	if time < 0.1 then
		grenade:NextThink( CurTime() )
		grenade:SetVelocity( vector_origin )
	end
	
	grenade:SetSequence( RandomInt( 3, 6 ) )
	grenade:SetPlaybackRate( 1.0 )

	-- Tumble through the air
	-- pGrenade->pev->avelocity.x = -400;
	
	--
	-- NEW
	--

	grenade:SetGravity( 0.5 )
	grenade:SetFriction( 0.8 )
	
	grenade:SetModel( GrenadeTimedModel )
	grenade:SetBlastDamage( 100 )
	grenade:SetBlastRadius( grenade:GetBlastDamage() * grenade_radius_factor:GetFloat() ) 
	
	-- New
	grenade:SetModelScale( grenade:GetModelScale() * 0.95, 0 )
	
	-- Set up solidity and movetype
	grenade:SetMoveType( MOVETYPE_VPHYSICS )
	grenade:SetSolid( SOLID_VPHYSICS )

	grenade:PhysicsInit( SOLID_VPHYSICS )
	grenade:PhysWake()
	
	if util.IsValidPhysicsObject( grenade, 0 ) then
		grenade:GetPhysicsObject():SetVelocityInstantaneous( vecVelocity )
	end
	
	--

	return grenade
end

function CGrenade.ShootTimedTNT( owner, vecStart, vecVelocity, time )
	
	local grenade = ents.Create( GrenadeTimedClassName )
	
	grenade:Spawn()
	grenade:Activate()
	grenade:SetPos( vecStart )
	grenade:SetVelocity( vecVelocity )
	grenade:SetAngles( vecVelocity:Angle() )
	grenade:SetOwner( owner )
	
	--[[
		Take one second off of the desired detonation time and set the think to PreDetonate. PreDetonate
		will insert a DANGER sound into the world sound list and delay detonation for one second so that 
		the grenade explodes after the exact amount of time specified in the call to ShootTimed(). 
	--]]
	
	grenade:SetDetonateTime( CurTime() + time )
	grenade.m_pfnThink = grenade.TumbleThink
	grenade:NextThink( CurTime() + 0.1 )
	
	if time < 0.1 then
		grenade:NextThink( CurTime() )
		grenade:SetVelocity( vector_origin )
	end
	
	grenade:SetSequence( RandomInt( 3, 6 ) )
	grenade:SetPlaybackRate( 1.0 )

	-- Tumble through the air
	-- pGrenade->pev->avelocity.x = -400;
	
	--
	-- NEW
	--

	grenade:SetGravity( 0.5 )
	grenade:SetFriction( 0.8 )
	
	grenade:SetModel( GrenadeTNTModel )
	grenade:SetBlastDamage( 100 )
	grenade:SetBlastRadius( grenade:GetBlastDamage() * grenade_radius_factor:GetFloat() ) 
	
	-- New
	grenade:SetModelScale( grenade:GetModelScale() * 0.95, 0 )
	
	-- Set up solidity and movetype
	grenade:SetMoveType( MOVETYPE_VPHYSICS )
	grenade:SetSolid( SOLID_VPHYSICS )

	grenade:PhysicsInit( SOLID_VPHYSICS )
	grenade:PhysWake()
	
	if util.IsValidPhysicsObject( grenade, 0 ) then
		grenade:GetPhysicsObject():SetVelocityInstantaneous( vecVelocity )
	end
	
	--

	return grenade
end


function CGrenade.ShootSatchelCharge( owner, vecStart, vecVelocity )

	local grenade = ents.Create( GrenadeSatchelClassName )
	grenade:SetMoveType( MOVETYPE_FLYGRAVITY )
	
	grenade:SetSolid( SOLID_BBOX )
	
	grenade:SetModel( GrenadeSatchelModel )
	
	grenade:SetCollisionBounds( vector_origin, vector_origin )

	--grenade:SetBlastDamage( 200 )
	grenade:SetPos( vecStart )
	grenade:SetVelocity( vecVelocity )
	grenade:SetAngles( angle_zero )
	grenade:SetOwner( owner )
	--
	grenade:Spawn()
	grenade:Activate()
	grenade:SetBlastRadius( grenade:GetBlastDamage() * grenade_radius_factor:GetFloat() )
	--
	
	-- Detonate in "time" seconds
	--pGrenade->SetThink( &CGrenade::SUB_DoNothing );
	grenade.m_pfnUse = grenade.DetonateUse
	grenade.m_pfnTouch = grenade.SlideTouch
	grenade:SetKeyValue( 'spawnflags', SF_DETONATE )

	grenade:SetFriction( 0.9 )

	return grenade
end

function CGrenade.UseSatchelCharges( owner, code )

	if !IsValid( owner ) then return end	

	for	_, v in pairs( ents.FindByClass( 'th_grenade_satchel' ) ) do
		if v:HasSpawnFlags( SF_DETONATE ) && v:GetOwner() ==  owner then
			if code == SatchelCode.SATCHEL_DETONATE then
				v:Use( owner, owner, USE_ON, 0 )
			else -- SATCHEL_RELEASE
				v:SetOwner( nil )
			end
		end
	end
end

--[[
function SUB_UseTargets( self, activator, useType, value )

	local kv = self:GetKeyValues()
	
	if kv then
		local target = kv[ 'target' ]
	
		if target then
			ents.FireTargets( target, activator, self, useType, value )
		end
	end
end
--]]