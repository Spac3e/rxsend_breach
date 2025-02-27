AddCSLuaFile()

ENT.Base = "base_anim"

ENT.PrintName		= "NTF_CutScene"

ENT.Type			= "anim"

ENT.Spawnable		= true

ENT.AdminSpawnable	= true

ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.Owner = nil

ENT.AutomaticFrameAdvance = true

function ENT:Initialize()

	self.Entity:SetModel( self.Owner:GetModel() )

	self.Entity:SetMoveType(MOVETYPE_NONE )

	self:SetCollisionGroup( COLLISION_GROUP_NONE    )

	local pos = Vector(-10600.646484, -77.443832, 2373.897461)

	if self.Owner:GTeam() == TEAM_USA then
		pos = Vector(-634.37982177734, 2779.4987792969, 2723.8400878906)
	end

	self:SetPos(pos-Vector(-73, 0, 0))

	self:SetAngles(Angle(0, 0, 0))

    self:SetModelScale( 1 )

    self:SetPlaybackRate( 1 )

	self:SetLocalVelocity( Vector( 0, 0, -240 ) )

	self.Owner:SetNoDraw(true)

	local time = 7
	if self.Owner:GTeam() == TEAM_NTF then
		if CLIENT and self.Owner == LocalPlayer() then
			NTFStart()
		end
		time = 1
	elseif self.Owner:GTeam() == TEAM_USA then
		if CLIENT and self.Owner == LocalPlayer() then
			SHTURMONPStart()
		end
		time = 3
	end

	timer.Simple(time, function()
		if IsValid(self) then

			self.Entity:SetSequence("2appel_a")
			self.Entity:SetCycle(0.1)

			for i = 0, self.Owner:GetNumBodyGroups() -1 do
				self.Entity:SetBodygroup(i, self.Owner:GetBodygroup(i))
			end

			if self.Owner:GTeam() == TEAM_USA then
				self.Entity:SetBodygroup(0,0)
			else
				self.Entity:SetBodygroup(4,0)
			end

			self.Owner:Freeze(false)
				
			self:SetPlaybackRate( 1 )

			if CLIENT then
				self:EmitSound("weapons/universal/uni_bipodretract.wav", 160)
				timer.Create("NTF_Sound", 1, 4, function()
					if !IsValid(self) then return end
					self:EmitSound("nextoren/charactersounds/foley/sprint/sprint_"..math.random(1,52)..".wav", 160)
				end)
			end
			
		end
	end)

	if CLIENT and self.Owner == LocalPlayer() then

		timer.Simple(time, function()

			ntf_helicopter = ents.CreateClientside("base_gmodentity")

			ntf_helicopter:SetModel("models/scp_helicopter/resque_helicopter.mdl")

			ntf_helicopter:Spawn()
			
			ntf_helicopter:SetPos(pos) 

			ntf_helicopter:ResetSequence(ntf_helicopter:LookupSequence("door_opened"), false)

			ntf_helicopter:SetAngles(Angle(0, 90, 0))

			timer.Simple(4.5, function()
				if IsValid(ntf_helicopter) then
					ntf_helicopter:Remove()
				end

				--PlayAnnouncer( "nextoren/round_sounds/intercom/support/ntf_enter.ogg" )
				
			end)

			timer.Simple(3, function()
				LocalPlayer():ScreenFade( SCREENFADE.OUT, Color( 0, 0, 0 ), 0.1, 0.8 )
				timer.Simple(0.8, function()
					LocalPlayer():ScreenFade( SCREENFADE.IN, color_black, 1, 0)
				end)
			end)
		end)
	end

	timer.Simple(time+1, function()
		if IsValid(self.Entity) then self.Entity:SetMoveType(MOVETYPE_NOCLIP ) end

	end)

	timer.Simple(time+3.7, function()
		if SERVER then
			self.Owner:SetNoDraw(false)
			self:Remove()
		end

	end)

end

function ENT:Think()


	for _, ply in ipairs(player.GetAll()) do

		if ply == self:GetOwner() then

			ply:SetNWEntity("NTF1Entity", self)

		end

	end

	self:NextThink( CurTime() )

	return true

end

function ENT:OnRemove()

	for _, ply in ipairs(player.GetAll()) do

		if ply == self:GetOwner() then

			ply:SetNWEntity("NTF1Entity", NULL)

		end

	end

end

if CLIENT then

	function ENT:Draw()

		if LocalPlayer() == self:GetOwner() then

			self:DrawModel()


		end

	end

end



