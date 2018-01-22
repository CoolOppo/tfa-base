local bvec = Vector(0, 0, 0)
local uAng = Angle(90, 0, 0)

EFFECT.Velocity = {120,160}
EFFECT.ShellPresets = {
	["sniper"] = { "models/hdweapons/rifleshell.mdl", 0.487 / 1.236636, 90 },--1.236636 is shell diameter, then divide base diameter into that for 7.62x54mm
	["rifle"] = { "models/hdweapons/rifleshell.mdl", 0.4709 / 1.236636, 90 },--1.236636 is shell diameter, then divide base diameter into that for standard nato rifle
	["pistol"] = { "models/hdweapons/shell.mdl", 0.391 / 0.955581, 90 },--0.955581 is shell diameter, then divide base diameter into that for 9mm luger
	["smg"] = { "models/hdweapons/shell.mdl", .476 / 0.955581, 90 },--.45 acp
	["shotgun"] = { "models/hdweapons/shotgun_shell.mdl", 1, 90 }
}
EFFECT.SoundFiles 	= { Sound(")player/pl_shell1.wav"),Sound(")player/pl_shell2.wav"),Sound(")player/pl_shell3.wav")}
EFFECT.SoundFilesSG 	= { Sound(")weapons/fx/tink/shotgun_shell1.wav"),Sound(")weapons/fx/tink/shotgun_shell2.wav"),Sound(")weapons/fx/tink/shotgun_shell3.wav")}
EFFECT.SoundLevel = {60,80}
EFFECT.SoundPitch = {80,120}
EFFECT.LifeTime = 15
EFFECT.FadeTime = 0.5

EFFECT.SmokeRate = 60 --Particles per second, multiplied by velocity down to 10%
EFFECT.SmokeTime = {0.7,1.4}
EFFECT.SmokeThickness = {2,2} --Particles on each puff

local cv_eject
local cv_life

function EFFECT:Init(data)
	if not cv_eject then
		cv_eject = GetConVar("cl_tfa_fx_ejectionsmoke")
	end
	if not cv_life then
		cv_life = GetConVar("cl_tfa_fx_ejectionlife")
	end
	if cv_life then
		self.LifeTime = cv_life:GetFloat()
	end
	
	self.StartTime = CurTime()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.SmokeDelta = 0
	if cv_eject:GetBool() then
		self.SmokeDeath = self.StartTime + math.Rand(self.SmokeTime[1],self.SmokeTime[2])
	else
		self.SmokeDeath = -1
	end

	self.Position = bvec
	self.WeaponEnt = data:GetEntity()
	if not IsValid(self.WeaponEnt) then return end
	self.WeaponEntOG = self.WeaponEnt
	if self.WeaponEntOG.LuaShellEffect and self.WeaponEntOG.LuaShellEffect == "" then return end
	self.Attachment = data:GetAttachment()
	self.Dir = data:GetNormal()
	local owent = self.WeaponEnt:GetOwner()

	if self.LifeTime <= 0 or not IsValid(owent) then
		self.StartTime = -1000
		self.SmokeDeath = -1000
		return
	end

	if owent:IsPlayer() then
		if owent ~= LocalPlayer() or owent:ShouldDrawLocalPlayer() then
			self.WeaponEnt = owent:GetActiveWeapon()
			if not IsValid(self.WeaponEnt) then return end
		else
			self.WeaponEnt = owent:GetViewModel()
			local theirweapon = owent:GetActiveWeapon()

			if IsValid(theirweapon) and theirweapon.ViewModelFlip or theirweapon.ViewModelFlipped then
				self.Flipped = true
			end

			if not IsValid(self.WeaponEnt) then return end
		end
	end

	if IsValid(self.WeaponEntOG) and self.WeaponEntOG.ShellAttachment then
		self.Attachment = self.WeaponEnt:LookupAttachment(self.WeaponEntOG.ShellAttachment)

		if not self.Attachment or self.Attachment <= 0 then
			self.Attachment = 2
		end

		if self.WeaponEntOG.Akimbo then
			self.Attachment = 3 + ( game.SinglePlayer() and self.WeaponEntOG:GetNW2Int("AnimCycle",1) or self.WeaponEntOG.AnimCycle )
		end

		if self.WeaponEntOG.ShellAttachmentRaw then
			self.Attachment = self.WeaponEntOG.ShellAttachmentRaw
		end
	end

	local angpos = self.WeaponEnt:GetAttachment(self.Attachment)

	if not angpos or not angpos.Pos then
		angpos = {
			Pos = bvec,
			Ang = uAng
		}
	end

	local model, scale, yaw = self:FindModel(self.WeaponEntOG)

	model = self.WeaponEntOG.ShellModel or self.WeaponEntOG.LuaShellModel or model
	scale = self.WeaponEntOG.ShellScale or self.WeaponEntOG.LuaShellScale or scale
	yaw = self.WeaponEntOG.ShellYaw or self.WeaponEntOG.LuaShellYaw or yaw
	
	if model:lower():find("shotgun") then
		self.Shotgun = true
	end

	self:SetModel(model)
	self:SetModelScale(scale,0)
	self:SetPos(angpos.Pos)
	local mdlang = angpos.Ang * 1
	mdlang:RotateAroundAxis(mdlang:Up(),yaw)
	self:SetAngles(mdlang)

	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetCollisionBounds(self:OBBMins(),self:OBBMaxs())

	self:PhysicsInitBox(self:OBBMins(),self:OBBMaxs())

	local velocity = angpos.Ang:Forward() * math.Rand( self.Velocity[1],self.Velocity[2] )
	if IsValid(owent) then
		velocity = velocity + owent:GetVelocity()
	end

	local physObj = self:GetPhysicsObject()

	if physObj:IsValid() then

		physObj:SetDamping(0.1,1)
		physObj:SetMass(5)
		physObj:SetMaterial("gmod_silent")
		physObj:SetVelocity(velocity)
		physObj:AddAngleVelocity(VectorRand() * velocity:Length()*5)
	end
end

function EFFECT:FindModel( wep )
	if not IsValid(wep) then
		return unpack(self.ShellPresets["rifle"])
	end

	local ammotype =  (wep.Primary.Ammo or wep:GetPrimaryAmmoType()):lower()
	local guntype = (wep.Type or wep:GetHoldType()):lower()

	if guntype:find("sniper") or ammotype:find("sniper") or guntype:find("dmr") then
		return unpack(self.ShellPresets["sniper"])
	elseif guntype:find("rifle") or ammotype:find("rifle") then
		return unpack(self.ShellPresets["rifle"])
	elseif ammotype:find("pist") or guntype:find("pist") then
		return unpack(self.ShellPresets["pistol"])
	elseif ammotype:find("smg") or guntype:find("smg") then
		return unpack(self.ShellPresets["smg"])
	elseif ammotype:find("buckshot") or ammotype:find("shotgun") or guntype:find("shot") then
		return unpack(self.ShellPresets["shotgun"])
	end
	return unpack(self.ShellPresets["rifle"])
end

function EFFECT:BounceSound()
	local snd = self.Shotgun and self.SoundFilesSG[math.random(1,#self.SoundFiles)] or self.SoundFiles[math.random(1,#self.SoundFiles)]
	sound.Play(snd,self:GetPos(),math.Rand(self.SoundLevel[1],self.SoundLevel[2]),math.Rand(self.SoundPitch[1],self.SoundPitch[2]))
end

function EFFECT:PhysicsCollide(data)
	if data.Speed > 60 then
		self:BounceSound()
		local impulse = (data.OurOldVelocity - 2 * data.OurOldVelocity:Dot(data.HitNormal) * data.HitNormal)*0.33
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:ApplyForceCenter(impulse)
		end
	end
end

function EFFECT:Think()
	if CurTime() < self.SmokeDeath then
		self.SmokeDelta = self.SmokeDelta + FrameTime() * math.Clamp( self:GetVelocity():Length() / self.Velocity[1], 0.2, 1.5 )
		self.LastSysTime = SysTime()
		local pos = self:GetPos()
		while ( self.SmokeDelta > 1/self.SmokeRate ) do
			self.SmokeDelta = self.SmokeDelta - 1/self.SmokeRate
			local thicc = math.random(self.SmokeThickness[1],self.SmokeThickness[2])
			self.Emitter:SetPos(pos)
			for i = 0, thicc do
				local particle = self.Emitter:Add("particles/smokey", pos)
		
				if (particle) then
					particle:SetVelocity(VectorRand() * (5*math.sqrt(thicc)) + self:GetVelocity() * 0.1 )
					particle:SetLifeTime(0)
					particle:SetDieTime(math.Rand(0.6, 0.7))
					particle:SetStartAlpha(math.Rand(16, 32))
					particle:SetEndAlpha(0)
					particle:SetStartSize(math.Rand(0.75,1.5))
					particle:SetEndSize(math.Rand(3, 4))
					particle:SetRoll(math.rad(math.Rand(0, 360)))
					particle:SetRollDelta(math.Rand(-0.8, 0.8))
					particle:SetLighting(true)
					particle:SetAirResistance(10)
					particle:SetGravity(Vector(0, 0, 60))
					particle:SetColor(255, 255, 255)
				end
			end
		end
	end
	if CurTime() > self.StartTime + self.LifeTime then
		if self.Emitter then
			self.Emitter:Finish()
		end
		return false
	else
		return true
	end
end

function EFFECT:Render()
	self:SetColor(ColorAlpha(color_white, (1 - math.Clamp( CurTime() - ( self.StartTime + self.LifeTime - self.FadeTime ),0,self.FadeTime ) / self.FadeTime) * 255 ) )
	self:SetupBones()
	self:DrawModel()
end
