AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("ForbidTalant")
util.AddNetworkString("Ability_ClientsideCooldown")

function SWEP:Cooldown(abil, cd)

	self.AbilityIcons[abil].CooldownTime = CurTime() + cd

	net.Start("Ability_ClientsideCooldown")
	net.WriteUInt(abil, 4)
	net.WriteFloat(cd)
	net.WriteEntity(self)
	net.Send(self.Owner)

end