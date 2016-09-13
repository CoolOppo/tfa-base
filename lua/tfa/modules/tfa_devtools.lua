local w,h,cv_dbc,lply

hook.Add("HUDPaint","tfa_debugcrosshair",function()
	if !cv_dbc then cv_dbc = GetConVar("cl_tfa_debugcrosshair") end
	if !cv_dbc or !cv_dbc:GetBool() then return end
	if !w then w = ScrW() end
	if !h then h = ScrH() end
	if !IsValid(lply) then lply = LocalPlayer() end
	if !IsValid(lply) then return end
	if !lply:IsAdmin() then return end
	surface.SetDrawColor(color_white)
	surface.DrawRect(w/2-1,h/2-1,2,2)
end)
