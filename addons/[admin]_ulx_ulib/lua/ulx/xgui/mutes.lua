xgui.prepareDataType( "mutes" )

local xmutes = xlib.makepanel{ parent=xgui.null }

xmutes.mutelist = xlib.makelistview{ x=5, y=30, w=572, h=310, multiselect=false, parent=xmutes }
	xmutes.mutelist:AddColumn( "Name/SteamID" )
	xmutes.mutelist:AddColumn( "Muted By" )
	xmutes.mutelist:AddColumn( "Unmute Date" )
	xmutes.mutelist:AddColumn( "Reason" )
xmutes.mutelist.DoDoubleClick = function( self, LineID, line )
	xmutes.ShowMuteDetailsWindow( xgui.data.mutes.cache[LineID] )
end
xmutes.mutelist.OnRowRightClick = function( self, LineID, line )
	local menu = DermaMenu()
	menu:SetSkin(xgui.settings.skin)
	menu:AddOption( "Details...", function()
		if not line:IsValid() then return end
		xmutes.ShowMuteDetailsWindow( xgui.data.mutes.cache[LineID] )
	end )
	menu:AddOption( "Edit Mute...", function()
		if not line:IsValid() then return end
		xgui.ShowMuteWindow( nil, line:GetValue( 5 ), nil, true, xgui.data.mutes.cache[LineID] )
	end )
	menu:AddOption( "Remove", function()
		if not line:IsValid() then return end
		xmutes.RemoveMute( line:GetValue( 5 ), xgui.data.mutes.cache[LineID] )
	end )
	menu:Open()
end
-- Change the column sorting method to hook into our own custom sort stuff.
xmutes.mutelist.SortByColumn = function( self, ColumnID, Desc )
	local index =	ColumnID == 1 and 2 or	-- Sort by Name
					ColumnID == 2 and 4 or	-- Sort by Admin
					ColumnID == 3 and 6 or	-- Sort by Unmute Date
					ColumnID == 4 and 5 or	-- Sort by Reason
									  1		-- Otherwise sort by Date
	xmutes.sortbox:ChooseOptionID( index )
end

local searchFilter = ""
xmutes.searchbox = xlib.maketextbox{ x=5, y=6, w=175, text="Search...", selectall=true, parent=xmutes }
local txtCol = xmutes.searchbox:GetTextColor() or Color( 0, 0, 0, 255 )
xmutes.searchbox:SetTextColor( Color( txtCol.r, txtCol.g, txtCol.b, 196 ) ) -- Set initial color
xmutes.searchbox.OnChange = function( pnl )
	if pnl:GetText() == "" then
		pnl:SetText( "Search..." )
		pnl:SelectAll()
		pnl:SetTextColor( Color( txtCol.r, txtCol.g, txtCol.b, 196 ) )
	else
		pnl:SetTextColor( Color( txtCol.r, txtCol.g, txtCol.b, 255 ) )
	end
end
xmutes.searchbox.OnLoseFocus = function( pnl )
	if pnl:GetText() == "Search..." then
		searchFilter = ""
	else
		searchFilter = pnl:GetText()
	end
	xmutes.setPage( 1 )
	xmutes.retrieveMutes()
	hook.Call( "OnTextEntryLoseFocus", nil, pnl )
end

local sortMode = 0
local sortAsc = false
xmutes.sortbox = xlib.makecombobox{ x=185, y=6, w=150, text="Sort: Date (Desc.)", choices={ "Date", "Name", "Steam ID", "Admin", "Reason", "Unmute Date", "Mute Length" }, parent=xmutes }
function xmutes.sortbox:OnSelect( i, v )
	if i-1 == sortMode then
		sortAsc = not sortAsc
	else
		sortMode = i-1
		sortAsc = false
	end
	self:SetValue( "Sort: " .. v .. (sortAsc and " (Asc.)" or " (Desc.)") )
	xmutes.setPage( 1 )
	xmutes.retrieveMutes()
end

local hidePerma = 0
xlib.makebutton{ x=355, y=6, w=95, label="Permamutes: Show", parent=xmutes }.DoClick = function( self )
	hidePerma = hidePerma + 1
	if hidePerma == 1 then
		self:SetText( "Permamutes: Hide" )
	elseif hidePerma == 2 then
		self:SetText( "Permamutes: Only" )
	elseif hidePerma == 3 then
		hidePerma = 0
		self:SetText( "Permamutes: Show" )
	end
	xmutes.setPage( 1 )
	xmutes.retrieveMutes()
end

local hideIncomplete = 0
xlib.makebutton{ x=455, y=6, w=95, label="Incomplete: Show", parent=xmutes, tooltip="Filters mutes that are loaded by ULib, but do not have any metadata associated with them." }.DoClick = function( self )
	hideIncomplete = hideIncomplete + 1
	if hideIncomplete == 1 then
		self:SetText( "Incomplete: Hide" )
	elseif hideIncomplete == 2 then
		self:SetText( "Incomplete: Only" )
	elseif hideIncomplete == 3 then
		hideIncomplete = 0
		self:SetText( "Incomplete: Show" )
	end
	xmutes.setPage( 1 )
	xmutes.retrieveMutes()
end


local function muteUserList( doFreeze )
	local menu = DermaMenu()
	menu:SetSkin(xgui.settings.skin)
	for k, v in ipairs( player.GetAll() ) do
		menu:AddOption( v:Nick(), function()
			if not v:IsValid() then return end
			xgui.ShowMuteWindow( v, v:SteamID(), doFreeze )
		end )
	end
	menu:AddSpacer()
	if LocalPlayer():query("ulx muteid") then menu:AddOption( "Mute by STEAMID...", function() xgui.ShowMuteWindow() end ) end
	menu:Open()
end

xlib.makebutton{ x=5, y=340, w=70, label="Mute...", parent=xmutes }.DoClick = function() muteUserList( false ) end
xmutes.btnFreezeMute = xlib.makebutton{ x=80, y=340, w=95, label="Freeze Mute...", parent=xmutes }
xmutes.btnFreezeMute.DoClick = function() muteUserList( true ) end

xmutes.infoLabel = xlib.makelabel{ x=204, y=344, label="Right-click on a mute for more options", parent=xmutes }


xmutes.resultCount = xlib.makelabel{ y=344, parent=xmutes }
function xmutes.setResultCount( count )
	local pnl = xmutes.resultCount
	pnl:SetText( count .. " results" )
	pnl:SizeToContents()

	local width = pnl:GetWide()
	local x, y = pnl:GetPos()
	pnl:SetPos( 475 - width, y )

	local ix, iy = xmutes.infoLabel:GetPos()
	xmutes.infoLabel:SetPos( ( 130 - width ) / 2 + 175, y )
end

local numPages = 1
local pageNumber = 1
xmutes.pgleft = xlib.makebutton{ x=480, y=340, w=20, icon="icon16/arrow_left.png", centericon=true, disabled=true, parent=xmutes }
xmutes.pgleft.DoClick = function()
	xmutes.setPage( pageNumber - 1 )
	xmutes.retrieveMutes()
end
xmutes.pageSelector = xlib.makecombobox{ x=500, y=340, w=57, text="1", enableinput=true, parent=xmutes }
function xmutes.pageSelector:OnSelect( index )
	xmutes.setPage( index )
	xmutes.retrieveMutes()
end
function xmutes.pageSelector.TextEntry:OnEnter()
	pg = math.Clamp( tonumber( self:GetValue() ) or 1, 1, numPages )
	xmutes.setPage( pg )
	xmutes.retrieveMutes()
end
xmutes.pgright = xlib.makebutton{ x=557, y=340, w=20, icon="icon16/arrow_right.png", centericon=true, disabled=true, parent=xmutes }
xmutes.pgright.DoClick = function()
	xmutes.setPage( pageNumber + 1 )
	xmutes.retrieveMutes()
end

xmutes.setPage = function( newPage )
	pageNumber = newPage
	xmutes.pgleft:SetDisabled( pageNumber <= 1 )
	xmutes.pgright:SetDisabled( pageNumber >= numPages )
	xmutes.pageSelector.TextEntry:SetText( pageNumber )
end


function xmutes.RemoveMute( ID, mutedata )
	local tempstr = "<Unknown>"
	if mutedata then tempstr = mutedata.name or "<Unknown>" end
	Derma_Query( "Are you sure you would like to unmute " .. tempstr .. " - " .. ID .. "?", "XGUI WARNING", 
		"Remove",	function()
						RunConsoleCommand( "ulx", "unmute", ID ) 
						xmutes.RemoveMuteDetailsWindow( ID )
					end,
		"Cancel", 	function() end )
end

xmutes.openWindows = {}
function xmutes.RemoveMuteDetailsWindow( ID )
	if xmutes.openWindows[ID] then
		xmutes.openWindows[ID]:Remove()
		xmutes.openWindows[ID] = nil
	end
end

function xmutes.ShowMuteDetailsWindow( mutedata )
	local wx, wy

	if not mutedata then return end

	if xmutes.openWindows[mutedata.steamID] then
		wx, wy = xmutes.openWindows[mutedata.steamID]:GetPos()
		xmutes.openWindows[mutedata.steamID]:Remove()
	end
	xmutes.openWindows[mutedata.steamID] = xlib.makeframe{ label="Mute Details", x=wx, y=wy, w=285, h=295, skin=xgui.settings.skin }

	local panel = xmutes.openWindows[mutedata.steamID]
	local name = xlib.makelabel{ x=50, y=30, label="Name:", parent=panel }
	xlib.makelabel{ x=90, y=30, w=190, label=( mutedata.name or "<Unknown>" ), parent=panel, tooltip=mutedata.name }
	xlib.makelabel{ x=36, y=50, label="SteamID:", parent=panel }
	xlib.makelabel{ x=90, y=50, label=mutedata.steamID, parent=panel }
	xlib.makelabel{ x=33, y=70, label="Mute Date:", parent=panel }
	xlib.makelabel{ x=90, y=70, label=mutedata.time and ( os.date( "%b %d, %Y - %I:%M:%S %p", tonumber( mutedata.time ) ) ) or "<This mute has no metadata>", parent=panel }
	xlib.makelabel{ x=20, y=90, label="Unmute Date:", parent=panel }
	xlib.makelabel{ x=90, y=90, label=( tonumber( mutedata.unmute ) == 0 and "Never" or os.date( "%b %d, %Y - %I:%M:%S %p", math.min(  tonumber( mutedata.unmute ), 4294967295 ) ) ), parent=panel }
	xlib.makelabel{ x=10, y=110, label="Length of Mute:", parent=panel }
	xlib.makelabel{ x=90, y=110, label=( tonumber( mutedata.unmute ) == 0 and "Permanent" or xgui.ConvertTime( tonumber( mutedata.unmute ) - mutedata.time ) ), parent=panel }
	xlib.makelabel{ x=33, y=130, label="Time Left:", parent=panel }
	local timeleft = xlib.makelabel{ x=90, y=130, label=( tonumber( mutedata.unmute ) == 0 and "N/A" or xgui.ConvertTime( tonumber( mutedata.unmute ) - os.time() ) ), parent=panel }
	xlib.makelabel{ x=26, y=150, label="Muted By:", parent=panel }
	if mutedata.admin then xlib.makelabel{ x=90, y=150, label=string.gsub( mutedata.admin, "%(STEAM_%w:%w:%w*%)", "" ), parent=panel } end
	if mutedata.admin then xlib.makelabel{ x=90, y=165, label=string.match( mutedata.admin, "%(STEAM_%w:%w:%w*%)" ), parent=panel } end
	xlib.makelabel{ x=41, y=185, label="Reason:", parent=panel }
	xlib.makelabel{ x=90, y=185, w=190, label=mutedata.reason, parent=panel, tooltip=mutedata.reason ~= "" and mutedata.reason or nil }
	xlib.makelabel{ x=13, y=205, label="Last Updated:", parent=panel }
	xlib.makelabel{ x=90, y=205, label=( ( mutedata.modified_time == nil ) and "Never" or os.date( "%b %d, %Y - %I:%M:%S %p", tonumber( mutedata.modified_time ) ) ), parent=panel }
	xlib.makelabel{ x=21, y=225, label="Updated by:", parent=panel }
	if mutedata.modified_admin then xlib.makelabel{ x=90, y=225, label=string.gsub( mutedata.modified_admin, "%(STEAM_%w:%w:%w*%)", "" ), parent=panel } end
	if mutedata.modified_admin then xlib.makelabel{ x=90, y=240, label=string.match( mutedata.modified_admin, "%(STEAM_%w:%w:%w*%)" ), parent=panel } end

	panel.data = mutedata	-- Store data on panel for future reference.
	xlib.makebutton{ x=5, y=265, w=89, label="Edit Mute...", parent=panel }.DoClick = function()
		xgui.ShowMuteWindow( nil, panel.data.steamID, nil, true, panel.data )
	end

	xlib.makebutton{ x=99, y=265, w=89, label="Unmute", parent=panel }.DoClick = function()
		xmutes.RemoveMute( panel.data.steamID, panel.data )
	end

	xlib.makebutton{ x=192, y=265, w=88, label="Close", parent=panel }.DoClick = function()
		xmutes.RemoveMuteDetailsWindow( panel.data.steamID )
	end

	panel.btnClose.DoClick = function ( button )
		xmutes.RemoveMuteDetailsWindow( panel.data.steamID )
	end

	if timeleft:GetValue() ~= "N/A" then
		function panel.OnTimer()
			if panel:IsVisible() then
				local mutetime = tonumber( panel.data.unmute ) - os.time()
				if mutetime <= 0 then
					xmutes.RemoveMuteDetailsWindow( panel.data.steamID )
					return
				else
					timeleft:SetText( xgui.ConvertTime( mutetime ) )
				end
				timeleft:SizeToContents()
				timer.Simple( 1, panel.OnTimer )
			end
		end
		panel.OnTimer()
	end
end

function xgui.ShowMuteWindow( ply, ID, doFreeze, isUpdate, mutedata )
	if not LocalPlayer():query( "ulx mute" ) and not LocalPlayer():query( "ulx muteid" ) then return end

	local xgui_mutewindow = xlib.makeframe{ label=( isUpdate and "Edit Mute" or "Mute Player" ), w=285, h=180, skin=xgui.settings.skin }
	xlib.makelabel{ x=37, y=33, label="Name:", parent=xgui_mutewindow }
	xlib.makelabel{ x=23, y=58, label="SteamID:", parent=xgui_mutewindow }
	xlib.makelabel{ x=28, y=83, label="Reason:", parent=xgui_mutewindow }
	xlib.makelabel{ x=10, y=108, label="Mute Length:", parent=xgui_mutewindow }
	local reason = xlib.makecombobox{ x=75, y=80, w=200, parent=xgui_mutewindow, enableinput=true, selectall=true, choices=ULib.cmds.translatedCmds["ulx mute"].args[4].completes }
	local mutepanel = ULib.cmds.NumArg.x_getcontrol( ULib.cmds.translatedCmds["ulx mute"].args[3], 2, xgui_mutewindow )
	mutepanel.interval:SetParent( xgui_mutewindow )
	mutepanel.interval:SetPos( 200, 105 )
	mutepanel.val:SetParent( xgui_mutewindow )
	mutepanel.val:SetPos( 75, 125 )
	mutepanel.val:SetWidth( 200 )

	local name
	if not isUpdate then
		name = xlib.makecombobox{ x=75, y=30, w=200, parent=xgui_mutewindow, enableinput=true, selectall=true }
		for k,v in pairs( player.GetAll() ) do
			name:AddChoice( v:Nick(), v:SteamID() )
		end
		name.OnSelect = function( self, index, value, data )
			self.steamIDbox:SetText( data )
		end
	else
		name = xlib.maketextbox{ x=75, y=30, w=200, parent=xgui_mutewindow, selectall=true }
		if mutedata then
			name:SetText( mutedata.name or "" )
			reason:SetText( mutedata.reason or "" )
			if tonumber( mutedata.unmute ) ~= 0 then
				local btime = ( tonumber( mutedata.unmute ) - tonumber( mutedata.time ) )
				if btime % 31536000 == 0 then
					if #mutepanel.interval.Choices >= 6 then
						mutepanel.interval:ChooseOptionID(6)
					else
						mutepanel.interval:SetText( "Years" )
					end
					btime = btime / 31536000
				elseif btime % 604800 == 0 then
					if #mutepanel.interval.Choices >= 5 then
						mutepanel.interval:ChooseOptionID(5)
					else
						mutepanel.interval:SetText( "Weeks" )
					end
					btime = btime / 604800
				elseif btime % 86400 == 0 then
					if #mutepanel.interval.Choices >= 4 then
						mutepanel.interval:ChooseOptionID(4)
					else
						mutepanel.interval:SetText( "Days" )
					end
					btime = btime / 86400
				elseif btime % 3600 == 0 then
					if #mutepanel.interval.Choices >= 3 then
						mutepanel.interval:ChooseOptionID(3)
					else
						mutepanel.interval:SetText( "Hours" )
					end
					btime = btime / 3600
				else
					btime = btime / 60
					if #mutepanel.interval.Choices >= 2 then
						mutepanel.interval:ChooseOptionID(2)
					else
						mutepanel.interval:SetText( "Minutes" )
					end
				end
				mutepanel.val:SetValue( btime )
			end
		end
	end

	local steamID = xlib.maketextbox{ x=75, y=55, w=200, selectall=true, disabled=( isUpdate or not LocalPlayer():query( "ulx muteid" ) ), parent=xgui_mutewindow }
	name.steamIDbox = steamID --Make a reference to the steamID textbox so it can change the value easily without needing a global variable

	if doFreeze and ply then
		if LocalPlayer():query( "ulx freeze" ) then
			RunConsoleCommand( "ulx", "freeze", "$" .. ULib.getUniqueIDForPlayer( ply ) )
			steamID:SetDisabled( true )
			name:SetDisabled( true )
			xgui_mutewindow:ShowCloseButton( false )
		else
			doFreeze = false
		end
	end
	xlib.makebutton{ x=165, y=150, w=75, label="Cancel", parent=xgui_mutewindow }.DoClick = function()
		if doFreeze and ply and ply:IsValid() then
			RunConsoleCommand( "ulx", "unfreeze", "$" .. ULib.getUniqueIDForPlayer( ply ) )
		end
		xgui_mutewindow:Remove()
	end
	xlib.makebutton{ x=45, y=150, w=75, label=( isUpdate and "Update" or "Mute!" ), parent=xgui_mutewindow }.DoClick = function()
		if isUpdate then
			local function performUpdate(btime)
				RunConsoleCommand( "xgui", "updateMute", steamID:GetValue(), btime, reason:GetValue(), name:GetValue() )
				xgui_mutewindow:Remove()
			end
			btime = mutepanel:GetMinutes()
			if btime ~= 0 and mutedata and btime * 60 + mutedata.time < os.time() then
				Derma_Query( "WARNING! The new mute time you have specified will cause this mute to expire.\nThe minimum time required in order to change the mute length successfully is " 
						.. xgui.ConvertTime( os.time() - mutedata.time ) .. ".\nAre you sure you wish to continue?", "XGUI WARNING",
					"Expire Mute", function()
						performUpdate(btime)
						xmutes.RemoveMuteDetailsWindow( mutedata.steamID )
					end,
					"Cancel", function() end )
			else
				performUpdate(btime)
			end
			return
		end

		if ULib.isValidSteamID( steamID:GetValue() ) then
			local isOnline = false
			for k, v in ipairs( player.GetAll() ) do
				if v:SteamID() == steamID:GetValue() then
					isOnline = v
					break
				end
			end
			if not isOnline then
				if name:GetValue() == "" then
					RunConsoleCommand( "ulx", "muteid", steamID:GetValue(), mutepanel:GetValue(), reason:GetValue() )
				else
					RunConsoleCommand( "xgui", "updateMute", steamID:GetValue(), mutepanel:GetMinutes(), reason:GetValue(), ( name:GetValue() ~= "" and name:GetValue() or nil ) )
				end
			else
				RunConsoleCommand( "ulx", "mute", "$" .. ULib.getUniqueIDForPlayer( isOnline ), mutepanel:GetValue(), reason:GetValue() )
			end
			xgui_mutewindow:Remove()
		else
			local ply, message = ULib.getUser( name:GetValue() )
			if ply then
				RunConsoleCommand( "ulx", "mute", "$" .. ULib.getUniqueIDForPlayer( ply ), mutepanel:GetValue(), reason:GetValue() )
				xgui_mutewindow:Remove()
				return
			end
			Derma_Message( message )
		end
	end

	if ply then name:SetText( ply:Nick() ) end
	if ID then steamID:SetText( ID ) else steamID:SetText( "STEAM_0:" ) end
end

function xgui.ConvertTime( seconds )
	--Convert number of seconds remaining to something more legible (Thanks JamminR!)
	local years = math.floor( seconds / 31536000 )
	seconds = seconds - ( years * 31536000 )
	local weeks = math.floor( seconds / 604800 )
	seconds = seconds - ( weeks * 604800 )
	local days = math.floor( seconds / 86400 )
	seconds = seconds - ( days * 86400 )
	local hours = math.floor( seconds/3600 )
	seconds = seconds - ( hours * 3600 )
	local minutes = math.floor( seconds/60 )
	seconds = seconds - ( minutes * 60 )
	local curtime = ""
	if years ~= 0 then curtime = curtime .. years .. " year" .. ( ( years > 1 ) and "s, " or ", " ) end
	if weeks ~= 0 then curtime = curtime .. weeks .. " week" .. ( ( weeks > 1 ) and "s, " or ", " ) end
	if days ~= 0 then curtime = curtime .. days .. " day" .. ( ( days > 1 ) and "s, " or ", " ) end
	curtime = curtime .. ( ( hours < 10 ) and "0" or "" ) .. hours .. ":"
	curtime = curtime .. ( ( minutes < 10 ) and "0" or "" ) .. minutes .. ":"
	return curtime .. ( ( seconds < 10 and "0" or "" ) .. seconds )
end

---Update stuff
function xmutes.mutesRefreshed()
	xgui.data.mutes.cache = {} -- Clear the mutes cache

	-- Retrieve mutes if XGUI is open, otherwise it will be loaded later.
	if xgui.anchor:IsVisible() then
		xmutes.retrieveMutes()
	end
end
xgui.hookEvent( "mutes", "process", xmutes.mutesRefreshed, "mutesRefresh" )

function xmutes.mutePageRecieved( data )
	xgui.data.mutes.cache = data
	xmutes.clearmutes()
	xmutes.populateMutes()
end
xgui.hookEvent( "mutes", "data", xmutes.mutePageRecieved, "mutesGotPage" )

function xmutes.checkCache()
	if xgui.data.mutes.cache and xgui.data.mutes.count ~= 0 and table.Count(xgui.data.mutes.cache) == 0 then
		xmutes.retrieveMutes()
	end
end
xgui.hookEvent( "onOpen", nil, xmutes.checkCache, "mutesCheckCache" )

function xmutes.clearmutes()
	xmutes.mutelist:Clear()
end

function xmutes.retrieveMutes()
	RunConsoleCommand( "xgui", "getmutes",
		sortMode,			-- Sort Type
		searchFilter,		-- Filter String
		hidePerma,			-- Hide permamutes?
		hideIncomplete,		-- Hide mutes that don't have full ULX metadata?
		pageNumber,			-- Page number
		sortAsc and 1 or 0)	-- Ascending/Descending
end

function xmutes.populateMutes()
	if xgui.data.mutes.cache == nil then return end
	local cache = xgui.data.mutes.cache
	local count = cache.count or xgui.data.mutes.count
	numPages = math.max( 1, math.ceil( count / 17 ) )

	xmutes.setResultCount( count )
	xmutes.pageSelector:SetDisabled( numPages == 1 )
	xmutes.pageSelector:Clear()
	for i=1, numPages do
		xmutes.pageSelector:AddChoice(i)
	end
	xmutes.setPage( math.Clamp( pageNumber, 1, numPages ) )

	cache.count = nil

	for _, muteinfo in pairs( cache ) do
		xmutes.mutelist:AddLine( muteinfo.name or muteinfo.steamID,
					( muteinfo.admin ) and string.gsub( muteinfo.admin, "%(STEAM_%w:%w:%w*%)", "" ) or "",
					(( tonumber( muteinfo.unmute ) ~= 0 ) and os.date( "%c", math.min( tonumber( muteinfo.unmute ), 4294967295 ) )) or "Never",
					muteinfo.reason,
					muteinfo.steamID,
					tonumber( muteinfo.unmute ) )
	end
end
xmutes.populateMutes() --For autorefresh

function xmutes.xmute( ply, cmd, args, dofreeze )
	if args[1] and args[1] ~= "" then
		local target = ULib.getUser( args[1] )
		if target then
			xgui.ShowMuteWindow( target, target:SteamID(), dofreeze )
		end
	else
		xgui.ShowMuteWindow()
	end
end
ULib.cmds.addCommandClient( "xgui xmute", xmutes.xmute )

function xmutes.fmute( ply, cmd, args )
	xmutes.xmute( ply, cmd, args, true )
end
ULib.cmds.addCommandClient( "xgui fmute", xmutes.fmute )

function xmutes.UCLChanged()
	xmutes.btnFreezeMute:SetDisabled( not LocalPlayer():query("ulx freeze") )
end
hook.Add( "UCLChanged", "xgui_RefreshMutesMenu", xmutes.UCLChanged )

xgui.addModule( "Mutes", xmutes, "icon16/exclamation.png", "xgui_managemutes" )
