include( 'shared.lua' )

function ENT:Think()

  if ( !self.AlarmIsPlaying ) then

    self.AlarmIsPlaying = CreateSound( self, "nextoren/alarmloop.wav" )
    self.AlarmIsPlaying:SetDSP( 17 )
    self.AlarmIsPlaying:Play()

  end

end

function ENT:OnRemove()

  if ( self.AlarmIsPlaying ) then

    self.AlarmIsPlaying:Stop()

  end

end
