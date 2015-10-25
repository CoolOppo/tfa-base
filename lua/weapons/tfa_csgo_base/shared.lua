DEFINE_BASECLASS("tfa_gun_base")

SWEP.Skins = { }

SWEP.Skin = ""

SWEP.Callback = {}

function SWEP:Initialize()

	if self.Callback.Initialize then
		local val = self.Callback.Initialize(self)
		if val then return val end
	end
	
	self:SetWeaponHoldType(self.HoldType)
	
	self:SetHoldType(self.HoldType)
	
	if (!self.Primary.Damage) or (self.Primary.Damage<=0.01) then
		self:AutoDetectDamage()
	end
	
	if !self.Primary.Accuracy then
		if self.Primary.ConeSpray then
			self.Primary.Accuracy  = ( 5 / self.Primary.ConeSpray) / 90
		else
			self.Primary.Accuracy = 0.01
		end
	end
	
	if !self.Primary.IronAccuracy then
		self.Primary.IronAccuracy = self.Primary.Accuracy * 0.2
	end
	
	if GetConVarNumber("tfa_bl_"..self:GetClass(),0)==1 then
		self.Spawnable				= false
		self.AdminSpawnable			= false
		
		if SERVER then
			timer.Simple(0, function()
				if IsValid(self) then
					if IsValid(self.Owner) then
						--print("Blacklisted weapon was spawned by:")
						--print(self.Owner)
						self.Owner:StripWeapon(self:GetClass())
						if self.Owner.SetAmmo then
							self.Owner:SetAmmo( math.Clamp(self:GetAmmoReserve()-self.Primary.DefaultClip,0,99999),self:GetPrimaryAmmoType())
						end
					end
				end
			end)
		end
	end
	
	if self.MuzzleAttachment == "1" then
		self.CSMuzzleFlashes = true
	end
	
	if self.Akimbo then
		self.AutoDetectMuzzleAttachment = true
		self.MuzzleAttachmentRaw = 2-self.AnimCycle
	end	
	
	self:CreateFireModes()
	
	self:AutoDetectMuzzle()
	
	self:AutoDetectRange()
	
	self.DefaultHoldType = self.HoldType
	self.ViewModelFOVDefault = self.ViewModelFOV
	
	self.DrawCrosshairDefault = self.DrawCrosshair
	
	self:SetUpSpread()
	
	self:CorrectScopeFOV( self.DefaultFOV and self.DefaultFOV or self.Owner:GetFOV() )
	
	if CLIENT then
		self:InitMods()
		self:IconFix()
	end
	self.drawcount=0
	self.drawcount2=0
	self.canholster=false
	
	self:DetectValidAnimations()
	self:SetDeploySpeed(self.SequenceLength[ACT_VM_DRAW])
	
	if !self.Primary.ClipMax then
		self.Primary.ClipMax = self.Primary.ClipSize * 3
	end
	
	self:ResetEvents()

	self:ReadSkin()
	
	self:ReadKills()
	
	if SERVER then self:CallOnClient("ReadSkin","") end
	
end

function SWEP:AltAttack()
	if !CLIENT then return end

	local bgcolor = Color(0,0,0,255*0.78)
	local bordercol = Color(10,10,10,255)
	local scrollbar_buttoncol = Color(96,96,96,255*0.8)
	local scrollbar_gripcol = Color(162,162,162,255*0.8)
	local buttoncolor_inactive = Color(0,0,0,255*0.6)
	local buttoncolor_active = Color(162,162,162,255*0.8)--Color(191,163,48,255*0.8)
	local spellpickertextcol = Color(255,255,255,255*0.9)
	local btntextcol = Color(255,255,255,255*0.9)
	local divcolor = Color(225,225,225,225*0.8)
	local panelscale = 0.7
	
	surface.CreateFont( "TFA_CSGO_SKIN", {
		font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		size = 48,
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false
	} )
	
	local labfont = { ['font'] = "TFA_CSGO_SKIN", ['charwidth'] = 42, ['charheight'] = 48 }
		
	local Frame = vgui.Create( "DFrame" )
	local scrollpanel = vgui.Create("DScrollPanel")	
	local sbar = scrollpanel:GetVBar()
	
	function sbar:Paint( wv, hv )
		draw.RoundedBox( 0, 0, 0, wv, hv, bgcolor )
	end
	
	function sbar.btnUp:Paint( wv, hv )
		draw.RoundedBox( 0, 0, 0, wv, hv, scrollbar_buttoncol )
	end
	
	function sbar.btnDown:Paint( wv, hv )
		draw.RoundedBox( 0, 0, 0, wv, hv, scrollbar_buttoncol )
	end
	
	function sbar.btnGrip:Paint( wv, hv )
		draw.RoundedBox( 0, 0, 0, wv, hv, scrollbar_gripcol )
	end	
		
	local scrw,scrh = ScrW(),ScrH()
	local w,h = scrw*panelscale,scrw*panelscale*(scrh/scrw)--790, 790*9/16
	Frame:SetPos( (scrw-w)/2, (scrh-h)/2 )
	Frame:SetSize( w, h  )
	Frame:SetTitle( "Skin Picker" )
	Frame:SetVisible( true )
	Frame:SetDraggable( true )
	Frame:SetSizable( true )
	Frame:SetScreenLock( true )
	Frame:ShowCloseButton( true )
	Frame:MakePopup()
	Frame:SetBackgroundBlur(true)
	Frame.startTime = SysTime()
	Frame.btnMaxim:Hide(true)
	Frame.btnMinim:Hide(true)
	Frame.Paint = function(self,wv,hv)
		local x,y = self:GetPos()
		--local x,y = self:GetPos()[1],self:GetPos()[2]
		
		render.SetScissorRect(x, y, x+wv, y+hv, true)
		Derma_DrawBackgroundBlur( self, self.startTime-60 )
		render.SetScissorRect(x, y, x+wv, y+hv, false)
		
		--DrawBlurRect(x, y, wv, hv, 3, 2)
		
		draw.NoTexture()
		surface.SetDrawColor(bgcolor)
		surface.DrawRect(0,0,wv,hv)
	end
	Frame:Center()
		
	local div2 = vgui.Create("DPanel")
	div2:SetParent(Frame)
	div2:SetSize(w,2)
	div2:Dock(TOP)
	div2.Paint = function(self,wv,hv)
		draw.NoTexture()
		surface.SetDrawColor(divcolor)
		surface.DrawRect(0,0,wv,hv)
	end		
	
	scrollpanel:SetParent(Frame)
	scrollpanel:Dock(FILL)		
	scrollpanel.w = w
	
	keys = table.GetKeys( self.Skins )
	
	table.sort( keys, function( a, b )
		local namea = self.Skins[a].name
		local nameb = self.Skins[b].name
		
		local aval = string.lower( namea and namea or "" )
		
		local bval = string.lower( nameb and nameb or "" )
		
		return tostring( aval and aval or a ) < tostring( bval and bval or b )
	end )
	
	table.RemoveByValue(keys,"Stock")
	table.insert(keys, 1, "Stock")
	
	if !self.Skins["Stock"] then
		self.Skins["Stock"] = {
			['name'] = "Stock",
			['tbl'] = {}
		}
	end
	
	table.RemoveByValue(keys,"BaseClass")
	
	local yy = 0
	
	local div
	
	for i = 1, #keys do
		local k = keys[i]
		local v = self.Skins[k]
		
		local tmpw = scrollpanel.w
		if !tmpw then
			tmpw = scrollpanel:GetSize()
		end
		
		local dbtn = vgui.Create("DButton")
		dbtn:SetParent(scrollpanel)
		local name = v.name and v.name or k
		local isimage = false
		if v.image then--file.Exists( "materials/".. (v.image and v.image or "doesn'texists"), "GAME" ) then
			isimage = true
			dbtn:SetText("")
		else
			dbtn:SetText(name)
		end
		
		dbtn:SetPos(30,yy+2)
		dbtn:SetSize(100,100)
		yy=yy+100+2
		dbtn.skin = k
		dbtn:SetTextColor(btntextcol)
		
		dbtn.DoClick = function(self2)
			if IsValid(self) then
				if self.Skins and self2.skin and self.Skins[self2.skin] and self.Skins[self2.skin].tbl then
					self.Skin = self2.skin
					self:UpdateSkin()
					self:SyncToServerSkin()
					self:SaveSkin()
				end
			end
		end
			--[[
		if !isimage then
			dbtn.Paint = function(self,wv,hv)
				draw.NoTexture()
				surface.SetDrawColor(buttoncolor_inactive)
				surface.DrawRect(0,0,wv,hv)
			end
		else
		]]--
			dbtn.Paint = function(self2,wv,hv)
				draw.NoTexture()
				if !self2.mat then
					self2.mat = Material( v.image and v.image or "vgui/tfa_csgo/default_flat" )
				end
				surface.SetMaterial(self2.mat)
				surface.SetDrawColor(color_white)
				surface.DrawTexturedRect(0,0,wv,hv)
				surface.SetDrawColor(bordercol)
				draw.NoTexture()
				surface.DrawRect(0,0,2,hv)
				surface.DrawRect(wv-2,0,2,hv)
				surface.DrawRect(0,0,wv,2)
				surface.DrawRect(0,hv-2,wv,2)
			end					
		--end
		
		local dlbl = vgui.Create("DLabel")
		dlbl:SetParent(scrollpanel)
		dlbl:SetFont(labfont.font)
		local xpos = 30+100+2+32
		dlbl:SetPos(xpos,yy-100 )
		dlbl:SetSize( tmpw - xpos - 30, 100 )
		dlbl:SetText(name)
		dlbl.skin = k
		dlbl.DoClick = function(self2)
			if IsValid(self) then
				if self.Skins and self2.skin and self.Skins[self2.skin] and self.Skins[self2.skin].tbl then
					self.Skin = self2.skin
					self:UpdateSkin()
					self:SyncToServerSkin()
					self:SaveSkin()
				end
			end
		end
		
		local extrapadding = 4
		
		div = vgui.Create("DPanel")
		div:SetParent(scrollpanel)
		div:SetSize(tmpw/2,2)
		div:SetPos(0,yy + 2 + extrapadding)
		div.Paint = function(self2,wv,hv)
			if !self2.img then
				self2.img = Material("vgui/spellkaster/divgrad")
			end
			draw.NoTexture()
			surface.SetDrawColor(divcolor)
			surface.SetMaterial(self2.img)
			surface.DrawTexturedRect(0,0,wv,hv)
		end	
		
		yy=yy+4 + extrapadding*2
		
	end
	
	if div and div.Remove then div:Remove() end
	
end

function SWEP:SaveSkin()
	if CLIENT then
		if !file.Exists("tfa_csgo/","DATA") then
			file.CreateDir("tfa_csgo")
		end
		local f = file.Open("tfa_csgo/"..self:GetClass()..".txt","w","DATA")
		f:Write(self.Skin and self.Skin or "")
		f:Flush()
	end
end

function SWEP:SyncToServerSkin( skin )
	if !CLIENT then return end
	net.Start("TFA_CSGO_SKIN")
	net.WriteEntity(self)
	net.WriteString(skin and skin or "")
	net.SendToServer()
end

function SWEP:ReadSkin()
	
	if CLIENT then
		local cl = self:GetClass()
		
		if !TFA_CSGO_SKINS then
			TFA_CSGO_SKINS = {}
		end
		
		if TFA_CSGO_SKINS[cl] then
			for k,v in pairs(TFA_CSGO_SKINS[cl]) do
				self.Skins[k] = v
			end
		end
		
		local path = "tfa_csgo/"..cl..".txt"
		if file.Exists(path,"DATA") then
			local f = file.Read(path,"DATA")
			if f and v!="" then
				self.Skin = f
			end
		end
		
		self:SetNWString("skin",self.Skin)
		self:SyncToServerSkin()
	end
	
	self:UpdateSkin()
end

function SWEP:UpdateSkin()
	
	if ( CLIENT and IsValid(LocalPlayer()) and LocalPlayer() != self.Owner ) or ( SERVER ) then
		self.Skin = self:GetNWString("skin")
		if self.Skins and self.Skins[self.Skin] and self.Skins[self.Skin].tbl and self.Skins[self.Skin].tbl[1] then
			local str = self.Skins[self.Skin].tbl[1]
			if type(str) == "string" then
				self:SetMaterial(self.Skins[self.Skin].tbl[1])
			end
		end
	end
	
	if !self.Skin then self.Skin = "" end
	
	if self.Skin and self.Skins and self.Skins[self.Skin] then
		self.MaterialTable = self.Skins[self.Skin].tbl
		self.MaterialCache = nil
		self.MaterialCached = nil
		self.MaterialsCache = nil
		self.MaterialsCached = nil	
	end
end



local function UpdateStattrackMaterials( self )
	if !self.NumberMaterials then self.NumberMaterials = {} end
	
	local i=0
	while i<=9 do
		if !self.NumberMaterials[i] then
			self.NumberMaterials[i] = Material("vgui/stattrack/"..i)
		end
		i=i+1
	end
end

local function DrawStattrackNumber( self, number )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC )
	render.PushFilterMag( TEXFILTER.ANISOTROPIC )
	UpdateStattrackMaterials( self )
	draw.NoTexture()
	surface.SetMaterial(self.NumberMaterials[number and number or 0])
	surface.SetDrawColor(color_white)
	surface.DrawTexturedRect(16,0,32,48)
	render.PopFilterMin()
	render.PopFilterMag()
end

local function Stattrack_Calc( self, digit )
	local stattrack_string
	if !self.Kills then self.Kills = 0 end
	stattrack_string = tostring(math.min(math.Round(self.Kills),999999))
	while string.len(stattrack_string)<6 do
		stattrack_string = "0" .. stattrack_string
	end
	return tonumber(string.sub(stattrack_string,digit,digit))
end

SWEP.VElements = {
	["digit6"] = { type = "Quad", bone = "v_weapon.stattrack", rel = "", pos = Vector(0.25, -0.35, 0.4), angle = Angle(0, 90, 90), size = 0.01, draw_func = function( self ) 
		DrawStattrackNumber(self,Stattrack_Calc(self,6))
	end},
	["digit5"] = { type = "Quad", bone = "v_weapon.stattrack", rel = "", pos = Vector(0.25, -0.1, 0.4), angle = Angle(0, 90, 90), size = 0.01, draw_func = function( self ) 
		DrawStattrackNumber(self,Stattrack_Calc(self,5))
	end},
	["digit4"] = { type = "Quad", bone = "v_weapon.stattrack", rel = "", pos = Vector(0.25, 0.15, 0.4), angle = Angle(0, 90, 90), size = 0.01, draw_func = function( self ) 
		DrawStattrackNumber(self,Stattrack_Calc(self,4))
	end},
	["digit3"] = { type = "Quad", bone = "v_weapon.stattrack", rel = "", pos = Vector(0.25, 0.4, 0.4), angle = Angle(0, 90, 90), size = 0.01, draw_func = function( self ) 
		DrawStattrackNumber(self,Stattrack_Calc(self,3))
	end},
	["digit2"] = { type = "Quad", bone = "v_weapon.stattrack", rel = "", pos = Vector(0.25, 0.65, 0.4), angle = Angle(0, 90, 90), size = 0.01, draw_func = function( self ) 
		DrawStattrackNumber(self,Stattrack_Calc(self,2))
	end},
	["digit1"] = { type = "Quad", bone = "v_weapon.stattrack", rel = "", pos = Vector(0.25, 0.9, 0.4), angle = Angle(0, 90, 90), size = 0.01, draw_func = function( self ) 
		DrawStattrackNumber(self,Stattrack_Calc(self,1))
	end},
	["stattrak"] = { type = "Model", model = "models/weapons/tfa_csgo/stattrack.mdl", bone = "v_weapon.stattrack", rel = "", pos = Vector(0, 0, 0), angle = Angle(0, -90, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.Kills = 0

function SWEP:WriteKills()
	if CLIENT then
		--print("writing")
		--print("tfa_csgo/"..self:GetClass().."_kills.txt")
		if !file.Exists("tfa_csgo/","DATA") then
			file.CreateDir("tfa_csgo")
		end
		local f = file.Open("tfa_csgo/"..self:GetClass().."_kills.txt","w","DATA")
		f:Write(tostring(self.Kills and self.Kills or 0))
		f:Flush()
	end
end

function SWEP:ReadKills()
	if SERVER then self:CallOnClient("ReadKills","") end
	
	if CLIENT then
		local cl = self:GetClass()
		
		if !file.Exists("tfa_csgo/","DATA") then
			file.CreateDir("tfa_csgo")
		end
		
		local path = "tfa_csgo/"..self:GetClass().."_kills.txt"
		if file.Exists(path,"DATA") then
			local f = file.Read(path,"DATA")
			if f then
				--print(f)
				self.Kills = tonumber(f)
			end
		end
	end
	
end

function SWEP:IncrementKills()
	
	--print("incrementing")
	
	self.Kills = self.Kills and self.Kills+1 or 1
	self.KillIncrement = self.KillIncrement and self.KillIncrement+1 or 1
	
	if self.KillIncrement>=5 then
		self:WriteKills()
		self.KillIncrement = 0
	end
	
end

hook.Add("OnNPCKilled","Stattrack_NPC",function(npc,attacker,inflictor)
	if !SERVER then return end
	local wep
	if IsValid(inflictor) then
		wep = inflictor
		if inflictor:IsPlayer() and inflictor.GetActiveWeapon and IsValid(inflictor:GetActiveWeapon()) then
			wep = inflictor:GetActiveWeapon()
		end
	end
	
	if !IsValid(wep) then return end
	if !wep:IsWeapon() then return end
	if wep.IncrementKills then
		wep:CallOnClient("IncrementKills")
		wep:IncrementKills()
	end
end)

hook.Add("PlayerDeath","Stattrack_PLY",function(npc,inflictor,attacker)
	if !SERVER then return end
	local wep
	if IsValid(inflictor) then
		wep = inflictor
		if inflictor:IsPlayer() and inflictor.GetActiveWeapon and IsValid(inflictor:GetActiveWeapon()) then
			wep = inflictor:GetActiveWeapon()
		end
	end
	
	if !IsValid(wep) then return end
	if !wep:IsWeapon() then return end
	if wep.IncrementKills then
		wep:CallOnClient("IncrementKills")
		wep:IncrementKills()
	end
end)

function SWEP:Holster( switchtowep )
	
	if !self:OwnerIsValid() then return end
	
	self:WriteKills()
	
	if SERVER then self:CallOnClient("WriteKills","") end

	if self.Callback.Holster then
		local val = self.Callback.Holster(self, switchtowep)
		if val then return val end
	end
	
	self:SetShotgunCancel( true )
	
	self:CleanParticles()
	
	if SERVER then
		self:CallOnClient("CleanParticles","")
	end
	
	if IsValid(self.Owner:GetViewModel()) then
		self.Owner:GetViewModel():StopParticles()
	end
		
	self.PenetrationCounter = 0

	if self==switchtowep then
		return
	end
	
	if switchtowep then
		self:SetNWEntity("SwitchToWep",switchtowep)
	end
	
	self:SetReloading(false)
	self:SetDrawing(false)
	
	self:SetInspecting(false)
	
	if (CurTime()<self:GetDrawingEnd()) then
		self:SetDrawingEnd(CurTime()-1)
	end
	
	if (CurTime()<self:GetReloadingEnd()) then
		self:SetReloadingEnd(CurTime()-1)
	end
	local hasholsteringanim = self.SequenceEnabled[ACT_VM_HOLSTER] or self.SequenceEnabled[ACT_VM_HOLSTER_EMPTY]
	if self:GetCanHolster()==false and hasholsteringanim then
		if !( self:GetHolstering() and CurTime()<self:GetHolsteringEnd() ) then
			local holstertimerstring=(self.SequenceEnabled[ACT_VM_HOLSTER] and 1 or 0)..","..(self.SequenceEnabled[ACT_VM_HOLSTER_EMPTY] and 1 or 0)
			self:InitHolsterCode(holstertimerstring)
		else
			if self:GetHolsteringEnd()-CurTime()<0.05 and self:GetHolstering() then
				self:SetCanHolster(true)
				self:Holster(self:GetNWEntity("SwitchToWep",switchtowep))
				if self.ResetBonePositions then
					self:ResetBonePositions()
				end
				return true
			end
		end
	else
		self.DrawCrosshair = self.DrawCrosshairDefault or self.DrawCrosshair
		self:SendWeaponAnim( 0 )
		dholdt = self.DefaultHoldType and self.DefaultHoldType or self.HoldType
		self:SetHoldType( dholdt )
		self:SetHolstering(false)
		self:SetHolsteringEnd(CurTime()-0.1)
		local wep=self:GetNWEntity("SwitchToWep",switchtowep)
		if IsValid( wep ) and IsValid(self.Owner) and self.Owner:HasWeapon( wep:GetClass() ) then
			if CLIENT or game.SinglePlayer() then
				if self.ResetBonePositions then
					self:ResetBonePositions()
				end
				self.Owner:ConCommand("use " .. wep:GetClass())
			end
		end
		return true
	end
<<<<<<< HEAD
end

if CLIENT then
	CreateClientConVar("cl_tfa_csgo_stattrack",1,true,true)
end

function SWEP:UpdateStattrack()
	local dostattrack = GetConVarNumber("cl_tfa_csgo_stattrack",1)==1
	for k,v in pairs(self.VElements) do
		if v.stattrack then
			if v.color then 
				v.pos.z = dostattrack and 0 or 4000
			elseif v.pos then
				v.pos.z = dostattrack and 0.4 or 4000			
			end
		end
	end
end

function SWEP:Think2()
	if !self:OwnerIsValid() then return end

	if self.Callback.Think2 then
		local val = self.Callback.Think2(self)
		if val then return val end
	end
	
	self:ProcessEvents()
	self:ProcessFireMode()
	self:ProcessTimers()
	self:UserInput()
	self:IronsSprint()
	self:ProcessHoldType()
	if self.Owner:GetVelocity():Length()>self.Owner:GetWalkSpeed()*0.4 then
		--self:CleanParticles()
	end
	
	if CLIENT then
		self:UpdateStattrack()
	end
=======
>>>>>>> parent of a7a0125... Stattrack Hiding
end