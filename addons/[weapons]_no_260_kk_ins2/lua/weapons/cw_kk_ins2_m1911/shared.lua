--[[
lua/weapons/cw_kk_ins2_m1911/shared.lua
--]]
if not CustomizableWeaponry then return end

AddCSLuaFile()
AddCSLuaFile("sh_sounds.lua")
AddCSLuaFile("sh_soundscript.lua")
include("sh_sounds.lua")
include("sh_soundscript.lua")

SWEP.magType = "pistolMag"

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "M1911"
	SWEP.CSMuzzleFlashes = true
	SWEP.InvIcon = Material( "nextoren/gui/icons/weapons/colt.png" )

	SWEP.SelectIcon = surface.GetTextureID("vgui/entities/m1911")

	SWEP.Shell = "KK_INS2_45apc"
	SWEP.ShellDelay = 0.07

	SWEP.ShellViewAngleAlign = {Forward = 0, Right = 0, Up = 180}

	SWEP.AttachmentModelsVM = {
		["kk_ins2_mag_m1911_8"] = {model = "models/weapons/upgrades/a_magazine_1911_8.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true, active = true},
		["kk_ins2_mag_m1911_15"] = {model = "models/weapons/upgrades/a_magazine_1911_15.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true},

		["kk_ins2_suppressor_pistol"] = {model = "models/weapons/upgrades/a_suppressor_pistol.mdl", pos = Vector(), angle = Angle(0, 90, 0), size = Vector(1, 1, 1), merge = true},

		["kk_ins2_lam"] = {model = "models/weapons/upgrades/a_laser_mak.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true},
		["kk_ins2_flashlight"] = {model = "models/weapons/upgrades/a_flashlight_mak.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true},
		["kk_ins2_m6x"] = {model = "models/weapons/attachments/v_cw_kk_ins2_cstm_m6x.mdl", bone = "Weapon", pos = Vector(0.004, 1.105, -1.175), angle = Angle(0, -90, 0), size = Vector(0.8, 0.8, 0.8)},

		["kk_ins2_m6x_rail"] = {model = "models/cw2/attachments/lowerpistolrail.mdl", bone = "Weapon", pos = Vector(0.006, 0.765, -0.561), angle = Angle(0, 90, 0), size = Vector(0.105, 0.105, 0.105),
			material = "models/weapons/attachments/cw_kk_ins2_cstm_m6x/rail_gy",
		},
	}

	SWEP.AttachmentModelsWM = {
		["kk_ins2_suppressor_pistol"] = {model = "models/weapons/upgrades/w_sil_pistol.mdl", pos = Vector(), angle = Angle(0, 90, 0), size = Vector(1, 1, 1), merge = true},
		["kk_ins2_mag_m1911_8"] = {model = "models/weapons/upgrades/w_magazine_1911_8.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true, active = true},
		["kk_ins2_mag_m1911_15"] = {model = "models/weapons/upgrades/w_magazine_1911_15.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true},

		["kk_ins2_lam"] = {model = "models/weapons/upgrades/w_laser_sec.mdl", pos = Vector(), angle = Angle(0, 180, 0), size = Vector(1, 1, 1), merge = true},
		["kk_ins2_flashlight"] = {model = "models/weapons/upgrades/w_laser_sec.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true},
	}

	SWEP.IronsightPos = Vector(-1.859, 0, 0.3468)
	SWEP.IronsightAng = Vector(0.3062, -0.0054, 0)

	SWEP.CustomizationMenuScale = 0.01
	SWEP.ReloadViewBobEnabled = false
	SWEP.DisableSprintViewSimulation = true
end

SWEP.MuzzleEffect = "muzzleflash_m9_1p_core"
SWEP.MuzzleEffectWorld = "muzzleflash_m9_3rd"

SWEP.Attachments = {
	{header = "Lasers", offset = {500, -400}, atts = {"kk_ins2_lam", "kk_ins2_flashlight", "kk_ins2_m6x"}},
	{header = "Barrel", offset = {-500, -400}, atts = {"kk_ins2_suppressor_pistol"}},
	{header = "Magazine", offset = {-500, 150}, atts = {"kk_ins2_mag_m1911_15"}},
	--["+reload"] = {header = "Ammo", offset = {500, 150}, atts = {"am_magnum", "am_matchgrade"}}
}

SWEP.Animations = {
	base_pickup = "base_ready",
	base_draw = "base_draw",
	base_draw_empty = "empty_draw",
	base_fire = {"base_fire","base_fire2","base_fire3"},
	base_fire_aim = {"iron_fire_1","iron_fire_2","iron_fire_3"},
	base_fire_last = "base_firelast",
	base_fire_last_aim = "iron_firelast",
	base_fire_empty = "base_dryfire",
	base_fire_empty_aim = "iron_dryfire",
	base_reload = "base_reload",
	base_reload_mm = "base_reload_extmag",
	base_reload_empty = "base_reloadempty",
	base_reload_empty_mm = "base_reloadempty_extmag",
	base_idle = "base_idle",
	base_idle_empty = "empty_idle",
	base_holster = "base_holster",
	base_holster_empty = "empty_holster",
	base_sprint = "base_sprint",
	base_sprint_empty = "empty_sprint",
	base_safe = "base_down",
	base_safe_empty = "empty_down",
	base_safe_aim = "iron_down",
	base_safe_empty_aim = "empty_iron_down",
	base_crawl = "base_crawl",
	base_crawl_empty = "empty_crawl",
}

SWEP.SpeedDec = 10

SWEP.Slot = 1
SWEP.SlotPos = 0
SWEP.NormalHoldType = "revolver"
SWEP.RunHoldType = "normal"
SWEP.FireModes = {"semi"}
SWEP.Base = "cw_kk_ins2_base"
SWEP.Category = "CW 2.0 KK INS2"

SWEP.Author			= "Spy"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 80
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_cw_kk_ins2_m1911.mdl"
SWEP.WorldModel		= "models/weapons/w_cw_kk_ins2_m1911.mdl"

SWEP.WMPos = Vector(5.309, 1.623, -1.616)
SWEP.WMAng = Vector(-3, -5, 180)

SWEP.CW_GREN_TWEAK = CustomizableWeaponry_KK.ins2.quickGrenade.models.f1
SWEP.CW_KK_KNIFE_TWEAK = CustomizableWeaponry_KK.ins2.quickKnife.models.gurkha

SWEP.Spawnable			= CustomizableWeaponry_KK.ins2.isContentMounted4(SWEP)
SWEP.AdminSpawnable		= CustomizableWeaponry_KK.ins2.isContentMounted4(SWEP)

SWEP.Primary.ClipSize		= 7
SWEP.Primary.DefaultClip = 0 --	= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Pistol"

SWEP.FireDelay = 0.129
SWEP.FireSound = "CW_KK_INS2_M1911_FIRE"
SWEP.FireSoundSuppressed = "CW_KK_INS2_M1911_FIRE_SUPPRESSED"
SWEP.Recoil = 1

SWEP.HipSpread = 0.04
SWEP.AimSpread = 0.01
SWEP.VelocitySensitivity = 1.25
SWEP.MaxSpreadInc = 0.036
SWEP.SpreadPerShot = 0.0125
SWEP.SpreadCooldown = 0.18
SWEP.Shots = 1
SWEP.Damage = 39

SWEP.FirstDeployTime = 1.3
SWEP.DeployTime = 0.4
SWEP.HolsterTime = 0.4

SWEP.CanRestOnObjects = false
SWEP.WeaponLength = 16

SWEP.KK_INS2_EmptyIdle = true

SWEP.MuzzleVelocity = 251

SWEP.ReloadTimes = {
	base_reload = {2, 2.65},
	base_reloadempty = {2, 2.65},
	base_reload_extmag = {2, 2.65},
	base_reloadempty_extmag = {2, 2.65},
}

if CLIENT then
	function SWEP:updateStandardParts()
		self:setElementActive("kk_ins2_mag_m1911_8", !self.ActiveAttachments.kk_ins2_mag_m1911_15)
	end
end


