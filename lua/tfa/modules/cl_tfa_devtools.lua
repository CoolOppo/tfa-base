
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
PopulateStatusNames()

local state_strings = {}

for i = 1, 32 do
	local strcomp = string.rep("%d", i)
	local slice = {}

	for i2 = 0, i - 1 do
		table.insert(slice, "band(rshift(state, " .. i2 .. "), 1) == 0 and 0 or 1")
	end

	local fn = CompileString([[
		local rshift = bit.rshift
		local band = bit.band
		return function(state)
			return ]] .. table.concat(slice, ", ") .. [[
		end
	]], "tfa_dev_tools")()

	state_strings[i] = function(state)
		return string.format(strcomp, fn(state))
	end
end

local function DrawDebugInfo(w, h, ply, wep)
	if not cv_dba then
		cv_dba = GetConVar("cl_tfa_debug_animations")
	end

	if not cv_dba or not cv_dba:GetBool() then return end

	local x, y = w * .5, h * .2

	if wep.event_table_overflow then
		if wep.EventTableEdict[0] then
			draw.SimpleTextOutlined("UNPREDICTED Event table state:", "TFASleekSmall", x + 240, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
			local y2 = y + TFA.Fonts.SleekHeightSmall

			if not wep._built_event_debug_string_fn then
				local str = ""
				local str2 = ""

				for i = 0, #wep.EventTableEdict do
					str = str .. "%d"

					if (i + 1) % 32 == 0 then
						str = str .. "\n"
					end

					if str2 == "" then
						str2 = "self.EventTableEdict[" .. i .. "].called and 1 or 0"
					else
						str2 = str2 .. ", self.EventTableEdict[" .. i .. "].called and 1 or 0"
					end
				end

				wep._built_event_debug_string_fn = CompileString([[
					local format = string.format
					return function(self)
						return format([==[]] .. str .. [[]==], ]] .. str2 .. [[)
					end
				]], "TFA Base Debug Tools")()
			end

			for line in string.gmatch(wep:_built_event_debug_string_fn(), "(%S+)") do
				draw.SimpleTextOutlined(line, "TFASleekSmall", x + 240, y2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
				y2 = y2 + TFA.Fonts.SleekHeightSmall
			end
		end
	elseif wep._EventSlotCount ~= 0 then
		draw.SimpleTextOutlined("Event table state:", "TFASleekSmall", x + 240, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
		local y2 = y + TFA.Fonts.SleekHeightSmall

		for i = 1, wep._EventSlotCount do
			local state = wep["GetEventStatus" .. i](wep)
			local stringbake

			if i ~= wep._EventSlotCount then
				stringbake = state_strings[32](state)
			else
				local fn = state_strings[wep._EventSlotNum % 32 + 1]

				if not fn then break end
				stringbake = fn(state)
			end

			draw.SimpleTextOutlined(stringbake, "TFASleekSmall", x + 240, y2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
			y2 = y2 + TFA.Fonts.SleekHeightSmall
		end
	end

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
	if not wep:IsValid() or not wep.IsTFAWeapon then return end

	w, h = ScrW(), ScrH()

	DrawDebugInfo(w, h, ply, wep)
	DrawDebugCrosshair(w, h)
end)
