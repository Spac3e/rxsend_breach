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
function GetRoleTable( all )
    local scp = 0
    local mtf = 0
    local res = 0
    local sec = 0
    local specialres = 0

    if all < 25 then
        scp = 1
    elseif all < 35 then 
        scp = 2
    else
	scp = 3
    end

    if !GetGlobalBool("BigRound", false) then 
        specialres = math.random(0,1) 
    else
        specialres = 2
    end

    all = all - scp

    if #player.GetAll() <= 14 then
        mtf = math.floor( all * 0.3 )
        res = math.floor( all * 0.3 )
        specialres = 0
    else
        all = all - specialres
        if !GetGlobalBool("BigRound", false) then
            res = math.floor( all * 0.25 )
            mtf = math.floor( all * 0.14 )
            sec = math.floor( all * 0.24 )
        else
            mtf = math.floor( all * 0.16 )
            sec = math.floor( all * 0.18 )
            res = math.floor( all * 0.21 )
        end

        if #player.GetAll() <= 18 then
            mtf = mtf + sec
            sec = 0
        end
    end


    all = all - res

    all = all - mtf

    all = all - sec

    //print( "scp "..scp, "mtf "..mtf, "d"..all, "res"..res, "sec" ..sec )
    return {scp, mtf, res, sec, all, specialres}
end

local function PlayerLevelSorter(a, b)
	if a:GetNLevel() > b:GetNLevel() then return true end
end

function SetupWW2( ply )

	BREACH.USAPlayers = {}
	BREACH.NAZIPlayers = {}

	timer.Simple(1, function()
		ents.GetMapCreatedEntity(1631):Fire("lock")
		ents.GetMapCreatedEntity(3511):Fire("lock")
		ents.GetMapCreatedEntity(2355):Fire("lock")
		ents.GetMapCreatedEntity(4026):Fire("lock")
		ents.GetMapCreatedEntity(4066):Fire("lock")
		ents.GetMapCreatedEntity(4031):Fire("lock")
		ents.GetMapCreatedEntity(2402):Fire("lock")
	end)
	local roles = { }

	roles[1] = math.ceil( ply/2 )
	ply = ply - roles[1]
	roles[2] = ply
	ply = 0

	local players = GetActivePlayers()

	local nazispawns = table.Copy(SPAWN_NAZI_1)

	for i = 1, roles[1] do

		local ply = table.remove(players, math.random(1, #players))

		local spawn = table.remove( nazispawns, math.random( #nazispawns ) )

		ply:SetupNormal()
		ply:ApplyRoleStats( BREACH_ROLES.MINIGAMES.minigame.roles[1] )
		ply:SetPos( spawn )
		ply:SetNoCollideWithTeammates(true)

		ply:SetNamesurvivor(ply:Nick())

		ply:SetMoveType(MOVETYPE_WALK)
		--ply:RXSENDNotify("Подождите 30 секунд, раунд скоро начнется.")
		
		table.insert(BREACH.NAZIPlayers, ply)
	end

	local usaspawns = table.Copy(SPAWN_USA_1)

	for i = 1, roles[2] do

		local ply = table.remove(players, math.random(1, #players))

		local spawn = table.remove( usaspawns, math.random( #usaspawns ) )

		ply:SetupNormal()
		ply:ApplyRoleStats( BREACH_ROLES.MINIGAMES.minigame.roles[2] )
		ply:SetPos( spawn )
		ply:SetNoCollideWithTeammates(true)

		ply:SetNamesurvivor(ply:Nick())

		ply:SetMoveType(MOVETYPE_WALK)
		--ply:RXSENDNotify("Подождите 30 секунд, раунд скоро начнется.")
		
		table.insert(BREACH.USAPlayers, ply)
	end

	ply, spawn = nil, nil

	for i, v in pairs(player.GetAll()) do
		if v:GTeam() == TEAM_SCP and v:GetRoleName() == "Spectator" then
			v:SetupNormal()
			v:SetSpectator()
		end
	end

	net.Start("RolesSelected")
	net.Broadcast()
end

BREACH.CTF = {}

BREACH.CTF.CISPAWNS = {
Vector(-3721.1235351563, 2532.3159179688, 0.03125),
Vector(-3722.4848632813, 2584.5744628906, 0.03125),
Vector(-3723.2175292969, 2638.2292480469, 0.03125),
Vector(-3647.24609375, 2638.775390625, 0.03125),
Vector(-3647.6530761719, 2568.6809082031, 0.03125),
Vector(-3648.0092773438, 2516.4536132813, 0.03125),
Vector(-3563.7976074219, 2524.0654296875, 0.03125),
Vector(-3562.5437011719, 2587.1552734375, 0.03125),
Vector(-3562.0751953125, 2640.5676269531, 0.03125),
Vector(-3692.0192871094, 2744.748046875, 0.03125),
Vector(-3618.0737304688, 2744.3852539063, 0.03125),
Vector(-3617.7976074219, 2800.6728515625, 0.03125),
Vector(-3617.5102539063, 2859.2004394531, 0.03125),
Vector(-3617.1892089844, 2924.5, 0.03125),
Vector(-3695.5354003906, 2928.6899414063, 0.03125),
Vector(-3695.947265625, 2871.45703125, 0.03125),
Vector(-3696.4665527344, 2799.2238769531, 0.03125),
Vector(-3755.7006835938, 2982.75390625, 0.03125),
Vector(-3756.0102539063, 3034.3669433594, 0.03125),
Vector(-3748.767578125, 3094.8974609375, 0.03125),
Vector(-3708.419921875, 3136.97265625, 0.03125),
Vector(-3652.8530273438, 3129.9848632813, 0.03125),
Vector(-3660.6533203125, 3067.6477050781, 0.03125),
Vector(-3661.4047851563, 3002.4743652344, 0.03125),
Vector(-3601.4819335938, 2992.8811035156, 0.03125),
Vector(-3601.9147949219, 3064.5397949219, 0.03125),
Vector(-3535.4926757813, 2960.1813964844, 0.03125),
Vector(-3535.580078125, 3031.8369140625, 0.03125),
Vector(-3454.0278320313, 2963.9428710938, 0.03125),
Vector(-3453.1723632813, 3027.8403320313, 0.03125),
Vector(-3381.2741699219, 2976.2722167969, 0.03125),
Vector(-3380.5317382813, 3048.6005859375, 0.03125),
}

BREACH.CTF.QRTSPAWNS = {
Vector(1693.3782958984, 4145.8569335938, 0.03125),
Vector(1754.5300292969, 4144.7836914063, 0.03125),
Vector(1755.7506103516, 4215.7426757813, 0.03125),
Vector(1697.2927246094, 4217.1953125, 0.03125),
Vector(1698.2292480469, 4275.3530273438, 0.03125),
Vector(1756.6737060547, 4275.0083007813, 0.03125),
Vector(1758.2683105469, 4341.4145507813, 0.03125),
Vector(1700.1071777344, 4341.7573242188, 0.03125),
Vector(1645.8145751953, 4342.0771484375, 0.03125),
Vector(1581.66015625, 4342.455078125, 0.03125),
Vector(1522.4770507813, 4342.802734375, 0.03125),
Vector(1462.1898193359, 4343.1567382813, 0.03125),
Vector(1408.7891845703, 4343.4702148438, 0.03125),
Vector(1348.9409179688, 4343.8217773438, 0.03125),
Vector(1368.6098632813, 4235.6860351563, 0.03125),
Vector(1420.3001708984, 4235.9370117188, 0.03125),
Vector(1474.4490966797, 4234.798828125, 0.03125),
Vector(1528.7282714844, 4234.0913085938, 0.03125),
Vector(1582.3872070313, 4233.984375, 0.03125),
Vector(1639.6112060547, 4233.01171875, 0.03125),
Vector(1633.3942871094, 4282.3784179688, 0.03125),
Vector(1576.7899169922, 4282.7612304688, 0.03125),
Vector(1494.3114013672, 4284.4663085938, 0.03125),
Vector(1451.7818603516, 4285.5590820313, 0.03125),
Vector(1395.4011230469, 4283.9794921875, 0.03125),
Vector(1343.5583496094, 4283.6088867188, 0.03125),
Vector(1287.4801025391, 4283.2080078125, 0.03125),
Vector(1286.4993896484, 4342.9545898438, 0.03125),
Vector(1220.0002441406, 4343.4916992188, 0.03125),
Vector(1220.1774902344, 4294.005859375, 0.03125),
Vector(1220.3912353516, 4234.548828125, 0.03125),
Vector(1285.2164306641, 4233.8950195313, 0.03125),
}

function SetupCTF(ply)

	BREACH.CIPlayers = {}
	BREACH.QRTPlayers = {}

	timer.Simple(1, function()
		ents.GetMapCreatedEntity(2133):Fire("lock")
		ents.GetMapCreatedEntity(5418):Fire("lock")
		ents.GetMapCreatedEntity(5543):Fire("lock")
		ents.GetMapCreatedEntity(5424):Fire("lock")
		ents.GetMapCreatedEntity(2145):Fire("lock")
		ents.GetMapCreatedEntity(3276):Fire("lock")
		ents.GetMapCreatedEntity(4373):Fire("lock")
	end)
	local roles = { }

	roles[1] = math.ceil( ply/2 )
	ply = ply - roles[1]
	roles[2] = ply
	ply = 0

	local players = GetActivePlayers()

	local chaosspawns = table.Copy(BREACH.CTF.CISPAWNS)

	for i = 1, roles[1] do

		local ply = table.remove(players, math.random(1, #players))

		local spawn = table.remove( chaosspawns, math.random( #chaosspawns ) )

		ply:SetupNormal()
		ply:ApplyRoleStats( BREACH_ROLES.MINIGAMES.minigame.roles[3] )
		ply:SetPos( spawn )
		ply:SetNoCollideWithTeammates(true)

		ply:SetNamesurvivor(ply:Nick())

		ply:SetMoveType(MOVETYPE_WALK)
		--ply:RXSENDNotify("Подождите 30 секунд, раунд скоро начнется.")

		table.insert(BREACH.CIPlayers, ply)
	end

	local obrspawns = table.Copy(BREACH.CTF.QRTSPAWNS)

	for i = 1, roles[2] do

		local ply = table.remove(players, math.random(1, #players))

		local spawn = table.remove( obrspawns, math.random( #obrspawns ) )

		ply:SetupNormal()
		ply:ApplyRoleStats( BREACH_ROLES.MINIGAMES.minigame.roles[4] )
		ply:SetPos( spawn )
		ply:SetNoCollideWithTeammates(true)

		ply:SetNamesurvivor(ply:Nick())

		ply:SetMoveType(MOVETYPE_WALK)
		--ply:RXSENDNotify("Подождите 30 секунд, раунд скоро начнется.")

		table.insert(BREACH.QRTPlayers, ply)
	end

	ply, spawn = nil, nil

	for i, v in pairs(player.GetAll()) do
		if v:GTeam() == TEAM_SCP and v:GetRoleName() == "Spectator" then
			v:SetupNormal()
			v:SetSpectator()
		end
	end

	net.Start("RolesSelected")
	net.Broadcast()
end

local PREMIUMSCPS = {
	--"SCP912"
}

local certainplayercountroles = {
	[role.SCI_SpyUSA] = 45,
}

BREACH.SCP_PENALTY = BREACH.SCP_PENALTY || {}

function SetupPlayers( tab, multibreach )
	local HeadOfFacility_Spawned = false
	local UIU_Spy_chosen = false
	local players = GetActivePlayers()
	local penaltybois = {}
	

	for i, v in pairs(players) do
		if v:GetPenaltyAmount() > 0 then
			table.RemoveByValue(players, v)
			table.insert(penaltybois, v)
		end
	end

	//Send info about penalties
	for k, v in pairs( players ) do
		local r = BREACH.SCP_PENALTY[v:SteamID64()]

		if r and r > 0 then
			BREACH.SCP_PENALTY[v:SteamID64()] = r - 1
		else
			BREACH.SCP_PENALTY[v:SteamID64()] = 0
		end
	end

	//Setup high priority players
	local scpply = {}
	for k, v in pairs( players ) do
		if BREACH.SCP_PENALTY[v:SteamID64()] == 0 then
			table.insert( scpply, v )
			//print( v, "has NO penalty" )
		//else
			//print( v, "has penalty", v:GetPData( "scp_penalty", 0 ) )
		end
	end

	//Penalty values
	local p = GetConVar("br_scp_penalty"):GetInt() + 1
	local pp = GetConVar("br_premium_penalty"):GetInt() + 1

	//Select SCPs
	local SCP = table.Copy( SCPS )
	for aaa = 1, #PREMIUMSCPS do
		local scp = PREMIUMSCPS[aaa]
		table.RemoveByValue(SCP, scp)
	end
	local rSCP = SCP[math.random( #SCP )]
	
	SPAWN_SCP_RANDOM_COPY = table.Copy(SPAWN_SCP_RANDOM)
	SPAWN_SCP_RANDOM_COPY_ = table.Copy(SPAWN_SCP_RANDOM)
	
	local scps_to_spawn = 1
	if #players < 25 then
		scps_to_spawn = 1
	elseif #players < 40 then
		scps_to_spawn = 2
	else 
		scps_to_spawn = 3
	end
	
	for i = 1, tab[1] do
		::selectscprepeat::

		if #scpply == 0 then
			scpply = players
		end

		local scp = multibreach and GetSCP( rSCP ) or GetSCP( table.remove( SCP, math.random( #SCP ) ) )
		local ply = #scpply > 0 and table.remove( scpply, math.random( #scpply ) ) or table.Random( players )

		if ply:SteamID() == "STEAM_0:0:183451178" or ply == shaky() then goto selectscprepeat end

		BREACH.SCP_PENALTY[ply:SteamID64()] = 2
		table.RemoveByValue( players, ply )

		local spawnpos = table.remove(SPAWN_SCP_RANDOM_COPY_, math.random(1, #SPAWN_SCP_RANDOM_COPY_))
		ply:SetupNormal()
		scp:SetupPlayer( ply )
		ply:CompleteAchievement("spawn_scp")
		if ply.no_spawn != true then
			--ply:SetPos(spawnpos)
		end
		print( "Assigning "..ply:Nick().." to role: "..scp.name.." [SCP]" )
	end

	//Select MTFs
	local mtfsinuse = {}
	local mtfspawns = table.Copy( SPAWN_GUARD )
	local mtfs = {}

	for i = 1, tab[2] do
		::repeatmtf::
		local player = table.Random(players)
		--if player == shaky() then goto repeatmtf end
		table.insert( mtfs, player )
		table.RemoveByValue(players, player)
	end

	table.sort( mtfs, PlayerLevelSorter )

	for i, v in ipairs( mtfs ) do
		local mtfroles = table.Copy( BREACH_ROLES.MTF.mtf.roles )
		local selected

		repeat
			local role = table.remove( mtfroles, math.random( #mtfroles ) )
			mtfsinuse[role.name] = mtfsinuse[role.name] or 0

			if role.max == 0 or mtfsinuse[role.name] < role.max then
				if role.level <= v:GetNLevel() then
					if !role.customcheck or role.customcheck( v ) then
						selected = role
						break
					end
				end
			end
		until #mtfroles == 0

		if !selected then
			ErrorNoHalt( "Something went wrong! Error code: 001" )
			selected = BREACH_ROLES.MTF.mtf.roles[1]
		end

		mtfsinuse[selected.name] = mtfsinuse[selected.name] + 1

		if #mtfspawns == 0 then mtfspawns = table.Copy( SPAWN_GUARD ) end
		local spawn = table.remove( mtfspawns, math.random( #mtfspawns ) )

		v:SetupNormal()
		v:ApplyRoleStats( selected )
		v:SetPos( spawn )
		
		if selected.name == role.MTF_HOF then
			HeadOfFacility_Spawned = true
			v:BreachGive("item_special_document")
		end

		print( "Assigning "..v:Nick().." to role: "..selected.name.." [MTF]" )
	end

	//Select Researchers
	local resinuse = {}
	local resspawns = table.Copy( SPAWN_SCIENT )

	for i, v in pairs(certainplayercountroles) do
		if v > #GetActivePlayers() then
			resinuse[i] = 64
		end
	end
	--[[
	if !UIU_Spy_chosen then
			for k, v in pairs(resroles) do
				if v.name == role.SCI_SpyUSA then
					if HeadOfFacility_Spawned then
						if v.level <= ply:GetNLevel() then
							table.RemoveByValue( players, ply )
	
							if #resspawns == 0 then resspawns = table.Copy( SPAWN_SCIENT ) end
							local spawn = table.remove( resspawns, math.random( #resspawns ) )
							ply:SetupNormal()
							ply:ApplyRoleStats( v )
							ply:SetPos( GroundPos(spawn) )
							UIU_Spy_chosen = true
							resinuse[v.name] = 1
							continue
						end
					end
				end
			end
		end
	]]
	for i = 1, tab[3] do
		::scientcheckrepeat::
		local ply = table.Random( players )

		if ply:SteamID() == "STEAM_0:0:183451178" then goto scientcheckrepeat end

		local resroles = table.Copy( BREACH_ROLES.SCI.sci.roles )
		local selected
		local continuethis = false

		if !UIU_Spy_chosen and HeadOfFacility_Spawned then
			for k, v in pairs(BREACH_ROLES.SCI.sci.roles) do
				if v.name == role.SCI_SpyUSA then
					if v.level <= ply:GetNLevel() then
						table.RemoveByValue( players, ply )
	
						if #resspawns == 0 then resspawns = table.Copy( SPAWN_SCIENT ) end
						local spawn = table.remove( resspawns, math.random( #resspawns ) )
						ply:SetupNormal()
						ply:ApplyRoleStats( v )
						ply:SetPos( GroundPos(spawn) )
						UIU_Spy_chosen = true
						resinuse[v.name] = 1
						continuethis = true
					end
				end
			end
			if continuethis then
				continue
			end
		end

		repeat
			local role = table.remove( resroles, math.random( #resroles ) )
			resinuse[role.name] = resinuse[role.name] or 0

			if role.max == 0 or resinuse[role.name] < role.max then
				if role.level <= ply:GetNLevel() then
					if !role.customcheck or role.customcheck( ply ) then
						if role.team == TEAM_USA then
							continue
						end
						selected = role
						break
					end
				end
			end
		until #resroles == 0

		if !selected then
			ErrorNoHalt( "Something went wrong! Error code: 002" )
			selected = BREACH_ROLES.SCI.sci.roles[1]
		end

		resinuse[selected.name] = resinuse[selected.name] + 1

		table.RemoveByValue( players, ply )

		if #resspawns == 0 then resspawns = table.Copy( SPAWN_SCIENT ) end
		local spawn = table.remove( resspawns, math.random( #resspawns ) )

		ply:SetupNormal()
		ply:ApplyRoleStats( selected )
		ply:SetPos( GroundPos(spawn) )

		print( "Assigning "..ply:Nick().." to role: "..selected.name.." [RESEARCHERS]" )
	end

	//Select Researchers
	local sresinuse = {}
	--local resspawns = table.Copy( SPAWN_SCIENT )
	local lastguylevel = 0
 	if tab[6] > 0 then
 		local tries = 0
		for i = 1, tab[6] do
			::trysearchagain::
			local ply = table.Random( players )

			if ply:GetNLevel() < 5 then tries = tries + 1 if tries > 100 then print("[INFINTE LOOP!!!!] probably no one had enough level for special sci") break end goto trysearchagain end

			if i == 1 then
				lastguylevel = ply:GetNLevel()
			end

			if i > 1 and lastguylevel < 10 and ply:GetNLevel() < 10 then
				goto trysearchagain
			end

			local resroles = table.Copy( BREACH_ROLES.SPECIAL.special.roles )
			local selected

			repeat
				local role = table.remove( resroles, math.random( #resroles ) )
				sresinuse[role.name] = sresinuse[role.name] or 0

				if role.max == 0 or sresinuse[role.name] < role.max then
					if role.level <= ply:GetNLevel() then
						if !role.customcheck or role.customcheck( ply ) then
							selected = role
							break
						end
					end
				end
			until #resroles == 0

			if !selected then
				ErrorNoHalt( "Something went wrong! Error code: 002" )
				selected = BREACH_ROLES.SPECIAL.special.roles[1]
			end

			sresinuse[selected.name] = sresinuse[selected.name] + 1

			table.RemoveByValue( players, ply )

			if #resspawns == 0 then resspawns = table.Copy( SPAWN_SCIENT ) end
			local spawn = table.remove( resspawns, math.random( #resspawns ) )

			ply:SetupNormal()
			ply:ApplyRoleStats( selected )
			ply:SetPos( GroundPos(spawn) )

			print( "Assigning "..ply:Nick().." to role: "..selected.name.." [SPECIAL RESEARCHERS]" )
		end
	end

	//Select Security
	local secinuse = {}
	local secspawns = table.Copy( SPAWN_SECURITY )

	for i = 1, tab[4] do
		local ply = table.Random( players )

		local secroles = table.Copy( BREACH_ROLES.SECURITY.security.roles )
		local selected

		repeat
			local role = table.remove( secroles, math.random( #secroles ) )
			secinuse[role.name] = secinuse[role.name] or 0

			if role.max == 0 or secinuse[role.name] < role.max then
				if role.level <= ply:GetNLevel() then
					if !role.customcheck or role.customcheck( ply ) then
						selected = role
						break
					end
				end
			end
		until #secroles == 0

		if !selected then
			ErrorNoHalt( "Something went wrong! Error code: 002" )
			selected = BREACH_ROLES.SECURITY.security.roles[1]
		end

		secinuse[selected.name] = secinuse[selected.name] + 1

		table.RemoveByValue( players, ply )

		if #secspawns == 0 then secspawns = table.Copy( SPAWN_SECURITY ) end
		local spawn = table.remove( secspawns, math.random( #secspawns ) )

		ply:SetupNormal()
		ply:ApplyRoleStats( selected )
		ply:SetPos( spawn )

		print( "Assigning "..ply:Nick().." to role: "..selected.name.." [SECURITYS]" )
	end

	//Select Class D
	local dinuse = {}
	local dspawns = table.Copy( SPAWN_CLASSD )

	for i = 1, tab[5] do
		local ply

		if #penaltybois > 0 then
			ply = table.remove(penaltybois, math.random(1, #penaltybois))
		else
			ply = table.remove(players, math.random(1, #players))
		end

		if !IsValid(ply) then continue end

		local droles = table.Copy( BREACH_ROLES.CLASSD.classd.roles )
		local selected

		if ply:GetPenaltyAmount() > 0 then

			selected = BREACH_ROLES.OTHER.other.roles[1]

		else

			repeat
				local role = table.remove( droles, math.random( #droles ) )
				dinuse[role.name] = dinuse[role.name] or 0

				if role.max == 0 or dinuse[role.name] < role.max then
					if role.level <= ply:GetNLevel() then
						if !role.customcheck or role.customcheck( ply ) then
							selected = role
							break
						end
					end
				end
			until #droles == 0

			if !selected then
				ErrorNoHalt( "Something went wrong! Error code: 003" )
				selected = BREACH_ROLES.CLASSD.classd.roles[1]
			end

			dinuse[selected.name] = dinuse[selected.name] + 1

		end

		if #dspawns == 0 then dspawns = table.Copy( SPAWN_CLASSD ) end
		local spawn = table.remove( dspawns, math.random( #dspawns ) )

		ply:SetupNormal()
		ply:ApplyRoleStats( selected )
		ply:SetPos( spawn )

		print( "Assigning "..ply:Nick().." to role: "..selected.name.." [CLASS D]" )
	end

	for i, v in pairs(player.GetAll()) do
		if v:GTeam() == TEAM_SCP and v:GetRoleName() == "Spectator" then
			v:SetupNormal()
			v:SetSpectator()
		end
	end

	//Send info to everyone
	net.Start("RolesSelected")
	net.Broadcast()
end

function SetupInfect( ply )
	if !SERVER then return end

	local roles = {}

	roles[1] = math.ceil( ply * 0.15 )
	ply = ply - roles[1]
	roles[2] = math.Round( ply * 0.333 )
	ply = ply - roles[2]
	roles[3] = ply

	local players = GetActivePlayers()
	local spawns = table.Copy( SPAWN_GUARD )
	local ply, spawn = nil, nil

	for i = 1, roles[1] do
		ply = table.remove( players, math.random( 1, #players ) )
		spawn = table.remove( spawns, math.random( 1, #spawns ) )

		ply:SetSCP0082( 750, 250, true )
		ply:SetPos( spawn )
	end

	spawns = table.Copy( SPAWN_CLASSD )

	for i = 1, roles[2] do
		if #spawns < 1 then
			spawns = table.Copy( SPAWN_CLASSD )
		end

		ply = table.remove( players, math.random( 1, #players ) )
		spawn = table.remove( spawns, math.random( 1, #spawns ) )

		ply:SetInfectMTF()
		ply:SetPos( spawn )
	end

	for i = 1, roles[3] do
		if #spawns < 1 then
			spawns = table.Copy( SPAWN_CLASSD )
		end

		ply = table.remove( players, math.random( 1, #players ) )
		spawn = table.remove( spawns, math.random( 1, #spawns ) )

		ply:SetInfectD()
		ply:SetPos( spawn )
	end

	for i, v in pairs(player.GetAll()) do
		if v:GTeam() == TEAM_SCP and v:GetRoleName() == "Spectator" then
			v:SetupNormal()
			v:SetSpectator()
		end
	end

	net.Start("RolesSelected")
	net.Broadcast()
end
