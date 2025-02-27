-- code was kindfully provided by spac3

local LOGDATA = {}



LOGDATA.name = "l:shlogs_death"


LOGDATA.color = BREACH.AdminLogs.LogTypeColors[1]

LOGDATA.supa_colors = {
	["weapon"] = Color(89, 160, 232),
}

function LOGDATA:GetText(values)
	if IsValid(values.killer) then
		if values.killer:GetClass() == "func_door" then
			return "l:shlogs_death_log1"
		end
	end
	return "l:shlogs_death_log2"
end


LOGDATA.Filters = {

	["victim"] = {
		name = "Жертва",
		type = ShLog_FILTERTYPE_PLAYER
	},

}

if SERVER then



	hook.Add("PlayerDeath", "SHLOGS_DEATH_LOG", function(victim, inflictor, attacker)

		if IsValid(victim) and victim:IsPlayer() then

			if IsValid(attacker) and attacker:GetClass() == "func_door" then

				if !IsValid(attacker.buttonentity) then return end

				local player1 = attacker.buttonentity._lastusedby

				local killer = NULL

				if IsValid(player1) and SysTime() - attacker.buttonentity._lastusedwhen <= 1 then
					killer = player1
				end

				if IsValid(killer) then

					BREACH.AdminLogs:Log("death_elevator", {
						user = victim,
						killer = killer,
					})

				end

			else

				BREACH.AdminLogs:Log("death", {
					victim = victim,
					killer = attacker,
				})


			end

		end

	end)



end


--НЕ УДАЛЯТЬ--
return LOGDATA