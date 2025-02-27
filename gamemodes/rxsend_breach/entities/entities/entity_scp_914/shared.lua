ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "SCP-914"

function ENT:SetupDataTables()

  self:NetworkVar( "Int", 0, "Status" )
  self:NetworkVar( "Bool", 0, "Working" )

  self:SetStatus(1)
  self:SetWorking(false)

end
