AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.CurrentFrame = 1
ENT.AutomaticFrameAdvance = true
ENT.IsDriving = true

ENT.APCHealth = 20000

ENT.AnimationFrames = {
	{Vector(2436.7131347656, 7494.7651367188, 1511.0599365234), Angle(0, 90, 0)},
	{Vector(2436.7131347656, 6844.7651367188, 1511.0599365234), Angle(0, 90, 0)},
}

ENT.EscapeAnimationFrames = {
	--{Vector(2436.7131347656, 6844.7651367188, 1511.0599365234), Angle(0, 90, 0)},
	{Vector(2436.7131347656, 7494.7651367188, 1511.0599365234), Angle(0, 90, 0)},
}

function ENT:LinearMotion(endpos, speed, islast)
	if !IsValid(self) then return end
	timer.Remove(self:GetClass().."_linear_motion")

	local ratio = 0
	local time = 0
	local startpos = self:GetPos()

	timer.Create(self:GetClass().."_linear_motion", FrameTime(), 9999999999999, function()
		if !IsValid(self) then return end
	    ratio = speed + ratio
	    time = time + FrameTime()
	    self:SetPos(LerpVector(ratio, startpos, endpos))

	    if self:GetPos():DistToSqr(endpos) < 1 then
	    	self:SetPos(endpos)
	    end

	    if self:GetPos() == endpos then
	    	timer.Remove(self:GetClass().."_linear_motion")
	    	if islast then
	    		self.IsDriving = false
	    		self.DriveSound:Stop()
	    		self:SetBodygroup(1, 1)
	    		self:ResetSequence(self:LookupSequence("idle"))
	    		self:ResetSequenceInfo()
	    	end
	    end
	end)
end

function ENT:LinearAngle(endangle, speed)
	if !IsValid(self) then return end
	timer.Remove(self:GetClass().."_linear_angle")

    local ratio = 0
    local startangle = self:GetAngles()
    local startangle_table = startangle:Unpack()
    local endangle_table = endangle:Unpack()
    local startangle_tovector = Vector(startangle[1], startangle[2], startangle[3])
    local endangle_tovector = Vector(endangle[1], endangle[2], endangle[3])

    timer.Create(self:GetClass().."_linear_angle", FrameTime(), 9999999999999, function()
        if !IsValid(self) then return end
        ratio = math.min(ratio + speed, 1)
        self:SetAngles(LerpAngle(ratio, startangle, endangle))

        	
        if startangle_tovector:DistToSqr(endangle_tovector) < 1 then
            self:SetAngles(endangle)
        end

        if self:GetAngles() == endangle then
            timer.Remove(self:GetClass().."_linear_angle")
            return true
        end
    end)
end

function ENT:Initialize()
	self:SetModel("models/scp_chaos_jeep/chaos_jeep.mdl")

	self:SetMoveType( MOVETYPE_NONE )

	self:PhysicsInit( SOLID_VPHYSICS )

	self:SetSolid( SOLID_VPHYSICS )

	self:SetTrigger(true)

	local filt = RecipientFilter()
	filt:AddAllPlayers()

	self.DriveSound = CreateSound(self, "nextoren/others/chaos_car/car_driving.wav", filt)
	self.DriveSound:Play()

	self:SetPos(self.AnimationFrames[1][1])
	self:SetAngles(self.AnimationFrames[1][2])

	local physobj = self:GetPhysicsObject()
	if IsValid(physobj) then physobj:EnableMotion(false) end

	--ents.GetMapCreatedEntity(2887):Fire("use")
	--ents.GetMapCreatedEntity(2888):Fire("use")

	timer.Simple(0.1, function()
		for i = 2, #self.AnimationFrames do
			timer.Create("apc__anim_"..tostring(i), 1 * ( i - 2 ), 1, function()
				self:LinearMotion(self.AnimationFrames[i][1], 0.004, i == #self.AnimationFrames)
				self:LinearAngle(self.AnimationFrames[i][2], 0.004)
			end)
		end
	end)

	local remembername = "Frame_Advance_"..self:EntIndex()
	timer.Create(remembername, FrameTime(), 999999999, function()
		if IsValid(self) then
			self:FrameAdvance()
		else
			timer.Remove(remembername)
		end
	end)

	self:ResetSequence(self:LookupSequence("driving"))
	self:SetPlaybackRate(-0.2)
	--self:ResetSequenceInfo()
end

function ENT:Explode(ply)

	if self.didexplode then return end

	self.didexplode = true

	local pos = self:GetPos()
	local dmg = 625
	local dmgowner = self

	ply:AddToStatistics("l:apc_destroyed", 400)

	local r_inner = 550
	local r_outer = r_inner * 1.15

	for i = 2, #self.AnimationFrames do
		timer.Remove("apc__anim_"..tostring(i))
	end

	--util.BlastDamage(ply, ply, pos, r_outer, dmg)

	ParticleEffect("gas_explosion_main", self:GetPos(), Angle(0,0,0), game.GetWorld())
	BroadcastLua("ParticleEffect(\"gas_explosion_main\", Vector("..tostring(self:GetPos().x)..", "..tostring(self:GetPos().y)..", "..tostring(self:GetPos().z).."), Angle(0,0,0), game.GetWorld())")
	local dmginfo = DamageInfo()
	dmginfo:SetDamageType(DMG_BLAST)
	dmginfo:SetDamage(450)
	local savepos = self:GetPos()

	sound.Play( "bullet/explode/large_4.wav", savepos, 125, 100, 1.3 )

	self:Remove()


	util.BlastDamageInfo(dmginfo, savepos, 850)

end

function ENT:Escape()

	ents.GetMapCreatedEntity(2887):Fire("use")
	ents.GetMapCreatedEntity(2888):Fire("use")

	self:ResetSequence(self:LookupSequence("driving"))
	self:SetPlaybackRate(0.2)
	self:SetBodygroup(1,0)
	self.DriveSound:Play()
	for i = 1, #self.EscapeAnimationFrames do
		timer.Create("apc__anim_"..tostring(i), 1.15 * i-1, 1, function()
			if i == 1 then self.IsDriving = true end
			self:LinearMotion(self.EscapeAnimationFrames[i][1], 0.005)
			self:LinearAngle(self.EscapeAnimationFrames[i][2], 0.005)
		end)
	end
	timer.Simple(4 * ( #self.EscapeAnimationFrames + 1 ), function()
		self:Remove()
	end)
end

function ENT:Touch(ply)
	if !IsValid(ply) then return end
	if !ply:IsPlayer() then return end
	if ply:GTeam() == TEAM_SPEC then return end
	if !ply:Alive() or ply:Health() <= 0 then return end
	if self.IsDriving != true then return end
	ply:Kill()
end

function ENT:Think()

	self:NextThink(CurTime())
end

function ENT:OnTakeDamage(dmginfo)
	local bannedteams = {
		[TEAM_CHAOS] = true,
		[TEAM_CLASSD] = true,
	}
	local attacker = dmginfo:GetAttacker()
	if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and !bannedteams[dmginfo:GetAttacker():GTeam()] then
		--local Ef = EffectData()
		--Ef:SetOrigin(dmginfo:GetDamagePosition())
		--Ef:SetEntity(self)
		--util.Effect("helicopter_impact", Ef)
		self.APCHealth = self.APCHealth - dmginfo:GetDamage()
		if self.APCHealth <= 0 then self:Explode(dmginfo:GetAttacker()) end
	end
	return dmginfo:GetDamage()
end