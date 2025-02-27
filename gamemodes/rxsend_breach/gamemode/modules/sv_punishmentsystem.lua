BREACH = BREACH || {}
BREACH.Punishment = BREACH.Punishment || {}

BREACH.Punishment.Type_MUTE = 1
BREACH.Punishment.Type_GAG = 2
BREACH.Punishment.Type_BAN = 3
BREACH.Punishment.Type_PENALTY = 4

BREACH.Punishment.Type_GIVE = 4

BREACH.Punishment.Bans = BREACH.Punishment.Bans || {}
BREACH.Punishment.Gags = BREACH.Punishment.Gags || {}
BREACH.Punishment.Mutes = BREACH.Punishment.Mutes || {}
BREACH.Punishment.Penalties = BREACH.Punishment.Penalties || {}



local function query(text)
	local query = BREACH.Punishment.databaseObject:query(text)

	query:start()
end


local function onConnected()

	query("CREATE TABLE IF NOT EXISTS ban_data (user TEXT, admin TEXT, reason TEXT, unban INT UNSIGNED)")
	query("CREATE TABLE IF NOT EXISTS ban_chat_data (user TEXT, type SMALLINT, admin TEXT, reason TEXT, unban INT UNSIGNED)")
	query("CREATE TABLE IF NOT EXISTS penalty_data (user TEXT, admin TEXT, reason TEXT, amount INT UNSIGNED)")

	BREACH.Punishment:LoadBans()
	BREACH.Punishment:LoadTalkMutes()

	--query("CREATE TABLE IF NOT EXISTS admin_log (victim TEXT, admin TEXT, date TEXT, reason TEXT, amount INT UNSIGNED)")

end

function PunishmentDataBaseSystemConnect()

	BREACH.Punishment.databaseObject = mysqloo.connect("123.60.78.23", "breach_handler", "WVEQo9seb", "breach_main")

	BREACH.Punishment.databaseObject.onConnectionFailed = function(_, msg)
        timer.Simple(5, function()
    		error("[RXSEND] Connection to Punishment database failed, retrying...")
           	PunishmentDataBaseSystemConnect()
        end)
    end

    BREACH.Punishment.databaseObject.onConnected = onConnected

    BREACH.Punishment.databaseObject:connect()

end



function BREACH.Punishment:Connect()

	PunishmentDataBaseSystemConnect()

end

function BREACH.Punishment:Initialize()

	BREACH.Punishment:Connect()

end


function BREACH.Punishment:LogAction(user, admin, reason, unban_successful, unban_notfound)

	if !user then return end

	if !admin then admin = "CONSOLE" end
	if !reason then reason = "No reason given." end

	BREACH.Punishment.Bans[user] = nil

	local plyadmin


	--[[Turning values in text]]

	if IsValid(admin) and admin:IsPlayer() then
		plyadmin = admin
		admin = admin:SteamID()
	end

	local notifyname = "ban_process_"..CurTime()

	timer.Create(notifyname, 0.1, 1, function()
		if IsValid(plyadmin) then
			plyadmin:RXSENDNotify("Начат процесс снятия блокировки, подождите...")
		end
	end)

	--[[Formatting for MYSQL]]--

	user = sql.SQLStr(user)
	reason = sql.SQLStr(reason)
	admin = sql.SQLStr(admin)

	--[[query_checkban : нам нужно проверить, существует ли бан с этим игроком]]
	local unban = BREACH.Punishment.databaseObject:query( f("DELETE FROM ban_data WHERE user = %s", user) )

	unban.onSuccess = function(a, result)

		timer.Remove(notifyname)

		if IsValid(plyadmin) then
			plyadmin:RXSENDNotify("Блокировка была успешно снята с игрока!")
		end

	end

	unban:start()

end


function BREACH.Punishment:LoadBans()

	local query_getbans = BREACH.Punishment.databaseObject:query("SELECT * FROM ban_data")

	query_getbans.onSuccess = function(_, bans)

		for _, ban in pairs(bans) do

			BREACH.Punishment.Bans[ban.user] = {
				admin = ban.admin,
				unban = ban.unban,
				reason = ban.reason,
				steamID = ban.user,
			}

		end

	end

	query_getbans:start()

end

function BREACH.Punishment:LoadTalkMutes()

	local query_get = BREACH.Punishment.databaseObject:query("SELECT * FROM ban_chat_data")

	query_get.onSuccess = function(_, bans)

		for _, ban in pairs(bans) do

			if ban.type == BREACH.Punishment.Type_GAG then

				BREACH.Punishment.Gags[ban.user] = {
					admin = ban.admin,
					unban = ban.unban,
					reason = ban.reason,
					steamID = ban.user,
				}

			else

				BREACH.Punishment.Mutes[ban.user] = {
					admin = ban.admin,
					unban = ban.unban,
					reason = ban.reason,
					steamID = ban.user,
				}

			end

		end

	end

	query_get:start()

end

local f = string.format


function BREACH.Punishment:Ban(user, admin, unban, reason)

	if !user then return end
	if IsValid(user) and user:IsPlayer() and ( user:IsBot() or user:IsUserGroup("spectator") or user:IsSuperAdmin() ) then return end -- забанить бота нельзя

	if !reason then reason = "No reason given." end
	if !admin then admin = "CONSOLE" end
	if !unban then unban = 0 end

	local saveply


	--[[Turning values in text]]

	if user and IsValid(user) and user:IsPlayer() then
		saveply = user
		user = user:SteamID()
	end

	if admin and IsValid(admin) and admin:IsPlayer() then
		admin = admin:SteamID()
	end

	saveply = player.GetBySteamID(user)

	BREACH.Punishment.Bans[user] = {
		admin = tostring(admin),
		unban = unban,
		reason = tostring(reason),
		steamID = tostring(user),
	}

	--[[Formatting for MYSQL]]--

	user = sql.SQLStr(user)
	reason = sql.SQLStr(reason)
	admin = sql.SQLStr(admin)
	unban = sql.SQLStr(unban, true)

	--[[query_checkban : нам нужно проверить, существует ли бан с этим игроком]]
	local query_checkban = BREACH.Punishment.databaseObject:query( f("SELECT * FROM ban_data WHERE user = %s LIMIT 1", user) )

	query_checkban.onSuccess = function(_, isban)

		local query
	
		if #isban > 0 then

			query = BREACH.Punishment.databaseObject:query(  f("UPDATE ban_data SET unban = %s, admin = %s, reason = %s WHERE user = %s", unban, admin, reason, user)  )

		else

			query = BREACH.Punishment.databaseObject:query(  f("INSERT INTO ban_data VALUES(%s, %s, %s, %s)", user, admin, reason, unban)  )

		end

		query.onSuccess = function()
			if IsValid(saveply) then
				saveply:Kick("You are banned, reconnect to see the reason")
			end
		end

		query:start()

	end

	query_checkban:start()

end

function BREACH.Punishment:BanTalk(user, admin, unban, reason, type)

	if !user then return end
	if IsValid(user) and user:IsPlayer() and user:IsBot() then return end -- забанить бота нельзя

	if !reason then reason = "No reason given." end
	if !admin then admin = "CONSOLE" end
	if !unban then unban = 0 end


	--[[Turning values in text]]

	if user and IsValid(user) and user:IsPlayer() then
		user = user:SteamID()
	end

	if admin and IsValid(admin) and admin:IsPlayer() then
		admin = admin:SteamID()
	end

	if user:StartWith("7656") then user = util.SteamIDFrom64(user) end

	if type == BREACH.Punishment.Type_GAG then
		BREACH.Punishment.Gags[user] = {
			admin = tostring(admin),
			unban = unban,
			reason = tostring(reason),
			steamID = tostring(user),
		}
	else
		BREACH.Punishment.Mutes[user] = {
			admin = tostring(admin),
			unban = unban,
			reason = tostring(reason),
			steamID = tostring(user),
		}
	end

	--[[Formatting for MYSQL]]--

	user = sql.SQLStr(user)
	reason = sql.SQLStr(reason)
	admin = sql.SQLStr(admin)
	unban = sql.SQLStr(unban, true)
	type = sql.SQLStr(type, true)

	--[[query_checkban : нам нужно проверить, существует ли бан с этим игроком]]
	local query_checkban = BREACH.Punishment.databaseObject:query( f("SELECT * FROM ban_chat_data WHERE user = %s AND type = %s LIMIT 1", user, type) )

	query_checkban.onSuccess = function(_, isban)

		local query
	
		if #isban > 0 then

			query = BREACH.Punishment.databaseObject:query(  f("UPDATE ban_chat_data SET unban = %s, admin = %s, reason = %s WHERE user = %s AND type = %s", unban, admin, reason, user, type)  )

		else

			query = BREACH.Punishment.databaseObject:query(  f("INSERT INTO ban_chat_data VALUES(%s, %s, %s, %s, %s)", user, type, admin, reason, unban)  )

		end

		query:start()

	end

	query_checkban:start()

end

function BREACH.Punishment:Gag(user, admin, unban, reason)
	BREACH.Punishment:BanTalk(user, admin, unban, reason, BREACH.Punishment.Type_GAG)
end
function BREACH.Punishment:Mute(user, admin, unban, reason)
	BREACH.Punishment:BanTalk(user, admin, unban, reason, BREACH.Punishment.Type_MUTE)
end

function BREACH.Punishment:Unban(user, admin, reason, unban_successful, unban_notfound)

	if !user then return end

	if !admin then admin = "CONSOLE" end
	if !reason then reason = "No reason given." end

	BREACH.Punishment.Bans[user] = nil

	local plyadmin


	--[[Turning values in text]]

	if !user:StartWith("STEAM") then
		user = util.SteamIDFrom64(user)
	end

	if IsValid(admin) and admin:IsPlayer() then
		plyadmin = admin
		admin = admin:SteamID()
	end

	local notifyname = "ban_process_"..CurTime()

	timer.Create(notifyname, 0.1, 1, function()
		if IsValid(plyadmin) then
			plyadmin:RXSENDNotify("Начат процесс снятия блокировки, подождите...")
		end
	end)

	--[[Formatting for MYSQL]]--

	user = sql.SQLStr(user)
	reason = sql.SQLStr(reason)
	admin = sql.SQLStr(admin)

	--[[query_checkban : нам нужно проверить, существует ли бан с этим игроком]]
	local unban = BREACH.Punishment.databaseObject:query( f("DELETE FROM ban_data WHERE user = %s", user) )

	unban.onSuccess = function(a, result)

		timer.Remove(notifyname)

		if IsValid(plyadmin) then
			plyadmin:RXSENDNotify("Блокировка была успешно снята с игрока!")
		end

	end

	unban:start()

end

function BREACH.Punishment:UnbanTalk(user, admin, reason, type)

	if !user then return end

	if !reason then reason = "No reason given." end
	if !admin then admin = "CONSOLE" end

	--[[Turning values in text]]

	if IsValid(user) and user:IsPlayer() then
		user = user:SteamID()
	end

	if !user:StartWith("STEAM") then
		user = util.SteamIDFrom64(user)
	end


	if type == BREACH.Punishment.Type_GAG then
		BREACH.Punishment.Gags[user] = nil
	else
		BREACH.Punishment.Mutes[user] = nil
	end

	local plyadmin

	local notifyname = "ban_process_"..tostring(type).."_"..CurTime()

	timer.Create(notifyname, 0.1, 1, function()
		if IsValid(plyadmin) then
			plyadmin:RXSENDNotify("Начат процесс снятия блокировки, подождите...")
		end
	end)

	--[[Formatting for MYSQL]]--

	user = sql.SQLStr(user)
	reason = sql.SQLStr(reason)
	admin = sql.SQLStr(admin)
	type = sql.SQLStr(type, true)

	--[[query_checkban : нам нужно проверить, существует ли бан с этим игроком]]
	local unban = BREACH.Punishment.databaseObject:query( f("DELETE FROM ban_chat_data WHERE user = %s AND type = %s", user, type) )

	unban.onSuccess = function(a, result)

		timer.Remove(notifyname)

		if IsValid(plyadmin) then
			plyadmin:RXSENDNotify("Блокировка была успешно снята с игрока!")
		end

	end

	unban:start()

end

function BREACH.Punishment:UnGag(user, admin, reason)
	BREACH.Punishment:UnbanTalk(user, admin, reason, BREACH.Punishment.Type_GAG)
end
function BREACH.Punishment:UnMute(user, admin, reason)
	BREACH.Punishment:UnbanTalk(user, admin, reason, BREACH.Punishment.Type_MUTE)
end


hook.Add("InitPostEntity", "CreatePunishmentDataTable", function()

	BREACH.Punishment:Initialize()

end)


function TESTICSUPRA()

	local query = BREACH.DataBaseSystem.databaseObject:query("SELECT * FROM player_data WHERE dataname = "..sql.SQLStr("premium"))

	query.onSuccess = function(_, data) print(#data) end

	query:start()

end
--
BREACH.DataList = {}

function util.SteamIDTo32(steamid)
	local acc32 = tonumber(steamid:sub(11))

	return tostring((acc32 * 2) + tonumber(steamid:sub(9,9)))
end

function util.SteamIDFrom32(steamid32)
	steamid32 = tonumber( steamid32 )
	local y = steamid32 % 2
	local z = ( steamid32 - y ) / 2

	return "STEAM_0:" .. y .. ":" .. z
end

function util.SteamID64To32(steamid64)
	return util.SteamIDTo32(util.SteamIDFrom64(steamid64))
end

function util.SteamID64From32(steamid32)
	return util.SteamIDTo64(util.SteamIDFrom32(steamid32))
end

local datattotrasnfer = {
	["prefix_activated"] = "prefix_activated",
	["rainbow_prefix_activated"] = "rainbow_prefix_activated",
}

function GETDATA()


	for dataname, tovalue in pairs(datattotrasnfer) do

		local txt = "["..dataname.."]"

		for i, v in pairs(sql.Query("SELECT * FROM playerpdata")) do

			if v.infoid:EndsWith(txt) and !v.infoid:StartWith("-") then

				BREACH.DataBaseSystem:UpdateData(util.SteamID64From32(string.sub(v.infoid, 0, #v.infoid-#txt)), tovalue, v.value)

			end


		end

	end
end