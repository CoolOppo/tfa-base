EFFECT.Life = 0.2
EFFECT.XFlashSize = 0
EFFECT.FlashSize = 2
EFFECT.SmokeSize = 2
EFFECT.SparkSize = 2
EFFECT.HeatSize = 2
EFFECT.Color = Color(255, 192, 64)
EFFECT.ColorSprites = false
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
	local dot = dir:GetNormalized():Dot(GetViewEntity():EyeAngles():Forward())
	local halofac = math.abs(dot)
	local epos = ownerent:GetShootPos()
	local dlight = DynamicLight(ownerent:EntIndex())

	if (dlight) then
		dlight.pos = epos + ownerent:EyeAngles():Forward() * self.vOffset:Distance(epos) --self.vOffset - ownerent:EyeAngles():Right() * 5 + 1.05 * ownerent:GetVelocity() * FrameTime()
		dlight.r = self.Color.r
		dlight.g = self.Color.g
		dlight.b = self.Color.b
		dlight.brightness = 4.5
		dlight.decay = 200 / self.Life
		dlight.size = 128
		dlight.dietime = CurTime() + self.Life
	end

	self.Dist = self.vOffset:Distance(epos)
	self.DLight = dlight
	self.DieTime = CurTime() + self.Life
	self.OwnerEnt = ownerent
	local emitter = ParticleEmitter(self.vOffset)
	local sval = 1 - math.random(0, 1) * 2

	if self.WeaponEnt.XTick == nil then
		self.WeaponEnt.XTick = 0
	end

	self.WeaponEnt.XTick = 1 - self.WeaponEnt.XTick

	if self.WeaponEnt.XTick == 1 and self.XFlashSize > 0 then
		local particle = emitter:Add(self.ColorSprites and "effects/muzzleflashx_nemole_w" or "effects/muzzleflashx_nemole", self.vOffset + FrameTime() * AddVel)

		if (particle) then
			particle:SetVelocity(dir * 4 * self.XFlashSize)
			particle:SetLifeTime(0)
			particle:SetDieTime(self.Life / 2)
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( 8 * (halofac*0.8+0.2), 0, 1)
			--particle:SetEndSize( 0 )
			particle:SetStartSize(3 * (halofac * 0.8 + 0.2) * self.XFlashSize)
			particle:SetEndSize(8 * (halofac * 0.8 + 0.2) * self.XFlashSize)
			local r = math.Rand(-10, 10) * 3.14 / 180
			particle:SetRoll(r)
			particle:SetRollDelta(r / 5)

			if self.ColorSprites then
				particle:SetColor(self.Color.r, self.Color.g, self.Color.b)
			else
				particle:SetColor(255, 255, 255)
			end

			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFA.Particles.RegisterParticleThink(particle, TFA.Particles.FollowMuzzle)
			particle:SetPos(vector_origin)
		end
		--particle:SetStartSize( 8 * (halofac*0.8+0.2), 0, 1)
		--particle:SetEndSize( 0 )
	elseif self.XFlashSize > 0 then
		local particle = emitter:Add(self.ColorSprites and "effects/muzzleflashx_nemole_w" or "effects/muzzleflashx_nemole", self.vOffset + FrameTime() * AddVel)

		if (particle) then
			particle:SetVelocity(dir * 4 * self.FlashSize)
			particle:SetLifeTime(0)
			particle:SetDieTime(self.Life / 2)
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(2 * (halofac * 0.8 + 0.2) * 0.3 * self.FlashSize)
			particle:SetEndSize(4 * (halofac * 0.8 + 0.2) * 0.3 * self.FlashSize)
			local r = math.Rand(-10, 10) * 3.14 / 180
			particle:SetRoll(r)
			particle:SetRollDelta(r / 5)

			if self.ColorSprites then
				particle:SetColor(self.Color.r, self.Color.g, self.Color.b)
			else
				particle:SetColor(255, 255, 255)
			end

			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFA.Particles.RegisterParticleThink(particle, TFA.Particles.FollowMuzzle)
			particle:SetPos(vector_origin)
		end
	end

	local flashCount = math.Round(self.FlashSize * 8)

	for i = 1, flashCount do
		local particle = emitter:Add(self.ColorSprites and "effects/scotchmuzzleflashw" or "effects/scotchmuzzleflash4", self.vOffset + dir * 0.4 * i + FrameTime() * AddVel)

		if (particle) then
			particle:SetVelocity(dir * 48 * (0.2 + (i / flashCount) * 0.8) * self.FlashSize)
			particle:SetLifeTime(0)
			particle:SetDieTime(self.Life * 0.75)
			particle:SetStartAlpha(math.Rand(128, 255))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( 7.5 * (halofac*0.8+0.2), 0, 1)
			--particle:SetEndSize( 0 )
			particle:SetStartSize(1 * math.Rand(1, 1.5) * (1 + (flashCount - i) * (1 / flashCount * 0.9)) * self.FlashSize)
			particle:SetEndSize(5 * math.Rand(0.75, 1) * (1 + (flashCount - i) * (1 / flashCount * 0.9)) * self.FlashSize)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.rad(math.Rand(15, 30)) * sval)

			if self.ColorSprites then
				particle:SetColor(self.Color.r, self.Color.g, self.Color.b)
			else
				particle:SetColor(255, 255, 255)
			end

			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFA.Particles.RegisterParticleThink(particle, TFA.Particles.FollowMuzzle)
		end
	end

	for _ = 1, flashCount do
		local particle = emitter:Add("effects/scotchmuzzleflash1", self.vOffset + FrameTime() * AddVel)

		if (particle) then
			particle:SetVelocity(dir * 6 * self.FlashSize + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(self.Life * 2)
			particle:SetStartAlpha(math.Rand(40, 140))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( 7.5 * (halofac*0.8+0.2), 0, 1)
			--particle:SetEndSize( 0 )
			particle:SetStartSize(1 * math.Rand(1, 1.5) * self.FlashSize)
			particle:SetEndSize(14 * math.Rand(0.5, 1) * self.FlashSize)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.rad(math.Rand(30, 60)) * sval)

			if self.ColorSprites then
				particle:SetColor(self.Color.r, self.Color.g, self.Color.b)
			else
				particle:SetColor(255, 255, 255)
			end

			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			--TFA.Particles.RegisterParticleThink(particle, TFA.Particles.FollowMuzzle)
		end
	end

	local glowCount = math.ceil(self.FlashSize * 3)

	for i = 1, glowCount do
		local particle = emitter:Add("effects/scotchmuzzleflash1", self.vOffset + dir * 0.9 * i)

		if (particle) then
			--particle:SetVelocity(dir * 32 )
			particle:SetLifeTime(0)
			particle:SetDieTime(self.Life * 0.75)
			particle:SetStartAlpha(255 * (1 - halofac))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( 7.5 * (halofac*0.8+0.2), 0, 1)
			--particle:SetEndSize( 0 )
			particle:SetStartSize(math.max(12 - 12 / glowCount * i * 0.5, 1) * 0.2 * self.FlashSize)
			particle:SetEndSize(math.max(12 - 12 / glowCount * i * 0.5, 1) * 0.6 * self.FlashSize)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.rad(math.Rand(15, 30)) * sval)

			if self.ColorSprites then
				particle:SetColor(self.Color.r, self.Color.g, self.Color.b)
			else
				particle:SetColor(255, 255, 255)
			end

			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFA.Particles.RegisterParticleThink(particle, TFA.Particles.FollowMuzzle)
		end
	end

	local smokeCount = math.ceil(self.SmokeSize * 6)

	for _ = 0, smokeCount do
		local particle = emitter:Add("particles/smokey", self.vOffset + dir * math.Rand(6, 10))

		if (particle) then
			particle:SetVelocity(VectorRand() * 10 * self.SmokeSize + dir * math.Rand(15, 20) * self.SmokeSize + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.6, 0.7) * self.Life * 5)
			particle:SetStartAlpha(math.Rand(6, 10))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(5, 7) * self.SmokeSize)
			particle:SetEndSize(math.Rand(12, 14) * self.SmokeSize)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.Rand(-0.8, 0.8))
			particle:SetLighting(true)
			particle:SetAirResistance(10)
			particle:SetGravity(Vector(0, 0, 60))
			particle:SetColor(255, 255, 255)
		end
	end

	local sparkcount = math.Round(math.random(2, 4) * self.SparkSize)

	for _ = 0, sparkcount do
		local particle = emitter:Add("effects/yellowflare", self.Position)

		if (particle) then
			particle:SetVelocity((VectorRand() + Vector(0, 0, 0.3)) * 20 * Vector(0.8, 0.8, 0.6) * self.SparkSize + dir * math.Rand(45, 60) * 1 * self.SparkSize + 1.15 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(self.Life / 2, self.Life))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0.5)
			particle:SetEndSize(1.0)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetGravity(vector_origin)
			particle:SetAirResistance(0)
			particle:SetStartLength(0.2)
			particle:SetEndLength(0.1)

			if self.ColorSprites then
				particle:SetColor(self.Color.r, self.Color.g, self.Color.b)
			else
				particle:SetColor(255, math.random(192, 225), math.random(140, 192))
			end

			particle:SetVelocityScale(true)
			local sl = self.SparkSize

			particle:SetThinkFunction(function(pa)
				pa.ranvel = pa.ranvel or VectorRand() * 4
				local ft = math.min(FrameTime() * 15, 1)
				pa.ranvel.x = Lerp(ft, pa.ranvel.x, math.Rand(-4, 4))
				pa.ranvel.y = Lerp(ft, pa.ranvel.y, math.Rand(-4, 4))
				pa.ranvel.z = Lerp(ft, pa.ranvel.z, math.Rand(-4, 4))
				pa:SetVelocity(pa:GetVelocity() + pa.ranvel * 2 * sl)
				pa:SetNextThink(CurTime())
			end)

			particle:SetNextThink(CurTime() + 0.01)
		end
	end

	if TFA.GetGasEnabled() then
		for i = 0, 1 do
			local particle = emitter:Add("sprites/heatwave", self.vOffset + (dir * i))

			if (particle) then
				particle:SetVelocity((dir * 25 * i) * self.HeatSize + 1.05 * AddVel)
				particle:SetLifeTime(0)
				particle:SetDieTime(self.Life)
				particle:SetStartAlpha(math.Rand(200, 225))
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.Rand(3, 5) * self.HeatSize)
				particle:SetEndSize(math.Rand(8, 10) * self.HeatSize)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-2, 2))
				particle:SetAirResistance(5)
				particle:SetGravity(Vector(0, 0, 40))
				particle:SetColor(255, 255, 255)
			end
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	if CurTime() > self.DieTime then
		return false
	elseif self.DLight and IsValid(self.OwnerEnt) then
			self.DLight.pos = self.OwnerEnt:GetShootPos() + self.OwnerEnt:EyeAngles():Forward() * self.Dist
	end

	return true
end

function EFFECT:Render()
end