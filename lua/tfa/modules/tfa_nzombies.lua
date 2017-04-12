if SERVER then
	AddCSLuaFile()
end

if TFA_DisableHostilePatching == nil then
	TFA_DisableHostilePatching = false --Change this if you need to
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

--[[
local function SpreadFix()

	local GAMEMODE = gmod.GetGamemode() or GAMEMODE
	if not GAMEMODE then return end

	print("[TFA] Patching NZombies")
	if TFA_DisableHostilePatching then return end

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
]]--

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

			--if IsValid(ent:GetOwner()) and ent:GetOwner():IsPlayer() and ent:GetOwner():HasPerk("jugg") then
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
		--SpreadFix()
		MeleeFix()
	end
end

hook.Add("InitPostEntity", "TFA_NZPatch", NZPatch)
NZPatch()