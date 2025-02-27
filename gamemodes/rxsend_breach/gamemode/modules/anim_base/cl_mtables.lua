local Breach = GM || GAMEMODE

local Derma_StringRequest = Derma_StringRequest;
local RunConsoleCommand = RunConsoleCommand;
local tonumber = tonumber;
local tostring = tostring;
local CurTime = CurTime;
local Entity = Entity;
local unpack = unpack;
local table = table;
local pairs = pairs;
local ScrW = ScrW;
local ScrH = ScrH;
local concommand = concommand;
local timer = timer;
local ents = ents;
local hook = hook;
local math = math;
local draw = draw;
local pcall = pcall;
local ErrorNoHalt = ErrorNoHalt;
local DeriveGamemode = DeriveGamemode;
local vgui = vgui;

function GM:PlayerFireAnimationEvent()
  return true
end

net.Receive( "UpdateClientHoldType", function()

  local client = net.ReadEntity()
  local wep = net.ReadString()

  if ( !( client && client:IsValid() ) ) then return end

  if ( #client:GetWeapons() < 1 ) then return end

  for _, v in ipairs( client:GetWeapons() ) do

    if ( v:GetClass() == wep ) then

      if ( client && client:IsValid() ) then

        hook.Run( "PlayerWeaponChanged", client, v, true )

        break
      end

    end

  end

end )
