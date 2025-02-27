AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = Model( "models/player/Group01/male_01.mdl" )

function ENT:Initialize()

	self:SetModel(self.Model)
	
	self:SetMoveType(MOVETYPE_NONE)
	self:PhysicsInit(SOLID_NONE)
	self:SetSolid(SOLID_BBOX)

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	self.filter = function(ent)

		if IsValid(ent) and ( ent:GetClass() == "breach_molotov_fire" ) then return false end

		return true

	end
	
end

function ENT:Think()

	for i, v in pairs(ents.FindInSphere(self:GetPos(), 40)) do

		if IsValid(v) and v:IsPlayer() and v:GTeam() != TEAM_SPEC and v:Alive() and v:Health() > 0 then

			local mins = v:OBBMins()
			local maxs = v:OBBMaxs()

			local tr = util.TraceHull({
				start = self:GetPos() + Vector(0,0,10),
				endpos = v:GetPos() + (self:GetPos() + v:GetPos()):Angle():Forward()*20,
				mins = mins,
				maxs = maxs,
				filter = self.filter,
			})

			if tr.Entity == v then

				v:SetOnFire(2)

			end

		end

	end

	self:NextThink( CurTime() + 0.1 )
end