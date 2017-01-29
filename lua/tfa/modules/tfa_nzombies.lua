if SERVER then
	AddCSLuaFile()
end

local cv_melee_scaling, cv_melee_basefactor
local nzombies = string.lower(engine.ActiveGamemode() or "") == "nzombies"

if nZombies or NZombies or NZ or NZombies then
	nzombies = true
end

if nzombies then
	cv_melee_scaling = CreateConVar("sv_tfa_nz_melee_scaling", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "0.5x means if zombies have 4x health, melee does 2x damage")
	cv_melee_basefactor = CreateConVar("sv_tfa_nz_melee_multiplier", "0.65", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "Base damage scale for TFA Melees.")
	cv_melee_berserkscale = CreateConVar("sv_tfa_nz_melee_immunity", "0.67", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "Take X% damage from zombies while you're melee.")
	--cv_melee_juggscale = CreateConVar("sv_tfa_nz_melee_juggernaut", "1.5", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_REPLICATED}, "Do X% damage to zombies while you're jug.")
end

local function VarArgPatch()
	function ReplacePrimaryFireCooldown(wep)
		wep.PrimaryAttackOld = wep.PrimaryAttackOld or wep.PrimaryAttack
		wep.PrimaryAttack = function(self, ...)
			local npfold = wep:GetNextPrimaryFire()
			wep.PrimaryAttackOld(wep, ...)
			if wep:GetNextPrimaryFire() <= npfold then return end
			-- FAS2 weapons have built-in DTap functionality
			if wep:IsFAS2() then return end

			-- With double tap, reduce the delay for next primary fire to 2/3

			local dtap1,dtap2 = wep.Owner:HasPerk("dtap"), wep.Owner:HasPerk("dtap2")
			if wep:IsTFA() then
				if dtap1 or dtap2 then
					local delay = wep:GetNextPrimaryFire() - CurTime()
					if dtap2 then
						delay = delay * 0.8
					end
					if dtap1 then
						delay = delay * 0.8
					end
					wep:SetNextPrimaryFire(CurTime() + delay)
					if wep:IsTFA() and (  wep:GetStatus() == TFA.GetStatus("shooting") or wep:GetStatus()  == TFA.GetStatus("bashing") ) then
						delay = wep:GetStatusEnd() - CurTime()
						if dtap2 then
							delay = delay * 0.8
						end
						if dtap1 then
							delay = delay * 0.8
						end
						wep:SetStatusEnd( CurTime() + delay )
					end
				end
			else
				local delay = wep:GetNextPrimaryFire() - CurTime()
				if dtap1 or dtap2 then
					delay = delay * 0.8
				end
				wep:SetNextPrimaryFire(CurTime() + delay)
			end
		end
		wep.SecondaryAttackOld = wep.SecondaryAttackOld or wep.SecondaryAttack
		wep.SecondaryAttack = function(self, ...)
			local npfold = wep:GetNextPrimaryFire()
			wep.SecondaryAttackOld(wep, ...)
			if wep:GetNextPrimaryFire() <= npfold then return end
			-- FAS2 weapons have built-in DTap functionality
			if wep:IsFAS2() then return end

			-- With double tap, reduce the delay for next primary fire to 2/3

			local dtap1,dtap2 = wep.Owner:HasPerk("dtap"), wep.Owner:HasPerk("dtap2")
			if wep:IsTFA() then
				if dtap1 or dtap2 then
					local delay = wep:GetNextPrimaryFire() - CurTime()
					if dtap2 then
						delay = delay * 0.8
					end
					if dtap1 then
						delay = delay * 0.8
					end
					wep:SetNextPrimaryFire(CurTime() + delay)
					if wep:IsTFA() and (  wep:GetStatus() == TFA.GetStatus("shooting") or wep:GetStatus()  == TFA.GetStatus("bashing") ) then
						delay = wep:GetStatusEnd() - CurTime()
						if dtap2 then
							delay = delay * 0.8
						end
						if dtap1 then
							delay = delay * 0.8
						end
						wep:SetStatusEnd( CurTime() + delay )
					end
				end
			else
				local delay = wep:GetNextPrimaryFire() - CurTime()
				if dtap1 or dtap2 then
					delay = delay * 0.8
				end
				wep:SetNextPrimaryFire(CurTime() + delay)
			end
		end
	end

	hook.Add("WeaponEquip", "nzModifyWeaponNextFires", ReplacePrimaryFireCooldown)

	function ReplaceReloadFunction(wep)
		-- Either not a weapon, doesn't have a reload function, or is FAS2
		if wep:NZPerkSpecialTreatment() then return end
		wep.ReloadOld = wep.ReloadOld or wep.Reload
		if not wep.ReloadOld then return end

		--print("Weapon reload modified")
		wep.Reload = function(self, ...)
			if wep.ReloadFinish and wep.ReloadFinish > CurTime() then return end
			local ply = wep.Owner

			if ply:HasPerk("speed") and not wep:IsTFA() then
				--print("Hasd perk")
				local cur = wep:Clip1()
				if cur >= wep:GetMaxClip1() then return end
				local give = wep:GetMaxClip1() - cur

				if give > ply:GetAmmoCount(wep:GetPrimaryAmmoType()) then
					give = ply:GetAmmoCount(wep:GetPrimaryAmmoType())
				end

				if give <= 0 then return end
				--print(give)
				wep:SendWeaponAnim(ACT_VM_RELOAD)
				wep.ReloadOld(self, ...)
				local rtime = wep:SequenceDuration(wep:SelectWeightedSequence(ACT_VM_RELOAD)) / 2
				wep:SetPlaybackRate(2)
				ply:GetViewModel():SetPlaybackRate(2)
				local nexttime = CurTime() + rtime
				wep:SetNextPrimaryFire(nexttime)
				wep:SetNextSecondaryFire(nexttime)
				wep.ReloadFinish = nexttime

				timer.Simple(rtime, function()
					if IsValid(wep) and ply:GetActiveWeapon() == wep then
						wep:SetPlaybackRate(1)
						ply:GetViewModel():SetPlaybackRate(1)
						wep:SendWeaponAnim(ACT_VM_IDLE)
						wep:SetClip1(give + cur)
						ply:RemoveAmmo(give, wep:GetPrimaryAmmoType())
						wep:SetNextPrimaryFire(0)
						wep:SetNextSecondaryFire(0)
					end
				end)
			else
				wep.ReloadOld(self, ...)
			end
		end
	end

	hook.Add("WeaponEquip", "nzModifyWeaponReloads", ReplaceReloadFunction)
end

local function SpreadFix()
	print("[TFA] Patching NZombies")

	local ghosttraceentities = {
		["wall_block"] = true,
		["invis_wall"] = true,
		["player"] = true
	}

	function GAMEMODE:EntityFireBullets(ent, data)
		-- Fire the PaP shooting sound if the weapon is PaP'd
		--print(wep, wep.pap)
		if ent:IsPlayer() and IsValid(ent:GetActiveWeapon()) then
			local wep = ent:GetActiveWeapon()
			if wep.pap and ( not wep.IsMelee ) and ( not wep.IsKnife ) then
				wep:EmitSound("nz/effects/pap_shoot_glock20.wav", 105, 100)
			end
		end

		if ent:IsPlayer() and ent:HasPerk("dtap2") then
			data.Num = data.Num * 2
		end

		-- Perform a trace that filters out entities from the table above
		local tr = util.TraceLine({
			start = data.Src,
			endpos = data.Src + (data.Dir * data.Distance),
			filter = function(entv)
				if ghosttraceentities[entv:GetClass()] and not entv:IsPlayer() then
					return true
				else
					return false
				end
			end
		})

		--PrintTable(tr)
		-- If we hit anything, move the source of the bullets up to that point
		if IsValid(tr.Entity) and tr.Fraction < 1 then
			local tr2 = util.TraceLine({
				start = data.Src,
				endpos = data.Src + (data.Dir * data.Distance),
				filter = function(entv)
					if ghosttraceentities[entv:GetClass()] then
						return false
					else
						return true
					end
				end
			})

			data.Src = tr2.HitPos - data.Dir * 5

			return true
		end

		if ent:IsPlayer() and ent:HasPerk("dtap2") then return true end
	end
end

local function MeleeFix()
	hook.Add("EntityTakeDamage", "TFA_MeleeScaling", function(target, dmg)
		if not nzRound then return end
		local ent = dmg:GetInflictor()

		if not ent:IsWeapon() and ent:IsPlayer() then
			ent = ent:GetActiveWeapon()
		end

		if not IsValid(ent) or not ent:IsWeapon() then return end

		if ent.IsTFAWeapon and ( dmg:IsDamageType(DMG_CRUSH) or dmg:IsDamageType(DMG_CLUB) or dmg:IsDamageType(DMG_SLASH)) then
			local scalefactor = cv_melee_scaling:GetFloat()
			local basefactor = cv_melee_basefactor:GetFloat()
			dmg:ScaleDamage(((nzRound:GetZombieHealth() - 75) / 75 * scalefactor + 1) * basefactor)

			--if IsValid(ent.Owner) and ent.Owner:IsPlayer() and ent.Owner:HasPerk("jugg") then
			--	dmg:ScaleDamage(cv_melee_juggscale:GetFloat())
			--end
		end
	end)

	hook.Add("EntityTakeDamage", "TFA_MeleeReceiveLess", function(target, dmg)
		if target:IsPlayer() and target.GetActiveWeapon then
			wep = target:GetActiveWeapon()

			if IsValid(wep) and wep:IsTFA() and (wep.IsKnife or wep.IsMelee or wep.Primary.Reach) then
				dmg:ScaleDamage(cv_melee_berserkscale:GetFloat())
			end
		end
	end)

	hook.Add("EntityTakeDamage", "TFA_MeleePaP", function(target, dmg)
		local ent = dmg:GetInflictor()
		if IsValid( ent ) then
			if ent:IsPlayer() then
				wep = ent:GetActiveWeapon()
			elseif ent:IsWeapon() then
				wep = ent
			end
			if IsValid(wep) and wep:IsTFA() and ( wep.Primary.Attacks or wep.IsMelee or wep.Primary.Reach ) and wep:GetPaP() then
				dmg:ScaleDamage( 2 )
			end
		end
	end)
end

local function NZPatch()
	nzombies = string.lower(engine.ActiveGamemode() or "") == "nzombies"

	if nZombies or NZombies or NZ or NZombies then
		nzombies = true
	end

	if nzombies then
		SpreadFix()
		VarArgPatch()
		MeleeFix()
	end
end

hook.Add("InitPostEntity", "TFA_NZPatch", NZPatch)
NZPatch()