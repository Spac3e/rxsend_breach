if CLIENT then end

AddCSLuaFile( "lootable_corpses_config.lua" )
include( "lootable_corpses_config.lua" )

util.AddNetworkString("create_Headshot")
util.AddNetworkString("LootForcedAnimStart")
util.AddNetworkString("OpenLootMenu")

net.Receive("LootForcedAnimStart", function(len, ply)
	--ply:SetForcedAnimation( 616, 0, nil )
end)

util.AddNetworkString("LootForcedAnimStop")

net.Receive("LootForcedAnimStop", function(len, ply)
	--ply:SetForcedAnimation( false )
end)

local function IsWep(wep, weptab) 
	if(table.HasValue(weptab, wep)) then
		return true
	end
	return false
end

local function BoxRemove(entid)
	if(!IsValid(Entity(entid))) then return end
	Entity(entid):Remove()
	sound.Play( table.Random(LC.DespawnSounds), Entity(entid):GetPos(), 65, 100, 1 ) 
end

local function CheckIfEmpty(entid)
	if(Entity(entid).Money==0 and #Entity(entid).Weapons==0) then
		Entity(entid).IsLooted = true
		BoxRemove(entid)
	end
end

local function StartPreDeathAnimation( ply, attacker, dmginfo )

	ply.force = dmginfo:GetDamageForce() * math.random( 2, 4 )
	ply.type = dmginfo:GetDamageType()

	if ( attacker && attacker:IsValid() && attacker:IsPlayer() && attacker:GTeam() == TEAM_SCP ) then

		ply.type = attacker:Nick()

	end

end
hook.Add( "DoPlayerDeath", "StartDeathAnimation", StartPreDeathAnimation )

function CreateUnconsBody( victim )

	victim:SetNoDraw( true )
	victim:SetNotSolid( true )
	victim:SetDSP( 37 )
	victim:Freeze( true )

	CreateLootBox( victim, nil, nil, true )

end

function TestDeathPose( ply )

	local ragdoll = ents.Create( "base_gmodentity" )
	ragdoll:SetPos( ply:GetPos() )
	ragdoll:SetModel( ply:GetModel() )
	ragdoll:Spawn()
	ragdoll:SetPlaybackRate( 1 )
	ragdoll.AutomaticFrameAdvance = true
	ragdoll:SetSequence( ply:LookupSequence( "deathpose_front" ) )
	ragdoll:SetNoDraw( true )
	ragdoll.Think = function( self )

		self:NextThink( CurTime() )
		self:SetCycle( .16 )

		return true
	end

	--timer.Simple( 2, function()

		local test_ragdoll = ents.Create( "prop_ragdoll" )
		test_ragdoll:SetPos( ragdoll:GetPos() )
		test_ragdoll:SetModel( ragdoll:GetModel() )
		test_ragdoll:Spawn()

		local velocity = player.GetByID( 2 ):GetVelocity() - ( player.GetByID( 2 ):GetAimVector() * 6 )

		if ( test_ragdoll && test_ragdoll:IsValid() ) then

			local headIndex = test_ragdoll:LookupBone( "ValveBiped.Bip01_Head1" )

			test_ragdoll:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

			for i = 1, test_ragdoll:GetPhysicsObjectCount() do

				local physicsObject = test_ragdoll:GetPhysicsObjectNum( i )
				local boneIndex = test_ragdoll:TranslatePhysBoneToBone( i )
				local position, angle = ragdoll:GetBonePosition( boneIndex )

				if ( physicsObject && physicsObject:IsValid() ) then

					physicsObject:SetPos( position )
					physicsObject:SetMass( 65 )
					physicsObject:SetAngles( angle )

					if ( boneIndex == headIndex ) then

						physicsObject:SetVelocity( ( velocity / 6 ) * 1.5 )

					else

						physicsObject:SetVelocity( velocity / 6 )

					end

					if ( player.GetByID( 2 ).force ) then

						if ( boneIndex == headIndex ) then

							physicsObject:ApplyForceCenter( player.GetByID( 2 ).force * 1.5 )

						else

							physicsObject:ApplyForceCenter( player.GetByID( 2 ).force )

						end

					end

					timer.Simple( .2, function()

						physicsObject:ApplyForceCenter( Vector( 0, 0, physicsObject:GetMass() - math.random( 4000, 6000 ) ) )

					end )

				end

			end

		end

	--end )

end

local corpse_mdl = Model( "models/cultist/humans/corpse.mdl" )

function CreateLootBox( ply, inflictor, attacker, knockedout, dmginfo)
	
	local team = ply:GTeam()

	if ( team == TEAM_SPEC ) then return end

	if ( team == TEAM_SCP && ply.DeathAnimation ) then
		if isstring(ply.DeathAnimation) then ply.DeathAnimation = ply:LookupSequence(ply.DeathAnimation) end
		local SCPRagdoll = ents.Create( "base_gmodentity" )
		SCPRagdoll:SetPos( ply:GetPos() )
		SCPRagdoll:SetModel( ply:GetModel() )
		SCPRagdoll:SetMaterial( ply:GetMaterial() )
		SCPRagdoll:SetAngles( ply:GetAngles() )
		SCPRagdoll:SetNotSolid(true)
		SCPRagdoll:Spawn()
		ply:SetNWEntity( "RagdollEntityNO", SCPRagdoll )
		SCPRagdoll:SetPlaybackRate( 1 )
		SCPRagdoll:SetSequence( ply.DeathAnimation )
		SCPRagdoll.AutomaticFrameAdvance = true
		SCPRagdoll.Think = function( self )

			self:NextThink( CurTime() )

			return true
		end
		if ply:GetRoleName() == "SCP457" then
			timer.Simple(0.8, function()
				if IsValid(SCPRagdoll) then
					sound.Play( "bullet/explode/large_4.wav", ply:GetPos() )
					local dmginfo = DamageInfo()
					dmginfo:SetDamageType(DMG_BLAST)
					dmginfo:SetDamage(600)
					util.BlastDamageInfo(dmginfo, SCPRagdoll:GetPos(), 750)
					ParticleEffect("gas_explosion_ground_fire", SCPRagdoll:GetPos(), Angle(0,0,0), SCPRagdoll)
					BroadcastLua("ParticleEffect(\"gas_explosion_ground_fire\", Vector("..tostring(SCPRagdoll:GetPos().x)..", "..tostring(SCPRagdoll:GetPos().y)..", "..tostring(SCPRagdoll:GetPos().z).."), Angle(0,0,0), Entity("..tostring(SCPRagdoll:EntIndex()).."))")
				end
			end)
		end

		if ( !ply.DeathLoop ) then

			timer.Simple( SCPRagdoll:SequenceDuration() - .1, function()

				local SCPRagdoll2 = ents.Create( "prop_ragdoll" )
				SCPRagdoll2:SetModel( SCPRagdoll:GetModel() )
				SCPRagdoll2:SetPos( SCPRagdoll:GetPos() )
				SCPRagdoll2:SetAngles( SCPRagdoll:GetAngles() )
				SCPRagdoll2:SetMaterial( SCPRagdoll:GetMaterial() )
				SCPRagdoll2:SetSequence( SCPRagdoll:GetSequence() )
				SCPRagdoll2:SetCycle( SCPRagdoll:GetCycle() )
				SCPRagdoll2:Spawn()

				if ( SCPRagdoll2 && SCPRagdoll2:IsValid() ) then

					SCPRagdoll2:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

					for i = 1, SCPRagdoll2:GetPhysicsObjectCount() do

						local physicsObject = SCPRagdoll2:GetPhysicsObjectNum( i )
						local boneIndex = SCPRagdoll2:TranslatePhysBoneToBone( i )
						local position, angle = SCPRagdoll:GetBonePosition( boneIndex )

						if ( physicsObject && physicsObject:IsValid() ) then

							physicsObject:SetPos( position )
							physicsObject:SetMass( 65 )
							physicsObject:SetAngles( angle )

						end

					end

				end

				SCPRagdoll:Remove()

			end )

		end

		return

	end

	local LootBox = ents.Create( "prop_ragdoll" )
	LootBox.vtable = {}
	LootBox.vtable.Entity = LootBox
	LootBox.vtable.Weapons = {}

	LootBox.IsLootingBy = {}

	LootBox.IsFemale = ply:IsFemale()

	if ply.TempValues.radiation then
		ply.TempValues.radiation = nil
		LootBox.radiation = true

		local unique_id = "body_radioation_"..LootBox:EntIndex()

        timer.Create( unique_id, .25, 0, function()

            if ( !( LootBox && LootBox:IsValid() ) ) then

                timer.Remove( unique_id )

                return
            end

			if ( ( LootBox.NextParticle || 0 ) < CurTime() ) then

				LootBox.NextParticle = CurTime() + 3
				ParticleEffect( "rgun1_impact_pap_child", LootBox:GetPos(), angle_zero, self )

			end

            for _, v in ipairs( ents.FindInSphere( LootBox:GetPos(), 400 ) ) do

            if ( v:IsPlayer() && v:GTeam() != TEAM_SPEC && v:Health() > 0 ) then

					if ( v:HasHazmat() ) then return end

					local radiation_info = DamageInfo()
					radiation_info:SetDamageType( DMG_RADIATION )
					radiation_info:SetDamage( 2 )
					radiation_info:SetAttacker( LootBox )
                    radiation_info:SetDamageForce( v:GetAimVector() * 4 )

					radiation_info:ScaleDamage( 1 * ( 1600 / LootBox:GetPos():DistToSqr( v:GetPos() ) ) )

                    v:TakeDamageInfo( radiation_info )

                end

            end

        end )
    end

	LootBox.vtable.Name = ply:GetNamesurvivor()

	if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().droppable != false and ply:GetActiveWeapon().UnDroppable != true and ply:GTeam() != TEAM_SCP and BREACH.DropWeaponsOnDeath and !attacker.NoRewardsForKill and ply:GTeam() != TEAM_ARENA then
		ply:DropWeapon(ply:GetActiveWeapon())
	end
	
	for _, weapon in ipairs( ply:GetWeapons() ) do
		if weapon:GetClass() == "item_radio" then
			LootBox.RadioChannel = weapon.Channel
		end
			table.insert( LootBox.vtable.Weapons, weapon:GetClass() )
			if weapon:GetClass() == "item_special_document" then
				LootBox:SetNWBool("HasDocument", true)
			end
			if weapon.CW20Weapon then
				LootBox.vtable.Weapons[weapon:GetClass()] = weapon.ActiveAttachments
				LootBox.vtable.Weapons[weapon:GetClass().."_Clip1"] = weapon:Clip1()
			end
	end

	ply:SetNWEntity( "RagdollEntityNO", LootBox )
	if ( knockedout ) then

		ply:SetNWEntity( "NTF1Entity", LootBox )

	end

	LootBox:SetModel( ply:GetModel() )

	for _, v in pairs( ply:GetBodyGroups() ) do

        LootBox:SetBodygroup( v.id, ply:GetBodygroup( v.id ) )

    end

	LootBox:SetSkin( ply:GetSkin() )
	LootBox:SetMaterial( ply:GetMaterial() )

	if ply.TempValues.burnttodeath then
		LootBox:SetModel(corpse_mdl)
		LootBox:SetSkin(0)
	else
		for _, v in ipairs( ply:LookupBonemerges() ) do
			if ( v && v:IsValid() ) then
				local a = Bonemerge( v:GetModel(), LootBox, v:GetNoDraw() )
				if IsValid(a) then
					a:SetInvisible(v:GetInvisible())
					a:SetMaterial(v:GetMaterial())
					a:SetSkin(v:GetSkin())
				end
			end
		end
	end


	if ( team == TEAM_SCP && ply.SCPTable && ply.SCPTable.DeleteRagdoll ) then

		LootBox:Remove()
		ply:SetNWEntity( "RagdollEntityNO", nil )
		ply.SCPTable = nil

	end

	if IsValid(ply:GetActiveWeapon()) then
		if ply:GetActiveWeapon():GetClass() == "weapon_scp_049_2" then
			LootBox.IsZombie = true
		else
			LootBox.IsZombie = false
		end
	end

	if ( team != TEAM_SCP or LootBox.IsZombie ) and !ply.burn_to_death then

		LootBox.breachsearchable = true

	end

	if ply.IsZombie then
		LootBox:MakeZombie()
	end

	LootBox.Role = ply:GetRoleName()

	LootBox.DieWhen = CurTime()

	LootBox.LastHit = ply:LastHitGroup()

	LootBox.KilledByWeapon = false

	if IsValid(attacker) and attacker:IsPlayer() and attacker.GetActiveWeapon and IsValid(attacker:GetActiveWeapon()) then

		if attacker:GetActiveWeapon().CW20Weapon then LootBox.KilledByWeapon = true end

	end

	LootBox.__Team = ply:GTeam()

	LootBox.OldSkin = ply.OldSkin

	LootBox.OldModel = ply.OldModel

	LootBox.OldBodygroups = ply.OldBodygroups	

	LootBox.AmmoData = ply:GetAmmo()

	LootBox.__Name = ply:GetNamesurvivor()

	LootBox.__Health = ply:GetMaxHealth()

	LootBox.AbilityTable = ply.AbilityTAB

	LootBox.AbilityCD = ply:GetSpecialCD()

	LootBox.AbilityMax = ply:GetSpecialMax()

	LootBox.WalkSpeed = ply:GetWalkSpeed()

	LootBox.Cloth = ply:GetUsingCloth()

	LootBox.RunSpeed = ply:GetRunSpeed()

	LootBox.Bodygroups = ply:GetBodyGroups()

	LootBox.Stamina = ply:GetStaminaScale()

	LootBox.Ammo = ply:GetAmmo()

	for k, v in pairs(LootBox.Ammo) do
		if v > 30 then
			LootBox.Ammo[k] = math.random(20, 30)
		end
	end

	LootBox:SetAngles( ply:GetAngles() )
	LootBox:SetPos( ply:GetPos() )

	LootBox:Spawn()

	if ply:GetRoleName() == "SCP173" then
		LootBox:SetModelScale(1.1, 0)
		ply:SetAngles(Angle(ply:GetAngles().x, ply:GetAngles().y + 90, ply:GetAngles().z))
	end

	local velocity = ply:GetVelocity() + ( ply:GetAimVector() * math.Rand( 1, 3 ) )

	if ( LootBox && LootBox:IsValid() ) then

		local headIndex = LootBox:LookupBone( "ValveBiped.Bip01_Head1" )

		--LootBox:SetCollisionGroup( COLLISION_GROUP_WEAPON )

		for i = 1, LootBox:GetPhysicsObjectCount() do

			local physicsObject = LootBox:GetPhysicsObjectNum( i )
			local boneIndex = LootBox:TranslatePhysBoneToBone( i )
			local position, angle = ply:GetBonePosition( boneIndex )

			if ( IsValid( physicsObject ) ) then

				physicsObject:SetPos( position )
				physicsObject:SetMass( 65 )
				physicsObject:SetAngles( angle )

				if ( boneIndex == headIndex ) then

					physicsObject:SetVelocity( ( velocity / math.Rand( 2, 6 ) ) * math.Rand( .6, .9 ) )

				else

					physicsObject:SetVelocity( ( velocity / math.Rand( 2, 6 ) ) * math.Rand( .6, .9 ) )

				end

				if ( ply.force ) then

					if ( boneIndex == headIndex ) then

						physicsObject:ApplyForceCenter( ply.force * 1.5 )

					else

						physicsObject:ApplyForceCenter( ply.force )

					end

				end

				timer.Simple( .2, function()

					if ( IsValid( physicsObject ) ) then

						physicsObject:ApplyForceCenter( Vector( 0, 0, physicsObject:GetMass() - math.random( 4000, 6000 ) ) )

					end

				end )

			end

		end

	end

	timer.Simple(math.random(1,5), function()
		if IsValid(LootBox) and LootBox.__Team != TEAM_SCP then
			local boneid
			if LootBox.LastHit == HITGROUP_HEAD then
				boneid = LootBox:LookupBone("ValveBiped.Bip01_Head1")
			else
				boneid = LootBox:LookupBone("ValveBiped.Bip01_Spine")
			end
			CreateBloodPoolForRagdoll(LootBox, boneid)
		end
	end)

	--ply:EmitSound("", 0, 0, 0, CHAN_VOICE)

	if LootBox.__Team != TEAM_SCP and LootBox.LastHit != HITGROUP_HEAD then
		if LootBox.IsFemale then 
			LootBox:EmitSound("^nextoren/charactersounds/hurtsounds/sfemale/death_"..math.random(1,75)..".mp3", 75, ply.VoicePitch, 2, CHAN_VOICE)
		else
			LootBox:EmitSound("^nextoren/charactersounds/hurtsounds/male/death_"..math.random(1,58)..".mp3", 75, ply.VoicePitch, 2, CHAN_VOICE)
		end
	end

	if ply.IsZombie then
		LootBox:EmitSound("^nextoren/charactersounds/zombie/die"..math.random(1,5)..".wav", 75, ply.VoicePitch, 2, CHAN_VOICE)
	end



	if ( knockedout ) then

		LootBox.Knockout = true
		LootBox.PlayerHealth = ply:Health()

		if ( ply.BoneMergedEnts ) then

			for _, v in ipairs( ply.BoneMergedEnts ) do

				if ( v && v:IsValid() ) then

					v:SetNoDraw( true )
					v:DrawShadow( false )

				end

			end

		end

		--local unique_id = "PlayerDeathFromBleeding" .. ply:SteamID64()

		--[[function LootBox:OnTakeDamage( dmginfo )

			local attacker = dmginfo:GetAttacker()

			if ( attacker && attacker:IsValid() && attacker:IsPlayer() ) then

				LootBox.PlayerHealth = LootBox.PlayerHealth - dmginfo:GetDamage()

				if ( LootBox.PlayerHealth <= 0 ) then

					timer.Remove( unique_id )

					ply:SetDSP( 1 )
					ply:SendLua( 'LocalPlayer().KnockedOut = false' )
					ply:SetNWEntity( "NTF1Entity", NULL )
					ply:Freeze( false )
					ply:SetSpectator()

				end

			end

		end]]

		--ply:SendLua( 'LocalPlayer().KnockedOut = true' )

		--[[timer.Create( unique_id, 25, 1, function()

			if ( LootBox && LootBox:IsValid() ) then

				LootBox.Knockout = false

				ply:SendLua( 'LocalPlayer().KnockedOut = false' )

				ply:SetNWEntity( "NTF1Entity", nil )
				ply:SetDSP( 1 )
				ply:Freeze( false )
				ply:SetSpectator()

			end

		end )]]

	end

	LootBox.survname = ply:GetNamesurvivor()
	LootBox:SetOwner( ply )
	LootBox.IsInfected = false
	LootBox:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
	LootBox:SetCustomCollisionCheck(true)

	if ply.forceremovehead then
			ply.forceremovehead = false

			net.Start("create_Headshot")
			net.WriteEntity(LootBox)
			net.WriteVector(LootBox:GetBonePosition(LootBox:LookupBone("ValveBiped.Bip01_Head1")))
			net.WriteVector(Vector(0,1,0))
			net.Broadcast()
			--BreachParticleEffect( "headshot", dmginfo:GetDamagePosition(), Angle( 0, 0, 0 ))
			if LootBox then
				ply.DeathReason = "Headshot"
				if ply:GetRoleName() != role.Dispatcher and ply:GTeam() != TEAM_SCP then
					--SetBloodyTexture(ply:GetNWEntity("RagdollEntityNO", false))

					

						for _, v in ipairs( LootBox:LookupBonemerges() ) do

							if ( v && v:IsValid() ) then

								v:Remove()

							end

						end

					

					Bonemerge( "models/cultist/heads/gibs/gib_head.mdl", LootBox)
				end
			end
		end
	
	for i, v in pairs(LootBox:LookupBonemerges()) do
		if IsValid(v) and ( v:GetModel():find("male_head") or v:GetModel():find("balaclava") ) and !v:GetModel():find("halloween") then
			v:SetSubMaterial(0, ply.FaceTexture)
		end
	end

	local reason = "l:body_death_unknown"
	if dmginfo then
		if dmginfo:IsBulletDamage() then
			local ammotype = dmginfo:GetAmmoType()
			if ammotype == PISTOL_AMMO or ammotype == PISTOL_AMMO_2 then
				reason = "l:body_low_caliber"
			elseif ammotype == REVOLVER_AMMO or ammotype == REVOLVER_AMMO_2 or ammotype == REVOLVER_AMMO_3 or ammotype == REVOLVER_AMMO_4 then
				reason = "l:body_high_caliber"
			elseif ammotype == AR2_AMMO or ammotype == AR2_AMMO_2 or ammotype == GRU_AMMO then
				reason = "l:body_high_caliber"
			elseif ammotype == SMG1_AMMO or ammotype == SMG1_AMMO_2 then
				reason = "l:body_low_caliber"
			elseif ammotype == SHOTGUN_AMMO or ammotype == SHOTGUN_AMMO_2 or ammotype == SHOTGUN_AMMO_3 then
				reason = "l:body_shotgun"
			elseif ammotype == GOC_AMMO then
				reason = "l:body_goc"
			else
				reason = "l:body_bullets"
			end
		end

		if dmginfo:IsDamageType(DMG_SLASH) then
			reason = "l:body_slashed"
		end

		if dmginfo:IsDamageType(DMG_BURN) then
			reason = "l:body_burned"
		end

		if dmginfo:IsDamageType(DMG_CRUSH) then
			reason = "l:body_crushed"
		end

		if dmginfo:IsDamageType(DMG_FALL) then
			reason = "l:body_fall"
		end

		if dmginfo:IsDamageType(DMG_BLAST) then
			reason = "l:body_exploded"
		end

		if dmginfo:IsDamageType(DMG_POISON) then
			reason = "l:body_acid"
		end

		if dmginfo:IsDamageType(DMG_ACID) then
			reason = "l:body_acid"
		end

		if dmginfo:IsDamageType(DMG_NERVEGAS) then
			reason = "l:body_gas"
		end

		if dmginfo:IsDamageType(DMG_DISSOLVE) and !(team == TEAM_SCP && ply.DeathAnimation) then
			BREACH.MakeDissolver(LootBox, LootBox:GetPos(), ply, 0)
		end

		util.StartBleeding(LootBox, dmginfo:GetDamage(), 15)
	end

	--ЕСЛИ СОБИРАЕШЬСЯ ЧТО-ТО ДЕЛАТЬ С DMGINFO, ТО ОБЯЗАТЕЛЬНО ЗАПИХНИ ВСЕ В УСЛОВИЕ ВЫШЕ!!!

	if ply.LootboxDisconnectReason then
		reason = "l:body_disconnected"
	end

	LootBox:SetNWString("DeathReason1", reason)
	if ply:LastHitGroup() == HITGROUP_HEAD then
		LootBox:SetNWString("DeathReason2", "l:body_headshot")
	end

	LootBox:SetNWInt("DiedWhen", os.time())

	return LootBox

end
--hook.Add( "DoPlayerDeath", "create_loot_box", function(ply, attacker, dmginfo)
	--if ply:Alive() then --создает 2 трупа иначе, что за хуйня?!
		--CreateLootBox(ply, dmginfo:GetInflictor(), attacker, nil, dmginfo)
	--end
--end)

local function UpdateBox(entid)
	for k, v in pairs(player.GetAll()) do
	   if(v.LastUsedBoxId==entid) then
			net.Start( "LC_UpdateStuff" )
				net.WriteTable( Entity(entid).Weapons )
				net.WriteInt( Entity(entid).Money, 16 )
			net.Send(v)
	   end
	end
	CheckIfEmpty(entid)
end

net.Receive( "LC_TakeWep", function(len, ply)
	if ply:GTeam() == TEAM_SCP then return end
	if ply:GTeam() == TEAM_SPEC then return end
    local Corpse = net.ReadEntity()
    local WPName = net.ReadString()

    local weapontable = weapons.Get(WPName)

    local count1 = 0
    local count2 = 0
    local count3 = 0

    local weptab = ply:GetWeapons()
	for _, v in ipairs( weptab ) do
		if ( !( v.UnDroppable || v.Equipableitem ) ) then
			count1 = count1 + 1
		end
	end

	for _, v in ipairs( weptab ) do
		if ( ( v.UnDroppable ) ) then
			count2 = count2 + 1
		end
	end

	for _, v in ipairs( weptab ) do
		if ( ( v.Equipableitem ) ) then
			count3 = count3 + 1
		end
	end

    if ply:GetEyeTrace().Entity != Corpse then return end
    if !IsValid(Corpse) then return end
    if !Corpse.vtable then return end
    if !Corpse.vtable.Weapons then return end
    if !table.HasValue(Corpse.vtable.Weapons, WPName) then return end
    if count1 >= ply:GetMaxSlots() then return end
    if count2 >= 6 then return end
    if count3 >= 6 then return end

    if istable(weapontable) and weapontable.UnDroppable == true and WPName != "ritual_paper" and WPName != "item_special_document" then return end
    if WPName == "ritual_paper" and ply:GTeam() != TEAM_COTSK then return end
    if WPName == "item_special_document" and ply:GTeam() != TEAM_USA then return end
    if WPName == "item_special_document" then
    	if ply:GetRoleName() != role.SCI_SpyUSA then
    		return
    	end
    	ply:AddSpyDocument()
    	table.RemoveByValue(Corpse.vtable.Weapons, WPName)
    	Corpse:SetNWBool("HasDocument", false)
    	return
    end
    if istable(weapontable) and weapontable.droppable == false  then return end

    table.RemoveByValue(Corpse.vtable.Weapons, WPName)
    ply:BreachGive(WPName)
	if Corpse.vtable.Weapons[WPName] then
		local wep = ply:GetWeapon(WPName)
		--ply:SelectWeapon(WPName)
		wep.ActiveAttachments = Corpse.vtable.Weapons[WPName]
		wep:SetClip1(Corpse.vtable.Weapons[WPName.."_Clip1"])
		for k, v in pairs(wep.ActiveAttachments) do
			if v then
				wep:attachSpecificAttachment(k)
				timer.Simple(0.1, function()
					wep:ValidateAttachments()
				end)
			end
		end
	end
    --[[
	local plyid = net.ReadInt(16)
	local entid = net.ReadInt(16)
	local wepindex = net.ReadInt(16)
	--local ply = Player(plyid)
	local plypos = ply:GetPos()
	if(!IsValid(Entity(entid)) or ply:Health()<=0) then return end
	if(plypos:Distance(Entity(entid):GetPos())>200 or Entity(entid).IsLooted) then return end
	if(Entity(entid).vtable.Weapons[wepindex]==nil) then return end
	if ply:GTeam() == TEAM_SCP or ply:GTeam() == TEAM_SPEC then return end
	if ply:GetEyeTrace().Entity != Entity(entid) then return end
	if !ply:Alive() then return end
	if Entity(entid).Team == TEAM_SCP and !Entity(entid).IsZombie then return end
	if(Entity(entid).vtable.Weapons[wepindex] != "LC_Already_Taken") then

		local maximumdefaultslots = 8
		local maximumitemsslots = 6
		local maximumnotdroppableslots = 6

		local countdefault = 0
		local countitem = 0
		local countnotdropable = 0

		local is_cw = Entity(entid).vtable.Weapons[wepindex].CW20Weapon

		for _, weapon in ipairs( ply:GetWeapons() ) do

			if ( is_cw && weapon.CW20Weapon && weapon.Primary.Ammo == Entity(entid).vtable.Weapons[wepindex].Primary.Ammo ) then

				ply.NextPickup = CurTime() + 1
				ply:setBottomMessage("У Вас уже есть данный тип оружия.")

				return
			end

			if ( !weapon.Equipableitem && !weapon.UnDroppable ) then

				countdefault = countdefault + 1

			elseif ( weapon.Equipableitem ) then

				countitem = countitem + 1

			elseif ( weapon.UnDroppable ) then

				countnotdropable = countnotdropable + 1

			end

		end

		if ( ply:HasWeapon( Entity(entid).vtable.Weapons[wepindex] ) ) then

			ply.NextPickup = CurTime() + 1
			ply:setBottomMessage("У Вас уже есть данный предмет.")

			return 

		elseif ( !Entity(entid).vtable.Weapons[wepindex].Equipableitem && !Entity(entid).vtable.Weapons[wepindex].UnDroppable && countdefault >= maximumdefaultslots ) then

			ply:setBottomMessage("Your main inventory is full")

			return 

		elseif ( Entity(entid).vtable.Weapons[wepindex].Equipableitem && countitem >= maximumitemsslots ) then

			ply:setBottomMessage("Your secondary inventory is full")

			return 

		elseif ( Entity(entid).vtable.Weapons[wepindex].UnDroppable && countnotdropable >= maximumnotdroppableslots ) then

			ply:setBottomMessage("Your main inventory is full")

			return 

		else
			ply.IsLooting = true
			ply:Give(Entity(entid).vtable.Weapons[wepindex], LC.GunsNoAmmo)
			ply.IsLooting = false
			table.remove(Entity(entid).vtable.Weapons, wepindex)
		end
	end
	UpdateBox(entid)]]
end )

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

util.AddNetworkString("LC_TakeAmmo")
net.Receive("LC_TakeAmmo", function(len, ply)
	local corpse = net.ReadEntity()
	local ammoid = net.ReadUInt(16)
	local amount = net.ReadUInt(16)

	if ply.lastsearchedbody != corpse then return end
    if !IsValid(corpse) then return end
    if !corpse.vtable then return end
    if !corpse.vtable.Weapons then return end
	if ply:GetShootPos():DistToSqr(ply:GetEyeTrace().HitPos) > 82 * 82 then return end
	if !corpse.Ammo[ammoid] then return end
	if corpse.Ammo[ammoid] < amount then return end
	if ammo_maxs[game.GetAmmoName(ammoid)] and ply:GetAmmoCount(ammoid) > ammo_maxs[game.GetAmmoName(ammoid)] then return end --exploiter?

	corpse.Ammo[ammoid] = corpse.Ammo[ammoid] - amount
	ply:GiveAmmo(amount, game.GetAmmoName(ammoid), true)
	local translated = BREACH.AmmoTranslation[game.GetAmmoName(ammoid)] or game.GetAmmoName(ammoid)
	ply:RXSENDNotify("l:looted_ammo_pt1 "..translated.." l:looted_ammo_pt2" or "l:looted_ammo_pt1 "..game.GetAmmoName(ammoid).." l:looted_ammo_pt2")
	ply:EmitSound("^items/ammo_pickup.wav", 50, math.random(95, 105), 1, CHAN_REPLACE)
end)

hook.Add("KeyPress", "UseRagdoll", function(ply, key)

    local tr = ply:GetEyeTrace()

    if key != IN_USE then return end
    --if ply:GTeam() == TEAM_SPEC or ply:GTEAM() == TEAM_SCP then print("NO") return end
    
    local tr = ply:GetEyeTrace()
    
    if !IsValid(tr.Entity) then return end
    
    if ( !tr.Entity.breachsearchable || tr.Entity:GetClass() != "prop_ragdoll" || tr.Entity:GetPos():DistToSqr( ply:GetPos() ) > 3025 ) then return end

    if ply:GTeam() == TEAM_SPEC or ply:GTeam() == TEAM_SCP then return end
    
    if !tr.Entity.vtable then return end

    if !table.HasValue(tr.Entity.IsLootingBy, ply) then
    	table.insert(tr.Entity.IsLootingBy, ply)
    end

    ply:BrProgressBar( "l:looting_body", 6, "nextoren/gui/icons/notifications/breachiconfortips.png", tr.Entity, false,
    function()
        if !IsValid(tr.Entity) then return end
        if ply:GTeam() == TEAM_SPEC or !ply:Alive() then return end
        ply:RXSENDNotify("l:looting_end")
        ply.lastsearchedbody = tr.Entity
        net.Start( "OpenLootMenu", true )
            net.WriteTable( tr.Entity.vtable )
			if tr.Entity.Ammo then
				net.WriteTable(tr.Entity.Ammo)
			end
        net.Send( ply )
    end,
    function()
    	ply:SetForcedAnimation( 616, math.huge, function() ply:SetNWEntity("NTF1Entity", ply) end, function() ply:SetNWEntity("NTF1Entity", NULL) if IsValid(tr.Entity) then table.RemoveByValue(tr.Entity.IsLootingBy, ply) end end, function() ply:SetNWEntity("NTF1Entity", NULL) if IsValid(tr.Entity) then table.RemoveByValue(tr.Entity.IsLootingBy, ply) end end, true )
        	ply:RXSENDNotify("l:looting_started")
    	end, function()
    end, true)
    
end)