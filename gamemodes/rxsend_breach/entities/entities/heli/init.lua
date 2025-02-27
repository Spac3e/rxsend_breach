AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.CurrentFrame = 1
ENT.AutomaticFrameAdvance = true
ENT.IsDriving = true

ENT.HeliHealth = 2000

ENT.AnimationFrames = {
	{Vector(332.09475708008, 4888.3051757813, 3075.1586914063), Angle(2.713623046875, 90.357055664063, -14.221801757813)},
	{Vector(-284.50988769531, 4850.2099609375, 3075.0688476563), Angle(2.713623046875, 91.0546875, -14.221801757813)},
	{Vector(-1044.5059814453, 4806.2075195313, 3075.6652832031), Angle(2.713623046875, 90.318603515625, -14.221801757813)},
	{Vector(-1411.5454101563, 4787.775390625, 3075.5754394531), Angle(2.713623046875, 90.318603515625, -14.221801757813)},
	{Vector(-1809.0645751953, 4771.603515625, 3075.3957519531), Angle(2.713623046875, 90.252685546875, -14.221801757813)},
	{Vector(-2412.2648925781, 4769.4565429688, 3072.7980957031), Angle(2.713623046875, 80.546264648438, -14.221801757813)},
	{Vector(-3129.3984375, 4670.0776367188, 3008.6701660156), Angle(8.6517333984375, 53.140869140625, -5.767822265625)},
	{Vector(-3418.9743652344, 4738.1059570313, 2967.3901367188), Angle(7.14111328125, 6.0809326171875, -1.0821533203125)},
	{Vector(-3533.8459472656, 4765.0766601563, 2886.8137207031), Angle(9.84375, -1.790771484375, -10.838012695313)},
	{Vector(-3565.6950683594, 4776.1674804688, 2613.4487304688), Angle(11.7333984375, -9.151611328125, 0.1153564453125)},
	{Vector(-3579.9892578125, 4816.9077148438, 2495.892578125), Angle(-0.19775390625, 1.043701171875, 0.0164794921875)},
}

ENT.EscapeAnimationFrames = {
	{Vector(-3637.78125, 4794.25, 2521.03125), Angle(0.2252197265625, 8.843994140625, 2.48291015625)},
	{Vector(-3634.46875, 4853.5, 2588.59375), Angle(6.2237548828125, 2.274169921875, -3.614501953125)},
	{Vector(-3623.40625, 4914.8125, 2659), Angle(3.4442138671875, -0.5548095703125, -10.508422851563)},
	{Vector(-3634.09375, 5014.34375, 2721.84375), Angle(1.5380859375, 2.5048828125, -17.550659179688)},
	{Vector(-3630, 5177.6875, 2734.6875), Angle(0.340576171875, 1.1480712890625, -21.8408203125)},
	{Vector(-3638.09375, 5416.53125, 2759.71875), Angle(0.3350830078125, 0.9063720703125, -22.78564453125)},
	{Vector(-3619.59375, 6146, 2781.125), Angle(0.3350830078125, 0.999755859375, -22.78564453125)},
	{Vector(-3614.03125, 6931, 2804.09375), Angle(0.3350830078125, 0.999755859375, -22.78564453125)},
	{Vector(-3611.4375, 7298.3125, 2814.8125), Angle(0.3350830078125, 0.999755859375, -22.78564453125)},
	{Vector(-3623.9375, 7459.875, 2719.03125), Angle(-0.208740234375, 0, -27.789916992188)},
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
	    	if islast and !isfunction(islast) then
	    		self.PropellerSound:Stop()
	    		local physobj = self:GetPhysicsObject()
				if IsValid(physobj) then physobj:EnableMotion(false) end
	    		self.IsFlying = false
	    		self.IsDriving = false
	    		self:SetBodygroup(2,0)
	    		self:SetBodygroup(3,1)
	    		self:ChangeRotating()
	    		self:AddGestureSequence(self:LookupSequence("door_open"), false)
				--self:ResetSequence(self:LookupSequence("door_opened"))
				--self:ResetSequenceInfo()
				--self:ManipulateBoneAngles(0, Angle(0,90,0))
				self:EmitSound("nextoren/vo/chopper/chopper_evacuate_start_"..math.random(1,7)..".wav", 110, 100, 1.2, CHAN_VOICE, 0, 0)
			elseif isfunction(islast) then
				islast()
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
	self:SetModel("models/scp_helicopter/resque_helicopter.mdl")

	self:SetMoveType( MOVETYPE_NONE )

	self:PhysicsInit( SOLID_VPHYSICS )

	self:SetSolid( SOLID_VPHYSICS )

	self:SetTrigger(true)

	self.IsFlying = true

	self.HelicopterHealth = self.HeliHealth
	self.IsBroken = false

	local filt = RecipientFilter()
	filt:AddAllPlayers()

	self.PropellerSound = CreateSound(self, "nextoren/others/helicopter/helicopter_propeller.wav", filt)
	self.PropellerSound:Play()

	self:SetPos(self.AnimationFrames[1][1])
	self:SetAngles(self.AnimationFrames[1][2])

	self:PhysicsDestroy()

	local physobj = self:GetPhysicsObject()
	if IsValid(physobj) then physobj:EnableMotion(false) end

	self:ResetSequence(self:LookupSequence("rotating"))
	self:ResetSequenceInfo()
	self:SetBodygroup(2,3)
	--for _, gate in pairs(ents.FindInBox( Vector(-1495.2327880859, 7149.9833984375, 1876.9328613281), Vector(-1083.5562744141, 7242.2333984375, 1660.4428710938) )) do gate:Fire("Open") end

		for i = 2, #self.AnimationFrames do
			timer.Create("helicopter__anim_"..tostring(i), 1.5 * ( i - 2 ), 1, function()
				self:LinearMotion(self.AnimationFrames[i][1], 0.005, i == #self.AnimationFrames)
				self:LinearAngle(self.AnimationFrames[i][2], 0.005)
			end)
		end

	local remembername = "Frame_Advance_"..self:EntIndex()
	timer.Create(remembername, FrameTime(), 999999999, function()
		if IsValid(self) then
			self:FrameAdvance()
		else
			timer.Remove(remembername)
		end
	end)

end

function ENT:ChangeRotating(start)

	local unid = "change_playback_"..self:EntIndex()

	timer.Create(unid, FrameTime(), 0, function()

		if !IsValid(self) or (!start and self:GetPlaybackRate() <= 0) or (start and self:GetPlaybackRate() >= 1) then
			timer.Remove(unid)
			return
		end

		if start then
			self:SetPlaybackRate(math.Approach(self:GetPlaybackRate(), 1, FrameTime()/2))
		else
			self:SetPlaybackRate(math.Approach(self:GetPlaybackRate(), 0, FrameTime()/2))
		end

	end)

end

function ENT:Explode(tem)

	if self.Blownup then return end

	local pos = self:GetPos()
	local dmg = 625
	local dmgowner = self

	self.Blownup = true

	local r_inner = 550
	local r_outer = r_inner * 1.15

	for i = 2, #self.AnimationFrames do
		timer.Remove("helicopter__anim_"..tostring(i))
	end

	--util.BlastDamage(self, dmgowner, pos, r_outer, dmg)

	--[[
	local effect = EffectData()
	effect:SetStart(pos)
	effect:SetOrigin(pos)
	effect:SetScale(r_outer)
	effect:SetRadius(r_outer)
	effect:SetMagnitude(dmg)
	util.Effect("Explosion", effect, true, true)]]

	if !self.IsFlying then
		ParticleEffect("gas_explosion_main", self:GetPos(), Angle(0,0,0), game.GetWorld())
		BroadcastLua("ParticleEffect(\"gas_explosion_main\", Vector("..tostring(self:GetPos().x)..", "..tostring(self:GetPos().y)..", "..tostring(self:GetPos().z).."), Angle(0,0,0), game.GetWorld())")
		local dmginfo = DamageInfo()
		dmginfo:SetDamageType(DMG_BLAST)
		dmginfo:SetDamage(450)
		local savepos = self:GetPos()

		sound.Play( "bullet/explode/large_4.wav", savepos, 125, 100, 1.3 )

		self:Remove()

		util.BlastDamageInfo(dmginfo, savepos, 1450)
	else

		local filt = RecipientFilter()
		filt:AddAllPlayers()

		self:SetCollisionGroup(COLLISION_GROUP_WORLD)

		self.PropellerSound:Stop()
		self.PropellerSound = CreateSound(self, "nextoren/others/helicopter/apache_damage_alarm.wav", filt)
		self.PropellerSound:Play()


		local fallpos = GroundPos(self:GetPos())
		self:LinearMotion(fallpos, 0.02, function()
			ParticleEffect("gas_explosion_main", self:GetPos(), Angle(0,0,0), game.GetWorld())
			BroadcastLua("ParticleEffect(\"gas_explosion_main\", Vector("..tostring(self:GetPos().x)..", "..tostring(self:GetPos().y)..", "..tostring(self:GetPos().z).."), Angle(0,0,0), game.GetWorld())")
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType(DMG_BLAST)
			dmginfo:SetDamage(450)
			local savepos = self:GetPos()

			sound.Play( "bullet/explode/large_4.wav", savepos, 125, 100, 1.3 )

			self.NOMOREEXPLOSIONS = true

			self:Remove()

			util.BlastDamageInfo(dmginfo, savepos, 1450)
		end)
		self:Ignite(1000)


		local _timername = "Helicopter_Crush_Animation_"..self:EntIndex()
		timer.Create(_timername, FrameTime(), 999999, function()
			if IsValid(self) then
				local curang = self:GetManipulateBoneAngles(0)
				local curpos = self:GetManipulateBoneAngles(0)
				local yaw = math.Clamp(curang.yaw + math.random(0.5, 2), 0, 360)
				if yaw == 360 then
					yaw = -3.5
				end
				self:ManipulateBonePosition(0, Vector(curpos.x, math.Clamp(curpos.y + math.random(0.5, 2), 0, 70), curpos.z))
				self:ManipulateBoneAngles(0, Angle(0, math.Clamp(curang.yaw + math.random(0.5, 2), 0, 360), math.Clamp(curang.roll + math.random(0.5, 2), 0, 90)))
			else
				timer.Remove(_timername)
			end
		end)

		self.IsBroken = true
	end

	for _, ply in pairs(player.GetAll()) do
		if ply:GTeam() == tem then
			ply:RXSENDNotify("l:ci_choppa_down")
			ply:AddToStatistics("l:choppa_bonus", 600)
		end
	end

end

--[[
function ENT:PhysicsCollide()
	if self.IsBroken and !self.NOMOREEXPLOSIONS then
		ParticleEffect("gas_explosion_main", self:GetPos(), Angle(0,0,0), game.GetWorld())
		BroadcastLua("ParticleEffect(\"gas_explosion_main\", Vector("..tostring(self:GetPos().x)..", "..tostring(self:GetPos().y)..", "..tostring(self:GetPos().z).."), Angle(0,0,0), game.GetWorld())")
		local dmginfo = DamageInfo()
		dmginfo:SetDamageType(DMG_BLAST)
		dmginfo:SetDamage(450)
		local savepos = self:GetPos()

		sound.Play( "bullet/explode/large_4.wav", savepos, 125, 100, 1.3 )

		self.NOMOREEXPLOSIONS = true

		self:Remove()

		util.BlastDamageInfo(dmginfo, savepos, 1450)
	end
end]]

function ENT:Escape()
	self:AddGestureSequence(self:LookupSequence("door_close"), false)
	self:ChangeRotating(true)
	timer.Simple(1, function()
		self.PropellerSound:Play()
		self:ManipulateBoneAngles(0, Angle(0,0,0))
		self:SetBodygroup(2, 3)
		self:SetBodygroup(4, 0)
		self.IsFlying = false
		for i = 1, #self.EscapeAnimationFrames do
			timer.Create("helicopter__anim_"..tostring(i), 1 * i, 1, function()
				self:LinearMotion(self.EscapeAnimationFrames[i][1], 0.01)
				self:LinearAngle(self.EscapeAnimationFrames[i][2], 0.01)
			end)
		end
		timer.Simple(1 * #self.EscapeAnimationFrames, function()
			self:Remove()
		end)
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
	if self:GetPos() == self.AnimationFrames[#self.AnimationFrames][1] and self.IsDriving == true then self:SetBodygroup(1, 1) self.IsDriving = false end
	if self.IsDriving and self:GetBodygroup(0) != 3 then self:SetBodygroup(0, 3) end
	if !self.IsDriving and self:GetBodygroup(0) != 0 then self:SetBodygroup(0, 0) end
	self:NextThink(CurTime() + FrameTime() )

	local mypos = self:GetPos()
	local ang = self:GetAngles()

	if !self.RotorWash then
		self.RotorWash = ents.Create("env_rotorwash_emitter")
		self.RotorWash:SetPos(self.Entity:GetPos())
		self.RotorWash:SetParent(self.Entity)
		self.RotorWash:Activate()
	end

	local pos1, pos2 = mypos + ang:Forward()*-450 + ang:Right()*-150 + ang:Up()*-150, mypos + ang:Forward()*350 + ang:Right()*150 + ang:Up()*150

	for k, v in ipairs(ents.FindInBox(pos1, pos2)) do
		if v:GetClass():find("cw_kk_ins2_projectile_") then
			if !v.Fuse and v.selfDestruct then
				v:selfDestruct()
			end
		end
	end
end

function ENT:OnTakeDamage( dmginfo )
	if self.NOMOREEXPLOSIONS or self.Blownup then return end
	if dmginfo:GetDamageType() == DMG_BLAST and IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():GTeam() == TEAM_CHAOS then
		self:Explode(TEAM_CHAOS)
	end


	if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() and dmginfo:GetAttacker():GTeam() == TEAM_GRU then
		if GRU_Objective != "Срыв эвакуации" then
			dmginfo:GetAttacker():RXSENDNotify(Color(255,0,0), "l:gru_psycho_pt1 ", color_white, "l:gru_psycho_pt2")
			return
		end
		--local Ef = EffectData()
		--Ef:SetOrigin(dmginfo:GetDamagePosition())
		--Ef:SetEntity(self)
		--util.Effect("helicopter_impact", Ef)
		self.HelicopterHealth = self.HelicopterHealth - dmginfo:GetDamage()
		if self.HelicopterHealth <= 0 then
			self:Explode(TEAM_GRU)
		end
	end

	return dmginfo:GetDamage()
end