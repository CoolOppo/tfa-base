local tmpsp = game.SinglePlayer()
local gas_cl_enabled = GetConVar("cl_tfa_fx_gasblur")

local l_FT = FrameTime
local l_mathClamp = math.Clamp
local sv_cheats_cv = GetConVar("sv_cheats")
local host_timescale_cv = GetConVar("host_timescale")
local ft = 0.01
local LastSys

local SoundChannels = {
	["shoot"] = CHAN_WEAPON,
	["shootwrap"] = CHAN_STATIC,
	["misc"] = CHAN_AUTO
}


local BindToKey = {
	["ctrl"] = KEY_LCONTROL,
	["rctrl"] = KEY_LCONTROL,
	["alt"] = KEY_LALT,
	["ralt"] = KEY_RALT,
	["space"] = KEY_SPACE,
	["caps"] = KEY_CAPSLOCK,
	["capslock"] = KEY_CAPSLOCK,
	["tab"] = KEY_TAB,
	["back"] = KEY_BACKSPACE,
	["backspace"] = KEY_BACKSPACE,
	[0] = KEY_0,
	[1] = KEY_1,
	[2] = KEY_2,
	[3] = KEY_3,
	[4] = KEY_4,
	[5] = KEY_5,
	[6] = KEY_6,
	[7] = KEY_7,
	[8] = KEY_8,
	[9] = KEY_9
}

local alphabet = "abcdefghijklmnopqrstuvwxyz"

for i = 1, string.len(alphabet) do
	local sstr = string.sub( alphabet, i, i )
	BindToKey[ sstr ] =  string.byte( sstr ) - 86
end

function TFA.BindToKey( bind, default )
	return BindToKey[ string.lower( bind ) ] or default or KEY_C
end

function TFA.AddFireSound(id,path,wrap)
	sound.Add({
		name = id,
		channel = wrap and SoundChannels.shootwrap or SoundChannels.shoot,
		volume = 1.0,
		level = 120,
		pitch = { 97, 103 },
		sound = ")" .. path
	})
end

function TFA.AddWeaponSound(id,path)
	sound.Add({
		name = id,
		channel = SoundChannels.misc,
		volume = 1.0,
		level = 80,
		pitch = { 97, 103 },
		sound = ")" .. path
	})
end

function TFA.FrameTime()
	return ft
end

function TFA.GetGasEnabled()
	if tmpsp then return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_gasblur", 0)) ~= 0 end
	local enabled

	if gas_cl_enabled then
		enabled = gas_cl_enabled:GetBool()
	else
		enabled = false
	end

	return enabled
end

local ejectionsmoke_cl_enabled = GetConVar("cl_tfa_fx_ejectionsmoke")
local muzzlesmoke_cl_enabled = GetConVar("cl_tfa_fx_muzzlesmoke")

function TFA.GetMZSmokeEnabled()
	if tmpsp then return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_muzzlesmoke", 0)) ~= 0 end
	local enabled

	if muzzlesmoke_cl_enabled then
		enabled = muzzlesmoke_cl_enabled:GetBool()
	else
		enabled = false
	end

	return enabled
end

function TFA.GetEJSmokeEnabled()
	if tmpsp then return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_ejectionsmoke", 0)) ~= 0 end
	local enabled

	if ejectionsmoke_cl_enabled then
		enabled = ejectionsmoke_cl_enabled:GetBool()
	else
		enabled = false
	end

	return enabled
end

local ricofx_cl_enabled = GetConVar("cl_tfa_fx_impact_ricochet_enabled")

function TFA.GetRicochetEnabled()
	if tmpsp then return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_impact_ricochet_enabled", 0)) ~= 0 end
	local enabled

	if ricofx_cl_enabled then
		enabled = ricofx_cl_enabled:GetBool()
	else
		enabled = false
	end

	return enabled
end

--Local function for detecting TFA Base weapons.
function TFA.PlayerCarryingTFAWeapon(ply)
	if not ply then
		if CLIENT then
			if IsValid(LocalPlayer()) then
				ply = LocalPlayer()
			else
				return false, nil, nil
			end
		elseif game.SinglePlayer() then
			ply = Entity(1)
		else
			return false, nil, nil
		end
	end

	if not (IsValid(ply) and ply:IsPlayer() and ply:Alive()) then return end
	local wep = ply:GetActiveWeapon()

	if IsValid(wep) then
		if (wep.IsTFAWeapon) then return true, ply, wep end

		return false, ply, wep
	end

	return false, ply, nil
end


hook.Add("Think","TFAFrameTimeThink",function()
	ft = (SysTime() - (LastSys or SysTime())) * game.GetTimeScale()

	if ft > l_FT() then
		ft = l_FT()
	end

	ft = l_mathClamp(ft, 0, 1 / 30)

	if sv_cheats_cv:GetBool() and host_timescale_cv:GetFloat() < 1 then
		ft = ft * host_timescale_cv:GetFloat()
	end

	LastSys = SysTime()
end)