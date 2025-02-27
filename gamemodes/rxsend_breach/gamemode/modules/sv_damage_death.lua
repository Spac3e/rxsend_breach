concommand.Add("toggledamage", function(ply, cmd, args, argstr)
	if !ply:IsSuperAdmin() then return end

	if ply.NoDamage == nil then
		ply.NoDamage = false
	end

	ply.NoDamage = !ply.NoDamage

	local msg = ""

	if ply.NoDamage then
		msg = "true"
	else
		msg = "false"
	end

	ply:RXSENDNotify("nodamage state: "..msg)
end)

function GM:HandlePlayerArmorReduction( ply, dmginfo )

	-- If no armor, or special damage types, bypass armor 
	if ( ply:Armor() <= 0 || bit.band( dmginfo:GetDamageType(), DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION ) != 0 ) then return end

	local flBonus = 1.0 -- Each Point of Armor is worth 1/x points of health
	local flRatio = 0.2 -- Armor Takes 80% of the damage

	local flNew = dmginfo:GetDamage() * flRatio
	local flArmor = (dmginfo:GetDamage() - flNew) * flBonus

	-- Does this use more armor than we have?
	if ( flArmor > ply:Armor() ) then

		flArmor = ply:Armor() * ( 1 / flBonus )
		flNew = dmginfo:GetDamage() - flArmor
		ply:SetArmor( 0 )

	else
		ply:SetArmor( ply:Armor() - flArmor )
	end

	dmginfo:SetDamage( flNew )

end

concommand.Add("togglereward", function(ply, cmd, args, argstr)
	if !ply:IsSuperAdmin() then return end

	if ply.NoRewardsForKill == nil then
		ply.NoRewardsForKill = false
	end
	
	ply.NoRewardsForKill = !ply.NoRewardsForKill
	
	local msg = ""
	
	if ply.NoRewardsForKill then
		msg = "true"
	else
		msg = "false"
	end

	ply:RXSENDNotify("noreward state: "..msg)
end)

local specialsoundnamescp = {
	["SCP8602"] = "860",
	["SCP062DE"] = "062de",
	["SCP062FR"] = "062fr",
	["SCP973"] = "937",
}

concommand.Add("vstal", function(callply, cmd, args, argstr)
	if !callply:IsSuperAdmin() then return end

	callply:LagCompensation(true)
	local body = callply:GetEyeTrace().Entity
	local ply = body:GetOwner()
	timer.Remove( "PlayerDeathFromBleeding" .. ply:SteamID64() )

		ply:SetupNormal()
		ply:SetModel(body:GetModel())
		ply:SetSkin(body:GetSkin())
		ply:SetGTeam(body.__Team)
		ply:SetRoleName(body.Role)
		ply:SetMaxHealth(body.__Health) 
		ply:SetHealth(ply:GetMaxHealth())
		ply:SetUsingCloth(body.Cloth)
		ply:SetNamesurvivor(body.__Name)
		ply.OldSkin = body.OldSkin
		ply.OldModel = body.OldModel
		ply.OldBodygroups = body.OldBodygroups
		ply:SetWalkSpeed(body.WalkSpeed)
		ply:SetRunSpeed(body.RunSpeed)
		ply:SetupHands()
		--ply:SetNWAngle("ViewAngles", ply:GetAngles())
		timer.Remove("Death_Scene"..ply:SteamID())
		ply:SetPos( Vector(body:GetPos().x, body:GetPos().y, GroundPos(body:GetPos()).z) )
		if istable(body.AmmoData) then
			for ammo, amount in pairs(body.AmmoData) do
				ply:SetAmmo(amount, ammo)
			end
		end

		if body.AbilityTable != nil then
			ply:SetNWString("AbilityName", body.AbilityTable[1])
			net.Start("SpecialSCIHUD")
		        net.WriteString(body.AbilityTable[1])
			    net.WriteUInt(body.AbilityTable[2], 9)
			    net.WriteString(body.AbilityTable[3])
			    net.WriteString(body.AbilityTable[4])
			    net.WriteBool(body.AbilityTable[5])
		    net.Send(ply)

		    ply:SetSpecialCD(body.AbilityCD)
		    ply:SetSpecialMax(body.AbilityMax)

		end
		--ply:BreachGive("br_holster")


		--if body.vtable and body.vtable.Weapons then
		for _, v in pairs(body.vtable.Weapons) do
			if weapons.GetStored(v) then
				ply:BreachGive(v)
			end
		end
		--else
			ply:BreachGive("br_holster")
		--end

		for _, bnmrg in pairs(body:LookupBonemerges()) do
			local bnmrg_ent = Bonemerge(bnmrg:GetModel(), ply)
			bnmrg_ent:SetSubMaterial(0, bnmrg:GetSubMaterial(0))
			bnmrg_ent:SetSubMaterial(2, bnmrg:GetSubMaterial(2))
		end

		for i = 0, 9 do
			ply:SetBodygroup(i, body:GetBodygroup(i))
		end

		body:Remove()

	callply:LagCompensation(false)
end)

function BREACH.MakeDissolver(ent, position, attacker, dissolveType)

    local Dissolver = ents.Create( "env_entity_dissolver" )
    timer.Simple(5, function()
        if IsValid(Dissolver) then
            Dissolver:Remove() -- backup edict save on error
        end
    end)

    Dissolver.Target = "dissolve"..ent:EntIndex()
    Dissolver:SetKeyValue( "dissolvetype", dissolveType )
    Dissolver:SetKeyValue( "magnitude", 0 )
    Dissolver:SetPos( position )
    Dissolver:SetPhysicsAttacker( attacker )
    Dissolver:Spawn()

    ent:SetName( Dissolver.Target )

    Dissolver:Fire( "Dissolve", Dissolver.Target, 0 )
    Dissolver:Fire( "Kill", "", 0.1 )

    if ent.vtable and ent.vtable.Weapons and table.HasValue(ent.vtable.Weapons, "item_special_document") then
		local document = ents.Create("item_special_document")
		document:SetPos(ent:GetPos() + Vector(0,0,20))
		document:Spawn()
		document:GetPhysicsObject():SetVelocity(Vector(table.Random({-100,100}),table.Random({-100,100}),175))
	end

    return Dissolver
end

concommand.Add("annihilatornaya_pushka", function(ply, cmd, arg)
	if !ply:IsSuperAdmin() then return end

	ply:LagCompensation(true)

	local ent = ply:GetEyeTrace().Entity
	if ( !IsValid( ent ) ) then return end -- Not looking at a valid entity
	
	if ent:IsPlayer() then
		dmginfo = DamageInfo()
		dmginfo:SetAttacker(ply)
		dmginfo:SetDamageType(DMG_DISSOLVE)
		dmginfo:SetDamage(9999999999)
		ent:TakeDamageInfo(dmginfo)
	else
		local dissolver = BREACH.MakeDissolver(ent, ent:GetPos(), ply, 0)
	end
	callply:LagCompensation(false)
end)

function RemoveBonemerges(ply)
	if ply.BoneMergedEnts then
		for k, v in ipairs(ply.BoneMergedEnts) do
			if (v && v:IsValid()) then
				v:Remove()
			end
		end
	end

	if ply.BoneMergedHackerHat then
		for k, v in ipairs(ply.BoneMergedHackerHat) do
			if (v && v:IsValid()) then
				v:Remove()
			end
		end
	end

	if ply.GhostBoneMergedEnts then
		for k, v in ipairs(ply.GhostBoneMergedEnts) do
			if (v && v:IsValid()) then
				v:Remove()
			end
		end
	end
end

function CalculateDamageByDistance(ply, attacker)
	if ply:GTeam() == TEAM_SCP then
		return 0
	end
	local distsqr = ply:GetShootPos():DistToSqr(attacker:GetShootPos())
	return math.Clamp(math.ceil(distsqr * 0.00009) - 1, 0, 15)
end

function GM:EntityTakeDamage( target, dmginfo )
	if target:IsPlayer() and target:HasWeapon( "item_scp_500" ) then
		if target:Health() <= dmginfo:GetDamage() then
			target:GetWeapon( "item_scp_500" ):OnUse()
			target:PrintMessage( HUD_PRINTTALK, "Using SCP 500" )
		end
	end

	local at = dmginfo:GetAttacker()
	if at:IsVehicle() or ( at:IsPlayer() and at:InVehicle() ) then
		dmginfo:SetDamage( 0 )
	end

	if target:IsPlayer() then
		if target:Alive() then
			local dmgtype = dmginfo:GetDamageType()
			if dmgtype == 268435464 or dmgtype == 8 then
				if target:GTeam() == TEAM_SCP then
					dmginfo:SetDamage( 0 )
					return true
				elseif target.UsingArmor == "armor_fireproof" then
					dmginfo:ScaleDamage( 0.25 )
				end
			end

			if (dmgtype == DMG_SHOCK or dmgtype == DMG_ENERGYBEAM) and target.UsingArmor == "armor_electroproof" then
				dmginfo:ScaleDamage( 0.1 )
			end

			if dmgtype == DMG_VEHICLE then
				dmginfo:SetDamage( 0 )
			end

		end
	end

	if at:IsPlayer() and target:IsPlayer() and at:GetRoleName() == SCP9571 and target:GTeam() == TEAM_SCP then
		return true
	end
end

PISTOL_AMMO = 84
PISTOL_AMMO_2 = 3
REVOLVER_AMMO = 85
REVOLVER_AMMO_2 = 5
REVOLVER_AMMO_3 = 41
REVOLVER_AMMO_4 = 109
SMG1_AMMO = 88
SMG1_AMMO_2 = 4
SHOTGUN_AMMO = 87
SHOTGUN_AMMO_2 = 7
SHOTGUN_AMMO_3 = 111
AR2_AMMO = 1
AR2_AMMO_2 = 43
GOC_AMMO = 65
GRU_AMMO = 50
SNIPER_AMMO = 1

--first table value - damage scale, second - minimum damage to be applied
--math.max(damage, HITGROUP_MODIFIERS[hitgroup][2])
HITGROUP_MODIFIERS = {
	[HITGROUP_HEAD] = {3, math.random(100, 110)},
	[HITGROUP_CHEST] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_LEFTARM] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_RIGHTARM] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_STOMACH] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_GEAR] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_LEFTLEG] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_RIGHTLEG] = {math.random(0.2, 0.3), math.random(20, 30)},
	[HITGROUP_GENERIC] = {math.random(0.6, 0.7), math.random(20, 30)}
}

local soldier_teams = {

	[ TEAM_USA ] = true,
	[ TEAM_NTF ] = true,
	[ TEAM_QRT ] = true,
	[ TEAM_GUARD ] = true,
	[ TEAM_SECURITY ] = true,
	[ TEAM_CHAOS ] = true

}

local guard_teams = {
	[ TEAM_GUARD ] = true,
}

local commanders_roles = {

}

local guard_model = "models/cultist/humans/mog/mog.mdl"

local removehead = false

local stomach_hit = {

	[ HITGROUP_STOMACH ] = true,
	[ HITGROUP_CHEST ] = true,
	[ HITGROUP_LEFTARM ] = true,
	[ HITGROUP_RIGHTARM ] = true

}

local group = nil

util.AddNetworkString("BreachFlinch")

local hitgroupfix = {}

local HEADSHOTWEPS = {
	["cw_cultist_machinegun_m60"] = true,
	["cw_kk_ins2_rkr"] = true,
}

local UNIQUEDAMAGEWEPS = {
	["cw_scp_122"] = 150,
}

hook.Add( "EntityEmitSound", "Breach_Sound_Emit", function( t )

	if t.SoundName == "items/ammo_pickup.wav" then
		return false
	end

	if t.SoundName:find("player/pl_fallpain") then
		return false
	end

	if t.SoundName:find("player/pl_drown1.wav") then
		return false
	end

end)

hook.Add( "EntityTakeDamage", "Hurt_Sound_Breach", function( ply, dmginfo )
	if IsValid(ply) and ply:IsPlayer() then
		if dmginfo:IsDamageType(DMG_FALL) then
			sound.Play("^nextoren/charactersounds/hurtsounds/fall/pldm_fallpain0"..math.random(1,2)..".wav", ply:GetPos(), 75, 100, 2)
			--ply:EmitSound("nextoren/charactersounds/hurtsounds/fall/pldm_fallpain0"..math.random(1,2)..".wav", 85, ply.VoicePitch, 1, CHAN_VOICE2)
		end
	end
	if IsValid(ply) and ply:IsPlayer() and ply:GTeam() != TEAM_SPEC and ply:GTeam() != TEAM_SCP then

		if ply.LastHurtSound == nil then ply.LastHurtSound = 0 end

		if ply:LastHitGroup() == HITGROUP_HEAD then return end

		local isguard = false
		local isfemale = false
		if ply:GetModel() == guard_model then isguard = true end
		if ply:GTeam() == TEAM_GUARD then isguard = true end
		if ply:IsFemale() then isfemale = true end
		if ply:GetRoleName() == role.Dispatcher then isguard = false end
		if ply:GetRoleName() == "Head of Facility" then isguard = false end

		if isguard and isfemale then isguard = false end

		if ply.LastHurtSound < CurTime() then

			ply.LastHurtSound = CurTime() + 5.5

			if isfemale then

				ply:EmitSound("^nextoren/charactersounds/hurtsounds/sfemale/hurt_"..math.random(1, 66)..".mp3", 75, ply.VoicePitch, 2, CHAN_VOICE)

			elseif isguard then

				ply:EmitSound("^nextoren/vo/mtf/mtf_hit_"..math.random(1, 23)..".wav", 75, ply.VoicePitch, 1, CHAN_VOICE)

				local closeguards = ents.FindInSphere(ply:GetPos(), 560)
				local havecommander = false


				for _, plyy in ipairs(closeguards) do
					if IsValid(plyy) and plyy:IsPlayer() and plyy:GTeam() != TEAM_SPEC and plyy != ply then
						if !plyy.NextAlertSound then plyy.NextAlertSound = 0 end
						if plyy:GTeam() == TEAM_GUARD or plyy:GetModel() == guard_model then
							if plyy.NextAlertSound and plyy.NextAlertSound <= CurTime() and plyy != dmginfo:GetAttacker() then
								plyy.NextAlertSound = CurTime() + 45
								timer.Simple(math.random(0.0, 0.6), function()
									if IsValid(plyy) and plyy:Health() > 0 then
										plyy:EmitSound("^nextoren/vo/mtf/mtf_alert_"..math.random(1, 5)..".wav", 75, plyy.VoicePitch, 2, CHAN_VOICE)
									end
								end)
							end
						end
					end
				end

			else

				local rand = math.random(0, 39)
				if rand == 0 then
					ply:EmitSound("^nextoren/charactersounds/hurtsounds/male/hurt.mp3", 75, ply.VoicePitch, 2, CHAN_VOICE)
				else
					ply:EmitSound("^nextoren/charactersounds/hurtsounds/male/hurt_"..tostring(rand)..".wav", 75, ply.VoicePitch, 2, CHAN_VOICE)
				end

			end

		end

	end

end )

hook.Add("EntityTakeDamage", "SCP_457", function(ply, dmginfo)

	if dmginfo:IsDamageType(DMG_BURN) then
		dmginfo:SetDamage(math.random(5,6))
	end

end)

function GM:ScalePlayerDamage( ply, hitgroup, dmginfo )
	if dmginfo:GetAttacker().NoDamage then
		dmginfo:SetDamage(0)
		АПЧХУЙНАХУЙ()
		return true
	end

	if hitgroup == HITGROUP_GENERIC then hitgroup = HITGROUP_CHEST end

	if IsValid(ply) and ply:GetRoleName() == SCP096 and IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() then
		if !table.HasValue(ply:GetActiveWeapon().victims, dmginfo:GetAttacker()) and dmginfo:GetAttacker():GTeam() != TEAM_SCP and dmginfo:GetAttacker():GTeam() != TEAM_DZ then
			table.insert( ply:GetActiveWeapon().victims, dmginfo:GetAttacker() )

			net.Start( "GetVictimsTable" )

				net.WriteTable( ply:GetActiveWeapon().victims )

			net.Send( ply )

			if !ply:GetActiveWeapon().IsInRage and !ply:GetActiveWeapon().IsCrying then
				ply:GetActiveWeapon():StartWatching()
			end
		end
	end




	local hitgroupstring = "HITGROUP_NONE"
	local weaponclass = ""
	if IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():IsWeapon() then weaponclass = dmginfo:GetInflictor():GetClass() end
	if hitgroup == HITGROUP_HEAD then hitgroupstring = "HITGROUP_HEAD" end
	if hitgroup == HITGROUP_CHEST then hitgroupstring = "HITGROUP_CHEST" end
	if hitgroup == HITGROUP_LEFTARM then hitgroupstring = "HITGROUP_LEFTARM" end
	if hitgroup == HITGROUP_RIGHTARM then hitgroupstring = "HITGROUP_RIGHTARM" end
	if hitgroup == HITGROUP_RIGHTLEG then hitgroupstring = "HITGROUP_RIGHTLEG" end
	if hitgroup == HITGROUP_LEFTLEG then hitgroupstring = "HITGROUP_LEFTLEG" end
	if hitgroup == HITGROUP_STOMACH then hitgroupstring = "HITGROUP_STOMACH" end
	local isguard = false
	local isfemale = false
	if ply:GetModel() == guard_model then isguard = true end
	if ply:GTeam() == TEAM_GUARD then isguard = true end
	if ply:IsFemale() then isfemale = true end
ply:SetLastHitGroup(hitgroup)

	if dmginfo:IsDamageType(DMG_BLAST) then dmginfo:ScaleDamage(4) end

if hitgroup == HITGROUP_HEAD and ply:GTeam() == TEAM_SCP then hitgroupstring = "HITGROUP_CHEST" hitgroup = HITGROUP_CHEST end

--[[
if ply.LastHurtSound == nil then ply.LastHurtSound = 0 end

if ply.LastHurtSound < CurTime() then

	ply.LastHurtSound = CurTime() + 5.5

	if isguard then

		ply:EmitSound("nextoren/vo/mtf/mtf_hit_"..math.random(1, 23)..".wav", 85, ply.VoicePitch, 1, CHAN_VOICE)

		local closeguards = ents.FindInSphere(ply:GetPos(), 350)
		local havecommander = false

		for _, plyy in ipairs(closeguards) do
			if IsValid(plyy) and plyy:IsPlayer() and plyy:GTeam() != TEAM_SPEC and plyy != ply then
				if plyy.NextAlertSound == nil then plyy.NextAlertSound = 0 end
				if plyy:GTeam() == TEAM_GUARD or plyy:GetModel() == guard_model then
					if plyy.MextAlertSound <= CurTime() and plyy != dmginfo:GetAttacker() then
						plyy.NextAlertSound = CurTime() + 45
						timer.Simple(math.random(0, 0.6), function()
							if IsValid(plyy) and plyy:Health() > 0 then
								plyy:EmitSound("nextoren/vo/mtf/mtf_alert_"..math.random(1, 5)..".wav", 85, plyy.VoicePitch, 2, CHAN_VOICE)
							end
						end)
					end
				end
			end
		end

	elseif isfemale then

		ply:EmitSound("nextoren/charactersounds/hurtsounds/sfemale/hurt_"..math.random(1, 66)..".mp3", 85, ply.VoicePitch, 2, CHAN_VOICE)

	else

		local rand = math.random(0, 39)
		if rand == 0 then
			ply:EmitSound("nextoren/charactersounds/hurtsounds/male/hurt.mp3", 85, ply.VoicePitch, 2, CHAN_VOICE)
		else
			ply:EmitSound("nextoren/charactersounds/hurtsounds/male/hurt_"..tostring(rand)..".wav", 85, ply.VoicePitch, 2, CHAN_VOICE)
		end

	end

end]]

if HITGROUP_MODIFIERS[hitgroup] and !dmginfo:IsDamageType(DMG_BLAST) then
	dmginfo:ScaleDamage(HITGROUP_MODIFIERS[hitgroup][1])
	dmginfo:SetDamage(math.max(dmginfo:GetDamage(), HITGROUP_MODIFIERS[hitgroup][2]))
	--print(dmginfo:GetDamage())
end

--[[if ply.ScaleDamage then
	if ply.ScaleDamage[hitgroupstring] then
		dmginfo:ScaleDamage(ply.ScaleDamage[hitgroupstring])
	end
end]]

if ply:GetUsingCloth() != "" and ply.ClothMultipliersType then --если человек в латексе
	if ply.ClothMultipliersType[dmginfo:GetDamageType()] then
		dmginfo:ScaleDamage(ply.ClothMultipliersType[dmginfo:GetDamageType()]) --то помножаем урон
	end
end

local attacker = dmginfo:GetAttacker()
local ammo = -1 --placeholder if unfound
if attacker.GetActiveWeapon and IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon().GetPrimaryAmmoType then
	ammo = attacker:GetActiveWeapon():GetPrimaryAmmoType()
end

if dmginfo:IsBulletDamage() then
local attacker = dmginfo:GetAttacker()
local weapon = dmginfo:GetInflictor()
local dmg = dmginfo:GetDamage()

if IsValid(attacker) and attacker != ply then
	if attacker.GTeam and attacker:GTeam() != TEAM_SCP and !IsTeamKill(ply, attacker) and !ply.NoRewardsForKill then
		attacker:AddToMVP("damage", dmginfo:GetDamage())
	end
end
--[[
if dmg > 15 and ply:GTeam() != TEAM_SCP then
	timer.Create("BloodFall_"..ply:SteamID64(), 1, 5, function()
		if IsValid(ply) and ply:Health() > 0 then
			CreateBloodPoolForRagdoll(ply)
		end
	end)
end]]

local dforce = dmginfo:GetDamageForce()
local df_x, df_y, df_z = math.Clamp(dforce.x, -2500, 2500), math.Clamp(dforce.y, -2500, 2500), 0--math.Clamp(dforce.z, -2500, 2500)
dmginfo:SetDamageForce(Vector(df_x, df_y, df_z))

if ply:GTeam() == TEAM_SCP and ply:GetRoleName() == "SCP082" then
	local wep = ply:GetActiveWeapon()
	if wep.SetRageNumber and wep.GetRageNumber then
		wep:SetRageNumber( wep:GetRageNumber() + math.floor(dmginfo:GetDamage() * 0.25) )
	end
end

if IsValid(attacker) and attacker:IsPlayer() and attacker.SCI_SPECIAL_DAMAGE_Active and ply:GTeam() == TEAM_SCP then dmginfo:ScaleDamage(2) end

ply.ClockerAbilityTime = ply.ClockerAbilityTime || 0
if IsValid(attacker) and attacker:IsPlayer() then
	attacker.ClockerAbilityTime = attacker.ClockerAbilityTime || 0
	if attacker:GetRoleName() == role.UIU_Clocker and attacker.ClockerAbilityTime > CurTime() and IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon():GetClass() == "weapon_fbi_knife" then
		dmginfo:ScaleDamage(2)
	end
end

if ammo == GOC_AMMO
or ammo == SHOTGUN_AMMO
or ammo == SHOTGUN_AMMO_2
or ammo == SHOTGUN_AMMO_3
or dmginfo:GetDamage() > 200 
or ammo == REVOLVER_AMMO
or ammo == REVOLVER_AMMO_2
or ammo == REVOLVER_AMMO_3
or ammo == REVOLVER_AMMO_4 or HEADSHOTWEPS[weaponclass] then
	removehead = true
else
	removehead = false
end

--print("Start damage: "..dmg)
--print("Ammo: "..ammo)
--print("Squared distance: "..distsqr)
	damagedrop = CalculateDamageByDistance(ply, attacker)   ---- 子弹伤害
	--print("Damage drop: "..damagedrop)
	--print("WCNMNMSLJB", weapon.UseUniqueDamage, weapon)
	if weapon.UseUniqueDamage then
		dmginfo:SetDamage(dmginfo:GetDamage() - damagedrop)
		--print(weaponclass)
	elseif weaponclass and UNIQUEDAMAGEWEPS[weaponclass] then
		dmginfo:SetDamage(UNIQUEDAMAGEWEPS[weaponclass] - damagedrop)
	elseif ammo == AR2_AMMO or ammo == AR2_AMMO_2 then
		dmginfo:SetDamage(70 - damagedrop)

	elseif ammo == SMG1_AMMO or ammo == SMG1_AMMO_2 then
		dmginfo:SetDamage(52 - damagedrop)

	elseif ammo == GOC_AMMO then
		dmginfo:SetDamage(90 - damagedrop)

	elseif ammo == SHOTGUN_AMMO or ammo == SHOTGUN_AMMO_2 or ammo == SHOTGUN_AMMO_3 then
		dmginfo:SetDamage(50 - damagedrop)

    elseif ammo == SHOTGUN_AMMO_3 then
        dmginfo:SetDamage(200 - damagedrop)

	elseif ammo == PISTOL_AMMO or ammo == PISTOL_AMMO_2 then
		dmginfo:SetDamage(45 - damagedrop)

	elseif ammo == REVOLVER_AMMO or ammo == REVOLVER_AMMO_2 or ammo == REVOLVER_AMMO_3 or ammo == REVOLVER_AMMO_4 then
		dmginfo:SetDamage(55 - damagedrop)

	elseif ammo == GRU_AMMO then
		dmginfo:SetDamage(100 - damagedrop)

	else
		dmginfo:SetDamage(65 - damagedrop)
	end

	if IsValid(weapon) and weapon.Primary then
		if weapon.Primary.Ammo == "Sniper" or weapon.SniperRifle then
			dmginfo:SetDamage(dmg + math.random(150, 160) - damagedrop / 3)
		end
	end

	if ply:GTeam() == TEAM_SCP and ammo != GOC_AMMO and ammo != REVOLVER_AMMO and dmginfo:IsBulletDamage() then
		--dmginfo:SetDamage(math.Clamp(dmginfo:GetDamage(), math.random(15,20), math.random(30,35)))
		if hitgroup == HITGROUP_HEAD then
			dmginfo:ScaleDamage(math.Rand(1, 1.1))
		else
			dmginfo:ScaleDamage(math.Rand(0.8, 0.9))
		end
	end

	if ply:GTeam() == TEAM_SCP and dmginfo:IsDamageType(DMG_BLAST) then
		dmginfo:SetDamage(450)
	end

	--if IsValid(weapon) and weapon.CW20Weapon and weapon.Primary.AmmoType == "Sniper" and IsValid(victim) then
		--if victim:GTeam() == TEAM_SCP then
			--dmginfo:SetDamage(math.random(135, 150))
		--elseif victim:GetRoleName():find("Juggernaut") then
			--dmginfo:SetDamage(math.random(90, 110))
		--else
			--dmginfo:SetDamage(math.random(280, 320))
		--end
	--end

	--print(dmginfo:GetDamage())
	--print("Final damage: "..dmginfo:GetDamage())
end

if ply.DamageModifier and ammo != 113 then
	dmginfo:ScaleDamage(ply.DamageModifier)
end

if ply.AdditionalScaleDamage then
	dmginfo:ScaleDamage(ply.AdditionalScaleDamage)
end

if ply:GetBoosted() then
	dmginfo:ScaleDamage(.5)
end

if ply.IsZombie == true and weaponclass != "weapon_fbi_knife" then
	dmginfo:ScaleDamage(.4)
end

--print("Hitgroup: "..hitgroup)
--print("Hitgroup damage modifier: "..ply.ScaleDamage[hitgroup])
--[[
if dmginfo:GetDamage() < ply:Health() and ply:GTeam() != TEAM_SCP then

	if ( soldier_teams[ ply:GTeam() ] ) and !ply:IsFemale() then

		if ( ( ply.NextCallPain || 0 ) >= CurTime() ) then return end

		ply.NextCallPain = CurTime() + 5

		ply:EmitSound( "nextoren/vo/mtf/mtf_hit_"..math.random(1, 23)..".wav", 75, 100, 1 )

	elseif !( soldier_teams[ ply:GTeam() ] ) and !ply:IsFemale() then

		if ( ( ply.NextCallPain || 0 ) >= CurTime() ) then return end

		ply.NextCallPain = CurTime() + 5

		ply:EmitSound( "nextoren/charactersounds/hurtsounds/male/hurt_"..math.random(1, 39)..".wav", 75, 100, 1)

	elseif ply:IsFemale() then

		if ( ( ply.NextCallPain || 0 ) >= CurTime() ) then return end

		ply.NextCallPain = CurTime() + 5

		ply:EmitSound( "nextoren/charactersounds/hurtsounds/sfemale/hurt_"..math.random(1, 66)..".mp3", 75, 100, 1 )

	end

end]]

timer.Simple(0.1, function()
	if ( removehead and hitgroup == HITGROUP_HEAD and !ply:Alive() and ply:GTeam() != TEAM_SCP ) or ply.forceremovehead then

		ParticleEffectAttach("blood_advisor_puncture_withdraw", PATTACH_POINT_FOLLOW, ply:GetNWEntity("RagdollEntityNO", false), 1)
		--util.Effect( "headshot", efdata )
		--BreachParticleEffect( "headshot", dmginfo:GetDamagePosition(), Angle( 0, 0, 0 ))
		if ply:GetNWEntity("RagdollEntityNO", false) then
			print(ply:ShouldDoGib())
			ply.DeathReason = "Headshot"
			if ply:ShouldDoGib() then
				--SetBloodyTexture(ply:GetNWEntity("RagdollEntityNO", false))

				if ( ply:GetNWEntity("RagdollEntityNO", false).BoneMergedEnts ) then

					for _, v in ipairs( ply:GetNWEntity("RagdollEntityNO", false).BoneMergedEnts ) do

						if ( v && v:IsValid() ) then

							v:Remove()

						end

					end

				end

				if ( ply:GetNWEntity("RagdollEntityNO", false).BoneMergedHackerHat ) then

					for _, v in ipairs( ply:GetNWEntity("RagdollEntityNO", false).BoneMergedHackerHat ) do

						if ( v && v:IsValid() ) then

							v:Remove()

						end

					end

				end

				if ( ply:GetNWEntity("RagdollEntityNO", false).GhostBoneMergedEnts ) then

					for _, v in ipairs( ply:GetNWEntity("RagdollEntityNO", false).GhostBoneMergedEnts ) do

						if ( v && v:IsValid() ) then

							v:Remove()

						end

					end

				end
				local giber = Bonemerge( "models/cultist/heads/gibs/gib_head.mdl", ply:GetNWEntity("RagdollEntityNO", false))
				giber:SetBodygroup(0, math.random(0, 2))
				if ply.FaceTexture and ply.FaceTexture:find("black") then
					giber:SetSkin(1)
				end
			end
		end
	end
end)

local attacker = dmginfo:GetAttacker()
local ammo = -1 --placeholder if unfound
if attacker.GetActiveWeapon and IsValid(attacker:GetActiveWeapon()) and attacker:GetActiveWeapon().GetPrimaryAmmoType then
	ammo = attacker:GetActiveWeapon():GetPrimaryAmmoType()
end

local ammoname = game.GetAmmoName(ammo)

if !ply.HeadResist or ((ammoname == "Revolver" or ammoname == "AR2" or ammoname == "GOC" or ammoname == "Sniper") and !ply:GetRoleName():find("Juggernaut")) then
	ply.HeadResist = 0
end

if !ply.BodyResist or ((ammoname == "Revolver" or ammoname == "Sniper") and !ply:GetRoleName():find("Juggernaut")) then
	ply.BodyResist = 0
end

if hitgroup == HITGROUP_HEAD and !ply:GetRoleName():find("Juggernaut") and ply:GetRoleName() != role.UIU_Clocker and (ply.HeadResist == 0 or ply.HeadResist == nil) then
	if dmginfo:GetDamage() < ply:Health() then
		if dmginfo:GetDamage() < 215 and ply:GTeam() != TEAM_SCP then
			if ammo == SHOTGUN_AMMO or ammo == SHOTGUN_AMMO_2 or ammo == SHOTGUN_AMMO_3 then
				dmginfo:SetDamage(ply:GetMaxHealth() * 0.55)
			else
				dmginfo:SetDamage(ply:GetMaxHealth() * 1)  --GetMaxHealth1.25
			end
		else
			dmginfo:ScaleDamage(3)
		end
	end
end

if hitgroup == HITGROUP_HEAD and ply.HeadResist > 0 then
	ply.HeadResist = ply.HeadResist - 1
	dmginfo:SetDamage(math.max(dmginfo:GetDamage(), ply:GetMaxHealth()*0.9))
	if ply.HeadResist == 0 then
		if IsValid(ply.HelmetBonemerge) then
			ply.HelmetBonemerge:Remove()
			ply.HelmetBonemerge = nil
		end
		--ply:SetUsingHelmet("")
	end
end

if !ply.BodyResist then
	ply.BodyResist = 0
end

if ( hitgroup == HITGROUP_CHEST or hitgroup == HITGROUP_STOMACH ) and ply.BodyResist > 0 then
	dmginfo:ScaleDamage(0.27)
	ply.BodyResist = ply.BodyResist - 1
	if ply.BodyResist == 0 then
		if IsValid(ply.VestBonemerge) then
			ply.VestBonemerge:Remove()
			ply.VestBonemerge = nil
		end
		ply:SetUsingArmor("")
	end
end

if weaponclass == "cw_kk_ins2_arse_usp" and IsValid(ply) and !ply:HasWeapon("item_special_document") then
	dmginfo:SetDamage(1)
end

if ply.ScaleDamage then
	if ply.ScaleDamage[hitgroupstring] then
		dmginfo:ScaleDamage(ply.ScaleDamage[hitgroupstring])
	end
end --新加

ply:SetNWFloat("LastDamage", dmginfo:GetDamage())

	local hitpos = {

	[HITGROUP_HEAD] = { "flinch_head_01", "flinch_head_02" },
	[HITGROUP_CHEST] = { "flinch_phys_01", "flinch_phys_02" },
	[HITGROUP_STOMACH] = { "flinch_stomach_01", "flinch_stomach_02" },
	[HITGROUP_LEFTARM] = "flinch_shoulder_l",
	[HITGROUP_RIGHTARM] = "flinch_shoulder_r",
	[HITGROUP_LEFTLEG] = ply:GetSequenceActivity(ply:LookupSequence("flinch_01")),
	[HITGROUP_RIGHTLEG] = ply:GetSequenceActivity(ply:LookupSequence("flinch_02"))

	}

	if hitpos[grp] then

		if ( istable( hitpos[grp] ) ) then
			group = ply:LookupSequence(table.Random(hitpos[grp]))
		else
			group = ply:LookupSequence(hitpos[grp])
		end

		ply:AnimResetGestureSlot( GESTURE_SLOT_CUSTOM )
		ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_CUSTOM, group, 0, true )
	end

	net.Start("BreachFlinch", true)
	net.Send(ply)

	--ply:ViewPunchReset(0)
	--ply:MeleeViewPunch(dmginfo:GetDamage() / 2)

	if ply:GTeam() != TEAM_SCP and ply:GTeam() != TEAM_SPEC then
		util.StartBleeding(ply, dmginfo:GetDamage(), 5)
	end
end

function GM:PlayerDeath(victim, inflictor, attacker)

end

hook.Add("PlayerDisconnected", "KillOnLeave", function(ply)
	if ply:GTeam() != TEAM_SPEC and ply:Health() > 0 and ply:Alive() then
		--ply.LootboxDisconnectReason = true
		ply:Kill()
	end
end)

function GM:CheckForFriendKill(ply, attacker)
	if IsValid(attacker) and IsValid(ply) and attacker:IsPlayer() and IsTeamKill(ply, attacker) and ply != attacker and attacker:GTeam() != TEAM_ARENA then
		local admins = {}
		local t = player.GetHumans()
		for i = 1, #t do
			local adm = t[i]
			if adm:IsAdmin() and adm:GTeam() == TEAM_SPEC then admins[#admins + 1] = adm end
		end
		BREACH.Players:ChatPrint( admins, true, true, gteams.GetColor(attacker:GTeam()), attacker:GetRoleName(), color_white, " dont_translate:"..attacker:Name().." ["..attacker:SteamID().."] l:teamkill_killed", gteams.GetColor(ply:GTeam()), ply:GetRoleName(), color_white, " dont_translate:"..ply:Name().." ["..ply:SteamID().."]" )
		BREACH.Players:ChatPrint( {ply}, true, true, "l:teamkill_you_have_been_teamkilled ", gteams.GetColor(attacker:GTeam()), attacker:GetRoleName(), color_white, " dont_translate:"..attacker:Name().." ["..attacker:SteamID().."]l:teamkill_report_if_rulebreaker")
		local charname = ply:GetNamesurvivor()
		if charname == "none" or charname == ply:GetRoleName() then 
			charname = ""
		else
			charname = " "..charname
		end
		BREACH.Players:ChatPrint( {attacker}, true, true, "l:teamkill_you_teamkilled ", gteams.GetColor(ply:GTeam()) ,ply:GetRoleName(),color_white," dont_translate:"..ply:Name().." ["..ply:SteamID().."]" )
	else
		if IsValid(attacker) and IsValid(ply) and attacker:IsPlayer() and ply != attacker then
			if ply:LastHitGroup() == HITGROUP_HEAD then
				attacker:CompleteAchievement("headshot")
			end
			BREACH.Players:ChatPrint( {ply}, true, true, "l:you_have_been_killed ",gteams.GetColor(attacker:GTeam()), attacker:GetRoleName(), color_white, " dont_translate:"..attacker:Name().." ["..attacker:SteamID().."]" )
		end
	end
end

function MakeSCPDeathSound(rolename)
	if postround then return end
	if preparing then return end
	timer.Simple(math.Rand(3,6), function()
		local sound = ""
		if specialsoundnamescp[rolename] then
			sound = specialsoundnamescp[rolename]
		else
			sound = string.sub(rolename, 4)
		end
		net.Start("ForcePlaySound")
		net.WriteString("nextoren/round_sounds/intercom/scp_contained/"..sound..".ogg")
		net.Broadcast()
	end)
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
	--timer.Simple(0.1, function()
	--end)
CreateKillFeed(ply, attacker)

ply.lastkilledby = attacker
ply.rememberteamafterdeath = ply:GTeam()

if ply and ply:IsPlayer() and ply:GTeam() == TEAM_SCP and !ply.IsZombie then

	local rolename = ply:GetRoleName()

	MakeSCPDeathSound(rolename)

end

ply:SendLua("system.FlashWindow()")

ply:CompleteAchievement("death")
if ply != attacker and dmginfo:IsFallDamage() and IsValid(attacker) and attacker:IsPlayer() then attacker:CompleteAchievement("fallkill") end

if IsValid(attacker) and attacker:IsPlayer() and attacker != ply and !IsTeamKill(ply, attacker) then
		if attacker:GTeam() == TEAM_SCP then
			if !ply.NoRewardsForKill then
				attacker:AddToMVP("scpkill", 1)
			end
		else
			if !ply.NoRewardsForKill then
				attacker:AddToMVP("kill", 1)
				timer.Simple(.1, function()
					if !IsValid(ply) or !IsValid(attacker) then return end
					if ply:LastHitGroup() == HITGROUP_HEAD then
						attacker:AddToMVP("headshot", 1)
					end
				end)
			end
		end
	end

	if ply.SetNDeaths and ply.GetNDeaths and !attacker.NoRewardsForKill then
		ply:AddNDeaths(1)
		ply:AddElo(ply:CalculateElo(20, false))
	end

	local victim = ply

	victim:Freeze(true)

	if victim.ProgibTarget then
		victim.ProgibTarget:StopForcedAnimation()
		victim.ProgibTarget.ProgibTarget = nil
		victim:StopForcedAnimation()
		victim.ProgibTarget = nil
	end

	RemoveBonemerges(victim)

	net.Start( "Effect", true )
		net.WriteBool( false )
	net.Send( victim )

	net.Start( "957Effect", true )
		net.WriteBool( false )
	net.Send( victim )

	victim:SetModelScale( 1 )

	victim.isexplosion = dmginfo:IsDamageType(DMG_BLAST)
	victim.dmg_took = dmginfo:GetDamage()

	if IsValid(attacker) and attacker:IsPlayer() and attacker != victim then
        if IsTeamKill(victim, attacker) then
			if !victim.NoRewards then
            	attacker:AddToStatistics("l:teamkill", -25)
				attacker:RemoveFromStatistics("l:pacifist")
			end
        else
            if victim:GTeam() != TEAM_SCP or victim.IsZombie == true then
                if !( ( (victim:GTeam() == TEAM_SCI or victim:GTeam() == TEAM_SPECIAL) and attacker:GTeam() == TEAM_CLASSD ) or ( (attacker:GTeam() == TEAM_SCI or attacker:GTeam() == TEAM_SPECIAL) and victim:GTeam() == TEAM_CLASSD ) ) then
                    if !AreNeutral(victim, attacker) then
                        if victim:LastHitGroup() != HITGROUP_HEAD then
							local multiply = BREACH.KillRewardMultiply or 1
							if multiply != 0 then
								if !victim.NoRewardsForKill then
                            		attacker:AddToStatistics("l:enemykill", 50 * multiply)
								end
                            end
                        else
							local multiply = BREACH.KillRewardMultiply or 1
							if multiply != 0 then
								if !victim.NoRewardsForKill then
									attacker:AddToStatistics("l:headshot", 150 * multiply)
								end
                        	end
                        end
                    end
                end
            else
                attacker:AddToStatistics("l:scpkill", 400)
            end
        end
    end

    if attacker:IsPlayer() then
        if AreNeutral(victim, attacker) then
            attacker:RemoveFromStatistics("l:pacifist")
        end
    end

	if attacker != nil then
		if attacker:IsPlayer() then
			ServerLog("[KILL] " .. attacker:Nick() .. " [" .. attacker:GetRoleName() .. "] killed " .. victim:Nick() .. " [" .. victim:GetRoleName() .. "]")
		end
	else
		ServerLog("[DEATH] " .. victim:Nick() .. " [" .. victim:GetRoleName() .. "]")
	end

	GAMEMODE:CheckForFriendKill(ply, attacker)

	if IsTeamKill(ply, attacker) and attacker:GetRoleName() == role.ClassD_Banned then
		attacker.norewardbanned = true
	end

	local multiply = BREACH.DeathRewardMultiply or 1
	if multiply > 0 then
		if !attacker.NoRewardsForKill then
			victim:AddToStatistics("l:death", -10 * multiply)
		end
		victim:LevelBar(attacker.NoRewardsForKill)
	end

	timer.Create("Death_Scene"..victim:SteamID(), 8, 1, function()
		if !IsValid(victim) then return end

		if victim:Alive() then return end

		victim:SetupNormal()
		victim:SetSpectator()
		hook.Run("Breach_PlayerDeathSceneFinished", victim)
	end)

	if victim.TempValues.abouttoexplode then

		local current_pos = victim:GetPos()

				local dmg_info = DamageInfo()
				dmg_info:SetDamage( 2000 )
				dmg_info:SetDamageType( DMG_BLAST )
				dmg_info:SetAttacker( victim )
				dmg_info:SetDamageForce( -victim:GetAimVector() * 40 )

				util.BlastDamageInfo( dmg_info, victim:GetPos(), 400 )

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

					victim:StopParticles()

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
--[[
local dorag = false
if IsValid(attacker) and attacker != ply and attacker:IsPlayer() and attacker:GetRoleName() == "SCP082" then
	dorag = true
end
if dmginfo:IsDamageType(DMG_BLAST) then
	dorag = true
end
if dmginfo:IsDamageType(DMG_CRUSH) then
	dorag = true
end
if dmginfo:IsDamageType(DMG_FALL) then
	dorag = true
end]]
	if !attacker.NoRewardsForKill then
		ply:AddDeaths(1)
	end
	if attacker != nil then
		if attacker:IsPlayer() and attacker != ply then
			attacker:AddFrags(1)
		end
	end

	local rag = CreateLootBox(ply, dmginfo:GetInflictor(), attacker, nil, dmginfo)
	--timer.Simple(1, function() if !IsValid(ply) then rag.Dissolve = true end end)
	if ply.LootboxDisconnectReason then BREACH.DissappearCorpse(rag) end
	if IsValid(rag) then
		net.Start("Death_Scene", true) --fast send
			net.WriteBool(true)--dorag)
			net.WriteEntity(rag)
		net.Send(ply)
		
		if ragphys then
			ragphys:SetVelocity(dmginfo:GetDamageForce()/5)
		end


	end

	if ply:GTeam() == TEAM_ARENA and IsValid(rag) then
		timer.Simple(8, function()
			if !IsValid(rag) then
				return
			end

			rag:Remove()
		end)

		timer.Simple(9, function()
			if !IsValid(ply) then
				return
			end

			if !ply.ArenaParticipant then
				return
			end

			if ply:GTeam() != TEAM_SPEC and ply:Alive() then
				return
			end

			ply:SetupNormal()
			ply:ApplyRoleStats(BREACH_ROLES.MINIGAMES.minigame.roles[3])
			BREACH.PickArenaSpawn(ply)
			ply:SetNamesurvivor(ply:Nick())
		end)
	end

	ply:DropObject() --shawm fix
end

function GM:PostPlayerDeath(ply)

end

function GM:PlayerDeathSound(ply)
	--[[
	if ply:GTeam() != TEAM_SCP and ply:GTeam() != TEAM_SPEC then

		if ply:LastHitGroup() != HITGROUP_HEAD then
			if ( soldier_teams[ ply:GTeam() ] ) and !ply:IsFemale() then

				ply:EmitSound( "nextoren/charactersounds/hurtsounds/male/death_"..math.random(1, 58)..".mp3", 75, 100, 1 )

			elseif !( soldier_teams[ ply:GTeam() ] ) and !ply:IsFemale() then

				ply:EmitSound( "nextoren/charactersounds/hurtsounds/male/death_"..math.random(1, 58)..".mp3", 75, 100, 1 )

			elseif ply:IsFemale() then

				ply:EmitSound( "nextoren/charactersounds/hurtsounds/sfemale/death_"..math.random(1, 75)..".mp3", 75, 100, 1 )

			end

		elseif ply:LastHitGroup() == HITGROUP_HEAD then
			ply:SetNWBool("Helmet", false)
		end

	end
	--]]
	return true
end

function GM:PlayerDeathThink(ply)
	return false
end

function BREACH.DissappearCorpse(ent)
	if IsValid(ent) then
				ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
					--if IsValid(ent.BoneMergedEnts) then
						for k, v in ipairs(ent:LookupBonemerges()) do
							v:SetRenderMode(RENDERMODE_TRANSCOLOR)
							local index = tostring(v:EntIndex())
							hook.Add("Think", "DissolveBonemerge_"..index, function()
								if IsValid(v) then
									local col = v:GetColor()
									local alpha = math.Approach(col.a, 0, -8)
						
									v:SetColor(Color(col.r, col.g, col.b, alpha))
						
									if alpha == 0 then
										v:Remove()
										hook.Remove("Think", "DissolveBonemerge_"..index)
									end
								else
									hook.Remove("Think", "DissolveBonemerge_"..index)
								end
							end)
						end
					--end
				local ragindex = tostring(ent:EntIndex())
				hook.Add("Think", "DissolveRagdoll_"..ragindex, function()
					if IsValid(ent) then
						local col = ent:GetColor()
						local alpha = math.Approach(col.a, 0, -8)
						
						ent:SetColor(Color(col.r, col.g, col.b, alpha))
						
						if alpha == 0 then
							ent:Remove()
							hook.Remove("Think", "DissolveRagdoll_"..ragindex)
						end
					else
						hook.Remove("Think", "DissolveRagdoll_"..ragindex)
					end
				end)
			end
end