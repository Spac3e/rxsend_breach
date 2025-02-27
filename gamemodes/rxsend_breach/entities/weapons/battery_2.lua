

AddCSLuaFile()

if ( CLIENT ) then

	SWEP.BounceWeaponIcon = false
	SWEP.InvIcon = Material( "nextoren/gui/icons/battery_2.png" )

end

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= ""
SWEP.WorldModel		= "models/cultist/items/battery/battery.mdl"
SWEP.PrintName		= "Улучшенная батарейка"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.Skin = 1
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "items"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.Charge = 40

SWEP.droppable				= true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			=  "none"
SWEP.Secondary.Automatic	=  false
SWEP.UseHands = true

SWEP.Pos = Vector( 1, 3, -2 )
SWEP.Ang = Angle( 240, -90, 240 )

function SWEP:Deploy()

  self.Owner:DrawViewModel( false )

end

function SWEP:CanPrimaryAttack()

  return false

end

function SWEP:CanSecondaryAttack()

  return false

end

function SWEP:CreateWorldModel()

	if ( !self.WModel ) then

		self.WModel = ClientsideModel( self.WorldModel, RENDERGROUP_OPAQUE )
		self.WModel:SetNoDraw( true )

	end

	return self.WModel

end

function SWEP:DrawWorldModel()

  if ( !IsValid( self.Owner ) ) then

		self:SetRenderOrigin( nil )
		self:SetRenderAngles( nil )
    self:SetSkin( self.Skin )
		self:DrawModel()

	end

end

function SWEP:Think() end


function SWEP:CanSecondaryAttack()

	return false

end
