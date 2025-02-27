AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model( "models/props_lab/binderredlabel.mdl" )

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	local physobj = self:GetPhysicsObject()
	if IsValid(physobj) then
		physobj:EnableMotion(false)
	end

	self:SetPos(Vector(-3662.137451, 5277.582031, 1704.031250))
end

function ENT:Think()
	self:NextThink(CurTime() + 0.1)
	local tabl = ents.FindInSphere(self:GetPos(), 45)
	if !istable(tabl) then return end
	for _, ply in ipairs(tabl) do
		if IsValid(ply) and ply:IsPlayer() then
			if ply:GTeam() == TEAM_DZ then
				local veh = ply:GetVehicle()
				if ply:InVehicle() then
					ply:CompleteAchievements("carportal")
					ply:ExitVehicle()
				end
				for _, wep in ipairs(ply:GetWeapons()) do
					if wep:GetClass():find("_scp_") then ply:AddToStatistics("l:sh_scps_stolen", 200) end
				end
				ply:AddToStatistics("l:escaped", 200)
				net.Start("Ending_HUD")
					net.WriteString("l:ending_tp_to_unknown_loc")
				net.Send(ply)
				ply:LevelBar()
				ply:SetupNormal()
				ply:SetSpectator()
				if IsValid(veh) then veh:Remove() end
			elseif ply:GTeam() == TEAM_SCP then
				ply:AddToStatistics("l:escaped", 600 * tonumber("1."..tostring(ply:GetNLevel() * 2)))
				net.Start("Ending_HUD")
					net.WriteString("l:ending_tp_to_unknown_loc")
				net.Send(ply)
				ply:LevelBar()
				ply:SetupNormal()
				ply:SetSpectator()
				for i, v in pairs(player.GetAll()) do
					if v.GTeam and v:GTeam() == TEAM_DZ then
						v:AddToStatistics("l:sh_scps_evacuated", 210)
					end
				end
			elseif ply:GetModel() == "models/player/april/the_goose.mdl" then
				ply:AddToStatistics("l:escaped", 300 * tonumber("1."..tostring(ply:GetNLevel() * 2)))
				net.Start("Ending_HUD")
					net.WriteString("l:ending_tp_to_unknown_loc")
				net.Send(ply)
				ply:LevelBar()
				ply:SetupNormal()
				ply:SetSpectator()
			elseif ply:GetModel() == "models/scp_527/scp_527.mdl" then
				ply:AddToStatistics("l:escaped", 300 * tonumber("1."..tostring(ply:GetNLevel() * 2)))
				net.Start("Ending_HUD")
					net.WriteString("l:ending_tp_to_unknown_loc")
				net.Send(ply)
				ply:LevelBar()
				ply:SetupNormal()
				ply:SetSpectator()
			end
		end
	end
end