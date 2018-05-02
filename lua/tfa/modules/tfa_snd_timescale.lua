local sv_cheats_cv = GetConVar("sv_cheats")
local host_timescale_cv = GetConVar("host_timescale")
local ts

local en_cvar = GetConVar("sv_tfa_soundscale")

hook.Add( "EntityEmitSound", "zzz_TFA_EntityEmitSound", function( soundData )
	if not en_cvar then return end
	if not en_cvar:GetBool() then return end
	ts = game.GetTimeScale()
	if sv_cheats_cv:GetBool() then
		ts = ts * host_timescale_cv:GetFloat()
	end
	if engine.GetDemoPlaybackTimeScale then
		ts = ts * engine.GetDemoPlaybackTimeScale()
	end
	if ts ~= 1 then
		soundData.Pitch = math.Clamp( soundData.Pitch * ts, 0, 255 )
		return true
	end
end )