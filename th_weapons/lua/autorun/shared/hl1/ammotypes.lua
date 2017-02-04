-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

AddCSLuaFile()

AMMO_CLASS_HL1_9MM 			= 'hl1_9mm'
AMMO_CLASS_HL1_PYTHON 		= 'hl1_357'
AMMO_CLASS_HL1_BUCKSHOT 	= 'hl1_buckshot'
AMMO_CLASS_HL1_BOLT 		= 'hl1_bolt'
AMMO_CLASS_HL1_MP5GRENADE 	= 'hl1_mp5grenade'
AMMO_CLASS_HL1_SATCHEL 		= 'hl1_satchel'
AMMO_CLASS_HL1_TRIPMINE 	= 'hl1_tripmine'

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


ADD_AMMO( AMMO_CLASS_HL1_9MM,
	DMG_BULLET,
	TRACER_LINE_AND_WHIZ,
	0,
	0,
	250,
	1000,
	0,
	0,
	0 )
	
ADD_AMMO( AMMO_CLASS_HL1_PYTHON,
	DMG_BULLET,
	TRACER_LINE_AND_WHIZ,
	0,
	0,
	36,
	1000,
	0,
	0,
	0 )
	
ADD_AMMO( AMMO_CLASS_HL1_BUCKSHOT,
	DMG_BULLET,
	TRACER_LINE_AND_WHIZ,
	0,
	0,
	125,
	1000,
	0,
	0,
	0 )
	
ADD_AMMO( AMMO_CLASS_HL1_BOLT,
	DMG_BULLET,
	0,
	0,
	0,
	50,
	0,
	0,
	0,
	0 )	
	
ADD_AMMO( AMMO_CLASS_HL1_MP5GRENADE,
	DMG_BLAST,
	0,
	0,
	0,
	10,
	0,
	0,
	0,
	0 )	
	
ADD_AMMO( AMMO_CLASS_HL1_SATCHEL,
	0,
	0,
	0,
	5,
	0,
	0,
	0,
	0 )

ADD_AMMO( AMMO_CLASS_HL1_TRIPMINE,
	0,
	0,
	0,
	5,
	0,
	0,
	0,
	0 )	