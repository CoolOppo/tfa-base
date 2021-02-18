
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

local sp = game.SinglePlayer()

hook.Add("PlayerSwitchWeapon", "TFA_Bodygroups_PSW", function(ply, oldwep, wep)
	if not IsValid(wep) or not wep.IsTFAWeapon then return end

	timer.Simple(0, function()
		if IsValid(ply) and ply:GetActiveWeapon() == wep then
			local vm = ply:GetViewModel()
			if not IsValid(vm) then return end

			local bgcount = #(vm:GetBodyGroups() or {})
			local bgt = wep.ViewModelBodygroups or wep.Bodygroups or {}

			if wep.GetStat then
				bgt = wep:GetStatL("ViewModelBodygroups", bgt)
			end

			for i = 0, bgcount - 1 do
				vm:SetBodygroup(i, bgt[i] or 0)
			end

			if wep.ClearMaterialCache then
				wep:ClearMaterialCache()

				if sp then
					wep:CallOnClient("ClearMaterialCache")
				end
			end
		end
	end)
end)
