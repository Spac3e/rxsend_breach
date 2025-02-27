-- code was kindfully provided by spac3

local LOGDATA = {}



LOGDATA.name = "l:shlogs_deathelev"


LOGDATA.color = BREACH.AdminLogs.LogTypeColors[1]

function LOGDATA:GetText(values)
	return "l:shlogs_deathelev_log1"
end

LOGDATA.snapshot_only = true

LOGDATA.Filters = {

	["user"] = {
		name = "Игрок",
		type = ShLog_FILTERTYPE_PLAYER
	},

	["killer"] = {
		name = "Убийца",
		type = ShLog_FILTERTYPE_PLAYER
	},

}


--НЕ УДАЛЯТЬ--
return LOGDATA