
AddCSLuaFile()

if ( CLIENT ) then

	SWEP.InvIcon = Material( "nextoren/gui/icons/player_check.png" )

end

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= ""
SWEP.WorldModel		= ""
SWEP.PrintName		= "Действие: Проверка Класса"
SWEP.Slot			= 1
SWEP.SlotPos		= 1
SWEP.DrawAmmo		= false
SWEP.DrawCrosshair	= true
SWEP.HoldType		= "normal"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.UnDroppable				= true

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

  if ( SERVER ) then

    self.Owner:DrawWorldModel( false )

  end

  self.Owner:DrawViewModel( false )

end

SWEP.AlreadyChecked = {}

local Phrases = {

  [ TEAM_CLASSD ] = "D级人员",
  [ TEAM_GOC ] = "D级人员",
  [ TEAM_SCI ] = "科研人员",
  [ TEAM_SPECIAL ] = "科研人员",
  [ TEAM_DZ ] = "未知人员",
  [ TEAM_USA ] = "科研人员",
  [ TEAM_CHAOS ] = "未知人员",
  [ TEAM_SECURITY ] = "安保部门武装人员",
  [ TEAM_QRT ] = "快速反应小队人员",
  [ TEAM_NTF ] = "机动特遣队九尾狐武装人员",
  [ TEAM_GUARD ] = "基金会站点武装人员"

}
function SWEP:PrimaryAttack()

  if ( CLIENT ) then return end

  local tr = self.Owner:GetEyeTrace()

  if ( !tr.Entity:IsPlayer() ) then return end

  if ( tr.Entity:GTeam() == TEAM_SCP ) then return end

	for _, v in ipairs( self.AlreadyChecked ) do

		if ( v.name == tr.Entity:GetNamesurvivor() ) then

      self.Owner.BypassMute = true
			self.Owner:ConCommand( "say 我已经查过这个人了，他是 "..v.phrase .. "." )

			return
		end

	end

  self.Owner:BrProgressBar( "l:checking_class", 4, "nextoren/gui/icons/player_check.png", tr.Entity, true, function()

		local tr = self.Owner:GetEyeTrace()

		if ( !( tr.Entity && tr.Entity:IsValid() ) ) then return end
		
		if ( tr.Entity:GTeam() == TEAM_CLASSD || tr.Entity:GTeam() == TEAM_CHAOS || tr.Entity:GTeam() == TEAM_DZ || tr.Entity:GTeam() == TEAM_USA ) then

			self.Owner:AddToStatistics( "l:checker_bonus", 100 )

		end

  	self.AlreadyChecked[ #self.AlreadyChecked + 1 ] = { name = tr.Entity:GetNamesurvivor(), phrase = Phrases[ tr.Entity:GTeam() ] }
    self.Owner.BypassMute = true
    self.Owner:ConCommand( "say 这个人是 "..Phrases[ tr.Entity:GTeam() ] .. "." )

    local t = tr.Entity:GTeam()
    if t == TEAM_GOC or t == TEAM_CHAOS or t == TEAM_DZ then
      self.Owner:CompleteAchievement("mtfagent")
    end

  end )


end

function SWEP:CanPrimaryAttack()

  return true

end

function SWEP:CanSecondaryAttack()

  return false

end

function SWEP:Think() end
