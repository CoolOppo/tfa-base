--Config GUI
if CLIENT then
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
			sv_tfa_weapon_strip = "0",
			sv_tfa_allow_dryfire = "1",
			sv_tfa_damage_multiplier = "1",
			sv_tfa_default_clip = "-1",
			sv_tfa_arrow_lifetime = "30",
			sv_tfa_force_multiplier = "1",
			sv_tfa_dynamicaccuracy = "1",
			sv_tfa_near_wall = "1",
			sv_tfa_range_modifier = "0.5",
			sv_tfa_spread_multiplier = "1",
			sv_tfa_bullet_penetration = "1",
			sv_tfa_bullet_ricochet = "0",
			sv_tfa_reloads_legacy = "0",
			sv_tfa_cmenu = "1",
			sv_tfa_penetration_limit = "2",
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
			Label = "Pull up weapon when near wall",
			Command = "sv_tfa_near_wall"
		})

		panel:AddControl("CheckBox", {
			Label = "Strip Empty Weapons",
			Command = "sv_tfa_weapon_strip"
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

	local function tfaOptionClient(panel)
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
			cl_tfa_3dscope_overlay = "0",
			cl_tfa_scope_sensitivity_autoscale = "1",
			cl_tfa_scope_sensitivity = "100",
			cl_tfa_inspection_ckey = "0",
			cl_tfa_inspection_old = "0",
			cl_tfa_ironsights_toggle = "1",
			cl_tfa_ironsights_resight = "1",
			cl_tfa_viewbob_reloading = "1",
			cl_tfa_viewbob_drawing = "0",
			sv_tfa_gunbob_intensity = "1",
			sv_tfa_viewbob_intensity = "1",
			cl_tfa_viewmodel_offset_x = "0",
			cl_tfa_viewmodel_offset_y = "0",
			cl_tfa_viewmodel_offset_z = "0",
			cl_tfa_viewmodel_offset_fov = "0",
			cl_tfa_viewmodel_flip = "0"
		}

		panel:AddControl("ComboBox", tfaOptionCL)

		--These are the panel controls.  Adding these means that you don't have to go into the console.
		panel:AddControl("CheckBox", {
			Label = "Enable 3D Scopes (Re-Draw Gun After Changing)",
			Command = "cl_tfa_3dscope"
		})

		panel:AddControl("CheckBox", {
			Label = "Enable 3D Scope Shadows (Re-Draw Gun After Changing)",
			Command = "cl_tfa_3dscope_overlay"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Viebob While Drawing",
			Command = "cl_tfa_viewbob_drawing"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Viebob While Reloading",
			Command = "cl_tfa_viewbob_reloading"
		})

		panel:AddControl("CheckBox", {
			Label = "Context Key Inspection",
			Command = "cl_tfa_inspection_ckey"
		})

		panel:AddControl("CheckBox", {
			Label = "Legacy Text Inspection",
			Command = "cl_tfa_inspection_old"
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
			Label = "Compensate sensitivity for FOV",
			Command = "cl_tfa_scope_sensitivity_autoscale"
		})

		panel:AddControl("Slider", {
			Label = "Scope sensitivity",
			Command = "cl_tfa_scope_sensitivity",
			Type = "Integer",
			Min = "1",
			Max = "100"
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
			sv_tfa_fx_impact_override = "-1",
			sv_tfa_fx_muzzlesmoke_override = "-1",
			sv_tfa_fx_ejectionsmoke_override = "-1",
			sv_tfa_fx_gas_override = "-1",
			sv_tfa_fx_ricochet_override = "-1",
			sv_tfa_worldmodel_culldistance = "-1",
			cl_tfa_fx_impact_enabled = "1",
			cl_tfa_fx_impact_ricochet_enabled = "1",
			cl_tfa_fx_impact_ricochet_sparks = "20",
			cl_tfa_fx_impact_ricochet_sparklife = "2",
			cl_tfa_fx_gasblur = "1",
			cl_tfa_fx_muzzlesmoke = "1",
			cl_tfa_inspection_bokeh = "0"
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

		panel:AddControl("Label", {
			Text = "Performance Overrides (Serverside)"
		})

		panel:AddControl("CheckBox", {
			Label = "Use Penetration Decal (SV)",
			Command = "sv_tfa_fx_penetration_decal"
		})

		panel:AddControl("Slider", {
			Label = "Gas Blur Effect Override (-1 to leave clientside)",
			Command = "sv_tfa_fx_gas_override",
			Type = "Integer",
			Min = "-1",
			Max = "1"
		})

		panel:AddControl("Slider", {
			Label = "Impact Effect Override (-1 to leave clientside)",
			Command = "sv_tfa_fx_impact_override",
			Type = "Integer",
			Min = "-1",
			Max = "1"
		})

		panel:AddControl("Slider", {
			Label = "Muzzle Smoke Effect Override (-1 to leave clientside)",
			Command = "sv_tfa_fx_muzzlesmoke_override",
			Type = "Integer",
			Min = "-1",
			Max = "1"
		})

		panel:AddControl("Slider", {
			Label = "Ejection Smoke Effect Override (-1 to leave clientside)",
			Command = "sv_tfa_fx_ejectionsmoke_override",
			Type = "Integer",
			Min = "-1",
			Max = "1"
		})

		panel:AddControl("Slider", {
			Label = "Ricochet Effect Override (-1 to leave clientside)",
			Command = "sv_tfa_fx_ricochet_override",
			Type = "Integer",
			Min = "-1",
			Max = "1"
		})

		panel:AddControl("Slider", {
			Label = "World Model Cull Distance (-1 to disable)",
			Command = "sv_tfa_worldmodel_culldistance",
			Type = "Integer",
			Min = "-1",
			Max = "4096"
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
			Command = "cl_tfa_debugcrosshair"
		})

		panel:AddControl("Label", {
			Text = "By TheForgottenArchitect"
		})
	end

	function tfaAddOption()
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "tfaOptionWeapons", "Weapon Behavior, Clientside", "", "", tfaOptionClient)
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "tfaOptionPerformance", "Performance", "", "", tfaOptionPerformance)
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseCrosshair", "HUD / Crosshair", "", "", tfaOptionHUD)
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseDeveloper", "Developer", "", "", tfaOptionDeveloper)
		spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseServer", "Admin / Server", "", "", tfaOptionServer)
		--spawnmenu.AddToolMenuOption("Options", "TFA SWEP Base Settings", "TFASwepBaseRestriction", "Restriction", "", "", tfaOptionRestriction)
	end

	hook.Add("PopulateToolMenu", "tfaAddOption", tfaAddOption)
else
	AddCSLuaFile()
end

--Serverside Convars
if GetConVar("sv_tfa_weapon_strip") == nil then
	CreateConVar("sv_tfa_weapon_strip", "0", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow the removal of empty weapons? 1 for true, 0 for false")
	--print("Weapon strip/removal con var created")
end

if GetConVar("sv_tfa_cmenu") == nil then
	CreateConVar("sv_tfa_cmenu", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow custom context menu?")
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

if GetConVar("sv_tfa_near_wall") == nil then
	CreateConVar("sv_tfa_near_wall", "1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Pull up your weapon and disable shooting when you're too close to a wall?")
	--print("Near wall con var created")
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

if GetConVar("sv_tfa_door_respawn") == nil then
	CreateConVar("sv_tfa_door_respawn", "-1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time for doors to respawn; -1 for never.")
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
					wep.Primary.DefaultClip = wep.Primary.TrueDefaultClip * dfc
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

if GetConVar("sv_tfa_fx_ejectionsmoke_override") == nil then
	CreateConVar("sv_tfa_fx_ejectionsmoke_override", "-1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "-1 to let clients pick.  0 to force off.  1 to force on.")
end

if GetConVar("sv_tfa_fx_muzzlesmoke_override") == nil then
	CreateConVar("sv_tfa_fx_muzzlesmoke_override", "-1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "-1 to let clients pick.  0 to force off.  1 to force on.")
end

if GetConVar("sv_tfa_fx_gas_override") == nil then
	CreateConVar("sv_tfa_fx_gas_override", "-1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "-1 to let clients pick.  0 to force off.  1 to force on.")
end

if GetConVar("sv_tfa_fx_impact_override") == nil then
	CreateConVar("sv_tfa_fx_impact_override", "-1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "-1 to let clients pick.  0 to force off.  1 to force on.")
end

if GetConVar("sv_tfa_fx_ricochet_override") == nil then
	CreateConVar("sv_tfa_fx_ricochet_override", "-1", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "-1 to let clients pick.  0 to force off.  1 to force on.")
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

--Clientside Convars
if CLIENT then
	if GetConVar("cl_tfa_inspection_old") == nil then
		CreateClientConVar("cl_tfa_inspection_old", 0, true, true)
	end

	if GetConVar("cl_tfa_inspection_ckey") == nil then
		CreateClientConVar("cl_tfa_inspection_ckey", 0, true, true)
	end

	if GetConVar("cl_tfa_viewbob_intensity") == nil then
		CreateClientConVar("cl_tfa_viewbob_intensity", 1, true, false)
	end

	if GetConVar("cl_tfa_gunbob_intensity") == nil then
		CreateClientConVar("cl_tfa_gunbob_intensity", 1, true, false)
		--print("Viewbob intensity con var created")
	end

	if GetConVar("cl_tfa_3dscope") == nil then
		CreateClientConVar("cl_tfa_3dscope", 1, true, true)
	end

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

	if GetConVar("cl_tfa_fx_ejectionsmoke") == nil then
		CreateClientConVar("cl_tfa_fx_ejectionsmoke", 1, true, true)
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
	if GetConVar("cl_tfa_viewbob_drawing") == nil then
		CreateClientConVar("cl_tfa_viewbob_drawing", 0, true, false)
	end

	if GetConVar("cl_tfa_viewbob_reloading") == nil then
		CreateClientConVar("cl_tfa_viewbob_reloading", 1, true, false)
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

	if GetConVar("cl_tfa_debugcrosshair") == nil then
		CreateClientConVar("cl_tfa_debugcrosshair", 0, true, false)
	end
end
