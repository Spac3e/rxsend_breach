local CATEGORY_NAME = "Fun"

------------------------------ Slay ------------------------------
function ulx.slay( calling_ply, v )
	local affected_plys = {}

	--for i=1, #target_plys do
		--local v = target_plys[ i ]

		v:Kill()
		table.insert( affected_plys, v )
		
		if v != calling_ply then AdminActionLog( calling_ply, v, "Slayed "..v:Name(), "" ) end

	--end

	ulx.fancyLogAdmin( calling_ply, "#A slayed #T", affected_plys )
end
local slay = ulx.command( CATEGORY_NAME, "ulx slay", ulx.slay, "!slay" )
slay:addParam{ type=ULib.cmds.PlayerArg }
slay:defaultAccess( ULib.ACCESS_ADMIN )
slay:help( "Slays target(s)." )

------------------------------ Sslay ------------------------------
function ulx.sslay( calling_ply, v )
	local affected_plys = {}

	--for i=1, #target_plys do
		--local v = target_plys[ i ]
			if v:InVehicle() then
				v:ExitVehicle()
			end

			v:LevelBar()

			v:SetupNormal()
			v:SetSpectator()

			v:RXSENDNotify("Вы были переведены в команду наблюдателей")
			table.insert( affected_plys, v )

			if v != calling_ply then AdminActionLog( calling_ply, v, "Silently Slayed "..v:Name(), "" ) end
	--end
end
local sslay = ulx.command( CATEGORY_NAME, "ulx sslay", ulx.sslay, "!sslay" )
sslay:addParam{ type=ULib.cmds.PlayerArg }
sslay:defaultAccess( ULib.ACCESS_ADMIN )
sslay:help( "Silently slays target(s)." )

------------------------------ God ------------------------------
function ulx.god( calling_ply, target_plys, should_revoke )
	if not target_plys[ 1 ]:IsValid() then
		if not should_revoke then
			Msg( "You are the console, you are already god.\n" )
		else
			Msg( "Your position of god is irrevocable; if you don't like it, leave the matrix.\n" )
		end
		return
	end

	local affected_plys = {}
	for i=1, #target_plys do
		local v = target_plys[ i ]

		if ulx.getExclusive( v, calling_ply ) then
			ULib.tsayError( calling_ply, ulx.getExclusive( v, calling_ply ), true )
		else
			if not should_revoke then
				v:GodEnable()
				v.ULXHasGod = true
			else
				v:GodDisable()
				v.ULXHasGod = nil
			end
			table.insert( affected_plys, v )
		end
	end

	if not should_revoke then
		ulx.fancyLogAdmin( calling_ply, "#A granted god mode upon #T", affected_plys )
	else
		ulx.fancyLogAdmin( calling_ply, "#A revoked god mode from #T", affected_plys )
	end
end
local god = ulx.command( CATEGORY_NAME, "ulx god", ulx.god, "!god" )
god:addParam{ type=ULib.cmds.PlayersArg, ULib.cmds.optional }
god:addParam{ type=ULib.cmds.BoolArg, invisible=true }
god:defaultAccess( ULib.ACCESS_ADMIN )
god:help( "Grants god mode to target(s)." )
god:setOpposite( "ulx ungod", {_, _, true}, "!ungod" )

------------------------------ Hp ------------------------------
function ulx.hp( calling_ply, target_plys, amount )
	for i=1, #target_plys do
		target_plys[ i ]:SetHealth( amount )
	end
	ulx.fancyLogAdmin( calling_ply, "#A set the hp for #T to #i", target_plys, amount )
end
local hp = ulx.command( CATEGORY_NAME, "ulx hp", ulx.hp, "!hp" )
hp:addParam{ type=ULib.cmds.PlayersArg }
hp:addParam{ type=ULib.cmds.NumArg, min=1, max=2^32/2-1, hint="hp", ULib.cmds.round }
hp:defaultAccess( ULib.ACCESS_ADMIN )
hp:help( "Sets the hp for target(s)." )

------------------------------ Maul ------------------------------
local zombieDeath -- We need these registered up here because functions reference each other.
local checkMaulDeath

local function newZombie( pos, ang, ply, b )
		local ent = ents.Create( "npc_fastzombie" )
		ent:SetPos( pos )
		ent:SetAngles( ang )
		ent:Spawn()
		ent:Activate()
		ent:AddRelationship("player D_NU 98") -- Don't attack other players
		ent:AddEntityRelationship( ply, D_HT, 99 ) -- Hate target

		ent:DisallowDeleting( true, _, true )
		ent:DisallowMoving( true )

		if not b then
			ent:CallOnRemove( "NoDie", zombieDeath, ply )
		end

		return ent
end

------------------------------ Strip ------------------------------
function ulx.stripweapons( calling_ply, target_plys )
	for i=1, #target_plys do
		target_plys[ i ]:StripWeapons()
	end

	ulx.fancyLogAdmin( calling_ply, "#A stripped weapons from #T", target_plys )
end
local strip = ulx.command( CATEGORY_NAME, "ulx strip", ulx.stripweapons, "!strip" )
strip:addParam{ type=ULib.cmds.PlayersArg }
strip:defaultAccess( ULib.ACCESS_ADMIN )
strip:help( "Strip weapons from target(s)." )
