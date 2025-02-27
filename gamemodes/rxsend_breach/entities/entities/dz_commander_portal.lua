AddCSLuaFile()

ENT.Base        = "base_entity"

ENT.Type        = "anim"
ENT.Category    = "Breach"
ENT.Model       = Model( "models/player/Group01/male_01.mdl" )

local teleports_dz_office = {
  {
    Vector(-804.83154296875, 6151.970703125, 242.03125),
    Vector(-806.70880126953, 6261.8735351563, 242.03125),
    Vector(-673.68408203125, 6261.3129882813, 242.03125),
    Vector(-672.34777832031, 6144.8901367188, 242.03125),
    Vector(-553.40893554688, 6149.6987304688, 242.03125),
  },
  {
    Vector(-2174.4145507813, 4933.9340820313, 0.03125),
    Vector(-2016.0612792969, 4831.724609375, 0.03125),
    Vector(-2173.5034179688, 4705.7485351563, 0.03125),
    Vector(-2168.1005859375, 4595.51171875, 0.03125),
    Vector(-2020.97265625, 4493.8569335938, 0.03125),
  },
  {
    Vector(-1494.4248046875, 3452.7919921875, 0.03125),
    Vector(-1618.6362304688, 3457.6867675781, 0.03125),
    Vector(-1743.7496337891, 3462.6174316406, 0.03125),
    Vector(-1830.9549560547, 3420.2829589844, 0.03125),
    Vector(-1855.96875, 3535.96875, 0.03125),
  },
  {
    Vector(-667.51287841797, 3056.8483886719, 18.150749206543),
    Vector(-737.18310546875, 3059.8474121094, 18.150749206543),
    Vector(-798.73693847656, 3062.5881347656, 19.082130432129),
    Vector(-778.36053466797, 3173.4838867188, 0.02734375),
    Vector(-684.92193603516, 3171.2951660156, 0.02734375),
  },
  {
    Vector(680.427734375, 1508.9471435547, 0.03125),
    Vector(677.21081542969, 1625.3916015625, 0.03125),
    Vector(503.86169433594, 1631.46484375, 0.03125),
    Vector(483.17468261719, 1503.0803222656, 0.03125),
    Vector(569.79504394531, 1454.0189208984, 0.03125),
  },
  {
    Vector(-1155.4731445313, 4634.7778320313, 0.03125),
    Vector(-1160.3403320313, 4497.451171875, 0.03125),
    Vector(-1163.2495117188, 4308.2856445313, 0.03125),
    Vector(-1341.1833496094, 4285.2944335938, 0.03125),
    Vector(-1345.0252685547, 4523.0615234375, 0.03125),
  },
  {
    Vector(-1208.2525634766, 3728.03125, -63.96875),
    Vector(-1221.0010986328, 3826.7475585938, -63.96875),
    Vector(-1110.5163574219, 3898.8881835938, -63.96875),
    Vector(-982.13427734375, 3883.3776855469, -63.96875),
    Vector(-900.98211669922, 3815.5607910156, -63.96875),
  },


}

local teleports_dz_office_ignoreplayerradius = {
  {
    Vector(-2781.9211425781, 1897.96875, 256.03125),
    Vector(-2630.5710449219, 1833.96875, 256.03125),
    Vector(-2891.24609375, 1720.3363037109, 256.03125),
    Vector(-2972.3195800781, 1712.2567138672, 256.03125),
    Vector(-2627.171875, 2102.6257324219, 256.03125),
  }
}

local teleport_dz_lz = {
  {
    Vector(8358.228515625, -4368.6494140625, 1.3310508728027),
    Vector(8349.2373046875, -4267.99609375, 1.3310508728027),
    Vector(8255.3505859375, -4284.4389648438, 1.3310508728027),
    Vector(8152.451171875, -4280.9516601563, 1.3310508728027),
    Vector(8166.048828125, -4363.7866210938, 1.3310508728027),
  },
  {
    Vector(9879.5380859375, -2628.1342773438, 1.3310508728027),
    Vector(9750.7412109375, -2628.3869628906, 1.3310508728027),
    Vector(9752.1884765625, -3051.4797363281, 1.3310508728027),
    Vector(9878.8388671875, -3052.6645507813, 1.3310508728027),
    Vector(9815.392578125, -2845.6184082031, 1.3310508728027),
  },
  {
    Vector(7700.0268554688, -3009.4865722656, 1.3310508728027),
    Vector(7700.7836914063, -3150.5166015625, 1.3310508728027),
    Vector(7552.2607421875, -3165.9370117188, 1.3310508728027),
    Vector(7542.7412109375, -3029.1450195313, 1.3310508728027),
    Vector(7411.9091796875, -3022.3488769531, 1.3310508728027),
  },
  {
    Vector(8949.935546875, -2025.5041503906, 1.4442481994629),
    Vector(8957.970703125, -1852.5881347656, 1.4442481994629),
    Vector(9242.2236328125, -1847.1865234375, 1.4442481994629),
    Vector(9240.85546875, -2026.7496337891, 1.4442481994629),
    Vector(8831.18359375, -1871.9442138672, 1.3310508728027),
  },
  {
    Vector(7897.1005859375, -5037.4633789063, 225.33126831055),
    Vector(7903.435546875, -5165.6987304688, 225.33126831055),
    Vector(7900.373046875, -5290.1821289063, 225.33126831055),
    Vector(7897.8081054688, -5423.212890625, 225.33126831055),
    Vector(7896.7446289063, -5551.0390625, 225.33126831055),
  },
  {
    Vector(7472.5795898438, -2429.3698730469, 18.88060760498),
    Vector(7469.16796875, -2494.6667480469, 18.823501586914),
    Vector(7467.83203125, -2562.3547363281, 18.795074462891),
    Vector(7464.7021484375, -2620.0163574219, 18.747146606445),
    Vector(7344.4077148438, -2525.41015625, 1.3310508728027),
  },
  {
    Vector(9056.9130859375, -2937.6564941406, 146.03125),
    Vector(9072.3203125, -2786.5710449219, 146.03125),
    Vector(8986.9365234375, -2792.8188476563, 146.03125),
    Vector(8981.4365234375, -2939.0349121094, 146.03125),
    Vector(9019.810546875, -2855.8569335938, 186.28125),
  },
}

function ENT:GetClosestAlivePlayer(pos, players_poses)
  local closest = math.huge
  for i = 1, #players_poses do
    local cpos = players_poses[i]
    local dsqr = pos:DistToSqr(cpos)
    --print(cpos, dsqr)
    if dsqr < closest then
      closest = dsqr
    end
  end
  return closest
end

function ENT:PickPosition()

  local playerpositions = {}
  local plys = GetAlivePlayers()

  local tab = teleport_dz_lz

  local purerandom = false

  if !(BREACH.TempStats and BREACH.TempStats.DZFirst) then
    local ran = math.random(100)
    if ran <= (#teleports_dz_office_ignoreplayerradius/#teleports_dz_office)*100 then
      purerandom = true
      tab = teleports_dz_office_ignoreplayerradius
    else
      tab = teleports_dz_office
    end
  end

  local poses = tab[1]

  if !purerandom then

    for i = 1, #plys do
      local pos = plys[i]:GetPos()
      table.insert(playerpositions, pos)
    end

    local chances = {}

    for i = 1, #tab do
      chances[i] = {chance = 100/#tab, poses = tab[i], distance = self:GetClosestAlivePlayer(tab[i][1], playerpositions)}
    end

    table.SortByMember( chances, "distance" )
    
    local rr = math.random(0, 100)
    if rr <= 50 then
      rr = 1
    elseif rr <= 80 then
      rr = 2
    else
      rr = 3
    end
    local i = 1

    for _, v in pairs(chances) do
      if rr == i then
        return v.poses
      end
      i = i + 1
    end

    --return chances[math.Rand(1, #chances)].poses

  else
    return tab[math.random(1, #tab)]
  end

  return poses

end

function ENT:Initialize()

  if ( SERVER ) then

    self:SetModel( self.Model )
    self:PhysicsInit( SOLID_NONE )
    self:SetMoveType( MOVETYPE_NONE )
    self:SetSolid( SOLID_NONE )

    self.NextTeleport = 0

    math.randomseed( os.time() )

    self:SetAngles( angle_zero )

    self.Positions = self:PickPosition(self.dooffice)
    self.curpos = 1
    self.alreadyteleported = {}

    self.DeathTime = CurTime() + 30

  end

end

local vec_up = Vector( 0, 0, 36 )

function ENT:Think()

  self:NextThink( CurTime() + .25 )

  if ( CLIENT ) then

    if ( !self.StartPatricle ) then

      self.StartPatricle = true
      ParticleEffect( "mr_portal_2a", self:GetPos() + vec_up, angle_zero, self )

    end

    local dlight = DynamicLight( self:EntIndex() )
    if ( dlight ) then
      dlight.pos = self:GetPos() + Vector(0,0,7)
      dlight.r = 0
      dlight.g = 155
      dlight.b = 0
      dlight.brightness = 3
      dlight.Decay = 400
      dlight.Size = 256
      dlight.DieTime = CurTime() + 5
    end

  end

  if ( SERVER ) then

    if ( ( self.DeathTime || 0 ) - CurTime() < 0 ) then

      self:Remove()

    end

    local nearby_entities = ents.FindInSphere( self:GetPos(), 90 )

    for i = 1, #nearby_entities do

      local v = nearby_entities[ i ]

      if ( v:IsPlayer() && v:GTeam() != TEAM_SPEC && self.NextTeleport < CurTime() ) then

        if self.alreadyteleported[v] then continue end

        self.alreadyteleported[v] = true

        self.NextTeleport = CurTime() + 0.1

        self:EmitSound( "ambient/machines/teleport3.wav", 75, math.random( 80, 100 ), 1, CHAN_STATIC )

        v:ScreenFade( SCREENFADE.OUT, color_white, .1, 1 )

        local pos = self.Positions[self.curpos]
        self.curpos = self.curpos + 1
        if self.curpos > #self.Positions then
          self.curpos = 1
        end

        v:GuaranteedSetPos( pos )

        net.Start( "ForcePlaySound" )

          net.WriteString( "ambient/machines/teleport3.wav" )

        net.Send( v )

      end

    end

  end

end

function ENT:OnRemove()

	if ( CLIENT ) then

		self:StopAndDestroyParticles()

	end

end

function ENT:Draw() end
