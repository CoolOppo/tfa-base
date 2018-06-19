TFA.Attachments = TFA.Attachments or {}
TFA.Attachments.Atts = {}

TFA.Attachments.Colors = {
	["active"] = Color(252, 151, 50, 255),
	["error"] = Color(225, 0, 0, 255),
	["background"] = Color(15, 15, 15, 64),
	["primary"] = Color(245, 245, 245, 255),
	["secondary"] = Color(153, 253, 220, 255),
	["+"] = Color(128, 255, 128, 255),
	["-"] = Color(255, 128, 128, 255),
	["="] = Color(192, 192, 192, 255)
}

TFA.Attachments.UIPadding = 2
TFA.Attachments.IconSize = 64
TFA.Attachments.CategorySpacing = 128

if SERVER then
	util.AddNetworkString("TFA_Attachment_Set")
	util.AddNetworkString("TFA_Attachment_Reload")
	util.AddNetworkString("TFA_Attachment_RequestAll")

	local function UpdateWeapon(wep, ply)
		for k, v in pairs(wep.Attachments) do
			if type(k) == "string" then continue end
			net.Start("TFA_Attachment_Set")
			net.WriteEntity(wep)
			net.WriteInt(k, 8)
			net.WriteInt(v.sel or -1, 7)
			net.Send(ply)
		end
	end

	local sp = game.SinglePlayer()

	net.Receive("TFA_Attachment_RequestAll", function(len, ply)
		if not IsValid(ply) then return end

		if sp or not ply.TFA_RequestAll then
			for _, v in pairs(ents.GetAll()) do
				if v:IsWeapon() and v:IsTFA() and v.HasInitAttachments then
					UpdateWeapon(v, ply)
				end
			end

			ply.TFA_RequestAll = true
		end
	end)

	net.Receive("TFA_Attachment_Set", function(len, ply)
		local wep = net.ReadEntity()

		if IsValid(ply) and IsValid(wep) and wep.SetTFAAttachment and ply:GetActiveWeapon() == wep then
			local cat = net.ReadInt(8)
			local ind = net.ReadInt(7)
			wep:SetTFAAttachment(cat, ind, true)
		end
	end)
end

if CLIENT then
	net.Receive("TFA_Attachment_Set", function(len)
		local wep = net.ReadEntity()

		if IsValid(wep) and wep.SetTFAAttachment then
			local cat = net.ReadInt(8)
			local ind = net.ReadInt(7)
			wep:SetTFAAttachment(cat, ind, false)
		end
	end)

	net.Receive("TFA_Attachment_Reload", function(len)
		TFAUpdateAttachments()
	end)

	hook.Add("HUDPaint", "TFA_Attachment_RequestAll", function()
		if LocalPlayer():IsValid() then
			hook.Remove("HUDPaint", "TFA_Attachment_RequestAll")
			net.Start("TFA_Attachment_RequestAll")
			net.SendToServer()
		end
	end)
end

function TFARegisterAttachment(att)
	local base

	if att.Base then
		base = TFA.Attachments.Atts[att.Base]
	else
		base = TFA.Attachments.Atts["base"]
	end

	if base then
		for k, v in pairs(base) do
			if not att[k] then
				att[k] = v
			end
		end
	end

	TFA.Attachments.Atts[att.ID or att.Name] = att
end

TFA.Attachments.Path = "tfa/att/"
TFA_ATTACHMENT_ISUPDATING = false

function TFAUpdateAttachments()
	if SERVER then
		net.Start("TFA_Attachment_Reload")
		net.Broadcast()
	end

	TFA.AttachmentColors = TFA.Attachments.Colors --for compatibility
	TFA.Attachments.Atts = {}
	TFA_ATTACHMENT_ISUPDATING = true
	local tbl = file.Find(TFA.Attachments.Path .. "*base*", "LUA", "namedesc")
	local addtbl = file.Find(TFA.Attachments.Path .. "*", "LUA", "namedesc")

	for _, v in ipairs(addtbl) do
		if not string.find(v, "base") then
			table.insert(tbl, #tbl + 1, v)
		end
	end

	for _, v in ipairs(tbl) do
		local id = v
		v = TFA.Attachments.Path .. v
		ATTACHMENT = {}
		ATTACHMENT.ID = string.Replace(id, ".lua", "")

		if SERVER then
			AddCSLuaFile(v)
			include(v)
		else
			include(v)
		end

		if ATTACHMENT.Model and type(ATTACHMENT.Model) == "string" and ATTACHMENT.Model ~= "" then
			util.PrecacheModel(ATTACHMENT.Model)
		end

		TFARegisterAttachment(ATTACHMENT)
		ATTACHMENT = nil
	end

	ProtectedCall(function()
		hook.Run("TFAAttachmentsLoaded")
	end)

	TFA_ATTACHMENT_ISUPDATING = false
end

hook.Add("InitPostEntity", "TFAUpdateAttachmentsIPE", TFAUpdateAttachments)

if TFAUpdateAttachments then
	TFAUpdateAttachments()
end

concommand.Add("sv_tfa_attachments_reload", function(ply, cmd, args, argStr)
	if SERVER and ply:IsAdmin() then
		TFAUpdateAttachments()
	end
end, function() end, "Reloads all TFA Attachments", {FCVAR_SERVER_CAN_EXECUTE})
--[[

if SERVER then
	util.AddNetworkString("TFA.Attachments.Atts")

	net.Receive("TFA.Attachments.Atts", function(length, client)
		if IsValid(client) then
			local wep = client:GetActiveWeapon()

			if IsValid(wep) and wep.Attach and wep.Detach then
				local attach = net.ReadBool()
				local attachment = net.ReadString()

				if attach then
					wep:Attach(attachment, true)
				else
					wep:Detach(attachment, true)
				end
			end
		end
	end)
end

hook.Add("PlayerBindPress", "TFA_Attachment_Binds", function(ply, bind, pressed)
	local first4 = string.sub(bind, 1, 4)
	if IsValid(ply) and pressed and first4 == "slot" then
		local wep = ply:GetActiveWeapon()

		if IsValid(wep) and wep.CLInspectingProgress and wep.CLInspectingProgress > 0.1 then
			--print(string.sub(bind,5,6))
			local slotstr = string.sub(bind, 5, 6)

			if slotstr and tonumber(slotstr) and wep.Attachments and wep.Attachments[slotnum] and wep.Attachments[slotnum].atts then
				local attbl = wep.Attachments[slotnum]
				local curatt = 0
				local newatt

				for k, v in pairs(attbl.atts) do
					if wep.AttachmentCache[v] and wep.AttachmentCache[v].active then
						curatt = k
					end
				end

				newatt = curatt + 1

				if newatt > #attbl.atts + 1 then
					newatt = 1
				end

				if attbl.atts[curatt] then
					wep:Detach(attbl.atts[curatt])
					net.Start("TFA.Attachments.Atts")
					net.WriteBool(false)
					net.WriteString(attbl.atts[curatt])
					net.SendToServer()
				end

				if attbl.atts[newatt] then
					wep:Attach(attbl.atts[newatt])
					net.Start("TFA.Attachments.Atts")
					net.WriteBool(true)
					net.WriteString(attbl.atts[newatt])
					net.SendToServer()
				end
			end
		end

		return true
	end
end)

]]
--