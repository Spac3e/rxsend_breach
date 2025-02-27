AddCSLuaFile()
if CLIENT then
SWEP.InvIcon = Material( "nextoren/gui/icons/scp/427.png" )

	SWEP.BounceWeaponIcon = false
	
end
SWEP.ViewModelFOV	= 60
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/cpthazama/scp/427.mdl"
SWEP.WorldModel		= "models/cpthazama/scp/427.mdl"
SWEP.PrintName		= "SCP-427"
SWEP.Slot			= 3
SWEP.SlotPos			= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "items"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false
SWEP.SelectFont = "SCPHUDMedium"


SWEP.droppable				= false
SWEP.teams					= {2,3,5,6,7,8,9,10,11,12}

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			=  "none"
SWEP.Secondary.Automatic	=  false

SWEP.Durability = 100

function SWEP:Deploy()
	if not IsFirstTimePredicted() then return end
	self.Owner:DrawViewModel( false )
end

function SWEP:Holster()
	if not IsFirstTimePredicted() then return end
	return true
end

function SWEP:Equip()
	if not IsFirstTimePredicted() then return end
end

function SWEP:DrawWorldModel()
	if !IsValid(self.Owner) then
		self:DrawModel()
	end
end

SWEP.Lang = nil

function SWEP:Initialize()

	self:SetHoldType(self.HoldType)
end

SWEP.LastTime = 0

function SWEP:Think()
	if not IsFirstTimePredicted() then return end
	if self.LastTime > CurTime() then return end
	self.LastTime = CurTime() + 2
	self.Durability = self.Durability - 1
	if SERVER then
		if self.Durability > 0 then
		end
		if self.Durability < 1 then  end
	end
end

function SWEP:OnRemove() 
end

function SWEP:Reload()
end

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:CanPrimaryAttack()
end

function SWEP:DrawHUD()
	if disablehud == true then return end
	
	local cRed = (100 - self.Durability) / 100 * 255
	local cGreen = self.Durability / 100 * 255
	
	color = Color( cRed, cGreen, 0 )
	text = "Naszyjnik zacznie Ciebie dusić, jeśli osiągniesz wystarczające wzmocnienie"
	disp = "Naszyjnik Ciebie wzmacnia"
	if self.Owner:Health() > 560 then
		color = Color( 255,0,0 )
		disp = "Naszyjnik zaczyna się zacieśniać, powodując duszenie"
	end
	
	draw.Text( {
		text = text,
		pos = { ScrW() / 2, ScrH() - 60 },
		font = "HUDFont",
		color = color,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	} )
	
		draw.Text( {
		text = disp,
		pos = { ScrW() / 2, ScrH() - 30 },
		font = "HUDFont",
		color = color,
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	} )
	
end