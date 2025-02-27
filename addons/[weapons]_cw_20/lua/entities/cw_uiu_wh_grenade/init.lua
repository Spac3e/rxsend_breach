AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.ExplodeRadius = 384
ENT.ExplodeDamage = 100
ENT.Model = "models/cultist/items/uiu_agent_whgrenade/grenade.mdl"

local phys, ef

function ENT:Initialize()
	self:SetModel(self.Model) 
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self.NextImpact = 0
	phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then
		phys:Wake()
		phys:SetBuoyancyRatio(0)
		phys:SetDamping(0, 3)
		phys:SetInertia(Vector(35,0,35))
		phys:SetMass(0)
	end
end

function ENT:UpdateTransmitState()
	
	return TRANSMIT_ALWAYS
end

function ENT:Use(activator, caller)
	return false
end

function ENT:OnRemove()
	return false
end

function ENT:Think()
	if self.fused then return end

	if self:BrOnGround() then
		self:Fuse(0, self.grenadetype)
	end

end

local vel, len, CT

function ENT:PhysicsCollide(data, physobj)
	vel = physobj:GetVelocity()
	len = vel:Length()
	
	if len > 500 then -- let it roll
		physobj:SetVelocity(vel * 0.6) -- cheap as fuck, but it works
	end
	
	if len > 100 then
		CT = CurTime()
		
		if CT > self.NextImpact then
			self:EmitSound("weapons/smokegrenade/grenade_hit1.wav", 75, 100)
			self.NextImpact = CT + 0.1
		end
	end
end

function ENT:Fuse(t, type)
	t = t or 3
	
	self.fused = true

	self:SetFused(true)

	self:EmitSound("^rxsend/wh_uiu_grenade/gren_loop.ogg")
end