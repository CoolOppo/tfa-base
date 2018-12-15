
-- Copyright (c) 2018 TFA Base Devs

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

if SERVER then
	util.AddNetworkString("tfaHitmarker")
	util.AddNetworkString("tfaHitmarker3D")

	return
end

local ScrW, ScrH = ScrW, ScrH

local markers = {}

local enabledcvar, solidtimecvar, fadetimecvar, scalecvar
local rcvar, gcvar, bcvar, acvar
local w, h, pos, sprh
local c = Color(255, 255, 255, 255)
local spr

net.Receive("tfaHitmarker", function()
	if not enabledcvar:GetBool() then return end

	local marker = {}
	marker.time = CurTime()

	table.insert(markers, marker)
end)

net.Receive("tfaHitmarker3D", function()
	if not enabledcvar:GetBool() then return end

	local marker = {}
	marker.pos = net.ReadVector()
	marker.time = CurTime()

	table.insert(markers, marker)
end)

hook.Add("HUDPaint", "tfaDrawHitmarker", function()
	if not enabledcvar then
		enabledcvar = GetConVar("cl_tfa_hud_hitmarker_enabled")
	end

	if not enabledcvar:GetBool() then return end

	if not spr then
		spr = Material("vgui/tfa_hitmarker.png", "smooth")
	end

	if not solidtimecvar then
		solidtimecvar = GetConVar("cl_tfa_hud_hitmarker_solidtime")
	end

	if not fadetimecvar then
		fadetimecvar = GetConVar("cl_tfa_hud_hitmarker_fadetime")
	end

	if not scalecvar then
		scalecvar = GetConVar("cl_tfa_hud_hitmarker_scale")
	end

	if not rcvar then
		rcvar = GetConVar("cl_tfa_hud_hitmarker_color_r")
	end

	if not gcvar then
		gcvar = GetConVar("cl_tfa_hud_hitmarker_color_g")
	end

	if not bcvar then
		bcvar = GetConVar("cl_tfa_hud_hitmarker_color_b")
	end

	if not acvar then
		acvar = GetConVar("cl_tfa_hud_hitmarker_color_a")
	end

	local solidtime = solidtimecvar:GetFloat()
	local fadetime = math.max(fadetimecvar:GetFloat(), 0.001)

	c.r = rcvar:GetFloat()
	c.g = gcvar:GetFloat()
	c.b = bcvar:GetFloat()

	w, h = ScrW(), ScrH()
	sprh = math.floor((h / 1080) * 64 * scalecvar:GetFloat())

	for k, v in pairs(markers) do
		if not v.time then
			markers[k] = nil
			continue
		end

		local alpha = math.Clamp(v.time - CurTime() + solidtime + fadetime, 0, fadetime) / fadetime
		c.a = acvar:GetFloat() * alpha

		if alpha > 0 then
			pos = {x = w * .5, y = h * .5}

			if v.pos then
				pos = v.pos:ToScreen()
			end

			if pos.visible == false then continue end

			surface.SetDrawColor(c)
			surface.SetMaterial(spr)
			surface.DrawTexturedRect(pos.x - sprh * .5, pos.y - sprh * .5, sprh, sprh)
		else
			markers[k] = nil
		end
	end
end)
