AddCSLuaFile()

function IsHL1Mounted()
	--[[
		Return true if either Half-Life: Source or 
		Half-Life Deathmatch: Source is mounted.
	--]]
	return IsMounted( 280 ) or IsMounted( 'hl1' ) or 
		IsMounted( 360 ) or IsMounted( 'hl1mp' )
end