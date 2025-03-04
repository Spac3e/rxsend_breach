if not CustomizableWeaponry then return end

AddCSLuaFile()
AddCSLuaFile("sh_sounds.lua")
AddCSLuaFile("sh_soundscript.lua")
include("sh_sounds.lua")
include("sh_soundscript.lua")

SWEP.magType = "pistolMag"

if CLIENT then
	SWEP.DrawCrosshair = false
	SWEP.PrintName = "Баллистический щит с пистолетом"
	SWEP.CSMuzzleFlashes = true

	SWEP.Shell = "KK_INS2_45apc"
	SWEP.ShellDelay = 0.06

	SWEP.InvIcon = Material( "nextoren/gui/icons/shield.png" )

	SWEP.ShellViewAngleAlign = {Forward = 0, Right = 0, Up = 180}
	SWEP.AttachmentModelsVM = {
		["kk_ins2_suppressor_pistol"] = {model = "models/weapons/upgrades/a_suppressor_pistol.mdl", pos = Vector(), angle = Angle(0, 90, 0), size = Vector(1, 1, 1), merge = true},

		--["kk_ins2_mag_m45_8"] = {model = "models/weapons/glock/a_magazine_glock_standard.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true, active = true},
		--["kk_ins2_mag_m45_15"] = {model = "models/weapons/glock/a_magazine_glock_extended.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true},

		["kk_ins2_lam"] = {model = "models/weapons/upgrades/a_laser_m9.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true},
		["kk_ins2_flashlight"] = {model = "models/weapons/upgrades/a_flashlight_m9.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true},
		["kk_ins2_flashlight_legacy"] = {model = "models/weapons/upgrades/a_flashlight_m9.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true},
		["kk_ins2_m6x"] = {model = "models/weapons/attachments/v_cw_kk_ins2_cstm_m6x.mdl", bone = "Weapon", pos = Vector(0, 1.455, -1.25), angle = Angle(0, -90, 0), size = Vector(0.85, 0.85, 0.85)},

		["kk_ins2_m6x_rail"] = {model = "models/cw2/attachments/lowerpistolrail.mdl", bone = "Weapon", pos = Vector(0, 1.171, -0.594), angle = Angle(0, 90, 0), size = Vector(0.109, 0.109, 0.109),
			material = "models/weapons/attachments/cw_kk_ins2_cstm_m6x/rail_bk",
		},
	}

	SWEP.AttachmentModelsWM = {
		["kk_ins2_suppressor_pistol"] = {model = "models/weapons/upgrades/w_sil_pistol.mdl", pos = Vector(), angle = Angle(0, 90, 0), size = Vector(1, 1, 1), merge = true},

		["kk_ins2_mag_m45_8"] = {model = "models/weapons/glock/w_glockmag.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true, active = true},
		["kk_ins2_mag_m45_15"] = {model = "models/weapons/glock/w_glockextmag.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true},

		["kk_ins2_lam"] = {model = "models/weapons/upgrades/w_laser_sec.mdl", pos = Vector(), angle = Angle(0, 180, 0), size = Vector(1, 1, 1), merge = true},
		["kk_ins2_flashlight"] = {model = "models/weapons/upgrades/w_laser_sec.mdl", pos = Vector(), angle = Angle(), size = Vector(1, 1, 1), merge = true},
	}
	SWEP.IronsightPos = Vector(-2.5384, 0, 0.8609)
	SWEP.IronsightAng = Vector(-0.2183, 0.0035, 0)

	SWEP.CustomizationMenuScale = 0.01
	SWEP.ReloadViewBobEnabled = false
	SWEP.DisableSprintViewSimulation = true
end

SWEP.MuzzleEffect = "muzzleflash_m9_1p_core"
SWEP.MuzzleEffectWorld = "muzzleflash_m9_3rd"

SWEP.Attachments = {
	{header = "Lasers", offset = {500, -400}, atts = {"kk_ins2_lam", "kk_ins2_flashlight", "kk_ins2_m6x"}},
	{header = "Barrel", offset = {-500, -400}, atts = {"kk_ins2_suppressor_pistol"}},
	{header = "Magazine", offset = {-500, 150}, atts = {"kk_ins2_mag_m45_15"}},
	--["+reload"] = {header = "Ammo", offset = {500, 150}, atts = {"am_magnum", "am_matchgrade"}}
}

SWEP.Animations = {
	base_pickup = "base_ready",
	base_draw = "base_draw",
	base_draw_empty = "empty_draw",
	base_fire = {"base_fire","base_fire2","base_fire3"},
	base_fire_aim = "iron_fire",
	base_fire_last = "base_firelast",
	base_fire_last_aim = "iron_fire_last",
	base_fire_empty = "base_dryfire",
	base_fire_empty_aim = "iron_dryfire",
	base_reload = "base_reload",
	base_reload_empty = "base_reload_empty",
	base_reload_mm = "base_reload_extmag",
	base_reload_empty_mm = "base_reload_empty_extmag",
	base_idle = "base_idle",
	base_idle_empty = "empty_idle",
	base_holster = "base_holster",
	base_holster_empty = "empty_holster",
	base_sprint = "base_sprint",
	base_sprint_empty = "empty_sprint",
	base_safe = "base_down",
	base_safe_empty = "empty_down",
	base_safe_aim = "iron_down",
	base_safe_empty_aim = "empty_down",
	base_crawl = "base_crawl",
	base_crawl_empty = "empty_crawl",
}

SWEP.SpeedDec = 10

SWEP.Slot = 1
SWEP.SlotPos = 0
SWEP.NormalHoldType = "shield"
SWEP.RunHoldType = "shield"
SWEP.FireModes = {"semi"}
SWEP.Base = "cw_kk_ins2_base"
SWEP.Category = "CW BREACH READY"

SWEP.Author			= "Spy"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 70
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/usp/v_usp.mdl"
SWEP.WorldModel		= "models/weapons/usp/w_usp.mdl"

SWEP.WMPos = Vector(5.309, 1.623, -1.616)
SWEP.WMAng = Vector(-3, -5, 180)

SWEP.Spawnable			= CustomizableWeaponry_KK.ins2.isContentMounted4(SWEP)
SWEP.AdminSpawnable		= CustomizableWeaponry_KK.ins2.isContentMounted4(SWEP)

SWEP.Primary.ClipSize		= 12
SWEP.Primary.DefaultClip = 0 --	= 0
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Pistol"

SWEP.FireDelay = 60/600
SWEP.FireSound = "CW_KK_INS2_M45_FIRE"
SWEP.FireSoundSuppressed = "CW_KK_INS2_M45_FIRE_SUPPRESSED"
SWEP.Recoil = 1

SWEP.HipSpread = 0.04
SWEP.AimSpread = 0.013
SWEP.VelocitySensitivity = 1.25
SWEP.MaxSpreadInc = 0.036
SWEP.SpreadPerShot = 0.0125
SWEP.SpreadCooldown = 0.22
SWEP.Shots = 1
SWEP.Damage = 21

SWEP.FirstDeployTime = 1.3
SWEP.DeployTime = 0.4
SWEP.HolsterTime = 0.4

SWEP.CanRestOnObjects = false
SWEP.WeaponLength = 16

SWEP.KK_INS2_EmptyIdle = true

SWEP.MuzzleVelocity = 244

SWEP.ReloadTimes = {
	base_reload = {2, 2.6},
	base_reload_empty = {2, 2.8},
	base_reload_extmag = {2, 2.6},
	base_reload_empty_extmag = {2, 2.8},
}

function SWEP:CreateShield()

    if ( self.Shield && self.Shield:IsValid() ) then return end

	self.Shield = ents.Create("scp_2012_shield");
	self.Shield:Spawn(); 
	
	local nothand = false;

	local attach = self.Owner:LookupAttachment("anim_attachment_LH");
	
	local up = -14;
	local forward = -8;
	local right = -11;
	
	local aforward = 0;
	local aup = 270;


	local attachTable = self.Owner:GetAttachment(attach);
	self.Shield:SetPos(attachTable.Pos + attachTable.Ang:Up()*up + attachTable.Ang:Forward()*forward + attachTable.Ang:Right()*right);
	attachTable.Ang:RotateAroundAxis(attachTable.Ang:Forward(),aforward);
	attachTable.Ang:RotateAroundAxis(attachTable.Ang:Up(),aup);
	self.Shield:SetAngles( attachTable.Ang );
	self.Shield:SetCollisionGroup( COLLISION_GROUP_WORLD );
	self.Shield:SetParent(self.Owner,attach);
		

end
