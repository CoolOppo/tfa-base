ACT_VM_FIDGET_EMPTY = ACT_VM_FIDGET_EMPTY or ACT_CROSSBOW_FIDGET_UNLOADED
ACT_VM_BLOWBACK = ACT_VM_BLOWBACK or -2

local ServersideLooped = {
	[ACT_VM_FIDGET] = true,
	[ACT_VM_FIDGET_EMPTY] = true,
	--[ACT_VM_IDLE] = true,
	--[ACT_VM_IDLE_EMPTY] = true,
	--[ACT_VM_IDLE_SILENCED] = true
}

local IdleBlendTime = 0.0

local d,pbr

function SWEP:SendViewModelAnim(act, rate, targ, blend )
	local vm = self.OwnerViewModel
	self:SetLastActivity( act )
	if rate and not targ then rate = math.max(rate,0.0001) end

	if act < 0 then return end

	if not self:VMIV() then return end

	local seq = vm:SelectWeightedSequenceSeeded(act,CurTime())
	if seq < 0 then
		return
	end
	self:ResetEvents()
	if self:GetLastActivity() == act and ServersideLooped[act] then
		self:ChooseIdleAnim()
		vm:SetPlaybackRate(0)
		vm:SetCycle(0)
		self:SetNextIdleAnim( CurTime() + 0.03 )

		if IsFirstTimePredicted() then
			timer.Simple(0, function()
				vm:SendViewModelMatchingSequence(seq)
				d = vm:SequenceDuration()
				pbr = targ and ( d / ( rate or 1 ) ) or ( rate or 1 )
				vm:SetPlaybackRate( pbr )
				if IsValid(self) then
					if blend == nil then blend = self.Idle_Smooth end
					self:SetNextIdleAnim( CurTime() + d / pbr - blend )
				end
			end)
		end
	else
		vm:SendViewModelMatchingSequence(seq)
		d = vm:SequenceDuration()
		pbr = targ and ( d / ( rate or 1 ) ) or ( rate or 1 )
		vm:SetPlaybackRate( pbr )
		if IsValid(self) then
			if blend == nil then blend = self.Idle_Smooth end
			self:SetNextIdleAnim( CurTime() + d / pbr - blend )
		end
	end
end

function SWEP:SendViewModelSeq(seq, rate, targ, blend )
	local vm = self.OwnerViewModel
	if type(seq) == "string" then
		seq = vm:LookupSequence(seq) or 0
	end

	if not self:VMIV() then return end
	local act = vm:GetSequenceActivity(seq)
	self:SetLastActivity( act )
	if seq < 0 then
		return
	end

	if not self:VMIV() then return end
	self:ResetEvents()
	if self:GetLastActivity() == act and ServersideLooped[act] then
		vm:SendViewModelMatchingSequence( act == 0 and 1 or 0 )
		vm:SetPlaybackRate(0)
		vm:SetCycle(0)
		self:SetNextIdleAnim( CurTime() + 0.03 )

		if IsFirstTimePredicted() then
			timer.Simple(0, function()
				vm:SendViewModelMatchingSequence(seq)
				d = vm:SequenceDuration()
				pbr = targ and ( d / ( rate or 1 ) ) or ( rate or 1 )
				vm:SetPlaybackRate( pbr )
				if IsValid(self) then
					if blend == nil then blend = self.Idle_Smooth end
					self:SetNextIdleAnim( CurTime() + d / pbr - blend )
				end
			end)
		end
	else
		vm:SendViewModelMatchingSequence(seq)
		d = vm:SequenceDuration()
		pbr = targ and ( d / ( rate or 1 ) ) or ( rate or 1 )
		vm:SetPlaybackRate( pbr )
		if IsValid(self) then
			if blend == nil then blend = self.Idle_Smooth end
			self:SetNextIdleAnim( CurTime() + d / pbr - blend )
		end
	end
end

local tval

function SWEP:PlayAnimation(data)
	if not self:VMIV() then return end
	local vm = self.OwnerViewModel
	if data.type == TFA.Enum.ANIMATION_ACT then
		tval = data.value
		if self:Clip1() <= 0 and self.Primary.ClipSize >= 0 then
			tval = data.value_empty or tval
		end
		if self:Clip1() == 1 and self.Primary.ClipSize >= 0 then
			tval = data.value_last or tval
		end
		self:SendViewModelAnim( tval, 1, false, data.transition and self.Idle_Blend or self.Idle_Smooth )
	elseif data.type == TFA.Enum.ANIMATION_SEQ then
		tval = data.value
		if self:Clip1() <= 0 and self.Primary.ClipSize >= 0 then
			tval = data.value_empty or tval
		end
		if self:Clip1() == 1 and self.Primary.ClipSize >= 0 then
			tval = data.value_last or tval
		end
		if type(tval) == "string" then
			tval = vm:LookupSequence(tval)
		end
		self:SendViewModelSeq( tval, 1, false, data.transition and self.Idle_Blend or self.Idle_Smooth )
	end
end

local success, tanim

--[[
Function Name:  Locomote
Syntax: self:Locomote( flip ironsights, new is, flip sprint, new sprint).
Returns:  
Notes:  
Purpose:  Animation / Utility
]]

local tldata

function SWEP:Locomote(flipis,is,flipsp,spr)
	if not ( flipis or flipsp ) then return end
	if self:GetStatus() ~= TFA.Enum.STATUS_IDLE then return end
	tldata = nil
	if flipis then
		if is and self.IronAnimation["in"] then
			tldata = self.IronAnimation["in"]
		elseif self.IronAnimation.out and not flipsp then
			tldata = self.IronAnimation["out"]
		end
	end
	if flipsp then
		if spr and self.SprintAnimation["in"] then
			tldata = self.SprintAnimation["in"]
		elseif self.SprintAnimation.out and not flipis then
			tldata = self.SprintAnimation["out"]
		end
	end
	if tldata then
		self:PlayAnimation(tldata)
	end
end

--[[
Function Name:  ChooseDrawAnim
Syntax: self:ChooseDrawAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]

function SWEP:ChooseDrawAnim()
	if not self:VMIV() then return end
	--self:ResetEvents()
	tanim = ACT_VM_DRAW
	success = true

	if self.SequenceEnabled[ACT_VM_DRAW_SILENCED] and self:GetSilenced() then
		tanim = ACT_VM_DRAW_SILENCED
	elseif self.SequenceEnabled[ACT_VM_DRAW_EMPTY] and (self:Clip1() == 0) then
		tanim = ACT_VM_DRAW_EMPTY
	else
		tanim = ACT_VM_DRAW
	end

	self:SendViewModelAnim(tanim)

	return success, tanim
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
	if not self:VMIV() then return end
	--self:ResetEvents()
	tanim = ACT_VM_FIDGET
	success = true

	if self.SequenceEnabled[ACT_VM_FIDGET_EMPTY] and self.Primary.ClipSize > 0 and math.Round(self:Clip1()) == 0 then
		tanim = ACT_VM_FIDGET_EMPTY
	elseif self.InspectionActions then
		math.randomseed(CurTime() + 1)
		tanim = self.InspectionActions[math.random(1, #self.InspectionActions)]
	elseif self.SequenceEnabled[ACT_VM_FIDGET] then
		tanim = ACT_VM_FIDGET
	else
		tanim = ACT_VM_IDLE
		success = false
	end

	self:SendViewModelAnim(tanim)
	self.lastidlefidget = true

	return success, tanim
end

--[[
Function Name:  ChooseHolsterAnim
Syntax: self:ChooseHolsterAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--
ACT_VM_HOLSTER_SILENCED = ACT_VM_HOLSTER_SILENCED or ACT_CROSSBOW_HOLSTER_UNLOADED

function SWEP:ChooseHolsterAnim()
	if not self:VMIV() then return end
	--self:ResetEvents()
	tanim = ACT_VM_HOLSTER
	success = true

	if self:GetSilenced() and self.SequenceEnabled[ACT_VM_HOLSTER_SILENCED] then
		tanim = ACT_VM_HOLSTER_SILENCED
	elseif self.SequenceEnabled[ACT_VM_HOLSTER_EMPTY] and self:Clip1() == 0 then
		tanim = ACT_VM_HOLSTER_EMPTY
	elseif self.SequenceEnabled[ACT_VM_HOLSTER] then
		tanim = ACT_VM_HOLSTER
	else
		tanim = ACT_VM_IDLE
		success = false
	end

	self:SendViewModelAnim(tanim)

	return success, tanim
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
	if not self:VMIV() then return end

	if not self.DisableIdleAnimations then
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
	if not self:VMIV() then return end
	if self.ProceduralReloadEnabled then return end

	--self:ResetEvents()
	success = true

	if self.SequenceEnabled[ACT_VM_RELOAD_SILENCED] and self:GetSilenced() then
		tanim = ACT_VM_RELOAD_SILENCED
	elseif self.SequenceEnabled[ACT_VM_RELOAD_EMPTY] and (self:Clip1() == 0) then
		tanim = ACT_VM_RELOAD_EMPTY
	else
		tanim = ACT_VM_RELOAD
	end

	local fac = 1
	if self.Shotgun and self.ShellTime then
		fac = self.ShellTime
	end

	self:SendViewModelAnim(tanim, fac, fac ~= 1 )

	return success, tanim
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
	if not self:VMIV() then return end
	--self:ResetEvents()
	tanim = ACT_SHOTGUN_RELOAD_START
	success = true

	if self.SequenceEnabled[ACT_VM_RELOAD_SILENCED] and self:GetSilenced() then
		tanim = ACT_VM_IDLE_SILENCED
	else
		if self.SequenceEnabled[ACT_VM_RELOAD_EMPTY] and self.KF2StyleShotgun and self:Clip1() == 0 then
			tanim = ACT_VM_RELOAD_EMPTY
			self.StartAnimInsertShell = true
		end
	end

	if not self.SequenceEnabled[tanim] then
		success = false
	else
		self:SendViewModelAnim(tanim)
	end

	return success, tanim
end

function SWEP:ChooseShotgunPumpAnim()
	if not self:VMIV() then return end
	--self:ResetEvents()
	tanim = ACT_SHOTGUN_RELOAD_FINISH
	success = true

	self:SendViewModelAnim(tanim)

	return success, tanim
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
	if not self:VMIV() then return end
	if self.Idle_Mode ~= TFA.Enum.IDLE_BOTH and self.Idle_Mode ~= TFA.Enum.IDLE_ANI then
		return
	end
	--self:ResetEvents()
	tanim = ACT_VM_IDLE

	if self:GetIronSights() then
		if self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA then
			return self:ChooseFlatAnim()
		else
			return self:ChooseADSAnim()
		end
	elseif self:GetSprinting() and self.Sprint_Mode ~= TFA.Enum.LOCMOTION_LUA then
		return self:ChooseSprintAnim()
	end

	if self.SequenceEnabled[ACT_VM_IDLE_SILENCED] and self:GetSilenced() then
		tanim = ACT_VM_IDLE_SILENCED
	elseif self:Clip1() == 0 then--self.SequenceEnabled[ACT_VM_IDLE_EMPTY] and (self:Clip1() == 0) then
		tanim = ACT_VM_IDLE_EMPTY
	end

	self:SendViewModelAnim(tanim)

	return true, tanim
end

function SWEP:ChooseFlatAnim()
	if not self:VMIV() then return end
	--self:ResetEvents()
	tanim = ACT_VM_IDLE

	if self.SequenceEnabled[ACT_VM_IDLE_SILENCED] and self:GetSilenced() then
		tanim = ACT_VM_IDLE_SILENCED
	elseif self.SequenceEnabled[ACT_VM_IDLE_EMPTY] then
		if (self:Clip1() == 0) then
			tanim = ACT_VM_IDLE_EMPTY
		else
			self:SendViewModelAnim(ACT_VM_IDLE,0.00001)
		end
	end
	self:SendViewModelAnim(tanim,0.00001)

	return true, tanim
end

function SWEP:ChooseADSAnim()
	self:PlayAnimation(self.IronAnimation.loop)
	return true,-1
end

function SWEP:ChooseSprintAnim()
	self:PlayAnimation(self.SprintAnimation.loop)
	return true,-1
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
	ifp = ifp or IsFirstTimePredicted()
	if not self:VMIV() then return end

	if self:GetIronSights() and self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI and self.IronAnimation.shoot then
		self:PlayAnimation(self.IronAnimation.shoot)

		return true, -1
	end

	if not self.BlowbackEnabled or (not self:GetIronSights() and self.Blowback_Only_Iron) then
		success = true

		if self.LuaShellEject then
			self:MakeShellBridge(ifp)
		end

		if self.SequenceEnabled[ACT_VM_PRIMARYATTACK_SILENCED] and self:GetSilenced() then
			tanim = ACT_VM_PRIMARYATTACK_SILENCED
		elseif self:Clip1() <= self.Primary.AmmoConsumption and self.SequenceEnabled[ACT_VM_PRIMARYATTACK_EMPTY] and not self.ForceEmptyFireOff then
			tanim = ACT_VM_PRIMARYATTACK_EMPTY
		elseif self:Clip1() == 0 and self.SequenceEnabled[ACT_VM_DRYFIRE] and not self.ForceDryFireOff then
			tanim = ACT_VM_DRYFIRE
		elseif self.Akimbo and self.SequenceEnabled[ACT_VM_SECONDARYATTACK] and ((self.AnimCycle == 0 and not self.Akimbo_Inverted) or (self.AnimCycle == 1 and self.Akimbo_Inverted)) then
			tanim = ACT_VM_SECONDARYATTACK
		elseif self:GetIronSights() and self.SequenceEnabled[ACT_VM_PRIMARYATTACK_1] then
			tanim = ACT_VM_PRIMARYATTACK_1
		else
			tanim = ACT_VM_PRIMARYATTACK
		end

		self:SendViewModelAnim(tanim)

		return success, tanim
	else
		if game.SinglePlayer() and SERVER then
			self:CallOnClient("BlowbackFull", "")
		end

		if ifp then
			self:BlowbackFull(ifp)
		end

		self:MakeShellBridge(ifp)
		self:SendViewModelAnim(ACT_VM_BLOWBACK)

		return true, ACT_VM_IDLE
	end
end

function SWEP:BlowbackFull()
	if IsValid(self) then
		self.BlowbackCurrent = 1
		self.BlowbackCurrentRoot = 1
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
	tanim = ACT_VM_PRIMARYATTACK
	success = false

	if val then
		if self.SequenceEnabled[ACT_VM_ATTACH_SILENCER] then
			self:SendViewModelAnim(ACT_VM_ATTACH_SILENCER)
			tanim = ACT_VM_ATTACH_SILENCER
			success = true
		end
	else
		if self.SequenceEnabled[ACT_VM_DETACH_SILENCER] then
			self:SendViewModelAnim(ACT_VM_DETACH_SILENCER)
			tanim = ACT_VM_DETACH_SILENCER
			success = true
		end
	end

	if not success then
		local _
		_, tanim = self:ChooseIdleAnim()
	end

	return success, tanim
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
	if not self:VMIV() then return end
	--self:ResetEvents()
	tanim = ACT_VM_DRYFIRE
	success = true

	if self.SequenceEnabled[ACT_VM_DRYFIRE_SILENCED] and self:GetSilenced() and not self.ForceDryFireOff then
		self:SendViewModelAnim(ACT_VM_DRYFIRE_SILENCED)
		tanim = ACT_VM_DRYFIRE_SILENCED
		--self:ChooseIdleAnim()
	else
		if self.SequenceEnabled[ACT_VM_DRYFIRE] and not self.ForceDryFireOff then
			self:SendViewModelAnim(ACT_VM_DRYFIRE)
			tanim = ACT_VM_DRYFIRE
		else
			success = false
			local _
			_, tanim = nil, nil
		end
	end

	return success, tanim
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

function SWEP:ProcessHoldType()

	if not self.DefaultHoldType then
		self.DefaultHoldType = self.HoldType or "ar2"
	end

	if not self.SprintHoldType then
		self.SprintHoldType = self.SprintHoldTypes[self.DefaultHoldType] or "passive"

		if self.SprintHoldTypeOverride and self.SprintHoldTypeOverride ~= "" then
			self.SprintHoldType = self.SprintHoldTypeOverride
		end
	end

	if not self.IronHoldType then
		self.IronHoldType = self.IronSightHoldTypes[self.DefaultHoldType] or "rpg"

		if self.IronSightHoldTypeOverride and self.IronSightHoldTypeOverride ~= "" then
			self.IronHoldType = self.IronSightHoldTypeOverride
		end
	end

	if not self.ReloadHoldType then
		self.ReloadHoldType = self.ReloadHoldTypes[self.DefaultHoldType] or "ar2"

		if self.ReloadHoldTypeOverride and self.ReloadHoldTypeOverride ~= "" then
			self.ReloadHoldType = self.ReloadHoldTypeOverride
		end
	end

	if not self.SetCrouchHoldType then
		self.SetCrouchHoldType = true
		self.CrouchHoldType = self.CrouchHoldTypes[self.DefaultHoldType]

		if self.CrouchHoldTypeOverride and self.CrouchHoldTypeOverride ~= "" then
			self.CrouchHoldType = self.CrouchHoldTypeOverride
		end
	end

	local curhold, targhold
	curhold = self:GetHoldType()
	targhold = self.DefaultHoldType
	local stat = self:GetStatus()

	if dynholdtypecvar:GetBool() then
		if self:OwnerIsValid() and self.Owner:Crouching() and self.CrouchHoldType then
			targhold = self.CrouchHoldType
		else
			if self:GetIronSights() then
				targhold = self.IronHoldType
			end

			if TFA.Enum.ReloadStatus[stat] then
				targhold = self.ReloadHoldType
			end
		end
	end

	if self:GetSprinting() or TFA.Enum.HolsterStatus[stat] or self:IsSafety() then
		targhold = self.SprintHoldType
	end

	if targhold ~= curhold then
		self:SetHoldType(targhold)
	end
end
