-- code was kindfully provided by spac3

game.AddParticles( "particles/pfx_redux.pcf" )

PrecacheParticleSystem("[1]embers")
PrecacheParticleSystem("[7]area_of_fog")
PrecacheParticleSystem("[8]orb_1")

BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.RegisteredLogTypes = {}

BREACH.AdminLogs.LogTypeColors = {
	Color(255,0,0),
	Color(205, 74, 196),
	Color(255, 219, 156),
}

MsgC("\n\n", color_white, "/|\\ ", Color(255,0,0), "SHAKY", Color(0,255,0), " LOGS", color_white, " /|\\ \n\n")

local ADMIN_LOGS_PATH = "shlogs/"
local LOG_PATH = ADMIN_LOGS_PATH.."logtypes/"
local UI_PATH = ADMIN_LOGS_PATH.."ui/"

function BREACH.AdminLogs:ConsoleSay(...)

	local tab = {...}

	MsgC(Color(0,255,0), "| SHAKY LOGS | ", color_white, unpack(tab), "\n")

end

if SERVER then
	include("sv_logs.lua")
	AddCSLuaFile("cl_logs.lua")
	AddCSLuaFile("config.lua")
else
	include("cl_logs.lua")
end

BREACH.AdminLogs.config = include("config.lua")

if SERVER and BREACH.AdminLogs.config.Admin19_OnlineLogs_ServerBlacklist[game.GetIPAddress()] then BREACH.AdminLogs.config.Admin19_OnlineLogs = false end

BREACH.AdminLogs.LogTypes = BREACH.AdminLogs.LogTypes || {}

ShLog_FILTERTYPE_PLAYER = 0
ShLog_FILTERTYPE_TEXT = 1
ShLog_FILTERTYPE_TABLESTRING = 2

function BREACH.AdminLogs:RegisterLogClass(class)

	BREACH.AdminLogs:ConsoleSay("Registering Log Module: "..class)

	if SERVER then
		AddCSLuaFile("LogTypes/"..class..".lua")
	end

	BREACH.AdminLogs.RegisteredLogTypes[class] = include("LogTypes/"..class..".lua")
	BREACH.AdminLogs.RegisteredLogTypes[class].class = class

end

function BREACH.AdminLogs:HaveAccess(ply)

	if ply:IsAdmin() then return true end

	return false

end

function BREACH.AdminLogs:GetBodygroupString(ent)

	local str = ""

	for i = 0, ent:GetNumBodyGroups() do
		str = str..tostring(ent:GetBodygroup(i))
	end

	return str

end

function BREACH.AdminLogs:GetBonemergeList(ent)

	local tab = {}

	for _, v in pairs(ent:LookupBonemerges()) do
		if IsValid(v) and !v:GetNoDraw() then
			table.insert(tab, v:GetModel())
		end
	end

	return tab

end

function BREACH.AdminLogs:LoadUIModules()

	if CLIENT then
		MsgC("\n", Color(255,0,255), "||| ", Color(255,0,0), "LOADING UI", Color(255,0,255), " |||\n\n")
	else
		MsgC("\n", Color(255,0,255), "||| ", Color(255,0,0), "MOUNTING UI", Color(255,0,255), " |||\n\n")
	end

	local files, _ = file.Find( UI_PATH.."*", "LUA" )

	for _, lua in pairs(files) do

		if SERVER then
			AddCSLuaFile("ui/"..lua)
			self:ConsoleSay("Mounting "..lua)
		else
			include("ui/"..lua)
			self:ConsoleSay("Executing "..lua)
		end

	end

	MsgC("\n", Color(255,0,255), "||| ", Color(255,0,0), "FINISH UI", Color(255,0,255), " |||\n\n\n")

end

function BREACH.AdminLogs:GetLogTypeModule(type)

	return self.RegisteredLogTypes[type]

end

function BREACH.AdminLogs:PrepareLogTypes()

	local files, _ = file.Find( LOG_PATH.."*", "LUA" )

	MsgC("\n", Color(255,0,255), "||| ", Color(255,255,0), "REGISTERING LOG TYPES", Color(255,0,255), " |||\n\n")

	for _, class in pairs(files) do

		self:RegisterLogClass(string.StripExtension(class))

	end

	MsgC("\n", Color(255,0,255), "||| ", Color(255,255,0), "FINISH REGISTERING LOG TYPES", Color(255,0,255), " |||\n\n\n")

end

BREACH.AdminLogs:LoadUIModules()
BREACH.AdminLogs:PrepareLogTypes()