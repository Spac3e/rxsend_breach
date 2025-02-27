AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 
include('shared.lua')

function ENT:Initialize()
	self:SetModel( "models/vinrax/props/cup_294.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS ) 
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS ) 
	self:SetUseType( SIMPLE_USE )
	self:SetNWBool("WasDrunk", false)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	end
end

function ENT:Use( ply, caller )
if ply:GTeam() == TEAM_SCP or ply:GTeam() == TEAM_SPEC then return end
	if not self:GetNWBool("WasDrunk") then
		local Drink = SCP294.Drinks[self:GetNWString("Drink")]
		if (Drink) then
			if (Drink.effect) then
				Drink.effect(ply)
			end
		else
			ply:Say( (SCP294BasicText or "A pretty good coffee .." ) )
			ply:EmitSound("scp294/slurp.ogg")
		end
		
		self:SetNWBool("WasDrunk", true)
		timer.Simple(2, function()
			self:Remove()
		end)
	end
end

function ENT:Think()
end

function ENT:OnRemove()
end