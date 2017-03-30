if SERVER then
	AddCSLuaFile()
	return
end

local dimensions = 64
local padding = TFA.AttachmentUIPadding
local spacing = 64
local tooltip_mincount = 1

local PANEL = {}

PANEL.HasInitialized = false
PANEL.VM = nil
PANEL.Wep = nil
PANEL.Att = nil
PANEL.x = -1
PANEL.y = -1
PANEL.AttachmentTable = {}
PANEL.AttachmentIcons = {}
PANEL.Style = 0

function PANEL:Init()
	self.HasInitialized = false
	self.VM = nil
	self.Wep = nil
	self.Att = nil
	self.x = -1
	self.y = -1
	self.AttachmentTable = {}
	self.AttachmentIcons = {}
	self:SetMouseInputEnabled(true)
	self.Style = 0
end

function PANEL:Initialize()
	if not IsValid(self.VM) then return false end
	if not IsValid(self.Wep) then return false end
	if not self.Att then return end
	self.AttachmentTable = self.Wep.Attachments[ self.Att ]
	local attCnt = #self.AttachmentTable.atts
	self:Position()
	local truewidth = dimensions * attCnt + padding * ( math.max(0,attCnt-1) + 2 )
	local finalwidth = math.max( truewidth, dimensions * tooltip_mincount + padding * ( math.max(0,tooltip_mincount-1) + 2 ) )
	self:SetSize( finalwidth, dimensions + padding * 2 ) --+ tooltipheightmax + padding * 2 )
	self:DockPadding( 0, 0, 0, 0 )

	local toppanel = self:Add("DPanel")

	--toppanel:Dock( FILL )
	--toppanel:Dock(TOP)

	toppanel:SetWidth( finalwidth )
	toppanel:SetHeight( self:GetTall() )
	toppanel:DockPadding( padding,padding, padding, padding )
	toppanel.Paint = function(myself,w,h)
		draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( TFA.AttachmentColors["secondary"], ( self.Wep.InspectingProgress or 0 ) * 128 ) )
	end

	--[[

	local tooltip = self:Add("TFAAttachmentTip")
	tooltip:SetWeapon( self.Wep )
	tooltip:SetAttachment( self.Att )
	--tooltip:SetHeight( tooltipheightmax + padding * 2 )
	tooltip:SetSize( finalwidth, tooltipheightmax + padding * 2 )
	tooltip:SetPos(0, toppanel:GetTall() )
	self.ToolTip = tooltip

	]]--

	local tooltip = vgui.Create("TFAAttachmentTip")
	tooltip.Anchor = self
	tooltip:SetWeapon( self.Wep )
	tooltip:SetAttachment( self.Att )
	--tooltip:SetHeight( tooltipheightmax + padding * 2 )
	tooltip:SetWidth( finalwidth )
	--tooltip:SetSize( finalwidth, tooltipheightmax + padding * 2 )
	tooltip:SetPos(0, toppanel:GetTall() )
	self.ToolTip = tooltip

	--local keyz = table.GetKeys( self.AttachmentTable.atts )
	--table.sort(keyz)
	--PrintTable(keyz)
	--for _,k in ipairs(keyz) do
	--	local v = self.AttachmentTable.atts[k]
	local i = 0
	for k,v in ipairs( self.AttachmentTable.atts ) do
		local p = toppanel:Add("TFAAttachmentIcon")

		p:SetWeapon( self.Wep )
		p:SetGunAttachment( self.Att )
		p:SetAttachment( v )
		p:SetID(k)

		p:SetSize(dimensions,dimensions)
		p:SetPos( dimensions * i + padding * ( i + 1 ), padding )
		i = i + 1
		--p:SetPos(0,0)
		--p:DockMargin( 0,0, padding, 0 )
		--p:Dock(LEFT)
		self.AttachmentIcons[k] = p
	end

	self.HasInitialized = true
	return true
end

function PANEL:CalcVAtt()
	if not self.VAtt then
		self.VAtt = 0
		local keyz = table.GetKeys( self.Wep.Attachments or {} )
		table.RemoveByValue( keyz, "BaseClass" )
		table.sort( keyz, function(a,b)
			--A and B are keys
			local v1 = self.Wep.Attachments[a]
			local v2 = self.Wep.Attachments[b]
			if v1 and v2 and v1.order then
				return v1.order < ( v2.order or math.huge )
			else
				return a < b
			end
		end)
		for k,v in ipairs(keyz) do
			if self.Att == v then
				self.VAtt = k
			end
		end
		--self:SetZPos( 100 - self.VAtt )
	end
end

function PANEL:Think()
	if not IsValid(self.ToolTip) then return end

	self:CalcVAtt()

	local header = nil
	local texttable = nil
	for k,v in pairs( self.AttachmentIcons ) do
		if v:IsHovered() then
			header = TFA.Attachments[v.Attachment].Name
			texttable = TFA.Attachments[v.Attachment].Description
			break
		end
	end
	if not header then
		for k,v in pairs( self.AttachmentIcons ) do
			if v:GetSelected() then
				header = TFA.Attachments[v.Attachment].Name
				texttable = {}--TFA.Attachments[v.Attachment].Description
				break
			end
		end
	end
	self.ToolTip:SetHeader(header)
	self.ToolTip:SetTextTable(texttable)
	self.ToolTip:SetActive( texttable and #texttable > 0 )
	if self:GetStyle() == 0 then
		self.ToolTip:SetContentPanel( self.ContentPanel )
	end
	self:Position()
end

function PANEL:SetContentPanel( p )
	if IsValid(p) then
		self.ContentPanel = p
	else
		self.ContentPanel = nil
	end
end

function PANEL:SetViewModel( vm )
	if IsValid(vm) then
		self.VM = vm
	end
end

function PANEL:SetWeapon( wepv )
	if IsValid(wepv) then
		self.Wep = wepv
	end
end

function PANEL:SetAttachment( att )
	if att ~= nil then
		self.Att = att
	end
end

function PANEL:GetAnchoredH()
	if self.HAnchored then return true end
	return false
end

function PANEL:SetStyle( s )
	self.Style = s
end

function PANEL:GetStyle()
	return self.Style
end

function PANEL:Position()
	if IsValid(self.Wep) and self:GetStyle() == 1 then
		local AngPos = self.VM:GetAttachment(self.Att)
		if not AngPos then return end
		local scr = AngPos.Pos:ToScreen()
		local w,h = self:GetSize()
		local tx = math.Clamp( scr.x - w / 2 + self.AttachmentTable.offset[1], 0, ScrW() - w )
		local ty = math.Clamp( scr.y - h / 2 + self.AttachmentTable.offset[2], 0, ScrH() - h )
		self:SetPos( math.floor(tx), math.floor(ty) )
		self.HAnchored = false
		--[[
		if IsValid( self.ToolTip ) then
			local xp, yp = self:GetPos()
			self.ToolTip:SetPos( xp, yp + self:GetTall() )
		end
		]]--
	else
		self:CalcVAtt()
		self:SetPos( math.floor( self:GetParent():GetWide() - 32 - self:GetWide() ), math.max( self.VAtt - 1, 0 ) * dimensions + math.max( self.VAtt - 1, 0 ) * padding * 4 + math.max( self.VAtt - 1, 0 ) * spacing )
		self.HAnchored = true
	--[[else
		self:CalcVAtt()
		local hv = math.Round( ScrH() * 0.8)
		self:SetPos( ScrW() - 64 - padding * 2 - self:GetWide(), ( ScrH() - hv ) / 2 + 64 + math.max( self.VAtt - 1, 0 ) * dimensions + math.max( self.VAtt - 1, 0 ) * padding * 4 + math.max( self.VAtt - 1, 0 ) * spacing  )
		--self:SetPos( ScrW() - 64 - padding * 2 - math.max( ( dimensions + padding ) * 3 ,self:GetWide()), ( ScrH() - hv ) / 2 + 32 + math.max( self.VAtt - 1, 0 ) * dimensions + math.max( self.VAtt - 1, 0 ) * padding * 4 + math.max( self.VAtt - 1, 0 ) * spacing  )
		--self:SetPos( ScrW() - 64 - padding * 2 - 256, ( ScrH() - hv ) / 2 + math.max( self.VAtt - 1, 0 ) * dimensions + math.max( self.VAtt - 1, 0 ) * padding * 4 + math.max( self.VAtt - 1, 0 ) * spacing  )
		--self:SetPos( 64 + padding, ( ScrH() - hv ) / 2 + 312 + math.max( self.VAtt - 1, 0 ) * dimensions + math.max( self.VAtt - 1, 0 ) * padding * 4 + math.max( self.VAtt - 1, 0 ) * spacing  )
		self.HAnchored = true
	end
	]]--
	end
end

function PANEL:Paint( w, h )
	if not self.HasInitialized then return false end
	if not IsValid(self.VM) then self:Remove() end
	if ( not IsValid(self.Wep) ) or ( not IsValid(self.Wep:GetOwner()) ) or ( not self.Wep:GetOwner():IsPlayer() ) then
		gui.EnableScreenClicker(false)
		self:Remove()
	end
	if ( self.Wep.InspectingProgress or 0 ) < 0.01 then	self:Remove() end
end

vgui.Register( "TFAAttachmentPanel", PANEL, "Panel" )