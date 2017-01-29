if SERVER then
	AddCSLuaFile()

	return
end

local padding = TFA.AttachmentUIPadding
local PANEL = {}
PANEL.Wep = nil
PANEL.ID = nil
PANEL.Att = nil --Weapon attachment
PANEL.Attachment = nil --Actual TFA attachment table

function PANEL:Init()
	self.Wep = nil --Weapon Entity
	self.ID = nil --Attachment ID
	self.Att = nil --Attachment Category
	self.Attachment = nil --TFA Attachment Name
	self:SetMouseInputEnabled(true)
	self:SetZPos( 500 )
end

function PANEL:SetWeapon(wep)
	if IsValid(wep) then
		self.Wep = wep
	end
end

function PANEL:SetGunAttachment(att)
	if att ~= nil then
		self.Att = att
	end
end

function PANEL:SetAttachment(att)
	self.Attachment = att
end

function PANEL:SetID(id)
	if id ~= nil then
		self.ID = id
	end
end

function PANEL:GetSelected()
	if not IsValid(self.Wep) then return false end
	if not self.Att then return end
	if not self.ID then return end
	if not self.Wep.Attachments[self.Att] then return end

	return self.Wep.Attachments[self.Att].sel == self.ID
end

function PANEL:AttachSound( attached )
	chat.PlaySound()
end

function PANEL:OnMousePressed()
	if not IsValid(self.Wep) or ( not self.Attachment ) or self.Attachment == "" then return end
	if not self.Wep:CanAttach( self.Attachment ) then return end
	if self:GetSelected() then
		self.Wep:SetTFAAttachment( self.Att, -1, true )
		self:AttachSound( false )
	elseif IsValid(self.Wep) and self.Wep.Attachments[self.Att] then
		self.Wep:SetTFAAttachment( self.Att, self.ID, true )
		self:AttachSound( true )
	end
end

surface.CreateFont("TFAAttachmentIconFont", {
	font = "Aral", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 12,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

surface.CreateFont("TFAAttachmentIconFontTiny", {
	font = "Aral", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	size = 10,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

local function abbrev( str )
	local tbl = string.Explode(" ",str,false)
	local retstr = ""
	for k,v in ipairs(tbl) do
		local tmpstr = string.sub(v,1,1)
		retstr = retstr .. ( ( k == 1 ) and string.upper( tmpstr ) or string.lower( tmpstr ) )
	end
	return retstr
end

function PANEL:Paint(w, h)
	if not IsValid(self.Wep) then return end
	if self.Attachment == nil then return end
	local sel = self:GetSelected()
	local col = sel and TFA.AttachmentColors["active"] or TFA.AttachmentColors["background"]
	if not self.Wep:CanAttach( self.Attachment) then col = TFA.AttachmentColors["error"] end
	draw.RoundedBox(0, 0, 0, w, h, ColorAlpha( col, self.Wep.InspectingProgress * 225))

	if not TFA.Attachments[self.Attachment].Icon then
		TFA.Attachments[self.Attachment].Icon = "entities/tfa_qmark.png"
	end

	if not TFA.Attachments[self.Attachment].Icon_Cached then
		TFA.Attachments[self.Attachment].Icon_Cached = Material( TFA.Attachments[self.Attachment].Icon, "noclamp smooth" )
	end

	surface.SetDrawColor(ColorAlpha(color_white, self.Wep.InspectingProgress * 255))
	surface.SetMaterial(TFA.Attachments[self.Attachment].Icon_Cached)
	surface.DrawTexturedRect(padding, padding, w - padding * 2, h - padding * 2)
	if not TFA.Attachments[self.Attachment].ShortName then
		TFA.Attachments[self.Attachment].ShortName = abbrev( TFA.Attachments[self.Attachment].Name or "")
	end
	draw.SimpleText( string.upper( TFA.Attachments[self.Attachment].ShortName ) , "TFAAttachmentIconFontTiny", padding / 4, h, ColorAlpha(TFA.AttachmentColors["primary"], self.Wep.InspectingProgress * ( sel and 192 or 64 ) ), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
end

vgui.Register("TFAAttachmentIcon", PANEL, "Panel")