AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.ExplodeRadius = 384
ENT.ExplodeDamage = 100
ENT.Model = "models/weapons/w_eq_smokegrenade_thrown.mdl"

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

	self:Fuse(3, self.grenadetype)
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
	
	timer.Simple(t, function()
		if self:IsValid() and !self.fused then
			local hitPos = self:GetPos()

			self.fused = true
			
			if type == 1 then
				local smokeScreen = ents.Create("cw_smokescreen_912")
				smokeScreen:SetPos(hitPos)
				smokeScreen:Spawn()
			else
				local data = EffectData()
				data:SetScale(15)
				data:SetOrigin(self:GetPos())
				util.Effect("scp_912_gas", data)

				local perdeshextreme = ents.Create("base_gmodentity")
				perdeshextreme:SetPos(self:GetPos())

				perdeshextreme:SetNoDraw(true)

				perdeshextreme:SetMoveType(MOVETYPE_NONE)

				perdeshextreme:Spawn()

				perdeshextreme.Think = function(self)

					local Ents = ents.FindInSphere(self:GetPos(), 250)

					for i = 1, #Ents do
						local ply = Ents[i]
						if ply.IsPlayer and ply:IsPlayer() and ply:GTeam() != TEAM_USA and ply:GTeam() != TEAM_SPEC and ply:IsLineOfSightClear(self:GetPos()) then
							local owner = self:GetOwner()
							if !timer.Exists("GAS_DAMAGE_XD"..ply:SteamID64()) then
								ply:ScreenFade(SCREENFADE.IN, Color(255,0,0), 1, 0.5)
								if IsValid(owner) then
									ply:TakeDamage(math.random(5, 10), owner, owner:GetActiveWeapon())
								else
									ply:TakeDamage(math.random(5, 10), ply)
								end
								timer.Create("GAS_DAMAGE_XD"..ply:SteamID64(), 1, 1, function() end)
							end
						end
					end

				end

				timer.Simple(14, function()
					if IsValid(perdeshextreme) then perdeshextreme:Remove() end
				end)

				sound.Play("weapons/smokegrenade/sg_explode.wav", self:GetPos(), 75, 175, 1)
			end
			
			self:Remove()
		end
	end)
end