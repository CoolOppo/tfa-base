
function SWEP:GetSeed()
	local sd = math.floor( self:Clip1() + self:Ammo1() + self:Clip2() + self:Ammo2() + self:GetLastActivity() ) + self:GetNextIdleAnim() + self:GetNextPrimaryFire() + self:GetNextSecondaryFire()
	return math.Round( sd )
end

SWEP.SharedRandomValues = {

}

local seed

function SWEP:SharedRandom( min, max, id ) --math.random equivalent
	if min and not max then
		max = min
		min = 1
	end
	min = math.Round(min)
	max = math.Round(max)
	local key = ( id or "Weapon" ) .. min .. max
	seed = self:GetSeed()
	local val = math.floor( util.SharedRandom( id or "Weapon", min, max + 1 , seed ) )
	if self.SharedRandomValues[ key ] and self.SharedRandomValues[ key ] == val then
		if min < val and max > val then
			math.randomseed( seed )
			if ( math.Rand(0,1) < 0.5 ) then
				math.randomseed( seed + 1 )
				val = math.random( min, val - 1 )
			else
				math.randomseed( seed + 1 )
				val = math.random( val + 1, max )
			end
		elseif min < val then
			math.randomseed( seed + 1 )
			val = math.random( min, val - 1 )
		elseif max > val then
			math.randomseed( seed + 1 )
			val = math.random( val + 1, max )
		end
	end
	if IsFirstTimePredicted() then
		timer.Simple(0,function()
			if IsValid(self) then
				self.SharedRandomValues[ key ] = val
			end
		end)
	end
	return val
end

local oiv = nil

local rlcv = GetConVar("sv_tfa_reloads_enabled")

local holding_result_cached = false
local last_held_check = -1
local sp = game.SinglePlayer()
local sqlen

function SWEP:GetActivityLength( tanim )
	if not self:VMIV() then return 0 end
	sqlen = self.OwnerViewModel:SequenceDuration( self.OwnerViewModel:GetSequence() )
	if self.SequenceLengthOverride[tanim] then
		sqlen = self.SequenceLengthOverride[tanim]
	elseif self.SequenceRateOverride[tanim] then
		sqlen = self.SequenceRateOverride[tanim]
	elseif self.SequenceRateOverrideScaled[tanim] then
		sqlen = sqlen / self.SequenceRateOverrideScaled[tanim]
	end
	sqlen = sqlen / self:NZAnimationSpeed( tanim )
	return sqlen
end

function SWEP:GetAnimationRate( tanim )
	sqlen = 1
	if self.SequenceRateOverride[tanim] then
		sqlen = self.SequenceRateOverride[tanim]
	elseif self.SequenceRateOverrideScaled[tanim] then
		sqlen = sqlen / self.SequenceRateOverrideScaled[tanim]
	end
	sqlen = sqlen / self:NZAnimationSpeed( tanim )
	return sqlen
end

function SWEP:GetHolding()
	if CurTime() > last_held_check + 0.2 then
		last_held_check = CurTime()
		holding_result_cached = nil
	end

	if holding_result_cached == nil then
		holding_result_cached = false
		if not IsValid(self.Owner) or not self.Owner:IsPlayer() then
			holding_result_cached = false
			return false
		end
		local ent = self.Owner:GetNW2Entity("LastHeldEntity")
		if not IsValid(ent) then
			holding_result_cached = false
			return false
		end
		if ent.IsPlayerHolding then
			ent:SetNW2Bool("PlayerHolding",ent:IsPlayerHolding())
		end
		if ent:GetNW2Bool("PlayerHolding") then
			holding_result_cached = true
			return true
		end
	end
	return holding_result_cached
end

function SWEP:CanInterruptShooting()
	return self:GetStat("Primary.RPM") > 160 and not self:GetStat("BoltAction") and not self:GetStat("BoltAction_Forced")
end

function SWEP:ReloadCV()
	if rlcv then
		if ( not rlcv:GetBool() ) and (not self.Primary.ClipSize_PreEdit) then
			self.Primary.ClipSize_PreEdit = self.Primary.ClipSize
			self.Primary.ClipSize = -1
		elseif rlcv:GetBool() and self.Primary.ClipSize_PreEdit then
			self.Primary.ClipSize = self.Primary.ClipSize_PreEdit
			self.Primary.ClipSize_PreEdit = nil
		end
	end
end

function SWEP:OwnerIsValid()
	if oiv == nil then oiv = IsValid(self.Owner) end
	return oiv
end

function SWEP:NullifyOIV()
	if oiv ~= nil then
		self:GetHolding()
		oiv = nil
	end
	return self:VMIV()
end

function SWEP:VMIV()
	if not IsValid(self.OwnerViewModel) then
		if IsValid(self.Owner) and self.Owner.GetViewModel then
			self.OwnerViewModel = self.Owner:GetViewModel()
		end
		return false
	else
		return self.OwnerViewModel
	end
end

function SWEP:CanChamber()
	if self.C_CanChamber ~= nil then
		return self.C_CanChamber
	else
		self.C_CanChamber = not self:GetStat("BoltAction") and not self.Shotgun and not self.Revolver and not self:GetStat("DisableChambering")

		return self.C_CanChamber
	end
end

function SWEP:GetPrimaryClipSize( calc )
	targetclip = self:GetStat("Primary.ClipSize")

	if self:CanChamber() and not ( calc and self:Clip1() <= 0 ) then
		targetclip = targetclip + ( self.Akimbo and 2 or 1)
	end

	return math.max(targetclip,-1)
end

function SWEP:Ammo1()
	return self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() or 0 )
end

function SWEP:TakePrimaryAmmo( num, pool )

	-- Doesn't use clips
	if self:GetStat("Primary.ClipSize") < 0 or pool then

		if ( self:Ammo1() <= 0 ) then return end

		self.Owner:RemoveAmmo( math.min( self:Ammo1(), num), self:GetPrimaryAmmoType() )

		return
	end

	self:SetClip1( math.max(self:Clip1() - num,0) )

end

function SWEP:GetFireDelay()
	if self:GetMaxBurst() > 1 and self:GetStat("Primary.RPM_Burst") and self:GetStat("Primary.RPM_Burst") > 0 then
		return 60 / self:GetStat("Primary.RPM_Burst")
	elseif self:GetStat("Primary.RPM_Semi") and not self:GetStat("Primary.Automatic") and self:GetStat("Primary.RPM_Semi") and self:GetStat("Primary.RPM_Semi") > 0 then
		return 60 / self:GetStat("Primary.RPM_Semi")
	elseif self:GetStat("Primary.RPM") and self:GetStat("Primary.RPM") > 0 then
		return 60 / self:GetStat("Primary.RPM")
	else
		return self:GetStat("Primary.Delay") or 0.1
	end
end

function SWEP:GetBurstDelay(bur)
	if not bur then
		bur = self:GetMaxBurst()
	end

	if bur <= 1 then return 0 end
	if self:GetStat("Primary.BurstDelay") then return self:GetStat("Primary.BurstDelay") end

	return self:GetFireDelay() * 3
end

--[[
Function Name:  IsSafety
Syntax: self:IsSafety( ).
Returns:   Are we in safety firemode.
Notes:    Non.
Purpose:  Utility
]]--
function SWEP:IsSafety()
	if not self:GetStat("FireModes") then return false end
	local fm = self:GetStat("FireModes")[self:GetFireMode()]
	local fmn = string.lower(fm and fm or self:GetStat("FireModes")[1])

	if fmn == "safe" or fmn == "holster" then
		return true
	else
		return false
	end
end

function SWEP:UpdateMuzzleAttachment()
	if not self:VMIV() then return end
	vm = self.OwnerViewModel
	if not IsValid(vm) then return end
	self.MuzzleAttachmentRaw = nil

	if not self.MuzzleAttachmentSilenced then
		self.MuzzleAttachmentSilenced = (vm:LookupAttachment("muzzle_silenced") <= 0) and self.MuzzleAttachment or "muzzle_silenced"
	end

	if self:GetSilenced() and self.MuzzleAttachmentSilenced then
		self.MuzzleAttachmentRaw = vm:LookupAttachment(self.MuzzleAttachmentSilenced)

		if not self.MuzzleAttachmentRaw or self.MuzzleAttachmentRaw <= 0 then
			self.MuzzleAttachmentRaw = nil
		end
	end

	if not self.MuzzleAttachmentRaw and self.MuzzleAttachment then
		self.MuzzleAttachmentRaw = vm:LookupAttachment(self.MuzzleAttachment)

		if not self.MuzzleAttachmentRaw or self.MuzzleAttachmentRaw <= 0 then
			self.MuzzleAttachmentRaw = 1
		end
	end

	local mzm = self:GetStat("MuzzleAttachmentMod", 0)
	if mzm and mzm > 0 then
		self.MuzzleAttachmentRaw = mzm
	end
end

function SWEP:UpdateConDamage()
	if not IsValid(self) then return end

	if not self.DamageConVar then
		self.DamageConVar = GetConVar("sv_tfa_damage_multiplier")
	end

	if self.DamageConVar and self.DamageConVar.GetFloat then
		self.ConDamageMultiplier = self.DamageConVar:GetFloat()
	end
end

--[[
Function Name:  IsCurrentlyScoped
Syntax: self:IsCurrentlyScoped( ).
Returns:   Is the player scoped in enough to display the overlay?  true/false, returns a boolean.
Notes:    Change SWEP.ScopeOverlayThreshold to change when the overlay is displayed.
Purpose:  Utility
]]--
function SWEP:IsCurrentlyScoped()
	return (self.IronSightsProgress > self:GetStat("ScopeOverlayThreshold")) and self:GetStat("Scoped")
end

--[[
Function Name:  IsHidden
Syntax: self:IsHidden( ).
Returns:   Should we hide self?.
Notes:
Purpose:  Utility
]]--
function SWEP:GetHidden()
	if not self:VMIV() then return true end
	if self.DrawViewModel ~= nil and not self.DrawViewModel then return true end
	if self.ShowViewModel ~= nil and not self.ShowViewModel then return true end
	if self:GetHolding() then return true end
	return self:IsCurrentlyScoped()
end

--[[
Function Name:  IsFirstPerson
Syntax: self:IsFirstPerson( ).
Returns:   Is the owner in first person.
Notes:    Broken in singplayer because gary.
Purpose:  Utility
]]--
function SWEP:IsFirstPerson()
	if not IsValid(self) or not self:OwnerIsValid() then return false end
	if sp and SERVER then return not self.Owner.TFASDLP end
	if self.Owner.ShouldDrawLocalPlayer and self.Owner:ShouldDrawLocalPlayer() then return false end
	local gmsdlp

	if LocalPlayer then
		gmsldp = hook.Call("ShouldDrawLocalPlayer", GAMEMODE, self.Owner)
	else
		gmsldp = false
	end

	if gmsdlp then return false end
	return true
end

--[[
Function Name:  GetMuzzlePos
Syntax: self:GetMuzzlePos( hacky workaround that doesn't work anyways ).
Returns:   The AngPos for the muzzle attachment.
Notes:    Defaults to the first attachment, and uses GetFPMuzzleAttachment
Purpose:  Utility
]]--
local fp
function SWEP:GetMuzzlePos(ignorepos)
	fp = self:IsFirstPerson()
	if not IsValid(vm) then
		vm = self.OwnerViewModel
	end
	if not IsValid(vm) then
		vm = self
	end

	obj = self.MuzzleAttachmentRaw or vm:LookupAttachment(self.MuzzleAttachment)
	obj = math.Clamp(obj or 1, 1, 128)

	if fp then
		muzzlepos = vm:GetAttachment(obj)
	else
		muzzlepos = self:GetAttachment(obj)
	end

	return muzzlepos
end

function SWEP:FindEvenBurstNumber()
	if (self:GetStat("Primary.ClipSize") % 3 == 0) then
		return 3
	elseif (self:GetStat("Primary.ClipSize") % 2 == 0) then
		return 2
	else
		local i = 4

		while i <= 7 do
			if self:GetStat("Primary.ClipSize") % i == 0 then return i end
			i = i + 1
		end
	end

	return nil
end


function SWEP:GetFireModeName()
	local fm = self:GetFireMode()
	local fmn = string.lower( self:GetStat("FireModes")[fm] )
	if fmn == "safe" or fmn == "holster" then return "Safety" end
	if self:GetStat("FireModeName") then return self:GetStat("FireModeName") end
	if fmn == "auto" or fmn == "automatic" then return "Full-Auto" end

	if fmn == "semi" or fmn == "single" then
		if self:GetStat("Revolver") then
			if (self:GetStat("BoltAction")) then
				return "Single-Action"
			else
				return "Double-Action"
			end
		else
			if (self:GetStat("BoltAction")) then
				return "Bolt-Action"
			else
				if (self.Shotgun and self:GetStat("Primary.RPM") < 250) then
					return "Pump-Action"
				else
					return "Semi-Auto"
				end
			end
		end
	end

	local bpos = string.find(fmn, "burst")
	if bpos then return string.sub(fmn, 1, bpos - 1) .. " Round Burst" end
	return ""
end

SWEP.BurstCountCache = {}

function SWEP:GetMaxBurst()
	local fm = self:GetFireMode()
	if not self.BurstCountCache[ fm ] then
		local fmn = string.lower( self.FireModes[fm] )
		local bpos = string.find(fmn, "burst")
		if bpos then
			self.BurstCountCache[ fm ] = tonumber( string.sub(fmn, 1, bpos - 1) )
		else
			self.BurstCountCache[ fm ] = 1
		end
	end
	return self.BurstCountCache[ fm ]
end

--[[
Function Name:  CycleFireMode
Syntax: self:CycleFireMode()
Returns:  Nothing.
Notes: Cycles to next firemode.
Purpose:  Feature
]]--
local l_CT = CurTime
function SWEP:CycleFireMode()
	local fm = self:GetFireMode()
	fm = fm + 1

	if fm >= #self:GetStat("FireModes") then
		fm = 1
	end

	self:SetFireMode(fm)
	self:EmitSound("Weapon_AR2.Empty")
	self:SetNextPrimaryFire(l_CT() + math.max( self:GetFireDelay(), 0.25))
	self.BurstCount = 0
	self:SetStatus(TFA.GetStatus("firemode"))
	self:SetStatusEnd( self:GetNextPrimaryFire() )
end

--[[
Function Name:  CycleSafety
Syntax: self:CycleSafety()
Returns:  Nothing.
Notes: Toggles safety
Purpose:  Feature
]]--
function SWEP:CycleSafety()
	ct = l_CT()
	local fm = self:GetFireMode()

	if fm ~= #self.FireModes then
		self.LastFireMode = fm
		self:SetFireMode(#self.FireModes)
	else
		self:SetFireMode(self.LastFireMode or 1)
	end

	self:EmitSound("Weapon_AR2.Empty")
	self:SetNextPrimaryFire(ct + math.max( self:GetFireDelay(), 0.25))
	self.BurstCount = 0
	--self:SetStatus(TFA.Enum.STATUS_FIREMODE)
	--self:SetStatusEnd( self:GetNextPrimaryFire() )
end

--[[
Function Name:  ProcessFireMode
Syntax: self:ProcessFireMode()
Returns:  Nothing.
Notes: Processes fire mode changing and whether the swep is auto or not.
Purpose:  Feature
]]--
local fm
local sp = game.SinglePlayer()

function SWEP:ProcessFireMode()
	if self.Owner:KeyPressed(IN_RELOAD) and self.Owner:KeyDown(IN_USE) and self:GetStatus() == TFA.Enum.STATUS_IDLE and ( SERVER or not sp ) then
		if self.SelectiveFire and not self.Owner:KeyDown(IN_SPEED) then
			self:CycleFireMode()
		elseif self.Owner:KeyDown(IN_SPEED) then
			self:CycleSafety()
		end
	end

	fm = self.FireModes[self:GetFireMode()]

	if fm == "Automatic" or fm == "Auto" then
		self.Primary.Automatic = true
	else
		self.Primary.Automatic = false
	end
end