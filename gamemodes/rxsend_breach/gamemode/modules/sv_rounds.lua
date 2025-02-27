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

local function GetTimeForSetup(n)
	return GetRoundTime() - n
end

local function GetTimeForSetup2(n)
	return GetRoundTime() - (GetRoundTime() - n)
end

function OpenSCP106Camera()
	ents.GetMapCreatedEntity(1904):Fire("use")

	timer.Simple(7.4, function()
		ents.GetMapCreatedEntity(2198):Fire("use")
	end)

end

ROUNDS = {
	normal = {
		name = "Containment Breach",
		setup = function()
			MAPBUTTONS = table.Copy(BUTTONS)
			SPAWN_SCP_RANDOM_COPY = table.Copy(SPAWN_SCP_RANDOM)
			SetupPlayers( GetRoleTable( #GetActivePlayers() ) )
			timer.Simple(3, function()
				StartSpecialRoleVote()
			end)
			--UIUSelectTargets()
			disableNTF = false
			disablesupport = false
			OpenSecDoors = nil
			SCPLockDownHasStarted = nil
			supcount = 0
			BREACH.InfectionStartedBy = NULL
			Monitors_Activated = 0
			BREACH.TempStats = {}
			MVPStats = {
				scpkill = {},
				headshot = {},
				kill = {},
				heal = {},
				damage = {},
			}
			timer.UnPause("EndRound_Timer")
			SPAWNEDPLAYERSASSUPPORT = {}
			SUPPORTTABLE = {
				["GOC"] = false,
				["FBI"] = false,
				["CHAOS"] = false,
				["NTF"] = false,
				["DZ"] = false,
				["COTSK"] = false,
			}
		end,
		init = function()
			timer.Simple(4, function()
				spawn_random_obr()
				SpawnAllItems()
			end)

			SetGlobalBool("Evacuation_HUD", false)

			BREACH.RoundPrepareTime = 62
			BREACH.DropWeaponsOnDeath = true
			BREACH.PeopleCanEscape = true
			BREACH.DissolveBodies = false
			BREACH.KillRewardMultiply = 1
			BREACH.DeathRewardMultiply = 1
			SetGlobalBool("AliveCanSeeRoundTime", false)
			SetGlobalBool("NoCutScenes", false)
			SetGlobalBool("DisableMusic", false)
			BREACH.DisableBloodPools = false
			BREACH.DisableTeamKills = false
			BREACH.DisableElo = false
			SetGlobalBool("Breach_ScoreboardForAlive", false)
		end,
		roundstart = function()
			timer.Remove("PowerfulUIUSupportDelayed")
			BREACH.PowerfulUIUSupportDelayed = false

			OpenSCPDoors()
			timer.Simple(2, function()
				if istable(MAPS_CHANGESKINPROPSTABLE) then
					for _, prop in ipairs(MAPS_CHANGESKINPROPSTABLE) do
						if IsValid(prop) then prop:SetSkin(1) end
					end
				end
			end)
			timer.Create("Security_Doors", 35, 1, function()
				sound.Play("nextoren/others/button_unlocked.wav", Vector(4761.009765625, -2765.419921875, 55))
				OpenSecDoors = true
			end)

			--[[
			if GetGlobalBool("BigRound", false) then
				timer.Create("AnnounceAboutDetonation", GetTimeForSetup(900), 1, function()
					--net.Start("ForcePlaySound")
					PlayAnnouncer("nextoren/round_sounds/main_decont/decont_15_b.mp3")
					--net.Broadcast()
					for i, v in pairs(player.GetAll()) do
						v:BrTip(0, "[RX Breach]", Color(255,0,0,200), "l:evac_15min", color_white)
					end
				end)
			end]]

			local lzlockdowntime = GetTimeForSetup(60 * 7)
			local lzlockdowntheme = GetTimeForSetup(60 * 7 + 106)
			local announcetime = GetTimeForSetup(60 * 8)
			local scp173open = GetTimeForSetup(60 * 10)

			if IsBigRound() then
				lzlockdowntime = GetTimeForSetup(60 * 10 + 30)
				lzlockdowntheme = GetTimeForSetup(60 * 11 + 106)
				announcetime = GetTimeForSetup(60 * 12)
				scp173open = GetTimeForSetup(60 * 20)
			end

			local doors173 = ents.FindInBox(Vector(6446.740723, -3533.156494, 344.553131), Vector(6061.392578, -3381.314209, 81.957375))
			for i = 1, #doors173 do
				local door = doors173[i]
				if IsValid(door) and door:GetClass() == "func_door" then
					door:Fire("lock")
				end
			end

			timer.Create("SCP173Open", scp173open, 1, function()
				local doors = ents.FindInBox(Vector(6446.740723, -3533.156494, 344.553131), Vector(6061.392578, -3381.314209, 81.957375))
				for i = 1, #doors do
					local door = doors[i]
					if IsValid(door) and door:GetClass() == "func_door" then
						door:Fire("unlock")
						door:Fire("open")
					end
				end
			end)

			BroadcastLua("timer.Create(\"LZDecont\", "..lzlockdowntime..", 1, function() end)")
			timer.Create( "LZDecont", lzlockdowntime, 1, function()
				LZLockDown()
			end )

			for _, ent in ipairs(ents.FindByClass("livetablz")) do
				if IsValid(ent) then ent:SetDecontTimer(lzlockdowntime) end
			end

			if IsBigRound() then
				timer.Create("AnnounceAboutDetonation", GetTimeForSetup(60 * 18), 1, function()
					--net.Start("ForcePlaySound")
					PlayAnnouncer("nextoren/round_sounds/main_decont/decont_15_b.mp3")
					--net.Broadcast()
					for i, v in pairs(player.GetAll()) do
						v:BrTip(0, "[RX Breach]", Color(255,0,0,200), "l:evac_15min", color_white)
					end
				end)
			end

			if IsBigRound() then
				timer.Create( "LZDecont_Anounce1", GetTimeForSetup(60 * 16), 1, function()
					--net.Start("ForcePlaySound")
					PlayAnnouncer("nextoren/round_sounds/lhz_decont/decont_5_min.ogg")
					--net.Broadcast()
					for i, v in pairs(player.GetAll()) do
						if v:GTeam() != TEAM_SPEC and v:IsLZ() then
							v:BrTip(0, "[RX Breach]", Color(255,0,0,240), "l:decont_5min", Color(255,255,255,240))
						end
					end
				end)
			end

			timer.Create( "LZDecont_Anounce2", announcetime, 1, function()
				--net.Start("ForcePlaySound")
				PlayAnnouncer("nextoren/round_sounds/lhz_decont/decont_1_min.ogg")
				--net.Broadcast()

				for i, v in pairs(player.GetAll()) do
					if v:GTeam() != TEAM_SPEC and v:IsLZ() then
						v:PlayMusic(BR_MUSIC_LIGHTZONE_DECONT)
						--v:SendLua("BREACH.Decontamination=true PickupActionSong()BREACH.Decontamination=false")
						v:BrTip(0, "[RX Breach]", Color(255,0,0,240), "l:decont_1min", Color(255,255,255,240))
					end
				end
			end)

			timer.Create("AnnounceAboutDetonation2", GetTimeForSetup(600), 1, function()
				--net.Start("ForcePlaySound")
				PlayAnnouncer("nextoren/round_sounds/main_decont/decont_10_b.mp3")
				--net.Broadcast()
				for i, v in pairs(player.GetAll()) do
					v:BrTip(0, "[RX Breach]", Color(255,0,0,200), "l:evac_10min", color_white)
				end
			end)

			timer.Create("AnnounceAboutDetonation3", GetTimeForSetup(300), 1, function()
				--net.Start("ForcePlaySound")
				PlayAnnouncer("nextoren/round_sounds/main_decont/decont_5_b.mp3")
				--net.Broadcast()
				for i, v in pairs(player.GetAll()) do
					v:BrTip(0, "[RX Breach]", Color(255,0,0,200), "l:evac_5min", color_white)
				end
			end)

			local ntfentertime = GetTimeForSetup(math.random(420, 480))

			if GetGlobalBool("BigRound", false) then
				ntfentertime = GetTimeForSetup(math.random(970, 840))
			end

			timer.Create( "NTFEnterTime", ntfentertime, 1, function()
				if !GetGlobalBool( "NukeTime", false ) then
					SupportSpawn()
				end
			end )
			if GetGlobalBool("BigRound", false) then
				timer.Create( "NTFEnterTime2", GetTimeForSetup(math.random(720, 660)), 1, function()
					if !GetGlobalBool( "NukeTime", false ) then
						SupportSpawn()
					end
				end )
			end
			if GetGlobalBool("BigRound", false) then
				timer.Create( "NTFEnterTime3", GetTimeForSetup(math.random(540, 480)), 1, function()
					if !GetGlobalBool( "NukeTime", false ) then
						SupportSpawn()
					end
				end )
			end
			--[[
			timer.Create( "PerformRandomIntercomAnnouncement", math.random(30, 70), math.random(1,2), function()
				--net.Start("ForcePlaySound")
				PlayAnnouncer("nextoren/round_sounds/intercom/"..tostring(math.random(1, 19))..".ogg")
				--net.Broadcast()
			end)]]
			local timetostart = 195 - 66
			timer.Create( "Evacuation", GetTimeForSetup(195), 1, function()
				Evacuation()
			end )
			timer.Create( "EvacuationWarhead", GetTimeForSetup(timetostart), 1, function()
				EvacuationWarhead()
			end )
			local r_time = 145
			if GetGlobalBool("BigRound", false) then
				r_time = GetTimeForSetup(60 * 18)
			else
				r_time = GetTimeForSetup(620)
			end

			timer.Create("FullContainmentOutBreak", r_time, 1, function()
				SCPLockDownHasStarted = true

				local doors682 = ents.FindInBox(Vector(2570.000000, 3006.000000, -334.000000), Vector(2570.000000, 3100.000000, -331.250000))
				for i = 1, #doors682 do
					local door = doors682[i]
					if IsValid(door) and door:GetClass() == "func_door" then
						door:Fire("open")
					end
				end

				--ents.GetMapCreatedEntity(4974):Fire('open')

				--OpenSCP106Camera()

				for i, v in pairs(player.GetAll()) do
					if !v.GTeam or v:GTeam() != TEAM_SCP then continue end
					if v.GetRoleName and v:GetRoleName() == "SCP062DE" and #v:GetWeapons() == 0 then
						v:BreachGive("cw_kk_ins2_doi_k98k")
						break
					end
				end
				for i, v in pairs(ents.FindByModel("models/noundation/doors/860_door.mdl")) do v:Fire("use") end
				for i, v in pairs(ents.FindInBox(Vector(2679.069336, 1976.072876, 368.106079), Vector(2333.408691, 1436.376221, -17.681280))) do
					if IsValid(v) and v:GetClass() == "func_door" then
						v:Fire("Unlock")
						v:Fire("Open")
					end
				end
				for i, v in pairs(ents.FindByName('scp_door_new_*')) do v:Fire('Unlock') v:Fire('open') end
				for i, v in pairs(BUTTONS) do
					if v.LockDownOpen == true then
						for _, door in pairs(ents.FindInSphere(v.pos, 40)) do
							if IsValid(door) and door:GetClass() == "func_door" then
								door:Fire( "Unlock" )
								door:Fire( "Open" )
							end
						end
					end
				end
				for _, door049 in pairs(ents.FindInSphere(Vector(7565.8999023438, -272.04998779297, 55.389999389648), 10)) do
					if IsValid(door049) and door049:GetClass() == "prop_dynamic" then door049:Remove() end
				end
			end)
		end,
		postround = function()
			makeMVPScore()

		end,
		endcheck = function()
			if #GetActivePlayers() < 2 then return end	
			endround = false
			local ds = gteams.NumPlayers(TEAM_CLASSD)
			local mtfs = gteams.NumPlayers(TEAM_GUARD)
			local res = gteams.NumPlayers(TEAM_SCI)
			local scps = gteams.NumPlayers(TEAM_SCP)
			local chaos = gteams.NumPlayers(TEAM_CHAOS)
			local all = #GetAlivePlayers()		
			why = "idk man"
			--[[
			if scps == all then
				endround = true
				why = "there are only scps"
			elseif mtfs == all then
				endround = true
				why = "there are only mtfs"
			elseif res == all then
				endround = true
				why = "there are only researchers"
			elseif ds == all then
				endround = true
				why = "there are only class ds"
			elseif chaos == all then
				endround = true
				why = "there are only chaos insurgency members"
			elseif (mtfs + res) == all then
				endround = true
				why = "there are only mtfs and researchers"
			elseif (chaos + ds) == all then
				endround = true
				why = "there are only chaos insurgency members and class ds"
			end]]
		end,
	}
}