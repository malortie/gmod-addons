-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

local DEFAULT_SCALE_FACTOR = 10.0

EFFECT.MatMuzzleFlash = Material( "effects/hl1/muzzleflash" )
EFFECT.MatMuzzleFlash1 = Material( "effects/hl1/muzzleflash1" )
EFFECT.MatMuzzleFlash2 = Material( "effects/hl1/muzzleflash2" )
EFFECT.MatMuzzleFlash3 = Material( "effects/hl1/muzzleflash3" )

function EFFECT:Init( data )
	self.Scale = data:GetScale()
	self.Ent = data:GetEntity()
	self:SetPos( data:GetEntity():GetPos() )
	self.LifeTime = CurTime() + math.random( 0.02, 0.03 )
	self.Rotation = math.random( 0, 360 )
	self.MaterialIndex = data:GetMaterialIndex() or 1
	
	local size = 16
	self:SetCollisionBounds( Vector( -size, -size, -size ), Vector( size, size, size ) )
end

function EFFECT:Think()
	if self.LifeTime > CurTime() then return true end
	return false
end

function EFFECT:Render()
	if self.Ent then
		if self.MaterialIndex == 1 then
			render.SetMaterial( self.MatMuzzleFlash )
		elseif self.MaterialIndex == 2 then
			render.SetMaterial( self.MatMuzzleFlash1 )
		elseif self.MaterialIndex == 3 then
			render.SetMaterial( self.MatMuzzleFlash2 )
		elseif self.MaterialIndex == 4 then
			render.SetMaterial( self.MatMuzzleFlash3 )
		end
	
		local attach = self.Ent:GetAttachment( 1 )
		if attach then
			local SpriteSize = self.Scale * DEFAULT_SCALE_FACTOR
			render.DrawQuadEasy( attach.Pos, -EyeVector(), SpriteSize, SpriteSize, Color( 255, 255, 255 ), self.Rotation )
		end
	end
end