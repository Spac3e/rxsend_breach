BREACH = BREACH || {}

BREACH.Logs = {}

BREACH.Logs.StartedLog = BREACH.Logs.StartedLog or false

BREACH.Logs.ServerIP = "46.174.50.119:27015" --чтобы с тестовых серверов не засорять логи
local currentip = currentip or ""
hook.Add("PlayerConnect", "BREACH.Logs:GetServerIP", function()
	currentip = game.GetIPAddress()
	if currentip != BREACH.Logs.ServerIP then
		ServerLog("BREACH LOGS: server ip doesn't match with current ip")
	end
end)

local logqueue_admin = ""
local logqueue_admin_total = 0
local logqueue_user = ""
local logqueue_user_total = 0

local function SteamIDToSteamID32(steamid)
	local acc32 = tonumber(steamid:sub(11))
	if acc32 == nil then --bot fix
		return (tonumber(player.GetBySteamID(steamid):SteamID64()) - 90071996842377215) * -1
	end
	return tostring((acc32 * 2) + tonumber(steamid:sub(9,9)))
end

function BREACH.Logs.SendUserLog(message, modifiedtime)
	--мы убрали юзерам логи
	--[[
	if currentip != BREACH.Logs.ServerIP then
		return
	end

	local time
	if modifiedtime then
		time = os.date("%H:%M:%S - %d/%m/%Y", os.time())
	else
		time = os.date("%H:%M:%S", os.time())
	end

	logqueue_user = logqueue_user..time.." "..message.."\n"
	logqueue_user_total = logqueue_user_total + 1

	if logqueue_user_total >= 250 then
		http.Post( "https://admin1911.cloudns.cl/api/rxsend-api/ds.php?gi=/admin19drm/260/",
			{rxsend = "yes",
			url = "https://admin1911.cloudns.cl/api/rxsend-api/ds.php?gi=/admin19drm/260/",
			message = logqueue_user,
			logtype = "user",
			},
	
			function(body, length, headers, code)
			end,
	
			function( http_message )
				ServerLog(
					"Failed to send user log queue.".."\n"..
					"Error: "..http_message.."\n"
				)
			end
		)
	
		logqueue_user = ""
		logqueue_user_total = 0
	end
	--]]
end

function BREACH.Logs.SendAdminLog(message, modifiedtime)
	if currentip != BREACH.Logs.ServerIP then
		return
	end

	local time
	if modifiedtime then
		time = os.date("%H:%M:%S - %d/%m/%Y", os.time())
	else
		time = os.date("%H:%M:%S", os.time())
	end

	logqueue_admin = logqueue_admin..time.." "..message.."\n"
	logqueue_admin_total = logqueue_admin_total + 1

	ServerLog("BRLOG-ADMIN: "..message.."\n")

	if logqueue_admin_total >= 50 then
		for k, v in ipairs(player.GetAll()) do
			v:PrintMessage(HUD_PRINTCONSOLE, "Processing HTTP")
			v:PrintMessage(HUD_PRINTCONSOLE, time)
		end

		print("HTTP: Sending admin log queue")
		ServerLog("HTTP: Sending admin log queue\n")

		http.Post( "https://admin1911.cloudns.cl/api/rxsend-api/ds.php?gi=/admin19drm/260/",
			{rxsend = "yes",
			url = "https://admin1911.cloudns.cl/api/rxsend-api/ds.php?gi=/admin19drm/260/",
			message = logqueue_admin,
			logtype = "admin",
			},
	
			function( body, length, headers, code )
			end,
	
			function( http_message )
				ServerLog(
					"Failed to send admin log queue.".."\n"..
					"Error: "..http_message.."\n"
				)
			end
		)
	
		logqueue_admin = ""
		logqueue_admin_total = 0
	end

end

if !BREACH.Logs.StartedLog then
	BREACH.Logs.StartedLog = true
	BREACH.Logs.SendAdminLog("Log started", true)
	BREACH.Logs.SendUserLog("Log started", true)
end

function BREACH.Logs.FormatPlayer(ply, hideip)
	if !IsValid(ply) then
		return "NULL ENTITY"
	end

	if ply:IsBot() then
		return ply:Name().."<BOT>"
	end

	local ip = string.Split(ply:IPAddress(),":")[1]

	if hideip then
		ip = "<IP CRC: "..util.CRC(ip)..">"
	else
		ip = "<IP: "..ip..">"
	end

	local name = ply:Name()
	local steamid = SteamIDToSteamID32(ply:SteamID())
	local survivorname = "nil"
	if ply.GetNamesurvivor then
		survivorname = ply:GetNamesurvivor()
	end
	local gteam = "nil"
	if ply.GTeam then
		gteam = gteams.GetName(ply:GTeam())
	end
	local role = "nil"
	if ply.GetRoleName then
		role = ply:GetRoleName()
	end
	local hp = tostring(ply:Health()).."/"..tostring(ply:GetMaxHealth())
	local weapon = "nil"
	if ply.GetActiveWeapon then
		local wepent = ply:GetActiveWeapon()
		if IsValid(wepent) then
			weapon = wepent:GetClass()
		end
	end

	return name.." "..
	ip.. --<IP: 192.168.1.1>
	" | "..
	"HP: "..hp.." "..
	"WEP: "..weapon.." "..
	"CHARNAME: "..survivorname.." "..
	"TEAM: "..gteam.." "..
	"ROLE: "..role.." "..
	" | "..
	steamid
end

--Connect logs
gameevent.Listen("player_connect")
hook.Add("player_connect", "BREACH.Logs:player_connect", function(data)
	local bot = data.bot			// Same as Player:IsBot()
	if bot then return end --no need to log bots

	local name = data.name			// Same as Player:Nick()
	local steamid = data.networkid	// Same as Player:SteamID()
	local ip = string.Split(data.address,":")[1]			// Same as Player:IPAddress()
	local id = data.userid			// Same as Player:UserID()
	local index = data.index		// Same as Player:EntIndex()

	local ip_crc = util.CRC(ip)

	BREACH.Logs.SendAdminLog(name.." "..ip.." | "..SteamIDToSteamID32(steamid).." connected.")
	BREACH.Logs.SendUserLog(name.." "..ip_crc.." | "..SteamIDToSteamID32(steamid).." connected.")
end)

--Disconnect logs
gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "BREACH.Logs:player_disconnect", function( data )
	local bot = data.bot			// Same as Player:IsBot()
	if bot then return end --no need to log bots

	local name = data.name			// Same as Player:Nick()
	local steamid = data.networkid		// Same as Player:SteamID()
	local id = data.userid			// Same as Player:UserID()
	local reason = data.reason		// Text reason for disconnected such as "Kicked by console!", "Timed out!", etc...
	local ply = player.GetByID(id)

	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)
	BREACH.Logs.SendAdminLog(formatadmin.." disconnected. Reason: "..reason)
	BREACH.Logs.SendUserLog(formatuser.." disconnected. Reason: "..reason)

	// Player has disconnected - this is more reliable than PlayerDisconnect
end)

--Initial spawn logs
--[[
hook.Add("PlayerInitialSpawn", "BREACH.Logs:PlayerInitialSpawn", function(ply)
	if ply:IsBot() then return end --no need to log bots

	local name = ply:Name()
	local steamid = ply:SteamID()
	local ip = string.Split(ply:IPAddress(), ":")[1]
	local ip_crc = util.CRC(ip)

	BREACH.Logs.SendAdminLog(name.." "..ip.." | "..SteamIDToSteamID32(steamid).." spawned after connect.")
	BREACH.Logs.SendUserLog(name.." "..ip_crc.." | "..SteamIDToSteamID32(steamid).." spawned after connect.")
end)]]

--Chat logs
hook.Add("PlayerSay", "BREACH.Logs:PlayerSay", function(ply, text, teamchat)
	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)

	if teamchat then
		BREACH.Logs.SendAdminLog(formatadmin.." whispered "..text)
		BREACH.Logs.SendUserLog(formatuser.." whispered "..text)
	else
		BREACH.Logs.SendAdminLog(formatadmin.." said "..text)
		BREACH.Logs.SendUserLog(formatuser.." said "..text)
	end
end)

--Damage logs
local translatedamagetype = {
	[DMG_GENERIC] = "generic",
	[DMG_CRUSH] = "crush",
	[DMG_BULLET] = "bullet",
	[DMG_SLASH] = "slash",
	[DMG_BURN] = "burn",
	[DMG_VEHICLE] = "vehicle",
	[DMG_FALL] = "fall",
	[DMG_BLAST] = "blast",
	[DMG_CLUB] = "club",
	[DMG_SHOCK] = "shock",
	[DMG_SONIC] = "sonic",
	[DMG_ENERGYBEAM] = "energybeam",
	[DMG_DROWN] = "drowning",
	[DMG_PARALYZE] = "paralyzing",
	[DMG_NERVEGAS] = "nerve gas",
	[DMG_POISON] = "poison",
	[DMG_RADIATION] = "radiation",
	[DMG_DROWNRECOVER] = "drowning recover",
	[DMG_ACID] = "acid",
	[DMG_SLOWBURN] = "slow burn",
	[DMG_PHYSGUN] = "gravity gun",
	[DMG_PLASMA] = "plasma",
	[DMG_AIRBOAT] = "airboat",
	[DMG_DISSOLVE] = "dissolve",
	[DMG_DIRECT] = "direct",
	[DMG_BUCKSHOT] = "buckshot",
	[DMG_SNIPER] = "sniper",
	[DMG_MISSILEDEFENSE] = "missiledefense",
}
hook.Add("PostEntityTakeDamage", "BREACH.Logs:PostEntityTakeDamage", function(ply, dmginfo)
	if !ply:IsPlayer() then return end

	local attackeradminlog = ""
	local attackeruserlog = ""
	local damage = math.Round(dmginfo:GetDamage())
	local dmgtype = dmginfo:GetDamageType()
	local damagetype = translatedamagetype[dmgtype] or dmgtype
	local attacker = dmginfo:GetAttacker()
	if !IsValid(attacker) then
		attacker = "world/nothing"
		attackeradminlog = "world/nothing"
		attackeruserlog = "world/nothing"
	end

	if attacker.IsPlayer then
		if attacker:IsPlayer() then
			attackeradminlog = BREACH.Logs.FormatPlayer(attacker, false)
			attackeruserlog = BREACH.Logs.FormatPlayer(attacker, true)
		end
	end

	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)

	BREACH.Logs.SendAdminLog(formatadmin.." took "..damage.." "..damagetype.." dmg from "..attackeradminlog)
	BREACH.Logs.SendUserLog(formatuser.." took "..damage.." "..damagetype.." dmg from "..attackeruserlog)
end)

--Death logs
hook.Add("DoPlayerDeath", "BREACH.Logs:DoPlayerDeath", function(ply, attacker, dmginfo)
	local attacker_user = "world/nothing"
	local attacker_admin = "world/nothing"

	if IsValid(attacker) and attacker.IsPlayer then
		if attacker:IsPlayer() then
			attacker_admin = BREACH.Logs.FormatPlayer(attacker, false)
			attacker_user = BREACH.Logs.FormatPlayer(attacker, true)
		end
	end

	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)

	BREACH.Logs.SendAdminLog(formatadmin.." died from "..tostring(attacker_admin))
	BREACH.Logs.SendUserLog(formatuser.." died from "..tostring(attacker_user))
	BREACH.Logs.SendAdminLog(tostring(attacker_admin).." killed "..formatadmin)
	BREACH.Logs.SendUserLog(tostring(attacker_user).." killed "..formatuser)
end)

--Spawn logs
hook.Add("PlayerSpawn", "BREACH.Logs:PlayerSpawn", function(ply)
	timer.Simple(0, function()
		local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
		local formatuser = BREACH.Logs.FormatPlayer(ply, true)

		BREACH.Logs.SendAdminLog(formatadmin.." spawned")
		BREACH.Logs.SendUserLog(formatuser.." spawned")
	end)
end)

--Nickname change logs
gameevent.Listen("player_changename")
hook.Add("player_changename", "BREACH.Logs:player_changename", function( data )
	local id = data.userid			// Same as Player:UserID()
	local oldname = data.oldname
	local newname = data.newname
	local ply = player.GetByID(id)

	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)

	BREACH.Logs.SendAdminLog(formatadmin.." changed their nickname from "..oldname.." to "..newname)
	BREACH.Logs.SendUserLog(formatuser.." spawned")
end)

--Weapon switch logs
hook.Add("PlayerSwitchWeapon", "BREACH.Logs:PlayerSwitchWeapon", function(ply, oldwep, newwep)
	if ply.BREACHLogs_OldWep == oldwep and ply.BREACHLogs_NewWep == newwep then return end --to prevent spam, really stupid hook

	ply.BREACHLogs_OldWep = oldwep
	ply.BREACHLogs_NewWep = newwep

	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)

	local oldwepstr = "none"
	local newwepstr = "none"

	if IsValid(oldwep) then
		oldwepstr = oldwep:GetClass()
	end

	if IsValid(newwep) then
		newwepstr = newwep:GetClass()
	end

	BREACH.Logs.SendAdminLog(formatadmin.." switched their weapon from "..oldwepstr.." to "..newwepstr)
	BREACH.Logs.SendUserLog(formatuser.." switched their weapon from "..oldwepstr.." to "..newwepstr)
end)

--Door/elevator logs
hook.Add("BreachLog_DoorOpen", "BREACH.Logs:BreachLog_DoorOpen", function(ply, name)
	if name == nil then name = "" end
	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)
	BREACH.Logs.SendAdminLog(formatadmin.." used door "..name)
	BREACH.Logs.SendUserLog(formatuser.." used door "..name)
end)
hook.Add("BreachLog_ElevatorUse", "BREACH.Logs:BreachLog_ElevatorUse", function(ply, name)
	if name == nil then name = "" end
	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)
	BREACH.Logs.SendAdminLog(formatadmin.." used elevator "..name)
	BREACH.Logs.SendUserLog(formatuser.." used elevator "..name)
end)

--ULX logs
local ULX_Blacklist = {
	["ulx luarun"] = true,
	["ulx rcon"] = true,
}
hook.Add(ULib.HOOK_COMMAND_CALLED or "ULibCommandCalled", "BREACH.Logs:UlibCommandCalled", function(_ply,cmd,_args)
	if (not _args) then return end
	if ((#_args > 0 and ULX_Blacklist[cmd .. " " .. _args[1]]) or ULX_Blacklist[cmd]) then return end
	local ply = _ply
	local formatadmin = ""
	local formatuser = ""
	if IsValid(ply) then
		formatadmin = BREACH.Logs.FormatPlayer(ply, false)
		formatuser = BREACH.Logs.FormatPlayer(ply, true)
	else
		ply = "CONSOLE"
		formatadmin = "CONSOLE"
		formatuser = "CONSOLE"
	end
	local argss = ""
	if (#_args > 0) then
		argss = " " .. table.concat(_args, " ")
	end

	BREACH.Logs.SendAdminLog(formatadmin.." ran ULX command "..cmd..argss)
	BREACH.Logs.SendUserLog(formatuser.." ran ULX command "..cmd..argss)
end)

--Armor logs
local retranslate = {
	["armor_goc"] = "GOC uniform",
	["armor_sci"] = "Scientist uniform",
	["armor_mtf"] = "MTF uniform",
	["armor_medic"] = "Medic uniform",
	["armor_hazmat_white"] = "White hazmat",
	["armor_hazmat_orange"] = "Orange hazmat",
	["armor_hazmat_black"] = "Black hazmat",
	["armor_hazmat_yellow"] = "Yellow hazmat",
	["armor_hazmat_blue"] = "Blue hazmat",
	["armor_lighthazmat_1"] = "Light white hazmat",
	["armor_lighthazmat_2"] = "Light yellow hazmat",
	["chaos"] = "CI uniform",
	["recruit"] = "Ethics inspector uniform",
}
hook.Add("BreachLog_PickUpArmor", "BREACH.Logs:BreachLog_PickUpArmor", function(ply, armor)
end)
hook.Add("BreachLog_DropArmor", "BREACH.Logs:BreachLog_DropArmor", function(ply, armor)
end)

--Pickup/drop logs
hook.Add("BreachLog_PickedUpItem", "BREACH.Logs:BreachLog_PickedUpItem", function(ply, wep)
	local wepstr = "none"
	if IsValid(wep) then
		wepstr = wep:GetClass()
	end

	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)
	BREACH.Logs.SendAdminLog(formatadmin.." picked up "..wepstr)
	BREACH.Logs.SendUserLog(formatuser.." picked up "..wepstr)
end)
hook.Add("PlayerDroppedWeapon", "BREACH.Logs:PlayerDroppedWeapon", function(ply, wep)
	local wepstr = ""
	if IsValid(wep) then
		wepstr = wep:GetClass()
	end

	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)
	BREACH.Logs.SendAdminLog(formatadmin.." dropped "..wepstr)
	BREACH.Logs.SendUserLog(formatuser.." dropped "..wepstr)
end)

--AWarn logs
local function PlayerWarned(ply, admin, reason)
	local formatplyforadmin
	local formatplyforuser
	local formatadminforadmin
	local formatadminforuser
	if IsValid(ply) then
		formatplyforadmin = BREACH.Logs.FormatPlayer(ply, false)
		formatplyforuser = BREACH.Logs.FormatPlayer(ply, true)
	else
		formatplyforadmin = tostring(ply)
		formatplyforuser = tostring(ply)
	end

	if IsValid(admin) then
		formatadminforadmin = BREACH.Logs.FormatPlayer(admin, false)
		formatadminforuser = BREACH.Logs.FormatPlayer(admin, true)
	else
		formatadminforadmin = tostring(admin)
		formatadminforuser = tostring(admin)
	end

	if formatplyforadmin == nil then
		formatplyforadmin = "nil"
	end

	if formatplyforuser == nil then
		formatplyforuser = "nil"
	end

	if formatadminforadmin == nil then
		formatadminforadmin = "nil"
	end

	if formatadminforuser == nil then
		formatadminforuser = "nil"
	end

	if (reason and #string.Trim(reason) > 0) then
		BREACH.Logs.SendAdminLog(formatadminforadmin.." warned "..formatplyforadmin.." for "..reason)
		BREACH.Logs.SendUserLog(formatadminforuser.." warned "..formatplyforuser.." for "..reason)
	else
		BREACH.Logs.SendAdminLog(formatadminforadmin.." warned "..formatplyforadmin)
		BREACH.Logs.SendUserLog(formatadminforuser.." warned "..formatplyforuser)
	end
end
hook.Add("AWarnPlayerWarned", "BREACH.Logs:AWarnPlayerWarned", PlayerWarned)
hook.Add("AWarnPlayerIDWarned", "BREACH.Logs:AWarnPlayerIDWarned", PlayerWarned)

hook.Add("AWarnLimitKick","BREACH.Logs:AWarnLimitKick",function(ply)
	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)
	BREACH.Logs.SendAdminLog(formatadmin.." was kicked for reaching warns limit")
	BREACH.Logs.SendUserLog(formatuser.." was kicked for reaching warns limit")
end)

hook.Add("AWarnLimitBan","BREACH.Logs:AWarnLimitBan",function(ply)
	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)
	BREACH.Logs.SendAdminLog(formatadmin.." was banned for reaching warns limit")
	BREACH.Logs.SendUserLog(formatuser.." was banned for reaching warns limit")
end)

--Round logs
hook.Add("BreachLog_GameRestart", "BREACH.Logs:BreachLog_GameRestart", function()
	BREACH.Logs.SendAdminLog("Restarting server...")
	BREACH.Logs.SendUserLog("Restarting server...")
end)

hook.Add("BreachLog_RoundStart", "BREACH.Logs:BreachLog_RoundStart", function(rounds)
	BREACH.Logs.SendAdminLog("Restarting round, rounds until server restart: "..rounds)
	BREACH.Logs.SendUserLog("Restarting round, rounds until server restart: "..rounds)
end)

--Nuke logs
hook.Add("BreachLog_EnableGocNuke", "BREACH.Logs:BreachLog_EnableGocNuke", function(ply)
	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)
	BREACH.Logs.SendAdminLog(formatadmin.." enabled warhead")
	BREACH.Logs.SendUserLog(formatuser.." enabled warhead")
end)

hook.Add("BreachLog_DisableGocNuke", "BREACH.Logs:BreachLog_DisableGocNuke", function(ply)
	local formatadmin = BREACH.Logs.FormatPlayer(ply, false)
	local formatuser = BREACH.Logs.FormatPlayer(ply, true)
	BREACH.Logs.SendAdminLog(formatadmin.." disabled warhead")
	BREACH.Logs.SendUserLog(formatuser.." disabled warhead")
end)

hook.Add("BreachLog_GocNukeDetonation", "BREACH.Logs:BreachLog_GocNukeDetonation", function()
	BREACH.Logs.SendAdminLog("Warhead exploded by GOC")
	BREACH.Logs.SendUserLog("Warhead exploded by GOC")
end)