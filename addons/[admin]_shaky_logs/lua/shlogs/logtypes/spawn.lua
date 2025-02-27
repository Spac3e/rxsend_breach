-- code was kindfully provided by spac3

local LOGDATA = {}

SHLOG_SPAWNTYPE_REVIVE = 1
SHLOG_SPAWNTYPE_SUPPORT = 2
SHLOG_SPAWNTYPE_ADMIN = 3

LOGDATA.name = "l:shlogs_spawn"

LOGDATA.no_deepinfo = true

LOGDATA.color = BREACH.AdminLogs.LogTypeColors[3]

function LOGDATA:GetText(values)
	if values.spawn_type == SHLOG_SPAWNTYPE_REVIVE then
		return "l:shlogs_spawn_log1"
	elseif values.spawn_type == SHLOG_SPAWNTYPE_SUPPORT then
		return  "l:shlogs_spawn_log2"
	elseif values.spawn_type == SHLOG_SPAWNTYPE_ADMIN then
		return "l:shlogs_spawn_log3"
	end
	return "l:shlogs_spawn_log4"
end


LOGDATA.Filters = {

	["user"] = {
		name = "Игрок",
		type = ShLog_FILTERTYPE_PLAYER
	},
	["spawn_type"] = {
		name = "spawn_type",
		type = ShLog_FILTERTYPE_TEXT
	},

}


--НЕ УДАЛЯТЬ--
return LOGDATA