if not CustomizableWeaponry then return end

AddCSLuaFile()
AddCSLuaFile("sh_sounds.lua")
AddCSLuaFile("sh_soundscript.lua")
include("sh_sounds.lua")
include("sh_soundscript.lua")

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "M24 HE Grenade"
	SWEP.CSMuzzleFlashes = true

	SWEP.IconLetter = "O"

	SWEP.AttachmentModelsVM = {
		["kk_ins2_ww2_nade_jackit"] = {model = "models/weapons/v_splintering_stielhandgranate.mdl", pos = Vector(0, 0, 0), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), merge = true, hideVM = true},
	}

	SWEP.AttachmentModelsWM = {}

	SWEP.MoveType = 2
	SWEP.ViewModelMovementScale = 0.8
	SWEP.DisableSprintViewSimulation = true

	SWEP.HUD_3D2DOffset = Vector(-1, 3, 0)
	SWEP.HUD_3D2DOffsetMenu = Vector(-8, 6, 0)
	SWEP.CustomizationMenuScale = 0.006
end

SWEP.Attachments = {
	{header = "Clothing", offset = {0, 0}, atts = {"kk_ins2_ww2_nade_jackit"}}
}

SWEP.CanRestOnObjects = false
SWEP.projectileClass = "cw_kk_ins2_projectile_frag"

SWEP.Animations = {
	pullpin = "pullbackhigh",
	throw = "throw",

	pull_cook = "pullbackhighbake",
	throw_cook = "bakethrow",

	pull_short = "pullbacklow",
	throw_short = "lowthrow",

	base_pickup = "draw",
	base_draw = "draw",
	base_idle = "idle",
	base_holster = "holster",
	base_sprint = "sprint",
	base_safe = "down",
	base_crawl = "crawl",
}

SWEP.SpeedDec = 5

SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.NormalHoldType = "grenade"
SWEP.RunHoldType = "normal"
SWEP.FireModes = {"semi"}
SWEP.Base = "cw_kk_ins2_base_nade"
SWEP.Category = "(GERMAN) WW2"

SWEP.Author			= "Spy"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/cw_kk_doi/v_stielhandgranate.mdl"
SWEP.WorldModel		= "models/weapons/w_stielhandgranate.mdl"

SWEP.WMPos = Vector(3.891, 2.295, -1.765)
SWEP.WMAng = Angle(-28.962, 155.365, 180)

SWEP.CW_KK_KNIFE_TWEAK = CustomizableWeaponry_KK.ins2.quickKnife.models.ww2de

SWEP.Spawnable			= CustomizableWeaponry_KK.ins2.isContentMounted4(SWEP)
SWEP.AdminSpawnable		= CustomizableWeaponry_KK.ins2.isContentMounted4(SWEP)

SWEP.Primary.Ammo			= "Frag Grenades"

SWEP.HolsterTime = 0.6

SWEP.fuseTime = 5

SWEP.timeToThrow = 1.2
SWEP.spawnTime = 0.95
SWEP.swapTime = 1.4
SWEP.maxVelDelay = 1.5

SWEP.spoonTime = 44/35.2
SWEP.timeToThrowCook = 1.5
SWEP.maxVelDelayCook = 1.8

SWEP.timeToThrowShort = 1.2
SWEP.spawnTimeShort = 0.65
SWEP.swapTimeShort = 1.3
SWEP.maxVelDelayShort = 1.5


if CLIENT then
	local att = CustomizableWeaponry.registeredAttachmentsSKey["kk_ins2_ww2_nade_jackit"]

	CustomizableWeaponry_KK.ins2.welementThink:add("cw_kk_ins2_doi_nade_m24", function(wep, welement)
		welement:SetBodygroup(1, wep.dt.PinPulled and 0 or 1)

		if wep.ActiveAttachments[att.name] then
			if welement:GetModel() != att.activeWM then
				welement:SetModel(att.activeWM)
			end
		else
			if welement:GetModel() != att.origWM then
				welement:SetModel(att.origWM)
			end
		end
	end)
end
