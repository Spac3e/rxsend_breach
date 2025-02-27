function GM:PlayerNoClip()
    return false
end

MODULES_PATH = GM.FolderName .. "/gamemode/modules"
LANGUAGES_PATH = GM.FolderName .. "/gamemode/languages"
MAP_CONFIG_PATH = GM.FolderName .. "/gamemode/mapconfigs"

ALLLANGUAGES = {}
WEPLANG = {}
BREACH = BREACH || {}

MsgC( Color(255,0,255), "[RXSEND Breach] Legend: ", Color(0,255,255), "Server ", Color(255,255,0), "Shared ", Color(255,100,0), "Client\n" )
Msg("======================================================================\n")

russian = russian or {} --для неготовых переводов, где есть таблица russian
nontranslated = {}

if SERVER then
	AddCSLuaFile( "modules/cl_module.lua" )
	AddCSLuaFile( "modules/sh_module.lua" )
	AddCSLuaFile( "modules/config/changelogs.lua" )
	AddCSLuaFile( "modules/config/donatelist.lua" )
	AddCSLuaFile( "modules/config/music.lua" )

	include("modules/config/music.lua")
	include( "modules/sv_module.lua" )
	include( "modules/sh_module.lua" )
else
	include( "modules/cl_module.lua" )
	include( "modules/sh_module.lua" )
end

Msg( "\n\n" )

MsgC( Color(0,255,0), "----------------Loading Languages----------------\n")

local files = file.Find(LANGUAGES_PATH .. "/*.lua", "LUA" )
for k, f in pairs( files ) do
	if SERVER then
		MsgC( Color(255,255,0), "[RXSEND Breach] Loading Language: " .. f .. "\n" )
		AddCSLuaFile( LANGUAGES_PATH.."/"..f )
		include( LANGUAGES_PATH.."/"..f )
	else
		MsgC( Color(255,255,0), "[RXSEND Breach] Loading Language: " .. f .. "\n" )
		include( LANGUAGES_PATH.."/"..f )
		if string.sub( f, 1, 3 ) != "wep" then
			--MsgC( Color(255,255,0), "[RXSEND Breach] Loading Language: " .. f .. "\n" )
		end
	end
end

MsgC( Color(255,255,0), "[RXSEND Breach] Comparing languages: \n" )

function BREACH.CompareLanguage(lang)
	local no_translations = {}
	for k, v in pairs(russian) do
		local found = false
		for _, ass in pairs(lang) do
			if _ == k then
				found = true
			end
		end
		if !found then
			no_translations[k] = v
		end
	end

	return no_translations
end

local function AutoComplete(cmd, stringargs)
	local tbl = {}
    for k, v in pairs(ALLLANGUAGES) do
    	table.insert(tbl, "breach_compare_language "..tostring(k))
    end
    return tbl
end

concommand.Add("breach_compare_language",
	function(ply, cmd, args, argstr)
		if !ALLLANGUAGES[args[1]] then
			print("language not found: "..args[1])
			return
		end
		local tbl = BREACH.CompareLanguage(ALLLANGUAGES[args[1]])
		if #table.GetKeys(tbl) > 0 then
			PrintTable(tbl)
			print("found "..#table.GetKeys(tbl).." missing phrases")
		else
			print("language is up to date")
		end
	end,
AutoComplete)

local obsolete_found = false
for k, v in pairs(ALLLANGUAGES) do
	local tbl = BREACH.CompareLanguage(v)

	if #table.GetKeys(tbl) > 0 then
		MsgC( Color(255,0,0), "[RXSEND Breach] Language "..tostring(k).." is obsolete. Found "..#table.GetKeys(tbl).." missing phrases\n" )
		obsolete_found = true
	else
		MsgC( Color(0,255,0), "[RXSEND Breach] Language "..tostring(k).." is up to date\n" )
	end
end

if obsolete_found then
	MsgC( Color(255,255,0), "[RXSEND Breach] Use command breach_compare_language (language) to get missing phrases\n" )
else
	MsgC( Color(0,255,0), "[RXSEND Breach] All languages are up to date\n" )
end

MsgC( Color(0,255,0),"----------------Loading Modules----------------\n")
local modules = file.Find( MODULES_PATH.."/*.lua", "LUA" )
local skipped = 0
for k, f in pairs( modules ) do
	if f == "sv_module.lua" or f == "sh_module.lua" or f == "cl_module.lua" then continue end

	if string.sub( f, 1, 1 ) == "_" then
		skipped = skipped + 1
		continue
	end

	if string.len( f ) > 3 then
		local ext = string.sub( f, 1, 3 )

		if ext == "cl_" then
			if SERVER then
				MsgC( Color(255,100,0), "[RXSEND Breach] Loading CLIENT file: " .. f .. "\n" )
				AddCSLuaFile( MODULES_PATH .. "/" .. f )
			else
				MsgC( Color(255,100,0), "[RXSEND Breach] Loading CLIENT file: " .. f .. "\n" )
				include( MODULES_PATH .. "/" .. f )
			end
		elseif ext == "sv_" then
			if SERVER then
				MsgC( Color(0,255,255), "[RXSEND Breach] Loading SERVER file: " .. f .. "\n" )
				include( MODULES_PATH .. "/" .. f )
			end
		elseif ext == "sh_" then
			if SERVER then
				AddCSLuaFile( MODULES_PATH .. "/" .. f )
			end
			MsgC( Color(255,255,0), "[RXSEND Breach] Loading SHARED file: " .. f .. "\n" )
			include( MODULES_PATH .. "/" .. f )
		end
	else
		skipped = skipped + 1
	end
end

MsgC( Color(0,255,0),"-----------------Loading Animation Base-----------------\n")
MODULES_PATH = GM.FolderName .. "/gamemode/modules/anim_base"
local modules = file.Find( MODULES_PATH.."/*.lua", "LUA" )
local skipped = 0
for k, f in pairs( modules ) do
	if f == "sv_module.lua" or f == "sh_module.lua" or f == "cl_module.lua" then continue end

	if string.sub( f, 1, 1 ) == "_" then
		skipped = skipped + 1
		continue
	end

	if string.len( f ) > 3 then
		local ext = string.sub( f, 1, 3 )

		if ext == "cl_" then
			if SERVER then
				MsgC( Color(255,100,0), "[RXSEND Breach] Loading CLIENT file: " .. f .. "\n" )
				AddCSLuaFile( MODULES_PATH .. "/" .. f )
			else
				MsgC( Color(255,100,0), "[RXSEND Breach] Loading CLIENT file: " .. f .. "\n" )
				include( MODULES_PATH .. "/" .. f )
			end
		elseif ext == "sv_" then
			if SERVER then
				MsgC( Color(0,255,255), "[RXSEND Breach] Loading SERVER file: " .. f .. "\n" )
				include( MODULES_PATH .. "/" .. f )
			end
		elseif ext == "sh_" then
			if SERVER then
				AddCSLuaFile( MODULES_PATH .. "/" .. f )
			end
			MsgC( Color(255,255,0), "[RXSEND Breach] Loading SHARED file: " .. f .. "\n" )
			include( MODULES_PATH .. "/" .. f )
		end
	else
		skipped = skipped + 1
	end
end

MsgC( Color(0,255,0),"-----------------Animation Base is ready!-----------------\n")

MsgC( Color(0,255,0),"#\n" )
MsgC( Color(0,255,0),"# Skipped files: " .. skipped.."\n")

MsgC( Color(0,255,0),"---------------Loading Map Config----------------\n" )
if file.Exists( MAP_CONFIG_PATH .. "/" .. game.GetMap() .. ".lua", "LUA" ) then
	local relpath = "mapconfigs/" .. game.GetMap() .. ".lua"
	if SERVER then
		AddCSLuaFile( relpath )
	end
	include( relpath )
	MsgC( Color(0,255,0), "# Loading config for map " .. game.GetMap().."\n" )
	MAP_LOADED = true
else
	MsgC( Color(0,255,0), "----------------Loading Complete-----------------\n" )
	error( "Unsupported map " .. game.GetMap() .. "!" )
end

MsgC( Color(0,255,0), "----------------Loading Complete-----------------\n" )