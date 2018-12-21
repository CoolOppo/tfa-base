
-- Copyright (c) 2018 TFA Base Devs

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

--Config GUI
if CLIENT then
	language.Add("tfa3dsm.label", "3D Scope Sensitivity Mode")
	language.Add("tfa3dsm.nc", "0 - No Compensation")
	language.Add("tfa3dsm.sc", "1 - Standard Compensation")
	language.Add("tfa3dsm.3d", "2 - 3D Compensation")
	language.Add("tfa3dsm.rt", "3 - RT FOV Compensation")
	language.Add("tfa3dsq.label", "3D Scope Quality")
	language.Add("tfa3dsq.at", "-1 - Autodetected")
	language.Add("tfa3dsq.ul", "0 - Ultra (2048x)")
	language.Add("tfa3dsq.hq", "1 - High (1024x)")
	language.Add("tfa3dsq.mq", "2 - Medium (512x)")
	language.Add("tfa3dsq.lq", "3 - Low (256x)")
	language.Add("tfa3dsb.label", "3D Scope Blur Mode")
	language.Add("tfa3dsb.nb", "0 - No Blur")
	language.Add("tfa3dsb.sb", "1 - Standard Blur")
	language.Add("tfa3dsb.bb", "2 - Bokeh Blur")
	language.Add("tfabaltra.di", "0 - Disabled")
	language.Add("tfabaltra.sm", "1 - Smokey")
	language.Add("tfabaltra.re", "2 - Bright Red")

	local function tfaOptionServer(panel)
		--Here are whatever default categories you want.
		local tfaOptionSV = {
			Options = {},
			CVars = {},
			Label = "#Presets",
			MenuButton = "1",
			Folder = "TFA SWEP Settings Server"
		}

		tfaOptionSV.Options["#Default"] = {
			sv_tfa_ironsights_enabled = "1",
			sv_tfa_sprint_enabled = "1",
			sv_tfa_weapon_strip = "0",
			sv_tfa_allow_dryfire = "1",
			sv_tfa_damage_multiplier = "1",
			sv_tfa_default_clip = "-1",
			sv_tfa_arrow_lifetime = "30",
			sv_tfa_force_multiplier = "1",
			sv_tfa_dynamicaccuracy = "1",
			sv_tfa_range_modifier = "0.5",
			sv_tfa_spread_multiplier = "1",
			sv_tfa_bullet_penetration = "1",
			sv_tfa_bullet_ricochet = "0",
			sv_tfa_bullet_doordestruction = "1",
			sv_tfa_reloads_legacy = "0",
			sv_tfa_reloads_enabled = "1",
			sv_tfa_cmenu = "1",
			sv_tfa_penetration_limit = "2",
			sv_tfa_jamming = "1",
			sv_tfa_jamming_mult = "1",
			sv_tfa_jamming_factor = "1",
			sv_tfa_jamming_factor_inc = "1",
			sv_tfa_door_respawn = "-1"
		}

		panel:AddControl("ComboBox", tfaOptionSV)

		--These are the panel controls.  Adding these means that you don't have to go into the console.
		panel:AddControl("CheckBox", {
			Label = "Require reload keypress",
			Command = "sv_tfa_allow_dryfire"
		})

		panel:AddControl("CheckBox", {
			Label = "Dynamic Accuracy",
			Command = "sv_tfa_dynamicaccuracy"
		})

		panel:AddControl("CheckBox", {
			Label = "Strip Empty Weapons",
			Command = "sv_tfa_weapon_strip"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Ironsights",
			Command = "sv_tfa_ironsights_enabled"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Modern-Stlye Sprinting",
			Command = "sv_tfa_sprint_enabled"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Custom C-Menu",
			Command = "sv_tfa_cmenu"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Bullet Penetration",
			Command = "sv_tfa_bullet_penetration"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Bullet Ricochet",
			Command = "sv_tfa_bullet_ricochet"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Bullet Door Destruction",
			Command = "sv_tfa_bullet_doordestruction"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Reloading",
			Command = "sv_tfa_reloads_enabled"
		})

		panel:AddControl("CheckBox", {
			Label = "If weapon support jamming, allow to jam",
			Command = "sv_tfa_jamming"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable nearly-empty sounds",
			Command = "sv_tfa_nearlyempty"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Legacy-Style Reloading",
			Command = "sv_tfa_reloads_legacy"
		})

		panel:AddControl("Slider", {
			Label = "Damage Multiplier",
			Command = "sv_tfa_damage_multiplier",
			Type = "Float",
			Min = "0",
			Max = "5"
		})

		panel:AddControl("Slider", {
			Label = "Door Respawn Time",
			Command = "sv_tfa_door_respawn",
			Type = "Integer",
			Min = "-1",
			Max = "120"
		})

		panel:NumSlider("Jam chance multiplier", "sv_tfa_jamming_mult", 0.01, 10, 2)
		panel:NumSlider("Jam factor multiplier", "sv_tfa_jamming_factor", 0.01, 10, 2)
		panel:NumSlider("Jam factor increase multiplier", "sv_tfa_jamming_factor_inc", 0.01, 10, 2)

		panel:AddControl("Slider", {
			Label = "Impact Force Multiplier",
			Command = "sv_tfa_force_multiplier",
			Type = "Float",
			Min = "0",
			Max = "5"
		})

		panel:AddControl("Slider", {
			Label = "Spread Multiplier",
			Command = "sv_tfa_spread_multiplier",
			Type = "Float",
			Min = "0",
			Max = "5"
		})

		panel:AddControl("Slider", {
			Label = "Penetration Count Limit",
			Command = "sv_tfa_penetration_limit",
			Type = "Integer",
			Min = "0",
			Max = "5"
		})

		panel:AddControl("Slider", {
			Label = "Default Clip Count (-1 = default)",
			Command = "sv_tfa_default_clip",
			Type = "Integer",
			Min = "-1",
			Max = "10"
		})

		panel:AddControl("Slider", {
			Label = "Bullet Range Damage Degredation",
			Command = "sv_tfa_range_modifier",
			Type = "Float",
			Min = "0",
			Max = "1"
		})

		panel:AddControl("Label", {
			Text = "By TheForgottenArchitect"
		})
	end

	local function tfaOptionSights(panel)
		--Here are whatever default categories you want.
		local tfaOptionCL = {
			Options = {},
			CVars = {},
			Label = "#Presets",
			MenuButton = "1",
			Folder = "TFA SWEP Settings Client"
		}

		tfaOptionCL.Options["#Default"] = {
			cl_tfa_3dscope = "1",
			cl_tfa_3dscope_overlay = "1",
			cl_tfa_3dscope_quality = "-1",
			cl_tfa_fx_rtscopeblur_passes = "3",
			cl_tfa_fx_rtscopeblur_intensity = "4",
			cl_tfa_fx_rtscopeblur_mode = "1",
			cl_tfa_scope_sensitivity_3d = "2",
			cl_tfa_scope_sensitivity_autoscale = "1",
			cl_tfa_scope_sensitivity = "100",
			cl_tfa_ironsights_toggle = "0",
			cl_tfa_ironsights_resight = "1"
		}

		panel:AddControl("ComboBox", tfaOptionCL)

		--These are the panel controls.  Adding these means that you don't have to go into the console.
		panel:AddControl("CheckBox", {
			Label = "Enable 3D Scopes",
			Command = "cl_tfa_3dscope"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable 3D Scope Shadows",
			Command = "cl_tfa_3dscope_overlay"
		})

		local tfaOption3DSM = {
			Options = {},
			CVars = {},
			Label = "#tfa3dsm.label",
			MenuButton = "0",
			Folder = "TFA 3D Scope Sens."
		}

		tfaOption3DSM.Options["#tfa3dsm.nc"] = {
			cl_tfa_scope_sensitivity_3d = "0"
		}

		tfaOption3DSM.Options["#tfa3dsm.nc"] = {
			cl_tfa_scope_sensitivity_3d = "0"
		}

		tfaOption3DSM.Options["#tfa3dsm.sc"] = {
			cl_tfa_scope_sensitivity_3d = "1"
		}

		tfaOption3DSM.Options["#tfa3dsm.3d"] = {
			cl_tfa_scope_sensitivity_3d = "2"
		}

		tfaOption3DSM.Options["#tfa3dsm.rt"] = {
			cl_tfa_scope_sensitivity_3d = "3"
		}

		tfaOption3DSM.CVars = table.GetKeys(tfaOption3DSM.Options["#tfa3dsm.3d"])
		panel:AddControl("ComboBox", tfaOption3DSM)

		local tfaOption3DSQ = {
			Options = {},
			CVars = {},
			Label = "#tfa3dsq.label",
			MenuButton = "0",
			Folder = "TFA 3D Scope Sens."
		}

		tfaOption3DSQ.Options["#tfa3dsq.at"] = {
			cl_tfa_3dscope_quality = "-1"
		}

		tfaOption3DSQ.Options["#tfa3dsq.ul"] = {
			cl_tfa_3dscope_quality = "0"
		}

		tfaOption3DSQ.Options["#tfa3dsq.hq"] = {
			cl_tfa_3dscope_quality = "1"
		}

		tfaOption3DSQ.Options["#tfa3dsq.mq"] = {
			cl_tfa_3dscope_quality = "2"
		}

		tfaOption3DSQ.Options["#tfa3dsq.lq"] = {
			cl_tfa_3dscope_quality = "3"
		}

		tfaOption3DSQ.CVars = table.GetKeys(tfaOption3DSQ.Options["#tfa3dsq.ul"])
		panel:AddControl("ComboBox", tfaOption3DSQ)

		local tfaOption3DSB = {
			Options = {},
			CVars = {},
			Label = "#tfa3dsb.label",
			MenuButton = "0",
			Folder = "TFA 3D Scope Blur."
		}

		tfaOption3DSB.Options["#tfa3dsb.nb"] = {
			cl_tfa_fx_rtscopeblur_mode = "0"
		}

		tfaOption3DSB.Options["#tfa3dsb.sb"] = {
			cl_tfa_fx_rtscopeblur_mode = "1"
		}

		tfaOption3DSB.Options["#tfa3dsb.bb"] = {
			cl_tfa_fx_rtscopeblur_mode = "2"
		}

		tfaOption3DSB.CVars = table.GetKeys(tfaOption3DSB.Options["#tfa3dsb.bb"])
		panel:AddControl("ComboBox", tfaOption3DSB)

		panel:AddControl("Slider", {
			Label = "Scope Blur Quality",
			Command = "cl_tfa_fx_rtscopeblur_passes",
			Type = "Integer",
			Min = "1",
			Max = "5"
		})

		panel:AddControl("Slider", {
			Label = "Scope Blur Strength",
			Command = "cl_tfa_fx_rtscopeblur_intensity",
			Type = "Float",
			Min = "0.01",
			Max = "10"
		})

		panel:AddControl("CheckBox", {
			Label = "Toggle Ironsights",
			Command = "cl_tfa_ironsights_toggle"
		})

		panel:AddControl("CheckBox", {
			Label = "Preserve Sights On Reload, Sprint, etc.",
			Command = "cl_tfa_ironsights_resight"
		})

		panel:AddControl("CheckBox", {
			Label = "Compensate Sensitivity for FOV",
			Command = "cl_tfa_scope_sensitivity_autoscale"
		})

		panel:AddControl("Slider", {
			Label = "Scope Sensitivity",
			Command = "cl_tfa_scope_sensitivity",
			Type = "Integer",
			Min = "1",
			Max = "100"
		})

		panel:AddControl("Label", {
			Text = "By TheForgottenArchitect"
		})
	end

	local function tfaOptionVM(panel)
		--Here are whatever default categories you want.
		local tfaOptionCL = {
			Options = {},
			CVars = {},
			Label = "#Presets",
			MenuButton = "1",
			Folder = "TFA SWEP Settings Client"
		}

		tfaOptionCL.Options["#Default"] = {
			cl_tfa_viewbob_animated = "0",
			cl_tfa_gunbob_intensity = "1",
			cl_tfa_viewmodel_viewpunch = "1",
			cl_tfa_viewbob_intensity = "1",
			cl_tfa_viewmodel_offset_x = "0",
			cl_tfa_viewmodel_offset_y = "0",
			cl_tfa_viewmodel_offset_z = "0",
			cl_tfa_viewmodel_offset_fov = "0",
			cl_tfa_viewmodel_flip = "0",
			cl_tfa_viewmodel_centered = "0",
			cl_tfa_viewmodel_nearwall = "1",
			cl_tfa_laser_trails = "1"
		}

		panel:AddControl("ComboBox", tfaOptionCL)

		--These are the panel controls.  Adding these means that you don't have to go into the console.
		panel:AddControl("CheckBox", {
			Label = "Use Animated Viewbob",
			Command = "cl_tfa_viewbob_animated"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Viewmodel Viewpunch",
			Command = "cl_tfa_viewmodel_viewpunch"
		})

		panel:AddControl("Slider", {
			Label = "Gun Bob Intensity",
			Command = "cl_tfa_gunbob_intensity",
			Type = "Float",
			Min = "0",
			Max = "2"
		})

		panel:AddControl("Slider", {
			Label = "View Bob Intensity",
			Command = "cl_tfa_viewbob_intensity",
			Type = "Float",
			Min = "0",
			Max = "2"
		})

		panel:AddControl("Slider", {
			Label = "Viemodel Offset - X",
			Command = "cl_tfa_viewmodel_offset_x",
			Type = "Float",
			Min = "-2",
			Max = "2"
		})

		panel:AddControl("Slider", {
			Label = "Viemodel Offset - Y",
			Command = "cl_tfa_viewmodel_offset_y",
			Type = "Float",
			Min = "-2",
			Max = "2"
		})

		panel:AddControl("Slider", {
			Label = "Viemodel Offset - Z",
			Command = "cl_tfa_viewmodel_offset_z",
			Type = "Float",
			Min = "-2",
			Max = "2"
		})

		panel:AddControl("Slider", {
			Label = "Viemodel Offset - FOV",
			Command = "cl_tfa_viewmodel_offset_fov",
			Type = "Float",
			Min = "-5",
			Max = "5"
		})

		panel:AddControl("CheckBox", {
			Label = "Centered Viewmodel",
			Command = "cl_tfa_viewmodel_centered"
		})

		panel:AddControl("CheckBox", {
			Label = "Near Wall Viewmodel Offset",
			Command = "cl_tfa_viewmodel_nearwall"
		})

		panel:AddControl("CheckBox", {
			Label = "Laser Dot Trails",
			Command = "cl_tfa_laser_trails"
		})

		panel:AddControl("CheckBox", {
			Label = "Left Handed Viewmodel (Buggy)",
			Command = "cl_tfa_viewmodel_flip"
		})

		panel:AddControl("Label", {
			Text = "By TheForgottenArchitect"
		})
	end

	local function tfaOptionPerformance(panel)
		--Here are whatever default categories you want.
		local tfaOptionPerf = {
			Options = {},
			CVars = {},
			Label = "#Presets",
			MenuButton = "1",
			Folder = "TFA SWEP Settings Performance"
		}

		tfaOptionPerf.Options["#Default"] = {
			sv_tfa_fx_penetration_decal = "1",
			cl_tfa_fx_impact_enabled = "1",
			cl_tfa_fx_impact_ricochet_enabled = "1",
			cl_tfa_fx_impact_ricochet_sparks = "20",
			cl_tfa_fx_impact_ricochet_sparklife = "2",
			cl_tfa_fx_gasblur = "1",
			cl_tfa_fx_muzzlesmoke = "1",
			cl_tfa_fx_muzzlesmoke_limited = "1",
			cl_tfa_inspection_bokeh = "0",
			cl_tfa_fx_ejectionlife = "15",
			cl_tfa_legacy_shells = "0",
			cl_tfa_fx_ads_dof = "0",
			cl_tfa_fx_ads_dof_hd = "0"
		}

		panel:AddControl("ComboBox", tfaOptionPerf)

		panel:AddControl("CheckBox", {
			Label = "Use Gas Blur",
			Command = "cl_tfa_fx_gasblur"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Muzzle Smoke Trails",
			Command = "cl_tfa_fx_muzzlesmoke"
		})

		panel:AddControl("CheckBox", {
			Label = "Limit Muzzle Smoke Trails",
			Command = "cl_tfa_fx_muzzlesmoke_limited"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Ejection Smoke",
			Command = "cl_tfa_fx_ejectionsmoke"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Custom Impact FX",
			Command = "cl_tfa_fx_impact_enabled"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Ricochet FX",
			Command = "cl_tfa_fx_impact_ricochet_enabled"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Inspection BokehDOF",
			Command = "cl_tfa_inspection_bokeh"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Legacy Shell-Ejection",
			Command = "cl_tfa_legacy_shells"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Iron Sights DoF",
			Command = "cl_tfa_fx_ads_dof"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable true DoF",
			Command = "cl_tfa_fx_ads_dof_hd"
		})

		panel:AddControl("Slider", {
			Label = "Ejected Shell Life",
			Command = "cl_tfa_fx_ejectionlife",
			Type = "Integer",
			Min = "0",
			Max = "60"
		})

		panel:AddControl("Slider", {
			Label = "Ricochet Spark Amount",
			Command = "cl_tfa_fx_impact_ricochet_sparks",
			Type = "Integer",
			Min = "0",
			Max = "50"
		})

		panel:AddControl("Slider", {
			Label = "Ricochet Spark Life",
			Command = "cl_tfa_fx_impact_ricochet_sparklife",
			Type = "Float",
			Min = "0",
			Max = "5"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Penetration Decal (SV)",
			Command = "sv_tfa_fx_penetration_decal"
		})

		panel:AddControl("Label", {
			Text = "By TheForgottenArchitect"
		})
	end

	local function tfaOptionHUD(panel)
		--Here are whatever default categories you want.
		local tfaTBLOptionHUD = {
			Options = {},
			CVars = {},
			Label = "#Presets",
			MenuButton = "1",
			Folder = "TFA SWEP Settings HUD"
		}

		tfaTBLOptionHUD.Options["#Default"] = {
			cl_tfa_hud_crosshair_enable_custom = "1",
			cl_tfa_hud_crosshair_color_r = "225",
			cl_tfa_hud_crosshair_color_g = "225",
			cl_tfa_hud_crosshair_color_b = "225",
			cl_tfa_hud_crosshair_color_a = "225",
			cl_tfa_hud_crosshair_color_team = "1",
			cl_tfa_hud_crosshair_outline_color_r = "5",
			cl_tfa_hud_crosshair_outline_color_g = "5",
			cl_tfa_hud_crosshair_outline_color_b = "5",
			cl_tfa_hud_crosshair_outline_color_a = "225",
			cl_tfa_hud_enabled = "1",
			cl_tfa_hud_ammodata_fadein = "0.2",
			cl_tfa_hud_hangtime = "1",
			cl_tfa_hud_crosshair_length_use_pixels = "0",
			cl_tfa_hud_crosshair_length = "1",
			cl_tfa_hud_crosshair_width = "1",
			cl_tfa_hud_crosshair_gap_scale = "1",
			cl_tfa_hud_crosshair_outline_enabled = "1",
			cl_tfa_hud_crosshair_outline_width = "1",
			cl_tfa_hud_crosshair_dot = "0",
			cl_tfa_hud_hitmarker_enabled = "1",
			cl_tfa_hud_hitmarker_3d_all = "0",
			cl_tfa_hud_hitmarker_3d_shotguns = "1",
			cl_tfa_hud_hitmarker_solidtime = "0.1",
			cl_tfa_hud_hitmarker_fadetime = "0.3",
			cl_tfa_hud_hitmarker_scale = "1",
			cl_tfa_hud_hitmarker_color_r = "225",
			cl_tfa_hud_hitmarker_color_g = "225",
			cl_tfa_hud_hitmarker_color_b = "225",
			cl_tfa_hud_hitmarker_color_a = "225"
		}

		tfaTBLOptionHUD.Options["Cross"] = {
			cl_tfa_hud_crosshair_enable_custom = "1",
			cl_tfa_hud_crosshair_color_r = "255",
			cl_tfa_hud_crosshair_color_g = "255",
			cl_tfa_hud_crosshair_color_b = "255",
			cl_tfa_hud_crosshair_color_a = "200",
			cl_tfa_hud_crosshair_color_team = "1",
			cl_tfa_hud_crosshair_outline_color_r = "154",
			cl_tfa_hud_crosshair_outline_color_g = "152",
			cl_tfa_hud_crosshair_outline_color_b = "175",
			cl_tfa_hud_crosshair_outline_color_a = "255",
			cl_tfa_hud_enabled = "1",
			cl_tfa_hud_ammodata_fadein = "0.2",
			cl_tfa_hud_hangtime = "1",
			cl_tfa_hud_crosshair_length_use_pixels = "0",
			cl_tfa_hud_crosshair_length = "0.75",
			cl_tfa_hud_crosshair_width = "1",
			cl_tfa_hud_crosshair_gap_scale = "0",
			cl_tfa_hud_crosshair_outline_enabled = "1",
			cl_tfa_hud_crosshair_outline_width = "1",
			cl_tfa_hud_crosshair_dot = "0",
			cl_tfa_hud_hitmarker_enabled = "1",
			cl_tfa_hud_hitmarker_3d_all = "0",
			cl_tfa_hud_hitmarker_3d_shotguns = "1",
			cl_tfa_hud_hitmarker_solidtime = "0.1",
			cl_tfa_hud_hitmarker_fadetime = "0.3",
			cl_tfa_hud_hitmarker_scale = "1",
			cl_tfa_hud_hitmarker_color_r = "225",
			cl_tfa_hud_hitmarker_color_g = "225",
			cl_tfa_hud_hitmarker_color_b = "225",
			cl_tfa_hud_hitmarker_color_a = "225"
		}

		tfaTBLOptionHUD.Options["Dot/Minimalist"] = {
			cl_tfa_hud_crosshair_enable_custom = "1",
			cl_tfa_hud_crosshair_color_r = "72",
			cl_tfa_hud_crosshair_color_g = "72",
			cl_tfa_hud_crosshair_color_b = "72",
			cl_tfa_hud_crosshair_color_a = "85",
			cl_tfa_hud_crosshair_color_team = "1",
			cl_tfa_hud_crosshair_outline_color_r = "225",
			cl_tfa_hud_crosshair_outline_color_g = "225",
			cl_tfa_hud_crosshair_outline_color_b = "225",
			cl_tfa_hud_crosshair_outline_color_a = "85",
			cl_tfa_hud_enabled = "1",
			cl_tfa_hud_ammodata_fadein = "0.1",
			cl_tfa_hud_hangtime = "0.5",
			cl_tfa_hud_crosshair_length_use_pixels = "0",
			cl_tfa_hud_crosshair_length = "0",
			cl_tfa_hud_crosshair_width = "1",
			cl_tfa_hud_crosshair_gap_scale = "0",
			cl_tfa_hud_crosshair_outline_enabled = "1",
			cl_tfa_hud_crosshair_outline_width = "1",
			cl_tfa_hud_crosshair_dot = "0",
			cl_tfa_hud_hitmarker_enabled = "0",
			cl_tfa_hud_hitmarker_3d_all = "0",
			cl_tfa_hud_hitmarker_3d_shotguns = "0",
			cl_tfa_hud_hitmarker_solidtime = "0.1",
			cl_tfa_hud_hitmarker_fadetime = "0.3",
			cl_tfa_hud_hitmarker_scale = "1",
			cl_tfa_hud_hitmarker_color_r = "225",
			cl_tfa_hud_hitmarker_color_g = "225",
			cl_tfa_hud_hitmarker_color_b = "225",
			cl_tfa_hud_hitmarker_color_a = "225"
		}

		tfaTBLOptionHUD.Options["Rockstar/GTAV/MP3"] = {
			cl_tfa_hud_crosshair_enable_custom = "1",
			cl_tfa_hud_crosshair_color_r = "225",
			cl_tfa_hud_crosshair_color_g = "225",
			cl_tfa_hud_crosshair_color_b = "225",
			cl_tfa_hud_crosshair_color_a = "85",
			cl_tfa_hud_crosshair_color_team = "1",
			cl_tfa_hud_crosshair_outline_color_r = "30",
			cl_tfa_hud_crosshair_outline_color_g = "30",
			cl_tfa_hud_crosshair_outline_color_b = "30",
			cl_tfa_hud_crosshair_outline_color_a = "85",
			cl_tfa_hud_enabled = "1",
			cl_tfa_hud_ammodata_fadein = "0.1",
			cl_tfa_hud_hangtime = "0.5",
			cl_tfa_hud_crosshair_length_use_pixels = "0",
			cl_tfa_hud_crosshair_length = "0",
			cl_tfa_hud_crosshair_width = "2",
			cl_tfa_hud_crosshair_gap_scale = "0",
			cl_tfa_hud_crosshair_outline_enabled = "1",
			cl_tfa_hud_crosshair_outline_width = "1",
			cl_tfa_hud_crosshair_dot = "0",
			cl_tfa_hud_hitmarker_enabled = "1",
			cl_tfa_hud_hitmarker_3d_all = "0",
			cl_tfa_hud_hitmarker_3d_shotguns = "0",
			cl_tfa_hud_hitmarker_solidtime = "0.1",
			cl_tfa_hud_hitmarker_fadetime = "0.3",
			cl_tfa_hud_hitmarker_scale = "1",
			cl_tfa_hud_hitmarker_color_r = "225",
			cl_tfa_hud_hitmarker_color_g = "225",
			cl_tfa_hud_hitmarker_color_b = "225",
			cl_tfa_hud_hitmarker_color_a = "8"
		}

		tfaTBLOptionHUD.Options["Half Life 2"] = {
			cl_tfa_hud_crosshair_enable_custom = "0",
			cl_tfa_hud_crosshair_color_r = "255",
			cl_tfa_hud_crosshair_color_g = "255",
			cl_tfa_hud_crosshair_color_b = "255",
			cl_tfa_hud_crosshair_color_a = "225",
			cl_tfa_hud_crosshair_color_team = "1",
			cl_tfa_hud_crosshair_outline_color_r = "5",
			cl_tfa_hud_crosshair_outline_color_g = "5",
			cl_tfa_hud_crosshair_outline_color_b = "5",
			cl_tfa_hud_crosshair_outline_color_a = "0",
			cl_tfa_hud_enabled = "0",
			cl_tfa_hud_ammodata_fadein = "0.01",
			cl_tfa_hud_hangtime = "0",
			cl_tfa_hud_crosshair_length_use_pixels = "1",
			cl_tfa_hud_crosshair_length = "0.5",
			cl_tfa_hud_crosshair_width = "1",
			cl_tfa_hud_crosshair_gap_scale = "1",
			cl_tfa_hud_crosshair_outline_enabled = "0",
			cl_tfa_hud_crosshair_outline_width = "0",
			cl_tfa_hud_crosshair_dot = "1",
			cl_tfa_hud_hitmarker_enabled = "0",
			cl_tfa_hud_hitmarker_3d_all = "0",
			cl_tfa_hud_hitmarker_3d_shotguns = "0",
			cl_tfa_hud_hitmarker_solidtime = "0.1",
			cl_tfa_hud_hitmarker_fadetime = "0.3",
			cl_tfa_hud_hitmarker_scale = "1",
			cl_tfa_hud_hitmarker_color_r = "225",
			cl_tfa_hud_hitmarker_color_g = "225",
			cl_tfa_hud_hitmarker_color_b = "225",
			cl_tfa_hud_hitmarker_color_a = "225"
		}

		tfaTBLOptionHUD.Options["Half Life 2 Enhanced"] = {
			cl_tfa_hud_crosshair_enable_custom = "1",
			cl_tfa_hud_crosshair_color_r = "255",
			cl_tfa_hud_crosshair_color_g = "255",
			cl_tfa_hud_crosshair_color_b = "255",
			cl_tfa_hud_crosshair_color_a = "225",
			cl_tfa_hud_crosshair_color_team = "1",
			cl_tfa_hud_crosshair_outline_color_r = "5",
			cl_tfa_hud_crosshair_outline_color_g = "5",
			cl_tfa_hud_crosshair_outline_color_b = "5",
			cl_tfa_hud_crosshair_outline_color_a = "0",
			cl_tfa_hud_enabled = "1",
			cl_tfa_hud_ammodata_fadein = "0.2",
			cl_tfa_hud_hangtime = "1",
			cl_tfa_hud_crosshair_length_use_pixels = "1",
			cl_tfa_hud_crosshair_length = "0.5",
			cl_tfa_hud_crosshair_width = "1",
			cl_tfa_hud_crosshair_gap_scale = "1",
			cl_tfa_hud_crosshair_outline_enabled = "0",
			cl_tfa_hud_crosshair_outline_width = "0",
			cl_tfa_hud_crosshair_dot = "1",
			cl_tfa_hud_hitmarker_enabled = "1",
			cl_tfa_hud_hitmarker_3d_all = "0",
			cl_tfa_hud_hitmarker_3d_shotguns = "1",
			cl_tfa_hud_hitmarker_solidtime = "0.1",
			cl_tfa_hud_hitmarker_fadetime = "0.3",
			cl_tfa_hud_hitmarker_scale = "1",
			cl_tfa_hud_hitmarker_color_r = "225",
			cl_tfa_hud_hitmarker_color_g = "225",
			cl_tfa_hud_hitmarker_color_b = "225",
			cl_tfa_hud_hitmarker_color_a = "225"
		}

		panel:AddControl("ComboBox", tfaTBLOptionHUD)

		--These are the panel controls.  Adding these means that you don't have to go into the console.
		panel:AddControl("CheckBox", {
			Label = "Use Custom HUD",
			Command = "cl_tfa_hud_enabled"
		})

		panel:AddControl("Slider", {
			Label = "Ammo HUD Fadein Time",
			Command = "cl_tfa_hud_ammodata_fadein",
			Type = "Float",
			Min = "0.01",
			Max = "1"
		})

		panel:AddControl("Slider", {
			Label = "HUD Hang Time (after a reload, etc.)",
			Command = "cl_tfa_hud_hangtime",
			Type = "Float",
			Min = "0",
			Max = "5"
		})

		panel:AddControl("Label", {
			Text = "-Crosshair Options-"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Custom Crosshair",
			Command = "cl_tfa_hud_crosshair_enable_custom"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Crosshair Dot",
			Command = "cl_tfa_hud_crosshair_dot"
		})

		panel:AddControl("CheckBox", {
			Label = "Crosshair Length In Pixels?",
			Command = "cl_tfa_hud_crosshair_length_use_pixels"
		})

		panel:AddControl("Slider", {
			Label = "Crosshair Length",
			Command = "cl_tfa_hud_crosshair_length",
			Type = "Float",
			Min = "0",
			Max = "10"
		})

		panel:AddControl("Slider", {
			Label = "Crosshair Gap Scale",
			Command = "cl_tfa_hud_crosshair_gap_scale",
			Type = "Float",
			Min = "0",
			Max = "2"
		})

		panel:AddControl("Slider", {
			Label = "Crosshair Width",
			Command = "cl_tfa_hud_crosshair_width",
			Type = "Integer",
			Min = "0",
			Max = "3"
		})

		panel:AddControl("Color", {
			Label = "Crosshair Color",
			Red = "cl_tfa_hud_crosshair_color_r",
			Green = "cl_tfa_hud_crosshair_color_g",
			Blue = "cl_tfa_hud_crosshair_color_b",
			Alpha = "cl_tfa_hud_crosshair_color_a",
			ShowHSV = 1,
			ShowRGB = 1,
			Multiplier = 255
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Crosshair Teamcolor",
			Command = "cl_tfa_hud_crosshair_color_team"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Crosshair Outline",
			Command = "cl_tfa_hud_crosshair_outline_enabled"
		})

		panel:AddControl("Slider", {
			Label = "Crosshair Outline Width",
			Command = "cl_tfa_hud_crosshair_outline_width",
			Type = "Integer",
			Min = "0",
			Max = "3"
		})

		panel:AddControl("Color", {
			Label = "Crosshair Outline Color",
			Red = "cl_tfa_hud_crosshair_outline_color_r",
			Green = "cl_tfa_hud_crosshair_outline_color_g",
			Blue = "cl_tfa_hud_crosshair_outline_color_b",
			Alpha = "cl_tfa_hud_crosshair_outline_color_a",
			ShowHSV = 1,
			ShowRGB = 1,
			Multiplier = 255
		})

		panel:AddControl("CheckBox", {
			Label = "Enable Hitmarker",
			Command = "cl_tfa_hud_hitmarker_enabled"
		})

		panel:AddControl("CheckBox", {
			Label = "3D Hitmarker For All Weapons",
			Command = "cl_tfa_hud_hitmarker_3d_all"
		})

		panel:AddControl("CheckBox", {
			Label = "3D Hitmarker For Shotguns",
			Command = "cl_tfa_hud_hitmarker_3d_shotguns"
		})

		panel:AddControl("Slider", {
			Label = "Hitmaker Solid Time",
			Command = "cl_tfa_hud_hitmarker_solidtime",
			Type = "Float",
			Min = "0",
			Max = "1"
		})

		panel:AddControl("Slider", {
			Label = "Hitmaker Fade Time",
			Command = "cl_tfa_hud_hitmarker_fadetime",
			Type = "Float",
			Min = "0",
			Max = "1"
		})

		panel:AddControl("Slider", {
			Label = "Hitmaker Scale",
			Command = "cl_tfa_hud_hitmarker_scale",
			Type = "Float",
			Min = "0",
			Max = "5"
		})

		panel:AddControl("Color", {
			Label = "Hitmarker Color",
			Red = "cl_tfa_hud_hitmarker_color_r",
			Green = "cl_tfa_hud_hitmarker_color_g",
			Blue = "cl_tfa_hud_hitmarker_color_b",
			Alpha = "cl_tfa_hud_hitmarker_color_a",
			ShowHSV = 1,
			ShowRGB = 1,
			Multiplier = 255
		})

		panel:AddControl("Label", {
			Text = "By TheForgottenArchitect"
		})
	end

	local function tfaOptionDeveloper(panel)
		--Here are whatever default categories you want.
		local tfaOptionPerf = {
			Options = {},
			CVars = {},
			Label = "#Presets",
			MenuButton = "1",
			Folder = "TFA SWEP Settings Developer"
		}

		tfaOptionPerf.Options["#Default"] = {}
		panel:AddControl("ComboBox", tfaOptionPerf)

		panel:AddControl("CheckBox", {
			Label = "Force Debug Crosshair",
			Command = "cl_tfa_debug_crosshair"
		})

		panel:AddControl("CheckBox", {
			Label = "Debug RT Overlay",
			Command = "cl_tfa_debug_rt"
		})

		panel:AddControl("CheckBox", {
			Label = "Disable Stat Caching",
			Command = "cl_tfa_debug_cache"
		})

		panel:AddControl("Label", {
			Text = "By TheForgottenArchitect"
		})
	end

	local function tfaOptionColors(panel)
		local tfaOptionCO = {
			Options = {},
			CVars = {},
			Label = "#Presets",
			MenuButton = "1",
			Folder = "TFA SWEP Settings Colors"
		}

		tfaOptionCO.Options["#Default"] = {
			cl_tfa_laser_color_r = "255",
			cl_tfa_laser_color_g = "0",
			cl_tfa_laser_color_b = "0",
			cl_tfa_reticule_color_r = "255",
			cl_tfa_reticule_color_g = "100",
			cl_tfa_reticule_color_b = "0"
		}

		panel:AddControl("ComboBox", tfaOptionCO)

		panel:AddControl("Color", {
			Label = "Laser Color",
			Red = "cl_tfa_laser_color_r",
			Green = "cl_tfa_laser_color_g",
			Blue = "cl_tfa_laser_color_b",
			ShowHSV = 1,
			ShowRGB = 1,
			Multiplier = 255
		})

		panel:AddControl("Color", {
			Label = "Reticule Color",
			Red = "cl_tfa_reticule_color_r",
			Green = "cl_tfa_reticule_color_g",
			Blue = "cl_tfa_reticule_color_b",
			ShowHSV = 1,
			ShowRGB = 1,
			Multiplier = 255
		})

		panel:AddControl("Label", {
			Text = "By TheForgottenArchitect"
		})
	end

	local function tfaOptionBallistics(panel)
		--Here are whatever default categories you want.
		local tfaOptionPerf = {
			Options = {},
			CVars = {},
			Label = "#Presets",
			MenuButton = "1",
			Folder = "TFA SWEP Settings Ballistics"
		}

		tfaOptionPerf.Options["#Default"] = {
			["sv_tfa_ballistics_enabled"] = nil,
			["sv_tfa_ballistics_mindist"] = -1,
			["sv_tfa_ballistics_bullet_life"] = 10,
			["sv_tfa_ballistics_bullet_damping_air"] = 1,
			["sv_tfa_ballistics_bullet_damping_water"] = 3,
			["sv_tfa_ballistics_bullet_velocity"] = 1,
			["sv_tfa_ballistics_bullet_substeps"] = 3,
			["cl_tfa_ballistics_mp"] = 1,
			["cl_tfa_ballistics_fx_bullet"] = 1,
			["cl_tfa_ballistics_fx_tracers_style"] = 1,
			["cl_tfa_ballistics_fx_tracers_mp"] = 1,
			["cl_tfa_ballistics_fx_tracers_adv"] = 1
		}

		panel:AddControl("ComboBox", tfaOptionPerf)

		panel:AddControl("Label", {
			Text = "Serverside"
		})

		panel:AddControl("CheckBox", {
			Label = "Enabler",
			Command = "sv_tfa_ballistics_enabled"
		})

		panel:AddControl("Slider", {
			Label = "Activation Distance (-1=always)",
			Command = "sv_tfa_ballistics_mindist",
			Type = "Int",
			Min = "-1",
			Max = "100"
		})

		panel:AddControl("Slider", {
			Label = "Bullet Life",
			Command = "sv_tfa_ballistics_bullet_life",
			Type = "Float",
			Min = "0",
			Max = "20"
		})

		panel:AddControl("Slider", {
			Label = "Bullet Air Resistance",
			Command = "sv_tfa_ballistics_bullet_damping_air",
			Type = "Float",
			Min = "0",
			Max = "10"
		})

		panel:AddControl("Slider", {
			Label = "Bullet Water Resistance",
			Command = "sv_tfa_ballistics_bullet_damping_water",
			Type = "Float",
			Min = "0",
			Max = "10"
		})

		panel:AddControl("Slider", {
			Label = "Bullet Velocity",
			Command = "sv_tfa_ballistics_bullet_velocity",
			Type = "Float",
			Min = "0",
			Max = "2"
		})

		panel:AddControl("Slider", {
			Label = "Sub-Steps",
			Command = "sv_tfa_ballistics_substeps",
			Type = "Integer",
			Min = "1",
			Max = "5"
		})

		panel:AddControl("Label", {
			Text = "Clientside"
		})

		panel:AddControl("CheckBox", {
			Label = "Bullet Models",
			Command = "cl_tfa_ballistics_fx_bullet"
		})

		panel:AddControl("CheckBox", {
			Label = "HQ Position Calcuations",
			Command = "cl_tfa_ballistics_fx_tracers_adv"
		})

		panel:AddControl("CheckBox", {
			Label = "Multiplayer Ballistics",
			Command = "cl_tfa_ballistics_mp"
		})

		panel:AddControl("CheckBox", {
			Label = "Multiplayer Tracers",
			Command = "cl_tfa_ballistics_fx_tracers_mp"
		})

		local tfaOptionTracerStyle = {
			Options = {},
			CVars = {"cl_tfa_ballistics_fx_tracers_style"},
			Label = "#Presets",
			MenuButton = "1",
			Folder = "TFASSBallTracerStyle"
		}

		tfaOptionTracerStyle.Options["#tfabaltra.di"] = {
			["cl_tfa_ballistics_fx_tracers_style"] = 0
		}

		tfaOptionTracerStyle.Options["#tfabaltra.sm"] = {
			["cl_tfa_ballistics_fx_tracers_style"] = 1
		}

		tfaOptionTracerStyle.Options["#tfabaltra.re"] = {
			["cl_tfa_ballistics_fx_tracers_style"] = 2
		}

		panel:AddControl("Label", {
			Text = "Tracer Style:"
		})

		panel:AddControl("ComboBox", tfaOptionTracerStyle)

		panel:AddControl("Label", {
			Text = "By TheForgottenArchitect"
		})
	end

	local function tfaAddOption()
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "tfaOptionVM", "Viewmodel", "", "", tfaOptionVM)
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "tfaOptionSights", "Scopes / Sights", "", "", tfaOptionSights)
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "tfaOptionPerformance", "Performance", "", "", tfaOptionPerformance)
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseCrosshair", "HUD / Crosshair", "", "", tfaOptionHUD)
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseDeveloper", "Developer", "", "", tfaOptionDeveloper)
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseColor", "Color Customisation", "", "", tfaOptionColors)
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseBallistics", "Ballistics", "", "", tfaOptionBallistics)
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseServer", "Admin / Server", "", "", tfaOptionServer)
		--spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseRestriction", "Restriction", "", "", tfaOptionRestriction)
	end

	hook.Add("PopulateToolMenu", "tfaAddOption", tfaAddOption)
else
	AddCSLuaFile()
end