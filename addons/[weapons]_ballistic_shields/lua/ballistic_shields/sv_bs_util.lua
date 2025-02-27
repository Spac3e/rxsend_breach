if CLIENT then return end
util.AddNetworkString( "bs_shield_info" )

function bshield_remove(ply)
	if(!IsValid(ply.bs_shield)) then return end
	ply.bs_type = 0
	ply.bs_shield:Remove()
end
                                                 
hook.Add( "EntityTakeDamage", "bshields_reduce_damage", function( ent, dmginfo )
	if !ent:IsPlayer() then return end
	if ( ent.bs_type == 1 ) then
		if(dmginfo:IsExplosionDamage()) then dmginfo:ScaleDamage( 1 - bshields.config.hshieldexpl/100 ) end
		if(dmginfo:IsDamageType(DMG_CRUSH) || dmginfo:IsDamageType(DMG_CLUB) || dmginfo:IsDamageType(DMG_SLASH)) then dmginfo:ScaleDamage( 1 - bshields.config.hshieldmelee/100 ) return end
	end
	if ( ent.bs_type == 3 ) then
		if(dmginfo:IsDamageType(DMG_CRUSH) || dmginfo:IsDamageType(DMG_CLUB) || dmginfo:IsDamageType(DMG_SLASH)) then dmginfo:ScaleDamage( 1 - bshields.config.rshieldmelee/100 ) return end
	end
end )

hook.Add( "PlayerSpawn", "bshields_hshield_init", function(ply)
	ply.allowhshield = true
end)

hook.Add( "PlayerInitialSpawn", "bshields_init_dshields", function(ply)
	ply.bs_shields = {}
end)

hook.Add( "AllowPlayerPickup", "bshields_disable_pickup", function(ply)
	if(IsValid(ply.bs_shield)) then return false end
end)

hook.Add( "PlayerDeath", "bshields_death", function(ply)
	bshield_remove(ply)
end)

hook.Add( "onDarkRPWeaponDropped", "bshields_drop", function(ply, wep, owep)
	bshield_remove(ply)
end)

hook.Add("CW_canPenetrate", "bshield_cw_penetration", function(ent)
	if (ent:GetModel() == "models/bshields/dshield.mdl" || ent:GetModel() == "models/weapons/shield/w_shield.mdl" || ent:GetModel() == "models/bshields/dshield_open.mdl" || (ent:GetModel() == "models/bshields/rshield.mdl" && bshields.config.rshieldbp)) then 
		return false
	end
end)

local function RemoveDeployedShields(ply)
	if(!IsValid(ply)) then return end
	if(ply.bs_shields==nil) then return end
	for _, v in pairs(ply.bs_shields) do
		if(IsValid(v)) then v:Remove() end
	end
end

hook.Add( "PlayerDisconnected", "bshields_remove_dshields", RemoveDeployedShields(ply))
hook.Add( "OnPlayerChangedTeam", "bshields_change_job",	function(ply) 
	if(bshields.config.removeonjobchange) then RemoveDeployedShields(ply) end
end)