BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}

BREACH.AdminLogs.Logs_Data = BREACH.AdminLogs.Logs_Data || {}

BREACH.AdminLogs.Logs_Data.CurRound = BREACH.AdminLogs.Logs_Data.CurRound || 0

BREACH.AdminLogs.Logs_Data.Logs = BREACH.AdminLogs.Logs_Data.Logs || {}
BREACH.AdminLogs.Logs_Data.LogsById = BREACH.AdminLogs.Logs_Data.LogsById || {}
BREACH.AdminLogs.Logs_Data.Player_DeepInfos = BREACH.AdminLogs.Logs_Data.Player_DeepInfos || {}

BREACH.AdminLogs.Logs_Data.deepinfoid = BREACH.AdminLogs.Logs_Data.deepinfoid || 0
BREACH.AdminLogs.Logs_Data.logid = BREACH.AdminLogs.Logs_Data.logid || 0

util.AddNetworkString("ShLogs_ReceiveLOGS")
util.AddNetworkString("ShLogs_SwitchPage")
util.AddNetworkString("ShLogs_ReceivePLAYERINFO")
util.AddNetworkString("ShLogs_ReceiveDEEPINFO")
util.AddNetworkString("ShLogs_UpdateLogs")
util.AddNetworkString("ShLogs_UpdateFilters")
util.AddNetworkString("ShLogs_ViewSnapshot")
util.AddNetworkString("ShLogs_TeleportTo")

net.Receive("ShLogs_ReceiveDEEPINFO", function(len, ply)
	if !BREACH.AdminLogs:HaveAccess(ply) then return end
	local id = net.ReadUInt(32)

	if BREACH.AdminLogs.Logs_Data.Player_DeepInfos[id] then
		net.Start("ShLogs_ReceiveDEEPINFO")
		net.WriteTable(BREACH.AdminLogs.Logs_Data.Player_DeepInfos[id])
		net.Send(ply)
	end
end)

net.Receive("ShLogs_UpdateFilters", function(len, ply)

	if !BREACH.AdminLogs:HaveAccess(ply) then return end

	local tab = net.ReadTable()

	ply._shlogs_filters = tab

end)

net.Receive("ShLogs_ViewSnapshot", function(len, ply)
	if !BREACH.AdminLogs:HaveAccess(ply) then return end

	local logid = net.ReadUInt(32)

	local id = net.ReadUInt(12)

	if !id then id = 1 end

	local log = BREACH.AdminLogs.Logs_Data.LogsById[logid]

	if log.combat_data then

		log = log.combat_data[id]

	end

	local addedplys = {}
	local tabreturn = {}



	if log then

		for _, data in pairs(log) do

			if istable(data) and data.isply and !addedplys[data.sid64] and data.hasnapshot and BREACH.AdminLogs.Logs_Data.Player_DeepInfos[data.deepinfoid] then

				addedplys[data.sid64] = true
				local tab = table.Copy(data)
				tab.deep_info = BREACH.AdminLogs.Logs_Data.Player_DeepInfos[data.deepinfoid]
				table.insert(tabreturn, tab)

			end
		end

	end

	net.Start("ShLogs_ViewSnapshot")
	net.WriteTable(tabreturn)
	net.Send(ply)

end)

net.Receive("ShLogs_TeleportTo", function(len, ply)

	if !BREACH.AdminLogs:HaveAccess(ply) then ply:RXSENDNotify("пошел нахуй") return end

	ply.ulx_prevpos = ply:GetPos()

	if ply:GetMoveType() != MOVETYPE_NOCLIP then
		ulx.noclip(ply, {ply})
	end

	ply:SetPos(net.ReadVector())

end)

-- function BREACH.AdminLogs:CreateChunk()

-- 	BREACH.AdminLogs.Logs_Data.CurrentChunk = BREACH.AdminLogs.Logs_Data.CurrentChunk + 1
-- 	BREACH.AdminLogs.Logs_Data["Chunk"..BREACH.AdminLogs.Logs_Data.CurrentChunk] = {}

-- end

function BREACH.AdminLogs:FormatInventory(weapons)

	local tab = {}

	for _, v in pairs(weapons) do

		if !IsValid(v) or !v.GetClass then continue end

		tab[#tab+1] = v:GetClass()

	end

	return tab

end

function BREACH.AdminLogs:GetPageTable(full_table, page, columns_perpage)

	local pages = math.floor(#full_table/columns_perpage) + 1

	local tab = {}

	page = math.min(page, pages)

	local from = (page-1)*columns_perpage+(1*math.min(1,page-1))
	local to = math.min(page*columns_perpage, #full_table)

	for i = from, to do
		table.insert(tab, full_table[i])
	end

	return tab, pages

end

function BREACH.AdminLogs:GetActiveWeapon(activeweapon)

	local curwpn = "none"

	if IsValid(activeweapon) and activeweapon.GetClass then
		curwpn = activeweapon:GetClass()
	end

	return curwpn

end

function BREACH.AdminLogs:FormatPlayer(player, no_deepinfo, no_snapshot)

	local tab = {
		isply = true,
		sid64 = player:SteamID64(),
		role = player:GetRoleName(),
		team = player:GTeam(),
	}

	if !no_deepinfo then
		BREACH.AdminLogs.Logs_Data.deepinfoid = BREACH.AdminLogs.Logs_Data.deepinfoid + 1
		tab.deepinfoid = BREACH.AdminLogs.Logs_Data.deepinfoid

		BREACH.AdminLogs.Logs_Data.Player_DeepInfos[tab.deepinfoid] = {
			charactername = player:GetNamesurvivor(),
			inventory = self:FormatInventory(player:GetWeapons()),
			uniform = player:GetUsingCloth(),
			activeweapon = self:GetActiveWeapon(player:GetActiveWeapon())
		}

		if !no_snapshot then
			tab.hasnapshot = true
			BREACH.AdminLogs.Logs_Data.Player_DeepInfos[tab.deepinfoid].snapshot = {
				pos = player:GetPos(),
				ang = player:EyeAngles(),
				seq = player:GetSequence(),
				shootpos = player:GetShootPos(),
				model = player:GetModel(),
				bgroups = BREACH.AdminLogs:GetBodygroupString(player),
				bnmrgs = BREACH.AdminLogs:GetBonemergeList(player),
			}
		end
	end

	return tab

end

function BREACH.AdminLogs:GetTypeFilters(type, filters)

	return self.LogTypes[type].Filters

end

function BREACH.AdminLogs:GetLogs(type, filters)

	if !type then type = "all" end

	--[[
	if self.config.debugmode then
		filters = {
			all_playercheck = {"76561198869328954"},
			--weapon = "cw_kk_ins2_sex9",
		}
	end]]

	local logs = {}

	for i, v in pairs(BREACH.AdminLogs.Logs_Data.Logs) do
		if !v then continue end

		if type != "all" then
			if v.type != type then continue end
		end

		if filters then

			local found

			local shouldskip = true

			for log_dataname, log_value in pairs(v) do

				if filters.round then
					if v.round == filters.round then
						shouldskip = false
					end
				end

				if filters.all_playercheck then

					if !found then found = {} end

					shouldskip = false

					for _, checksid64 in pairs(filters.all_playercheck) do
						if istable(log_value) and ( ( log_value.sid64 and log_value.sid64 == checksid64 ) or ( log_value.attacker and log_value.attacker.sid64 == checksid64 ) or ( log_value.victim and log_value.victim.sid64 == checksid64 ) ) then
							found[checksid64] = true
						end
					end

				end

				--[[

				for filter_name, filter_value in pairs(filters) do
					if filter_name == "all_playercheck" then continue end
					if filter_name == "round" then continue end

					if v[filter_name] == nil then shouldskip = true break end

					if isstring(filter_value) then

						if isstring(v[filter_name]) then
							if !string.find(string.lower(v[filter_name]), string.lower(filter_value)) then
								shouldskip = true
								break
							end
						else
							if istable(v) and v.sid64 and v.sid64 != filter_value then shouldskip = true break end
						end

					else

						if filter_value != v[filter_name] then
							shouldskip = true break
						end

					end

				end]]

			end

			if found then
				for _, checksid64 in pairs(filters.all_playercheck) do
					if !found[checksid64] then
						shouldskip = true
					end
				end
			end

			if shouldskip then continue end

		end

		table.insert(logs, v)

	end

	return logs

end

net.Receive("ShLogs_ReceiveLOGS", function(len, ply)

	if !BREACH.AdminLogs:HaveAccess(ply) then return end

	local type = net.ReadString()

	local filters = nil

	if ply._shlogs_filters and (#ply._shlogs_filters.Players > 0 or ply._shlogs_filters.round != 0) then
		filters = {}
		if #ply._shlogs_filters.Players > 0 then
			filters.all_playercheck = ply._shlogs_filters.Players
		end
		if ply._shlogs_filters.round != 0 then
			filters.round = ply._shlogs_filters.round
		end
	end

	local logs = BREACH.AdminLogs:GetLogs(type, filters)

	ply.shlogs_logs_save_type = type
	ply.shlogs_logs_save = logs

	local amount = BREACH.AdminLogs.config.AmountOfLogsPerChunk

	if type == "pvp" then
		amount = BREACH.AdminLogs.config.AmountOfPVPLogsPerChunk
	end

	local logstosend, pages = BREACH.AdminLogs:GetPageTable(logs, 1, amount)

	net.Start("ShLogs_ReceiveLOGS", true)
	net.WriteTable(logstosend)
	net.WriteUInt(1, 8) -- 8 - 255 pages
	net.WriteUInt(pages, 8) -- 8 - 255 pages
	net.Send(ply)

end)

net.Receive("ShLogs_SwitchPage", function(len, ply)

	if !BREACH.AdminLogs:HaveAccess(ply) then return end

	local logs = ply.shlogs_logs_save
	local type = ply.shlogs_logs_save_type

	if !logs then return end

	local amount = BREACH.AdminLogs.config.AmountOfLogsPerChunk

	if type == "pvp" then
		amount = BREACH.AdminLogs.config.AmountOfPVPLogsPerChunk
	end

	local page = net.ReadUInt(8)

	local logstosend, pages = BREACH.AdminLogs:GetPageTable(logs, page, amount)

	net.Start("ShLogs_ReceiveLOGS", true)
	net.WriteTable(logstosend)
	net.WriteUInt(page, 8) -- 8 - 255 pages
	net.WriteUInt(pages, 8) -- 8 - 255 pages
	net.Send(ply)

end)


net.Receive("ShLogs_ReceivePLAYERINFO", function(len, ply)
	if !BREACH.AdminLogs:HaveAccess(ply) then return end
	if !ply.shlogs_logs_save then return end

	local logid = net.ReadUInt(32)
	local id = net.ReadString()

	for _, v in pairs(BREACH.AdminLogs.Logs_Data.LogsById[logid]) do
		if istable(v) and v.isply and v.sid64 == id then
			net.Start("ShLogs_ReceivePLAYERINFO")
			net.WriteTable(v)
			net.Send(ply)
			break
		end
	end

end)

function BREACH.AdminLogs:FormatLogToText(data, logtype)

	local text = ""

	text = text..os.date("%x %X ["..logtype.."] : ", data.date)

	local module = BREACH.AdminLogs:GetLogTypeModule(logtype)

	local log_text = module:GetText(data)

	local text_explode = string.Explode(" ", log_text)

	for i, v in pairs(text_explode) do

		if data[v] then
			if isstring(data[v]) then
				text_explode[i] = data[v]
			elseif IsEntity(data[v]) then
				if data[v]:IsPlayer() then
					text_explode[i] = data[v]:SteamID64()
				else
					text_explode[i] = data[v]:GetClass()
				end
			elseif istable(data[v]) and data[v].sid64 then
				local txt = data[v].sid64
				local ply = player.GetBySteamID64(txt)
				if IsValid(ply) and ply.GetNamesurvivor and ply.GetRoleName then
					txt = txt.." |"..ply:GetNamesurvivor().."| ("..ply:GetRoleName()..")"
				end
				text_explode[i] = txt
			end
		end

	end

	text = text..table.concat( text_explode, " " )

	return text

end

function BREACH.AdminLogs:Log(type, data)

	-- if #BREACH.AdminLogs.Logs_Data["Chunk"..BREACH.AdminLogs.Logs_Data.CurrentChunk] >= BREACH.AdminLogs.config.AmountOfLogsPerChunk then
	-- 	BREACH.AdminLogs:CreateChunk()
	-- end

	-- local chunk = BREACH.AdminLogs.Logs_Data["Chunk"..BREACH.AdminLogs.Logs_Data.CurrentChunk]
	-- local type_data = BREACH.AdminLogs.RegisteredLogTypes[type]

	BREACH.AdminLogs.Logs_Data.logid = BREACH.AdminLogs.Logs_Data.logid + 1

	local module = BREACH.AdminLogs:GetLogTypeModule(type)

	local log = {
		date = os.time(),
		type = type,
		round = BREACH.AdminLogs.Logs_Data.CurRound,
		id = BREACH.AdminLogs.Logs_Data.logid,
	}

	for i, v in pairs(data) do
		local value = v
		if IsEntity(v) and v:IsPlayer() then
			value = self:FormatPlayer(v, module.no_deepinfo)
		end

		if i == "data_arguments" then
			local tab = string.Explode(" ", v)

			for _, str_check in pairs(tab) do
				if str_check:StartWith("$") then
					local ply = ULib.getUser( str_check, true )

					if IsValid(ply) then
						log[str_check] = self:FormatPlayer(ply, module.no_deepinfo)
					end
				end
			end
		end

		log[i] = value
	end

	table.insert(BREACH.AdminLogs.Logs_Data.Logs,1,log)
	BREACH.AdminLogs.Logs_Data.LogsById[BREACH.AdminLogs.Logs_Data.logid] = log

	if self.config.debugmode then
		self:ConsoleSay("Created LOG "..type.." "..#BREACH.AdminLogs.Logs_Data.Logs)
	end
	

end