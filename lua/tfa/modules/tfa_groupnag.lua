if SERVER then
	
	util.AddNetworkString( "TFAJoinGroupPopup" )
	
	hook.Add("PlayerSay","TFAJoinGroupChat", function(ply,text,tc)
		if string.Trim(text)=="!jointfa" then
			net.Start("TFAJoinGroupPopup")
			net.Send(ply)
		end
	end)

end

if CLIENT then

	TFA_SHOULD_NAG = false
	
	if !file.Exists("tfa_hasnagged.txt","DATA") then
		local f = file.Open("tfa_hasnagged.txt","w","DATA")
		f:Write("yes")
		f:Flush()
		f:Close()
		
		TFA_SHOULD_NAG = true
	end
	
	hook.Add("HUDPaint", "TFA_NAG",function()
		if IsValid(LocalPlayer()) then
			
			if TFA_SHOULD_NAG then
				chat.AddText( "Dear ", LocalPlayer(),", please take a moment to join TFA Mod News.  It's the best way to stay updated about what I change and why.  You'll only receive this message once, but please consider it. Every member helps! To join, please type \"!jointfa\" in chat without quotes.")
			end
			
			hook.Remove("HUDPaint","TFA_NAG")
		end
	end)
	
	net.Receive("TFAJoinGroupPopup",function()
		gui.OpenURL( "http://steamcommunity.com/groups/tfa-mods" )
	end)
end