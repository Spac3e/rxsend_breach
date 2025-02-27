AddCSLuaFile()

ENT.PrintName		= "Tree"
ENT.Author		    = ""
ENT.Type			= "anim"
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Owner = nil
ENT.IsAttacking = false
ENT.CurrentTargets = {}
ENT.Attacks = 0
ENT.SnapSound = Sound( "snap.wav" )

function ENT:Initialize()
	self.Entity:SetModel( "models/trees/new_elm.mdl" )
	self.Entity:SetMoveType(MOVETYPE_NOCLIP )
	self:SetCollisionGroup( COLLISION_GROUP_NONE    )
	self.Entity:SetPos(Vector(9085.486328, -1932.134644, 5.520229))
	
    self.Entity:SetModelScale( 0.23, 1 )
	 
	 
end


function ENT:Think()
    if SERVER then
        for k,v in pairs(ents.FindInSphere(self.Entity:GetPos(), 150)) do

	        if !IsValid(v:GetOwner()) then
                if v:IsPlayer() then return false end
                if v:IsWeapon() then
                    if v == self.Copied then return end
                    if v == self.CopiedOut then return end
			        if v:GetClass() == "item_scp_005" then continue end
			        if v:GetClass() == "weapon_special_gaus" then continue end
                    local Copy = ents.Create( v:GetClass() )
                    Copy:Spawn()
                    Copy:SetPos( Vector(9085.438477, -1904.265137, 81.331055) )
			
                    
                    self.Copied = v

                    
                    self.CopiedOut = Copy
                end
            

            end
	    end
    end

    self:NextThink( CurTime() + 1 )
    return true 
end
