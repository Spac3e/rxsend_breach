include( "shared.lua" )

surface.CreateFont( "SelectionFontBig", {

  font = "Conduit ITC",
  size = 24,
  weight = 800,
  blursize = 0,
  scanlines = 0,
  antialias = true,
  underline = false,
  italic = false,
  strikeout = false,
  symbol = false,
  rotary = false,
  shadow = true,
  additive = false,
  outline = false

} )

surface.CreateFont( "SelectionFont", {

  font = "Conduit ITC",
  size = 22,
  weight = 800,
  blursize = 0,
  scanlines = 0,
  antialias = true,
  underline = false,
  italic = false,
  strikeout = false,
  symbol = false,
  rotary = false,
  shadow = true,
  additive = false,
  outline = false

} )

local status_text = {

  "粗",
  "超粗",
  "1:1",
  "精",
  "超精"

}

local vector_offset = Vector( 5, 3.2, 12 )
local angle_offset = Angle( 0, 180, 90 )

function ENT:Draw()

  self:DrawModel()

  local client = LocalPlayer()

  if ( client:GetPos():DistToSqr( self:GetPos() ) > 62500 ) then return end

  local campos = self:LocalToWorld( vector_offset )
  cam.Start3D2D( campos, self:LocalToWorldAngles( angle_offset, .1 ), .1 )

    draw.DrawText( "加工模式: " .. status_text[ self:GetStatus() ], "SelectionFont", 60, 35, color_white, 1 )

  cam.End3D2D()

end

function Open914Menu()
    local scp914 = LocalPlayer():GetEyeTrace().Entity
    local client = LocalPlayer()
    if client:GTeam() == TEAM_SCP or client:GTeam() == TEAM_SPEC then return end
    if !IsValid(scp914) or scp914:GetClass() != "entity_scp_914" then return end
        if istable(BREACH.Menu914Options) then
          for i, v in pairs(BREACH.Menu914Options) do
            if IsValid(v) then v:Remove() end
          end
        end
        BREACH.Menu914Options = BREACH.Menu914Options || {}
                local clrgray = Color( 198, 198, 198 )
                local clrgray2 = Color( 180, 180, 180 )
                local clrred = Color( 255, 0, 0 )
                local clrred2 = Color( 50,205,50 )
                local gradienttt = Material( "vgui/gradient-r" )

        local teams_table = {

          { name = "更改状态", func = function() net.Start("Changestatus_SCP914") net.WriteEntity(scp914) net.SendToServer() end },
          { name = "开启", func = function() net.Start("Activate_SCP914") net.WriteEntity(scp914) net.SendToServer() end },

        }
      
      
      
        BREACH.Menu914Options.MainPanel = vgui.Create( "DPanel" )
        BREACH.Menu914Options.MainPanel:SetSize( 256, 256 )
        BREACH.Menu914Options.MainPanel:SetPos( ScrW() / 2 - 128, ScrH() / 2 - 128 )
        BREACH.Menu914Options.MainPanel:SetText( "" )
        BREACH.Menu914Options.MainPanel.Paint = function( self, w, h )
      
          if ( !vgui.CursorVisible() ) then
      
            gui.EnableScreenClicker( true )
      
          end
      
          draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
          draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )
      
          if ( input.IsKeyDown( KEY_BACKSPACE ) ) then
      
            self:Remove()
            BREACH.Menu914Options.MainPanel.Disclaimer:Remove()
            gui.EnableScreenClicker( false )
      
          end
      
        end
      
        BREACH.Menu914Options.MainPanel.Disclaimer = vgui.Create( "DPanel" )
        BREACH.Menu914Options.MainPanel.Disclaimer:SetSize( 256, 64 )
        BREACH.Menu914Options.MainPanel.Disclaimer:SetPos( ScrW() / 2 - 128, ScrH() / 2 - 192 )
        BREACH.Menu914Options.MainPanel.Disclaimer:SetText( "" )
      
        local client = LocalPlayer()
      
        BREACH.Menu914Options.MainPanel.Disclaimer.Paint = function( self, w, h )
      
          draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_white, 120 ) )
          draw.OutlinedBox( 0, 0, w, h, 1.5, color_black )
      
          draw.DrawText( "SCP-914", "ChatFont_new", w / 2, h / 2 - 16, color_black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      
          if ( client:GTeam() == TEAM_SPEC || client:GTeam() == TEAM_SCP || client:Health() <= 0 || !IsValid(scp914) || scp914:GetPos():DistToSqr(client:GetPos()) > 7000 || client:GetEyeTrace().Entity != scp914 ) then
      
            if ( IsValid( BREACH.Menu914Options.MainPanel ) ) then
      
              BREACH.Menu914Options.MainPanel:Remove()
      
            end
      
            self:Remove()
      
            gui.EnableScreenClicker( false )
      
          end
      
        end
      
        BREACH.Menu914Options.ScrollPanel = vgui.Create( "DScrollPanel", BREACH.Menu914Options.MainPanel )
        BREACH.Menu914Options.ScrollPanel:Dock( FILL )
      
        for i = 1, #teams_table do
      
          BREACH.Menu914Options.Users = BREACH.Menu914Options.ScrollPanel:Add( "DButton" )
          BREACH.Menu914Options.Users:SetText( "" )
          BREACH.Menu914Options.Users:Dock( TOP )
          BREACH.Menu914Options.Users:SetSize( 256, 64 )
          BREACH.Menu914Options.Users:DockMargin( 0, 0, 0, 2 )
          BREACH.Menu914Options.Users.CursorOnPanel = false
          BREACH.Menu914Options.Users.gradientalpha = 0
      
          BREACH.Menu914Options.Users.Paint = function( self, w, h )
      
            if ( self.CursorOnPanel ) then
      
              self.gradientalpha = math.Approach( self.gradientalpha, 255, FrameTime() * 128 )
      
            else
      
              self.gradientalpha = math.Approach( self.gradientalpha, 0, FrameTime() * 256 )
      
            end
      
            draw.RoundedBox( 0, 0, 0, w, h, color_black )
            draw.OutlinedBox( 0, 0, w, h, 1.5, clrgray )
      
            surface.SetDrawColor( ColorAlpha( color_white, self.gradientalpha ) )
            surface.SetMaterial( gradienttt )
            surface.DrawTexturedRect( 0, 0, w, h )
      
            draw.SimpleText( teams_table[ i ].name, "ChatFont_new", w / 2, h / 2, clrgray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      
          end
      
          BREACH.Menu914Options.Users.OnCursorEntered = function( self )
      
            self.CursorOnPanel = true
      
          end
      
          BREACH.Menu914Options.Users.OnCursorExited = function( self )
      
            self.CursorOnPanel = false
      
          end
      
          BREACH.Menu914Options.Users.DoClick = function( self )

            teams_table[ i ].func()
      
            BREACH.Menu914Options.MainPanel:Remove()
            BREACH.Menu914Options.MainPanel.Disclaimer:Remove()
            gui.EnableScreenClicker( false )
      
          end
      
        end
end
