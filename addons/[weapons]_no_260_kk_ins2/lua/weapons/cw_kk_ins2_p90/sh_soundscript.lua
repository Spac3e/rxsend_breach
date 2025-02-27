
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
~ file: addons/all_weapons/lua/weapons/cw_kk_ins2_p90/sh_soundscript.lua ~

]]


SWEP.Sounds = {
	base_ready = {
		{time = 0, sound = "CW_KK_INS2_UNIVERSAL_DRAW"},
		{time = 15/30, sound = "CW_KK_INS2_P90_BOLTLOCK"},
		{time = 18/30, sound = "CW_KK_INS2_P90_BOLTRELEASE"},
	},

	base_draw = {
		{time = 0, sound = "CW_KK_INS2_UNIVERSAL_DRAW"},
	},

	base_holster = {
		{time = 0, sound = "CW_KK_INS2_UNIVERSAL_HOLSTER"},
	},

	base_dryfire = {
		{time = 0, sound = "CW_KK_INS2_P90_EMPTY"},
	},

	base_fireselect = {
		{time = 6/30, sound = "CW_KK_INS2_P90_FIRESELECT"},
	},

	base_reload = {
		{time = 19/30, sound = "CW_KK_INS2_P90_MAGRELEASE"},
		{time = 21/30, sound = ""},
		--{time = 35/30, sound = "CW_KK_INS2_P90_MAGHIT"},
		{time = 73/30, sound = "CW_KK_INS2_P90_MAGIN"},
	},

	base_reloadempty = {
		--{time = 17/30, sound = "CW_KK_INS2_P90_BOLTBACK"},
		--{time = 28/30, sound = "CW_KK_INS2_P90_BOLTLOCK"},
		{time = 19/30, sound = "CW_KK_INS2_P90_MAGRELEASE"},
		{time = 23/30, sound = ""},
		{time = 72/30, sound = "CW_KK_INS2_P90_MAGIN"},
		{time = 74/30, sound = "CW_KK_INS2_P90_MAGHIT"},
		{time = 92/30, sound = "CW_KK_INS2_GALIL_DRUM_MAGHIT"},
		{time = 109/30, sound = "CW_KK_INS2_P90_BOLTLOCK"},
		{time = 111/30, sound = "CW_KK_INS2_P90_BOLTRELEASE"},
	},

	iron_dryfire = {
		{time = 0, sound = "CW_KK_INS2_P90_EMPTY"},
	},

	iron_fireselect = {
		{time = 6/30, sound = "CW_KK_INS2_P90_FIRESELECT"},
	},

	base_crawl = {
		{time = 0/30, sound = "CW_KK_INS2_UNIVERSAL_LEFTCRAWL"},
		{time = 22/30, sound = "CW_KK_INS2_UNIVERSAL_RIGHTCRAWL"},
	},
}
