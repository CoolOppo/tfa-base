
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

--[[ AddCSLua our other essential functions. ]]--
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
--[[ Load up our shared code. ]]--
include("shared.lua")

--[[ Include these modules]]--
for _, v in pairs(SWEP.SV_MODULES) do
	include(v)
end

--[[ Include these modules, and AddCSLua them, since they're shared.]]--
for _, v in pairs(SWEP.SH_MODULES) do
	AddCSLuaFile(v)
	include(v)
end

--[[ Include these modules if singleplayer, and AddCSLua them, since they're clientside.]]--
for _, v in pairs(SWEP.ClSIDE_MODULES) do
	AddCSLuaFile(v)
end

if game.SinglePlayer() then
	for _, v in pairs(SWEP.ClSIDE_MODULES) do
		include(v)
	end
end

--[[Actual serverside values]]--
SWEP.Weight = 60 -- Decides whether we should switch from/to this
SWEP.AutoSwitchTo = true -- Auto switch to
SWEP.AutoSwitchFrom = true -- Auto switch from

local sv_tfa_npc_burst = GetConVar("sv_tfa_npc_burst")

function SWEP:NPCShoot_Primary()
	if self:Clip1() <= 0 and self:GetMaxClip1() > 0 then
		self:GetOwner():SetSchedule(SCHED_RELOAD)
		return
	end

	return self:PrimaryAttack()
end

function SWEP:GetNPCRestTimes()
	if sv_tfa_npc_burst:GetBool() or self:GetStat("NPCBurstOverride", false) then
		return self:GetStat("NPCMinRest", self:GetFireDelay()), self:GetStat("NPCMaxRest", self:GetFireDelay() * 2)
	end

	if self:GetStat("Primary.Automatic") then
		return 0, 0
	else
		return self:GetFireDelay(), self:GetFireDelay() * 2
	end
end

function SWEP:GetNPCBurstSettings()
	if sv_tfa_npc_burst:GetBool() or self:GetStat("NPCBurstOverride", false) then
		return self:GetStat("NPCMinBurst", 1), self:GetStat("NPCMinBurst", 6), self:GetStat("NPCBurstDelay", self:GetFireDelay() * self:GetMaxBurst())
	end

	if self:GetMaxClip1() > 0 then
		local burst = self:GetMaxBurst()
		local value = math.ceil(self:Clip1() / burst)
		local delay = self:GetFireDelay() * burst

		if self:GetStat("Primary.Automatic") then
			return math.min(4, value), math.min(12, value), delay
		else
			return 1, math.min(4, value), delay
		end
	else
		return 1, 30, self:GetFireDelay() * self:GetMaxBurst()
	end
end

function SWEP:GetNPCBulletSpread()
	return 1 -- we handle this manually, in calculate cone, recoil and shootbullet
end

function SWEP:CanBePickedUpByNPCs()
	return true
end

local sv_tfa_npc_randomize_atts = GetConVar("sv_tfa_npc_randomize_atts")

function SWEP:Equip(...)
	local owner = self:GetOwner()

	if owner:IsNPC() then
		self.IsNPCOwned = true

		if not self.IsFirstEquip and sv_tfa_npc_randomize_atts:GetBool() then
			self:RandomizeAttachments(true)
		end

		local function closure()
			self:NPCWeaponThinkHook()
		end

		hook.Add("TFA_NPCWeaponThink", self, function()
			ProtectedCall(closure)
		end)
	else
		self.IsNPCOwned = false
	end

	self.IsFirstEquip = true
	self.OwnerViewModel = nil
	self:EquipTTT(...)
end
