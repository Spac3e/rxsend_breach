AddCSLuaFile()

ENT.Type = "anim"
ENT.Owners = {}

ENT.Base = "base_gmodentity"
ENT.CanTakeDamage = true

function ENT:AddOwner(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    self.Owners[ply:SteamID()] = ply
end

function ENT:RemoveOwner(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    self.Owners[ply:SteamID()] = nil
end

function ENT:GetOwners()
    local owners = {}
    for _, ply in pairs(self.Owners) do
        if IsValid(ply) then
            table.insert(owners, ply)
        end
    end
    return owners
end

function ENT:Initialize()
    self:SetModel("models/props_c17/oildrum001.mdl") 

    if SERVER then
        self:SetMaxHealth(20)
        self:SetHealth(20)

        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_BBOX)
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
        self:SetCollisionBounds(Vector(15, -75, 0), Vector(-21, 75, 125))
        self:CollisionRulesChanged()
        self:PhysicsInitBox(Vector(15, -75, 0), Vector(-21, 75, 125))
        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end

        self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)  

        local owner = self:GetOwner()
        if IsValid(owner) and owner:IsPlayer() then
            self:AddOwner(owner)
            self:SetNWEntity("PrimaryOwner", owner)
        end
    end
end

function ENT:Think()
    self:NextThink(CurTime() + 1)
    return true
end

function ENT:CopyPlayerPose(ply)
    local seq = ply:GetSequence()
    self:SetSequence(seq)
    self:ResetSequenceInfo()

    for i = 0, ply:GetNumPoseParameters() - 1 do
        local pname = ply:GetPoseParameterName(i)
        local pval = ply:GetPoseParameter(pname)
        self:SetPoseParameter(pname, pval)
    end

    self:SetPlaybackRate(0)

    if self.SetupBones then
        self:SetupBones()
    end
end

function ENT:OnTakeDamage(dmg)
    if not SERVER then return end

    print("实体受到了伤害") 

    local att = dmg:GetAttacker()
    if not IsValid(att) or not att:IsPlayer() then return end

    local newHealth = self:Health() - dmg:GetDamage()
    print(newHealth)
    self:SetHealth(newHealth)

    if newHealth <= 0 then
        for _, owner in ipairs(self:GetOwners()) do
            if IsValid(owner) and owner:IsPlayer() then
                owner:ChatPrint("你的投影已被摧毁！")
            end
        end

        self:Destroy()
    end
end

function ENT:Destroy()
    if SERVER then
        local explosion = ents.Create("env_explosion")
        if not IsValid(explosion) then
            print("[Error] Failed to create explosion entity.")
            return
        end

        local pos = self:GetPos()
        explosion:SetPos(pos)
        explosion:SetKeyValue("spawnflags", 129) 
        explosion:SetKeyValue("iMagnitude", 100) 

        explosion:Spawn()
        explosion:Fire("explode", "", 0)

        for _, v in pairs(ents.FindInSphere(pos, 300)) do  --爆炸范围
            if v:IsPlayer() and v:GTeam() ~= TEAM_SPEC then
                local dist = v:GetPos():Distance(pos)
                local dmginfo = DamageInfo()

                dmginfo:SetDamage(math.ceil((301 - dist) / 2)) --伤害
                dmginfo:SetAttacker(self)
                dmginfo:SetInflictor(explosion)

                v:TakeDamageInfo(dmginfo)
            end
        end
		
        self:Remove()
    end
end
function ENT:Draw()
    if CLIENT then
        self:DrawModel()
    end
end

--[[

if not IsValid(ply) or not ply:IsPlayer() then return end

		local ent = ents.Create("fake_people") 
		if not IsValid(ent) then return end

		local invisiblePlayers = {}
		ply:SetNoDraw(true)
		
		invisiblePlayers[ply] = true
		
		timer.Create("InvisibilityTimer_" .. ply:SteamID(), 20, 1, function()
			if IsValid(ply) and invisiblePlayers[ply] then
				ply:SetNoDraw(false)
				invisiblePlayers[ply] = nil
			end
		end)
		
		hook.Add("PlayerButtonDown", "InvisibilityCancelOnAttack", function(ply, button)
			if invisiblePlayers[ply] and button == IN_ATTACK then
				ply:SetNoDraw(false)
				invisiblePlayers[ply] = nil
				timer.Remove("InvisibilityTimer_" .. ply:SteamID())
			end
		end)

		local model = ply:GetModel()
		local pos = ply:GetPos()
		local ang = ply:GetAngles()
		ent:Spawn()
			ent:SetModel(model)
			ent:SetPos(pos)
			ent:SetAngles(ang)

			ent:SetOwner(ply)      

			ent:CopyPlayerPose(ply)

			ent:AddOwner(ply)
			ent:SetNWEntity("PrimaryOwner", ply)

			if ply.BoneMergedEnts then
				for _, v in pairs(ply.BoneMergedEnts) do
					if IsValid(v) and not v:GetInvisible() then
						local mdl = v:GetModel()
						local mskin = v:GetSkin()
						Bonemerge(mdl, ent, mskin)
					end
				end

				for index, mat in ipairs(ply:GetMaterials()) do
					ent:SetSubMaterial(index - 1, ply:GetSubMaterial(index - 1))
				end

				if ply.HeadEnt and ply.HeadEnt:IsValid() then
					for index, mat in ipairs(ply.HeadEnt:GetMaterials()) do
						ent.HeadEnt:SetSubMaterial(index - 1, ply.HeadEnt:GetSubMaterial(index - 1))
						ent.HeadEnt:SetSkin(ply.HeadEnt:GetSkin())
					end
				end
			end 
			
			for i = 0, ply:GetNumBodyGroups() - 1 do
				local bg = ply:GetBodygroup(i)
				ent:SetBodygroup(i, bg)
			end



]]