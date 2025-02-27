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
playing = false
local sequence = 0

surface.CreateFont( "HUDSplashVSmall", {
    font = "Bauhaus",    
	size = 20,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont( "HUDSplashSmall", {
    font = "Bauhaus",    
	size = 32,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont( "HUDSplashMedium", {
    font = "Bauhaus",    
	size = 64,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont( "HUDSplashBig", {
    font = "Bauhaus",    
	size = 96,
	weight = 700,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

function PlayIntro( seq )
	gui.EnableScreenClicker( true )
	playing = true
	sequence = seq or 1
end

function Intro()
	if !playing then return end
	if sequence == 1 then
		gui.EnableScreenClicker( false )
		Logo()
	elseif sequence == 2 then
		Settings()
	elseif sequence == 3 then
		gui.EnableScreenClicker( false )
		sequence = 0
		file.Write( "breach/intro.dat", tostring( showupdates ) )
		net.Start( "PlayerReady" )
		net.SendToServer()
		sequence = 4
	elseif sequence == 4 then
		if file.Exists( "breach/version.dat", "DATA" ) then
			local ver = file.Read( "breach/version.dat" )
			if ver != VERSION then
				file.Write( "breach/version.dat", tostring( VERSION ) )
				sequence = 5
				playing = true
			else
				playing = false
				gui.EnableScreenClicker( false )
			end
		else
			file.Write( "breach/version.dat", tostring( VERSION ) )
			sequence = 5
			playing = true
		end
	elseif sequence == 5 then
		Update()
	end
end

hook.Add( "HUDPaint", "Intro", Intro )

local elements = {
	{ 0.348, 0.4, 0.055, 0.14, 255 },
	{ 0.409, 0.4, 0.055, 0.14, 255 },
	{ 0.47, 0.4, 0.06, 0.14, 255 },
	{ 0.545, 0.39, 0.11, 0.163, 255 },
	{ 0.345, 0.555, 0.31, 0.05, 255 },
}

local scplx, scply, scplw, scplh = ScrW() * 0.25, ScrH() * 0.25, ScrW() * 0.5, ScrH() * 0.5
local scaledown = 1
local brla, ka, da, foa = 0, 0, 0, -1000

function Logo()
	local w, h = ScrW(), ScrH()
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetMaterial( Material( "materials/breach/logo_scp.png" ) )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( scplx + scplw * (1 - scaledown) / 2 , scply * scaledown, scplw * scaledown, scplh * scaledown )
	
	for k, v in pairs( elements ) do
		surface.SetDrawColor( 0, 0, 0, v[5] )
		surface.DrawRect( w * v[1], h * v[2], w * v[3], h * v[4] )
	end
	
	for k, v in pairs( elements ) do
		if v[5] > 0 then
			v[5] = v[5] - 2
			return
		end
	end
	
	if scaledown > 0.3 then
		scaledown = scaledown - 0.001
		return
	end
	surface.SetMaterial( Material( "materials/breach/logo_breach.png" ) )
	surface.SetDrawColor( 255, 255, 255, brla )
	surface.DrawTexturedRect( w * 0.43, h * 0.3, w * 0.14, h * 0.25 )
	
	if brla < 255 then
		brla = brla + 2
		return
	end
	
	draw.Text( {
		text = clang.credits_orig,
		pos = { w * 0.5, h * 0.55 },
		font = "HUDSplashSmall",
		color = Color( 155, 155, 155, ka ),
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_RIGHT,
	})
	draw.Text( {
		text = "Kanade",
		pos = { w * 0.5, h * 0.58 },
		font = "HUDSplashMedium",
		color = Color( 255, 255, 255, ka ),
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_RIGHT,
	})
	
	if ka < 255 then
		ka = ka + 2
		return
	end
	
	draw.Text( {
		text = clang.credits_edit,
		pos = { w * 0.5, h * 0.68 },
		font = "HUDSplashMedium",
		color = Color( 155, 155, 155, da ),
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_RIGHT,
	})
	draw.Text( {
		text = "danx91",
		pos = { w * 0.5, h * 0.74 },
		font = "HUDSplashBig",
		color = Color( 255, 255, 255, da ),
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_RIGHT,
	})
	draw.Text( {
		text = "[aka ZGFueDkx]",
		pos = { w * 0.5, h * 0.82 },
		font = "HUDSplashSmall",
		color = Color( 255, 255, 255, da ),
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_RIGHT,
	})
	
	if da < 255 then
		da = da + 2
		return
	end
	
	surface.SetDrawColor( 0, 0, 0, foa )
	surface.DrawRect( 0, 0, w, h )
	
	if foa < 255 then
		foa = foa + 2
		return
	end
	sequence = 2
	
end

local sa = 255
local bposx, bvel = 0, 0

showupdates = showupdates or false

if showupdates then
	bposx = ScrW() * 0.04
end

local sfoa = -1
function Settings()
	if !vgui.CursorVisible() then
		gui.EnableScreenClicker( true )
	end
	local w, h = ScrW(), ScrH()
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawRect( 0, 0, w, h )
	
	draw.Text( {
		text = clang.settings,
		pos = { w * 0.5, h * 0.02 },
		font = "HUDSplashMedium",
		color = Color( 255, 255, 255, 255 ),
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_RIGHT,
	})
	
	surface.SetDrawColor( 100, 100, 100, 255 )
	surface.DrawRect( w * 0.1, h * 0.15, w * 0.08, h * 0.04 )
	
	if showupdates then
		surface.SetDrawColor( 20, 100, 20, 255 )
		if DoButton( w * 0.14 + 1, h * 0.15 + 1, w * 0.04 - 1, h * 0.04 - 2 ) then
			showupdates = false
			bvel = -10
		end
	else
		surface.SetDrawColor( 100, 20, 20, 255 )
		if DoButton( w * 0.10 + 1, h * 0.15 + 1, w * 0.04 - 1, h * 0.04 - 2 ) then
			showupdates = true
			bvel = 10
		end
	end
	
	surface.DrawRect( w * 0.10 + bposx + 1, h * 0.15 + 1, w * 0.04 - 1, h * 0.04 - 2 )
	
	if bvel != 0 then
		bposx = bposx + bvel
		if bposx < 0 then
			bposx = 0
			bvel = 0
		elseif bposx > w * 0.04 then
			bposx = w * 0.04
			bvel = 0
		end
	end
	
	draw.Text( {
		text = clang.updateinfo,
		pos = { w * 0.2, h * 0.17 },
		font = "HUDSplashSmall",
		color = Color( 255, 255, 255, 255 ),
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_CENTER,
	})
	
	surface.SetDrawColor( 80, 80, 100, 255 )
	surface.DrawRect( w * 0.6, h * 0.9, w * 0.3, h * 0.06 )
	
	draw.Text( {
		text = clang.done,
		pos = { w * 0.75, h * 0.93 },
		font = "HUDSplashSmall",
		color = Color( 255, 255, 255, 255 ),
		xalign = TEXT_ALIGN_CENTER,
		yalign = TEXT_ALIGN_CENTER,
	})
	
	if DoButton( w * 0.6, h * 0.9, w * 0.3, h * 0.06 ) then
		sfoa = 0
	end
	
	draw.Text( {
		text = clang.repe,
		pos = { w * 0.01, h * 0.95 },
		font = "HUDSplashSmall",
		color = Color( 255, 255, 255, 255 ),
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_CENTER,
	})
	
	surface.SetDrawColor( 0, 0, 0, sa )
	surface.DrawRect( 0, 0, w, h )
	
	if sa > 0 then
		sa = sa - 2
		return
	end
	
	if sfoa == -1 then return end
	
	surface.SetDrawColor( 0, 0, 0, sfoa )
	surface.DrawRect( 0, 0, w, h )
	
	if sfoa < 255 then
		sfoa = sfoa + 2
		return
	end
	
	sequence = 3
	
end

local info = { version = 0.00 }
if file.Exists( "gamemodes/breach/gamemode/updates/update"..VERSION..".lua", "GAME" ) then
	local raw = file.Read( "gamemodes/breach/gamemode/updates/update"..VERSION..".lua", "GAME" )
	info = util.JSONToTable( raw )
end

//PrintTable( info )

local COLOR_BUFF = Color( 20, 200, 20, 255 )
local COLOR_NERF = Color( 200, 20, 20, 255 )

function Update()
	if !vgui.CursorVisible() then
		gui.EnableScreenClicker( true )
	end
	local w, h = ScrW(), ScrH()
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.DrawRect( h * 0.1, h * 0.1, w - h * 0.2, h * 0.8 )
	
	surface.SetDrawColor( 200, 20, 20, 255 )
	surface.DrawRect( w - h * 0.2, h * 0.13, h * 0.07, h * 0.07 )
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	draw.NoTexture()
	surface.DrawTexturedRectRotated( w - h * 0.165, h * 0.165, 5, 75, 45 )
	surface.DrawTexturedRectRotated( w - h * 0.165, h * 0.165, 5, 75, -45 )
	
	if DoButton( w - h * 0.2, h * 0.13, h * 0.07, h * 0.07 ) then
		sequence = 0
		playing = false
		gui.EnableScreenClicker( false ) 
	end
	
	local num = 3
	
	if clang.updates[1] == "polski" then num = 2 end
	
	draw.Text( {
		text = clang.updates[2].." "..info.version,
		pos = { w * 0.07, h * 0.13 },
		font = "HUDSplashSmall",
		color = Color( 255, 255, 255, 255 ),
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_CENTER,
	})
	
	draw.Text( {
		text = clang.updates[4].." "..VERSION,
		pos = { w * 0.35, h * 0.13 },
		font = "HUDSplashSmall",
		color = Color( 255, 255, 255, 255 ),
		xalign = TEXT_ALIGN_LEFT,
		yalign = TEXT_ALIGN_CENTER,
	})
	
	if info.version != VERSION then
		draw.Text( {
			text = string.format( clang.updates[3], VERSION ),
			pos = { w * 0.1, h * 0.25 },
			font = "HUDSplashMedium",
			color = Color( 255, 255, 255, 255 ),
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER,
		})
		return
	end
	
	local lastinfo = { [0] = 0, [1] = 0, [2] = 0 }
	local col = 0
	local row = 0
	
	for k, v in pairs( info.update ) do
		local infos = math.floor( #v / 3 )
		local yadd = row > 0 and 60 or 0
		draw.Text( {
			text = k,
			pos = { w * 0.08 + (w - h * 0.2) / 3 * col - 25, h * 0.2 + row * lastinfo[ col ] * 25 + yadd },
			font = "HUDSplashSmall",
			color = Color( 255, 255, 255, 255 ),
			xalign = TEXT_ALIGN_LEFT,
			yalign = TEXT_ALIGN_CENTER,
		})
		for i = 0, infos - 1 do
			local drawcolor = v[1 + i * 3] == "buff" and COLOR_BUFF or v[1 + i * 3] == "nerf" and COLOR_NERF or Color( 200, 200, 200, 255 )
			draw.Text( {
				text = v[num + i * 3],
				pos = { w * 0.08 + (w - h * 0.2) / 3 * col, h * 0.2 + row * lastinfo[ col ] * 25 + 35 + i * 25 + yadd },
				font = "HUDSplashVSmall",
				color = drawcolor,
				xalign = TEXT_ALIGN_LEFT,
				yalign = TEXT_ALIGN_CENTER,
			})
		end
		lastinfo[ col ] = infos
		col = col + 1
		if col > 2 then 
			col = 0
			row = row + 1
		end
		if col > 0 then
			for i = 1, col do
				if i > 2 then break end
				surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
				surface.DrawRect( h * 0.1 + (w - h * 0.2) / 3 * i - 1, h * 0.2, 2, h * 0.65 )
			end
		end
	end
end

function DoButton( x, y, w, h )
	local mx, my = input.GetCursorPos()
	if mx > x and mx < x + w then
		if my > y and my < y + h then
			if input.IsMouseDown( MOUSE_LEFT ) then
				return true
			end
		end
	end
	return false
end

