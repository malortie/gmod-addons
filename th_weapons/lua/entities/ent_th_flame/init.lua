-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

-------------------------------------
-- Projectile shot by Flamethrower.
-------------------------------------
AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )

include( 'shared.lua' )

-- Minimum and maximum flame life time (in seconds).
ENT.MinLifeTime = 0.5
ENT.MaxLifeTime = 1

-- Minimum and maximum flame radius.
ENT.MinRadius = 64
ENT.MaxRadius = 68

-------------------------------------
-- Skill ConVars
-------------------------------------

-- Represents the amount of damage casted by a flame.
local flame_damage = GetConVar( 'sk_th_plr_dmg_flame' ) or CreateConVar( 'sk_th_plr_dmg_flame', '1' )

--[[---------------------------------------------------------
	Perform Server-side initialization.
-----------------------------------------------------------]]
function ENT:InitializeServerSide()

	-- Use the helibomb model just for the shadow (because it's about the same size)
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:SetSolid( SOLID_BBOX )
	self:AddSolidFlags( FSOLID_NOT_SOLID )
	self:SetMoveType( MOVETYPE_FLY )
	
	self:AddEffects( EF_BRIGHTLIGHT )

	self:SetRadius( self:GetRadius() or 16 )
	local size = self:GetRadius() / 2
	
	self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )
	
	self:DrawShadow( false )
	self:SetTrigger( true )
	self:UseTriggerBounds( true, 24 )
	
	self:SetLifeDuration( RandomFloat( self.MinLifeTime, self.MaxLifeTime ) )
	self:SetLifeTime( CurTime() )
	self:SetRadius( RandomInt( self.MinRadius, self.MaxRadius ) )

end

--[[---------------------------------------------------------
	Called every frame.
-----------------------------------------------------------]]
function ENT:Think()

	if ( CurTime() - self:GetLifeTime() ) > self:GetLifeDuration() then
		self:Remove()
		return
	end
	
	if ( IsValid( self:GetOwner() ) && ( CurTime() - self:GetLifeTime() ) > 0.25 ) then
		self:SetOwner( nil )
	end
	
	self:NextThink( CurTime() + 0.1 )
	return true
end

--[[---------------------------------------------------------
	Called when touched by another entity.
		
	@param other The entity that we are touching.
-----------------------------------------------------------]]
function ENT:Touch( other )
	
	if other == self:GetOwner() then return end
	
	-- Flame is about to be removed. At this point, the sprite animation
	-- has almost fade out. Therefore, ignore the final touchers.
	if ( ( self:GetLifeTime() + self:GetLifeDuration() ) - CurTime() ) < 0.5 then
		self:Remove()
		return
	end
	
	local OldVelocity = self:GetVelocity() 
	
	local tr = self:GetTouchTrace()
	
	if ( other:IsPlayer() or other:IsNPC() ) then
		
		local info = DamageInfo()

		info:SetInflictor( self )
		if IsValid( self:GetOwner() ) then
			info:SetAttacker( self:GetOwner() )
		else
			info:SetAttacker( self )
		end
		info:SetDamage( flame_damage:GetFloat() )
		info:SetDamageType( DMG_BURN )
		info:SetDamagePosition( tr.HitPos )
		info:SetDamageForce( OldVelocity:GetNormalized() )
		
		other:DispatchTraceAttack( info, tr )
		
		self:Remove()
		
	elseif other:IsWorld() then
		self:SetVelocity( Vector( 0, 0, 0 ) )
		
		self:SetMoveType( MOVETYPE_NONE )
	end
	
	if other:IsNPC() then
		other:Ignite( 50, 128 )
	else
		other:Ignite( 1, 128 )
	end	
end
