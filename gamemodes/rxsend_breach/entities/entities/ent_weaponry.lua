
AddCSLuaFile()

ENT.Type        = "anim"
ENT.Category    = "Breach"

ENT.Model       = Model( "models/cultist/armory/armory.mdl" )

function ENT:Initialize()

  if ( SERVER ) then

    self:SetModel( self.Model )
    self:SetMoveType( MOVETYPE_NONE )

    self.BannedUsers = {}
  end

  self:SetSolid( SOLID_VPHYSICS )

end

if ( SERVER ) then

  local MTF_SETUP = {

    [role.MTF_Shock] = "Shotgun",
    [role.MTF_Security] = "Pistol",
    [role.MTF_DocX] = "Revolver",
    [role.MTF_Engi] = "Sniper",
    [role.MTF_Chem] = "SMG1",
    [role.MTF_Medic] = "SMG1",
    [role.MTF_HOF] = "Revolver",
    
  }

  local Teams_Setup = {

        [ role.SECURITY_Recruit ] = {

          weapon = { "cw_kk_ins2_scorpion","breach_keycard_guard_2" },
          ammo = {"cw_kk_ins2_scorpion", 120},
          bodygroups = "11001001",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 1,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 1,
            ["HITGROUP_RIGHTARM"] = 1,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 1,
            ["HITGROUP_RIGHTLEG"] = 1
           },

        },

        [ role.SECURITY_Chief ] = {

          weapon = { "cw_kk_ins2_fnf2000","breach_keycard_guard_4" },
          ammo = {"cw_kk_ins2_fnf2000", 180},
          bodygroups = "12001001",
          bonemerge = "models/cultist/humans/balaclavas_new/balaclava_full.mdl",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 1,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 1,
            ["HITGROUP_RIGHTARM"] = 1,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 1,
            ["HITGROUP_RIGHTLEG"] = 1
           },

        },

        [ role.SECURITY_Sergeant ] = {

          weapon = { "cw_kk_ins2_mpx","breach_keycard_guard_3" },
          ammo = {"cw_kk_ins2_mpx", 180},
          bodygroups = "22001001",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.8,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 0.8,
            ["HITGROUP_RIGHTARM"] = 0.8,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 0.8,
            ["HITGROUP_RIGHTLEG"] = 0.8
           },

        },
        [ role.SECURITY_Corporal ] = {

          weapon = { "cw_kk_ins2_cq300","breach_keycard_guard_2" },
          ammo = {"cw_kk_ins2_cq300", 180},
          bodygroups = "10101001",
          bonemerge = "models/cultist/humans/balaclavas_new/balaclava_half.mdl",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.65,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 0.8,
            ["HITGROUP_RIGHTARM"] = 0.8,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 0.9,
            ["HITGROUP_RIGHTLEG"] = 0.9
           },

        },

        [ role.SECURITY_OFFICER ] = {

          weapon = { "cw_kk_ins2_ump45","breach_keycard_guard_2" },
          ammo = {"cw_kk_ins2_ump45", 180},
          bodygroups = "10101001",
          bonemerge = "models/cultist/humans/balaclavas_new/head_balaclava_month.mdl",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.8,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 0.8,
            ["HITGROUP_RIGHTARM"] = 0.8,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 0.9,
            ["HITGROUP_RIGHTLEG"] = 0.9
           },

        },

        [ role.SECURITY_OFFICER ] = {

          weapon = { "cw_kk_ins2_ump45","breach_keycard_guard_2" },
          ammo = {"cw_kk_ins2_ump45", 180},
          bodygroups = "10101001",
          bonemerge = "models/cultist/humans/balaclavas_new/head_balaclava_month.mdl", 
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.8,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 0.8,
            ["HITGROUP_RIGHTARM"] = 0.8,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 0.9,
            ["HITGROUP_RIGHTLEG"] = 0.9
           },

        },
       

        [ role.SECURITY_Shocktrooper ] ={

          weapon = { "cw_kk_ins2_cstm_ksg","breach_keycard_guard_3" },
          ammo = {"cw_kk_ins2_cstm_ksg", 40},
          bodygroups = "22011101",
          bonemerge = "models/cultist/humans/balaclavas_new/balaclava_full.mdl",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.65,
            ["HITGROUP_CHEST"] = 0.65,
            ["HITGROUP_LEFTARM"] = 0.65,
            ["HITGROUP_RIGHTARM"] = 0.65,
            ["HITGROUP_STOMACH"] = 0.65,
            ["HITGROUP_GEAR"] = 0.65,
            ["HITGROUP_LEFTLEG"] = 0.65,
            ["HITGROUP_RIGHTLEG"] = 0.65
           },

        },

        [ role.SECURITY_Warden ] = {

          weapon = { "cw_kk_ins2_hk416c","breach_keycard_guard_4" },
          ammo = {"cw_kk_ins2_hk416c", 160},
          bodygroups = "12001001",
          bonemerge = true,
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.8,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 0.8,
            ["HITGROUP_RIGHTARM"] = 0.8,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 0.8,
            ["HITGROUP_RIGHTLEG"] = 0.8
           },

        },

        [ role.SECURITY_IMVSOLDIER ] = {

          weapon = { "cw_kk_ins2_blackout","breach_keycard_guard_3" },
          ammo = {"cw_kk_ins2_blackout", 160},
          bodygroups = "22001001",
          bonemerge = "models/cultist/humans/balaclavas_new/balaclava_full.mdl",
          damage_modifiers = {
            ["HITGROUP_HEAD"] = 0.9,
            ["HITGROUP_CHEST"] = 0.8,
            ["HITGROUP_LEFTARM"] = 0.8,
            ["HITGROUP_RIGHTARM"] = 0.8,
            ["HITGROUP_STOMACH"] = 0.8,
            ["HITGROUP_GEAR"] = 0.8,
            ["HITGROUP_LEFTLEG"] = 0.8,
            ["HITGROUP_RIGHTLEG"] = 0.8
           },

        },
      }

  function ENT:Use( survivor )
    if ( ( self.NextUse || 0 ) > CurTime() ) then return end

    self.NextUse = CurTime() + .25

    local gteam = survivor:GTeam()

    if ( gteam != TEAM_SECURITY and gteam != TEAM_GUARD ) or survivor:GetRoleName() == role.Dispatcher then
      survivor:RXSENDNotify("l:weaponry_cant_use")
      return
    end
    
    if gteam == TEAM_GUARD then

      if self.BannedUsers[survivor:GetNamesurvivor()] then
        survivor:RXSENDNotify("l:weaponry_took_ammo_already")
        return
      end

      if survivor:GetRoleName() == role.MTF_Shock then
        survivor:BreachGive("cw_kk_ins2_nade_anm14")
      end

      self.BannedUsers[survivor:GetNamesurvivor()] = true

      local ammotype = "AR2"

      if MTF_SETUP[survivor:GetRoleName()] then
        ammotype = MTF_SETUP[survivor:GetRoleName()]
      end

      local ammo = 30

      for i, v in pairs(survivor:GetWeapons()) do

        if v.GetPrimaryAmmoType and v:GetPrimaryAmmoType() == game.GetAmmoID(ammotype) then
          ammo = v:GetMaxClip1()
        end

      end

      survivor:GiveAmmo(ammo*30, ammotype, true)

      survivor:EmitSound( "nextoren/equipment/ammo_pickup.wav", 75, math.random( 95, 105 ), .75, CHAN_STATIC )

    elseif gteam == TEAM_SECURITY then
      if gteam == TEAM_SECURITY and survivor:GetModel():find("mog.mdl") then
        survivor:RXSENDNotify("l:weaponry_took_uniform_already")
        return
      end
      if gteam != TEAM_SECURITY or !Teams_Setup[survivor:GetRoleName()] then
        survivor:RXSENDNotify("l:weaponry_cant_use")
        return
      end
      if survivor:GetMaxSlots() - survivor:GetPrimaryWeaponAmount() < #Teams_Setup[survivor:GetRoleName()].weapon then
        survivor:RXSENDNotify("l:weaponry_need_slots_pt1 "..tostring(#Teams_Setup[survivor:GetRoleName()].weapon).." l:weaponry_need_slots_pt2")
        return
      end

      if self.BannedUsers[survivor:GetNamesurvivor()] then
        survivor:RXSENDNotify("l:weaponry_took_ammo_already")
        return
      end

      self.BannedUsers[survivor:GetNamesurvivor()] = true
      
      survivor:CompleteAchievement("weaponry")
      local tab = Teams_Setup[survivor:GetRoleName()]
      survivor:EmitSound( Sound("nextoren/others/cloth_pickup.wav"), 125, 100, 1.25, CHAN_VOICE)
      survivor:ScreenFade(SCREENFADE.IN, color_black, 1, 1)
      if survivor:IsFemale() then
        survivor:SetModel("models/cultist/humans/mog/mog_woman_capt.mdl")
      else
        survivor:SetModel("models/cultist/humans/mog/mog.mdl")
        if tab.bonemerge then
          for _, bnmrg in ipairs(survivor:LookupBonemerges()) do
            if bnmrg:GetModel():find("male_head") or bnmrg:GetModel():find("balaclava") then
              local copytext = bnmrg:GetSubMaterial(0)
              local bnmrg_new
              if tab.bonemerge != true then
                bnmrg_new = Bonemerge(tab.bonemerge, survivor)
              else
                bnmrg_new = Bonemerge(PickHeadModel(), survivor)
              end
              bnmrg_new:SetSubMaterial(0, copytext)
              bnmrg:Remove()
            end
          end
        end
      end
      survivor:ClearBodyGroups()
      survivor:SetupHands()
      survivor:SetBodyGroups(tab.bodygroups)
      survivor.ScaleDamage = tab.damage_modifiers
      for _, wep in ipairs(tab.weapon) do
       survivor:BreachGive(wep)
      end
      survivor:GiveAmmo(tab.ammo[2], survivor:GetWeapon(tab.ammo[1]):GetPrimaryAmmoType(), true)
      survivor:RXSENDNotify("l:weaponry_mtf_armor_pt1 ", gteams.GetColor(TEAM_GUARD), "l:weaponry_mtf_armor_pt2")
    end
  end

end

if ( CLIENT ) then

  function ENT:Draw()

    self:DrawModel()

  end

end
