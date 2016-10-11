--[[
Example RT

local wepcol = Color(0,0,0,255)

local cd = {}

SWEP.RTMaterialOverride = 0

SWEP.RTOpaque = true

SWEP.RTCode = function( wep )

	render.OverrideAlphaWriteEnable( true, true)
	surface.SetDrawColor(color_white)
	surface.DrawRect(-512,-512,1024,1024)
	render.OverrideAlphaWriteEnable( true, true)

	local ang = EyeAngles()

	local AngPos = wep.Owner:GetViewModel():GetAttachment(1)

	if AngPos then

		ang = AngPos.Ang

		ang:RotateAroundAxis(ang:Right(),90)

	end

	cd.angles = ang
	cd.origin = wep.Owner:GetShootPos()

	cd.x = 0
	cd.y = 0
	cd.w = 512
	cd.h = 512
	cd.fov = 4
	cd.drawviewmodel = false
	cd.drawhud = false

	render.RenderView(cd)

	render.OverrideAlphaWriteEnable( false, true)


	cam.Start2D()
		draw.NoTexture()
		local plywepcol = wep.Owner:GetWeaponColor()
		wepcol.r = plywepcol.r*255
		wepcol.g = plywepcol.g*255
		wepcol.b = plywepcol.b*255
		surface.SetDrawColor(wepcol)
		drawFilledCircle(256,256,8,16)
		surface.DrawRect(64,256-4,128,8)
		surface.DrawRect(512-64-128,256-4,128,8)
		surface.DrawRect(256-4,512-64-128,8,128)
	cam.End2D()

end
]]--
