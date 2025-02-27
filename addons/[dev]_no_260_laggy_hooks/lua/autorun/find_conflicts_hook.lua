addon_hooks_conflict_finder = addon_hooks_conflict_finder or {}

local concommand_name
if SERVER then
	concommand_name = "find_conflicts_hook_sv"
	util.AddNetworkString( "find_conflicts_hook" )
else
	concommand_name = "find_conflicts_hook_cl"
end

local SendToSuperAdmins -- parameter set below

---------- BUILD LUA LIST FOR EACH WORKSHOP ADDON ----------
local ComprAddonsList, ComprAddonsListLen -- cache for Lua files in Workshop addons, sent to client
local net_ReceiveLuaFiles
-- addon_hooks_conflict_finder.AddonsList: Workshop addons list, only set when the 1st test starts
if SERVER then
	function addon_hooks_conflict_finder.FillAddonsList()
		local TempAddonsList = {}
		local title
		for _,addon_info in pairs( engine.GetAddons() ) do
			title = addon_info.title
			if isstring( title ) then
				local _,folders = file.Find( "*", title )
				local folder_l
				for _,folder in ipairs( folders ) do
					folder_l = string.lower( folder )
					if folder_l=="lua" or folder_l=="gamemodes" then -- only listed if contains Lua
						table.insert( TempAddonsList, title )
						break
					end
				end
			end
		end
		addon_hooks_conflict_finder.AddonsList = {}
		for _,title in ipairs( TempAddonsList ) do
			local dirs = {"lua", "gamemodes"}
			local finished = false
			local BeginLoop,EndLoop = 1,#dirs
			while !finished do
				for i=BeginLoop,EndLoop,1 do
					local _,DirListTmp = file.Find( dirs[i].."/*", title )
					for _,DirName in ipairs( DirListTmp ) do
						table.insert( dirs, dirs[i].."/"..DirName )
					end
				end
				BeginLoop = EndLoop+1
				EndLoop = #dirs
				if BeginLoop > EndLoop then
					finished = true
				end
			end
			local LuaList = {}
			for _,dir in ipairs( dirs ) do
				local files = file.Find( dir.."/*.lua", title )
				for _,f in ipairs( files ) do
					LuaList[dir.."/"..f] = true -- BEWARE OF CASE-SENSITIVE file systems
				end
			end
			addon_hooks_conflict_finder.AddonsList[title] = LuaList
		end
		ComprAddonsList = util.Compress( util.TableToJSON( addon_hooks_conflict_finder.AddonsList ) )
		ComprAddonsListLen = string.len( ComprAddonsList )
	end
	net.Receive( "find_conflicts_hook", function( len, ply )
		if !addon_hooks_conflict_finder.AddonsList then
			addon_hooks_conflict_finder.FillAddonsList()
		end
		net.Start( "find_conflicts_hook" )
			net.WriteUInt( 1, 8 )
			net.WriteUInt( ComprAddonsListLen, 32 )
			net.WriteData( ComprAddonsList, ComprAddonsListLen )
		net.Send( ply )
	end )
else
	function addon_hooks_conflict_finder.FillAddonsList()
		net.Start( "find_conflicts_hook" )
		net.SendToServer()
	end
	function net_ReceiveLuaFiles()
		addon_hooks_conflict_finder.AddonsList = util.JSONToTable( util.Decompress( net.ReadData( net.ReadUInt( 32 ) ) ) )
		KnownLuaFiles = {}
	end
end

---------- FIND LUA FILE LOCATION ----------
local KnownLuaFiles = {} -- cache for Lua file readable locations (table of paths or path+addon name)
function addon_hooks_conflict_finder.LocateLuaFile( LuaFile )
	-- WorkshopAddons must be nil when LuaFile is not contained in any Workshop addon, otherwise it must be a table of addon names.
	if !KnownLuaFiles[LuaFile] then
		local CleanLuaFile = LuaFile
		if string.sub( CleanLuaFile, 1, 9 )=="workshop/" then
			CleanLuaFile = string.sub( CleanLuaFile, 10 ) -- remove the workshop/ prefix
		end
		local WorkshopAddons
		local f
		if addon_hooks_conflict_finder.AddonsList then -- nil while client has not loaded
			for title,LuaList in pairs( addon_hooks_conflict_finder.AddonsList ) do
				if LuaList[CleanLuaFile] then -- BEWARE OF CASE-SENSITIVE file systems
					WorkshopAddons = WorkshopAddons or {}
					table.insert( WorkshopAddons, title )
				end
			end
		end
		KnownLuaFiles[LuaFile] = { -- This table can be completed with other fields if needed (legacy addons, gamemodes).
			WorkshopAddons = WorkshopAddons,
		}
	end
	return ( KnownLuaFiles[LuaFile] ).WorkshopAddons
end

---------- MESSAGE COLORS ----------
local ServerColor = Color( 255, 128, 192 )
local ResultColor
if SERVER then
	ResultColor = ServerColor
else
	ResultColor = Color( 255, 192, 0 )
end

---------- FORMAT HOOK RESULTS ----------
local FormatReturned
do
	local FormatBase = 'Event "%s", %s,\n in "%s" (lines %s to %s),\n %s, returned:%s\n\n'
	function FormatReturned( EventName, HookName, LuaFile, linedefined, lastlinedefined, foundstr, list_rarg )
		return string.format( FormatBase, EventName, HookName, LuaFile, tostring( linedefined ), tostring( lastlinedefined ), foundstr, list_rarg )
	end
end

---------- NETWORK ----------
if CLIENT then
	local function net_ReceiveRemoteReturned()
		local EventName = net.ReadString()
		local HookName = net.ReadString()
		local LuaFile = net.ReadString()
		local linedefined = net.ReadUInt( 32 )
		local lastlinedefined = net.ReadUInt( 32 )
		local foundstr = net.ReadString()
		local list_rarg = net.ReadString()
		MsgC( ServerColor, FormatReturned( EventName, HookName, LuaFile, linedefined, lastlinedefined, foundstr, list_rarg ) )
	end
	net.Receive( "find_conflicts_hook", function()
		local Type = net.ReadUInt( 8 )
		if Type == 0 then
			net_ReceiveRemoteReturned()
		elseif Type == 1 then
			net_ReceiveLuaFiles()
		end
	end )
end

---------- REPORT HOOK RESULTS ----------
local find_conflicts_hook -- function defined below
function addon_hooks_conflict_finder.ReportHookResult( EventName, HookName, HookFunction, ... )
	local Returned = { ... }
	if #Returned == 0 or ( #Returned == 1 and Returned[1] == nil ) then -- unverified condition
		return ...
	end
	-- Process HookName:
	if HookName == nil then
		HookName = "GAMEMODE"
	elseif isstring( HookName ) then
		HookName = 'hook "'..HookName..'"'
	else
		HookName = 'hook '..tostring( HookName )
	end
	-- Process info:
	local info = debug.getinfo( HookFunction, 'S' )
	-- MsgN( "info" ); PrintTable( info ) -- debug
	-- Process list_rarg:
	local list_rarg = ""
	for k,rarg in ipairs( Returned ) do
		if isstring( rarg ) then
			list_rarg = list_rarg.."\n\tArg #"..tostring( k )..' = "'..rarg..'"'
		else
			list_rarg = list_rarg.."\n\tArg #"..tostring( k )..' = '..tostring( rarg )
		end
	end
	-- Finish operation:
	local LuaFile = tostring( info.short_src )
	local foundstr
	do
		local locations = addon_hooks_conflict_finder.LocateLuaFile( LuaFile )
		if !locations then
			foundstr = "not found in Workshop addons"
		elseif #locations == 1 then
			foundstr = "found in Workshop addon « "..locations[1].." »"
		else
			foundstr = "found in Workshop addons « "..string.Implode( " », « ", locations ).." »"
		end
	end
	if CLIENT or !SendToSuperAdmins then
		MsgC( ResultColor, FormatReturned( EventName, HookName, LuaFile, info.linedefined, info.lastlinedefined, foundstr, list_rarg ) )
	else
		local superadmins = {}
		for _,ply in pairs( player.GetAll() ) do
			if ply:IsSuperAdmin() then
				superadmins[#superadmins+1] = ply
			end
		end
		if #superadmins > 0 then
			net.Start( "find_conflicts_hook" )
				net.WriteUInt( 0, 8 )
				net.WriteString( EventName )
				net.WriteString( HookName )
				net.WriteString( LuaFile )
				net.WriteUInt( info.linedefined or 0, 32 )
				net.WriteUInt( info.lastlinedefined or 0, 32 )
				net.WriteString( foundstr )
				net.WriteString( list_rarg )
			net.Send( superadmins )
		else
			find_conflicts_hook( nil, concommand_name, { EventName, 0 }, concommand_name..' "'..EventName..'" "0"' ) -- Stop sending to superadmins if none connected.
		end
	end
	return ...
end

---------- SEND MESSAGE ----------
local function NiceMsgN( ply, ... )
	if SERVER and IsValid( ply ) then
		ply:PrintMessage( HUD_PRINTCONSOLE, string.Implode( "", { ... } ) )
	else
		MsgN( ... )
	end
end

---------- START TESTS ----------
local helpstr = concommand_name.." <EventName> <0|1>\n   Displays the hook result of the specified event name in order to find a hook conflict.\n"
local CancelTests
if addon_hooks_conflict_finder.CancelTests then
	CancelTests = addon_hooks_conflict_finder.CancelTests
else
	CancelTests = {}
	addon_hooks_conflict_finder.CancelTests = CancelTests
end
function addon_hooks_conflict_finder.AddModifiedHook( EventName, HookName, HookFunction )
	if isfunction( HookFunction ) then
		local function new_HookFunction( ... )
			return addon_hooks_conflict_finder.ReportHookResult( EventName, HookName, HookFunction, HookFunction( ... ) )
		end
		addon_hooks_conflict_finder.CancelTests[EventName][HookName] = HookFunction
		-- hook.Remove( EventName, HookName ) -- useless
		addon_hooks_conflict_finder.hook_Add( EventName, HookName, new_HookFunction )
	end
end
function find_conflicts_hook( ply, cmd, args, fullstring )
	if CLIENT or !IsValid( ply ) or ply:IsSuperAdmin() then
		local EventName = args[1]
		if !isstring( EventName ) then
			NiceMsgN( ply, " - "..helpstr )
			return
		end
		if !addon_hooks_conflict_finder.AddonsList then
			addon_hooks_conflict_finder.FillAddonsList()
		end
		local start_op = tobool( tonumber( args[2] or 1 ) )
		local IsRunning = istable( CancelTests[EventName] )
		local HookTable = hook.GetTable() -- This is a copy!
		local EventFunctions = HookTable[EventName]
		local CancelTest
		if start_op then -- begin operation
			if !IsRunning then
				if IsValid( ply ) then
					SendToSuperAdmins = true
				else
					SendToSuperAdmins = false
				end
				if istable( EventFunctions ) and table.Count( EventFunctions ) > 0 then
					if !addon_hooks_conflict_finder.hook_Add then
						addon_hooks_conflict_finder.hook_Add = hook.Add
						hook.Add = function( EventName, HookName, HookFunction, ... )
							if addon_hooks_conflict_finder.CancelTests[EventName] then
								addon_hooks_conflict_finder.AddModifiedHook( EventName, HookName, HookFunction )
							else
								addon_hooks_conflict_finder.hook_Add( EventName, HookName, HookFunction, ... )
							end
						end
					end
					CancelTests[EventName] = {}
					CancelTest = CancelTests[EventName]
					for HookName,HookFunction in pairs( EventFunctions ) do
						addon_hooks_conflict_finder.AddModifiedHook( EventName, HookName, HookFunction )
					end
					NiceMsgN( ply, 'Conflict test started for event name "'..EventName..'"!' )
				else
					NiceMsgN( ply, 'Could find no hook with event name "'..EventName..'"!' )
					return
				end
				if isfunction( GAMEMODE[EventName] ) then
					local HookFunction = GAMEMODE[EventName]
					local function new_HookFunction( ... )
						return addon_hooks_conflict_finder.ReportHookResult( EventName, nil, HookFunction, HookFunction( ... ) )
					end
					CancelTest[GAMEMODE] = HookFunction -- to be restored first
					GAMEMODE[EventName] = new_HookFunction
				end
			else
				NiceMsgN( ply, 'Conflict test is already started for event name "'..EventName..'"!' )
			end
		else -- finish operation
			if IsRunning then
				local CancelTest = CancelTests[EventName]
				if CancelTest[GAMEMODE] != nil then
					GAMEMODE[EventName] = CancelTest[GAMEMODE]
					CancelTest[GAMEMODE] = nil
				end
				for HookName,HookFunction in pairs( EventFunctions ) do -- Check the current hooks instead of the cancel list in case of removed hooks while the test was running.
					if CancelTest[HookName] != nil then
						-- hook.Remove( EventName, HookName ) -- useless
						addon_hooks_conflict_finder.hook_Add( EventName, HookName, CancelTest[HookName] )
					end
				end
				CancelTests[EventName] = nil
				NiceMsgN( ply, 'Conflict test is now stopped for event name "'..EventName..'"!' )
			else
				NiceMsgN( ply, 'Conflict test is not running for event name "'..EventName..'"!' )
			end
		end
	end
end
concommand.Add( concommand_name, find_conflicts_hook, nil, helpstr, 0 )
