local att
local flashlightdot
local flashlightFOV = 60
local angpos
local traceres
SWEP.FlashLightDistance = 12 * 50 -- default 50 feet
SWEP.FlashLightAttachment = 1

local function IsHolstering(wep)
	if IsValid(wep) and TFA.Enum.HolsterStatus[wep:GetStatus()] then return true end

	return false
end

function SWEP:DrawFlashLight(is_vm)
	if not flashlightdot then
		flashlightdot = Material(self.FlashLightMaterial or "effects/flashlight001")
	end

	if is_vm then
		if not self:VMIV() then
			self:CleanFlashLight()

			return
		end

		att = self:GetStat("FlashLightAttachment")

		if (not att) or att <= 0 then
			self:CleanFlashLight()

			return
		end

		angpos = self.OwnerViewModel:GetAttachment(att)

		if not angpos then
			self:CleanFlashLight()

			return
		end

		if self.FlashLightISMovement and self.CLIronSightsProgress > 0 then
			local isang = self:GetStat("IronSightsAng")
			angpos.Ang:RotateAroundAxis(angpos.Ang:Right(), isang.y * (self.ViewModelFlip and -1 or 1) * self.CLIronSightsProgress)
			angpos.Ang:RotateAroundAxis(angpos.Ang:Up(), -isang.x * self.CLIronSightsProgress)
		end

		local localProjAng = select(2, WorldToLocal(vector_origin, angpos.Ang, vector_origin, EyeAngles()))
		localProjAng.p = localProjAng.p * self:GetOwner():GetFOV() / self.ViewModelFOV
		localProjAng.y = localProjAng.y * self:GetOwner():GetFOV() / self.ViewModelFOV
		local wsProjAng = select(2, LocalToWorld(vector_origin, localProjAng, vector_origin, EyeAngles())) --reprojection for trace angle
		traceres = util.QuickTrace(self:GetOwner():GetShootPos(), wsProjAng:Forward() * 999999, self:GetOwner())
		local ply = self:GetOwner()

		if not IsValid(ply.TFAFlashLightGun) and not IsHolstering(self) then
			local lamp = ProjectedTexture()
			ply.TFAFlashLightGun = lamp
			lamp:SetTexture(flashlightdot:GetString("$basetexture"))
			lamp:SetFarZ(self.FlashLightDistance) -- How far the light should shine
			lamp:SetFOV(flashlightFOV)
			lamp:SetPos(angpos.Pos)
			lamp:SetAngles(angpos.Ang)
			lamp:SetBrightness(1.4 + 0.1 * math.max(math.sin(CurTime() * 120), math.cos(CurTime() * 40)))
			lamp:SetNearZ(1)
			lamp:SetColor(color_white)
			lamp:SetEnableShadows(true)
			lamp:Update()
		end

		local lamp = ply.TFAFlashLightGun

		if IsValid(lamp) then
			local lamppos = EyePos() + EyeAngles():Up() * 4
			local ang = (traceres.HitPos - lamppos):Angle()
			self.flashlightpos_old = traceres.HitPos
			lamp:SetPos(lamppos)
			lamp:SetAngles(ang)
			lamp:SetBrightness(1.4 + 0.1 * math.max(math.sin(CurTime() * 120), math.cos(CurTime() * 40)))
			lamp:Update()
		end
	else
		att = self:GetStat("FlashLightAttachmentWorld")

		if (not att) or att <= 0 then
			att = self:GetStat("FlashLightAttachment")
		end

		if (not att) or att <= 0 then
			self:CleanFlashLight()

			return
		end

		angpos = self:GetAttachment(att)

		if not angpos then
			angpos = self:GetAttachment(1)
		end

		if not angpos then
			self:CleanFlashLight()

			return
		end

		local ply = self:GetOwner()

		if not IsValid(ply.TFAFlashLightGun) and not IsHolstering(self) then
			local lamp = ProjectedTexture()
			ply.TFAFlashLightGun = lamp
			lamp:SetTexture(flashlightdot:GetString("$basetexture"))
			lamp:SetFarZ(self.FlashLightDistance) -- How far the light should shine
			lamp:SetFOV(flashlightFOV)
			lamp:SetPos(angpos.Pos)
			lamp:SetAngles(angpos.Ang)
			lamp:SetBrightness(1.4 + 0.1 * math.max(math.sin(CurTime() * 120), math.cos(CurTime() * 40)))
			lamp:SetNearZ(1)
			lamp:SetColor(color_white)
			lamp:SetEnableShadows(false)
			lamp:Update()
		end

		local lamp = ply.TFAFlashLightGun

		if IsValid(lamp) then
			local lamppos = angpos.Pos
			local ang = angpos.Ang
			lamp:SetPos(lamppos)
			lamp:SetAngles(ang)
			lamp:SetBrightness(1.4 + 0.1 * math.max(math.sin(CurTime() * 120), math.cos(CurTime() * 40)))
			lamp:Update()
		end
	end
end

function SWEP:CleanFlashLight()
	local ply = self:GetOwner()

	if IsValid(ply) and IsValid(ply.TFAFlashLightGun) then
		ply.TFAFlashLightGun:Remove()
	end
end

hook.Add("PostPlayerDraw", "TFA_FlashLight", function(plyv)
	local wep = plyv:GetActiveWeapon()

	if IsValid(wep) and wep:IsTFA() and (plyv ~= LocalPlayer() or not wep:IsFirstPerson()) then
		wep:DrawFlashLight(false)
	end
end)