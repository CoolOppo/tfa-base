
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

local lshift = bit.lshift
local band = bit.band
local bor = bit.bor
local bxor = bit.bxor

local sp = game.SinglePlayer()
local l_CT = CurTime

local is, spr, wlk, cst

--[[
Function Name:  ResetEvents
Syntax: self:ResetEvents()
Returns:  Nothing.
Purpose:  Cleans up events table.
]]--
function SWEP:ResetEvents()
	self:SetEventStatus1(0x00000000)
	self:SetEventStatus2(0x00000000)
	self:SetEventStatus3(0x00000000)
	self:SetEventStatus4(0x00000000)
	self:SetEventStatus5(0x00000000)
	self:SetEventStatus6(0x00000000)
	self:SetEventStatus7(0x00000000)
	self:SetEventStatus8(0x00000000)

	self:SetEventTimer(l_CT())

	if self.EventTable then
		for k, eventtable in pairs(self.EventTable) do
			for i = 1, #eventtable do
				eventtable[i].called = false
			end
		end

	end
end

function SWEP:GetEventPlayed(event_slot)
	local inner_index = event_slot % 32
	local outer_index = (event_slot - inner_index) / 32
	local lindex = lshift(1, inner_index)

	if outer_index == 0 then
		return band(lindex, self:GetEventStatus1()) ~= 0, inner_index, outer_index, lindex
	elseif outer_index == 1 then
		return band(lindex, self:GetEventStatus2()) ~= 0, inner_index, outer_index, lindex
	elseif outer_index == 2 then
		return band(lindex, self:GetEventStatus3()) ~= 0, inner_index, outer_index, lindex
	elseif outer_index == 3 then
		return band(lindex, self:GetEventStatus4()) ~= 0, inner_index, outer_index, lindex
	elseif outer_index == 4 then
		return band(lindex, self:GetEventStatus5()) ~= 0, inner_index, outer_index, lindex
	elseif outer_index == 5 then
		return band(lindex, self:GetEventStatus6()) ~= 0, inner_index, outer_index, lindex
	elseif outer_index == 6 then
		return band(lindex, self:GetEventStatus7()) ~= 0, inner_index, outer_index, lindex
	elseif outer_index == 7 then
		return band(lindex, self:GetEventStatus8()) ~= 0, inner_index, outer_index, lindex
	end

	return false, inner_index, outer_index, lindex
end

function SWEP:SetEventPlayed(event_slot)
	local inner_index = event_slot % 32
	local outer_index = (event_slot - inner_index) / 32
	local lindex = lshift(1, inner_index)

	if outer_index == 0 then
		self:SetEventStatus1(bor(self:GetEventStatus1(), lindex))
	elseif outer_index == 1 then
		self:SetEventStatus2(bor(self:GetEventStatus2(), lindex))
	elseif outer_index == 2 then
		self:SetEventStatus3(bor(self:GetEventStatus3(), lindex))
	elseif outer_index == 3 then
		self:SetEventStatus4(bor(self:GetEventStatus4(), lindex))
	elseif outer_index == 4 then
		self:SetEventStatus5(bor(self:GetEventStatus5(), lindex))
	elseif outer_index == 5 then
		self:SetEventStatus6(bor(self:GetEventStatus6(), lindex))
	elseif outer_index == 6 then
		self:SetEventStatus7(bor(self:GetEventStatus7(), lindex))
	elseif outer_index == 7 then
		self:SetEventStatus8(bor(self:GetEventStatus8(), lindex))
	end

	return inner_index, outer_index, lindex
end

--[[
Function Name:  ProcessEvents
Syntax: self:ProcessEvents().
Returns:  Nothing.
Notes: Critical for the event table to function.
Purpose:  Main SWEP function
]]--

SWEP._EventSlotCount = 0
SWEP.EventTableBuilt = {}

function SWEP:ProcessEvents(firstprediction)
	local viewmodel = self:VMIVNPC()
	if not viewmodel then return end

	local ply = self:GetOwner()
	local isplayer = ply:IsPlayer()

	local evtbl = self.EventTableBuilt[self:GetLastActivity() or -1] or self.EventTableBuilt[viewmodel:GetSequenceName(viewmodel:GetSequence())]
	local evtbl2 = self.EventTable[self:GetLastActivity() or -1] or self.EventTable[viewmodel:GetSequenceName(viewmodel:GetSequence())]
	if not evtbl then return end

	local curtime = l_CT()
	local eventtimer = self:GetEventTimer()
	local is_local = CLIENT and ply == LocalPlayer()
	local animrate = self:GetAnimationRate(self:GetLastActivity() or -1)

	for i = 1, #evtbl do
		local event = evtbl[i]
		if self:GetEventPlayed(event.slot) or curtime < eventtimer + event.time / animrate then goto CONTINUE end
		self:SetEventPlayed(event.slot)

		if evtbl2 and evtbl2[i] then
			evtbl2[i].called = true
		end

		if event.type == "lua" then
			if ((event.client and CLIENT and (not event.client_predictedonly or is_local)) or (event.server and SERVER)) and event.value then
				event.value(self, viewmodel)
			end
		elseif event.type == "snd" or event.type == "sound" then
			if SERVER then
				if event.client then
					if not isplayer and player.GetCount() ~= 0 then
						net.Start("tfaSoundEvent")
						net.WriteEntity(self)
						net.WriteString(event.value or "")
						net.SendPVS(self:GetPos())
					elseif isplayer then
						net.Start("tfaSoundEvent")
						net.WriteEntity(self)
						net.WriteString(event.value or "")

						if sp then
							net.SendPVS(self:GetPos())
						else
							net.SendOmit(ply)
						end
					end
				elseif event.server and event.value and event.value ~= "" then
					self:EmitSound(event.value)
				end
			elseif event.client and is_local and not sp and event.value and event.value ~= "" then
				if firstprediction or firstprediction == nil then
					if event.time <= 0.01 then
						self:EmitSoundSafe(event.value)
					else
						self:EmitSound(event.value)
					end
				end
			end
		elseif event.type == "bg" or event.type == "bodygroup" then
			if ((event.client and CLIENT and (not event.client_predictedonly or is_local)) or
				(event.server and SERVER)) and (event.name and event.value and event.value ~= "") then

				if event.view then
					self.Bodygroups_V[event.name] = event.value
				end

				if event.world then
					self.Bodygroups_W[event.name] = event.value
				end
			end
		end

		::CONTINUE::
	end
end

function SWEP:EmitSoundSafe(snd)
	timer.Simple(0, function()
		if IsValid(self) and snd then self:EmitSound(snd) end
	end)
end

local ct, stat, statend, finalstat, waittime, lact

function SWEP:ProcessStatus()
	local self2 = self:GetTable()

	is = self2.GetIronSightsRaw(self)
	spr = self2.GetSprinting(self)
	wlk = self2.GetWalking(self)
	cst = self2.GetCustomizing(self)

	local ply = self:GetOwner()
	local isplayer = ply:IsPlayer()

	if stat == TFA.Enum.STATUS_FIDGET and is then
		self:SetStatusEnd(0)

		self2.Idle_Mode_Old = self2.Idle_Mode
		self2.Idle_Mode = TFA.Enum.IDLE_BOTH
		self2.ChooseIdleAnim(self)

		if sp then
			self:CallOnClient("ChooseIdleAnim", "")
		end

		self2.Idle_Mode = self2.Idle_Mode_Old
		self2.Idle_Mode_Old = nil
		statend = -1
	end

	is = self:GetIronSights()
	stat = self:GetStatus()
	statend = self:GetStatusEnd()

	ct = l_CT()

	if stat ~= TFA.Enum.STATUS_IDLE and ct > statend then
		finalstat = TFA.Enum.STATUS_IDLE

		--Holstering
		if stat == TFA.Enum.STATUS_HOLSTER then
			finalstat = TFA.Enum.STATUS_HOLSTER_READY
			self:SetStatusEnd(ct + 0.0)
		elseif stat == TFA.Enum.STATUS_HOLSTER_READY then
			self2.FinishHolster(self)
			finalstat = TFA.Enum.STATUS_HOLSTER_FINAL
			self:SetStatusEnd(ct + 0.6)
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL then
			--Shotgun Reloading from empty
			if not self2.IsJammed(self) then
				self2.TakePrimaryAmmo(self, 1, true)
				self2.TakePrimaryAmmo(self, -1)
			end

			if self2.Ammo1(self) <= 0 or self:Clip1() >= self2.GetPrimaryClipSize(self) or self:GetShotgunCancel() then
				finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
				local _, tanim = self2.ChooseShotgunPumpAnim(self)
				self:SetStatusEnd(ct + self:GetActivityLength(tanim))
				self:SetShotgunCancel(false)

				if not self:GetShotgunCancel() then
					self:SetJammed(false)
				end
			else
				lact = self:GetLastActivity()
				waittime = self2.GetActivityLength(self, lact, false) - self2.GetActivityLength(self, lact, true)

				if waittime > 0.01 then
					finalstat = TFA.Enum.STATUS_RELOADING_WAIT
					self:SetStatusEnd(ct + waittime)
				else
					finalstat = self2.LoadShell(self)
				end

				self:SetJammed(false)
				--finalstat = self:LoadShell()
				--self:SetStatusEnd( self:GetNextPrimaryFire() )
			end
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_START then
			--Shotgun Reloading
			finalstat = self2.LoadShell(self)
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP then
			self2.TakePrimaryAmmo(self, 1, true)
			self2.TakePrimaryAmmo(self, -1)
			lact = self:GetLastActivity()

			if self2.GetActivityLength(self, lact, true) < self2.GetActivityLength(self, lact, false) - 0.01 then
				local sht = self2.GetStat(self, "ShellTime")

				if sht then
					sht = sht / self2.GetAnimationRate(self, ACT_VM_RELOAD)
				end

				waittime = (sht or self2.GetActivityLength(self, lact, false)) - self2.GetActivityLength(self, lact, true)
			else
				waittime = 0
			end

			if waittime > 0.01 then
				finalstat = TFA.Enum.STATUS_RELOADING_WAIT
				self:SetStatusEnd(ct + waittime)
			else
				if self2.Ammo1(self) <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
					finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
					local _, tanim = self2.ChooseShotgunPumpAnim(self)
					self:SetStatusEnd(ct + self:GetActivityLength(tanim))
					self:SetShotgunCancel(false)
				else
					finalstat = self2.LoadShell(self)
				end
			end
		elseif stat == TFA.Enum.STATUS_RELOADING then
			self2.CompleteReload(self)
			lact = self:GetLastActivity()
			waittime = self2.GetActivityLength(self, lact, false) - self2.GetActivityLength(self, lact, true)

			if waittime > 0.01 then
				finalstat = TFA.Enum.STATUS_RELOADING_WAIT
				self:SetStatusEnd(ct + waittime)
			end
		elseif stat == TFA.Enum.STATUS_SILENCER_TOGGLE then
			--self:SetStatusEnd( self:GetNextPrimaryFire() )
			self:SetSilenced(not self:GetSilenced())
			self2.Silenced = self:GetSilenced()
		elseif stat == TFA.Enum.STATUS_RELOADING_WAIT and self2.Shotgun then
			if self2.Ammo1(self) <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
				finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
				local _, tanim = self2.ChooseShotgunPumpAnim(self)
				self:SetStatusEnd(ct + self:GetActivityLength(tanim))
				--self:SetShotgunCancel( false )
			else
				finalstat = self2.LoadShell(self)
			end
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_END and self2.Shotgun then
			self:SetShotgunCancel(false)
		elseif self2.GetStat(self, "PumpAction") and stat == TFA.Enum.STATUS_PUMP then
			self:SetShotgunCancel(false)
		elseif stat == TFA.Enum.STATUS_SHOOTING and self2.GetStat(self, "PumpAction") then
			if self:Clip1() == 0 and self2.GetStat(self, "PumpAction").value_empty then
				--finalstat = TFA.GetStatus("pump_ready")
				self:SetShotgunCancel(true)
			elseif (self2.GetStat(self, "Primary.ClipSize") < 0 or self:Clip1() > 0) and self2.GetStat(self, "PumpAction").value then
				--finalstat = TFA.GetStatus("pump_ready")
				self:SetShotgunCancel(true)
			end
		end

		--self:SetStatusEnd( math.huge )
		self:SetStatus(finalstat)
		local smi = self2.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID or self2.Sights_Mode == TFA.Enum.LOCOMOTION_ANI
		local spi = self2.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or self2.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI
		local wmi = self2.Walk_Mode == TFA.Enum.LOCOMOTION_HYBRID or self2.Walk_Mode == TFA.Enum.LOCOMOTION_ANI
		local cmi = self2.Customize_Mode == TFA.Enum.LOCOMOTION_HYBRID or self2.Customize_Mode == TFA.Enum.LOCOMOTION_ANI

		if (not TFA.Enum.ReadyStatus[stat]) and stat ~= TFA.Enum.STATUS_SHOOTING and stat ~= TFA.Enum.STATUS_PUMP and finalstat == TFA.Enum.STATUS_IDLE and ((smi or spi) or (cst and cmi)) then
			is = self2.GetIronSights(self, true)

			if (is and smi) or (spr and spi) or (wlk and wmi) or (cst and cmi) then
				local success, _ = self2.Locomote(self, is and smi, is, spr and spi, spr, wlk and wmi, wlk, cst and cmi, cst)

				if success == false then
					self:SetNextIdleAnim(-1)
				else
					self:SetNextIdleAnim(math.max(self:GetNextIdleAnim(), ct + 0.1))
				end
			end
		end

		self2.LastBoltShoot = nil

		if self:GetBurstCount() > 0 then
			if finalstat ~= TFA.Enum.STATUS_SHOOTING and finalstat ~= TFA.Enum.STATUS_IDLE then
				self:SetBurstCount(0)
			elseif self:GetBurstCount() < self:GetMaxBurst() and self:Clip1() > 0 then
				self:PrimaryAttack()
			else
				self:SetBurstCount(0)
				self:SetNextPrimaryFire(ct + self2.GetBurstDelay(self))
			end
		end
	end

	if stat == TFA.Enum.STATUS_IDLE and self:GetShotgunCancel() then
		if self2.GetStat(self, "PumpAction") then
			if ct > self:GetNextPrimaryFire() and (not isplayer or not ply:KeyDown(IN_ATTACK)) then
				self2.DoPump(self)
			end
		else
			self:SetShotgunCancel(false)
		end
	end
end