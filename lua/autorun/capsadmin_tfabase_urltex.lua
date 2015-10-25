--[[This code is by CapsAdmin, modified by TheForgottenArchitect, and released under GPL V3]]
--[[
tfabase_urltex = tfabase_urltex or {}

tfabase_urltex.TextureSize = 512
tfabase_urltex.ActivePanel = tfabase_urltex.ActivePanel or NULL
tfabase_urltex.Queue = tfabase_urltex.Queue or {}
tfabase_urltex.Cache = tfabase_urltex.Cache or {}

concommand.Add("cl_tfa_tfabase_urltex_clear_cache", function()
	tfabase_urltex.Cache = {}
	tfabase_urltex.Queue = {}
end)

if tfabase_urltex.ActivePanel:IsValid() then
	tfabase_urltex.ActivePanel:Remove()
end

local enable = CreateClientConVar("cl_tfa_enable_tfabase_urltex", "1", true)

function tfabase_urltex.GetMaterialFromURL(url, callback, skip_cache, shader, size, size_hack)
	if size_hack == nil then
		size_hack = true
	end
	shader = shader or "VertexLitGeneric"
	if not enable:GetBool() then return end
	
	url = url:gsub("https://", "http://")
	
	if type(callback) == "function" and not skip_cache and tfabase_urltex.Cache[url] then
		local tex = tfabase_urltex.Cache[url]
		local mat = CreateMaterial("cl_tfa_tfabase_urltex_" .. util.CRC(url .. SysTime()), shader)
		mat:SetTexture("$basetexture", tex)
		callback(mat, tex)
		return
	end
	if tfabase_urltex.Queue[url] then
		local old = tfabase_urltex.Queue[url].callback
		tfabase_urltex.Queue[url].callback = function(...)	
			callback(mat, tex)
			old()
		end
	else
		tfabase_urltex.Queue[url] = {callback = callback, tries = 0, size = size, size_hack = size_hack}
	end
end

function tfabase_urltex.Think()
	if table.Count(tfabase_urltex.Queue) > 0 then
		for url, data in pairs(tfabase_urltex.Queue) do
			-- when the panel is gone start a new one
			if not tfabase_urltex.ActivePanel:IsValid() then
				tfabase_urltex.StartDownload(url, data)
			end
		end
		tfabase_urltex.Busy = true
	else
		tfabase_urltex.Busy = false
	end
end

timer.Create("tfabase_urltex_queue", 0.1, 0, tfabase_urltex.Think)

function tfabase_urltex.StartDownload(url, data)

	if tfabase_urltex.ActivePanel:IsValid() then
		tfabase_urltex.ActivePanel:Remove()
	end
	
	local size = data.size or tfabase_urltex.TextureSize

	local id = "tfabase_urltex_download_" .. url
	
	local pnl = vgui.Create("HTML")
	pnl:SetVisible(true)
	--pnl:SetPos(50,50)
	pnl:SetPos(ScrW()-1, ScrH()-1)
	pnl:SetSize(size, size)
	pnl:SetHTML( (data.size_hack and "margin: -8px -8px;" or "margin: 0px 0px;") .. url .. size.. size	)
	

	local function start()
		local go = false
		local time = 0

		-- restart the timeout
		timer.Stop(id)
		timer.Start(id)
	
		hook.Add("Think", id, function()
		
			-- panel is no longer valid
			if not pnl:IsValid() then
				hook.Remove("Think", id)
				-- let the timeout handle it
				return
			end
			
			local html_mat = pnl:GetHTMLMaterial()
					
			-- give it some time.. IsLoading is sometimes lying
			if not go and html_mat and not pnl:IsLoading() then
				time = RealTime() + 1
				go = true
			end
				
			if go and time > RealTime() then
				local vertex_mat = CreateMaterial("cl_tfa_tfabase_urltex_" .. util.CRC(url .. SysTime()), "VertexLitGeneric")
				
				local tex = html_mat:GetTexture("$basetexture")
				tex:Download()
				
				vertex_mat:SetTexture("$basetexture", tex)				
				
				tex:Download()
				
				tfabase_urltex.Cache[url] = tex
				
				hook.Remove("Think", id)
				timer.Remove(id)
				tfabase_urltex.Queue[url] = nil
				timer.Simple(0, function() pnl:Remove() end)
								
				if data.callback then
					data.callback(vertex_mat, tex)
				end
			end
			
		end)
	end

	start()
	
	-- 5 sec max timeout
	timer.Create(id, 5, 1, function()
		timer.Remove(id)
		tfabase_urltex.Queue[url] = nil
		pnl:Remove()
		
		if hook.GetTable().Think[id] then
			hook.Remove("Think", id)
		end

		if data.tries < 5 then
			print("timeout")
			-- try again
			data.tries = data.tries + 1
			tfabase_urltex.GetMaterialFromURL(url, data)
			tfabase_urltex.Queue[url] = data
		else
			print("timed out for good")
		end
	end)
	
	tfabase_urltex.ActivePanel = pnl
end
]]--