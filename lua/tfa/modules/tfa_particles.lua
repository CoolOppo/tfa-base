TFA_Base_Particles = TFA_Base_Particles or {}
TFA_Base_Particles["tfa_muzzle_rifle"] = "tfa_muzzleflashes"
TFA_Base_Particles["tfa_muzzle_sniper"] = "tfa_muzzleflashes"
TFA_Base_Particles["tfa_muzzle_energy"] = "tfa_muzzleflashes"
TFA_Base_Particles["tfa_muzzle_energy"] = "tfa_muzzleflashes"
TFA_Base_Particles["tfa_muzzle_gauss"] = "tfa_muzzleflashes"
-- TFA_Base_Particles["weapon_muzzle_smoke_long"] = "csgo_fx"
-- TFA_Base_Particles["weapon_muzzle_smoke"] = "csgo_fx"
TFA_Base_Particles["tfa_ins2_weapon_muzzle_smoke"] = "tfa_ins2_muzzlesmoke"
TFA_Base_Particles["tfa_bullet_smoke_tracer"] = "tfa_ballistics"
TFA_Base_Particles["tfa_bullet_fire_tracer"] = "tfa_ballistics"
--legacy
TFA_Base_Particles["smoke_trail_tfa"] = "tfa_smoke"
TFA_Base_Particles["smoke_trail_controlled"] = "tfa_smoke"
local addedparts = {}
local cachedparts = {}

function TFA_Initialize_Particles()
	for k, v in pairs(TFA_Base_Particles) do
		if not addedparts[v] then
			game.AddParticles("particles/" .. v .. ".pcf")
			addedparts[v] = true
		end

		if not cachedparts[k] and not string.find(k, "DUMMY") then
			PrecacheParticleSystem(k)
			cachedparts[k] = true
		end
	end
end

hook.Add("InitPostEntity", "TFA_Initialize_Particles", TFA_Initialize_Particles)
TFA_Initialize_Particles()
