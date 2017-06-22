local ply,wep,sp

sp = game.SinglePlayer()

--[[
Hook: PlayerTick
Function: Weapon Logic
Used For: Main weapon "think" logic
]]--

hook.Add("PlayerTick", "PlayerTickTFA", function(plyv)
	wep = plyv:GetActiveWeapon() or wep

	if IsValid(wep) and wep.PlayerThink  and wep.IsTFAWeapon then
		wep:PlayerThink(plyv)
	end
end)

--[[
Hook: Tick
Function: Inspection mouse support
Used For: Enables and disables screen clicker
]]--

if CLIENT then
	local tfablurintensity
	local its_old = 0
	local ScreenClicker = false
	local att_enabled_cv

	hook.Add("Tick","TFAInspectionScreenClicker",function( )
		if not att_enabled_cv then
			att_enabled_cv = GetConVar("sv_tfa_attachments_enabled")
		end
		if not att_enabled_cv then
			return
		end
		tfablurintensity = 0
		if LocalPlayer():IsValid() and IsValid( LocalPlayer():GetActiveWeapon() ) and att_enabled_cv:GetBool() then
			local w = LocalPlayer():GetActiveWeapon()
			if not w.Attachments then
				tfablurintensity = 0
			elseif table.Count( w.Attachments ) <= 0 then
				tfablurintensity = 0
			else
				tfablurintensity = w.Inspecting and 1 or 0
			end
		end
		if tfablurintensity > its_old and not ScreenClicker then
			gui.EnableScreenClicker(true)
			ScreenClicker = true
		elseif tfablurintensity < its_old and ScreenClicker then
			gui.EnableScreenClicker(false)
			ScreenClicker = false
		end
		its_old = tfablurintensity * 1
	end)
end

--[[
Hook: PreRender
Function: Weapon Logic
Used For: Per-frame weapon "think" logic
]]
--
hook.Add("PreRender", "prerender_tfabase", function()
	if not IsValid(ply) then ply = LocalPlayer() return end
	wep = ply:GetActiveWeapon() or wep

	if IsValid(wep) and wep.IsTFAWeapon and wep.PlayerThinkCL then
		wep:PlayerThinkCL(ply)
	end

	if sp and CLIENT then
		net.Start("tfaSDLP")
		net.WriteBool(ply:ShouldDrawLocalPlayer())
		net.SendToServer()
	end
end)

--[[
Hook: AllowPlayerPickup
Function: Prop holding
Used For: Records last held object
]]
--
hook.Add("AllowPlayerPickup", "TFAPickupDisable", function(plyv, ent)
	plyv:SetNW2Entity("LastHeldEntity", ent)
end)

--[[
Hook: PlayerBindPress
Function: Intercept Keybinds
Used For:  Alternate attack, inspection, shotgun interrupts, and more
]]--

local cv_cm = GetConVar("sv_tfa_cmenu")
local cv_cm_key = GetConVar("sv_tfa_cmenu_key")
local keyv

local function GetInspectionKey()
	if cv_cm_key and cv_cm_key:GetInt() >= 0 then
		keyv = cv_cm_key:GetInt()
	else
		keyv = TFA.BindToKey( input.LookupBinding("+menu_context", true) or "c" , KEY_C )
	end
	return keyv
end

local function TFAContextBlock()
	local plyv = LocalPlayer()
	if not plyv:IsValid() then return end
	if GetViewEntity() ~= plyv then return end
	local wepv = plyv:GetActiveWeapon()
	if not IsValid(wepv) then return end
	if GetInspectionKey() == TFA.BindToKey( input.LookupBinding("+menu_context", true) or "c" , KEY_C ) and wepv.ToggleInspect then
		return false
	end
end

hook.Add("ContextMenuOpen", "TFAContextBlock", TFAContextBlock)

if CLIENT then
	local kd_old = false
	function TFAKPThink()
		local plyv = LocalPlayer()
		if not plyv:IsValid() then return end
		if GetViewEntity() ~= plyv then return end
		local wepv = plyv:GetActiveWeapon()
		if not IsValid(wepv) then return end
		if not wepv.ToggleInspect then return end
		local key = GetInspectionKey()
		local kd = input.IsKeyDown( key )
		if IsValid( vgui.GetKeyboardFocus() ) then kd = false end
		if kd ~= kd_old and kd and cv_cm:GetBool() then
			wepv:ToggleInspect()
		end
		kd_old = kd
	end
	hook.Add("Think", "TFAInspectionMenu", TFAKPThink)
end


--[[
Hook: KeyPress
Function: Allows player to bash
Used For:  Predicted bashing
]]--

local cv_lr = GetConVar("sv_tfa_reloads_legacy")

local function KP_Bash(plyv, key)
	if (key == IN_ZOOM) then
		wep = plyv:GetActiveWeapon()

		if IsValid(wep) and wep.AltAttack then
			wep:AltAttack()
		end
	end
	if (key == IN_RELOAD ) then
		plyv.HasTFAAmmoChek = false
		plyv.LastReloadPressed = CurTime()
	end
end

local reload_threshold = 0.3

hook.Add("KeyPress","TFABase_KP",KP_Bash)

local function KR_Reload(plyv, key)
	if key == IN_RELOAD and cv_lr and ( not cv_lr:GetBool() ) and ( not plyv:KeyDown(IN_USE) ) and CurTime() <= ( plyv.LastReloadPressed or CurTime() ) + reload_threshold then
		plyv.LastReloadPressed = nil
		plyv.HasTFAAmmoChek = false
		wep = plyv:GetActiveWeapon()

		if IsValid(wep) and wep.IsTFAWeapon then
			plyv:GetActiveWeapon():Reload( true )
		end
	end
end

hook.Add("KeyRelease","TFABase_KR",KR_Reload)

local function KD_AmmoCheck(plyv)
	if plyv.HasTFAAmmoChek then return end
	if plyv:KeyDown(IN_RELOAD) and ( not plyv:KeyDown(IN_USE) ) and CurTime() > ( plyv.LastReloadPressed or CurTime() ) + reload_threshold then
		wep = plyv:GetActiveWeapon()

		if IsValid(wep) and wep.IsTFAWeapon then
			plyv.HasTFAAmmoChek = true
			plyv:GetActiveWeapon():CheckAmmo()
		end
	end
end

hook.Add("PlayerTick","TFABase_KD",KD_AmmoCheck)

function TFA.ProcessBashZoom( plyv, wepv )
	if not IsValid(wepv) then
		plyv:SetCanZoom(true)
		return
	end
	if wepv.AltAttack then
		plyv:SetCanZoom(false)
	else
		plyv:SetCanZoom(true)
	end
end

local function PSW_PBZ(plyv,owv,nwv)
	timer.Simple(0,function()
		if IsValid(plyv) then
			TFA.ProcessBashZoom( plyv, plyv:GetActiveWeapon() )
		end
	end)
end

hook.Add("PlayerSwitchWeapon","TFABashFixZoom",PSW_PBZ)

--[[
Hook: PlayerSpawn
Function: Extinguishes players, zoom cleanup
Used For:  Fixes incendiary bullets post-respawn
]]--

hook.Add("PlayerSpawn", "TFAExtinguishQOL", function(plyv)
	if IsValid(plyv) and plyv:IsOnFire() then
		plyv:Extinguish()
		TFA.ProcessBashZoom( plyv, plyv:GetActiveWeapon() )
	end
end)

--[[
Hook: SetupMove
Function: Modify movement speed
Used For:  Weapon slowdown, ironsights slowdown
]]--

local sumwep
local speedmult

hook.Add("SetupMove", "tfa_setupmove", function(plyv, movedata, commanddata)

	sumwep = plyv:GetActiveWeapon() or wep
	if IsValid(sumwep) and sumwep.IsTFAWeapon then
		sumwep.IronSightsProgress = sumwep.IronSightsProgress or 0
		speedmult = Lerp(sumwep.IronSightsProgress, sumwep:GetStat("MoveSpeed"), sumwep:GetStat("IronSightsMoveSpeed"))
		movedata:SetMaxClientSpeed(movedata:GetMaxClientSpeed() * speedmult)
		commanddata:SetForwardMove(commanddata:GetForwardMove() * speedmult)
		commanddata:SetSideMove(commanddata:GetSideMove() * speedmult)
	end
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
