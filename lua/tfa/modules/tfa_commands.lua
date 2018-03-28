--Serverside Convars

if GetConVar("sv_tfa_soundscale") == nil then
	CreateConVar("sv_tfa_soundscale","1",{FCVAR_ARCHIVE,FCVAR_SERVER_CAN_EXECUTE,FCVAR_REPLICATED},"Scale times in accordance to timescale?")
	--print("Weapon strip/removal con var created")
end

if GetConVar("sv_tfa_weapon_strip") == nil then
	CreateConVar("sv_tfa_weapon_strip", "0", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow the removal of empty weapons? 1 for true, 0 for false")
	--print("Weapon strip/removal con var created")
end
if GetConVar("sv_tfa_spread_legacy") == nil then
	CreateConVar("sv_tfa_spread_legacy", "0", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Use legacy spread algorithms?")
	--print("Weapon strip/removal con var created")
end

if GetConVar("sv_tfa_cmenu") == nil then
	CreateConVar("sv_tfa_cmenu", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow custom context menu?")
	--print("Weapon strip/removal con var created")
end

if GetConVar("sv_tfa_cmenu_key") == nil then
	CreateConVar("sv_tfa_cmenu_key", "-1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Override the inspection menu key?  Uses the KEY enum available on the gmod wiki. -1 to not.")
	--print("Weapon strip/removal con var created")
end

if GetConVar("sv_tfa_range_modifier") == nil then
	CreateConVar("sv_tfa_range_modifier", "0.5", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "This controls how much the range affects damage.  0.5 means the maximum loss of damage is 0.5.")
	--print("Dry fire con var created")
end

if GetConVar("sv_tfa_allow_dryfire") == nil then
	CreateConVar("sv_tfa_allow_dryfire", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow dryfire?")
	--print("Dry fire con var created")
end

if GetConVar("sv_tfa_penetration_limit") == nil then
	CreateConVar("sv_tfa_penetration_limit", "2", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Number of objects we can penetrate through.")
	--print("Dry fire con var created")
end

if GetConVar("sv_tfa_penetration_hitmarker") == nil then
	CreateConVar("sv_tfa_penetration_hitmarker", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Should penetrating bullet send hitmarker to attacker?")
end

if GetConVar("sv_tfa_damage_multiplier") == nil then
	CreateConVar("sv_tfa_damage_multiplier", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Multiplier for TFA base projectile damage.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_damage_mult_min") == nil then
	CreateConVar("sv_tfa_damage_mult_min", "0.95", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "This is the lower range of a random damage factor.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_damage_mult_max") == nil then
	CreateConVar("sv_tfa_damage_mult_max", "1.05", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "This is the lower range of a random damage factor.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_melee_damage_npc") == nil then
	CreateConVar("sv_tfa_melee_damage_npc", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Damage multiplier against NPCs using TFA Melees.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_melee_damage_ply") == nil then
	CreateConVar("sv_tfa_melee_damage_ply", "0.65", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Damage multiplier against players using TFA Melees.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_melee_blocking_timed") == nil then
	CreateConVar("sv_tfa_melee_blocking_timed", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable timed blocking?")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_melee_blocking_anglemult") == nil then
	CreateConVar("sv_tfa_melee_blocking_anglemult", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Players can block attacks in an angle around their view.  This multiplies that angle.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_melee_blocking_deflection") == nil then
	CreateConVar("sv_tfa_melee_blocking_deflection", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "For weapons that can deflect bullets ( e.g. certain katans ), can you deflect bullets?  Set to 1 to enable for parries, or 2 for all blocks.")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_melee_blocking_timed") == nil then
	CreateConVar("sv_tfa_melee_blocking_timed", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable timed blocking?")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_melee_blocking_stun_enabled") == nil then
	CreateConVar("sv_tfa_melee_blocking_stun_enabled", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Stun NPCs on block?")
	--print("Damage Multiplier con var created")
end

if GetConVar("sv_tfa_melee_blocking_stun_time") == nil then
	CreateConVar("sv_tfa_melee_blocking_stun_time", "0.65", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How long to stun NPCs on block.")
	--print("Damage Multiplier con var created")
end

cv_dfc = CreateConVar("sv_tfa_default_clip", "-1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many clips will a weapon spawn with? Negative reverts to default values.")

function TFAUpdateDefaultClip()
	local dfc = cv_dfc:GetInt()
	local weplist = weapons.GetList()
	if not weplist or #weplist <= 0 then return end

	for k, v in pairs(weplist) do
		local cl = v.ClassName and v.ClassName or v
		local wep = weapons.GetStored(cl)

		if wep and (wep.IsTFAWeapon or string.find(string.lower(wep.Base and wep.Base or ""), "tfa")) then
			if not wep.Primary then
				wep.Primary = {}
			end

			if not wep.Primary.TrueDefaultClip then
				wep.Primary.TrueDefaultClip = wep.Primary.DefaultClip
			end

			if not wep.Primary.TrueDefaultClip then
				wep.Primary.TrueDefaultClip = 0
			end

			if dfc < 0 then
				wep.Primary.DefaultClip = wep.Primary.TrueDefaultClip
			else
				if wep.Primary.ClipSize and wep.Primary.ClipSize > 0 then
					wep.Primary.DefaultClip = wep.Primary.ClipSize * dfc
				else
					wep.Primary.DefaultClip = wep.Primary.TrueDefaultClip * 1
				end
			end
		end
	end
end

hook.Add("InitPostEntity", "TFADefaultClipPE", TFAUpdateDefaultClip)

if TFAUpdateDefaultClip then
	TFAUpdateDefaultClip()
end

--if GetConVar("sv_tfa_default_clip") == nil then

cvars.AddChangeCallback("sv_tfa_default_clip", function(convar_name, value_old, value_new)
	print("Update Default Clip")
	TFAUpdateDefaultClip()
end, "TFAUpdateDefaultClip")

--print("Default clip size con var created")
--end
if GetConVar("sv_tfa_unique_slots") == nil then
	CreateConVar("sv_tfa_unique_slots", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Give TFA-based Weapons unique slots? 1 for true, 0 for false. RESTART AFTER CHANGING.")
	--print("Unique slot con var created")
end

if GetConVar("sv_tfa_spread_multiplier") == nil then
	CreateConVar("sv_tfa_spread_multiplier", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Increase for more spread, decrease for less.")
	--print("Arrow force con var created")
end

if GetConVar("sv_tfa_force_multiplier") == nil then
	CreateConVar("sv_tfa_force_multiplier", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Arrow force multiplier (not arrow velocity, but how much force they give on impact).")
	--print("Arrow force con var created")
end

if GetConVar("sv_tfa_dynamicaccuracy") == nil then
	CreateConVar("sv_tfa_dynamicaccuracy", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Dynamic acuracy?  (e.g.more accurate on crouch, less accurate on jumping.")
	--print("DynAcc con var created")
end

if GetConVar("sv_tfa_ammo_detonation") == nil then
	CreateConVar("sv_tfa_ammo_detonation", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Ammo Detonation?  (e.g. shoot ammo until it explodes) ")
	--print("DynAcc con var created")
end

if GetConVar("sv_tfa_ammo_detonation_mode") == nil then
	CreateConVar("sv_tfa_ammo_detonation_mode", "2", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Ammo Detonation Mode?  (0=Bullets,1=Blast,2=Mix) ")
	--print("DynAcc con var created")
end

if GetConVar("sv_tfa_ammo_detonation_chain") == nil then
	CreateConVar("sv_tfa_ammo_detonation_chain", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Ammo Detonation Chain?  (0=Ammo boxes don't detonate other ammo boxes, 1 you can chain them together) ")
	--print("DynAcc con var created")
end

if GetConVar("sv_tfa_scope_gun_speed_scale") == nil then
	CreateConVar("sv_tfa_scope_gun_speed_scale", "0", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Scale player sensitivity based on player move speed?")
end

if GetConVar("sv_tfa_bullet_penetration") == nil then
	CreateConVar("sv_tfa_bullet_penetration", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow bullet penetration?")
end

if GetConVar("sv_tfa_bullet_doordestruction") == nil then
	CreateConVar("sv_tfa_bullet_doordestruction", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow players to shoot down doors?")
end

if GetConVar("sv_tfa_bullet_ricochet") == nil then
	CreateConVar("sv_tfa_bullet_ricochet", "0", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow bullet ricochet?")
end

if GetConVar("sv_tfa_holdtype_dynamic") == nil then
	CreateConVar("sv_tfa_holdtype_dynamic", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow dynamic holdtype?")
end

if GetConVar("sv_tfa_arrow_lifetime") == nil then
	CreateConVar("sv_tfa_arrow_lifetime", "30", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Arrow lifetime.")
end

if GetConVar("sv_tfa_arrow_lifetime") == nil then
	CreateConVar("sv_tfa_arrow_lifetime", "30", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Arrow lifetime.")
end

if GetConVar("sv_tfa_worldmodel_culldistance") == nil then
	CreateConVar("sv_tfa_worldmodel_culldistance", "-1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "-1 to leave unculled.  Anything else is feet*16.")
end

if GetConVar("sv_tfa_reloads_legacy") == nil then
	CreateConVar("sv_tfa_reloads_legacy", "0", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "-1 to leave unculled.  Anything else is feet*16.")
end

if GetConVar("sv_tfa_fx_penetration_decal") == nil then
	CreateConVar("sv_tfa_fx_penetration_decal", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable decals on the other side of a penetrated object?")
end

if GetConVar("sv_tfa_ironsights_enabled") == nil then
	CreateConVar("sv_tfa_ironsights_enabled", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable ironsights? Disabling this still allows scopes.")
end

if GetConVar("sv_tfa_sprint_enabled") == nil then
	CreateConVar("sv_tfa_sprint_enabled", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable sprinting? Disabling this allows shooting while IN_SPEED.")
end

if GetConVar("sv_tfa_reloads_enabled") == nil then
	CreateConVar("sv_tfa_reloads_enabled", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Enable reloading? Disabling this allows shooting from ammo pool.")
end

if GetConVar("sv_tfa_attachments_enabled") == nil then
	CreateConVar("sv_tfa_attachments_enabled", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Display attachment picker?")
end

if GetConVar("sv_tfa_attachments_alphabetical") == nil then
	CreateConVar("sv_tfa_attachments_alphabetical", "0", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Override weapon attachment order to be alphabetical.")
end

--Clientside Convars
if CLIENT then
	if GetConVar("cl_tfa_viewbob_intensity") == nil then
		CreateClientConVar("cl_tfa_viewbob_intensity", 1, true, false)
	end

	if GetConVar("cl_tfa_gunbob_intensity") == nil then
		CreateClientConVar("cl_tfa_gunbob_intensity", 1, true, false)
		--print("Viewbob intensity con var created")
	end

	if GetConVar("cl_tfa_viewmodel_viewpunch") == nil then
		CreateClientConVar("cl_tfa_viewmodel_viewpunch", 1, true, false)
	end

	if GetConVar("cl_tfa_3dscope_quality") == nil then
		CreateClientConVar("cl_tfa_3dscope_quality", -1, true, true)
	end
	

	if GetConVar("cl_tfa_3dscope") == nil then
		CreateClientConVar("cl_tfa_3dscope", 1, true, true)
	else
		cvars.RemoveChangeCallback( "cl_tfa_3dscope", "3DScopeEnabledCB" )
	end

	cvars.AddChangeCallback("cl_tfa_3dscope",function(cv,old,new)
		local lply = LocalPlayer()
		if lply:IsValid() and IsValid(lply:GetActiveWeapon()) then
			local wep = lply:GetActiveWeapon()
			if wep.UpdateScopeType then
				wep:UpdateScopeType( true )
			end
		end
	end,"3DScopeEnabledCB")

	if GetConVar("cl_tfa_scope_sensitivity_3d") == nil then
		CreateClientConVar("cl_tfa_scope_sensitivity_3d", 2, true, true) --0 = no sensitivity mod, 1 = scaled to 2D sensitivity, 2 = compensated, 3 = RT FOV compensated
	else
		cvars.RemoveChangeCallback( "cl_tfa_scope_sensitivity_3d", "3DScopeModeCB" )
	end

	cvars.AddChangeCallback("cl_tfa_scope_sensitivity_3d",function(cv,old,new)
		local lply = LocalPlayer()
		if lply:IsValid() and IsValid(lply:GetActiveWeapon()) then
			local wep = lply:GetActiveWeapon()
			if wep.UpdateScopeType then
				wep:UpdateScopeType( true )
			end
		end
	end,"3DScopeModeCB")

	if GetConVar("cl_tfa_3dscope_overlay") == nil then
		CreateClientConVar("cl_tfa_3dscope_overlay", 0, true, true)
	end

	if GetConVar("cl_tfa_scope_sensitivity_autoscale") == nil then
		CreateClientConVar("cl_tfa_scope_sensitivity_autoscale", 100, true, true)
		--print("Scope sensitivity autoscale con var created")
	end

	if GetConVar("cl_tfa_scope_sensitivity") == nil then
		CreateClientConVar("cl_tfa_scope_sensitivity", 100, true, true)
		--print("Scope sensitivity con var created")
	end

	if GetConVar("cl_tfa_ironsights_toggle") == nil then
		CreateClientConVar("cl_tfa_ironsights_toggle", 1, true, true)
		--print("Ironsights toggle con var created")
	end

	if GetConVar("cl_tfa_ironsights_resight") == nil then
		CreateClientConVar("cl_tfa_ironsights_resight", 1, true, true)
		--print("Ironsights resight con var created")
	end

	if GetConVar("cl_tfa_laser_trails") == nil then
		CreateClientConVar("cl_tfa_laser_trails", 1, true, true)
		--print("Laser trails con var created")
	end

	--Crosshair Params
	if GetConVar("cl_tfa_hud_crosshair_length") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_length", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_length_use_pixels") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_length_use_pixels", 0, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_width") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_width", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_enable_custom") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_enable_custom", 1, true, false)
		--print("Custom crosshair con var created")
	end

	if GetConVar("cl_tfa_hud_crosshair_gap_scale") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_gap_scale", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_dot") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_dot", 0, true, false)
	end

	--Crosshair Color
	if GetConVar("cl_tfa_hud_crosshair_color_r") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_r", 225, true, false)
		--print("Crosshair tweaking con vars created")
	end

	if GetConVar("cl_tfa_hud_crosshair_color_g") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_g", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_color_b") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_b", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_color_a") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_a", 200, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_color_team") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_color_team", 1, true, false)
	end

	--Crosshair Outline
	if GetConVar("cl_tfa_hud_crosshair_outline_color_r") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_r", 5, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_color_g") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_g", 5, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_color_b") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_b", 5, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_color_a") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_color_a", 200, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_width") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_width", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_crosshair_outline_enabled") == nil then
		CreateClientConVar("cl_tfa_hud_crosshair_outline_enabled", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_enabled") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_enabled", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_fadetime") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_fadetime", 0.3, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_solidtime") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_solidtime", 0.1, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_scale") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_scale", 1, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_r") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_r", 225, true, false)
		--print("hitmarker tweaking con vars created")
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_g") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_g", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_b") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_b", 225, true, false)
	end

	if GetConVar("cl_tfa_hud_hitmarker_color_a") == nil then
		CreateClientConVar("cl_tfa_hud_hitmarker_color_a", 200, true, false)
	end

	--Other stuff
	if GetConVar("cl_tfa_hud_ammodata_fadein") == nil then
		CreateClientConVar("cl_tfa_hud_ammodata_fadein", 0.2, true, false)
	end

	if GetConVar("cl_tfa_hud_hangtime") == nil then
		CreateClientConVar("cl_tfa_hud_hangtime", 1, true, true)
	end

	if GetConVar("cl_tfa_hud_enabled") == nil then
		CreateClientConVar("cl_tfa_hud_enabled", 1, true, false)
	end

	if GetConVar("cl_tfa_fx_gasblur") == nil then
		CreateClientConVar("cl_tfa_fx_gasblur", 0, true, true)
	end

	if GetConVar("cl_tfa_fx_muzzlesmoke") == nil then
		CreateClientConVar("cl_tfa_fx_muzzlesmoke", 1, true, true)
	end

	if GetConVar("cl_tfa_fx_muzzlesmoke_limited") == nil then
		CreateClientConVar("cl_tfa_fx_muzzlesmoke_limited", 0, true, true)
	end
	
	if GetConVar("cl_tfa_legacy_shells") == nil then
		CreateClientConVar("cl_tfa_legacy_shells", 0, true, true)
	end

	if GetConVar("cl_tfa_fx_ejectionsmoke") == nil then
		CreateClientConVar("cl_tfa_fx_ejectionsmoke", 1, true, true)
	end

	if GetConVar("cl_tfa_fx_ejectionlife") == nil then
		CreateClientConVar("cl_tfa_fx_ejectionlife", 15, true, true)
	end

	if GetConVar("cl_tfa_fx_impact_enabled") == nil then
		CreateClientConVar("cl_tfa_fx_impact_enabled", 1, true, true)
	end

	if GetConVar("cl_tfa_fx_impact_ricochet_enabled") == nil then
		CreateClientConVar("cl_tfa_fx_impact_ricochet_enabled", 1, true, true)
	end

	if GetConVar("cl_tfa_fx_impact_ricochet_sparks") == nil then
		CreateClientConVar("cl_tfa_fx_impact_ricochet_sparks", 6, true, true)
	end

	if GetConVar("cl_tfa_fx_impact_ricochet_sparklife") == nil then
		CreateClientConVar("cl_tfa_fx_impact_ricochet_sparklife", 2, true, true)
	end

	--viewbob

	if GetConVar("cl_tfa_viewbob_animated") == nil then
		CreateClientConVar("cl_tfa_viewbob_animated", 1, true, false)
	end

	--Viewmodel Mods
	if GetConVar("cl_tfa_viewmodel_offset_x") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_x", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_offset_y") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_y", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_offset_z") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_z", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_offset_fov") == nil then
		CreateClientConVar("cl_tfa_viewmodel_offset_fov", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_multiplier_fov") == nil then
		CreateClientConVar("cl_tfa_viewmodel_multiplier_fov", 1, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_flip") == nil then
		CreateClientConVar("cl_tfa_viewmodel_flip", 0, true, false)
	end

	if GetConVar("cl_tfa_viewmodel_centered") == nil then
		CreateClientConVar("cl_tfa_viewmodel_centered", 0, true, false)
	end

	if GetConVar("cl_tfa_debug_crosshair") == nil then
		CreateClientConVar("cl_tfa_debug_crosshair", 0, false, false)
	end

	if GetConVar("cl_tfa_debug_rt") == nil then
		CreateClientConVar("cl_tfa_debug_rt", 0, false, false)
	end

	if GetConVar("cl_tfa_debug_cache") == nil then
		CreateClientConVar("cl_tfa_debug_cache", 0, false, false)
	end

	--Reticule Color
	if GetConVar("cl_tfa_reticule_color_r") == nil then
		CreateClientConVar("cl_tfa_reticule_color_r", 255, true, true)
		--print("Reticule tweaking con vars created")
	end

	if GetConVar("cl_tfa_reticule_color_g") == nil then
		CreateClientConVar("cl_tfa_reticule_color_g", 100, true, true)
	end

	if GetConVar("cl_tfa_reticule_color_b") == nil then
		CreateClientConVar("cl_tfa_reticule_color_b", 0, true, true)
	end

	--Laser Color
	if GetConVar("cl_tfa_laser_color_r") == nil then
		CreateClientConVar("cl_tfa_laser_color_r", 255, true, true)
		--print("Laser tweaking con vars created")
	end

	if GetConVar("cl_tfa_laser_color_g") == nil then
		CreateClientConVar("cl_tfa_laser_color_g", 0, true, true)
	end

	if GetConVar("cl_tfa_laser_color_b") == nil then
		CreateClientConVar("cl_tfa_laser_color_b", 0, true, true)
	end
	
end
