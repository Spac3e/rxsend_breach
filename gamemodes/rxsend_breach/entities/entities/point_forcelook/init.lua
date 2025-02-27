
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.NextHit = 0

function ENT:Initialize()
	self:SetModel("models/props_c17/oildrum001.mdl")
	self:SetColor(Color(0,0,0,0))
	self:SetSolid(SOLID_NONE)
end

function ENT:Think()
	if self:GetPos() != Vector(-676.172058, 6937.478027, 2070.031250) then
		local plys = player.GetAll()
		for i = 1, #plys do
			local v = plys[i]
			if v:GTeam() == TEAM_SPEC then continue end
			local tr = util.TraceLine({
				start = v:GetShootPos(),
				endpos = self:GetPos(),
				filter = {v, self, Entity(0)}
			})
			if not tr.Hit and self.NextHit <= SysTime() then
				local dmg = DamageInfo()
				self.NextHit = SysTime() + 1
				dmg:SetDamage(1)
				dmg:SetAttacker(game.GetWorld())
				dmg:SetInflictor(game.GetWorld())
				v:TakeDamageInfo(dmg)
			end
		end
	end
end