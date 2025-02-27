include( "shared.lua" )

local vec_offset = Vector( 0, 0, 30 )

function ENT:Think()

  if ( !self.StartPatricle ) then

    self.StartPatricle = true
    ParticleEffect( "mr_portal_2a_fg", self:GetPos() + vec_offset, angle_zero, self )

  end

  local dlight = DynamicLight( self:EntIndex() )
  if ( dlight ) then
    dlight.pos = self:GetPos() + Vector(0,0,7)
    dlight.r = 0
    dlight.g = 15
    dlight.b = 0
    dlight.brightness = 0.5
    dlight.Decay = 400
    dlight.Size = 1251
    dlight.DieTime = CurTime() + 5
  end

end

function ENT:OnRemove()

  self:StopAndDestroyParticles()

end

function ENT:Draw()
end
