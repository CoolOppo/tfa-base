local tmpsp = game.SinglePlayer()
local gas_cl_enabled = GetConVar("cl_tfa_fx_gasblur")
local gas_sv_enabled = GetConVar("sv_tfa_fx_gas_override")

function GetTFAGasEnabled()

	if tmpsp then
		return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_gasblur",0))!=0
	end

	local enabled
	if gas_cl_enabled then
		enabled = gas_cl_enabled:GetBool()
	else
		enabled = false
	end

	if gas_sv_enabled and gas_sv_enabled:GetInt()!=-1 then enabled=gas_sv_enabled:GetBool() end

	return enabled

end

local ejectionsmoke_cl_enabled = GetConVar("cl_tfa_fx_ejectionsmoke")
local ejectionsmoke_sv_enabled = GetConVar("sv_tfa_fx_ejectionsmoke_override")

local muzzlesmoke_cl_enabled = GetConVar("cl_tfa_fx_muzzlesmoke")
local muzzlesmoke_sv_enabled = GetConVar("sv_tfa_fx_muzzlesmoke_override")

function GetTFAMZSmokeEnabled()

	if tmpsp then
		return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_muzzlesmoke",0))!=0
	end

	local enabled
	if muzzlesmoke_cl_enabled then
		enabled = muzzlesmoke_cl_enabled:GetBool()
	else
		enabled = false
	end

	if muzzlesmoke_sv_enabled and muzzlesmoke_sv_enabled:GetInt()!=-1 then enabled=muzzlesmoke_sv_enabled:GetBool() end

	return enabled

end

function GetTFAEJSmokeEnabled()

	if tmpsp then
		return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_ejectionsmoke",0))!=0
	end

	local enabled
	if ejectionsmoke_cl_enabled then
		enabled = ejectionsmoke_cl_enabled:GetBool()
	else
		enabled = false
	end

	if ejectionsmoke_sv_enabled and ejectionsmoke_sv_enabled:GetInt()==0 then enabled=ejectionsmoke_sv_enabled:GetBool() end

	return enabled

end

local ricofx_cl_enabled = GetConVar("cl_tfa_fx_impact_ricochet_enabled")
local ricofx_sv_enabled = GetConVar("sv_tfa_fx_ricochet_override")

function GetTFARicochetEnabled()

	if tmpsp then
		return math.Round(Entity(1):GetInfoNum("cl_tfa_fx_impact_ricochet_enabled",0))!=0
	end

	local enabled
	if ricofx_cl_enabled then
		enabled = ricofx_cl_enabled:GetBool()
	else
		enabled = false
	end

	if ricofx_sv_enabled and ricofx_sv_enabled:GetInt()!=-1 then enabled=ricofx_sv_enabled:GetBool() end

	return enabled

end

--Local function for detecting TFA Base weapons.

function PlayerCarryingTFAWeapon( ply )
	if !ply then
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

	if not ( IsValid(ply) and ply:IsPlayer() and ply:Alive() ) then return end

	local wep = ply:GetActiveWeapon()
	if IsValid(wep) then
		if (wep.IsTFAWeapon)then
			return true, ply, wep
		end
		return false, ply, wep
	end
	return false, ply, nil
end
