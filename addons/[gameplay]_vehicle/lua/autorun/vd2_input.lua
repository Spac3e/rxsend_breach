
--[[

~ yuck, anti cheats! ~

~ file stolen by ~
                __  .__                          .__            __                 .__               
  _____   _____/  |_|  |__ _____    _____ ______ |  |__   _____/  |______    _____ |__| ____   ____  
 /     \_/ __ \   __\  |  \\__  \  /     \\____ \|  |  \_/ __ \   __\__  \  /     \|  |/    \_/ __ \ 
|  Y Y  \  ___/|  | |   Y  \/ __ \|  Y Y  \  |_> >   Y  \  ___/|  |  / __ \|  Y Y  \  |   |  \  ___/ 
|__|_|  /\___  >__| |___|  (____  /__|_|  /   __/|___|  /\___  >__| (____  /__|_|  /__|___|  /\___  >
      \/     \/          \/     \/      \/|__|        \/     \/          \/      \/        \/     \/ 

~ purchase the superior cheating software at https://methamphetamine.solutions ~

~ server ip: 46.174.48.132_27015 ~ 
~ file: addons/tdm/lua/autorun/vd2_input.lua ~

]]

VD2 = VD2 or {}

VD2.KEY_LOCK = "slot1"
VD2.KEY_SWITCH = "slot2"

if SERVER then

util.AddNetworkString("VD2_PSwitch")
util.AddNetworkString("VD2_Lock")

net.Receive("VD2_PSwitch", function(len, ply)
    if !ply:IsValid() then return false end

    if !ply:InVehicle()  then return false end

    local veh = ply:GetVehicle()

    if veh.VD2 then
        VD2_SwitchSeat(ply, veh)
    elseif veh.VD2_Passenger then
        local vp = veh:GetParent()

        VD2_SwitchSeat(ply, vp)
    end
end)

net.Receive("VD2_Lock", function(len, ply)
    if !ply:IsValid() then return false end

    if !ply:InVehicle()  then return false end

    local veh = ply:GetVehicle()

    if veh.VD2 then
        veh:SetLocked(!veh.Locked)
    end
end)

end

function VD2_PlayerBindPress(ply, bind, pressed)
    if !pressed then return end
    if !ply:IsValid() then return end

    if !ply:InVehicle()  then return end

    local key_switch = VD2.KEY_SWITCH
    local key_lock = VD2.KEY_LOCK

    local veh = ply:GetVehicle()

    if veh.VD2 or veh:GetParent().VD2 then
        if bind == key_switch then
            net.Start("VD2_PSwitch")
            net.SendToServer()

            return true
        elseif bind == key_lock then
            net.Start("VD2_Lock")
            net.SendToServer()

            return true
        end
    end
end

hook.Add("PlayerBindPress", "VD2_PlayerBindPress", VD2_PlayerBindPress)