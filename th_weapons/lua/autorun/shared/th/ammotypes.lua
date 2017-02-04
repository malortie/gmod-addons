-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

AddCSLuaFile()

AMMO_CLASS_TH_AP9 		= 'th_ap9'
AMMO_CLASS_TH_TAURUS 	= 'th_taurus'
AMMO_CLASS_TH_SNIPER 	= 'th_sniper'
AMMO_CLASS_TH_GAS 		= 'th_gas'
AMMO_CLASS_TH_TNT 		= 'th_tnt'
AMMO_CLASS_TH_MEDKIT 	= 'th_medkit'

AMMO_CLASS_TH_SAWGAS 	= 'th_sawgas' -- Cut chainsaw

local function ADD_AMMO( Name, DamageType, Tracer, PlayerDmg, NPCDmg, MaxCarry, Force, MinSplash, MaxSplash, Flags )
	game.AddAmmoType({ 
		name = Name,
		dmgtype = DamageType,
		tracer = Tracer,
		plydmg = PlayerDmg,
		npcdmg = NPCDmg,
		maxcarry = MaxCarry,
		force = Force,
		minsplash = MinSplash,
		maxsplash = MaxSplash,
		flags = Flags
	})
end
	
ADD_AMMO( AMMO_CLASS_TH_AP9,
	DMG_BULLET,
	TRACER_LINE_AND_WHIZ,
	0,
	0,
	200,
	1000,
	0,
	0,
	0 )

ADD_AMMO( AMMO_CLASS_TH_TAURUS,
	DMG_BULLET,
	TRACER_LINE_AND_WHIZ,
	0,
	0,
	80,
	1000,
	0,
	0,
	0 )
	
ADD_AMMO( AMMO_CLASS_TH_SNIPER,
	DMG_BULLET,
	TRACER_LINE_AND_WHIZ,
	0,
	0,
	50,
	1000,
	0,
	0,
	0 )
	
ADD_AMMO( AMMO_CLASS_TH_GAS,
	DMG_BURN,
	0,
	0,
	100,
	0,
	0,
	0,
	0 )
	
ADD_AMMO( AMMO_CLASS_TH_SAWGAS,
	0,
	0,
	0,
	100,
	0,
	0,
	0,
	0 )	
	
ADD_AMMO( AMMO_CLASS_TH_TNT,
	0,
	0,
	0,
	10,
	0,
	0,
	0,
	0 )

ADD_AMMO( AMMO_CLASS_TH_MEDKIT,
	0,
	0,
	0,
	12,
	0,
	0,
	0,
	0 )

function GetAmmoMax( name )
	return game.GetAmmoMax( game.GetAmmoID( name ) )
end