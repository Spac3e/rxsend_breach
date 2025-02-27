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

if SERVER then
  util.AddNetworkString("UpdateClientHoldType")
  util.AddNetworkString("GestureClientNetworking")
end

function GM:PlayerSwitchWeapon(ply, oldw, neww)
  hook.Run( "PlayerWeaponChanged", ply, neww, true )
end

local mply = FindMetaTable("Player")

function mply:PlayGesture(sequence_name)
  net.Start("GestureClientNetworking")
    net.WriteEntity(self)
    net.WriteUInt(self:LookupSequence(sequence_name), 13)
    net.WriteUInt(GESTURE_SLOT_CUSTOM, 3)
    net.WriteBool(true)
  net.Broadcast()
end

concommand.Add("ggesture", function(ply, cmd, args, argstr)
  ply:PlayGesture(argstr)
  ply:SetNWBool("Breach:DrawLocalPlayer", true)
  timer.Create(
    "Breach:Gestures:PlayGesture_"..ply:SteamID(), --name
    ply:SequenceDuration(ply:LookupSequence(argstr)), --delay
    1, --repetitions

    function()
      ply:SetNWBool("Breach:DrawLocalPlayer", false)
    end
  )
end)