include("shared.lua")

function ENT:Draw()
    self:DrawModel() -- Draw the model.
end

hook.Add("PostDrawTranslucentRenderables", "ClientArrowsUpdate", function()
    for k, v in pairs(TFArrowEnts) do
        v:UpdatePosition()
    end
end)
