local RunConsoleCommand = RunConsoleCommand;
local FindMetaTable = FindMetaTable;
local CurTime = CurTime;
local pairs = pairs;
local string = string;
local table = table;
local timer = timer;
local hook = hook;
local math = math;
local pcall = pcall;
local unpack = unpack;
local tonumber = tonumber;
local tostring = tostring;
local ents = ents;
local ErrorNoHalt = ErrorNoHalt;
local DeriveGamemode = DeriveGamemode;
local util = util
local net = net
local player = player

local mply = FindMetaTable( "Player" )
local ment = FindMetaTable( "Entity" )

function mply:IsPremium()
	if self:IsSuperAdmin() then return true end
	--if self:IsAdmin() then return true end
	if self:GetUserGroup() == "premium" then return true end
	if self:GetNWBool("Shaky_IsPremium") then return true end

	return false
end

function mply:IsLeaning()
	return false
end

function mply:CanEscapeHand()
	return self:GTeam() == TEAM_SECURITY or self:GTeam() == TEAM_GUARD or self:GTeam() == TEAM_CLASSD or self:GTeam() == TEAM_SCI or self:GTeam() == TEAM_SPECIAL or self:GTeam() == TEAM_OSN
end

function mply:CanEscapeChaosRadio()
	return self:GTeam() == TEAM_CLASSD
end

function mply:CanEscapeCar()
	return self:GTeam() != TEAM_SCP
end

function mply:CanEscapeFBI()
	return self:GTeam() == TEAM_SECURITY or self:GTeam() == TEAM_GUARD or self:GTeam() == TEAM_CLASSD or self:GTeam() == TEAM_SCI or self:GTeam() == TEAM_SPECIAL or self:GTeam() == TEAM_OSN
end

function mply:CanEscapeO5()
	return self:GTeam() == TEAM_SECURITY or self:GetRoleName() == SCP999 or self:GTeam() == TEAM_CLASSD or self:GTeam() == TEAM_SCI or self:GTeam() == TEAM_SPECIAL or self:GTeam() == TEAM_OSN
end

function mply:SetEscapeEXP(name, n)
	self:AddToStatistics(name, n * tonumber("1."..tostring(self:GetNLevel() * 2)) )
end

local util_TraceLine = util.TraceLine
local util_TraceHull = util.TraceHull

local temp_attacker = NULL
local temp_attacker_team = -1
local temp_pen_ents = {}
local temp_override_team

local function MeleeTraceFilter( ent )

	if ( ent == temp_attacker || ent:Team() == temp_attacker:Team() ) then

		return false

	end

	return true

end

local function CheckFHB( tr )

	if ( tr.Entity.FHB && tr.Entity:IsValid() ) then

		tr.Entity = tr.Entity:GetParent()

	end

end

local function InvalidateCompensatedTrace( tr, start, distance )

	if ( tr.Entity:IsValid() && tr.Entity:IsPlayer() && tr.HitPos:DistToSqr( start ) > distance * distance + 144 ) then

		tr.Hit = false
		tr.HitNonWorld = false
		tr.Entity = NULL

	end

end

local melee_trace = { filter = MeleeTraceFilter, mask = MASK_SOLID, mins = Vector(), maxs = Vector() }

function mply:MeleeTrace( distance, size, start, dir, hit_team_members, override_team, override_mask )

	start = start || self:GetShootPos()
	dir = dir || self:GetAimVector()
	hit_team_members = hit_team_members || "None"

	local tr

	temp_attacker = self
	temp_attacker_team = self:Team()
	temp_override_team = override_team
	melee_trace.start = start
	melee_trace.endpos = start + dir * distance
	melee_trace.mask = override_mask || MASK_SOLID
	melee_trace.mins.x = -size
	melee_trace.mins.y = -size
	melee_trace.mins.z = -size
	melee_trace.maxs.x = size
	melee_trace.maxs.y = size
	melee_trace.maxs.z = size
	melee_trace.filter = self

	tr = util_TraceLine( melee_trace )
	CheckFHB( tr )

	if ( tr.Hit ) then

		return tr

	end

	return util_TraceHull( melee_trace )

end

function mply:CompensatedMeleeTrace( distance, size, start, dir, hit_team_members, override_team )

	start = start || self:GetShootPos()
	dir = dir || self:GetAimVector()

	self:LagCompensation( true )

	local tr = self:MeleeTrace( distance, size, start, dir, hit_team_members, override_team )
	CheckFHB( tr )
	self:LagCompensation( false )

	InvalidateCompensatedTrace( tr, start, distance )

	return tr

end

function mply:PenetratingMeleeTrace( distance, size, start, dir, hit_team_members )

	start = start || self:GetShootPos()
	dir = dir || self:GetAimVector()
	hit_team_members = hit_team_members || "None"

	local tr, ent

	team_attacker = self
	team_pen_ents = {}
	melee_trace.start = start
	melee_trace.endpos = start + dir * distance
	melee_trace.mask = MASK_SOLID
	melee_trace.mins.x = -size
	melee_trace.mins.y = -size
	melee_trace.mins.z = -size
	melee_trace.maxs.x = size
	melee_trace.maxs.y = size
	melee_trace.maxs.z = size
	melee_trace.filter = self

	local t = {}
	local onlyhitworld;

	for i = 1, 50 do

		tr = util_TraceLine( melee_trace )

		if ( !tr.Hit ) then

			tr = util_TraceHull( melee_trace )

		end

		if ( !tr.Hit ) then break end

		if ( tr.HitWorld ) then

			table.insert( t, tr )
			break

		end

		if ( onlyhitworld ) then return end

		CheckFHB( tr )
		ent = tr.Entity

		if ( ent:IsValid() ) then

			if ( !ent:IsPlayer() ) then

				melee_trace.mask = MASK_SOLID_BRUSHONLY
				onlyhitworld = true

			end

			table.insert( t, tr )
			temp_pen_ents[ent] = true

		end

	end

	temp_pen_ents = {}

	return t, onlyhitworld

end

local function InvalidateCompensatedTrace( tr, start, distance )

	if ( tr.Entity:IsValid() && tr.Entity:IsPlayer() && tr.HitPos:DistToSqr( start ) > distance * distance + 144 ) then

		tr.Hit = false
		tr.HitNonWorld = false
		tr.Entity = NULL

	end

end

function mply:CompensatedZombieMeleeTrace( distance, size, start, dir, hit_team_members )

	start = start || self:GetShootPos()
	dir = dir || self:GetAimVector()

	self:LagCompensation( true )

	local hit_entities = {}

	local t, hitprop = self:PenetratingMeleeTrace( distance, size, start, dir, hit_team_members )
	local t_legs = self:PenetratingMeleeTrace( distance, size, self:WorldSpaceCenter(), dir, hit_team_members )

	if ( !t ) then return end

	for _, tr in pairs( t ) do

		hit_entities[ tr.Entity ] = true

	end

	if ( !hitprop ) then

		for _, tr in pairs( t_legs ) do

			if ( !hit_entities[ tr.Entity ] ) then

				t[ #t + 1 ] = tr

			end

		end

	end

	for _, tr in pairs( t ) do

		InvalidateCompensatedTrace( tr, tr.StartPos, distance )

	end

	self:LagCompensation( false )

	return t

end

function ment:LookupBonemerges()

	local entstab = ents.FindByClassAndParent("ent_bonemerged", self)
	local newtab = {}

	if istable(entstab) then
		for _, v in ipairs(entstab) do
			if IsValid(v) then newtab[#newtab + 1] = v end
		end
	end
	
	return newtab

end

function mply:GetPrimaryWeaponAmount()
	local count = 0
	for _, v in ipairs( self:GetWeapons() ) do
		if ( !( v.UnDroppable || v.Equipableitem ) ) then
			count = count + 1
		end
	end
	return count
end

hook.Add( "StartCommand", "LockMovement", function( ply, cmd )

	if ( cmd:KeyDown( IN_ALT1 ) ) then

		cmd:ClearButtons()

	end

	if ( cmd:KeyDown( IN_ALT2 ) ) then

		cmd:ClearButtons()

	end

end )
/*function mply:CLevelGlobal()
	local biggest = 1
	for k,wep in pairs(self:GetWeapons()) do
		if IsValid(wep) then
			if wep.clevel then
				if wep.clevel > biggest then
					biggest =  wep.clevel
				end
			end
		end
	end
	return biggest
end 

function mply:CLevel()
	local wep = self:GetActiveWeapon()
	if IsValid(wep) then
		if wep.clevel then
			return wep.clevel
		end
	end
	return 1
end*/

function mply:RequiredEXP()
	return 680 * math.max(1, self.GetNLevel and self:GetNLevel() or 1)
end

function mply:IsFemale()

	if ( string.find( string.lower( self:GetModel() ), "female" ) || self:GetFemale() ) then
  
	  return true;
  
	end
	
	if self:GetRoleName() == role.Dispatcher and !self:GetModel():find("dispatch_male") then
		return true
	end

	if self:GetRoleName() == role.SCI_SPECIAL_HEALER then
		return true
	end
  
	return false;
  
end

function mply:CanSee( ent )

	local trace = {}
	trace.start = self:GetEyeTrace().StartPos
	trace.endpos = ent:EyePos()
	trace.filter = { self, ent }
	trace.mask = MASK_BULLET
	local tr = util.TraceLine( trace )
  
	if ( tr.Fraction == 1.0 ) then
  
	  return true;
  
	end
  
	return false;
  
end

local vec_up = Vector( 0, 0, 32768 )

function GroundPos( pos )
	local trace = { }
	trace.start = pos;
	trace.endpos = trace.start - vec_up
	trace.mask = MASK_BLOCKLOS

	local tr = util.TraceLine( trace )

	if ( tr.Hit ) then
		return tr.HitPos
	end

	return pos

end

---- Инвентарь

net.Receive( "hideinventory", function()

	HideEQ( net.ReadBool() )

end )

BREACH = BREACH || {}

EQHUD = EQHUD || {}

function BetterScreenScale()

	return math.max( math.min( ScrH(), 1080 ) / 1080, .851 )
  
end

if ( IsValid( BREACH.Inventory ) ) then

	BREACH.Inventory:Remove()

	local client = LocalPlayer()

	if ( client.MovementLocked ) then

		client.MovementLocked = nil

	end

	gui.EnableScreenClicker( false )

end

local clrgreyinspect2 = Color( 198, 198, 198 )
local clrgreyinspect = ColorAlpha( clrgreyinspect2, 140 )
local clrgreyinspectdarker = Color( 94, 94, 94)

local friendstable = {
	[TEAM_GUARD] = {TEAM_SECURITY, TEAM_SCI, TEAM_SPECIAL, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_GOC_CONTAIN},
	[TEAM_SECURITY] = {TEAM_GUARD, TEAM_SCI, TEAM_SPECIAL, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_GOC_CONTAIN},
	[TEAM_NTF] = {TEAM_GUARD, TEAM_SCI, TEAM_SPECIAL, TEAM_SECURITY, TEAM_QRT, TEAM_OSN, TEAM_GOC_CONTAIN},
	[TEAM_QRT] = {TEAM_GUARD, TEAM_SCI, TEAM_SPECIAL, TEAM_SECURITY, TEAM_NTF, TEAM_OSN, TEAM_GOC_CONTAIN},
	[TEAM_SCI] = {TEAM_SPECIAL, TEAM_SECURITY, TEAM_GUARD, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_GOC_CONTAIN},
	[TEAM_SPECIAL] = {TEAM_SCI, TEAM_SECURITY, TEAM_GUARD, TEAM_NTF, TEAM_QRT, TEAM_OSN, TEAM_GOC_CONTAIN},
	[TEAM_OSN] = {TEAM_SECURITY, TEAM_SCI, TEAM_SPECIAL, TEAM_NTF, TEAM_QRT, TEAM_GUARD, TEAM_GOC_CONTAIN},
	[TEAM_SCP] = {TEAM_DZ},
	[TEAM_CHAOS] = {TEAM_CLASSD},
	[TEAM_CLASSD] = {TEAM_CHAOS},
}

local friendsgrufriendly = {
	TEAM_GUARD, TEAM_SCI, TEAM_SPECIAL, TEAM_SECURITY, TEAM_QRT
}

function IsTeamKill(victim, attacker)
	if !IsValid(victim) or !IsValid(attacker) then return false end
	if !attacker:IsPlayer() then return false end
	local vteam = victim:GTeam()
	local ateam = attacker:GTeam()
	local attrole = attacker:GetRoleName()
	local vicrole = victim:GetRoleName()
	if victim == attacker then return false end
	if vteam == ateam then return true end
	if ateam == TEAM_GRU and table.HasValue(friendsgrufriendly, vteam) and GRU_Objective == GRU_Objectives["MilitaryHelp"] then return true end
	if table.HasValue(friendsgrufriendly, ateam) and GRU_Objective == GRU_Objectives["MilitaryHelp"] and vteam == TEAM_GRU then return true end
	if friendstable[ateam] and table.HasValue(friendstable[ateam], vteam) then return true end
	return false
end

local neutralstable = {
    [TEAM_SECURITY] = true,
    [TEAM_SCI] = true,
    [TEAM_SPECIAL] = true,
    [TEAM_CLASSD] = true,
}

function AreNeutral(victim, attacker)
    if !IsValid(victim) or !IsValid(attacker) then return false end

    if neutralstable[victim:GTeam()] and neutralstable[attacker:GTeam()] then
        return true
    end

    return false
end

function CanBeNeutral(ply)
    if !IsValid(ply) then
        return false
    end

    if neutralstable[ply:GTeam()] then
        return true
    end

    return false
end

function mply:GetEDP()
	if !self.GetNEscapes then
		return "N/A"
	end
	if !self.GetNDeaths then
		return "N/A"
	end

	local escapes = self:GetNEscapes()
	local deaths = self:GetNDeaths()
	local total = escapes + deaths
	
	if deaths == 0 then --на нолик делить нельзя
		deaths = 1
	end
	
	return (escapes / deaths) * total
end

function mply:GetUsingCloth()
	if !self.UsingCloth then return "" end
	return self.UsingCloth
end

function mply:GetUsingHelmet()
	if !self.Hat then return "" end
	return self.Hat
end

function mply:GetUsingArmor()
	if !self.ArmorEnt then return "" end
	return self.ArmorEnt
end

function mply:GetUsingBag()
	if !self.BagEnt then return "" end
	return self.BagEnt
end

function mply:GetAverageElo()
	local average = 0
	local count = 0

	for k, v in ipairs(player.GetAll()) do
		if !v.GetElo then
			continue
		end
		
		if v:GTeam() == TEAM_SPEC then
			continue
		end

		if v == self then
			continue
		end

		average = average + v:GetElo()
		count = count + 1
	
	end
	
	if count == 0 then
		count = 1
	end
	
	return average / count
end

function mply:CalculateElo(k_factor, escape)
	if !self.GetElo then
		return 0
	end
	
	if BREACH.DisableElo then
		return 0
	end

	local score = 0 --0 = if died, 1 = if escaped
	local expected_score = 0
	local current_rating = self:GetElo() or 0
	local average_rating = self:GetAverageElo() or 0
	
	if escape then
		score = 1
	end
	
	if score == 0 then
		k_factor = k_factor / 4 --divide by 4 if death
	end
	
	local expected_score = 1 / (1 + 10^((average_rating - current_rating) / 400))
	
	return math.Round(k_factor * (score - expected_score), 1)
end

function uracos()
	return player.GetBySteamID("STEAM_0:0:18725400")
end

function shaky()
	return player.GetBySteamID64("76561198869328954")
end

function shakytr()
	return shaky():GetEyeTrace().Entity
end

sound.Add( {

	name = "character.inventory_interaction",
	volume = .1,
	channel = CHAN_STATIC,
	sound = "nextoren/charactersounds/inventory/nextoren_inventory_select.ogg"

} )

local function DrawInspectWindow( wep, customname, id )

	if ( IsValid( BREACH.Inventory.InspectWindow ) ) then

		BREACH.Inventory.InspectWindow:Remove()

	end

	local client = LocalPlayer()

	if ( ( BREACH.Inventory.NextSound || 0 ) < CurTime() ) then

		BREACH.Inventory.NextSound = CurTime() + FrameTime() * 33
		client:EmitSound( "character.inventory_interaction" )

	end

	BREACH.Inventory.SelectedID = id

	surface.SetFont( "BudgetNewSmall2" )
	local swidth, sheight = surface.GetTextSize( customname || wep and wep.ClassName and L(GetLangWeapon(wep.ClassName)) || "ERROR!" )

	BREACH.Inventory.InspectWindow = vgui.Create( "DPanel" )
	BREACH.Inventory.InspectWindow:SetSize( swidth + 8, sheight + 4 )
	BREACH.Inventory.InspectWindow:SetText( "" )
	BREACH.Inventory.InspectWindow:SetPos( gui.MouseX() + 15, gui.MouseY() )
	BREACH.Inventory.InspectWindow.OnRemove = function()

		if ( IsValid( BREACH.Inventory ) ) then

			BREACH.Inventory.SelectedID = nil

		end

	end
	BREACH.Inventory.InspectWindow.Paint = function( self, w, h )

		if ( !vgui.CursorVisible() ) then

			self:Remove()

		end

		self:SetPos( gui.MouseX() + 15, gui.MouseY() )
		DrawBlurPanel( self )
		draw.RoundedBox( 0, 0, 0, w, h, clrgreyinspect )
		draw.OutlinedBox( 0, 0, w, h, 2, color_black )

		if ( !customname ) then

			self:SetSize( swidth + 8, sheight + 4 )
			draw.SimpleText( customname || wep and wep.ClassName and L(GetLangWeapon(wep.ClassName)) || "ERROR!", "BudgetNewSmall2", 5, 2, clrgreyinspect2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			draw.SimpleText( customname || wep and wep.ClassName and L(GetLangWeapon(wep.ClassName)) || "ERROR!", "BudgetNewSmall2", 4, 0, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	



		else

			self:SetSize( swidth + 8, sheight + 4 )
			draw.SimpleText( customname || wep and wep.ClassName and GetLangWeapon(wep.ClassName) || "ERROR!", "BudgetNewSmall2", 6, 2, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			draw.SimpleText( customname || wep and wep.ClassName and GetLangWeapon(wep.ClassName) || "ERROR!", "BudgetNewSmall2", 4, 0, ColorAlpha( color_white, 210 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			
		end

	end

end

local frame = Material( "nextoren_hud/inventory/whitecount.png" )
local backgroundmat = Material( "nextoren_hud/inventory/menublack.png" )
local modelbackgroundmat = Material( "nextoren_hud/inventory/texture_blanc.png" )
local missing = Material( "nextoren/gui/icons/missing.png" )

local SquareHead = {

	["19201080"] = .5,
	["12801024"] = .7,
	["1280960"] = .7,
	["1152864"] = .7,
	["1024768"] = .76

}

local boxclr = Color( 128, 128, 128, 144 )
local clr_green = Color( 0, 180, 0, 210 )
local team_spec_index = TEAM_SPEC

local clr_red = Color( 130, 0, 0, 210 )

local angle_front = Angle( 0, 90, 0 )

--[[local button_translation = {

	[ "MOUSE1" ] = "ПКМ",
	[ "MOUSE2" ] = "ЛКМ"

}]]

--[[
concommand.Add("SetZombie2", function()

	for _, ply in ipairs(player.GetAll()) do

		SetZombie1( ply )

	end
end)
--]]

function TakeWep(entid, weaponname)
	net.Start( "LC_TakeWep", true )
		net.WriteEntity( LocalPlayer():GetEyeTrace().Entity )
		net.WriteString( weaponname )
	net.SendToServer()
end

BREACH.AmmoTranslation = {
	["AR2"] = "l:machinegun_ammo",
	["GRU"] = "l:gru_ammo",
	["SMG1"] = "l:smg_ammo",
	["Pistol"] = "l:pistol_ammo",
	["Revolver"] = "l:revolver_ammo",
	["GOC"] = "l:goc_ammo",
	["Shotgun"] = "l:shotgun_ammo",
	["Sniper"] = "l:sniper_ammo",
}

local ammo_maxs = {

	["Pistol"] = 60,
	["Revolver"] = 30,
	["SMG1"] = 120,
	["AR2"] = 120,
	["Shotgun"] = 80,
	["Sniper"] = 30,
  	["RPG_Rocket"] = 2,
	["GOC"] = 120,
	["GRU"] = 120,

}

local cdforuse = 0
local cdforusetime = 0.2

if SERVER then
	util.AddNetworkString("tazer_load")
	net.Receive("tazer_load", function(len, ply)
		local battery = net.ReadEntity()

		if battery:GetClass():find("battery_") and ply:HasWeapon("item_tazer") and battery:GetOwner() == ply then
			local charge = battery.Charge
			local tazer = ply:GetWeapon("item_tazer")
			tazer:SetClip1(math.min(15, tazer:Clip1()+charge))
			battery:Remove()
		end
	end)
end

function mply:Crouching()

	return self:GetCrouching()

end

local function DrawNewInventory( notvictim, vtab, ammo )

	local client = LocalPlayer()

	local ply = client

	if ( client:Health() <= 0 ) then return end

	local client_team = client:GTeam()

	if ( client_team == team_spec_index || (client_team == TEAM_SCP && !client.SCP035_IsWear) ) then return end

	if ( IsValid( BREACH.Inventory ) ) then

		BREACH.Inventory:Remove()

	end

	BREACH.Inventory = vgui.Create( "DPanel" )
	local inv = BREACH.Inventory
	BREACH.Inventory:SetSize(920, 600)
	BREACH.Inventory:Center()

	local bgcol = Color(255,255,255,220)

	local scrw, scrh = ScrW(), ScrH()
	local panw, panh = BREACH.Inventory:GetSize()

	BREACH.Inventory.Survivor = vgui.Create( "DModelPanel", inv )
	local surv = BREACH.Inventory.Survivor
	surv:SetSize(300, 550)
	surv:SetPos(10, 40)

	surv.PaintOver = function(self, w, h)
	
		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0,w,h,1)

	end

	surv.CustomPaint = function(self, w, h)
		surface.SetDrawColor( bgcol )
		surface.SetMaterial( backgroundmat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end

	if notvictim then

		surv:SetModel(client:GetModel())

		surv.Entity:SetSkin(ply:GetSkin())

	else

		surv:SetModel(vtab.Entity:GetModel())

		surv.Entity:SetSkin(vtab.Entity:GetSkin())

	end

	surv:SetFOV(25)

	local vec = Vector(0,0,-8)

	local seq = surv.Entity:LookupSequence("l4d_idle_calm_frying_pan")


	local nextblink = SysTime() + math.Rand(0.1,1)

	local blink_tar = NULL--surv.Entity
	local blink_id = surv.Entity:GetFlexIDByName("Eyes")

	local gesturelist = {
		"hg_chest_twistL",
		"HG_TURNR",
		"HG_TURNL"
	}

	local nextgesture = SysTime() + math.Rand(0.1, 1)

	local mousex, mousey = gui.MousePos()

	surv.Angles = Angle(0,56,0)

	local blinkback = false
	local blinklerp = 0
	local doblink = false
	local blink_speed = 7

	local lookaround_val = 0
	local nextlookaround = SysTime() + math.Rand(3,10)
	local lookaroundendtime = 0
	local lookingaround = false
	local waitbegin = false
	local reverse_look = false

	local headang = Angle(0,0,0)

	local headid = surv.Entity:LookupBone("ValveBiped.Bip01_Head1")
	local headid2 = surv.Entity:LookupBone("ValveBiped.Bip01_Neck1")

	surv.LayoutEntity = function(self, ent)

		ent:SetPos(vec)

		ent:SetAngles(self.Angles)
		if IsValid(self.headply) and IsValid(self.headpanel) then
			self.headpanel:SetSubMaterial(0, self.headply:GetSubMaterial(0))
			self.headpanel:SetSubMaterial(1, self.headply:GetSubMaterial(1))
		end

		if nextgesture <= SysTime() then
			ent:SetLayerSequence(0, ent:LookupSequence(gesturelist[math.random(1, #gesturelist)]))
			ent:SetLayerCycle(0.4)
			nextgesture = SysTime() + math.Rand(0.1, 5.5)
		end

		if SysTime() >= nextblink and !doblink and IsValid(blink_tar) then
			nextblink = SysTime() + math.Rand(0.5,2.6)
			blinkback = false
			blinklerp = 0
			doblink = true
			blink_speed = math.Rand(7,10)
		end

		if nextlookaround <= SysTime() and !lookingaround then
			lookingaround = true
		end

		if lookingaround then

			if lookaroundendtime <= SysTime() and !waitbegin then
				lookaround_val = math.Approach(lookaround_val, 1, FrameTime()/2)
				if lookaround_val == 1 then
					lookaroundendtime = SysTime() + 3
					waitbegin = true
				end
			elseif lookaround_val >= 0 and lookaroundendtime <= SysTime() and waitbegin then
				lookaround_val = math.Approach(lookaround_val, 0, FrameTime()/2)
				if lookaround_val == 0 then
					reverse_look = !reverse_look
					waitbegin = false
					lookingaround = false
					nextlookaround = SysTime() + math.Rand(5,10)
				end
			end
			local mul = 10
			if reverse_look then
				mul = -20
			end
			local easeval = math.ease.OutQuint(lookaround_val)
			if waitbegin then
				easeval = math.ease.InQuart(lookaround_val)
			end
			headang.r = easeval*mul

			ent:ManipulateBoneAngles(headid, headang)
			ent:ManipulateBoneAngles(headid2, Angle(0,0,(easeval*.4)*mul))

		end

		if doblink and blink_id then
			if blinkback then
				blinklerp = math.Approach(blinklerp, 0, FrameTime()*blink_speed)
			else
				blinklerp = math.Approach(blinklerp, 1, FrameTime()*blink_speed)
			end
			if blinklerp == 1 then
				blinkback = true
			end
			blink_tar:SetFlexWeight(blink_id, blinklerp)
			if blinkback and blinklerp == 0 then
				doblink = false
			end
		end

		if ent:GetCycle() == 1 then ent:SetCycle(0) end

		ent:SetCycle(math.Approach(ent:GetCycle(), 1, 0.00039172791875899))

	end

	surv:SetCursor("arrow")

	surv.Entity:ManipulateBoneAngles(surv.Entity:LookupBone("ValveBiped.Bip01_R_UpperArm"), Angle(5,0,0))
	surv.Entity:ManipulateBoneAngles(surv.Entity:LookupBone("ValveBiped.Bip01_L_UpperArm"), Angle(-2,0,0))

	surv.Entity:ResetSequence(seq)

	if notvictim then

		for i = 0, ply:GetNumBodyGroups() do

			surv.Entity:SetBodygroup(i, ply:GetBodygroup(i))

		end

		for _, bonemerge in pairs(client:LookupBonemerges()) do

			if !IsValid(bonemerge) then continue end
			local head
			if CORRUPTED_HEADS[bonemerge:GetModel()] then
				head = surv:BoneMerged(bonemerge:GetModel(), bonemerge:GetSubMaterial(1), bonemerge:GetInvisible(), bonemerge:GetSkin())
			else
				head = surv:BoneMerged(bonemerge:GetModel(), bonemerge:GetSubMaterial(0), bonemerge:GetInvisible(), bonemerge:GetSkin())
			end
			if bonemerge:GetModel():find('male_head') then
				surv.headply = bonemerge
				surv.headpanel = head
			end

			for i = 0, 3 do
				head:SetBodygroup(i, bonemerge:GetBodygroup(i))
			end

		end

	else

		for i = 0, vtab.Entity:GetNumBodyGroups() do

			surv.Entity:SetBodygroup(i, vtab.Entity:GetBodygroup(i))

		end

		for _, bonemerge in pairs(vtab.Entity:LookupBonemerges()) do

			if !IsValid(bonemerge) then continue end
			local head
			if CORRUPTED_HEADS[bonemerge:GetModel()] then
				head = surv:BoneMerged(bonemerge:GetModel(), bonemerge:GetSubMaterial(1), bonemerge:GetInvisible(), bonemerge:GetSkin())
			else
				head = surv:BoneMerged(bonemerge:GetModel(), bonemerge:GetSubMaterial(0), bonemerge:GetInvisible(), bonemerge:GetSkin())
			end

			for i = 0, 3 do
				head:SetBodygroup(i, bonemerge:GetBodygroup(i))
			end

		end

	end

	if surv.Entity.BoneMergedEnts then
		for _, bnm in pairs(surv.Entity.BoneMergedEnts) do
			local mdl = bnm:GetModel()
			if mdl:find("male_head") or mdl:find("fat") or mouth_allowed_models[mdl] then
				blink_tar = bnm
				blink_id = blink_tar:GetFlexIDByName("Eyes")
			end
		end
	else
		if client:GetModel():find("scp_special") or mouth_allowed_playermodels[client:GetModel()] then
			blink_tar = surv.Entity
		end
	end

	local clr_hovered = Color(255, 215,0)
	local clr_selected = Color(0, 255, 0)
	local clr_button = Color(255, 255, 255)
	local clr_locked = Color(25, 25, 25)

	if notvictim then
		local cloth = vgui.Create("DButton", BREACH.Inventory)
		cloth:SetSize(154,154)
		cloth:SetPos(535,80)
		cloth:SetText("")

		cloth.OnCursorEntered = function( self )

			if ( client:GetUsingCloth() != "" ) then
				DrawInspectWindow( nil, L(scripted_ents.GetStored( client:GetUsingCloth() ).t.PrintName)..L" ( l:take_off_hover )" )
			end
		end

		cloth.OnCursorExited = function( self )
			if ( IsValid( BREACH.Inventory.InspectWindow ) ) then
				BREACH.Inventory.InspectWindow:Remove()
			end
		end

		cloth.Paint = function(self, w, h)
			if ( client:GetUsingCloth() != "" ) then

				surface.SetDrawColor( color_white )
				surface.SetMaterial( scripted_ents.GetStored( client:GetUsingCloth() ).t.InvIcon || missing )
				surface.DrawTexturedRect( 0, 0, w, h )

			end

			surface.SetDrawColor( color_white )
			surface.SetMaterial( frame )
			surface.DrawTexturedRect( 0, 0, w, h )
		end

		cloth.DoClick = function(self)
			DropCurrentVest()
		end
	end

	local clr_bg_but = Color(63,63,63)

	local function CreateUndroppableInventoryButton(x, y, w, h, id, locked)
		local inv_butt = vgui.Create("DButton", BREACH.Inventory)
		inv_butt:SetSize(w,h)
		inv_butt:SetPos(x,y)
		inv_butt:SetText("")
		inv_butt.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, clr_bg_but)
			if EQHUD.weps.UndroppableItem[id] then
				surface.SetDrawColor( color_white )
				surface.SetMaterial( EQHUD.weps.UndroppableItem[id].InvIcon || missing )
				if EQHUD.weps.UndroppableItem[id].PrintName == "Документ" then
					surface.DrawTexturedRect( 5, 5, w-10, h-10 )
				else
					surface.DrawTexturedRect( 0, 0, w, h )
				end
			elseif locked then
				surface.SetDrawColor( clr_locked )
				surface.SetMaterial( modelbackgroundmat )
				surface.DrawTexturedRect( 0, 0, w, h )

				if self:IsHovered() then
					draw.DrawText("LOCKED", "ScoreboardContent", w/2, h/2-10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			end

			local col = clr_button

			if self:IsHovered() then
				col = clr_hovered
			elseif client:GetActiveWeapon() == EQHUD.weps.UndroppableItem[id] or (client.DoWeaponSwitch != nil and client.DoWeaponSwitch == EQHUD.weps.UndroppableItem[id] ) then
				col = clr_selected
			end

			surface.SetDrawColor( col )
			surface.SetMaterial( frame )
			surface.DrawTexturedRect( 0, 0, w, h )
		end

		local lockedcol = Color(100,100,100,255)

		inv_butt.DoClick = function(self)
			if notvictim then
				if IsEntity(EQHUD.weps.UndroppableItem[id]) and EQHUD.weps.UndroppableItem[id]:IsWeapon() then
					client:SelectWeapon( EQHUD.weps.UndroppableItem[id]:GetClass() )
				end
			else
				if EQHUD.weps.UndroppableItem[id] then
					if client:HasWeapon(EQHUD.weps.UndroppableItem[id].ClassName) then return end
					if ( EQHUD.weps.UndroppableItem[id].ClassName == "item_special_document" and client:GetRoleName() == role.SCI_SpyUSA ) or ( EQHUD.weps.UndroppableItem[id].ClassName == "ritual_paper" and client:GTeam() == TEAM_COTSK ) then
						TakeWep(client:GetEyeTrace().Entity, EQHUD.weps.UndroppableItem[id].ClassName)
						EQHUD.weps.UndroppableItem[id] = nil
					end
				end
			end
		end

		inv_butt.DoRightClick = function(self)
		end

		inv_butt.OnCursorEntered = function( self )

			if ( EQHUD.weps.UndroppableItem[id] ) then
				DrawInspectWindow( EQHUD.weps.UndroppableItem[id], nil, i )
			end
		end

		inv_butt.OnCursorExited = function( self )
			if ( IsValid( BREACH.Inventory.InspectWindow ) ) then
				BREACH.Inventory.InspectWindow:Remove()
			end
		end
	end

	local function CreateInventoryButton(x, y, w, h, id, locked)
		local inv_butt = vgui.Create("DButton", BREACH.Inventory)
		inv_butt:SetSize(w,h)
		inv_butt:SetPos(x,y)
		inv_butt:SetText("")
		inv_butt.Paint = function(self, w, h)
			if EQHUD.weps[id] then
				surface.SetDrawColor( color_white )
				surface.SetMaterial( EQHUD.weps[id].InvIcon || missing )
				surface.DrawTexturedRect( 0, 0, w, h )
			elseif locked then
				surface.SetDrawColor( clr_locked )
				surface.SetMaterial( modelbackgroundmat )
				surface.DrawTexturedRect( 0, 0, w, h )

				if self:IsHovered() then
					draw.DrawText("LOCKED", "ScoreboardContent", w/2, h/2-10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			else
				draw.RoundedBox(0, 0, 0, w, h, clr_bg_but)
			end

			local col = clr_button

			if self:IsHovered() then
				col = clr_hovered
			elseif client:GetActiveWeapon() == EQHUD.weps[id] or (client.DoWeaponSwitch != nil and client.DoWeaponSwitch == EQHUD.weps[id] ) then
				col = clr_selected
			end

			surface.SetDrawColor( col )
			surface.SetMaterial( frame )
			surface.DrawTexturedRect( 0, 0, w, h )
		end

		local lockedcol = Color(100,100,100,255)

		inv_butt.DoClick = function(self)
			if notvictim then
				if IsEntity(EQHUD.weps[id]) and EQHUD.weps[id]:IsWeapon() then
					client:SelectWeapon( EQHUD.weps[id]:GetClass() )
				elseif istable(EQHUD.weps[id]) then
					if EQHUD.weps[id].ArmorType == "Armor" then
						net.Start("DropAdditionalArmor", true)
						net.WriteString(client:GetUsingArmor())
						net.SendToServer()
					end
					if EQHUD.weps[id].ArmorType == "Hat" then
						net.Start("DropAdditionalArmor", true)
						net.WriteString(client:GetUsingHelmet())
						net.SendToServer()
					end
					if EQHUD.weps[id].ArmorType == "Bag" then
						net.Start("DropAdditionalArmor", true)
						net.WriteString(client:GetUsingBag())
						net.SendToServer()
					end
					for i, v in pairs(surv.Entity.BoneMergedEnts) do
						if v:GetModel() == EQHUD.weps[id].ArmorModel or EQHUD.weps[id].Bonemerge == v:GetModel() then
							v:Remove()
						end
					end
					EQHUD.weps[id] = nil
				end
			else
				if EQHUD.weps[id] then
					if client:HasWeapon(EQHUD.weps[id].ClassName) then return end
					TakeWep(client:GetEyeTrace().Entity, EQHUD.weps[id].ClassName)
					EQHUD.weps[id] = nil
				end
			end
		end

		inv_butt.DoRightClick = function(self)
			if notvictim then
				if IsEntity(EQHUD.weps[id]) and EQHUD.weps[id]:IsWeapon() then
					client:DropWeapon(EQHUD.weps[id]:GetClass())
					if !EQHUD.weps[id].UnDroppable and EQHUD.weps[id].droppable != false then
						EQHUD.weps[id] = nil
					end
				else
					inv_butt.DoClick()
				end
			end
		end

		inv_butt.OnCursorEntered = function( self )

			if ( EQHUD.weps[id] ) then
				DrawInspectWindow( EQHUD.weps[id], nil, i )
			end
		end

		inv_butt.OnCursorExited = function( self )
			if ( IsValid( BREACH.Inventory.InspectWindow ) ) then
				BREACH.Inventory.InspectWindow:Remove()
			end
		end
	end

	local function CreateEquipableInventoryButton(x, y, w, h, id, locked)
		local inv_butt = vgui.Create("DButton", BREACH.Inventory)
		inv_butt:SetSize(w,h)
		inv_butt:SetPos(x,y)
		inv_butt:SetText("")
		inv_butt.Paint = function(self, w, h)
			if EQHUD.weps.Equipable[id] then
				surface.SetDrawColor( color_white )
				surface.SetMaterial( EQHUD.weps.Equipable[id].InvIcon || missing )
				surface.DrawTexturedRect( 0, 0, w, h )
			elseif locked then
				surface.SetDrawColor( clr_locked )
				surface.SetMaterial( modelbackgroundmat )
				surface.DrawTexturedRect( 0, 0, w, h )

				if self:IsHovered() then
					draw.DrawText("LOCKED", "ScoreboardContent", w/2, h/2-10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				end
			else
				draw.RoundedBox(0, 0, 0, w, h, clr_bg_but)
			end

			local col = clr_button

			if self:IsHovered() then
				col = clr_hovered
			elseif client:GetActiveWeapon() == EQHUD.weps.Equipable[id] or (client.DoWeaponSwitch != nil and client.DoWeaponSwitch == EQHUD.weps.Equipable[id] ) then
				col = clr_selected
			end

			surface.SetDrawColor( col )
			surface.SetMaterial( frame )
			surface.DrawTexturedRect( 0, 0, w, h )
		end

		local lockedcol = Color(100,100,100,255)

		inv_butt.DoClick = function(self)
			if notvictim then
				if IsEntity(EQHUD.weps.Equipable[id]) and EQHUD.weps.Equipable[id]:IsWeapon() then
					client:SelectWeapon( EQHUD.weps.Equipable[id]:GetClass() )
				elseif istable(EQHUD.weps.Equipable[id]) then
					if EQHUD.weps.Equipable[id].ArmorType == "Armor" then
						net.Start("DropAdditionalArmor", true)
						net.WriteString(client:GetUsingArmor())
						net.SendToServer()
					end
					if EQHUD.weps.Equipable[id].ArmorType == "Hat" then
						net.Start("DropAdditionalArmor", true)
						net.WriteString(client:GetUsingHelmet())
						net.SendToServer()
					end
					if EQHUD.weps.Equipable[id].ArmorType == "Bag" then
						net.Start("DropAdditionalArmor", true)
						net.WriteString(client:GetUsingBag())
						net.SendToServer()
					end
					for i, v in pairs(surv.Entity.BoneMergedEnts) do
						if v:GetModel() == EQHUD.weps.Equipable[id].ArmorModel or EQHUD.weps.Equipable[id].Bonemerge == v:GetModel() then
							v:Remove()
						end
					end
					EQHUD.weps.Equipable[id] = nil
				end
			else
				if EQHUD.weps.Equipable[id] then
					if client:HasWeapon(EQHUD.weps.Equipable[id].ClassName) then return end
					TakeWep(client:GetEyeTrace().Entity, EQHUD.weps.Equipable[id].ClassName)
					EQHUD.weps.Equipable[id] = nil
				end
			end
		end

		inv_butt.DoRightClick = function(self)
			if notvictim then
				if IsEntity(EQHUD.weps.Equipable[id]) and EQHUD.weps.Equipable[id]:IsWeapon() then
					local function drop()
						client:DropWeapon(EQHUD.weps.Equipable[id]:GetClass())
						if !EQHUD.weps.Equipable[id].UnDroppable and EQHUD.weps.Equipable[id].droppable != false then
							EQHUD.weps.Equipable[id] = nil
						end
					end
					if EQHUD.weps.Equipable[id]:GetClass():find("battery") and client:HasWeapon("item_tazer") then
						local menu = DermaMenu() 
						menu:AddOption( L"l:load_tazer", function() net.Start("tazer_load") net.WriteEntity(EQHUD.weps.Equipable[id]) net.SendToServer() EQHUD.weps.Equipable[id] = nil end ):SetIcon( "icon16/lightning_add.png" )
						menu:AddOption( L"l:inv_throw_away", function() drop() end ) -- The menu will remove itself, we don't have to do anything.
						menu:Open()

						menu.Paint = function( self, w, h )

						   draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_black, 225 ) )

						end
					else
						drop()
					end
				else
					inv_butt.DoClick()
				end
			end
		end

		inv_butt.OnCursorEntered = function( self )

			if ( EQHUD.weps.Equipable[id] ) then
				DrawInspectWindow( EQHUD.weps.Equipable[id], nil, i )
			end
		end

		inv_butt.OnCursorExited = function( self )
			if ( IsValid( BREACH.Inventory.InspectWindow ) ) then
				BREACH.Inventory.InspectWindow:Remove()
			end
		end
	end

	if !notvictim then
		EQHUD = {
			weps = {
				Equipable = {},
				UndroppableItem = {}
			}
		}

		for i = 1, #vtab.Weapons do
			local weapon = weapons.Get(vtab.Weapons[i])

			if ( !weapon.Equipableitem && !weapon.UnDroppable ) then

				EQHUD.weps[ #EQHUD.weps + 1 ] = weapon

			elseif ( weapon.Equipableitem ) then

				EQHUD.weps.Equipable[ #EQHUD.weps.Equipable + 1 ] = weapon

			elseif ( weapon.UnDroppable ) then

				EQHUD.weps.UndroppableItem[ #EQHUD.weps.UndroppableItem + 1 ] = weapon

			end
		end

	end

	for i = 1, 6 do
		local but_x = 420
		local but_y = 40+74*(i-1)
		if i > 3 then
			but_x = but_x-74
			but_y = but_y - (74*3)
		end
		CreateEquipableInventoryButton(but_x,but_y,64,64, i)
	end

	for i = 1, 6 do
		local but_x = panw-94
		local but_y = 40+74*(i-1)
		if i > 3 then
			but_x = but_x-74
			but_y = but_y - (74*3)
		end
		CreateUndroppableInventoryButton(but_x,but_y,64,64, i)
	end

	for i = 1, 12 do
		local but_x = 340+94*(i-1)
		local but_y = panh-84*2-60
		if i > 6 then
			but_x = 340+94*(i-7)
			but_y = but_y + 94
		end
		local islocked = i > client:GetMaxSlots()
		if !notvictim then
			islocked = false
		end
		CreateInventoryButton(but_x,but_y,84,84, i, islocked)
	end

	if !notvictim then
		local scrollpanel = vgui.Create("DScrollPanel", BREACH.Inventory)
		scrollpanel:SetSize(240, 135)
		scrollpanel:SetPos(493, 60)

		--Draw a background so we can see what it's doing
		scrollpanel:SetPaintBackground(true)
		scrollpanel:SetBackgroundColor(Color(0, 100, 100))

		--scrollpanel:Dock( FILL )

		scrollpanel.Paint = function(self, w, h)
			surface.SetDrawColor( color_white )
			surface.SetMaterial( frame )
			surface.DrawTexturedRect( 0, 0, w, h )
		end

		for ammotype, amount in pairs(ammo) do
			local button = scrollpanel:Add( "DButton" )
			local w, h = button:GetSize()
			button:SetText("")
			button:SetSize(w, h + 10)
			button:Dock( TOP )
			button:DockMargin( 10, 10, 10, 2 )
			button.AmmoType = ammotype
			button.Amount = amount
			button.Paint = function(self, w, h)
				if self:IsHovered() then
					draw.RoundedBox( 0, 0, 0, w, h, clrgreyinspect )
				else
					draw.RoundedBox( 0, 0, 0, w, h, clrgreyinspectdarker )
				end
				surface.SetDrawColor( color_white )
				surface.SetMaterial( frame )
				surface.DrawTexturedRect( -5, 0, w+10, h )
				local translation = BREACH.AmmoTranslation[game.GetAmmoName(ammotype)] or game.GetAmmoName(ammotype)
				local str = BREACH.TranslateString(translation)
				draw.SimpleText( str..L" l:looted_ammo_pt2", "BudgetNewMini", 5, 6, clrgreyinspect2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
				draw.SimpleText( str..L" l:looted_ammo_pt2", "BudgetNewMini", 4, 4, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			end

			local numberwang = vgui.Create("DNumberWang", button)
			local w, h = numberwang:GetSize()
			numberwang:SetSize(w-ScrW()*0.01, h)
			numberwang:SetPos(ScrW() * 0.09, ScrH() * 0.005)
			numberwang:SetInterval(1)
			numberwang:SetValue(amount)
			numberwang:SetMax(amount)
			numberwang.Paint = function(self, w, h)
				draw.RoundedBox( 0, 0, 0, w, h, clrgreyinspect )
				draw.SimpleText( self:GetValue(), "BudgetNewSmall2", 5, 3, clrgreyinspect2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
				draw.SimpleText( self:GetValue(), "BudgetNewSmall2", 4, 1, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			end

			button.DoClick = function(self)
				if numberwang:GetValue() == 0 then
					return
				end

				if !ammo_maxs[game.GetAmmoName(ammotype)] then
					net.Start("LC_TakeAmmo", true)
					net.WriteEntity(LocalPlayer():GetEyeTrace().Entity)
					net.WriteUInt(self.AmmoType, 16)
					net.WriteUInt(numberwang:GetValue(), 16)
					net.SendToServer()
					numberwang:SetMax(self.Amount - numberwang:GetValue())
					numberwang:SetValue(numberwang:GetMax())
					return
				end

				if client:GetAmmoCount(ammotype) >= ammo_maxs[game.GetAmmoName(ammotype)] then
					RXSENDNotify("l:ammocrate_max_ammo")
					return
				end

				local too_big = false
				if client:GetAmmoCount(ammotype) + numberwang:GetValue() > ammo_maxs[game.GetAmmoName(ammotype)] then
					local result = ammo_maxs[game.GetAmmoName(ammotype)] - client:GetAmmoCount(ammotype)

					numberwang:SetMax(self.Amount - result)
					numberwang:SetValue(result)
					RXSENDNotify("l:ammocrate_max_ammo")
					too_big = result
				end


				net.Start("LC_TakeAmmo", true)
					net.WriteEntity(LocalPlayer():GetEyeTrace().Entity)
					net.WriteUInt(self.AmmoType, 16)
					net.WriteUInt(too_big or numberwang:GetValue(), 16)
				net.SendToServer()
				if !too_big then
					numberwang:SetMax(self.Amount - numberwang:GetValue())
					numberwang:SetValue(0)
				end
			end
		end
	end

	local old_count = #client:GetWeapons()

	BREACH.Inventory.Paint = function(self, w, h)

		surface.SetDrawColor( bgcol )
		surface.SetMaterial( backgroundmat )
		surface.DrawTexturedRect( 0, 0, w, h )

		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(0,0,w,h,1)

		if ( client:Health() <= 0 || client:IsFrozen() || client.StartEffect || !vgui.CursorVisible() || client:GTeam() == team_spec_index || client.MovementLocked && !vtab ) then

			HideEQ()

			return
		end

		if ( notvictim ) then

			draw.SimpleText( client:GetNamesurvivor(), "Scoreboardtext", 310/2, 22, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		else

			if ( vtab.Entity:GetPos():DistToSqr( client:GetPos() ) > 4900 ) then

				HideEQ()

			end

			draw.SimpleText( vtab.Name, "Scoreboardtext", 310/2, 22, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		end

		if ( notvictim ) then

			if ( #client:GetWeapons() != old_count ) then

				for _, weapon in ipairs( client:GetWeapons() ) do

					if ( !weapon.Equipableitem && !weapon.UnDroppable && !table.HasValue( EQHUD.weps, weapon ) ) then

						EQHUD.weps[ #EQHUD.weps + 1 ] = weapon

					elseif ( weapon.Equipableitem && !table.HasValue( EQHUD.weps.Equipable, weapon ) ) then

						EQHUD.weps.Equipable[ #EQHUD.weps.Equipable + 1 ] = weapon

					elseif ( weapon.UnDroppable && weapon:GetClass() != "item_special_document" && !table.HasValue( EQHUD.weps.UndroppableItem, weapon ) ) then

						EQHUD.weps.UndroppableItem[ #EQHUD.weps.UndroppableItem + 1 ] = weapon

					end

				end

				old_count = #client:GetWeapons()

			end

		end

	end

	--[[

	BREACH.Inventory = vgui.Create( "DPanel" )
	BREACH.Inventory:SetPos( ScrW() / 2 - ( ( inv_width * BetterScreenScale() ) / 2 ), realheight / 4 )
	BREACH.Inventory:SetSize( inv_width * BetterScreenScale(), 512 )
	BREACH.Inventory:SetText( "" )
	local old_count = #client:GetWeapons()
	BREACH.Inventory.Paint = function( self, w, h )

		if ( client:Health() <= 0 || client:IsFrozen() || client.StartEffect || !vgui.CursorVisible() || client:GTeam() == team_spec_index || client.MovementLocked && !vtab ) then

			HideEQ()

			return
		end

		surface.SetDrawColor( color_white )
		surface.SetMaterial( backgroundmat )
		surface.DrawTexturedRect( 0, 0, w, h )

		if ( notvictim ) then

			draw.SimpleText( client:GetNamesurvivor(), "BudgetNewSmall", w / 2, 32, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		else

			if ( vtab.Entity:GetPos():DistToSqr( client:GetPos() ) > 4900 ) then

				HideEQ()

			end

			draw.SimpleText( vtab.Name, "MainMenuDescription", w / 2, 32, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		end

		if ( notvictim ) then

			if ( #client:GetWeapons() != old_count ) then

				for _, weapon in ipairs( client:GetWeapons() ) do

					if ( !weapon.Equipableitem && !weapon.UnDroppable && !table.HasValue( EQHUD.weps, weapon ) ) then

						EQHUD.weps[ #EQHUD.weps + 1 ] = weapon

					elseif ( weapon.Equipableitem && !table.HasValue( EQHUD.weps.Equipable, weapon ) ) then

						EQHUD.weps.Equipable[ #EQHUD.weps.Equipable + 1 ] = weapon

					elseif ( weapon.UnDroppable && !table.HasValue( EQHUD.weps.UndroppableItem, weapon ) ) then

						EQHUD.weps.UndroppableItem[ #EQHUD.weps.UndroppableItem + 1 ] = weapon

					end

				end

				old_count = #client:GetWeapons()

			end

		end

		draw.OutlinedBox( 0, 0, w, h, 2, color_white )

	end
	if !notvictim then
		local scrollpanel = vgui.Create("DScrollPanel", BREACH.Inventory)
		scrollpanel:SetSize(ScrW() * 0.15, ScrH() * 0.15)
		scrollpanel:SetPos(ScrW() * 0.2, ScrH() * 0.076)

		--Draw a background so we can see what it's doing
		scrollpanel:SetPaintBackground(true)
		scrollpanel:SetBackgroundColor(Color(0, 100, 100))

		--scrollpanel:Dock( FILL )

		scrollpanel.Paint = function(self, w, h)
			surface.SetDrawColor( color_white )
			surface.SetMaterial( frame )
			surface.DrawTexturedRect( 0, 0, w, h )
		end

		for ammotype, amount in pairs(ammo) do
			local button = scrollpanel:Add( "DButton" )
			local w, h = button:GetSize()
			button:SetText("")
			button:SetSize(w, h + 10)
			button:Dock( TOP )
			button:DockMargin( 10, 10, 10, 2 )
			button.AmmoType = ammotype
			button.Amount = amount
			button.Paint = function(self, w, h)
				if self:IsHovered() then
					draw.RoundedBox( 0, 0, 0, w, h, clrgreyinspect )
				else
					draw.RoundedBox( 0, 0, 0, w, h, clrgreyinspectdarker )
				end
				surface.SetDrawColor( color_white )
				surface.SetMaterial( frame )
				surface.DrawTexturedRect( -5, 0, w+10, h )
				local str = BREACH.TranslateString(BREACH.AmmoTranslation[game.GetAmmoName(ammotype)]) or game.GetAmmoName(ammotype)
				draw.SimpleText( str.." патроны", "BudgetNewSmall2", 5, 6, clrgreyinspect2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
				draw.SimpleText( str.." патроны", "BudgetNewSmall2", 4, 4, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			end

			local numberwang = vgui.Create("DNumberWang", button)
			local w, h = numberwang:GetSize()
			numberwang:SetSize(w-25, h)
			numberwang:SetPos(ScrW() * 0.11, ScrH() * 0.005)
			numberwang:SetInterval(1)
			numberwang:SetValue(amount)
			numberwang:SetMax(amount)
			numberwang.Paint = function(self, w, h)
				draw.RoundedBox( 0, 0, 0, w, h, clrgreyinspect )
				draw.SimpleText( self:GetValue(), "BudgetNewSmall2", 5, 3, clrgreyinspect2, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
				draw.SimpleText( self:GetValue(), "BudgetNewSmall2", 4, 1, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			end

			button.DoClick = function(self)
				if numberwang:GetValue() == 0 then
					return
				end

				if client:GetAmmoCount(ammotype) >= ammo_maxs[game.GetAmmoName(ammotype)] then
					RXSENDNotify("Вы больше не можете брать патроны для данного типа оружия. Достигнут лимит.")
					return
				end

				local too_big = false
				if client:GetAmmoCount(ammotype) + numberwang:GetValue() > ammo_maxs[game.GetAmmoName(ammotype)] then
					local result = ammo_maxs[game.GetAmmoName(ammotype)] - client:GetAmmoCount(ammotype)

					numberwang:SetMax(self.Amount - result)
					numberwang:SetValue(result)
					RXSENDNotify("Вы больше не можете брать патроны для данного типа оружия. Достигнут лимит.")
					too_big = result
				end


				net.Start("LC_TakeAmmo", true)
					net.WriteEntity(LocalPlayer():GetEyeTrace().Entity)
					net.WriteUInt(self.AmmoType, 16)
					net.WriteUInt(too_big or numberwang:GetValue(), 16)
				net.SendToServer()
				if !too_big then
					numberwang:SetMax(self.Amount - numberwang:GetValue())
					numberwang:SetValue(0)
				end
			end
		end
	end

	BREACH.Inventory.Slot 				= {}
	BREACH.Inventory.Items 				= {}
	BREACH.Inventory.Model			 	= {}
	BREACH.Inventory.Clothes 			= {}
	BREACH.Inventory.Undroppable 	= {}

	if ( notvictim ) then

		local modelpanel_height = 188 * BetterScreenScale()

		BREACH.Inventory.Model = vgui.Create( "DPanel", BREACH.Inventory )
		BREACH.Inventory.Model:SetText( "" )
		BREACH.Inventory.Model:SetSize( 138 * BetterScreenScale(), modelpanel_height )
		BREACH.Inventory.Model:SetPos( BREACH.Inventory.Model:GetParent():GetSize() / 2 - 28, 64 )
		BREACH.Inventory.Model.Paint = function( self, w, h )

			surface.SetDrawColor( color_white )
			surface.SetMaterial( modelbackgroundmat )
			surface.DrawTexturedRect( 0, 0, w, h )

		end

		BREACH.Inventory.Model[ "Model" ] = vgui.Create( "DModelPanel", BREACH.Inventory.Model )
		BREACH.Inventory.Model[ "Model" ]:SetModel( "models/buildables/teleporter.mdl" )
		BREACH.Inventory.Model[ "Model" ]:SetPos( 0, 0 )
		BREACH.Inventory.Model[ "Model" ]:SetPaintedManually( false )
		BREACH.Inventory.Model[ "Model" ]:SetSize( 138 * BetterScreenScale(), modelpanel_height )

		if ( client:GetModel() ) then

			BREACH.Inventory.Model[ "Model" ].Entity:SetModel( client:GetModel() )
			BREACH.Inventory.Model[ "Model" ].Entity:SetSkin( client:GetSkin() )

			for _, v in ipairs( client:GetBodyGroups() ) do

				BREACH.Inventory.Model[ "Model" ].Entity:SetBodygroup( v.id, client:GetBodygroup( v.id ) )

			end

			BREACH.Inventory.Model[ "Model" ]:SetFOV( 40 )
			local obb = BREACH.Inventory.Model[ "Model" ].Entity:OBBCenter()

			if ( ents.FindByClassAndParent( "ent_bonemerged", client ) ) then

				local tbl_bonemerged = ents.FindByClassAndParent( "ent_bonemerged", client )
		
				for i = 1, #tbl_bonemerged do
			
					local bonemerge = tbl_bonemerged[ i ]
			
					if ( bonemerge && bonemerge:IsValid() ) then
						local submat = bonemerge:GetSubMaterial(0)
						if CORRUPTED_HEADS[bonemerge:GetModel()] then submat = bonemerge:GetSubMaterial(1) end
						BREACH.Inventory.Model[ "Model" ]:BoneMerged({bonemerge}, submat, bonemerge:GetInvisible())
						--[[
			
						local charav2 = vgui.Create( "DModelPanel", BREACH.Inventory.Model )
						charav2:SetSize(138 * BetterScreenScale(), modelpanel_height)
						charav2:SetPos(0, 0)
						charav2:SetModel( bonemerge:GetModel() )
						charav2:SetFOV( 40 )
						charav2:SetColor( color_white )
						function charav2:LayoutEntity( entity )
					
							entity:SetAngles(Angle(0,0,0))
							entity:SetParent(BREACH.Inventory.Model[ "Model" ].Entity)
							entity:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL))

							if ! (bonemerge && bonemerge:IsValid()) then return end
							entity:SetSkin(bonemerge:GetSkin())
			

					
						end
						local ent2 = charav2:GetEntity()
						if client:GTeam() != TEAM_SCP then
							charav2:SetLookAt( obb )
							charav2:SetCamPos( Vector( 0, ( modelpanel_height / 2 ) - ( ( obb.z / 2 ) * BetterScreenScale() ), obb.z + 5 ) )
						end
						--
					end
			
				end
			
			end

			local iSeq = BREACH.Inventory.Model["Model"].Entity:LookupSequence( "idle_all_01" )

			BREACH.Inventory.Model[ "Model" ]:SetCamPos( Vector( 0, ( modelpanel_height / 2 ) - ( ( obb.z / 2 ) * BetterScreenScale() ), obb.z + 5 ) )

			if ( iSeq > 0 ) then

				BREACH.Inventory.Model[ "Model" ].Entity:ResetSequence( iSeq )

			end

			BREACH.Inventory.Model[ "Model" ].__LayoutEntity = BREACH.Inventory.Model[ "Model" ].__LayoutEntity || BREACH.Inventory.Model[ "Model" ].LayoutEntity
			BREACH.Inventory.Model[ "Model" ].LayoutEntity = function( ent )

				BREACH.Inventory.Model[ "Model" ].Entity:SetAngles( angle_front )
				BREACH.Inventory.Model[ "Model" ].Entity:SetPos( Vector( 0, 0, -5 ) )
				BREACH.Inventory.Model[ "Model" ]:SetLookAt( obb )

			end

		end

		BREACH.Inventory.Model[ "Model" ].OutlinePanel = vgui.Create( "DPanel", BREACH.Inventory.Model[ "Model" ] )
		BREACH.Inventory.Model[ "Model" ].OutlinePanel:SetPos( 0, 0 )
		BREACH.Inventory.Model[ "Model" ].OutlinePanel:SetSize( BREACH.Inventory.Model[ "Model" ].OutlinePanel:GetParent():GetSize() )
		BREACH.Inventory.Model[ "Model" ].OutlinePanel.Paint = function( self, w, h )

			surface.SetDrawColor( color_white )
			surface.SetMaterial( frame )
			surface.DrawTexturedRect( 0, 0, w, h )

		end

	end

	for i = 1, 8 do

		if ( i > 1 && i < 5 ) then

			local oldposx = BREACH.Inventory.Slot[ i - 1 ]:GetPos()
			local oldsize = BREACH.Inventory.Slot[ i - 1 ]:GetSize()

			BREACH.Inventory.Slot[ i ] = vgui.Create( "DButton", BREACH.Inventory )
			BREACH.Inventory.Slot[ i ]:SetText( "" )
			BREACH.Inventory.Slot[ i ]:SetPos( oldposx + ( oldsize * 1.5 ), 264 )
			BREACH.Inventory.Slot[ i ]:SetSize( 96 * BetterScreenScale(), 96 * BetterScreenScale() )
			BREACH.Inventory.Slot[ i ].DoClick = function( self )

				if ( !EQHUD.weps ) then return end

				if ( notvictim && EQHUD.weps[ i ] && EQHUD.weps[ i ]:IsValid() ) then

					if ( EQHUD.weps[ i ] && EQHUD.weps[ i ]:IsValid() && isstring( EQHUD.weps[ i ]:GetClass() ) ) then

						client:SelectWeapon( EQHUD.weps[ i ]:GetClass() )

					end

				elseif ( EQHUD.weps[ i ] && !notvictim ) then

					for _, weapons in ipairs( client:GetWeapons() ) do

						if ( weapons.CW20Weapon && EQHUD.weps[ i ].ClassName:find( "cw" ) ) then

							if ( weapons.Primary.Ammo == EQHUD.weps[ i ].Primary.Ammo ) then

								RXSENDNotify( "У Вас уже есть данный тип оружия." )

								return
							end

						end

					end

					if ( client:HasWeapon( EQHUD.weps[ i ].ClassName ) ) then

						RXSENDNotify( "У Вас уже есть этот предмет." )
						return
					end

					TakeWep(client:GetEyeTrace().Entity, EQHUD.weps[ i ].ClassName)

					EQHUD.weps[ i ] = nil

				end

			end

			BREACH.Inventory.Slot[ i ].DoRightClick = function( self )

				if ( !notvictim ) then return end

				if ( EQHUD.weps[ i ] && EQHUD.weps[ i ]:IsValid() ) then

					client:DropWeapon( EQHUD.weps[ i ]:GetClass() )
					if ( SERVER ) then

						net.Start( "DropAnimation", true )
						net.Send( client )

					end

					EQHUD.weps[ i ] = nil

				end

			end

			BREACH.Inventory.Slot[ i ].Paint = function( self, w, h )

				if ( EQHUD.weps[ i ] ) then

					if ( notvictim ) then

						local weapon = EQHUD.weps[ i ]
						if ( weapon:IsValid() ) then

							surface.SetDrawColor( color_white )
							surface.SetMaterial( weapon.InvIcon || missing )
							surface.DrawTexturedRect( 0, 0, w, h )

						end

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

						if ( weapon == LocalPlayer():GetActiveWeapon() ) then

							draw.OutlinedBox( 0, 0, w, h, 2, clr_green )

						end

						if ( BREACH.Inventory.SelectedID == i ) then

							draw.OutlinedBox( 0, 0, w, h, 2, ColorAlpha( color_black, 210 * math.abs( math.sin( RealTime() * 2 ) ) ) )

						end

					else

						surface.SetDrawColor( color_white )
						surface.SetMaterial( EQHUD.weps[ i ].InvIcon || missing )
						surface.DrawTexturedRect( 0, 0, w, h )

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

					end

				else

					surface.SetDrawColor( color_white )
					surface.SetMaterial( frame )
					surface.DrawTexturedRect( 0, 0, w, h )

				end

			end

			BREACH.Inventory.Slot[ i ].OnCursorEntered = function( self )

				if ( EQHUD.weps[ i ] ) then

					if ( notvictim && EQHUD.weps[ i ]:IsValid() ) then

						DrawInspectWindow( EQHUD.weps[ i ], nil, i )

					else

						DrawInspectWindow( EQHUD.weps[ i ], nil, i )

					end

				end

			end

			BREACH.Inventory.Slot[ i ].OnCursorExited = function( self )

				if ( IsValid( BREACH.Inventory.InspectWindow ) ) then

					BREACH.Inventory.InspectWindow:Remove()

				end

			end

		elseif ( i > 5 ) then

			local oldposx = BREACH.Inventory.Slot[ i - 1 ]:GetPos()
			local oldsize = BREACH.Inventory.Slot[ i - 1 ]:GetSize()

			BREACH.Inventory.Slot[ i ] = vgui.Create( "DButton", BREACH.Inventory )
			BREACH.Inventory.Slot[ i ]:SetText( "" )
			BREACH.Inventory.Slot[ i ]:SetPos( oldposx + ( oldsize * 1.5 ), 264 + 124 )
			BREACH.Inventory.Slot[ i ]:SetSize( 96 * BetterScreenScale(), 96 * BetterScreenScale() )

			BREACH.Inventory.Slot[ i ].DoClick = function( self )

				if ( notvictim && EQHUD.weps[i] && EQHUD.weps[ i ]:IsValid() ) then

					client:SelectWeapon( EQHUD.weps[i]:GetClass() )

				elseif ( EQHUD.weps[ i ] && !notvictim ) then

					for _, weapons in ipairs( client:GetWeapons() ) do

						if ( weapons.CW20Weapon && EQHUD.weps[ i ].ClassName:find( "cw" ) && weapons.Primary.Ammo == EQHUD.weps[ i ].Primary.Ammo ) then

							BREACH.Player:ChatPrint( true, true, "У Вас уже есть данный тип оружия." )

							return

						end

					end

					if ( client:HasWeapon( EQHUD.weps[ i ].ClassName ) ) then

						BREACH.Player:ChatPrint( true, true, "У Вас уже есть этот предмет." )
						return
					end

					TakeWep(client:GetEyeTrace().Entity, EQHUD.weps[ i ].ClassName)

					EQHUD.weps[i] = nil

				end

			end

			BREACH.Inventory.Slot[ i ].DoRightClick = function( self )

				if ( !notvictim ) then return end
				if ( EQHUD.weps[ i ] && EQHUD.weps[ i ]:IsValid() ) then

					client:DropWeapon( EQHUD.weps[ i ]:GetClass() )
					if ( SERVER ) then

						net.Start( "DropAnimation", true )
						net.Send( client )

					end

					EQHUD.weps[ i ] = nil

				end

			end

			BREACH.Inventory.Slot[ i ].Paint = function( self, w, h )

				--draw.RoundedBoxEx( 2, 0, 0, w, h, color_black, false, false, false, false )
				if ( EQHUD.weps[ i ] ) then

					if ( notvictim ) then

						local weapon = EQHUD.weps[ i ]
						if ( weapon && weapon:IsValid() ) then

							surface.SetDrawColor( color_white )
							surface.SetMaterial( weapon.InvIcon || missing )
							surface.DrawTexturedRect( 0, 0, w, h )

						end

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

						if ( weapon == LocalPlayer():GetActiveWeapon() ) then

							draw.OutlinedBox( 0, 0, w, h, 2, clr_green )

						end

						if ( BREACH.Inventory.SelectedID == i ) then

							draw.OutlinedBox( 0, 0, w, h, 2, ColorAlpha( color_black, 210 * math.abs( math.sin( RealTime() * 2 ) ) ) )

						end

					else

						surface.SetDrawColor( color_white )
						surface.SetMaterial( EQHUD.weps[ i ].InvIcon || missing )
						surface.DrawTexturedRect( 0, 0, w, h )

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

					end

				else

					surface.SetDrawColor( color_white )
					surface.SetMaterial( frame )
					surface.DrawTexturedRect( 0, 0, w, h )

				end

			end

			BREACH.Inventory.Slot[ i ].OnCursorEntered = function( self )

				if ( EQHUD.weps[ i ] ) then

					if ( notvictim ) then

						if ( EQHUD.weps[ i ]:IsValid() ) then

							DrawInspectWindow( EQHUD.weps[ i ], nil, i )

						end

					else

						DrawInspectWindow( EQHUD.weps[ i ], nil, i )

					end

				end

			end

			BREACH.Inventory.Slot[ i ].OnCursorExited = function( self )

				if ( IsValid( BREACH.Inventory.InspectWindow ) ) then

					BREACH.Inventory.InspectWindow:Remove()

				end

			end

		end

		if ( i == 1 ) then

			BREACH.Inventory.Slot[i] = vgui.Create( "DButton", BREACH.Inventory )
			BREACH.Inventory.Slot[i]:SetText( "" )
			BREACH.Inventory.Slot[i]:SetPos( 68, 264 )
			BREACH.Inventory.Slot[i]:SetSize( 96 * BetterScreenScale(), 96 * BetterScreenScale() )
			BREACH.Inventory.Slot[i].DoClick = function( self )

				if ( notvictim && EQHUD.weps[ i ] && EQHUD.weps[ i ]:IsValid() ) then

					client:SelectWeapon( EQHUD.weps[ i ]:GetClass() )

				elseif ( EQHUD.weps[i] && !notvictim ) then

					for _, weapons in ipairs( client:GetWeapons() ) do

						if ( weapons.CW20Weapon && EQHUD.weps[ i ].ClassName:find( "cw" ) ) then

							if ( weapons.Primary.Ammo == EQHUD.weps[ i ].Primary.Ammo ) then

								BREACH.Player:ChatPrint( true, true, "У Вас уже есть данный тип оружия." )

								return
							end

						end

					end

					if ( client:HasWeapon( EQHUD.weps[i].ClassName ) ) then return end
                    
                    --[[

					client.JustSpawned = true

					client:Give( EQHUD.weps[ i ]:GetClass() )
	
					timer.Simple( 0.1, function()
						client.JustSpawned = false
					end)
                    TakeWep(client:GetEyeTrace().Entity, EQHUD.weps[ i ].ClassName)

					EQHUD.weps[i] = nil

				end

			end
			BREACH.Inventory.Slot[i].Paint = function( self, w, h )

				--draw.RoundedBoxEx( 2, 0, 0, w, h, color_black, false, false, false, false )

				if ( EQHUD.weps[ i ] ) then

					if ( notvictim ) then

						local weapon = EQHUD.weps[ i ]
						if ( weapon && weapon:IsValid() ) then

							surface.SetDrawColor( color_white )
							surface.SetMaterial( weapon.InvIcon || missing )
							surface.DrawTexturedRect( 0, 0, w, h )

						end

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

						if ( weapon == LocalPlayer():GetActiveWeapon() ) then

							draw.OutlinedBox( 0, 0, w, h, 2, clr_green )

						end

						if ( BREACH.Inventory.SelectedID == i ) then

							draw.OutlinedBox( 0, 0, w, h, 2, ColorAlpha( color_black, 210 * math.abs( math.sin( RealTime() * 2 ) ) ) )

						end

					else

						surface.SetDrawColor( color_white )
						surface.SetMaterial( EQHUD.weps[ i ].InvIcon || missing )
						surface.DrawTexturedRect( 0, 0, w, h )

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

					end

				else

					surface.SetDrawColor( color_white )
					surface.SetMaterial( frame )
					surface.DrawTexturedRect( 0, 0, w, h )

				end

			end

			BREACH.Inventory.Slot[ i ].DoRightClick = function( self )

				if ( !notvictim ) then return end
				if ( EQHUD.weps[ i ] && EQHUD.weps[ i ]:IsValid() ) then

					client:DropWeapon( EQHUD.weps[ i ]:GetClass() )
					if ( SERVER ) then

						net.Start( "DropAnimation", true )
						net.Send( client )

					end

					EQHUD.weps[ i ] = nil

				end

			end

			BREACH.Inventory.Slot[ i ].OnCursorEntered = function( self )

				if ( EQHUD.weps[ i ] ) then

					if ( notvictim ) then

						if ( EQHUD.weps[ i ]:IsValid() ) then

							DrawInspectWindow( EQHUD.weps[ i ], nil, i )

						end

					else

						DrawInspectWindow( EQHUD.weps[ i ], nil, i )

					end

				end

			end

			BREACH.Inventory.Slot[ i ].OnCursorExited = function( self )

				if ( IsValid( BREACH.Inventory.InspectWindow ) ) then

					BREACH.Inventory.InspectWindow:Remove()

				end

			end

		elseif ( i == 5 ) then

			BREACH.Inventory.Slot[i] = vgui.Create( "DButton", BREACH.Inventory )
			BREACH.Inventory.Slot[i]:SetText( "" )
			BREACH.Inventory.Slot[i]:SetPos( 68, 264 + 124 )
			BREACH.Inventory.Slot[i]:SetSize( 96 * BetterScreenScale(), 96 * BetterScreenScale() )
			BREACH.Inventory.Slot[i].DoClick = function( self )

				if ( notvictim && EQHUD.weps[ i ] && EQHUD.weps[ i ]:IsValid() ) then

					client:SelectWeapon( EQHUD.weps[ i ]:GetClass() )

				elseif ( EQHUD.weps[ i ] && !notvictim ) then

					for _, weapons in ipairs( client:GetWeapons() ) do

						if ( weapons.CW20Weapon && EQHUD.weps[ i ].ClassName:find( "cw" ) ) then

							if ( weapons.Primary.Ammo == EQHUD.weps[ i ].Primary.Ammo ) then

								BREACH.Player:ChatPrint( true, true, "У Вас уже есть данный тип оружия." )

								return
							end

						end

					end

					if ( client:HasWeapon( EQHUD.weps[ i ].ClassName ) ) then return end

					--client:Give( EQHUD.weps[i]:GetClass() )
					 TakeWep(client:GetEyeTrace().Entity, EQHUD.weps[ i ].ClassName)--TakeWep(nil, EQHUD.weps[i])

					EQHUD.weps[i] = nil

				end

			end

			BREACH.Inventory.Slot[ i ].DoRightClick = function( self )

				if ( !notvictim ) then return end
				if ( EQHUD.weps[ i ] && EQHUD.weps[ i ]:IsValid() ) then

					client:DropWeapon( EQHUD.weps[ i ]:GetClass() )
					if ( SERVER ) then

						net.Start( "DropAnimation", true )
						net.Send( client )

					end

					EQHUD.weps[ i ] = nil

				end

			end

			BREACH.Inventory.Slot[ i ].Paint = function( self, w, h )

				--draw.RoundedBoxEx( 2, 0, 0, w, h, boxclr2, false, false, false, false )

				if ( EQHUD.weps[ i ] ) then

					if ( notvictim ) then

						local weapon = EQHUD.weps[ i ]
						if ( weapon && weapon:IsValid() ) then

							surface.SetDrawColor( color_white )
							surface.SetMaterial( weapon.InvIcon || missing )
							surface.DrawTexturedRect( 0, 0, w, h )

						end

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

						if ( weapon == LocalPlayer():GetActiveWeapon() ) then

							draw.OutlinedBox( 0, 0, w, h, 2, clr_green )

						end

						if ( BREACH.Inventory.SelectedID == i ) then

							draw.OutlinedBox( 0, 0, w, h, 2, ColorAlpha( color_black, 210 * math.abs( math.sin( RealTime() * 2 ) ) ) )

						end

					else

						surface.SetDrawColor( color_white )
						surface.SetMaterial( EQHUD.weps[ i ].InvIcon || missing )
						surface.DrawTexturedRect( 0, 0, w, h )

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

					end

				else

					surface.SetDrawColor( color_white )
					surface.SetMaterial( frame )
					surface.DrawTexturedRect( 0, 0, w, h )

				end

				if ( client:GetMaxSlots() < i ) then

					draw.RoundedBoxEx( 2, 0, 0, w, h, boxclr, false, false, false, false )

				end

			end

			BREACH.Inventory.Slot[ i ].OnCursorEntered = function( self )

				if ( EQHUD.weps[ i ] ) then

					if ( notvictim ) then

						if ( EQHUD.weps[ i ]:IsValid() ) then

							DrawInspectWindow( EQHUD.weps[ i ], nil, i )

						end

					else

						DrawInspectWindow( EQHUD.weps[ i ], nil, i )

					end

				end

			end

			BREACH.Inventory.Slot[ i ].OnCursorExited = function( self )

				if ( IsValid( BREACH.Inventory.InspectWindow ) ) then

					BREACH.Inventory.InspectWindow:Remove()

				end

			end

		end

	end


	for i = 1, 4 do

		if ( i <= 2 ) then

			local oldposx = BREACH.Inventory.Slot[ 4 ]:GetPos()
			local oldsize = BREACH.Inventory.Slot[ 4 ]:GetSize()

			BREACH.Inventory.Slot[ 8 + i ] = vgui.Create( "DButton", BREACH.Inventory )
			BREACH.Inventory.Slot[ 8 + i ]:SetText( "" )
			BREACH.Inventory.Slot[ 8 + i ]:SetPos( oldposx + ( ( oldsize * 1.5 ) * i ), 264 )
			BREACH.Inventory.Slot[ 8 + i ]:SetSize( 96 * BetterScreenScale(), 96 * BetterScreenScale() )
			BREACH.Inventory.Slot[ 8 + i ].DoClick = function( self )

				if ( notvictim && EQHUD.weps[ 8 + i ] && EQHUD.weps[ 8 + i ]:IsValid() ) then

					client:SelectWeapon( EQHUD.weps[8 + i]:GetClass() )

				elseif ( EQHUD.weps[8 + i] && !notvictim ) then

					for _, weapons in ipairs( client:GetWeapons() ) do

						if ( weapons.CW20Weapon && EQHUD.weps[ 8 + i ].ClassName:find( "cw" ) ) then

							if ( weapons.Primary.Ammo == EQHUD.weps[ 8 + i ].PrimaryAmmo ) then

								BREACH.Player:ChatPrint( true, true, "У Вас уже есть данный тип оружия." )

								return
							end

						end

					end

					if ( client:HasWeapon( EQHUD.weps[ 8 + i ].ClassName ) ) then

						BREACH.Player:ChatPrint( true, true, "У Вас уже есть этот предмет." )
						return
					end

					client.JustSpawned = true

					client:Give( EQHUD.weps[ 8 + i ]:GetClass() )
	
					timer.Simple( 0.1, function()
						client.JustSpawned = false
					end)

					EQHUD.weps[8 + i] = nil

				end

			end

			BREACH.Inventory.Slot[ 8 + i ].Paint = function( self, w, h )

				if ( EQHUD.weps[ 8 + i ] ) then

					if ( notvictim ) then

						local weapon = EQHUD.weps[ 8 + i ]
						if ( weapon && weapon:IsValid() ) then

							surface.SetDrawColor( color_white )
							surface.SetMaterial( weapon.InvIcon || missing )
							surface.DrawTexturedRect( 0, 0, w, h )

						end

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

						if ( weapon == LocalPlayer():GetActiveWeapon() ) then

							draw.OutlinedBox( 0, 0, w, h, 2, clr_green )

						end

						if ( BREACH.Inventory.SelectedID == i ) then

							draw.OutlinedBox( 0, 0, w, h, 2, ColorAlpha( color_black, 210 * math.abs( math.sin( RealTime() * 2 ) ) ) )

						end

					else

						surface.SetDrawColor( color_white )
						surface.SetMaterial( EQHUD.weps[ 8 + i ].InvIcon || missing )
						surface.DrawTexturedRect( 0, 0, w, h )

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

					end

				else

					surface.SetDrawColor( color_white )
					surface.SetMaterial( frame )
					surface.DrawTexturedRect( 0, 0, w, h )

				end

				if ( client:GetMaxSlots() < 8 + i ) then

					draw.RoundedBoxEx( 2, 0, 0, w, h, boxclr, false, false, false, false )

				end

			end

			BREACH.Inventory.Slot[ 8 + i ].DoRightClick = function( self )

				if ( !notvictim ) then return end
				if ( EQHUD.weps[ 8 + i ] && EQHUD.weps[ 8 + i ]:IsValid() ) then

					client:DropWeapon( EQHUD.weps[ 8 + i ]:GetClass() )
					if ( SERVER ) then

						net.Start( "DropAnimation", true )
						net.Send( client )

					end

					EQHUD.weps[ 8 + i ] = nil

				end

			end

			BREACH.Inventory.Slot[ 8 + i ].OnCursorEntered = function( self )

				local i = 8 + i

				if ( EQHUD.weps[ i ] ) then

					if ( notvictim ) then

						if ( EQHUD.weps[ i ]:IsValid() ) then

							DrawInspectWindow( EQHUD.weps[ i ], nil, i )

						end

					else

						DrawInspectWindow( EQHUD.weps[ i ], nil, i )

					end

				end

			end

			BREACH.Inventory.Slot[ 8 + i ].OnCursorExited = function( self )

				if ( IsValid( BREACH.Inventory.InspectWindow ) ) then

					BREACH.Inventory.InspectWindow:Remove()

				end

			end

		else

			local oldposx = BREACH.Inventory.Slot[ 8 ]:GetPos()
			local oldsize = BREACH.Inventory.Slot[ 8 ]:GetSize()

			BREACH.Inventory.Slot[ 8 + i ] = vgui.Create( "DButton", BREACH.Inventory )
			BREACH.Inventory.Slot[ 8 + i ]:SetText( "" )
			BREACH.Inventory.Slot[ 8 + i ]:SetPos( oldposx + ( ( oldsize * 1.5 ) * ( i - 2 ) ), 264 + 124 )
			BREACH.Inventory.Slot[ 8 + i ]:SetSize( 96 * BetterScreenScale(), 96 * BetterScreenScale() )
			BREACH.Inventory.Slot[ 8 + i ].DoClick = function( self )

				local i = 8 + i

				if ( notvictim && EQHUD.weps[ i ] && EQHUD.weps[ i ] ) then

					client:SelectWeapon( EQHUD.weps[ i ]:GetClass() )

				elseif ( EQHUD.weps[ i ] && !notvictim ) then

					for _, weapons in ipairs( client:GetWeapons() ) do

						if ( weapons.CW20Weapon && EQHUD.weps[ i ].ClassName:find( "cw" ) ) then

							if ( weapons.Primary.Ammo == EQHUD.weps[ i ].Primary.Ammo ) then

								BREACH.Player:ChatPrint( true, true, "У Вас уже есть данный тип оружия." )

								return
							end

						end

					end

					if ( client:HasWeapon( EQHUD.weps[ i ].ClassName ) ) then

						BREACH.Player:ChatPrint( true, true, "У Вас уже есть этот предмет." )
						return
					end

					client.JustSpawned = true

					client:Give( EQHUD.weps[ i ] )
	
					timer.Simple( 0.1, function()
						client.JustSpawned = false
					end)

					EQHUD.weps[ i ] = nil

				end

			end

			BREACH.Inventory.Slot[ 8 + i ].DoRightClick = function( self )

				if ( !notvictim ) then return end
				if ( EQHUD.weps[ 8 + i ] && EQHUD.weps[ 8 + i ]:IsValid() ) then

					client:DropWeapon( EQHUD.weps[ 8 + i ]:GetClass() )
					if ( SERVER ) then

						net.Start( "DropAnimation", true )
						net.Send( client )

					end

					EQHUD.weps[ 8 + i ] = nil

				end

			end

			BREACH.Inventory.Slot[ 8 + i ].Paint = function( self, w, h )

				local i = 8 + i

				if ( EQHUD.weps[ i ] ) then

					if ( notvictim ) then

						local weapon = EQHUD.weps[ i ]
						if ( weapon && weapon:IsValid() ) then

							surface.SetDrawColor( color_white )
							surface.SetMaterial( weapon.InvIcon || missing )
							surface.DrawTexturedRect( 0, 0, w, h )

						end

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

						if ( weapon == LocalPlayer():GetActiveWeapon() ) then

							draw.OutlinedBox( 0, 0, w, h, 2, clr_green )

						end

						if ( BREACH.Inventory.SelectedID == i ) then

							draw.OutlinedBox( 0, 0, w, h, 2, ColorAlpha( color_black, 210 * math.abs( math.sin( RealTime() * 2 ) ) ) )

						end

					else

						surface.SetDrawColor( color_white )
						surface.SetMaterial( EQHUD.weps[ i ].InvIcon || missing )
						surface.DrawTexturedRect( 0, 0, w, h )

						surface.SetDrawColor( color_white )
						surface.SetMaterial( frame )
						surface.DrawTexturedRect( 0, 0, w, h )

					end

				else

					surface.SetDrawColor( color_white )
					surface.SetMaterial( frame )
					surface.DrawTexturedRect( 0, 0, w, h )

				end

				if ( client:GetMaxSlots() < i ) then

					draw.RoundedBoxEx( 2, 0, 0, w, h, boxclr, false, false, false, false )

				end



			end

			BREACH.Inventory.Slot[ 8 + i ].OnCursorEntered = function( self )

				local i = 8 + i

				if ( EQHUD.weps[ i ] ) then

					if ( notvictim ) then

						if ( EQHUD.weps[ i ]:IsValid() ) then

							DrawInspectWindow( EQHUD.weps[ i ], nil, i )

						end

					else

						DrawInspectWindow( EQHUD.weps[ i ], nil, i )

					end

				end

			end

			BREACH.Inventory.Slot[ 8 + i ].OnCursorExited = function( self )

				if ( IsValid( BREACH.Inventory.InspectWindow ) ) then

					BREACH.Inventory.InspectWindow:Remove()

				end

			end

		end

	end

	for i = 1, 6 do -- Equipable items

		if ( i <= 2 ) then

			posy = 28

		elseif ( i >= 3 && i < 5 ) then

			posy = 100

		elseif ( i >= 5 ) then

			posy = 172

		end

		BREACH.Inventory.Items[i] = vgui.Create( "DButton", BREACH.Inventory )
		BREACH.Inventory.Items[i]:SetText( "" )
		BREACH.Inventory.Items[i]:SetSize( 64 * BetterScreenScale(), 64 * BetterScreenScale() )
		BREACH.Inventory.Items[i]:SetPos(  68 + ( 84 * ( i % 2 ) ), posy )
		BREACH.Inventory.Items[i].DoClick = function()

			if ( !EQHUD.weps.Equipable[i] ) then return end

			if ( EQHUD.weps.Equipable[i].ArmorType ) then 
				if EQHUD.weps.Equipable[i].ArmorType == "Armor" then
					net.Start("DropAdditionalArmor", true)
					net.WriteString(client:GetUsingArmor())
					net.SendToServer()
				end
				if EQHUD.weps.Equipable[i].ArmorType == "Hat" then
					net.Start("DropAdditionalArmor", true)
					net.WriteString(client:GetUsingHelmet())
					net.SendToServer()
				end
				if EQHUD.weps.Equipable[i].ArmorType == "Bag" then
					net.Start("DropAdditionalArmor", true)
					net.WriteString(client:GetUsingBag())
					net.SendToServer()
				end
				EQHUD.weps.Equipable[i] = nil
				return
			end
			if ( EQHUD.weps.Equipable[i] && notvictim ) then

				client:SelectWeapon( EQHUD.weps.Equipable[i]:GetClass() )

			elseif ( EQHUD.weps.Equipable[i] && !notvictim ) then

				if ( client:HasWeapon( EQHUD.weps.Equipable[i].ClassName ) ) then return end

				TakeWep( client:GetEyeTrace().Entity, EQHUD.weps.Equipable[i].ClassName )

				EQHUD.weps.Equipable[i] = nil

			end

		end
		BREACH.Inventory.Items[ i ].DoRightClick = function()
			if ( EQHUD.weps.Equipable[i] && notvictim && EQHUD.weps.Equipable[ i ].GetClass  ) then

				client:DropWeapon( EQHUD.weps.Equipable[ i ]:GetClass() )
				EQHUD.weps.Equipable[i] = nil

			end
		end

		BREACH.Inventory.Items[ i ].Paint = function( self, w, h )

			--draw.RoundedBoxEx( 2, 0, 0, w, h, color_black, false, false, false, false )

			if ( EQHUD.weps.Equipable && EQHUD.weps.Equipable[ i ] ) then

				if ( notvictim ) then

					local item = EQHUD.weps.Equipable[ i ]
					if ( item ) then

						surface.SetDrawColor( color_white )
						surface.SetMaterial( item.InvIcon || missing )
						surface.DrawTexturedRect( 0, 0, w, h )

					end

					surface.SetDrawColor( color_white )
					surface.SetMaterial( frame )
					surface.DrawTexturedRect( 0, 0, w, h )

					if ( item == LocalPlayer():GetActiveWeapon() ) then

						draw.OutlinedBox( 0, 0, w, h, 2, clr_green )

					end

					if ( BREACH.Inventory.SelectedID == 18 + i ) then

						draw.OutlinedBox( 0, 0, w, h, 2, ColorAlpha( color_black, 210 * math.abs( math.sin( RealTime() * 2 ) ) ) )

					end

				else

					surface.SetDrawColor( color_white )
					surface.SetMaterial( EQHUD.weps.Equipable[ i ].InvIcon || missing )
					surface.DrawTexturedRect( 0, 0, w, h )

					surface.SetDrawColor( color_white )
					surface.SetMaterial( frame )
					surface.DrawTexturedRect( 0, 0, w, h )

				end

			else

				surface.SetDrawColor( color_white )
				surface.SetMaterial( frame )
				surface.DrawTexturedRect( 0, 0, w, h )

			end

		end

		BREACH.Inventory.Items[ i ].OnCursorEntered = function( self )

			if ( EQHUD.weps.Equipable[ i ] ) then

				if ( notvictim ) then

					DrawInspectWindow( EQHUD.weps.Equipable[ i ], nil, 18 + i )

				else

					DrawInspectWindow( EQHUD.weps.Equipable[ i ], nil, 18 + i )

				end

			end

		end

		BREACH.Inventory.Items[ i ].OnCursorExited = function( self )

			if ( IsValid( BREACH.Inventory.InspectWindow ) ) then

				BREACH.Inventory.InspectWindow:Remove()

			end

		end

	end

	BREACH.Inventory.Clothes = vgui.Create( "DButton", BREACH.Inventory )
	BREACH.Inventory.Clothes:SetText( "" )
	BREACH.Inventory.Clothes:SetSize( 128 * BetterScreenScale(), 128 * BetterScreenScale() )
	BREACH.Inventory.Clothes:SetPos( BREACH.Inventory.Items[ 5 ]:GetPos() + 80 * BetterScreenScale(), 116 )
	BREACH.Inventory.Clothes.Paint = function( self, w, h )

		--draw.RoundedBoxEx( 2, 0, 0, w, h, color_black, false, false, false, false )

		local client = LocalPlayer()

		if ( client:GetUsingCloth() != "" ) then

			surface.SetDrawColor( color_white )
			surface.SetMaterial( scripted_ents.GetStored( client:GetUsingCloth() ).t.InvIcon || missing )
			surface.DrawTexturedRect( 0, 0, w, h )

			if ( self.Enable_Outline ) then

				draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( clr_red, 80 * math.abs( math.sin( RealTime() * 2 ) ) ) )

			end

		end

		surface.SetDrawColor( color_white )
		surface.SetMaterial( frame )
		surface.DrawTexturedRect( 0, 0, w, h )

		if ( self.Enable_Outline ) then

			draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( clr_red, 80 * math.abs( math.sin( RealTime() * 2 ) ) ) )

		end


	end
	BREACH.Inventory.Clothes.DoClick = function( self )

		net.Start( "DropCurrentVest", true )
		net.SendToServer()


	end

	BREACH.Inventory.Clothes.OnCursorEntered = function( self )

		if ( client:GetUsingCloth() != "" ) then

			DrawInspectWindow( nil, scripted_ents.GetStored( client:GetUsingCloth() ).t.PrintName.." ( Нажмите \"ЛКМ\" для снятия )" )

		end

	end

	BREACH.Inventory.Clothes.OnCursorExited = function( self )

		if ( IsValid( BREACH.Inventory.InspectWindow ) ) then

			BREACH.Inventory.InspectWindow:Remove()

		end

		self.Enable_Outline = nil

	end

	for i = 1, 6 do

		if ( i <= 2 ) then

			posy = 28

		elseif ( i <= 4 ) then

			posy = 100

		elseif ( i <= 6 ) then

			posy = 172

		end

		local oldsize = ( 64 * BetterScreenScale() )

		if ( BREACH.Inventory.Undroppable[ i - 1 ] ) then

			oldsize = BREACH.Inventory.Undroppable[ i - 1 ]:GetSize()

		end

		BREACH.Inventory.Undroppable[ i ] = vgui.Create( "DButton", BREACH.Inventory )
		BREACH.Inventory.Undroppable[ i ]:SetText( "" )
		BREACH.Inventory.Undroppable[ i ]:SetSize( 64 * BetterScreenScale(), 64 * BetterScreenScale() )
		BREACH.Inventory.Undroppable[ i ]:SetPos( ( BREACH.Inventory.Undroppable[ i ]:GetParent():GetSize() * .9 ) - oldsize - ( 84 * ( i % 2 ) ), posy )
		BREACH.Inventory.Undroppable[ i ].Paint = function( self, w, h )

			--draw.RoundedBoxEx( 2, 0, 0, w, h, color_black, false, false, false, false )

			if ( EQHUD.weps.UndroppableItem && EQHUD.weps.UndroppableItem[ i ] ) then

				if ( notvictim ) then

					local item = EQHUD.weps.UndroppableItem[ i ]
					if ( item:IsValid() ) then

						surface.SetDrawColor( color_white )
						surface.SetMaterial( item.InvIcon || missing )
						surface.DrawTexturedRect( 0, 0, w, h )

					end

					surface.SetDrawColor( color_white )
					surface.SetMaterial( frame )
					surface.DrawTexturedRect( 0, 0, w, h )

					if ( item == LocalPlayer():GetActiveWeapon() ) then

						draw.OutlinedBox( 0, 0, w, h, 2, clr_green )

					end

					if ( BREACH.Inventory.SelectedID == i + 12 ) then

						draw.OutlinedBox( 0, 0, w, h, 2, ColorAlpha( color_black, 210 * math.abs( math.sin( RealTime() * 2 ) ) ) )

					end

				else

					surface.SetDrawColor( color_white )
					surface.SetMaterial( EQHUD.weps.UndroppableItem[ i ].InvIcon || missing )
					surface.DrawTexturedRect( 0, 0, w, h )

					surface.SetDrawColor( color_white )
					surface.SetMaterial( frame )
					surface.DrawTexturedRect( 0, 0, w, h )

				end

			else

				surface.SetDrawColor( color_white )
				surface.SetMaterial( frame )
				surface.DrawTexturedRect( 0, 0, w, h )

			end

		end

		BREACH.Inventory.Undroppable[ i ].DoClick = function()

			if ( notvictim && EQHUD.weps.UndroppableItem[ i ] && EQHUD.weps.UndroppableItem[ i ]:IsValid() ) then

				client:SelectWeapon( EQHUD.weps.UndroppableItem[ i ]:GetClass() )

			end

			if !notvictim && EQHUD.weps.UndroppableItem[ i ].ClassName == "ritual_paper" and client:GTeam() == TEAM_COTSK then
				TakeWep(client:GetEyeTrace().Entity, EQHUD.weps.UndroppableItem[ i ].ClassName)

				EQHUD.weps.UndroppableItem[ i ] = nil
			end

		end

		BREACH.Inventory.Undroppable[ i ].OnCursorEntered = function( self )

			if ( EQHUD.weps.UndroppableItem[ i ] ) then

				if ( notvictim ) then

					if ( EQHUD.weps.UndroppableItem[ i ]:IsValid() ) then

						DrawInspectWindow( EQHUD.weps.UndroppableItem[ i ], nil, i + 12 )

					end

				else

					DrawInspectWindow( EQHUD.weps.UndroppableItem[ i ], nil, i + 12 )

				end

			end

		end

		BREACH.Inventory.Undroppable[ i ].OnCursorExited = function( self )

			if ( BREACH.Inventory.InspectWindow ) then

				BREACH.Inventory.InspectWindow:Remove()

			end

		end

	end]]

end

--[[function DrawEQ()

	if ( !EQHUD.enabled ) then return end

end
hook.Add( "DrawOverlay", "DrawEQ", DrawEQ )]]

function ShowEQ( notlottable, vtab, ammo )

	local client = LocalPlayer()

	if ( client.StartEffect || client.MovementLocked && !vtab ) then return end

	if ( client:IsFrozen() ) then return end

	if ( cdforuse > CurTime() && !vtab ) then return end

	EQHUD.enabled = true
	gui.EnableScreenClicker( true )

	EQHUD.weps = {}
	EQHUD.weps.Equipable = {}
	EQHUD.weps.UndroppableItem = {}

	if ( !notlottable ) then

		for _, weapon in pairs( vtab.Weapons ) do

			weapon = weapons.GetStored( weapon )
			if !weapon then
				continue
			end
			if ( !weapon.Equipableitem && !weapon.UnDroppable ) then

				EQHUD.weps[ #EQHUD.weps + 1 ] = weapon

			elseif ( weapon.Equipableitem ) then

				EQHUD.weps.Equipable[ #EQHUD.weps.Equipable + 1 ] = weapon

			elseif ( weapon.UnDroppable ) then

				EQHUD.weps.UndroppableItem[ #EQHUD.weps.UndroppableItem + 1 ] = weapon

			end

		end

	else
		
		if ( client:GetUsingHelmet() != "" ) then

			EQHUD.weps.Equipable[ #EQHUD.weps.Equipable + 1 ] = scripted_ents.GetStored( client:GetUsingHelmet() ).t

		end

		if ( client:GetUsingArmor() != "" ) then

			EQHUD.weps.Equipable[ #EQHUD.weps.Equipable + 1 ] = scripted_ents.GetStored( client:GetUsingArmor() ).t

		end

		if ( client:GetUsingBag() != "" ) then

			EQHUD.weps.Equipable[ #EQHUD.weps.Equipable + 1 ] = scripted_ents.GetStored( client:GetUsingBag() ).t

		end

		for _, weapon in ipairs( client:GetWeapons() ) do

			if ( !weapon.Equipableitem && !weapon.UnDroppable ) then

				EQHUD.weps[ #EQHUD.weps + 1 ] = weapon

			elseif ( weapon.Equipableitem ) then

				EQHUD.weps.Equipable[ #EQHUD.weps.Equipable + 1 ] = weapon

			elseif ( weapon.UnDroppable and weapon:GetClass() != "item_special_document" ) then

				EQHUD.weps.UndroppableItem[ #EQHUD.weps.UndroppableItem + 1 ] = weapon

			end

		end

	end

	DrawNewInventory( notlottable, vtab, ammo )

end

function HideEQ( open_inventory )

	if ( !open_inventory ) then

		cdforuse = CurTime() + cdforusetime

	end

	EQHUD.enabled = false
	gui.EnableScreenClicker( false )

	if ( IsValid( BREACH.Inventory ) ) then

		BREACH.Inventory:Remove()

	end

	if ( open_inventory ) then

		net.Start( "ShowEQAgain", true )
		net.SendToServer()

	else

		local client = LocalPlayer()

		if ( client.MovementLocked && !client.AttackedByBor ) then

			net.Start( "LootEnd", true )
			net.SendToServer()

			client.MovementLocked = nil

		end

	end

end

function CanShowEQ()

	local client = LocalPlayer()

	local t = client:GTeam()

	return t != TEAM_SPEC && (t != TEAM_SCP or client.SCP035_IsWear) && client:Alive() && client:GetMoveType() != MOVETYPE_OBSERVER

end

function IsEQVisible()

	return EQHUD.enabled

end

function mply:HaveSpecialAb(rolename)
	for i, v in pairs(BREACH_ROLES) do
		if i == "SCP" or i == "OTHER" then continue end
		for _, group in pairs(v) do
			for _, role in pairs(group.roles) do
				if role.name != rolename then continue end
				if !role["ability"] then continue end
				if self:GetNWString("AbilityName") == role["ability"][1] then return true end
			end
		end
	end
	return false
end

hook.Add( "PlayerButtonDown", "Specials", function( ply, button )

	if ( SERVER and button == ply.specialability ) or ( CLIENT and button == GetConVar("breach_config_useability"):GetInt() ) then

		if ply:GetSpecialCD() > CurTime() then return end

		if ply:IsFrozen() then return end

		if ply.MovementLocked == true then return end

		if ply:HaveSpecialAb(role.Goc_Special) then

			if SERVER then

				if !ply.TempValues.UsedTeleporter then

					ply:SetSpecialCD(CurTime() + 3)

					if ply:GetPos():WithinAABox(Vector(-9240.0830078125, -1075.4862060547, 2639.8430175781), Vector(-12292.916015625, 1553.1733398438, 1209.9250488281)) then return end

					ply.TempValues.UsedTeleporter = true

					if !ply:IsOnGround() then
						ply:SetSpecialCD(CurTime() + 5)
						return
					end

					local teleporter = ents.Create("ent_goc_teleporter")
					teleporter:SetOwner(ply)
					teleporter:SetPos(ply:GetPos() + Vector(0,0,3))
					teleporter:Spawn()

					ply.teleporterentity = teleporter

				elseif IsValid(ply.teleporterentity) then

					ply:SetSpecialCD(CurTime() + 45)

					BroadcastLua("ParticleEffectAttach(\"mr_portal_1a\", PATTACH_POINT_FOLLOW, Entity("..ply:EntIndex().."), Entity("..ply:EntIndex().."):LookupAttachment(\"waist\"))")

					net.Start("ThirdPersonCutscene2", true)
					net.WriteUInt(2, 4)
					net.WriteBool(false)
					net.Send(ply)
					ply:SetMoveType(MOVETYPE_OBSERVER)

					ply:EmitSound("nextoren/others/introfirstshockwave.wav", 115, 100, 1.4)
					ply:ScreenFade(SCREENFADE.OUT, color_white, 1.4, 1)

					timer.Create("goc_special_teleport"..ply:SteamID64(), 2, 1, function()
						ply:ScreenFade(SCREENFADE.IN, color_white, 2, 0.3)
						ply:StopParticles()
						ply:SetMoveType(MOVETYPE_WALK)
						ply:SetPos(ply.teleporterentity:GetPos())
					end)

					ply:SetForcedAnimation("MPF_Deploy")

				end

			end

		elseif ply:HaveSpecialAb(role.UIU_Agent_Specialist) then

			ply:SetSpecialCD(CurTime() + 90)

			if CLIENT then return end

			local grenade = ents.Create("cw_uiu_wh_grenade")
			grenade:SetPos(ply:GetShootPos())
			grenade:Spawn()
			grenade:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

			local phy = grenade:GetPhysicsObject()

			if IsValid(phy) then
				local vel = Vector(0, 0, 200)

				phy:SetVelocity(ply:GetAimVector() * 750 + ply:GetVelocity() + vel)
				phy:SetAngleVelocity(Vector(500, 200, 0))
				phy:SetBuoyancyRatio(1)
			end

			timer.Simple(11, function()
				if IsValid(grenade) then
					grenade:EmitSound("^rxsend/wh_uiu_grenade/gren_explode.ogg")
					grenade:Remove()
				end
			end)

		elseif ply:HaveSpecialAb(role.UIU_Commander) then

			ply:SetSpecialCD(CurTime() + 90)

			if CLIENT then return end

			local grenade = ents.Create("cw_smoke_912")
			grenade:SetPos(ply:GetShootPos())
			grenade:Spawn()
			grenade:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

			local phy = grenade:GetPhysicsObject()

			if IsValid(phy) then
				local vel = Vector(0, 0, 200)

				phy:SetVelocity(ply:GetAimVector() * 750 + ply:GetVelocity() + vel)
				phy:SetAngleVelocity(Vector(500, 200, 0))
				phy:SetBuoyancyRatio(1)
			end

		elseif ply:HaveSpecialAb(role.ClassD_Thief) then

			if CLIENT then return end
			ply:LagCompensation(true)
			local DASUKADAIMNEEGO = util.TraceLine( {
				start = ply:GetShootPos(),
				endpos = ply:GetShootPos() + ply:GetAimVector() * 130,
				filter = ply
			} )
			ply:LagCompensation(false)
			local target = DASUKADAIMNEEGO.Entity
			if !IsValid(target) or !target:IsPlayer() or target:GTeam() == TEAM_SCP then
				ply:RXSENDNotify("l:thief_look_on_them")
				ply:SetSpecialCD(CurTime() + 5)
				return
			end

			if !IsValid(target:GetActiveWeapon()) or target:GetActiveWeapon().UnDroppable or target:GetActiveWeapon().droppable == false then
				ply:RXSENDNotify("l:thief_cant_steal")
				ply:SetSpecialCD(CurTime() + 5)
				return
			end

			if ply:GetPrimaryWeaponAmount() == ply:GetMaxSlots() then
				ply:RXSENDNotify("l:thief_need_slot")
				ply:SetSpecialCD(CurTime() + 5)
				return
			end

			if ply:HasWeapon(target:GetActiveWeapon():GetClass()) then
				ply:RXSENDNotify("l:thief_has_already")
				ply:SetSpecialCD(CurTime() + 5)
				return
			end

			local stealweapon = target:GetActiveWeapon()
			ply:BrProgressBar("l:stealing", 1.45, "nextoren/gui/special_abilities/ability_placeholder.png", target, false, function()
				if IsValid(stealweapon) and stealweapon:GetOwner() == target then
					target:ForceDropWeapon(stealweapon:GetClass())
					ply.Shaky_PICKUPWEAPON = stealweapon
					local physobj = stealweapon:GetPhysicsObject()
					stealweapon:SetNoDraw(true)
					if IsValid(physobj) then
						physobj:EnableMotion(false)
					end
					timer.Create("WEAPON_GIVE_THIEF_"..ply:UniqueID(), FrameTime(), 9999, function()
						if ply:HasWeapon(stealweapon:GetClass()) or ply:GTeam() == TEAM_SPEC or ply:Health() <= 0 then
							stealweapon:SetNoDraw(false)
							local physobj = stealweapon:GetPhysicsObject()
							if IsValid(physobj) then
								physobj:EnableMotion(true)
							end
							timer.Remove("WEAPON_GIVE_THIEF_"..ply:UniqueID())
							return
						end
						if !ply:HasWeapon(stealweapon:GetClass()) then
							stealweapon:SetPos(ply:GetPos())
						end
					end)
					stealweapon:SetPos(ply:GetPos())
					ply:SetSpecialCD(CurTime() + 45)
				end
			end)

		elseif ply:HaveSpecialAb(role.SCI_SpyUSA) then

			ply:SetSpecialCD(CurTime() + 7)

			if SERVER then
				if !ply.TempValues.SpyUSAINFO then
					ply:RXSENDNotify("l:spyusainfo")
					ply.TempValues.SpyUSAINFO = true
				end
				local all_documents = ents.FindByClass("item_special_document")

				local search_corpses = ents.FindByClass("prop_ragdoll")

				for i = 1, #search_corpses do

					local corpse = search_corpses[i]

					if corpse.vtable and corpse.vtable.Weapons and table.HasValue(corpse.vtable.Weapons, "item_special_document") then
						all_documents[#all_documents + 1] = corpse
						corpse:SetNWBool("HasDocument", true)
					end

				end

				for i = 1, #all_documents do

					local doc = all_documents[i]

					local location_color = color_white

					local location = "位置未知"
					if doc:IsLZ() then
						location = "在轻收区域"
						location_color = Color(0,153,230)
					elseif doc:Outside() then
						location = "在地表"
					elseif doc:IsEntrance() then
						location = "位于办公区"
						location_color = Color(230,153,0)
					elseif doc:IsHardZone() then
						location = "在重收"
						location_color = Color(100,100,100)
					end

					local dist = math.Round(doc:GetPos():Distance(ply:GetPos()) / 52.49, 1)
					local dist_clr_far = Color(0,255,0)
					local dist_clr_near = Color(230,153,0)
					local dist_clr_close = Color(255,0,0)

					local dist_clr = dist_clr_far
					if dist < 16 then
						dist_clr = dist_clr_close
					elseif dist < 60 then
						dist_clr = dist_clr_near
					end

					ply:RXSENDNotify("l:uiuspy_doc_dist_pt1 = ",dist_clr,dist.."m",color_white,", l:uiuspy_doc_dist_pt2 ",location_color,location)
				end
			end

		elseif ply:HaveSpecialAb(role.Chaos_Commander) then

			if ply:GetSpecialMax() == 0 then return end

			ply:SetSpecialCD(CurTime() + 4)

			maxs_chaos = Vector( 8, 2, 5 )

			local trace = {}

			trace.start = ply:GetShootPos()

			trace.endpos = trace.start + ply:GetAimVector() * 165

			trace.filter = ply

			trace.mins = -maxs_chaos

			trace.maxs = maxs_chaos
		
			trace = util.TraceHull( trace )
		
			local target = trace.Entity

			if ( target && target:IsValid() && target:IsPlayer() && target:Health() > 0 && (target:GetRoleName() == "CI Spy" or target:GTeam() == TEAM_CLASSD ) ) then
				if target:GetModel():find("goose") then return end 

				if target:GetModel() == "models/cultist/humans/chaos/chaos.mdl" or target:GetModel() == "models/cultist/humans/chaos/fat/chaos_fat.mdl" then 
					ply:RXSENDNotify("l:cicommander_conscripted_already")
					return 
				end

				if target:GetUsingCloth() != "" or (target:GetRoleName() == role.ClassD_Hitman and target:GetRoleName() == role.ClassD_LegHitman and !target:GetModel():find("class_d")) then
					ply:RXSENDNotify("l:cicommander_need_to_take_off_smth")
				end

				local count = 0

				for _, v in ipairs( target:GetWeapons() ) do
		
				  if ( !( v.UnDroppable || v.Equipableitem ) ) then
		
					count = count + 1
		
				  end
		
				end

				if ( ( count + 1 ) >= target:GetMaxSlots() ) then

					ply:RXSENDNotify("l:cicommander_no_slots")

					return

				end

				if SERVER then
					ply:BrProgressBar("l:giving_uniform", 8, "nextoren/gui/special_abilities/ability_placeholder.png")
				end

				old_target = target


				timer.Create("Chaos_Special_Recruiting_Check"..ply:SteamID(), 1, 8, function()

					if ply:GetEyeTrace().Entity != old_target then

						timer.Remove("Chaos_Special_Recruiting"..ply:SteamID())
						
						ply:ConCommand("stopprogress")

						timer.Remove("Chaos_Special_Recruiting_Check"..ply:SteamID())

					end

				end)

				timer.Create("Chaos_Special_Recruiting"..ply:SteamID(), 8, 1, function()

					if IsValid(ply) && IsValid(target) then

						local count = 0

						for _, v in ipairs( target:GetWeapons() ) do
				
						  if ( !( v.UnDroppable || v.Equipableitem ) ) then
				
							count = count + 1
				
						  end
				
						end

						if ( ( count + 1 ) >= target:GetMaxSlots() ) then

							ply:RXSENDNotify("l:cicommander_no_slots")

							return

						end

						ply:SetSpecialMax( ply:GetSpecialMax() - 1 )

						if SERVER then
							if target:GetRoleName() != role.ClassD_Fat then

								target:ClearBodyGroups()

							    target:SetModel("models/cultist/humans/chaos/chaos.mdl")

								target:SetBodygroup( 2, 1 )
								
								local hitgroup_head = target.ScaleDamage["HITGROUP_HEAD"]
								target.ScaleDamage = {

									["HITGROUP_HEAD"] = hitgroup_head,
									["HITGROUP_CHEST"] = 0.7,
									["HITGROUP_LEFTARM"] = 0.8,
									["HITGROUP_RIGHTARM"] = 0.8,
									["HITGROUP_STOMACH"] = 0.7,
									["HITGROUP_GEAR"] = 0.7,
									["HITGROUP_LEFTLEG"] = 0.8,
									["HITGROUP_RIGHTLEG"] = 0.8

								}

							else

								target:ClearBodyGroups()

							    target:SetModel("models/cultist/humans/chaos/fat/chaos_fat.mdl")

								local hitgroup_head = target.ScaleDamage["HITGROUP_HEAD"]

								target.ScaleDamage = {

									["HITGROUP_HEAD"] = 0.8,
									["HITGROUP_CHEST"] = 0.8,
									["HITGROUP_LEFTARM"] = 0.8,
									["HITGROUP_RIGHTARM"] = 0.8,
									["HITGROUP_STOMACH"] = 0.8,
									["HITGROUP_GEAR"] = 0.8,
									["HITGROUP_LEFTLEG"] = 0.8,
									["HITGROUP_RIGHTLEG"] = 0.8

								}

								target:SetArmor(target:Armor() + 30)

							end

							target:EmitSound( Sound("nextoren/others/cloth_pickup.wav") )

							target:BreachGive("cw_kk_ins2_ak12")

							target:GiveAmmo(180, "AR2", true)

							target:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 1, 1 )

							target:SetupHands()

						end

					end

				end)

			end

		elseif ply:HaveSpecialAb(role.Chaos_Edd) then

			if ply:GetSpecialMax() <= 0 then return end

			if CLIENT then return end
			ply:LagCompensation(true)
			local DASUKADAIMNEEGO = util.TraceLine( {
				start = ply:GetShootPos(),
				endpos = ply:GetShootPos() + ply:GetAimVector() * 130,
				filter = ply
			} )
			ply:LagCompensation(false)
			if !DASUKADAIMNEEGO.Hit then
				ply:RXSENDNotify("l:feelon_too_far")
				ply:SetSpecialCD(CurTime() + 5)
				return
			end

			if !DASUKADAIMNEEGO.Hit or !IsGroundPos(DASUKADAIMNEEGO.HitPos) then
				ply:RXSENDNotify("l:feelon_no_ground")
				ply:SetSpecialCD(CurTime() + 5)
				return
			end

			local mine = ents.Create("ent_chaos_mine")
			mine:SetPos(DASUKADAIMNEEGO.HitPos)
			local sang = ply:GetAngles()
			mine:SetOwner(ply)
			mine:Spawn()
			mine:SetAngles(sang + Angle(0,-90,0))
			ply:SetSpecialMax(ply:GetSpecialMax() - 1)
			ply:SetSpecialCD(CurTime() + 10)
			
		elseif ply:HaveSpecialAb(role.SCI_SPECIAL_MINE) then

			if ply:GetSpecialMax() <= 0 then return end

			if CLIENT then return end
			ply:LagCompensation(true)
			local DASUKADAIMNEEGO = util.TraceLine( {
				start = ply:GetShootPos(),
				endpos = ply:GetShootPos() + ply:GetAimVector() * 130,
				filter = ply
			} )
			ply:LagCompensation(false)
			if !DASUKADAIMNEEGO.Hit then
				ply:RXSENDNotify("l:feelon_too_far")
				ply:SetSpecialCD(CurTime() + 5)
				return
			end

			if !DASUKADAIMNEEGO.Hit or !IsGroundPos(DASUKADAIMNEEGO.HitPos) then
				ply:RXSENDNotify("l:feelon_no_ground")
				ply:SetSpecialCD(CurTime() + 5)
				return
			end

			local mine = ents.Create("ent_special_trap")
			mine:SetPos(DASUKADAIMNEEGO.HitPos)
			mine:SetOwner(ply)
			mine:Spawn()
			ply:SetSpecialMax(ply:GetSpecialMax() - 1)
			ply:SetSpecialCD(CurTime() + 40)
			ply:EmitSound("nextoren/vo/special_sci/trapper/trapper_"..math.random(1,10)..".mp3")

		elseif ply:HaveSpecialAb(role.MTF_Engi) then

			if ply:GetSpecialMax() <= 0 then return end

			if CLIENT then return end
			ply:LagCompensation(true)
			local DASUKADAIMNEEGO = util.TraceLine( {
				start = ply:GetShootPos(),
				endpos = ply:GetShootPos() + ply:GetAimVector() * 130,
				filter = ply
			} )
			ply:LagCompensation(false)

			if !DASUKADAIMNEEGO.Hit or !DASUKADAIMNEEGO.HitWorld or !IsGroundPos(DASUKADAIMNEEGO.HitPos) or DASUKADAIMNEEGO.HitNonWorld then
				ply:RXSENDNotify("l:engi_no_ground")
				ply:SetSpecialCD(CurTime() + 5)
				return
			end

			local mine = ents.Create("ent_engineer_turret")
			mine:SetPos(DASUKADAIMNEEGO.HitPos)
			mine:SetOwner(ply)
			mine:Spawn()
			ply:SetSpecialMax(ply:GetSpecialMax() - 1)
        elseif ( ply:HaveSpecialAb(role.ClassD_LegHitman) ) then
			if SERVER then
				ply:LagCompensation(true)
				local DASUKADAIMNEEGO = util.TraceLine( {
					start = ply:GetShootPos(),
					endpos = ply:GetShootPos() + ply:GetAimVector() * 130,
					filter = ply
				} )
				local target = DASUKADAIMNEEGO.Entity
				ply:LagCompensation(false)

				if !IsValid(target) or target:GetClass() != "prop_ragdoll" then return end
				if target:GetModel():find("corpse") then return end

				if ply:GetUsingArmor() != "" then
					ply:RXSENDNotify("l:hitman_take_off_helmet")
					return
				end
				if ply:GetUsingHelmet() != "" then
					ply:RXSENDNotify("l:hitman_take_off_vest")
					return
				end

				local function finish()

					if !IsValid(target) then return end
					if !IsValid(ply) then return end
					if !ply:Alive() then return end
					if ply:Health() <= 0 then return end
					if target:GetModel():find("corpse") then return end

					ply:SetSpecialCD(CurTime() + 7)

					local savemodel = ply:GetModel()
					local saveskin = ply:GetSkin()
					local remembername = ply:GetNamesurvivor()
					local bodygroups = {}
					for _, v in pairs(ply:GetBodyGroups()) do
						bodygroups[v.id] = ply:GetBodygroup(v.id)
					end
					local bnmrgs = ply:LookupBonemerges()

					ply:SetModel(target:GetModel())
					for _, v in pairs(target:GetBodyGroups()) do
						ply:SetBodygroup(v.id, target:GetBodygroup(v.id))
					end
					ply:SetSkin(target:GetSkin())
					if ply:GetModel():find("class_d.mdl") then
						ply:SetSkin(0)
					end

					local corpse_face = "models/all_scp_models/shared/heads/head_1_1"
					local havebalaclava = false
					local foundhead = false

					for i, v in pairs(target:LookupBonemerges()) do
						if v:GetModel():find("hair") then continue end
						if v:GetModel():find("gasmask") then continue end
						if v:GetModel():find("male_head") or v:GetModel():find("balaclava") then
							foundhead = true
							if CORRUPTED_HEADS[v:GetModel()] then
								corpse_face = v:GetSubMaterial(1)
							else
								corpse_face = v:GetSubMaterial(0)
							end
						end
						if v:GetModel():find("balaclava") then
							havebalaclava = true
							for _, v1 in pairs(bnmrgs) do
								if v1:GetModel():find("male_head") then
									local remember = v:GetModel()
									if CORRUPTED_HEADS[v1:GetModel()] then
										v1:SetSubMaterial(0, v1:GetSubMaterial(1))
										v1:SetSubMaterial(1, "")
									end
									ply.rememberface = v1:GetModel()
									v:SetModel("models/cultist/heads/male/male_head_1")
									v1:SetModel(remember)
								end
							end
						end
					end

					if !foundhead then
						Bonemerge(PickHeadModel(), target)
					end

					for i, v in pairs(target:LookupBonemerges()) do
						if v:GetModel():find("hair") then continue end
						if !v:GetModel():find("male_head") and !v:GetModel():find("balaclava") then
							Bonemerge(v:GetModel(), ply, v:GetSkin())
							v:Remove()
						end
					end

					for i, v in pairs(bnmrgs) do
						if v:GetModel():find("hair") then continue end
						if v:GetModel():find("gasmask") then continue end
						if v:GetModel():find("balaclava") and !havebalaclava then
							for _, v1 in pairs(target:LookupBonemerges()) do
								if v1:GetModel():find("male_head") then
									local remember = v:GetModel()
									if ply.rememberface == nil then ply.rememberface = "models/cultist/heads/male/male_head_1" end
									v:SetModel(ply.rememberface)
									v1:SetModel(remember)
								end
							end
						end
						if !v:GetModel():find("male_head") and !v:GetModel():find("balaclava") then
							Bonemerge(v:GetModel(), target, v:GetSkin())
							v:Remove()
						end
					end

					target:SetModel(savemodel)
					for i, v in pairs(bodygroups) do
						target:SetBodygroup(i,v)
					end
					target:SetSkin(saveskin)

					if target:GetModel():find("class_d.mdl") and corpse_face:find("black") then
						target:SetSkin(1)
					end

					for i, v in pairs(ply:LookupBonemerges()) do
						v:SetInvisible(false)
					end

					ply:SetNamesurvivor(target.__Name)
					ply:SetRunSpeed(target.RunSpeed)
					target.__Name = remembername

					ply:RXSENDNotify("l:hitman_disguised")
					ply:SetupHands()

					ply:ScreenFade(SCREENFADE.IN, color_black, 1, 1)

					if ply:GetModel():find("hazmat") then
						for i, v in pairs(ply:LookupBonemerges()) do
							v:SetInvisible(true)
						end
					else
						for i, v in pairs(ply:LookupBonemerges()) do
							v:SetInvisible(false)
						end
					end

					if target:GetModel():find("hazmat") then
						for i, v in pairs(target:LookupBonemerges()) do
							v:SetInvisible(true)
						end
					else
						for i, v in pairs(target:LookupBonemerges()) do
							v:SetInvisible(false)
						end
					end

					ply:EmitSound( Sound("nextoren/others/cloth_pickup.wav") )

				end

				ply:BrProgressBar( "l:changing_identity", 15, "nextoren/gui/icons/notifications/breachiconfortips.png", target, false, finish )

			end
		elseif ( ply:HaveSpecialAb(role.ClassD_Hitman) ) then
			if SERVER then
				ply:LagCompensation(true)
				local DASUKADAIMNEEGO = util.TraceLine( {
					start = ply:GetShootPos(),
					endpos = ply:GetShootPos() + ply:GetAimVector() * 130,
					filter = ply
				} )
				local target = DASUKADAIMNEEGO.Entity
				ply:LagCompensation(false)

				local blockedTeams = { TEAM_GOC, TEAM_DZ, TEAM_COTSK, TEAM_SPECIAL, TEAM_SCP }
				local blockedRoles = { role.ClassD_Bor, role.ClassD_Fat, role.Dispatcher, role.MTF_HOF, role.MTF_Jag, role.SCI_Head }
				local allowedRoles = { role.ClassD_GOCSpy, role.SCI_SpyDZ }

				if !IsValid(target) or !target.vtable or target:GetClass() != "prop_ragdoll" or ( table.HasValue(blockedTeams, target.__Team) and !table.HasValue(allowedRoles, target.Role) ) or table.HasValue(blockedRoles, target.Role) or target:GetModel():find("goc.mdl") or target.IsFemale then return end
				if target:GetModel():find("corpse") then return end

				if ply:GetUsingArmor() != "" then
					ply:RXSENDNotify("l:hitman_take_off_helmet")
					return
				end
				if ply:GetUsingHelmet() != "" then
					ply:RXSENDNotify("l:hitman_take_off_vest")
					return
				end

				local function finish()

					if !IsValid(target) then return end
					if !IsValid(ply) then return end
					if !ply:Alive() then return end
					if ply:Health() <= 0 then return end
					if target:GetModel():find("corpse") then return end

					ply:SetSpecialCD(CurTime() + 15)

					local savemodel = ply:GetModel()
					local saveskin = ply:GetSkin()
					local remembername = ply:GetNamesurvivor()
					local bodygroups = {}
					for _, v in pairs(ply:GetBodyGroups()) do
						bodygroups[v.id] = ply:GetBodygroup(v.id)
					end
					local bnmrgs = ply:LookupBonemerges()

					ply:SetModel(target:GetModel())
					for _, v in pairs(target:GetBodyGroups()) do
						ply:SetBodygroup(v.id, target:GetBodygroup(v.id))
					end
					ply:SetSkin(target:GetSkin())
					if ply:GetModel():find("class_d.mdl") then
						ply:SetSkin(0)
					end

					local corpse_face = "models/all_scp_models/shared/heads/head_1_1"
					local havebalaclava = false
					local foundhead = false

					for i, v in pairs(target:LookupBonemerges()) do
						if v:GetModel():find("hair") then continue end
						if v:GetModel():find("gasmask") then continue end
						if v:GetModel():find("male_head") or v:GetModel():find("balaclava") then
							foundhead = true
							if CORRUPTED_HEADS[v:GetModel()] then
								corpse_face = v:GetSubMaterial(1)
							else
								corpse_face = v:GetSubMaterial(0)
							end
						end
						if v:GetModel():find("balaclava") then
							havebalaclava = true
							for _, v1 in pairs(bnmrgs) do
								if v1:GetModel():find("male_head") then
									local remember = v:GetModel()
									if CORRUPTED_HEADS[v1:GetModel()] then
										v1:SetSubMaterial(0, v1:GetSubMaterial(1))
										v1:SetSubMaterial(1, "")
									end
									ply.rememberface = v1:GetModel()
									v:SetModel("models/cultist/heads/male/male_head_1")
									v1:SetModel(remember)
								end
							end
						end
					end

					if !foundhead then
						Bonemerge(PickHeadModel(), target)
					end

					for i, v in pairs(target:LookupBonemerges()) do
						if v:GetModel():find("hair") then continue end
						if !v:GetModel():find("male_head") and !v:GetModel():find("balaclava") then
							Bonemerge(v:GetModel(), ply, v:GetSkin())
							v:Remove()
						end
					end

					for i, v in pairs(bnmrgs) do
						if v:GetModel():find("hair") then continue end
						if v:GetModel():find("gasmask") then continue end
						if v:GetModel():find("balaclava") and !havebalaclava then
							for _, v1 in pairs(target:LookupBonemerges()) do
								if v1:GetModel():find("male_head") then
									local remember = v:GetModel()
									if ply.rememberface == nil then ply.rememberface = "models/cultist/heads/male/male_head_1" end
									v:SetModel(ply.rememberface)
									v1:SetModel(remember)
								end
							end
						end
						if !v:GetModel():find("male_head") and !v:GetModel():find("balaclava") then
							Bonemerge(v:GetModel(), target, v:GetSkin())
							v:Remove()
						end
					end

					target:SetModel(savemodel)
					for i, v in pairs(bodygroups) do
						target:SetBodygroup(i,v)
					end
					target:SetSkin(saveskin)

					if target:GetModel():find("class_d.mdl") and corpse_face:find("black") then
						target:SetSkin(1)
					end

					for i, v in pairs(ply:LookupBonemerges()) do
						v:SetInvisible(false)
					end

					ply:SetNamesurvivor(target.__Name)
					ply:SetRunSpeed(target.RunSpeed)
					target.__Name = remembername

					ply:RXSENDNotify("l:hitman_disguised")
					ply:SetupHands()

					ply:ScreenFade(SCREENFADE.IN, color_black, 1, 1)

					if ply:GetModel():find("hazmat") then
						for i, v in pairs(ply:LookupBonemerges()) do
							v:SetInvisible(true)
						end
					else
						for i, v in pairs(ply:LookupBonemerges()) do
							v:SetInvisible(false)
						end
					end

					if target:GetModel():find("hazmat") then
						for i, v in pairs(target:LookupBonemerges()) do
							v:SetInvisible(true)
						end
					else
						for i, v in pairs(target:LookupBonemerges()) do
							v:SetInvisible(false)
						end
					end

					ply:EmitSound( Sound("nextoren/others/cloth_pickup.wav") )

				end

				ply:BrProgressBar( "l:changing_identity", 30, "nextoren/gui/icons/notifications/breachiconfortips.png", target, false, finish )

			end
		elseif ply:HaveSpecialAb(role.ClassD_Bor) and SERVER then
			local angle_zero = Angle(0,0,0)
			ply:LagCompensation(true)
		local DASUKADAIMNEEGO = util.TraceLine( {
			start = ply:GetShootPos(),
			endpos = ply:GetShootPos() + ply:GetAimVector() * 130,
			filter = ply
		} )
		local target = DASUKADAIMNEEGO.Entity
		ply:LagCompensation(false)

		if !ply:IsOnGround() then
			ply:RXSENDNotify("l:strong_no_ground")
			ply:SetSpecialCD(CurTime() + 3)
			return
		end
		if !IsValid(target) or !target.GTeam or target:GTeam() == TEAM_SPEC then
			ply:RXSENDNotify("l:strong_look_on_them")
			ply:SetSpecialCD(CurTime() + 3)
			return
		end
		if target:HasGodMode() then return end
		if !ply:IsSuperAdmin() and target:GTeam() == TEAM_SCP and !target.IsZombie then
			ply:RXSENDNotify("l:strong_look_on_them")
			ply:SetSpecialCD(CurTime() + 3)
			return
		end
		ply:Freeze(true)
		target:Freeze(true)
		local pos = ply:GetShootPos() + ply:GetAngles():Forward()*44
		pos.z = ply:GetPos().z
		ply:SetMoveType(MOVETYPE_OBSERVER)
		net.Start( "ThirdPersonCutscene", true )

			net.WriteUInt( 6, 4 )

		net.Send( ply )
		target:SetMoveType(MOVETYPE_OBSERVER)
		ply:SetNWBool("IsNotForcedAnim", false)
		target:SetNWBool("IsNotForcedAnim", false)
		target:SetPos(pos)
		ply:SetSpecialCD(CurTime() + 65)
		local startcallbackattacker = function()
			--ply:SetNWEntity("NTF1Entity", ply)
			ply:Freeze(true)
			ply.ProgibTarget = target
			sound.Play("^nextoren/charactersounds/special_moves/bor/grab_start.wav", ply:GetPos(), 75, 100, 1)
			sound.Play("^nextoren/charactersounds/special_moves/bor/victim_struggle_6.wav", ply:GetPos(), 75, 100, 1)
			target.ProgibTarget = ply
			local vec_pos = target:GetShootPos() + ( ply:GetShootPos() - target:EyePos() ):Angle():Forward() * 1.5
			vec_pos.z = ply:GetPos().z
			target:SetPos(vec_pos)
			ply:SetNWAngle( "ViewAngles", ( target:GetShootPos() - ply:EyePos() ):Angle() )
			target:SetNWAngle( "ViewAngles", ( ply:GetShootPos() - target:EyePos() ):Angle() )
		end
		local stopcallbackattacker = function()
			ply:SetNWEntity("NTF1Entity", NULL)
			ply:SetNWAngle("ViewAngles", angle_zero)
			ply:Freeze(false)
			ply.ProgibTarget = nil
			ply:SetNWBool("IsNotForcedAnim", true)
			ply:SetMoveType(MOVETYPE_WALK)
		end
		local finishcallbackattacker = function()
			ply:SetNWEntity("NTF1Entity", NULL)
			ply:SetNWAngle("ViewAngles", angle_zero)
			target:SetNWAngle("ViewAngles", angle_zero)
			target:TakeDamage(1000000, ply, "КАЧОК СУКА ХУЯЧИТ")
			ply:Freeze(false)
			ply.ProgibTarget = nil
			ply:SetNWBool("IsNotForcedAnim", true)
			ply:SetMoveType(MOVETYPE_WALK)

			target:StopForcedAnimation()
			sound.Play("^nextoren/charactersounds/hurtsounds/fall/pldm_fallpain0"..math.random(1, 2)..".wav", ply:GetShootPos(), 75, 100, 1)
		end
		local startcallbackvictim = function()
			target:SetNWEntity("NTF1Entity", target)
			target:Freeze(true)
			target.ProgibTarget = ply
			ply.ProgibTarget = target
		end
		local stopcallbackvictim = function()
			target:SetNWEntity("NTF1Entity", NULL)
			target:SetNWAngle("ViewAngles", angle_zero)
			target:Freeze(false)
			target.ProgibTarget = nil
			target:SetNWBool("IsNotForcedAnim", true)
			target:SetMoveType(MOVETYPE_WALK)
		end
		local finishcallbackvictim = function()
			target:SetNWEntity("NTF1Entity", NULL)
			target:SetNWAngle("ViewAngles", angle_zero)
			target:Freeze(false)
			target.ProgibTarget = nil
			target:SetNWBool("IsNotForcedAnim", true)
			target:SetMoveType(MOVETYPE_WALK)
		end
		ply:SetForcedAnimation(ply:LookupSequence("1_bor_progib_attacker"), 5.5, startcallbackattacker, finishcallbackattacker, stopcallbackattacker)
		target:SetForcedAnimation(target:LookupSequence("1_bor_progib_resiver"), 5.5, startcallbackvictim, finishcallbackvictim, stopcallbackvictim)
		target:StopGestureSlot( GESTURE_SLOT_CUSTOM )

		elseif ply:HaveSpecialAb(role.Goc_Commander) then
			ply:SetSpecialCD(CurTime() + 80)
			if CLIENT then 
				local hands = ply:GetHands()
				local ef = EffectData()
				ef:SetEntity(hands)
				util.Effect("gocabilityeffect", ef)
				return
			end

			local ef = EffectData()
			ef:SetEntity(ply)
			util.Effect("gocabilityeffect", ef)
			BroadcastLua("local ef = EffectData() ef:SetEntity(Entity("..tostring(ply:EntIndex())..")) util.Effect(\"gocabilityeffect\", ef)")

			ply:BrProgressBar("l:becoming_invisible", 0.8, "nextoren/gui/icons/notifications/breachiconfortips.png")

			timer.Simple(0.8, function()
				if IsValid(ply) and ply:HaveSpecialAb(role.Goc_Commander) then
					ply:ScreenFade(SCREENFADE.IN, gteams.GetColor(TEAM_GOC), 0.5, 0)
					ply:RXSENDNotify("l:became_invisible")
					ply:SetNoDraw(true)
					ply.CommanderAbilityActive = true
					for _, wep in pairs(ply:GetWeapons()) do wep:SetNoDraw(true) end
					timer.Create("Goc_Commander_"..ply:UniqueID(), 20, 1, function()
						if !ply.CommanderAbilityActive then return end
						ply:SetNoDraw(false)
						ply.CommanderAbilityActive = nil
						for _, wep in pairs(ply:GetWeapons()) do wep:SetNoDraw(false) end
					end)
				end
			end)

		elseif ply:HaveSpecialAb(role.SCI_Recruiter) then
			if ply:GetSpecialMax() == 0 then return end
			local angle_zero = Angle(0,0,0)
			ply:LagCompensation(true)
			local DASUKADAIMNEEGO = util.TraceLine( {
				start = ply:GetShootPos(),
				endpos = ply:GetShootPos() + ply:GetAimVector() * 130,
				filter = ply
			} )
			local target = DASUKADAIMNEEGO.Entity
			ply:LagCompensation(false)
			if SERVER then
				if !IsValid(target) or !target:IsPlayer() or target:GTeam() == TEAM_SPEC or target:GetModel():find("goose") then
					ply:RXSENDNotify("l:commitee_look_on_them")
					ply:SetSpecialCD(CurTime() + 2)
					return
				end
				if ( target:GTeam() != TEAM_CLASSD and target:GetRoleName() != role.ClassD_GOCSpy ) or target:GetRoleName() == role.ClassD_Banned or target:GetUsingCloth() != "" or target:GetModel():find('goc') then
					ply:RXSENDNotify("l:commitee_cant_conscript")
					ply:SetSpecialCD(CurTime() + 2)
					return
				end
				if target:GetPrimaryWeaponAmount() >= target:GetMaxSlots() then
					ply:RXSENDNotify("l:commitee_no_slots")
					ply:SetSpecialCD(CurTime() + 2)
					return
				end
				if IsValid(target:GetActiveWeapon()) and target:GetActiveWeapon():GetClass() != "br_holster" then
					ply:RXSENDNotify("l:commitee_active_weapon")
					return
				end
				local finishcallback = function()
					if !IsValid(target) or !target:IsPlayer() or target:GTeam() == TEAM_SPEC then
						ply:RXSENDNotify("l:commitee_look_on_them")
						ply:SetSpecialCD(CurTime() + 2)
						return
					end
					if ( target:GTeam() != TEAM_CLASSD and target:GetRoleName() != role.ClassD_GOCSpy ) or target:GetUsingCloth() != "" or target:GetModel():find('goc') then
						ply:RXSENDNotify("l:commitee_cant_conscript")
						ply:SetSpecialCD(CurTime() + 2)
						return
					end
					if target:GetPrimaryWeaponAmount() >= target:GetMaxSlots() then
						ply:RXSENDNotify("l:commitee_no_slots")
						ply:SetSpecialCD(CurTime() + 2)
						return
					end
					if IsValid(target:GetActiveWeapon()) and target:GetActiveWeapon():GetClass() != "br_holster" then
						ply:RXSENDNotify("l:commitee_active_weapon")
						return
					end
					ply:SetSpecialMax( ply:GetSpecialMax() - 1 )
					if target:GTeam() != TEAM_GOC then
						target:SetGTeam(TEAM_SCI)
					else
						target:SetUsingCloth("armor_sci")
						target.OldModel = target:GetModel()
						target.OldSkin = target:GetSkin()
						target.OldBodygroups = target:GetBodyGroupsString()
					end
					if ( target.BoneMergedHackerHat ) then
				
						for _, v in ipairs( target.BoneMergedHackerHat ) do
				
							if ( v && v:IsValid() ) then
				
								v:Remove()
				
							end
				
						end
				
					end
					if target:GetRoleName() != role.ClassD_Fat and target:GetRoleName() != role.ClassD_Bor then
						if target:GetModel():find("female") then
							target:SetModel("models/cultist/humans/sci/scientist_female.mdl")
						else
							target:SetModel("models/cultist/humans/sci/scientist.mdl")
						end
						target:ClearBodyGroups()
				 		target:SetBodygroup(0, 2)
				 		target:SetBodygroup(2, 1)
				 		target:SetBodygroup(4, 1)
				 	else
				 		if target:GetRoleName() == role.ClassD_Fat then
							target:SetModel("models/cultist/humans/sci/class_d_fat.mdl")
						else
							target:SetModel("models/cultist/humans/sci/class_d_bor.mdl")
							target:SetBodygroup(0, 0)
						end
				 	end
				 	target.AbilityTAB = nil
				 	target:SetNWString("AbilityName", "")
					target:StripWeapon("item_knife")
                    target:StripWeapon("hacking_doors")
					target:BreachGive("weapon_pass_sci")
					target:EmitSound( Sound("nextoren/others/cloth_pickup.wav") )
					target:ScreenFade( SCREENFADE.IN, Color( 0, 0, 0, 255 ), 1, 1 )
					target:SetupHands()
					ply:AddToAchievementPoint("comitee", 1)
				end
				ply:BrProgressBar("l:giving_equipment", 8, "nextoren/gui/special_abilities/ability_recruiter.png", target, false, finishcallback)
			end

		elseif ply:HaveSpecialAb(role.Goc_Jag) then

			ply:SetSpecialCD( CurTime() + 75)

			if SERVER then

				local shield = ents.Create("ent_goc_shield")
				shield:SetOwner(ply)
				shield:Spawn()

			end

		elseif ply:HaveSpecialAb(role.UIU_Specialist) then

			maxs_uiu_spec = Vector( 8, 10, 5 )

			local trace = {}

			trace.start = ply:GetShootPos()

			trace.endpos = trace.start + ply:GetAimVector() * 165

			trace.filter = ply

			trace.mins = -maxs_uiu_spec

			trace.maxs = maxs_uiu_spec
		
			trace = util.TraceHull( trace )
		
			local target = trace.Entity

			if target:IsValid() && target:GetClass() == "func_button" && !target:IsPlayer() && ply:Alive() && ply:GTeam() == TEAM_USA && ply:Health() > 0 then

				old_target_uiu = target

				if SERVER then
					ply:BrProgressBar("l:blocking_door", 5, "nextoren/gui/special_abilities/special_fbi_hacker.png")
				end

				timer.Create("Blocking_UIU_Check"..ply:SteamID(), 1, 5, function()
					if ply:GetEyeTrace().Entity != old_target_uiu && ply:Alive() && ply:GTeam() == TEAM_USA && ply:Health() > 0 then
						timer.Remove("Blocking_UIU"..ply:SteamID())
						timer.Remove("Blocking_UIU_Check"..ply:SteamID())
						ply:ConCommand("stopprogress")
					end
				end)

				timer.Create("Blocking_UIU"..ply:SteamID(), 5, 1, function()

					ply:SetSpecialCD( CurTime() + 30)

					target:Fire("Lock")

					timer.Simple(30, function()
						
						target:Fire("Unlock")

					end)

				end)

			end
		elseif ply:HaveSpecialAb(role.DZ_Commander) then

			ply:SetSpecialCD( CurTime() + 90 )
		
			local forward_portal = ply:GetForward()

			forward_portal.z = 0

			local siusiakko12 = ply:EyeAngles()

			siusiakko12.pitch = 0
			
		    siusiakko12.roll = 0

			if SERVER then

				local por = ents.Create( "dz_commander_portal" )

				por:SetOwner( ply )

				por:SetPos( ply:GetPos() + forward_portal * 150 + Vector(0, 0, 20) )

				por:SetAngles(siusiakko12 - Angle(0,0,0))

				por:Spawn()

			end

		elseif ply:HaveSpecialAb(role.SECURITY_Spy) then

			ply:SetSpecialCD( CurTime() + 20 )

			if CLIENT then return end

			net.Start("Chaos_SpyAbility", true)
			net.Send(ply)

		elseif ply:HaveSpecialAb(role.Cult_Specialist) then

			ply:SetSpecialCD( CurTime() + 50 )

			if CLIENT then return end

			net.Start("Cult_SpecialistAbility", true)
			net.Send(ply)

		elseif ply:HaveSpecialAb(role.UIU_Agent_Commander) then

			ply:SetSpecialCD( CurTime() + 45 )

			if CLIENT then return end

			net.Start("fbi_commanderabillity", true)
			net.Send(ply)

		elseif ply:HaveSpecialAb(role.NTF_Commander) then

			ply:SetSpecialCD( CurTime() + 2 )

			if CLIENT then
				Choose_Faction()
			end
			
		elseif ply:HaveSpecialAb(role.Chaos_Scanning) then

			ply:SetSpecialCD( CurTime() + 2 )

			if CLIENT then
				Ci_Faction()
			end

		elseif ply:HaveSpecialAb(role.UIU_Clocker) then

			if SERVER then

				ply:SetSpecialCD( CurTime() + 40 )

				ply:ScreenFade(SCREENFADE.IN, Color(255,0,0,100), 1, 0.3)

				local saveresist = table.Copy(ply.ScaleDamage)
				local savespeed = ply:GetRunSpeed()

				ply.Stamina = 200
				ply:SetStamina(200)

				ply:SetArmor(255)

				ply.ScaleDamage = {
					["HITGROUP_HEAD"] = 0.4,
					["HITGROUP_CHEST"] = 0.2,
					["HITGROUP_LEFTARM"] = 0.2,
					["HITGROUP_RIGHTARM"] = 0.2,
					["HITGROUP_STOMACH"] = 0.2,
					["HITGROUP_GEAR"] = 0.2,
					["HITGROUP_LEFTLEG"] = 0.2,
					["HITGROUP_RIGHTLEG"] = 0.2
				}

				ply:SetRunSpeed(ply:GetRunSpeed() + 65)

				if ply:GetActiveWeapon() == ply:GetWeapon("weapon_fbi_knife") then

					ply.SafeRun = ply:LookupSequence("phalanx_b_run")

					net.Start("ChangeRunAnimation", true)
					net.WriteEntity(ply)
					net.WriteString("phalanx_b_run")
					net.Broadcast()

				end

				timer.Simple(15, function()
					if IsValid(ply) and ply:Health() > 0 and ply:Alive() and ply:HaveSpecialAb(role.UIU_Clocker) then
						ply.ScaleDamage = saveresist
						ply:SetRunSpeed(savespeed)
						ply:SetArmor(0)
						if ply:GetActiveWeapon() == ply:GetWeapon("weapon_fbi_knife") then

							ply.SafeRun = ply:LookupSequence("AHL_r_RunAim_KNIFE")

							net.Start("ChangeRunAnimation", true)
							net.WriteEntity(ply)
							net.WriteString("AHL_r_RunAim_KNIFE")
							net.Broadcast()

						end
					end
				end)


		end

		elseif ply:HaveSpecialAb(role.NTF_Specialist) then

			maxs_uiu_spec = Vector( 8, 10, 5 )

			local trace = {}

			trace.start = ply:GetShootPos()

			trace.endpos = trace.start + ply:GetAimVector() * 165

			trace.filter = ply

			trace.mins = -maxs_uiu_spec

			trace.maxs = maxs_uiu_spec
		
			trace = util.TraceHull( trace )
		
			local target = trace.Entity

			--print("11111111")
			if target && target:IsValid() && target:IsPlayer() && target:GTeam() == TEAM_SCP && target:Health() > 0 && target:Alive() then
				--print("234")
				ply:SetSpecialCD( CurTime() + 90 )
				target:Freeze(true)
				old_name = target:GetNamesurvivor()
				old_role = target:GetRoleName()
				if target:GetModel() == "models/cultist/scp/scp_682.mdl" then
					if SERVER then
						target:SetForcedAnimation("0_Stun_29", false, false, 6)
					end
				else
					if SERVER then
						target:SetForcedAnimation("0_SCP_542_lifedrain", false, false, 6)
					end
				end
				timer.Create("UnFreezeNTF_Specialist"..target:SteamID(), 6, 1, function()
					--print("111", target:GetNamesurvivor() != old_name , target:GetRoleName() != old_role , target:GTeam() != TEAM_SCP)
					if target:GetNamesurvivor() != old_name && target:GetRoleName() != old_role && target:GTeam() != TEAM_SCP then return end
					target:Freeze(false)
				end)
			end

		elseif ply:HaveSpecialAb(role.SCI_SPECIAL_SHIELD) then

			ply:SetSpecialCD( CurTime() + 300 )

if SERVER then
			ply:EmitSound("nextoren/vo/special_sci/shield/shield_"..math.random(1,9)..".mp3")

				local special_shield = ents.Create("special_sphere")

				special_shield:SetOwner(ply)

				special_shield:Spawn()

				special_shield:SetPos(ply:GetPos())


			end

		elseif ply:HaveSpecialAb(role.SCI_SPECIAL_VISION) then

			ply:SetSpecialCD( CurTime() + 60 )

			if CLIENT then HedwigAbility() end

		elseif ply:HaveSpecialAb(role.SCI_SPECIAL_SPEED) then

			ply:SetSpecialCD( CurTime() + 57 )

			if SERVER then
				ply:EmitSound("nextoren/vo/special_sci/speed_booster/speed_booster_"..math.random(1,12)..".mp3")

				local special_buff_radius = ents.FindInSphere( ply:GetPos(), 450 )

				for _, tply in pairs(special_buff_radius) do
					if IsValid(tply) and tply:IsPlayer() and tply:GTeam() != TEAM_SPEC and tply:GTeam() != TEAM_SCP then
						tply:SetRunSpeed(tply:GetRunSpeed() + 40)
						tply.Shaky_SPEEDName = tply:GetNamesurvivor()
						timer.Simple(25, function()
							if IsValid(tply) and tply:IsPlayer() and tply:GetNamesurvivor() == tply.Shaky_SPEEDName then tply:SetRunSpeed(tply:GetRunSpeed() - 40) end
						end)
					end
				end

			end


		elseif ply:HaveSpecialAb(role.SCI_SPECIAL_INVISIBLE) then

			ply:SetSpecialCD( CurTime() + 201 )

			if SERVER then
				local special_buff_radius = ents.FindInSphere( ply:GetPos(), 450 )

				for _, tply in pairs(special_buff_radius) do
					if IsValid(tply) and tply:IsPlayer() and tply == ply then
						local ef = EffectData()
						ef:SetEntity(tply)
						util.Effect("gocabilityeffect", ef)
						BroadcastLua("local ef = EffectData() ef:SetEntity(Entity("..tostring(tply:EntIndex())..")) util.Effect(\"gocabilityeffect\", ef)")
						timer.Simple(0.8, function()
							tply:SetNoDraw(true)
							for i, v in pairs(tply:LookupBonemerges()) do v:SetNoDraw(true) end
							tply.CommanderAbilityActive = true
							for _, wep in pairs(tply:GetWeapons()) do wep:SetNoDraw(true) end
							timer.Create("Special_invis_Commander_"..tply:UniqueID(), 20, 1, function()
								if !tply.CommanderAbilityActive then return end
								for i, v in pairs(tply:LookupBonemerges()) do v:SetNoDraw(false) end
								tply:SetNoDraw(false)
								tply.CommanderAbilityActive = nil
								for _, wep in pairs(ply:GetWeapons()) do wep:SetNoDraw(false) end
							end)
						end)
					end
				end

			end

		elseif ply:HaveSpecialAb(role.SCI_SPECIAL_HEALER) then

			ply:SetSpecialCD( CurTime() + 45 )

			if SERVER then ply:EmitSound("nextoren/vo/special_sci/medic/medic_"..math.random(1,11)..".mp3") end

			for _, target in ipairs(ents.FindInSphere(ply:GetPos(), 250)) do

				if target:IsPlayer() then
					if SERVER then
	
						target:SetHealth( math.Clamp( target:Health() + 40, 0, target:GetMaxHealth() ) )
	
					end		
				end	

			end

		elseif ply:HaveSpecialAb(role.Cult_Psycho) then

			ply:SetSpecialCD( CurTime() + 205 )

			if SERVER then

				ply:SetHealth(ply:GetMaxHealth())

				ply.ScaleDamage = {
				 	["HITGROUP_HEAD"] = .1,
				 	["HITGROUP_CHEST"] = .1,
				 	["HITGROUP_LEFTARM"] = .1,
				 	["HITGROUP_RIGHTARM"] = .1,
				 	["HITGROUP_STOMACH"] = .1,
				 	["HITGROUP_GEAR"] = .1,
				 	["HITGROUP_LEFTLEG"] = .1,
				 	["HITGROUP_RIGHTLEG"] = .1
				 },

				ply:Boosted( 2, 30 )
				ply:SetArmor(255)
				ply.DamageModifier = 0.4

				local old_name_psycho = ply:GetNamesurvivor()

				timer.Simple(30, function()
					if ply:GetNamesurvivor() != old_name_psycho or ply:Health() < 0 or !ply:Alive() or ply:GTeam() == TEAM_SPEC then return end
					ply:AddToStatistics("l:psycho_bravery_bonus", 50)
					ply:Kill()
				end)

			end


		elseif ply:HaveSpecialAb(role.SCI_SPECIAL_SLOWER) then

			ply:SetSpecialCD( CurTime() + 85 )

			if SERVER then
				local tabslowed = {}
				local special_slow_radius = ents.FindInSphere( ply:GetPos(), 450 )

				ply:EmitSound("nextoren/vo/special_sci/scp_slower/scp_slower_"..math.random(1,14)..".mp3")
				for _, ply in pairs(special_slow_radius) do
					if IsValid(ply) and ply:IsPlayer() and ply:GTeam() == TEAM_SCP then
						ply:SetNWInt("Speed_Multiply", 0.45)
						timer.Create("ply_slower_special_"..ply:SteamID(), 15, 1, function()
							ply:SetNWInt("Speed_Multiply", 1)
						end)
					end
				end

			end

		elseif ply:HaveSpecialAb(role.SCI_SPECIAL_DAMAGE) then

			ply:SetSpecialCD( CurTime() + 65 )

			if SERVER then
				local special_buff_radius = ents.FindInSphere( ply:GetPos(), 450 )

				ply:EmitSound("nextoren/vo/special_sci/buffer_damage/buffer_"..math.random(1,14)..".mp3")

				for _, tply in pairs(special_buff_radius) do
					if IsValid(tply) and tply:IsPlayer() and tply:GTeam() != TEAM_SPEC and tply:GTeam() != TEAM_SCP then
						tply.SCI_SPECIAL_DAMAGE_Active = true
						timer.Simple(25, function()
							if IsValid(tply) and tply:IsPlayer() then tply.SCI_SPECIAL_DAMAGE_Active = nil end
						end)
					end
				end
				
			end

		elseif ply:HaveSpecialAb(role.SKP_Offizier) then

			ply:SetSpecialCD( CurTime() + 120 )

			local special_speed_radius = ents.FindInSphere( ply:GetPos(), 450 )

			for _, v in ipairs( special_speed_radius ) do

				if v:IsPlayer() then
					
					if v:GTeam() != TEAM_SCP and v:GTeam() != TEAM_SPEC and v:GTeam() == TEAM_NAZI then

			            v:Boosted( 3, math.random( 20, 25 ) )
						v:Boosted( 2, 5 )

					end

				end

			end

		elseif ply:HaveSpecialAb(role.ClassD_Fast) then

			ply:SetSpecialCD( CurTime() + 1 )

			if SERVER then

				if ply:GetRunSpeed() == 231 or ply:GetRunSpeed() == 288 then
					if ply:GetRunSpeed() == 231 then
						ply:SetRunSpeed(288)
						ply:RXSENDNotify("l:sport_run")
						if ply:GetActiveWeapon() == ply:GetWeapon("br_holster") then

							ply.SafeRun = ply:LookupSequence("phalanx_b_run")

							net.Start("ChangeRunAnimation", true)
							net.WriteEntity(ply)
							net.WriteString("run_all_02")
							net.Broadcast()

						end
					else
						ply:SetRunSpeed(231)
						ply:RXSENDNotify("l:default_run")
						if ply:GetActiveWeapon() == ply:GetWeapon("br_holster") then

							ply.SafeRun = ply:LookupSequence("phalanx_b_run")

							net.Start("ChangeRunAnimation", true)
							net.WriteEntity(ply)
							net.WriteString("run_all_01")
							net.Broadcast()

						end
					end
				else
					ply:RXSENDNotify("l:cant_change_run")
				end

			end
		elseif ply:HaveSpecialAb(role.SCI_SPECIAL_BOOSTER) then

			ply:SetSpecialCD( CurTime() + 100 )

			local special_speed_radius = ents.FindInSphere( ply:GetPos(), 450 )

			for _, v in ipairs( special_speed_radius ) do

				if v:IsPlayer() then
					
					if v:GTeam() != TEAM_SCP and v:GTeam() != TEAM_SPEC then

			            v:Boosted( 2, math.random( 17, 20 ) )

					end

				end

			end

		elseif ply:HaveSpecialAb(role.GRU_Commander) then

			maxs_uiu_spec = Vector( 8, 10, 5 )

			local trace = {}

			trace.start = ply:GetShootPos()

			trace.endpos = trace.start + ply:GetAimVector() * 165

			trace.filter = ply

			trace.mins = -maxs_uiu_spec

			trace.maxs = maxs_uiu_spec
		
			trace = util.TraceHull( trace )
		
			local target = trace.Entity

			if target:IsValid() && target:IsPlayer() && ply:Alive() && ply:GTeam() == TEAM_GRU && target:GTeam() != TEAM_SPEC && target:GTeam() != TEAM_SCP && ply:Health() > 0 then

				old_target = target

				if SERVER then
					ply:BrProgressBar("l:interrogation", 5, "nextoren/gui/special_abilities/special_gru_commander.png")
				end

				timer.Create("GRU_Com_Check"..ply:SteamID(), 1, 5, function()
					if ply:GetEyeTrace().Entity != old_target && ply:Alive() && ply:GTeam() == TEAM_GRU && ply:Health() > 0 then
						timer.Remove("GRU_Com"..ply:SteamID())
						timer.Remove("GRU_Com_Check"..ply:SteamID())
						ply:ConCommand("stopprogress")
					end
				end)

				timer.Create("GRU_Com"..ply:SteamID(), 5, 1, function()

					ply:SetSpecialCD( CurTime() + 50)

					if SERVER then
					    target:AddToStatistics("l:interrogated_by_gru", -40)
					end

					local players = player.GetAll()

					for i = 1, #players do

						local player = players[i]

						if player:GTeam() == TEAM_GRU then

							if !GRU_Members then

								GRU_Members = {}

							end

							GRU_Members[#GRU_Members + 1] = player

						end

					end

					if SERVER then
						net.Start("GRU_CommanderAbility", true)
					    	net.WriteString(target:GTeam())
						net.Send(ply)
					end

				end)

			end

		end

	end

end)

local stance_exit_mins, stance_exit_maxs = Vector( -16, -16, 16 ), Vector( 16, 16, 72 )

function Stance_CanExit( ply )

	local tr = {}
	tr.start = ply:GetPos()
	tr.endpos = tr.start
	tr.filter = ply
	tr.mins = stance_exit_mins
	tr.maxs = stance_exit_maxs

	tr = util.TraceHull( tr )

	if ( tr.Hit ) then return false end

	return true

end

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	 if ( hitgroup == HITGROUP_HEAD ) then
		dmginfo:ScaleDamage( 2 ) // More damage when we're shot in the head
 	 else
		dmginfo:ScaleDamage( 0.50 )  // Less damage when shot anywhere else
	 end
end


hook.Add( "ScalePlayerDamage", "Damage_PEnalty", function( ply, hitgroup, dmginfo )
	if !ply.DamageMovePenalty then ply.DamageMovePenalty = ply:GetRunSpeed() end
	if dmginfo:IsBulletDamage() then
		ply.DamageMovePenalty = 50
	end
end)

hook.Add( "SetupMove", "StanceSpeed", function( ply, mv, cmd )

	local velLength = ply:GetVelocity():Length2DSqr()

	local pl = ply:GetTable()

	local team = ply:GTeam()
	local runspeed = ply:GetRunSpeed()
	local walkspeed = ply:GetWalkSpeed()

	if team != TEAM_SCP and team != TEAM_SPEC then

		if !pl.DamageMovePenalty then pl.DamageMovePenalty = runspeed end


		if pl.DamageMovePenalty and pl.DamageMovePenalty < runspeed then
			pl.DamageMovePenalty = math.Approach(pl.DamageMovePenalty, runspeed, FrameTime()*128)
			if mv:KeyDown( IN_SPEED ) then
				mv:SetMaxClientSpeed( pl.DamageMovePenalty )
				mv:SetMaxSpeed( pl.DamageMovePenalty )
			end
		end

	end

	--[[

	if ( mv:KeyDown( IN_SPEED ) && velLength > .25 || ply.SprintMove && !ply.Run_fading ) then

		if ( ply:IsLeaning() ) then

			ply:SetNW2Int( "LeanOffset", 0 )
			ply.OldStatus = nil

		end

		if ( !ply.SprintMove ) then

			ply.Run_fading = nil
			ply.SprintMove = true
			ply.Sprint_Speed = ply:GetWalkSpeed()

		end

		ply.Sprint_Speed = math.Approach( ply.Sprint_Speed, ply:GetRunSpeed(), FrameTime() * 128 )

		mv:SetMaxClientSpeed( ply.Sprint_Speed )
		mv:SetMaxSpeed( ply.Sprint_Speed )

	elseif ( ply.SprintMove && ply.Run_fading ) then

		local walk_Speed = ply:GetWalkSpeed()

		ply.Sprint_Speed = math.Approach( ply.Sprint_Speed, walk_Speed, FrameTime() * 500 )

		mv:SetMaxClientSpeed( ply.Sprint_Speed )
		mv:SetMaxSpeed( ply.Sprint_Speed )

		if ( ply.Sprint_Speed == walk_Speed ) then

			ply.SprintMove = nil
			ply.Sprint_Speed = nil

		end

	end]]

	if ( ply:GetCrouching() ) then

		local walk_speed = ply:GetWalkSpeed()

		mv:SetMaxClientSpeed( walk_speed * .5 )
		mv:SetMaxSpeed( walk_speed * .5 )

	end

	local wep = ply:GetActiveWeapon()

	if ( wep != NULL && wep.CW20Weapon && wep.dt.State == CW_AIMING ) then

		mv:SetMaxClientSpeed( mv:GetMaxClientSpeed() * .5 )
		mv:SetMaxSpeed( mv:GetMaxSpeed() * .5 )

	end

end )

hook.Add( "StartCommand", "DisableCrouchJump", function( ply, cmd )

	if ( !ply:Alive() or ply:GTeam() == TEAM_SPEC ) then return end

	if !ply:IsOnGround() and cmd:KeyDown(IN_DUCK) then
		cmd:RemoveKey(IN_DUCK)
	end
end )


local inventory_button = CreateConVar("breach_config_openinventory", KEY_Q, FCVAR_ARCHIVE, "number you will open inventory with")

local duck_offset = Vector( 0, 0, 32 )
local stand_offset = Vector( 0, 0, 64 )

local AllowedModels = {

	["models/cultist/humans/mog/mog.mdl"] = true,
	["models/cultist/humans/chaos/chaos.mdl"] = true,
	["models/cultist/humans/ntf/ntf.mdl"] = true,
	["models/cultist/humans/goc/goc.mdl"] = true,
	["models/cultist/humans/fbi/fbi.mdl"] = true,
	["models/cultist/humans/mog/mog_hazmat.mdl"] = true,
	["models/cultist/humans/mog/mog_jagger.mdl"] = true

}

local hull_min, hull_max = Vector( -16, -16, 0 ), Vector( 16, 16, 38 )

function GM:PlayerButtonDown( ply, button )

	if CLIENT and IsFirstTimePredicted() then
		//local bind = _G[ "KEY_"..string.upper( input.LookupBinding( "+menu" ) or "q" ) ] or 
		local key = input.LookupBinding( "+menu" )

		if LocalPlayer().cantopeninventory then return end

		if ( button == inventory_button:GetInt() ) then

			if ( CanShowEQ() && !IsEQVisible() ) then

				ShowEQ( true )

				RestoreCursorPosition()

			elseif ( IsEQVisible() ) then

				RememberCursorPosition()

				HideEQ()

			end


		end
	end
	
end

function GM:KeyPress(ply, key)

	if ply:GTeam() == TEAM_SPEC and ply:Crouching() then ply:SetCrouching(false) end

	if ( IsFirstTimePredicted() && key == IN_DUCK && !( ply:GTeam() == TEAM_SPEC ) && ply:GetMoveType() == MOVETYPE_WALK && !ply:IsFrozen() ) then


		if ( !ply:Crouching() and ply:GTeam() != TEAM_SCP ) then

			ply:SetCrouching( true )
			ply:SetHull( hull_min, hull_max )
			ply:SetViewOffsetDucked( duck_offset )
			ply:SetViewOffset( duck_offset )

			if ( AllowedModels[ ply:GetModel() ] ) and SERVER then

				ply:EmitSound( "nextoren/charactersounds/foley/posechange_" .. math.random( 1, 6 ) .. ".wav", 75, math.random( 100, 105 ), 1, CHAN_STATIC )

			end

		elseif ( ply:Crouching() && Stance_CanExit( ply ) && !ply:IsFrozen() && ply:GetMoveType() == MOVETYPE_WALK ) then

			ply:SetCrouching( false )
			ply:ResetHull()
			ply:SetViewOffsetDucked( stand_offset )
			ply:SetViewOffset( stand_offset )

			if ( AllowedModels[ ply:GetModel() ] ) and SERVER then

				ply:EmitSound( "nextoren/charactersounds/foley/posechange_" .. math.random( 1, 6 ) .. ".wav", 75, math.random( 90, 95 ), 1, CHAN_STATIC )

			end

		end

	end

end

function GM:PlayerButtonUp( ply, button )
	if CLIENT and IsFirstTimePredicted() then
		//local bind = _G[ "KEY_"..string.upper( input.LookupBinding( "+menu" ) ) ] or KEY_Q
		local key = input.LookupBinding( "+menu" )

		if key then
			if input.GetKeyCode( inventory_button:GetInt() ) == button and IsEQVisible() then
				HideEQ()
			end
		end
	end
end

function mply:HasHazmat()

  if ( string.find( string.lower( self:GetModel() ), "hazmat" ) or self:GetRoleName() == role.DZ_Gas or self:GetRoleName() == role.ClassD_FartInhaler ) then

    return true

  end

  return false

end

------ Конец Инвентаря

function mply:Dado( kind )

	if ( kind == 1 ) then

		local unique_id = "Radiation" .. self:SteamID64()
        local old_name = self:GetNamesurvivor()

		self.TempValues.radiation = true

        timer.Create( unique_id, .25, 0, function()

            if ( !( self && self:IsValid() ) || self:GetNamesurvivor() != old_name || self:GTeam() == TEAM_SPEC || self:Health() <= 0 ) then

                timer.Remove( unique_id )

                return
            end

			if ( ( self.NextParticle || 0 ) < CurTime() ) then

				self.NextParticle = CurTime() + 3
				ParticleEffect( "rgun1_impact_pap_child", self:GetPos(), angle_zero, self )

			end

            for _, v in ipairs( ents.FindInSphere( self:GetPos(), 400 ) ) do

            if ( v:IsPlayer() && v:GTeam() != TEAM_SPEC && v:Health() > 0 ) then

					if ( v:HasHazmat() && v != self ) then return end

					local radiation_info = DamageInfo()
					radiation_info:SetDamageType( DMG_RADIATION )
					radiation_info:SetDamage( 2 )
					radiation_info:SetAttacker( self )
                    radiation_info:SetDamageForce( v:GetAimVector() * 4 )

					if ( v == self ) then

						radiation_info:ScaleDamage( .5 )

					else

						radiation_info:ScaleDamage( 1 * ( 1600 / self:GetPos():DistToSqr( v:GetPos() ) ) )

					end

                    v:TakeDamageInfo( radiation_info )

                end

            end

        end )

	elseif ( kind == 2 ) then

		local unique_id = "FireBlow" .. self:SteamID64()
		local old_name = self:GetNamesurvivor()

		self.TempValues.abouttoexplode = true
		self.TempValues.burnttodeath = true

		timer.Create( unique_id, 10, 1, function()

			if ( !( self && self:IsValid() ) || self:GetNamesurvivor() != old_name || self:GTeam() == TEAM_SPEC || self:Health() <= 0 ) then

				timer.Remove( unique_id )

				return
			end

			if ( SERVER ) then

				local current_pos = self:GetPos()

				self.TempValues.abouttoexplode = nil

				self.TempValues.burnttodeath = true

				local dmg_info = DamageInfo()
				dmg_info:SetDamage( 2000 )
				dmg_info:SetDamageType( DMG_BLAST )
				dmg_info:SetAttacker( self )
				dmg_info:SetDamageForce( -self:GetAimVector() * 40 )

				util.BlastDamageInfo( dmg_info, self:GetPos(), 400 )

				sound.Play("nextoren/others/explosion_ambient_" .. math.random( 1, 2 ) .. ".ogg", current_pos, 100, 100, 100)

				local trigger_ent = ents.Create( "base_gmodentity" )
				trigger_ent:SetPos( current_pos )
				trigger_ent:SetNoDraw( true )
				trigger_ent:DrawShadow( false )
				trigger_ent:Spawn()
				trigger_ent.Die = CurTime() + 50

				net.Start( "CreateParticleAtPos", true )

					net.WriteString( "pillardust" )
					net.WriteVector( current_pos )

				net.Broadcast()

				net.Start( "CreateParticleAtPos", true )

					net.WriteString( "gas_explosion_main" )
					net.WriteVector( current_pos )

				net.Broadcast()

				trigger_ent.OnRemove = function( self )

					self:StopParticles()

				end
				trigger_ent.Think = function( self )

					self:NextThink( CurTime() + .25 )

					if ( self.Die < CurTime() ) then

						self:Remove()

					end

					for _, v in ipairs( ents.FindInSphere( self:GetPos(), 300 ) ) do

						if ( v:IsPlayer() && v:GTeam() != TEAM_SPEC && ( v:GTeam() != TEAM_SCP || !v:GetNoDraw() ) ) then
							
							v:SetOnFire(4)

						end

					end

				end

			end

		end )
    elseif ( kind == 3 ) then
		local unique_id = "Radiation" .. self:SteamID64()
        local old_name = self:GetNamesurvivor()

		self.TempValues.radiation = true

        timer.Create( unique_id, .25, 0, function()

            if ( !( self && self:IsValid() ) || self:GetNamesurvivor() != old_name || self:GTeam() == TEAM_SPEC || self:Health() <= 0 ) then

                timer.Remove( unique_id )

                return
            end

			if ( ( self.NextParticle || 0 ) < CurTime() ) then

				self.NextParticle = CurTime() + 3
				ParticleEffect( "rgun1_impact_pap_child", self:GetPos(), angle_zero, self )

			end

            for _, v in ipairs( ents.FindInSphere( self:GetPos(), 1 ) ) do

            if ( v:IsPlayer() && v:GTeam() != TEAM_SPEC && v:Health() > 0 ) then

					if ( v:HasHazmat() && v != self ) then return end

					local radiation_info = DamageInfo()
					radiation_info:SetDamageType( DMG_RADIATION )
					radiation_info:SetDamage( 25 )
					radiation_info:SetAttacker( self )
                    radiation_info:SetDamageForce( v:GetAimVector() * 1 )


                    v:TakeDamageInfo( radiation_info )

                end

            end

        end )
	elseif ( kind == 4 ) then
		local unique_id = "FireBlow" .. self:SteamID64()
		local old_name = self:GetNamesurvivor()

		self.TempValues.abouttoexplode = true
		self.TempValues.burnttodeath = true

		timer.Create( unique_id, 3, 1, function()

			if ( !( self && self:IsValid() ) || self:GetNamesurvivor() != old_name || self:GTeam() == TEAM_SPEC || self:Health() <= 0 ) then

				timer.Remove( unique_id )

				return
			end

			if ( SERVER ) then

				local current_pos = self:GetPos()

				self.TempValues.abouttoexplode = nil

				self.TempValues.burnttodeath = true

				local dmg_info = DamageInfo()
				dmg_info:SetDamage( 114514 )
				dmg_info:SetDamageType( DMG_BLAST )
				dmg_info:SetAttacker( self )
				dmg_info:SetDamageForce( -self:GetAimVector() * 40 )

				util.BlastDamageInfo( dmg_info, self:GetPos(), 0 )

				sound.Play("nextoren/others/explosion_ambient_" .. math.random( 1, 2 ) .. ".ogg", current_pos, 100, 100, 100)

				local trigger_ent = ents.Create( "base_gmodentity" )
				trigger_ent:SetPos( current_pos )
				trigger_ent:SetNoDraw( true )
				trigger_ent:DrawShadow( false )
				trigger_ent:Spawn()
				trigger_ent.Die = CurTime() + 50

				net.Start( "CreateParticleAtPos", true )

					net.WriteString( "pillardust" )
					net.WriteVector( current_pos )

				net.Broadcast()

				net.Start( "CreateParticleAtPos", true )

					net.WriteString( "gas_explosion_main" )
					net.WriteVector( current_pos )

				net.Broadcast()

				trigger_ent.OnRemove = function( self )

					self:StopParticles()

				end
				trigger_ent.Think = function( self )

					self:NextThink( CurTime() + .25 )

					if ( self.Die < CurTime() ) then

						self:Remove()

					end

				end

			end

		end )
	end

end

function mply:Boosted( kind, timetodie )

	if ( kind == 1 ) then

		if ( self:GetEnergized() ) then

			local current_name = self:GetNamesurvivor()

			net.Start( "ForcePlaySound", true )

				net.WriteString( "nextoren/others/heartbeat_stop.ogg" )

			net.Send( self )

			timer.Simple( 15, function()

				if ( self && self:IsValid() && self:Health() > 0 && self:GetNamesurvivor() == current_name && self:GTeam() != TEAM_SPEC ) then

					self:Kill()

				end

			end )

			return
		end

		self:SetEnergized( true )

		timer.Simple( ( timetodie || 10 ), function()

			if ( self && self:IsValid() && self:Health() > 0 ) then

				self:SetEnergized( false )

			end

		end )

	elseif ( kind == 2 ) then

		if ( self:GetBoosted() ) then return end

		self:SetBoosted( true )

		if self.exhausted then
			self.exhausted = false
			if SERVER then
				self:SetRunSpeed( self.RunSpeed )
				self:SetJumpPower( self.jumppower )
			end
		end

		self:SetWalkSpeed( self:GetWalkSpeed() * 1.3 )
		self:SetRunSpeed( self:GetRunSpeed() * 1.3 )

		timer.Simple( ( timetodie || 10 ), function()

			if ( self && self:IsValid() && self:Alive() ) then

				self:SetBoosted( false )

				self:SetWalkSpeed( math.Round(self:GetWalkSpeed() * 0.77) )
				self:SetRunSpeed( math.Round(self:GetRunSpeed() * 0.77) )

			end

		end )

	elseif ( kind == 3 ) then

		if ( !SERVER ) then return end

		local randomhealth = math.random( 60, 80 )

		self.old_maxhealth = self.old_maxhealth || self:GetMaxHealth()

		local old_name = self:GetNamesurvivor()

		self:SetHealth( math.min(self.old_maxhealth+200, self:Health() + randomhealth) )
		self:SetMaxHealth( math.min(self.old_maxhealth+200, self:GetMaxHealth() + randomhealth) )

		local unique_id = "ReduceHealthByPills" .. self:SteamID64()

		timer.Create( unique_id, 1, self:GetMaxHealth() - self.old_maxhealth, function()

			if ( !( self && self:IsValid() ) ) then timer.Remove( unique_id ) return end

			if ( self:Health() < 2 || !self:Alive() || self:GTeam() == TEAM_SPEC || self:GTeam() == TEAM_SCP || self:GetMaxHealth() == old_maxhealth || self:GetNamesurvivor() != old_name ) then

				self:SetMaxHealth( self.old_maxhealth )
				self.old_maxhealth = nil
				timer.Remove( unique_id )

				return
			end

			self:SetHealth( self:Health() - 1 )
			self:SetMaxHealth( self:GetMaxHealth() - 1 )

			if ( self:GetMaxHealth() == self.old_maxhealth ) then

				self.old_maxhealth = nil

			end

		end )

	elseif ( kind == 4 ) then

		self:SetAdrenaline( true )

		timer.Simple( ( timetodie || 10 ), function()

			if ( self && self:IsValid() ) then

				self:SetAdrenaline( false )

			end

		end )

	elseif ( kind == 5 ) then

		self.WaterDr = true

		timer.Simple( ( timetodie || 10 ), function()

			if ( self && self:IsValid() ) then

				self.WaterDr = false

			end

		end )

	end

end

function mply:GetExp()
	if not self.GetNEXP then
		player_manager.RunClass( self, "SetupDataTables" )
	end
	if self.GetNEXP and self.SetNEXP then
		return self:GetNEXP()
	else
		ErrorNoHalt( "Cannot get the exp, GetNEXP invalid" )
		return 0
	end
end

local box_parameters = Vector( 5, 5, 5 )

net.Receive( "ThirdPersonCutscene", function()

	local time = net.ReadUInt( 4 )
  
	local client = LocalPlayer()
  
	client.ExitFromCutscene = nil
  
	local multiplier = 0
  
	hook.Add( "CalcView", "ThirdPerson", function( client, pos, angles, fov )
  
	  if ( !client.ExitFromCutscene && multiplier != 1 ) then
  
		multiplier = math.Approach( multiplier, 1, RealFrameTime() * 2 )
  
	  elseif ( client.ExitFromCutscene ) then
  
		multiplier = math.Approach( multiplier, 0, RealFrameTime() * 2 )
  
		if ( multiplier < .25 ) then
  
		  hook.Remove( "CalcView", "ThirdPerson" )
		  client.ExitFromCutscene = nil
  
		end
  
	  end
  
	  local offset_eyes = client:LookupAttachment( "eyes" )
	  offset_eyes = client:GetAttachment( offset_eyes )
  
	  if ( offset_eyes ) then
  
		angles = offset_eyes.Ang
  
	  end
  
	  local trace = {}
	  trace.start = offset_eyes && offset_eyes.Pos || pos
	  trace.endpos = trace.start + angles:Forward() * ( -80 * multiplier )
	  trace.filter = client
	  trace.mins = -box_parameters
	  trace.maxs = box_parameters
	  trace.mask = MASK_VISIBLE
  
	  trace = util.TraceLine( trace )
  
	  pos = trace.HitPos
  
	  if ( trace.Hit ) then
  
		pos = pos + trace.HitNormal * 5
  
	  end
  
	  local view = {}
	  view.origin = pos
	  view.angles = angles
	  view.fov = fov
	  view.drawviewer = true
  
	  return view
  
	end )
  
	timer.Simple( time, function()
  
	  client.ExitFromCutscene = true
  
	end )
  
end )

function BreachUtilEffect(effectname, effectdata)
	net.Start("Shaky_UTILEFFECTSYNC", true)
	net.WriteString(effectname)
	net.WriteTable({effectdata})
	net.Broadcast()
end
function BreachParticleEffect(ParticleName, Position, angles, EntityParent)
	if EntityParent == nil then EntityParent = NULL end
	ParticleEffect(ParticleName, Position, angles, EntityParent)
	net.Start("Shaky_PARTICLESYNC", true)
	net.WriteString(ParticleName)
	net.WriteVector(Position)
	net.WriteAngle(angles)
	net.WriteEntity(EntityParent)
	net.Broadcast()
end
function BreachParticleEffectAttach(ParticleName, attachType, entity, attachmentID)
	if EntityParent == nil then EntityParent = NULL end
	ParticleEffectAttach(ParticleName, attachType, entity, attachmentID)
	net.Start("Shaky_PARTICLEATTACHSYNC", true)
	net.WriteString(ParticleName)
	net.WriteUInt(attachtype, 4)
	net.WriteEntity(entity)
	net.WriteUInt(attachmentID, 20)
	net.Broadcast()
end
if CLIENT then
	net.Receive("Shaky_PARTICLESYNC", function(len)
		local ParticleName = net.ReadString()
		local Position = net.ReadVector()
		local angles = net.ReadAngle()
		local EntityParent = net.ReadEntity()
		ParticleEffect(ParticleName, Position, angles, EntityParent)
	end)
	net.Receive("Shaky_UTILEFFECTSYNC", function(len)
		local ParticleName = net.ReadString()
		local EfData = net.ReadTable()[1] || EffectData()
		util.Effect(effectname, EfData)
	end)
	net.Receive("Shaky_PARTICLEATTACHSYNC", function(len)
		local ParticleName = net.ReadString()
		local attachtype = net.ReadUInt(4)
		local entity = net.ReadEntity()
		local attachmentID = net.ReadUInt(20)
		ParticleEffectAttach(ParticleName, attachType, entity, attachmentID)
	end)
end

function mply:GetLevel()
	if not self.GetNLevel then
		player_manager.RunClass( self, "SetupDataTables" )
	end
	if self.GetNLevel and self.SetNLevel then
		return self:GetNLevel()
	else
		ErrorNoHalt( "Cannot get the exp, GetNLevel invalid" )
		return 0
	end
end

function mply:WouldDieFrom( damage, hitpos )

	return self:Health() <= damage

end

function mply:ThrowFromPositionSetZ( pos, force, zmul, noknockdown )

	if ( force == 0 || self.NoThrowFromPosition ) then return false end

	zmul = zmul || .7

	if ( self:IsPlayer() ) then

		force = force * ( self.KnockbackScale || 1 )

	end

	if ( self:GetMoveType() == MOVETYPE_VPHYSICS ) then

		local phys = self:GetPhysicsObject()

		if ( phys:IsValid() && phys:IsMoveable() ) then

			local nearest = self:NearestPoint( pos )
			local dir = nearest - pos
			dir.z = 0
			dir:Normalize()
			dir.z = zmul
			phys:ApplyForceOffset( force * 50 * dir, nearest )

		end

		return true

	elseif ( self:GetMoveType() >= MOVETYPE_WALK && self:GetMoveType() < MOVETYPE_PUSH ) then

		self:SetGroundEntity( NULL )

		local dir = self:LocalToWorld( self:OBBCenter() )
		dir.z = 0
		dir:Normalize()
		dir.z = zmul
		self:SetVelocity( force * dir )

		return true

	end

end

function mply:MeleeViewPunch( damage )

	local maxpunch = ( damage + 25 ) * 0.5
	local minpunch = -maxpunch
	self:ViewPunch( Angle( math.Rand( minpunch, maxpunch ), math.Rand( minpunch, maxpunch ), math.Rand( minpunch, maxpunch ) ) )

end

if SERVER then

	util.AddNetworkString("SetStamina")

	function mply:SetStamina(float)
		net.Start("SetStamina", true)
		net.WriteFloat(float)
		net.WriteBool(false)
		net.Send(self)
	end

	function mply:AddStamina(float)
		net.Start("SetStamina", true)
		net.WriteFloat(float)
		net.WriteBool(true)
		net.Send(self)
	end

end

net.Receive("SetStamina", function()

	local stamina = net.ReadFloat()
	local add = net.ReadBool()

	if !add then
		LocalPlayer().Stamina = stamina
	else
		if LocalPlayer().Stamina == nil then LocalPlayer().Stamina = 100 end
		LocalPlayer().Stamina = LocalPlayer().Stamina + stamina
	end

end)

local cd_stamina = 0
if CLIENT then
	hook.Add("KeyPress", "Stamina_drain", function(ply, press)
		if ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetMoveType() == MOVETYPE_OBSERVER then
			return
		end

		if press == IN_JUMP and ply.Stamina and !ply:Crouching() and ply:IsOnGround() then
			if !ply:GetEnergized() and !ply:GetAdrenaline() then
				cd_stamina = CurTime() + 3
				ply.Stamina = ply.Stamina - 6
			end
		end

	end)
end

function UpdateStamina_Breach(v, cd)
	if !cd then cd = 1.5 end
	LocalPlayer().Stamina = v
	cd_stamina = CurTime() + cd
end

function Sprint( ply, mv )

	if ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetMoveType() == MOVETYPE_OBSERVER then
		return
	end

	if (ply:GTeam() == TEAM_SCP and !ply.SCP035_IsWear) or ply:GTeam() == TEAM_SPEC then
		ply.Stamina = nil
		ply.exhausted = nil
		return
	end
	local pl = ply:GetTable()

	if !pl.LastSysTime then
		pl.LastSysTime = SysTime()
	end
	local n_new = ply:GetStaminaScale()
	local stamina = pl.Stamina
	local maxstamina = n_new*100
	local movetype = ply:GetMoveType()
	local invehicle = ply:InVehicle()
	local energized = ply:GetEnergized()
	local boosted = ply:GetBoosted()
	local adrenaline = ply:GetAdrenaline()
	local plyteam = ply:GTeam()
	local activeweapon = ply:GetActiveWeapon()
	if stamina == nil then pl.Stamina = maxstamina end
	stamina = pl.Stamina

	if stamina > maxstamina then stamina = maxstamina end

	if pl.exhausted then
		if exhausted_cd <= CurTime() then
			pl.exhausted = nil
		end
		--return
	end

	local isrunning = false

	if IsValid(activeweapon) and activeweapon.HoldingBreath then
		stamina = stamina - (SysTime() - pl.LastSysTime) * 8
	end

	if !adrenaline then
		if mv:KeyDown(IN_SPEED) and !( ply:GetVelocity():Length2DSqr() < 0.25 or movetype == MOVETYPE_NOCLIP or movetype == MOVETYPE_LADDER or movetype == MOVETYPE_OBSERVER or invehicle ) and (plyteam != TEAM_SCP or ply.SCP035_IsWear ) and !pl.exhausted then
			if !energized then stamina = stamina - (SysTime() - pl.LastSysTime) * 3.33 end
			cd_stamina = CurTime() + 1.5
			isrunning = true
		end
	end
	if !isrunning and !ply:GetPos():WithinAABox(Vector(-4120.291504, -11427.226563, 38.683075), Vector(1126.214844, -15695.861328, -3422.429688)) then
		if cd_stamina <= CurTime() then
			local add = (SysTime() - pl.LastSysTime) * 7
			if energized then
				add = add *2
			end
			if stamina < 0 then stamina = 0 end
			stamina = math.Approach(stamina, maxstamina, add)
		end
	end

	if isrunning and mv:KeyPressed(IN_JUMP) and IsFirstTimePredicted() then
		stamina = stamina - (SysTime() - pl.LastSysTime) * 15
	end

	if stamina < 0 and !pl.exhausted and !boosted then
		make_bottom_message("我需要喘口气")
		pl.exhausted = true
		exhausted_cd = CurTime() + 7
	end

	pl.LastSysTime = SysTime()


	pl.Stamina = stamina

end

hook.Add("SetupMove", "stamina_new", function(ply, mv)
	if CLIENT then Sprint(ply, mv) end
end)

hook.Add("Move", "LeanSpeed", function(ply, mv)
	if ply:IsLeaning() and CanLean(ply) then
		local speed = ply:GetWalkSpeed() * 0.55
		mv:SetMaxSpeed( speed )
		mv:SetMaxClientSpeed( speed )
	end
end)

hook.Add("CreateMove", "stamina_new", function(mv)
	local ply = LocalPlayer()
	local pl = ply:GetTable()

	if ( pl.exhausted and !pl:GetBoosted() ) or ply:GetInDimension() then
		if mv:KeyDown(IN_SPEED) then
			mv:SetButtons(mv:GetButtons() - IN_SPEED)
		end
		if mv:KeyDown(IN_JUMP) then
			mv:SetButtons(mv:GetButtons() - IN_JUMP)
		end
	end
end)

if CLIENT then
	function mply:DropWeapon( class )
		net.Start( "DropWeapon", true )
			net.WriteString( class )
		net.SendToServer()
	end

	function mply:SelectWeapon( class )
		if ( !self:HasWeapon( class ) ) then return end
		self.DoWeaponSwitch = self:GetWeapon( class )
	end
	
	hook.Add( "CreateMove", "WeaponSwitch", function( cmd )
		if !IsValid( LocalPlayer().DoWeaponSwitch ) then return end

		cmd:SelectWeapon( LocalPlayer().DoWeaponSwitch )

		if LocalPlayer():GetActiveWeapon() == LocalPlayer().DoWeaponSwitch then
			LocalPlayer():GetActiveWeapon().DrawCrosshair = true
			LocalPlayer().DoWeaponSwitch = nil
		end
	end )
end

--[[
hook.Add("KeyPress", "stm_on", function( ply, button )

	if button == IN_SPEED then ply.sprintEnabled = true end

end )



hook.Add("KeyPress", "stmj_on", function( ply, button )

	if button == IN_JUMP then ply.jumped = true end

end )



hook.Add("KeyRelease", "stmj_off", function( ply, button )

	if button == IN_JUMP then ply.jumped = false end

end )



hook.Add("KeyRelease", "stm_off", function( ply, button )

	if button == IN_SPEED then ply.sprintEnabled = false end

end )

function GM:KeyPress(ply, key)

	if ( key == IN_SPEED ) then

		Sprint(ply)

	end

end
--]]