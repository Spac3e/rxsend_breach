-- code was kindfully provided by spac3

local LOGDATA = {}

LOGDATA.name = "l:shlogs_disconnection"

LOGDATA.no_deepinfo = true
LOGDATA.no_snapshot = true

LOGDATA.color = BREACH.AdminLogs.LogTypeColors[3]

function LOGDATA:GetText()
	return "l:shlogs_disconnection_log1"
end


LOGDATA.Filters = {

	["user"] = {
		name = "Игрок",
		type = ShLog_FILTERTYPE_PLAYER
	},

}

if SERVER then
	hook.Add( "PlayerDisconnected", "Shlogs_playerdisconnect", function( ply )
		BREACH.AdminLogs:Log("disconnection", {
			user = ply,
		})
	end )
end

--НЕ УДАЛЯТЬ--
return LOGDATA