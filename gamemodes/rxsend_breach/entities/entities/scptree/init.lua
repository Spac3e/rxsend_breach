AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Model = "models/props_foliage/small-tree01.mdl"

ENT.BlockedWeapons = {}

function ENT:Initialize()

	self:SetModel( self.Model )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )

	--self:SetUseType( SIMPLE_USE )

	self:SetCollisionGroup( COLLISION_GROUP_NONE )

	self:SetPos(Vector(9088.7763671875, -1937.5451660156, 17.3310546875))

	local physobject = self:GetPhysicsObject()

	if ( physobject:IsValid() ) then

		physobject:EnableMotion( false )

	end

	timer.Create("SCP_Tree_item_dupe", 1, 0, function()

		local EntityList = ents.FindInBox( Vector(8879.58984375, -2071.1611328125, 46.128795623779), Vector(9328.998046875, -1798.9703369141, 0.52617311477661) )

		for i = 1, #EntityList do

			local weapon = EntityList[i]

			if !IsValid(weapon) then continue end
			if !weapon:IsWeapon() then continue end
			if weapon.DupedSCPTree then continue end
			if weapon:GetClass():find("_scp_") then continue end
			if weapon:GetClass():find("_dado_") then continue end
			if !weapon.JustPlacedSCPTree then weapon.JustPlacedSCPTree = CurTime() + 2 end
			if  weapon.JustPlacedSCPTree > CurTime() then continue end 

			local physobject = weapon:GetPhysicsObject()
			if ( IsValid(physobject) ) then physobject:EnableMotion(false) end
			local pos = Vector(math.random(8910, 9284), math.random(-1830, -2041), math.random(98, 116))
			weapon.DupedSCPTree = true
			timer.Simple(0.4, function()
				weapon:SetPos( Vector(weapon:GetPos().x, weapon:GetPos().y, weapon:GetPos().z - 1 ) )
				timer.Simple(0.4, function()
					weapon:SetPos( Vector(weapon:GetPos().x, weapon:GetPos().y, weapon:GetPos().z - 1 ) )
					timer.Simple(0.4, function()
						weapon:SetPos( Vector(weapon:GetPos().x, weapon:GetPos().y, weapon:GetPos().z - 1 ) )
						timer.Simple(0.4, function()
							weapon:SetPos( Vector(weapon:GetPos().x, weapon:GetPos().y, weapon:GetPos().z - 1 ) )
							weapon:SetNoDraw(true)
							timer.Simple(1, function()
								local class = weapon:GetClass()
								local newwep = ents.Create(class)
								if class == "weapon_special_gaus" then
									newwep.CanCharge = weapon.CanCharge
								end
								newwep:Spawn()
								print(weapon.ActiveAttachments)
								if weapon.ActiveAttachments then
									newwep.ActiveAttachments = table.Copy(weapon.ActiveAttachments)
								end
								print(weapon.ActiveAttachments)
								print(newwep.ActiveAttachments)
								newwep:SetClip1(weapon:Clip1())
								newwep:SetClip2(weapon:Clip2())
								weapon:SetPos(Vector(pos.x, pos.y,GroundPos(pos).z + 5))
								newwep:SetPos(Vector(pos.x, pos.y,GroundPos(pos).z + 10))
								weapon:SetNoDraw(false)
								newwep.DupedSCPTree = true
								local physobject = weapon:GetPhysicsObject()
								if ( IsValid(physobject) ) then physobject:EnableMotion(true) end
							end)
						end)
					end)
				end)
			end)
		end

	end)

end