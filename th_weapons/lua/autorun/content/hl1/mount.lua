AddCSLuaFile()

function IsHL1Mounted()
	
	if !IsMounted( 280 ) || !IsMounted( 'hl1' ) then return false end

	return true
end