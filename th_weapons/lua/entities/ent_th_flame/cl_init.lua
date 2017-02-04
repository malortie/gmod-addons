-- Only enable this addon if HL:S is mounted.
if !IsHL1Mounted() then return end

include( 'shared.lua' )

function ENT:InitializeClientSide() end

local matPath = 'sprites/th/fthrow/'
local Template = Material( matPath .. 'fthrow000' )
local params = Template:GetKeyValues()

params["$spriterendermode"] = 5
params["$vertexcolor"] = 1

local matFlame = CreateMaterial( 'MyFlameMaterial', 'Sprite_DX9', params )

local FlameMaterials = {}

for i = 0, 9 do
	FlameMaterials[ i ] = matPath .. 'fthrow00' .. i
end

for i = 10, 15 do
	FlameMaterials[ i ] =  matPath .. 'fthrow0' .. i
end

function ENT:Draw()

	if self:GetLifeDuration() <= 0 then return end

	local realElapsedTime = CurTime() - self:GetLifeTime()
	local timeProportion = realElapsedTime / self:GetLifeDuration()
	
	local frame = math.Round( math.Clamp( timeProportion, 0, 1 ) * #FlameMaterials )

	matFlame:SetTexture( '$basetexture', FlameMaterials[ frame ] )
	
	render.SetMaterial( matFlame )
	
	local pos = self:GetPos()
	local size = self:GetRadius()
	
	render.DrawSprite( pos, size, size, Color( 255, 255, 255, 255 ) )
end