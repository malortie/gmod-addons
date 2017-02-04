AddCSLuaFile()

-- Notify user about initialization status.
if IsHL1Mounted() then

if ( CLIENT ) then
	MsgC( Color( 0, 255, 0 ), "(CLIENT) They Hunger weapons initialization: successful.\n" )
else
	MsgC( Color( 0, 255, 0 ), "(SERVER) They Hunger weapons initialization: successful.\n" )
end -- end ( CLIENT )

else -- !IsHL1Mounted()

if ( CLIENT ) then
	MsgC( Color( 244, 119, 125 ), "(CLIENT) They Hunger weapons initialization failure: " ..
								  "Half-Life: Source either not installed or not improperly mounted.\n" )
else
	MsgC( Color( 244, 119, 125 ), "(SERVER) They Hunger weapons initialization failure: " .. 
								  "Half-Life: Source either not installed or not improperly mounted.\n" )
end -- end ( CLIENT )

end