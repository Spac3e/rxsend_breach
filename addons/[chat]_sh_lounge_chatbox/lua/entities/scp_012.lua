AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.PrintName = "SCP-012"
ENT.Information = "A Bad Composition"
ENT.Category = "SCP"

ENT.Editable = false
ENT.Spawnable = true
ENT.AdminOnly = true

local textureindex = 1
local used = false

function ENT:Initialize()

	if (CLIENT) then return end

	self:SetModel("models/scp012comp/scp012comp.mdl")
	self:SetSkin(1)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if ( phys && phys:IsValid() ) then

		phys:Wake()

	end

end

function ENT:Draw()

	if (SERVER) then return end

	self:DrawModel()

end

local mins, maxs = Vector( -350, -250, -150 ), Vector( -300, -200, -100 )

function ENT:Think()

	if self:GetPos():WithinAABox( mins, maxs ) then return end

	for _, ply in pairs (ents.FindInSphere(self:GetPos(), 123)) do

		if (( ply:IsPlayer() ) and not (ply:Team() == TEAM_SCP) and not (ply:Team() == TEAM_SPEC) and not ply:HasGodMode()) then

			ply:SetEyeAngles((self:GetPos() - ply:GetShootPos()):Angle())
			ply:SetHealth(ply:Health() - 3)
			ply:EmitSound("ambient/creatures/town_scared_breathing1.wav" ,30 , 100, 1, CHAN_VOICE)
			if ((ply:Health() <= 0) && (SERVER) && ply:Alive()) then

				ply:Kill()

			end

			if (used == false) then

				textureindex = textureindex + 1
				used = true
				timer.Simple(1, function()
					used = false
				end)

			end

			if (textureindex == 5) then

				textureindex = 1

			end

			self:SetSkin(textureindex)

			if ( CLIENT ) then

				self:DrawModel()

			end

		end

	end
end
