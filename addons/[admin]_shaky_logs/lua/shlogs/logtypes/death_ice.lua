-- code was kindfully provided by spac3

local LOGDATA = {}



LOGDATA.name = "l:shlogs_icedev"


LOGDATA.color = BREACH.AdminLogs.LogTypeColors[1]

LOGDATA.supa_colors = {
	["409"] = Color(111, 252, 228),
	["009"] = Color(173, 12, 3),
}

function LOGDATA:GetText(values)
	if values.icetype == 1 then
		if values.waskilled then
			return "l:shlogs_icedev_log1"
		end
		return "l:shlogs_icedev_log2"
	end
	return "l:shlogs_icedev_log3"
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