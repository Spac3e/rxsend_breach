
include( "shared.lua" )

function ENT:Initialize()

  self:DestroyShadow()

end

ENT.ParticleTable = {

  [ 1 ] = { Name = "deathcore_range", Bone = "ValveBiped.Bip01_R_Hand" },
  [ 2 ] = { Name = "death_evil6" }

}

function ENT:CreateParticles()

  for i = 1, #self.ParticleTable do

    ParticleEffectAttach( self.ParticleTable[ i ].Name, PATTACH_POINT_FOLLOW, self, i )

  end

end

function ENT:Think()

  if ( !self.ParticlePlayed ) then

    self.ParticlePlayed = true

    self:CreateParticles()

  end

  if ( self.Bone_attach ) then

    self:SetPos( self:GetParent():GetBonePosition( self.Attach_id ) )

  end

  return true

end

function ENT:OnRemove()

  local parent = self:GetParent()

  if ( parent && parent:IsValid() ) then

    parent:StopParticles()

  end

  self:StopAndDestroyParticles()

end
