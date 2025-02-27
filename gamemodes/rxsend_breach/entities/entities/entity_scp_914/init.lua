AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

util.AddNetworkString("Changestatus_SCP914")
util.AddNetworkString("Activate_SCP914")

ENT.ActivationSound = Sound("nextoren/scp/914/refining.ogg")
ENT.PlayerKill = Sound("nextoren/scp/914/player_death.ogg")
ENT.DoorOpenSound = Sound("nextoren/doors/lhz_doors/open_start.ogg")
ENT.DoorCloseSound = Sound("nextoren/doors/lhz_doors/close_start.ogg")

ENT.DoorShouldBeOpened = true

ENT.UpgradeList = {


	["breach_keycard_1"] = {
		["Rough"] = {NULL},
		["Coarse"] = {"breach_keycard_1", NULL},
		["1:1"] = {"breach_keycard_1", "breach_keycard_security_1", "breach_keycard_sci_1"},
		["Fine"] = {"breach_keycard_2", "breach_keycard_1"},
		["Very Fine"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_3"},
	},
	["breach_keycard_2"] = {
		["Rough"] = {"breach_keycard_1"},
		["Coarse"] = {"breach_keycard_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2"},
		["Fine"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_1"},
		["Very Fine"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5"},
	},
	["breach_keycard_3"] = {
		["Rough"] = {"breach_keycard_1"},
		["Coarse"] = {"breach_keycard_2", "breach_keycard_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3"},
		["Fine"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_1"},
		["Very Fine"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_6"},
	},
	["breach_keycard_4"] = {
		["Rough"] = {"breach_keycard_1"},
		["Coarse"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3", "breach_keycard_security_4", "breach_keycard_sci_4"},
		["Fine"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_1"},
		["Very Fine"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_6"},
	},
	["breach_keycard_security_1"] = {
		["Rough"] = {NULL},
		["Coarse"] = {"breach_keycard_security_1", NULL},
		["1:1"] = {"breach_keycard_1", "breach_keycard_security_1", "breach_keycard_sci_1"},
		["Fine"] = {"breach_keycard_security_2", "breach_keycard_security_1"},
		["Very Fine"] = {"breach_keycard_security_1", "breach_keycard_security_2", "breach_keycard_security_3"},
	},
	["breach_keycard_security_2"] = {
		["Rough"] = {"breach_keycard_security_1"},
		["Coarse"] = {"breach_keycard_security_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2"},
		["Fine"] = {"breach_keycard_security_2", "breach_keycard_security_3", "breach_keycard_security_1"},
		["Very Fine"] = {"breach_keycard_security_1", "breach_keycard_security_2", "breach_keycard_security_3"},
	},
	["breach_keycard_security_3"] = {
		["Rough"] = {"breach_keycard_security_1"},
		["Coarse"] = {"breach_keycard_security_2", "breach_keycard_security_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3"},
		["Fine"] = {"breach_keycard_security_2", "breach_keycard_security_3", "breach_keycard_security_4", "breach_keycard_security_1"},
		["Very Fine"] = {"breach_keycard_security_1", "breach_keycard_security_2", "breach_keycard_guard_2", "breach_keycard_security_3", "breach_keycard_security_4"},
	},
	["breach_keycard_security_4"] = {
		["Rough"] = {"breach_keycard_security_1"},
		["Coarse"] = {"breach_keycard_security_2", "breach_keycard_security_3", "breach_keycard_security_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3", "breach_keycard_security_4", "breach_keycard_sci_4"},
		["Fine"] = {"breach_keycard_security_2", "breach_keycard_security_3", "breach_keycard_security_4", "breach_keycard_guard_4", "breach_keycard_guard_3"},
		["Very Fine"] = {"breach_keycard_security_1", "breach_keycard_security_2", "breach_keycard_security_3", "breach_keycard_security_4", "breach_keycard_6", "breach_keycard_7"},
	},
	["breach_keycard_5"] = {
		["Rough"] = {"breach_keycard_1"},
		["Coarse"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3", "breach_keycard_security_4", "breach_keycard_sci_4"},
		["Fine"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_1"},
		["Very Fine"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_6"},
	},
	["breach_keycard_6"] = {
		["Rough"] = {"breach_keycard_1"},
		["Coarse"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3", "breach_keycard_security_4", "breach_keycard_sci_4"},
		["Fine"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_1"},
		["Very Fine"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_6", "breach_keycard_crack", "breach_keycard_7"},
	},
	["breach_keycard_7"] = {
		["Rough"] = {"breach_keycard_1"},
		["Coarse"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3", "breach_keycard_security_4", "breach_keycard_sci_4"},
		["Fine"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_1"},
		["Very Fine"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_6", "breach_keycard_crack"},
	},


	["breach_keycard_guard_1"] = {
		["Rough"] = {NULL},
		["Coarse"] = {"breach_keycard_1", "breach_keycard_guard_1", "breach_keycard_security_1", NULL},
		["1:1"] = {"breach_keycard_1", "breach_keycard_guard_1", "breach_keycard_security_1", "breach_keycard_sci_1"},
		["Fine"] = {"breach_keycard_guard_2", "breach_keycard_guard_1"},
		["Very Fine"] = {"breach_keycard_guard_1", "breach_keycard_1", "breach_keycard_guard_2", "breach_keycard_guard_3"},
	},
	["breach_keycard_guard_2"] = {
		["Rough"] = {"breach_keycard_guard_1"},
		["Coarse"] = {"breach_keycard_guard_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_guard_1", "breach_keycard_guard_2"},
		["Fine"] = {"breach_keycard_guard_2", "breach_keycard_guard_3", "breach_keycard_guard_1"},
		["Very Fine"] = {"breach_keycard_guard_2", "breach_keycard_guard_3", "breach_keycard_guard_4", "breach_keycard_5"},
	},
	["breach_keycard_guard_3"] = {
		["Rough"] = {"breach_keycard_guard_1"},
		["Coarse"] = {"breach_keycard_guard_2", "breach_keycard_guard_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3", "breach_keycard_guard_1", "breach_keycard_guard_2", "breach_keycard_guard_3"},
		["Fine"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_1"},
		["Very Fine"] = {"breach_keycard_guard_2", "breach_keycard_guard_3", "breach_keycard_guard_4"},
	},
	["breach_keycard_guard_4"] = {
		["Rough"] = {"breach_keycard_guard_1"},
		["Coarse"] = {"breach_keycard_guard_2", "breach_keycard_guard_3", "breach_keycard_guard_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3", "breach_keycard_security_4", "breach_keycard_sci_4", "breach_keycard_guard_1", "breach_keycard_guard_2", "breach_keycard_guard_3", "breach_keycard_guard_4"},
		["Fine"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_1"},
		["Very Fine"] = {"breach_keycard_guard_2", "breach_keycard_guard_3", "breach_keycard_guard_4", "breach_keycard_6", "breach_keycard_crack"},
	},

	["breach_keycard_crack"] = {
		["Rough"] = {"breach_keycard_1"},
		["Coarse"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3", "breach_keycard_security_4", "breach_keycard_sci_4"},
		["Fine"] = {"breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_1"},
		["Very Fine"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_3", "breach_keycard_4", "breach_keycard_5", "breach_keycard_6", "breach_keycard_7"},
	},


	["breach_keycard_sci_1"] = {
		["Rough"] = {NULL},
		["Coarse"] = {"breach_keycard_1", NULL},
		["1:1"] = {"breach_keycard_1", "breach_keycard_security_1", "breach_keycard_sci_1"},
		["Fine"] = {"breach_keycard_sci_2", "breach_keycard_sci_1"},
		["Very Fine"] = {"breach_keycard_sci_1", "breach_keycard_sci_2", "breach_keycard_sci_3"},
	},
	["breach_keycard_sci_2"] = {
		["Rough"] = {"breach_keycard_1", "breach_keycard_sci_1"},
		["Coarse"] = {"breach_keycard_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2"},
		["Fine"] = {"breach_keycard_sci_2", "breach_keycard_sci_3", "breach_keycard_sci_1"},
		["Very Fine"] = {"breach_keycard_sci_1", "breach_keycard_sci_2", "breach_keycard_sci_3", "breach_keycard_sci_4"},
	},
	["breach_keycard_sci_3"] = {
		["Rough"] = {"breach_keycard_sci_1"},
		["Coarse"] = {"breach_keycard_sci_2", "breach_keycard_sci_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3"},
		["Fine"] = {"breach_keycard_sci_2", "breach_keycard_sci_3", "breach_keycard_sci_4", "breach_keycard_sci_1"},
		["Very Fine"] = {"breach_keycard_sci_1", "breach_keycard_sci_2", "breach_keycard_sci_3", "breach_keycard_sci_4", "breach_keycard_4"},
	},
	["breach_keycard_sci_4"] = {
		["Rough"] = {"breach_keycard_sci_1"},
		["Coarse"] = {"breach_keycard_sci_2", "breach_keycard_sci_3", "breach_keycard_sci_1"},
		["1:1"] = {"breach_keycard_1", "breach_keycard_2", "breach_keycard_security_1", "breach_keycard_sci_1", "breach_keycard_security_2", "breach_keycard_sci_2", "breach_keycard_security_3", "breach_keycard_sci_3", "breach_keycard_security_4", "breach_keycard_sci_4"},
		["Fine"] = {"breach_keycard_sci_2", "breach_keycard_sci_3", "breach_keycard_sci_4", "breach_keycard_5"},
		["Very Fine"] = {"breach_keycard_sci_2", "breach_keycard_sci_3", "breach_keycard_sci_4", "breach_keycard_5", "breach_keycard_crack"},
	},


	["item_medkit_1"] = {
		["Rough"] = {NULL},
		["Coarse"] = {NULL, "item_medkit_1"},
		["1:1"] = {"item_medkit_1", "item_medkit_3"},
		["Fine"] = {"item_medkit_1", "item_medkit_2"},
		["Very Fine"] = {"item_medkit_2", "item_medkit_3", "item_medkit_4","item_pills"},
	},

	["item_medkit_2"] = {
		["Rough"] = {NULL},
		["Coarse"] = {NULL, "item_medkit_1"},
		["1:1"] = {"item_medkit_2", "item_medkit_4","item_pills"},
		["Fine"] = {"item_medkit_2", "item_medkit_3","item_pills"},
		["Very Fine"] = {"item_medkit_2","item_medkit_3", "item_medkit_4","item_pills"},
	},

	["item_medkit_3"] = {
		["Rough"] = {NULL},
		["Coarse"] = {NULL, "item_medkit_1"},
		["1:1"] = {"item_medkit_3", "item_medkit_1","item_pills"},
		["Fine"] = {"item_medkit_3", "item_medkit_4","item_pills"},
		["Very Fine"] = {"item_medkit_2","item_medkit_3", "item_medkit_4","item_pills"},
	},

	["item_medkit_4"] = {
		["Rough"] = {NULL},
		["Coarse"] = {NULL, "item_medkit_1","item_pills"},
		["1:1"] = {"item_medkit_4", "item_medkit_2","item_pills"},
		["Fine"] = {"item_medkit_3", "item_medkit_4","item_pills"},
		["Very Fine"] = {"item_medkit_4","item_pills","item_adrenaline","item_syringe"},
	},


	["copper_coin"] = {
		["Rough"] = {NULL},
		["Coarse"] = {NULL, "copper_coin"},
		["1:1"] = {"copper_coin"},
		["Fine"] = {"copper_coin", "silver_coin"},
		["Very Fine"] = {"gold_coin", "copper_coin", "silver_coin"},
	},

	["silver_coin"] = {
		["Rough"] = {"copper_coin"},
		["Coarse"] = {"silver_coin", "copper_coin"},
		["1:1"] = {"copper_coin"},
		["Fine"] = {"copper_coin", "silver_coin", "gold_coin"},
		["Very Fine"] = {"gold_coin", "copper_coin", "silver_coin"},
	},

	["gold_coin"] = {
		["Rough"] = {"copper_coin"},
		["Coarse"] = {"silver_coin", "copper_coin"},
		["1:1"] = {"gold_coin"},
		["Fine"] = {"gold_coin"},
		["Very Fine"] = {"copper_coin"},
	},

	["weapon_pass_guard"] = {
		["Rough"] = {"NULL"},
		["Coarse"] = {"NULL"},
		["1:1"] = {"weapon_pass_guard"},
		["Fine"] = {"weapon_pass_sci","weapon_pass_medic","weapon_pass_guard"},
		["Very Fine"] = {"weapon_pass_sci","weapon_pass_medic","weapon_pass_guard","gasmask"},
	},

	["item_adrenaline"] = {
		["Rough"] = {NULL},
		["Coarse"] = {NULL},
		["1:1"] = {"item_adrenaline"},
		["Fine"] = {"item_adrenaline", "item_syringe"},
		["Very Fine"] = {"item_adrenaline", "item_syringe"},
	},


}

ENT.ModeTypes = {
	"Rough",
	"Coarse",
	"1:1",
	"Fine",
	"Very Fine"
}

function ENT:Initialize()

  	self:SetModel("models/next_breach/gas_monitor.mdl");

	self:PhysicsInit( SOLID_NONE )

	self:SetMoveType( MOVETYPE_NONE )

	self:SetSolid(SOLID_VPHYSICS)

	self:SetUseType(SIMPLE_USE)



	--self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

	self:SetPos(Vector(9498.7158203125, -4766.1997070313, 59.6369972229))
	self:SetAngles( Angle(0, 89.961547851563, 0) )

	--self:UseTriggerBounds(true, 10)

end

net.Receive("Changestatus_SCP914", function( len, ply )
	local ent = net.ReadEntity()
	if !IsValid(ent) or ent:GetClass() != "entity_scp_914" then return end
	if ply:GTeam() == TEAM_SPEC then return end
	if ply:GTeam() == TEAM_SCP then return end
	if ent:GetWorking() then return end
	if ent.NextUse == nil then ent.NextUse = 0 end
	if ent.NextUse > CurTime() then return end
	ent.NextUse = CurTime() + 1
	if ent:GetStatus() >= 5 then 
		ent:SetStatus(1)
	else
		ent:SetStatus(ent:GetStatus() + 1)
	end

	ply:RXSENDNotify("l:scp914_change_mode "..ent.ModeTypes[ent:GetStatus()])
end)

net.Receive("Activate_SCP914", function( len, ply )

	local ent = net.ReadEntity()
	if !IsValid(ent) or ent:GetClass() != "entity_scp_914" then return end
	if ply:GTeam() == TEAM_SPEC then return end
	if ply:GTeam() == TEAM_SCP then return end
	if ent:GetWorking() then return end

	ent:SetWorking(true)
	ent:EmitSound(ent.ActivationSound)
	timer.Simple(2.5, function()

		for _, door in pairs(ents.FindInSphere(Vector(9546.245117, -4566.125488, 66.792221), 32)) do

			if IsValid(door) and door:GetClass() == "func_door" then
				door:Fire("Unlock")
				door:Fire("Close")
				door:Fire("Lock")
				door:EmitSound(ent.DoorCloseSound)
			end

		end

		for _, door in pairs(ents.FindInSphere(Vector(9537.967773, -5018.667480, 66.792221), 32)) do

			if IsValid(door) and door:GetClass() == "func_door" then
				door:Fire("Unlock")
				door:Fire("Close")
				door:Fire("Lock")
				door:EmitSound(ent.DoorCloseSound)
			end

		end

	end)

	timer.Simple(7, function()
		ent:GetItemsAndUpgrade(ent.ModeTypes[ent:GetStatus()], ply)
	end)

	timer.Simple(14, function()

		for _, door in pairs(ents.FindInSphere(Vector(9546.245117, -4566.125488, 66.792221), 40)) do

			if IsValid(door) and door:GetClass() == "func_door" then
				door:Fire("Unlock")
				door:Fire("Open")
				door:Fire("Lock")
				door:EmitSound(ent.DoorOpenSound)
			end

		end

		for _, door in pairs(ents.FindInSphere(Vector(9537.967773, -5018.667480, 66.792221), 40)) do

			if IsValid(door) and door:GetClass() == "func_door" then
				door:Fire("Unlock")
				door:Fire("Open")
				door:Fire("Lock")
				door:EmitSound(ent.DoorOpenSound)
			end

		end

		timer.Simple(1, function()
			ent:SetWorking(false)
		end)

	end)
end)

function ENT:GetItemsAndUpgrade(mode, activator)

	local Ents = ents.FindInBox( Vector(9552.1748046875, -4607.720703125, 0), Vector(9615.6962890625, -4480.3388671875, 113.26854705811) )
	local BastardsToKill = ents.FindInBox( Vector(9536.7724609375, -4911.8510742188, 114.65923309326), Vector(9629.798828125, -5070.6748046875, -22.197147369385) )
	local UpgradeList = self.UpgradeList

	local SoundPlayed = false
	for _, ply in pairs(BastardsToKill) do
		if IsValid(ply) and ply:IsPlayer() and ply:GTeam() != TEAM_SPEC then
			if !SoundPlayed then
				SoundPlayed = true
				sound.Play(self.PlayerKill, Vector(9587.307617, -4988.501953, 66.792221))
			end
			ply:AddToStatistics("l:scp914_death", -50 )
			ply:LevelBar()
			ply:SetupNormal()
			ply:SetSpectator()
		end
	end

	local SoundPlayed = false
	for _, ply in pairs(Ents) do
		if IsValid(ply) and ply:IsPlayer() and ply:GTeam() != TEAM_SPEC then
			if math.random(1,100) <= 10 then
				print("1")
				SoundPlayed = true
				sound.Play(self.PlayerKill, Vector(9587.307617, -4988.501953, 66.792221))
				ply:AddToStatistics("l:scp914_death", -50 )
			    ply:LevelBar()
			    ply:SetupNormal()
			    ply:SetSpectator()

			elseif math.random(1,100) <= 30 then
				print("2")
				ply:SetStaminaScale(ply:GetStaminaScale()+1)
			    ply:SetMaxHealth(255)
			    ply:SetHealth(255)

			elseif math.random(1,100) <= 50 then
				print("3")
				ply:SetMaxHealth(100)
			    ply:SetHealth(100)
            elseif math.random(1,100) <= 90 then
				print("4")
				ply:SetStaminaScale(ply:GetStaminaScale()+10)
			    ply:SetMaxHealth(114514)
			    ply:SetHealth(114514)
                ply:Dado( 4 )
 			else
				print("5")
			    ply:SetMaxHealth(1)
			    ply:SetHealth(1)
			end
		end
	end

	local itemtospawn = {}
	local spawnpoint = Vector(9582.87890625, -4988.6982421875, 2.7922210693359)

	for _, weapon in pairs(Ents) do
		if !weapon:GetPos():WithinAABox(Vector(9552.1748046875, -4607.720703125, 0), Vector(9615.6962890625, -4480.3388671875, 113.26854705811)) then --дополнительная проверка, чтобы байпаснуть криворукость разрабов гмода
			continue
		end

		if IsValid(weapon) and weapon:GetClass() == "prop_ragdoll" then
			table.insert(itemtospawn, {"item_hamburger", Vector(weapon:GetPos().x, weapon:GetPos().y - 450, weapon:GetPos().z + 30)})
		else
			if !IsValid(weapon) or !weapon:IsWeapon() then continue end
			if self.UpgradeList[weapon:GetClass()] == nil then continue end
			if self.UpgradeList[weapon:GetClass()][mode] == nil then continue end
			table.insert(itemtospawn, {table.Random(self.UpgradeList[weapon:GetClass()][mode]), Vector(weapon:GetPos().x, weapon:GetPos().y - 450, weapon:GetPos().z + 30)})
		end

	end

	for _, weapon in pairs(Ents) do
		if !weapon:GetPos():WithinAABox(Vector(9552.1748046875, -4607.720703125, 0), Vector(9615.6962890625, -4480.3388671875, 113.26854705811)) then --дополнительная проверка, чтобы байпаснуть криворукость разрабов гмода
			continue
		end

		if IsValid(weapon) and ( weapon:IsWeapon() or weapon:GetClass() == "prop_ragdoll" ) then weapon:Remove() end
	end

	if !table.IsEmpty(itemtospawn) then
		for k, v in pairs(itemtospawn) do
			local entclass = v[1]
			local entpos = v[2]
			timer.Simple(k / 10, function()
				if entclass == "breach_keycard_7" and IsValid(activator) then
					activator:CompleteAchievement("scp914")
				elseif entclass == "item_hamburger" and IsValid(activator) then
					activator:CompleteAchievement("scp914burger")
				end
		
				local item = ents.Create(entclass)
				item:SetPos(entpos)
				item:Spawn()
				--uracos():SetPos(entpos)
			end)
		end
	end

end

function ENT:Think()
	--[[
	if !self:GetWorking() then
		for _, door in pairs(ents.FindInSphere(Vector(9546.245117, -4566.125488, 66.792221), 40)) do

			if IsValid(door) and door:GetClass() == "func_door" then
				door:Fire("Open")
			end

		end

		for _, door in pairs(ents.FindInSphere(Vector(9537.967773, -5018.667480, 66.792221), 40)) do

			if IsValid(door) and door:GetClass() == "func_door" then
				door:Fire("Open")
			end

		end
	end]]
	self:NextThink(CurTime() + 0.5)
end

function ENT:Use(ply, caller)
	if ply:GTeam() == TEAM_SPEC or ply:GTeam() == TEAM_SCP then return end
	if !ply:Alive() or ply:Health() <= 0 then return end
	if ply:GetEyeTrace().Entity != self then return end
	ply:SendLua("Open914Menu()")
end