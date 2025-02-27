
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
~ file: addons/all_weapons/lua/cw_kk/ins2/shared/flashlight_v7.lua ~

]]


CustomizableWeaponry_KK.ins2.flashlight.v7 = CustomizableWeaponry_KK.ins2.flashlight.v7 or {}
setmetatable(CustomizableWeaponry_KK.ins2.flashlight.v7, CustomizableWeaponry_KK.ins2.flashlight)

if CLIENT then
	CustomizableWeaponry_KK.ins2.flashlight.v7.white = color_white
	CustomizableWeaponry_KK.ins2.flashlight.v7.texture = "effects/flashlight001"

	--[[function CustomizableWeaponry_KK.ins2.flashlight.v7:Think()
		if true then return end

		--print( "eee" )
		local pt = ProjectedTexture()
		pt:SetTexture(self.texture)
		pt:SetEnableShadows(true)
		pt:SetFarZ(2048)
		pt:SetFOV(60)

	end

	hook.Add("Think", CustomizableWeaponry_KK.ins2.flashlight.v7, CustomizableWeaponry_KK.ins2.flashlight.v7.Think)]]

	function CustomizableWeaponry_KK.ins2.flashlight.v7:elementRender(attBeamSource)
		if not attBeamSource then return end

	end
end

function CustomizableWeaponry_KK.ins2.flashlight.v7:attach(att)
	self:SetNWInt("INS2LAMMode", 0)
end

function CustomizableWeaponry_KK.ins2.flashlight.v7:detach()
end
