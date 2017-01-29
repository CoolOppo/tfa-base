if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Base Attachment"
ATTACHMENT.ShortName = nil --Abbreviation, 5 chars or less please
--ATTACHMENT.ID = "base" -- normally this is just your filename
ATTACHMENT.Description = { TFA.AttachmentColors["+"], "Does something good", TFA.AttachmentColors["-"], "Does something bad" }
ATTACHMENT.Icon = nil --Revers to label, please give it an icon though!  This should be the path to a png, like "entities/tfa_ammo_match.png"

ATTACHMENT.WeaponTable = {
	["Primary"] = {}
}

function ATTACHMENT:Attach(wep)
end

function ATTACHMENT:Detach(wep)
end

--Toss basically anything into here, inline with this format:
--[[
ATTACHMENT.WeaponTable = {
	["Primary"] = {
		["Damage"] = function(wep,val) return val * 1.15 end
	},
	["VElements"] = {
		["sample"] = {
			["active"] = true
		}
	}
}
]]--

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end
