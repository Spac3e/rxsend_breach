AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.Attack = Sound("engi_turret/turret_fire.wav")
ENT.Turn = Sound("engi_turret/turret_turn.wav")

ENT.THealth = 400

function ENT:Initialize()
	
	self:SetModel("models/codbo/other/autoturret.mdl")

	local TurretPart = ents.Create("base_gmodentity")
	TurretPart:SetModel("models/codbo/other/autoturret.mdl")

	TurretPart:SetMoveType(MOVETYPE_NONE)
	TurretPart:SetSolid(SOLID_NONE)
	TurretPart:PhysicsInit(SOLID_NONE)

	TurretPart:SetPos(self:GetPos())
	self:SetAngles(Angle(0,0,0))

	self.IgnoreCheck = {}

	self:SetUseType( SIMPLE_USE )

	self.TurnSound = CreateSound(self, self.Turn)

	self.TurretAim = TurretPart

	local turret = self


	self:PhysicsInit( SOLID_VPHYSICS );
	self:SetMoveType( MOVETYPE_VPHYSICS );
	self:SetSolid( SOLID_VPHYSICS );

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

	local phys_obj = self:GetPhysicsObject()

	if ( phys_obj && phys_obj:IsValid() ) then

	  phys_obj:Wake()
	  phys_obj:EnableMotion( false )

	end

	TurretPart:SetBodygroup(0, 0)
	TurretPart:SetBodygroup(1, 0)
	TurretPart:SetBodygroup(2, 1)
	TurretPart:SetBodygroup(3, 0)
	TurretPart:SetBodygroup(4, 0)
	TurretPart:SetBodygroup(5, 1)
	TurretPart:SetBodygroup(6, 1)

	self:SetBodygroup(0, 1)
	self:SetBodygroup(1, 1)
	self:SetBodygroup(2, 0)
	self:SetBodygroup(3, 1)
	self:SetBodygroup(4, 1)
	self:SetBodygroup(5, 1)
	self:SetBodygroup(6, 1)

	self:SetBodygroup(5,1)


end

function ENT:Use(activator)

	if activator == self:GetOwner() then
		activator:SetSpecialMax(activator:GetSpecialMax() + 1)
		activator:SetSpecialCD(CurTime()+15)
		self:Remove()
	end

	if activator:GTeam() == TEAM_SCP then
		if activator:GetRoleName() == SCP999 then return end
		local dmg = DamageInfo()
		dmg:SetDamage(90)
		dmg:SetAttacker(activator)
		dmg:SetDamageType(DMG_SLASH)
		dmg:SetInflictor(activator:GetActiveWeapon())
		self:EmitSound("nextoren/doors/door_break.wav")
		self:TakeDamageInfo(dmg)
	end

end

local SearchDistance = 500

function ENT:MoveTo(yaw)
	local uid = "TURRET["..self:EntIndex().."]_MOVESEQUENCE"

	self.Lerp = 0

	self.TurnSound:Play()

	timer.Create(uid, FrameTime(), 0, function()
		if !IsValid(self) or self.Lerp == 1 then
			if IsValid(self) then
				self:EmitSound(self.Attack)
				local data = EffectData()
				local pos, ang = self.TurretAim:GetBonePosition(1)
				local forw = ang:Forward()
				data:SetOrigin(pos + Vector(0,0,19) + forw*27)
				data:SetNormal(forw)
				data:SetScale(0.25)
				util.Effect("turret_muzzle", data)
				self.TurnSound:Stop()


				pos = self.TurretAim:GetPos() + Vector(0,0,35)

				local bullet = {}
				bullet.Attacker = self:GetOwner()
				bullet.Num 		= 1
				bullet.Src 		= pos			-- Source
				bullet.Dir 		= ang:Forward()		-- Dir of bullet
				bullet.Spread 	= Vector(0.002, 0.002, 0)		-- Aim Cone
				bullet.Tracer	= 5								-- Show a tracer on every x bullets
				bullet.Force	= 7							-- Amount of force to give to phys objects
				if self.CurrentTarget:GTeam() == TEAM_SCP then
					bullet.Damage = 150
				else
					bullet.Damage = 6
				end
				bullet.AmmoType = "Pistol"
				bullet.TracerName = "LaserTracer"
				bullet.IgnoreEntity = self
				self.TurretAim:FireBullets(bullet)
			end
			timer.Remove(uid)
			return
		end
		self.Lerp = math.Approach(self.Lerp, 1, FrameTime()*25)
		self.TurretAim:ManipulateBoneAngles(1, LerpAngle(self.Lerp, self.TurretAim:GetManipulateBoneAngles(1), Angle(0, yaw, 0)))
	end)
	self.TurretAim:SetAngles(Angle(0,0,0))
	self.TurretAim:SetPos(self:GetPos())

end

function ENT:IsFriend(ply)
	if !IsValid(ply) then
		return true
	end
	if !ply:Alive() then return true end
	if ply:Health() <= 0 then return true end
	if ply:GetNoDraw() and ply:GetRoleName() != SCP173 then
		return true
	end
	if self.IgnoreCheck[ply:SteamID64()] then
		return false
	end
	if ply:GTeam() == TEAM_SCP and ply:GetRoleName() != SCP999 then
		return false
	end
	if ply:GetModel():find("class_d") and ply:GTeam() == TEAM_CLASSD then
		return false
	end
	if ply:GetModel():find("/chaos/") then
		return false
	end
	if ply:GetModel():find("/dz/") then
		return false
	end
	return true
end

function ENT:OnRemove()
	self.TurretAim:Remove()
	self.TurnSound:Stop()
end

function ENT:CanSeeEnt( ent )



  local trace = {}

  trace.start = self.TurretAim:GetPos() + Vector(0,0,35)

  trace.endpos = ent:EyePos()

  trace.filter = { self, ent, self.TurretAim }

  trace.mask = MASK_BULLET

  local tr = util.TraceLine( trace )



  if ( tr.Fraction == 1.0 ) then



    return true;



  end



  return false;



end

local nextfire = 0
function ENT:Think()

	for i, v in pairs(ents.FindInSphere(self:GetPos(), SearchDistance)) do
		if v:IsPlayer() then
			if !IsValid(self.CurrentTarget) or ( self.CurrentTarget:GetPos():DistToSqr(self:GetPos()) > v:GetPos():DistToSqr(self:GetPos()) and !self:IsFriend(v) ) then
				self.CurrentTarget = v
			end
		end
	end

	self.TurretAim:SetPos(self:GetPos())
	self:SetAngles(Angle(0,0,0))

	if IsValid(self.CurrentTarget) and self.CurrentTarget:GetPos():DistToSqr(self:GetPos()) > SearchDistance*SearchDistance or self:IsFriend(self.CurrentTarget) then
		self.CurrentTarget = nil
	end

	if nextfire <= CurTime() and IsValid(self.CurrentTarget) then

		if self.CurrentTarget:GTeam() == TEAM_SCP then
			nextfire = CurTime() + 0.07
		else
			nextfire = CurTime() + 0.5
		end

		if IsValid(self.CurrentTarget) and self:CanSeeEnt(self.CurrentTarget) then
			self:MoveTo((self.CurrentTarget:GetPos()-self:GetPos()):Angle().yaw)
		end

	end

end

function ENT:OnTakeDamage(dmginfo)
	self.THealth = self.THealth - dmginfo:GetDamage()
	local attacker = dmginfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() and attacker:GetRoleName() != role.MTF_Engi then
		self.IgnoreCheck[attacker:SteamID64()] = true
		self.CurrentTarget = attacker
	end
	if self.THealth <= 0 then
		self:Remove()
	end
end