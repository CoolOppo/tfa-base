local st_old, host_ts, cheats, vec, ang
host_ts = GetConVar("host_timescale")
cheats = GetConVar("sv_cheats")
vec = Vector()
ang = Angle()

local sp = game.SinglePlayer()
local IsGameUIVisible = gui and gui.IsGameUIVisible

hook.Add("PreDrawViewModel", "TFACalculateViewmodel", function(vm, ply, wep)
	if not IsValid(wep) or not wep:IsTFA() then return end

	local st = SysTime()
	st_old = st_old or st

	local delta = st - st_old
	st_old = st

	if sp and IsGameUIVisible and IsGameUIVisible() then return end

	delta = delta * game.GetTimeScale() * (cheats:GetBool() and host_ts:GetFloat() or 1)

	wep:Sway(vec, ang, delta)
	wep:CalculateViewModelOffset(delta)
	wep:CalculateViewModelFlip()
end)