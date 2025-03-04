AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.BurnDuration = 25

ENT.ExplodeRadius = 256
ENT.ExplodeDamage = 0

ENT.Model = "models/weapons/w_molotov.mdl"

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
	end

	self:GetPhysicsObject():SetBuoyancyRatio(0)
end

function ENT:Use(activator, caller)
	return false
end

function ENT:OnRemove()
	return false
end

local vel, len, CT

function ENT:PhysicsCollide(data, physobj)
	self.resetOwner = true

	vel = physobj:GetVelocity()
	len = vel:Length()

	if len > 500 then -- let it roll
		physobj:SetVelocity(vel * 0.6) -- cheap as fuck, but it works
	end

	if len > 100 then
		CT = CurTime()

		if CT > self.NextImpact then
			self:EmitSound("CW_KK_INS2_ANM14_ENT_BOUNCE", 75, 100)
			self.NextImpact = CT + 0.1
		end
	end
end

function ENT:Fuse(t)
	t = t or 3

	self.kaboomboomTime = CurTime() + t
end

function ENT:Detonate()
	if self.wentBoomAlready then
		return
	end

	local check_if_bottom = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + Vector(0,0,-10),
		filter = self,
	})

	if !check_if_bottom.Hit then return end

	self.wentBoomAlready = true

	self:StopParticles()

	t = 30

	if self:WaterLevel() == 0 then
		local fx = ents.Create("cw_kk_ins2_particles")
		fx:processProjectile(self)
		fx:Spawn()

		BREACH_FIRE_INITIATE(self:GetPos(), 22, self)

		timer.Simple(1, function()
			if IsValid(fx) then fx:Remove() end
		end)

		-- local bn = ents.Create("cw_kk_ins2_burn")
		-- bn:processProjectile(self)
		-- bn:Spawn()

		self:SetNoDraw(true)

		td.start = self:GetPos()
		td.endpos = self:GetPos() + dn
		td.filter = self

		tr = util.TraceLine(td)

		if tr.Hit then
			self:SetPos(tr.HitPos)
		end

		t = 2
	end

	SafeRemoveEntityDelayed(self, 30)
end

function ENT:Think()
	if self.kaboomboomTime and CurTime() > self.kaboomboomTime then
		self:Detonate()
	end

	if self.resetOwner then
		self.resetOwner = false
		self:SetOwner()
	end
end
