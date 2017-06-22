local fx, sp

function SWEP:PCFTracer( bul, hitpos, ovrride )
	if bul.PCFTracer then
		self:UpdateMuzzleAttachment()
		local mzp = self:GetMuzzlePos()
		if bul.PenetrationCount > 0 and not ovrride then return end --Taken care of with the pen effect
		if ( CLIENT or game.SinglePlayer() ) and self.Scoped and self:IsCurrentlyScoped() and self:IsFirstPerson() then
			TFA.ParticleTracer( bul.PCFTracer, self:GetOwner():GetShootPos() - self:GetOwner():EyeAngles():Up() * 5 , hitpos, false, 0, -1 )
		else
			local vent = self
			if ( CLIENT or game.SinglePlayer() ) and self:IsFirstPerson() then
				vent = self.OwnerViewModel
			end
			if game.SinglePlayer() and not self:IsFirstPerson() then
				TFA.ParticleTracer( bul.PCFTracer, self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 32, hitpos, false )
			else
				TFA.ParticleTracer( bul.PCFTracer, mzp.Pos, hitpos, false, vent, self.MuzzleAttachmentRaw or 1 )
			end
		end
	end
end

function SWEP:EventShell()
	if SERVER then
		net.Start( "tfaBaseShellSV" )
		net.WriteEntity(self)
		net.SendOmit(self:GetOwner())
	else
		self:EjectionSmoke(true)
		self:MakeShellBridge(true)
	end
end

function SWEP:MakeShellBridge(ifp)
	if ifp then
		if self.LuaShellEjectDelay > 0 then
			self.LuaShellRequestTime = CurTime() + self.LuaShellEjectDelay / self:NZAnimationSpeed( ACT_VM_PRIMARYATTACK )
		else
			self:MakeShell()
		end
	end
end

function SWEP:MakeShell()
	if IsValid(self) and self:VMIV() then
		local vm = (not self:GetOwner().ShouldDrawLocalPlayer or self:GetOwner():ShouldDrawLocalPlayer()) and self.OwnerViewModel or self

		if IsValid(vm) then
			fx = EffectData()
			local attid = vm:LookupAttachment(self.ShellAttachment)
			if self.Akimbo then
				attid = 3 + self.AnimCycle
			end
			attid = math.Clamp(attid and attid or 2, 1, 127)
			local angpos = vm:GetAttachment(attid)

			if angpos then
				fx:SetEntity(self)
				fx:SetAttachment(attid)
				fx:SetMagnitude(1)
				fx:SetScale(1)
				fx:SetOrigin(angpos.Pos)
				fx:SetNormal(angpos.Ang:Forward())
				util.Effect("tfa_shell", fx)
			end
		end
	end
end

--[[
Function Name:  CleanParticles
Syntax: self:CleanParticles().
Returns:  Nothing.
Notes:    Cleans up particles.
Purpose:  FX
]]--
function SWEP:CleanParticles()
	if not IsValid(self) then return end

	if self.StopParticles then
		self:StopParticles()
	end

	if self.StopParticleEmission then
		self:StopParticleEmission()
	end

	if not self:VMIV() then return end
	local vm = self.OwnerViewModel

	if IsValid(vm) then
		if vm.StopParticles then
			vm:StopParticles()
		end

		if vm.StopParticleEmission then
			vm:StopParticleEmission()
		end
	end
end

--[[
Function Name:  EjectionSmoke
Syntax: self:EjectionSmoke().
Returns:  Nothing.
Notes:    Puff of smoke on shell attachment.
Purpose:  FX
]]--
function SWEP:EjectionSmoke( ovrr )
	if TFA.GetEJSmokeEnabled() and ( self.EjectionSmokeEnabled or ovrr ) then
		local vm = self.OwnerViewModel

		if IsValid(vm) then
			local att = vm:LookupAttachment(self.ShellAttachment)

			if not att or att <= 0 then
				att = 2
			end

			local oldatt = att

			if self.ShellAttachmentRaw then
				att = self.ShellAttachmentRaw
			end

			local angpos = vm:GetAttachment(att)

			if not angpos then
				att = oldatt
				angpos = vm:GetAttachment(att)
			end

			if angpos then
				fx = EffectData()
				fx:SetEntity(self)
				fx:SetOrigin(angpos.Pos)
				fx:SetAttachment(att)
				fx:SetNormal(angpos.Ang:Forward())
				util.Effect("tfa_shelleject_smoke", fx)
			end
		end
	end
end

--[[
Function Name:  ShootEffectsCustom
Syntax: self:ShootEffectsCustom().
Returns:  Nothing.
Notes:    Calls the proper muzzleflash, muzzle smoke, muzzle light code.
Purpose:  FX
]]--

local limit_particle_cv  = GetConVar("cl_tfa_fx_muzzlesmoke_limited")
SWEP.NextSmokeParticle = { }
SWEP.SmokeParticleTable = {
	[1] = { --[attachment] = 
		--{ ["time"] = 0. ["end"] = 55 }
	}
}
function SWEP:AddSmokeParticleTBL(att)
	self:UpdateSmokeParticleTBL()
	self.SmokeParticleTable[att] = self.SmokeParticleTable[att] or {}

	if (not limit_particle_cv) or (not limit_particle_cv:GetBool()) then
		self.NextSmokeParticle[ att ] = CurTime() + 0.1 + math.sqrt(math.Clamp(#self.SmokeParticleTable, 0, 15)) * 0.2
	else
		self.NextSmokeParticle[ att ] = CurTime() + 0.3 + math.Clamp(#self.SmokeParticleTable, 0, 5) * 0.2
	end

	table.insert(self.SmokeParticleTable[att], #self.SmokeParticleTable[att] + 1, {
		["time"] = CurTime(),
		["delay"] = 4
	})
end

function SWEP:UpdateSmokeParticleTBL(att)
	for k, v in ipairs(self.SmokeParticleTable) do
		for l, b in ipairs(v) do
			if CurTime() > b.time + b.delay then
				table.remove(v, l)
			end
		end
	end
end

function SWEP:ShootEffectsCustom( ifp )
	if self.DoMuzzleFlash ~= nil then
		self.MuzzleFlashEnabled = self.DoMuzzleFlash
		self.DoMuzzleFlash = nil
	end
	if not self.MuzzleFlashEnabled then return end
	if self:IsFirstPerson() and not self:VMIV() then return end
	if not self:GetOwner().GetShootPos then return end
	ifp = ifp or IsFirstTimePredicted()

	if sp == nil then
		sp = game.SinglePlayer()
	end

	if (SERVER and sp and self.ParticleMuzzleFlash) or (SERVER and not sp) then
		net.Start("tfa_base_muzzle_mp")
		net.WriteEntity(self)

		if (sp) then
			net.Broadcast()
		else
			net.SendOmit(self:GetOwner())
		end

		return
	end

	if (CLIENT and ifp and not sp) or (sp and SERVER) then
		if self.SmokeParticle == nil then
			self.SmokeParticle = self.SmokeParticles[ self.DefaultHoldType or self.HoldType ]
		end
		local vm = self.OwnerViewModel
		self:UpdateMuzzleAttachment()
		local att = math.max(1, self.MuzzleAttachmentRaw or (sp and vm or self):LookupAttachment(self.MuzzleAttachment))
		if self.Akimbo then
			att = 1 + self.AnimCycle
		end
		fx = EffectData()
		fx:SetOrigin(self:GetOwner():GetShootPos())
		fx:SetNormal(self:GetOwner():EyeAngles():Forward())
		fx:SetEntity(self)
		fx:SetAttachment(att)
		if CurTime() > ( self.NextSmokeParticle[ att ] or -1 ) and self.SmokeParticle and self.SmokeParticle ~= "" then
			util.Effect("tfa_muzzlesmoke", fx)
			self:AddSmokeParticleTBL(att)
		end

		local mzsil = self:GetStat( "MuzzleFlashEffectSilenced" )
		if (self:GetSilenced() and mzsil and mzsil ~= "" ) then
			util.Effect( mzsil, fx)
		else
			util.Effect( self:GetStat( "MuzzleFlashEffect", self.MuzzleFlashEffect or "" ), fx)
		end
	end
end

--[[
Function Name:  CanDustEffect
Syntax: self:CanDustEffect( concise material name ).
Returns:  True/False
Notes:    Used for the impact effect.  Should be used with GetMaterialConcise.
Purpose:  Utility
]]--

function SWEP:CanDustEffect( matv )
	local n = self:GetMaterialConcise(matv )
	if n == "energy" or n == "dirt" or n == "ceramic" or n == "plastic" or n == "wood" then return true end

	return false
end

--[[
Function Name:  CanSparkEffect
Syntax: self:CanSparkEffect( concise material name ).
Returns:  True/False
Notes:    Used for the impact effect.  Should be used with GetMaterialConcise.
Purpose:  Utility
]]--

function SWEP:CanSparkEffect(matv)
	local n = self:GetMaterialConcise(matv)
	if n == "default" or n == "metal" then return true end

	return false
end