local AddVel = Vector()
local ang

local limit_particle_cv  = GetConVar("cl_tfa_fx_muzzlesmoke_limited")

local SMOKEDELAY = 1.5

function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end
	if limit_particle_cv:GetBool() and self.WeaponEnt:GetOwner() ~= LocalPlayer() then return end
	self.Attachment = data:GetAttachment()
	local smokepart = "smoke_trail_tfa"
	local delay = ( self.WeaponEnt.GetStat and self.WeaponEnt:GetStat("SmokeDelay") or self.WeaponEnt.SmokeDelay )

	if self.WeaponEnt.SmokeParticle then
		smokepart = self.WeaponEnt.SmokeParticle
	elseif self.WeaponEnt.SmokeParticles then
		smokepart = self.WeaponEnt.SmokeParticles[self.WeaponEnt.DefaultHoldType or self.WeaponEnt.HoldType] or smokepart
	end

	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)

	if IsValid(self.WeaponEnt:GetOwner()) then
		if self.WeaponEnt:GetOwner() == LocalPlayer() then
			if not self.WeaponEnt:IsFirstPerson() then
				ang = self.WeaponEnt:GetOwner():EyeAngles()
				ang:Normalize()
				--ang.p = math.max(math.min(ang.p,55),-55)
				self.Forward = ang:Forward()
			else
				self.WeaponEnt = self.WeaponEnt:GetOwner():GetViewModel()
			end
			--ang.p = math.max(math.min(ang.p,55),-55)
		else
			ang = self.WeaponEnt:GetOwner():EyeAngles()
			ang:Normalize()
			self.Forward = ang:Forward()
		end
	end

	if TFA.GetMZSmokeEnabled == nil or TFA.GetMZSmokeEnabled() then
		local w = self.WeaponEnt
		local tn = w:EntIndex() .. "smokedelay"
		local a = self.Attachment
		local sp = smokepart
		if timer.Exists(tn) then timer.Remove(tn) end

		if IsValid(w.SmokePCF) then
			w.SmokePCF:StopEmission()
		end

		timer.Create(tn, delay or SMOKEDELAY, 1, function()
			if not IsValid(w) then return end

			w.SmokePCF = CreateParticleSystem(w, sp, PATTACH_POINT_FOLLOW, a)

			if IsValid(w.SmokePCF) then
				w.SmokePCF:StartEmission()
			end
		end)
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
