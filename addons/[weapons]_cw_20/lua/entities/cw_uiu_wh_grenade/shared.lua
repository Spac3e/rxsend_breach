ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Thrown smoke grenade"
ENT.Author = "Spy"
ENT.Information = "Thrown smoke grenade"
ENT.Spawnable = false
ENT.AdminSpawnable = false 

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Fused" )

	self:SetFused(false)

end
