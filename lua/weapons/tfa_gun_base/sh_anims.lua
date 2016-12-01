ACT_VM_FIDGET_EMPTY = ACT_VM_FIDGET_EMPTY or ACT_CROSSBOW_FIDGET_UNLOADED
ACT_VM_BLOWBACK = ACT_VM_BLOWBACK or -2

local ServersideLooped = {
	[ACT_VM_FIDGET] = true,
	[ACT_VM_FIDGET_EMPTY] = true,
	--[ACT_VM_IDLE] = true,
	--[ACT_VM_IDLE_EMPTY] = true,
	--[ACT_VM_IDLE_SILENCED] = true
}

function SWEP:SendViewModelAnim(act, rate, targ )
	local vm = self.OwnerViewModel
	self:SetLastActivity( act )

	if act < 0 then return end

	if not IsValid(vm) then
		self.OwnerViewModel = IsValid(self.Owner) and self.Owner:GetViewModel()
		return
	end

	local seq = vm:SelectWeightedSequenceSeeded(act,CurTime())
	if seq < 0 then
		return
	end

	if self:GetLastActivity() == act and ServersideLooped[act] then
		vm:SendViewModelMatchingSequence( act == 0 and 1 or 0 )
		vm:SetPlaybackRate(0)
		vm:SetCycle(0)

		if IsFirstTimePredicted() then
			timer.Simple(0, function()
				vm:SendViewModelMatchingSequence(seq)
				if targ then
					local d = vm:SequenceDuration()
					vm:SetPlaybackRate( d / rate )
				else
					vm:SetPlaybackRate(rate or 1)
				end
			end)
		end
	else
		vm:SendViewModelMatchingSequence(seq)
		if targ then
			local d = vm:SequenceDuration()
			vm:SetPlaybackRate( d / rate )
		else
			vm:SetPlaybackRate(rate or 1)
		end
	end
end

local success, tanim

--[[
Function Name:  ChooseDrawAnim
Syntax: self:ChooseDrawAnim().
Returns:  Could we successfully find an animation?  Which action?
Notes:  Requires autodetection or otherwise the list of valid anims.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseDrawAnim()
	if not self:OwnerIsValid() then return end
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
	if not self:OwnerIsValid() then return end
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
	if not self:OwnerIsValid() then return end
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
	if not self:OwnerIsValid() then return end

	if self.Callback.ChooseProceduralReloadAnim then
		local retval = self.Callback.ChooseProceduralReloadAnim(self)
		if retval ~= nil then return retval end
	end

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
	if not self:OwnerIsValid() then return end

	if self.Callback.ChooseReloadAnim then
		local retval = self.Callback.ChooseReloadAnim(self)
		if retval ~= nil then return retval end
	end

	--self:ResetEvents()
	success = true

	if self.SequenceEnabled[ACT_VM_RELOAD_SILENCED] and self:GetSilenced() then
		tanim = ACT_VM_RELOAD_SILENCED
	elseif self.SequenceEnabled[ACT_VM_RELOAD_EMPTY] and (self:Clip1() == 0) then
		tanim = ACT_VM_RELOAD_EMPTY
	else
		tanim = ACT_VM_RELOAD
	end

	self:SendViewModelAnim(tanim)

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
	if not self:OwnerIsValid() then return end
	--self:ResetEvents()
	tanim = ACT_SHOTGUN_RELOAD_START
	success = true

	if self.SequenceEnabled[ACT_VM_RELOAD_SILENCED] and self:GetSilenced() then
		self:SendViewModelAnim(ACT_VM_RELOAD_SILENCED)
		tanim = ACT_VM_RELOAD_SILENCED
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

--[[
Function Name:  ChooseIdleAnim
Syntax: self:ChooseIdleAnim().
Returns:  True,  Which action?
Notes:  Requires autodetection for full features.
Purpose:  Animation / Utility
]]
--
function SWEP:ChooseIdleAnim()
	if not self:OwnerIsValid() then return end
	--self:ResetEvents()
	tanim = ACT_VM_IDLE

	if self.SequenceEnabled[ACT_VM_IDLE_SILENCED] and self:GetSilenced() then
		self:SendViewModelAnim(ACT_VM_IDLE_SILENCED)
		tanim = ACT_VM_IDLE_SILENCED
	else
		if self.SequenceEnabled[ACT_VM_IDLE_EMPTY] then
			if (self:Clip1() == 0) then
				self:SendViewModelAnim(ACT_VM_IDLE_EMPTY)
				tanim = ACT_VM_IDLE_EMPTY
			else
				self:SendViewModelAnim(ACT_VM_IDLE)
			end
		else
			self:SendViewModelAnim(ACT_VM_IDLE)
		end
	end

	return true, tanim
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
	if not self:OwnerIsValid() then return end

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
		elseif self.Akimbo and self.SequenceEnabled[ACT_VM_SECONDARYATTACK] and ((self.AnimCycle == 1 and not self.Akimbo_Inverted) or (self.AnimCycle == 0 and self.Akimbo_Inverted)) then
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
	if not self:OwnerIsValid() then return end
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
	if not self:OwnerIsValid() then return end
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