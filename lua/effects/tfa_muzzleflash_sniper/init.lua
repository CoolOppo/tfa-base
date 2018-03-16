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
	dir = self.Forward

	local owner = self.WeaponEnt:GetOwner()
	if not IsValid(ownerent) then
		ownerent = LocalPlayer()
	end
	AddVel = ownerent:GetVelocity()

	self.vOffset = self.Position
	dir = self.Forward
	AddVel = AddVel * 0.05
	local dot = dir:GetNormalized():Dot(GetViewEntity():EyeAngles():Forward())
	local dotang = math.deg(math.acos(math.abs(dot)))
	local halofac = math.abs(dot)
	local epos = ownerent:GetShootPos()

	local dlight = DynamicLight(ownerent:EntIndex())

	if (dlight) then
		dlight.pos = epos + ownerent:EyeAngles():Forward() * self.vOffset:Distance(epos) + 1.05 * ownerent:GetVelocity() * FrameTime()--self.vOffset - ownerent:EyeAngles():Right() * 5 + 1.05 * ownerent:GetVelocity() * FrameTime()
		dlight.r = 255
		dlight.g = 192
		dlight.b = 64
		dlight.brightness = 4.5
		dlight.Decay = 500
		dlight.Size = 128
		dlight.DieTime = CurTime() + 0.2
	end

	local emitter = ParticleEmitter(self.vOffset)
	local sval = 1-math.random(0,1)*2

	if self.WeaponEnt.XTick == nil then
		self.WeaponEnt.XTick = 0
	end

	self.WeaponEnt.XTick = 1 - self.WeaponEnt.XTick

	if self.WeaponEnt.XTick == 1 then
		local particle = emitter:Add("effects/muzzleflashX_nemole", self.vOffset)

		if (particle) then
			particle:SetVelocity(dir * 4 + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.1)
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( 8 * (halofac*0.8+0.2), 0, 1)
			--particle:SetEndSize( 0 )
			particle:SetStartSize(3 * (halofac * 0.8 + 0.2), 0, 1)
			particle:SetEndSize(8 * (halofac * 0.8 + 0.2), 0, 1)
			local r = math.Rand(-10, 10) * 3.14 / 180
			particle:SetRoll(r)
			particle:SetRollDelta(r / 5)
			particle:SetColor(255, 255, 255)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFARegPartThink(particle, TFAMuzzlePartFunc)
			particle:SetPos(vector_origin)
		end
		--particle:SetStartSize( 8 * (halofac*0.8+0.2), 0, 1)
		--particle:SetEndSize( 0 )
	else
		local particle = emitter:Add("effects/muzzleflashX_nemole", self.vOffset)

		if (particle) then
			particle:SetVelocity(dir * 4 + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.1)
			particle:SetStartAlpha(math.Rand(200, 255))
			particle:SetEndAlpha(0)
			particle:SetStartSize(3 * (halofac * 0.8 + 0.2) * 0.3, 0, 1)
			particle:SetEndSize(8 * (halofac * 0.8 + 0.2) * 0.3, 0, 1)
			local r = math.Rand(-10, 10) * 3.14 / 180
			particle:SetRoll(r)
			particle:SetRollDelta(r / 5)
			particle:SetColor(255, 255, 255)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFARegPartThink(particle, TFAMuzzlePartFunc)
			particle:SetPos(vector_origin)
		end
	end

	for i = 1, 8 do
		local particle = emitter:Add("effects/scotchmuzzleflash4", self.vOffset + dir*0.4*i)

		if (particle) then
			particle:SetVelocity(dir * 32 + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.2)
			particle:SetStartAlpha(math.Rand(128,255) * (halofac * 0.8 + 0.2))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( 7.5 * (halofac*0.8+0.2), 0, 1)
			--particle:SetEndSize( 0 )
			particle:SetStartSize(1 * (halofac * 0.8 + 0.2) * math.Rand(1,1.5) * (1+(8-i)*0.1) )
			particle:SetEndSize(6 * (halofac * 0.8 + 0.2) * math.Rand(0.75,1) * (1+(8-i)*0.1) )
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.rad(math.Rand(15,30)) * sval)
			particle:SetColor(255, 255, 255)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFARegPartThink(particle, TFAMuzzlePartFunc)
		end
	end
	for i = 1, 8 do
		local particle = emitter:Add("effects/scotchmuzzleflash1", self.vOffset )

		if (particle) then
			particle:SetVelocity(dir * 6 + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.5)
			particle:SetStartAlpha(math.Rand(40,140))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( 7.5 * (halofac*0.8+0.2), 0, 1)
			--particle:SetEndSize( 0 )
			particle:SetStartSize(1 * (halofac * 0.8 + 0.2) * math.Rand(1,1.5) )
			particle:SetEndSize(14 * (halofac * 0.8 + 0.2) * math.Rand(0.5,1) )
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.rad(math.Rand(30,60)) * sval)
			particle:SetColor(255, 255, 255)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			--TFARegPartThink(particle, TFAMuzzlePartFunc)
		end
	end

	for i = 1, 5 do
		local particle = emitter:Add("effects/scotchmuzzleflash4", self.vOffset + dir*1.2*i)

		if (particle) then
			--particle:SetVelocity(dir * 32 + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(0.2)
			particle:SetStartAlpha(255 * (1-halofac))
			particle:SetEndAlpha(0)
			--particle:SetStartSize( 7.5 * (halofac*0.8+0.2), 0, 1)
			--particle:SetEndSize( 0 )
			particle:SetStartSize(math.max(12 - 2 * i, 1) * 0.3)
			particle:SetEndSize(math.max(12 - 2 * i, 1) * 0.6)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.rad(math.Rand(15,30)) * sval)
			particle:SetColor(255, 255, 255)
			particle:SetLighting(false)
			particle.FollowEnt = self.WeaponEnt
			particle.Att = self.Attachment
			TFARegPartThink(particle, TFAMuzzlePartFunc)
		end
	end

	for i = 0, 6 do
		local particle = emitter:Add("particles/smokey", self.vOffset + dir * math.Rand(6, 10))

		if (particle) then
			particle:SetVelocity(VectorRand() * 10 + dir * math.Rand(15, 20) + 1.05 * AddVel)
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.6, 0.7))
			particle:SetStartAlpha(math.Rand(6, 10))
			particle:SetEndAlpha(0)
			particle:SetStartSize(math.Rand(5, 7))
			particle:SetEndSize(math.Rand(12, 14))
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetRollDelta(math.Rand(-0.8, 0.8))
			particle:SetLighting(true)
			particle:SetAirResistance(10)
			particle:SetGravity(Vector(0, 0, 60))
			particle:SetColor(255, 255, 255)
		end
	end

	local sparkcount = math.random(6,10)

	for i = 0, sparkcount do
		local particle = emitter:Add("effects/yellowflare", self.Position)

		if (particle) then
			particle:SetVelocity( ((VectorRand() + Vector(0, 0, 0.3)) * 10 * Vector(0.8, 0.8, 0.6) + dir * math.Rand(45, 60) * 1.1 + 1.15 * AddVel) * 0.7 )
			particle:SetLifeTime(0)
			particle:SetDieTime(math.Rand(0.2, 0.4))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(0.5)
			particle:SetEndSize(1.0)
			particle:SetRoll(math.rad(math.Rand(0, 360)))
			particle:SetGravity(vector_origin)
			particle:SetAirResistance(20)
			particle:SetStartLength(0.4)
			particle:SetEndLength(0.1)
			particle:SetColor(255, math.random(192,225), math.random(140,192))
			particle:SetVelocityScale(true)

			particle:SetThinkFunction(function(pa)
				pa.ranvel = pa.ranvel or VectorRand() * 4
				pa.ranvel.x = math.Approach(pa.ranvel.x, math.Rand(-4, 4), 0.5)
				pa.ranvel.y = math.Approach(pa.ranvel.y, math.Rand(-4, 4), 0.5)
				pa.ranvel.z = math.Approach(pa.ranvel.z, math.Rand(-4, 4), 0.5)
				pa:SetVelocity(pa:GetVelocity() + pa.ranvel )
				pa:SetNextThink(CurTime() + 0.01)
			end)

			particle:SetNextThink(CurTime() + 0.01)
		end
	end

	if TFA.GetGasEnabled() then
		for i = 0, 1 do
			local particle = emitter:Add("sprites/heatwave", self.vOffset + (dir * i))

			if (particle) then
				particle:SetVelocity((dir * 25 * i) + 1.05 * AddVel)
				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(0.05, 0.15))
				particle:SetStartAlpha(math.Rand(200, 225))
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.Rand(3, 5))
				particle:SetEndSize(math.Rand(8, 10))
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
	return false
end

function EFFECT:Render()
end
