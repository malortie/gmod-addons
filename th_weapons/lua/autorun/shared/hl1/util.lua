-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

AddCSLuaFile()

function RandomInt( Min, Max )
	return math.Round( math.random( Min, Max ) )
end

function RandomFloat( Min, Max )
	return math.random( Min, Max )
end

function CheckTraceHullAttack( self, distance, mins, maxs, damage, bitsDamageType )

	local startpos, endpos, forward
	
	local selfMins, selfMaxs = self:GetCollisionBounds()
	
	startpos = self:GetPos()
	startpos.z = startpos.z + (selfMins.z + selfMaxs.z) * 0.5
	forward = self:GetAngles():Forward()
	endpos = startpos + forward * distance
	
	local tr = util.TraceHull({
		start = startpos,
		endpos = endpos,
		mins = mins,
		maxs = maxs,
		filter = self,
		mask = MASK_SHOT_HULL
	})
	
	if ( tr.Hit && !tr.HitWorld ) then
	
		local hit = tr.Entity
		
		if ( hit != nil && damage > 0 ) then
		
			local dmginfo = DamageInfo()
			
			dmginfo:SetInflictor( self )
			dmginfo:SetAttacker( self )
			dmginfo:SetDamage( damage )
			dmginfo:SetDamagePosition( endpos )
			dmginfo:SetDamageType( bitsDamageType )
			dmginfo:SetDamageForce( tr.HitNormal )
		
			hit:DispatchTraceAttack( dmginfo, tr )
		end
	end
	
	return tr.Entity
end

VECTOR_CONE_1DEGREES = Vector( 0.00873, 0.00873, 0.00873 )
VECTOR_CONE_2DEGREES = Vector( 0.01745, 0.01745, 0.01745 )
VECTOR_CONE_3DEGREES = Vector( 0.02618, 0.02618, 0.02618 )
VECTOR_CONE_4DEGREES = Vector( 0.03490, 0.03490, 0.03490 )
VECTOR_CONE_5DEGREES = Vector( 0.04362, 0.04362, 0.04362 )
VECTOR_CONE_6DEGREES = Vector( 0.05234, 0.05234, 0.05234 )
VECTOR_CONE_7DEGREES = Vector( 0.06105, 0.06105, 0.06105 )
VECTOR_CONE_8DEGREES = Vector( 0.06976, 0.06976, 0.06976 )
VECTOR_CONE_9DEGREES = Vector( 0.07846, 0.07846, 0.07846 )
VECTOR_CONE_10DEGREES = Vector( 0.08716, 0.08716, 0.08716 )
VECTOR_CONE_15DEGREES = Vector( 0.13053, 0.13053, 0.13053 )
VECTOR_CONE_20DEGREES = Vector( 0.17365, 0.17365, 0.17365 )


WeaponSounds = {
	EMPTY = 0,
	SINGLE = 1,
	SINGLE_NPC = 2,
	WPN_DOUBLE = 3,
	DOUBLE_NPC = 4,
	BURST = 5,
	RELOAD = 6,
	RELOAD_NPC = 7,
	MELEE_MISS = 8,
	MELEE_HIT = 9,
	MELEE_HIT_WORLD = 10,
	SPECIAL1 = 11,
	SPECIAL2 = 12,
	SPECIAL3 = 13,
	TAUNT = 14,
	DEPLOY = 15
}

VEC_DUCK_HULL_MIN 	= Vector( -16, -16, -18 )
VEC_DUCK_HULL_MAX	= Vector( 16,  16,  18 )

function FindHullIntersection( vecSrc, tr, mins, maxs, pEntity )

	local tr2 = tr

	local		minmaxs = {mins, maxs, maxs}
	local		vecHullEnd = tr.HitPos
	local		vecEnd = vector_origin

	local distance = tonumber('1e6')

	vecHullEnd = vecSrc + ((vecHullEnd - vecSrc)*2)
	
	local tmpTrace = util.TraceLine({
		start = vecSrc,
		endpos = vecHullEnd,
		filter = pEntity,
		mask = MASK_SHOT_HULL
	})
	
	if tmpTrace.Fraction < 1.0 then
		tr2 = tmpTrace
		return tr2
	end
	
	for i = 1, 2 do
		for j = 1, 2 do
			for k = 1, 2 do

				tmpTrace = util.TraceLine({
					start = vecSrc,
					endpos = vecEnd,
					filter = pEntity,
					mask = MASK_SHOT_HULL
				})
				
				if tmpTrace.Fraction < 1.0 then
					local thisDistance = (tmpTrace.HitPos - vecSrc):Length()
					if thisDistance < distance then
						tr2 = tmpTrace
						distance = thisDistance
					end
				end
			end
		end
	end

	return tr2
end

function SpawnBlood( pos, dir, color, amount )

--if ( SERVER ) then

	local data = EffectData()

	data:SetOrigin( pos )
	data:SetNormal( dir )
	data:SetScale( amount )
	data:SetColor( color )
	
	util.Effect( "bloodimpact", data )	
	
--end -- end ( SERVER )

end

function UTIL_Sparks( pos, tr, scale )

if ( SERVER ) then

	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	
	if tr != nil then
		scale = scale or 1
		
		effectdata:SetNormal( tr.HitNormal )
		effectdata:SetMagnitude( scale )
		effectdata:SetRadius( scale )
	end

	util.Effect( "Sparks", effectdata, true, true )

end -- end ( SERVER )

end

function UTIL_ImpactEffect( pos, tr, scale )

if ( SERVER ) then

	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	
	if tr != nil then
		scale = scale or 1
		effectdata:SetNormal( tr.HitNormal )
		effectdata:SetScale( scale )
	end
	
	util.Effect( "Impact", effectdata, true, true )

end -- end ( SERVER )

end

local PropClassList = {

	['prop_physics'] = true,
	['prop_physics_override'] = true,
	['prop_dynamic'] = true,
	['prop_dynamic_override'] = true,
	['prop_static'] = true
}

function IsProp( entity )

	if !IsValid( entity ) then return false end
	
	if !PropClassList[ entity:GetClass() ] then return false end
	
	return true
end

SHELL_PISTOL 	= 0
SHELL_RIFLE 	= 1
SHELL_SHOTGUN 	= 2

TE_BOUNCE_NULL		= 0
TE_BOUNCE_SHELL		= 1
TE_BOUNCE_SHOTSHELL	= 2

-- Regular muzzle flash

MUZZLEFLASH_HL1_GLOCK 	= 11
MUZZLEFLASH_HL1_MP5 	= 20
MUZZLEFLASH_HL1_357 	= 31
MUZZLEFLASH_HL1_SHOTGUN_DOUBLE = 41