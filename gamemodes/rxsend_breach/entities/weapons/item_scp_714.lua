AddCSLuaFile()
if CLIENT then
SWEP.InvIcon = Material( "nextoren/gui/icons/scp714.png" )
	SWEP.BounceWeaponIcon = false
	
end
SWEP.ViewModelFOV	= 60
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/mishka/models/scp714.mdl"
SWEP.WorldModel		= "models/mishka/models/scp714.mdl"
SWEP.PrintName		= "SCP-714"
SWEP.Slot			= 3
SWEP.SlotPos			= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "items"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false
SWEP.SelectFont = "SCPHUDMedium"


SWEP.droppable				= true
SWEP.teams					= {2,3,5,6,7,8,9,10,11,12}

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo			=  "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo			=  "none"
SWEP.Secondary.Automatic	=  false

SWEP.InUse = false
SWEP.Durability = 100

function SWEP:Deploy()
	if not IsFirstTimePredicted() then return end
	self.Owner:DrawViewModel( false )
	self.InUse = true
	self.Owner.Using714 = true
end

function SWEP:Holster()
	if not IsFirstTimePredicted() then return end
	self.InUse = false
	self.Owner.Using714 = false
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
	if CLIENT then
		self.Lang = GetWeaponLang().SCP_714
		self.Author		= self.Lang.author
		self.Contact		= self.Lang.contact
		self.Purpose		= self.Lang.purpose
		self.Instructions	= self.Lang.instructions
	end
	self:SetHoldType(self.HoldType)
end

SWEP.LastTime = 0

function SWEP:Think()
	if not IsFirstTimePredicted() then return end
	if !self.InUse then return end
	if self.LastTime > CurTime() then return end
	self.LastTime = CurTime() + 1
	self.Durability = self.Durability - 1
	if SERVER then
		if self.Durability > 0 then
			if self.Owner:GetMaxHealth() > self.Owner:Health() then
				self.Owner:SetHealth( self.Owner:Health() + 1 )
			end
		end
		if self.Durability < 1 then self.Owner:SelectWeapon("v92_eq_rece") self.Owner:StripWeapon( "item_scp_714" ) end
	end
end

function SWEP:OnRemove() 
	self.InUse = false
	for k, v in pairs( player.GetAll() ) do
		v.Using714 = false
	end
end

function SWEP:Reload()
end

function SWEP:OwnerChanged()
	self.InUse = false
	for k, v in pairs( player.GetAll() ) do
		v.Using714 = false
	end
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
	text = self.Lang.HUD.durability.." "..self.Durability.."%"
	disp = self.Lang.HUD.protect
	if self.Durability < 15 then
		disp = self.Lang.HUD.protend
	end
	

	
	draw.SimpleTextOutlined( self.Durability.."%", "HUDFont", ScrW() / 1.961, ScrH() - 110, Color( cRed, cGreen, 0 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, 1.5, color_black )
end 

	local icon_clr = Color( 10, 10, 40, 240 )



function SWEP:DrawHUDBackground()





		if self.Owner.Using714 then



			local w = 64

			local h = 64

			local padding = 133



			local screenheight = ScrH()



			local y = screenheight - 60

			local clr = color_white

			local percent = self.Durability


			local actualpercent = self.Durability
			
			if ( actualpercent < 0 ) then

				self.Owner.Using714 = nil


			end


			local screenwidth_one_half = ScrW() / 2

			local quad_pos = Vector( screenwidth_one_half, y )


			render.SetMaterial( Material( "nextoren/gui/special_abilities/714.png" ) )

			render.DrawQuadEasy( quad_pos,

				-vector_up,

				w, h,

				icon_clr,

				-90

			)

			render.SetScissorRect( screenwidth_one_half + 30, y + 32 - ( h * self.Durability / 100), padding + w, screenheight, true )


			render.DrawQuadEasy( quad_pos,

				-vector_up,

				w, h,

				clr,

				-90

			)

			render.SetScissorRect( 0, y + 32, padding + w, screenheight, false )



		end

	end
