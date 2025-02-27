local surface = surface
local Material = Material
local draw = draw
local DrawBloom = DrawBloom
local DrawSharpen = DrawSharpen
local DrawToyTown = DrawToyTown
local Derma_StringRequest = Derma_StringRequest;
local RunConsoleCommand = RunConsoleCommand;
local tonumber = tonumber;
local tostring = tostring;
local CurTime = CurTime;
local Entity = Entity;
local unpack = unpack;
local table = table;
local pairs = pairs;
local ScrW = ScrW;
local ScrH = ScrH;
local concommand = concommand;
local timer = timer;
local ents = ents;
local hook = hook;
local math = math;
local draw = draw;
local pcall = pcall;
local ErrorNoHalt = ErrorNoHalt;
local DeriveGamemode = DeriveGamemode;
local vgui = vgui;
local util = util
local net = net
local player = player
/*
soundstoloop = {
	{
		pos = Vector(2725.010010, -192.000000, 128.000000),
		ent = "prop_dynamic",
		len = 5,
		sound = "camera.ogg"
	},
	{
		pos = Vector(2725.010010, 1088.000000, 128.000000),
		ent = "prop_dynamic",
		len = 5,
		sound = "camera.ogg"
	}
}

foundsoundents = {}

function FindSoundEnts()
	for k,v in pairs(soundstoloop) do
		for k2,ent in pairs(ents.FindInSphere( v.pos, 1 )) do
			if ent:GetClass() == v.ent then
				table.ForceInsert(foundsoundents, {
					ent = ent,
					sound = v.sound,
					len = v.len,
					nextplay = 0
				})
			end
		end
	end
	print("Found " .. #foundsoundents .. " sound entities")
end

FindSoundEnts()

function UpdateSounds()
	for k,v in pairs(foundsoundents) do
		if v.nextplay < CurTime() then
			if IsValid(v.ent) then
				v.ent:EmitSound( v.sound, 75, 100, 1, CHAN_STATIC )
				v.nextplay = CurTime() + v.len
			else
				FindSoundEnts()
			end
		end
	end
end
hook.Add("Tick", "UpdateSounds", UpdateSounds)

function LoopSoundsStart()
	for k,v in pairs(foundsoundents) do
		//CreateSound( v.pos, v.sound, CPASAttenuationFilter )
		v.ent:EmitSound( v.sound, 75, 100, 1, CHAN_STATIC )
		v.nextplay = CurTime() + v.len
	end
end

LoopSoundsStart()
*/
function StartIntroMusic()
	local client = LocalPlayer()
	if client:GTeam() != TEAM_GUARD and client:GTeam() != TEAM_NAZI and client:GTeam() != TEAM_AMERICA then
		PlayMusic("sound/no_music/start_round_ambient/start_ambience"..math.random(1, 10)..".ogg")
	end
end

function IntroSound()
	local client = LocalPlayer()
	if client:GTeam() != TEAM_GUARD then
		FadeMusic(1)
	end
	if client:GTeam() == TEAM_GUARD then
		surface.PlaySound("nextoren/start_round/start_round_mtf.mp3")		
		timer.Simple(24, function()
			surface.PlaySound("nextoren/start_round/start_round_lockdown.wav")
		end)			
	elseif client:GTeam() == TEAM_CLASSD then
		surface.PlaySound("nextoren/start_round/start_round_classd.mp3")
		timer.Simple(7, function()
			util.ScreenShake( Vector(0, 0, 0), 35, 15, 3, 150 )
			surface.PlaySound("nextoren/others/horror/horror_14.ogg")
			local blackscreen = vgui.Create( "DPanel" )
			blackscreen:SetSize(ScrW(), ScrH())
			blackscreen:SetAlpha(0)
			blackscreen:AlphaTo(255,0.6, 0, function()
				BREACH.Round.GeneratorsActivated = false
				blackscreen:AlphaTo(0,1,3,function()
					blackscreen:Remove()
				end)
			end)
			blackscreen.Paint = function(self, w, h)
				draw.RoundedBox(0,0,0,w,h,color_black)
			end
		end)
	elseif client:GTeam() == TEAM_SCP then
		surface.PlaySound("nextoren/start_round/start_round_scp.mp3")
	else
		surface.PlaySound("nextoren/start_round/start_round_sci.mp3")
	    timer.Simple(5, function()
			util.ScreenShake( Vector(0, 0, 0), 35, 15, 3, 150 )
			surface.PlaySound("nextoren/others/horror/horror_14.ogg")
			local blackscreen = vgui.Create( "DPanel" )
			blackscreen:SetSize(ScrW(), ScrH())
			blackscreen:SetAlpha(0)
			blackscreen:AlphaTo(255,0.6, 0, function()
				BREACH.Round.GeneratorsActivated = false
				blackscreen:AlphaTo(0,1,3,function()
					blackscreen:Remove()
				end)
			end)
			blackscreen.Paint = function(self, w, h)
				draw.RoundedBox(0,0,0,w,h,color_black)
			end
		end)
	end
end

function StartOutisdeSounds()
	surface.PlaySound("Satiate Strings.ogg")
end

function StartEndSound()
	surface.PlaySound("Mandeville.ogg")
end