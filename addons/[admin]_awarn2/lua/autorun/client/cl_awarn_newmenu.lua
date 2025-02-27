AddCSLuaFile()

AWarn.NewMenu = AWarn.NewMenu or {}
local loc = AWarn.localizations.localLang

surface.CreateFont("AWarn2MenuFont1", {
	font = "Arial", 
	size = 18, 
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
	outline = false, 
})
surface.CreateFont("AWarn2MenuFont2", {
	font = "Arial", 
	size = 16, 
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
	outline = false, 
})
surface.CreateFont("AWarn2MenuFont3", {
	font = "Arial", 
	size = 14, 
	weight = 400, 
	blursize = 0, 
	scanlines = 0, 
	antialias = true, 
	underline = false, 
	italic = false, 
	strikeout = false, 
	symbol = false, 
	rotary = false, 
	shadow = false, 
	additive = false, 
	outline = false, 
})

function AWarn.NewMenu:ShowNewMenu( ply, com, args )
	self.new_menu = vgui.Create( "awarn_new_menu" )
	self.new_menu:MakePopup()
	for k, v in pairs( player.GetAll() ) do
		AWarn2_CreatePlayerButton( v )
	end
end
concommand.Add( "awarn_newmenu", function( ... ) AWarn.NewMenu:ShowNewMenu( ... ) end )

function AWarn.NewMenu:ShowOfflineMenu()

	if ValidPanel( self.offline_menu ) then return end

	self.offline_menu = vgui.Create( "awarn_offline_menu" )
	self.offline_menu:MakePopup()
	self.offline_menu:SetParent( self.new_menu )
end

function AWarn.NewMenu:ShowWarnPlayerMenu()

	if ValidPanel( self.warnplayer_menu ) then return end

	self.warnplayer_menu = vgui.Create( "awarn_warnplayer_menu" )
	self.warnplayer_menu:MakePopup()
	self.warnplayer_menu:SetParent( self.new_menu )
end

function AWarn.NewMenu:ShowWarnIDMenu()

	if ValidPanel( self.warnid_menu ) then return end

	self.warnid_menu = vgui.Create( "awarn_warnid_menu" )
	self.warnid_menu:MakePopup()
	self.warnid_menu:SetParent( self.new_menu )
end

function AWarn.NewMenu:ShowClientMenu()

	if ValidPanel( self.client_menu ) then return end

	self.client_menu = vgui.Create( "awarn_client_menu" )
	self.client_menu:MakePopup()
	self.client_menu:SetParent( self.new_menu )
end

function AWarn.NewMenu:ShowOptionsMenu()

	if ValidPanel( self.options_menu ) then return end

	self.options_menu = vgui.Create( "awarn_options_menu" )
	self.options_menu:MakePopup()
	self.options_menu:SetParent( self.new_menu )
end

local PANEL = {}

function PANEL:Init()

	self:SetSize( ScrW() * 0.8, ScrH() * 0.8 )
    self:Center()
	self:DrawFrame()
	self:SetTitle("")
	self:SetDraggable( true )
	self.selectedpanel = nil
	self:SetSkin("AWarn")
	AWarn.lastselected = nil
	AWarn.selectedActive = 0
	AWarn.selectedTotal = 0
end

function PANEL:Paint()
	local plist_x = self:GetWide() - 192 + 8

	--Main Window--	
	surface.SetDrawColor( 90, 90, 90, 230 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	surface.SetDrawColor( 10, 10, 10, 220 )	
	surface.DrawRect( plist_x, 29, 180, self:GetTall() - 33 ) --PlayerListPanel
	surface.DrawRect( 4, 4, self:GetWide() - 8, 22 ) --TopPanel
	surface.DrawRect( 4, 29, self:GetWide() - 192, self:GetTall() - 93 ) --WarningsBodyPanel
	surface.DrawRect( 4, self:GetTall() - 60, self:GetWide() - 192, 56 ) --PlayerInfoPanel
	
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.DrawRect( plist_x + 2, 31, 176, 20 ) --PlayerListPanelInner
	
	--Player Name Text--
	surface.SetFont( "AWarn2MenuFont1" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( plist_x + 20 , 32 )
	surface.DrawText( "Connected Players" )

	surface.SetFont( "AWarn2MenuFont1" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( 8 , self:GetTall() - 52 )
	surface.DrawText( AWarn.localizations[loc].cl4 .. ":" )
	surface.SetTextPos( 8 , self:GetTall() - 32 )
	surface.DrawText( AWarn.localizations[loc].cl5 .. ":" )
	surface.SetTextPos( 320 , self:GetTall() - 32 )
	surface.DrawText( "Viewing Warnings For: " )
	
	surface.SetTextColor( 255, 100, 100, 255 )
	local w, h = surface.GetTextSize(AWarn.localizations[loc].cl4 .. ":")
	surface.SetTextPos( w + 15 , self:GetTall() - 52 )
	surface.DrawText( AWarn.selectedActive )
	local w, h = surface.GetTextSize(AWarn.localizations[loc].cl5 .. ":")
	surface.SetTextPos( w + 15 , self:GetTall() - 32 )
	surface.DrawText( AWarn.selectedTotal )
	surface.SetTextColor( 100, 200, 200, 255 )
	surface.SetTextPos( 485 , self:GetTall() - 32 )
	surface.DrawText( AWarn.lastselected or "None Selected" )
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( 10 , 6 )
	surface.DrawText( AWarn.localizations[loc].cl1 .. " (" .. AWarn.localizations[loc].cl2 .. ": " .. AWarn.Version .. ") ::: " .. AWarn.localizations[loc].cl3 .. "" )
end



function PANEL:DrawFrame()

	

	local plist_x = self:GetWide() - 192 + 8
	
	local WarningsWindow = vgui.Create( "DPanel", self )
	WarningsWindow:SetSize( self:GetWide() - 192, self:GetTall() - 93 )
	WarningsWindow:SetPos( 4, 29 )
	WarningsWindow.Paint = function()
	
	end
	
	self.WarningsList = vgui.Create( "DListView", WarningsWindow )
	self.WarningsList:SetWidth( self:GetWide() - 192 )
	self.WarningsList:SetHeight( self:GetTall() - 93 )
	self.WarningsList:SetMultiSelect(false)
	self.WarningsList:AddColumn("ID"):SetFixedWidth( 40 )
	self.WarningsList:AddColumn(AWarn.localizations[loc].cl7):SetFixedWidth( 200 )
	self.WarningsList:AddColumn(AWarn.localizations[loc].cl8):SetFixedWidth( self.WarningsList:GetWide() - 460 )
	self.WarningsList:AddColumn(AWarn.localizations[loc].cl9):SetFixedWidth( 100 )
	self.WarningsList:AddColumn(AWarn.localizations[loc].cl10):SetFixedWidth( 120 )
	self.WarningsList.OnRowRightClick = function( PlayerList, line )
		if ( self.WarningsList:GetLine( line ):GetValue( 1 ) == "*" ) then return end
		local DropDown = DermaMenu()
		DropDown:AddOption(AWarn.localizations[loc].cl11, function()
			warning = self.WarningsList:GetLine( line ):GetValue( 1 )
			net.Start("awarn_deletesinglewarn")
				net.WriteInt( warning, 32 )
			net.SendToServer()
			
			self.WarningsList:Clear()
			net.Start("awarn_fetchwarnings")
				net.WriteString( AWarn.lastselectedtype )
				net.WriteString( AWarn.lastselected )
			net.SendToServer()
		end )
		DropDown:AddOption(AWarn.localizations[loc].cl12, function()
			SetClipboardText( self.WarningsList:GetLine( line ):GetValue( 3 ) )
			MsgC( Color(255,0,0), "AWarn2: ", Color(255,255,255), AWarn.localizations[loc].cl13)
		end )
		DropDown:AddOption(AWarn.localizations[loc].cl15, function()
			AWarn.NewMenu:ShowWarnIDMenu()
		end )
		DropDown:Open()
	end
	self.WarningsList.OnRowSelected = function( PlayerList, line )
		local newText, num = string.gsub(self.WarningsList:GetLine( line ):GetValue( 3 ), "\n", " `")
	end
	
	
	
	self.Scroll = vgui.Create( "DScrollPanel", self )
	self.Scroll:SetSize( 176, self:GetTall() - 57 )
	self.Scroll:SetPos( plist_x + 2, 54 )
	
	self.WarningsList:AddLine("*","","SELECT A PLAYER ON THE RIGHT TO VIEW THEIR WARNINGS","","")
	ModifyFontInListView( self.WarningsList )
	
	
	local ButtonBar = vgui.Create( "DPanel", self )
	ButtonBar:SetSize( 170, 22 )
	ButtonBar:SetPos( self:GetWide() - 200, 4 )
	ButtonBar:DockPadding( 0, 2, 0, 2 )
	ButtonBar.Paint = function() end
	
	local DermaButton = vgui.Create( "DButton", ButtonBar )
	DermaButton:SetText( AWarn.localizations[loc].cl6 )
	DermaButton:SizeToContents()
	DermaButton:Dock( RIGHT )
	DermaButton:DockMargin( 0, 0, 4, 0)
	DermaButton:SetTextColor(Color(255,255,255,255))
	DermaButton.Paint = function()
		surface.SetDrawColor( 120, 120, 120, 210 )
		surface.DrawRect( 0, 0, DermaButton:GetWide(), DermaButton:GetTall() )
		if DermaButton:IsHovered() then
			surface.SetDrawColor( 160, 160, 160, 210 )
			surface.DrawRect( 0, 0, DermaButton:GetWide(), DermaButton:GetTall() )
		end
	end
	DermaButton.DoClick = function()
		AWarn.NewMenu:ShowOptionsMenu()
	end
	
	local DermaButton = vgui.Create( "DButton", ButtonBar )
	DermaButton:SetText( "Offline Players" )
	DermaButton:SizeToContents()
	DermaButton:Dock( RIGHT )
	DermaButton:DockMargin( 0, 0, 4, 0)
	DermaButton:SetTextColor(Color(255,255,255,255))
	DermaButton.Paint = function()
		surface.SetDrawColor( 120, 120, 120, 210 )
		surface.DrawRect( 0, 0, DermaButton:GetWide(), DermaButton:GetTall() )
		if DermaButton:IsHovered() then
			surface.SetDrawColor( 160, 160, 160, 210 )
			surface.DrawRect( 0, 0, DermaButton:GetWide(), DermaButton:GetTall() )
		end
	end
	DermaButton.DoClick = function()
		--awarn_offlineplayerprompt_new()
		AWarn.NewMenu:ShowOfflineMenu()
	end
	
	local DermaButton = vgui.Create( "DButton", ButtonBar )
	DermaButton:SetText(  AWarn.localizations[loc].cl15 )
	DermaButton:SizeToContents()
	DermaButton:Dock( RIGHT )
	DermaButton:DockMargin( 0, 0, 4, 0)
	DermaButton:SetTextColor(Color(255,255,255,255))
	DermaButton.Paint = function()
		if not self.selectedpanel then
			surface.SetDrawColor( 150, 150, 150, 40 )
			surface.DrawRect( 0, 0, DermaButton:GetWide(), DermaButton:GetTall() )
		else
			surface.SetDrawColor( 150, 20, 20, 180 )
			surface.DrawRect( 0, 0, DermaButton:GetWide(), DermaButton:GetTall() )
			if DermaButton:IsHovered() then
				surface.SetDrawColor( 100, 100, 100, 80 )
				surface.DrawRect( 0, 0, DermaButton:GetWide(), DermaButton:GetTall() )
			end
		end
	end
	DermaButton.DoClick = function()
		if not self.selectedpanel then return end
		AWarn.activeplayer = self.selectedpanel.ply:GetName()
		AWarn.NewMenu:ShowWarnPlayerMenu()
	end
end

net.Receive( "awarn_playerjoin", function( len )
	local ply = net.ReadEntity()
	AWarn2_CreatePlayerButton( ply )
end )



function AWarn2_CreatePlayerButton( ply )
	if not IsValid( ply ) then return end
	if not ValidPanel(AWarn.NewMenu.new_menu) then return end	
	local DermaButton = vgui.Create( "DButton", AWarn.NewMenu.new_menu.Scroll )
	DermaButton.ply = ply
	DermaButton:SetText( AWarn.localizations[loc].cl6 )
	DermaButton:SetHeight( 20 )
	DermaButton:Dock( TOP )
	DermaButton:DockMargin( 2, 0, 2, 0 )
	DermaButton:SetTextColor(Color(255,255,255,255))
	DermaButton:SetText("")
	DermaButton.Paint = function()
		if not IsValid( ply ) then
			DermaButton:Remove()
			return
		end
	
		if DermaButton.hovered then
			surface.SetDrawColor( 120, 120, 120, 210 )
			surface.DrawRect( 0, 0, AWarn.NewMenu.new_menu:GetWide(), AWarn.NewMenu.new_menu:GetTall() )
		end
		if AWarn.NewMenu.new_menu.selectedpanel == DermaButton then
			surface.SetDrawColor( 140, 140, 180, 210 )
			surface.DrawRect( 0, 0, AWarn.NewMenu.new_menu:GetWide(), AWarn.NewMenu.new_menu:GetTall() )
		end
		surface.SetFont( "AWarn2MenuFont2" )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( 5 , 2 )
		surface.DrawText( ply:GetName() )
	end
	DermaButton.DoClick = function()
		AWarn.NewMenu.new_menu.selectedpanel = DermaButton
		AWarn.NewMenu.new_menu.WarningsList:Clear()
		net.Start("awarn_fetchwarnings")
			net.WriteString( "playername" )
			net.WriteString( DermaButton.ply:GetName() )
		net.SendToServer()
		AWarn.lastselected = DermaButton.ply:GetName()
		AWarn.lastselectedtype = "playername"
	end
	DermaButton.DoRightClick = function()
		local DropDown = DermaMenu()
		DropDown:AddOption(AWarn.localizations[loc].cl15, function() 
			AWarn.activeplayer = DermaButton.ply:GetName()
			AWarn.NewMenu:ShowWarnPlayerMenu()		
		end )
		DropDown:AddOption(AWarn.localizations[loc].cl16, function()
			AWarn.NewMenu.new_menu.WarningsList:Clear() 
			AWarn.playerinfo = {} 
			awarn_deletewarnings( DermaButton.ply:GetName() )
			AWarn.selectedActive = 0
			AWarn.selectedTotal = 0
			AWarn.NewMenu.new_menu.WarningsList:AddLine("","","This player has no warnings!","","")
			ModifyFontInListView( AWarn.NewMenu.new_menu.WarningsList )
		end )
		DropDown:AddOption(AWarn.localizations[loc].cl17, function() 
		awarn_removewarn( DermaButton.ply:GetName() )
		end )			
		DropDown:Open()
	end
	DermaButton.Think = function()
		if DermaButton:IsHovered() then
			DermaButton.hovered = true
		else
			DermaButton.hovered = nil
		end
	end
end

function PANEL:PerformLayout()
	local titlePush = 0
	self.btnClose:SetPos( self:GetWide() - 24, 6 )
	self.btnClose:SetSize( 18, 18 )
	self.lblTitle:Remove()
	self.btnMaxim:Remove()
	self.btnMinim:Remove()

end
function PANEL:Think()
	local mousex = math.Clamp( gui.MouseX(), 1, ScrW() - 1 )
	local mousey = math.Clamp( gui.MouseY(), 1, ScrH() - 1 )

	if ( self.Dragging ) then

		local x = mousex - self.Dragging[1]
		local y = mousey - self.Dragging[2]

		-- Lock to screen bounds if screenlock is enabled
		if ( self:GetScreenLock() ) then

			x = math.Clamp( x, 0, ScrW() - self:GetWide() )
			y = math.Clamp( y, 0, ScrH() - self:GetTall() )

		end

		self:SetPos( x, y )

	end

	if ( self.Hovered && self:GetDraggable() && mousey < ( self.y + 24 ) ) then
		self:SetCursor( "sizeall" )
		return
	end

	self:SetCursor( "arrow" )

	-- Don't allow the frame to go higher than 0
	if ( self.y < 0 ) then
		self:SetPos( self.x, 0 )
	end

	if ValidPanel(AWarn.NewMenu.offline_menu) then
		AWarn.NewMenu.offline_menu:MoveToFront()
	end
	if ValidPanel(AWarn.NewMenu.warnplayer_menu) then
		AWarn.NewMenu.warnplayer_menu:MoveToFront()
	end
	if ValidPanel(AWarn.NewMenu.warnid_menu) then
		AWarn.NewMenu.warnid_menu:MoveToFront()
	end
	if ValidPanel(AWarn.NewMenu.options_menu) then
		AWarn.NewMenu.options_menu:MoveToFront()
	end
end
vgui.Register("awarn_new_menu", PANEL, "DFrame")



/* - Offline Players Panel - */
local PANEL = {}
function PANEL:Init()
	self:SetSize( 450, 500 )
    self:Center()
	self:DrawFrame()
	self:SetTitle("")
	self:SetDraggable( true )
	self:SetSkin("AWarn")
end

function PANEL:Paint()

	--Main Window--	
	surface.SetDrawColor( 60, 60, 60, 200 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	surface.SetDrawColor( 80, 80, 80, 200 )
	surface.DrawRect( 4, 4, self:GetWide() - 8, 22 )
	surface.DrawRect( 4, 30, self:GetWide() - 8, self:GetTall() - 90 )
	surface.DrawRect( 4, self:GetTall() - 56, self:GetWide() - 8, 52 )
	
	surface.SetFont( "AWarn2MenuFont1" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( 8 , 6 )
	surface.DrawText( "Offline Players" )
	surface.SetTextPos( 8 , self:GetTall() - 52 )
	surface.DrawText( "Manual Lookup - Enter SteamID:" )



end

function PANEL:DrawFrame()

	net.Start("awarn_fetchofflineplayers")
	net.SendToServer()

	self.OfflinePlayerList = vgui.Create( "DListView", self )
	self.OfflinePlayerList:SetWidth( self:GetWide() - 8 )
	self.OfflinePlayerList:SetHeight( self:GetTall() - 90 )
	self.OfflinePlayerList:SetPos( 4, 30 )
	self.OfflinePlayerList:SetMultiSelect(false)
	self.OfflinePlayerList:AddColumn("SteamID"):SetFixedWidth( 125 )
	self.OfflinePlayerList:AddColumn(AWarn.localizations[loc].cl14):SetFixedWidth( self.OfflinePlayerList:GetWide() - 220 )
	self.OfflinePlayerList:AddColumn("Last Played"):SetFixedWidth( 95 )
	self.OfflinePlayerList.OnRowSelected = function( PlayerList, line )
		AWarn.NewMenu.new_menu.WarningsList:Clear()
		AWarn.NewMenu.new_menu.selectedpanel = nil
		net.Start("awarn_fetchwarnings")
			net.WriteString( "playerid" )
			net.WriteString( self.OfflinePlayerList:GetLine( line ):GetValue( 1 ) )
		net.SendToServer()
		AWarn.lastselectedtype = "playerid"
		AWarn.lastselected = self.OfflinePlayerList:GetLine( line ):GetValue( 2 ) .. " (OFFLINE) (" .. self.OfflinePlayerList:GetLine( line ):GetValue( 1 ) .. ")"
	end

	ModifyFontInOfflineListView(self.OfflinePlayerList)
	
	local MenuPanelTextEntry1 = vgui.Create( "DTextEntry", self )
	MenuPanelTextEntry1:SetPos( 8,  self:GetTall() - 30 )
	MenuPanelTextEntry1:SetMultiline( false )
	MenuPanelTextEntry1:SetWidth( 200 )
	
	local DermaButton = vgui.Create( "DButton", self )
	DermaButton:SetText(  AWarn.localizations[loc].cl23 )
	DermaButton:SizeToContents()
	DermaButton:SetHeight(18)
	DermaButton:SetWidth(DermaButton:GetWide() + 10)
	DermaButton:SetPos( 215,  self:GetTall() - 29)
	DermaButton:SetTextColor(Color(255,255,255,255))
	
	DermaButton.Paint = function()
		surface.SetDrawColor( 120, 120, 120, 210 )
		surface.DrawRect( 0, 0, DermaButton:GetWide(), DermaButton:GetTall() )
		if DermaButton:IsHovered() then
			surface.SetDrawColor( 160, 160, 160, 210 )
			surface.DrawRect( 0, 0, DermaButton:GetWide(), DermaButton:GetTall() )
		end
	end
	DermaButton.DoClick = function()
		AWarn.NewMenu.new_menu.WarningsList:Clear()
		AWarn.NewMenu.new_menu.selectedpanel = nil
		self.OfflinePlayerList:ClearSelection()
		net.Start("awarn_fetchwarnings")
			net.WriteString( "playerid" )
			net.WriteString( MenuPanelTextEntry1:GetValue() )
		net.SendToServer()
		AWarn.lastselectedtype = "playerid"
		AWarn.lastselected = "(OFFLINE) (" .. MenuPanelTextEntry1:GetValue() .. ")"
	end
end

function PANEL:PerformLayout()

	self.btnClose:SetPos( self:GetWide() - 24, 6 )
	self.btnClose:SetSize( 18, 18 )
	self.lblTitle:Remove()
	self.btnMaxim:Remove()
	self.btnMinim:Remove()

end
vgui.Register("awarn_offline_menu", PANEL, "DFrame")

/* - Warning Panel - */
local PANEL = {}
function PANEL:Init()
	self:SetSize( 370, 174 )
    self:Center()
	self:DrawFrame()
	self:SetTitle("")
	self:SetDraggable( true )
	self:SetSkin("AWarn")
end

function PANEL:Paint()

	--Main Window--	
	surface.SetDrawColor( 60, 60, 60, 200 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	surface.SetDrawColor( 80, 80, 80, 200 )
	surface.DrawRect( 4, 4, self:GetWide() - 8, 22 )
	surface.DrawRect( 4, 30, self:GetWide() - 8, self:GetTall() - 34 )
	
	surface.SetFont( "AWarn2MenuFont1" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( 8 , 6 )
	surface.DrawText( AWarn.localizations[loc].cl21 )
	surface.SetTextPos( 8 , 40 )
	local wptext = AWarn.localizations[loc].cl22
	surface.DrawText( wptext )
	surface.SetTextPos( 8 , 60 )
	surface.DrawText( AWarn.localizations[loc].cl8 .. ":" )
	
	
	surface.SetTextColor( 255, 100, 100, 255 )
	local w, h = surface.GetTextSize( wptext )
	surface.SetTextPos( w + 10 , 40 )
	surface.DrawText( self.HiddenLabel:GetText() )
	
	
	
	

end

function PANEL:DrawFrame()
	self.HiddenLabel = vgui.Create( "DLabel", self )
	self.HiddenLabel:SetPos( 0, 0 )
	self.HiddenLabel:SetColor( Color(255, 255, 255, 0) )
	self.HiddenLabel:SetFont( "AWarnFont1" )
	self.HiddenLabel:SetText( AWarn.activeplayer )
	self.HiddenLabel:SizeToContents()

	local MenuPanelTextEntry1 = vgui.Create( "DTextEntry", self )
	MenuPanelTextEntry1:SetPos( 5, 80 )
	MenuPanelTextEntry1:SetMultiline( true )
	MenuPanelTextEntry1:SetSize( 360, 50 )
	
	local MenuPanelButton1 = vgui.Create( "DButton", self )
	MenuPanelButton1:SetSize( 80, 30 )
	MenuPanelButton1:SetPos( 5, 135 )
	MenuPanelButton1:SetText( AWarn.localizations[loc].cl23 )
	MenuPanelButton1.DoClick = function( MenuPanelButton1 )
		awarn_sendwarning( self.HiddenLabel:GetText(), MenuPanelTextEntry1:GetValue() )
		self:Close()
	end
	
	local MenuPanelButton2 = vgui.Create( "DButton", self )
	MenuPanelButton2:SetSize( 80, 30 )
	MenuPanelButton2:SetPos( 90, 135 )
	MenuPanelButton2:SetText( AWarn.localizations[loc].cl24 )
	MenuPanelButton2.DoClick = function( MenuPanelButton2 )
		self:Close()
	end
end

function PANEL:PerformLayout()

	self.btnClose:SetPos( self:GetWide() - 24, 6 )
	self.btnClose:SetSize( 18, 18 )
	self.lblTitle:Remove()
	self.btnMaxim:Remove()
	self.btnMinim:Remove()

end
vgui.Register("awarn_warnplayer_menu", PANEL, "DFrame")

/* - Options Panel - */
local PANEL = {}
function PANEL:Init()
	self:SetSize( 380, 220 )
    self:Center()
	self:DrawFrame()
	self:SetTitle("")
	self:SetDraggable( true )
	self:SetSkin("AWarn")
end

function PANEL:Paint()

	--Main Window--	
	surface.SetDrawColor( 60, 60, 60, 200 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	surface.SetDrawColor( 80, 80, 80, 200 )
	surface.DrawRect( 4, 4, self:GetWide() - 8, 22 )
	surface.DrawRect( 4, 30, self:GetWide() - 8, self:GetTall() - 34 )
	
	surface.SetFont( "AWarn2MenuFont1" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( 8 , 6 )
	surface.DrawText( AWarn.localizations[loc].cl25 )
	
	surface.SetFont( "AWarn2MenuFont3" )
	surface.SetTextColor( 255, 100, 100, 255 )
	surface.SetTextPos( 8 , self:GetTall() - 35 )
	surface.DrawText( AWarn.localizations[loc].cl33 )
	surface.SetTextPos( 8 , self:GetTall() - 23 )
	surface.DrawText( "addons/awarn2/lua/awarn/modules/awarn_settings.lua" )
	

end

function PANEL:DrawFrame()
	self:DockPadding( 8, 40, 0, 0 )
	
	local MenuPanelCheckBox1 = vgui.Create( "DCheckBoxLabel", self )
	MenuPanelCheckBox1:Dock(TOP)
	MenuPanelCheckBox1:DockMargin( 0, 0, 0, 4 )
	MenuPanelCheckBox1:SetText( AWarn.localizations[loc].cl26 )
	MenuPanelCheckBox1.Button.DoClick = function( MenuPanelCheckBox1 )
		local val = tostring(MenuPanelCheckBox1:GetChecked())
		net.Start("awarn_changeconvarbool")
			net.WriteString("awarn_kick")
			net.WriteString( val )
		net.SendToServer()
	end
	MenuPanelCheckBox1.Think = function( MenuPanelCheckBox1 )
		if GetConVar("awarn_kick"):GetBool() ~= MenuPanelCheckBox1:GetChecked() then
			MenuPanelCheckBox1:SetValue( GetConVar("awarn_kick"):GetBool() )
		end
	end
	
	local MenuPanelCheckBox2 = vgui.Create( "DCheckBoxLabel", self )
	MenuPanelCheckBox2:Dock(TOP)
	MenuPanelCheckBox2:DockMargin( 0, 0, 0, 4 )
	MenuPanelCheckBox2:SetText( AWarn.localizations[loc].cl27 )
	MenuPanelCheckBox2.Button.DoClick = function( MenuPanelCheckBox2 )
		local val = tostring(MenuPanelCheckBox2:GetChecked())
		net.Start("awarn_changeconvarbool")
			net.WriteString("awarn_ban")
			net.WriteString( val )
		net.SendToServer()
	end
	MenuPanelCheckBox2.Think = function( MenuPanelCheckBox2 )
		if GetConVar("awarn_ban"):GetBool() ~= MenuPanelCheckBox2:GetChecked() then
			MenuPanelCheckBox2:SetValue( GetConVar("awarn_ban"):GetBool() )
		end
	end
	
	local MenuPanelCheckBox3 = vgui.Create( "DCheckBoxLabel", self )
	MenuPanelCheckBox3:Dock(TOP)
	MenuPanelCheckBox3:DockMargin( 0, 0, 0, 4 )
	MenuPanelCheckBox3:SetText( AWarn.localizations[loc].cl28 )
	MenuPanelCheckBox3.Button.DoClick = function( MenuPanelCheckBox3 )
		local val = tostring(MenuPanelCheckBox3:GetChecked())
		net.Start("awarn_changeconvarbool")
			net.WriteString("awarn_decay")
			net.WriteString( val )
		net.SendToServer()
	end
	MenuPanelCheckBox3.Think = function( MenuPanelCheckBox3 )
		if GetConVar("awarn_decay"):GetBool() ~= MenuPanelCheckBox3:GetChecked() then
			MenuPanelCheckBox3:SetValue( GetConVar("awarn_decay"):GetBool() )
		end
	end
	
	local MenuPanelCheckBox4 = vgui.Create( "DCheckBoxLabel", self )
	MenuPanelCheckBox4:Dock(TOP)
	MenuPanelCheckBox4:DockMargin( 0, 0, 0, 4 )
	MenuPanelCheckBox4:SetText( AWarn.localizations[loc].cl29 )
	MenuPanelCheckBox4.Button.DoClick = function( MenuPanelCheckBox4 )
		local val = tostring(MenuPanelCheckBox4:GetChecked())
		net.Start("awarn_changeconvarbool")
			net.WriteString("awarn_reasonrequired")
			net.WriteString( val )
		net.SendToServer()
	end
	MenuPanelCheckBox4.Think = function( MenuPanelCheckBox4 )
		if GetConVar("awarn_reasonrequired"):GetBool() ~= MenuPanelCheckBox4:GetChecked() then
			MenuPanelCheckBox4:SetValue( GetConVar("awarn_reasonrequired"):GetBool() )
		end
	end
	
	local MenuPanelCheckBox5 = vgui.Create( "DCheckBoxLabel", self )
	MenuPanelCheckBox5:Dock(TOP)
	MenuPanelCheckBox5:DockMargin( 0, 0, 0, 4 )
	MenuPanelCheckBox5:SetText( AWarn.localizations[loc].cl30 )
	MenuPanelCheckBox5.Button.DoClick = function( MenuPanelCheckBox5 )
		local val = tostring(MenuPanelCheckBox5:GetChecked())
		net.Start("awarn_changeconvarbool")
			net.WriteString("awarn_reset_warnings_after_ban")
			net.WriteString( val )
		net.SendToServer()
	end
	MenuPanelCheckBox5.Think = function( MenuPanelCheckBox5 )
		if GetConVar("awarn_reset_warnings_after_ban"):GetBool() ~= MenuPanelCheckBox5:GetChecked() then
			MenuPanelCheckBox5:SetValue( GetConVar("awarn_reset_warnings_after_ban"):GetBool() )
		end
	end
	
	local MenuPanelCheckBox6 = vgui.Create( "DCheckBoxLabel", self )
	MenuPanelCheckBox6:Dock(TOP)
	MenuPanelCheckBox6:DockMargin( 0, 0, 0, 4 )
	MenuPanelCheckBox6:SetText( AWarn.localizations[loc].cl31 .. " (garrysmod/data/awarn2)" )
	MenuPanelCheckBox6.Button.DoClick = function( MenuPanelCheckBox6 )
		local val = tostring(MenuPanelCheckBox6:GetChecked())
		net.Start("awarn_changeconvarbool")
			net.WriteString("awarn_logging")
			net.WriteString( val )
		net.SendToServer()
	end
	MenuPanelCheckBox6.Think = function( MenuPanelCheckBox6 )
		if GetConVar("awarn_logging"):GetBool() ~= MenuPanelCheckBox6:GetChecked() then
			MenuPanelCheckBox6:SetValue( GetConVar("awarn_logging"):GetBool() )
		end
	end
	
	local MenuPanelSlider = vgui.Create( "DNumSlider", self )
	MenuPanelSlider:Dock(TOP)
	MenuPanelSlider:DockMargin( 0, 0, 8, 4 )
	MenuPanelSlider:SetSize( 390, 30 )
	MenuPanelSlider:SetText( AWarn.localizations[loc].cl32 .. ": " )
	MenuPanelSlider:SetMin( 0 )
	MenuPanelSlider:SetMax( 43200 )
	MenuPanelSlider:SetDark( false )
	MenuPanelSlider:SetDecimals( 0 )
	MenuPanelSlider.TextArea:SetDrawBackground( true )
	MenuPanelSlider.TextArea:SetWide( 30 )
	MenuPanelSlider.Label:SetWide(150)
	MenuPanelSlider:SetValue( GetConVar("awarn_decay_rate"):GetInt() )
	MenuPanelSlider.Think = function( MenuPanelSlider )
		
		if MenuPanelSlider.Slider:GetDragging() then return end
		if ( AWarn.MenuThink or CurTime() ) > CurTime() then return end
		
		if MenuPanelSlider.TextArea:GetValue() == "" then return end
		if tonumber(MenuPanelSlider.TextArea:GetValue()) ~= GetConVar("awarn_decay_rate"):GetInt() then
			net.Start("awarn_changeconvar")
				net.WriteString("awarn_decay_rate")
				net.WriteInt( MenuPanelSlider.TextArea:GetValue(), 32 )
			net.SendToServer()
			AWarn.MenuThink = CurTime() + 1
			return
		end
		if GetConVar("awarn_decay_rate"):GetInt() ~= MenuPanelSlider:GetValue() then
			MenuPanelSlider:SetValue( GetConVar("awarn_decay_rate"):GetInt() )
		end
	end
end

function PANEL:PerformLayout()

	self.btnClose:SetPos( self:GetWide() - 24, 6 )
	self.btnClose:SetSize( 18, 18 )
	self.lblTitle:Remove()
	self.btnMaxim:Remove()
	self.btnMinim:Remove()

end
vgui.Register("awarn_options_menu", PANEL, "DFrame")

/* - ID Warning Panel - */
local PANEL = {}
function PANEL:Init()
	self:SetSize( 370, 174 )
    self:Center()
	self:DrawFrame()
	self:SetTitle("")
	self:SetDraggable( true )
	self:SetSkin("AWarn")
end

function PANEL:Paint()

	--Main Window--	
	surface.SetDrawColor( 60, 60, 60, 200 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	surface.SetDrawColor( 80, 80, 80, 200 )
	surface.DrawRect( 4, 4, self:GetWide() - 8, 22 )
	surface.DrawRect( 4, 30, self:GetWide() - 8, self:GetTall() - 34 )
	
	surface.SetFont( "AWarn2MenuFont1" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( 8 , 6 )
	surface.DrawText( AWarn.localizations[loc].cl21 )
	surface.SetTextPos( 8 , 40 )
	local wptext = AWarn.localizations[loc].cl22
	surface.DrawText( wptext )
	surface.SetTextPos( 8 , 60 )
	surface.DrawText( AWarn.localizations[loc].cl8 .. ":" )
	
	
	surface.SetTextColor( 255, 100, 100, 255 )
	local w, h = surface.GetTextSize( wptext )
	surface.SetTextPos( w + 10 , 40 )
	surface.DrawText( self.HiddenLabel:GetText() )
	
	

end

function PANEL:DrawFrame()
	self.HiddenLabel = vgui.Create( "DLabel", self )
	self.HiddenLabel:SetPos( 0, 0 )
	self.HiddenLabel:SetColor( Color(255, 255, 255, 0) )
	self.HiddenLabel:SetFont( "AWarnFont1" )
	self.HiddenLabel:SetText( util.SteamIDFrom64(AWarn.currentselectedplayer) )
	self.HiddenLabel:SizeToContents()

	local MenuPanelTextEntry1 = vgui.Create( "DTextEntry", self )
	MenuPanelTextEntry1:SetPos( 5, 80 )
	MenuPanelTextEntry1:SetMultiline( true )
	MenuPanelTextEntry1:SetSize( 360, 50 )
	
	local MenuPanelButton1 = vgui.Create( "DButton", self )
	MenuPanelButton1:SetSize( 80, 30 )
	MenuPanelButton1:SetPos( 5, 135 )
	MenuPanelButton1:SetText( AWarn.localizations[loc].cl23 )
	MenuPanelButton1.DoClick = function( MenuPanelButton1 )
		awarn_sendwarning( self.HiddenLabel:GetText(), MenuPanelTextEntry1:GetValue() )
		self:Close()
	end
	
	local MenuPanelButton2 = vgui.Create( "DButton", self )
	MenuPanelButton2:SetSize( 80, 30 )
	MenuPanelButton2:SetPos( 90, 135 )
	MenuPanelButton2:SetText( AWarn.localizations[loc].cl24 )
	MenuPanelButton2.DoClick = function( MenuPanelButton2 )
		self:Close()
	end
end

function PANEL:PerformLayout()

	self.btnClose:SetPos( self:GetWide() - 24, 6 )
	self.btnClose:SetSize( 18, 18 )
	self.lblTitle:Remove()
	self.btnMaxim:Remove()
	self.btnMinim:Remove()

end
vgui.Register("awarn_warnid_menu", PANEL, "DFrame")

/* - Offline Players Panel - */
local PANEL = {}
function PANEL:Init()
	self:SetSize( ScrW() * 0.6, ScrH() * 0.8 )
    self:Center()
	self:DrawFrame()
	self:SetTitle("")
	self:SetDraggable( true )
	self:SetSkin("AWarn")
	self.activewarns = 0
	self.totalwarns = 0
end

function PANEL:Paint()

	--Main Window--	
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.DrawRect( 0, 0, self:GetWide(), self:GetTall() )
	
	surface.SetDrawColor( 10, 10, 10, 220 )
	surface.DrawRect( 4, 4, self:GetWide() - 8, 22 )
	surface.DrawRect( 4, 30, self:GetWide() - 8, self:GetTall() - 90 )
	surface.DrawRect( 4, self:GetTall() - 56, self:GetWide() - 8, 52 )
	
	surface.SetFont( "AWarn2MenuFont1" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( 8 , 6 )
	surface.DrawText( AWarn.localizations[loc].cl1 .. " ::: " .. AWarn.localizations[loc].cl18 )
	
	surface.SetFont( "AWarn2MenuFont1" )
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( 13 , self:GetTall() - 48 )
	surface.DrawText( AWarn.localizations[loc].cl19 )
	surface.SetTextPos( 13 , self:GetTall() - 28 )
	surface.DrawText( AWarn.localizations[loc].cl20 )
	
	surface.SetTextColor( 255, 100, 100, 255 )
	local w, h = surface.GetTextSize(AWarn.localizations[loc].cl19 .. ":")
	surface.SetTextPos( w + 10 , self:GetTall() - 48 )
	surface.DrawText( self.activewarns )
	local w, h = surface.GetTextSize(AWarn.localizations[loc].cl20 .. ":")
	surface.SetTextPos( w + 10 , self:GetTall() - 28 )
	surface.DrawText( self.totalwarns )

end

function PANEL:DrawFrame()

	
	self.WarningsList = vgui.Create( "DListView", self )
	self.WarningsList:SetPos( 4, 30 )
	self.WarningsList:SetSize( self:GetWide() - 8, self:GetTall() - 90 )
	self.WarningsList:SetMultiSelect(false)
	self.WarningsList:AddColumn(AWarn.localizations[loc].cl7):SetFixedWidth( 140 )
	self.WarningsList:AddColumn(AWarn.localizations[loc].cl8)
	self.WarningsList:AddColumn(AWarn.localizations[loc].cl10):SetFixedWidth( 100 )

	
	net.Start("awarn_fetchownwarnings")
	net.SendToServer()
end

function PANEL:PerformLayout()

	self.btnClose:SetPos( self:GetWide() - 24, 6 )
	self.btnClose:SetSize( 18, 18 )
	self.lblTitle:Remove()
	self.btnMaxim:Remove()
	self.btnMinim:Remove()

end
vgui.Register("awarn_client_menu", PANEL, "DFrame")

function ModifyFontInListView( pnl )

	for k, v in pairs( pnl:GetLines() ) do
		for k2, pn in pairs( v.Columns ) do
			pn:SetTextColor( Color(255,255,255,255) )
			pn:SetFont("AWarn2MenuFont3")
			
			local newText, num = string.gsub(pn:GetText(), "\n", " ")
			pn:SetText(newText)
			
			if pn:GetText() == "" then v.center = true end
			if k2 == 1 then
				pn:SetContentAlignment( 5 )			
			end
			if v.center then
				pn:SetContentAlignment( 5 )
			end
		end
	end
end

function ModifyFontInOfflineListView( pnl )

	for k, v in pairs( pnl:GetLines() ) do
		for k2, pn in pairs( v.Columns ) do
			pn:SetTextColor( Color(255,255,255,255) )
			pn:SetFont("AWarn2MenuFont3")
			if k2 == 1 then
				pn:SetContentAlignment( 5 )			
			end
		end
	end
end

net.Receive("SendOfflinePlayers", function(length )
	local tbl = {}
	tbl = net.ReadTable()
	
	for k, v in pairs( tbl ) do
		AWarn.NewMenu.offline_menu.OfflinePlayerList:AddLine(util.SteamIDFrom64(v.unique_id),v.playername,os.date( "%Y / %m / %d" , v.lastplayed ))
	end
	ModifyFontInOfflineListView(AWarn.NewMenu.offline_menu.OfflinePlayerList)
end)

