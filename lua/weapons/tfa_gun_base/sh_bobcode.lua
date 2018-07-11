SWEP.ti = 0
SWEP.LastCalcBob = 0
SWEP.tiView = 0
SWEP.LastCalcViewBob = 0
local TAU = math.pi * 2
local rateScaleFac = 2
local rate_up = 6 * rateScaleFac
local scale_up = 0.3
local rate_right = 3 * rateScaleFac
local scale_right = 0.3
local rate_forward_view = 3 * rateScaleFac
local scale_forward_view = 0.35
local rate_right_view = 3 * rateScaleFac
local scale_right_view = -1
local rate_p = 6 * rateScaleFac
local scale_p = 3
local rate_y = 3 * rateScaleFac
local scale_y = 6
local rate_r = 3 * rateScaleFac
local scale_r = -3
local pist_rate = 3 * rateScaleFac
local pist_scale = 9
local rate_clamp = 2 * rateScaleFac
local walkIntensitySmooth, breathIntensitySmooth = 0, 0
local walkRate = 160 / 60 * TAU / 1.085 / 2 * rateScaleFac --steps are at 160bpm at default velocity, then divide that by 60 for per-second, multiply by TAU for trig, divided by default walk rate
local walkVec = Vector()
local ownerVelocity, ownerVelocityMod = Vector(), Vector()
local zVelocity, zVelocitySmooth = 0, 0
local xVelocity, xVelocitySmooth, rightVec = 0, 0, Vector()
local flatVec = Vector(1, 1, 0)
local WalkPos = Vector()
local WalkPosLagged = Vector()
local gunbob_intensity_cvar = GetConVar("cl_tfa_gunbob_intensity")
local gunbob_intensity = 0
SWEP.VMOffsetWalk = Vector(0.5, -0.5, -0.5)
SWEP.footstepTotal = 0
SWEP.footstepTotalTarget = 0
local upVec, riVec, fwVec = Vector(0, 0, 1), Vector(1, 0, 0), Vector(0, 1, 0)

function SWEP:CalculateBob(pos, ang, breathIntensity, walkIntensity, runIntensity, rate, ftv)
	if not self:OwnerIsValid() then return end
	rate = math.min(rate or 0.5, rate_clamp)
	gunbob_intensity = gunbob_intensity_cvar:GetFloat()
	local ea = self.Owner:EyeAngles()
	local up = ang:Up()
	local ri = ang:Right()
	local fw = ang:Forward()
	local upLocal = upVec
	local riLocal = riVec
	local fwLocal = fwVec
	local delta = ftv
	local flip_v = self.ViewModelFlip and -1 or 1
	--delta = delta * game.GetTimeScale()
	--self.LastCalcBob = SysTime()
	self.bobRateCached = rate
	self.ti = self.ti + delta * rate

	if self.SprintStyle == nil then
		if self.RunSightsAng and self.RunSightsAng.x > 5 then
			self.SprintStyle = 1
		else
			self.SprintStyle = 0
		end
	end

	--preceding calcs
	walkIntensitySmooth = Lerp(delta * 10 * rateScaleFac, walkIntensitySmooth, walkIntensity)
	breathIntensitySmooth = Lerp(delta * 10 * rateScaleFac, breathIntensitySmooth, breathIntensity)
	walkVec = LerpVector(walkIntensitySmooth, vector_origin, self.VMOffsetWalk)
	ownerVelocity = self:GetOwner():GetVelocity()
	zVelocity = ownerVelocity.z
	zVelocitySmooth = Lerp(delta * 7 * rateScaleFac, zVelocitySmooth, zVelocity)
	ownerVelocityMod = ownerVelocity * flatVec
	ownerVelocityMod:Normalize()
	rightVec = ea:Right() * flatVec
	rightVec:Normalize()
	xVelocity = ownerVelocity:Length2D() * ownerVelocityMod:Dot(rightVec)
	xVelocitySmooth = Lerp(delta * 5 * rateScaleFac, xVelocitySmooth, xVelocity)
	--multipliers
	breathIntensity = breathIntensitySmooth * gunbob_intensity * 1.5
	walkIntensity = walkIntensitySmooth * gunbob_intensity * 1.5
	runIntensity = runIntensity * gunbob_intensity * 1.5
	--breathing
	pos:Add(riLocal * math.cos(self.ti * walkRate / 2) * flip_v * breathIntensity * 0.6)
	pos:Add(upLocal * math.sin(self.ti * walkRate) * breathIntensity * 0.3)
	--walk anims, danny method because i just can't
	self.walkTI = (self.walkTI or 0) + delta * 160 / 60 * self:GetOwner():GetVelocity():Length2D() / self:GetOwner():GetWalkSpeed()
	WalkPos.x = Lerp(delta * 5 * rateScaleFac, WalkPos.x, -math.sin(self.ti * walkRate * 0.5) * gunbob_intensity * walkIntensity)
	WalkPos.y = Lerp(delta * 5 * rateScaleFac, WalkPos.y, math.sin(self.ti * walkRate) / 1.5 * gunbob_intensity * walkIntensity)
	WalkPosLagged.x = Lerp(delta * 5 * rateScaleFac, WalkPosLagged.x, -math.sin((self.ti * walkRate * 0.5) + math.pi / 3) * gunbob_intensity * walkIntensity)
	WalkPosLagged.y = Lerp(delta * 5 * rateScaleFac, WalkPosLagged.y, math.sin(self.ti * walkRate + math.pi / 3) / 1.5 * gunbob_intensity * walkIntensity)
	pos:Add(WalkPos.x * 0.33 * riLocal)
	pos:Add(WalkPos.y * 0.25 * upLocal)
	ang:RotateAroundAxis(ri, -WalkPosLagged.y)
	ang:RotateAroundAxis(up, WalkPosLagged.x)
	ang:RotateAroundAxis(fw, WalkPos.x)
	--constant offset
	pos:Add(ri * walkVec.x * flip_v)
	pos:Add(fw * walkVec.y)
	pos:Add(up * walkVec.z)
	--jumping
	local trigX = -math.Clamp(zVelocitySmooth / 200, -1, 1) * math.pi / 2
	local jumpIntensity = (3 + math.Clamp(math.abs(zVelocitySmooth) - 100, 0, 200) / 200 * 4) * (1 - self.IronSightsProgress * 0.8)
	pos:Add(ri * math.sin(trigX) * scale_r * 0.1 * jumpIntensity * flip_v * 0.4)
	pos:Add(-up * math.sin(trigX) * scale_r * 0.1 * jumpIntensity * 0.4)
	ang:RotateAroundAxis(ang:Forward(), math.sin(trigX) * scale_r * jumpIntensity * flip_v * 0.4)
	--rolling with horizontal motion
	local xVelocityClamped = xVelocitySmooth

	if math.abs(xVelocityClamped) > 200 then
		local sign = (xVelocityClamped < 0) and -1 or 1
		xVelocityClamped = (math.sqrt((math.abs(xVelocityClamped) - 200) / 50) * 50 + 200) * sign
	end

	ang:RotateAroundAxis(ang:Forward(), xVelocityClamped * 0.04 * flip_v)

	--sprint calculations
	if self.SprintProgress > 0.005 then
		if self.SprintStyle == 1 then
			local intensity3 = math.max(runIntensity - 0.3, 0) / (1 - 0.3)
			ang:RotateAroundAxis(up, math.sin(self.ti * pist_rate) * pist_scale * intensity3 * 0.33 * 0.6)
			ang:RotateAroundAxis(ri, math.sin(self.ti * pist_rate) * pist_scale * intensity3 * 0.33 * 0.25)
			ang:RotateAroundAxis(fw, math.sin(self.ti * pist_rate) * pist_scale * intensity3 * 0.33 * 0.25)
			pos:Add(fwLocal * math.sin(self.ti * pist_rate) * pist_scale * 0.1 * intensity3 * 0.33)
			pos:Add(fwLocal * math.sin(self.ti * pist_rate * 2 + math.pi) * pist_scale * -0.1 * intensity3 * 0.5)
			pos:Add(riLocal * math.sin(self.ti * pist_rate) * pist_scale * 0.15 * intensity3 * 0.33 * 1)
		else
			pos:Add(-up * math.sin(self.ti * rate_up) * scale_up * runIntensity * 0.33)
			pos:Add(ri * math.sin(self.ti * rate_right) * scale_right * runIntensity * flip_v * 0.33)
			pos:Add(fwLocal * math.max(math.sin(self.ti * rate_forward_view), 0) * scale_forward_view * runIntensity * 0.33)
			pos:Add(riLocal * math.sin(self.ti * rate_right_view) * scale_right_view * runIntensity * flip_v * 0.33)
			ang:RotateAroundAxis(ri, math.sin(self.ti * rate_p) * scale_p * runIntensity * 0.33)
			pos:Add(up * math.sin(self.ti * rate_p) * scale_p * 0.1 * runIntensity * 0.33)
			pos:Add(-fw * math.sin(self.ti * rate_p) * scale_p * 0.1 * runIntensity * 0.33)
			pos:Add(ri * math.sin(self.ti * rate_y) * scale_y * 0.1 * runIntensity * flip_v * 0.33)
			pos:Add(fw * math.sin(self.ti * rate_y) * scale_y * 0.1 * runIntensity * 0.33)
			ang:RotateAroundAxis(ang:Up(), math.sin(self.ti * rate_y) * scale_y * runIntensity * flip_v * 0.5)
			pos:Add(ri * math.sin(self.ti * rate_r) * scale_r * 0.1 * runIntensity * flip_v * 0.5)
			pos:Add(up * math.sin(self.ti * rate_r) * scale_r * 0.1 * runIntensity * 0.7)
			ang:RotateAroundAxis(ang:Forward(), math.sin(self.ti * rate_r) * scale_r * runIntensity * flip_v * 0.5)
		end
	end

	return pos, ang
end