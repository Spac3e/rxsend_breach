AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model("models/shaky/breach/gift.mdl")

function ENT:Initialize()

	self:SetModel(self.Model)
	
	self:SetMoveType(MOVETYPE_NONE)
	self:PhysicsInit(SOLID_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	self:SetUseType(SIMPLE_USE)

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	
end

function ENT:Use(ply)

	if self.CantUse then return end

	if ply.TempValues.usedgift then return end

	RunConsoleCommand("breach_donate",ply:SteamID64(),unpack(string.Explode(" ", self.arguments)))

	self.CantUse = true

	ply.TempValues.usedgift = true

	local sexname = "DissolveGift"..self:EntIndex()
	hook.Add("Think", sexname, function()
		if !IsValid(self) or self:GetColor().a <= 0 then if IsValid(self) then self:Remove() end timer.Remove(sexname) return end

		local alpha = self:GetColor().a

		alpha = math.Approach(alpha, 0, -5)

		self:SetPos(self:GetPos() + Vector(0,0,1))

		self:SetColor(Color(255,255,255,alpha))

	end)

end

concommand.Add("br_creategift", function(ply,cmd, args, argstr)
	if !ply:IsSuperAdmin() then return end

	local gift = ents.Create("breach_gift")
	gift:SetPos(ply:GetEyeTrace().HitPos)
	gift:Spawn()

	gift.arguments = argstr

	undo.Create("prop")
		undo.AddEntity(gift)
		undo.SetPlayer(ply)
	undo.Finish()
end)