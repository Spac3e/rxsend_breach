BREACH = BREACH || {}
BREACH.DataBaseSystem = BREACH.DataBaseSystem || {}

BREACH.DataBaseSystem.cachedQueries = BREACH.DataBaseSystem.cachedQueries || {}

require("mysqloo")

local mply = FindMetaTable("Player")

BREACH.DataBaseSystem.PDATASWAP = {
	["breach_level"] = "level",
	["DonatedLevels"] = "donatedlevels",
	["elo"] = "elo",
}

BR_DATATYPE_NUM = 0
BR_DATATYPE_STRING = 1
BR_DATATYPE_BOOL = 2

local data_list = {
	
	["level"] = {
		default = 0,
		type = BR_DATATYPE_NUM,
	},

	["donatedlevels"] = {
		type = BR_DATATYPE_NUM,
		default = 0
	},

	["exp"] = {
		default = 0,
		type = BR_DATATYPE_NUM,
	},

	["firsttime"] = {
		type = BR_DATATYPE_NUM,
	},
	
	["lastname"] = {
		type = BR_DATATYPE_STRING,
	},

	["playtime"] = {
		type = BR_DATATYPE_NUM
	},

	["premium"] = {
		type = BR_DATATYPE_NUM,
		default = 0,
	},

	["adminka"] = {
		type = BR_DATATYPE_NUM,
		default = 0,
	},

}

local function onConnected()

	local query = BREACH.DataBaseSystem.databaseObject:query("CREATE TABLE IF NOT EXISTS player_data (id TEXT, dataname TEXT, value varchar(255))")

	query:start()

end

function DataBaseSystemConnect()

	BREACH.DataBaseSystem.databaseObject = mysqloo.connect("123.60.78.23", "breach_handler", "WVEQo9seb", "breach_main")

	BREACH.DataBaseSystem.databaseObject.onConnectionFailed = function(_, msg)
        timer.Simple(5, function()
    		error("[RXSEND] Connection to database failed, retrying...")
           	DataBaseSystemConnect()
        end)
    end

    BREACH.DataBaseSystem.databaseObject.onConnected = onConnected

    BREACH.DataBaseSystem.databaseObject:connect()

end

function BREACH.DataBaseSystem:Connect()

	DataBaseSystemConnect()

end

hook.Add("InitPostEntity", "CreateDataTable", function()

	BREACH.DataBaseSystem:Connect()


end)

function BREACH.DataBaseSystem:GetData(sid64, dataname, default, callback, onerror)

	local query = BREACH.DataBaseSystem.databaseObject:query("SELECT * from player_data WHERE id = "..sql.SQLStr(sid64).." AND dataname = "..sql.SQLStr(dataname).." LIMIT 1")

	query.onSuccess = function(_, data)
		if callback then
			local toreturn = default

			if #data > 0 then
				toreturn = data[1].value
			end

			callback(toreturn)
		end
	end

	query.onError = onerror

	query:start()

end

function BREACH.DataBaseSystem:GetPlayerData(sid64, callback)

	local query = BREACH.DataBaseSystem.databaseObject:query("SELECT * from player_data WHERE id = "..sql.SQLStr(sid64))

	query.onSuccess = function(_, data)
		callback(data)
	end

	query.onError = onerror

	query:start()

end

function BREACH.DataBaseSystem:UpdateData(sid64, dataname, value, add)

	local query = BREACH.DataBaseSystem.databaseObject:query("SELECT value from player_data WHERE id = "..sql.SQLStr(sid64).." AND dataname = "..sql.SQLStr(dataname).." LIMIT 1")

	query.onSuccess = function(_, data)

		local isdefault

		if data_list and data_list[dataname] then
			isdefault = (data_list and data_list[dataname].default != nil and ( data_list[dataname].type == BR_DATATYPE_NUM and data_list[dataname].default == value ))
		end
		local addvalue

		local setvalue = value

		if #data > 0 then

			if isdefault then

				addvalue = BREACH.DataBaseSystem.databaseObject:query("DELETE FROM player_data WHERE id = "..sql.SQLStr(sid64).." AND dataname = "..sql.SQLStr(dataname))

			else

				if add then
					addvalue = BREACH.DataBaseSystem.databaseObject:query("UPDATE player_data SET value = value + "..sql.SQLStr(setvalue).." WHERE id = "..sql.SQLStr(sid64).." AND dataname = "..sql.SQLStr(dataname))
				else
					addvalue = BREACH.DataBaseSystem.databaseObject:query("UPDATE player_data SET value = "..sql.SQLStr(setvalue).." WHERE id = "..sql.SQLStr(sid64).." AND dataname = "..sql.SQLStr(dataname))
				end

			end

		else

			if !isdefault then

				addvalue = BREACH.DataBaseSystem.databaseObject:query("INSERT INTO player_data VALUES("..sql.SQLStr(sid64)..", "..sql.SQLStr(dataname)..", "..sql.SQLStr(value)..")")

			end

		end

		if addvalue then

			addvalue.onSuccess = function()

				local ply = player.GetBySteamID64(sid64)

				if IsValid(ply) then

					if add and ply.StoredData[dataname] then

						ply.StoredData[dataname] = ply.StoredData[dataname] + setvalue

					else

						ply.StoredData[dataname] = setvalue

					end

				end

			end

			addvalue:start()

		end
	end

	query:start()

end

function BREACH.DataBaseSystem:RemoveData(sid64, dataname)

	local query = BREACH.DataBaseSystem.databaseObject:query("DELETE FROM player_data WHERE id = "..sql.SQLStr(sid64).." AND dataname = "..sql.SQLStr(dataname))

	query:start()

end

function mply:RemoveBreachData(dataname)
	BREACH.DataBaseSystem:RemoveData(self:SteamID64(), dataname)
end

function mply:GetBreachData(dataname)
	if !self.StoredData then
		BREACH.DataBaseSystem:LoadPlayer(self)
		return
	else
		local val = self.StoredData[dataname]

		if !val and data_list[dataname] then
			val = data_list[dataname].default
		end
		return val
	end
end

function mply:SetBreachData(dataname, value)
	BREACH.DataBaseSystem:UpdateData(self:SteamID64(), dataname, value)
end

function BREACH.DataBaseSystem:LoadValuesToPlayer(ply)

	ply:SetNLevel(ply:GetBreachData("level"))
	ply:SetPenaltyAmount(tonumber(ply:GetPData("breach_penalty", 0)))
	ply:SetNEXP(ply:GetBreachData("exp"))

end

function BREACH.DataBaseSystem:LoadPlayer(ply, onload)

	if !IsValid(ply) or !ply:IsPlayer() then return false end

	if !ply.StoredData then

		ply.StoredData = {}

		for i, v in pairs(data_list) do
			ply.StoredData[i] = v.default
		end

		self:GetPlayerData(ply:SteamID64(), function(data)

			for _, v in pairs(data) do

				local val = v.value

				if data_list[v.dataname] then
					if data_list[v.dataname].type == BR_DATATYPE_NUM then
						val = tonumber(val)
					elseif data_list[v.dataname].type == BR_DATATYPE_BOOL then
						val = tobool(val)
					end
				end

				ply.StoredData[v.dataname] = val

			end

			BREACH.DataBaseSystem:LoadValuesToPlayer(ply)

			if onload then onload() end

		end)

	else

		BREACH.DataBaseSystem:LoadValuesToPlayer(ply)

		if onload then onload() end

	end

end