DEFINE_BASECLASS("tfa_csgo_base")
SWEP.Secondary.ScopeZoom			= 1
SWEP.Secondary.UseACOG			= false	
SWEP.Secondary.UseMilDot			= false		
SWEP.Secondary.UseSVD			= false	
SWEP.Secondary.UseParabolic		= false	
SWEP.Secondary.UseElcan			= false
SWEP.Secondary.UseGreenDuplex		= false

SWEP.RTScopeFOV = 6

SWEP.Scoped				= false
SWEP.BoltAction		= false

SWEP.ScopeAngleTransforms = {
	--{"P",1} --Pitch, 1
	--{"Y",1} --Yaw, 1
	--{"R",1} --Roll, 1
}

SWEP.ScopeOverlayTransforms = { 0, 0 }

SWEP.ScopeOverlayTransformMultiplier = 0.8

SWEP.RTMaterialOverride = 1

SWEP.IronSightsSensitivity = 1

SWEP.ScopeShadow = nil
SWEP.ScopeReticule = nil
SWEP.ScopeDirt = nil

SWEP.ScopeReticule_CrossCol = false
SWEP.ScopeReticule_Scale = {1, 1}
--[[End of Tweakable Parameters]]--

SWEP.Scoped_3D				= true
SWEP.BoltAction_3D		= false

if !GetConVar("cl_tfa_3dscope") then
	CreateClientConVar("cl_tfa_3dscope",1,true,true)
end

function SWEP:Do3DScope()
	return GetConVarNumber("cl_tfa_3dscope","1")==1
end

function SWEP:UpdateScopeType()
	if self:Do3DScope() then
		self.Scoped = false
		self.Scoped_3D = true
		if !self.Secondary.ScopeZoom_Backup then
			self.Secondary.ScopeZoom_Backup = self.Secondary.ScopeZoom		
		end
		if self.BoltAction then 
			self.BoltAction_3D = true
			self.BoltAction = false
			self.DisableChambering = true
		end
		if self.Secondary.ScopeZoom and self.Secondary.ScopeZoom>0 then
			self.RTScopeFOV = 70/self.Secondary.ScopeZoom
			self.IronSightsSensitivity = 1/self.Secondary.ScopeZoom
			self.Secondary.ScopeZoom = nil
			self.Secondary.IronFOV_Backup = self.Secondary.IronFOV
			self.Secondary.IronFOV = 70
		end
	else
		self.Scoped = true
		self.Scoped_3D = false
		if self.Secondary.ScopeZoom_Backup then
			self.Secondary.ScopeZoom = self.Secondary.ScopeZoom_Backup
		else
			self.Secondary.ScopeZoom = 4
		end		
		if self.BoltAction_3D then 
			self.BoltAction = true
			self.BoltAction_3D = nil
		end
		self.Secondary.IronFOV = 70/self.Secondary.ScopeZoom	
		self.IronSightsSensitivity = 1
	end
	self.DefaultFOV = GetConVarNumber("fov_desired",90)
end

if !SWEP.Callback then
	SWEP.Callback = {}
end

SWEP.Callback.Initialize = function(self)
	self:UpdateScopeType()
	timer.Simple(0,function()
		if IsValid(self) then
			self:UpdateScopeType()
			if SERVER then
				self:CallOnClient("UpdateScopeType","")
			end
		end
	end)
end

SWEP.Callback.Deploy = function(self)
	if SERVER then self:CallOnClient("UpdateScopeType","") end
	self:UpdateScopeType()
	timer.Simple(0,function()
		if IsValid(self) then
			self:UpdateScopeType()
			if SERVER then
				self:CallOnClient("UpdateScopeType","")
			end
		end
	end)
end

local cd = {}

local crosscol = Color(255,255,255,255)

SWEP.RTOpaque = true

SWEP.RTCode = function( self, rt, scrw, scrh )
	
	if !self.myshadowmask then self.myshadowmask = Material(self.ScopeShadow and self.ScopeShadow or "vgui/scope_shadowmask") end
	if !self.myreticule then self.myreticule = Material(self.ScopeReticule and self.ScopeReticule or "scope/gdcw_scopesightonly") end
	if !self.mydirt then self.mydirt = Material(self.ScopeDirt and self.ScopeDirt or "vgui/scope_dirt") end

	local vm = self.Owner:GetViewModel()
	
	if !self.LastOwnerPos then self.LastOwnerPos = self.Owner:GetShootPos() end
	
	local owoff = self.Owner:GetShootPos() - self.LastOwnerPos
	
	self.LastOwnerPos = self.Owner:GetShootPos()
	
	
	local att = vm:GetAttachment(3)
	if !att then return end
	
	local pos = att.Pos - owoff
	
	local scrpos = pos:ToScreen()
	
	scrpos.x = scrpos.x - scrw/2 + self.ScopeOverlayTransforms[1]
	scrpos.y = scrpos.y - scrh/2 + self.ScopeOverlayTransforms[2]
	
	--scrpos.x = scrpos.x * ( 2 - self.CLIronSightsProgress*1 )
	--scrpos.y = scrpos.y * ( 2 - self.CLIronSightsProgress*1 )
	
	scrpos.x = scrpos.x * self.ScopeOverlayTransformMultiplier
	scrpos.y = scrpos.y * self.ScopeOverlayTransformMultiplier
	
	if !self.scrpos then self.scrpos = scrpos end
	
	self.scrpos.x = math.Approach( self.scrpos.x, scrpos.x, (scrpos.x-self.scrpos.x)*FrameTime()*10 )
	self.scrpos.y = math.Approach( self.scrpos.y, scrpos.y, (scrpos.y-self.scrpos.y)*FrameTime()*10 )
	
	scrpos = self.scrpos
	
	render.OverrideAlphaWriteEnable( true, true)
	surface.SetDrawColor(color_white)
	surface.DrawRect(-512,-512,1024,1024)
	render.OverrideAlphaWriteEnable( true, true)
	
	local ang = EyeAngles()
	
	local AngPos = self.Owner:GetViewModel():GetAttachment(3)
	
	if AngPos then
	
		ang = AngPos.Ang
		for k,v in pairs(self.ScopeAngleTransforms) do
			if v[1] == "P" then
				ang:RotateAroundAxis(ang:Right(),v[2])				
			elseif v[1] == "Y" then
				ang:RotateAroundAxis(ang:Up(),v[2])			
			elseif v[1] == "R" then
				ang:RotateAroundAxis(ang:Forward(),v[2])		
			end
		end
	end
	
	cd.angles = ang
	cd.origin = self.Owner:GetShootPos()
	
	if !self.RTScopeOffset then self.RTScopeOffset = {0,0} end
	if !self.RTScopeScale then self.RTScopeScale = {1,1} end
	
	local rtow,rtoh = self.RTScopeOffset[1], self.RTScopeOffset[2]
	local rtw,rth = 512 * self.RTScopeScale[1], 512 * self.RTScopeScale[2]
	
	cd.x = 0
	cd.y = 0
	cd.w = rtw
	cd.h = rth
	cd.fov = self.RTScopeFOV
	cd.drawviewmodel = false
	cd.drawhud = false
	
	render.Clear( 0, 0, 0, 255, true, true )
	
	render.SetScissorRect(0+rtow,0+rtoh,rtw+rtow,rth+rtoh,true)
	if self.CLIronSightsProgress>0.01 and self.Scoped_3D then
		render.RenderView(cd)
	end
	render.SetScissorRect(0,0,rtw,rth,false)
	
	render.OverrideAlphaWriteEnable( false, true)	
	
	cam.Start2D()
		draw.NoTexture()
		surface.SetMaterial(self.myshadowmask)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRect(scrpos.x+rtow,scrpos.y+rtoh,rtw,rth)
		if self.ScopeReticule_CrossCol then
			crosscol.r = GetConVarNumber("cl_tfa_hud_crosshair_color_r")
			crosscol.g = GetConVarNumber("cl_tfa_hud_crosshair_color_g")
			crosscol.b = GetConVarNumber("cl_tfa_hud_crosshair_color_b")
			crosscol.a = GetConVarNumber("cl_tfa_hud_crosshair_color_a")*(1-math.Clamp(self.Owner:GetVelocity():Length()/120,0,1)*0.6)
			surface.SetDrawColor(crosscol)
		end
		surface.SetMaterial(self.myreticule)
		local tmpborderw = rtw*(1-self.ScopeReticule_Scale[1])/2*(1-math.Clamp(self.Owner:GetVelocity():Length()/120,0,1)*0.2)
		local tmpborderh = rth*(1-self.ScopeReticule_Scale[2])/2*(1-math.Clamp(self.Owner:GetVelocity():Length()/120,0,1)*0.2)
		surface.DrawTexturedRect(rtow+tmpborderw,rtoh+tmpborderh,rtw-tmpborderw*2,rth-tmpborderh*2)		
		surface.SetDrawColor(color_black)
		draw.NoTexture()
		surface.DrawRect(scrpos.x-2048+rtow, -1024+rtoh, 2048, 2048)
		surface.DrawRect(scrpos.x+rtw+rtow, -1024+rtoh, 2048, 2048)
		surface.DrawRect(-1024+rtow, scrpos.y-2048+rtoh, 2048, 2048)
		surface.DrawRect(-1024+rtow, scrpos.y+rth+rtoh, 2048, 2048)
		surface.SetDrawColor(ColorAlpha(color_black,255-255*( math.Clamp( self.CLIronSightsProgress-0.75,0,0.25 )*4 ) ) )
		surface.DrawRect(-1024+rtow, -1024+rtoh,2048,2048)
		surface.SetMaterial(self.mydirt)
		surface.SetDrawColor(ColorAlpha(color_white,128))
		surface.DrawTexturedRect(0,0,rtw,rth)
		surface.SetDrawColor(ColorAlpha(color_white,64))
		surface.DrawTexturedRectUV(rtow,rtoh,rtw,rth,2,0,0,2)
	cam.End2D()
end