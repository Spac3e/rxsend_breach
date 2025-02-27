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
--[[-------------------------------------------------------------------------

								READ CAREFULLY!

Now to add SCP you have to call RegisterSCP() inside 'RegisterSCP' hook
Therefore if you only want to add SCPs, you don't have to reupload gamemode! Use hook instead and
place files in 'lua/autorun/server/'!


Basic infotmations about RegisterSCP():
	

	RegisterSCP( name, model, weapon, static_stats, dynamic_stats, callback, post_callback )


		name (String) - name of SCP, it will be used by most things. This function will automatically add
			every necessary variablesso you no longer have to care about ROLES table(function will
			create ROLES.ROLE_name = name). Funtion will look for valid language and spawnpos entries
			(for language: english.ROLES.ROLE_name and english.starttexts.ROLE_name, for
			spawnpos: SPAWN_name = Vector or Table of vectors). Function will throw error if something
			is wrong(See errors section below)


		model (String) - full path to model. If you put wrong path you will see error instead of model!


		weapon (String) - SWEP call name. If you put wrong name your scp will not receive weapon and you
			will see red error in console


		static_stats (Table) - this table contain important entries for your SCP. Things specified inside
			this table are more important than dynamic_stats, so it will overwrite them. These stats cannot
			be changed in 'scp.txt' file. This table cotains keys and values(key = "value"). List of valid keys is below.


		dynamic_stats (Table) - this table contains entries for your SCP that can be accessed and changed in
			'garrysmod/data/breach/scp.txt' file. So everybody can customize them. These stats will be overwritten
			by statc_stats. This table cotains keys and values(key = "value") or tables that contains value and
			clamping info(num values only!)(key = "value" or key = { var = num_value, max = max_value, min = minimum_value }).
			List of valid keys is below. 

					Valid entreis for static_stats and dynamic_stats:
							base_speed - walk speed
							run_speed - run speed
							max_speed - maximum speed
							base_health - starting health
							max_health - maximum health
							jump_power - jump power
							crouch_speed - crouched walk speed
							no_ragdoll - if true, rgdoll will not appear
							model_scale - scale of model
							hands_model - model of hands
							prep_freeze - if true, SCP will not be able to move during preparing
							no_spawn - position will not be changed
							no_model - model will not be changed
							no_swep - SCP won't have SWEP
							no_strip - player EQ won't be stripped
							no_select - SCP won't appear in game


		callback (Function) - called on beginning of SetupPlayer return true to override default actions(post callback will not be called).
			function( ply, basestats, ... ) - 3 arguments are passed:
				ply - player
				basestats - result of static_stats and dynamic_stats
				... - (varargs) passsed from SetupPlayer
		

		post_callback (Function) - called on end of SetupPlayer. Only player is passed as argument:
			function( ply )
				ply - player


To get registered SCP:
		GetSCP( name ) - global function that returns SCP object
			arguments:
				name - name of SCP(same as used in RegisterSCP)

			return:
				ObjectSCP - (explained below)

	ObjectSCP:
		functions:
			ObjectSCP:SetCallback( callback, post ) - used internally by RegisterSCP. Sets callback, if post == true, sets post_callback

			ObjectSCP:SetupPlayer( ply, ... ) - use to set specified player as SCP.
					ply - player who become SCP
					... - varargs passed to callback if ObjectSCP has one

---------------------------------------------------------------------------]]

hook.Add( "RegisterSCP", "RegisterBaseSCPs", function()

	RegisterSCP( "SCP049", "models/cultist/scp/scp_049.mdl", {"weapon_scp_049_redux"}, {
		jump_power = 100,
		no_spawn = true,
		--damagemodifier = 0.2,
		base_health = 2500,
		max_health = 2500,
		base_speed = 80,
		run_speed =80,
		max_speed = 80,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.65,
				["HITGROUP_CHEST"] = 0.65,
				["HITGROUP_LEFTARM"] = 0.65,
				["HITGROUP_RIGHTARM"] = 0.65,
				["HITGROUP_STOMACH"] = 0.65,
				["HITGROUP_GEAR"] = 0.65,
				["HITGROUP_LEFTLEG"] = 0.65,
				["HITGROUP_RIGHTLEG"] = 0.65
			},
	}, {
	}, nil, function(ply)
		ply:SetPos(Vector(7480.477051, -396.929413, 0.031250))
	end )


	--
	RegisterSCP( "SCP912", "models/cultist/scp/scp_912.mdl", {"weapon_scp_912"}, {
		jump_power = 100,
		damagemodifier = 0.1,
		base_health = 400,
		max_health = 400,
		base_speed = 115,
		run_speed = 115,
		max_speed = 115,
		scaledamage = {
				["HITGROUP_HEAD"] = 1,
				["HITGROUP_CHEST"] = 1,
				["HITGROUP_LEFTARM"] = 0.75,
				["HITGROUP_RIGHTARM"] = 0.75,
				["HITGROUP_STOMACH"] = 1,
				["HITGROUP_GEAR"] = 0.7,
				["HITGROUP_LEFTLEG"] = 1,
				["HITGROUP_RIGHTLEG"] = 1
			},
	}, {
	})

	--[[RegisterSCP( "SCP035", "models/cultist/scp/scp_035.mdl", {""}, {

		no_spawn = true,
		no_model = true,
		no_strip = true,
		no_select = true,
		scaledamage = {
				["HITGROUP_HEAD"] = 0,
				["HITGROUP_CHEST"] = 0,
				["HITGROUP_LEFTARM"] = 0,
				["HITGROUP_RIGHTARM"] = 0,
				["HITGROUP_STOMACH"] = 0,
				["HITGROUP_GEAR"] = 0,
				["HITGROUP_LEFTLEG"] = 0,
				["HITGROUP_RIGHTLEG"] = 0
			},
	}, {
	}, function(ply) ply.SelectedSCPAlready = true end)]]
	--[[

	RegisterSCP( "SCP1015RU", "models/cultist/scp/1015ru.mdl", {"weapon_scp_1015ru"}, {
		jump_power = 100,
	}, {
		base_health = 1800,
		max_health = 1800,
		base_speed = 100,
		run_speed = 100,
		max_speed = 100,
	})]]

	RegisterSCP( "SCP062DE", "models/cultist/scp/scp_062de.mdl", {}, {
		jump_power = 100,
		--damagemodifier = 0.7,
		no_swep = true,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.9,
				["HITGROUP_CHEST"] = 0.3,
				["HITGROUP_LEFTARM"] = 0.3,
				["HITGROUP_RIGHTARM"] = 0.3,
				["HITGROUP_STOMACH"] = 0.3,
				["HITGROUP_GEAR"] = 0.3,
				["HITGROUP_LEFTLEG"] = 0.3,
				["HITGROUP_RIGHTLEG"] = 0.3
			},
	}, {
		base_health = 2200,
		max_health = 2200,
		base_speed = 100,
		run_speed = 100,
		max_speed = 100,
	}, nil, function(ply)
		timer.Simple(1, function()
			if IsValid(ply) and ply:GetRoleName() == "SCP062DE" and !ply:IsPremium() then
				ply:SendLua("SCP062de_Menu()")
			end
		end)
	end)
	--[[
	RegisterSCP( "SCP1027RU", "models/cultist/scp/scp_1027ru.mdl", {"weapon_scp_1027_ru"}, {
		jump_power = 100,
	}, {
		base_health = 4000,
		max_health = 4000,
		base_speed = 50,
		run_speed = 50,
		max_speed = 50,
	})
	--]]
--[[
	RegisterSCP( "SCP035", "models/cultist/scp/scp_035.mdl", {"weapon_scp_035"}, {
		jump_power = 100,
	}, {
		base_health = 1500,
		max_health = 1500,
		base_speed = 75,
		run_speed = 75,
		max_speed = 75,
	} )
	--]]
	RegisterSCP( "SCP638", "models/cultist/scp/scp638/scp_638.mdl", {"weapon_scp_638"}, {
		jump_power = 20,
		--damagemodifier = 0.35,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.45,
				["HITGROUP_CHEST"] = 0.45,
				["HITGROUP_LEFTARM"] = 0.45,
				["HITGROUP_RIGHTARM"] = 0.45,
				["HITGROUP_STOMACH"] = 0.45,
				["HITGROUP_GEAR"] = 0.45,
				["HITGROUP_LEFTLEG"] = 0.45,
				["HITGROUP_RIGHTLEG"] = 0.45
			},
	}, {
		base_health = 2800,
		max_health = 2800,
		base_speed = 50,
		run_speed = 90,
		max_speed = 90,
	} )
	--
	RegisterSCP( "SCP062FR", "models/cultist/scp/scp_062fr_new.mdl", {"weapon_scp_062"}, {
		jump_power = 20,
		scaledamage = {
			   ["HITGROUP_HEAD"] = 1.0,
			   ["HITGROUP_CHEST"] = 1.0,
			   ["HITGROUP_LEFTARM"] = 1.0,
			   ["HITGROUP_RIGHTARM"] = 1.0,
			   ["HITGROUP_STOMACH"] = 1.0,
			   ["HITGROUP_GEAR"] = 1.0,
			   ["HITGROUP_LEFTLEG"] = 1.0,
			   ["HITGROUP_RIGHTLEG"] = 1.0
		    },
	},	{
		base_health = 1500,
		max_health = 1500,
		base_speed = 100,
		run_speed = 100,
		max_speed = 200,
	} )
	--

	RegisterSCP( "SCP076", "models/cultist/scp/scp_076.mdl", {"weapon_scp_076"}, {
		jump_power = 200,
		prep_freeze = true,
		base_health = 1000,
		max_health = 1000,
		base_speed = 180,
		run_speed = 180,
		max_speed = 180,
	}, {
	}, nil, function( ply )
		--SetupSCP0761( ply )
	end)

	RegisterSCP( "SCP106", "models/cultist/scp/scp_106.mdl", {"weapon_scp_106"}, {
		jump_power = 200,
		no_spawn = true,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.6,
				["HITGROUP_CHEST"] = 0.6,
				["HITGROUP_LEFTARM"] = 0.6,
				["HITGROUP_RIGHTARM"] = 0.6,
				["HITGROUP_STOMACH"] = 0.6,
				["HITGROUP_GEAR"] = 0.6,
				["HITGROUP_LEFTLEG"] = 0.6,
				["HITGROUP_RIGHTLEG"] = 0.6
			},
	}, {
		base_health = 4500,
		max_health = 4500,
		base_speed = 100,
		run_speed = 100,
		max_speed = 100,
	}, nil, function(ply)
		ply:SetPos(Vector(7083.2299804688, 4222.74609375, -447.96875))
	end )
	--[[
	RegisterSCP( "SCP8602", "models/cultist/scp/scp_860.mdl", {"weapon_scp_8602"}, {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 2250,
		max_health = 2250,
		base_speed = 190,
		run_speed = 190,
		max_speed = 190,
	} )
	--]]
	--
	RegisterSCP( "SCP096", "models/cultist/scp/scp_096.mdl", {"weapon_scp096"}, {
		jump_power = 200,
		prep_freeze = true,
		--no_spawn = true,
		base_health = 4000,
		max_health = 4000,
		damagemodifier = 0.1,
		deathanimation = "COWER",
		deathloop = true,
		base_speed = 40,
		run_speed = 40,
		max_speed = 40,
	}, {
	}, nil)

	RegisterSCP( "SCP542", "models/cultist/scp/scp_542.mdl", {"weapon_scp_542"}, {
		jump_power = 200,
		prep_freeze = true,
		base_health = 3000,
		--damagemodifier = 0.85,
		max_health = 3000,
		base_speed = 150,
		run_speed = 150,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.45,
				["HITGROUP_CHEST"] = 0.45,
				["HITGROUP_LEFTARM"] = 0.45,
				["HITGROUP_RIGHTARM"] = 0.45,
				["HITGROUP_STOMACH"] = 0.45,
				["HITGROUP_GEAR"] = 0.45,
				["HITGROUP_LEFTLEG"] = 0.45,
				["HITGROUP_RIGHTLEG"] = 0.45
			},
		max_speed = 150,
	}, {
	} )

	RegisterSCP( "SCP999", "models/cultist/scp/scp_999_new.mdl", {"weapon_scp_999"}, {
		jump_power = 200,
		prep_freeze = true,
		base_health = 1300,
		damagemodifier = 0.35,
		max_health = 1300,
		model_scale = 0.6,
		base_speed = 165,
		--no_spawn = true,
		deathanimation = "die",
		deathloop = true,
		run_speed = 165,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.6,
				["HITGROUP_CHEST"] = 0.6,
				["HITGROUP_LEFTARM"] = 0.6,
				["HITGROUP_RIGHTARM"] = 0.6,
				["HITGROUP_STOMACH"] = 0.6,
				["HITGROUP_GEAR"] = 0.6,
				["HITGROUP_LEFTLEG"] = 0.6,
				["HITGROUP_RIGHTLEG"] = 0.6
			},
		max_speed = 150,
	}, {
	}, nil, function(ply)
		--ply:SetPos(Vector(8847.445312, -5702.301270, 2.331253))
	end )

	RegisterSCP( "SCP1903", "models/cultist/scp/scp_1903.mdl", {"weapon_scp_1903"}, {
		jump_power = 200,
		prep_freeze = true,
		base_health = 3100,
		max_health = 3100,
		--damagemodifier = 0.6,
		base_speed = 100,
		run_speed = 100,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.65,
				["HITGROUP_CHEST"] = 0.65,
				["HITGROUP_LEFTARM"] = 0.65,
				["HITGROUP_RIGHTARM"] = 0.65,
				["HITGROUP_STOMACH"] = 0.65,
				["HITGROUP_GEAR"] = 0.65,
				["HITGROUP_LEFTLEG"] = 0.65,
				["HITGROUP_RIGHTLEG"] = 0.65
			},
		max_speed = 100,
	}, {
	} )

	RegisterSCP( "SCP973", "models/cultist/scp/scp_973/scp_973.mdl", {"weapon_scp_973"}, {
		jump_power = 200,
		prep_freeze = true,
		--damagemodifier = 0.35,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.65,
				["HITGROUP_CHEST"] = 0.65,
				["HITGROUP_LEFTARM"] = 0.65,
				["HITGROUP_RIGHTARM"] = 0.65,
				["HITGROUP_STOMACH"] = 0.65,
				["HITGROUP_GEAR"] = 0.65,
				["HITGROUP_LEFTLEG"] = 0.65,
				["HITGROUP_RIGHTLEG"] = 0.65
			},
	}, {
		base_health = 3700,
		max_health = 3700,
		base_speed = 100,
		run_speed = 100,
		max_speed = 100,
	} )

	
	RegisterSCP( "SCP457", "models/cultist/scp/scp_457.mdl", {"weapon_scp_457"}, {
		jump_power = 200,
		prep_freeze = true,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.6,
				["HITGROUP_CHEST"] = 0.6,
				["HITGROUP_LEFTARM"] = 0.6,
				["HITGROUP_RIGHTARM"] = 0.6,
				["HITGROUP_STOMACH"] = 0.6,
				["HITGROUP_GEAR"] = 0.6,
				["HITGROUP_LEFTLEG"] = 0.6,
				["HITGROUP_RIGHTLEG"] = 0.6
			},
	}, {
		base_health = 2300,
		max_health = 2300,
		base_speed = 90,
		deathanimation = "457_death",
		deathloop = true,
		run_speed = 90,
		max_speed = 90,
	} )

	--[[
	RegisterSCP( "SCP8602", "models/cultist/scp/scp_860.mdl", {"weapon_scp_860"}, {
		jump_power = 200,
		prep_freeze = true,
		base_health = 2500,
		max_health = 2500,
		deathanimation = "z_death_cock",
		deathloop = false,
		base_speed = 190,
		run_speed = 190,
		max_speed = 190,
		no_spawn = true,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.4,
				["HITGROUP_CHEST"] = 0.4,
				["HITGROUP_LEFTARM"] = 0.4,
				["HITGROUP_RIGHTARM"] = 0.4,
				["HITGROUP_STOMACH"] = 0.4,
				["HITGROUP_GEAR"] = 0.4,
				["HITGROUP_LEFTLEG"] = 0.4,
				["HITGROUP_RIGHTLEG"] = 0.4
			},
	}, {
		base_health = 2500,
		max_health = 2500,
		base_speed = 190,
		deathanimation = "z_death_cock",
		deathloop = false,
		run_speed = 190,
		max_speed = 190,
	}, nil, function(ply)
		ply:RXSENDNotify("l:scp860_first_msg")
		ply:RXSENDNotify("l:scp860_second_msg")
		ply:SetPos(Vector(10766.436523, -11217.120117, -3396.127441))
	end)]]
--[[
	RegisterSCP( "SCP173", "models/cultist/scp/173.mdl", {"weapon_scp_173"}, {
		jump_power = 200,
		prep_freeze = true,
		no_draw = true,
		no_spawn = true,
	}, {
		base_health = 5400,
		max_health = 5400,
		base_speed = 250,
		run_speed = 250,
		max_speed = 250,
	}, nil, function( ply )
		ply:SetPos(Vector(6307.718262, -3212.505371, 129.331268))
	end )]]
	
	RegisterSCP( "SCP2012", "models/shaky/scp/scp2012/scp_2012.mdl", {"weapon_scp_2012", "weapon_scp_2012_crossbow"}, {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 2001,
		max_health = 2001,
		base_speed = 200,
		run_speed = 200,
		max_speed = 200,
	} )

	RegisterSCP( "SCP082", "models/cultist/scp/scp_082.mdl", {"weapon_scp_082"}, {
		jump_power = 200,
		prep_freeze = true,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.3,
				["HITGROUP_CHEST"] = 0.3,
				["HITGROUP_LEFTARM"] = 0.3,
				["HITGROUP_RIGHTARM"] = 0.3,
				["HITGROUP_STOMACH"] = 0.3,
				["HITGROUP_GEAR"] = 0.3,
				["HITGROUP_LEFTLEG"] = 0.3,
				["HITGROUP_RIGHTLEG"] = 0.3
			},
	}, {
		base_health = 2000,
		max_health = 2000,
		base_speed = 100,
		run_speed = 100,
		deathanimation = "death_loot",
		deathloop = true,
		max_speed = 100,
	} )

	RegisterSCP( "SCP939", "models/cultist/scp/scp_939.mdl", {"weapon_scp_939"}, {
		jump_power = 200,
		prep_freeze = true,
		damagemodifier = 0.2,
		scaledamage = {
				["HITGROUP_HEAD"] = 0.3,
				["HITGROUP_CHEST"] = 0.3,
				["HITGROUP_LEFTARM"] = 0.3,
				["HITGROUP_RIGHTARM"] = 0.3,
				["HITGROUP_STOMACH"] = 0.3,
				["HITGROUP_GEAR"] = 0.3,
				["HITGROUP_LEFTLEG"] = 0.3,
				["HITGROUP_RIGHTLEG"] = 0.3
			},
	}, {
		base_health = 2500,
		max_health = 2500,
		base_speed = 120,
		deathanimation = "die",
		deathloop = true,
		run_speed = 120,
		max_speed = 120,
	} )
--
	RegisterSCP( "SCP811", "models/cultist/scp/scp_811.mdl", {"weapon_scp_811"}, {
		jump_power = 200,
		prep_freeze = true,
	}, {
		base_health = 2700,
		max_health = 2700,
		base_speed = 120,
		run_speed = 120,
		max_speed = 120,
	} )

	RegisterSCP( "SCP682", "models/cultist/scp/scp_682.mdl", {"weapon_scp_682"}, {
		jump_power = 200,
		prep_freeze = true,
		no_spawn = true
	}, {
		base_health = 6000,
		max_health = 6000,
		base_speed = 120,
		deathanimation = "0_Death_64",
		deathloop = true,
		run_speed = 120,
		max_speed = 120,
	}, nil, function(ply)
		ply:SetPos(Vector(2064.8991699219, 3010.1586914063, -383.96875))
	end )

end )

function SetupSCP0761( ply )
	if !IsValid( SCP0761 ) then
		cspawn076 = SPAWN_SCP076
		SCP0761 = ents.Create( "item_scp_0761" )
		SCP0761:Spawn()
		SCP0761:SetPos( cspawn076 )
	end
	ply:SetPos( cspawn076 )
end