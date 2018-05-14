--[[Bullet Struct:
[BULLET_ID] = {
	["owner"] = Entity, --used for dmginfo SetAttacker
	["inflictor"] = Entity, --used for dmginfo SetInflictor
	["damage"] = Double, --floating point number representing inflicted damage
	["force"] = Double,
	["pos"] = Vector, --vector representing current position
	["velocity"] = Vector, --vector representing movement velocity
	["model"] = String --optional variable representing the given model,
	["bul"] = {} --optional table containing bullet data,
	["smokeparticle"] = String --smoke particle name from within pcf
}
]]
--default cvar integration
local cv_gravity = GetConVar("sv_gravity")
local cv_ts = GetConVar("host_timescale")

local function TimeScale(v)
	return v * cv_ts:GetFloat() * game.GetTimeScale() / TFA.Ballistics.SubSteps
end

--init code
TFA.Ballistics = TFA.Ballistics or {}
TFA.Ballistics.Enabled = false
TFA.Ballistics.Gravity = Vector(0, 0, -cv_gravity:GetFloat())
TFA.Ballistics.Bullets = {}
TFA.Ballistics.BulletCount = TFA.Ballistics.BulletCount or 0
TFA.Ballistics.BulletLife = 10
TFA.Ballistics.UnitScale = TFA.UnitScale or 39.3701 --meters to inches
TFA.Ballistics.AirResistance = 1
TFA.Ballistics.WaterResistance = 3
TFA.Ballistics.WaterEntranceResistance = 6

TFA.Ballistics.DamageVelocityLUT = {
	[13] = 350, --shotgun
	[25] = 425, --mp5k etc.
	[35] = 900, --ak-12
	[65] = 830, --SVD
	[120] = 1100 --sniper cap
}

TFA.Ballistics.VelocityMultiplier = 1
TFA.Ballistics.SubSteps = 1
TFA.Ballistics.BulletCreationNetString = "TFABallisticsBullet"

TFA.Ballistics.TracerStyles = {
	[0] = "",
	[1] = "tfa_bullet_smoke_tracer",
	[2] = "tfa_bullet_fire_tracer"
}

setmetatable(TFA.Ballistics.TracerStyles, {
	["__index"] = function(t, k) return t[math.Round(tonumber(k) or 1)] or t[1] end
})

if SERVER then
	util.AddNetworkString(TFA.Ballistics.BulletCreationNetString)
end

--bullet class
local function IncludeClass(fn)
	include("tfa/ballistics/" .. fn .. ".lua")
	AddCSLuaFile("tfa/ballistics/" .. fn .. ".lua")
end

IncludeClass("bullet")
--cvar code
local cv_enabled = CreateConVar("sv_tfa_ballistics_enabled", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Enable TFA Ballistics?")
local cv_bulletlife = CreateConVar("sv_tfa_ballistics_bullet_life", 10, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Time to process bullets before removing.")
local cv_res_air = CreateConVar("sv_tfa_ballistics_bullet_damping_air", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Air resistance, which makes bullets arc faster.")
local cv_res_water = CreateConVar("sv_tfa_ballistics_bullet_damping_water", 3, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Water resistance, which makes bullets arc faster in water.")
local cv_vel = CreateConVar("sv_tfa_ballistics_bullet_velocity", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Global velocity multiplier for TFA ballistics bullets.")
local cv_substep = CreateConVar("sv_tfa_ballistics_substeps", 1, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Substeps for ballistics; more is more precise, at the cost of performance.")

local function updateCVars()
	TFA.Ballistics.BulletLife = cv_bulletlife:GetFloat()
	TFA.Ballistics.AirResistance = cv_res_air:GetFloat()
	TFA.Ballistics.WaterResistance = cv_res_water:GetFloat()
	TFA.Ballistics.WaterEntranceResistance = TFA.Ballistics.WaterResistance * 2
	TFA.Ballistics.VelocityMultiplier = cv_vel:GetFloat()
	TFA.Ballistics.Gravity.z = -cv_gravity:GetFloat()
	TFA.Ballistics.Enabled = cv_enabled:GetBool()
	TFA.Ballistics.SubSteps = cv_substep:GetInt()
end

timer.Create("TFABallisticsUpdateSVCVars", 1, 0, updateCVars)
updateCVars()
--client cvar code
local cv_receive, cv_tracers_style, cv_tracers_mp

if CLIENT then
	cv_receive = CreateClientConVar("cl_tfa_ballistics_mp", "1", true, false, "Receive bullet data from other players?")
	CreateClientConVar("cl_tfa_ballistics_fx_bullet", "1", true, false, "Display bullet models for each TFA ballistics bullet?")
	cv_tracers_style = CreateClientConVar("cl_tfa_ballistics_fx_tracers_style", "1", true, false, "Style of tracers for TFA ballistics? 0=disable,1=smoke")
	cv_tracers_mp = CreateClientConVar("cl_tfa_ballistics_fx_tracers_mp", "1", true, false, "Enable tracers for other TFA ballistics users?")
	CreateClientConVar("cl_tfa_ballistics_fx_tracers_adv", "1", true, false, "Enable advanced tracer calculations for other users? This corrects smoke trail to their barrel")
end

--utility func
local function Remap(inp, u, v, x, y)
	return (inp - u) / (v - u) * (y - x) + x
end

--Accessors
local CopyTable = table.Copy

function TFA.Ballistics.Bullets:Add(bulletStruct, originalBulletData)
	local b = TFA.Ballistics:Bullet(bulletStruct)
	b.bul = CopyTable(originalBulletData or b.bul)
	self[TFA.Ballistics.BulletCount] = b

	if SERVER then
		b:Update(FrameTime())
	end

	TFA.Ballistics.BulletCount = TFA.Ballistics.BulletCount + 1
end

function TFA.Ballistics.Bullets:Update()
	local delta = TimeScale(SysTime() - (self.lastUpdate or (SysTime() - FrameTime())))
	self.lastUpdate = SysTime()

	for k, v in pairs(self) do
		if isnumber(k) then
			if v.delete then
				self[k] = nil
			else
				for i = 1, TFA.Ballistics.SubSteps do
					v:Update(delta)
				end
			end
		end
	end
end

function TFA.Ballistics:AutoDetectVelocity(damage)
	local lutMin, lutMax, LUT, DMGs
	LUT = self.DamageVelocityLUT
	DMGs = table.GetKeys(LUT)
	table.sort(DMGs)

	for k, v in ipairs(DMGs) do
		if v < damage then
			lutMin = v
		elseif lutMin then
			lutMax = v
			break
		end
	end

	if not lutMax then
		lutMax = DMGs[#DMGs]
		lutMin = DMGs[#DMGs - 1]
	elseif not lutMin then
		lutMin = DMGs[1]
		lutMax = DMGs[2]
	end

	return Remap(damage, lutMin, lutMax, LUT[lutMin], LUT[lutMax])
end

function TFA.Ballistics:ShouldUse(wep)
	if not self.Enabled then return false end

	if wep.UseBallistics == nil then
		if wep:IsTFA() and wep:GetStat("TracerPCF") then return false end

		return true
	else
		return wep.UseBallistics
	end
end

function TFA.Ballistics:FireBullets(wep, b, angIn)
	if not IsValid(wep) then return end
	if not IsValid(wep:GetOwner()) then return end
	local vel, sharedRandomSeed

	if wep.GetStat and wep:GetStat("Primary.Velocity") then
		vel = wep:GetStat("Primary.Velocity") * TFA.Ballistics.UnitScale
	elseif wep.Primary and wep.Primary.Velocity then
		vel = wep.Primary.Velocity * TFA.Ballistics.UnitScale
	elseif wep.Velocity then
		vel = wep.Velocity * TFA.Ballistics.UnitScale
	else
		local dmg

		if wep.GetStat and wep:GetStat("Primary.Damage") then
			dmg = wep:GetStat("Primary.Damage")
		else
			dmg = wep.Primary.Damage or wep.Damage or 30
		end

		vel = TFA.Ballistics:AutoDetectVelocity(dmg) * TFA.Ballistics.UnitScale
	end

	vel = vel * (TFA.Ballistics.VelocityMultiplier or 1)
	local oldNum = b.Num
	b.Num = 1

	for i = 1, oldNum do
		local ang

		if angIn then
			ang = angIn
		else
			ang = wep:GetOwner():EyeAngles()
			local ac = b.Spread
			sharedRandomSeed = ("Ballistics" .. tostring(CurTime()))
			ang:RotateAroundAxis(ang:Up(), util.SharedRandom(sharedRandomSeed, -ac.x * 45, ac.x * 45, 0 + i))
			ang:RotateAroundAxis(ang:Right(), util.SharedRandom(sharedRandomSeed, -ac.y * 45, ac.y * 45, 1 + i))
		end

		local struct = {
			["owner"] = wep:GetOwner(), --used for dmginfo SetAttacker
			["inflictor"] = wep, --used for dmginfo SetInflictor
			["damage"] = b.Damage, --floating point number representing inflicted damage
			["force"] = b.Force,
			["pos"] = wep:GetOwner():GetShootPos(), --b.Src, --vector representing current position
			["velocity"] = ang:Forward() * vel, --b.Dir * vel, --vector representing movement velocity
			["model"] = wep.BulletModel or b.Model, --optional variable representing the given model
			["smokeparticle"] = b.SmokeParticle
		}

		--disable shotgun tracers
		if oldNum > 1 then
			struct.smokeparticle = ""
		end

		if CLIENT then
			if (not cv_tracers_mp:GetBool()) and wep:GetOwner() ~= LocalPlayer() then
				struct.smokeparticle = ""
			elseif not struct.smokeparticle then
				struct.smokeparticle = TFA.Ballistics.TracerStyles[cv_tracers_style:GetInt()]
			end
		end

		self.Bullets:Add(struct, b)

		if SERVER then
			net.Start(TFA.Ballistics.BulletCreationNetString)
			net.WriteEntity(wep)

			net.WriteTable({
				["Damage"] = b.Damage,
				["Force"] = b.Force,
				["Num"] = b.Num,
				["Src"] = b.Src,
				["Dir"] = b.Dir,
				["Attacker"] = b.Attacker,
				["Spread"] = b.Spread,
				["SmokeParticle"] = struct.smokeparticle
			})

			net.WriteAngle(ang)

			if game.SinglePlayer() then
				net.Broadcast()
			else
				net.SendOmit(wep:GetOwner())
			end
		end
	end
end

function TFA.Ballistics.Bullets:Render()
	for k, v in pairs(self) do
		if isnumber(k) then
			v:Render()
		end
	end
end

--Netcode and Hooks
if CLIENT then
	net.Receive(TFA.Ballistics.BulletCreationNetString, function()
		if game.SinglePlayer() or cv_receive:GetBool() then
			local wep, b, ang
			wep = net.ReadEntity()
			b = net.ReadTable()
			ang = net.ReadAngle()
			if not wep then return end
			if not b then return end
			TFA.Ballistics:FireBullets(wep, b, ang)
		end
	end)
end

hook.Add(SERVER and "Tick" or "PreRender", "TFABallisticsTick", function()
	TFA.Ballistics.Bullets:Update()
end)

--Rendering
hook.Add("PostDrawOpaqueRenderables", "TFABallisticsRender", function()
	TFA.Ballistics.Bullets:Render()
end)