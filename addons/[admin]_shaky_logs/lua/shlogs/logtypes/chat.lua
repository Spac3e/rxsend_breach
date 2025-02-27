-- code was kindfully provided by spac3

local LOGDATA = {}

LOGDATA.name = "l:shlogs_chat"

LOGDATA.no_deepinfo = true
LOGDATA.no_snapshot = true

LOGDATA.color = BREACH.AdminLogs.LogTypeColors[1]

function LOGDATA:GetText()
	return "l:shlogs_chat_log1"
end


LOGDATA.Filters = {

	["sender"] = {
		name = "Игрок",
		type = ShLog_FILTERTYPE_PLAYER
	},
	["message"] = {
		name = "Сообщение",
		type = ShLog_FILTERTYPE_TEXT
	},

}

if SERVER then
	hook.Add( "PlayerSay", "Shlogs_playersay", function( ply, text )
		if !text:StartWith("!") then
			BREACH.AdminLogs:Log("chat", {
				sender = ply,
				message = text,
			})
		end
	end )
end

--НЕ УДАЛЯТЬ--
return LOGDATA