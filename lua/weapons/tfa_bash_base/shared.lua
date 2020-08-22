
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

DEFINE_BASECLASS("tfa_gun_base")
SWEP.Secondary.BashDamage = 25
SWEP.Secondary.BashSound = Sound("TFA.Bash")
SWEP.Secondary.BashHitSound = Sound("TFA.BashWall")
SWEP.Secondary.BashHitSound_Flesh = Sound("TFA.BashFlesh")
SWEP.Secondary.BashLength = 54
SWEP.Secondary.BashDelay = 0.2
SWEP.Secondary.BashDamageType = DMG_SLASH
SWEP.Secondary.BashEnd = nil --Override bash sequence length easier
SWEP.Secondary.BashInterrupt = false --Do you need to be in a "ready" status to bash?
SWEP.BashBase = true

function SWEP:BashForce(ent, force, pos, now)
	if not IsValid(ent) or not ent.GetPhysicsObjectNum then return end

	if now then
		if ent.GetRagdollEntity then
			ent = ent:GetRagdollEntity() or ent
		end

		local phys = ent:GetPhysicsObjectNum(0)

		if IsValid(phys) then
			if ent:IsPlayer() or ent:IsNPC() then
				ent:SetVelocity( force * 0.1)
				phys:SetVelocity(phys:GetVelocity() + force * 0.1)
			else
				phys:ApplyForceOffset(force, pos)
			end
		end
	else
		timer.Simple(0, function()
			if IsValid(self) and self:OwnerIsValid() and IsValid(ent) then
				self:BashForce(ent, force, pos, true)
			end
		end)
	end
end

local cv_doordestruction = GetConVar("sv_tfa_melee_doordestruction")

function SWEP:HandleDoor(slashtrace)
	if CLIENT or not IsValid(slashtrace.Entity) then return end

	if not cv_doordestruction:GetBool() then return end

	if slashtrace.Entity:GetClass() == "func_door_rotating" or slashtrace.Entity:GetClass() == "prop_door_rotating" then
		slashtrace.Entity:EmitSound("ambient/materials/door_hit1.wav", 100, math.random(80, 120))

		local newname = "TFABash" .. self:EntIndex()
		self.PreBashName = self:GetName()
		self:SetName(newname)

		slashtrace.Entity:SetKeyValue("Speed", "500")
		slashtrace.Entity:SetKeyValue("Open Direction", "Both directions")
		slashtrace.Entity:SetKeyValue("opendir", "0")
		slashtrace.Entity:Fire("unlock", "", .01)
		slashtrace.Entity:Fire("openawayfrom", newname, .01)

		timer.Simple(0.02, function()
			if not IsValid(self) or self:GetName() ~= newname then return end

			self:SetName(self.PreBashName)
		end)

		timer.Simple(0.3, function()
			if IsValid(slashtrace.Entity) then
				slashtrace.Entity:SetKeyValue("Speed", "100")
			end
		end)
	end
end

local l_CT = CurTime
local sp = game.SinglePlayer()

function SWEP:AltAttack()
	local time = l_CT()

	if
		self:GetStat("Secondary.CanBash") == false or
		not self:OwnerIsValid() or
		time < self:GetNextSecondaryFire()
	then return end

	local stat = self:GetStatus()
	if not TFA.Enum.ReadyStatus[stat] and not self:GetStat("Secondary.BashInterrupt") or
		stat == TFA.Enum.STATUS_BASHING and self:GetStat("Secondary.BashInterrupt") then return end

	if self:IsSafety() or self:GetHolding() then return end

	local enabled, act = self:ChooseBashAnim()
	if not enabled then return end

	if self:GetOwner().Vox and IsFirstTimePredicted() then
		self:GetOwner():Vox("bash", 0)
	end

	self:BashAnim()
	if sp and SERVER then self:CallOnClient("BashAnim", "") end

	local bashend = self:GetStat("Secondary.BashEnd")

	self:SetNextPrimaryFire(time + (bashend or self:GetActivityLength(act, false)))
	self:SetNextSecondaryFire(time + (bashend or self:GetActivityLength(act, true)))

	self:EmitSoundNet(self:GetStat("Secondary.BashSound"))

	self:SetStatus(TFA.Enum.STATUS_BASHING)
	self:SetStatusEnd(time + (bashend or self:GetActivityLength(act, true)))

	self:SetNW2Float("BashTTime", time + self:GetStat("Secondary.BashDelay"))
end

function SWEP:BashAnim()
	--if IsValid(wep) and wep.GetHoldType then
	local ht = self.DefaultHoldType or self.HoldType
	local altanim = false

	if ht == "ar2" or ht == "shotgun" or ht == "crossbow" or ht == "physgun" then
		altanim = true
	end

	self:GetOwner():AnimRestartGesture(0, altanim and ACT_GMOD_GESTURE_MELEE_SHOVE_2HAND or ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2, true)
end

local ttime = -1

function SWEP:HandleBashAttack()
	local ply = self:GetOwner()
	local pos = ply:GetShootPos()
	local av = ply:GetAimVector()

	local slash = {}
	slash.start = pos
	slash.endpos = pos + (av * self:GetStat("Secondary.BashLength"))
	slash.filter = ply
	slash.mins = Vector(-10, -5, 0)
	slash.maxs = Vector(10, 5, 5)
	local slashtrace = util.TraceHull(slash)

	local pain = self:GetStat("Secondary.BashDamage")

	if not slashtrace.Hit then return end
	self:HandleDoor(slashtrace)

	if not (sp and CLIENT) then
		self:EmitSound(
			(slashtrace.MatType == MAT_FLESH or slashtrace.MatType == MAT_ALIENFLESH) and
			self:GetStat("Secondary.BashHitSound_Flesh") or
			self:GetStat("Secondary.BashHitSound"))
	end

	if CLIENT then return end

	local dmg = DamageInfo()
	dmg:SetAttacker(ply)
	dmg:SetInflictor(self)
	dmg:SetDamagePosition(pos)
	dmg:SetDamageForce(av * pain)
	dmg:SetDamage(pain)
	dmg:SetDamageType(self:GetStat("Secondary.BashDamageType"))

	if IsValid(slashtrace.Entity) and slashtrace.Entity.TakeDamageInfo then
		slashtrace.Entity:TakeDamageInfo(dmg)
	end

	local ent = slashtrace.Entity
	if not IsValid(ent) or not ent.GetPhysicsObject then return end

	local phys

	if ent:IsRagdoll() then
		phys = ent:GetPhysicsObjectNum(slashtrace.PhysicsBone or 0)
	else
		phys = ent:GetPhysicsObject()
	end

	if IsValid(phys) then
		if ent:IsPlayer() or ent:IsNPC() then
			ent:SetVelocity(av * self:GetStat("Secondary.BashDamage") * 0.5)
			phys:SetVelocity(phys:GetVelocity() + av * self:GetStat("Secondary.BashDamage") * 0.5)
		else
			phys:ApplyForceOffset(av * self:GetStat("Secondary.BashDamage") * 0.5, slashtrace.HitPos)
		end
	end
end

function SWEP:Think2(...)
	ttime = self:GetNW2Float("BashTTime", -1)

	if ttime ~= -1 and l_CT() > ttime then
		self:SetNW2Float("BashTTime", -1)

		if IsFirstTimePredicted() then
			self:HandleBashAttack()
		end
	end

	BaseClass.Think2(self, ...)
end

function SWEP:SecondaryAttack()
	if self:GetStat("data.ironsights", 0) == 0 then
		self:AltAttack()
		return
	end

	BaseClass.SecondaryAttack(self)
end

function SWEP:GetBashing()
	if not self:VMIV() then
		return self:GetStatus() == TFA.Enum.STATUS_BASHING
	end

	local stat = self:GetStatus()

	return (stat == TFA.Enum.STATUS_BASHING) and self.OwnerViewModel:GetCycle() > 0 and self.OwnerViewModel:GetCycle() < 0.65
end
