
-- Copyright (c) 2018-2020 TFA Base Devs

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

--[[Define Modules]]
SWEP.SV_MODULES = {}
SWEP.SH_MODULES = {"sh_ai_translations.lua", "sh_anims.lua", "sh_autodetection.lua", "sh_utils.lua", "sh_attachments.lua", "sh_bullet.lua", "sh_effects.lua", "sh_bobcode.lua", "sh_calc.lua", "sh_akimbo.lua", "sh_events.lua", "sh_nzombies.lua", "sh_ttt.lua", "sh_vm.lua", "sh_skins.lua" }
SWEP.ClSIDE_MODULES = { "cl_effects.lua", "cl_viewbob.lua", "cl_hud.lua", "cl_mods.lua", "cl_laser.lua", "cl_fov.lua", "cl_flashlight.lua" }
SWEP.Category = "" --The category.  Please, just choose something generic or something I've already done if you plan on only doing like one swep.
SWEP.Author = "TheForgottenArchitect"
SWEP.Contact = "theforgottenarchitect"
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.DrawCrosshair = true
SWEP.DrawCrosshairIS = false
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.Skin = 0 --Viewmodel skin
SWEP.Spawnable = false
SWEP.IsTFAWeapon = true

SWEP.Shotgun = false
SWEP.ShotgunEmptyAnim = false
SWEP.ShotgunEmptyAnim_Shell = true
SWEP.ShotgunStartAnimShell = false --shotgun start anim inserts shell
SWEP.ShellTime = nil

SWEP.data = {}
SWEP.data.ironsights = 1

SWEP.MoveSpeed = 1
SWEP.IronSightsMoveSpeed = nil

SWEP.FireSoundAffectedByClipSize = true

SWEP.Primary.Damage = -1
SWEP.Primary.DamageTypeHandled = true --true will handle damagetype in base
SWEP.Primary.NumShots = 1
SWEP.Primary.Force = -1
SWEP.Primary.Knockback = -1
SWEP.Primary.Recoil = 1
SWEP.Primary.RPM = 600
SWEP.Primary.RPM_Semi = -1
SWEP.Primary.RPM_Burst = -1
SWEP.Primary.StaticRecoilFactor = 0.5
SWEP.Primary.KickUp = 0.5
SWEP.Primary.KickDown = 0.5
SWEP.Primary.KickRight = 0.5
SWEP.Primary.KickHorizontal = 0.5
SWEP.Primary.DamageType = nil
SWEP.Primary.Ammo = "smg1"
SWEP.Primary.AmmoConsumption = 1
SWEP.Primary.Spread = 0
SWEP.Primary.SpreadMultiplierMax = -1 --How far the spread can expand when you shoot.
SWEP.Primary.SpreadIncrement = -1 --What percentage of the modifier is added on, per shot.
SWEP.Primary.SpreadRecovery = -1 --How much the spread recovers, per second.
SWEP.Primary.IronAccuracy = 0
SWEP.Primary.MaxPenetration = 100
SWEP.Primary.Range = -1--1200
SWEP.Primary.RangeFalloff = -1--0.5
SWEP.Primary.PenetrationMultiplier = 1
SWEP.Primary.DryFireDelay = nil

local sv_tfa_jamming = GetConVar('sv_tfa_jamming')
local sv_tfa_jamming_mult = GetConVar('sv_tfa_jamming_mult')
local sv_tfa_jamming_factor = GetConVar('sv_tfa_jamming_factor')
local sv_tfa_jamming_factor_inc = GetConVar('sv_tfa_jamming_factor_inc')

-- RP owners always like realism, so this feature might be something they like. Enable it for them!
TFA_AUTOJAMMING_ENABLED = string.find(engine.ActiveGamemode(), 'rp') or
	string.find(engine.ActiveGamemode(), 'roleplay') or
	string.find(engine.ActiveGamemode(), 'nutscript') or
	string.find(engine.ActiveGamemode(), 'serious') or
	TFA_ENABLE_JAMMING_BY_DEFAULT

SWEP.CanJam = tobool(TFA_AUTOJAMMING_ENABLED)

SWEP.JamChance = 0.04
SWEP.JamFactor = 0.06

SWEP.BoltAction = false --Unscope/sight after you shoot?
SWEP.BoltAction_Forced = false
SWEP.Scoped = false --Draw a scope overlay?
SWEP.ScopeOverlayThreshold = 0.875 --Percentage you have to be sighted in to see the scope.
SWEP.BoltTimerOffset = 0.25 --How long you stay sighted in after shooting, with a bolt action.
SWEP.ScopeScale = 0.5
SWEP.ReticleScale = 0.7

SWEP.MuzzleAttachment = "1"
SWEP.ShellAttachment = "2"

SWEP.MuzzleFlashEnabled = true
SWEP.MuzzleFlashEffect = nil
SWEP.MuzzleFlashEffectSilenced = "tfa_muzzleflash_silenced"
SWEP.CustomMuzzleFlash = true

SWEP.EjectionSmokeEnabled = true

SWEP.LuaShellEject = false
SWEP.LuaShellEjectDelay = 0
SWEP.LuaShellEffect = nil --Defaults to blowback

SWEP.SmokeParticle = nil --Smoke particle (ID within the PCF), defaults to something else based on holdtype

SWEP.StatusLengthOverride = {} --Changes the status delay of a given animation; only used on reloads.  Otherwise, use SequenceLengthOverride or one of the others
SWEP.SequenceLengthOverride = {} --Changes both the status delay and the nextprimaryfire of a given animation
SWEP.SequenceTimeOverride = {} --Like above but changes animation length to a target
SWEP.SequenceRateOverride = {} --Like above but scales animation length rather than being absolute

SWEP.BlowbackEnabled = false --Enable Blowback?
SWEP.BlowbackVector = Vector(0, -1, 0) --Vector to move bone <or root> relative to bone <or view> orientation.
SWEP.BlowbackCurrentRoot = 0 --Amount of blowback currently, for root
SWEP.BlowbackCurrent = 0 --Amount of blowback currently, for bones
SWEP.BlowbackBoneMods = nil --Viewmodel bone mods via SWEP Creation Kit
SWEP.Blowback_Only_Iron = true --Only do blowback on ironsights
SWEP.Blowback_PistolMode = false --Do we recover from blowback when empty?

SWEP.ProceduralHolsterEnabled = nil
SWEP.ProceduralHolsterTime = 0.3
SWEP.ProceduralHolsterPos = Vector(3, 0, -5)
SWEP.ProceduralHolsterAng = Vector(-40, -30, 10)

SWEP.ProceduralReloadEnabled = false --Do we reload using lua instead of a .mdl animation
SWEP.ProceduralReloadTime = 1 --Time to take when procedurally reloading, including transition in (but not out)

SWEP.Blowback_PistolMode_Disabled = {
	[ACT_VM_RELOAD] = true,
	[ACT_VM_RELOAD_EMPTY] = true,
	[ACT_VM_DRAW_EMPTY] = true,
	[ACT_VM_IDLE_EMPTY] = true,
	[ACT_VM_HOLSTER_EMPTY] = true,
	[ACT_VM_DRYFIRE] = true,
	[ACT_VM_FIDGET] = true,
	[ACT_VM_FIDGET_EMPTY] = true
}

SWEP.Blowback_Shell_Enabled = true
SWEP.Blowback_Shell_Effect = "ShellEject"

SWEP.Secondary.Ammo = ""
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0

SWEP.Sights_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = lua but continue idle, Lua = stop mdl animation
SWEP.Sprint_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Walk_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.Customize_Mode = TFA.Enum.LOCOMOTION_LUA -- ANI = mdl, HYBRID = ani + lua, Lua = lua only
SWEP.SprintFOVOffset = 5
SWEP.Idle_Mode = TFA.Enum.IDLE_BOTH --TFA.Enum.IDLE_DISABLED = no idle, TFA.Enum.IDLE_LUA = lua idle, TFA.Enum.IDLE_ANI = mdl idle, TFA.Enum.IDLE_BOTH = TFA.Enum.IDLE_ANI + TFA.Enum.IDLE_LUA
SWEP.Idle_Blend = 0.25 --Start an idle this far early into the end of a transition
SWEP.Idle_Smooth = 0.05 --Start an idle this far early into the end of another animation

SWEP.IronSightTime = 0.3
SWEP.IronSightsSensitivity = 1

SWEP.InspectPosDef = Vector(9.779, -11.658, -2.241)
SWEP.InspectAngDef = Vector(24.622, 42.915, 15.477)

SWEP.RunSightsPos = Vector(0,0,0)
SWEP.RunSightsAng = Vector(0,0,0)
SWEP.AllowSprintAttack = false --Shoot while sprinting?

SWEP.EventTable = {}

SWEP.RTMaterialOverride = nil
SWEP.RTOpaque = false
SWEP.RTCode = nil--function(self) return end
SWEP.RTBGBlur = true

SWEP.VMPos = Vector(0,0,0)
SWEP.VMAng = Vector(0,0,0)
SWEP.CameraOffset = Angle(0, 0, 0)
SWEP.VMPos_Additive = true

SWEP.AllowIronSightsDoF = true

SWEP.IronAnimation = {
	--[[
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Idle_To_Iron", --Number for act, String/Number for sequence
		["value_empty"] = "Idle_To_Iron_Dry",
		["transition"] = true
	}, --Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Idle_Iron", --Number for act, String/Number for sequence
		["value_empty"] = "Idle_Iron_Dry"
	}, --Looping Animation
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Iron_To_Idle", --Number for act, String/Number for sequence
		["value_empty"] = "Iron_To_Idle_Dry",
		["transition"] = true
	}, --Outward transition
	["shoot"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Fire_Iron", --Number for act, String/Number for sequence
		["value_last"] = "Fire_Iron_Last",
		["value_empty"] = "Fire_Iron_Dry"
	} --What do you think
	]]--
}

SWEP.SprintAnimation = {
	--[[
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Idle_to_Sprint", --Number for act, String/Number for sequence
		["value_empty"] = "Idle_to_Sprint_Empty",
		["transition"] = true
	}, --Inward transition
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Sprint_", --Number for act, String/Number for sequence
		["value_empty"] = "Sprint_Empty_",
		["is_idle"] = true
	},--looping animation
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "Sprint_to_Idle", --Number for act, String/Number for sequence
		["value_empty"] = "Sprint_to_Idle_Empty",
		["transition"] = true
	} --Outward transition
	]]--
}

SWEP.ShootAnimation = {--[[
	["in"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "shoot_loop_start", --Number for act, String/Number for sequence
		["value_is"] = "shoot_loop_iron_start"
	},
	["loop"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "shoot_loop", --Number for act, String/Number for sequence
		["value_is"] = "shoot_loop_iron",
		["is_idle"] = true
	},
	["out"] = {
		["type"] = TFA.Enum.ANIMATION_SEQ, --Sequence or act
		["value"] = "shoot_loop_end", --Number for act, String/Number for sequence
		["value_is"] = "shoot_loop_iron_end"
	}]]--
}

SWEP.FirstDeployEnabled = nil--Force first deploy enabled

--[[Dont edit under this unless you know what u r doing]]

SWEP.IronSightsProgress = 0
SWEP.CLIronSightsProgress = 0
SWEP.SprintProgress = 0
SWEP.WalkProgress = 0
SWEP.SpreadRatio = 0
SWEP.CrouchingRatio = 0
SWEP.SmokeParticles = {
	pistol = "tfa_ins2_weapon_muzzle_smoke",
	smg = "tfa_ins2_weapon_muzzle_smoke",
	grenade = "tfa_ins2_weapon_muzzle_smoke",
	ar2 = "tfa_ins2_weapon_muzzle_smoke",
	shotgun = "tfa_ins2_weapon_muzzle_smoke",
	rpg = "tfa_ins2_weapon_muzzle_smoke",
	physgun = "tfa_ins2_weapon_muzzle_smoke",
	crossbow = "tfa_ins2_weapon_muzzle_smoke",
	melee = "tfa_ins2_weapon_muzzle_smoke",
	slam = "tfa_ins2_weapon_muzzle_smoke",
	normal = "tfa_ins2_weapon_muzzle_smoke",
	melee2 = "tfa_ins2_weapon_muzzle_smoke",
	knife = "tfa_ins2_weapon_muzzle_smoke",
	duel = "tfa_ins2_weapon_muzzle_smoke",
	camera = "tfa_ins2_weapon_muzzle_smoke",
	magic = "tfa_ins2_weapon_muzzle_smoke",
	revolver = "tfa_ins2_weapon_muzzle_smoke",
	silenced = "tfa_ins2_weapon_muzzle_smoke"
}
--[[ SWEP.SmokeParticles = {
	pistol = "weapon_muzzle_smoke",
	smg = "weapon_muzzle_smoke",
	grenade = "weapon_muzzle_smoke",
	ar2 = "weapon_muzzle_smoke",
	shotgun = "weapon_muzzle_smoke_long",
	rpg = "weapon_muzzle_smoke_long",
	physgun = "weapon_muzzle_smoke_long",
	crossbow = "weapon_muzzle_smoke_long",
	melee = "weapon_muzzle_smoke",
	slam = "weapon_muzzle_smoke",
	normal = "weapon_muzzle_smoke",
	melee2 = "weapon_muzzle_smoke",
	knife = "weapon_muzzle_smoke",
	duel = "weapon_muzzle_smoke",
	camera = "weapon_muzzle_smoke",
	magic = "weapon_muzzle_smoke",
	revolver = "weapon_muzzle_smoke_long",
	silenced = "weapon_muzzle_smoke"
}--]]
--[[
SWEP.SmokeParticles = {
	pistol = "smoke_trail_controlled",
	smg = "smoke_trail_tfa",
	grenade = "smoke_trail_tfa",
	ar2 = "smoke_trail_tfa",
	shotgun = "smoke_trail_wild",
	rpg = "smoke_trail_tfa",
	physgun = "smoke_trail_tfa",
	crossbow = "smoke_trail_tfa",
	melee = "smoke_trail_tfa",
	slam = "smoke_trail_tfa",
	normal = "smoke_trail_tfa",
	melee2 = "smoke_trail_tfa",
	knife = "smoke_trail_tfa",
	duel = "smoke_trail_tfa",
	camera = "smoke_trail_tfa",
	magic = "smoke_trail_tfa",
	revolver = "smoke_trail_tfa",
	silenced = "smoke_trail_controlled"
}
]]--

SWEP.Inspecting = false
SWEP.InspectingProgress = 0
SWEP.LuaShellRequestTime = -1
SWEP.BobScale = 0
SWEP.SwayScale = 0
SWEP.BoltDelay = 1
SWEP.ProceduralHolsterProgress = 0
SWEP.BurstCount = 0
SWEP.DefaultFOV = 90

--[[ Localize Functions  ]]
local function l_Lerp(v, f, t)
	return f + (t - f) * v
end
local l_mathApproach = math.Approach
local l_CT = CurTime
--[[Frequently Reused Local Vars]]
local stat --Weapon status
local ct, ft  = 0, 0.01--Curtime, frametime, real frametime
local sp = game.SinglePlayer() --Singleplayer

--[[
Function Name:  SetupDataTables
Syntax: Should not be manually called.
Returns:  Nothing.  Simple sets up DTVars to be networked.
Purpose:  Networking.
]]
function SWEP:SetupDataTables()
	--self:NetworkVar("Bool", 0, "IronSights")
	self:NetworkVar("Bool", 0, "IronSightsRaw")
	self:NetworkVar("Bool", 1, "Sprinting")
	self:NetworkVar("Bool", 2, "Silenced")
	self:NetworkVar("Bool", 3, "ShotgunCancel")
	self:NetworkVar("Bool", 4, "Walking")
	self:NetworkVar("Bool", 5, "Customizing")
	self:NetworkVar("Bool", 18, "FlashlightEnabled")
	self:NetworkVar("Bool", 19, "Jammed")
	self:NetworkVar("Float", 0, "StatusEnd")
	self:NetworkVar("Float", 1, "NextIdleAnim")
	self:NetworkVar("Float", 18, "NextLoopSoundCheck")
	self:NetworkVar("Float", 19, "JamFactor")
	self:NetworkVar("Int", 0, "Status")
	self:NetworkVar("Int", 1, "FireMode")
	self:NetworkVar("Int", 2, "LastActivity")
	self:NetworkVar("Int", 3, "BurstCount")
	self:NetworkVar("Int", 4, "ShootStatus")
	self:NetworkVar("Entity", 0, "SwapTarget")
	hook.Run("TFA_SetupDataTables", self)

	self:NetworkVarNotify("Customizing", self.CustomizingUpdated)
end

--[[
Function Name:  Initialize
Syntax: Should not be normally called.
Notes:   Called after actual SWEP code, but before deploy, and only once.
Returns:  Nothing.  Sets the intial values for the SWEP when it's created.
Purpose:  Standard SWEP Function
]]

local PistolHoldTypes = {
	["pistol"] = true,
	["357"] = true,
	["revolver"] = true
}
local MeleeHoldTypes = {
	["melee"] = true,
	["melee2"] = true,
	["knife"] = true
}

function SWEP:Initialize()
	local self2 = self:GetTable()

	hook.Run("TFA_PreInitialize", self)

	self2.DrawCrosshairDefault = self2.DrawCrosshair
	self2.HasInitialized = true

	if not self2.BobScaleCustom or self2.BobScaleCustom <= 0 then
		self2.BobScaleCustom = 1
	end

	self.Primary_TFA = table.Copy(self.Primary)
	self.Secondary_TFA = table.Copy(self.Secondary)

	self.Primary.BaseClass = nil
	self.Secondary.BaseClass = nil

	self.Primary_TFA.BaseClass = nil
	self.Secondary_TFA.BaseClass = nil

	self2.BobScale = 0
	self2.SwayScaleCustom = 1
	self2.SwayScale = 0
	self2.SetSilenced(self, self2.Silenced or self2.DefaultSilenced)
	self2.Silenced = self2.Silenced or self2.DefaultSilenced
	self2.InitializeAnims(self)
	self2.InitializeMaterialTable(self)
	self2.PatchAmmoTypeAccessors(self)
	self2.FixRPM(self)
	self2.FixIdles(self)
	self2.FixIS(self)
	self2.FixProceduralReload(self)
	self2.FixCone(self)
	self2.FixProjectile(self)
	self2.AutoDetectMuzzle(self)
	self2.AutoDetectDamage(self)
	self2.AutoDetectDamageType(self)
	self2.AutoDetectForce(self)
	self2.AutoDetectPenetrationPower(self)
	self2.AutoDetectKnockback(self)
	self2.AutoDetectSpread(self)
	self2.AutoDetectRange(self)
	self2.AutoDetectLowAmmoSound(self)
	self2.IconFix(self)
	self2.CreateFireModes(self)
	self2.FixAkimbo(self)
	self2.FixSprintAnimBob(self)
	self2.FixWalkAnimBob(self)

	table.Merge(self.Primary, self.Primary_TFA)
	table.Merge(self.Secondary, self.Secondary_TFA)

	self.Primary_TFA.BaseClass = nil
	self.Secondary_TFA.BaseClass = nil

	self2.ClearStatCache(self)

	if not self2.IronSightsMoveSpeed then
		self2.IronSightsMoveSpeed = self2.MoveSpeed * 0.8
	end

	if self2.GetStat(self, "Skin") and isnumber(self2.GetStat(self, "Skin")) then
		self:SetSkin(self:GetStat("Skin"))
	end

	self:SetNextLoopSoundCheck(-1)
	self:SetShootStatus(TFA.Enum.SHOOT_IDLE)

	if SERVER and self:GetOwner():IsNPC() then
		local seq = self:GetOwner():LookupSequence("shootp1")

		if MeleeHoldTypes[self2.DefaultHoldType or self2.HoldType] then
			if self:GetOwner():GetSequenceName(seq) == "shootp1" then
				self:SetWeaponHoldType("melee2")
			else
				self:SetWeaponHoldType("melee")
			end
		elseif PistolHoldTypes[self2.DefaultHoldType or self2.HoldType] then
			if self:GetOwner():GetSequenceName(seq) == "shootp1" then
				self:SetWeaponHoldType("pistol")
			else
				self:SetWeaponHoldType("smg")
			end
		else
			self:SetWeaponHoldType(self2.DefaultHoldType or self2.HoldType)
		end

		if self:GetOwner():GetClass() == "npc_citizen" then
			self:GetOwner():Fire( "DisableWeaponPickup" )
		end

		self:GetOwner():SetKeyValue( "spawnflags", "256" )

		return
	end

	hook.Run("TFA_Initialize", self)
end

function SWEP:NPCWeaponThinkHook()
	local self2 = self:GetTable()

	if not self:GetOwner():IsNPC() then
		hook.Remove("TFA_NPCWeaponThink", self)
		return
	end

	self2.Think(self)
end

--[[
Function Name:  Deploy
Syntax: self:Deploy()
Notes:  Called after self:Initialize().  Called each time you draw the gun.  This is also essential to clearing out old networked vars and resetting them.
Returns:  True/False to allow quickswitch.  Why not?  You should really return true.
Purpose:  Standard SWEP Function
]]

function SWEP:Deploy()
	local self2 = self:GetTable()
	hook.Run("TFA_PreDeploy", self)
	local ply = self:GetOwner()

	self2.IsNPCOwned = ply:IsNPC()

	if IsValid(ply) and IsValid(ply:GetViewModel()) then
		self2.OwnerViewModel = ply:GetViewModel()
	end

	if SERVER and self:GetStat("FlashlightAttachment", 0) > 0 and IsValid(ply) and ply:IsPlayer() and ply:FlashlightIsOn() then
		if not self:GetFlashlightEnabled() then
			self:ToggleFlashlight(true)
		end

		ply:Flashlight(false)
	end

	ct = l_CT()

	if not self:VMIV() then
		print("Invalid VM on owner: ")
		print(ply)

		return
	end

	if not self2.HasDetectedValidAnimations then
		self:CacheAnimations()
	end

	local _, tanim = self:ChooseDrawAnim()

	if sp then
		self:CallOnClient("ChooseDrawAnim", "")
	end

	self:SetStatus(TFA.Enum.STATUS_DRAW)

	local len = self:GetActivityLength(tanim)

	self:SetStatusEnd(ct + len)
	self:SetNextPrimaryFire(ct + len)
	self:SetIronSightsRaw(false)

	if not self:GetStat("PumpAction") then
		self:SetShotgunCancel( false )
	end

	self:SetBurstCount(0)

	self:SetNW2Float("IronSightsProgress", 0)
	self:SetNW2Float("SprintProgress", 0)
	self:SetNW2Float("InspectingProgress", 0)
	self:SetNW2Float("ProceduralHolsterProgress", 0)

	if self:GetCustomizing() then
		self:ToggleCustomize()
	end

	self2.DefaultFOV = TFADUSKFOV or ( IsValid(ply) and ply:GetFOV() or 90 )

	if self:GetStat("Skin") and isnumber(self:GetStat("Skin")) then
		self2.OwnerViewModel:SetSkin(self:GetStat("Skin"))
		self:SetSkin(self:GetStat("Skin"))
	end

	self:InitAttachments()

	local v = hook.Run("TFA_Deploy", self)

	if v ~= nil then return v end

	return true
end

--[[
Function Name:  Holster
Syntax: self:Holster( weapon entity to switch to )
Notes:  This is kind of broken.  I had to manually select the new weapon using ply:ConCommand.  Returning true is simply not enough.  This is also essential to clearing out old networked vars and resetting them.
Returns:  True/False to allow holster.  Useful for animations.
Purpose:  Standard SWEP Function
]]
function SWEP:Holster(target)
	local self2 = self:GetTable()

	local v = hook.Run("TFA_PreHolster", self)
	if v ~= nil then return v end

	if not IsValid(target) then
		self2.InspectingProgress = 0

		return true
	end

	if not IsValid(self) then return end
	ct = l_CT()
	stat = self:GetStatus()

	if not TFA.Enum.HolsterStatus[stat] then
		if stat == TFA.GetStatus("reloading_wait") and self:Clip1() <= self:GetStat("Primary.ClipSize") and (not self:GetStat("DisableChambering")) and (not self:GetStat("Shotgun")) then
			self:ResetFirstDeploy()

			if sp then
				self:CallOnClient("ResetFirstDeploy", "")
			end
		end

		local success, tanim = self:ChooseHolsterAnim()

		if IsFirstTimePredicted() then
			self:SetSwapTarget(target)
		end

		self:SetStatus(TFA.Enum.STATUS_HOLSTER)

		if success then
			self:SetStatusEnd(ct + self:GetActivityLength(tanim))
		else
			self:SetStatusEnd(ct + self:GetStat("ProceduralHolsterTime") / self:GetAnimationRate(ACT_VM_HOLSTER))
		end

		return false
	elseif stat == TFA.Enum.STATUS_HOLSTER_READY or stat == TFA.Enum.STATUS_HOLSTER_FINAL then
		self:ResetViewModelModifications()

		return true
	end
end

function SWEP:FinishHolster()
	local self2 = self:GetTable()

	self:CleanParticles()

	local v2 = hook.Run("TFA_Holster", self)

	if self:GetOwner():IsNPC() then return end
	if v2 ~= nil then return v2 end

	if SERVER then
		local ent = self:GetSwapTarget()
		self:Holster(ent)

		if IsValid(ent) and ent:IsWeapon() then
			self:GetOwner():SelectWeapon(ent:GetClass())
			self2.OwnerViewModel = nil
		end
	end
end

--[[
Function Name:  OnRemove
Syntax: self:OnRemove()
Notes:  Resets bone mods and cleans up.
Returns:  Nil.
Purpose:  Standard SWEP Function
]]
function SWEP:OnRemove()
	local self2 = self:GetTable()

	if self2.CleanParticles then
		self2.CleanParticles(self)
	end

	if self2.ResetViewModelModifications then
		self2.ResetViewModelModifications(self)
	end

	return hook.Run("TFA_OnRemove", self)
end

--[[
Function Name:  OnDrop
Syntax: self:OnDrop()
Notes:  Resets bone mods and cleans up.
Returns:  Nil.
Purpose:  Standard SWEP Function
]]
function SWEP:OnDrop()
	local self2 = self:GetTable()

	if self2.CleanParticles then
		self2.CleanParticles(self)
	end

	-- if self2.ResetViewModelModifications then
	-- 	self:ResetViewModelModifications()
	-- end

	return hook.Run("TFA_OnDrop", self)
end

function SWEP:OwnerChanged() -- TODO: sometimes not called after switching weapon ???
	if not IsValid(self:GetOwner()) and self.ResetViewModelModifications then
		self:ResetViewModelModifications()
	end

	if SERVER then
		if self.IsNPCOwned and (not IsValid(self:GetOwner()) or not self:GetOwner():IsNPC()) then
			self:SetClip1(self:GetMaxClip1())
			self:SetClip2(self:GetMaxClip2())
		end
	end
end

--[[
Function Name:  Think
Syntax: self:Think()
Returns:  Nothing.
Notes:  This is blank.
Purpose:  Standard SWEP Function
]]
function SWEP:Think()
	local self2 = self:GetTable()
	self2.CalculateRatios(self)

	if self:GetOwner():IsNPC() and SERVER then
		if self2.ThinkNPC then self2.ThinkNPC(self) end
		self2.Think2(self, false)
	end
end

function SWEP:PlayerThink(plyv, is_working_out_prediction_errors)
	ft = TFA.FrameTime()

	if not self:NullifyOIV() then return end

	self:Think2(is_working_out_prediction_errors)
end

function SWEP:PlayerThinkCL(plyv)
	local self2 = self:GetTable()

	ft = TFA.FrameTime()

	if not self:NullifyOIV() then return end

	self:SmokePCFLighting()

	if sp then
		self:Think2(false)
	end

	if self2.GetStat(self, "BlowbackEnabled") then
		if not self2.Blowback_PistolMode or self:Clip1() == -1 or self:Clip1() > 0.1 or self2.Blowback_PistolMode_Disabled[self:GetLastActivity()] then
			self2.BlowbackCurrent = l_mathApproach(self2.BlowbackCurrent, 0, self2.BlowbackCurrent * ft * 15)
		end

		self2.BlowbackCurrentRoot = l_mathApproach(self2.BlowbackCurrentRoot, 0, self2.BlowbackCurrentRoot * ft * 15)
	end
end

--[[
Function Name:  Think2
Syntax: self:Think2().  Called from Think.
Returns:  Nothing.
Notes:  Essential for calling other important functions.
Purpose:  Standard SWEP Function
]]
function SWEP:Think2(is_working_out_prediction_errors)
	local self2 = self:GetTable()

	ct = l_CT()

	if not is_working_out_prediction_errors then
		if self2.LuaShellRequestTime > 0 and ct > self2.LuaShellRequestTime then
			self2.LuaShellRequestTime = -1
			self2.MakeShell(self)
		end

		if not self2.HasInitialized then
			self:Initialize()
		end

		if not self2.HasDetectedValidAnimations then
			self2.CacheAnimations(self)
			self2.ChooseDrawAnim(self)
		end

		self2.InitAttachments(self)

		self2.ProcessBodygroups(self)

		self2.ProcessEvents(self)
		self2.ProcessFireMode(self)
		self2.ProcessHoldType(self)
		self2.ReloadCV(self)
		self2.IronSightSounds(self)
		self2.ProcessLoopSound(self)
	end

	--if is_working_out_prediction_errors then return end

	if not sp or SERVER then
		self2.IronSights(self)
	end

	self2.ProcessStatus(self)
	self2.ProcessLoopFire(self)
	stat = self2.GetStatus(self)

	if not sp or SERVER then
		if ct > self:GetNextIdleAnim() and (TFA.Enum.ReadyStatus[stat] or (stat == TFA.Enum.STATUS_SHOOTING and TFA.Enum.ShootLoopingStatus[self:GetShootStatus()])) then
			self:ChooseIdleAnim()
		end
	end
end

function SWEP:IronSights()
	local self2 = self:GetTable()
	local owent = self:GetOwner()
	if not IsValid(owent) then return end

	ct = l_CT()
	stat = self:GetStatus()

	local issighting = false
	local issprinting = self:GetSprinting()
	local iswalking = self:GetWalking()

	local current_iron_sights = self:GetIronSightsRaw()
	local isplayer = owent:IsPlayer()

	local ironsights_toggle_cvar = (isplayer and owent:GetInfoNum("cl_tfa_ironsights_toggle", 0) or 0) == 1
	local ironsights_resight_cvar = (isplayer and owent:GetInfoNum("cl_tfa_ironsights_resight", 0) or 0) == 1

	if isplayer and (SERVER or not sp) and self2.GetStat(self, "data.ironsights") ~= 0 then
		if not ironsights_toggle_cvar then
			if owent:KeyDown(IN_ATTACK2) then
				issighting = true
			end
		else
			issighting = self:GetIronSightsRaw()

			if owent:KeyPressed(IN_ATTACK2) then
				issighting = not issighting
				self:SetIronSightsRaw(issighting)
			end
		end
	end

	if CLIENT and sp then
		issighting = self:GetIronSightsRaw()
	end

	if ironsights_toggle_cvar and not ironsights_resight_cvar then
		if issprinting then
			issighting = false
		end

		if not TFA.Enum.IronStatus[stat] then
			issighting = false
		end

		if self2.GetStat(self, "BoltAction") or self2.GetStat(self, "BoltAction_Forced") then
			if stat == TFA.Enum.STATUS_SHOOTING then
				if not self2.LastBoltShoot then
					self2.LastBoltShoot = l_CT()
				end

				if l_CT() > self2.LastBoltShoot + self2.BoltTimerOffset then
					issighting = false
				end
			elseif (stat == TFA.Enum.STATUS_IDLE and self:GetShotgunCancel(true)) or stat == TFA.Enum.STATUS_PUMP then
				issighting = false
			else
				self2.LastBoltShoot = nil
			end
		end
	end

	if issighting and isplayer and owent:InVehicle() and not owent:GetAllowWeaponsInVehicle() then
		issighting = false
		self:SetIronSightsRaw(false)
	end

	-- self:SetNW2Float("LastSightsStatusCached", false)
	local userstatus = issighting

	if current_iron_sights ~= issighting then
		self:SetIronSightsRaw(issighting)
	end

	if issprinting then
		issighting = false
	end

	if issighting and not TFA.Enum.IronStatus[stat] then
		issighting = false
	end

	if issighting and self:IsSafety() then
		issighting = false
	end

	if self2.GetStat(self, "BoltAction") or self2.GetStat(self, "BoltAction_Forced") then
		if stat == TFA.Enum.STATUS_SHOOTING then
			if not self2.LastBoltShoot then
				self2.LastBoltShoot = l_CT()
			end

			if l_CT() > self2.LastBoltShoot + self2.BoltTimerOffset then
				issighting = false
			end
		elseif (stat == TFA.Enum.STATUS_IDLE and self:GetShotgunCancel(true)) or stat == TFA.Enum.STATUS_PUMP then
			issighting = false
		else
			self2.LastBoltShoot = nil
		end
	end

	local old_iron_sights_final = self:GetNW2Bool("IronSightsOldFinal", false)

	if old_iron_sights_final ~= issighting and self2.Sights_Mode == TFA.Enum.LOCOMOTION_LUA then -- and stat == TFA.Enum.STATUS_IDLE then
		self:SetNextIdleAnim(-1)
	end

	local smi = (self2.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID or self2.Sights_Mode == TFA.Enum.LOCOMOTION_ANI)
		and old_iron_sights_final ~= issighting

	local spi = (self2.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or self2.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI)
		and self2.sprinting_updated

	local wmi = (self2.Walk_Mode == TFA.Enum.LOCOMOTION_HYBRID or self2.Walk_Mode == TFA.Enum.LOCOMOTION_ANI)
		and self2.walking_updated

	local cmi = (self2.Customize_Mode == TFA.Enum.LOCOMOTION_HYBRID or self2.Customize_Mode == TFA.Enum.LOCOMOTION_ANI)
		and self:GetNW2Bool("CustomizeUpdated", false)

	self:SetNW2Bool("CustomizeUpdated", false)

	if (smi or spi or wmi or cmi) and (self:GetStatus() == TFA.Enum.STATUS_IDLE or (self:GetStatus() == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting())) and not self:GetShotgunCancel() then
		local toggle_is = current_iron_sights ~= issighting

		if issighting and self:GetSprinting() then
			toggle_is = true
		end

		local success, _ = self:Locomote(toggle_is and (self2.Sights_Mode ~= TFA.Enum.LOCOMOTION_LUA), issighting, spi, issprinting, wmi, iswalking, cmi, self:GetCustomizing())

		if not success and (toggle_is and smi or spi or wmi or cmi) then
			self:SetNextIdleAnim(-1)
		end
	end

	self:SetNW2Bool("IronSightsOldFinal", issighting)

	return userstatus, issighting
end

function SWEP:GetIronSights()
	-- Is this code supposed to do something other than duplicating code of function above?
	--[==[local self2 = self:GetTable()

	if ignorestatus or not self:GetNW2Bool("LastSightsStatusCached", false) then
		-- local issighting = self:GetIronSightsRaw()
		local issighting = self:GetNW2Bool("IronSightsOldFinal")
		local issprinting = self:GetSprinting()
		local stat = self:GetStatus()

		if issprinting then
			issighting = false
		end

		if self:GetStat("BoltAction") or self:GetStat("BoltAction_Forced") then
			if stat == TFA.Enum.STATUS_SHOOTING then
				if not self2.LastBoltShoot then
					self2.LastBoltShoot = l_CT()
				end

				if l_CT() > self2.LastBoltShoot + self2.BoltTimerOffset then
					issighting = false
				end
			elseif (stat == TFA.Enum.STATUS_IDLE and self:GetShotgunCancel(true)) or stat == TFA.Enum.STATUS_PUMP then
				issighting = false
			else
				self2.LastBoltShoot = nil
			end
		end

		if not ignorestatus then
			self:SetNW2Bool("LastSightsStatus", issighting)
			self:SetNW2Bool("LastSightsStatusCached", true)

			--[[
			if (self2.is_cached_old ~= issighting) and not ( sp and CLIENT ) then
				if (issighting == false) then--and ((CLIENT and IsFirstTimePredicted()) or (SERVER and sp)) then
					self:EmitSound(self2.IronOutSound or "TFA.IronOut")
				elseif issighting == true then--and ((CLIENT and IsFirstTimePredicted()) or (SERVER and sp)) then
					self:EmitSound(self2.IronInSound or "TFA.IronIn")
				end
			end
			]]--

			self:SetNW2Bool("LastSightsStatusOld", issighting)
		end

		return issighting
	end

	return self:GetNW2Bool("LastSightsStatus", false)]==]

	return self:GetNW2Bool("IronSightsOldFinal")
end

function SWEP:GetIronSightsDirect()
	return self:GetNW2Bool("LastSightsStatus", false)
end

SWEP.is_sndcache_old = false

function SWEP:IronSightSounds()
	local self2 = self:GetTable()

	local is = self:GetIronSights()

	if SERVER or IsFirstTimePredicted() then
		if is ~= self2.is_sndcache_old and hook.Run("TFA_IronSightSounds", self) == nil then
			if is then
				self:EmitSound(self:GetStat("IronInSound", "TFA.IronIn"))
			else
				self:EmitSound(self:GetStat("IronOutSound", "TFA.IronOut"))
			end
		end

		self2.is_sndcache_old = is
	end
end

local legacy_reloads_cv = GetConVar("sv_tfa_reloads_legacy")
local dryfire_cvar = GetConVar("sv_tfa_allow_dryfire")

SWEP.Primary.Sound_DryFire = Sound("Weapon_Pistol.Empty2") -- dryfire sound, played only once
SWEP.Primary.Sound_DrySafety = Sound("Weapon_AR2.Empty2") -- safety click sound
SWEP.Primary.Sound_Blocked = Sound("Weapon_AR2.Empty") -- underwater click sound
SWEP.Primary.Sound_Jammed = Sound("Default.ClipEmpty_Rifle") -- jammed click sound

function SWEP:CanPrimaryAttack()
	local self2 = self:GetTable()

	local v = hook.Run("TFA_PreCanPrimaryAttack", self)

	if v ~= nil then
		return v
	end

	stat = self:GetStatus()

	if not TFA.Enum.ReadyStatus[stat] and stat ~= TFA.Enum.STATUS_SHOOTING then
		if self2.Shotgun and TFA.Enum.ReloadStatus[stat] then
			self:SetShotgunCancel(true)
		end

		return false
	end

	if self:IsSafety() then
		self:EmitSound(self:GetStat("Primary.Sound_DrySafety"))
		self2.LastSafetyShoot = self2.LastSafetyShoot or 0

		if l_CT() < self2.LastSafetyShoot + 0.2 then
			self:CycleSafety()
			self:SetNextPrimaryFire(l_CT() + 0.1)
		end

		self2.LastSafetyShoot = l_CT()

		return
	end

	if self:GetStat("Primary.ClipSize") <= 0 and self:Ammo1() < self:GetStat("Primary.AmmoConsumption") then
		return false
	end

	if self:GetSprinting() and not self:GetStat("AllowSprintAttack", false) then
		return false
	end

	if self:GetPrimaryClipSize(true) > 0 and self:Clip1() < self:GetStat("Primary.AmmoConsumption") then
		if self:GetOwner():IsNPC() or self:GetOwner():KeyPressed(IN_ATTACK) then
			local enabled, act = self:ChooseDryFireAnim()

			if enabled then
				self:SetNextPrimaryFire(l_CT() + self:GetStat("Primary.DryFireDelay", self:GetActivityLength(act, true)))

				return false
			end
		end

		if not self2.HasPlayedEmptyClick then
			self:EmitSound(self:GetStat("Primary.Sound_DryFire"))

			if not dryfire_cvar:GetBool() then
				self:Reload(true)
			end

			self2.HasPlayedEmptyClick = true
		end

		return false
	end

	if self2.FiresUnderwater == false and self:GetOwner():WaterLevel() >= 3 then
		self:SetNextPrimaryFire(l_CT() + 0.5)
		self:EmitSound(self:GetStat("Primary.Sound_Blocked"))
		return false
	end

	self2.HasPlayedEmptyClick = false

	if l_CT() < self:GetNextPrimaryFire() then return false end

	local v2 = hook.Run("TFA_CanPrimaryAttack", self)

	if v2 ~= nil then
		return v2
	end

	if self:CheckJammed() then
		if IsFirstTimePredicted() then
			self:EmitSound(self:GetStat("Primary.Sound_Jammed"))
		end

		local typev, tanim = self:ChooseAnimation("shoot1_empty")

		if typev ~= TFA.Enum.ANIMATION_SEQ then
			self:SendViewModelAnim(tanim)
		else
			self:SendViewModelSeq(tanim)
		end

		self:SetNextPrimaryFire(l_CT() + 1)

		return false
	end

	return true
end

function SWEP:EmitGunfireLoop()
	local self2 = self:GetTable()
	local tgtSound = self:GetSilenced() and self:GetStat("Primary.LoopSoundSilenced", self:GetStat("Primary.LoopSound")) or self:GetStat("Primary.LoopSound")

	if self:GetNextLoopSoundCheck() < 0 or (l_CT() >= self:GetNextLoopSoundCheck() and self2.LastLoopSound ~= tgtSound) then
		if self2.LastLoopSound ~= tgtSound and self2.LastLoopSound ~= nil then
			self:StopSound(self2.LastLoopSound)
		end

		self2.LastLoopSound = tgtSound

		self:EmitSound(tgtSound)
	end

	self:SetNextLoopSoundCheck(CurTime() + self:GetFireDelay())
end

function SWEP:EmitGunfireSound(soundscript)
	self:EmitSound(soundscript)
end

local sv_tfa_nearlyempty = GetConVar("sv_tfa_nearlyempty")

SWEP.LowAmmoSoundThreshold = 0.33

function SWEP:EmitLowAmmoSound()
	if not sv_tfa_nearlyempty:GetBool() then return end

	local self2 = self:GetTable()

	if not self2.FireSoundAffectedByClipSize then return end

	local clip1, maxclip1 = self:Clip1(), self:GetMaxClip1()

	if maxclip1 <= 4 or maxclip1 >= 70 or clip1 <= 0 then return end

	local mult = clip1 / maxclip1
	if mult >= self2.LowAmmoSoundThreshold or mult <= 0 then return end

	local soundname = ((clip1 - (self:GetStat("Primary.AmmoConsumption", 1) * (self:GetStat("Akimbo") and 2 or 1))) <= 0) and self:GetStat("LastAmmoSound", "") or self:GetStat("LowAmmoSound", "")

	if soundname and soundname ~= "" then
		self2.GonnaAdjustVol = true
		self2.RequiredVolume = 1 - (mult / math.max(self2.LowAmmoSoundThreshold, 0.01))

		self:EmitSound(soundname)
	end
end

function SWEP:PrimaryAttack()
	local self2 = self:GetTable()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	self:PrePrimaryAttack()

	if not IsValid(self) then return end
	if ply:IsPlayer() and not self:VMIV() then return end
	if not self:CanPrimaryAttack() then return end

	if hook.Run("TFA_PrimaryAttack", self) then return end

	if TFA.Enum.ShootReadyStatus[self:GetShootStatus()] then
		self:SetShootStatus(TFA.Enum.SHOOT_IDLE)
	end

	if self2.CanBeSilenced and (ply.KeyDown and ply:KeyDown(IN_USE)) and (SERVER or not sp) then
		self:ChooseSilenceAnim(not self:GetSilenced())
		local _, tanim = self:SetStatus(TFA.Enum.STATUS_SILENCER_TOGGLE)
		self:SetStatusEnd(l_CT() + self:GetActivityLength(tanim, true))

		return
	end

	self:SetNextPrimaryFire(l_CT() + self:GetFireDelay())

	if self:GetMaxBurst() > 1 then
		self:SetBurstCount(math.max(1, self:GetBurstCount() + 1))
	end

	if self:GetStat("PumpAction") and self:GetShotgunCancel() then return end

	self:SetStatus(TFA.Enum.STATUS_SHOOTING)
	self:SetStatusEnd(self:GetNextPrimaryFire())
	self:ToggleAkimbo()

	local _, tanim = self:ChooseShootAnim(IsFirstTimePredicted())

	if (not sp) or (not self:IsFirstPerson()) then
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	end

	if self:GetStat("Primary.Sound") and IsFirstTimePredicted() and not (sp and CLIENT) then
		if self:GetOwner():IsPlayer() and self:GetStat("Primary.LoopSound") and (not self:GetStat("Primary.LoopSoundAutoOnly", false) or self2.Primary_TFA.Automatic) then
			self:EmitGunfireLoop()
		elseif self:GetStat("Primary.SilencedSound") and self:GetSilenced() then
			self:EmitGunfireSound(self:GetStat("Primary.SilencedSound"))
		else
			self:EmitGunfireSound(self:GetStat("Primary.Sound"))
		end

		self:EmitLowAmmoSound()
	end

	self:TakePrimaryAmmo(self:GetStat("Primary.AmmoConsumption"))

	if self:Clip1() == 0 and self:GetStat("Primary.ClipSize") > 0 then
		self:SetNextPrimaryFire(math.max(self:GetNextPrimaryFire(), l_CT() + (self2.Primary_TFA.DryFireDelay or self:GetActivityLength(tanim, true))))
	end

	self:ShootBulletInformation()
	self:UpdateJamFactor()
	local _, CurrentRecoil = self:CalculateConeRecoil()
	self:Recoil(CurrentRecoil, IsFirstTimePredicted())

	if sp and SERVER then
		self:CallOnClient("Recoil", "")
	end

	if self2.MuzzleFlashEnabled and (not self:IsFirstPerson() or not self2.AutoDetectMuzzleAttachment) then
		self:ShootEffectsCustom()
	end

	if self2.EjectionSmoke and CLIENT and self:GetOwner() == LocalPlayer() and IsFirstTimePredicted() and not self2.LuaShellEject then
		self:EjectionSmoke()
	end

	self:DoAmmoCheck()

	if self:GetStatus() == TFA.GetStatus("shooting") and self:GetStat("PumpAction") then
		if self:Clip1() == 0 and self:GetStat("PumpAction").value_empty then
			self:SetShotgunCancel(true)
		elseif (self:GetStat("Primary.ClipSize") < 0 or self:Clip1() > 0) and self:GetStat("PumpAction").value then
			self:SetShotgunCancel(true)
		end
	end

	if IsFirstTimePredicted() then
		self:RollJamChance()
	end

	self:PostPrimaryAttack()
	hook.Run("TFA_PostPrimaryAttack", self)
end

function SWEP:PrePrimaryAttack()
	-- override
end

function SWEP:PostPrimaryAttack()
	-- override
end

function SWEP:CanSecondaryAttack()
	-- override
end

function SWEP:SecondaryAttack()
	self:PreSecondaryAttack()

	if hook.Run("TFA_SecondaryAttack", self) then return end

	if self:GetStat("data.ironsights", 0) == 0 and self.AltAttack and self:GetOwner():IsPlayer() then
		self:AltAttack()
		self:PostSecondaryAttack()
		return
	end

	self:PostSecondaryAttack()
end

function SWEP:PreSecondaryAttack()
	-- override
end

function SWEP:PostSecondaryAttack()
	-- override
end

function SWEP:GetLegacyReloads()
	return legacy_reloads_cv:GetBool()
end

function SWEP:Reload(released)
	local self2 = self:GetTable()

	self:PreReload(released)

	if hook.Run("TFA_PreReload", self, released) then return end

	local isplayer = self:GetOwner():IsPlayer()
	local vm = self:VMIV()

	if isplayer and not vm then return end

	if not self:IsJammed() then
		if self:Ammo1() <= 0 then return end
		if self:GetStat("Primary.ClipSize") < 0 then return end
	end

	if not released and not self:GetLegacyReloads() then return end
	if self:GetLegacyReloads() and not dryfire_cvar:GetBool() and not self:GetOwner():KeyDown(IN_RELOAD) then return end
	if self:GetOwner():KeyDown(IN_USE) then return end

	ct = l_CT()
	stat = self:GetStatus()

	if self:GetStat("PumpAction") and self:GetShotgunCancel() then
		if stat == TFA.Enum.STATUS_IDLE then
			self:DoPump()
		end
	elseif TFA.Enum.ReadyStatus[stat] or ( stat == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting() ) or self:IsJammed() then
		if self:Clip1() < self:GetPrimaryClipSize() or self:IsJammed() then
			if hook.Run("TFA_Reload", self) then return end
			self:SetBurstCount(0)

			if self2.Shotgun then
				local _, tanim = self:ChooseShotgunReloadAnim()

				if self:GetStat("ShotgunStartAnimShell") then
					self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL)
				elseif self2.ShotgunEmptyAnim then
					local _, tg = self:ChooseAnimation( "reload_empty" )
					local action = tanim

					if type(tg) == "string" and tonumber(tanim) and tonumber(tanim) > 0 and isplayer then
						action = vm:GetSequenceName(vm:SelectWeightedSequenceSeeded(tanim, self:GetSeed()))
					end

					if action == tg and self:GetStat("ShotgunEmptyAnim_Shell") then
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL)
					else
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
					end
				else
					self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
				end

				self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ))
				--self:SetNextPrimaryFire(ct + self:GetActivityLength( tanim, false ) )
			else
				local _, tanim = self:ChooseReloadAnim()

				self:SetStatus(TFA.Enum.STATUS_RELOADING)

				if self:GetStat("ProceduralReloadEnabled") then
					self:SetStatusEnd(ct + self:GetStat("ProceduralReloadTime"))
				else
					self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ) )
					self:SetNextPrimaryFire(ct + self:GetActivityLength( tanim, false ) )
				end
			end

			if not sp or not self:IsFirstPerson() then
				self:GetOwner():SetAnimation(PLAYER_RELOAD)
			end

			if self:GetStat("Primary.ReloadSound") and IsFirstTimePredicted() then
				self:EmitSound(self:GetStat("Primary.ReloadSound"))
			end

			self:SetNextPrimaryFire( -1 )
		elseif released or self:GetOwner():KeyPressed(IN_RELOAD) then--if self:GetOwner():KeyPressed(IN_RELOAD) or not self:GetLegacyReloads() then
			self:CheckAmmo()
		end
	end

	self:PostReload(released)

	hook.Run("TFA_PostReload", self)
end

function SWEP:PreReload(released)
	-- override
end

function SWEP:PostReload(released)
	-- override
end

function SWEP:Reload2(released)
	local self2 = self:GetTable()

	local ply = self:GetOwner()
	local isplayer = ply:IsPlayer()
	local vm = self:VMIV()

	if isplayer and not vm then return end

	if self:Ammo2() <= 0 then return end
	if self:GetStat("Secondary.ClipSize") < 0 then return end
	if not released and not self:GetLegacyReloads() then return end
	if self:GetLegacyReloads() and not  dryfire_cvar:GetBool() and not ply:KeyDown(IN_RELOAD) then return end
	if isplayer and ply:KeyDown(IN_USE) then return end

	ct = l_CT()
	stat = self:GetStatus()

	if self:GetStat("PumpAction") and self:GetShotgunCancel() then
		if stat == TFA.Enum.STATUS_IDLE then
			self:DoPump()
		end
	elseif TFA.Enum.ReadyStatus[stat] or ( stat == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting() ) then
		if self:Clip2() < self:GetSecondaryClipSize() then
			if self2.Shotgun then
				local _, tanim = self:ChooseShotgunReloadAnim()

				if self2.ShotgunEmptyAnim  then
					local _, tg = self:ChooseAnimation( "reload_empty" )

					if tanim == tg and self2.ShotgunEmptyAnim_Shell then
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL)
					else
						self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
					end
				else
					self:SetStatus(TFA.Enum.STATUS_RELOADING_SHOTGUN_START)
				end

				self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ))
				--self:SetNextPrimaryFire(ct + self:GetActivityLength( tanim, false ) )
			else
				local _, tanim = self:ChooseReloadAnim()

				self:SetStatus(TFA.Enum.STATUS_RELOADING)

				if self:GetStat("ProceduralReloadEnabled") then
					self:SetStatusEnd(ct + self:GetStat("ProceduralReloadTime"))
				else
					self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ) )
					self:SetNextPrimaryFire(ct + self:GetActivityLength( tanim, false ) )
				end
			end

			if not sp or not self:IsFirstPerson() then
				ply:SetAnimation(PLAYER_RELOAD)
			end

			if self:GetStat("Secondary.ReloadSound") and IsFirstTimePredicted() then
				self:EmitSound(self:GetStat("Secondary.ReloadSound"))
			end

			self:SetNextPrimaryFire( -1 )
		elseif released or ply:KeyPressed(IN_RELOAD) then--if ply:KeyPressed(IN_RELOAD) or not self:GetLegacyReloads() then
			self:CheckAmmo()
		end
	end
end

function SWEP:DoPump()
	if hook.Run("TFA_Pump", self) then return end

	local _, tanim = self:PlayAnimation(self:GetStat("PumpAction"))

	self:SetStatus(TFA.GetStatus("pump"))
	self:SetStatusEnd(l_CT() + self:GetActivityLength(tanim, true))
	self:SetNextPrimaryFire(l_CT() + self:GetActivityLength(tanim, false))
	self:SetNextIdleAnim(math.max(self:GetNextIdleAnim(), l_CT() + self:GetActivityLength(tanim, false)))
end

function SWEP:LoadShell()
	if hook.Run("TFA_LoadShell", self) then return end

	local _, tanim = self:ChooseReloadAnim()

	if self:GetActivityLength(tanim,true) < self:GetActivityLength(tanim,false) then
		self:SetStatusEnd(ct + self:GetActivityLength(tanim, true))
	else
		local sht = self:GetStat("ShellTime")
		if sht then sht = sht / self:GetAnimationRate(ACT_VM_RELOAD) end
		self:SetStatusEnd(ct + ( sht or self:GetActivityLength(tanim, true)))
	end

	return TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP
end

function SWEP:CompleteReload()
	if hook.Run("TFA_CompleteReload", self) then return end

	local maxclip = self:GetPrimaryClipSizeForReload(true)
	local curclip = self:Clip1()
	local amounttoreplace = math.min(maxclip - curclip, self:Ammo1())
	self:TakePrimaryAmmo(amounttoreplace * -1)
	self:TakePrimaryAmmo(amounttoreplace, true)
	self:SetJammed(false)
end

function SWEP:CheckAmmo()
	if hook.Run("TFA_CheckAmmo", self) then return end

	local self2 = self:GetTable()

	if self2.GetIronSights(self) or self2.GetSprinting(self) then return end

	--if self2.NextInspectAnim == nil then
	--  self2.NextInspectAnim = -1
	--end

	if self:GetOwner().GetInfoNum and self:GetOwner():GetInfoNum("cl_tfa_keys_inspect", 0) > 0 then
		return
	end

	if (self:GetActivityEnabled(ACT_VM_FIDGET) or self2.InspectionActions) and self:GetStatus() == TFA.Enum.STATUS_IDLE then--and CurTime() > self2.NextInspectAnim then
		local _, tanim = self:ChooseInspectAnim()
		self:SetStatus(TFA.GetStatus("fidget"))
		self:SetStatusEnd(l_CT() + self:GetActivityLength(tanim))
	end
end

local cv_strip = GetConVar("sv_tfa_weapon_strip")

function SWEP:DoAmmoCheck()
	if self:GetOwner():IsNPC() then return end
	local self2 = self:GetTable()

	if IsValid(self) and SERVER and cv_strip:GetBool() and self:Clip1() == 0 and self:Ammo1() == 0 then
		timer.Simple(.1, function()
			if SERVER and IsValid(self) and self:OwnerIsValid() then
				self:GetOwner():StripWeapon(self2.ClassName)
			end
		end)
	end
end

--[[
Function Name:  AdjustMouseSensitivity
Syntax: Should not normally be called.
Returns:  SWEP sensitivity multiplier.
Purpose:  Standard SWEP Function
]]

local fovv
local sensval
local sensitivity_cvar, sensitivity_fov_cvar, sensitivity_speed_cvar
if CLIENT then
	sensitivity_cvar = GetConVar("cl_tfa_scope_sensitivity")
	sensitivity_fov_cvar = GetConVar("cl_tfa_scope_sensitivity_autoscale")
	sensitivity_speed_cvar = GetConVar("sv_tfa_scope_gun_speed_scale")
end

function SWEP:AdjustMouseSensitivity()
	sensval = 1

	if self:GetIronSights() then
		sensval = sensval * sensitivity_cvar:GetFloat() / 100

		if sensitivity_fov_cvar:GetBool() then
			fovv = self:GetStat("Secondary.IronFOV") or 70
			sensval = sensval * TFA.CalculateSensitivtyScale( fovv, nil, 1 )
		else
			sensval = sensval
		end

		if sensitivity_speed_cvar:GetFloat() then
			sensval = sensval * self:GetStat("IronSightsMoveSpeed")
		end
	end

	sensval = sensval * l_Lerp(self:GetNW2Float("IronSightsProgress"), 1, self:GetStat( "IronSightsSensitivity" ) )
	return sensval
end

--[[
Function Name:  TranslateFOV
Syntax: Should not normally be called.  Takes default FOV as parameter.
Returns:  New FOV.
Purpose:  Standard SWEP Function
]]

function SWEP:TranslateFOV(fov)
	local self2 = self:GetTable()

	self2.LastTranslatedFOV = fov

	local retVal = hook.Run("TFA_PreTranslateFOV", self,fov)

	if retVal then return retVal end

	self:CorrectScopeFOV()

	local nfov = l_Lerp(self:GetNW2Float("IronSightsProgress"), fov, fov * math.min(self:GetStat("Secondary.IronFOV") / 90, 1))
	local ret = l_Lerp(self:GetNW2Float("SprintProgress"), nfov, nfov + self2.SprintFOVOffset)

	if self:OwnerIsValid() and not self2.IsMelee then
		local vpa = self:GetOwner():GetViewPunchAngles()

		ret = ret + math.abs(vpa.p) / 4 + math.abs(vpa.y) / 4 + math.abs(vpa.r) / 4
	end

	if CLIENT then
		self2.LastTranslatedFOV2 = Lerp(RealFrameTime() * 3, self2.LastTranslatedFOV2 or ret, ret)
		ret = self2.LastTranslatedFOV2
	end

	ret = hook.Run("TFA_TranslateFOV", self,ret) or ret

	return ret
end

function SWEP:GetPrimaryAmmoType()
	return self:GetStat("Primary.Ammo") or ""
end

function SWEP:ToggleInspect()
	if self:GetOwner():IsNPC() then return false end -- NPCs can't look at guns silly

	local self2 = self:GetTable()

	if (self:GetSprinting() or self:GetIronSights() or self:GetStatus() ~= TFA.Enum.STATUS_IDLE) and not self:GetCustomizing() then return end

	self:SetCustomizing(not self:GetCustomizing())
	self2.Inspecting = self:GetCustomizing()
	self:SetNW2Bool("CustomizeUpdated", true)

	--if self2.Inspecting then
	--  gui.EnableScreenClicker(true)
	--else
	--  gui.EnableScreenClicker(false)
	--end

	return self:GetCustomizing()
end

SWEP.ToggleCustomize = SWEP.ToggleInspect

function SWEP:GetIsInspecting()
	return self:GetCustomizing()
end

function SWEP:CustomizingUpdated(_, old, new)
	if old ~= new and self._inspect_hack ~= new then
		self._inspect_hack = new

		if new then
			self:OnCustomizationOpen()
		else
			self:OnCustomizationClose()
		end
	end
end

function SWEP:OnCustomizationOpen()
	-- override
	-- example:
	--[[
		if CLIENT then surface.PlaySound("ui/buttonclickrelease.wav") end
	]]
end

function SWEP:OnCustomizationClose()
	-- override
end

function SWEP:EmitSoundNet(sound)
	if CLIENT or sp then
		if sp and not IsFirstTimePredicted() then return end

		self:EmitSound(sound)

		return
	end

	local filter = RecipientFilter()
	filter:AddPAS(self:GetPos())

	if IsValid(self:GetOwner()) then
		filter:RemovePlayer(self:GetOwner())
	end

	net.Start("tfaSoundEvent")
	net.WriteEntity(self)
	net.WriteString(sound)
	net.Send(filter)
end

function SWEP:CanBeJammed()
	return self.CanJam and self:GetMaxClip1() > 0 and sv_tfa_jamming:GetBool()
end

-- Use this to increase/decrease factor added based on ammunition/weather conditions/etc
function SWEP:GrabJamFactorMult()
	return 1 -- override
end

function SWEP:UpdateJamFactor()
	local self2 = self:GetTable()
	if not self:CanBeJammed() then return self end
	self:SetJamFactor(math.min(100, self:GetJamFactor() + self2.JamFactor * sv_tfa_jamming_factor_inc:GetFloat() * self:GrabJamFactorMult()))
	return self
end

function SWEP:IsJammed()
	if not self:CanBeJammed() then return false end
	return self:GetJammed()
end

function SWEP:NotifyJam()
	local ply = self:GetOwner()

	if IsValid(ply) and ply:IsPlayer() and IsFirstTimePredicted() and (not ply._TFA_LastJamMessage or ply._TFA_LastJamMessage < RealTime()) then
		ply:PrintMessage(HUD_PRINTCENTER, "#tfa.msg.weaponjammed")
		ply._TFA_LastJamMessage = RealTime() + 4
	end
end

function SWEP:CheckJammed()
	if not self:IsJammed() then return false end
	self:NotifyJam()
	return true
end

function SWEP:RollJamChance()
	if not self:CanBeJammed() then return false end
	if self:IsJammed() then return true end

	local chance = self:GetJamChance()
	local roll = util.SharedRandom('tfa_base_jam', math.max(0.002711997795105, math.pow(chance, 1.19)), 1, l_CT())

	if roll <= chance * sv_tfa_jamming_mult:GetFloat() then
		self:SetJammed(true)
		self:NotifyJam()
		return true
	end

	return false
end

function SWEP:GrabJamChanceMult()
	return 1 -- override
end

function SWEP:GetJamChance()
	-- you can safely override this with your own logic if you desire
	local self2 = self:GetTable()
	if not self:CanBeJammed() then return 0 end
	return self:GetJamFactor() * sv_tfa_jamming_factor:GetFloat() * (self2.JamChance / 100) * self:GrabJamChanceMult()
end

SWEP.FlashlightSoundToggleOn = Sound("HL2Player.FlashLightOn")
SWEP.FlashlightSoundToggleOff = Sound("HL2Player.FlashLightOff")

function SWEP:ToggleFlashlight(toState)
	if toState == nil then
		toState = not self:GetFlashlightEnabled()
	end

	self:SetFlashlightEnabled(toState)
	self:EmitSoundNet(self:GetStat("FlashlightSoundToggle" .. (toState and "On" or "Off")))
end

-- source engine save load
function SWEP:OnRestore()
	local self2 = self:GetTable()
	self2.HasInitialized = false
	self2.HasInitAttachments = false
end

-- lua autorefresh
function SWEP:OnReloaded()
	table.Merge(self.Primary_TFA, self.Primary)
	table.Merge(self.Secondary_TFA, self.Secondary)

	local self2 = self:GetTable()
	self2.AutoDetectMuzzle(self)
	self2.AutoDetectDamage(self)
	self2.AutoDetectDamageType(self)
	self2.AutoDetectForce(self)
	self2.AutoDetectPenetrationPower(self)
	self2.AutoDetectKnockback(self)
	self2.AutoDetectSpread(self)
	self2.AutoDetectRange(self)
	self2.ClearStatCache(self)
end

function SWEP:ProcessLoopSound()
	if (SERVER or not sp) and (
			self:GetNextLoopSoundCheck() >= 0
			and ct > self:GetNextLoopSoundCheck()
			and self:GetStatus() ~= TFA.Enum.STATUS_SHOOTING
		) then

		self:SetNextLoopSoundCheck(-1)

		local tgtSound = self:GetSilenced() and self:GetStat("Primary.LoopSoundSilenced", self:GetStat("Primary.LoopSound")) or self:GetStat("Primary.LoopSound")

		if tgtSound then
			self:StopSound(tgtSound)
		end

		tgtSound = self:GetSilenced() and self:GetStat("Primary.LoopSoundTailSilenced", self:GetStat("Primary.LoopSoundTail")) or self:GetStat("Primary.LoopSoundTail")

		if tgtSound then
			self:EmitSound(tgtSound)
		end
	end
end

function SWEP:ProcessLoopFire()
	local self2 = self:GetTable()
	if sp and not IsFirstTimePredicted() then return end
	if (self:GetStatus() == TFA.Enum.STATUS_SHOOTING ) then
		if TFA.Enum.ShootLoopingStatus[self:GetShootStatus()] then
			self:SetShootStatus(TFA.Enum.SHOOT_LOOP)
		end
	else --not shooting
		if (not TFA.Enum.ShootReadyStatus[self:GetShootStatus()]) then
			if ( self:GetShootStatus() ~= TFA.Enum.SHOOT_CHECK ) then
				self:SetShootStatus(TFA.Enum.SHOOT_CHECK) --move to check first
			else --if we've checked for one more tick that we're not shooting
				self:SetShootStatus(TFA.Enum.SHOOT_IDLE) --move to check first
				if not ( self:GetSprinting() and self2.Sprint_Mode ~= TFA.Enum.LOCOMOTION_LUA ) then --assuming we don't need to transition into sprint
					self:PlayAnimation(self:GetStat("ShootAnimation.out")) --exit
				end
			end
		end
	end
end
