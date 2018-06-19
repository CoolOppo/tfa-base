local upVec = Vector(0,0,1)
--[[
Function Name:  ComputeSmokeLighting
Syntax: self:ComputeSmokeLighting(pos,nrm,pcf).
Returns:  Nothing.
Notes:	Used to light the muzzle smoke trail, by setting its PCF Control Point 1
Purpose:  FX
]]--
function SWEP:ComputeSmokeLighting( pos, nrm, pcf )
	if not IsValid(pcf) then return end
	local licht = render.ComputeLighting(pos, nrm)
	local lichtFloat = math.Clamp((licht.r + licht.g + licht.b) / 3, 0, TFA.Particles.SmokeLightingClamp) / TFA.Particles.SmokeLightingClamp
	local lichtFinal = LerpVector(lichtFloat, TFA.Particles.SmokeLightingMin, TFA.Particles.SmokeLightingMax)
	pcf:SetControlPoint(1, lichtFinal)
end
--[[
Function Name:  SmokePCFLighting
Syntax: self:SmokePCFLighting().
Returns:  Nothing.
Notes:	Used to loop through all of our SmokePCF tables and call ComputeSmokeLighting on them
Purpose:  FX
]]--
function SWEP:SmokePCFLighting()
	local mzPos = self:GetMuzzlePos()
	if not mzPos or not mzPos.Pos then return end
	local pos = mzPos.Pos
	if self.SmokePCF then
		for _, v in pairs(self.SmokePCF) do
			self:ComputeSmokeLighting(pos,upVec,v)
		end
	end
	if not self:VMIV() then return end
	local vm = self.OwnerViewModel
	if vm.SmokePCF then
		for _, v in pairs(vm.SmokePCF) do
			self:ComputeSmokeLighting(pos,upVec,v)
		end
	end
end

--[[
Function Name:  FireAnimationEvent
Syntax: self:FireAnimationEvent( position, angle, event id, options).
Returns:  Nothing.
Notes:	Used to capture and disable viewmodel animation events, unless you disable that feature.
Purpose:  FX
]]--
function SWEP:FireAnimationEvent(pos, ang, event, options)
	if self.CustomMuzzleFlash or not self.MuzzleFlashEnabled then
		-- Disables animation based muzzle event
		if (event == 21) then return true end
		-- Disable thirdperson muzzle flash
		if (event == 5003) then return true end

		-- Disable CS-style muzzle flashes, but chance our muzzle flash attachment if one is given.
		if (event == 5001 or event == 5011 or event == 5021 or event == 5031) then
			if self.AutoDetectMuzzleAttachment then
				self.MuzzleAttachmentRaw = math.Clamp(math.floor((event - 4991) / 10), 1, 4)
				net.Start("tfa_base_muzzle_mp")
				net.SendToServer()
				self:ShootEffectsCustom(true)
			end

			return true
		end
	end

	if (self.LuaShellEject and event ~= 5004) then return true end
end

--[[
Function Name:  MakeMuzzleSmoke
Syntax: self:MakeMuzzleSmoke( entity, attachment).
Returns:  Nothing.
Notes:	Deprecated. Used to make the muzzle smoke effect, clientside.
Purpose:  FX
]]--

local limit_particle_cv  = GetConVar("cl_tfa_fx_muzzlesmoke_limited")

function SWEP:MakeMuzzleSmoke(entity, attachment)
	if ( not limit_particle_cv ) or limit_particle_cv:GetBool() then
		self:CleanParticles()
	end
	local ht = self.DefaultHoldType and self.DefaultHoldType or self.HoldType

	if (CLIENT and TFA.GetMZSmokeEnabled() and IsValid(entity) and attachment and attachment ~= 0) then
		ParticleEffectAttach(self.SmokeParticles[ht], PATTACH_POINT_FOLLOW, entity, attachment)
	end
end

--[[
Function Name:  ImpactEffect
Syntax: self:ImpactEffect( position, normal (ang:Up()), materialt ype).
Returns:  Nothing.
Notes:	Used to make the impact effect.  See utilities code for CanDustEffect.
Purpose:  FX
]]--

function SWEP:DoImpactEffect(tr, dmgtype)
	if tr.HitSky then return true end
	local ib = self.BashBase and IsValid(self) and self:GetBashing()
	local dmginfo = DamageInfo()
	dmginfo:SetDamageType(dmgtype)

	if dmginfo:IsDamageType(DMG_SLASH) or (ib and self.Secondary.BashDamageType == DMG_SLASH and tr.MatType ~= MAT_FLESH and tr.MatType ~= MAT_ALIENFLESH) or (self and self.DamageType and self.DamageType == DMG_SLASH) then
		util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

		return true
	end

	if ib and self.Secondary.BashDamageType == DMG_GENERIC then return true end
	if ib then return end

	if IsValid(self) then
		self:ImpactEffectFunc(tr.HitPos, tr.HitNormal, tr.MatType)
	end

	if self.ImpactDecal and self.ImpactDecal ~= "" then
		util.Decal(self.ImpactDecal, tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)

		return true
	end
end

local impact_cl_enabled = GetConVar("cl_tfa_fx_impact_enabled")
local impact_sv_enabled = GetConVar("sv_tfa_fx_impact_override")

function SWEP:ImpactEffectFunc(pos, normal, mattype)
	local enabled

	if impact_cl_enabled then
		enabled = impact_cl_enabled:GetBool()
	else
		enabled = true
	end

	if impact_sv_enabled and impact_sv_enabled:GetInt() >= 0 then
		enabled = impact_sv_enabled:GetBool()
	end

	if enabled then
		local fx = EffectData()
		fx:SetOrigin(pos)
		fx:SetNormal(normal)

		if self:CanDustEffect(mattype) then
			util.Effect("tfa_dust_impact", fx)
		end

		if self:CanSparkEffect(mattype) then
			util.Effect("tfa_metal_impact", fx)
		end

		local scal = math.sqrt(self:GetStat("Primary.Damage") / 30)
		if mattype == MAT_FLESH then
			scal = scal * 0.25
		end
		fx:SetEntity(self:GetOwner())
		fx:SetMagnitude(mattype or 0)
		fx:SetScale( scal )
		util.Effect("tfa_bullet_impact", fx)

		if self.ImpactEffect then
			util.Effect(self.ImpactEffect, fx)
		end
	end
end

local supports
local cl_tfa_fx_dof = GetConVar('cl_tfa_fx_dof')

local fmat = CreateMaterial('TFA_DOF_Material4', 'Refract', {
	['$model'] = '1',
	['$alpha'] = '1',
	['$alphatest'] = '1',
	['$normalmap'] = 'effects/flat_normal',
	['$refractamount'] = '0.1',
	['$vertexalpha'] = '1',
	['$vertexcolor'] = '1',
	['$translucent'] = '1',
	['$forcerefract'] = '0',
	['$bluramount'] = '1.5',
	['$nofog'] = '1',
})

local fmat2 = CreateMaterial('TFA_DOF_Material5', 'Refract', {
	['$model'] = '1',
	['$alpha'] = '1',
	['$alphatest'] = '1',
	['$normalmap'] = 'effects/flat_normal',
	['$refractamount'] = '0.1',
	['$vertexalpha'] = '1',
	['$vertexcolor'] = '1',
	['$translucent'] = '1',
	['$forcerefract'] = '0',
	['$bluramount'] = '0.9',
	['$nofog'] = '1',
})

local fmat3 = CreateMaterial('TFA_DOF_Material16', 'Refract', {
	['$model'] = '1',
	['$alpha'] = '1',
	['$alphatest'] = '1',
	['$normalmap'] = 'effects/flat_normal',
	['$refractamount'] = '0.1',
	['$vertexalpha'] = '1',
	['$vertexcolor'] = '1',
	['$translucent'] = '1',
	['$forcerefract'] = '0',
	['$bluramount'] = '0.8',
	['$nofog'] = '1',
})

local white = CreateMaterial('TFA_DOF_White', 'UnlitGeneric', {
	['$alpha'] = '0',
	['$basetexture'] = 'models/debug/debugwhite',
})

TFA.LastRTUpdate = TFA.LastRTUpdate or CurTime()

hook.Add('PreDrawViewModel', 'TFA_DrawViewModel', function(vm, plyv, self)
	if not vm or not plyv or not self then return end
	if not self:IsTFA() then return end

	if supports == nil then
		supports = render.SupportsPixelShaders_1_4() and render.SupportsPixelShaders_2_0() and render.SupportsVertexShaders_2_0()

		if not supports then
			print('[TFA] Your videocard does not support pixel shaders! DoF of Iron Sights is disabled!')
		end
	end

	if not supports then return end
	cl_tfa_fx_dof = cl_tfa_fx_dof or GetConVar('cl_tfa_fx_dof')
	if not cl_tfa_fx_dof:GetBool() then return end

	local aimingDown = self.IronSightsProgress > 0.4
	local scoped = TFA.LastRTUpdate > CurTime()

	if aimingDown and not scoped then
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilTestMask(0)
		render.SetStencilWriteMask(1)

		render.SetStencilReferenceValue(1)

		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.OverrideColorWriteEnable(true, true)

		render.SetStencilZFailOperation(STENCIL_KEEP)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
	end
end)

local transparent = Color(0, 0, 0, 0)
local color_white = Color(255, 255, 255)
local STOP = false

hook.Add('PostDrawViewModel', 'TFA_DrawViewModel', function(vm, plyv, self)
	if not self:IsTFA() then return end
	if not supports then return end

	cl_tfa_fx_dof = cl_tfa_fx_dof or GetConVar('cl_tfa_fx_dof')
	if not cl_tfa_fx_dof:GetBool() then return end

	local aimingDown = self.IronSightsProgress > 0.4
	local eangles = EyeAngles()
	local fwd2 = vm:GetAngles():Forward()
	local scoped = TFA.LastRTUpdate > CurTime()

	if aimingDown and not scoped then
		fmat:SetFloat('$alpha', self.IronSightsProgress)

		local muzzle = vm:LookupAttachment('muzzle')
		local muzzleflash = vm:LookupAttachment('muzzleflash')
		local muzzledata

		if muzzle and muzzle ~= 0 then
			muzzledata = vm:GetAttachment(muzzle)
		elseif self.MuzzleAttachmentRaw then
			muzzledata = vm:GetAttachment(self.MuzzleAttachmentRaw)
		elseif muzzleflash and muzzleflash ~= 0 then
			muzzledata = vm:GetAttachment(muzzleflash)
		end

		local hands = plyv:GetHands()

		if IsValid(hands) then
			render.OverrideColorWriteEnable(true, false)
			STOP = true
			local candraw = hook.Run('PreDrawPlayerHands', hands, vm, plyv, self)
			STOP = false

			if candraw ~= true then
				hands:DrawModel()
			end

			render.OverrideColorWriteEnable(false, false)
		end

		if muzzledata then
			render.SetStencilPassOperation(STENCIL_ZERO)
			render.SetMaterial(white)
			render.DrawSprite(muzzledata.Pos - fwd2 * 6 + eangles:Up() * 4, 30, 30, transparent)
			render.SetStencilPassOperation(STENCIL_REPLACE)
		end

		local w, h = ScrW(), ScrH()

		render.SetStencilTestMask(1)
		render.SetStencilWriteMask(2)
		render.SetStencilCompareFunction(STENCIL_EQUAL)
		render.SetStencilPassOperation(STENCIL_REPLACE)

		render.UpdateScreenEffectTexture()

		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)

		render.SetMaterial(fmat)

		cam.Start2D()
		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(fmat)
		surface.DrawTexturedRect(0, 0, w, h)
		cam.End2D()

		if muzzledata then
			-- :POG:
			render.SetMaterial(fmat2)

			for i = 28, 2, -1 do
				render.UpdateScreenEffectTexture()
				render.DrawSprite(muzzledata.Pos - fwd2 * i * 3, 200, 200, color_white)
			end
		end

		render.SetMaterial(fmat3)

		cam.Start2D()
		surface.SetMaterial(fmat3)

		for i = 0, 32 do
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(0, h / 1.6 + h / 2 * i / 32, w, h / 2)
		end

		cam.End2D()

		render.PopFilterMin()
		render.PopFilterMag()
		--render.PopRenderTarget()

		render.SetStencilEnable(false)
	end

	self:ViewModelDrawnPost()
end)

hook.Add('PreDrawPlayerHands', 'TFA_DrawViewModel', function(hands, vm, plyv, self)
	if STOP then return end
	if not self:IsTFA() then return end
	if not supports then return end

	cl_tfa_fx_dof = cl_tfa_fx_dof or GetConVar('cl_tfa_fx_dof')
	if not cl_tfa_fx_dof:GetBool() then return end

	if self.IronSightsProgress > 0.4 then return true end
end)
