-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

include('shared.lua')

DEFINE_BASECLASS( 'weapon_th_base' )

SWEP.CSMuzzleX = true

SWEP.ScopeTexture = Material( 'vgui/th/nmxhair2' )
SWEP.ScopeScaleX	= 0.5
SWEP.ScopeScaleY	= 0.5

SWEP.ScopeFadeColor	= Color( 0, 128, 0, 64 )

function SWEP:TranslateFOV( current_fov )

	if self.Weapon:GetInZoom() then
		current_fov = 40
	end

	return current_fov
end

function SWEP:DoDrawCrosshair( x, y )

	if self.Weapon:GetInZoom() then return true end
end

function SWEP:AdjustScopeTextureDimensions( texture, width, height )

	width  = self.ScopeScaleX * width
	height = self.ScopeScaleY * height

	return width, height
end

function SWEP:DrawHUD()

	if !self.Weapon:GetInZoom() then return end
	
	-- Draw a faded color rectangle on the screen.

	surface.SetDrawColor( self.ScopeFadeColor )
	surface.DrawRect( 0, 0, ScrW(), ScrH() )

	-- Reset draw color.
	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	
	-- Retreive texture from material.
	local Texture = self.ScopeTexture:GetTexture( '$basetexture' )
	local width, height = Texture:Width(), Texture:Height()
	
	-- Adjust width and height.
	width, height = self:AdjustScopeTextureDimensions( Texture, width, height )
	
	-- Draw the scope, centered on screen.
	local x = ScrW() / 2 - width / 2
	local y = ScrH() / 2 - height / 2
	
	surface.SetMaterial( self.ScopeTexture )
	
	surface.DrawTexturedRect( x, y, width, height )
end

function SWEP:PreDrawViewModel( vm, weapon, ply )
	-- Force the viewmodel to remain still at the player's
	-- actual aim vectors.
	--vm:SetAngles( ply:GetAimVector():Angle() )
end

function SWEP:ShouldDrawMuzzleFlash()
	if self.Weapon:GetInZoom() then return false end
	
	return BaseClass.ShouldDrawMuzzleFlash( self )
end