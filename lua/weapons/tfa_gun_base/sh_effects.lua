local fx, sp

function SWEP:MakeShellBridge(ifp)
	if ifp then
		if self.LuaShellEjectDelay > 0 then
			self.LuaShellRequestTime = CurTime() + self.LuaShellEjectDelay
		else
			self:MakeShell()
		end
	end
end

function SWEP:MakeShell()
	if IsValid(self) and self:VMIV() then
		local vm = (not self.Owner.ShouldDrawLocalPlayer or self.Owner:ShouldDrawLocalPlayer()) and self.OwnerViewModel or self

		if IsValid(vm) then
			fx = EffectData()
			fx:SetEntity(vm)
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

	if not self:OwnerIsValid() then return end
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
function SWEP:EjectionSmoke()
	if TFA.GetEJSmokeEnabled() then
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

			if angpos and angpos.Pos then
				fx = EffectData()
				fx:SetEntity(vm)
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
function SWEP:ShootEffectsCustom( ifp )
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
			net.SendOmit(self.Owner)
		end

		return
	end

	if (CLIENT and ifp and not sp) or (sp and SERVER) then
		local vm = self.Owner:GetViewModel()
		self:UpdateMuzzleAttachment()
		local att = math.max(1, self.MuzzleAttachmentRaw or (sp and vm or self):LookupAttachment(self.MuzzleAttachment))
		if self.Akimbo then
			att = 1 + self.AnimCycle
		end
		self:CleanParticles()
		fx = EffectData()
		fx:SetOrigin(self.Owner:GetShootPos())
		fx:SetNormal(self.Owner:EyeAngles():Forward())
		fx:SetEntity(self)
		fx:SetAttachment(att)
		util.Effect("tfa_muzzlesmoke", fx)

		if (self:GetSilenced()) then
			util.Effect("tfa_muzzleflash_silenced", fx)
		else
			util.Effect(self.MuzzleFlashEffect or "", fx)
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