local tblGestureAnimsToPlay = {

  1223,
  1457,
  1453,
  1219,
  1144

}

local animationstabletest = animationstabletest || {}
local animgesture_NextThink = animgesture_NextThink || 0

local bannedTeams = {

  [ TEAM_SPEC ] = true,
  [ TEAM_SCP ] = true

}

function BREACH.AnimGestureThink()

  if ( ( animgesture_NextThink || 0 ) >= CurTime() ) then return end

  animgesture_NextThink = CurTime() + 10

  local players = player.GetAll()

  for i = 1, #players do

    local v = players[ i ]

    if ( !( v && v:IsValid() ) || v:IsBot() ) then continue end

    if ( !timer.Exists( "LookAround" .. v:EntIndex() ) && !bannedTeams[ v:GTeam() ] ) then

      timer.Create( "LookAround" .. v:EntIndex(), math.random( 80, 120 ), 1, function()

        if ( v && v:IsValid() && v:Health() > 0 && !bannedTeams[ v:GTeam() ] ) then

          if ( !animationstabletest || #animationstabletest == 0 ) then

            animationstabletest = table.Copy( tblGestureAnimsToPlay )

          end

          local randomanimation = math.random( 1, #animationstabletest )
          local seqid = animationstabletest[ randomanimation ]

          table.remove( animationstabletest, randomanimation )

          v:AddVCDSequenceToGestureSlot( GESTURE_SLOT_VCD, seqid, 0, true )

        end

      end )

    end

  end

end

BREACH.ChatGestures = {

  "hg_headshake", -- hg_headshake
  "hg_nod_left", -- hg_nod_left
  "hg_nod_no", -- hg_nod_no
  "hg_nod_right", -- hg_nod_right
  "hg_nod_yes" -- hg_nod_yes

}

function GM:DoChatGesture( ply, cmd, text )

  local t = utf8.len( text )

  if ( !isnumber( t ) ) then return end

  t = t / 10

  if ( ( ply.SpeechEndTime || 0 ) > CurTime() ) then return end

  ply.SpeechEndTime = CurTime() + t
  ply.SpeechTab = BREACH.ChatGestures

  local random_speechid = ply.SpeechTab[ math.random( 1, #ply.SpeechTab ) ]

  ply:AddVCDSequenceToGestureSlot( GESTURE_SLOT_VCD, ply:LookupSequence(random_speechid), 0, true )

  if ( CLIENT ) then return end

  net.Start( "GestureClientNetworking" )

    net.WriteEntity( ply )
    net.WriteString( random_speechid )
    net.WriteUInt( GESTURE_SLOT_VCD, 3 )
    net.WriteBool( true )

  net.SendPVS( ply:GetPos() )

end
