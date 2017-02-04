AddCSLuaFile()

if ( SERVER ) then

	AddCSLuaFile( 'content/hl1/mount.lua' )
	AddCSLuaFile( 'shared/hl1/util.lua' )
	AddCSLuaFile( 'shared/hl1/ammotypes.lua' )

	AddCSLuaFile( 'shared/th/util.lua' )
	AddCSLuaFile( 'shared/th/ammotypes.lua' )
	AddCSLuaFile( 'shared/th/sound.lua' )
	
	AddCSLuaFile( 'init/th/post.lua' )
	
end -- end ( SERVER )

include( 'content/hl1/mount.lua' )
include( 'shared/hl1/util.lua' )
include( 'shared/hl1/ammotypes.lua' )
include( 'shared/th/util.lua' )
include( 'shared/th/ammotypes.lua' )
include( 'shared/th/sound.lua' )

if ( CLIENT ) then
end -- end ( CLIENT )

if ( SERVER ) then

	include( 'server/hl1/grenade_util.lua' )
	include( 'server/th/resources.lua' )
	
end -- end ( SERVER )

include( 'init/th/post.lua' )
