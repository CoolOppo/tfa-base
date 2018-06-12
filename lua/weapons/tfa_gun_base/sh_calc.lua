local l_Lerp = function(t, a, b) return a + ( b - a ) * t end
local l_mathMin = function(a,b) return ( a<b ) and a or b end
local l_mathMax = function(a,b) return ( a>b ) and a or b end
local l_ABS = function(a) return (a<0) and -a or a end
local l_mathClamp = function(t,a,b) return l_mathMax(l_mathMin( t,b),a) end
local l_mathApproach = function(a,b,delta)
	if a<b then
		return l_mathMin(a+l_ABS(delta),b)
	else
		return l_mathMax(a-l_ABS(delta),b)
	end
end

local is, spr, ist, sprt, ft, hlst, stat,jr_targ
ft = 0.01

SWEP.LastRatio = nil

local host_timescale_cv = GetConVar("host_timescale")
local sv_cheats_cv = GetConVar("sv_cheats")

function SWEP:CalculateRatios()
	local owent = self:GetOwner()
	if not IsValid(owent) or not owent:IsPlayer() then return end
	ft = TFA.FrameTime()
	stat = self:GetStatus()
	is = self:GetIronSights()
	spr = self:GetSprinting()
	ist = is and 1 or 0
	sprt = spr and 1 or 0
	hlst = ( ( TFA.Enum.HolsterStatus[ stat ] and self.ProceduralHolsterEnabled ) or ( TFA.Enum.ReloadStatus[ stat ] and self.ProceduralReloadEnabled ) ) and 1 or 0
	adstransitionspeed = 12.5
	if is then
		adstransitionspeed = 12.5 / ( self:GetStat("IronSightTime") / 0.3 )
	elseif spr then
		adstransitionspeed = 7.5
	end
	self.CrouchingRatio = l_mathApproach(self.CrouchingRatio or 0, owent:Crouching() and 1 or 0, ft / self.ToCrouchTime)
	self.SpreadRatio = l_mathClamp(self.SpreadRatio - self:GetStat("Primary.SpreadRecovery") * ft, 1, self:GetStat("Primary.SpreadMultiplierMax"))
	self.IronSightsProgress = l_mathApproach(self.IronSightsProgress,ist, (ist - self.IronSightsProgress ) * ft * adstransitionspeed )
	self.SprintProgress = l_mathApproach(self.SprintProgress,sprt, (sprt - self.SprintProgress ) * ft * adstransitionspeed )
	self.ProceduralHolsterProgress = l_mathApproach(self.ProceduralHolsterProgress,sprt, (sprt - self.SprintProgress ) * ft * self.ProceduralHolsterTime * 15 )
	self.InspectingProgress = l_mathApproach(self.InspectingProgress, self.Inspecting and 1 or 0, ( ( self.Inspecting and 1 or 0 )  - self.InspectingProgress ) * ft * 10 )
	self.CLIronSightsProgress = self.IronSightsProgress--compatibility
	jr_targ = math.min( math.abs(owent:GetVelocity().z) / 500, 1)
	self.JumpRatio = l_mathApproach(self.JumpRatio, jr_targ, ( jr_targ  - self.JumpRatio ) * ft * 20 )
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
local ccon,crec

SWEP.JumpRatio = 0

function SWEP:CalculateConeRecoil()
	tmpiron = self:GetIronSights()
	local dynacc = false
	isr = self.IronSightsProgress or 0

	if dynacc_cvar:GetBool() and (self:GetStat("Primary.NumShots") <= 1) then
		dynacc = true
	end

	local isr_1 = l_mathClamp(isr * 2, 0, 1)
	local isr_2 = l_mathClamp((isr - 0.5) * 2, 0, 1)
	local acv = self:GetStat("Primary.Spread") or self:GetStat("Primary.Accuracy")
	local recv = self:GetStat("Primary.Recoil") * 5

	if dynacc then
		ccon = l_Lerp(isr_2, l_Lerp(isr_1, acv, acv * self:GetStat("ChangeStateAccuracyMultiplier")), self:GetStat("Primary.IronAccuracy"))
		crec = l_Lerp(isr_2, l_Lerp(isr_1, recv, recv * self:GetStat("ChangeStateRecoilMultiplier")), recv * self:GetStat("IronRecoilMultiplier"))
	else
		ccon = l_Lerp(isr, acv, self:GetStat("Primary.IronAccuracy"))
		crec = l_Lerp(isr, recv, recv * self:GetStat("IronRecoilMultiplier"))
	end

	local crc_1 = l_mathClamp(self.CrouchingRatio * 2, 0, 1)
	local crc_2 = l_mathClamp((self.CrouchingRatio - 0.5) * 2, 0, 1)

	if dynacc then
		ccon = l_Lerp(crc_2, l_Lerp(crc_1, ccon, ccon * self:GetStat("ChangeStateAccuracyMultiplier")), ccon * self:GetStat("CrouchAccuracyMultiplier"))
		crec = l_Lerp(crc_2, l_Lerp(crc_1, crec, self:GetStat("Primary.Recoil") * self:GetStat("ChangeStateRecoilMultiplier")), crec * self:GetStat("CrouchRecoilMultiplier"))
	end

	local ovel = self:GetOwner():GetVelocity():Length2D()
	local vfc_1 = l_mathClamp(ovel / self:GetOwner():GetWalkSpeed(), 0, 2)

	if dynacc then
		ccon = l_Lerp(vfc_1, ccon, ccon * self:GetStat("WalkAccuracyMultiplier"))
		crec = l_Lerp(vfc_1, crec, crec * self:GetStat("WallRecoilMultiplier"))
	end

	local jr = self.JumpRatio
	if dynacc then
		ccon = l_Lerp(jr, ccon, ccon * self:GetStat("JumpAccuracyMultiplier"))
		crec = l_Lerp(jr, crec, crec * self:GetStat("JumpRecoilMultiplier"))
	end

	ccon = ccon * self.SpreadRatio

	if mult_cvar then
		ccon = ccon * mult_cvar:GetFloat()
	end

	return ccon, crec
end

local righthanded,shouldflip,cl_vm_flip_cv

function SWEP:CalculateViewModelFlip()
	if CLIENT and not cl_vm_flip_cv then
		cl_vm_flip_cv = GetConVar("cl_tfa_viewmodel_flip")
	end
	if self.ViewModelFlipDefault == nil then
		self.ViewModelFlipDefault = self.ViewModelFlip
	end

	righthanded = true

	if SERVER and self:GetOwner():GetInfoNum("cl_tfa_viewmodel_flip", 0) == 1 then
		righthanded = false
	end

	if CLIENT and cl_vm_flip_cv:GetBool() then
		righthanded = false
	end

	shouldflip = self.ViewModelFlipDefault

	if not righthanded then
		shouldflip = not self.ViewModelFlipDefault
	end

	if self.ViewModelFlip ~= shouldflip then
		self.ViewModelFlip = shouldflip
	end
end