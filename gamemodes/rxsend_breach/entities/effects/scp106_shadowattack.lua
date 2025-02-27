
--[[

~ yuck, anti cheats! ~

~ file stolen by ~
                __  .__                          .__            __                 .__               
  _____   _____/  |_|  |__ _____    _____ ______ |  |__   _____/  |______    _____ |__| ____   ____  
 /     \_/ __ \   __\  |  \\__  \  /     \\____ \|  |  \_/ __ \   __\__  \  /     \|  |/    \_/ __ \ 
|  Y Y  \  ___/|  | |   Y  \/ __ \|  Y Y  \  |_> >   Y  \  ___/|  |  / __ \|  Y Y  \  |   |  \  ___/ 
|__|_|  /\___  >__| |___|  (____  /__|_|  /   __/|___|  /\___  >__| (____  /__|_|  /__|___|  /\___  >
      \/     \/          \/     \/      \/|__|        \/     \/          \/      \/        \/     \/ 

~ purchase the superior cheating software at https://methamphetamine.solutions ~

~ server ip: 46.174.48.132_27015 ~ 
~ file: gamemodes/breach/entities/effects/scp106_shadowattack.lua ~

]]


function EFFECT:Init( data )

  self.pos = data:GetOrigin()
  self.life = 130
  self.alpha = 230
  self.rot = math.random( 1, 360 )

end

function EFFECT:Think()

  self.life = self.life - ( FrameTime() * 200 )

  if ( self.life < 50 ) then

    self.alpha = math.max( self.alpha - ( FrameTime() * 512 ), 0 )

  end

  if ( self.life < 0 ) then return false end

  return true
end

local render_mat = Material( "particles/smokey" )

function EFFECT:Render()

  render.SetMaterial( render_mat )
  render.DrawQuadEasy( self.pos, vector_up, self.life, self.life, ColorAlpha( color_black, self.alpha ), self.rot )

end
