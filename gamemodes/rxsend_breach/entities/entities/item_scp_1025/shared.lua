ENT.Type = "anim"
ENT.Base = "base_anim"

ENT.PrintName = "SCP-1025"

function ENT:Initialize()

  self:SetModel("models/mishka/models/scp1025.mdl");

  self:PhysicsInit( SOLID_VPHYSICS )

  self:SetMoveType( MOVETYPE_VPHYSICS )

  self:SetSolid(SOLID_VPHYSICS)

  self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

  self:PhysWake()

  self:AddEFlags(EFL_NO_DAMAGE_FORCES)

  self.BlockDrag = true

  if SERVER then
    self:SetUseType(SIMPLE_USE)
  end

end