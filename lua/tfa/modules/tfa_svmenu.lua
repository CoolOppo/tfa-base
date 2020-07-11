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

local IsSinglePlayer = game.SinglePlayer()

if SERVER then
	util.AddNetworkString("TFA_SetServerCommand")

	local function ChangeServerOption(_length, _player)
		local _cvarname = net.ReadString()
		local _value = net.ReadString()

		if not IsValid(_player) or not _player:IsAdmin() then return end
		if IsSinglePlayer or _player:IsListenServerHost() then return end

		if not string.find(_cvarname, "_tfa") or not GetConVar(_cvarname) then return end -- affect only TFA convars

		RunConsoleCommand(_cvarname, _value)
	end

	net.Receive("TFA_SetServerCommand", ChangeServerOption)
end

if CLIENT then
	function TFA.NumSliderNet(_parent, ...)
		local newpanel = _parent:NumSlider(...)

		newpanel.OnValueChanged = function(_self, _newval)
			if not LocalPlayer():IsAdmin() then return end

			local _cvarname = _self.TextArea.m_strConVar

			if timer.Exists("tfa_vgui_" .. _cvarname) then
				timer.Remove("tfa_vgui_" .. _cvarname)
			end

			timer.Create("tfa_vgui_" .. _cvarname, 0.1, 1, function()
				if not LocalPlayer():IsAdmin() then return end

				net.Start("TFA_SetServerCommand")
				net.WriteString(_cvarname)
				net.WriteString(_newval)
				net.SendToServer()
			end)
		end

		return newpanel
	end

	function TFA.CheckBoxNet(_parent, ...)
		local newpanel = _parent:CheckBox(...)

		newpanel.OnValueChanged = function(_self, _bVal)
			if not LocalPlayer():IsAdmin() then return end

			net.Start("TFA_SetServerCommand")
			net.WriteString(_self.m_strConVar)
			net.WriteString(_bVal and "1" or "0")
			net.SendToServer()
		end

		return newpanel
	end

	function TFA.ComboBoxNet(_parent, ...)
		local rightpanel, leftpanel = _parent:ComboBox(...)

		if not IsSinglePlayer then
			rightpanel.OnSelect = function(_self, _index, _value, _data)
				if not _self.m_strConVar then return end

				local _newval = tostring(data or value)
				RunConsoleCommand(_self.m_strConVar, _newval)

				if LocalPlayer():IsAdmin() then
					net.Start("TFA_SetServerCommand")
					net.WriteString(_self.m_strConVar)
					net.WriteString(_newval)
					net.SendToServer()
				end
			end
		end

		return rightpanel, leftpanel
	end
end