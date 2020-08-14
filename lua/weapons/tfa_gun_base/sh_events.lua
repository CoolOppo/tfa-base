
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

local sp = game.SinglePlayer()
local l_CT = CurTime
SWEP.EventTimer = -1

--[[
Function Name:  ResetEvents
Syntax: self:ResetEvents()
Returns:  Nothing.
Purpose:  Cleans up events table.
]]--
function SWEP:ResetEvents()
	if not self:OwnerIsValid() then return end

	if sp and not CLIENT then
		self:CallOnClient("ResetEvents", "")
	end

	if IsFirstTimePredicted() or game.SinglePlayer() then
		self.EventTimer = l_CT()
		for _, v in pairs(self.EventTable) do
			for _, b in pairs(v) do
				b.called = false
			end
		end
	end
end

--[[
Function Name:  ProcessEvents
Syntax: self:ProcessEvents().
Returns:  Nothing.
Notes: Critical for the event table to function.
Purpose:  Main SWEP function
]]--

function SWEP:ProcessEvents()
	if not self:VMIV() then return end
	if self.EventTimer < 0 then
		self:ResetEvents()
	end
	if sp then
		self.LastAct = self:GetLastActivity()
	end
	local evtbl = self.EventTable[ self.LastAct or self:GetLastActivity() ] or self.EventTable[ self.OwnerViewModel:GetSequenceName(self.OwnerViewModel:GetSequence()) ]

	if not evtbl then return end
	for _, v in pairs(evtbl) do
		if v.called or l_CT() < self.EventTimer + v.time / self:GetAnimationRate( self.LastAct or self:GetLastActivity() ) then goto CONTINUE end
		v.called = true

		if v.client == nil then
			v.client = true
		end

		if v.type == "lua" then
			if v.server == nil then
				v.server = true
			end

			if (v.client and CLIENT and (not v.client_predictedonly or self:GetOwner() == LocalPlayer())) or (v.server and SERVER) and v.value then
				v.value(self, self.OwnerViewModel)
			end
		elseif v.type == "snd" or v.type == "sound" then
			if v.server == nil then
				v.server = false
			end

			if SERVER then
				if v.client then
					net.Start("tfaSoundEvent")
					net.WriteEntity(self)
					net.WriteString(v.value or "")

					if sp then
						net.Broadcast()
					else
						net.SendOmit(self:GetOwner())
					end
				elseif v.server and v.value and v.value ~= "" then
					self:EmitSound(v.value)
				end
			elseif v.client and self:GetOwner() == LocalPlayer() and ( not sp ) and v.value and v.value ~= "" then
				if v.time <= 0.01 then
					self:EmitSoundSafe(v.value)
				else
					self:EmitSound(v.value)
				end
			end
		end

		::CONTINUE::
	end
end

function SWEP:EmitSoundSafe(snd)
	timer.Simple(0,function()
		if IsValid(self) and snd then self:EmitSound(snd) end
	end)
end

local ct, is, stat, statend, finalstat, waittime, lact

function SWEP:ProcessStatus()
	local self2 = self:GetTable()

	ct = l_CT()

	is = self:GetIronSights()
	stat = self:GetStatus()
	statend = self:GetStatusEnd()

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
				self:SetNextPrimaryFire(ct + self2:GetBurstDelay(self))
			end
		end
	end

	if stat == TFA.Enum.STATUS_IDLE and self:GetShotgunCancel() then
		if self2.GetStat(self, "PumpAction") then
			if ct > self:GetNextPrimaryFire() and not self:GetOwner():KeyDown(IN_ATTACK) then
				self2.DoPump(self)
			end
		else
			self:SetShotgunCancel( false )
		end
	end
end