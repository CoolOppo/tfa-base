if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Base Attachment"
ATTACHMENT.ShortName = nil --Abbreviation, 5 chars or less please
ATTACHMENT.Description = {} --TFA.Attachments.Colors["+"], "Does something good", TFA.Attachments.Colors["-"], "Does something bad" }
ATTACHMENT.Icon = nil --Revers to label, please give it an icon though!  This should be the path to a png, like "entities/tfa_ammo_match.png"
ATTACHMENT.WeaponTable = {} --put replacements for your SWEP talbe in here e.g. ["Primary"] = {}

function ATTACHMENT:CanAttach(wep)
	return true --can be overridden per-attachment
end

function ATTACHMENT:Attach(wep)
end

function ATTACHMENT:Detach(wep)
end

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end