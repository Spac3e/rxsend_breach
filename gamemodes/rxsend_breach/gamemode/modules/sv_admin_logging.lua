BREACH = BREACH || {}
BREACH.AdminLogSystem = BREACH.AdminLogSystem || {}

BREACH.AdminLogSystem.Months = {

	[1] = "January",
	[2] = "February",
	[3] = "March",
	[4] = "April",
	[5] = "May",
	[6] = "June",
	[7] = "July",
	[8] = "August",
	[9] = "September",
	[10] = "October",
	[11] = "November",
	[12] = "December",

}

BREACH.AdminLogSystem.DaysInMonth = {
	[1] = 31,
	[2] = 28,
	[3] = 31,
	[4] = 30,
	[5] = 31,
	[6] = 30,
	[7] = 31,
	[8] = 31,
	[9] = 30,
	[10] = 31,
	[11] = 30,
	[12] = 31,
}

function BREACH.AdminLogSystem:GetName(sid64)

	local steamid = util.SteamIDFrom64(sid64)

	if ULib and ULib.ucl and ULib.ucl.users and ULib.ucl.users[steamid] and ULib.ucl.users[steamid].name then
		return ULib.ucl.users[steamid].name
	else
		return sid64
	end

end


function BREACH.AdminLogSystem:GetDaysInMonth(month)

	return (BREACH.AdminLogSystem.DaysInMonth[month] || 30)

end

function BREACH.AdminLogSystem:IsCurrentMonth(month)

	if month == BREACH.AdminLogSystem.month then return true end
	return false

end

function BREACH.AdminLogSystem:formattime(time)

	local days = math.floor(time/1440)
	local hours = math.floor((time-days*1440)/60)
	local minutes = time - hours*60 - days*1440

	hours = tostring(hours)
	minutes = tostring(minutes)

	if #hours == 1 then hours = "0"..hours end
	if #minutes == 1 then minutes = "0"..minutes end

	if days > 0 then
		hours = tostring(days)..":"..hours
	end

	return hours..":"..minutes

end

function BREACH.AdminLogSystem:GetUsersPlaytime(sid64, month, onreturn)

	if month > 12 then return end

	if !onreturn then onreturn = function(data) print(data) end end

	newMysql.query(string.format("SELECT * FROM admin_active_data WHERE user=%s AND month = %s AND year = %s", sql.SQLStr(sid64), tostring(month), tostring(BREACH.AdminLogSystem.year)), function(data)
	
	local results = {}

	local nums = BREACH.AdminLogSystem:GetDaysInMonth(month)

	if BREACH.AdminLogSystem:IsCurrentMonth(month) then
		nums = BREACH.AdminLogSystem.day
	end

	for i = 1, nums do
		results[i] = {text = "День "..i..": **Не был на сервере**"}
	end

	if data then
		for _, v in pairs(data) do
			results[tonumber(v.day)] = {text = "День "..tonumber(v.day)..": "..BREACH.AdminLogSystem:formattime(tonumber(v.playtime))}
		end
	end

	local text = ""

	for _, aaaa in ipairs(results) do
		text = text..aaaa.text.."\n"
	end

	onreturn(text)

	end, function(errar) print(errar) end)

end

function BREACH.AdminLogSystem:GetScoreboardPlaytime(month, onreturn)

	if month > 12 then return end

	if !onreturn then onreturn = function(data) print(data) end end

	newMysql.query(string.format("SELECT * FROM admin_active_data WHERE month = %s AND year = %s", tostring(month), tostring(BREACH.AdminLogSystem.year)), function(data)
	
	local adminlist = {}

	for i, v in pairs(ULib.ucl.users) do
		if v.group != "superadmin" and v.group != "premium" and v.name then
			table.insert(adminlist, {id64 = util.SteamIDTo64(i), playtime = 0, name = v.name})
		end
	end

	if data then
		for _, dat in pairs(data) do
		
			for i, v in ipairs(adminlist) do
				if v.id64 == dat.user then
					v.playtime = v.playtime + tonumber(dat.playtime)
				end
			end

		end
	end

	table.SortByMember( adminlist, "playtime" )

	local text = ""

	for _, aaaa in ipairs(adminlist) do
		local spenttime = "**Не был ни разу на сервере**"

		if aaaa.playtime > 0 then
			spenttime = BREACH.AdminLogSystem:formattime(aaaa.playtime)
		end

		local datext = aaaa.name.." ("..aaaa.id64.."): "..spenttime
		text = text..datext.."\n"
	end

	onreturn(text)

	end, function(errar) print(errar) end)

end

function BREACH.AdminLogSystem:Create()

	newMysql.query("CREATE TABLE IF NOT EXISTS admin_active_data (user TEXT, playtime SMALLINT UNSIGNED, year SMALLINT UNSIGNED, month TINYINT UNSIGNED, day TINYINT UNSIGNED)", function()
	
	print("success")

	end, function(errar) print(errar) end)

	BREACH.AdminLogSystem.day = tonumber(os.date("%d"))
	BREACH.AdminLogSystem.month = tonumber(os.date("%m"))
	BREACH.AdminLogSystem.year = tonumber(os.date("%Y"))

end

hook.Add("Initialize", "AdminLogSystem:Create", function()


	BREACH.AdminLogSystem:Create()


end)

function BREACH.AdminLogSystem:LogPlayer(ply)
	if ply.loggedhisactivityadminplaytime then return end
	if !ply:IsAdmin() then return end
	if ply:IsSuperAdmin() then return end
	ply.loggedhisactivityadminplaytime = true
	BREACH.AdminLogSystem:Log(ply:SteamID64(), math.floor(ply:TimeConnected()/60))
end

hook.Add( "PlayerDisconnected", "AdminLogSystem:SavePlayTime", function(ply)
    if ply:IsAdmin() then
    	BREACH.AdminLogSystem:LogPlayer(ply)
    end
end )


function BREACH.AdminLogSystem:Log(admin, playtime)

	local day, month, year = BREACH.AdminLogSystem.day, BREACH.AdminLogSystem.month, BREACH.AdminLogSystem.year

	print(admin, playtime)

	local query = string.format("SELECT * FROM admin_active_data WHERE user=%s AND year=%s AND month = %s AND day = %s", sql.SQLStr(admin), tostring(year), tostring(month), tostring(day))

	local q = newMysql.query

	q(query, function(result)
	
		print("result Logged")

		if not result then

			q(string.format("INSERT INTO admin_active_data VALUES(%s, %s, %s, %s, %s)", tostring(admin), tostring(playtime), tostring(year), tostring(month), tostring(day)))

		else

			local quer = string.format("UPDATE admin_active_data SET playtime=playtime+%s WHERE user=%s AND year=%s AND month=%s AND day=%s", tostring(playtime), sql.SQLStr(admin), tostring(year), tostring(month), tostring(day))
			print(quer)
			q(quer, function(a) print(a) end, function(err) print(err) end)

		end

	end)

end