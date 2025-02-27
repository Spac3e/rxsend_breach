-- code was kindfully provided by spac3

local LOGDATA = {}



LOGDATA.name = "ULX"


LOGDATA.color = BREACH.AdminLogs.LogTypeColors[2]

function LOGDATA:GetText(values)
	return "user used| cmd data_arguments"
end

LOGDATA.supa_colors = {
	["cmd"] = Color(89, 160, 232),
}

LOGDATA.Filters = {

	["user"] = {
		name = "Пользователь",
		type = ShLog_FILTERTYPE_PLAYER
	},
	["cmd"] = {
		name = "Команда",
		type = ShLog_FILTERTYPE_TEXT
	},
	["data_arguments"] = {
		name = "Аргументы",
		type = ShLog_FILTERTYPE_TABLESTRING
	}

}


if SERVER then
	local ULX_Blacklist = {
		["ulx noclip"] = true,
		["ulx luarun"] = true,
		["ulx rcon"] = true,

		["ulx dev_force_spawn"] = true,
		["ulx force_spawn"] = true,
		["ulx force_scp"] = true,

		["ulx forceround"] = true,
		["ulx forcesupport"] = true,
		["ulx prioritysupport"] = true,

		["ulx checkpenalty"] = true,
		["ulx ignore"] = true,

		["ulx getgaginfo"] = true,
		["ulx getmuteinfo"] = true,
		["ulx getpenalty"] = true,
		["ulx steamsharing"] = true,

		["ulx expiredate"] = true,

		["ulx steamsharing"] = true,


		["ulx funnypic"] = true,
		["ulx giveability"] = true,

		["ulx thirdperson"] = true,
		["ulx firstperson"] = true,
		["ulx strip"] = true,

		["ulx hp"] = true,
		["ulx god"] = true,
		["ulx ungod"] = true,

		["ulx psay"] = true,

		["ulx discord"] = true,
		["ulx faq"] = true,
		["ulx donate"] = true,
		["ulx rules"] = true,
		["ulx steam"] = true,


		["ulx addbypassip"] = true,
		["ulx addbypassid"] = true,
		["ulx isbypassip"] = true,
		["ulx isbypassid"] = true,
		["ulx removebypassip"] = true,
		["ulx removebypassid"] = true,
		["ulx viewbypassip"] = true,
		["ulx viewbypassid"] = true,
		["ulx ksaikoksg"] = true,

		["ulx motd"] = true,

		["ulx lastseenuser"] = true,

		["ulx votebanMinvotes"] = true,
		["ulx votebanSuccessratio"] = true,
		["ulx votekickMinvotes"] = true,
		["ulx votekickSuccessratio"] = true,
		["ulx votemap2Minvotes"] = true,
		["ulx votemap2Successratio"] = true,
		["ulx voteEcho"] = true,
		["ulx votemapMapmode"] = true,
		["ulx votemapVetotime"] = true,
		["ulx votemapMinvotes"] = true,
		["ulx votemapWaittime"] = true,
		["ulx votemapMintime"] = true,
		["ulx votemapEnabled"] = true,
		["ulx rslotsVisible"] = true,
		["ulx rslots"] = true,
		["ulx rslotsMode"] = true,
		["ulx logEchoColorMisc"] = true,
		["ulx logEchoColorPlayer"] = true,
		["ulx logEchoColorPlayerAsGroup"] = true,
		["ulx logEchoColorEveryone"] = true,
		["ulx logEchoColorSelf"] = true,
		["ulx logEchoColorConsole"] = true,
		["ulx logEchoColorDefault"] = true,
		["ulx logEchoColors"] = true,
		["ulx logEcho"] = true,
		["ulx logDir"] = true,
		["ulx logJoinLeaveEcho"] = true,
		["ulx logSpawnsEcho"] = true,
		["ulx votemapSuccessratio"] = true,
		["ulx logSpawns"] = true,
		["ulx logChat"] = true,
		["ulx logEvents"] = true,
		["ulx logFile"] = true,
		["ulx welcomemessage"] = true,
		["ulx meChatEnabled"] = true,
		["ulx chattime"] = true,
		["ulx motdurl"] = true,
		["ulx motdfile"] = true,
		["ulx showMotd"] = true,
		["ulx kickAfterNameChanges"] = true,
		["ulx kickAfterNameChangesWarning"] = true,

	}

	hook.Add("ULibCommandCalled", "shlogs_commandlog", function(_ply,cmd,_args)
		if (not _args) then return end
		if ((#_args > 0 and ULX_Blacklist[cmd .. " " .. _args[1]]) or ULX_Blacklist[cmd]) then return end
		local ply = _ply
		if (not IsValid(ply)) then
			ply = "CONSOLE"
		end
		local argss = ""
		if (#_args > 0) then
			argss = " " .. table.concat(_args, " ")
		end

		BREACH.AdminLogs:Log("ulx", {
			user = ply,
			cmd = cmd,
			data_arguments = argss,
		})

		--print(GAS.Logging:FormatPlayer(ply), GAS.Logging:Highlight(cmd .. argss))
	end)
end

--НЕ УДАЛЯТЬ--
return LOGDATA