
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

TFA.GUESS_NPC_WALKSPEED = 160

local function l_Lerp(t, a, b) return a + (b - a) * t end
local function l_mathMin(a, b) return (a < b) and a or b end
local function l_mathMax(a, b) return (a > b) and a or b end
local function l_ABS(a) return (a < 0) and -a or a end
local function l_mathClamp(t, a, b)
	if t > b then
		return b
	end

	if t < a then
		return a
	end

	return t
end

local function l_mathApproach(a, b, delta)
	if a < b then
		return l_mathMin(a + l_ABS(delta), b)
	else
		return l_mathMax(a - l_ABS(delta), b)
	end
end

local sprint_cv = GetConVar("sv_tfa_sprint_enabled")

function SWEP:TFAFinishMove(ply, velocity, movedata)
	local ft = FrameTime()
	local self2 = self:GetTable()
	local isply = ply:IsPlayer()

	local jr_targ = math.min(math.abs(velocity.z) / 500, 1)
	self:SetNW2Float("JumpRatio", l_mathApproach(self:GetNW2Float("JumpRatio", 0), jr_targ, (jr_targ - self:GetNW2Float("JumpRatio", 0)) * ft * 20))
	self2.JumpRatio = self:GetNW2Float("JumpRatio", 0)
	self:SetNW2Float("CrouchingRatio", l_mathApproach(self:GetNW2Float("CrouchingRatio", 0), ((isply and ply:Crouching()) and ply:OnGround()) and 1 or 0, ft / self2.ToCrouchTime))
	self2.CrouchingRatio = self:GetNW2Float("CrouchingRatio", 0)

	local status = self2.GetStatus(self)
	local oldsprinting, oldwalking = self:GetSprinting(), self:GetWalking()
	local vellen = velocity:Length2D()

	if TFA.Enum.ReloadStatus[status] then
		self:SetSprinting(false)
	elseif sprint_cv:GetBool() and not self:GetStat("AllowSprintAttack", false) and movedata then
		self:SetSprinting(vellen > ply:GetRunSpeed() * 0.6 and movedata:KeyDown(IN_SPEED) and ply:OnGround())
	else
		self:SetSprinting(false)
	end

	self:SetWalking(vellen > ((isply and ply:GetWalkSpeed() or TFA.GUESS_NPC_WALKSPEED) * self:GetStat("MoveSpeed", 1) * .75) and ply:GetNW2Bool("TFA_IsWalking") and ply:OnGround() and not self:GetSprinting() and not self:GetCustomizing())

	self2.walking_updated = oldwalking ~= self:GetWalking()
	self2.sprinting_updated = oldsprinting ~= self:GetSprinting()

	if self:GetCustomizing() and (self2.GetIronSights(self) or self:GetSprinting() or not TFA.Enum.ReadyStatus[status]) then
		self:ToggleCustomize()
	end

	local spr = self:GetSprinting(self)
	local walk = self:GetWalking(self)

	local sprt = spr and 1 or 0
	local walkt = walk and 1 or 0
	local adstransitionspeed = (spr or walk) and 7.5 or 12.5

	self:SetNW2Float("SprintProgress", l_mathApproach(self:GetNW2Float("SprintProgress", 0), sprt, (sprt - self:GetNW2Float("SprintProgress", 0)) * ft * adstransitionspeed))
	self:SetNW2Float("WalkProgress", l_mathApproach(self:GetNW2Float("WalkProgress", 0), walkt, (walkt - self:GetNW2Float("WalkProgress", 0)) * ft * adstransitionspeed))

	self:SetNW2Float("LastVelocity", vellen)
end

hook.Add("FinishMove", "TFAFinishMove", function(self, movedata)
	local weapon = self:GetActiveWeapon()

	if IsValid(weapon) and weapon:IsTFA() then
		weapon:TFAFinishMove(self, movedata:GetVelocity(), movedata)
	end
end)

local sp = game.SinglePlayer()
local sv_tfa_recoil_legacy = GetConVar("sv_tfa_recoil_legacy")

function SWEP:CalculateRatios()
	local owent = self:GetOwner()
	--if not IsValid(owent) or not owent:IsPlayer() then return end
	if not IsValid(owent) then return end

	local self2 = self:GetTable()

	if self2.ratios_calc == nil then
		self2.ratios_calc = true
	end

	local ft = FrameTime()

	local is = self2.GetIronSights(self)
	local spr = self2.GetSprinting(self)
	local walk = self2.GetWalking(self)

	local ist = is and 1 or 0
	local sprt = spr and 1 or 0
	local walkt = walk and 1 or 0
	local adstransitionspeed

	if is then
		adstransitionspeed = 12.5 / (self:GetStat("IronSightTime") / 0.3)
	elseif spr or walk then
		adstransitionspeed = 7.5
	else
		adstransitionspeed = 12.5
	end

	if not owent:IsPlayer() then
		self:TFAFinishMove(owent, owent:GetVelocity())
	end

	self:SetNW2Float("SpreadRatio", l_mathClamp(self:GetNW2Float("SpreadRatio", 0) - self2.GetStat(self, "Primary.SpreadRecovery") * ft, 1, self2.GetStat(self, "Primary.SpreadMultiplierMax")))
	self:SetNW2Float("IronSightsProgress", l_mathApproach(self:GetNW2Float("IronSightsProgress", 0), ist, (ist - self:GetNW2Float("IronSightsProgress", 0)) * ft * adstransitionspeed))
	self:SetNW2Float("ProceduralHolsterProgress", l_mathApproach(self:GetNW2Float("ProceduralHolsterProgress", 0), sprt, (sprt - self:GetNW2Float("SprintProgress", 0)) * ft * self2.ProceduralHolsterTime * 15))
	self:SetNW2Float("InspectingProgress", l_mathApproach(self:GetNW2Float("InspectingProgress", 0), self:GetCustomizing() and 1 or 0, ((self:GetCustomizing() and 1 or 0) - self:GetNW2Float("InspectingProgress", 0)) * (ft / game.GetTimeScale()) * 10))

	if not sv_tfa_recoil_legacy:GetBool() then
		ft = l_mathClamp(ft, 0, 1)
		self:SetNW2Float("ViewPunchBuild", l_mathMax(0, self:GetNW2Float("ViewPunchBuild") - self:GetNW2Float("ViewPunchBuild") * ft))
		local build = l_mathMax(0, 4.5 - self:GetNW2Float("ViewPunchBuild"))
		ft = ft * build * build
		self:SetNW2Float("ViewPunchP", self:GetNW2Float("ViewPunchP") - self:GetNW2Float("ViewPunchP") * ft)
		self:SetNW2Float("ViewPunchY", self:GetNW2Float("ViewPunchY") - self:GetNW2Float("ViewPunchY") * ft)
	end

	self2.SpreadRatio = self:GetNW2Float("SpreadRatio", 0)
	self2.IronSightsProgress = self:GetNW2Float("IronSightsProgress", 0)
	self2.SprintProgress = self:GetNW2Float("SprintProgress", 0)
	self2.WalkProgress = self:GetNW2Float("WalkProgress", 0)
	self2.ProceduralHolsterProgress = self:GetNW2Float("ProceduralHolsterProgress", 0)
	self2.InspectingProgress = self:GetNW2Float("InspectingProgress", 0)

	if sp and CLIENT then
		self2.Inspecting = self:GetCustomizing() --compatibility
	end

	self2.CLIronSightsProgress = self:GetNW2Float("IronSightsProgress") --compatibility
end

SWEP.IronRecoilMultiplier = 0.5 --Multiply recoil by this factor when we're in ironsights.  This is proportional, not inversely.
SWEP.CrouchRecoilMultiplier = 0.65 --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.JumpRecoilMultiplier = 1.3 --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.WallRecoilMultiplier = 1.1 --Multiply recoil by this factor when we're changing state e.g. not completely ironsighted.  This is proportional, not inversely.
SWEP.ChangeStateRecoilMultiplier = 1.3 --Multiply recoil by this factor when we're crouching.  This is proportional, not inversely.
SWEP.CrouchAccuracyMultiplier = 0.5 --Less is more.  Accuracy * 0.5 = Twice as accurate, Accuracy * 0.1 = Ten times as accurate
SWEP.ChangeStateAccuracyMultiplier = 1.5 --Less is more.  A change of state is when we're in the progress of doing something, like crouching or ironsighting.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.JumpAccuracyMultiplier = 2 --Less is more.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.WalkAccuracyMultiplier = 1.35 --Less is more.  Accuracy * 2 = Half as accurate.  Accuracy * 5 = 1/5 as accurate
SWEP.ToCrouchTime = 0.2

local mult_cvar = GetConVar("sv_tfa_spread_multiplier")
local dynacc_cvar = GetConVar("sv_tfa_dynamicaccuracy")
local ccon, crec

SWEP.JumpRatio = 0

function SWEP:CalculateConeRecoil()
	local dynacc = false
	local self2 = self:GetTable()
	local isr = self:GetNW2Float("IronSightsProgress", 0)

	if dynacc_cvar:GetBool() and (self2.GetStat(self, "Primary.NumShots") <= 1) then
		dynacc = true
	end

	local isr_1 = l_mathClamp(isr * 2, 0, 1)
	local isr_2 = l_mathClamp((isr - 0.5) * 2, 0, 1)
	local acv = self2.GetStat(self, "Primary.Spread") or self2.GetStat(self, "Primary.Accuracy")
	local recv = self2.GetStat(self, "Primary.Recoil") * 5

	if dynacc then
		ccon = l_Lerp(isr_2, l_Lerp(isr_1, acv, acv * self2.GetStat(self, "ChangeStateAccuracyMultiplier")), self2.GetStat(self, "Primary.IronAccuracy"))
		crec = l_Lerp(isr_2, l_Lerp(isr_1, recv, recv * self2.GetStat(self, "ChangeStateRecoilMultiplier")), recv * self2.GetStat(self, "IronRecoilMultiplier"))
	else
		ccon = l_Lerp(isr, acv, self2.GetStat(self, "Primary.IronAccuracy"))
		crec = l_Lerp(isr, recv, recv * self2.GetStat(self, "IronRecoilMultiplier"))
	end

	local crc_1 = l_mathClamp(self:GetNW2Float("CrouchingRatio") * 2, 0, 1)
	local crc_2 = l_mathClamp((self:GetNW2Float("CrouchingRatio") - 0.5) * 2, 0, 1)

	if dynacc then
		ccon = l_Lerp(crc_2, l_Lerp(crc_1, ccon, ccon * self2.GetStat(self, "ChangeStateAccuracyMultiplier")), ccon * self2.GetStat(self, "CrouchAccuracyMultiplier"))
		crec = l_Lerp(crc_2, l_Lerp(crc_1, crec, self2.GetStat(self, "Primary.Recoil") * self2.GetStat(self, "ChangeStateRecoilMultiplier")), crec * self2.GetStat(self, "CrouchRecoilMultiplier"))
	end

	local owner = self:GetOwner()
	local isply = owner:IsPlayer()
	local ovel

	if IsValid(owner) then
		if owner:IsPlayer() then
			ovel = self:GetNW2Float("LastVelocity")
		else
			ovel = owner:GetVelocity():Length2D()
		end
	else
		ovel = 0
	end

	local vfc_1 = l_mathClamp(ovel / (isply and owner:GetWalkSpeed() or TFA.GUESS_NPC_WALKSPEED), 0, 2)

	if dynacc then
		ccon = l_Lerp(vfc_1, ccon, ccon * self2.GetStat(self, "WalkAccuracyMultiplier"))
		crec = l_Lerp(vfc_1, crec, crec * self2.GetStat(self, "WallRecoilMultiplier"))
	end

	local jr = self:GetNW2Float("JumpRatio")

	if dynacc then
		ccon = l_Lerp(jr, ccon, ccon * self2.GetStat(self, "JumpAccuracyMultiplier"))
		crec = l_Lerp(jr, crec, crec * self2.GetStat(self, "JumpRecoilMultiplier"))
	end

	ccon = ccon * self:GetNW2Float("SpreadRatio")

	if mult_cvar then
		ccon = ccon * mult_cvar:GetFloat()
	end

	if not isply and IsValid(owner) then
		local prof = owner:GetCurrentWeaponProficiency()

		if prof == WEAPON_PROFICIENCY_POOR then
			ccon = ccon * 8
		elseif prof == WEAPON_PROFICIENCY_AVERAGE then
			ccon = ccon * 5
		elseif prof == WEAPON_PROFICIENCY_GOOD then
			ccon = ccon * 3
		elseif prof == WEAPON_PROFICIENCY_VERY_GOOD then
			ccon = ccon * 2
		elseif prof == WEAPON_PROFICIENCY_PERFECT then
			ccon = ccon * 1.5
		end
	end

	return ccon, crec
end
