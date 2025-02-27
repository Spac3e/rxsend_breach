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

function SetupInfect( ply )
	if !SERVER then return end
	local roles = { }
	roles[1] = math.ceil( ply * 0.166 )
	ply = ply - roles[1]
	roles[2] = math.Round( ply * 0.333 )
	ply = ply - roles[2]
	roles[3] = ply
	ply = 0
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
	ply, spawn = nil, nil
	for i = 1, roles[2] do
		if #spawns < 1 then
			spawns = table.Copy( SPAWN_CLASSD )
		end
		ply = table.remove( players, math.random( 1, #players ) )
		spawn = table.remove( spawns, math.random( 1, #spawns ) )
		ply:SetInfectMTF()
		ply:SetPos( spawn )
	end
	ply, spawn = nil, nil
	for i = 1, roles[3] do
		if #spawns < 1 then
			spawns = table.Copy( SPAWN_CLASSD )
		end
		ply = table.remove( players, math.random( 1, #players ) )
		spawn = table.remove( spawns, math.random( 1, #spawns ) )
		ply:SetInfectD()
		ply:SetPos( spawn )
	end
	net.Start("RolesSelected")
	net.Broadcast()
end

/*function SetupMultiBreach( pltab )
	if !SERVER then return end
	local allply = GetActivePlayers()
	
	// SCPS
	local scprole = table.Random( SPCS )
	for i=1, pltab[1] do
		local pl = table.Random(allply)
		if IsValid(pl) == false then return end
		scprole["func"](pl)
		print("assigning " .. pl:Nick() .. " to scps")
		table.RemoveByValue(allply, pl)
	end
	
	// Class D Personell
	local dspawns = table.Copy(SPAWN_CLASSD)
	for i=1, pltab[3] do
		if #dspawns < 1 then
			dspawns = table.Copy(SPAWN_CLASSD)
		end
		if #dspawns > 0 then
			local pl = table.Random(allply)
			if IsValid(pl) == false then return end
			local spawn = table.Random(dspawns)
			pl:SetupNormal()
			pl:SetClassD()
			pl:SetPos(spawn)
			print("assigning " .. pl:Nick() .. " to classds")
			table.RemoveByValue(dspawns, spawn)
			table.RemoveByValue(allply, pl)
		end
	end
	
	// Researchers
	local resspawns = table.Copy(SPAWN_SCIENT)
	for i=1, pltab[4] do
		if #resspawns < 1 then
			resspawns = table.Copy(SPAWN_SCIENT)
		end
		if #resspawns > 0 then
			local pl = table.Random(allply)
			if IsValid(pl) == false then return end
			local spawn = table.Random(resspawns)
			pl:SetupNormal()
			pl:SetResearcher()
			pl:SetPos(spawn)
			print("assigning " .. pl:Nick() .. " to researchers")
			table.RemoveByValue(resspawns, spawn)
			table.RemoveByValue(allply, pl)
		end
	end
	
	// Security
	local security = BREACH_ROLES["MTF"]["mtf"]["roles"]
	local snum = pltab[2]
	local securityspawns = table.Copy(SPAWN_GUARD)
	
	local i4 = math.floor(snum / GetConVar("br_i4_min_mtf"):GetInt())
	
	local i4roles = {}
	local i4players = {}
	local i3roles = {}
	local i3players = {}
	local i2roles = {}
	local i2players = {}
	for k,v in pairs(security) do
		if v.importancelevel == 4 then
			table.ForceInsert(i4roles, v)
		elseif v.importancelevel == 3 then
			table.ForceInsert(i3roles, v)
		elseif v.importancelevel == 2 then
			table.ForceInsert(i2roles, v)
		end
	end
	
	for _,pl in pairs(allply) do
		for k,v in pairs(security) do
			if v.importancelevel > 1 then
				local can = true
				if v.customcheck != nil then
					if v.customcheck(pl) == false then
						can = false
					end
				end
				if can == true then
					if pl:GetLevel() >= v.level then
						if v.importancelevel == 2 then
							table.ForceInsert(i2players, pl)
						elseif v.importancelevel == 3 then
							table.ForceInsert(i3players, pl)
						else
							table.ForceInsert(i4players, pl)
						end
					end
				end
			end
		end
	end
	
	if i4 >= 1 then
		if #i4roles > 0 and #i4players > 0 then
			local pl = table.Random(i4players)
			local spawn = table.Random(securityspawns)
			pl:SetupNormal()
			pl:ApplyRoleStats(table.Random(i4roles))
			table.RemoveByValue(i4players, pl)
			table.RemoveByValue(i3players, pl)
			table.RemoveByValue(i2players, pl)
			pl:SetPos(spawn)
			print("assigning " .. pl:Nick() .. " to security i4")
			table.RemoveByValue(securityspawns, spawn)
			table.RemoveByValue(allply, pl)
		end
	end

	if #i3roles > 0 and #i3players > 0 then
		local pl = table.Random(i3players)
		local spawn = table.Random(securityspawns)
		pl:SetupNormal()
		pl:ApplyRoleStats(table.Random(i3roles))
		table.RemoveByValue(i4players, pl)
		table.RemoveByValue(i3players, pl)
		table.RemoveByValue(i2players, pl)
		pl:SetPos(spawn)
		print("assigning " .. pl:Nick() .. " to security i3")
		table.RemoveByValue(securityspawns, spawn)
		table.RemoveByValue(allply, pl)
	end
	
	if #i2roles > 0 and #i2players > 0 then
		local pl = table.Random(i2players)
		local spawn = table.Random(securityspawns)
		pl:SetupNormal()
		pl:ApplyRoleStats(table.Random(i2roles))
		pl:SetPos(spawn)
		table.RemoveByValue(i4players, pl)
		table.RemoveByValue(i3players, pl)
		table.RemoveByValue(i2players, pl)
		print("assigning " .. pl:Nick() .. " to security i2")
		table.RemoveByValue(securityspawns, spawn)
		table.RemoveByValue(allply, pl)
	end
	
	for k,v in pairs(allply) do
		if #securityspawns < 1 then
			securityspawns = table.Copy(SPAWN_GUARD2)
		end
		local spawn = table.Random(securityspawns)
		v:SetupNormal()
		v:SetSecurityI1()
		v:SetPos(spawn)
		print("assigning " .. v:Nick() .. " to security i1")
		table.RemoveByValue(securityspawns, spawn)
	end
	net.Start("RolesSelected")
	net.Broadcast()
end*/

function SetupMultiBreach(pltab)
	local allply = GetActivePlayers()
	
	// SCPS
	local scp = table.Random( SCPS )
	for i=1, pltab[1] do
		local pl = table.Random(allply)
		if IsValid(pl) == false then continue end
		--scp["func"](pl)
		GetSCP( scp ):SetupPlayer( pl )
		print("assigning " .. pl:Nick() .. " to scps")
		table.RemoveByValue(spctab, scp)
		table.RemoveByValue(allply, pl)
	end
	
	// Class D Personell
	local dspawns = table.Copy(SPAWN_CLASSD)
	for i=1, pltab[3] do
		if #dspawns < 1 then
			dspawns = table.Copy(SPAWN_CLASSD)
		end
		if #dspawns > 0 then
			local pl = table.Random(allply)
			if IsValid(pl) == false then continue end
			local spawn = table.Random(dspawns)
			pl:SetupNormal()
			pl:SetClassD()
			pl:SetPos(spawn)
			print("assigning " .. pl:Nick() .. " to classds")
			table.RemoveByValue(dspawns, spawn)
			table.RemoveByValue(allply, pl)
		end
	end
	
	// Researchers
	local resspawns = table.Copy(SPAWN_SCIENT)
	for i=1, pltab[4] do
		if #resspawns < 1 then
			resspawns = table.Copy(SPAWN_SCIENT)
		end
		if #resspawns > 0 then
			local pl = table.Random(allply)
			if IsValid(pl) == false then continue end
			local spawn = table.Random(resspawns)
			pl:SetupNormal()
			pl:SetResearcher()
			pl:SetPos(spawn)
			print("assigning " .. pl:Nick() .. " to researchers")
			table.RemoveByValue(resspawns, spawn)
			table.RemoveByValue(allply, pl)
		end
	end
	
	// Security
	local security = BREACH_ROLES["MTF"]["mtf"]["roles"]
	local securityspawns = table.Copy(SPAWN_GUARD)
	
	local i4inuse = false
	for i = 1, pltab[2] do
		if #securityspawns < 1 then
			securityspawns = table.Copy(SPAWN_GUARD)
		end
		if #securityspawns > 0 then
			local pl = table.remove( allply, math.random( #allply ) )
			if !IsValid( pl ) then continue end
			local spawn = table.remove( securityspawns, math.random( #allply ) )
			local thebestone
			for k, v in pairs( BREACH_ROLES["MTF"]["mtf"]["roles"] ) do
				local useci = math.random( 1, 6 )
				local can = true
				if v.customcheck != nil then
					if !v.customcheck( self ) then
						can = false
					end
				end
				local using = 0
				for _, pl in pairs( player.GetAll() ) do
					if pl:GetRoleName() == v.name then
						using = using + 1
					end
				end
				if using >= v.max then
					can = false
				end
				if v.importancelevel == 4 and ( i < GetConVar( "br_i4_min_mtf" ):GetInt() or i4inuse ) then
					can = false
				end
				if can then
					if pl:GetLevel() >= v.level then
						if thebestone != nil then
							if thebestone.sorting < v.sorting then
								thebestone = v
							end
						else
							thebestone = v
						end
					else
						can = false
					end
				end
			end
			if !thebestone then
				thebestone = BREACH_ROLES["MTF"]["mtf"]["roles"][1]
			end
			if thebestone.name == ROLES.ROLE_MTFGUARD then
				if math.random( 1, 4 ) == 4 then
					for _, role in pairs( BREACH_ROLES["MTF"]["mtf"]["roles"] ) do
						if role.name == ROLES.ROLE_CHAOSSPY then
							thebestone = role
							break
						end
					end
				end
			end
			if useci == 6 then
				local fakeci = math.random( 1, 3 ) == 1
				for _, role in pairs( BREACH_ROLES["MTF"]["mtf"]["roles"] ) do
					local tofind = ROLES.ROLE_CHAOSSPY
					if fakeci then tofind = ROLES.ROLE_MTFGUARD end
					if role.name == tofind then
						thebestone = role
						break
					end
				end
			end
			if thebestone.importancelevel == 4 then
				i4inuse = true
			end
			pl:SetupNormal()
			pl:ApplyRoleStats( thebestone )
			pl:SetPos( spawn )
			print("assigning " .. pl:Nick() .. " to MTFs")
		end
	end
	
	net.Start("RolesSelected")
	net.Broadcast()
end