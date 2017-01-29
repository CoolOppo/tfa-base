if not ATTACHMENT then
	ATTACHMENT = {}
end

ATTACHMENT.Name = "Slug Ammunition"
ATTACHMENT.ShortName = "Slug" --Abbreviation, 5 chars or less please
--ATTACHMENT.ID = "base" -- normally this is just your filename
ATTACHMENT.Description = { TFA.AttachmentColors["+"], "Much lower spread", TFA.AttachmentColors["+"], "100m higher range", TFA.AttachmentColors["-"], "30% less damage", "One pellet"  }
ATTACHMENT.Icon = "entities/tfa_ammo_slug.png" --Revers to label, please give it an icon though!  This should be the path to a png, like "entities/tfa_ammo_match.png"

ATTACHMENT.WeaponTable = {
	["Primary"] = {
		["Damage"] = function( wep, stat ) return wep.Primary.NumShots * stat * 0.7 end,
		["NumShots"] = function( wep, stat ) return 1, true end,
		["Spread"] = function( wep, stat ) return math.max( stat - 0.02, stat * 0.5 ) end,
		["IronAccuracy"] = function( wep, stat ) return math.max( stat - 0.02, stat * 0.5 ) end,
		["Range"] = function( wep, stat ) return stat + 100 * 39.370 end
	}
}

if not TFA_ATTACHMENT_ISUPDATING then
	TFAUpdateAttachments()
end
