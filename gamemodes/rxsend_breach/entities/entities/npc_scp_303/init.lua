AddCSLuaFile("shared.lua")
include("shared.lua")

local function PlysWithinABox(box1, box2)
	for _, ply in pairs(player.GetAll()) do
		if ply:GTeam() == TEAM_SPEC then continue end
		if ply:GTeam() == TEAM_SCP then continue end
		if ply:Health() <= 0 then continue end
		if !ply:Alive() then continue end
		if ply:GetPos():WithinAABox(box1, box2) then return true end
	end
	return false
end

function ENT:picktable()
	for _, tab in RandomPairs(self.SCP_303_CONFIG, false) do
		if !PlysWithinABox(tab.CheckForPlayers[1], tab.CheckForPlayers[2]) then continue end
		if PlysWithinABox(tab.CheckForNoPlayers[1], tab.CheckForNoPlayers[2]) then continue end
		return tab
	end
	return nil
end

local function MakeShouldSpawnRandom()
	local rand = math.random(0, 100)
	return rand <= 20 -- 20% to spawn
end

local function CanMakeCheck()
	return !postround and gamestarted and !preparing
end

function ENT:OnTakeDamage(dmginfo)
	local attacker = dmginfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() and attacker:GTeam() != TEAM_SCP and attacker:GTeam() != TEAM_SPEC then 
		attacker:SetForcedAnimation(attacker:LookupSequence("2ugbait_hit"), 3, function()
			attacker:GodEnable()
			attacker:SetMoveType(MOVETYPE_OBSERVER)
			attacker:Freeze(true)
			attacker:SetNWEntity("NTF1Entity", attacker)
			attacker:EmitSound("nextoren/charactersounds/hurtsounds/hg_onfire0"..tostring(math.random(1,4))..".wav", 165, 100, 1.35, CHAN_VOICE)
		end, function()
			attacker:SetMoveType(MOVETYPE_WALK)
			attacker:Freeze(false)
			attacker:SetNWEntity("NTF1Entity", NULL)
			attacker:Kill()
			attacker:LevelBar()
			attacker:StopSound("nextoren/charactersounds/hurtsounds/hg_onfire01.wav")
			attacker:StopSound("nextoren/charactersounds/hurtsounds/hg_onfire02.wav")
			attacker:StopSound("nextoren/charactersounds/hurtsounds/hg_onfire03.wav")
			attacker:StopSound("nextoren/charactersounds/hurtsounds/hg_onfire04.wav")
		end)
	end
end

timer.Create("SCP_303_SPAWN", 120, 0, function()
	local rand = math.random(0,100)
	if rand <= 20 and CanMakeCheck() then
		local ent = ents.Create("npc_scp_303")
		ent:Spawn()
	end
end)

ENT.SCP_303_CONFIG = {
	{
		pos = Vector(-1727.990234375, 2395.587890625, 0.03125),
		ang = Angle(0,90,0),
		CheckForPlayers = {Vector(-1415.6171875, 2440.6928710938, 255.26457214355), Vector(-2037.6555175781, 2877.3139648438, -128.28379821777)},
		CheckForNoPlayers = {Vector(-1405.0634765625, 2282.1381835938, 193.55326843262), Vector(-2042.4888916016, 2440.2846679688, -36.809215545654)},
	},
	{
		pos = Vector(-1856.8875732422, 5343.0302734375, 0.03125),
		ang = Angle(0,90,0),
		CheckForPlayers = {Vector(-2167.7250976563, 5390.3828125, 234.41983032227), Vector(-993.31146240234, 6167.2817382813, -33.028888702393)},
		CheckForNoPlayers = {Vector(-1941.8990478516, 5399.875, 204.26742553711), Vector(-1299.9688720703, 4320.48046875, -36.728115081787)},
	},
	{
		pos = Vector(-1057.4510498047, 5696.11328125, 0.03125),
		ang = Angle(0,0,0),
		CheckForPlayers = {Vector(-998.28796386719, 5592.5073242188, 541.61077880859), Vector(-401.0378112793, 6382.3862304688, -0.56832838058472)},
		CheckForNoPlayers = {Vector(-1000.860534668, 5114.6479492188, -68.491645812988), Vector(-2126.7666015625, 6177.5869140625, 496.24438476563)},
	},
	{
		pos = Vector(-2593.8518066406, 2353.8686523438, 0.03125),
		ang = Angle(0,0,0),
		CheckForPlayers = {Vector(-2556.9921875, 2008.7222900391, -69.960479736328), Vector(-2051.2280273438, 2690.3295898438, 300.27728271484)},
		CheckForNoPlayers = {Vector(-2553.1359863281, 2444.1901855469, 580.84204101563), Vector(-3091.1252441406, 1580.3048095703, -14.112850189209)},
	},
}