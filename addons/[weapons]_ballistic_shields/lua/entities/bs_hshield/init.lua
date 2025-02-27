AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')


function ENT:Initialize()
	self.Entity:SetModel("models/weapons/shield/w_shield.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetRenderMode( RENDERMODE_TRANSCOLOR )
	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
		phys:SetMass(100)
	end
end

function ENT:Think()
	if self:GetParent() then
		if self:GetParent():GetMoveType() == MOVETYPE_OBSERVER or self:GetParent():GetObserverMode() != OBS_MODE_NONE or !self:GetParent():Alive() or !self:GetParent():HasWeapon("heavy_shield") then
			self:Remove()
		end
	end
end