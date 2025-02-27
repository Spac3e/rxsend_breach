-- code was kindfully provided by spac3

local LOGDATA = {}

LOGDATA.name = "l:shlogs_pickup"

LOGDATA.color = BREACH.AdminLogs.LogTypeColors[2]

LOGDATA.supa_colors = {
	["weapon"] = Color(89, 160, 232),
}

function LOGDATA:GetText(values)
	return "l:shlogs_pickup_log1"
end


LOGDATA.Filters = {

	["user"] = {
		name = "Игрок",
		type = ShLog_FILTERTYPE_PLAYER
	},
	["weapon"] = {
		name = "Предмет",
		type = ShLog_FILTERTYPE_TEXT
	},

}


--НЕ УДАЛЯТЬ--
return LOGDATA