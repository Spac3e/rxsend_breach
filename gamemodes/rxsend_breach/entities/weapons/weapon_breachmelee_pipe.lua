AddCSLuaFile()

if ( CLIENT ) then

  SWEP.Category = "[NextOren] Melee"
  SWEP.PrintName = "Гаечный ключ"
  SWEP.Slot = 1
  SWEP.ViewModelFOV = 50
  SWEP.InvIcon = Material( "nextoren/gui/icons/wrench.png" )
  SWEP.DrawSecondaryAmmo = false
  SWEP.DrawAmmo = false

end

SWEP.Base = "breach_melee_base"

SWEP.HoldType = "crowbar"
SWEP.ViewModel = "models/weapons/breach_melee/v_pipe.mdl"
SWEP.WorldModel = "models/weapons/breach_melee/w_pipe.mdl"

SWEP.PrimaryDamage = 30
SWEP.PrimaryStamina = 20
SWEP.DamageForce = 6

SWEP.Pos = Vector( -1, 4, -12 )
SWEP.Ang = Angle( 185, -28, 200 )

function SWEP:CreateWorldModel()

  if ( !self.WModel ) then

    self.WModel = ClientsideModel( self.WorldModel, RENDERGROUP_OPAQUE )
    self.WModel:SetNoDraw( true )

  end

  return self.WModel

end

function SWEP:DrawWorldModel()

  local wm = self:CreateWorldModel()

  local pl = self:GetOwner()

  if ( IsValid( pl ) ) then

    local bone = self.Owner:LookupBone( "ValveBiped.Bip01_R_Hand" )
    if ( !bone ) then return end
    local pos, ang = self.Owner:GetBonePosition( bone )

    if ( bone ) then

      ang:RotateAroundAxis( ang:Right(), self.Ang.p )
      ang:RotateAroundAxis( ang:Forward(), self.Ang.y )
      ang:RotateAroundAxis( ang:Up(), self.Ang.r )
      wm:SetRenderOrigin( pos + ang:Right() * self.Pos.x + ang:Forward() * self.Pos.y + ang:Up() * self.Pos.z )
      wm:SetRenderAngles( ang )
      wm:DrawModel()

    end

  else

    self:SetRenderOrigin( nil )
    self:SetRenderAngles( nil )
    self:DrawModel()

  end

end
