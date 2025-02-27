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
// Serverside file for all player related functions

function CheckIfPlayersStillEnough()
	if #GetActivePlayers() < MINPLAYERS and GetGlobalBool("EnoughPlayersCountDown") then
		for i, v in pairs(GetActivePlayers()) do
			v:RXSENDNotify("l:not_enough_players")
		end
		BroadcastStopMusic()
		SetGlobalBool("EnoughPlayersCountDown", false)
		timer.Remove("StartRoundBecauseMinPlr")
		waitingplayers = false
		players_warned = false
	elseif #GetActivePlayers() >= MINPLAYERS and !GetGlobalBool("EnoughPlayersCountDown") and !gamestarted then
		waitingplayers = false
		CheckStart()
	end
end
timer.Create("ENOUGH_PLAYERCHECK", 1, 0, CheckIfPlayersStillEnough)

function CheckStart()
	MINPLAYERS = GetConVar("br_min_players"):GetInt()
	if gamestarted == false and #GetActivePlayers() >= MINPLAYERS then
	
		if !players_warned then
			for k, v in ipairs(player.GetAll()) do
				v:RXSENDNotify("l:game_will_start_soon")
			end
			BroadcastPlayMusic(BR_MUSIC_COUNTDOWN)
		end

		players_warned = true

		if !waitingplayers then
			waitingplayers = true
			SetGlobalBool("EnoughPlayersCountDown", true)
			SetGlobalInt("EnoughPlayersCountDownStart", CurTime() + 119)
			timer.Create("StartRoundBecauseMinPlr", 119, 1, function()
				if gamestarted == false and #GetActivePlayers() >= MINPLAYERS then
					waitingplayers = false
					players_warned = false
					RoundRestart()
				elseif #GetActivePlayers() <= MINPLAYERS then
					waitingplayers = false
					players_warned = false
					for k, v in ipairs(player.GetAll()) do
						v:RXSENDNotify("l:not_enough_players_for_round_start")
					end
				end
			end)
		end

	end
	if gamestarted then
		BroadcastLua( 'gamestarted = true' )
	end
end

function GM:PlayerInitialSpawn( ply )

	print("starting to spawn "..ply:Name())

	ply:SetCanZoom( false )
	ply:SetNoDraw(true)
	ply.freshspawn = true
	ply.isblinking = false
	player_manager.SetPlayerClass( ply, "class_breach" )
	player_manager.RunClass( ply, "SetupDataTables" )

	CheckStart()

	timer.Simple(10, function()
		if timer.Exists( "RoundTime" ) == true then
			net.Start("UpdateTime")
				net.WriteString(tostring(timer.TimeLeft( "RoundTime" )))
			net.Send(ply)
		end
		if gamestarted then
			ply:SendLua( 'gamestarted = true' )
		end
		ply:SetSpectator()
	end)
end

function GM:PlayerSpawn( ply )

	ply:SetCanZoom( false )
	ply:SetTeam(2)
	ply:SetNoCollideWithTeammates(false)

	if ply.freshspawn then
		ply:SetSpectator()
		ply:SetPos(table.Random(BREACH.MainMenu_Spawns)[1])
		ply.freshspawn = false
	end

	ply.JustSpawned = true
	ply.JustSpawned = false

end


function GM:PlayerNoClip( ply, desiredState )
	if ply:GTeam() == TEAM_SPEC and desiredState == true then return true end
end

function GM:PlayerDisconnected( ply )
	 ply:SetTeam(TEAM_SPEC)
	 if #player.GetAll() < MINPLAYERS then
		BroadcastLua('gamestarted = false')
		gamestarted = false
	 end
	 WinCheck()
end


function HaveRadio(pl1, pl2)
	if pl1:HasWeapon("item_radio") then
		if pl2:HasWeapon("item_radio") then
			local r1 = pl1:GetWeapon("item_radio")
			local r2 = pl2:GetWeapon("item_radio")
			if !IsValid(r1) or !IsValid(r2) or pl2:GetActiveWeapon() != r1 then return false end
			if r1.Enabled == true then
				if r2.Enabled == true then
					if r1.Channel == r2.Channel then
						return true
					end
				end
			end
		end
	end
	return false
end

local CanTalkToOtherPlayersSCP = {
	["SCP049"] = true,
	["SCP076"] = true
}

local roomTrResult = {}
local roomTr = {output = roomTrResult}
local function IsInRoom(listenerShootPos, talkerShootPos, talker)
    roomTr.start = talkerShootPos
    roomTr.endpos = listenerShootPos
    -- Listener needs not be ignored as that's the end of the trace
    roomTr.filter = talker
    roomTr.collisiongroup = COLLISION_GROUP_WORLD
    roomTr.mask = MASK_SOLID_BRUSHONLY
    util.TraceLine(roomTr)

    return not roomTrResult.HitWorld
end

local _CanHear = {}
local _CanHear3D = {}

-- Recreate DrpCanHear after Lua Refresh
-- This prevents an indexing nil error in PlayerCanHearPlayersVoice
for _, ply in pairs(player.GetAll()) do
    _CanHear[ply] = {}
    _CanHear3D[ply] = {}
end

hook.Add("PlayerInitialSpawn", "HearCheck_Spawn", function(ply)
	_CanHear[ply] = {}
	_CanHear3D[ply] = {}
end)

local function hearcheck_function(Listener, Speaker)
	local table_listener = Listener:GetTable()
	local table_speaker = Speaker:GetTable()

	if !table_speaker.GetRoleName then
		player_manager.SetPlayerClass( Speaker, "class_breach" )
		player_manager.RunClass( Speaker, "SetupDataTables" )
	end

	if !table_listener.GetRoleName then
		player_manager.SetPlayerClass( Listener, "class_breach" )
		player_manager.RunClass( Listener, "SetupDataTables" )
	end

	local t_h = Speaker:Health()
	local t_g = BREACH.Punishment.Gags[Speaker:SteamID()]
	local t_t = Speaker:GTeam()
	local l_t = Listener:GTeam()
	local l_r = Listener:GetRoleName()
	--local l_h = Listener:Health() --not used
	local t_a = t_h > 0 --ALIVE is slow!!!!
	--local l_a = Listener:Alive() --not used
	local t_r = Speaker:GetRoleName()
	local dist = Speaker:GetPos():DistToSqr(Listener:GetPos())
	local l_spectator = l_t == TEAM_SPEC
	local t_spectator = t_t == TEAM_SPEC

	if t_t == TEAM_SCP and Speaker:GetInDimension() and dist < 562500 then
		return true, true
	end

	if !table_listener.hasloadedalready then
		return false
	end

	if table_speaker.canttalk then
		return false
	end

	table_speaker.proverilsluh = SysTime()

	if l_spectator then
		if table_listener.mutespec and t_spectator then return false end
		if table_listener.mutealive and !t_spectator then return false end
	end

	if t_g then
		return false
	end

	if t_spectator then
		if l_spectator then
			return true
		else
			return false
		end
	end

	if Speaker:IsFrozen() then
		return false
	end

	--if table_speaker.IntercomTalk and t_a then
		--return true
	--end

	if table_listener.CameraLook and Listener:GetViewEntity():GetPos():DistToSqr(Speaker:GetPos()) < 562500 and t_t != TEAM_SPEC and t_t != TEAM_SCP then
		return true, true
	end

	if t_a == false then
		return false
	end

	if t_t == TEAM_SCP and !CanTalkToOtherPlayersSCP[t_r] then

		if l_t == TEAM_SCP then
			return true

		elseif l_t == TEAM_SPEC or l_t == TEAM_DZ or ( t_r == "SCP939" and !SCPFOOTSTEP["SCP939"] ) or Speaker.SCP035_IsWear then
			if dist < 562500 then
				return true, true
			else
				return false
			end

		else
			return false
		end
	end

	if CanTalkToOtherPlayersSCP[t_r] and l_t == TEAM_SCP then
		return true
	end

	local hasIntercom
	for _, ic in pairs(ents.FindByClass("object_intercom")) do

		if ic:GetPos():DistToSqr(Speaker:GetPos()) > 16384 or ic:GetStatus() != "Transmitting" then continue end
		hasIntercom = true
		break

	end
	--print(#hasIntercom)

	if dist < 562500 or hasIntercom then
		return true, !hasIntercom --true
	else
		return false
	end
end

BREACH.voiceCheckTimeDelay = 1

timer.Create("HearCheck", BREACH.voiceCheckTimeDelay, 0, function()
    local players = player.GetAll()


	for i=1, #players do
		local talker = players[i]
		_CanHear[talker] = {}
		_CanHear3D[talker] = {}

		for num=1, #players do
			local listener = players[num]

			local shouldhear = false
			local proximitive_sound = false

			shouldhear, proximitive_sound = hearcheck_function(listener, talker)

			_CanHear[talker][listener] = shouldhear
			_CanHear3D[talker][listener] = proximitive_sound
		end
	end
end)

hook.Add("PlayerDisconnect", "Breach:_CanHear", function(ply)
    _CanHear[ply] = nil
    _CanHear3D[ply] = nil
end)

function GM:PlayerCanHearPlayersVoice(listener, talker)
    if talker:Health() < 0 then return false end

	local shouldhear, proximitive_sound = _CanHear[talker][listener], _CanHear3D[talker][listener]
    return shouldhear, proximitive_sound
end

util.AddNetworkString("HearCheck_TalkingStart")

net.Receive("HearCheck_TalkingStart", function(len, ply)
	local players = player.GetAll()
	--print(ply, "базарит")
	local talker = ply
	_CanHear[talker] = {}
	_CanHear3D[talker] = {}

	for num=1, #players do
		local listener = players[num]

		local shouldhear = false
		local proximitive_sound = false

		shouldhear, proximitive_sound = hearcheck_function(listener, talker)

		_CanHear[talker][listener] = shouldhear
		--_CanHear[listener][talker] = shouldhear
		_CanHear3D[talker][listener] = proximitive_sound
		--_CanHear3D[listener][talker] = proximitive_sound
	end

	--возвратити Аминь
end)

hook.Add("PlayerSay", "RXSEND_Mute", function(ply, msg)
	if ply:GTeam() != TEAM_SCP and ply:GTeam() != TEAM_SPEC then GAMEMODE:DoChatGesture(ply, cmd, msg) end
	if ply.BypassMute then ply.BypassMute = false return msg end
	if BREACH.Punishment.Mutes[ply:SteamID()] and ( ply:GTeam() == TEAM_SPEC or !msg:find("quickchat_") ) then
		ply:RXSENDNotify("l:you_are_muted")
		return ""
	end
end)

function GM:PlayerCanSeePlayersChat( text, teamOnly, listener, talker )

if !talker.GetRoleName then
	player_manager.SetPlayerClass( talker, "class_breach" )
	player_manager.RunClass( talker, "SetupDataTables" )
end

if !listener.GetRoleName then
	player_manager.SetPlayerClass( listener, "class_breach" )
	player_manager.RunClass( listener, "SetupDataTables" )
end

	if !listener.hasloadedalready then return false end
	if talker.canttalk then return false end

	--[[
	if talker == SERVER then
		return true
	end]]

	if listener:GTeam() == TEAM_SPEC then
		if listener.mutespec and talker:GTeam() == TEAM_SPEC then return false end
		if listener.mutealive and talker:GTeam() != TEAM_SPEC then return false end
	end

	if talker:GTeam() == TEAM_SCP and talker:GetInDimension() and talker:GetPos():DistToSqr(listener:GetPos()) < 562500 then
		return true, true
	end
    
	if talker:GetNWBool("IntercomTalking", false) == true and talker:Alive() and talker:GTeam() != TEAM_SCP and talker:GTeam() != TEAM_SPEC and talker:Health() > 0 then
		return true
	end

    if talker:GTeam() == TEAM_SPEC and listener:GTeam() == TEAM_SPEC then return true end
	if talker:GTeam() == TEAM_ARENA and listener:GTeam() == TEAM_ARENA then return true end

	if talker:Alive() == false then
		return false
	end

	if talker:GTeam() == TEAM_SPEC or !talker:Alive() and listener:Alive() == false then
		return false
	end
	
	if talker:GTeam() == TEAM_SCP then
		if listener:GTeam() == TEAM_SCP then
			return true
		elseif listener:GTeam() == TEAM_SPEC or listener:GTeam() == TEAM_DZ or ( talker:GetRoleName() == "SCP939" and !SCPFOOTSTEP["SCP939"] ) then
			if teamOnly then
				if talker:GetPos():DistToSqr(listener:GetPos()) < 2500 then
					return true
				end
			else
				if talker:GetPos():DistToSqr(listener:GetPos()) < 562500 then
					return true
				end
			end
		else
			return false
		end
	end

	--if talker:GetNClass() == ROLES.ADMIN or listener:GetNClass() == ROLES.ADMIN then return true end
	if talker:Alive() == false then return false end
	if listener:Alive() == false then return false end

	if talker:GTeam() == TEAM_SPEC then
		if listener:GTeam() == TEAM_SPEC then
			return true
		else
			return false
		end
	end
	
	if teamOnly and talker:Alive() then
		if listener:GTeam() != TEAM_SPEC then
			if talker:GetPos():DistToSqr(listener:GetPos()) < 2500 then
				return true
			else
				return false
			end
		end
	end

	if listener.CameraLook and listener:GetViewEntity():GetPos():DistToSqr(talker:GetPos()) < 562500 then
		return true, true
	end

	--[[
	if HaveRadio(listener, talker) == true then
		return true
	end
	--]]
	return (talker:GetPos():DistToSqr(listener:GetPos()) < 562500)
end

local Squech = Sound("nextoren/weapons/radio/squelch.ogg")

hook.Add( "PlayerSay", "Shaky_Radio", function( ply, msg, teamonly )
	if ply:IsFrozen() then
		return ""
	end
	if string.lower( msg ):StartWith("!r ") or string.lower( msg ):StartWith("/r ") then
		if ply:GTeam() == TEAM_SCP then
			return ""
		end
		if !ply:HasWeapon("item_radio") then ply:RXSENDNotify("l:no_radio") return "" end
		if !ply:GetWeapon("item_radio"):GetEnabled() then ply:RXSENDNotify("l:turn_up_the_radio") return "" end
		local msgtext = string.sub(msg, 4)
		if msgtext == "" then ply:RXSENDNotify("l:no_text_radio") return "" end
		local plychan = ply:GetWeapon("item_radio").Channel
		ply:EmitSound("^"..Squech, 76, 100, 2)
		local talkername = ply:GetNamesurvivor()
		ply:RXSENDNotify(Color(0,0,255), "l:radio_in_chat", Color(0, 255, 0), " ["..talkername.."] ", color_white, "<\"", msgtext, "\">")

		for _, tply in pairs(player.GetAll()) do
			if tply == ply then continue end
			if !tply:HasWeapon("item_radio") then continue end
			if !tply:GetWeapon("item_radio"):GetEnabled() then continue end
			if tply:GetWeapon("item_radio").Channel != plychan then continue end

			net.Start("ForcePlaySound")
			net.WriteString(Squech)
			net.Send(tply)

			tply:RXSENDNotify(Color(0,0,255), "l:radio_in_chat", Color(0, 255, 0), " ["..talkername.."] ", color_white, "<\"", msgtext, "\">")
		end
		return ""
	end
end )

local BREACH = BREACH || {}
local gradient = Material("vgui/gradient-r")
local gradients = Material("gui/center_gradient")

util.AddNetworkString("CameraPVS")

net.Receive("CameraPVS", function(len, ply)
	ply.CameraEnabled = net.ReadBool()
end)

hook.Add( "SetupPlayerVisibility", "CCTVPVS", function( ply, viewentity )

	local wep = ply:GetActiveWeapon()
	if IsValid( wep ) and wep:GetClass() == "item_cameraview" then
		if wep:GetEnabled() and IsValid( CCTV[wep:GetCAM()].ent ) then
			AddOriginToPVS( CCTV[wep:GetCAM()].pos ) 
		end
	end
	
	if ply:GetTable().CameraEnabled then
		for i = 1, #CamerasTable do
			AddOriginToPVS( CamerasTable[ i ].Vector )
		end
	end

end )

function GM:PlayerCanPickupWeapon(ply, wep)
    ply.OnTheGround = true

    if ply.Shaky_PICKUPWEAPON == wep then
    	if IsValid(wep) and wep.GetClass then
	    	BREACH.AdminLogs:Log("pickup", {
	    		user = ply,
	    		weapon = wep:GetClass(),
	    	})
	    end
    	hook.Run("BreachLog_PickedUpItem", ply, wep) ply.Shaky_PICKUPWEAPON = nil return true end
	
	if ply.JustSpawned == true then
		return true

	elseif ply.IsLooting == true then
		return true

	elseif ply:GTeam() == TEAM_SCP or ply:GTeam() == TEAM_SPEC then
		return false

	elseif ply:GTeam() == TEAM_SCP and ply.JustSpawned then
		return true

	elseif ply:HasWeapon(wep:GetClass()) then
		return false

	end
	
	--if wep:GetClass() == "scp_035_swep" then return true end

	if ( !ply:KeyDown( IN_USE ) ) then return false end

	if ( ply:GTeam() == TEAM_SCP || ply:GTeam() == TEAM_SPEC || ply:Health() <= 0 ) then return false end

	local tr = ply:GetEyeTrace()

	local wepent = tr.Entity
		
end

local button_models = {
	["models/next_breach/entrance_button.mdl"] = true,
	["models/next_breach/hcz_keycard_panel.mdl"] = true,
	["models/next_breach/keycard_panel.mdl"] = true,
}

hook.Add("KeyPress", "ItemPickup_SHAKY", function(ply, butt)
	if butt == IN_USE and ply:GTeam() != TEAM_SPEC and ply:GTeam() != TEAM_SCP then
		local tr = ply:GetEyeTrace()
		local wepent = tr.Entity

		if !IsValid(wepent) or !wepent:IsWeapon() then return end

		if ( ply:GTeam() == TEAM_SCP || ply:GTeam() == TEAM_SPEC || ply:Health() <= 0 ) then return end

		if ( wepent:IsWeapon() && wepent:GetPos():DistToSqr( ply:GetPos() ) <= 6400 ) then

			local ent_class = wepent:GetClass()

			if ( ply:HasWeapon( ent_class ) ) then

				ply.NextPickup = CurTime() + 1
				--ply:RXSENDWarning("У Вас уже есть данный предмет.")

				return
			end

			local maximumdefaultslots = ply:GetMaxSlots()
			local maximumitemsslots = 6
			local maximumnotdroppableslots = 6

			local countdefault = 0
			local countitem = 0
			local countnotdropable = 0

			local is_cw = wepent.CW20Weapon

			for _, weapon in ipairs( ply:GetWeapons() ) do

				if ( is_cw && weapon.CW20Weapon && weapon.Primary.Ammo == wepent.Primary.Ammo ) then

					ply.NextPickup = CurTime() + 1
					--ply:RXSENDWarning("У Вас уже есть данный тип оружия.")

					return
				end

				if ( !weapon.Equipableitem && !weapon.UnDroppable ) then

					countdefault = countdefault + 1

				elseif ( weapon.Equipableitem ) then

					countitem = countitem + 1

				elseif ( weapon.UnDroppable ) then

					countnotdropable = countnotdropable + 1

				end

			end

			if ( !wepent.Equipableitem && !wepent.UnDroppable && countdefault >= maximumdefaultslots ) then

				ply:setBottomMessage("l:inventory_full")

				return

			elseif ( wepent.Equipableitem && countitem >= maximumitemsslots ) then

				ply:setBottomMessage("l:secondary_inventory_full")

				return

			elseif ( wepent.UnDroppable && countnotdropable >= maximumnotdroppableslots ) then

				ply:setBottomMessage("l:inventory_full")

				return

			end

			local physobj = wepent:GetPhysicsObject()

			if ( physobj && physobj:IsValid() ) then

				physobj:EnableMotion( false )

			end

			local function finishcallback()
				ply.Shaky_PICKUPWEAPON = wepent

				wepent:SetPos(ply:GetShootPos())--ply:GetPos()
				ply:EmitSound("^nextoren/charactersounds/inventory/nextoren_inventory_itemreceived.wav")
				local physobj = wepent:GetPhysicsObject()

				if ( physobj && physobj:IsValid() ) then

					physobj:EnableMotion( true )

				end
			end

			local function stopcallback()

				local physobj = wepent:GetPhysicsObject()

				if ( physobj && physobj:IsValid() ) then

					physobj:EnableMotion( true )

				end

			end

			ply:BrProgressBar( "l:progress_wait", 0.5, "nextoren/gui/icons/hand.png", wepent, false, finishcallback, nil, stopcallback)

		end

	end
end)

function GM:PlayerCanPickupItem( ply, item )
	return ply:GTeam() != TEAM_SPEC or ply:GetRoleName() == ADMIN
end

function GM:AllowPlayerPickup( ply, ent )
	if ent.funkyragdoll and ply:GTeam() != TEAM_SPEC then return true end
	return false
end
// usesounds = true,
function IsInTolerance( spos, dpos, tolerance )
	if spos == dpos then return true end

	if isnumber( tolerance ) then
		tolerance = { x = tolerance, y = tolerance, z = tolerance }
	end

	local allaxes = { "x", "y", "z" }
	for k, v in pairs( allaxes ) do
		if spos[v] != dpos[v] then
			if tolerance[v] then
				if math.abs( dpos[v] - spos[v] ) > tolerance[v] then
					return false
				end
			else
				return false
			end
		end
	end

	return true
end

local trashbins = {"models/props_canteen/canteenbin.mdl",
"models/props_gffice/metalbin01.mdl",
"models/props_beneric/trashbin002.mdl",
"models/props_residue/trashcan01.mdl",}

local trashbinloot = {
	{ -- 70%
		"breach_keycard_1",
		"breach_keycard_sci_1",
		"breach_keycard_guard_1",
		"breach_keycard_security_1",
		"copper_coin",
		"silver_coin",
		"weapon_flashlight",
		"item_screwdriver",
		"item_eyedrops_1",
		"item_drink_soda",
		"item_drink_water",
	},
	{ -- 24%
		"breach_keycard_2",
		"breach_keycard_3",
		"breach_keycard_security_2",
		"breach_keycard_sci_2",
		"gold_coin",
		"item_eyedrops_2",
		"item_eyedrops_3",
		"item_drink_energy",
		"item_drink_coffee",
	},
	{ -- 5%
		"breach_keycard_guard_2",
		"breach_keycard_security_2",
		"breach_keycard_security_3",
		"breach_keycard_sci_3",
		"breach_keycard_sci_4",
	},
	{ -- 1%
		"breach_keycard_7",
		"item_keys",
	},
}

local function GetTrashbinLootTable()
	local rand = math.random(1, 100)
	if rand == 1 then
		return trashbinloot[4]
	elseif rand <= 5 then
		return trashbinloot[3]
	elseif rand <= 24 then
		return trashbinloot[2]
	else
		return trashbinloot[1]
	end
end

local function LogDoorOpen(ply, ent, name)
	hook.Run("BreachLog_DoorOpen", ply, name)
end

local function LogDoorClose(ply, ent, name)
	hook.Run("BreachLog_DoorClose", ply, name)
end

local function LogElevator(ply, ent, name)
	hook.Run("BreachLog_ElevatorUse", ply, name)
end

local function LogDoorOrElevator(ply, ent, name)
	if ent:GetName():find("elev") then
		LogElevator(ply, ent, name)
	else
		if ent.Opened then
			LogDoorClose(ply, ent, name)
		else
			LogDoorOpen(ply, ent, name)
		end
	end
end

function ChangeSkinKeypad(ply, ent, state)
	if ent:GetClass() == "func_button" then
		if ent:GetInternalVariable("m_toggle_state") == 1 then
			for i, v in pairs(ents.FindInSphere(ent:GetPos(), 65)) do
				if IsValid(v) and button_models[v:GetModel()] then
					if state then
						v:SetSkin(1)
					else
						v:SetSkin(2)
					end
					timer.Create("DefaultButtonSkin"..v:EntIndex(), 1.8, 1, function()
						v:SetSkin(0)
					end)
					for p, e in pairs(ents.FindInSphere(v:GetPos()+v:GetAngles():Forward()*-65, 55)) do
						if IsValid(e) and button_models[e:GetModel()] then
							if state then
								e:SetSkin(1)
							else
								e:SetSkin(2)
							end
							timer.Create("DefaultButtonSkin"..e:EntIndex(), 1.8, 1, function()
								e:SetSkin(0)
							end)
						end
					end
				end
			end
		end
	end
end

function GM:PlayerUse( ply, ent )
	if ply:GTeam() == TEAM_SPEC and ply:GetRoleName() != ADMIN then return false end
	if ent:GetModel() == "models/noundation/doors/860_door.mdl" and !SCPLockDownHasStarted then return false end
	if ply:GetRoleName() == ADMIN then return true end
	--if ply:IsSuperAdmin() then print(NormalVector(ent:GetPos())) end

	if ply:GetRoleName() == role.SCI_Cleaner then
		if IsValid(ent) and ent:GetClass() == "prop_dynamic" and ply:KeyPressed(IN_USE) then
			if table.HasValue(trashbins, ent:GetModel()) and ply:GetEyeTrace().Entity == ent and ent:GetPos():DistToSqr(ply:GetPos()) <= 22500 then
				if ent.CleanerLooted != true then
					ply:BrProgressBar( "l:looting_trash_can", 7, "nextoren/gui/icons/hand.png", ent, false, function()
						ent.CleanerLooted = true
						ply:setBottomMessage("l:trashbin_loot_end")
						local _t = GetTrashbinLootTable()
						ply:BreachGive(_t[math.random(1, #_t)])
					end, nil, nil )
				else
					ply:setBottomMessage("l:trashbin_empty")
				end
			end
		end
	end
	if ply.lastuse == nil then ply.lastuse = 0 end
	if ply.lastuse > CurTime() then return false end

	ent._lastusedby = ply
	ent._lastusedwhen = SysTime()

	--print(ent:GetPos().x..", "..ent:GetPos().y..", "..ent:GetPos().z)
	for k, v in pairs( BUTTONS ) do
		if v.pos == ent:GetPos() or v.tolerance then
			if v.tolerance and !IsInTolerance( v.pos, ent:GetPos(), v.tolerance ) then
				continue
			end

			local name = v.name or v:GetName()

			ply.lastuse = CurTime() + 1

			if v.keycardnotrequired then
				if v.custom_access_granted then
					if v.custom_access_granted( ply, ent ) then
						ChangeSkinKeypad(ply, ent, true)
						return true
					else
						if !v.nosound and !timer.Exists("next_deny_"..ent:EntIndex()) then
							--ply:EmitSound( "^nextoren/weapons/keycard/keycarduse_2.ogg" )
							--ply:EmitSound( "nextoren/others/access_denied.wav" )
						end
	
						ply:setBottomMessage( "l:access_denied" )

						ChangeSkinKeypad(ply, ent, false)

						return false
					end
									 
				else
					return true
				end
			end
			if v.access then
				if v.name:find("Ворота") or v.name:find("КПП") then

					if GetGlobalBool("Evacuation", false) then
						if !isnumber(Monitors_Activated) or Monitors_Activated < 5 then
							LogDoorOrElevator(ply, ent, name)
							return true

						end

					end
				end

				if OMEGADoors then
					LogDoorOrElevator(ply, ent, name)
					return true
				end

				if v.levelOverride and v.levelOverride( ply ) then
					LogDoorOrElevator(ply, ent, name)
					return true
				end

				local wep = ply:GetActiveWeapon()
				if IsValid( wep ) and wep:GetClass():find("_keycard_") then
					local keycard = wep
					if IsValid( keycard ) then
						if !(v.allowed_keycards and v.allowed_keycards[wep:GetClass()]) then
							for k, acses in pairs(v.access) do
								if acses >  keycard.CLevels[k] then
									if !v.nosound then
										ply:EmitSound( "^nextoren/weapons/keycard/keycarduse_2.ogg" )
										--ply:EmitSound( "nextoren/others/access_denied.wav" )
									end
		
									ply:setBottomMessage( "l:access_denied" )

									ChangeSkinKeypad(ply, ent, false)
		
									return false
								end
							end
						end

								
								if v.custom_access_granted then
									if v.custom_access_granted( ply, ent ) then
										if !v.nosound then
										ply:EmitSound( "^nextoren/weapons/keycard/keycarduse_1.ogg" )
									end
			
										ply:setBottomMessage( "l:access_granted" )
										ent:Fire("use")
										LogDoorOrElevator(ply, ent, name)
										ChangeSkinKeypad(ply, ent, true)
										return true
									else
										if !v.nosound then
									ply:EmitSound( "^nextoren/weapons/keycard/keycarduse_2.ogg" )
									--ply:EmitSound( "nextoren/others/access_denied.wav" )
								end
								
								ply:setBottomMessage( "l:access_denied" )
								ChangeSkinKeypad(ply, ent, false)
	
								return false
									end
									 
								else
										if !v.nosound then
									ply:EmitSound( "^nextoren/weapons/keycard/keycarduse_1.ogg" )
								end
	
									ply:setBottomMessage( "l:access_granted" )
									ChangeSkinKeypad(ply, ent, true)
									ent:Fire("use")
									LogDoorOrElevator(ply, ent, name)
									return true
								end
					end
				else
					--ply:EmitSound( "nextoren/others/access_denied.wav" )
					ply:setBottomMessage( "l:keycard_needed" )
					return false
				end
			end

			if v.canactivate == nil or v.canactivate( ply, ent ) then

				--print("2")
				LogDoorOrElevator(ply, ent, name)
				return true
			else
				if !v.nosound then
					ply:EmitSound( "^nextoren/weapons/keycard/keycarduse_2.ogg" )
					--ply:EmitSound( "nextoren/others/access_denied.wav" )
				end

				if v.customdenymsg then
					ply:setBottomMessage( v.customdenymsg )
					ChangeSkinKeypad(ply, ent, false)
				else
					ply:setBottomMessage( "l:access_denied" )
					ChangeSkinKeypad(ply, ent, false)
					
				end

				return false
			end
		end
	end
	
	--[[
	print(ent:GetClass())
	print(ent:GetPos())

	for _, armor in ipairs(ents.FindByClass("armor_light")) do
		print(armor:GetPos())
	end

	if ent:IsPlayer() then

		print(ent:Health())
		print(ent:GetMaxHealth())
		print(ent:GTeam())
		print(ent:GetRoleName())
		print(#ent:GetWeapons())
		print(ent:GetWalkSpeed())
		print(ent:GetRunSpeed())

	end
	--]]

	if ent:GetClass() == "func_button" and ent:GetInternalVariable("m_toggle_state") == 1 then
		ChangeSkinKeypad(ply, ent, true)
	end

	return true
end

function GM:CanPlayerSuicide( ply )
	return false
end

function string.starts( String, Start )
   return string.sub( String, 1, string.len( Start ) ) == Start
end