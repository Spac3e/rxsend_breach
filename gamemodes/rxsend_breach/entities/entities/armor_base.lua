AddCSLuaFile()

ENT.PrintName		= "Base Armor"
ENT.Author		    = "Kanade"
ENT.Type			= "anim"
ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.ArmorType = "armor_mtfguard"
ENT.Bodygroups = {

  [0] = "0", -- шлем
  [1] = "0", -- броня
  [2] = "0"

}

function ENT:Initialize()

	if self:GetClass() == "armor_sci" then
		local pickrole = BREACH_ROLES.SCI.sci.roles[table.Random({1,4,6})]
		for i = 0, 12 do
			if pickrole["bodygroup"..i] then
				self.Bodygroups[i] = tostring(pickrole["bodygroup"..i])
			end
		end
	end

	self.Entity:SetModel(self.Model)

	self.Entity:PhysicsInit(SOLID_VPHYSICS)

	//self.Entity:SetMoveType(MOVETYPE_VPHYSICS)

	self.Entity:SetMoveType(MOVETYPE_NONE)

	self.Entity:SetSolid(SOLID_BBOX)

	if SERVER then

		self:SetUseType(SIMPLE_USE)

	end
	
	//local phys = self.Entity:GetPhysicsObject()

	//if phys and phys:IsValid() then phys:Wake() end

	self:SetCollisionGroup(COLLISION_GROUP_WEAPON) 

	if ( self.SkinModel ) then

		self:SetSkin( self.SkinModel )

	end

	--timer.Simple( .2, function()

		if ( !( self && self:IsValid() ) ) then return end

		if ( self.BodygroupModel ) then

			self:SetBodygroup( 0, self.BodygroupModel )

		end

		self:SetPos( Vector( self:GetPos().x, self:GetPos().y, self:GetPos().z  ) )

	--end )

end

print("CHECK!")

local nextuse = 0
local delay = 1

function ENT:Use(ply)
	if !self:GetClass():find('hazmat') and ply:GetRoleName() == role.ClassD_Banned then
		ply:RXSENDNotify("Вы можете надеть только химзащиту")
		return
	end
if nextuse > CurTime() then return end
if timer.Exists("WearingClothThink"..ply:SteamID()) then return end
if ply:GetModel():find("goc") then return end
if ply:GetModel():find("chaos") then return end
if ply:GetModel():find("goose") then return end
if ply:GetModel():find("scp_527") then return end
if ply:GetRoleName() == role.ClassD_Hitman and ply:GetRoleName() == role.ClassD_LegHitman and !ply:GetModel():find("class_d.mdl") then return end
if self.IsUsedAlready then return end
if self.Team and ply:GTeam() != self.Team and ply:GetRoleName() != role.ClassD_GOCSpy then ply:RXSENDNotify("l:you_cant_wear_this_uniform") return end

	if ( ply:GTeam() == TEAM_CLASSD or ply:GTeam() == TEAM_SCI or ply:GetRoleName() == role.ClassD_GOCSpy or ply:GetRoleName() == role.SCI_SpyUSA or ply:GetRoleName() == role.SCI_SpyDZ ) and ply:GetRoleName() != role.ClassD_Fat and ply:GetRoleName() != role.ClassD_Bor then
		nextuse = CurTime() + delay
		if SERVER then
			if ply:GetUsingCloth() != "" then
				ply:BrTip( 0, "[RX Breach]", Color(255, 0, 0), "l:has_uniform_already", Color(255, 255, 255) )
				return
			end
			if self:GetClass() != "armor_sci" and self:GetClass() != "armor_medic" then
				if ply:GetUsingArmor() != "" and ( self:GetClass() != "armor_sci" or self:GetClass() != "armor_medic" ) then
					ply:BrTip( 0, "[RX Breach]", Color(255, 0, 0), "l:take_off_armor_to_wear_uniform", Color(255, 255, 255) )
					return
				end
				if ply:GetUsingHelmet() != "" and ( self:GetClass() != "armor_sci" or self:GetClass() != "armor_medic" ) then
					ply:BrTip( 0, "[RX Breach]", Color(255, 0, 0), "l:take_off_armor_to_wear_uniform", Color(255, 255, 255) )
					return
				end
			end
			ply:BrProgressBar("l:progress_wait", 7, "nextoren/gui/icons/hand.png", self, false, function()
				self:EmitSound( Sound("nextoren/others/cloth_pickup.wav") )

				if ply.BoneMergedHackerHat then

					for _, v in pairs( ply.BoneMergedHackerHat ) do
			
						if ( v && v:IsValid() ) then
							
							v:SetInvisible(true)
			
						end

					end

				end

				if ( self.HideBoneMerge ) then
			
					for _, v in pairs( ply:LookupBonemerges() ) do
			
						if ( v && v:IsValid() && !v:GetModel():find("backpack") ) then
							
							v:SetInvisible(true)
			
						end

					end
			
				end
				if self:GetClass() == "armor_medic" or self:GetClass() == "armor_mtf" then
					for _, v in pairs( ply:LookupBonemerges() ) do
			
						if ( v:GetModel():find("hair") and !ply:IsFemale() ) then
					
							v:SetInvisible(true)
			
						end
			
					end
				end
				ply.OldModel = ply:GetModel()
				ply.OldSkin = ply:GetSkin()
				if ( self.Bodygroups ) then
			
					ply.OldBodygroups = ply:GetBodyGroupsString()
			
					ply:ClearBodyGroups()

					ply.ModelBodygroups = self.Bodygroups
			
					if ( self.Bonemerge ) then
			
						for _, v in ipairs( self.Bonemerge ) do
			
							GhostBoneMerge( ply, v )
			
						end
			
					end
			
				end
				if self.MultiGender then
					if ply:IsFemale() then
						ply:SetModel(self.ArmorModelFem)
					else
						ply:SetModel(self.ArmorModel)
					end
				else
					ply:SetModel(self.ArmorModel)
				end
				if ( self.ArmorSkin ) then
					ply:SetSkin(self.ArmorSkin)
				end
	
				if self.MultipliersType then
					ply.ClothMultipliersType = self.MultipliersType
				end
				hook.Run("BreachLog_PickUpArmor", ply, self:GetClass())
				if isfunction(self.FuncOnPickup) then self.FuncOnPickup(ply) end
				self:Remove() 
			
				ply:BrTip( 0, "[RX Breach]", Color( 0, 210, 0, 180 ), "l:your_uniform_is "..self.PrintName, Color( 0, 255, 0, 180 ) )
				ply:SetupHands()
				if self.ArmorSkin then
					ply:GetHands():SetSkin(self.ArmorSkin)
				end

				ply:SetUsingCloth(self:GetClass())

				timer.Simple( .25, function()
			
						for bodygroupid, bodygroupvalue in pairs( ply.ModelBodygroups ) do
							
							if !istable(bodygroupvalue) then
								ply:SetBodygroup( bodygroupid, bodygroupvalue )
							end
			
						end
			
					end )
			end )
			
		end
	end
end

function ENT:Draw()
	self:DrawModel()
end