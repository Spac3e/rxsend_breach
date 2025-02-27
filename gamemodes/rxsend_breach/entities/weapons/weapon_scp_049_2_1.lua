AddCSLuaFile()

SWEP.HotKeyTable = {}

function toLines(text, font, mWidth)
  surface.SetFont(font)
  
  local buffer = { }
  local nLines = { }

  for word in string.gmatch(text, "%S+") do
    local w,h = surface.GetTextSize(table.concat(buffer, " ").." "..word)
    if w > mWidth then
      table.insert(nLines, table.concat(buffer, " "))
      buffer = { }
    end
    table.insert(buffer, word)
  end
    
  if #buffer > 0 then -- If still words to add.
    table.insert(nLines, table.concat(buffer, " "))
  end
  
  return nLines
end

function drawMultiLine(text, font, mWidth, spacing, x, y, color, alignX, alignY, oWidth, oColor)
  local mLines = toLines(text, font, mWidth)

  for i,line in pairs(mLines) do
    if oWidth and oColor then
      draw.SimpleTextOutlined(line, font, x, y + (i - 1) * spacing, color, alignX, alignY, oWidth, oColor)
    else
      draw.SimpleText(line, font, x, y + (i - 1) * spacing, color, alignX, alignY)
    end
  end
    
  return (#mLines - 1) * spacing
  -- return #mLines * spacing
end

local blur = Material("pp/blurscreen")

function DrawBlurPanel( panel, amount, heavyness )

  local x, y = panel:LocalToScreen( 0, 0 )
  local scrW, scrH = ScrW(), ScrH()
  surface.SetDrawColor( 255, 255, 255 )
  surface.SetMaterial(blur)

  for i = 1, ( heavyness || 3 ) do

    blur:SetFloat( "$blur", ( i / 3 ) * ( amount || 6 ) )
    blur:Recompute()
    render.UpdateScreenEffectTexture()
    surface.DrawTexturedRect( x * -1, y * -1, scrW, scrH )

  end

end

function SWEP:Initialize()

  self:SetHoldType( self.HoldType )
  self.Owner.EquipTime = RealTime()

  for i = 1, #self.AbilityIcons do

    if ( self.AbilityIcons[ i ].KEY != "Nonekey" ) then

      self.HotKeyTable[ #self.HotKeyTable + 1 ] = self.AbilityIcons[ i ].KEY

    end

  end


  if ( self.NotDrawVW ) then

    self:DrawViewModel( false )

  end

  if ( self.NotDrawWM ) then

    self.Owner:DrawWorldModel( false )

  end

end

function SWEP:ForbidAbility( id, b_forbid )

  if ( !self.AbilityIcons || !self.AbilityIcons[ id ] ) then return end

  self.AbilityIcons[ id ].Forbidden = b_forbid

  if ( SERVER ) then

    if ( id > 15 ) then return end -- Only 4 byte

    net.Start( "ForbidTalant" )

      net.WriteBool( b_forbid )
      net.WriteUInt( id, 4 )

    net.Send( self.Owner )

  end

end

BREACH.Abilities = BREACH.Abilities || {}

local clrgray = Color( 198, 198, 198 )
local clrgray2 = Color( 180, 180, 180 )
local clrred = Color( 255, 0, 0 )
local clrred2 = Color( 198, 0, 0 )
local blackalpha = Color( 0, 0, 0, 180 )

local function ForbidTalant()

  local is_forbidden = net.ReadBool()
  local talant_id = net.ReadUInt( 4 )

  if ( !IsValid( BREACH.Abilities ) || #BREACH.Abilities.Buttons == 0 ) then return end

  LocalPlayer():GetActiveWeapon().AbilityIcons[ talant_id ].Forbidden = is_forbidden


end
net.Receive( "ForbidTalant", ForbidTalant )

local function ShowAbilityDesc( name, text, cooldown, x, y )

  if ( IsValid( BREACH.Abilities.TipWindow ) ) then

    BREACH.Abilities.TipWindow:Remove()

  end

  surface.SetFont( "ChatFont_new" )
  local stringwidth, stringheight = surface.GetTextSize( text )
  BREACH.Abilities.TipWindow = vgui.Create( "DPanel" )
  BREACH.Abilities.TipWindow:SetAlpha( 0 )
  BREACH.Abilities.TipWindow:SetPos( x + 10, ScrH() - 80  )
  BREACH.Abilities.TipWindow:SetSize( 180, stringheight + 76 )
  BREACH.Abilities.TipWindow:SetText( "" )
  BREACH.Abilities.TipWindow:MakePopup()
  BREACH.Abilities.TipWindow.Paint = function( self, w, h )

    if ( !vgui.CursorVisible() ) then

      self:Remove()

    end

    self:SetPos( gui.MouseX() + 15, gui.MouseY() )
    if ( self && self:IsValid() && self:GetAlpha() <= 0 ) then

      self:SetAlpha( 255 )

    end
    DrawBlurPanel( self )
    draw.OutlinedBox( 0, 0, w, h, 2, clrgray2 )
    drawMultiLine( name, "ChatFont_new", w, 16, 5, 0, clrred, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

    local namewidth, nameheight = surface.GetTextSize( name )
    drawMultiLine( text, "ChatFont_new", w + 32, 16, 5, nameheight * 1.4, clrgray, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

    local line_height = nameheight * 1.15

    surface.DrawLine( 0, line_height, w, line_height )
    surface.DrawLine( 0, line_height + 1, w, line_height + 1 )

    draw.SimpleTextOutlined( cooldown, "ChatFont_new", w - 8, 3, clrred2, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, 1, blackalpha )

  end

end

local scp_team_index = TEAM_SCP
local darkgray = Color( 105, 105, 105 )

function SWEP:ChooseAbility( table )

  if ( IsValid( BREACH.Abilities ) ) then

    BREACH.Abilities:Remove()

  end

  BREACH.Abilities = vgui.Create( "DPanel" )
  BREACH.Abilities.AbilityIcons = table
  BREACH.Abilities:SetPos( ScrW() / 2 - ( 32 * #BREACH.Abilities.AbilityIcons ), ScrH() / 1.2 )
  BREACH.Abilities:SetSize( 64 * #BREACH.Abilities.AbilityIcons, 64 )
  BREACH.Abilities:SetText( "" )
  BREACH.Abilities.SCP_Name = LocalPlayer():GetNClass()
  BREACH.Abilities.Alpha = 1
  BREACH.Abilities.Paint = function( self, w, h )

    local client = LocalPlayer()

    if ( client:Health() <= 0 || client:GetNClass() != self.SCP_Name ) then

      self:Remove()

    end

    if ( self.Alpha != 255 ) then

      self.Alpha = math.Approach( self.Alpha, 255, RealFrameTime() * 512 )
      self:SetAlpha( self.Alpha )

    end

    surface.SetDrawColor( color_white )
    draw.OutlinedBox( 0, 0, w, h, 4, color_black )

  end

  BREACH.Abilities.OnRemove = function()

    gui.EnableScreenClicker( false )

    if ( IsValid( BREACH.Abilities ) && IsValid( BREACH.Abilities.TipWindow ) ) then

      BREACH.Abilities.TipWindow:Remove()

    end

  end

  for i = 1, #BREACH.Abilities.AbilityIcons do

    BREACH.Abilities.Buttons = BREACH.Abilities.Buttons || {}
    BREACH.Abilities.Buttons[ i ] = vgui.Create( "DButton", BREACH.Abilities )
    BREACH.Abilities.Buttons[ i ]:SetPos( 64 * ( i - 1 ), 0 )
    BREACH.Abilities.Buttons[ i ]:SetSize( 64, 64 )
    BREACH.Abilities.Buttons[ i ]:SetText( "" )
    BREACH.Abilities.Buttons[ i ].ID = iForbidTalant
    BREACH.Abilities.Buttons[ i ].OnCursorEntered = function( self )

      ShowAbilityDesc( BREACH.Abilities.AbilityIcons[ i ].Name, BREACH.Abilities.AbilityIcons[ i ].Description, BREACH.Abilities.AbilityIcons[ i ].Cooldown, gui.MouseX(), ( gui.MouseY() || 5 ) )

    end
    BREACH.Abilities.Buttons[ i ].OnCursorExited = function()

      if ( BREACH.Abilities.TipWindow && BREACH.Abilities.TipWindow:Remove() ) then

        BREACH.Abilities.TipWindow:Remove()

      end

    end

    BREACH.Abilities.Buttons[ i ].DoClick = function()  end

    local iconmaterial = Material( BREACH.Abilities.AbilityIcons[ i ].Icon )
    local key = BREACH.Abilities.AbilityIcons[ i ].KEY
    local c_key

    if ( isnumber( key ) ) then

      c_key = key
      key = string.upper( input.GetKeyName( key ) )

    end

    surface.SetFont( "ChatFont_new" )
    local text_sizew = surface.GetTextSize( key ) + 16

    BREACH.Abilities.Buttons[ i ].Paint = function( self, w, h )

      local client = LocalPlayer()

      if ( !BREACH.Abilities || !BREACH.Abilities.AbilityIcons[ i ] ) then

        self:Remove()

        return
      end

      surface.SetDrawColor( color_white )
      surface.SetMaterial( iconmaterial )
      surface.DrawTexturedRect( 0, 0, 64, 64 )

      if ( c_key && input.IsKeyDown( c_key ) && !client:IsTyping() ) then

        draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( clrgray, 70 ) )

      end

      if ( BREACH.Abilities && !BREACH.Abilities.AbilityIcons[ i ].Using || BREACH.Abilities && BREACH.Abilities.AbilityIcons[ i ].Forbidden ) then

        draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( darkgray, 190 ) )

      end

      draw.SimpleTextOutlined( key, "ChatFont_new", w - ( text_sizew / 4 ), 4, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_RIGHT, 1.5, color_black )

      if ( self.PaintOverride && isfunction( self.PaintOverride ) ) then

        self:PaintOverride( w, h )

        return
      end

      if ( ( ( BREACH.Abilities.AbilityIcons[ i ].CooldownTime || 0 ) - CurTime() ) > 0 ) then

        if ( BREACH.Abilities.AbilityIcons[ i ].Using ) then

          BREACH.Abilities.AbilityIcons[ i ].Using = false

        end

        draw.SimpleTextOutlined( math.Round( BREACH.Abilities.AbilityIcons[ i ].CooldownTime - CurTime() ), "ChatFont_new", 32, 32, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1.5, color_black )

      elseif ( BREACH.Abilities.AbilityIcons[ i ].Forbidden ) then

        if ( !( primary_wep && primary_wep:IsValid() ) ) then return end

        local number_cooldown = tonumber( BREACH.Abilities.AbilityIcons[ i ].Cooldown )
        if ( ( primary_wep:GetRage() || 0 ) < number_cooldown ) then

          local value = math.Round( number_cooldown - primary_wep:GetRage() )
          draw.SimpleText( value, "ChatFont_new", 32, 32, ColorAlpha( color_white, 210 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        end

      else

        if ( !BREACH.Abilities.AbilityIcons[ i ].Using ) then

          BREACH.Abilities.AbilityIcons[ i ].Using = true

        end

      end

    end

  end

end

function SWEP:OnRemove()

  if ( self.RemoveCustomFunc && isfunction( self.RemoveCustomFunc ) ) then

    self.RemoveCustomFunc()

  end

end

function SWEP:Holster()

  if ( self.RemoveCustomFunc && isfunction( self.RemoveCustomFunc ) ) then

    self.RemoveCustomFunc()

  end

end

function SWEP:DrawHUD()

  if ( !IsValid( BREACH.Abilities ) ) then

    self:ChooseAbility( self.AbilityIcons )

  end

  if ( input.IsKeyDown( KEY_F3 ) && ( self.NextPush || 0 ) <= CurTime() ) then

    self.NextPush = CurTime() + .5
    gui.EnableScreenClicker( !vgui.CursorVisible() )

  end

end

if CLIENT then
	SWEP.WepSelectIcon 	= surface.GetTextureID("breach/wep_zombie")
	SWEP.BounceWeaponIcon = false
end

SWEP.Base			= "weapon_breach_basemelee"

SWEP.ViewModelFOV	= 75
SWEP.ViewModelFlip	= false
SWEP.HoldType		= "zombie"
SWEP.ViewModel		= "models/cultist/scp/scp_049_2_hands.mdl"
SWEP.WorldModel		= ""
SWEP.PrintName		= "Zombie"
SWEP.DrawCrosshair	= false
SWEP.Slot			= 0

SWEP.Spawnable			= false
SWEP.AdminOnly			= false
SWEP.ISSCP 				= true

SWEP.droppable				= false
SWEP.Primary.Automatic		= false
SWEP.Primary.NextAttack		= 0.25
SWEP.Primary.AttackDelay	= 0.4
SWEP.Primary.Damage			= 15
SWEP.Primary.Force			= 3250
SWEP.Primary.AnimSpeed		= 2.8

SWEP.Secondary.Automatic	= true
SWEP.Secondary.NextAttack	= 0.7
SWEP.Secondary.AttackDelay	= 1.6
SWEP.Secondary.Damage		= 15
SWEP.Secondary.Force		= 6000
SWEP.Secondary.AnimSpeed	= 2.4

SWEP.Range					= 100

SWEP.UseHands				= false
SWEP.DrawCustomCrosshair	= true
SWEP.DeploySpeed			= 1
SWEP.AttackTeams			= {2,3,5,6} // Attack only humans
SWEP.AttackNPCs				= false
SWEP.maxs = Vector( 8, 10, 5 )

SWEP.ZombieWeapon			= true

SWEP.SoundMiss 			= "npc/zombie/claw_miss1.wav"
SWEP.SoundWallHit		= "npc/zombie/claw_strike1.wav"
SWEP.SoundFleshSmall	= "npc/zombie/claw_strike2.wav"
SWEP.SoundFleshLarge	= "npc/zombie/claw_strike3.wav"

SWEP.Lang = nil

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
  local trace = {}
	trace.start = self.Owner:GetShootPos()
	trace.endpos = trace.start + self.Owner:GetAimVector() * 165
	trace.filter = self.Owner
	trace.mins = -self.maxs
	trace.maxs = self.maxs

	trace = util.TraceHull( trace )

  local target = trace.Entity

  if ( target && target:IsValid() && target:IsPlayer() && target:Health() > 0 && target:GTeam() != TEAM_SCP && target:GTeam() != TEAM_SPEC ) then

    self.dmginfo = DamageInfo()
    self.dmginfo:SetDamageType( DMG_SLASH )
    self.dmginfo:SetDamage( math.random( 20, 30 ) )
    self.dmginfo:SetDamageForce( target:GetAimVector() * 120 )
    self.dmginfo:SetInflictor( self )
    self.dmginfo:SetAttacker( self.Owner )

    self.Owner:DoAnimationEvent( ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE )

    target:TakeDamageInfo( self.dmginfo )
  else
    self.Owner:ViewPunch( AngleRand( 10, 2, 10 ) )
    self.Owner:DoAnimationEvent( ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE )
  end
end
