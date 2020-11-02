
-- Copyright (c) 2018-2020 TFA Base Devs

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local vector_origin = Vector()
local angle_zero = Angle()

local Vector = Vector
local Angle = Angle
local math = math
local LerpVector = LerpVector

local sv_cheats = GetConVar("sv_cheats")
local host_timescale = GetConVar("host_timescale")

local cv_fov = GetConVar("fov_desired")
local cl_vm_nearwall = GetConVar("cl_tfa_viewmodel_nearwall")

local cl_tfa_viewmodel_offset_x = GetConVar("cl_tfa_viewmodel_offset_x")
local cl_tfa_viewmodel_offset_y = GetConVar("cl_tfa_viewmodel_offset_y")
local cl_tfa_viewmodel_offset_z = GetConVar("cl_tfa_viewmodel_offset_z")
local cl_tfa_viewmodel_centered = GetConVar("cl_tfa_viewmodel_centered")

local cl_tfa_viewmodel_vp_enabled = GetConVar("cl_tfa_viewmodel_vp_enabled")
local cl_tfa_viewmodel_vp_pitch = GetConVar("cl_tfa_viewmodel_vp_pitch")
local cl_tfa_viewmodel_vp_pitch_is = GetConVar("cl_tfa_viewmodel_vp_pitch_is")
local cl_tfa_viewmodel_vp_vertical = GetConVar("cl_tfa_viewmodel_vp_vertical")
local cl_tfa_viewmodel_vp_vertical_is = GetConVar("cl_tfa_viewmodel_vp_vertical_is")
local cl_tfa_viewmodel_vp_max_vertical = GetConVar("cl_tfa_viewmodel_vp_max_vertical")
local cl_tfa_viewmodel_vp_max_vertical_is = GetConVar("cl_tfa_viewmodel_vp_max_vertical_is")
local cl_tfa_viewmodel_vp_yaw = GetConVar("cl_tfa_viewmodel_vp_yaw")
local cl_tfa_viewmodel_vp_yaw_is = GetConVar("cl_tfa_viewmodel_vp_yaw_is")

local sv_tfa_recoil_legacy = GetConVar("sv_tfa_recoil_legacy")

local cv_customgunbob = GetConVar("cl_tfa_gunbob_custom")

local function Lerp(t, a, b)
	return a + (b - a) * t
end

local function Clamp(a, b, c)
	if a < b then return b end
	if a > c then return c end
	return a
end

local math_max = math.max

local cl_vm_flip_cv = GetConVar("cl_tfa_viewmodel_flip")
local fovmod_add = GetConVar("cl_tfa_viewmodel_offset_fov")
local fovmod_mult = GetConVar("cl_tfa_viewmodel_multiplier_fov")

function SWEP:AirWalkScale()
	return (self:OwnerIsValid() and self:GetOwner():IsOnGround()) and 1 or 0.2
end

function SWEP:GetViewModelPosition(pos, ang)
	local self2 = self:GetTable()

	if not self2.pos_cached then return pos, ang end

	ang:RotateAroundAxis(ang:Right(), self2.ang_cached.p)
	ang:RotateAroundAxis(ang:Up(), self2.ang_cached.y)
	ang:RotateAroundAxis(ang:Forward(), self2.ang_cached.r)
	pos:Add(ang:Right() * self2.pos_cached.x)
	pos:Add(ang:Forward() * self2.pos_cached.y)
	pos:Add(ang:Up() * self2.pos_cached.z)

	if cv_customgunbob:GetBool() then
		pos, ang = self:Sway(pos, ang)
		pos, ang = self:SprintBob(pos, ang, Lerp(self2.SprintProgressUnpredicted3 or self2.SprintProgressUnpredicted or self:GetSprintProgress(), 0, self2.SprintBobMult))
	end

	return pos, ang
end

function SWEP:CalculateViewModelFlip()
	local self2 = self:GetTable()

	if self2.ViewModelFlipDefault == nil then
		self2.ViewModelFlipDefault = self2.ViewModelFlip
	end

	local righthanded = true

	if cl_vm_flip_cv:GetBool() then
		righthanded = false
	end

	local shouldflip = self2.ViewModelFlipDefault

	if not righthanded then
		shouldflip = not self2.ViewModelFlipDefault
	end

	if self2.ViewModelFlip ~= shouldflip then
		self2.ViewModelFlip = shouldflip
	end

	self2.ViewModelFOV_OG = self2.ViewModelFOV_OG or self2.ViewModelFOV

	local cam_fov = self2.LastTranslatedFOV or cv_fov:GetInt() or 90
	local iron_add = cam_fov * (1 - 90 / cam_fov) * math.max(1 - self2.GetStat(self, "Secondary.IronFOV", 90) / 90, 0)

	local ironSightsProgress = TFA.Cosine(self2.IronSightsProgressUnpredicted or self:GetIronSightsProgress())
	self2.ViewModelFOV = Lerp(ironSightsProgress, self2.ViewModelFOV_OG, self2.GetStat(self, "IronViewModelFOV", self2.ViewModelFOV_OG)) * fovmod_mult:GetFloat() + fovmod_add:GetFloat() + iron_add * ironSightsProgress
end

function SWEP:UpdateWeaponLength()
	local self2 = self:GetTable()
	if not self:VMIV() then return end
	local vm = self2.OwnerViewModel
	local mzpos = self:GetMuzzlePos()
	if not mzpos then return end
	if not mzpos.Pos then return end
	if GetViewEntity and GetViewEntity() ~= self:GetOwner() then return end
	local mzVec = vm:WorldToLocal(mzpos.Pos)
	self2.WeaponLength = math.abs(mzVec.x)
end

function SWEP:CalculateNearWall(p, a)
	local self2 = self:GetTable()
	if not self:OwnerIsValid() then return p, a end

	if not cl_vm_nearwall:GetBool() then return p, a end

	local ply = self:GetOwner()

	local sp = ply:GetShootPos()
	local ea = ply:EyeAngles()
	local et = util.QuickTrace(sp,ea:Forward()*128,{self,ply})--self:GetOwner():GetEyeTrace()
	local dist = et.HitPos:Distance(sp)

	if dist<1 then
		et=util.QuickTrace(sp,ea:Forward()*128,{self,ply,et.Entity})
		dist = et.HitPos:Distance(sp)
	end

	self:UpdateWeaponLength()

	local nw_offset_vec = LerpVector(self2.IronSightsProgressUnpredicted or self:GetIronSightsProgress(), self2.NearWallVector, self2.NearWallVectorADS)
	local off = self2.WeaponLength - dist
	self2.LastNearWallOffset = self2.LastNearWallOffset or 0

	local ft = RealFrameTime() * game.GetTimeScale() * (sv_cheats:GetBool() and host_timescale:GetFloat() or 1)

	if off > self2.LastNearWallOffset then
		self2.LastNearWallOffset = math.min(self2.LastNearWallOffset + math.max(ft * 66, off * 0.1), off, 34)
	elseif off < self2.LastNearWallOffset then
		self2.LastNearWallOffset = math.max(self2.LastNearWallOffset - ft * 66, off, 0)
	end

	off = TFA.Cosine(self2.LastNearWallOffset / 34) * 34

	if off > 0 then
		p = p + nw_offset_vec * off / 2
		local posCompensated = sp * 1
		posCompensated:Add(ea:Right() * nw_offset_vec.x * off / 2 * (self2.ViewModelFlip and -1 or 1))
		posCompensated:Add(ea:Forward() * nw_offset_vec.y * off / 2)
		posCompensated:Add(ea:Up() * nw_offset_vec.z * off / 2)
		local angleComp = (et.HitPos - posCompensated):Angle()
		a.x = a.x - math.AngleDifference(angleComp.p, ea.p) / 2
		a.y = a.y + math.AngleDifference(angleComp.y, ea.y) / 2
	end

	return p, a
end

local centered_sprintpos = Vector(0, -1, 1)
local centered_sprintang = Vector(-15, 0, 0)

local bezierVectorBuffer = {}

local function bezierVector(t, vec1, vec2, vec3)
	local _1, _2 = vec1.x, vec3.x
	bezierVectorBuffer[1] = _1
	bezierVectorBuffer[2] = _1
	bezierVectorBuffer[3] = _1
	bezierVectorBuffer[4] = _1
	bezierVectorBuffer[5] = vec2.x
	bezierVectorBuffer[6] = _2
	bezierVectorBuffer[7] = _2
	bezierVectorBuffer[8] = _2
	bezierVectorBuffer[9] = _2

	local x = TFA.tbezier(t, bezierVectorBuffer)

	_1, _2 = vec1.y, vec3.y
	bezierVectorBuffer[1] = _1
	bezierVectorBuffer[2] = _1
	bezierVectorBuffer[3] = _1
	bezierVectorBuffer[4] = _1
	bezierVectorBuffer[5] = vec2.y
	bezierVectorBuffer[6] = _2
	bezierVectorBuffer[7] = _2
	bezierVectorBuffer[8] = _2
	bezierVectorBuffer[9] = _2

	local y = TFA.tbezier(t, bezierVectorBuffer)

	_1, _2 = vec1.z, vec3.z
	bezierVectorBuffer[1] = _1
	bezierVectorBuffer[2] = _1
	bezierVectorBuffer[3] = _1
	bezierVectorBuffer[4] = _1
	bezierVectorBuffer[5] = vec2.z
	bezierVectorBuffer[6] = _2
	bezierVectorBuffer[7] = _2
	bezierVectorBuffer[8] = _2
	bezierVectorBuffer[9] = _2

	local z = TFA.tbezier(t, bezierVectorBuffer)

	return Vector(x, y, z)
end

function SWEP:CalculateViewModelOffset(delta)
	local self2 = self:GetTable()

	local target_pos, target_ang
	local additivePos = self2.GetStat(self, "VMPos_Additive")

	if additivePos then
		target_pos, target_ang = Vector(), Vector()
	else
		target_pos = Vector(self2.GetStat(self, "VMPos"))
		target_ang = Vector(self2.GetStat(self, "VMAng"))
	end

	local CenteredPos = self2.GetStat(self, "CenteredPos")
	local CenteredAng = self2.GetStat(self, "CenteredAng")
	local IronSightsPos = self2.GetStat(self, "IronSightsPos", self2.SightsPos)
	local IronSightsAng = self2.GetStat(self, "IronSightsAng", self2.SightsAng)

	local targetPosCenter, targetAngCenter

	if CenteredPos then
		targetPosCenter = Vector(CenteredPos)

		if CenteredAng then
			targetAngCenter = Vector(CenteredAng)
		end
	elseif IronSightsPos then
		targetPosCenter = Vector((self2.IronSightsPosCurrent or IronSightsPos).x, target_pos.y, target_pos.z - 3)

		if IronSightsAng then
			targetAngCenter = Vector(0, (self2.IronSightsAngCurrent or IronSightsAng).y, 0)
		end
	else
		targetPosCenter, targetAngCenter = target_pos, target_ang
	end

	if cl_tfa_viewmodel_centered:GetBool() then
		target_pos:Set(targetPosCenter)
		target_ang:Set(targetAngCenter)
	end

	local stat = self:GetStatus()

	local holsterStatus = TFA.Enum.HolsterStatus[stat] and self2.GetStat(self, "ProceduralHolsterEnabled")
	local proceduralReloadStatus = TFA.Enum.ReloadStatus[stat] and self2.GetStat(self, "ProceduralReloadEnabled")
	local holsterProgress = 0
	local statusProgress = self:GetStatusProgress()

	if proceduralReloadStatus then
		holsterProgress = TFA.Quintic(Clamp((statusProgress >= 0.5 and (2 - statusProgress * 2) or (statusProgress * 2)), 0, 1))
	elseif self2.GetStat(self, "ProceduralHolsterEnabled") then
		if TFA.Enum.HolsterStatusFinal[stat] then
			holsterProgress = 1
		elseif TFA.Enum.HolsterStatus[stat] then
			holsterProgress = TFA.Quintic(Clamp(statusProgress * 1.1, 0, 1))
		end
	end

	local sprintAnimAllowed = self2.Sprint_Mode == TFA.Enum.LOCOMOTION_LUA or self2.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID

	local isSafety = self:IsSafety()

	local ironSights = self:GetIronSights()
	local isSprinting = self:GetSprinting()
	local sprintProgress = sprintAnimAllowed and TFA.Cubic(self2.SprintProgressUnpredicted2 or self2.SprintProgressUnpredicted or self:GetSprintProgress()) or 0
	local safetyProgress = Lerp(sprintProgress, TFA.Cubic(self2.SafetyProgressUnpredicted or 0), 0)

	local ironSightsProgress = Clamp(
		Lerp(
			math_max(holsterProgress, sprintProgress, safetyProgress),
			TFA.Cubic(self2.IronSightsProgressUnpredicted2 or self2.IronSightsProgressUnpredicted or self:GetIronSightsProgress()),
			0)
		, 0, 1)

	--local ironSightsProgress = TFA.tbezier(self2.IronSightsProgressUnpredicted or self:GetIronSightsProgress(), IRON_SIGHTS_BEZIER)

	local crouchRatio = Lerp(math_max(ironSightsProgress, holsterProgress, Clamp(sprintProgress * 2, 0, 1), safetyProgress), TFA.Quintic(self2.CrouchingRatioUnpredicted or self:GetCrouchingRatio()), 0)

	if crouchRatio > 0.01 then
		target_pos = LerpVector(crouchRatio, target_pos, self2.GetStat(self, "CrouchPos"))
		target_ang = LerpVector(crouchRatio, target_ang, self2.GetStat(self, "CrouchAng"))
	end

	if holsterStatus or proceduralReloadStatus then
		local targetHolsterPos = Vector(self2.GetStat(self, "ProceduralHolsterPos"))
		local targetHolsterAng = Vector(self2.GetStat(self, "ProceduralHolsterAng"))

		if self2.ViewModelFlip then
			targetHolsterPos.x = -targetHolsterPos.x

			targetHolsterAng.y = -targetHolsterAng.y
			targetHolsterAng.z = -targetHolsterAng.z
		end

		target_pos = LerpVector(holsterProgress, target_pos, targetHolsterPos)
		target_ang = LerpVector(holsterProgress, target_ang, targetHolsterAng)
	end

	if
		(sprintProgress > 0.01 or safetyProgress > 0.01) and
		(sprintAnimAllowed and sprintProgress > 0.01 or safetyProgress > 0.01)
		and stat ~= TFA.Enum.STATUS_BASHING
	then
		if cl_tfa_viewmodel_centered:GetBool() then
			target_pos = target_pos + centered_sprintpos
			target_ang = target_ang + centered_sprintang
		else
			target_pos = LerpVector(safetyProgress, target_pos, self2.GetStat(self, "SafetyPos", self2.GetStat(self, "RunSightsPos")))
			target_ang = LerpVector(safetyProgress, target_ang, self2.GetStat(self, "SafetyAng", self2.GetStat(self, "RunSightsAng")))

			if sprintAnimAllowed then
				target_pos = LerpVector(sprintProgress, target_pos, self2.GetStat(self, "RunSightsPos"))
				target_ang = LerpVector(sprintProgress, target_ang, self2.GetStat(self, "RunSightsAng"))
			end
		end
	end

	if ironSightsProgress > 0.02 and (self2.Sights_Mode == TFA.Enum.LOCOMOTION_LUA or self2.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID) then
		if targetPosCenter then
			target_pos = bezierVector(ironSightsProgress, target_pos, targetPosCenter, self2.IronSightsPosCurrent or IronSightsPos or self2.GetStat(self, "SightsPos", vector_origin))
		else
			target_pos = LerpVector(ironSightsProgress, target_pos, self2.IronSightsPosCurrent or IronSightsPos or self2.GetStat(self, "SightsPos", vector_origin))
		end

		if targetAngCenter then
			local deviate = 30

			if self2.VM_IsScopedIn then
				deviate = -deviate
			end

			if self2.ViewModelFlip then
				deviate = -deviate
			end

			local targetAngCenter2 = Vector(targetAngCenter.x, targetAngCenter.y, targetAngCenter.z + deviate)
			target_ang = bezierVector(ironSightsProgress, target_ang, targetAngCenter2, self2.IronSightsAngCurrent or IronSightsAng or self2.GetStat(self, "SightsAng", vector_origin))
		else
			target_ang = LerpVector(ironSightsProgress, target_ang, self2.IronSightsAngCurrent or IronSightsAng or self2.GetStat(self, "SightsAng", vector_origin))
		end
	end

	target_pos.x = target_pos.x + cl_tfa_viewmodel_offset_x:GetFloat() * (1 - ironSightsProgress)
	target_pos.y = target_pos.y + cl_tfa_viewmodel_offset_y:GetFloat() * (1 - ironSightsProgress)
	target_pos.z = target_pos.z + cl_tfa_viewmodel_offset_z:GetFloat() * (1 - ironSightsProgress)

	local customizationProgress = TFA.Quintic(self2.CustomizingProgressUnpredicted or self:GetInspectingProgress())

	if customizationProgress > 0.01 and self2.Customize_Mode ~= TFA.Enum.LOCOMOTION_ANI then
		if not self2.InspectPos then
			self2.InspectPos = Vector(self2.InspectPosDef)

			if self2.ViewModelFlip then
				self2.InspectPos.x = self2.InspectPos.x * -1
			end
		end

		if not self2.InspectAng then
			self2.InspectAng = Vector(self2.InspectAngDef)

			if self2.ViewModelFlip then
				self2.InspectAng.y = self2.InspectAngDef.y * -1
				self2.InspectAng.z = self2.InspectAngDef.z * -1
			end
		end

		target_pos = LerpVector(customizationProgress, target_pos, self2.GetStat(self, "InspectPos"))
		target_ang = LerpVector(customizationProgress, target_ang, self2.GetStat(self, "InspectAng"))
	end

	target_pos, target_ang = self:CalculateNearWall(target_pos, target_ang)

	if additivePos then
		target_pos:Add(self2.VMPos)
		target_ang:Add(self2.VMAng)
	end

	target_ang.z = target_ang.z + -7.5 * (1 - math.abs(0.5 - ironSightsProgress) * 2) * (self:GetIronSights() and 1 or 0.5) * (self2.ViewModelFlip and 1 or -1)

	if self:GetHidden() then
		target_pos.z = target_pos.z - 5
	end

	if self2.GetStat(self, "BlowbackEnabled") and self2.BlowbackCurrentRoot > 0.01 then
		local bbvec = self2.GetStat(self, "BlowbackVector")
		target_pos = target_pos + bbvec * self2.BlowbackCurrentRoot
		local bbang = self2.GetStat(self, "BlowbackAngle") or angle_zero
		bbvec = bbvec * 1
		bbvec.x = bbang.p
		bbvec.y = bbang.y
		bbvec.z = bbang.r
		target_ang = target_ang + bbvec * self2.BlowbackCurrentRoot
		bbang = self2.BlowbackRandomAngle * (1 - math.max(0, ironSightsProgress) * .8)
		bbvec.x = bbang.p
		bbvec.y = bbang.y
		bbvec.z = bbang.r
		target_ang = target_ang + bbvec * self2.BlowbackCurrentRoot
	end

	if not sv_tfa_recoil_legacy:GetBool() and cl_tfa_viewmodel_vp_enabled:GetBool() then
		if self:HasRecoilLUT() then
			if not ironSights then
				local ang = self:GetRecoilLUTAngle()

				target_ang.x = target_ang.x - ang.p / 2 * Lerp(ironSightsProgress, self:GetStat("ViewModelPunchPitchMultiplier") * cl_tfa_viewmodel_vp_pitch:GetFloat(), self:GetStat("ViewModelPunchPitchMultiplier_IronSights") * cl_tfa_viewmodel_vp_pitch_is:GetFloat())
				target_ang.y = target_ang.y + ang.y / 2 * Lerp(ironSightsProgress, self:GetStat("ViewModelPunchYawMultiplier") * cl_tfa_viewmodel_vp_yaw:GetFloat(), self:GetStat("ViewModelPunchYawMultiplier_IronSights") * cl_tfa_viewmodel_vp_yaw_is:GetFloat())
			end
		else
			target_ang.x = target_ang.x - self:GetViewPunchP() * Lerp(ironSightsProgress, self:GetStat("ViewModelPunchPitchMultiplier") * cl_tfa_viewmodel_vp_pitch:GetFloat(), self:GetStat("ViewModelPunchPitchMultiplier_IronSights") * cl_tfa_viewmodel_vp_pitch_is:GetFloat())
			target_ang.y = target_ang.y + self:GetViewPunchY() * Lerp(ironSightsProgress, self:GetStat("ViewModelPunchYawMultiplier") * cl_tfa_viewmodel_vp_yaw:GetFloat(), self:GetStat("ViewModelPunchYawMultiplier_IronSights") * cl_tfa_viewmodel_vp_yaw_is:GetFloat())

			local ViewModelPunch_MaxVertialOffset = Lerp(ironSightsProgress, self:GetStat("ViewModelPunch_MaxVertialOffset") * cl_tfa_viewmodel_vp_max_vertical:GetFloat(), self:GetStat("ViewModelPunch_MaxVertialOffset_IronSights") * cl_tfa_viewmodel_vp_max_vertical_is:GetFloat())

			target_pos.y = target_pos.y + math.Clamp(
				self:GetViewPunchP() * Lerp(ironSightsProgress, self:GetStat("ViewModelPunch_VertialMultiplier") * cl_tfa_viewmodel_vp_vertical:GetFloat(), self:GetStat("ViewModelPunch_VertialMultiplier_IronSights") * cl_tfa_viewmodel_vp_vertical_is:GetFloat()),
				-ViewModelPunch_MaxVertialOffset,
				ViewModelPunch_MaxVertialOffset)
		end
	end

	if not cv_customgunbob:GetBool() then
		self2.pos_cached, self2.ang_cached = Vector(target_pos), Angle(target_ang.x, target_ang.y, target_ang.z)

		return
	end

	local intensityWalk = math.min(self:GetOwner():GetVelocity():Length2D() / self:GetOwner():GetWalkSpeed(), 1) * Lerp(ironSightsProgress, self2.WalkBobMult, self2.WalkBobMult_Iron or self2.WalkBobMult)
	local intensityBreath = Lerp(ironSightsProgress, self2.GetStat(self, "BreathScale", 0.2), self2.GetStat(self, "IronBobMultWalk", 0.5) * intensityWalk)
	intensityWalk = (1 - ironSightsProgress) * intensityWalk
	local intensityRun = Lerp(self2.SprintProgressUnpredicted3 or self2.SprintProgressUnpredicted or self:GetSprintProgress(), 0, self2.SprintBobMult)
	local velocity = math.max(self:GetOwner():GetVelocity():Length2D() * self:AirWalkScale() - self:GetOwner():GetVelocity().z * 0.5, 0)
	local rate = math.min(math.max(0.15, math.sqrt(velocity / self:GetOwner():GetRunSpeed()) * 1.75), self:GetSprinting() and 5 or 3)

	self2.pos_cached, self2.ang_cached = self:WalkBob(
		target_pos,
		Angle(target_ang.x, target_ang.y, target_ang.z),
		math.max(intensityBreath - intensityWalk - intensityRun, 0),
		math.max(intensityWalk - intensityRun, 0), rate, delta)
end

local rft, eyeAngles, viewPunch, oldEyeAngles, delta, motion, counterMotion, compensation, fac, positionCompensation, swayRate, wiggleFactor, flipFactor

local gunswaycvar = GetConVar("cl_tfa_gunbob_intensity")

function SWEP:Sway(pos, ang, ftv)
	local self2 = self:GetTable()
	--sanity check
	if not self:OwnerIsValid() then return pos, ang end
	--convar
	fac = gunswaycvar:GetFloat() * 3 * ((1 - ((self2.IronSightsProgressUnpredicted or self:GetIronSightsProgress()) or 0)) * 0.85 + 0.15)
	flipFactor = (self2.ViewModelFlip and -1 or 1)
	--init vars
	delta = delta or Angle()
	motion = motion or Angle()
	counterMotion = counterMotion or Angle()
	compensation = compensation or Angle()

	if ftv then
		--grab eye angles
		eyeAngles = self:GetOwner():EyeAngles()
		viewPunch = self:GetOwner():GetViewPunchAngles()
		eyeAngles.p = eyeAngles.p - viewPunch.p
		eyeAngles.y = eyeAngles.y - viewPunch.y
		oldEyeAngles = oldEyeAngles or eyeAngles
		--calculate delta
		wiggleFactor = (1 - self2.GetStat(self, "MoveSpeed")) / 0.6 + 0.15
		swayRate = math.pow(self2.GetStat(self, "MoveSpeed"), 1.5) * 10
		rft = math.Clamp(ftv, 0.001, 1 / 20)
		local clampFac = 1.1 - math.min((math.abs(motion.p) + math.abs(motion.y) + math.abs(motion.r)) / 20, 1)
		delta.p = math.AngleDifference(eyeAngles.p, oldEyeAngles.p) / rft / 120 * clampFac
		delta.y = math.AngleDifference(eyeAngles.y, oldEyeAngles.y) / rft / 120 * clampFac
		delta.r = math.AngleDifference(eyeAngles.r, oldEyeAngles.r) / rft / 120 * clampFac
		oldEyeAngles = eyeAngles
		--calculate motions, based on Juckey's methods
		counterMotion = LerpAngle(rft * (swayRate * (0.75 + math.max(0, 0.5 - wiggleFactor))), counterMotion, -motion)
		compensation.p = math.AngleDifference(motion.p, -counterMotion.p)
		compensation.y = math.AngleDifference(motion.y, -counterMotion.y)
		motion = LerpAngle(rft * swayRate, motion, delta + compensation)
	end

	--modify position/angle
	positionCompensation = 0.2 + 0.2 * ((self2.IronSightsProgressUnpredicted or self:GetIronSightsProgress()) or 0)
	pos:Add(-motion.y * positionCompensation * 0.66 * fac * ang:Right() * flipFactor) --compensate position for yaw
	pos:Add(-motion.p * positionCompensation * fac * ang:Up()) --compensate position for pitch
	ang:RotateAroundAxis(ang:Right(), motion.p * fac)
	ang:RotateAroundAxis(ang:Up(), -motion.y * 0.66 * fac * flipFactor)
	ang:RotateAroundAxis(ang:Forward(), counterMotion.r * 0.5 * fac * flipFactor)

	return pos, ang
end
