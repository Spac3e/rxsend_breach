if not CustomizableWeaponry then return end

AddCSLuaFile()
AddCSLuaFile("sh_soundscript.lua")
include("sh_soundscript.lua")

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "M34 WP Grenade"

	SWEP.SelectIcon = surface.GetTextureID("vgui/inventory/weapon_nam_m34")

	SWEP.AttachmentModelsVM = {}
	SWEP.AttachmentModelsWM = {}

	SWEP.HUD_3D2DBone = 56
end

SWEP.Attachments = CustomizableWeaponry_KK.ins2.slowGrenadeMenu

SWEP.CanRestOnObjects = false
SWEP.projectileClass = "cw_kk_ins2_projectile_anm14"

SWEP.Animations = {
	pullpin = "pullbackhigh",
	throw = "throw",

	pull_cook = "pullbackhighbake",
	throw_cook = "bakethrow",

	pull_short = "pullbacklow",
	throw_short = "lowthrow",

	base_pickup = "base_draw",
	base_draw = "base_draw",
	base_idle = "base_idle",
	base_holster = "base_holster",
	base_sprint = "base_sprint",
	base_safe = "base_down",
	base_crawl = "base_crawl",
}

SWEP.SpeedDec = 5

SWEP.Slot = 4
SWEP.SlotPos = 0
SWEP.NormalHoldType = "grenade"
SWEP.RunHoldType = "normal"
SWEP.FireModes = {"semi"}
SWEP.Base = "cw_kk_ins2_base_nade"
SWEP.Category = "CW 2.0 KK INS2 B2K"

SWEP.Author			= "Spy"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 80
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_nam_m34.mdl"
SWEP.WorldModel		= "models/weapons/w_nam_m34.mdl"

SWEP.WMPos = Vector(3.891, 2.295, -1.765)
SWEP.WMAng = Angle(-28.962, 155.365, 180)

SWEP.CW_GREN_TWEAK = CustomizableWeaponry_KK.ins2.quickGrenade.models.m26
SWEP.CW_KK_KNIFE_TWEAK = CustomizableWeaponry_KK.ins2.quickKnife.models.b2kus
SWEP.CW_KK_40MM_MDL = "models/weapons/w_grenade_kar98k.mdl"

SWEP.Spawnable			= CustomizableWeaponry_KK.ins2.isContentMounted4(SWEP)
SWEP.AdminSpawnable		= CustomizableWeaponry_KK.ins2.isContentMounted4(SWEP)

SWEP.Primary.Ammo			= "Incendiary"

SWEP.fuseTime = 1.8

SWEP.timeToThrow = 0.9

SWEP.timeToThrowCook = 1.3

SWEP.timeToThrowShort = 0.9
