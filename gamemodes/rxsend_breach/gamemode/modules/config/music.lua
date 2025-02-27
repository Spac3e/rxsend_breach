-- code was kindfully provided by the most notorious lua programmer in the world spac3

BR_MUSIC_AMBIENT_LZ = 1
BR_MUSIC_AMBIENT_HZ = 2
BR_MUSIC_AMBIENT_OFFICE = 3
BR_MUSIC_AMBIENT_OUTSIDE = 4

BR_MUSIC_FBI_AGENTS_START = 5
BR_MUSIC_FBI_AGENTS_ESCAPE = 6

BR_MUSIC_FBI_AGENTS_LOOP = 16

BR_MUSIC_SPAWN_FBI_AGENTS = 7
BR_MUSIC_SPAWN_FBI = 31
BR_MUSIC_SPAWN_CHAOS = 8
BR_MUSIC_SPAWN_MOG = 9
BR_MUSIC_SPAWN_DZ = 18
BR_MUSIC_SPAWN_OBR = 19
BR_MUSIC_SPAWN_GOC = 20
BR_MUSIC_SPAWN_CULT = 21
BR_MUSIC_SPAWN_NTF = 27
BR_MUSIC_SPAWN_SECURITY = 10
BR_MUSIC_SPAWN_DEFAULT = 23

BR_MUSIC_TEST = 11

BR_MUSIC_ACTION_LZ = 12
BR_MUSIC_ACTION_HZ = 13
BR_MUSIC_ACTION_OFFICE = 14
BR_MUSIC_ACTION_OUTSIDE = 15

BR_MUSIC_DEATH = 17

BR_MUSIC_OUTRO_GOC_WIN = 24
BR_MUSIC_UIU_WIN = 25
BR_MUSIC_UIU_LOOSE = 26
BR_MUSIC_ESCAPED = 25
BR_MUSIC_COUNTDOWN = 28
BR_MUSIC_GOC_NUKE = 29
BR_MUSIC_SPAWN_GOC_Con = 34
BR_MUSIC_SPAWN_Army = 35
BR_MUSIC_SPAWN_Army_2 = 36

BR_MUSIC_DIMENSION_SCP106 = 30

BR_MUSIC_EVACUATION = 33

BR_MUSIC_LIGHTZONE_DECONT = 32

local escapesmusic = 6

if SERVER then return end

local volume_misc = "misc"
local volume_spawn = "spawn"
local volume_ambience = "ambience"
local volume_panic = "panic"

local music_path = "sound/rxsend_music/"

local function getpath(m)
	return music_path..m
end



local tab = {}

local function RegisterMusic(id, soundname, playwhenend, volume_type, loop, endat, fade, ispercentendat)

	tab[id] = {}
	tab[id].volumetype = volume_type
	tab[id].soundname = soundname
	tab[id].loop = loop == true

	tab[id].playwhenend = playwhenend

	if endat then
		tab[id].EndAt = endat
		tab[id].IsPercentEndAt = ispercentendat
	end

	if fade then
		tab[id].fade = fade
	end

	tab[id].id = id

end

BREACH.Music.Custom_Volumes = {
	["entrance_zone_2.ogg"] = 0.3,
	["entrance_zone_1.ogg"] = 0.3,

	["light_zone_2.ogg"] = 0.3,
	["light_zone_1.ogg"] = 0.8,

	["heavy_zone_5.ogg"] = 0.3,
	["heavy_zone_2.ogg"] = 0.8,
	["uiu_mission_complete.ogg"] = 1.4,

}

RegisterMusic(BR_MUSIC_OUTRO_GOC_WIN,
	getpath("misc/goc_won.ogg"),
	_,
	volume_misc
)

RegisterMusic(BR_MUSIC_UIU_WIN,
	getpath("misc/uiu_mission_complete.ogg"),
	_,
	volume_misc
)

RegisterMusic(BR_MUSIC_UIU_LOOSE,
	getpath("misc/uiu_mission_failed.ogg"),
	_,
	volume_misc
)

RegisterMusic(BR_MUSIC_ESCAPED,
	getpath("misc/pl_escaped.ogg"),
	_,
	volume_misc
)

RegisterMusic(BR_MUSIC_COUNTDOWN,
	getpath("misc/countdownmusic.ogg"),
	_,
	volume_misc
)

RegisterMusic(BR_MUSIC_EVACUATION,
	{
		getpath("cheli1.mp3"),
		getpath("arknigts1.mp3"),
		getpath("mhy1.mp3"),
		getpath("uma1.mp3"),
		getpath("cheli2.mp3"),
		getpath("cheli3.mp3"),
		getpath("cheli4.mp3"),
		getpath("cheli5.mp3"),
		getpath("cheli6.mp3"),
		getpath("cheli7.mp3"),
	},
	_,
	volume_misc
)

RegisterMusic(BR_MUSIC_LIGHTZONE_DECONT,
	getpath("fangdu.ogg"),
	_,
	volume_misc,
	false,
	70,
	0.1
)

local function registerambience(path, ambience_id, action_id)
	local tab = {}
	
	local files = file.Find(path.."*", "GAME")

	local Action = {}
	local default = {}

	for i, v in pairs(files) do
		if v:find("decont") then continue end
		if v:find("action") then
			table.insert(Action, path..v)
		else
			table.insert(default, path..v)
		end
	end

	RegisterMusic(ambience_id,
		default,
		_,
		volume_ambience,
		false,
		0.9,
		0.1,
		true
	)

	RegisterMusic(action_id,
		Action,
		_,
		volume_panic,
		false,
		15,
		0.2
	)

end

registerambience(getpath("/heavy_zone/"), BR_MUSIC_AMBIENT_HZ, BR_MUSIC_ACTION_HZ)
registerambience(getpath("/entrance_zone/"), BR_MUSIC_AMBIENT_OFFICE, BR_MUSIC_ACTION_OFFICE)
registerambience(getpath("/light_zone/"), BR_MUSIC_AMBIENT_LZ, BR_MUSIC_ACTION_LZ)
registerambience(getpath("/outside/"), BR_MUSIC_AMBIENT_OUTSIDE, BR_MUSIC_ACTION_OUTSIDE)

RegisterMusic(BR_MUSIC_TEST,
	getpath("situational_song/fbi/fbi_escape_loop.ogg"),
	_,
	volume_misc,
	true,
	10,
	0.1
)

RegisterMusic(BR_MUSIC_FBI_AGENTS_START,
	getpath("situational_song/fbi/fbi_action_start.ogg"),
	BR_MUSIC_FBI_AGENTS_LOOP,
	volume_misc,
	false
)


RegisterMusic(BR_MUSIC_FBI_AGENTS_LOOP,
	getpath("situational_song/fbi/fbi_action_loop.ogg"),
	_,
	volume_misc,
	true
)

RegisterMusic(BR_MUSIC_FBI_AGENTS_ESCAPE,
	getpath("situational_song/fbi/fbi_escape_loop.ogg"),
	BR_MUSIC_FBI_AGENTS_LOOP,
	volume_misc,
	false
)


--[[SPAWNS]]--

RegisterMusic(BR_MUSIC_SPAWN_FBI_AGENTS,
	getpath("factions_spawn/fbi_agent_spawn.wav"),
	_,
	volume_spawn
)

RegisterMusic(BR_MUSIC_SPAWN_CHAOS,
	getpath("factions_spawn/chaos_theme.ogg"),
	_,
	volume_spawn,
	false,
	15,
	0.1
)

RegisterMusic(BR_MUSIC_SPAWN_FBI,
	getpath("factions_spawn/fbi_agent_spawn.wav"),
	_,
	volume_spawn
)

RegisterMusic(BR_MUSIC_SPAWN_MOG,
	getpath("factions_spawn/mtf_intro.ogg"),
	_,
	volume_spawn
)

RegisterMusic(BR_MUSIC_SPAWN_DZ,
	getpath("shpl.MP3"),
	_,
	volume_spawn
)

RegisterMusic(BR_MUSIC_SPAWN_NTF,
	getpath("factions_spawn/ntfspawntheme2.wav"),
	_,
	volume_spawn
)

RegisterMusic(BR_MUSIC_SPAWN_CULT,
	getpath("factions_spawn/cult_theme.ogg"),
	_,
	volume_spawn
)

RegisterMusic(BR_MUSIC_SPAWN_GOC,
	getpath("factions_spawn/goc_intro.ogg"),
	_,
	volume_spawn
)

RegisterMusic(BR_MUSIC_SPAWN_OBR,
	getpath("factions_spawn/obr_intro.ogg"),
	_,
	volume_spawn,
	false,
	15,
	0.1
)

local ambient = {}

for i = 1, 3 do
	ambient[#ambient + 1] = getpath("spawn_ambient/start_ambience"..i..".ogg")
end

RegisterMusic(BR_MUSIC_SPAWN_DEFAULT,
	ambient,
	_,
	volume_spawn
)


RegisterMusic(BR_MUSIC_GOC_NUKE,
	getpath("nukes/goc_nuke.ogg"),
	_,
	volume_misc,
	false,
	130,
	0.2
)



--[[MISC]]--

RegisterMusic(BR_MUSIC_DEATH,
	{getpath("situational_song/death/death_1.ogg"), getpath("situational_song/death/death_2.ogg")},
	_,
	volume_misc
)

local dimension = {}

for i = 1, 3 do
	dimension[#dimension + 1] = getpath("dimension/dimension_"..i..".ogg")
end

RegisterMusic(BR_MUSIC_DIMENSION_SCP106,
	dimension,
	_,
	volume_misc
)

RegisterMusic(BR_MUSIC_SPAWN_GOC_Con,
    {
     getpath("gocmusic2.ogg"),
	 getpath("goc_intro3.ogg"),
	
	},
	_,
	volume_spawn
)

RegisterMusic(BR_MUSIC_SPAWN_Army,
    getpath("army_intro.ogg"),
	_,
	volume_spawn
)

RegisterMusic(BR_MUSIC_SPAWN_Army_2,
    getpath("ymca.mp3"),
	_,
	volume_spawn
)

return tab