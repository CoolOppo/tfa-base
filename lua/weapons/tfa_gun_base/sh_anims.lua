
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

SWEP.Locomotion_Data_Queued = nil

local ServersideLooped = {
	[ACT_VM_FIDGET] = true,
	[ACT_VM_FIDGET_EMPTY] = true
}

--[ACT_VM_IDLE] = true,
--[ACT_VM_IDLE_EMPTY] = true,
--[ACT_VM_IDLE_SILENCED] = true
local d, pbr

-- Override this after SWEP:Initialize, for example, in attachments
SWEP.BaseAnimations = {
	["draw_first"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRAW_DEPLOYED,
		["enabled"] = nil --Manually force a sequence to be enabled
	},
	["draw"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRAW
	},
	["draw_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRAW_EMPTY
	},
	["draw_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRAW_SILENCED
	},
	["shoot1"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_PRIMARYATTACK
	},
	["shoot1_last"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_PRIMARYATTACK_EMPTY
	},
	["shoot1_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRYFIRE
	},
	["shoot1_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_PRIMARYATTACK_SILENCED
	},
	["shoot1_silenced_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRYFIRE_SILENCED or 0
	},
	["shoot1_is"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_PRIMARYATTACK_1
	},
	["shoot2"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_SECONDARYATTACK
	},
	["shoot2_last"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "shoot2_last"
	},
	["shoot2_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DRYFIRE
	},
	["shoot2_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "shoot2_silenced"
	},
	["shoot2_is"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_ISHOOT_M203
	},
	["idle"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_IDLE
	},
	["idle_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_IDLE_EMPTY
	},
	["idle_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_IDLE_SILENCED
	},
	["reload"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_RELOAD
	},
	["reload_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_RELOAD_EMPTY
	},
	["reload_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_RELOAD_SILENCED
	},
	["reload_shotgun_start"] = {
		["type"] = TFA.Enum.ANIMATION_ACT,
		["value"] = ACT_SHOTGUN_RELOAD_START
	},
	["reload_shotgun_finish"] = {
		["type"] = TFA.Enum.ANIMATION_ACT,
		["value"] = ACT_SHOTGUN_RELOAD_FINISH
	},
	["reload_is"] = {
		["type"] = TFA.Enum.ANIMATION_ACT,
		["value"] = ACT_VM_RELOAD_ADS
	},
	["reload_empty_is"] = {
		["type"] = TFA.Enum.ANIMATION_ACT,
		["value"] = ACT_VM_RELOAD_EMPTY_ADS
	},
	["reload_silenced_is"] = {
		["type"] = TFA.Enum.ANIMATION_ACT,
		["value"] = ACT_VM_RELOAD_SILENCED_ADS
	},
	["reload_shotgun_start_is"] = {
		["type"] = TFA.Enum.ANIMATION_ACT,
		["value"] = ACT_SHOTGUN_RELOAD_START_ADS
	},
	["reload_shotgun_finish_is"] = {
		["type"] = TFA.Enum.ANIMATION_ACT,
		["value"] = ACT_SHOTGUN_RELOAD_FINISH_ADS
	},
	["holster"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_HOLSTER
	},
	["holster_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_HOLSTER_EMPTY
	},
	["holster_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_HOLSTER_SILENCED
	},
	["silencer_attach"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_ATTACH_SILENCER
	},
	["silencer_detach"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_DETACH_SILENCER
	},
	["rof"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_FIREMODE
	},
	["rof_is"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_IFIREMODE
	},
	["bash"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_HITCENTER
	},
	["bash_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_HITCENTER2
	},
	["bash_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_MISSCENTER
	},
	["bash_empty_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_MISSCENTER2
	},
	["inspect"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_FIDGET
	},
	["inspect_empty"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_FIDGET_EMPTY
	},
	["inspect_silenced"] = {
		["type"] = TFA.Enum.ANIMATION_ACT, --Sequence or act
		["value"] = ACT_VM_FIDGET_SILENCED
	}
}

SWEP.Animations = {}

function SWEP:InitializeAnims()
	local self2 = self:GetTable()

	setmetatable(self2.Animations, {
		__index = function(t, k) return self2.BaseAnimations[k] end
	})
end

function SWEP:BuildAnimActivities()
	local self2 = self:GetTable()
	self2.AnimationActivities = self2.AnimationActivities or {}

	for k, v in pairs(self2.BaseAnimations) do
		if v.value then
			self2.AnimationActivities[v.value] = k
		end
	end

	for k, _ in pairs(self2.BaseAnimations) do
		local kvt = self2.GetStat(self, "Animations." .. k)

		if kvt.value then
			self2.AnimationActivities[kvt.value] = k
		end
	end

	for k, _ in pairs(self2.Animations) do
		local kvt = self2.GetStat(self, "Animations." .. k)

		if kvt.value then
			self2.AnimationActivities[kvt.value] = k
		end
	end
end

function SWEP:GetActivityEnabled(act)
	local self2 = self:GetTable()
	local stat = self2.GetStat(self, "SequenceEnabled." .. act)
	if stat then return stat end

	if not self2.AnimationActivities then
		self:BuildAnimActivities()
	end

	local keysel = self2.AnimationActivities[act] or ""
	local kv = self2.GetStat(self, "Animations." .. keysel)
	if not kv then return false end

	if kv["enabled"] then
		return kv["enabled"]
	else
		return false
	end
end

function SWEP:ChooseAnimation(key)
	local self2 = self:GetTable()
	local kv = self2.GetStat(self, "Animations." .. key)
	if not kv then return 0, 0 end
	if not kv["type"] then return 0, 0 end
	if not kv["value"] then return 0, 0 end

	return kv["type"], kv["value"]
end

local sqto, sqro

function SWEP:GetAnimationRate(ani)
	local self2 = self:GetTable()
	local rate = 1
	if not ani or ani < 0 or not self:VMIV() then return rate end
	local nm = self2.OwnerViewModel:GetSequenceName(self2.OwnerViewModel:SelectWeightedSequence(ani))

	if IsValid(self) then
		sqto = self2.GetStat(self, "SequenceTimeOverride." .. nm) or self2.GetStat(self, "SequenceTimeOverride." .. (ani or "0"))
		sqro = self2.GetStat(self, "SequenceRateOverride." .. nm) or self2.GetStat(self, "SequenceRateOverride." .. (ani or "0"))

		if sqro then
			rate = rate * sqro
		elseif sqto then
			local t = self:GetActivityLengthRaw(ani, false)

			if t then
				rate = rate * t / sqto
			end
		end
	end

	rate = hook.Run("TFA_AnimationRate", self, ani, rate) or rate

	return rate
end

function SWEP:SendViewModelAnim(act, rate, targ, blend)
	local self2 = self:GetTable()
	local vm = self2.OwnerViewModel

	if rate and not targ then
		rate = math.max(rate, 0.0001)
	end

	if not rate then
		rate = 1
	end

	if targ then
		rate = rate / self:GetAnimationRate(act)
	else
		rate = rate * self:GetAnimationRate(act)
	end

	if act < 0 then return false, act end
	if not self:VMIV() then return false, act end
	local seq = vm:SelectWeightedSequenceSeeded(act, CurTime())

	if seq < 0 then
		if act == ACT_VM_IDLE_EMPTY then
			seq = vm:SelectWeightedSequenceSeeded(ACT_VM_IDLE, CurTime())
		elseif act == ACT_VM_PRIMARYATTACK_EMPTY then
			seq = vm:SelectWeightedSequenceSeeded(ACT_VM_PRIMARYATTACK, CurTime())
		else
			return
		end

		if seq < 0 then return false, act end
	end

	self2.LastAct = act
	self:ResetEvents()

	if self:GetLastActivity() == act and ServersideLooped[act] then
		self:ChooseIdleAnim()
		d = vm:SequenceDuration(seq)
		pbr = targ and (d / (rate or 1)) or (rate or 1)

		if IsValid(self) then
			if blend == nil then
				blend = self2.Idle_Smooth
			end

			self:SetNextIdleAnim(CurTime() + d / pbr - blend)
		end

		if IsFirstTimePredicted() then
			timer.Simple(0, function()
				vm:SendViewModelMatchingSequence(seq)
				d = vm:SequenceDuration()
				pbr = targ and (d / (rate or 1)) or (rate or 1)
				vm:SetPlaybackRate(pbr)

				if IsValid(self) then
					if blend == nil then
						blend = self2.Idle_Smooth
					end

					self:SetNextIdleAnim(CurTime() + d / pbr - blend)
					self:SetLastActivity(act)
					self2.LastAct = act
				end
			end)
		end
	else
		if seq >= 0 then
			vm:SendViewModelMatchingSequence(seq)
		end

		d = vm:SequenceDuration()
		pbr = targ and (d / (rate or 1)) or (rate or 1)
		vm:SetPlaybackRate(pbr)

		if blend == nil then
			blend = self2.Idle_Smooth
		end

		self:SetNextIdleAnim(CurTime() + math.max(d / pbr - blend, self2.Idle_Smooth))
	end

	self:SetLastActivity(act)

	return true, act
end

function SWEP:SendViewModelSeq(seq, rate, targ, blend)
	local self2 = self:GetTable()
	local seqold = seq
	local vm = self2.OwnerViewModel
	if not self:VMIV() then return false, 0 end

	if isstring(seq) then
		seq = vm:LookupSequence(seq) or 0
	end

	local act = vm:GetSequenceActivity(seq)

	if self2.SequenceRateOverride[seqold] then
		rate = self2.SequenceRateOverride[seqold]
		targ = false
	elseif self2.SequenceRateOverride[act] then
		rate = self2.SequenceRateOverride[act]
		targ = false
	elseif self2.SequenceTimeOverride[seqold] then
		rate = self2.SequenceTimeOverride[seqold]
		targ = true
	elseif self2.SequenceTimeOverride[act] then
		rate = self2.SequenceTimeOverride[act]
		targ = true
	end

	if not rate then
		rate = 1
	end

	if targ then
		rate = rate / self:GetAnimationRate(act)
	else
		rate = rate * self:GetAnimationRate(act)
	end

	if seq < 0 then return false, act end
	self2.LastAct = act
	self:ResetEvents()

	if self:GetLastActivity() == act and ServersideLooped[act] then
		vm:SendViewModelMatchingSequence(act == 0 and 1 or 0)
		vm:SetPlaybackRate(0)
		vm:SetCycle(0)
		self:SetNextIdleAnim(CurTime() + 0.03)

		if IsFirstTimePredicted() then
			timer.Simple(0, function()
				vm:SendViewModelMatchingSequence(seq)
				d = vm:SequenceDuration()
				pbr = targ and (d / (rate or 1)) or (rate or 1)
				vm:SetPlaybackRate(pbr)

				if IsValid(self) then
					if blend == nil then
						blend = self2.Idle_Smooth
					end

					self:SetNextIdleAnim(CurTime() + d / pbr - blend)
					self:SetLastActivity(act)
					self2.LastAct = act
				end
			end)
		end
	else
		if seq >= 0 then
			vm:SendViewModelMatchingSequence(seq)
		end

		d = vm:SequenceDuration()
		pbr = targ and (d / (rate or 1)) or (rate or 1)
		vm:SetPlaybackRate(pbr)

		if IsValid(self) then
			if blend == nil then
				blend = self2.Idle_Smooth
			end

			self:SetNextIdleAnim(CurTime() + d / pbr - blend)
		end
	end

	self:SetLastActivity(act)

	return true, act
end

local tval

function SWEP:PlayAnimation(data, fade, rate, targ)
	local self2 = self:GetTable()
	if not self:VMIV() then return end
	if not data then return false, -1 end
	local vm = self2.OwnerViewModel

	if data.type == TFA.Enum.ANIMATION_ACT then
		tval = data.value

		if self:Clip1() <= 0 and self2.Primary_TFA.ClipSize >= 0 then
			tval = data.value_empty or tval
		end

		if self:Clip1() == 1 and self2.Primary_TFA.ClipSize >= 0 then
			tval = data.value_last or tval
		end

		if self2.GetSilenced(self) then
			tval = data.value_sil or tval
		end

		if self:GetIronSightsDirect() then
			tval = data.value_is or tval

			if self:Clip1() <= 0 and self2.Primary_TFA.ClipSize >= 0 then
				tval = data.value_is_empty or tval
			end

			if self:Clip1() == 1 and self2.Primary_TFA.ClipSize >= 0 then
				tval = data.value_is_last or tval
			end

			if self2.GetSilenced(self) then
				tval = data.value_is_sil or tval
			end
		end

		if isstring(tval) then
			tval = tonumber(tval) or -1
		end

		if tval and tval > 0 then return self:SendViewModelAnim(tval, rate or 1, targ, fade or (data.transition and self2.Idle_Blend or self2.Idle_Smooth) ) end
	elseif data.type == TFA.Enum.ANIMATION_SEQ then
		tval = data.value

		if self:Clip1() <= 0 and self2.Primary_TFA.ClipSize >= 0 then
			tval = data.value_empty or tval
		end

		if self:Clip1() == 1 and self2.Primary_TFA.ClipSize >= 0 then
			tval = data.value_last or tval
		end

		if self2.GetSilenced(self) then
			tval = data.value_sil or tval
		end

		if self:GetIronSightsDirect() then
			tval = data.value_is or tval

			if self:Clip1() <= 0 and self2.Primary_TFA.ClipSize >= 0 then
				tval = data.value_is_empty or tval
			end

			if self:Clip1() == 1 and self2.Primary_TFA.ClipSize >= 0 then
				tval = data.value_is_last or tval
			end

			if self2.GetSilenced(self) then
				tval = data.value_is_sil or tval
			end
		end

		if isstring(tval) then
			tval = vm:LookupSequence(tval)
		end

		if tval and tval > 0 then return self:SendViewModelSeq(tval, rate or 1, targ, fade or (data.transition and self2.Idle_Blend or self2.Idle_Smooth) ) end
	end
end

local success, tanim, typev
--[[
Function Name:  Locomote
Syntax: self:Locomote( flip ironsights, new is, flip sprint, new sprint, flip walk, new walk).
Returns:
Notes:
Purpose:  Animation / Utility
]]
local tldata

function SWEP:Locomote(flipis, is, flipsp, spr, flipwalk, walk, flipcust, cust)
	local self2 = self:GetTable()
	if not (flipis or flipsp or flipwalk or flipcust) then return end
	if not (self:GetStatus() == TFA.Enum.STATUS_IDLE or (self:GetStatus() == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting())) then return end
	tldata = nil

	if flipis then
		if is and self2.GetStat(self, "IronAnimation.in") then
			tldata = self2.GetStat(self, "IronAnimation.in") or tldata
		elseif self2.GetStat(self, "IronAnimation.out") and not flipsp then
			tldata = self2.GetStat(self, "IronAnimation.out") or tldata
		end
	end

	if flipsp then
		if spr and self2.GetStat(self, "SprintAnimation.in") then
			tldata = self2.GetStat(self, "SprintAnimation.in") or tldata
		elseif self2.GetStat(self, "SprintAnimation.out") and not flipis and not spr then
			tldata = self2.GetStat(self, "SprintAnimation.out") or tldata
		end
	end

	if flipwalk and not is then
		if walk and self2.GetStat(self, "WalkAnimation.in") then
			tldata = self2.GetStat(self, "WalkAnimation.in") or tldata
		elseif self2.GetStat(self, "WalkAnimation.out") and (not flipis and not flipsp and not flipcust) and not walk then
			tldata = self2.GetStat(self, "WalkAnimation.out") or tldata
		end
	end

	if flipcust then
		if cust and self2.GetStat(self, "CustomizeAnimation.in") then
			tldata = self2.GetStat(self, "CustomizeAnimation.in") or tldata
		elseif self2.GetStat(self, "CustomizeAnimation.out") and (not flipis and not flipsp and not flipwalk) and not cust then
			tldata = self2.GetStat(self, "CustomizeAnimation.out") or tldata
		end
	end

	--self2.Idle_WithHeld = true
	if tldata then return self:PlayAnimation(tldata) end
	--self:SetNextIdleAnim(-1)

	return false, -1
end

--[[
Function Name:  ChooseDrawAnim
Syntax: self:ChooseDrawAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
SWEP.IsFirstDeploy = true

function SWEP:ChooseDrawAnim()
	local self2 = self:GetTable()
	if not self:VMIV() then return end
	--self:ResetEvents()
	tanim = ACT_VM_DRAW
	success = true

	if self2.IsFirstDeploy and CurTime() > (self2.LastDeployAnim or CurTime()) + 0.1 then
		self2.IsFirstDeploy = false
	end

	if self:GetActivityEnabled(ACT_VM_DRAW_EMPTY) and (self:Clip1() == 0) then
		typev, tanim = self:ChooseAnimation("draw_empty")
	elseif (self:GetActivityEnabled(ACT_VM_DRAW_DEPLOYED) or self2.FirstDeployEnabled) and self2.IsFirstDeploy then
		typev, tanim = self:ChooseAnimation("draw_first")
	elseif self:GetActivityEnabled(ACT_VM_DRAW_SILENCED) and self2.GetSilenced(self) then
		typev, tanim = self:ChooseAnimation("draw_silenced")
	else
		typev, tanim = self:ChooseAnimation("draw")
	end

	self2.LastDeployAnim = CurTime()

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

function SWEP:ResetFirstDeploy()
	local self2 = self:GetTable()
	self2.IsFirstDeploy = true
	self2.LastDeployAnim = math.huge
end

--[[
Function Name:  ChooseInspectAnim
Syntax: self:ChooseInspectAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--

function SWEP:ChooseInspectAnim()
	local self2 = self:GetTable()
	if not self:VMIV() then return end

	if self:GetActivityEnabled(ACT_VM_FIDGET_SILENCED) and self2.GetSilenced(self) then
		typev, tanim = self:ChooseAnimation("inspect_silenced")
	elseif self:GetActivityEnabled(ACT_VM_FIDGET_EMPTY) and self2.Primary_TFA.ClipSize > 0 and math.Round(self:Clip1()) == 0 then
		typev, tanim = self:ChooseAnimation("inspect_empty")
	elseif self2.InspectionActions then
		tanim = self2.InspectionActions[self:SharedRandom(1, #self2.InspectionActions, "Inspect")]
	elseif self:GetActivityEnabled(ACT_VM_FIDGET) then
		typev, tanim = self:ChooseAnimation("inspect")
	else
		typev, tanim = self:ChooseAnimation("idle")
		success = false
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseHolsterAnim
Syntax: self:ChooseHolsterAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseHolsterAnim()
	local self2 = self:GetTable()
	if not self:VMIV() then return end

	if self:GetActivityEnabled(ACT_VM_HOLSTER_SILENCED) and self2.GetSilenced(self) then
		typev, tanim = self:ChooseAnimation("holster_silenced")
	elseif self:GetActivityEnabled(ACT_VM_HOLSTER_EMPTY) and (self:Clip1() == 0) then
		typev, tanim = self:ChooseAnimation("holster_empty")
	elseif self:GetActivityEnabled(ACT_VM_HOLSTER) then
		typev, tanim = self:ChooseAnimation("holster")
	else
		local _
		_, tanim = self:ChooseIdleAnim()

		return false, tanim
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseProceduralReloadAnim
Syntax: self:ChooseProceduralReloadAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Uses some holster code
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseProceduralReloadAnim()
	local self2 = self:GetTable()
	if not self:VMIV() then return end

	if not self2.DisableIdleAnimations then
		self:SendViewModelAnim(ACT_VM_IDLE)
	end

	return true, ACT_VM_IDLE
end

--[[
Function Name:  ChooseReloadAnim
Syntax: self:ChooseReloadAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseReloadAnim()
	local self2 = self:GetTable()
	if not self:VMIV() then return false, 0 end
	if self2.ProceduralReloadEnabled then return false, 0 end

	local ads = self:GetStat("IronSightsReloadEnabled") and self:GetIronSightsDirect()

	if self:GetActivityEnabled(ACT_VM_RELOAD_SILENCED) and self2.GetSilenced(self) then
		typev, tanim = self:ChooseAnimation((ads and self:GetActivityEnabled(ACT_VM_RELOAD_SILENCED_ADS)) and "reload_silenced_is" or "reload_silenced")
	elseif self:GetActivityEnabled(ACT_VM_RELOAD_EMPTY) and (self:Clip1() == 0 or self:IsJammed()) and not self2.Shotgun then
		typev, tanim = self:ChooseAnimation((ads and self:GetActivityEnabled(ACT_VM_RELOAD_EMPTY_ADS)) and "reload_empty_is" or "reload_empty")
	else
		typev, tanim = self:ChooseAnimation((ads and self:GetActivityEnabled(ACT_VM_RELOAD_ADS)) and "reload_is" or "reload")
	end

	local fac = 1

	if self2.Shotgun and self2.ShellTime then
		fac = self2.ShellTime
	end

	self2.AnimCycle = self2.ViewModelFlip and 0 or 1

	if SERVER and game.SinglePlayer() then
		self2.SetNW2Int = self.SetNW2Int or self.SetNWInt
		self:SetNW2Int("AnimCycle", self2.AnimCycle)
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim, fac, fac ~= 1)
	else
		return self:SendViewModelSeq(tanim, fac, fac ~= 1)
	end
end

--[[
Function Name:  ChooseReloadAnim
Syntax: self:ChooseReloadAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseShotgunReloadAnim()
	local self2 = self:GetTable()
	if not self:VMIV() then return end

	local ads = self:GetStat("IronSightsReloadEnabled") and self:GetIronSightsDirect()

	if self:GetActivityEnabled(ACT_VM_RELOAD_SILENCED) and self2.GetSilenced(self) then
		typev, tanim = self:ChooseAnimation((ads and self:GetActivityEnabled(ACT_VM_RELOAD_SILENCED_ADS)) and "reload_silenced_is" or "reload_silenced")
	elseif self:GetActivityEnabled(ACT_VM_RELOAD_EMPTY) and self2.ShotgunEmptyAnim and (self:Clip1() == 0 or self:IsJammed()) then
		typev, tanim = self:ChooseAnimation((ads and self:GetActivityEnabled(ACT_VM_RELOAD_EMPTY_ADS)) and "reload_empty_is" or "reload_empty")
	elseif self2.SequenceEnabled[ACT_SHOTGUN_RELOAD_START] then
		typev, tanim = self:ChooseAnimation((ads and self:GetActivityEnabled(ACT_SHOTGUN_RELOAD_START_ADS)) and "reload_shotgun_start_is" or "reload_shotgun_start")
	else
		local _
		_, tanim = self:ChooseIdleAnim()

		return false, tanim
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

function SWEP:ChooseShotgunPumpAnim()
	if not self:VMIV() then return end

	local ads = self:GetStat("IronSightsReloadEnabled") and self:GetIronSightsDirect()

	typev, tanim = self:ChooseAnimation((ads and self:GetActivityEnabled(ACT_SHOTGUN_RELOAD_START_ADS)) and "reload_shotgun_finish_is" or "reload_shotgun_finish")

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseIdleAnim
Syntax: self:ChooseIdleAnim().
Returns:  True,  Which action?
Notes:  Requires autodetection for full features.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseIdleAnim()
	local self2 = self:GetTable()
	if not self:VMIV() then return end
	--if self2.Idle_WithHeld then
	--	self2.Idle_WithHeld = nil
	--	return
	--end

	if TFA.Enum.ShootLoopingStatus[self:GetShootStatus()] then
		return self:ChooseLoopShootAnim()
	end

	if self2.Idle_Mode ~= TFA.Enum.IDLE_BOTH and self2.Idle_Mode ~= TFA.Enum.IDLE_ANI then return end

	--self:ResetEvents()
	if self:GetIronSights() then
		if self2.Sights_Mode == TFA.Enum.LOCOMOTION_LUA then
			return self:ChooseFlatAnim()
		else
			return self:ChooseADSAnim()
		end
	elseif self:GetSprinting() and self2.Sprint_Mode ~= TFA.Enum.LOCOMOTION_LUA then
		return self:ChooseSprintAnim()
	elseif self:GetWalking() and self2.Walk_Mode ~= TFA.Enum.LOCOMOTION_LUA then
		return self:ChooseWalkAnim()
	elseif self:GetCustomizing() and self2.Customize_Mode ~= TFA.Enum.LOCOMOTION_LUA then
		return self:ChooseCustomizeAnim()
	end

	if self:GetActivityEnabled(ACT_VM_IDLE_SILENCED) and self2.GetSilenced(self) then
		typev, tanim = self:ChooseAnimation("idle_silenced")
	elseif (self2.Primary_TFA.ClipSize > 0 and self:Clip1() == 0) or (self2.Primary_TFA.ClipSize <= 0 and self:Ammo1() == 0) then
		--self:GetActivityEnabled( ACT_VM_IDLE_EMPTY ) and (self:Clip1() == 0) then
		if self:GetActivityEnabled(ACT_VM_IDLE_EMPTY) then
			typev, tanim = self:ChooseAnimation("idle_empty")
		else --if not self:GetActivityEnabled( ACT_VM_PRIMARYATTACK_EMPTY ) then
			typev, tanim = self:ChooseAnimation("idle")
		end
	else
		typev, tanim = self:ChooseAnimation("idle")
	end

	--else
	--	return
	--end
	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

function SWEP:ChooseFlatAnim()
	local self2 = self:GetTable()
	if not self:VMIV() then return end
	--self:ResetEvents()
	typev, tanim = self:ChooseAnimation("idle")

	if self:GetActivityEnabled(ACT_VM_IDLE_SILENCED) and self2.GetSilenced(self) then
		typev, tanim = self:ChooseAnimation("idle_silenced")
	elseif self:GetActivityEnabled(ACT_VM_IDLE_EMPTY) and ((self2.Primary_TFA.ClipSize > 0 and self:Clip1() == 0) or (self2.Primary_TFA.ClipSize <= 0 and self:Ammo1() == 0)) then
		typev, tanim = self:ChooseAnimation("idle_empty")
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim, 0.000001)
	else
		return self:SendViewModelSeq(tanim, 0.000001)
	end
end

function SWEP:ChooseADSAnim()
	local self2 = self:GetTable()
	local a, b, c = self:PlayAnimation(self2.GetStat(self, "IronAnimation.loop"))

	--self:SetNextIdleAnim(CurTime() + 1)
	if not a then
		local _
		_, b, c = self:ChooseFlatAnim()
		a = false
	end

	return a, b, c
end

function SWEP:ChooseSprintAnim()
	return self:PlayAnimation(self:GetStat("SprintAnimation.loop"))
end

function SWEP:ChooseWalkAnim()
	return self:PlayAnimation(self:GetStat("WalkAnimation.loop"))
end

function SWEP:ChooseLoopShootAnim()
	return self:PlayAnimation(self:GetStat("ShootAnimation.loop"))
end

function SWEP:ChooseCustomizeAnim()
	return self:PlayAnimation(self:GetStat("CustomizeAnimation.loop"))
end

--[[
Function Name:  ChooseShootAnim
Syntax: self:ChooseShootAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseShootAnim(ifp)
	local self2 = self:GetTable()
	if ifp == nil then ifp = IsFirstTimePredicted() end
	if not self:VMIV() then return end

	if self2.GetStat(self, "ShootAnimation.loop") and self2.Primary_TFA.Automatic then
		if self2.LuaShellEject and ifp then
			self:EventShell()
		end

		if TFA.Enum.ShootReadyStatus[self:GetShootStatus()] then
			self:SetShootStatus(TFA.Enum.SHOOT_START)

			local inan = self2.GetStat(self, "ShootAnimation.in")

			if not inan then
				inan = self2.GetStat(self, "ShootAnimation.loop")
			end

			return self:PlayAnimation(inan)
		end

		return
	end

	if self:GetIronSights() and (self2.Sights_Mode == TFA.Enum.LOCOMOTION_ANI or self2.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID) and self2.GetStat(self, "IronAnimation.shoot") then
		if self2.LuaShellEject and ifp then
			self:EventShell()
		end

		return self:PlayAnimation(self2.GetStat(self, "IronAnimation.shoot"))
	end

	if not self2.BlowbackEnabled or (not self:GetIronSights() and self2.Blowback_Only_Iron) then
		success = true

		if self2.LuaShellEject and (ifp or game.SinglePlayer()) then
			self:EventShell()
		end

		if self:GetActivityEnabled(ACT_VM_PRIMARYATTACK_SILENCED) and self2.GetSilenced(self) then
			typev, tanim = self:ChooseAnimation("shoot1_silenced")
		elseif self:Clip1() <= self2.Primary_TFA.AmmoConsumption and self:GetActivityEnabled(ACT_VM_PRIMARYATTACK_EMPTY) and self2.Primary_TFA.ClipSize >= 1 and not self2.ForceEmptyFireOff then
			typev, tanim = self:ChooseAnimation("shoot1_last")
		elseif self:Ammo1() <= self2.Primary_TFA.AmmoConsumption and self:GetActivityEnabled(ACT_VM_PRIMARYATTACK_EMPTY) and self2.Primary_TFA.ClipSize < 1 and not self2.ForceEmptyFireOff then
			typev, tanim = self:ChooseAnimation("shoot1_last")
		elseif self:Clip1() == 0 and self:GetActivityEnabled(ACT_VM_DRYFIRE) and not self2.ForceDryFireOff then
			typev, tanim = self:ChooseAnimation("shoot1_empty")
		elseif self2.GetStat(self, "Akimbo") and self:GetActivityEnabled(ACT_VM_SECONDARYATTACK) and ((self2.AnimCycle == 0 and not self2.Akimbo_Inverted) or (self2.AnimCycle == 1 and self2.Akimbo_Inverted)) then
			typev, tanim = self:ChooseAnimation((self:GetIronSights() and self:GetActivityEnabled(ACT_VM_ISHOOT_M203)) and "shoot2_is" or "shoot2")
		elseif self:GetIronSights() and self:GetActivityEnabled(ACT_VM_PRIMARYATTACK_1) then
			typev, tanim = self:ChooseAnimation("shoot1_is")
		else
			typev, tanim = self:ChooseAnimation("shoot1")
		end

		if typev ~= TFA.Enum.ANIMATION_SEQ then
			return self:SendViewModelAnim(tanim)
		end

		return self:SendViewModelSeq(tanim)
	end

	if game.SinglePlayer() and SERVER then
		self:CallOnClient("BlowbackFull", "")
	end

	if ifp then
		self:BlowbackFull(ifp)
	end

	if self2.Blowback_Shell_Enabled and (ifp or game.SinglePlayer()) then
		self:EventShell()
	end

	self:SendViewModelAnim(ACT_VM_BLOWBACK)

	return true, ACT_VM_IDLE
end

function SWEP:BlowbackFull()
	local self2 = self:GetTable()
	if IsValid(self) then
		self2.BlowbackCurrent = 1
		self2.BlowbackCurrentRoot = 1
		self2.BlowbackRandomAngle = Angle(math.Rand(.1, .2), math.Rand(-.5, .5), math.Rand(-1, 1))
	end
end

--[[
Function Name:  ChooseSilenceAnim
Syntax: self:ChooseSilenceAnim( true if we're silencing, false for detaching the silencer).
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.  This is played when you silence or unsilence a gun.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseSilenceAnim(val)
	if not self:VMIV() then return end
	--self:ResetEvents()
	typev, tanim = self:ChooseAnimation("idle_silenced")
	success = false

	if val then
		if self:GetActivityEnabled(ACT_VM_ATTACH_SILENCER) then
			typev, tanim = self:ChooseAnimation("silencer_attach")
			success = true
		end
	elseif self:GetActivityEnabled(ACT_VM_DETACH_SILENCER) then
		typev, tanim = self:ChooseAnimation("silencer_detach")
		success = true
	end

	if not success then
		local _
		_, tanim = self:ChooseIdleAnim()

		return false, tanim
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseDryFireAnim
Syntax: self:ChooseDryFireAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.  set SWEP.ForceDryFireOff to false to properly use.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseDryFireAnim()
	local self2 = self:GetTable()
	if not self:VMIV() then return end
	--self:ResetEvents()
	typev, tanim = self:ChooseAnimation("shoot1_empty")
	success = true

	if self:GetActivityEnabled(ACT_VM_DRYFIRE_SILENCED) and self2.GetSilenced(self) and not self2.ForceDryFireOff then
		typev, tanim = self:ChooseAnimation("shoot1_silenced_empty")
		--self:ChooseIdleAnim()
	else
		if self:GetActivityEnabled(ACT_VM_DRYFIRE) and not self2.ForceDryFireOff then
			typev, tanim = self:ChooseAnimation("shoot1_empty")
		else
			success = false
			local _
			_, tanim = nil, nil

			return success, tanim
		end
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseROFAnim
Syntax: self:ChooseROFAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.  Called when we change the firemode.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseROFAnim()
	local self2 = self:GetTable()
	if not self:VMIV() then return end

	--self:ResetEvents()
	if self:GetIronSights() and self:GetActivityEnabled(ACT_VM_IFIREMODE) then
		typev, tanim = self2.ChooseAnimation(self, "rof_is")
		success = true
	elseif self:GetActivityEnabled(ACT_VM_FIREMODE) then
		typev, tanim = self2.ChooseAnimation(self, "rof")
		success = true
	else
		success = false
		local _
		_, tanim = nil, nil

		return success, tanim
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[
Function Name:  ChooseBashAnim
Syntax: self:ChooseBashAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.  Called when we bash.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseBashAnim()
	local self2 = self:GetTable()
	if not self:VMIV() then return end

	typev, tanim = nil, nil
	success = false

	local isempty = self2.GetStat(self, "Primary.ClipSize") > 0 and self:Clip1() == 0

	if self2.GetSilenced(self) and self:GetActivityEnabled(ACT_VM_HITCENTER2) then
		if self:GetActivityEnabled(ACT_VM_MISSCENTER2) and isempty then
			typev, tanim = self:ChooseAnimation("bash_empty_silenced")
			success = true
		else
			typev, tanim = self:ChooseAnimation("bash_silenced")
			success = true
		end
	elseif self:GetActivityEnabled(ACT_VM_MISSCENTER) and isempty then
		typev, tanim = self:ChooseAnimation("bash_empty")
		success = true
	elseif self:GetActivityEnabled(ACT_VM_HITCENTER) then
		typev, tanim = self:ChooseAnimation("bash")
		success = true
	end

	if not success then
		return success, tanim
	end

	if typev ~= TFA.Enum.ANIMATION_SEQ then
		return self:SendViewModelAnim(tanim)
	else
		return self:SendViewModelSeq(tanim)
	end
end

--[[THIRDPERSON]]
--These holdtypes are used in ironsights.  Syntax:  DefaultHoldType=NewHoldType
SWEP.IronSightHoldTypes = {
	pistol = "revolver",
	smg = "rpg",
	grenade = "melee",
	ar2 = "rpg",
	shotgun = "ar2",
	rpg = "rpg",
	physgun = "physgun",
	crossbow = "ar2",
	melee = "melee2",
	slam = "camera",
	normal = "fist",
	melee2 = "magic",
	knife = "fist",
	duel = "duel",
	camera = "camera",
	magic = "magic",
	revolver = "revolver"
}

--These holdtypes are used while sprinting.  Syntax:  DefaultHoldType=NewHoldType
SWEP.SprintHoldTypes = {
	pistol = "normal",
	smg = "passive",
	grenade = "normal",
	ar2 = "passive",
	shotgun = "passive",
	rpg = "passive",
	physgun = "normal",
	crossbow = "passive",
	melee = "normal",
	slam = "normal",
	normal = "normal",
	melee2 = "melee",
	knife = "fist",
	duel = "normal",
	camera = "slam",
	magic = "normal",
	revolver = "normal"
}

--These holdtypes are used in reloading.  Syntax:  DefaultHoldType=NewHoldType
SWEP.ReloadHoldTypes = {
	pistol = "pistol",
	smg = "smg",
	grenade = "melee",
	ar2 = "ar2",
	shotgun = "shotgun",
	rpg = "ar2",
	physgun = "physgun",
	crossbow = "crossbow",
	melee = "pistol",
	slam = "smg",
	normal = "pistol",
	melee2 = "pistol",
	knife = "pistol",
	duel = "duel",
	camera = "pistol",
	magic = "pistol",
	revolver = "revolver"
}

--These holdtypes are used in reloading.  Syntax:  DefaultHoldType=NewHoldType
SWEP.CrouchHoldTypes = {
	ar2 = "ar2",
	smg = "smg",
	rpg = "ar2"
}

SWEP.IronSightHoldTypeOverride = "" --This variable overrides the ironsights holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
SWEP.SprintHoldTypeOverride = "" --This variable overrides the sprint holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
SWEP.ReloadHoldTypeOverride = "" --This variable overrides the reload holdtype, choosing it instead of something from the above tables.  Change it to "" to disable.
local dynholdtypecvar = GetConVar("sv_tfa_holdtype_dynamic")
SWEP.mht_old = ""
local mht

function SWEP:IsOwnerCrouching()
	local ply = self:GetOwner()

	if not ply:IsPlayer() then return false end

	return ply:Crouching()
end

function SWEP:ProcessHoldType()
	local self2 = self:GetTable()
	mht = self2.GetStat(self, "HoldType") or "ar2"

	if mht ~= self2.mht_old or not self2.DefaultHoldType then
		self2.DefaultHoldType = mht
		self2.SprintHoldType = nil
		self2.IronHoldType = nil
		self2.ReloadHoldType = nil
		self2.CrouchHoldType = nil
	end

	self2.mht_old = mht

	if not self2.SprintHoldType then
		self2.SprintHoldType = self2.SprintHoldTypes[self2.DefaultHoldType] or "passive"

		if self2.SprintHoldTypeOverride and self2.SprintHoldTypeOverride ~= "" then
			self2.SprintHoldType = self2.SprintHoldTypeOverride
		end
	end

	if not self2.IronHoldType then
		self2.IronHoldType = self2.IronSightHoldTypes[self2.DefaultHoldType] or "rpg"

		if self2.IronSightHoldTypeOverride and self2.IronSightHoldTypeOverride ~= "" then
			self2.IronHoldType = self2.IronSightHoldTypeOverride
		end
	end

	if not self2.ReloadHoldType then
		self2.ReloadHoldType = self2.ReloadHoldTypes[self2.DefaultHoldType] or "ar2"

		if self2.ReloadHoldTypeOverride and self2.ReloadHoldTypeOverride ~= "" then
			self2.ReloadHoldType = self2.ReloadHoldTypeOverride
		end
	end

	if not self2.SetCrouchHoldType then
		self2.SetCrouchHoldType = true
		self2.CrouchHoldType = self2.CrouchHoldTypes[self2.DefaultHoldType]

		if self2.CrouchHoldTypeOverride and self2.CrouchHoldTypeOverride ~= "" then
			self2.CrouchHoldType = self2.CrouchHoldTypeOverride
		end
	end

	local curhold, targhold, stat
	curhold = self:GetHoldType()
	targhold = self2.DefaultHoldType
	stat = self:GetStatus()

	if dynholdtypecvar:GetBool() then
		if self:OwnerIsValid() and self:IsOwnerCrouching() and self2.CrouchHoldType then
			targhold = self2.CrouchHoldType
		else
			if self:GetIronSights() then
				targhold = self2.IronHoldType
			end

			if TFA.Enum.ReloadStatus[stat] then
				targhold = self2.ReloadHoldType
			end
		end
	end

	if self:GetSprinting() or TFA.Enum.HolsterStatus[stat] or self:IsSafety() then
		targhold = self2.SprintHoldType
	end

	if targhold ~= curhold then
		self:SetHoldType(targhold)
	end
end