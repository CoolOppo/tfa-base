--[[
Example RT

local wepcol = Color(0,0,0,255)

local cd = {}

SWEP.RTMaterialOverride = 0

SWEP.RTOpaque = true

SWEP.RTCode = function( self )

	render.OverrideAlphaWriteEnable( true, true)
	surface.SetDrawColor(color_white)
	surface.DrawRect(-512,-512,1024,1024)
	render.OverrideAlphaWriteEnable( true, true)
	
	local ang = EyeAngles()
	
	local AngPos = self.Owner:GetViewModel():GetAttachment(1)
	
	if AngPos then
	
		ang = AngPos.Ang
		
		ang:RotateAroundAxis(ang:Right(),90)
	
	end
	
	cd.angles = ang
	cd.origin = self.Owner:GetShootPos()
	
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
		local plywepcol = self.Owner:GetWeaponColor()
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

if CLIENT then
	local props = {
		['$translucent'] = 1
	}
	local TFA_RTMat = CreateMaterial("tfa_rtmaterial","UnLitGeneric", props )--Material("models/weapons/kf2/shared/optic")
	local TFA_RTScreen = GetRenderTargetEx("TFA_RT_Screen",	512,	512,	RT_SIZE_NO_CHANGE,	MATERIAL_RT_DEPTH_SEPARATE,	0,	CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_ARGB8888	)
	local TFA_RTScreenO = GetRenderTargetEx("TFA_RT_ScreenO",	512,	512,	RT_SIZE_NO_CHANGE,	MATERIAL_RT_DEPTH_SEPARATE,	0,	CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGB888	)
	
	local wepcol = Color(0,0,0,255)
	
	local oldVmModel = ""
	
	local function KF2RenderScreen()
		
		if !IsValid(LocalPlayer()) or !IsValid(LocalPlayer():GetActiveWeapon()) then return end
		
		local self = LocalPlayer():GetActiveWeapon()
		
		local vm = self.Owner:GetViewModel()
		
		if oldVmModel != vm:GetModel() then
			local matcount = #vm:GetMaterials()
			local i=0
			while i<=matcount do
				self.Owner:GetViewModel():SetSubMaterial(i,"")
				i=i+1
			end
			oldVmModel = vm:GetModel()
			return
		end
		
		if !IsValid(self) or !self.RTMaterialOverride or !self.RTCode then return end
		
		oldVmModel = vm:GetModel()
		
		local w,h = ScrW(), ScrH()
		
		local oldrt = render.GetRenderTarget()
		
		if !self.RTOpaque then
			render.SetRenderTarget(TFA_RTScreen)
		else
			render.SetRenderTarget(TFA_RTScreenO)
		end
		render.Clear( 0, 0, 0, 0, true, true )
		render.SetViewPort(0,0,512,512)
		self:RTCode(TFA_RTMat)
		render.SetRenderTarget(oldrt)
		render.SetViewPort(0,0,w,h)
		
		if !self.RTOpaque then
			TFA_RTMat:SetTexture("$basetexture",TFA_RTScreen)
		else
			TFA_RTMat:SetTexture("$basetexture",TFA_RTScreenO)
		end
		
		self.Owner:GetViewModel():SetSubMaterial(self.RTMaterialOverride,"!tfa_rtmaterial")
	end

	hook.Add("RenderScene","KF2SCREENS",KF2RenderScreen)
end