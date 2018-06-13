TFA.Particles = TFA.Particles or {}
TFA.Particles.PCFParticles = TFA.Particles.PCFParticles or {}
TFA.Particles.PCFParticles["tfa_muzzle_rifle"] = "tfa_muzzleflashes"
TFA.Particles.PCFParticles["tfa_muzzle_sniper"] = "tfa_muzzleflashes"
TFA.Particles.PCFParticles["tfa_muzzle_energy"] = "tfa_muzzleflashes"
TFA.Particles.PCFParticles["tfa_muzzle_energy"] = "tfa_muzzleflashes"
TFA.Particles.PCFParticles["tfa_muzzle_gauss"] = "tfa_muzzleflashes"
-- TFA.Particles.PCFParticles["weapon_muzzle_smoke_long"] = "csgo_fx"
-- TFA.Particles.PCFParticles["weapon_muzzle_smoke"] = "csgo_fx"
TFA.Particles.PCFParticles["tfa_ins2_weapon_muzzle_smoke"] = "tfa_ins2_muzzlesmoke"
TFA.Particles.PCFParticles["tfa_ins2_weapon_shell_smoke"] = "tfa_ins2_shellsmoke"
TFA.Particles.PCFParticles["tfa_bullet_smoke_tracer"] = "tfa_ballistics"
TFA.Particles.PCFParticles["tfa_bullet_fire_tracer"] = "tfa_ballistics"
--legacy
TFA.Particles.PCFParticles["smoke_trail_tfa"] = "tfa_smoke"
TFA.Particles.PCFParticles["smoke_trail_controlled"] = "tfa_smoke"
local addedparts = {}
local cachedparts = {}

function TFA.Particles.Initialize()
	for k, v in pairs(TFA.Particles.PCFParticles) do
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

hook.Add("InitPostEntity", "TFA.Particles.Initialize", TFA.Particles.Initialize)
TFA.Particles.Initialize()
