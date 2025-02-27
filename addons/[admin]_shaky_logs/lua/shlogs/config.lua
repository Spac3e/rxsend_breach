-- config has been set up by the most talented config-editor spac3

local CONFIG = {}

CONFIG.debugmode = false

CONFIG.AmountOfLogsPerChunk = 20
CONFIG.AmountOfPVPLogsPerChunk = 10
CONFIG.Delay_PlayerDivide = 32 -- playercount / n
CONFIG.Delay_Min = 0.4
CONFIG.DefaultColor = Color(155,93,66)

CONFIG.Admin19_OnlineLogs = true
CONFIG.Admin19_OnlineLogs_Blacklist = {
	["pvp"] = true,
}
CONFIG.Admin19_OnlineLogs_ServerBlacklist = {
	["5.189.199.152:27015"] = true, -- ну чтобы логи не записывались на тестовом сервере X)
}


return CONFIG