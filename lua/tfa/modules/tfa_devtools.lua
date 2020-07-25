
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

local cv_dba, cv_dbc

local statusnames = {}

local function PopulateStatusNames()
	if #statusnames > 0 then return end

	for k, v in pairs(TFA.Enum) do
		if (k:StartWith("STATUS")) and type(v) == "number" then
			statusnames[v] = k
		end
	end
end

cvars.AddChangeCallback("cl_tfa_debug_animations", PopulateStatusNames, "TFADevPopStatusNames")

local function DrawDebugInfo(w, h, ply, wep)
	if not cv_dba then
		cv_dba = GetConVar("cl_tfa_debug_animations")
	end

	if not cv_dba or not cv_dba:GetBool() then return end

	local x, y = w * .5, h * .2

	draw.SimpleTextOutlined(string.format("%s [%.2f, %.2f]", statusnames[wep:GetStatus()] or wep:GetStatus(), CurTime(), wep:GetStatusEnd()), "TFASleekSmall", x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	y = y + TFA.Fonts.SleekHeightSmall

	local vm = ply:GetViewModel() or NULL

	if vm:IsValid() then
		local seq = vm:GetSequence()

		draw.SimpleTextOutlined(string.format("%s (%s/%d)", vm:GetSequenceName(seq), vm:GetSequenceActivityName(seq), vm:GetSequenceActivity(seq)), "TFASleekSmall", x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
		y = y + TFA.Fonts.SleekHeightSmall

		local cycle = vm:GetCycle()
		local len = vm:SequenceDuration(seq)
		local rate = vm:GetPlaybackRate()

		draw.SimpleTextOutlined(string.format("%.2fs / %.2fs (%.2f) @ %d%%", cycle * len, len, cycle, rate * 100), "TFASleekSmall", x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, color_black)
	end
end

local function DrawDebugCrosshair(w, h)
	if not cv_dbc then
		cv_dbc = GetConVar("cl_tfa_debug_crosshair")
	end

	if not cv_dbc or not cv_dbc:GetBool() then return end

	surface.SetDrawColor(color_white)
	surface.DrawRect(w * .5 - 1, h * .5 - 1, 2, 2)
end

local w, h

hook.Add("HUDPaint", "tfa_drawdebughud", function()
	local ply = LocalPlayer() or NULL
	if not ply:IsValid() or not ply:IsAdmin() then return end

	local wep = ply:GetActiveWeapon() or NULL
	if not wep:IsValid() or not wep:IsTFA() then return end

	w, h = ScrW(), ScrH()

	DrawDebugInfo(w, h, ply, wep)
	DrawDebugCrosshair(w, h)
end)
