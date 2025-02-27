

AddCSLuaFile('shared.lua')

include('shared.lua')

local dzwiekii = false
dzwiekii = nil
local dzwiekii2 = false
dzwiekii2 = nil

function ENT:Initialize()



	self.CreationTime = CurTime() + 2

	dzwiekii = true

    timer.Simple( 24.3, function()
        if IsValid(self) then
			dzwiekii = false
            self.hover_snd:Stop()
			dzwiekii2 = true
        end
    end)
 
    timer.Simple( 175, function()
        if IsValid(self) then
			dzwiekii = true
            self.hover_snd:Stop()
			dzwiekii2 = false
        end
    end)
end

function ENT:Draw()
	self.Entity:SetModel("models/cyox/mog/mog.mdl")
	self.Entity:DrawModel()
end


function ENT:OnRemove()



	if ( self.hover_snd && self.hover_snd:IsPlaying() ) then



		self.hover_snd:Stop()



	end



end



function ENT:Think()
	if dzwiekii then

		if ( self.CreationTime < CurTime() ) then
	
	
	
			self.SoundCreated = true
	
	
	
			self.hover_snd = CreateSound( self, "nextoren/others/helicopter/apache_hover.wav" )
	
			self.hover_snd:SetDSP( 17 )
	
			self.hover_snd:Play()
			
	
		end
	
	end
	
	
	if dzwiekii2 then
	
		if ( self.CreationTime < CurTime() ) then
	
	
	
			self.SoundCreated = true
	
	
	
			self.hover_snd = CreateSound( self, "nextoren/others/helicopter/helicopter_propeller.wav" )
	
			self.hover_snd:SetDSP( 17 )
	
			self.hover_snd:Play()
			
	
		end
	
	end
end