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

local Lerp = Lerp
local RealFrameTime = RealFrameTime

local vector_one = Vector(1, 1, 1)

matproxy.Add({
	name = "TFA_CubemapTint",
	init = function(self, mat, values)
		self.ResultVar = values.resultvar or "$envmaptint"
		self.MultVar = values.multiplier
	end,
	bind = function(self, mat, ent)
		local tint = vector_one

		if IsValid(ent) then
			local mult = self.MultVar and mat:GetVector(self.MultVar) or vector_one

			tint = Lerp(RealFrameTime() * 10, mat:GetVector(self.ResultVar), mult * render.GetLightColor(ent:GetPos()))
		end

		mat:SetVector(self.ResultVar, tint)
	end
})

-- VMT Example:
--[[
	$envmapmultiplier	"[1 1 1]" // Lighting will be multiplied by this value

	Proxies
	{
		TFA_CubemapTint
		{
			resultvar	$envmaptint // Write final output to $envmaptint
			multiplier	$envmapmultiplier // Use our value for default envmap tint
		}
	}
]]