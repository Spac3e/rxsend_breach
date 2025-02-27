local RunConsoleCommand = RunConsoleCommand;
local tonumber = tonumber;
local tostring = tostring;
local CurTime = CurTime;
local Entity = Entity;
local unpack = unpack;
local table = table;
local pairs = pairs;
local concommand = concommand;
local timer = timer;
local ents = ents;
local hook = hook;
local math = math;
local pcall = pcall;
local ErrorNoHalt = ErrorNoHalt;
local DeriveGamemode = DeriveGamemode;
local util = util
local net = net
local player = player
util.AddNetworkString("GASMASK_RequestToggle")
util.AddNetworkString("GASMASK_Remove")
util.AddNetworkString("GASMASK_SendEquippedStatus")

local meta = FindMetaTable("Player")
function meta:GASMASK_RequestToggle()
	net.Start("GASMASK_RequestToggle")
		net.WriteBool(self.GASMASK_Equiped)
	net.Send(self)
	local model
	if self:GTeam() == TEAM_GUARD or self:GetUsingCloth() == "armor_mtf" then
		model = "models/cultist/humans/mog/mask/mask_gasmask.mdl"
	else
		model = "models/gmod4phun/w_contagion_gasmask_equipped.mdl"
	end
	if self.GASMASK_Equiped then
		if self:GTeam() != TEAM_SPEC or self:GTeam() != TEAM_SCP && self:Alive() && self:Health() > 0 then
			if self:GTeam() == TEAM_GUARD or self:GTeam() == TEAM_SECURITY or self:GTeam() == TEAM_CLASSD or self:GTeam() == TEAM_SCI or self:GetRoleName() == role.ClassD_GOCSpy or self:GetRoleName() == role.SCI_SpyDZ or self:GetRoleName() == role.SECURITY_Spy then
			    GhostBoneMerge(self, model)
			elseif self:GetModel() == "models/cultist/humans/obr/obr.mdl" then
				self:SetBodygroup(0, 1)
			end
		end
	elseif !self:HasWeapon("gasmask") then
		if ( self.GhostBoneMergedEnts ) then

			for _, v in ipairs( self.GhostBoneMergedEnts ) do
	
				if ( v && v:IsValid() ) then

					if ( v:GetModel() == model ) then
	
						v:Remove()
					end
				end
			end

		end
		if self:GetModel() == "models/cultist/humans/obr/obr.mdl" then
			self:SetBodygroup(0, 0)
		end

	else
		if ( self.GhostBoneMergedEnts ) then

			for _, v in ipairs( self.GhostBoneMergedEnts ) do
	
				if ( v && v:IsValid() ) then

					if ( v:GetModel() == model ) then
	
						v:Remove()
					end
				end
			end

		end
		if self:GetModel() == "models/cultist/humans/obr/obr.mdl" then
			self:SetBodygroup(0, 0)
		end
	end
end

function meta:GASMASK_SetEquipped(b)
	self.GASMASK_Equiped = b
	net.Start("GASMASK_SendEquippedStatus")
		net.WriteBool(b)
	net.Send(self)
end

hook.Add("PlayerSpawn", "GASMASK_PlayerSpawn", function(ply)
	ply.GASMASK_Ready = true
	ply:GASMASK_SetEquipped(false)
end)

hook.Add("PostPlayerDeath", "GASMASK_PostDeath", function(ply)
	ply:GASMASK_SetEquipped(false)
end)

local gasmask_class = "gasmask"
concommand.Add("g4p_gasmask_toggle", function(ply)
	if !ply.GASMASK_Ready then return end

	local wep = ply:GetActiveWeapon()
	if !IsValid(wep) then return end
	
	if wep:GetClass() != gasmask_class then
		if !ply.GASMASK_SpamDelay or ply.GASMASK_SpamDelay < CurTime() then
			ply.GASMASK_SpamDelay = CurTime() + 0.75
			ply.GASMASK_LastWeapon = wep
			ply:StripWeapon(gasmask_class)
			ply:SetSuppressPickupNotices(true)
			ply:Give(gasmask_class).GASMASK_SignalForDeploy = true
			ply:SetSuppressPickupNotices(false)
			ply:SelectWeapon(gasmask_class)
		end
	end
end)

local dmgtypes = {
	["DMG_GENERIC"] = DMG_GENERIC,
	["DMG_CRUSH"] = DMG_CRUSH,
	["DMG_BULLET"] = DMG_BULLET,
	["DMG_SLASH"] = DMG_SLASH,
	["DMG_BURN"] = DMG_BURN,
	["DMG_VEHICLE"] = DMG_VEHICLE,
	["DMG_FALL"] = DMG_FALL,
	["DMG_BLAST"] = DMG_BLAST,
	["DMG_CLUB"] = DMG_CLUB,
	["DMG_SHOCK"] = DMG_SHOCK,
	["DMG_SONIC"] = DMG_SONIC,
	["DMG_ENERGYBEAM"] = DMG_ENERGYBEAM,
	["DMG_PREVENT_PHYSICS_FORCE"] = DMG_PREVENT_PHYSICS_FORCE,
	["DMG_NEVERGIB"] = DMG_NEVERGIB,
	["DMG_ALWAYSGIB"] = DMG_ALWAYSGIB,
	["DMG_DROWN"] = DMG_DROWN,
	["DMG_PARALYZE"] = DMG_PARALYZE,
	["DMG_NERVEGAS"] = DMG_NERVEGAS,
	["DMG_POISON"] = DMG_POISON,
	["DMG_RADIATION"] = DMG_RADIATION,
	["DMG_DROWNRECOVER"] = DMG_DROWNRECOVER,
	["DMG_ACID"] = DMG_ACID,
	["DMG_SLOWBURN"] = DMG_SLOWBURN,
	["DMG_REMOVENORAGDOLL"] = DMG_REMOVENORAGDOLL,
	["DMG_PHYSGUN"] = DMG_PHYSGUN,
	["DMG_PLASMA"] = DMG_PLASMA,
	["DMG_AIRBOAT"] = DMG_AIRBOAT,
	["DMG_DISSOLVE"] = DMG_DISSOLVE,
	["DMG_BLAST_SURFACE"] = DMG_BLAST_SURFACE,
	["DMG_DIRECT"] = DMG_DIRECT,
	["DMG_BUCKSHOT"] = DMG_BUCKSHOT,
	["DMG_SNIPER"] = DMG_SNIPER,
	["DMG_MISSILEDEFENSE"] = DMG_MISSILEDEFENSE
}

local function CheckDMGTypes(dmginfo)
	print(dmginfo:GetDamageType())
	print("Damage types included:")
	for name, dmgtype in pairs(dmgtypes) do
		if dmginfo:IsDamageType(dmgtype) then
			print(name)
		end
	end
end
