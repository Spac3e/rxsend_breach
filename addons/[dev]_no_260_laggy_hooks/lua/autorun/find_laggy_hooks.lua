--- Ajouter le temps de rendu VGUI.



-- Note: GM functions that have been modified during a test will be restored with an older version.

addon_hooks_lag_finder = addon_hooks_lag_finder or {}

local concommand_name
if SERVER then
	concommand_name = "find_laggy_hooks_sv"
	util.AddNetworkString( "find_laggy_hooks" )
else
	concommand_name = "find_laggy_hooks_cl"
end

local SendToSuperAdmins -- parameter set below

---------- MESSAGE COLORS ----------
local ServerColor = Color( 255, 128, 192 )
local ResultColor
if SERVER then
	ResultColor = ServerColor
else
	ResultColor = Color( 255, 192, 0 )
end

---------- SEND MESSAGE ----------
local function NiceMsgN( ply, ... )
	if SERVER and IsValid( ply ) then
		ply:PrintMessage( HUD_PRINTCONSOLE, string.Implode( "", { ... } ) )
	else
		MsgN( ... )
	end
end

---------- FORMAT HOOK TIMINGS ----------
local IntroMessage = "\n\nHere are the %u laggiest hooks found during the last %u frames:\n"..
	( SERVER and game.IsDedicated() and " Identifier ------------------------------- Impact  Execs  Mean t /f  Max time \n" or--79
	" Identifier ------------------------------------------------------------ Impact  Executions  Mean t /f  Max time \n" )--113
local FormatTimings
do
	local function FillStringSlot( Input, Slot )
		Input = string.sub( Input, 1, Slot )
		Input = Input..( string.rep( " ", Slot-utf8.len( Input ) ) )
		return Input
	end
	local UnitFormats={ -- decimals+unit, multiplier
		-- Greek characters are not used because UTF-8 sub-strings are not supported.
		{"%01.3fus", 1000000},
		{"%01.2fus", 1000000},
		{"%01.1fus", 1000000},
		{"%01.0fus", 1000000},
		{"%01.2fms", 1000},
		{"%01.1fms", 1000},
		{"%01.0fms", 1000},
		{"%01.2fs", 1},
		{"%01.1fs", 1},
		{"%01.0fs", 1},
	}
	local function FillTimeSlot( Input, Slot )
		local NumString
		for i,UnitFormat in ipairs( UnitFormats ) do
			NumString=string.format( UnitFormat[1], Input*UnitFormat[2] )
			if utf8.len( NumString )<=Slot then
				break
			end
		end
		return FillStringSlot( NumString, Slot )
	end
	local function FillIntegerSlot( Input, Slot )
		local NumString = tostring( Input )
		if string.len( NumString )>Slot then
			for decimals=Slot-5,0,-1 do
				NumString = string.format( "%."..decimals.."e", Input )
				if string.len( NumString )<=Slot then
					break
				end
			end
		end
		return FillStringSlot( NumString, Slot )
	end
	local FormatBase = ' %s %s %s %s %s\n  in "%s" (lines %s to %s),\n  %s\n'
	local Slots -- string lengths for virtual table in console
	if CLIENT or !game.IsDedicated() then
		Slots = {
			identifier=71,
			Impact=7,
			count=11,
			meantime=10,
			maxtime=9,
		}
	else
		Slots = {
			identifier=42,
			Impact=7,
			count=6,
			meantime=10,
			maxtime=9,
		}
	end
	function FormatTimings( identifier, Impact, count, meantime, maxtime, LuaFile, linedefined, lastlinedefined, foundstr )
		return string.format( FormatBase,
			FillStringSlot( identifier, Slots.identifier ),
			FillStringSlot( string.format( Impact<10 and "%05.2f%%" or "%1.0f%%", Impact*100 ), Slots.Impact ),
			FillIntegerSlot( count, Slots.count ),
			FillTimeSlot( meantime, Slots.meantime ),
			FillTimeSlot( maxtime, Slots.maxtime ),
			-- FillStringSlot( string.format( "%.2e", meantime ), Slots.meantime ), -- debug
			-- FillStringSlot( string.format( "%.2e", maxtime ), Slots.maxtime ), -- debug
			LuaFile,
			tostring( linedefined ),
			tostring( lastlinedefined ),
			foundstr
		)
	end
end

---------- NETWORK ----------
if CLIENT then
	local function net_ReceiveRemoteTimings()
		local TopCount = net.ReadUInt( 32 )
		local NumFrames = net.ReadUInt( 32 )
		MsgC( ServerColor, string.format( IntroMessage, TopCount, NumFrames ) )
		for k=1,TopCount do
			local identifier = net.ReadString()
			local Impact = net.ReadFloat()
			local count = net.ReadUInt( 32 )
			local meantime = net.ReadFloat()
			local maxtime = net.ReadFloat()
			local LuaFile = net.ReadString()
			local linedefined = net.ReadUInt( 32 )
			local lastlinedefined = net.ReadUInt( 32 )
			local foundstr = net.ReadString()
			MsgC( ServerColor, FormatTimings( identifier, Impact, count, meantime, maxtime, LuaFile, linedefined, lastlinedefined, foundstr ) )
		end
	end
	net.Receive( "find_laggy_hooks", function()
		local Type = net.ReadUInt( 8 )
		if Type == 0 then
			net_ReceiveRemoteTimings()
		end
	end )
end

---------- STORE HOOK EXECUTION TIME ----------
addon_hooks_lag_finder.ReportedTimings = addon_hooks_lag_finder.ReportedTimings or {}
function addon_hooks_lag_finder.ReportHookTiming( identifier, HookFunction, start, finish )
	local Report = addon_hooks_lag_finder.ReportedTimings[identifier]
	if !Report then
		Report = {
			identifier = identifier,
			HookFunction = HookFunction,
			count = 0,
			time = 0.,
			maxtime = 0.,
		}
		addon_hooks_lag_finder.ReportedTimings[identifier] = Report
	end
	local RunTime = finish-start
	Report.count = Report.count+1
	Report.time = Report.time+RunTime
	Report.maxtime = math.max( RunTime, Report.maxtime )
end

---------- REPORT STATISTICS ----------
local find_laggy_hooks -- function defined below
local ReportStatistics
do
	local function SortReportedTimings( a, b )
		return a.Impact > b.Impact
	end
	function ReportStatistics()
		local NumFrames = addon_hooks_lag_finder.NumFrames
		local NumFrames1 = NumFrames-1
		local PeriodEnd = SysTime() -- true value
		local PeriodDuration = PeriodEnd-addon_hooks_lag_finder.PeriodStart
		-- Copy the ReportedTimings, with integer keys:
		local ReportedTimings = {}
		for _,Report in pairs( addon_hooks_lag_finder.ReportedTimings ) do
			-- Good method but the maxtime often gets crazy values:
			-- Report.Impact = (
				-- ( Report.maxtime*math.max( NumFrames, Report.count ) ) -- pessimistic: consider as always max time
				-- +Report.time -- optimistic: consider as always mean time
			-- )/( 2*PeriodDuration )
			-- Average method:
			if Report.count>=NumFrames1 then -- considering only mean execution time
				Report.Impact = Report.time/PeriodDuration
			else -- same, multiplied by NumFrames/Report.count
				Report.Impact = ( Report.time*NumFrames )/( PeriodDuration*Report.count )
			end
			table.insert( ReportedTimings, Report )
		end
		-- Sort the copied ReportedTimings:
		table.sort( ReportedTimings, SortReportedTimings )
		local TopCount=0 -- number of displayed values
		if addon_hooks_lag_finder.TopCountOrRatioThreshold < 1 then -- use RatioThreshold
			local RatioThreshold = addon_hooks_lag_finder.TopCountOrRatioThreshold
			-- Only keep impacts higher than the RatioThreshold:
			for k=#ReportedTimings,1,-1 do
				if ReportedTimings[k].Impact>=RatioThreshold then
					TopCount=k
					break
				end
			end
		else -- use TopCount
			TopCount=math.min( #ReportedTimings, addon_hooks_lag_finder.TopCountOrRatioThreshold )
		end
		-- Clear the ReportedTimings for next capture period:
		addon_hooks_lag_finder.ReportedTimings = {}
		addon_hooks_lag_finder.RunningFunctions = {} -- safety precaution
		addon_hooks_lag_finder.PeriodStart = PeriodEnd
		addon_hooks_lag_finder.PeriodEnd = PeriodEnd+addon_hooks_lag_finder.ReportInterval
		addon_hooks_lag_finder.NumFrames = 0
		-- Process info:
		for k=1,TopCount do
			local Report = ReportedTimings[k]
			Report.meantime = Report.time/NumFrames
			local info = debug.getinfo( Report.HookFunction, 'S' )
			Report.info = info
			local LuaFile = tostring( info.short_src )
			Report.LuaFile = LuaFile
			local foundstr
			if addon_hooks_conflict_finder and addon_hooks_conflict_finder.LocateLuaFile then
				local locations = addon_hooks_conflict_finder.LocateLuaFile( LuaFile )
				if !locations then
					foundstr = "not found in Workshop addons"
				elseif #locations == 1 then
					foundstr = "found in Workshop addon « "..locations[1].." »"
				else
					foundstr = "found in Workshop addons « "..string.Implode( " », « ", locations ).." »"
				end
			else
				foundstr = "Addon hooks Conflict Finder not available"
			end
			Report.foundstr = foundstr
		end
		if CLIENT or !SendToSuperAdmins then
			MsgC( ResultColor, string.format( IntroMessage, TopCount, NumFrames ) )
			for k=1,TopCount do
				local Report = ReportedTimings[k]
				local info = Report.info
				MsgC( ResultColor, FormatTimings( Report.identifier, Report.Impact, Report.count, Report.meantime, Report.maxtime, Report.LuaFile, info.linedefined, info.lastlinedefined, Report.foundstr ) )
			end
		else
			local superadmins = {}
			for _,ply in pairs( player.GetAll() ) do
				if ply:IsSuperAdmin() then
					superadmins[#superadmins+1] = ply
				end
			end
			if #superadmins > 0 then
				net.Start( "find_laggy_hooks" )
					net.WriteUInt( 0, 8 )
					net.WriteUInt( TopCount, 32 )
					net.WriteUInt( NumFrames, 32 )
					for k=1,TopCount do
						local Report = ReportedTimings[k]
						local info = Report.info
						net.WriteString( Report.identifier )
						net.WriteFloat( Report.Impact )
						net.WriteUInt( Report.count, 32 )
						net.WriteFloat( Report.meantime )
						net.WriteFloat( Report.maxtime )
						net.WriteString( Report.LuaFile )
						net.WriteUInt( info.linedefined or 0, 32 )
						net.WriteUInt( info.lastlinedefined or 0, 32 )
						net.WriteString( Report.foundstr )
					end
				net.Send( superadmins )
			else
				find_laggy_hooks( nil, concommand_name, { 0 }, concommand_name..' "0"' ) -- Stop sending to superadmins if none connected.
			end
		end
		-- Set the period start & end again (accurate time ignoring find_laggy_hooks' process):
		addon_hooks_lag_finder.PeriodStart = SysTime()
		addon_hooks_lag_finder.PeriodEnd = addon_hooks_lag_finder.PeriodStart+addon_hooks_lag_finder.ReportInterval -- expected value
	end
end
hook.Add( "Think", "find_laggy_hooks", function()
	if addon_hooks_lag_finder.RunningTest then
		addon_hooks_lag_finder.NumFrames = addon_hooks_lag_finder.NumFrames+1
		if SysTime()>=addon_hooks_lag_finder.PeriodEnd then
			ReportStatistics()
		end
	end
end )

---------- START TESTS ----------
local helpstr = concommand_name.." [ReportInterval=30 or 0] [TopCount=16 or RatioThreshold]\n   Displays laggy hooks on every ReportInterval seconds.\n   The optional second argument can be a top TopCount of laggiest hooks or a threshold ratio of (execution_time/frame_time).\n   To stop the test, type 0 as the first argument.\n"
local CancelTests
if addon_hooks_lag_finder.CancelTests then
	CancelTests = addon_hooks_lag_finder.CancelTests
else
	CancelTests = {
		-- hook={},-- contains event names, hook names, functions
		-- net={},-- contains message ids, functions
		-- usermessage={},-- contains message ids, functions
		-- ENT={},-- contains classes, event names, functions
		-- SWEP={},-- contains classes, event names, functions
		-- GM={},-- contains gamemodes, event names, functions
	}
	addon_hooks_lag_finder.CancelTests = CancelTests
end
local function GetModifiedHookFunction( identifier, HookFunction, ReportedFunction )
	-- Do not make re-used local variables: danger in case of recursive calls.
	local function new_HookFunction( ... )
		if !addon_hooks_lag_finder.RunningFunctions[HookFunction] then
			addon_hooks_lag_finder.RunningFunctions[HookFunction]=true
			local start,ret,finish
			start=SysTime()
			ret={ pcall( HookFunction, ... ) } -- protected to prevent malfunction
			finish=SysTime()
			addon_hooks_lag_finder.RunningFunctions[HookFunction]=false
			addon_hooks_lag_finder.ReportHookTiming( identifier, ReportedFunction or HookFunction, start, finish )
			if ret[1] then -- ok
				table.remove( ret, 1 ) -- remove the returned status
			else -- error
				error( ret[2] ) -- throw the returned error when safe
			end
			return unpack( ret )
		else -- ignore recursive calls
			return HookFunction( ... )
		end
	end
	return new_HookFunction
end
function addon_hooks_lag_finder.AddModifiedHook( EventName, HookName, HookFunction, ... )
	local new_HookFunction
	if isfunction( HookFunction ) then
		if HookName!="find_laggy_hooks" then
			new_HookFunction = GetModifiedHookFunction(
				'Event "'..tostring( EventName )..'", hook "'..tostring( HookName )..'"',
				HookFunction
			)
			addon_hooks_lag_finder.CancelTests.hook[EventName] = addon_hooks_lag_finder.CancelTests.hook[EventName] or {}
			addon_hooks_lag_finder.CancelTests.hook[EventName][HookName] = HookFunction
		else
			new_HookFunction = HookFunction
		end
	else
		new_HookFunction = HookFunction
	end
	-- hook.Remove( EventName, HookName ) -- useless
	return addon_hooks_lag_finder.hook_Add( EventName, HookName, new_HookFunction, ... )
end
function addon_hooks_lag_finder.AddModifiedNet( EventName, HookFunction, ... )
	local new_HookFunction
	local lower_EventName = tostring( EventName ):lower()
	if isfunction( HookFunction ) then
		if EventName!="find_laggy_hooks" then
			new_HookFunction = GetModifiedHookFunction(
				'Net receiver "'..tostring( EventName )..'"',
				HookFunction
			)
			addon_hooks_lag_finder.CancelTests.net[lower_EventName] = HookFunction
		else
			new_HookFunction = HookFunction
		end
	else
		new_HookFunction = HookFunction
	end
	return addon_hooks_lag_finder.net_Receive( lower_EventName, new_HookFunction, ... )
end
function addon_hooks_lag_finder.AddModifiedUsermessage( EventName, HookFunction, ... )
	local new_HookFunction
	if isfunction( HookFunction ) then
		if EventName!="find_laggy_hooks" then
			new_HookFunction = GetModifiedHookFunction(
				'Usermessage receiver "'..tostring( EventName )..'"',
				HookFunction
			)
			addon_hooks_lag_finder.CancelTests.usermessage[EventName] = {
				Function = HookFunction,
				PreArgs = {...},
			}
		else
			new_HookFunction = HookFunction
		end
	else
		new_HookFunction = HookFunction
	end
	return addon_hooks_lag_finder.usermessage_Hook( EventName, new_HookFunction, ... )
end
function addon_hooks_lag_finder.AdjustModifiedTimer( EventName, delay, repetitions, HookFunction, ... )
print(tostring(EventName))
	local new_HookFunction
	if isfunction( HookFunction ) then
		local new_HookFunction2 = GetModifiedHookFunction(
			'Timer "'..tostring( EventName )..'"',
			HookFunction
		)
		new_HookFunction = function( ... )
			if addon_hooks_lag_finder.RunningTest then
				return new_HookFunction2( ... )
			else
				return HookFunction( ... )
			end
		end
	else
		new_HookFunction = HookFunction
	end
	return addon_hooks_lag_finder.timer_Adjust( EventName, delay, repetitions, new_HookFunction, ... )
end
function addon_hooks_lag_finder.AddModifiedTimer( EventName, delay, repetitions, HookFunction, ... )
	local new_HookFunction
	if isfunction( HookFunction ) then
		local new_HookFunction2 = GetModifiedHookFunction(
			'Timer "'..tostring( EventName )..'"',
			HookFunction
		)
		new_HookFunction = function( ... )
			if addon_hooks_lag_finder.RunningTest then
				return new_HookFunction2( ... )
			else
				return HookFunction( ... )
			end
		end
	else
		new_HookFunction = HookFunction
	end
	return addon_hooks_lag_finder.timer_Create( EventName, delay, repetitions, new_HookFunction, ... )
end
function addon_hooks_lag_finder.AdjustModifiedTimerSimple( delay, HookFunction, ... )
	local new_HookFunction
	if isfunction( HookFunction ) then
		local new_HookFunction2 = GetModifiedHookFunction(
			'Timer timer.Simple( '..tostring( delay )..', '..tostring( HookFunction )..' )',
			HookFunction
		)
		new_HookFunction = function( ... )
			if addon_hooks_lag_finder.RunningTest then
				return new_HookFunction2( ... )
			else
				return HookFunction( ... )
			end
		end
	else
		new_HookFunction = HookFunction
	end
	return addon_hooks_lag_finder.timer_Simple( delay, new_HookFunction, ... )
end
-- Modify timer.Adjust():
if !addon_hooks_lag_finder.timer_Adjust then
	addon_hooks_lag_finder.timer_Adjust = timer.Adjust
	timer.Adjust = function( EventName, delay, repetitions, HookFunction, ... )
		return addon_hooks_lag_finder.AdjustModifiedTimer( EventName, delay, repetitions, HookFunction, ... )
	end
end
-- Modify timer.Create():
if !addon_hooks_lag_finder.timer_Create then
	addon_hooks_lag_finder.timer_Create = timer.Create
	timer.Create = function( EventName, delay, repetitions, HookFunction, ... )
		return addon_hooks_lag_finder.AddModifiedTimer( EventName, delay, repetitions, HookFunction, ... )
	end
end
-- Modify timer.Simple():
if !addon_hooks_lag_finder.timer_Simple then
	addon_hooks_lag_finder.timer_Simple = timer.Simple
	timer.Simple = function( delay, HookFunction, ... )
		return addon_hooks_lag_finder.AdjustModifiedTimerSimple( delay, HookFunction, ... )
	end
end
-- Run or stop the test:
function find_laggy_hooks( ply, cmd, args, fullstring )
	if CLIENT or !IsValid( ply ) or ply:IsSuperAdmin() then
		local ReportInterval = tonumber( args[1] ) or 30
		if !ReportInterval then
			NiceMsgN( ply, " - "..helpstr )
			return
		end
		if addon_hooks_conflict_finder and addon_hooks_conflict_finder.FillAddonsList then
			if !addon_hooks_conflict_finder.AddonsList then
				addon_hooks_conflict_finder.FillAddonsList()
			end
		end
		local IsRunning = addon_hooks_lag_finder.RunningTest
		local HookTable = hook.GetTable() -- This may be a copy!
		local NetTable = net.Receivers
		local UsermessageTable = usermessage and usermessage.GetTable() or {}
		local ENTTable = scripted_ents.GetList()
		local SWEPTable = weapons.GetList()
		if ReportInterval>0 then -- begin operation
			if !IsRunning then
				if IsValid( ply ) then
					SendToSuperAdmins = true
				else
					SendToSuperAdmins = false
				end
				-- Modify hook.Add():
				if !addon_hooks_lag_finder.hook_Add then
					addon_hooks_lag_finder.hook_Add = hook.Add
					hook.Add = function( EventName, HookName, HookFunction, ... )
						if addon_hooks_lag_finder.RunningTest and HookName!="find_laggy_hooks" then
							return addon_hooks_lag_finder.AddModifiedHook( EventName, HookName, HookFunction, ... )
						else
							return addon_hooks_lag_finder.hook_Add( EventName, HookName, HookFunction, ... )
						end
					end
				end
				-- Modify net.Receive():
				if !addon_hooks_lag_finder.net_Receive then
					addon_hooks_lag_finder.net_Receive = net.Receive
					net.Receive = function( EventName, HookFunction, ... )
						if addon_hooks_lag_finder.RunningTest and EventName!="find_laggy_hooks" then
							return addon_hooks_lag_finder.AddModifiedNet( EventName, HookFunction, ... )
						else
							return addon_hooks_lag_finder.net_Receive( EventName, HookFunction, ... )
						end
					end
				end
				-- Modify usermessage.Hook():
				if !addon_hooks_lag_finder.usermessage_Hook then
					if usermessage then
						addon_hooks_lag_finder.usermessage_Hook = usermessage.Hook
						usermessage.Hook = function( EventName, HookFunction, ... )
							if addon_hooks_lag_finder.RunningTest and EventName!="find_laggy_hooks" then
								return addon_hooks_lag_finder.AddModifiedUsermessage( EventName, HookFunction, ... )
							else
								return addon_hooks_lag_finder.usermessage_Hook( EventName, HookFunction, ... )
							end
						end
					end
				end
				-- Mark test as running:
				addon_hooks_lag_finder.ReportedTimings = {}
				addon_hooks_lag_finder.RunningFunctions = {}
				addon_hooks_lag_finder.PeriodStart = SysTime()
				addon_hooks_lag_finder.PeriodEnd = addon_hooks_lag_finder.PeriodStart+ReportInterval
				addon_hooks_lag_finder.NumFrames = 0
				addon_hooks_lag_finder.TopCountOrRatioThreshold = tonumber( args[2] ) or 16
				addon_hooks_lag_finder.ReportInterval = ReportInterval
				addon_hooks_lag_finder.RunningTest = true
				-- Add hooks:
				CancelTests.hook={}
				do
					local TempHookTable = {} -- Copy: ensure that pairs() is safe while modifying table.
					for EventName,EventFunctions in pairs( HookTable ) do
						TempHookTable[EventName]={}
						for HookName,HookFunction in pairs( EventFunctions ) do
							TempHookTable[EventName][HookName]=HookFunction
						end
					end
					for EventName,EventFunctions in pairs( TempHookTable ) do
						for HookName,HookFunction in pairs( EventFunctions ) do
							pcall( addon_hooks_lag_finder.AddModifiedHook, EventName, HookName, HookFunction )
						end
					end
				end
				-- Add net receivers:
				CancelTests.net={}
				do
					local TempNetTable = {} -- Copy: ensure that pairs() is safe while modifying table.
					for EventName,HookFunction in pairs( NetTable ) do
						TempNetTable[EventName]=HookFunction
					end
					for EventName,HookFunction in pairs( TempNetTable ) do
						pcall( addon_hooks_lag_finder.AddModifiedNet, EventName, HookFunction )
					end
				end
				-- Add usermessage receivers:
				CancelTests.usermessage={}
				do
					local TempUsermessageTable = {} -- Copy: ensure that pairs() is safe while modifying table.
					for EventName,HookData in pairs( UsermessageTable ) do
						TempUsermessageTable[EventName]=HookData
					end
					for EventName,HookData in pairs( TempUsermessageTable ) do
						pcall( addon_hooks_lag_finder.AddModifiedUsermessage, EventName, HookData.Function, unpack( HookData.PreArgs ) )
					end
				end
				-- Add ENT functions:
				CancelTests.ENT={}
				do
					local TempENTTable = {} -- Copy: ensure that pairs() is safe while modifying table.
					for class,ClassTable in pairs( ENTTable ) do
						TempENTTable[class]={}
						for EventName,HookFunction in pairs( ClassTable.t ) do
							if isfunction( HookFunction ) then
								TempENTTable[class][EventName]=HookFunction
							end
						end
					end
					for class,ClassFunctions in pairs( TempENTTable ) do
						CancelTests.ENT[class] = {}
						local ENT = scripted_ents.GetStored( class ).t
						for EventName,HookFunction in pairs( ClassFunctions ) do
							local new_HookFunction = GetModifiedHookFunction(
								'Entity "'..tostring( class )..'", function ENT.'..tostring( EventName ),
								HookFunction
							)
							CancelTests.ENT[class][EventName] = HookFunction
							ENT[EventName] = new_HookFunction
						end
						pcall( scripted_ents.Register, ENT, class ) -- should not be required
					end
				end
				-- Add SWEP functions:
				CancelTests.SWEP={}
				do
					local TempSWEPTable = {} -- Copy: ensure that pairs() is safe while modifying table.
					for _,SWEP in pairs( SWEPTable ) do
						local class = SWEP.ClassName
						if class then
							TempSWEPTable[class]={}
							for EventName,HookFunction in pairs( SWEP ) do
								if isfunction( HookFunction ) then
									TempSWEPTable[class][EventName]=HookFunction
								end
							end
						end
					end
					for class,ClassFunctions in pairs( TempSWEPTable ) do
						CancelTests.SWEP[class] = {}
						local SWEP = weapons.GetStored( class )
						for EventName,HookFunction in pairs( ClassFunctions ) do
							local new_HookFunction = GetModifiedHookFunction(
								'Weapon "'..tostring( class )..'", function SWEP.'..tostring( EventName ),
								HookFunction
							)
							CancelTests.SWEP[class][EventName] = HookFunction
							SWEP[EventName] = new_HookFunction
						end
						pcall( weapons.Register, SWEP, class ) -- should not be required
					end
				end
				-- Add GM functions:
				CancelTests.GM={}
				do
					local Validated={} -- Prevent endless loops.
					local TempGamemodeTable = {} -- Copy: ensure that pairs() is safe while modifying table and prevent risk of multiply modified functions.
					local GM = GAMEMODE
					while GM and !Validated[GM] do
						TempGamemodeTable[GM]={}
						for EventName,HookFunction in pairs( GM ) do
							if isfunction( HookFunction ) then
								TempGamemodeTable[GM][EventName]=HookFunction
							end
						end
						Validated[GM]=true
						GM = GM.BaseClass
					end
					for GM,GM_functions in pairs( TempGamemodeTable ) do
						CancelTests.GM[GM] = {}
						for EventName,HookFunction in pairs( GM_functions ) do
							local new_HookFunction
							if CLIENT and EventName=="RenderScene" then
								addon_hooks_lag_finder.view = {
									dopostprocess = true,
									drawhud = true,
									drawmonitors = true,
									drawviewmodel = true,
									bloomtone = true,
								}
								local function RenderScene( ... )
									local result = HookFunction( ... )
									if result then
										return result
									else
										render.RenderView( addon_hooks_lag_finder.view )
										return true
									end
								end
								new_HookFunction = GetModifiedHookFunction(
									'Default scene rendering / GM.RenderScene',
									RenderScene,
									HookFunction
								)
							else
								new_HookFunction = GetModifiedHookFunction(
									'Function GM.'..tostring( EventName ),
									HookFunction
								)
							end
							CancelTests.GM[GM][EventName] = HookFunction -- to be restored first
							GM[EventName] = new_HookFunction
						end
					end
				end
				-- Re-adjust to accurate time reference:
				addon_hooks_lag_finder.PeriodStart = SysTime()
				addon_hooks_lag_finder.PeriodEnd = addon_hooks_lag_finder.PeriodStart+ReportInterval
				NiceMsgN( ply, 'Lag test started, next output in '..ReportInterval..' seconds!' )
			else
				NiceMsgN( ply, 'Lag test is already running!' )
			end
		else -- finish operation
			-- We only browse cancel tables because they are copies!
			if IsRunning then
				-- Restore GM functions:
				if CancelTests.GM then
					local Validated={} -- Prevent endless loops.
					local GM = GAMEMODE
					while GM and !Validated[GM] do
						if CancelTests.GM[GM] then
							for EventName,HookFunction in pairs( CancelTests.GM[GM] ) do
								if isfunction( GM[EventName] ) then
									GM[EventName]=HookFunction
								end
							end
						end
						CancelTests.GM[GM]=nil
						Validated[GM]=true
						GM = GM.BaseClass
					end
					CancelTests.GM=nil
				end
				-- Restore ENT functions:
				if CancelTests.ENT then
					for class,ClassFunctions in pairs( CancelTests.ENT ) do
						local ENT = scripted_ents.GetStored( class ).t
						if ENT then
							for EventName,HookFunction in pairs( ClassFunctions ) do
								if isfunction( ENT[EventName] ) then
									ENT[EventName]=HookFunction
								end
							end
							pcall( scripted_ents.Register, ENT, class ) -- should not be required
						end
					end
					CancelTests.ENT=nil
				end
				-- Restore SWEP functions:
				if CancelTests.SWEP then
					for class,ClassFunctions in pairs( CancelTests.SWEP ) do
						local SWEP = weapons.GetStored( class )
						if SWEP then
							for EventName,HookFunction in pairs( ClassFunctions ) do
								if isfunction( SWEP[EventName] ) then
									SWEP[EventName]=HookFunction
								end
							end
							pcall( scripted_ents.Register, SWEP, class ) -- should not be required
						end
					end
					CancelTests.SWEP=nil
				end
				-- Restore usermessage receivers:
				if CancelTests.usermessage then
					for EventName,HookData in pairs( CancelTests.usermessage ) do
						if istable( UsermessageTable[EventName] ) then
							addon_hooks_lag_finder.usermessage_Hook( EventName, HookData.Function, unpack( HookData.PreArgs ) )
						end
					end
					CancelTests.usermessage=nil
				end
				-- Restore net receivers:
				if CancelTests.net then
					for EventName,HookFunction in pairs( CancelTests.net ) do
						if isfunction( NetTable[EventName] ) then
							addon_hooks_lag_finder.net_Receive( EventName, HookFunction )
						end
					end
					CancelTests.net=nil
				end
				-- Restore hooks:
				if CancelTests.hook then
					for EventName,EventFunctions in pairs( CancelTests.hook ) do
						if istable( HookTable[EventName] ) then
							for HookName,HookFunction in pairs( EventFunctions ) do
								if isfunction( HookTable[EventName][HookName] ) then
									addon_hooks_lag_finder.hook_Add( EventName, HookName, HookFunction )
								end
							end
						end
					end
					CancelTests.hook=nil
				end
				-- Mark test as stopped:
				addon_hooks_lag_finder.RunningTest = false
				-- Report pending statistics:
				ReportStatistics()
				addon_hooks_lag_finder.ReportedTimings = {}
				addon_hooks_lag_finder.RunningFunctions = {}
				-- Confirm:
				NiceMsgN( ply, 'Lag test is now stopped!' )
			else
				NiceMsgN( ply, 'Lag test is not running!' )
			end
		end
	end
end
concommand.Add( concommand_name, find_laggy_hooks, nil, helpstr, 0 )
