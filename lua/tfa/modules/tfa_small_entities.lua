
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

-- This file contain aliases/slight modifications which do not deserve their own Lua file

weapons.Register({
	Base = "tfa_nade_base",
	AllowUnderhanded = true,
}, "tfa_cssnade_base")

weapons.Register({
	Base = "tfa_gun_base",
	Shotgun = true,
}, "tfa_shotty_base")

weapons.Register({
	Base = "tfa_gun_base",
}, "tfa_akimbo_base")

if SERVER then
	AddCSLuaFile("tfa/3dscoped_base.lua")
end

local SWEP_ = include("tfa/3dscoped_base.lua")
local SWEP = table.Copy(SWEP_)

SWEP.Secondary.ScopeZoom = 1
SWEP.Secondary.UseACOG = false
SWEP.Secondary.UseMilDot = false
SWEP.Secondary.UseSVD = false
SWEP.Secondary.UseParabolic = false
SWEP.Secondary.UseElcan = false
SWEP.Secondary.UseGreenDuplex = false
SWEP.RTScopeFOV = 6
SWEP.RTScopeAttachment = 3 --Anchor the scope shadow to this
SWEP.Scoped = false
SWEP.BoltAction = false
SWEP.ScopeLegacyOrientation = false --used to align with eyeangles instead of vm angles
SWEP.ScopeAngleTransforms = {}
--{"P",1} --Pitch, 1
--{"Y",1} --Yaw, 1
--{"R",1} --Roll, 1
SWEP.ScopeOverlayTransforms = {0, 0}
SWEP.ScopeOverlayTransformMultiplier = 0.8
SWEP.RTMaterialOverride = 1
SWEP.IronSightsSensitivity = 1
SWEP.ScopeShadow = nil
SWEP.ScopeReticule = nil
SWEP.ScopeDirt = nil
SWEP.ScopeReticule_CrossCol = false
SWEP.ScopeReticule_Scale = {1, 1}
--[[End of Tweakable Parameters]]--
SWEP.Scoped_3D = true
SWEP.BoltAction_3D = false

SWEP.Base = "tfa_bash_base"

weapons.Register(SWEP, "tfa_3dbash_base")

local SWEP = table.Copy(SWEP_)

SWEP.Secondary.ScopeZoom = 0
SWEP.Secondary.UseACOG = false
SWEP.Secondary.UseMilDot = false
SWEP.Secondary.UseSVD = false
SWEP.Secondary.UseParabolic = false
SWEP.Secondary.UseElcan = false
SWEP.Secondary.UseGreenDuplex = false
SWEP.RTScopeFOV = 6
SWEP.RTScopeAttachment = 3
SWEP.Scoped = false
SWEP.BoltAction = false
SWEP.ScopeLegacyOrientation = false --used to align with eyeangles instead of vm angles
SWEP.ScopeAngleTransforms = {}
--{"P",1} --Pitch, 1
--{"Y",1} --Yaw, 1
--{"R",1} --Roll, 1
SWEP.ScopeOverlayTransforms = {0, 0}
SWEP.ScopeOverlayTransformMultiplier = 0.8
SWEP.RTMaterialOverride = 1
SWEP.IronSightsSensitivity = 1
SWEP.ScopeShadow = nil
SWEP.ScopeReticule = nil
SWEP.ScopeDirt = nil
SWEP.ScopeReticule_CrossCol = false
SWEP.ScopeReticule_Scale = {1, 1}
--[[End of Tweakable Parameters]]--
SWEP.Scoped_3D = true
SWEP.BoltAction_3D = false

SWEP.Base = "tfa_gun_base"

weapons.Register(SWEP, "tfa_3dscoped_base")

weapons.Register({
	Base = "tfa_gun_base",

	Secondary = {
		ScopeZoom = 0,
		UseACOG = false,
		UseMilDot = false,
		UseSVD = false,
		UseParabolic = false,
		UseElcan = false,
		UseGreenDuplex = false,
	},

	Scoped = true,
	BoltAction = false,
}, "tfa_scoped_base")
