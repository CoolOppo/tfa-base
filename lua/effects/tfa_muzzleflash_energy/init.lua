local AddVel = Vector()
local ang

function EFFECT:Init(data)
	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end
	self.Attachment = data:GetAttachment()
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)

	if IsValid(self.WeaponEnt:GetOwner()) then
		if self.WeaponEnt:GetOwner() == LocalPlayer() then
			if self.WeaponEnt:GetOwner():ShouldDrawLocalPlayer() then
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

	self.Forward = self.Forward or data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	self.vOffset = self.Position
	local dir = self.Forward
	local ownerent = self.WeaponEnt:GetOwner()

	if not IsValid(ownerent) then
		ownerent = LocalPlayer()
	end

	AddVel = ownerent:GetVelocity()
	self.vOffset = self.Position
	AddVel = AddVel * 0.05
	local dlight = DynamicLight(ownerent:EntIndex())

	if (dlight) then
		dlight.Pos = self.Position + dir * 1 - dir:Angle():Right() * 5
		dlight.r = 25
		dlight.g = 200
		dlight.b = 255
		dlight.Brightness = 4.0
		dlight.size = 128
		dlight.DieTime = CurTime() + 0.03
	end

	ParticleEffectAttach("tfa_muzzle_energy", PATTACH_POINT_FOLLOW, self.WeaponEnt, data:GetAttachment())
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end