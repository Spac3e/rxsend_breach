util.AddNetworkString("GetAchievementTable")
util.AddNetworkString("AchievementBar")
util.AddNetworkString("CompleteAchievement_Clientside")
util.AddNetworkString("OpenAchievementMenu")
include("achievements.lua")

BreachAchievements = BreachAchievements || {}
BreachAchievements.RoundScoreList = BreachAchievements.RoundScoreList || {}

hook.Add("Initialize", "BreachAchievement_DataBase", function()
	sql.Query( "CREATE TABLE IF NOT EXISTS breachachievements ( owner TEXT, achivid TEXT, count INTEGER )" )
end)

net.Receive("GetAchievementTable", function(len, ply)

	net.Start("GetAchievementTable")
	net.WriteTable(BreachAchievements.AchievementTable)
	net.Send(ply)

	local data = newMysql.query( "SELECT * FROM breachachievements WHERE owner = " .. sql.SQLStr( ply:SteamID() ) .. ";")

	if data then
		ply.CompletedAchievements = data
		ply:SetNWInt("CompletedAchievements", ply:GetAchievementsNum())
	else
		ply.CompletedAchievements = {}
	end

end)

hook.Add("PlayerSay", "BreachAchievement_OpenMenu", function(ply, msg)
	if msg == "!achievements" or msg == "/achievements" then
		--[[
		net.Start("OpenAchievementMenu")
		net.WriteEntity(ply)
		net.WriteTable(BreachAchievements.AchievementTable)
		net.WriteTable(ply.CompletedAchievements || {})
		net.Send(ply)]]
		--ply:RXSENDNotify("На время ачивки были отключены")
		return ""
	end
end)

net.Receive("OpenAchievementMenu", function(len, ply)
	local plyr = net.ReadEntity()
	if !IsValid(plyr) or !plyr:IsPlayer() or plyr:IsBot() then return end
	--plyr:RXSENDNotify("На время ачивки были отключены")
	--[[
	net.Start("OpenAchievementMenu")
	net.WriteEntity(plyr)
	net.WriteTable(BreachAchievements.AchievementTable)
	net.WriteTable(plyr.CompletedAchievements || {})
	net.Send(ply)]]
end)

local mply = FindMetaTable("Player")

function mply:AddToAchievementPoint(name, count)

	self.CompletedAchievements = self.CompletedAchievements || {}

	local found = false
	for i, v in pairs(self.CompletedAchievements) do
		if v.achivid == name then
			if tonumber(v.count) >= FindAchievementTableByName(v.achivid).countnum then break end
			v.count = tonumber(v.count) + count
			if v.count >= FindAchievementTableByName(v.achivid).countnum then
				net.Start("AchievementBar")
				net.WriteTable(FindAchievementTableByName(v.achivid))
				net.Send(self)
			end
			v.count = math.Clamp(v.count, 0, FindAchievementTableByName(v.achivid).countnum)
			found = true
			newMysql.query("UPDATE breachachievements SET count = " .. tostring(v.count) .. " WHERE owner = " .. sql.SQLStr( self:SteamID() ) .. " AND achivid = " .. sql.SQLStr(name) .. ";")
			break
		end
	end
	if !found then
		self.CompletedAchievements[#self.CompletedAchievements + 1] = {
			achivid = name,
			count = math.Clamp(count, 0, FindAchievementTableByName(name).countnum),
		}

		if count >= FindAchievementTableByName(name).countnum then
			net.Start("AchievementBar")
			net.WriteTable(FindAchievementTableByName(name))
			net.Send(self)
		end
		newMysql.query("INSERT INTO breachachievements ( owner, achivid, count ) VALUES( " .. sql.SQLStr( self:SteamID() ) .. ", ".. sql.SQLStr(name) .."," .. tostring(count) .. " )")
	end

	self:SetNWInt("CompletedAchievements", self:GetAchievementsNum())

end

function mply:CleanAchievements()
	self.CompletedAchievements = {}
	newMysql.query( "DELETE * FROM breachachievements WHERE owner = " .. sql.SQLStr( self:SteamID() ) .. ";")
	self:SetNWInt("CompletedAchievements", self:GetAchievementsNum())
end

function mply:GetAchievementsNum()
	local num = 0
	local counted = {}
	for i, v in pairs(self.CompletedAchievements) do
		if !counted[v.achivid] and !FindAchievementTableByName(v.achivid).countable then
			num = num + 1 
			counted[v.achivid] = true
		else
			if !counted[v.achivid] and FindAchievementTableByName(v.achivid).countnum <= tonumber(v.count) then
				num = num + 1
				counted[v.achivid] = true
			end
		end
	end
	return num
end

function mply:CompleteAchievement(name)

	if true then return end

	self.CompletedAchievements = self.CompletedAchievements || {}

	for i, v in pairs(self.CompletedAchievements) do
		if v.achivid == name then
			return
		end
	end

	for i, v in pairs(BreachAchievements.AchievementTable) do
		if v.name == name then
			net.Start("AchievementBar")
			net.WriteTable(v)
			net.Send(self)
			self.CompletedAchievements[#self.CompletedAchievements + 1] = {
				achivid = v.name,
				count = 1000000000000,
			}
			newMysql.query("INSERT INTO breachachievements ( owner, achivid, count ) VALUES( " .. sql.SQLStr( self:SteamID() ) .. ", ".. sql.SQLStr(v.name) .."," .. tostring(1000000000000) .. " )")
		end
	end

	if FindAchievementTableByName(name).textnotify then
		for _, ply in pairs(player.GetHumans()) do
			if ply:GTeam() == TEAM_SPEC then
				ply:RXSENDNotify("l:player ", Color(255,0,0), self:Name(), color_white, " l:unlocked_achievement \""..FindAchievementTableByName(name).achievements_name.."\"")
			end
		end
	end

	self:SetNWInt("CompletedAchievements", self:GetAchievementsNum())

end

mply.CompleteAchievements = mply.CompleteAchievement

net.Receive("CompleteAchievement_Clientside", function(len, ply)
	local achievement = net.ReadString()
	if achievement == "firsttime" then
		ply:CompleteAchievement("firsttime")
	end
end)

hook.Add("PlayerSay", "ACHIEVEMENT_SECRETWORD", function(ply, msg)
	if string.lower(msg):find("bloxwich") then
		ply:CompleteAchievement("secretword")
		return ""
	end
end)