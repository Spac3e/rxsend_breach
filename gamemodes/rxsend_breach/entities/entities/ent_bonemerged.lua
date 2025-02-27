AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:SetupDataTables()

  self:NetworkVar( "Bool", 0, "Invisible" )

  self:SetInvisible( false )

end

function ENT:Think()

  local parent = self:GetParent()
  local parent_valid = parent && parent:IsValid()

  if ( !parent_valid ) then

    self:Remove()

    return
  end

  local parent_nodraw = parent:GetNoDraw()
  local self_nodraw = self:GetNoDraw()

  if ( parent_valid && parent_nodraw && !self_nodraw ) then

    self:SetNoDraw( true )

  elseif ( parent_valid && self_nodraw && !parent_nodraw ) then

    self:SetNoDraw( false )

  end

end

if ( SERVER ) then return end

function ENT:Draw()

  if ( !self:GetInvisible() ) then

    self:DrawModel()

  end

end

function ENT:Think()

  local parent = self:GetParent()
  local parent_valid = parent && parent:IsValid()

  if ( !parent_valid && self:EntIndex() == -1 ) then

    self:Remove()

  elseif ( !parent_valid ) then

    return

  end

  if ( !parent:IsPlayer() ) then return end

  local parent_nodraw = parent:GetNoDraw()
  local self_nodraw = self:GetNoDraw()

  if ( parent_valid && parent_nodraw && !self_nodraw ) then

    self:SetNoDraw( true )
    self.no_draw = true

  elseif ( parent_valid && !parent_nodraw && self_nodraw ) then

    self:SetNoDraw( false )
    self.no_draw = false

  end

end