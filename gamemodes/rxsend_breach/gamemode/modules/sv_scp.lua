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
SCPObjects = {}
SCPNoSelectObjects = {}
TransmitSCPS = {}

SCP_VALID_ENTRIES = {
	base_speed = true,
	run_speed = true,
	max_speed = true,
	base_health = true,
	max_health = true,
	jump_power = true,
	crouch_speed = true,
	no_ragdoll = true,
	deathanimation = true,
	model_scale = true,
	hands_model = true,
	prep_freeze = true,
	no_spawn = true,
	no_model = true,
	no_swep = true,
	no_strip = true,
	scaledamage = true,
	deathloop = true,
	damagemodifier = true,
	no_select = true,
	no_draw = true,
}

SCP_DYNAMIC_VARS = {}

local lua_override = false

function UpdateDynamicVars()
	print( "Updating SCPs dynamic vars" )
	if !file.Exists( "breach", "DATA" ) then
		file.CreateDir( "breach" )
	end
	if !file.Exists( "breach/scp.txt", "DATA" ) then
		util.WriteINI( "breach/scp.txt", {} )
	end

	if lua_override then
		print( "Dev mode is enabled! Overwritting INI values..." )
	else
		util.LoadINI( "breach/scp.txt", SCP_DYNAMIC_VARS )
	end
end

UpdateDynamicVars()

function SaveDynamicVars()
	util.WriteINI( "breach/scp.txt", SCP_DYNAMIC_VARS )
end

function SendSCPList( ply )
	net.Start( "SCPList" )
		net.WriteTable( SCPS )	
		net.WriteTable( TransmitSCPS )
	net.Send( ply )
end

function GetSCP( name )
	return SCPObjects[name] or SCPNoSelectObjects[name]
end

function RegisterSCP( name, model, weapon, static_stats, dynamic_stats, custom_callback, post_callback )
	--RegisterSCP( "name", "path_to_model", "SWEP_class_name", {entry = value} )
	if !name or !model or !weapon or !static_stats then return end

	dynamic_stats = dynamic_stats or {}

	if SCPObjects[name] then
		error( "SCP " .. name .. "is already registered!" )
	end

	local rolename = name
	if !ALLLANGUAGES["english"]["role"][rolename] then
		error( "No language entry for: "..rolename )
	end

	local spawn = _G["SPAWN_"..name]
	if !static_stats.no_spawn and !dynamic_stats.no_spawn then
		if !spawn or ( !isvector( spawn ) and !istable( spawn ) ) then
			print( "No spawn position entry for: ".."SPAWN_"..name..", returning to default spawn table" )
			pos = false
		else
			pos = spawn
		end
	end
	ObjectSCP:Create( name, model, weapon, pos, static_stats, dynamic_stats )
	rolename = name

	local scp = ObjectSCP( name, model, weapon, spawn, static_stats, dynamic_stats )

	if custom_callback and isfunction( custom_callback ) then
		scp:SetCallback( custom_callback )
	end

	if post_callback and isfunction( post_callback ) then
		scp:SetCallback( post_callback, true )
	end

	if !scp.basestats.no_select then
		SCPObjects[name] = scp
		table.insert( SCPS, name )
	else
		SCPNoSelectObjects[name] = scp
		table.insert( TransmitSCPS, name )
	end

	print( name.." has been registered!" )
	return true
end


-----SCP class-----
ObjectSCP = {}
ObjectSCP.__index = ObjectSCP

/*ObjectSCP.name = ""
ObjectSCP.basestats = {}
ObjectSCP.callback = function() end
ObjectSCP.post = function() end
ObjectSCP.swep = ""
ObjectSCP.model = ""
ObjectSCP.spawnpos = nil*/

function ObjectSCP:Create( name, model, weapon, pos, static_stats, dynamic_stats )
	local scp = setmetatable( {}, ObjectSCP )
	scp.Create = function() end

	scp.name = name
	scp.model = model
	scp.swep = weapon
	scp.spawnpos = pos
	scp.basestats = {}

	scp.callback = function() end
	scp.post = function() end

	if !SCP_DYNAMIC_VARS[name] then
		SCP_DYNAMIC_VARS[name] = {}
	end

	local dv = SCP_DYNAMIC_VARS[name]

	for k, v in pairs( dynamic_stats ) do
		if SCP_VALID_ENTRIES[k] then
			local istab = istable( v )
			local var = istab and v.var or v

			if dv[k] then
				var = dv[k]
			else
				dv[k] = var
			end

			if istab then
				if v.min or v.max then
					if !isnumber( var ) then
						ErrorNoHalt( name.." entry: "..k..". Number expected, got "..type( var ) )
						continue
					end

					if v.min then
						var = math.max( v.min, var )
					end

					if v.max then
						var = math.min( v.max, var )
					end
				end
			end

			scp.basestats[k] = var
		else
			print( "Invalid dynamic stat entry '"..k.."' for "..name )
		end
	end

	for k, v in pairs( static_stats ) do
		if SCP_VALID_ENTRIES[k] then
			scp.basestats[k] = v
		else
			print( "Invalid static stat entry '"..k.."' for "..name )
		end
	end

	return scp
end

function ObjectSCP:SetCallback( cb, post )
	if post then
		self.post = cb
	else
		self.callback = cb
	end
end

function ObjectSCP:SetupPlayer( ply, ... )
	if self.callback then
		if self.callback( ply, self.basestats, ... ) then
			return
		end
	end

	ply:UnSpectate()
	ply:GodDisable()
	if !self.basestats.no_strip then
		ply:StripWeapons()
		ply:RemoveAllAmmo()
	end

	ply.no_spawn = self.basestats.no_spawn == true

	local pos = self.spawnpos or SPAWN_SCP_RANDOM
	if !self.basestats.no_spawn then
		--if istable( pos ) then
			--pos = table.Random( pos )
			if !SPAWN_SCP_RANDOM_COPY or #SPAWN_SCP_RANDOM_COPY <= 0 then
				SPAWN_SCP_RANDOM_COPY = table.Copy(SPAWN_SCP_RANDOM)
			end
			local spawn = table.remove( SPAWN_SCP_RANDOM_COPY, math.random( 1, #SPAWN_SCP_RANDOM_COPY ) )
		--end
		ply:Spawn()
		if isvector(spawn) then
			ply:SetPos( spawn )
		end
	end

	ply:SetGTeam( TEAM_SCP )
	ply:SetRoleName( self.name )

	if !self.basestats.no_model then
		ply:SetModel( self.model )
	end

	if !self.basestats.damagemodifier then
		ply.DamageModifier = 0.15
	else
		ply.DamageModifier = self.basestats.damagemodifier
	end

	ply:SetModelScale( self.basestats.model_scale or 1 )

	local roletable = GetLangRole(self.name)

	for _, role in ipairs(BREACH_ROLES.SCP.scp.roles) do
		if role.name == roletable then
			roletable = role
			break
		end
	end

	if istable(roletable) then
		ply:SetHealth( roletable["health"] )
		ply:SetMaxHealth( roletable["health"] )
	else
		ply:SetHealth( self.basestats.base_health or 1500 )
		ply:SetMaxHealth( self.basestats.max_health or 1500 )
	end
	ply:SetWalkSpeed( self.basestats.base_speed or 200 )
	ply:SetSlowWalkSpeed( self.basestats.base_speed or 200 )
	ply:SetRunSpeed( self.basestats.run_speed or 200 )
	ply:SetMaxSpeed( self.basestats.max_speed or 200 )
	ply:SetCrouchedWalkSpeed( self.basestats.crouch_speed or 0.6 )
	ply:SetJumpPower( 0 )--self.basestats.jump_power or 200 )

	if self.basestats.deathanimation then
		ply.DeathAnimation = self.basestats.deathanimation
	end

	if self.basestats.deathloop then
		ply.DeathLoop = self.basestats.deathloop
	end

	if self.basestats.scaledamage then
		ply.ScaleDamage = self.basestats.scaledamage
	end

	ply.StartedPlayAt = CurTime() + 100

	if !self.basestats.no_swep then
		for k, v in pairs( self.swep ) do
			ply.JustSpawned = true
			ply:Give( v )
			timer.Simple( .1, function()
				ply.JustSpawned = false 
			end)
		end

		ply:SelectWeapon( self.swep[1] )

		if IsValid( wep ) then
			wep.ShouldFreezePlayer = self.basestats.prep_freeze == true
		end
	end

		ply:SetArmor( 0 )

		ply:Flashlight( false )
		ply:AllowFlashlight( false )
	ply:SetNoDraw( self.basestats.no_draw == true )
	ply:SetNoTarget( true )

	ply.BaseStats = nil
	ply.UsingArmor = nil

	ply.Active = true
	ply.canblink = false
	ply.noragdoll = self.basestats.no_ragdoll == true

	ply.handsmodel = self.basestats.hands_model
	ply:SetupHands()

	hook.Run( "PlayerWeaponChanged", ply, ply:GetActiveWeapon(), true )

	net.Start( "RolesSelected" )
	net.Send( ply )

	if ply:IsPremium() and ply.SelectedSCPAlready != true then
		timer.Simple(0.65, function()
			if !IsValid(ply) then return end
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
		end)
	end

	if self.post then
		self.post( ply )
	end
end

setmetatable( ObjectSCP, { __call = ObjectSCP.Create } )
--------------------------------------------------------------------------------

timer.Simple( 0, function()
	hook.Run( "RegisterSCP" )
	SaveDynamicVars()
	--InitializeBreachULX()
	--SetupForceSCP()
	for k, v in pairs( player.GetAll() ) do
		SendSCPList( v )
	end
end )