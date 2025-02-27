-- code was kindfully provided by spac3

BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.Combat = BREACH.AdminLogs.Combat || {}
BREACH.AdminLogs._Combat_table = BREACH.AdminLogs._Combat_table || {}

SHLOG_COMBAT_STATUS_INITIATOR_DEAD = 0
SHLOG_COMBAT_STATUS_VICTIM_DEAD = 1

function BREACH.AdminLogs.Combat:LogCombat(attacker, victim, damage)

	local lockedteams = {
		[TEAM_SCP] = true,
		[TEAM_SPEC] = true,
	}

	if !IsValid(victim) or !victim:IsPlayer() then return end
	if !IsValid(attacker) or !attacker:IsPlayer() then return end	
	if attacker == victim then return end

	if lockedteams[attacker:GTeam()] or lockedteams[victim:GTeam()] then return end

	local combat_name = "COMBAT_"..math.min(attacker:UserID(), victim:UserID()).."_"..math.max(attacker:UserID(), victim:UserID())

	if !timer.Exists(combat_name) then

		BREACH.AdminLogs._Combat_table[combat_name] = {keys = {}, initiator = attacker, victim = victim}
		timer.Create(combat_name, 1, 60*2, function()
		end)

		if damage == 0 then return end

		BREACH.AdminLogs.Combat:LogCombat(attacker, victim, damage)

	else
		timer.Create(combat_name, 1, 60*2, function()
		end)
		if damage == 0 or !attacker:Alive() or !victim:Alive() or BREACH.AdminLogs._Combat_table[combat_name].markedfordeath then BREACH.AdminLogs._Combat_table[combat_name].markedfordeath = true return end
		local is_initiator = BREACH.AdminLogs._Combat_table[combat_name].initiator:SteamID64() == attacker:SteamID64()

		local tab = {
			attacker = BREACH.AdminLogs:FormatPlayer(attacker),
			victim = BREACH.AdminLogs:FormatPlayer(victim),
			initiator = is_initiator,
			damage = damage
		}

		if istable(BREACH.AdminLogs._Combat_table[combat_name].keys[#BREACH.AdminLogs._Combat_table[combat_name].keys]) and BREACH.AdminLogs._Combat_table[combat_name].keys[#BREACH.AdminLogs._Combat_table[combat_name].keys].initiator == is_initiator then
			BREACH.AdminLogs._Combat_table[combat_name].keys[#BREACH.AdminLogs._Combat_table[combat_name].keys].damage = BREACH.AdminLogs._Combat_table[combat_name].keys[#BREACH.AdminLogs._Combat_table[combat_name].keys].damage + damage
		else
			table.insert(BREACH.AdminLogs._Combat_table[combat_name].keys, tab)
		end

	end

end

function BREACH.AdminLogs.Combat:EndCombat(attacker, victim, damage)

	if !IsValid(victim) or !victim:IsPlayer() then return end
	if !IsValid(attacker) or !attacker:IsPlayer() then return end

	local combat_name = "COMBAT_"..math.min(attacker:UserID(), victim:UserID()).."_"..math.max(attacker:UserID(), victim:UserID())

	if timer.Exists(combat_name) then

		local is_initiator = BREACH.AdminLogs._Combat_table[combat_name].initiator == attacker

		local real_victim
		local initiator

		if is_initiator then
			real_victim = victim
			initiator = attacker
		else
			real_victim = attacker
			initiator = victim
		end

		local status = SHLOG_COMBAT_STATUS_INITIATOR_DEAD

		if (!is_initiator and !attacker:Alive()) or (is_initiator and !victim:Alive()) then
			status = SHLOG_COMBAT_STATUS_VICTIM_DEAD
		end

		if !damage then damage = 50 end

		local tab = {
			attacker = BREACH.AdminLogs:FormatPlayer(attacker),
			victim = BREACH.AdminLogs:FormatPlayer(victim),
			initiator = is_initiator,
			status = status,
			damage = damage,
		}

		table.insert(BREACH.AdminLogs._Combat_table[combat_name].keys, tab)

		timer.Remove(combat_name)

		BREACH.AdminLogs:Log("pvp", {
			initiator = initiator,
			victim = real_victim,
			combat_data = BREACH.AdminLogs._Combat_table[combat_name].keys,
		})

	end


end


local LOGDATA = {}

LOGDATA.name = "PVP"


LOGDATA.color = BREACH.AdminLogs.LogTypeColors[1]

LOGDATA.supa_colors = {
	["weapon"] = Color(89, 160, 232),
}

function LOGDATA:GetText(values)

	return ""
end


LOGDATA.Filters = {

	["initiator"] = {
		name = "нападающий",
		type = ShLog_FILTERTYPE_PLAYER
	},
	["victim"] = {
		name = "Жертва",
		type = ShLog_FILTERTYPE_PLAYER
	},

	["victim_weapon"] = {
		name = "Оружие жертвы",
		type = ShLog_FILTERTYPE_TEXT
	},
	["initiator_weapon"] = {
		name = "Оружие нападающего",
		type = ShLog_FILTERTYPE_TEXT
	},

}


if SERVER then


	hook.Add("PostEntityTakeDamage", "SHLOGS_PVP_DAMAGERECEIVE", function(ent, dmg, took)

		if IsValid(ent) and ent:IsPlayer() and IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() then

			BREACH.AdminLogs.Combat:LogCombat(dmg:GetAttacker(), ent, dmg:GetDamage())

		end

	end)

	hook.Add("PlayerDeath", "SHLOGS_PVP_KILL", function(victim, inflictor, attacker)

		if IsValid(victim) and victim:IsPlayer() and IsValid(attacker) and attacker:IsPlayer() then

			BREACH.AdminLogs.Combat:LogCombat(attacker, victim, 0)
			timer.Simple(0.1, function()
				BREACH.AdminLogs.Combat:EndCombat(attacker, victim, damage)
			end)

		end

	end)


end

--НЕ УДАЛЯТЬ--
return LOGDATA