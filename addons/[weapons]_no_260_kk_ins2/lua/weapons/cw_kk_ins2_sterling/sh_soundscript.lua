--[[
lua/weapons/cw_kk_ins2_sterling/sh_soundscript.lua
--]]

SWEP.Sounds = {
	base_ready = {
		{time = 0, sound = "CW_KK_INS2_UNIVERSAL_DRAW"},
		{time = 10/30, sound = "CW_KK_INS2_STERLING_STOCKOPEN1"},
		{time = 15/30, sound = "CW_KK_INS2_STERLING_STOCKOPEN2"},
		{time = 49/30, sound = "CW_KK_INS2_STERLING_BOLTBACK"},
	},

	base_draw = {
		{time = 0, sound = "CW_KK_INS2_UNIVERSAL_DRAW"},
	},

	empty_draw = {
		{time = 0, sound = "CW_KK_INS2_UNIVERSAL_DRAW"},
	},

	base_holster = {
		{time = 0, sound = "CW_KK_INS2_UNIVERSAL_HOLSTER"},
	},

	empty_holster = {
		{time = 0, sound = "CW_KK_INS2_UNIVERSAL_HOLSTER"},
	},

	base_crawl = {
		{time = 0, sound = "CW_KK_INS2_UNIVERSAL_LEFTCRAWL"},
		{time = 22/30, sound = "CW_KK_INS2_UNIVERSAL_RIGHTCRAWL"},
	},

	empty_crawl = {
		{time = 0, sound = "CW_KK_INS2_UNIVERSAL_LEFTCRAWL"},
		{time = 22/30, sound = "CW_KK_INS2_UNIVERSAL_RIGHTCRAWL"},
	},

	base_dryfire = {
		{time = 0, sound = "CW_KK_INS2_STERLING_EMPTY"},
	},

	base_reload = {
		{time = 12/30, sound = "CW_KK_INS2_STERLING_MAGRELEASE"},
		{time = 14/30, sound = "CW_KK_INS2_STERLING_MAGOUT"},
		{time = 61/30, sound = "CW_KK_INS2_STERLING_MAGIN"},
		{time = 66/30, sound = "CW_KK_INS2_STERLING_MAGHIT"},
	},

	base_reloadempty = {
		{time = 12/30, sound = "CW_KK_INS2_STERLING_MAGRELEASE"},
		{time = 14/30, sound = "CW_KK_INS2_STERLING_MAGOUT"},
		{time = 61/30, sound = "CW_KK_INS2_STERLING_MAGIN"},
		{time = 66/30, sound = "CW_KK_INS2_STERLING_MAGHIT"},
		{time = 92/30, sound = "CW_KK_INS2_STERLING_BOLTBACK"},
	},

	iron_dryfire = {
		{time = 0, sound = "CW_KK_INS2_STERLING_EMPTY"},
	},
}


