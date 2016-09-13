--[[DEPRECATED]]--

local function VecOrFix()
	vector_origin.x=0
	vector_origin.y=0
	vector_origin.z=0
end

--[[
Hook: PlayerTick
Function: Weapon Logic
Used For: Main weapon "think" logic
]]--

hook.Add( "PlayerTick" , "PlayerTickTFA", function( ply )
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) then
		if wep.PlayerThink and wep.IsTFAWeapon then
			wep:PlayerThink( ply )
		end
	end
end)

--[[
Hook: PreRender
Function: Weapon Logic
Used For: Per-frame weapon "think" logic
]]--

hook.Add("PreRender", "prerender_tfabase", function()

	ply = LocalPlayer()
	if !IsValid(ply) then return end
	wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.IsTFAWeapon and wep.PlayerThinkClientFrame then
		wep:PlayerThinkClientFrame(ply)
	end

end)

--[[
Hook: AllowPlayerPickup
Function: Prop holding
Used For: Records last held object
]]--

hook.Add("AllowPlayerPickup","TFAPickupDisable", function(ply, ent)
	ply:SetNWEntity("LastHeldEntity",ent)
	ply:SetNWInt("LastHeldEntityIndex",ent.EntIndex and ent:EntIndex() or -1)
end)

--[[
Hook: PlayerBindPress
Function: Intercept Keybinds
Used For:  Alternate attack, inspection, shotgun interrupts, and more
]]--

function TFAPlayerBindPress(ply, b, p)
	if p and IsValid(ply) then
		local wep = ply:GetActiveWeapon()

		if IsValid(wep) then
			if wep.AltAttack then
				if b == "+zoom" then
					wep:AltAttack()
					if CLIENT then
						net.Start("tfaAltAttack")
						net.SendToServer()
					end
					return true
				end
			end
			if wep.ToggleInspect then
				if b == "+menu_context" and GetConVarNumber("sv_tfa_cmenu",1)==1  then
					wep:ToggleInspect()
					return true
				end
			end
			if wep.ShotgunInterrupt then
				if b == "+attack" and (wep:GetReloading() and wep.Shotgun and !wep:GetShotgunPumping() and !wep:GetShotgunNeedsPump()) then
					wep:ShotgunInterrupt()
					return true
				end
			end
		end
	end
end

hook.Add("PlayerBindPress", "TFAInspectionMenu", TFAPlayerBindPress)

--[[
Hook: PlayerSpawn
Function: Extinguishes players
Used For:  Fixes incendiary bullets post-respawn
]]--

hook.Add("PlayerSpawn","TFAExtinguishQOL", function(ply)
	if IsValid(ply) then
		if ply:IsOnFire() then
			ply:Extinguish()
		end
	end
end)

--[[
Hook: SetupMove
Function: Modify movement speed
Used For:  Weapon slowdown, ironsights slowdown
]]--

if !(Clockwork) and GetConVarNumber("sv_tfa_compatibility_movement",0)!=1 then
	hook.Add("SetupMove","tfa_setupmove",function( ply, movedata, commanddata )

		local iscarryingtfaweapon, pl, wep = PlayerCarryingTFAWeapon( ply )

		if iscarryingtfaweapon then
			if wep.GetIronSightsRatio then
				local speedmult = Lerp(wep:GetIronSightsRatio(), wep.MoveSpeed or 1, wep.IronSightsMoveSpeed or 1)
				movedata:SetMaxClientSpeed(movedata:GetMaxClientSpeed()*speedmult)
				commanddata:SetForwardMove(commanddata:GetForwardMove()*speedmult)
				commanddata:SetSideMove(commanddata:GetSideMove()*speedmult)
			end
		end

	end)
end

--[[
Hook: PlayerFootstep
Function: Weapoon Movement
Used For:  Weapon viewbob, gunbob per-step
]]--

hook.Add("PlayerFootstep","tfa_playerfootstep", function( ply )
	local isc, pl, wep = PlayerCarryingTFAWeapon(ply)

	if isc then
		if wep.Footstep and CLIENT then
			wep:Footstep()
		end
	end

	return
end)

--[[
Hook: HUDShouldDraw
Function: Weapon HUD
Used For:  Hides default HUD
]]--

if CLIENT then

	local TFAHudHide = {
		CHudAmmo = true,
		CHudSecondaryAmmo = true
	}

	hook.Add("HUDShouldDraw", "tfa_hidehud", function( name )
		if ( TFAHudHide[ name ] ) and ( GetConVarNumber("cl_tfa_hud_enabled",1) == 1 ) then
			local ictfa = PlayerCarryingTFAWeapon()
			if ictfa then
				return false
			end
		end
	end)

end
