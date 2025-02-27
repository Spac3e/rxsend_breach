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
local mply = FindMetaTable( "Player" )
local ment = FindMetaTable( "Entity" )

util.AddNetworkString("Special_outline")
util.AddNetworkString("catch_breath")
util.AddNetworkString("StopGestureClientNetworking")
util.AddNetworkString("bettersendlua")
util.AddNetworkString("ArmorIndicator")

mply.SetBodyGroups = ment.SetBodyGroups

function mply:bSendLua(code)

	net.Start("bettersendlua")
	net.WriteString(code)
	net.Send(self)

end

function mply:SetUsingCloth(str)

	if !str or str == "" then
		self:UpdateArmorIndicator("Clothes", false)
	else
		self:UpdateArmorIndicator("Clothes", true, str)
	end

end

function mply:SetUsingBag(str)

	if !str or str == "" then
		self:UpdateArmorIndicator("Bag", false)
	else
		self:UpdateArmorIndicator("Bag", true, str)
	end

end

function mply:SetUsingArmor(str)

	if !str or str == "" then
		self:UpdateArmorIndicator("Armor", false)
	else
		self:UpdateArmorIndicator("Armor", true, str)
	end

end

function mply:SetUsingHelmet(str)

	if !str or str == "" then
		self:UpdateArmorIndicator("Hat", false)
	else
		self:UpdateArmorIndicator("Hat", true, str)
	end

end

function mply:UpdateArmorIndicator(stype, bHas, ArmorEntity)

	if !ArmorEntity then ArmorEntity = "" end

	net.Start("ArmorIndicator")
	net.WriteString(stype)
	net.WriteBool(bHas)
	net.WriteString(ArmorEntity)
	net.Send(self)

	if ( stype == "Everything" ) then

		self.HasHelmet = bHas
		self.HasArmor = bHas
		self.UsingCloth = bHas
		self.Hat = bHas
		self.ArmorEnt = bHas
		self.DisableFootsteps = nil
		self.HasBag = bHas
		self.BagEnt = bHas

		return
	end

	if ( stype == "Hat" ) then

		self.HasHelmet = bHas
		self.Hat = ArmorEntity

	elseif ( stype == "Armor" ) then

		self.HasArmor = bHas
		self.ArmorEnt = ArmorEntity

	elseif ( stype == "Clothes" ) then

		self.UsingCloth = ArmorEntity

	elseif ( stype == "Bag" ) then

	    self.HasBag = bHas
	    self.BagEnt = ArmorEntity

	end

end

net.Receive("catch_breath", function(len, ply)
	if ply:GTeam() == TEAM_SPEC or ply:GTeam() == TEAM_SCP then return end
	if ply.breathcd == nil then ply.breathcd = 0 end
	if ply.breathcd and ply.breathcd >= CurTime() then return end
	ply.breathcd = CurTime() + 7
	if ply:IsFemale() then
		ply:EmitSound("^nextoren/charactersounds/breathing/breathing_female.wav", 75, 100, 1, CHAN_VOICE)
	else
		ply:EmitSound("^nextoren/charactersounds/breathing/breath0.wav", 75, 100, 1, CHAN_VOICE)
	end
	timer.Create("stop_exhaust", 6, 1, function()
		ply:StopSound("^nextoren/charactersounds/breathing/breathing_female.wav")
		ply:StopSound("^nextoren/charactersounds/breathing/breath0.wav")
	end)
end)

function mply:PrintTranslatedMessage( string )
	net.Start( "TranslatedMessage" )
		net.WriteString( string )
		//net.WriteBool( center or false )
	net.Send( self )
end

function GhostBoneMerge( target, mdl )

	local bonemerged_ent = ents.Create("ent_bonemerged")
	bonemerged_ent:Spawn()
	bonemerged_ent:SetSolid(SOLID_NONE)
	bonemerged_ent:SetParent(target)
	bonemerged_ent:SetOwner(ent)
	bonemerged_ent:SetModel( mdl )
	bonemerged_ent:AddEffects(EF_BONEMERGE)
	bonemerged_ent:SetTransmitWithParent(true)

	if ( !target.GhostBoneMergedEnts ) then
  
		target.GhostBoneMergedEnts = {}
	
	end
	
	target.GhostBoneMergedEnts[ #target.GhostBoneMergedEnts + 1 ] = bonemerged_ent

end

function GhostBoneMergeArmor( target, mdl )

	local bonemerged_ent = ents.Create("ent_bonemerged")
	bonemerged_ent:Spawn()
	bonemerged_ent:SetSolid(SOLID_NONE)
	bonemerged_ent:SetParent(target)
	bonemerged_ent:SetOwner(ent)
	bonemerged_ent:SetModel( mdl )
	bonemerged_ent:AddEffects(EF_BONEMERGE)
	bonemerged_ent:SetTransmitWithParent(true)

	if ( !target.GhostBoneMergedArmorEnts ) then
  
		target.GhostBoneMergedArmorEnts = {}
	
	end
	
	target.GhostBoneMergedArmorEnts[ #target.GhostBoneMergedArmorEnts + 1 ] = bonemerged_ent

end

function GhostBoneMergeHat( target, mdl )

	local bonemerged_ent = ents.Create("ent_bonemerged")
	bonemerged_ent:Spawn()
	bonemerged_ent:SetSolid(SOLID_NONE)
	bonemerged_ent:SetParent(target)
	bonemerged_ent:SetOwner(ent)
	bonemerged_ent:SetModel( mdl )
	bonemerged_ent:AddEffects(EF_BONEMERGE)
	bonemerged_ent:SetTransmitWithParent(true)

	if ( !target.GhostBoneMergedHatEnts ) then
  
		target.GhostBoneMergedHatEnts = {}
	
	end
	
	target.GhostBoneMergedHatEnts[ #target.GhostBoneMergedHatEnts + 1 ] = bonemerged_ent

end

function Bonemerge(mdl, ent)
	local bonemerged_ent = ents.Create("ent_bonemerged")
	bonemerged_ent:Spawn()
	bonemerged_ent:SetSolid(SOLID_NONE)
	bonemerged_ent:SetParent(ent)
	bonemerged_ent:SetOwner(ent)
	bonemerged_ent:SetModel( mdl )
	bonemerged_ent:AddEffects(EF_BONEMERGE)
	bonemerged_ent:SetTransmitWithParent(true)
	bonemerged_ent:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)

	if ( !ent.BoneMergedEnts ) then
  
		ent.BoneMergedEnts = {}
	
	end
	
	ent.BoneMergedEnts[ #ent.BoneMergedEnts + 1 ] = bonemerged_ent

	return bonemerged_ent

end

function ApplyBonemergeHackerHat(mdl, ent)
	local bonemerged_ent = ents.Create("ent_bonemerged")
	bonemerged_ent:Spawn()
	bonemerged_ent:SetSolid(SOLID_NONE)
	bonemerged_ent:SetParent(ent)
	bonemerged_ent:SetOwner(ent)
	bonemerged_ent:SetModel( mdl )
	bonemerged_ent:AddEffects(EF_BONEMERGE)
	bonemerged_ent:SetTransmitWithParent(true)
	bonemerged_ent:AddEFlags(EFL_KEEP_ON_RECREATE_ENTITIES)

	if ( !ent.BoneMergedHackerHat ) then
  
		ent.BoneMergedHackerHat = {}
	
	end
	
	ent.BoneMergedHackerHat[ #ent.BoneMergedHackerHat + 1 ] = bonemerged_ent

end

function mply:ForceDropWeapon( class )
	if self:HasWeapon( class ) then
		local wep = self:GetWeapon( class )
		if IsValid( wep ) and IsValid( self ) then
			if self:GTeam() == TEAM_SPEC then return end
			local atype = wep:GetPrimaryAmmoType()
			if atype > 0 then
				wep.SavedAmmo = wep:Clip1()
			end	
			if wep:GetClass() == nil then return end
			if wep.droppable != nil and !wep.droppable then return end
			BREACH.AdminLogs:Log("drop", {
				user = self,
				weapon = class,
			})
			self:DropWeapon( wep )
			self:ConCommand( "lastinv" )
		end
	end
end

function mply:BreachGive(wep)
	self.JustSpawned = true
	self:Give(wep)
	self.JustSpawned = false
end

function mply:DropAllWeapons( strip )
	if GetConVar( "br_dropvestondeath" ):GetInt() != 0 then
		self:UnUseArmor()
	end
	if #self:GetWeapons() > 0 then
		local pos = self:GetPos()
		for k, v in pairs( self:GetWeapons() ) do
			local candrop = true
			if v.droppable != nil then
				if v.droppable == false then
					candrop = false
				end
			end
			if candrop then
				local class = v:GetClass()
				local wep = ents.Create( class )
				if IsValid( wep ) then
					wep:SetPos( pos )
					wep:Spawn()
					if class == "br_keycard" then
						local cardtype = v.KeycardType or v:GetNWString( "K_TYPE", "safe" )
						wep:SetKeycardType( cardtype )
					end
					local atype = v:GetPrimaryAmmoType()
					if atype > 0 then
						wep.SavedAmmo = v:Clip1()
					end
				end
			end
			if strip then
				v:Remove()
			end
		end
	end
end

// just for finding a bad spawns :p
function mply:FindClosest(tab, num)
	local allradiuses = {}
	for k,v in pairs(tab) do
		table.ForceInsert(allradiuses, {v:Distance(self:GetPos()), v})
	end
	table.sort( allradiuses, function( a, b ) return a[1] < b[1] end )
	local rtab = {}
	for i=1, num do
		if i <= #allradiuses then
			table.ForceInsert(rtab, allradiuses[i])
		end
	end
	return rtab
end

function mply:DeleteItems()
	for k,v in pairs(ents.FindInSphere( self:GetPos(), 150 )) do
		if v:IsWeapon() then
			if !IsValid(v.Owner) then
				v:Remove()
			end
		end
	end
end

function mply:ClearBodyGroups()
	for k, v in pairs(self:GetBodyGroups()) do
		self:SetBodygroup( v.id, 0 )
	end
end

function mply:ClearBoneMerges()
	if ( self.GhostBoneMergedEnts ) then

		for _, v in ipairs( self.GhostBoneMergedEnts ) do

			if ( v && v:IsValid() ) then

				v:Remove()
			end
		end
	end
	if ( self.BoneMergedEnts ) then

		for _, v in pairs( self.BoneMergedEnts ) do

			if ( v && v:IsValid() ) then

				v:Remove()
			end
		end
	end
	if ( self.BoneMergedHackerHat ) then

		for _, v in pairs( self.BoneMergedHackerHat ) do

			if ( v && v:IsValid() ) then

				v:Remove()
			end
		end
	end
	if ( self.GhostBoneMergedHatEnts ) then

		for _, v in pairs( self.GhostBoneMergedHatEnts ) do

			if ( v && v:IsValid() ) then

				v:Remove()
			end
		end
	end
	if ( self.GhostBoneMergedArmorEnts ) then

		for _, v in pairs( self.GhostBoneMergedArmorEnts ) do

			if ( v && v:IsValid() ) then

				v:Remove()
			end
		end
	end
end


function mply:UnUseArmor()
	if !self:GetUsingCloth() or self:GetUsingCloth() == "" then return end
	if ( self.GhostBoneMergedEnts ) then

		for _, v in ipairs( self.GhostBoneMergedEnts ) do

			if ( v && v:IsValid() ) then

				v:Remove()
			end
		end
	end
	for i, v in pairs(self:LookupBonemerges()) do
		v:SetInvisible(false)
	end
	if ( self.BoneMergedEnts ) then

		for _, v in pairs( self.BoneMergedEnts ) do

			if ( v && v:IsValid() ) then

				v:SetInvisible(false)
			end
		end
	end
	if ( self.BoneMergedHackerHat ) then

		for _, v in pairs( self.BoneMergedHackerHat ) do

			if ( v && v:IsValid() ) then

				v:SetInvisible(false)
			end
		end
	end
	local item = ents.Create( self:GetUsingCloth() )
	if IsValid( item ) then
		item:Spawn()
		item:SetPos( self:GetPos() )
		for i = 0, 12 do
			item.Bodygroups[i] = self:GetBodygroup(i)
		end
	end
	self:ClearBodyGroups()
	self:SetModel(self.OldModel)
	self:SetBodyGroups(self.OldBodygroups)
	self:SetSkin(self.OldSkin)
	self:SetUsingCloth("")
	if self:HasWeapon("weapon_scp_409") then self:Start409Infected(self) end
	self.CanUseArmor = true
	self:SetupHands()
end

function BroadcastPlayMusic(music, s_time)
	net.Start("ClientPlayMusic")
	net.WriteUInt(music, 32)
	net.Send(GetActivePlayers())
end

function BroadcastFadeMusic(s_time)
	net.Start("ClientFadeMusic")
	net.WriteFloat(s_time || 1)
	net.Send(GetActivePlayers())
end

function BroadcastStopMusic()
	net.Start("ClientStopMusic")
	net.Send(GetActivePlayers())
end

function mply:PlayMusic(music)
	net.Start("ClientPlayMusic")
	net.WriteUInt(music, 32)
	net.Send(self)
end

function mply:FadeMusic(s_time)
	net.Start("ClientFadeMusic")
	net.WriteFloat(s_time || 1)
	net.Send(self)
end

function mply:StopMusic()
	net.Start("ClientStopMusic")
	net.Send(self)
end

function mply:SetSpectator()
	self:DropObject()
	self:ClearBoneMerges()
	self:ClearBodyGroups()
	self:SetSkin(0)
	self:Flashlight( false )
	self:AllowFlashlight( false )
	self.handsmodel = nil
	self:Spectate( OBS_MODE_ROAMING )
	self:StripWeapons()
	self:RemoveAllAmmo()
	self:SetGTeam(TEAM_SPEC)
	--self:SetNoDraw(true) --clientside nodraw
	if self.SetRoleName then
		self:SetRoleName(role.Spectator)
	end
	self.Active = true
	print("adding " .. self:Nick() .. " to spectators")
	self.canblink = false
	self:SetNoTarget( true )
	self.BaseStats = nil
	self:SetMoveType(MOVETYPE_OBSERVER)
	self:SetModel("models/props_junk/watermelon01.mdl")
	self:PhysicsInit(SOLID_NONE)

	net.Start("set_spectator_sync")
	net.WriteEntity(self)
	net.Broadcast()

	//self:Spectate(OBS_MODE_IN_EYE)
end

function mply:GiveTempAttach()
	self:RXSENDNotify("l:temp_attach")
	self.CanAttach = true
	self:SetNW2Bool("Breach:CanAttach", true)
	timer.Simple(30, function()
		if IsValid(self) and self:GTeam() != TEAM_SPEC then
			self.CanAttach = false
			self:SetNW2Bool("Breach:CanAttach", false)
			self:RXSENDNotify("l:temp_attach_time_out")
		end
	end)
end

function mply:AddSpyDocument()

	if self:GetRoleName() != role.SCI_SpyUSA then return end

	self:SetNWInt("CollectedDocument", self:GetNWInt("CollectedDocument") + 1)

	if self:GetNWInt("CollectedDocument") >= 3 then
		self:RXSENDNotify("l:uiuspy_docs_ready")
	end

end


function mply:GuaranteedSetPos(vector)

	self:SetPos(vector)

	if self:GetPos() != vector then
		timer.Simple(0, function() -- waiting for a tick ((SOURCE ENGINE IS SHIT!!!!!!!!!))
			self:SetPos(vector)
			if self:GetPos() != vector then
				local tid = "GuaranteedSetPos"..self:SteamID64()
				timer.Create(tid, 0, 0, function()
					if !IsValid(self) or self:GetPos() == vector or !self:Alive() or self:Health() <= 0 then timer.Remove(tid) return end
					self:SetPos(vector)
				end)
			end
		end)
	end

end

hook.Add("PlayerShouldTakeDamage", "scp_860_nodamage", function(ply)

	if ply:GetRoleName() == SCP8602 and ply:GetPos():WithinAABox(Vector(9427.230469, -10222.647461, -1387.806152), Vector(15480.257813, -15956.700195, -3600.172607)) then
		return false
	end
	return true

end)

function mply:AddToStatistics( reason_exp, value_exp )
	if self:GTeam() == TEAM_ARENA then
		return
	end

    if tostring(reason_exp) == "l:escaped" then
    	if self:GetRoleName() == role.ClassD_Banned and !self.norewardbanned then
    		SetPenalty(self:SteamID64(), self:GetPenaltyAmount() - 1)
    	end
        self:AddNEscapes(1)
		self:AddElo(self:CalculateElo(20, true))
    end

    if reason_exp == "l:cheemer_rescue" then
    	self:CompleteAchievement("cheemer")
    end

    if value_exp > 0 and self:GetNLevel() <= 10 then
    	value_exp = value_exp*2
    end

    --if self:IsPremium() and value_exp > 0 then value_exp = value_exp * 2 end

    if !( self.LevelStats ) then

        self.LevelStats = {}

    end

    for i = 1, #self.LevelStats do

        if self.LevelStats[i].reason == reason_exp then

            self.LevelStats[i].value = self.LevelStats[i].value + value_exp
            return

        end

    end

    self.LevelStats[ #self.LevelStats + 1] = { value = value_exp, reason = reason_exp }

end

function mply:RemoveFromStatistics(reason_exp)
    --if self:IsPremium() and value_exp > 0 then value_exp = value_exp * 2 end

    if !( self.LevelStats ) then
        self.LevelStats = {}
        return
    end

    for i = 1, #self.LevelStats do
        if self.LevelStats[i].reason == reason_exp then
            table.remove(self.LevelStats, i)
            return
        end
    end
end

function mply:ClearStatistics()

	if ( self.LevelStats ) then

		self.LevelStats = {}

	end

end

function mply:LevelBar(noreward)

	if !self.GetNEXP then return end

	if !( self.LevelStats ) then

		self.LevelStats = {}

	end

	if self.StartedPlayAt and self:GetRoleName() != role.NTF_Pilot then

		local exp = (CurTime() - self.StartedPlayAt)
		if exp > 0 then
			exp = exp * 0.55
		end

		if !noreward then
			self:AddToStatistics("l:survival_bonus", exp)
		end

		self.StartedPlayAt = CurTime() + 100

	end

	local premiumbonus = 0

	if self:IsPremium() then
		local exp = 0
		for _, v in ipairs(self.LevelStats) do
			if v.value <= 0 then continue end
			exp = exp + v.value
		end
		premiumbonus = exp
		if exp != 0 then
			self.LevelStats[#self.LevelStats + 1] = {value = exp, reason = "l:prem_bonus"} -- НЕ ЗАБЫТЬ УБРАТЬ
		end
	end

	if self:GetRoleName() != role.ClassD_Banned then

		net.Start("LevelBar")

		    net.WriteTable(self.LevelStats)
		    net.WriteUInt(self:GetNEXP(), 32)

		net.Send(self)

	end

	--timer.Simple(.4, function()
	local exp = 0
	for i = 1, #self.LevelStats do
		
		exp = exp + self.LevelStats[ i ].value
	
	end

	self.LevelStats = {}
	self.SurvivalTime = nil

	if self:GetRoleName() != role.ClassD_Banned then

		timer.Simple(0.1, function()
			if !IsValid(self) then return end
			self:AddExp(exp)

			self:RXSENDNotify("l:your_current_exp "..self:GetNEXP())
			if self:IsPremium() then
				self:RXSENDNotify("l:premium_2x_bonus_pt1 ",Color(255,255,0, 200),"l:premium_2x_bonus_pt2 ",color_white,"l:premium_2x_bonus_pt3 ",Color(255,0,0, 200),"l:premium_2x_bonus_pt4")
			end
		end)

	end
	--end)



end

function TestPARTICLER_DEBUG(ent, effect)
	ParticleEffect(effect, ent:GetPos(), Angle(0,0,0))
end

function mply:GetLangRole(rl)

	local lang = self:GetInfo("br_language")

	local clang = _G[string.lower(lang)]

	if clang == nil then clang = english end

	return clang.role[rolef]

end

function SetPenalty(steamid64, amount, admin)

	local ply = player.GetBySteamID64(steamid64)

	if amount > 0 then

		if IsValid(ply) then
			if ply:GetPenaltyAmount() <= 0 then
				if admin then
					ply:RXSENDNotify("你已获得 ",Color(255,0,0),"惩罚D",color_white,", 你必须逃脱对应的次数才能摆脱此状态")
				else
					ply:RXSENDNotify("你已经到达了上限，获得了身份 ",Color(255,0,0),"惩罚D",color_white,", 要清除此状态，必须多次逃离")
				end
			end
			ply:SetPenaltyAmount(amount)
			ply:RXSENDNotify("所需逃脱次数: ",Color(255,0,0), amount)
		end

		util.SetPData(util.SteamIDFrom64(steamid64), "breach_penalty", amount)

	else

		if IsValid(ply) then
			ply:SetPenaltyAmount(0)

			if admin then
				ply:RXSENDNotify("惩罚D被撤销")
			else
				ply:RXSENDNotify("你已逃脱所需的次数!尽量不要违规了")
			end
		end

		util.RemovePData(util.SteamIDFrom64(steamid64), "breach_penalty")

	end

end

function mply:SetupNormal()
	local saveangles = self:EyeAngles()
	local saveangles2 = self:GetAngles()
	local savepos = self:EyePos()
	self:SetSubMaterial( nil, nil )
	self.SurvivalTime = nil
	self.recoilmultiplier = 1
	self:SetNWEntity("NTF1Entity", NULL)
	self.AdditionalScaleDamage = nil
	self.norewardbanned = nil
	self.queuerole = nil
	self:SetNWAngle("ViewAngles", Angle(0,0,0))
	--self:ClearStatistics()
	self.OriginalWalkSpeed = 0
	self.OriginalRunSpeed = 0
	self.Infected409 = nil
	self:SetMaterial("")
	self.CameraLook = nil
	self:SetNWInt("CollectedDocument", 0)
	self:SetViewEntity(self)
	self.IsZombie = nil
	self.burn_to_death = nil
	self.AbilityTAB = nil
	self:SetEnergized(false)
	self:SetBoosted(false)
	self.VoicePitch = 100
	self:SetNWBool("RXSEND_ONFIRE", false)
	self.br_onfire = nil
	self.isescaping = false
	self.abouttoexplode = nil
	self.TempValues = {}
	self.Block_Use = nil
	self.ProgibTarget = nil
	self:SetStamina(100)
	self.SCP173Effect = false
	self.DamageModifier = 1
	self:SetModel("")
	self:SetModelScale(1)
	self:SetInDimension(false)
	self:ClearBoneMerges()
	self.GASMASK_Ready = true
	self:GASMASK_SetEquipped(false)
	self:ClearBodyGroups()
	self:SetSkin(0)
	self.BaseStats = nil
	self:SetNWString("AbilityName", "")
	self.KACHOKABILITY = nil
	self.HeadResist = 0
	self.BodyResist = 0
	self:StopForcedAnimation()
	self.HelmetBonemerge = nil
	self.ArmorBonemerge = nil
	self.HasHelmet = nil
	self.DeathAnimation = nil
	self.HasArmor = nil
	self.CanUseArmor = true
	self.handsmodel = nil
	self:UnSpectate()
	self:Spawn()
	self:GodDisable()
	self:SetNoDraw(false)
	self:SetMaxSlots(8)
	self:SetNoTarget(false)
	self:SetupHands()
	self:RemoveAllAmmo()
	self:StripWeapons()
	self.canblink = true
	self.noragdoll = false
	self.scp1471stacks = 1
	self:RemoveEffects(EF_NODRAW)
	self:SetSpecialCD(0)
	self:Freeze(false)
	self:SetPos(savepos)
	saveangles.r = 0
	self:SetEyeAngles(saveangles)
	self:SetAngles(saveangles2)
	self:UpdateArmorIndicator("Everything", false)
end


function GM:PlayerShouldTaunt(ply, taunt)
	return false
end

util.AddNetworkString("NTF_Intro")

function OpenedDoor(index)
	local door = Entity(index)
	door.Opened = true
end

function ClosedDoor(index)
	local door = Entity(index)
	door.Opened = false
end


function ElevatorTest(index)

	local button = Entity(index)

	if IsValid(button._lastusedby) and button._lastusedby:IsPlayer() then
		print(button.doorentity)
		--[[
		BREACH.AdminLogs:Log("elevator_use", {
			user = button._lastusedby,
		})]]
	end

end

function SetupMapLua()
	MapLua = ents.Create("lua_run")
	MapLua:SetName("triggerhook")
	MapLua:Spawn()

	for k, v in pairs(ents.FindByClass("func_button")) do
		if v:GetName():find("elev") then
			v:Fire("AddOutput", "OnPressed triggerhook:RunPassedCode:ElevatorTest("..v:EntIndex()..")")
			local check = ents.FindInSphere(v:GetPos(), 200)
			local closestdoor_dist = math.huge
			local door = NULL

			for i = 1, #check do

				local ent = check[i]

				if IsValid(ent) and ent:GetClass() == "func_door" then
					local dist = v:GetPos():DistToSqr(ent:GetPos())
					if dist < closestdoor_dist then
						closestdoor_dist = dist
						door = ent
					end
				end

			end

			if IsValid(door) and (v:GetName():find("_up") or v:GetName():find("_down")) then

				door.buttonentity = v
			end
		end
	end

	for k, v in pairs(ents.FindByClass("func_door")) do
		v.Opened = false
		if !string.find(string.lower(v:GetName()), "elev") and !string.find(string.lower(v:GetName()), "gate") and !string.find(string.lower(v:GetName()), "containment") then
			v:SetKeyValue("wait", "2.2")
		end

		--auto-close system
		v:Fire("AddOutput", "OnOpen triggerhook:RunPassedCode:CloseDoor("..v:EntIndex()..")")
		--for logs to check door state
		v:Fire("AddOutput", "OnOpen triggerhook:RunPassedCode:OpenedDoor("..v:EntIndex()..")")
		v:Fire("AddOutput", "OnClose triggerhook:RunPassedCode:ClosedDoor("..v:EntIndex()..")")
	end

	--too big cooldown
	for k, v in pairs(ents.FindByClass("func_button")) do
		if !string.find(string.lower(v:GetName()), "elev") and !string.find(string.lower(v:GetName()), "gate") and !string.find(string.lower(v:GetName()), "containment") then
			v:SetKeyValue("wait", "2.2")
		end
	end

	--gate abuse fix
	for k, v in pairs(ents.FindByClass("func_button")) do
		if string.find(string.lower(v:GetName()), "gate") then
			v:SetKeyValue("wait", "5")
		end
	end
end

hook.Add("InitPostEntity", "SetupMapLua", SetupMapLua)
hook.Add("PostCleanupMap", "SetupMapLua", SetupMapLua)
local blockedkpps = {
	Vector(6880.000000, -1504.000000, 54.299999),
	Vector(7499.200195, -1040.619995, 54.299999),
	Vector(8160.000000, -1504.000000, 54.299999),
	Vector(9633.0302734375, -533.01000976562, 54.299999237061),
	Vector(4672, -2224, 53)
}
function CloseDoor(index)
	local door = Entity(index)
	if string.find(string.lower(Entity(index):GetName()), "elev") then return end

	if table.HasValue(ents.FindInSphere(Vector(9537.967773, -5018.667480, 66.792221), 32), door) then return end
	if table.HasValue(ents.FindInSphere(Vector(9546.245117, -4566.125488, 66.792221), 32), door) then return end
	if table.HasValue(blockedkpps, door:GetPos()) then return end
	if Entity(index).NoAutoClose then return end

	timer.Remove("close_door_"..index)
	timer.Create("close_door_"..index, 17, 1, function()
		Entity(index):Fire('Close')
	end)
end

function mply:AddToMVP(type, val)

	if self:GTeam() == TEAM_ARENA then return end

	if !MVPStats then return end

	if !MVPStats[type][self:SteamID64()] then
		MVPStats[type][self:SteamID64()] = 0
	end

	MVPStats[type][self:SteamID64()] = math.floor(MVPStats[type][self:SteamID64()] + val)

end
function mply:NTF_Scene()

	ntf_grunt = ents.Create("ntf_cutscene_2")
	ntf_grunt:SetOwner(self)
	ntf_grunt:Spawn()

end

local spy_teams = {
	[TEAM_CHAOS] = true,
	[TEAM_DZ] = true,
	[TEAM_GOC] = true,
	[TEAM_CLASSD] = true,
	[TEAM_USA] = true,
}


function mply:ApplyRoleStats( role, nointro )
	self:DropObject() --shawm fix
	self.Ducking = false
	self:SendLua("LocalPlayer().Ducking = false")
	self:SendLua("system.FlashWindow()")

	self:StripWeapons()

	timer.Remove("Death_Scene"..self:SteamID64())

	local my_steamid = self:SteamID64()
	--print(role)
	--if !role t--hen return end

	if role.name == "CI Spy" then
		role = table.Copy(role)
		local values = BREACH.ChaosSpy_CanBe
		local val = values[math.random(1, #values)]
		local tab

		for i, v in pairs(BREACH_ROLES.SECURITY.security.roles) do
			if v.name == val then
				tab = v
			end
		end

		role.weapons = tab.weapons
		role.headgear = tab.headgear
		role.head = tab.head
		role.walkspeed = tab.walkspeed
		role.runspeed = tab.runspeed
		role.jumppower = tab.jumppower
		role.keycard = tab.keycard
		role.usehead = tab.usehead
		role.randomizehead = tab.randomizehead
		role.randomizeface = tab.randomizeface
		role.ammo = tab.ammo
		for i = 0, 9 do
			role["bodygroup"..i] = tab["bodygroup"..i]
		end
	end

	--[[
	if role["team"] == TEAM_NTF then

		self:NTF_Scene()

	end]]

	if role["ability"] != nil then
		self:SetNWString("AbilityName", role["ability"][1])
		self.AbilityTAB = role["ability"]
		net.Start("SpecialSCIHUD")
	        net.WriteString(role["ability"][1])
		    net.WriteUInt(role["ability"][2], 9)
		    net.WriteString(role["ability"][3])
		    net.WriteString(role["ability"][4])
		    net.WriteBool(role["ability"][5])
	    net.Send(self)

	end

	if role["ability_max"] != nil then

		self:SetSpecialMax( role["ability_max"] )

	else

		self:SetSpecialMax( 0 )

	end

	self:SetRoleName( role["name"] )

	if role["bodyresist"] then
		self.BodyResist = role["bodyresist"]
	else
		self.BodyResist = 0
	end

	if role["headresist"] then
		self.HeadResist = role["headresist"]
	else
		self.HeadResist = 0
	end

	if role["recoilmultiplier"] then
		self.recoilmultiplier = 1 --role["recoilmultiplier"]
	else
		self.recoilmultiplier = 1
	end

	self:SetGTeam( role["team"] )
	
	if CanBeNeutral(self) then
        self:AddToStatistics("l:pacifist", 100)
    end

	for k, v in pairs( role["weapons"] ) do
		self.JustSpawned = true
		local wep = self:Give( v, true )
		timer.Simple( 0.1, function()
		    self.JustSpawned = false 
		end)
		--timer.Simple(0.1, function()
			if v == "item_radio" and IsValid(wep) then

				wep.Channel = math.Round(Radio_GetChannel(role["team"], role["name"]), 1)
				net.Start("SetFrequency")
				net.WriteEntity(wep)
				net.WriteFloat(wep.Channel)
				net.Send(self)
			end
		--end)
	end
	if role["keycard"] and role["keycard"] != "" then
		card = self:Give( "breach_keycard_"..role["keycard"], true )
	end

	--[[
	if role["doctype"] != nil then
		local doc = self:Give( "document" )
		if doc then
			doc:SetType( role["doctype"] )
		end
	end]]

	if role["ammo"] and role["ammo"] != {} then

		for k, v in pairs( role["ammo"] ) do
			for _, wep in pairs( self:GetWeapons() ) do
				if v[1] == wep:GetClass() then
					local max_clip = wep:GetMaxClip1()
					local new_clip = math.min( v[2], max_clip )
					local reserve = v[2] - new_clip

					wep:SetClip1( new_clip )

					if reserve > 0 then
						self:GiveAmmo( reserve, wep:GetPrimaryAmmoType(), true )
					end

					break
				end
			end
		end

	end

	if role["damage_modifiers"] then
		self.ScaleDamage = role["damage_modifiers"]
	else
		self.ScaleDamage = {

			[HITGROUP_HEAD] = 1,
			[HITGROUP_CHEST] = 1,
			[HITGROUP_LEFTARM] = 1,
			[HITGROUP_RIGHTARM] = 1,
			[HITGROUP_STOMACH] = 1,
			[HITGROUP_GEAR] = 1,
			[HITGROUP_LEFTLEG] = 1,
			[HITGROUP_RIGHTLEG] = 1

		}
	end
	
	self:SetNWFloat("HeadshotMultiplier", self.ScaleDamage["HITGROUP_HEAD"])
	
	self:SetHealth(role["health"])
	self:SetMaxHealth(role["health"])
	self:SetArmor(role["armor"] || 0)
	local walk = 1 -- role["walkspeed"]
	local run = role["runspeed"] or 1
	self:SetWalkSpeed(100)
	self:SetCrouchedWalkSpeed( 1 )
	self:SetSlowWalkSpeed(70)
	self:SetRunSpeed(231 * run)
	self.StartedPlayAt = CurTime() + 100
	self.OriginalWalkSpeed = self:GetWalkSpeed()
	self.OriginalRunSpeed = self:GetRunSpeed()
	self:SetJumpPower(200)
	self:Flashlight( false )
	self:AllowFlashlight( false )
	self.RequiredLevelRole = role["level"]
	self.VoicePitch = math.random(79, 120)
	if role["stamina"] != nil then
		self:SetStaminaScale(role["stamina"])
	else
		self:SetStaminaScale(1)
	end
	if role["genders"] != nil then
		self:SetFemale(table.Random(role["genders"]) )
	elseif role["premium_female"] and self:IsPremium() then
		self:SetFemale(math.random(1, 2) == 1)
		if self.SpawnOnlyMale then
			self:SetFemale(false)
		elseif self.SpawnOnlyFemale then
			self:SetFemale(true)
		end
	else
		self:SetFemale(false)
	end
	if role["team"] == TEAM_CLASSD and role["fmodel"] then
		local rand = math.random(0,100)
		self:SetFemale(rand <= 20)
	end
	if role["fmodel"] and self:IsPremium() then
		if self.SpawnOnlyMale then
			self:SetFemale(false)
		end
	end
	if role["skin"] != nil then
		self:SetSkin( role["skin"] )
	else
		self:SetSkin( 0 )
	end

	if self:GetFemale() == true then
		if role["fmodel"] != nil then
			self:SetModel( role["fmodel"] )
		elseif role["premium_female"] then
			self:SetModel( role["premium_female"] )
		else
			self:SetModel( role["model"] )
		end
		local isblack = math.random(1, 5) == 1
		if role["white"] then isblack = false end
		local face = PickFaceSkin(isblack, self:SteamID64(), true)
		self.FaceTexture = face
		if role["usehead"] then
			local mdl = PickHeadModel(self:SteamID64(), true)
			if !role["randomizehead"] then
				mdl = "models/cultist/heads/female/female_head_1.mdl"
			end
			local ent = Bonemerge(mdl, self)
			if CORRUPTED_HEADS[mdl] then
				ent:SetSubMaterial(1, face)
			else
				ent:SetSubMaterial(0, face)
			end
		end
		if !role["premium_female"] then
			if role["headf"] != nil then
				Bonemerge(table.Random(role["headf"]), self)
			end
			if role["hairf"] != nil then
				local hair = Bonemerge(table.Random(role["hairf"]), self)
				hair:SetSkin(math.random(0,3))
			end
		else
			if role["female_head"] then
				Bonemerge(table.Random(role["female_head"]), self)
			end
			if role["female_headgear"] then
				if istable(role["female_headgear"]) then
					Bonemerge(table.Random(role["female_headgear"]), self)
				else
					Bonemerge(role["female_headgear"], self)
				end
			end
		end

		if ( self:GetModel() == "models/cultist/humans/class_d/class_d_female.mdl" or self:GetModel() == "models/cultist/humans/class_d/class_d_cleaner_female.mdl" ) and isblack then
			self:SetSkin(1)
		end

		self.VoicePitch = math.random(100, 120)
		self:SetNamesurvivor( name_f[math.random(1, #name_f)].." "..surname[math.random(1, #surname)] )
	else

		if self.sexychemist and (RXSEND_SEXY_CHEMISTS[self:SteamID64()] or self:IsSuperAdmin()) and role["name"] == "MTF Chemist" then
			self:SetModel( "models/cultist/humans/mog/sexy_mog_hazmat.mdl" )
		else
			self:SetModel( role["model"] )
		end

		local isblack = math.random(1, 3) == 1
		if role["white"] then isblack = false end

		local face = PickFaceSkin(isblack, self:SteamID64())
		self.FaceTexture = face

		if self:GetModel():find("class_d_bor") then isblack = math.random(1, 2) == 1 end

		if ( self:GetModel() == "models/cultist/humans/class_d/class_d.mdl" or self:GetModel() == "models/cultist/humans/fbi/fbi_agent.mdl" or self:GetModel() == "models/cultist/humans/class_d/class_d_cleaner.mdl" or self:GetModel():find("class_d_bor") ) and isblack then
			self:SetSkin(1)
		end

		if role["head"] != nil then
			local mdl = role["head"]
			if istable(role["head"]) then mdl = role["head"][math.random(1,#role["head"])] end
			local ent = Bonemerge(mdl, self)
			if self:GetModel():find("class_d_bor") and isblack then ent:SetSkin(1) end
			if mdl:find("balaclava") or mdl:find("male_head") then
				if CORRUPTED_HEADS[mdl] then
					ent:SetSubMaterial(1, face)
				else
					ent:SetSubMaterial(0, face)
				end
			end
		end
		if role["usehead"] then
			local mdl = PickHeadModel(self:SteamID64())
			if !role["randomizehead"] then
				mdl = "models/cultist/heads/male/male_head_1.mdl"
			end
			local ent = Bonemerge(mdl, self)
			if CORRUPTED_HEADS[mdl] then
				ent:SetSubMaterial(1, face)
			else
				ent:SetSubMaterial(0, face)
			end
		end


			--[[
		    local head_bnmrg = Bonemerge(!istable(role["head"]) and role["head"] or table.Random(role["head"]), self)
		    if head_bnmrg:GetModel():find("head_main_1") or head_bnmrg:GetModel():find("balaclava") then
			    local skintable = {
			    	"models/all_scp_models/shared/heads/head_1_1",
			    	"models/all_scp_models/shared/heads/head_1_2",
			    	"models/all_scp_models/shared/heads/head_1_3",
			    	"models/all_scp_models/shared/heads/head_1_4",
			    	"models/all_scp_models/shared/heads/head_1_5",
			    	"models/all_scp_models/shared/heads/head_1_6",
			    }
			    if role["white"] != true then
			    	skintable = {
				    	"models/all_scp_models/shared/heads/head_1_1",
				    	"models/all_scp_models/shared/heads/head_1_2",
				    	"models/all_scp_models/shared/heads/head_1_3",
				    	"models/all_scp_models/shared/heads/head_1_4",
				    	"models/all_scp_models/shared/heads/head_1_5",
				    	"models/all_scp_models/shared/heads/head_1_6",
				    	"models/all_scp_models/shared/heads/head_1_7",
				    	"models/all_scp_models/shared/heads/head_1_8",
				    }
			    end
			    local selectedface = table.Random(skintable)
			    if head_bnmrg:GetModel():find("head_main_1_3") or head_bnmrg:GetModel():find("head_main_1_4") then
				    head_bnmrg:SetSubMaterial(2, selectedface)
				else
					head_bnmrg:SetSubMaterial(0, selectedface)
				end
			    self.FaceTexture = selectedface
			    if NextOren_HEADS_BLACKHEADS[selectedface] then
			    	self.VoicePitch = math.random(79, 90)
			    end
			    if NextOren_HEADS_BLACKHEADS[selectedface] then
			    	isblack = true
			    end
			    if ( self:GetModel() == "models/cultist/humans/class_d/class_d.mdl" or self:GetModel() == "models/cultist/humans/class_d/class_d_cleaner.mdl" ) and NextOren_HEADS_BLACKHEADS[selectedface] then
			    	self:SetSkin(1)
			    end
			end
	    end]]
	    local hairrandom = math.random(1, 5)
	    --if my_steamid == "76561198869328954" then hairrandom = 1 end
	    if hairrandom > 1 then
		    if role["hairm"] and !isblack then
		    	Bonemerge(role["hairm"][math.random(1, #role["hairm"])], self)
			elseif role["blackhairm"] then
				Bonemerge(role["blackhairm"][math.random(1, #role["blackhairm"])], self)
			end
		end
		if role["team"] == TEAM_GRU then
		    self:SetNamesurvivor( name_ru[math.random(1, #name_ru)].." "..surname_ru[math.random(1, #surname_ru)] )
		else
			self:SetNamesurvivor( name_eng[math.random(1, #name_eng)].." "..surname[math.random(1, #surname)] )
		end
	end
	self.Stamina = 100
	if role["stamina"] != nil then
		self.Stamina = 100 * role["stamina"]
	end
	if role["bodygroups"] != nil then
		self:SetBodyGroups( role["bodygroups"][1] )
	end
	if role["bodygroup0"] != nil then
		self:SetBodygroup( 0, role["bodygroup0"] )
	else
		if ( self:GetModel() == "models/cultist/humans/class_d/class_d.mdl" or self:GetModel() == "models/cultist/humans/class_d/class_d_female.mdl" ) and self:IsPremium() then
			if self:SteamID64() == "76561199067270911" then
				self:SetBodygroup( 0, 4)
			else
				self:SetBodygroup( 0, math.random(0, 4))
			end
		elseif self:IsPremium() and ( self:GetModel() == "models/cultist/humans/class_d/shaky/class_d_fat_new.mdl" or self:GetModel() == "models/cultist/humans/class_d/shaky/class_d_bor_new.mdl" ) then
			if self:SteamID64() == "76561199067270911" then
				self:SetBodygroup( 0, 3)
			else
				self:SetBodygroup( 0, math.random(0, 3))
			end
		else
			self:SetBodygroup( 0, 0 )
		end
	end
	for i = 1, 13 do
		if role["bodygroup"..i] != nil then
			self:SetBodygroup( i, role["bodygroup"..i] )
		else
			self:SetBodygroup( i, 0 )
		end
	end
	if role["hackerhat"] != nil then
		ApplyBonemergeHackerHat( role["hackerhat"], self )
	end
	if role.random_accessories then
		for i = 0, 13 do
			if role.random_accessories["bodygroup"..i] then
				self:SetBodygroup( i, math.random(role.random_accessories["bodygroup"..i][1], role.random_accessories["bodygroup"..i][2]) )
			end
		end
	end
	if !self:GetFemale() then
		if role["headgearrandom"] != nil then
			Bonemerge( table.Random(role["headgearrandom"]), self )
		end
		if role["headgear"] != nil then
			local model = Bonemerge(role["headgear"], self)
			if role.random_accessories and role.random_accessories["headgears"] then
				for i = 0, 8 do
					if role.random_accessories["headgears"]["bodygroup"..i] then
						model:SetBodygroup( i, math.random(role.random_accessories["headgears"]["bodygroup"..i][1], role.random_accessories["headgears"]["bodygroup"..i][2]) )
					end
				end
			end
		end
	end
	if role["team"] == TEAM_SPECIAL then
		local sur = surname[math.random(1, #surname)]
		self:SetNamesurvivor( self:GetRoleName() .." "..sur )
	end
	net.Start("RolesSelected")
	net.Send(self)
	self:SetupHands()

	if role["maxslots"] then
		self:SetMaxSlots(role["maxslots"])
	end

	if nointro != true then
		if role["team"] == TEAM_DZ and !role["name"]:find("Spy") then
			self:bSendLua("SHStart()")
			self:Freeze(true)
			self.MovementLocked = true
		elseif role["team"] == TEAM_GUARD then
			self:bSendLua("MOGStart()")
			self.canttalk = true
			--self:Freeze(true)
			--self.MovementLocked = true
			timer.Simple(27, function()
				if IsValid(self) then
					self.canttalk = false
				end
			end)
		elseif role["team"] == TEAM_GRU then
			self:bSendLua("GRUSpawn()")
		elseif role["team"] == TEAM_NTF then 
			self:bSendLua("NTFStart()")
			self:Freeze(true)
			self.MovementLocked = true
		elseif role["team"] == TEAM_GOC_CONTAIN and !role["name"]:find("Nego") then
			self:bSendLua("GOC_CONStart()")
			self:Freeze(true)
			self.MovementLocked = true
		elseif role["team"] == TEAM_GOC and !role["name"]:find("Spy") then
			self:bSendLua("GOCStart()")
			self:Freeze(true)
			self.MovementLocked = true
		elseif role["team"] == TEAM_QRT or role["team"] == TEAM_OSN then
			self:bSendLua("OBRStart()")
			self:Freeze(true)
			self.MovementLocked = true
			timer.Simple(8, function()
				if IsValid(self) then
					self.MovementLocked = nil
					self:Freeze(false)
				end
			end)
		--[[elseif role["team"] == TEAM_NTF then
			--self:SendLua("NTFStart()")
			self:Freeze(true)
			self.MovementLocked = true]]
		elseif role["team"] == TEAM_USA and BREACH.IsUiuAgent(role["name"]) and !role["name"]:find("Spy") then
			self:bSendLua("ONPStart()")
			if role["name"] == "UIU Infiltrator" then
				self:CompleteAchievement("clocker")
			end
		elseif role["team"] == TEAM_CHAOS and !role["name"]:find("Spy") then
			self:bSendLua("CutScene()")
		elseif role["team"] == TEAM_COTSK then
			self:bSendLua("CultStart()")
			self:Freeze(true)
			self.MovementLocked = true
		end

	end

	if spy_teams[role["team"]] then
		local team = role["team"]
		net.Start("Special_outline")
		net.WriteUInt(team, 16)
		net.Send(self)
	end

	self:SetNWEntity("RagdollEntityNO", NULL)
	
end

function mply:SexTest()

	local d = DamageInfo()
	d:SetInflictor(self:GetActiveWeapon())
	d:SetAttacker(self)
	d:SetDamageType(DMG_BULLET)
	d:SetDamage(100)
	self:TakeDamageInfo(d)

end

function mply:SetSecurityI1()
	local thebestone = nil
	local usechaos = false
	if math.random(1,6) == 6 then usechaos = true end
	for k,v in pairs(ALLCLASSES["security"]["roles"]) do
		if v.importancelevel == 1 then
			local skip = false
			if usechaos == true then
				if v.team == TEAM_GUARD then
					skip = true
				end
			else
				if v.team == TEAM_CHAOS then
					skip = true
				end
			end
			if skip == false then
				local can = true
				if v.customcheck != nil then
					if v.customcheck(self) == false then
						can = false
					end
				end
				local using = 0
				for _,pl in pairs(player.GetAll()) do
					if pl:GetRoleName() == v.name then
						using = using + 1
					end
				end
				if using >= v.max then can = false end
				if can == true then
					if self:GetLevel() >= v.level then
						if thebestone != nil then
							if thebestone.sorting < v.sorting then
								thebestone = v
							end
						else
							thebestone = v
						end
					end
				end
			end
		end
	end
	if thebestone == nil then
		thebestone = ALLCLASSES["security"]["roles"][1]
	end
	self:SetupNormal()
	self:ApplyRoleStats(thebestone)
end

function mply:SetClassD()
	self:SetRoleBestFrom("classds")
end

function mply:SetResearcher()
	self:SetRoleBestFrom("researchers")
end

function mply:SetChaosSpy()
	self:SetupNormal()
	self:ApplyRoleStats(BREACH_ROLES.MTF.mtf.roles[table.Random({1, 2, 4, 6})], true)
	self:SetGTeam(TEAM_CHAOS)
	self:SetRoleName(role.SECURITY_Spy)
	self:BreachGive("cw_kk_ins2_nade_c4")
end

function mply:SetRoleBestFrom(role)
	local thebestone = nil
	for k,v in pairs(ALLCLASSES[role]["roles"]) do
		local can = true
		if v.customcheck != nil then
			if v.customcheck(self) == false then
				can = false
			end
		end
		local using = 0
		for _,pl in pairs(player.GetAll()) do
			if pl:GetRoleName() == v.name then
				using = using + 1
			end
		end
		if using >= v.max then can = false end
		if can == true then
			if self:GetLevel() >= v.level then
				if thebestone != nil then
					if thebestone.level < v.level then
						thebestone = v
					end
				else
					thebestone = v
				end
			end
		end
	end
	if thebestone == nil then
		thebestone = ALLCLASSES[role]["roles"][1]
	end
	if thebestone == ALLCLASSES["classds"]["roles"][4] and #player.GetAll() < 4 then
		thebestone = ALLCLASSES["classds"]["roles"][3]
	end
	if ( GetConVar("br_dclass_keycards"):GetInt() != 0 ) then
		if thebestone == ALLCLASSES["classds"]["roles"][1] then thebestone = ALLCLASSES["classds"]["roles"][2] end
	else
		if thebestone == ALLCLASSES["classds"]["roles"][2] then thebestone = ALLCLASSES["classds"]["roles"][1] end
	end
	self:SetupNormal()
	self:ApplyRoleStats(thebestone)
end

function mply:IsActivePlayer()
	return self.Active
end

hook.Add( "KeyPress", "keypress_spectating", function( ply, key )
	if ply:GTeam() != TEAM_SPEC then return end
	if ( key == IN_ATTACK ) then
		ply:SpectatePlayerLeft()
	elseif ( key == IN_ATTACK2 ) then
		ply:SpectatePlayerRight()
	elseif ( key == IN_RELOAD ) then
		ply:ChangeSpecMode()
	end
end )

function mply:SpectatePlayerRight()
	if !self:Alive() then return end
	if self:GetObserverMode() != OBS_MODE_IN_EYE and
	   self:GetObserverMode() != OBS_MODE_CHASE 
	then return end
	self:SetNoDraw(true)
	local allply = GetAlivePlayers()
	if #allply == 1 then self:SpectateEntity( allply[1] ) return end
	if not self.SpecPly then
		self.SpecPly = 0
	end
	self.SpecPly = self.SpecPly - 1
	if self.SpecPly < 1 then
		self.SpecPly = #allply 
	end
	for k,v in pairs(allply) do
		if k == self.SpecPly then
			if v:GetMoveType() == MOVETYPE_NOCLIP then
				self.SpecPly = self.SpecPly - 1
				continue
			end
			self:SpectateEntity( v )
		end
	end
end

function mply:SpectatePlayerLeft()
	if !self:Alive() then return end
	if self:GetObserverMode() != OBS_MODE_IN_EYE and
	   self:GetObserverMode() != OBS_MODE_CHASE 
	then return end
	self:SetNoDraw(true)
	local allply = GetAlivePlayers()
	if #allply == 1 then self:SpectateEntity( allply[1] ) return end
	if not self.SpecPly then
		self.SpecPly = 0
	end
	self.SpecPly = self.SpecPly + 1
	if self.SpecPly > #allply then
		self.SpecPly = 1
	end
	for k,v in pairs(allply) do
		if k == self.SpecPly then
			if v:GetMoveType() == MOVETYPE_NOCLIP then
				self.SpecPly = self.SpecPly + 1
				continue
			end
			self:SpectateEntity( v )
		end
	end
end

function GM:EntityTakeDamage(target, dmginfo)
	if ( IsValid(target) and dmginfo:GetDamage() > 1 and dmginfo:IsBulletDamage() and target:IsPlayer() ) then
		if target:IsEFlagSet(EFL_NO_DAMAGE_FORCES) == false then
			target:AddEFlags(EFL_NO_DAMAGE_FORCES) -- эта хуйня работает
		end
	end
end

function mply:ChangeSpecMode()
	if !self:Alive() then return end
	if !(self:GTeam() == TEAM_SPEC) then return end
	self:SetNoDraw(true)
	local m = self:GetObserverMode()
	local allply = #GetAlivePlayers()
	if allply < 1 then
		self:Spectate(OBS_MODE_ROAMING)
		return
	end
	/*
	if m == OBS_MODE_CHASE then
		self:Spectate(OBS_MODE_IN_EYE)
	else
		self:Spectate(OBS_MODE_CHASE)
	end
	*/
	
	if m == OBS_MODE_IN_EYE then
		self:Spectate(OBS_MODE_CHASE)	
	elseif m == OBS_MODE_CHASE then
		if GetConVar( "br_allow_roaming_spectate" ):GetInt() == 1 then
			self:Spectate(OBS_MODE_ROAMING)
		elseif GetConVar( "br_allow_ineye_spectate" ):GetInt() == 1 then
			self:Spectate(OBS_MODE_IN_EYE)
			self:SpectatePlayerLeft()
		else
			self:SpectatePlayerLeft()
		end	
	elseif m == OBS_MODE_ROAMING then
		if GetConVar( "br_allow_ineye_spectate" ):GetInt() == 1 then
			self:Spectate(OBS_MODE_IN_EYE)
			self:SpectatePlayerLeft()
		else
			self:Spectate(OBS_MODE_CHASE)
			self:SpectatePlayerLeft()
		end
	else
		self:Spectate(OBS_MODE_ROAMING)
	end
end

hook.Add("Think", "Spec_Think", function()

	local plys = gteams.GetPlayers(TEAM_SPEC)

	for i = 1, #plys do

		local ply = plys[i]

		local observer = ply:GetObserverTarget()

		if IsValid(observer) and observer:IsPlayer() then
			if observer:GTeam() == TEAM_SPEC or !observer:Alive() or observer:Health() <= 0 then
				ply:SetObserverMode(OBS_MODE_ROAMING)
			end
		end

	end

end)

function mply:SaveExp()
	self:SetBreachData( "exp", self:GetNEXP() )
end

function mply:SaveLevel()
	self:SetBreachData( "level", self:GetNLevel() )
end

function mply:AddExp(amount)

	local requiredexp = self:RequiredEXP()

	if !self.GetNEXP then return end

	if self:GetNEXP() + amount >= requiredexp then

		self:SetNLevel( self:GetNLevel() + 1 )
		self:SaveLevel()

		self:SetNEXP( 0 )
		self:SaveExp()

		self:RXSENDNotify( "l:levelup ", Color(255,0,0), self:GetNLevel() )

	else

		self:SetNEXP( self:GetNEXP() + amount )
		self:SaveExp()

	end

end

function mply:AddLevel(amount)
	if not self.GetNLevel then
		player_manager.RunClass( self, "SetupDataTables" )
	end
	if self.GetNLevel and self.SetNLevel then
		self:SetNLevel( self:GetNLevel() + amount )
		self:SaveLevel()
	else
		if self.SetNLevel then
			self:SetNLevel( 0 )
		else
			ErrorNoHalt( "Cannot set the exp, SetNLevel invalid" )
		end
	end
end

function mply:AddNEscapes(amount)
	--[[
    if not self.GetNEscapes then
        player_manager.RunClass( self, "SetupDataTables" )
    end
    if self.GetNEscapes and self.SetNEscapes then
        self:SetNEscapes( self:GetNEscapes() + amount )
        self:SetBreachData( "escapes", self:GetNEscapes() )
    else
        if self.SetNEscapes then
            self:SetNEscapes( 0 )
        else
            ErrorNoHalt( "Cannot set the escape count, SetNEscapes invalid" )
        end
    end]]
end

function mply:AddNDeaths(amount)
	--[[
    if not self.GetNDeaths then
        player_manager.RunClass( self, "SetupDataTables" )
    end
    if self.GetNDeaths and self.SetNDeaths then
        self:SetNDeaths( self:GetNDeaths() + amount )
        self:SetBreachData( "deaths", self:GetNDeaths() )
    else
        if self.SetNDeaths then
            self:SetNDeaths( 0 )
        else
            ErrorNoHalt( "Cannot set the death count, SetNDeaths invalid" )
        end
    end]]
end

function mply:AddElo(amount)
	--[[
    if not self.GetElo then
        player_manager.RunClass( self, "SetupDataTables" )
    end

	if self:GTeam() == TEAM_ARENA then
		return
	end

    if self.GetElo and self.SetElo then
		if amount < 0 and (self:GetElo() + amount) < 0 then
			self:SetElo( 0 )
			self:SetBreachData( "elo", 0 )
			return
		end
        self:SetElo( self:GetElo() + amount )
        self:SetBreachData( "elo", self:GetElo() )
    else
        if self.SetElo then
            self:SetElo( 0 )
        else
            ErrorNoHalt( "Cannot set the elo rating, SetElo invalid" )
        end
    end]]
end

hook.Add("PlayerAmmoChanged", "checkthisshit", function(ply, ammoID, oldCount, newCount)
	if ammoID == 3 and oldCount == 0 and newCount == 24 then
		ply:SetAmmo(0, ammoID)
	end
end)

function mply:SetActive( active )
	self.ActivePlayer = active
	if !gamestarted then
		CheckStart()
	end
end

function mply:SetOnFire(duration)

	if self.burn_to_death then return end
	self:SetNWBool("RXSEND_ONFIRE", true)
	self.br_onfire = true
	local uid = "FIRE_THINK_"..self:SteamID64()
	local uid2 = "FIRE_END_"..self:SteamID64()
	local filt = RecipientFilter()
	filt:AddAllPlayers()
	if !self.burnsound then
		self.burnsound = CreateSound(self, "nextoren/charactersounds/hurtsounds/fire/ambient_generic_fire.ogg", filt)
		self.burnsound:Play()
	end

	timer.Create(uid, FrameTime(), 999999, function()

		if !IsValid(self) or self:Health() <= 0 or self:GTeam() == TEAM_SPEC or !self.br_onfire or !self:GetNWBool("RXSEND_ONFIRE", false) then
			timer.Remove(uid)
			timer.Remove(uid2)
			return
		end

		local dmg = math.random(3,6)

		local plys = player.GetAll()

		for i = 1, #plys do

			local ply = plys[i]

			if ply != self and ply:GTeam() != TEAM_SPEC then
				local dist = ply:GetPos():DistToSqr(self:GetPos())
				if dist <= 3000 then
					ply:SetOnFire(duration)
				end
			end


		end

		if (self.next_fire_dmg || 0) <= CurTime() then

			self.next_fire_dmg = CurTime() + 0.3

			local woulddie = self:Health() - dmg <= 0

			if !woulddie then
				if !self:HasGodMode() then
					self:SetHealth(self:Health() - dmg)
				end
				--self:MeleeViewPunch(dmg*.2)
				self:ScreenFade(SCREENFADE.IN,Color(255,0,0,55), 0.5, 0)
				if self:GTeam() != TEAM_SCP then self:EmitSound("nextoren/charactersounds/hurtsounds/fire/pl_burnpain0"..math.random(1,6)..".wav", 75, 100, 1) end
			else
				timer.Remove(uid)
				timer.Remove(uid2)
				if self.burnsound then self.burnsound:Stop() self.burnsound = nil end
				if self:GTeam() != TEAM_SCP then
					self.burn_to_death = true
					self:SetForcedAnimation(self:LookupSequence("2ugbait_hit"), 2, function()
					self:GodEnable()
					self:SetMoveType(MOVETYPE_OBSERVER)
					self:Freeze(true)
					self:SetNWEntity("NTF1Entity", self)
					self:EmitSound("nextoren/charactersounds/hurtsounds/hg_onfire0"..math.random(1,4)..".wav", 165, 100, 1.35, CHAN_VOICE)
					end, function()
						self:Freeze(false)
						self:SetNWEntity("NTF1Entity", NULL)
						if self:HasWeapon("item_special_document") then
							local document = ents.Create("item_special_document")
							document:SetPos(self:GetPos() + Vector(0,0,20))
							document:Spawn()
							document:GetPhysicsObject():SetVelocity(Vector(table.Random({-100,100}),table.Random({-100,100}),175))
							self:StripWeapon("item_special_document")
						end
						self:Kill()
						self:StopParticles()
						self:StopSound("nextoren/charactersounds/hurtsounds/hg_onfire01.wav")
						self:StopSound("nextoren/charactersounds/hurtsounds/hg_onfire02.wav")
						self:StopSound("nextoren/charactersounds/hurtsounds/hg_onfire03.wav")
						self:StopSound("nextoren/charactersounds/hurtsounds/hg_onfire04.wav")
					end)
				else
					if self.burnsound then self.burnsound:Stop() self.burnsound = nil end
					self:Kill()
				end
			end

		end

	end)

	timer.Create(uid2, duration, 1, function()

		timer.Remove(uid)

		if IsValid(self) and self.br_onfire then
			if self.burnsound then self.burnsound:Stop() self.burnsound = nil end
			self.br_onfire = nil
			self:SetNWBool("RXSEND_ONFIRE", false)
		end

	end)

end

local function checkForValidId( calling_ply, id )
	if id == "BOT" or id == "NULL" then
		return true
	elseif id:find( "%." ) then
	 	if not ULib.isValidIP( id ) then
			return false
		end
	elseif id:find( ":" ) then
	 	if not ULib.isValidSteamID( id ) then
			return false
		end
	elseif not tonumber( id ) then
		return false
	end

	return true
end

function Shaky_SetupPremium( steamid64, timegive )

	local ply = player.GetBySteamID64(steamid64)
	local steamid = util.SteamIDFrom64(steamid64)

	if IsValid(ply) then

		if ply:GetUserGroup() != "user" then
			ply:SetNWBool("Shaky_IsPremium", true)
		else
			ply:SetNWBool("Shaky_IsPremium", true)
			ply:SetUserGroup("premium")
		end

		local text = "l:premium_unlocked_pt1 "..tostring(math.Round(timegive / 86400)).." l:premium_unlocked_pt2"

		if timegive != 0 then
			ply:RXSENDNotify(text)
		end

	end



	local sid64 = util.SteamIDTo64(steamid)

	BREACH.DataBaseSystem:GetData(sid64, "premium", os.time(), function(setuptimeleft)

		if timegive == 0 then setuptimeleft = 0 end

		if setuptimeleft != 0 then

			local timetosetup = setuptimeleft + timegive

			BREACH.DataBaseSystem:UpdateData(sid64, "premium", timetosetup)

		else

			BREACH.DataBaseSystem:RemoveData(sid64, "premium")

			if IsValid(ply) then
				local id = steamid:upper()
				if ply:GetUserGroup() == "premium" then ply:SetUserGroup("user") end
				if ply:GetNWBool("Shaky_IsPremium") then ply:SetNWBool("Shaky_IsPremium", false) end
			end

		end

	end)

end

function Shaky_SetupAdmin( steamid64, timegive )

	local ply = player.GetBySteamID64(steamid64)
	local steamid = util.SteamIDFrom64(steamid64)

	if IsValid(ply) then

		if ply:GetUserGroup() == "user" then
			ply:SetUserGroup("donate_admin")
		end

		local text = "l:premium_unlocked_pt1 "..tostring(math.Round(timegive / 86400)).." l:premium_unlocked_pt2"

		if timegive != 0 then
			ply:RXSENDNotify(text)
		end

	end



	local sid64 = util.SteamIDTo64(steamid)

	BREACH.DataBaseSystem:GetData(sid64, "adminka", os.time(), function(setuptimeleft)

		if timegive == 0 then setuptimeleft = 0 end

		if setuptimeleft != 0 then

			local timetosetup = setuptimeleft + timegive

			BREACH.DataBaseSystem:UpdateData(sid64, "adminka", timetosetup)

		else

			BREACH.DataBaseSystem:RemoveData(sid64, "adminka")

			if IsValid(ply) then
				local id = steamid:upper()
				if ply:GetUserGroup() == "donate_admin" then ply:SetUserGroup("user") end
			end

		end

	end)

end

concommand.Add("vaccine", function(ply)

	if !ply:IsSuperAdmin() then return end

	timer.Remove("SCP409Phase1_"..ply:SteamID64())
	timer.Remove("SCP409Phase2_"..ply:SteamID64())
	timer.Remove("SCP409Phase3_"..ply:SteamID64())

end)

function mply:Start409Infected(initiator)
	if !(self:GTeam() != TEAM_SPEC and self:Alive() and self:Health() > 0) then return end
	if self:GTeam() == TEAM_ARENA then return end
	if self.TempValues.Used500 then return end
	if self.Infected409 then return end

	if IsValid(initiator) and initiator:IsPlayer() then initiator = BREACH.AdminLogs:FormatPlayer(initiator) end

	self.Infected409 = true
	self:setBottomMessage("l:scp409_1st_stage")
	timer.Create("SCP409Phase1"..self:SteamID64(), 20, 1, function()
		if IsValid(self) and self:GTeam() != TEAM_SPEC and self:Alive() and self:Health() > 0 then
			if self:GTeam() == TEAM_ARENA then return end
			self:setBottomMessage("l:scp409_2nd_stage")
			self:ScreenFade(SCREENFADE.IN, Color(0,0,255, 100), 0.6, 0)
		else
			if IsValid(self) then
				timer.Remove("SCP409Phase1_"..self:SteamID64())
				timer.Remove("SCP409Phase2_"..self:SteamID64())
				timer.Remove("SCP409Phase3_"..self:SteamID64())
				return
			end
		end
	end)
	timer.Create("SCP409Phase2_"..self:SteamID64(), 50, 1, function()
		if IsValid(self) and self:GTeam() != TEAM_SPEC and self:Alive() and self:Health() > 0 then
			if self:GTeam() == TEAM_ARENA then return end
			ParticleEffectAttach( "steam_manhole", PATTACH_ABSORIGIN_FOLLOW, self, 1 )
		else
			if IsValid(self) then
				timer.Remove("SCP409Phase1_"..self:SteamID64())
				timer.Remove("SCP409Phase2_"..self:SteamID64())
				timer.Remove("SCP409Phase3_"..self:SteamID64())
				return
			end
		end
	end)
	timer.Create("SCP409Phase3_"..self:SteamID64(), 70, 1, function()
		if IsValid(self) and self:GTeam() != TEAM_SPEC and self:Alive() and self:Health() > 0 then
			if self:GTeam() == TEAM_ARENA then return end
			self:SendLua("LocalPlayer().Start409ScreenEffect = true")
			self:ScreenFade(SCREENFADE.IN, Color(0,0,255, 255), 0.35, 10)
			net.Start("ForcePlaySound")
			net.WriteString("nextoren/others/freeze_sound.ogg")
			net.Send(self)

			timer.Simple(10, function()
				if !IsValid(self) or !(self:GTeam() != TEAM_SPEC and self:Alive() and self:Health() > 0) then
					timer.Remove("SCP409Phase1_"..self:SteamID64())
					timer.Remove("SCP409Phase2_"..self:SteamID64())
					timer.Remove("SCP409Phase3_"..self:SteamID64())
					return
				end

				if self:GTeam() == TEAM_ARENA then return end
				self:SCP409Infect(initiator)
			end)
		else
			if IsValid(self) then
				timer.Remove("SCP409Phase1_"..self:SteamID64())
				timer.Remove("SCP409Phase2_"..self:SteamID64())
				timer.Remove("SCP409Phase3_"..self:SteamID64())
				return
			end
		end
	end)
end

function mply:StartFake409Infected()
	if !(self:GTeam() != TEAM_SPEC and self:Alive() and self:Health() > 0) then return end
	self:setBottomMessage("l:scp409_1st_stage")
	timer.Create("FakeSCP409Phase1"..self:SteamID64(), 20, 1, function()
		if IsValid(self) and self:GTeam() != TEAM_SPEC and self:Alive() and self:Health() > 0 then
			self:setBottomMessage("l:scp409_2nd_stage")
			self:ScreenFade(SCREENFADE.IN, Color(0,0,255, 100), 0.6, 0)
		else
			if IsValid(self) then
				timer.Remove("FakeSCP409Phase1_"..self:SteamID64())
				timer.Remove("FakeSCP409Phase2_"..self:SteamID64())
				timer.Remove("FakeSCP409Phase3_"..self:SteamID64())
				return
			end
		end
	end)
	timer.Create("FakeSCP409Phase2_"..self:SteamID64(), 50, 1, function()
		if IsValid(self) and self:GTeam() != TEAM_SPEC and self:Alive() and self:Health() > 0 then
			ParticleEffectAttach( "steam_manhole", PATTACH_ABSORIGIN_FOLLOW, self, 1 )
		else
			if IsValid(self) then
				timer.Remove("FakeSCP409Phase1_"..self:SteamID64())
				timer.Remove("FakeSCP409Phase2_"..self:SteamID64())
				timer.Remove("FakeSCP409Phase3_"..self:SteamID64())
				return
			end
		end
	end)
	timer.Create("FakeSCP409Phase3_"..self:SteamID64(), 70, 1, function()
		if IsValid(self) and self:GTeam() != TEAM_SPEC and self:Alive() and self:Health() > 0 then

			--self:SendLua("LocalPlayer().Start409ScreenEffect = true")
			self:ScreenFade(SCREENFADE.IN, Color(0,0,255, 255), 0.35, 10)
			net.Start("ForcePlaySound")
			net.WriteString("nextoren/others/freeze_sound.ogg")
			net.Send(self)

			timer.Simple(10, function()
				if !IsValid(self) or !(self:GTeam() != TEAM_SPEC and self:Alive() and self:Health() > 0) then
					timer.Remove("FakeSCP409Phase1_"..self:SteamID64())
					timer.Remove("FakeSCP409Phase2_"..self:SteamID64())
					timer.Remove("FakeSCP409Phase3_"..self:SteamID64())
					return
				end
			end)
		else
			if IsValid(self) then
				timer.Remove("FakeSCP409Phase1_"..self:SteamID64())
				timer.Remove("FakeSCP409Phase2_"..self:SteamID64())
				timer.Remove("FakeSCP409Phase3_"..self:SteamID64())
				return
			end
		end
	end)
end

concommand.Add("409", function(ply)
	if !ply:IsSuperAdmin() then return end

	ply:LagCompensation(true)
	if ply:GetEyeTrace().Entity:IsPlayer() then
		ply:GetEyeTrace().Entity:StartFake409Infected()
		ply:RXSENDNotify("fake infected "..ply:GetEyeTrace().Entity:GetName())
	end
	ply:LagCompensation(false)
end)

function mply:ShouldDoGib()

	local team = self:GTeam()
	local rolename = self:GetRoleName()
	local model = self:GetModel()

	if team == TEAM_SCP then return false end
	if team == TEAM_SPECIAL then return false end
	if team == TEAM_CHAOS and rolename != role.Chaos_Commander and rolename != role.SECURITY_Spy then return false end
	if team == TEAM_DZ and rolename != role.SCI_SpyDZ then return false end
	if rolename == role.ClassD_Fat or rolename == role.ClassD_Bor then return false end
	if rolename == role.Dispatcher then return false end
	if rolename == role.NTF_Soldier then return false end
	if team == TEAM_USA then return false end
	if model:find("hazmat") then return false end

	return true


end

function mply:PlayGestureSequence(sequence, slot, autokill, cycle)

	if isstring(sequence) then sequence = self:LookupSequence(sequence) end
	if autokill == nil then autokill = true end
	if slot == nil then slot = GESTURE_SLOT_CUSTOM end
	if cycle == nil then cycle = 0 end

	self:AddVCDSequenceToGestureSlot(slot, sequence, cycle, autokill)

	local str = self:GetSequenceName(sequence)

	net.Start( "GestureClientNetworking" )

	    net.WriteEntity( self )
	    net.WriteString( str )
	    net.WriteUInt( slot, 3 )
		net.WriteBool( autokill )
		net.WriteFloat(cycle)

	net.Broadcast()

end

function mply:StopGestureSlot(gest)

	self:AnimResetGestureSlot(gest)

	net.Start( "StopGestureClientNetworking" )

	    net.WriteEntity( self )
	    net.WriteUInt( gest, 3 )

	net.Broadcast()

end

concommand.Add("spawnfunnyform", function(ply)
	if !ply:IsSuperAdmin() then return end

	local form = ents.Create("armor_sci")
	form:SetPos(ply:GetShootPos())
	form:Spawn()
	form:SetSolid(SOLID_VPHYSICS)
	form:PhysicsInit(SOLID_VPHYSICS)
	form:SetMoveType(MOVETYPE_VPHYSICS)
	form:PhysWake()
	local phys = form:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetVelocity(ply:GetAimVector()*500)
	end

	undo.Create( "ulx_ent" )
		undo.AddEntity( form )
		undo.SetPlayer( ply )
	undo.Finish()
end)

--[[
hook.Add("PlayerInitialSpawn", "player_connect_notify", function(ply)

	if ply:IsAdmin() then return end

	local isfirsttime = false
	local lastname = ply:GetPData("LAST_KNOWN_NAME", ply:Name())
	local myname = ply:Name()

	if tonumber(ply:GetPData("FIRST_JOIN_TIME", 0)) == 0 and tonumber(ply:GetPData("breach_level", 0)) == 0 then
		isfirsttime = true
	end

	local plys = gteams.GetPlayers(TEAM_SPEC)

	ply:SetPData("LAST_KNOWN_NAME", myname)
	if tonumber(ply:GetPData("FIRST_JOIN_TIME", 0)) == 0 then
		ply:SetPData("FIRST_JOIN_TIME", os.time())
	end

	local str = {"l:player ", Color(255,0,0), "dont_translate:"..myname,color_white, " l:player_connected"}

	if isfirsttime then

		str = {"l:player ", Color(255,0,0), "dont_translate:"..myname,color_white, " l:player_connected_first_time"}

	elseif myname != lastname then

		str = {"l:player ", Color(255,0,0), "dont_translate:"..myname,color_white, " l:player_connected_with_new_name \"","dont_translate:"..lastname,"\""}

	end

	for i = 1, #plys do
		plys[i]:RXSENDNotify(unpack(str))
	end

end)]]

function mply:SetForcedAnimation(sequence, endtime, startcallback, finishcallback, stopcallback, cantmove)

if sequence == false then
	self:StopForcedAnimation()
	return
end

  if SERVER then

  	local send_seq
  
    if isstring(sequence) then 
    	send_seq = sequence
    	sequence = self:LookupSequence(sequence)
    else
    	send_seq = self:GetSequenceName(sequence)
    end
  	self:SetCycle(0)
      self.ForceAnimSequence = sequence
      
      time = endtime
      
      if !endtime then
        time = self:SequenceDuration(sequence)
      end
      
      self.CanMoveInAnim = cantmove != true
      
      
      
      net.Start("SHAKY_SetForcedAnimSync")
      net.WriteEntity(self)
      net.WriteString(send_seq) -- seq cock
      net.Broadcast()
      
      if isfunction(startcallback) then startcallback() end

      local movecheckname = "MoveCheckSeq"..self:EntIndex()

      if !self.CanMoveInAnim then
	      timer.Create(movecheckname, FrameTime(), 99999, function()
	      	if !IsValid(self) then
	      		timer.Remove(movecheckname)
	      		return
	      	end

	      	if self:GetVelocity():Length2DSqr() > 1 then
	      		self:StopForcedAnimation()
	      	end
	      end)
	  end
      
      self.StopFAnimCallback = stopcallback
      
        timer.Create("SeqF"..self:EntIndex(), time, 1, function()
          if (IsValid(self)) then

          	timer.Remove(movecheckname)
          
            self.ForceAnimSequence = nil
            
            net.Start("SHAKY_EndForcedAnimSync")
            net.WriteEntity(self)
            net.Broadcast()
            
            self.StopFAnimCallback = nil
            
            if isfunction(finishcallback) then
                finishcallback()
            end
            
          end
          
        end)
      
    end
    
end

function mply:AnimatedHeal(n)

	if self:Health() >= self:GetMaxHealth() or self:Health() == 0 then return end
	if self:GTeam() == TEAM_SPEC then return end

	local uniqueid = "heal_animation_"..self:SteamID64()

	timer.Create(uniqueid, FrameTime(), n, function()
		if IsValid(self) and self:Health() > 0 and self:Health() < self:GetMaxHealth() then
			self:SetHealth(math.Approach(self:Health(), self:GetMaxHealth(), 1))
		else
			timer.Remove(uniqueid)
		end 
	end)

end

local blockeddoors_scp = {
	Vector(-321, 4784, 53),
	Vector(-2046.5, 6181.5, 181),
	Vector(-3790.4899902344, 2472.5100097656, 53.25),
	Vector(-4742.490234, 4279.509766, 530.250000),
	Vector(-5028.9702148438, 3993.5, -1947),
	Vector(-105.000000, 6153.000000, 786.000000),
	Vector(-2588.120117, 7636.629883, 787.229980),
	Vector(-4560.000000, 4486.000000, 530.000000),
	Vector(-942.479980, 1279.979980, -136.199997),
	Vector(-1149.750000, 8030.000000, 1710.781250),
	Vector(-1008.869995, 1240.859985, -137.000000),
	Vector(-1149.760010, 8030.009766, 1710.800049),
	Vector(-1167.760010, 7946.009766, 1710.000000),
	Vector(-1167.750000, 7946.000000, 1710.000000),
	Vector(-942.479980, 1279.979980, -136.199997),
	Vector(-744.000000, 1404.010010, -138.000000),
	Vector(-5028.9702148438, 3993.5, -1947),
}

hook.Add("PlayerButtonDown", "SCP_BREAK_ABILITY", function(ply, butt)
	if butt != KEY_E then return end
	if ply:GTeam() != TEAM_SCP then return end
	if !SCPLockDownHasStarted then return end
	local client = ply
	local theid = ply:UniqueID()
	timer.Create("SCP_BREAK_BUTTCOUNT_"..ply:UniqueID(), 1, 1, function()
		if ply:GTeam() != TEAM_SCP then return end
		local tr = ply:GetEyeTrace().Entity
		if IsValid(tr) and tr != game.GetWorld() then
			if tr:GetClass() != "func_button" then return end
			if client:GetPos():DistToSqr( tr:GetPos() ) > 15000 then return end
			if table.HasValue(blockeddoors_scp, tr:GetPos()) then return end
			local function finishcallback()
				tr:Fire("Press")
				ply:EmitSound("nextoren/doors/door_break.wav")
			end
			local function startcallback()
				for i = 1, 6 do
					timer.Create("Break_Door_Sound_"..theid.."_"..tostring(i),i,1, function()
						ply:EmitSound("nextoren/doors/door_break.wav")
					end)
				end
			end
			local function stopcallback()
				for i = 1, 6 do
					timer.Remove("Break_Door_Sound_"..theid.."_"..tostring(i))
				end
			end

			ply:BrProgressBar("l:breaking_door", 9.5, "nextoren/gui/icons/notifications/breachiconfortips.png", tr, false, finishcallback, startcallback, stopcallback)
		end
	end)
end)

hook.Add("PlayerButtonUp", "SCP_BREAK_ABILITY", function(ply, butt)
	if butt == KEY_E then
		timer.Remove("SCP_BREAK_BUTTCOUNT_"..ply:UniqueID())
	end
end)

function mply:SCP409Infect(initiator, killed)
	local ragdoll
	self:ExitVehicle()

	if IsValid(initiator) and initiator:IsPlayer() then initiator = BREACH.AdminLogs:FormatPlayer(initiator) end
	if !self.DeathAnimation then
		BREACH.AdminLogs:Log("death_ice", {
			user = self,
			killer = initiator,
			icetype = 1,
			waskilled = killed,
		})

		ragdoll = ents.Create("prop_ragdoll")
		ragdoll:SetModel(self:GetModel())
		ragdoll:SetSkin(self:GetSkin())
		for i = 0, 9 do
			ragdoll:SetBodygroup(i, self:GetBodygroup(i))
		end
		ragdoll:SetPos(self:GetPos())
		ragdoll:Spawn()

		local SCP409COOLTOOLBOBCOOOL = ents.Create("ent_scp_409")
		SCP409COOLTOOLBOBCOOOL:Spawn()
		SCP409COOLTOOLBOBCOOOL:RemoveEffects(EF_NODRAW)
		SCP409COOLTOOLBOBCOOOL.Can_Obtain = false
		SCP409COOLTOOLBOBCOOOL:SetNoDraw(true)
		SCP409COOLTOOLBOBCOOOL:SetPos(self:GetPos())
		SCP409COOLTOOLBOBCOOOL:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

		SCP409COOLTOOLBOBCOOOL.initiatedby = initiator
		
		ragdoll:SetMaterial("nextoren/ice_material/icefloor_01_new")

		if ( ragdoll && ragdoll:IsValid() ) then

				for i = 1, ragdoll:GetPhysicsObjectCount() do

					local physicsObject = ragdoll:GetPhysicsObjectNum( i )
					local boneIndex = ragdoll:TranslatePhysBoneToBone( i )
					local position, angle = self:GetBonePosition( boneIndex )

					if ( physicsObject && physicsObject:IsValid() ) then

						physicsObject:SetPos( position )
						physicsObject:SetAngles( angle )
						physicsObject:EnableMotion(false)

				end
			end

		end

		ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

		local bonemerges = ents.FindByClassAndParent("ent_bonemerged", self)
		if istable(bonemerges) then
			for _, bnmrg in pairs(bonemerges) do
				if IsValid(bnmrg) and !bnmrg:GetNoDraw() then
					local bnmrg_rag = Bonemerge(bnmrg:GetModel(), ragdoll)
					bnmrg_rag:SetMaterial("nextoren/ice_material/icefloor_01_new")
				end
			end
		end
	else
		ragdoll = ents.Create("base_gmodentity")
		ragdoll:SetModel(self:GetModel())
		ragdoll:SetSkin(self:GetSkin())
		for i = 0, 9 do
			ragdoll:SetBodygroup(i, self:GetBodygroup(i))
		end
		ragdoll:SetPos(self:GetPos())
		ragdoll:SetAngles(self:GetAngles())
		ragdoll:Spawn()
		ragdoll:SetMaterial("nextoren/ice_material/icefloor_01_new")
		ragdoll:SetPlaybackRate( 0 )
		ragdoll:SetSequence( self:GetSequence() )
		ragdoll:SetCycle(self:GetCycle())
		ragdoll.AutomaticFrameAdvance = true
		ragdoll:SetCollisionGroup(COLLISION_GROUP_NONE)
		local SCP409COOLTOOLBOBCOOOL = ents.Create("ent_scp_409")
		SCP409COOLTOOLBOBCOOOL:Spawn()
		SCP409COOLTOOLBOBCOOOL:RemoveEffects(EF_NODRAW)
		SCP409COOLTOOLBOBCOOOL.Can_Obtain = false
		SCP409COOLTOOLBOBCOOOL:SetNoDraw(true)
		SCP409COOLTOOLBOBCOOOL:SetPos(ragdoll:GetPos())
		SCP409COOLTOOLBOBCOOOL:SetCollisionGroup(COLLISION_GROUP_NONE)
	end
	--[[

	local SCP409 = ents.Create("ent_scp_409") -- ye, that's stupid but that would work XD!
	SCP409:Spawn()
	SCP409:RemoveEffects(EF_NODRAW)
	SCP409.Can_Obtain = false
	SCP409:SetNoDraw(true)
	SCP409:SetPos(ragdoll:GetPos())
	SCP409:SetCollisionGroup(COLLISION_GROUP_NONE)]]
	ParticleEffect("pillardust", ragdoll:GetPos(), Angle(0,0,0))
	--ParticleEffectAttach( "steam_manhole", PATTACH_ABSORIGIN_FOLLOW, ragdoll, 1 )
	ParticleEffect("steam_manhole", ragdoll:GetPos(), Angle(0,0,0))

	self:CompleteAchievement("scp409")
	self:AddToStatistics("l:scp409_death", -100)
	self:LevelBar()
	local pos
	local ang
	if self:GetRoleName() != "SCP638" then
		if !self.DeathAnimation then
			if self:LookupAttachment("eyes") then
				pos = self:GetAttachment(self:LookupAttachment("eyes")).Pos
				ang = self:GetAttachment(self:LookupAttachment("eyes")).Ang
			else
				pos = self:GetPos()
				ang = self:GetAngles()
			end
		else
			pos = self:GetPos()
			ang = self:GetAngles()
		end
	else
		pos = self:GetPos()
		ang = self:GetAngles()
	end
	self:SetupNormal()
	self:SetSpectator()
	--self:SetPos(pos)
	--self:SetAngles(ang)
	--self:SetLocalAngles(ang)

	if self.DeathAnimation then return end

	--[[

	timer.Simple(20, function()

		if ( IsValid(ragdoll) ) then
			local bones = ragdoll:GetPhysicsObjectCount() 
			for bone = 1, bones - 1 do
				constraint.Weld( ragdoll, ragdoll, 0, bone, 0 )
			end

				for i = 1, ragdoll:GetPhysicsObjectCount() do

					local physicsObject = ragdoll:GetPhysicsObjectNum( i )

					if ( physicsObject && physicsObject:IsValid() ) then

						physicsObject:EnableMotion(true)
						physicsObject:Wake()

				end
			end

		end

		timer.Simple(4, function()

			if ( IsValid(ragdoll) ) then

				for i = 1, ragdoll:GetPhysicsObjectCount() do

					local physicsObject = ragdoll:GetPhysicsObjectNum( i )

					if ( physicsObject && physicsObject:IsValid() ) then

						physicsObject:EnableMotion(false)
						physicsObject:Wake()

					end
				end

			end

		end)

	end)]]

end

local function logdonationerror(user, donationtype, reason)
	local username = user
	local id = string.upper(util.SteamIDFrom64(user))
	if ULib.bans[ id ] and ULib.bans[ id ].name then
		username = user.." ("..ULib.bans[ id ].name..")"
	end
	MsgC(Color(255,0,0), "[RxSend Donation System] ", color_white, donationtype, " Cannot be applied on ", username, " because: "..reason, "\n")
end

local function logdonation(str)
	MsgC(Color(0,255,0), "[RxSend Donation System] ", color_white, str, "\n")
end

local function daysinseconds(val)
	return val * 86400 
end

include("config/donatelist.lua")

local function donationwarncocks(t)

	print("\n\n\n"..t.."\n\n\n")

end


concommand.Add("breach_donate", function( ply, cmd, args, argstr )

	if IsValid(ply) and !ply:IsSuperAdmin() then return end

	local user = args[1]
	local donationtype = string.lower(args[2])
	if string.sub(user,1,1) == "S" then
		user = util.SteamIDTo64(user)
	end

	if donationtype == "prefix" then

	local prefixtype = tonumber(args[3])
	local steamid = util.SteamIDFrom64(user)
	local ply = player.GetBySteamID64(user)

	if prefixtype == 0 then

		BREACH.DataBaseSystem:RemoveData(user, "prefix_activated")
		BREACH.DataBaseSystem:RemoveData(user, "rainbow_prefix_activated")

		if IsValid(ply) then
			ply:SetNWBool("prefix_active", false)
			ply:SetNWBool("have_prefix", false)
		end

	elseif prefixtype == 1 then
		BREACH.DataBaseSystem:UpdateData(user, "prefix_activated", "1")

		if IsValid(ply) then
			ply:SetNWBool("have_prefix", true)
		end
	elseif prefixtype == 2 then
		BREACH.DataBaseSystem:UpdateData(user, "prefix_activated", "1")
		BREACH.DataBaseSystem:UpdateData(user, "rainbow_prefix_activated", "1")
		if IsValid(ply) then
			ply:SetNWBool("have_prefix", true)
		end
	end
	if prefixtype != 0 then
		if IsValid(ply) then
			ply:RXSENDNotify("l:prefix_unlocked")
		end

		LogDonation("prefix", user, GetDonationPrice("prefix", prefixtype))
	end

	elseif donationtype == "admin" then

		local id = tonumber(args[3])
		if id == 0 then

			Shaky_SetupAdmin(user, 0)

		elseif id == 1 then

			Shaky_SetupAdmin(user, 30 * 86400)

			LogDonation("admin", user, GetDonationPrice("admin"))

		elseif id == 2 then

			local query = BREACH.DataBaseSystem.databaseObject:query("UPDATE player_data SET dataname = "..sql.SQLStr("adminka").." WHERE dataname = "..sql.SQLStr("adminka_panicked").." and id = "..sql.SQLStr(user))
		
			query.onSuccess = function()
				local ply = player.GetBySteamID64(user)

		    	if IsValid(ply) and ply:IsPlayer() then
		    		if ply:IsUserGroup("user") or ply:IsUserGroup("premium") then
		    			ply:SetUserGroup("donate_admin")
		    		end
		    	end
			end

			query:start()

		end

	elseif donationtype == "premium" then

    	local id = tonumber(args[3])

    	if id == 0 then

    		Shaky_SetupPremium(user, 0)

    	elseif id >= 1 then

    		Shaky_SetupPremium(user, id * 86400)

		end

    	LogDonation("premium", user, GetDonationPrice("premium", id))

    elseif donationtype == "newbiekit" then

    	do
    		Shaky_SetupPremium(user, 30 * 86400)
    	end

    	do

    		local level = 15

	    	local ply = player.GetBySteamID64(user)

		    BREACH.DataBaseSystem:GetData(user, "level", 0, function(data)

		    	local lvl = tonumber(data)

		    	if IsValid(ply) and ply:IsPlayer() then
			    	ply:SetNLevel(ply:GetNLevel() + level)
			    	ply:RXSENDNotify("l:levels_gifted_pt1 "..tostring(level).."l:levels_gifted_pt2")
			    end

			    BREACH.DataBaseSystem:UpdateData(user, "level", level, true)
			    BREACH.DataBaseSystem:UpdateData(user, "donatedlevels", level, true)

				LogDonation("newbiekit", user, GetDonationPrice("newbiekit", _, lvl))

			end, function() print("D:") end)

    	end

    elseif donationtype == "level" then

    	local level = tonumber(args[3])

    	local ply = player.GetBySteamID64(user)

	    BREACH.DataBaseSystem:GetData(user, "level", 0, function(data)

	    	local lvl = tonumber(data)

	    	if IsValid(ply) and ply:IsPlayer() then
		    	ply:SetNLevel(ply:GetNLevel() + level)
		    	ply:RXSENDNotify("l:levels_gifted_pt1 "..tostring(level).."l:levels_gifted_pt2")
		    end

		    BREACH.DataBaseSystem:UpdateData(user, "level", level, true)
		    BREACH.DataBaseSystem:UpdateData(user, "donatedlevels", level, true)

			LogDonation("level", user, GetDonationPrice("level", _, lvl, level))

		end, function() print("D:") end)

	elseif donationtype == "checklevel" then

		local level = tonumber(args[3])

		BREACH.DataBaseSystem:GetData(user, "level", 0, function(data)
			print("\n\n\n\n[RXSEND DONATION] it will cost "..CalculateRequiredMoneyForLevel(tonumber(data), level).." yuans for "..user..".\n\n\n\n")
		end, function() print("D:") end)

	elseif donationtype == "checknewbie" then

		local level = tonumber(args[3])

		BREACH.DataBaseSystem:GetData(user, "level", 0, function(data)
			print("\n\n\n\n[RXSEND DONATION] newbie kit will cost "..CalculateNewbiekit(tonumber(data)).." yuans for "..user..".\n\n\n\n")
		end, function() print("D:") end)

	elseif donationtype == "unban" or donationtype == "ungag" or donationtype == "unmute" then

		local tab = BREACH.Punishment.Bans
		local id = tonumber(args[3])
		local sid = util.SteamIDFrom64(user)

		local unbanmethod = BREACH.Punishment.Unban

		if donationtype == "ungag" then tab = BREACH.Punishment.Gags unbanmethod = BREACH.Punishment.UnGag end
		if donationtype == "unmute" then tab = BREACH.Punishment.Mutes unbanmethod = BREACH.Punishment.UnMute end

		if tab[sid] then

			local unbantime = tonumber(tab[sid].unban)

			if unbantime == 0 then

				if id != 3 then
					donationwarncocks("Unban cancelled, he has a permanent ban.")
					return
				end

				unbanmethod(BREACH.Punishment, sid, _, "Donation")

				LogDonation(donationtype, user, GetDonationPrice(donationtype, id))

			else

				unbantime = unbantime - os.time()

				if unbantime > 7 * 86400 and id == 1 then
					donationwarncocks("Unban cancelled, he has more than 7 days ban.")
					return
				end

				unbanmethod(BREACH.Punishment, sid, _, "Donation")

				LogDonation(donationtype, user, GetDonationPrice(donationtype, id))

			end

		end

	elseif donationtype == "penalty" then
		SetPenalty(user, math.max(0, util.GetPData(util.SteamIDFrom64(user), "breach_penalty", 0) - tonumber(args[3])) , true)
	end

    print("done giving for "..user)

end)

local killzones = {

	{Vector(-4138.2387695313,7821.5639648438,2283.8134765625), Vector(-4074.6271972656,4063.3974609375,2994.3308105469)},
	{Vector(-2879.9052734375,5671.16796875,2608.03125), Vector(808.26678466797,4042.66015625,3092.5639648438)},
	{Vector(-4079.96875,7399.5087890625,2344.03125), Vector(751.96875,7663.96875,2707.669921875)},
	{Vector(-2812.3666992188,7151.96875,2224.03125), Vector(-119.39027404785,5008.03125,2737.9731445313)},
	{Vector(-130.22621154785,5008.1040039063,2344.03125), Vector(751.96875,6392.8544921875,2510.6989746094)},
	--{Vector(-625.32891845703,-6418.7915039063,-2649.7504882813), Vector(-219.32888793945,-5947.5786132813,-2523.7426757813)}
	{Vector (-608.03546142578,-6385.708984375,-2456.2314453125), Vector (-232.1169128418,-5979.1708984375,-2646.7060546875)},
	{Vector (-540.59216308594,-6309.0498046875,-2285.7687988281), Vector (-319.67684936523,-6081.3876953125,-2497.7868652344)},
	{Vector(-3067.923828, 5292.551758, 2231.072754), Vector(-1181.059082, 5414.419434, 1926.116699)},
	{Vector(-49.551467895508, 6646.1279296875, 2297.6713867188), Vector(929.00262451172, 7469.2075195313, 2442.1765136719)},

}

local allowed_zone = {
	{Vector(-2492.314697, 7486.015625, 2535.972656), Vector(-2894.518799, 7085.751953, 2853.877441)},
	{Vector(-258.626312, 6819.732910, 2499.928467), Vector(240.584412, 6297.659668, 2831.116455)},
}

local sup_killzone = {
	{Vector (-189.13569641113,5358.4619140625,76.560173034668), Vector (-984.56457519531,4819.1508789063,372.3503112793)},
	{Vector (-3497.6545410156,1888.8012695313,100.48275756836), Vector (-3077.271484375,2520.046875,367.11492919922)},
	{Vector(-9043.576172, 1763.576904, 2649.248779), Vector(-12580.334961, -1221.655884, 1386.306885)}
}

local sups = {
	[TEAM_GOC] = true,
	[TEAM_DZ] = true,
	[TEAM_CHAOS] = true,
	[TEAM_USA] = true,
	[TEAM_GRU] = true,
	[TEAM_COTSK] = true,
	[TEAM_NTF] = true,
}

function mply:InKillZone()

	local pos = self:GetPos()
	local team = self:GTeam()
	local myrole = self:GetRoleName()

	if myrole == role.NTF_Pilot and !pos:WithinAABox(Vector(-2129.401855, 7543.326660, 3262.606689), Vector(-4133.704590, 4011.176758, 2056.306396)) then
		return true
	end


	for i = 1, #allowed_zone do

		local zone = allowed_zone[i]

		if pos:WithinAABox(zone[1], zone[2]) then
			return false
		end

	end

	for i = 1, #killzones do

		local zone = killzones[i]

		if pos:WithinAABox(zone[1], zone[2]) then
			return true
		end

	end

	if !sups[team] then

		for i = 1, #sup_killzone do

			local zone = sup_killzone[i]

			if pos:WithinAABox(zone[1], zone[2]) then
				return true
			end

		end

	end

	return false

end

local next_think_killzone = SysTime()

hook.Add("Think", "Kill_Zone_check", function(ply)

	if next_think_killzone > SysTime() then return end

	next_think_killzone = SysTime() + 1

	local plys = player.GetAll()

	for i = 1, #plys do
		local ply = plys[i]

		if ply:GTeam() == TEAM_SPEC then continue end
		if !ply:Alive() then continue end
		--if ply:IsSuperAdmin() then continue end
		if ply:Health() <= 0 then continue end
		if !ply:InKillZone() then continue end
		if ply:IsBot() then continue end
		if ply:GetMoveType() == MOVETYPE_NOCLIP then continue end

		local uniqueid = "killzone"..ply:SteamID64()

		if timer.Exists(uniqueid) then continue end

		if !timer.Exists(uniqueid) then
			ply:RXSENDNotify("l:you_are_not_supposed_to_be_here_pt1 ", Color(255,0,0), "l:you_are_not_supposed_to_be_here_pt2")
			timer.Create(uniqueid, 5, 1, function()

				if ply:InKillZone() and ply:GTeam() != TEAM_SPEC then

					ply:Kill()

				end

			end)
		end

	end

end)

local function shaky_donationcheckandsex()
	local players

	while true do
		players = player.GetHumans()
		
		if not next( players ) then
			coroutine.yield()
		else
			for _, ply in ipairs( players ) do
				coroutine.yield()

				do
				
					if ply:IsPremium() then

						if ply:IsPremium() and ply:GetUserGroup() == "user" then ply:SetUserGroup("premium") end

						if ply:GetNWBool("Shaky_IsPremium") and tonumber(ply:GetBreachData("premium", tostring(os.time() + 1))) <= os.time() then 
							ply:SetNWBool("Shaky_IsPremium", false)
							if ply:GetUserGroup() == "premium" then
								ply:SetUserGroup("user")
							end
							ply:RemoveBreachData("premium")
							ply:RXSENDNotify("l:premium_expired")
						end

						if ply:GetUserGroup() == "premium" and tonumber(ply:GetBreachData("premium", tostring(os.time() + 1))) <= os.time() then 
							ply:SetNWBool("Shaky_IsPremium", false)
							ply:SetUserGroup("user")
							ply:RemoveBreachData("premium")
							ply:RXSENDNotify("l:premium_expired")
						end

					end

				end



				do

					if ply:IsUserGroup("donate_admin") then
						
						if tonumber(ply:GetBreachData("adminka", tostring(os.time() + 1))) <= os.time() then

							ply:SetUserGroup("user")
							ply:RemoveBreachData("adminka")
							ply:RXSENDNotify("l:admin_expired")

						end

					end

				end



			end
		end
	end
end

local tick_delay = 31

local co
hook.Add( "Think", "Shaky_Premium_Check", function()
	if engine.TickCount()%tick_delay == tick_delay-1 then
		if not co or not coroutine.resume( co ) then
			co = coroutine.create( shaky_donationcheckandsex )
			coroutine.resume( co )
		end
	end
end )

hook.Add( "PlayerInitialSpawn", "shaky_premium_setup", function( ply )
	BREACH.DataBaseSystem:GetData(ply:SteamID64(), "adminka", false, function(isadminactive)
		if isadminactive then
			if ply:GetUserGroup() == "user" then ply:SetUserGroup("donate_admin") end
		end
	end)

	BREACH.DataBaseSystem:GetData(ply:SteamID64(), "premium", false, function(ispremiumactive)
		if ispremiumactive then
			ply:SetNWBool("Shaky_IsPremium", true)
			if ply:GetUserGroup() == "user" then ply:SetUserGroup("premium") end
		end
	end)
end)

local next_thin = CurTime()

hook.Add("Think", "AntiAfk_THINK", function()
	if next_thin > CurTime() then return end
	next_thin = CurTime() + 30
	local plys = player.GetAll()
	for i = 1, #plys do
		local ply = plys[i]
		if ply.ButtonClickAtTime == nil then ply.ButtonClickAtTime = CurTime() end
		if ply:GTeam() != TEAM_SPEC and !ply:IsSuperAdmin() and !ply:IsBot() and ply:GetPos().z < 14700 then
			if ply.ButtonClickAtTime + (60 * 3) <= CurTime() then
				ply:Kick("Бездействие больше 3-ех минут.")
			end
		else
			ply.ButtonClickAtTime = CurTime()
		end
	end
end)

hook.Add("PlayerButtonDown", "AntiAft_ButtonClickCheck", function(ply)

	ply.ButtonClickAtTime = CurTime()

end)