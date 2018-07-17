local nvec = Vector()

if SERVER then
	hook.Add("Tick", "NetworkTFAColors", function()
		for _, v in pairs(player.GetAll()) do
			local f = v.SetNW2Vector or v.SetNWVector
			nvec.x = v:GetInfoNum("cl_tfa_laser_color_r", 255)
			nvec.y = v:GetInfoNum("cl_tfa_laser_color_g", 0)
			nvec.z = v:GetInfoNum("cl_tfa_laser_color_b", 0)
			f(v, "TFALaserColor", nvec)
			nvec.x = v:GetInfoNum("cl_tfa_reticule_color_r", 255)
			nvec.y = v:GetInfoNum("cl_tfa_reticule_color_g", 0)
			nvec.z = v:GetInfoNum("cl_tfa_reticule_color_b", 0)
			f(v, "TFAReticuleColor", nvec)
		end
	end)
end

if not matproxy then return end

matproxy.Add({
	name = "PlayerWeaponColorStatic",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		if (not IsValid(ent)) then return end
		local owner = ent:GetOwner()
		if (not IsValid(owner) or not owner:IsPlayer()) then return end
		local col = owner:GetWeaponColor()
		if (not isvector(col)) then return end
		mat:SetVector(self.ResultTo, col * 1)
	end
})

local cvec = Vector()

matproxy.Add({
	name = "TFALaserColor",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		local owner

		if (IsValid(ent)) then
			owner = ent:GetOwner()

			if not IsValid(owner) then
				owner = ent:GetParent()
			end

			if IsValid(owner) and owner:IsWeapon() then
				owner = owner:GetOwner() or owner:GetOwner()
			end

			if not (IsValid(owner) and owner:IsPlayer()) then
				owner = GetViewEntity()
			end
		else
			owner = GetViewEntity()
		end

		if (not IsValid(owner) or not owner:IsPlayer()) then return end
		local c

		if owner.GetNW2Vector then
			c = owner:GetNW2Vector("TFALaserColor") or cvec
		else
			c = owner:GetNWVector("TFALaserColor") or cvec
		end

		cvec.x = math.sqrt(c.r / 255) --sqrt for gamma
		cvec.y = math.sqrt(c.g / 255)
		cvec.z = math.sqrt(c.b / 255)
		mat:SetVector(self.ResultTo, cvec)
	end
})

local cvec_r = Vector()

matproxy.Add({
	name = "TFAReticuleColor",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
	end,
	bind = function(self, mat, ent)
		local owner

		if (IsValid(ent)) then
			owner = ent:GetOwner()

			if not IsValid(owner) then
				owner = ent:GetParent()
			end

			if IsValid(owner) and owner:IsWeapon() then
				owner = owner:GetOwner() or owner:GetOwner()
			end

			if not (IsValid(owner) and owner:IsPlayer()) then
				owner = GetViewEntity()
			end
		else
			owner = GetViewEntity()
		end

		if (not IsValid(owner) or not owner:IsPlayer()) then return end
		local c

		if owner.GetNW2Vector then
			c = owner:GetNW2Vector("TFAReticuleColor") or cvec_r
		else
			c = owner:GetNWVector("TFAReticuleColor") or cvec_r
		end

		cvec_r.x = c.r / 255
		cvec_r.y = c.g / 255
		cvec_r.z = c.b / 255
		mat:SetVector(self.ResultTo, cvec_r)
	end
})

matproxy.Add({
	name = "TFA_RTScope",
	init = function(self, mat, values)
		self.RTMaterial = Material("!tfa_rtmaterial")
	end,
	bind = function(self, mat, ent)
		if not self.RTMaterial then
			self.RTMaterial = Material("!tfa_rtmaterial")
		end

		mat:SetTexture("$basetexture", self.RTMaterial:GetTexture("$basetexture"))
	end
})