--[[Define Modules]]
SWEP.SV_MODULES = {}
SWEP.SH_MODULES = {"sh_anims.lua", "sh_autodetection.lua", "sh_utils.lua", "sh_attachments.lua", "sh_bullet.lua", "sh_effects.lua", "sh_bobcode.lua", "sh_calc.lua", "sh_akimbo.lua", "sh_events.lua", "sh_nzombies.lua", "sh_ttt.lua", "sh_vm.lua" }
SWEP.ClSIDE_MODULES = { "cl_effects.lua", "cl_viewbob.lua", "cl_hud.lua", "cl_mods.lua", "cl_laser.lua" }
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
SWEP.ShellTime = nil

SWEP.data = {}
SWEP.data.ironsights = 1

SWEP.MoveSpeed = 1
SWEP.IronSightsMoveSpeed = nil

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
SWEP.Primary.MaxPenetration = 2
SWEP.Primary.Range = -1--1200
SWEP.Primary.RangeFalloff = -1--0.5
SWEP.Primary.PenetrationMultiplier = 1
SWEP.Primary.DryFireDelay = nil

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
SWEP.SequenceRateOverride = {} --Like above but changes animation length to a target
SWEP.SequenceRateOverrideScaled = {} --Like above but scales animation length rather than being absolute

SWEP.BlowbackEnabled = false --Enable Blowback?
SWEP.BlowbackVector = Vector(0, -1, 0) --Vector to move bone <or root> relative to bone <or view> orientation.
SWEP.BlowbackCurrentRoot = 0 --Amount of blowback currently, for root
SWEP.BlowbackCurrent = 0 --Amount of blowback currently, for bones
SWEP.BlowbackBoneMods = nil --Viewmodel bone mods via SWEP Creation Kit
SWEP.Blowback_Only_Iron = true --Only do blowback on ironsights
SWEP.Blowback_PistolMode = false --Do we recover from blowback when empty?

SWEP.ProceduralHoslterEnabled = nil
SWEP.ProceduralHolsterTime = 0.3
SWEP.ProceduralHolsterPos = Vector(3, 0, -5)
SWEP.ProceduralHolsterAng = Vector(-40, -30, 10)

SWEP.ProceduralReloadEnabled = false --Do we reload using lua instead of a .mdl animation
SWEP.ProceduralReloadTime = 1 --Time to take when procedurally reloading, including transition in (but not out)

ACT_VM_FIDGET_EMPTY = ACT_VM_FIDGET_EMPTY or ACT_CROSSBOW_FIDGET_UNLOADED

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

SWEP.VMPos = Vector(0,0,0)
SWEP.VMAng = Vector(0,0,0)
SWEP.CameraOffset = Angle(0, 0, 0)
SWEP.VMPos_Additive = true

local vm_offset_pos = Vector()
local vm_offset_ang = Angle()

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

SWEP.FirstDeployEnabled = nil--Force first deploy enabled

--[[Dont edit under this unless you know what u r doing]]

SWEP.IronSightsProgress = 0
SWEP.SprintProgress = 0
SWEP.SpreadRatio = 0
SWEP.CrouchingRatio = 0
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

for k, v in pairs(SWEP.SmokeParticles) do
	PrecacheParticleSystem(v)
end

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
local l_mathClamp = math.Clamp
local l_CT = CurTime
local l_FT = FrameTime

--[[
Function Name:  QerpAngle
Syntax: QerpAngle(progress, starting value, ending value, period)
Returns:  The quadratically interpolated angle.
Purpose:  Utility function / Animation
]]
local l_NormalizeAngle = math.NormalizeAngle
local LerpAngle = LerpAngle

local function util_NormalizeAngles(a)
	a.p = l_NormalizeAngle(a.p)
	a.y = l_NormalizeAngle(a.y)
	a.r = l_NormalizeAngle(a.r)

	return a
end

--[[Localize Functions]]
local l_ct = CurTime
--[[Frequently Reused Local Vars]]
local success --Used for animations
local stat, statend --Weapon status
local ct, ft, rft --Curtime, frametime, real frametime
ft = 0.01
local sp --Singleplayer

local host_timescale_cv = GetConVar("host_timescale")
local sv_cheats_cv = GetConVar("sv_cheats")

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
	self:NetworkVar("Float", 0, "StatusEnd")
	self:NetworkVar("Float", 1, "NextIdleAnim")
	self:NetworkVar("Int", 0, "Status")
	self:NetworkVar("Int", 1, "FireMode")
	self:NetworkVar("Int", 2, "LastActivity")
	self:NetworkVar("Int", 3, "BurstCount")
	self:NetworkVar("Entity", 0, "SwapTarget")
end

--[[
Function Name:  Initialize
Syntax: Should not be normally called.
Notes:   Called after actual SWEP code, but before deploy, and only once.
Returns:  Nothing.  Sets the intial values for the SWEP when it's created.
Purpose:  Standard SWEP Function
]]
sp = game.SinglePlayer()

local nzombies = string.lower( engine.ActiveGamemode() or "" ) == "nzombies"

function SWEP:Initialize()
	self.DrawCrosshairDefault = self.DrawCrosshair
	self.HasInitialized = true
	if ( not self.BobScaleCustom ) or self.BobScaleCustom <= 0 then
		self.BobScaleCustom = 1
	end
	self.BobScale = 0
	self.SwayScaleCustom = 1
	self.SwayScale = 0
	self:SetSilenced( self.Silenced or self.DefaultSilenced )
	self.Silenced = self.Silenced or self.DefaultSilenced
	self:PatchAmmoTypeAccessors()
	self:FixRPM()
	self:FixIdles()
	self:FixIS()
	self:FixProceduralReload()
	self:FixCone()
	self:FixProjectile()
	self:AutoDetectMuzzle()
	self:AutoDetectDamage()
	self:AutoDetectDamageType()
	self:AutoDetectForce()
	self:AutoDetectKnockback()
	self:AutoDetectSpread()
	self:AutoDetectRange()
	self:IconFix()
	self:CreateFireModes()
	self:FixAkimbo()
	self:PathStatsTable('Primary')
	self:PathStatsTable('Secondary')
	self:ClearStatCache()

	if not self.IronSightsMoveSpeed then
		self.IronSightsMoveSpeed = self.MoveSpeed * 0.8
	end

	if self:GetStat("Skin") and isnumber(self:GetStat("Skin")) then
		self:SetSkin(self:GetStat("Skin"))
	end

	if nzombies then
		self:NZDeploy()
	end

	if SERVER then
		if self.Owner:IsNPC() then
			local seq = self.Weapon.Owner:LookupSequence("shootp1")
			if self.Weapon.Owner:GetSequenceName(seq) == "shootp1" then
				self:SetWeaponHoldType("pistol")
			else
				self:SetWeaponHoldType("ar2")
			end
			if self.Owner:GetClass() == "npc_citizen" then
				self.Weapon.Owner:Fire( "DisableWeaponPickup" )
			end
			self.Weapon.Owner:SetKeyValue( "spawnflags", "256" )
			return
		end
	end
end

function SWEP:PathStatsTable(statID)
	local tableDest = self[statID]
	local tableCopy = table.Copy(tableDest)
	self[statID .. '_TFA'] = tableCopy
	local ammo = statID .. '.Ammo'
	local clipSize = statID .. '.ClipSize'
	local defaultClip = statID .. '.DefaultClip'
	local automatic = statID .. '.Automatic'
	table.Empty(tableDest)

	local ignore = false

	local function ignoreHack(key)
		if key == 'Ammo' then
			return self:GetStat(ammo)
		elseif key == 'ClipSize' then
			return self:GetStat(clipSize)
		elseif key == 'DefaultClip' then
			return self:GetStat(defaultClip)
		elseif key == 'Automatic' then
			return self:GetStat(automatic)
		else
			return tableCopy[key]
		end
	end

	self[statID] = setmetatable(tableDest, {
		__index = function(_, key)
			if ignore then return tableCopy[key] end
			ignore = true
			local val = ignoreHack(key)
			ignore = false
			return val
		end,
		
		__newindex = function(_, key, value)
			tableCopy[key] = value
		end
	})
end

function SWEP:Equip( ... )
	self.OwnerViewModel = nil
	self:EquipTTT(  ... )
end

--[[
Function Name:  Deploy
Syntax: self:Deploy()
Notes:  Called after self:Initialize().  Called each time you draw the gun.  This is also essential to clearing out old networked vars and resetting them.
Returns:  True/False to allow quickswitch.  Why not?  You should really return true.
Purpose:  Standard SWEP Function
]]

function SWEP:Deploy()

	if engine.ActiveGamemode() == "terrortown" and IsValid(self:GetOwner()) and IsValid(self:GetOwner():GetViewModel()) then
		self.OwnerViewModel = self:GetOwner():GetViewModel()
		self.OwnerViewModel:SetModel(self.ViewModel)
	end

	ct = l_CT()
	self:VMIV()
	if not self:VMIV() then
		print("Invalid VM on owner: ")
		print(self:GetOwner())

		return
	end
	if not self.HasDetectedValidAnimations then
		self:CacheAnimations()
	end

	success,tanim = self:ChooseDrawAnim()

	if sp then
		self:CallOnClient("ChooseDrawAnim", "")
	end

	self:SetStatus(TFA.Enum.STATUS_DRAW)
	local len = self:GetActivityLength( tanim )
	self:SetStatusEnd(ct + len )
	self:SetNextPrimaryFire( ct + len )
	self:SetIronSightsRaw(false)
	if not self.PumpAction then
		self:SetShotgunCancel( false )
	end
	self:SetBurstCount(0)
	self.IronSightsProgress = 0
	self.SprintProgress = 0
	self.InspectingProgress = 0
	self.ProceduralHolsterEnabled = 0
	if self.Inspecting then
		--if gui then
		--	gui.EnableScreenClicker(false)
		--end
		self.Inspecting = false
	end
	self.DefaultFOV = TFADUSKFOV or ( IsValid(self:GetOwner()) and self:GetOwner():GetFOV() or 90 )
	if self:GetStat("Skin") and isnumber(self:GetStat("Skin")) then
		self.OwnerViewModel:SetSkin(self:GetStat("Skin"))
		self:SetSkin(self:GetStat("Skin"))
	end
	if nzombies then
		self:NZDeploy()
	end

	self:InitAttachments()

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
	if self.Owner:IsNPC() then
		return
	end
	if not IsValid(self) then return end
	ct = l_CT()
	stat = self:GetStatus()

	if not TFA.Enum.HolsterStatus[stat] then

		if stat == TFA.GetStatus("reloading_wait") and self:Clip1() <= self:GetStat("Primary.ClipSize") and ( not self:GetStat("DisableChambering") ) and ( not self:GetStat("Shotgun") ) then
			self:ResetFirstDeploy()
			if game.SinglePlayer() then
				self:CallOnClient("ResetFirstDeploy","")
			end
			print("resetting first deploy")
		end

		success, tanim = self:ChooseHolsterAnim()

		if IsFirstTimePredicted() then
			if not IsValid(target) then
				target = self:GetOwner()
			end

			self:SetSwapTarget(target)
		end

		self:SetStatus(TFA.Enum.STATUS_HOLSTER)
		if success then
			self:SetStatusEnd( ct + self:GetActivityLength( tanim ) )
		else
			self:SetStatusEnd( ct + self:GetStat("ProceduralHolsterTime") / self:NZAnimationSpeed( ACT_VM_HOLSTER ) )
		end
		return false
	elseif stat == TFA.Enum.STATUS_HOLSTER_READY or stat == TFA.Enum.STATUS_HOLSTER_FINAL then
		return true
	end
end

function SWEP:FinishHolster()
	if self.Owner:IsNPC() then
		return
	end
	if SERVER then
		ent = self:GetSwapTarget()
		self:CleanParticles()
		self:Holster(ent)

		if IsValid(ent) then
			if ent == self:GetOwner() then
				self:WeaponUse(self:GetOwner())
			else
				self:GetOwner():SelectWeapon(ent:GetClass())
				self.OwnerViewModel = nil
			end
		end
	end
end

function SWEP:WeaponUse(plyv)
	if self.Owner:IsNPC() then
		return
	end
	plyv:ConCommand("+use")
	self:GetHolding()

	timer.Simple(0.1, function()
		if IsValid(plyv) then
			plyv:ConCommand("-use")
			self:GetHolding()

			timer.Simple(0.2, function()
				if IsValid(plyv) and IsValid(self) then
					ent = plyv:GetNW2Entity("LastHeldEntity")

					if not IsValid(ent) or not ent:IsPlayerHolding() then
						self:Deploy()
					end
				end
			end)
		end
	end)
end

--[[
Function Name:  OnRemove
Syntax: self:OnRemove()
Notes:  Resets bone mods and cleans up.
Returns:  Nil.
Purpose:  Standard SWEP Function
]]
function SWEP:OnRemove()
end

--[[
Function Name:  OnDrop
Syntax: self:OnDrop()
Notes:  Resets bone mods and cleans up.
Returns:  Nil.
Purpose:  Standard SWEP Function
]]
function SWEP:OnDrop()
end

--[[
Function Name:  Think
Syntax: self:Think()
Returns:  Nothing.
Notes:  This is blank.
Purpose:  Standard SWEP Function
]]
function SWEP:Think()
	if self.Owner:IsNPC() then
		if SERVER then
			if self.Owner:GetClass() == "npc_combine_s" then
				if self.Owner:GetActivity() == 16 then
					self:PrimaryAttack()
				end
			else
				if self.Owner:GetActivity() == 11 then
					self:PrimaryAttack()
				end
			end
		end
	end
end

--[[
Function Name:  Think2
Syntax: self:Think2().  Called from PlayerThink.
Returns:  Nothing.
Notes:  Essential for calling other important functions.  This is called from PlayerThink.  It's used because SWEP:Think() isn't always called.
Purpose:  Standard SWEP Function
]]
local finalstat

function SWEP:PlayerThink()
	if self.Owner:IsNPC() then
		return
	end
	ft = TFA.FrameTime()
	if not self:NullifyOIV() then return end
	self:Think2()
	if SERVER then
		self:CalculateRatios()
	end
end

function SWEP:PlayerThinkCL()
	if self.Owner:IsNPC() then
		return
	end
	ft = TFA.FrameTime()
	if not self:NullifyOIV() then return end
	self:CalculateRatios()
	self:OwnerIsValid()
	self:Think2()
	self:CalculateViewModelOffset()
	self:CalculateViewModelFlip()

	if not self.Blowback_PistolMode or self:Clip1() == -1 or self:Clip1() > 0.1 or self.Blowback_PistolMode_Disabled[ self:GetLastActivity() ] then
		self.BlowbackCurrent = l_mathApproach(self.BlowbackCurrent, 0, self.BlowbackCurrent * ft * 15)
	end

	self.BlowbackCurrentRoot = l_mathApproach(self.BlowbackCurrentRoot, 0, self.BlowbackCurrentRoot * ft * 15)
end

local is, spr, waittime, sht, lact

function SWEP:Think2()
	if self.Owner:IsNPC() then
		return
	end
	if self.LuaShellRequestTime > 0 and CurTime() > self.LuaShellRequestTime then
		self.LuaShellRequestTime = -1
		self:MakeShell()
		self:EjectionSmoke()
	end

	if not self.HasInitialized then
		self:Initialize()
	end

	if not self.HasDetectedValidAnimations then
		self:CacheAnimations()
		self:ChooseDrawAnim()
	end
	self:InitAttachments()
	self:ProcessBodygroups()
	self:ProcessEvents()
	self:ProcessFireMode()
	self:ProcessHoldType()
	self:ReloadCV()
	self:IronSightSounds()
	is, spr = self:IronSights()
	if stat == TFA.Enum.STATUS_FIDGET and is then
		self:SetStatusEnd(0)
		self.Idle_Mode_Old = self.Idle_Mode
		self.Idle_Mode = TFA.Enum.IDLE_BOTH
		self:ChooseIdleAnim()
		if game.SinglePlayer() then
			self:CallOnClient("ChooseIdleAnim","")
		end
		self.Idle_Mode = self.Idle_Mode_Old
		self.Idle_Mode_Old = nil
		statend = -1
	end
	is = self:GetIronSights()
	ct = l_ct()
	stat = self:GetStatus()
	statend = self:GetStatusEnd()
	if stat ~= TFA.Enum.STATUS_IDLE then
		self.NextInspectAnim = -1
	end

	if stat ~= TFA.Enum.STATUS_IDLE and ct > statend then
		finalstat = TFA.Enum.STATUS_IDLE

		if stat == TFA.Enum.STATUS_HOLSTER then--Holstering
			finalstat = TFA.Enum.STATUS_HOLSTER_READY
			self:SetStatusEnd(ct + 0.0)
		elseif stat == TFA.Enum.STATUS_HOLSTER_READY then
			self:FinishHolster()
			finalstat = TFA.Enum.STATUS_HOLSTER_FINAL
			self:SetStatusEnd(ct + 0.6)
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_START_SHELL then--Shotgun Reloading from empty
			self:TakePrimaryAmmo(1,true)
			self:TakePrimaryAmmo(-1)
			if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
				finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
				success,tanim = self:ChooseShotgunPumpAnim()
				self:SetStatusEnd(ct + self:GetActivityLength( tanim ))
				self:SetShotgunCancel( false )
			else
				waittime = self:GetActivityLength( self:GetLastActivity(), false ) - self:GetActivityLength( self:GetLastActivity(), true )
				if waittime > 0.01 then
					finalstat = TFA.GetStatus("reloading_wait")
					self:SetStatusEnd( CurTime() + waittime )
				else
					finalstat = self:LoadShell()
				end
				--finalstat = self:LoadShell()
				--self:SetStatusEnd( self:GetNextPrimaryFire() )
			end
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_START then--Shotgun Reloading
			finalstat = self:LoadShell()
		elseif stat == TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP then
			self:TakePrimaryAmmo(1,true)
			self:TakePrimaryAmmo(-1)
			lact = self:GetLastActivity()
			if self:GetActivityLength(lact,true) < self:GetActivityLength(lact,false) - 0.01 then
				sht = self:GetStat("ShellTime")
				if sht then sht = sht / self:NZAnimationSpeed(ACT_VM_RELOAD) end
				waittime = ( sht or self:GetActivityLength( lact , false ) ) -  self:GetActivityLength( lact , true )
			else
				waittime = 0
			end
			if waittime > 0.01 then
				finalstat = TFA.GetStatus("reloading_wait")
				self:SetStatusEnd( CurTime() + waittime )
			else
				if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
					finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
					success,tanim = self:ChooseShotgunPumpAnim()
					self:SetStatusEnd(ct + self:GetActivityLength( tanim ))
					self:SetShotgunCancel( false )
				else
					finalstat = self:LoadShell()
				end
			end
		elseif stat == TFA.Enum.STATUS_RELOADING then
			self:CompleteReload()
			waittime = self:GetActivityLength( self:GetLastActivity(), false ) - self:GetActivityLength( self:GetLastActivity(), true )
			if waittime > 0.01 then
				finalstat = TFA.GetStatus("reloading_wait")
				self:SetStatusEnd( CurTime() + waittime )
			end
			--self:SetStatusEnd( self:GetNextPrimaryFire() )
		elseif stat == TFA.Enum.STATUS_SILENCER_TOGGLE then
			self:SetSilenced( not self:GetSilenced() )
			self.Silenced = self:GetSilenced()
		elseif stat == TFA.GetStatus("reloading_wait") and self.Shotgun then
			if self:Ammo1() <= 0 or self:Clip1() >= self:GetPrimaryClipSize() or self:GetShotgunCancel() then
				finalstat = TFA.Enum.STATUS_RELOADING_SHOTGUN_END
				success,tanim = self:ChooseShotgunPumpAnim()
				self:SetStatusEnd(ct + self:GetActivityLength( tanim ))
				--self:SetShotgunCancel( false )
			else
				finalstat = self:LoadShell()
			end
		elseif stat == TFA.GetStatus("reloading_shotgun_end") and self.Shotgun then
			self:SetShotgunCancel( false )
		elseif self.PumpAction and stat == TFA.GetStatus("pump") then
			self:SetShotgunCancel( false )
		elseif stat == TFA.GetStatus("shooting") and self.PumpAction then
			if self:Clip1() == 0 and self:GetStat("PumpAction").value_empty then
				--finalstat = TFA.GetStatus("pump_ready")
				self:SetShotgunCancel( true )
			elseif ( self:GetStat("Primary.ClipSize") < 0 or self:Clip1() > 0 ) and self:GetStat("PumpAction").value then
				--finalstat = TFA.GetStatus("pump_ready")
				self:SetShotgunCancel( true )
			end
			--self:SetStatusEnd( math.huge )
		end

		self:SetStatus(finalstat)

		local smi = self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI
		local spi = self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI

		if ( not TFA.Enum.ReadyStatus[stat] ) and stat ~= TFA.GetStatus("shooting") and stat ~= TFA.GetStatus("pump") and finalstat == TFA.Enum.STATUS_IDLE and ( smi or spi ) then
			is = self:GetIronSights( true )
			if ( is and smi ) or ( spr and spi ) then
				succ,tanim = self:Locomote(is and smi, is, spr and spi, spr)
				if succ == false then
					self:SetNextIdleAnim(-1)
				else
					self:SetNextIdleAnim(math.max(self:GetNextIdleAnim(),CurTime() + 0.1))
				end
			end
		end
		self.LastBoltShoot = nil
		if self:GetBurstCount() > 0 then
			if finalstat ~= TFA.Enum.STATUS_SHOOTING and finalstat ~= TFA.Enum.STATUS_IDLE then
				self:SetBurstCount(0)
			elseif self:GetBurstCount() < self:GetMaxBurst() and self:Clip1() > 0 then
				self:PrimaryAttack()
			else
				self:SetBurstCount(0)
				self:SetNextPrimaryFire( CurTime() + self:GetBurstDelay() )
			end
		end
	end

	if stat == TFA.Enum.STATUS_IDLE and self:GetShotgunCancel() then
		if self.PumpAction then
			if CurTime() > self:GetNextPrimaryFire() and not self:GetOwner():KeyDown(IN_ATTACK) then
				self:DoPump()
			end
		else
			self:SetShotgunCancel( false )
		end
	end

	if TFA.Enum.ReadyStatus[stat] and ct > self:GetNextIdleAnim() then
		self:ChooseIdleAnim()
	end
end

local issighting, issprinting = false, false
SWEP.spr_old = false
SWEP.is_old = false
local issighting_tmp
local ironsights_toggle_cvar, ironsights_resight_cvar
local ironsights_cv = GetConVar("sv_tfa_ironsights_enabled")
local sprint_cv = GetConVar("sv_tfa_sprint_enabled")
if CLIENT then
	ironsights_resight_cvar = GetConVar("cl_tfa_ironsights_resight")
	ironsights_toggle_cvar = GetConVar("cl_tfa_ironsights_toggle")
end

function SWEP:IronSights()
	if self.Owner:IsNPC() then
		return
	end
	if not self:GetStat("Scoped") and not self:GetStat("Scoped_3D") then
		if not ironsights_cv:GetBool() then
			self.data.ironsights_default = self.data.ironsights_default or self.data.ironsights
			self.data.ironsights = 0
		elseif self.data.ironsights_default == 1 and self:GetStat("data.ironsights") == 0 then
			self.data.ironsights = 1
			self.data.ironsights_default = 0
		end
	end
	ct = l_CT()
	stat = self:GetStatus()
	local owent = self:GetOwner()
	issighting = false
	issprinting = false
	self.is_old = self:GetIronSightsRaw()
	self.spr_old = self:GetSprinting()
	if sprint_cv:GetBool() and not self.AllowSprintAttack then
		issprinting = self:GetOwner():GetVelocity():Length2D() > self:GetOwner():GetRunSpeed() * 0.6 and self:GetOwner():KeyDown(IN_SPEED)
	end
	vm = self.OwnerViewModel

	if not (self.data and self:GetStat("data.ironsights") == 0 ) then
		if CLIENT then
			if not ironsights_toggle_cvar:GetBool() then
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
		else
			if owent:GetInfoNum("cl_tfa_ironsights_toggle", 0) == 0 then
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
	end

	if ( ( CLIENT and ironsights_toggle_cvar:GetBool() ) or ( SERVER and owent:GetInfoNum("cl_tfa_ironsights_toggle", 0) == 1 ) ) and not ( ( CLIENT and ironsights_resight_cvar:GetBool() ) or ( SERVER and owent:GetInfoNum("cl_tfa_ironsights_resight", 0) == 1 ) ) then
		if issprinting then
			issighting = false
		end

		if not TFA.Enum.IronStatus[stat] then
			issighting = false
		end
		if self:GetStat("BoltAction") or self:GetStat("BoltAction_Forced") then
			if stat == TFA.Enum.STATUS_SHOOTING then
				if not self.LastBoltShoot then
					self.LastBoltShoot = CurTime()
				end
				if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
					issighting = false
				end
			else
				self.LastBoltShoot = nil
			end
		end
	end

	if TFA.Enum.ReloadStatus[stat] then
		issprinting = false
	end

	self.is_cached = nil

	if ( issighting or issprinting or stat ~= TFA.Enum.STATUS_IDLE ) and self.Inspecting then
		--if gui then
		--	gui.EnableScreenClicker(false)
		--end
		self.Inspecting = false
	end

	if (self.is_old ~= issighting) then
		self:SetIronSightsRaw(issighting)
	end

	issighting_tmp = issighting

	if issprinting then
		issighting = false
	end

	if not TFA.Enum.IronStatus[stat] then
		issighting = false
	end

	if self:IsSafety() then
		issighting = false
		--issprinting = true
	end

	if self.BoltAction or self.BoltAction_Forced then
		if stat == TFA.Enum.STATUS_SHOOTING then
			if not self.LastBoltShoot then
				self.LastBoltShoot = CurTime()
			end
			if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
				issighting = false
			end
		else
			self.LastBoltShoot = nil
		end
	end

	if (self.is_old_final ~= issighting) and self.Sights_Mode == TFA.Enum.LOCOMOTION_LUA then--and stat == TFA.Enum.STATUS_IDLE then
		self:SetNextIdleAnim(-1)
	end


	local smi = ( self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI ) and self.is_old_final ~= issighting
	local spi = ( self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID or self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI ) and self.spr_old ~= issprinting

	if ( smi or spi ) and ( self:GetStatus() == TFA.Enum.STATUS_IDLE or ( self:GetStatus() == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting() ) ) and not self:GetShotgunCancel() then
		--self:SetNextIdleAnim(-1)
		local toggle_is = self.is_old ~= issighting
		if issighting and self.spr_old ~= issprinting then
			toggle_is = true
		end
		succ,tanim = self:Locomote(toggle_is and (self.Sights_Mode == TFA.Enum.LOCOMOTION_ANI or self.Sights_Mode == TFA.Enum.LOCOMOTION_HYBRID ), issighting, (self.spr_old ~= issprinting) and (self.Sprint_Mode == TFA.Enum.LOCOMOTION_ANI or self.Sprint_Mode == TFA.Enum.LOCOMOTION_HYBRID ), issprinting)
		if ( not succ ) and ( ( toggle_is and smi ) or ( (self.spr_old ~= issprinting) and spi ) ) then
			self:SetNextIdleAnim(-1)
		end
	end

	if (self.spr_old ~= issprinting) then
		self:SetSprinting(issprinting)
	end

	self.is_old_final = issighting

	return issighting_tmp, issprinting
end

SWEP.is_cached = nil
SWEP.is_cached_old = false

function SWEP:GetIronSights( ignorestatus )
	if self.Owner:IsNPC() then
		return
	end
	if ignorestatus then
		issighting = self:GetIronSightsRaw()
		issprinting = self:GetSprinting()
		if issprinting then
			issighting = false
		end

		if self:GetStat("BoltAction") or self:GetStat("BoltAction_Forced") then
			if stat == TFA.Enum.STATUS_SHOOTING then
				if not self.LastBoltShoot then
					self.LastBoltShoot = CurTime()
				end
				if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
					issighting = false
				end
			else
				self.LastBoltShoot = nil
			end
		end

		return issighting
	end
	if self.is_cached == nil then
		issighting = self:GetIronSightsRaw()
		issprinting = self:GetSprinting()
		stat = self:GetStatus()
		if issprinting then
			issighting = false
		end

		if not TFA.Enum.IronStatus[stat] then
			issighting = false
		end

		if self.BoltAction or self.BoltAction_Forced then
			if stat == TFA.Enum.STATUS_SHOOTING then
				if not self.LastBoltShoot then
					self.LastBoltShoot = CurTime()
				end
				if CurTime() > self.LastBoltShoot + self.BoltTimerOffset then
					issighting = false
				end
			else
				self.LastBoltShoot = nil
			end
		end

		self.is_cached = issighting

		--[[
		if (self.is_cached_old ~= issighting) and not ( game.SinglePlayer() and CLIENT ) then
			if (issighting == false) then--and ((CLIENT and IsFirstTimePredicted()) or (SERVER and sp)) then
				self:EmitSound(self.IronOutSound or "TFA.IronOut")
			elseif issighting == true then--and ((CLIENT and IsFirstTimePredicted()) or (SERVER and sp)) then
				self:EmitSound(self.IronInSound or "TFA.IronIn")
			end
		end
		]]--

		self.is_cached_old = self.is_cached
	end

	return self.is_cached
end

SWEP.is_sndcache_old = false

function SWEP:IronSightSounds()
	if self.Owner:IsNPC() then
		return
	end
	is = self:GetIronSights()
	if SERVER or ( CLIENT and IsFirstTimePredicted() ) then
		if is ~= self.is_sndcache_old then
			if is then
				self:EmitSound(self.IronInSound or "TFA.IronIn")
			else
				self:EmitSound(self.IronOutSound or "TFA.IronOut")
			end
		end
		self.is_sndcache_old = is
	end
end

local legacy_reloads_cv = GetConVar("sv_tfa_reloads_legacy")
local dryfire_cvar = GetConVar("sv_tfa_allow_dryfire")

function SWEP:CanPrimaryAttack( )
	if self.Owner:IsNPC() then
		if SERVER then
			if CurTime() < self:GetNextPrimaryFire() then
				return false
			end
			return true
		end
	end
	stat = self:GetStatus()
	if not TFA.Enum.ReadyStatus[stat] and stat ~= TFA.Enum.STATUS_SHOOTING then
		if self.Shotgun and TFA.Enum.ReloadStatus[stat] then
			self:SetShotgunCancel( true )
		end
		return false
	end

	if self:IsSafety() then
		self:EmitSound("Weapon_AR2.Empty2")
		self.LastSafetyShoot = self.LastSafetyShoot or 0

		if l_CT() < self.LastSafetyShoot + 0.2 then
			self:CycleSafety()
			self:SetNextPrimaryFire(l_CT() + 0.1)
		end

		self.LastSafetyShoot = l_CT()

		return
	end

	if self:GetStat("Primary.ClipSize") <= 0 and self:Ammo1() < self:GetStat("Primary.AmmoConsumption") then
		return false
	end
	if self:GetSprinting() and not self.AllowSprintAttack then
		return false
	end
	if self:GetPrimaryClipSize(true) > 0 and self:Clip1() < self:GetStat("Primary.AmmoConsumption") then
		if self:GetOwner():KeyPressed(IN_ATTACK) then
			self:ChooseDryFireAnim()
		end
		if not self.HasPlayedEmptyClick then
			self:EmitSound("Weapon_Pistol.Empty2")

			if not dryfire_cvar:GetBool() then
				self:Reload( true )
			end

			self.HasPlayedEmptyClick = true
		end
		return false
	end
	if self.FiresUnderwater == false and self:GetOwner():WaterLevel() >= 3 then
		self:SetNextPrimaryFire(l_CT() + 0.5)
		self:EmitSound("Weapon_AR2.Empty")
		return false
	end

	self.HasPlayedEmptyClick = false

	if CurTime() < self:GetNextPrimaryFire() then return false end

	return true
end

function SWEP:PrimaryAttack()
	if self.Owner:IsNPC() then
		if self:Clip1() <= 0 then
			if SERVER then
				self.Owner:SetSchedule(SCHED_RELOAD)
			end
			return
		end
		if SERVER then
			if CurTime() < self:GetNextPrimaryFire() then
				return false
			end
		end
		local times_to_fire = 2
		if self.OnlyBurstFire then
			times_to_fire = 3
		end
		if self.Primary.Automatic then
			times_to_fire = math.random(5,8)
		end
		self:SetNextPrimaryFire( CurTime() + (((self.Primary.RPM / 60) / 100)*times_to_fire) + math.random(0.2, 0.6))
		timer.Create( "GunTimer", (self.Primary.RPM / 60) / 100, times_to_fire, function()
			self.Weapon:EmitSound(self.Primary.Sound)
			self:TakePrimaryAmmo(1)
			local damage_to_do = self.Primary.Damage * 0.16
			local bullet = {}
			bullet.Num = self.Primary.NumShots
			bullet.Src = self.Owner:GetShootPos()
			bullet.Dir = self.Owner:GetAimVector()
			bullet.Tracer = 1
			bullet.Damage = damage_to_do
			bullet.AmmoType = self.Primary.Ammo
			self.Owner:FireBullets( bullet )
		end)
		return
	end

	if not IsValid(self) then return end
	if not self:VMIV() then return end
	if not self:CanPrimaryAttack() then return end
	if self.CanBeSilenced and self:GetOwner():KeyDown(IN_USE) and ( SERVER or not sp ) then
		self:ChooseSilenceAnim( not self:GetSilenced() )
		success, tanim = self:SetStatus(TFA.Enum.STATUS_SILENCER_TOGGLE)
		self:SetStatusEnd( l_CT() + self:GetActivityLength( tanim ) )
		return
	end
	self:SetNextPrimaryFire( CurTime() + self:GetFireDelay() )
	if self:GetMaxBurst() > 1 then
		self:SetBurstCount( math.max(1,self:GetBurstCount() + 1) )
	end
	if self.PumpAction and self:GetShotgunCancel() then return end
	self:SetStatus(TFA.Enum.STATUS_SHOOTING)
	self:SetStatusEnd(self:GetNextPrimaryFire())
	self:ToggleAkimbo()
	succ, tanim = self:ChooseShootAnim()
	if ( not game.SinglePlayer() ) or ( not self:IsFirstPerson() ) then
		self:GetOwner():SetAnimation(PLAYER_ATTACK1)
	end
	if self:GetStat("Primary.Sound") and IsFirstTimePredicted()  and not ( sp and CLIENT ) then
		if self:GetStat("Primary.SilencedSound") and self:GetSilenced() then
			self:EmitSound(self:GetStat("Primary.SilencedSound")	)
		else
			self:EmitSound(self:GetStat("Primary.Sound"))
		end
	end
	self:TakePrimaryAmmo( self:GetStat("Primary.AmmoConsumption") )
	if self:Clip1() == 0 and self:GetStat("Primary.ClipSize") > 0 then
		self:SetNextPrimaryFire( math.max( self:GetNextPrimaryFire(), CurTime() + ( self.Primary.DryFireDelay or self:GetActivityLength(tanim, true) ) ) )
	end
	self:ShootBulletInformation()
	local _, CurrentRecoil = self:CalculateConeRecoil()
	self:Recoil(CurrentRecoil,IsFirstTimePredicted())
	if sp and SERVER then
		self:CallOnClient("Recoil","")
	end
	if self.MuzzleFlashEnabled and ( not self:IsFirstPerson() or not self.AutoDetectMuzzleAttachment ) then
		self:ShootEffectsCustom()
	end

	if self.EjectionSmoke and IsFirstTimePredicted() and not (self.LuaShellEject and self.LuaShellEjectDelay > 0) then
		self:EjectionSmoke()
	end
	self:DoAmmoCheck()
	if self:GetStatus() == TFA.GetStatus("shooting") and self.PumpAction then
		if self:Clip1() == 0 and self:GetStat("PumpAction").value_empty then
			--finalstat = TFA.GetStatus("pump_ready")
			self:SetShotgunCancel( true )
		elseif ( self:GetStat("Primary.ClipSize") < 0 or self:Clip1() > 0 ) and self:GetStat("PumpAction").value then
			--finalstat = TFA.GetStatus("pump_ready")
			self:SetShotgunCancel( true )
		end
	end
end

function SWEP:CanSecondaryAttack()
end

function SWEP:SecondaryAttack()
	if self.Owner:IsNPC() then
		return
	end
	if self.data and self:GetStat("data.ironsights") == 0 and self.AltAttack then
		self:AltAttack()
		return
	end
end

function SWEP:GetLegacyReloads()
	return legacy_reloads_cv:GetBool() --nzombies or legacy_reloads_cv:GetBool()
end

function SWEP:Reload(released)
	if self.Owner:IsNPC() then
		return
	end
	if not self:VMIV() then return end
	if self:Ammo1() <= 0 then return end
	if self:GetStat("Primary.ClipSize") < 0 then return end
	if ( not released ) and ( not self:GetLegacyReloads() ) then return end
	if self:GetLegacyReloads() and not  dryfire_cvar:GetBool() and not self:GetOwner():KeyDown(IN_RELOAD) then return end
	if self:GetOwner():KeyDown(IN_USE) then return end

	ct = l_CT()
	stat = self:GetStatus()

	if self.PumpAction and self:GetShotgunCancel() then
		if stat == TFA.Enum.STATUS_IDLE then
			self:DoPump()
		end
	elseif TFA.Enum.ReadyStatus[stat] or ( stat == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting() ) then
		if self:Clip1() < self:GetPrimaryClipSize() then
			if self.Shotgun then
				success, tanim = self:ChooseShotgunReloadAnim()
				if self.ShotgunEmptyAnim  then
					local _, tg = self:ChooseAnimation( "reload_empty" )
					local action = tanim
					if type(tg) == "string" and tonumber(tanim) and tonumber(tanim)>0 then
						action = self.OwnerViewModel:GetSequenceName( self.OwnerViewModel:SelectWeightedSequenceSeeded( tanim, self:GetSeed() ) )
					end
					if action == tg and self.ShotgunEmptyAnim_Shell then
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
				success, tanim = self:ChooseReloadAnim()
				self:SetStatus(TFA.Enum.STATUS_RELOADING)
				if self:GetStat("ProceduralReloadEnabled") then
					self:SetStatusEnd(ct + self:GetStat("ProceduralReloadTime"))
				else
					self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ) )
					self:SetNextPrimaryFire(ct + self:GetActivityLength( tanim, false ) )
				end
			end
			if ( not game.SinglePlayer() ) or ( not self:IsFirstPerson() ) then
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
end

function SWEP:Reload2(released)
	if self.Owner:IsNPC() then
		return
	end
	if not self:VMIV() then return end
	if self:Ammo2() <= 0 then return end
	if self:GetStat("Secondary.ClipSize") < 0 then return end
	if ( not released ) and ( not self:GetLegacyReloads() ) then return end
	if self:GetLegacyReloads() and not  dryfire_cvar:GetBool() and not self:GetOwner():KeyDown(IN_RELOAD) then return end
	if self:GetOwner():KeyDown(IN_USE) then return end

	ct = l_CT()
	stat = self:GetStatus()

	if self.PumpAction and self:GetShotgunCancel() then
		if stat == TFA.Enum.STATUS_IDLE then
			self:DoPump()
		end
	elseif TFA.Enum.ReadyStatus[stat] or ( stat == TFA.Enum.STATUS_SHOOTING and self:CanInterruptShooting() ) then
		if self:Clip2() < self:GetSecondaryClipSize() then
			if self.Shotgun then
				success, tanim = self:ChooseShotgunReloadAnim()
				if self.ShotgunEmptyAnim  then
					local _, tg = self:ChooseAnimation( "reload_empty" )
					if tanim == tg and self.ShotgunEmptyAnim_Shell then
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
				success, tanim = self:ChooseReloadAnim()
				self:SetStatus(TFA.Enum.STATUS_RELOADING)
				if self:GetStat("ProceduralReloadEnabled") then
					self:SetStatusEnd(ct + self:GetStat("ProceduralReloadTime"))
				else
					self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ) )
					self:SetNextPrimaryFire(ct + self:GetActivityLength( tanim, false ) )
				end
			end
			if ( not game.SinglePlayer() ) or ( not self:IsFirstPerson() ) then
				self:GetOwner():SetAnimation(PLAYER_RELOAD)
			end
			if self:GetStat("Secondary.ReloadSound") and IsFirstTimePredicted() then
				self:EmitSound(self:GetStat("Secondary.ReloadSound"))
			end
			self:SetNextPrimaryFire( -1 )
		elseif released or self:GetOwner():KeyPressed(IN_RELOAD) then--if self:GetOwner():KeyPressed(IN_RELOAD) or not self:GetLegacyReloads() then
			self:CheckAmmo()
		end
	end
end

function SWEP:DoPump()
	if self.Owner:IsNPC() then
		return
	end
	succ,tanim = self:PlayAnimation( self:GetStat("PumpAction") )
	self:SetStatus( TFA.GetStatus("pump") )
	self:SetStatusEnd( CurTime() + self:GetActivityLength( tanim, true ) )
	self:SetNextPrimaryFire( CurTime() + self:GetActivityLength( tanim, false ) )
	self:SetNextIdleAnim(math.max( self:GetNextIdleAnim(), CurTime() + self:GetActivityLength( tanim, false ) ))
end

function SWEP:LoadShell( )
	if self.Owner:IsNPC() then
		return
	end
	success, tanim = self:ChooseReloadAnim()
	if self:GetActivityLength(tanim,true) < self:GetActivityLength(tanim,false) then
		self:SetStatusEnd(ct + self:GetActivityLength( tanim, true ) )
	else
		sht = self:GetStat("ShellTime")
		if sht then sht = sht / self:NZAnimationSpeed(ACT_VM_RELOAD) end
		self:SetStatusEnd(ct + ( sht or self:GetActivityLength( tanim, true ) ) )
	end
	return TFA.Enum.STATUS_RELOADING_SHOTGUN_LOOP
end

function SWEP:CompleteReload()
	if self.Owner:IsNPC() then
		return
	end
	local maxclip = self:GetPrimaryClipSize( true )
	local curclip = self:Clip1()
	local amounttoreplace = math.min(maxclip - curclip, self:Ammo1())
	self:TakePrimaryAmmo(amounttoreplace * -1)
	self:TakePrimaryAmmo(amounttoreplace, true)
end


function SWEP:CheckAmmo()
	if self.Owner:IsNPC() then
		return
	end
	if self:GetIronSights() or self:GetSprinting() then return end

	--if self.NextInspectAnim == nil then
	--	self.NextInspectAnim = -1
	--end
	tanim, success = self:SelectInspectAnim()

	if (self.SequenceEnabled[ACT_VM_FIDGET] or self.InspectionActions) and self:GetStatus() == TFA.Enum.STATUS_IDLE and tanim ~= self:GetLastActivity() then--and CurTime() > self.NextInspectAnim then
		--self:SetStatus(TFA.Enum.STATUS_FIDGET)
		succ,tanim = self:ChooseInspectAnim()
		--[[
		if IsFirstTimePredicted() then
			timer.Simple(0.05,function()
				self.NextInspectAnim = l_CT() + self:GetActivityLength( tanim ) - 0.05
			end)
		end
		]]--
		--self:SetStatusEnd( l_CT() + self:GetActivityLength( tanim ) )
	end
end

local cv_strip = GetConVar("sv_tfa_weapon_strip")
function SWEP:DoAmmoCheck()
	if self.Owner:IsNPC() then
		return
	end
	if IsValid(self) and SERVER and cv_strip:GetBool() and self:Clip1() == 0 and self:Ammo1() == 0 then
		timer.Simple(.1, function()
			if SERVER and IsValid(self) and self:OwnerIsValid() then
				self:GetOwner():StripWeapon(self.ClassName)
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
			sensval = sensval * TFA.CalculateSensitivtyScale( fovv )
		else
			sensval = sensval
		end

		if sensitivity_speed_cvar:GetFloat() then
			sensval = sensval * self:GetStat("IronSightsMoveSpeed")
		end
	end

	sensval = sensval * l_Lerp(self.IronSightsProgress, 1, self:GetStat( "IronSightsSensitivity" ) )
	return sensval
end

--[[
Function Name:  TranslateFOV
Syntax: Should not normally be called.  Takes default FOV as parameter.
Returns:  New FOV.
Purpose:  Standard SWEP Function
]]

local nfov
function SWEP:TranslateFOV(fov)
	if self.Owner:IsNPC() then
		return
	end
	self:CorrectScopeFOV()
	nfov = l_Lerp(self.IronSightsProgress, fov, fov * math.min( self:GetStat("Secondary.IronFOV") / 90,1))

	return l_Lerp(self.SprintProgress, nfov, nfov + self.SprintFOVOffset)
end

function SWEP:GetPrimaryAmmoType()
	return self:GetStat("Primary.Ammo") or ""
end

function SWEP:ToggleInspect()
	if self.Owner:IsNPC() then
		return
	end
	if self:GetSprinting() or self:GetIronSights() or self:GetStatus() ~= TFA.Enum.STATUS_IDLE then return end
	self.Inspecting = not self.Inspecting
	--if self.Inspecting then
	--	gui.EnableScreenClicker(true)
	--else
	--	gui.EnableScreenClicker(false)
	--end
end
