AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Use(activator)
	if self:GetEmergencyMode() then return end
	if !IsBigRound() then return end
	if activator:GTeam() == TEAM_GUARD or activator:GetModel():find("mog.mdl") then
		self:SetEmergencyMode(true)
		self:EmitSound("nextoren/others/button_unlocked.wav", 100, 115, 1.2)
		timer.Simple(4.5, function()
			self:SetEmergencyMode(false)
		end)
	end
end