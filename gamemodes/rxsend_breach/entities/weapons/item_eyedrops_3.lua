AddCSLuaFile()

if ( CLIENT ) then

  SWEP.InvIcon = Material( "nextoren/gui/icons/eyedrops_3.png" )

end

SWEP.ViewModelFOV	= 60
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/cultist/items/eyedrops/eyedrops.mdl"
SWEP.WorldModel		= "models/cultist/items/eyedrops/eyedrops.mdl"
SWEP.PrintName		= "Экспериментальные Глазные Капли"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false
SWEP.Skin = 2

SWEP.droppable				= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			=  "none"
SWEP.Secondary.Automatic	=  false

function SWEP:Deploy()

	self.Owner:DrawViewModel( false )

end

function SWEP:DrawWorldModel()

	if ( !( self.Owner && self.Owner:IsValid() ) ) then

		self:DrawModel()
    self:SetSkin( self.Skin )

	end

end

function SWEP:Initialize()

	self:SetCollisionGroup( COLLISION_GROUP_WORLD )

	self:SetHoldType( self.HoldType )
	self:SetSkin( 1 )

end

function SWEP:PrimaryAttack()

  if ( self.IsUsing ) then return end

  self.IsUsing = true

  if ( CLIENT ) then

    EyeDrops( self.Owner, 3 )

  end

  if ( SERVER ) then

	  OnUseEyedrops( self.Owner, 3 )
    self:Remove()

  end

end

function SWEP:CanSecondaryAttack()

  return false

end
