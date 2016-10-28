local ply,wep

--[[
Hook: PlayerTick
Function: Weapon Logic
Used For: Main weapon "think" logic
]]--

hook.Add("PlayerTick", "PlayerTickTFA", function(plyv)
	wep = plyv:GetActiveWeapon() or wep

	if IsValid(wep) and wep.PlayerThink and wep.IsTFAWeapon then
		wep:PlayerThink(plyv)
	end
end)

--[[
Hook: PreRender
Function: Weapon Logic
Used For: Per-frame weapon "think" logic
]]
--
hook.Add("PreRender", "prerender_tfabase", function()
	if not IsValid(ply) then ply = LocalPlayer() return end
	wep = ply:GetActiveWeapon() or wep

	if IsValid(wep) and wep.IsTFAWeapon and wep.PlayerThinkClientFrame then
		wep:PlayerThinkClientFrame(ply)
	end
end)

--[[
Hook: AllowPlayerPickup
Function: Prop holding
Used For: Records last held object
]]
--
hook.Add("AllowPlayerPickup", "TFAPickupDisable", function(plyv, ent)
	plyv:SetNWEntity("LastHeldEntity", ent)
	plyv:SetNWInt("LastHeldEntityIndex", ent.EntIndex and ent:EntIndex() or -1)
end)

--[[
Hook: PlayerBindPress
Function: Intercept Keybinds
Used For:  Alternate attack, inspection, shotgun interrupts, and more
]]--

local cv_cm = GetConVar("sv_tfa_cmenu")

function TFAPlayerBindPress(plyv, b, p)
	if p and IsValid(plyv) then
		wep = plyv:GetActiveWeapon() or wep

		if IsValid(wep) then
			if wep.AltAttack and b == "+zoom" then
				wep:AltAttack()

				if CLIENT then
					net.Start("tfaAltAttack")
					net.SendToServer()
				end

				return true
			end

			if wep.ToggleInspect and b == "+menu_context" and cv_cm:GetBool() then
				wep:ToggleInspect()

				return true
			end

			if wep.ShotgunInterrupt and b == "+attack" and (wep:GetReloading() and wep.Shotgun and not wep:GetShotgunPumping() and not wep:GetShotgunNeedsPump()) then
				wep:ShotgunInterrupt()

				return true
			end
		end
	end
end

hook.Add("PlayerBindPress", "TFAInspectionMenu", TFAPlayerBindPress)

--[[
Hook: PlayerSpawn
Function: Extinguishes players
Used For:  Fixes incendiary bullets post-respawn
]]
--
hook.Add("PlayerSpawn", "TFAExtinguishQOL", function(plyv)
	if IsValid(plyv) and plyv:IsOnFire() then
		plyv:Extinguish()
	end
end)

--[[
Hook: SetupMove
Function: Modify movement speed
Used For:  Weapon slowdown, ironsights slowdown
]]--

local cv_cmove = GetConVar("sv_tfa_compatibility_movement")
local sumwep
local speedmult

if not Clockwork and ( not cv_cmove or ( not cv_cmove:GetBool() ) ) then
	hook.Add("SetupMove", "tfa_setupmove", function(plyv, movedata, commanddata)
		--[[
		if not cv_cmove then
			cv_cmove = GetConVar("sv_tfa_compatibility_movement")
		else
			if not cv_cmove:GetBool() then return end
		end
		]]--
		sumwep = plyv:GetActiveWeapon() or wep
		if IsValid(sumwep) and sumwep.GetIronSightsRatio then
			speedmult = Lerp(sumwep:GetIronSightsRatio(), sumwep.MoveSpeed or 1, sumwep.IronSightsMoveSpeed or 1)
			movedata:SetMaxClientSpeed(movedata:GetMaxClientSpeed() * speedmult)
			commanddata:SetForwardMove(commanddata:GetForwardMove() * speedmult)
			commanddata:SetSideMove(commanddata:GetSideMove() * speedmult)
		end
	end)
end

--[[
Hook: PlayerFootstep
Function: Weapoon Movement
Used For:  Weapon viewbob, gunbob per-step
]]
--
hook.Add("PlayerFootstep", "tfa_playerfootstep", function(plyv)
	local isc = TFA.PlayerCarryingTFAWeapon(plyv)

	if isc and wep.Footstep and CLIENT then
		wep:Footstep()
	end

	return
end)

--[[
Hook: HUDShouldDraw
Function: Weapon HUD
Used For:  Hides default HUD
]]--

local cv_he = GetConVar("cl_tfa_hud_enabled", 1)

if CLIENT then
	local TFAHudHide = {
		CHudAmmo = true,
		CHudSecondaryAmmo = true
	}

	hook.Add("HUDShouldDraw", "tfa_hidehud", function(name)
		if TFAHudHide[name] and cv_he:GetBool() then
			local ictfa = TFA.PlayerCarryingTFAWeapon()
			if ictfa then return false end
		end
	end)
end
