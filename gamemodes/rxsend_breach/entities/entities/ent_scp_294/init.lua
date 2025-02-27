AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.Model = "models/vinrax/scp294/scp294_lg.mdl"

util.AddNetworkString("send_drink")
util.AddNetworkString("create_294_menu")

ENT.Drinks = {}

--[[
	sip sounds:
	1 -- ahh
	2 -- beurk
	3 -- burn
	4 -- cough
	5 -- slurp
	6 -- spit
]]

ENT.Drinks["sex"] = {

	effect = function(ply, ent)

		ply:RXSENDNotify("l:scp294_sex")

	end,

	sip = 5,

	vendingsound = 3,

}

ENT.Drinks["fanta"] = {

	effect = function(ply, ent)

		ply:RXSENDNotify("l:scp294_fanta")

	end,

	sip = 1,

	vendingsound = 1,

}

ENT.Drinks["pepsi"] = ENT.Drinks["fanta"]
ENT.Drinks["cola"] = ENT.Drinks["fanta"]
ENT.Drinks["cocacola"] = ENT.Drinks["fanta"]
ENT.Drinks["sprite"] = ENT.Drinks["fanta"]

ENT.Drinks["water"] = {

	effect = function(ply, ent)

		ply:RXSENDNotify("l:scp294_water")

	end,

	sip = 5,

	vendingsound = 1,

}


ENT.Drinks["pee"] = {

	effect = function(ply, ent)

		ply:TakeDamage(ply:GetMaxHealth()*.1, ply, ply:GetActiveWeapon())

	end,

	color = Color(255,255,0),

	sip = 6,

	vendingsound = 1,

}

ENT.Drinks["milk"] = {

	effect = function(ply, ent)

	end,

	color = Color(255,255,255),

	sip = 1,

	vendingsound = 1,

}


ENT.Drinks["cyox"] = {

	effect = function(ply, ent)

	end,

	color = Color(0,255,0),

	sip = 2,

	vendingsound = 2,

}

ENT.Drinks["shaky"] = ENT.Drinks["cyox"]

ENT.Drinks["uracos"] = ENT.Drinks["cyox"]

ENT.Drinks["uracosvereches"] = ENT.Drinks["cyox"]

ENT.Drinks["rxsend"] = {

	effect = function(ply, ent)

	end,

	color = Color(0,255,0),

	sip = 1,

	vendingsound = 2,

}

ENT.Drinks["piss"] = ENT.Drinks["pee"]
ENT.Drinks["turd"] = ENT.Drinks["pee"]

ENT.Drinks["turd"].color = Color(150,75,0)
ENT.Drinks["shit"] = ENT.Drinks["turd"]
ENT.Drinks["poop"] = ENT.Drinks["turd"]
ENT.Drinks["poo"] = ENT.Drinks["turd"]

ENT.Drinks["sperm"] = ENT.Drinks["pee"]
ENT.Drinks["sperm"].color = Color(255,255,255)
ENT.Drinks["cum"] = ENT.Drinks["sperm"]
ENT.Drinks["semen"] = ENT.Drinks["sperm"]

ENT.Drinks["tnt"] = {

	effect = function(ply, ent)

	end,

	sip = 5,

	vendingsound = 1,

}

ENT.Drinks["suicide"] = {

	effect = function(ply, ent)

		ply:Kill()

	end,

	sip = 5,

	vendingsound = 1,

}

ENT.Drinks["clone"] = {

	effect = function(ply, ent)

		--if ply.TempValues.UsedClone then return end

		local myclone = CreateLootBox(ply)

		myclone.vtable.Weapons = {}

		myclone.breachsearchable = false

		for i = 1, myclone:GetPhysicsObjectCount() do
			local ph = myclone:GetPhysicsObjectNum( i )
			if IsValid(ph) then
				ph:EnableGravity(false)
				ph:SetVelocity(Vector(0,0,15))
			end
		end

		timer.Simple(10, function()
			myclone:Remove()
		end)

		ply.TempValues.UsedClone = true

	end,

	color = Color(100,95,95),

	sip = 5,

	vendingsound = 1

}

ENT.Drinks["bunny"] = {

	coin = "gold",

	effect = function(ply, ent)

		if !ply.TempValues.bunnydrank then

			ply:SetJumpPower(ply:GetJumpPower()+175)

		end

		ply.TempValues.bunnydrank = true

	end,

	color = Color(215,215,215),

	sip = 5,

	vendingsound = 1

}

ENT.Drinks["zombie"] = {

	effect = function(ply, ent)

		local ran = math.random(10,100)

		if ran <= 13 and ply.TempValues.zombiedrink != true then
			ply:SetupZombie()
		else
			ply:setBottomMessage("l:scp294_feeling_really_bad")
			ply:TakeDamage(ply:GetMaxHealth()*.3, ply, ply:GetActiveWeapon())
		end

		ply.TempValues.zombiedrink = true

	end,

	color = Color(215,0,0),

	sip = 5,

	vendingsound = 1,

}

ENT.Drinks["scp500"] = {

	effect = function(ply, ent)

		if ply:Health() < ply:GetMaxHealth() then

			ply:AnimatedHeal(ply:GetMaxHealth() - ply:Health())

		end

		ply:setBottomMessage("l:scp294_scp500")

	end,

	color = Color(255,0,0),

	sip = 1,

	vendingsound = 1,

}

ENT.Drinks["500"] = ENT.Drinks["scp500"]

ENT.Drinks["scp009"] = {

	effect = function(ply, ent)

		timer.Simple(15, function()
			if ply:GTeam() != TEAM_SPEC then
				ply:Make009Statue()
			end
		end)

	end,

	sip = 4,

	vendingsound = 2,

}

ENT.Drinks["009"] = ENT.Drinks["scp009"]

ENT.DispenseCD = {
	[1] = 2.5,
	[2] = 6.2,
	[3] = 6
}

function ENT:Initialize()

	self:SetModel(self.Model)

	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)

	self.idlesound = CreateSound( self, "nextoren/others/vending_machine_sounds/machine_idle.wav" )
  	self.idlesound:Play()

	local phy = self:GetPhysicsObject()

	if IsValid(phy) then
		phy:EnableMotion(false)
	end

	self:SetUseType(SIMPLE_USE)

end

function ENT:Use(activator)

	if activator:GTeam() != TEAM_SPEC and activator:GTeam() != TEAM_SCP and activator:GetEyeTrace().Entity == self then

		net.Start("create_294_menu")
		net.Send(activator)

	end
end

function ENT:OnRemove()
	self.idlesound:Stop()
end

function ENT:MakeDrink(drink)

	if self.MakingDrink then return end

	for i, v in pairs(ents.FindByClass("item_drink_294")) do

		if !IsValid(v:GetOwner()) then v:Remove() end

	end

	self.MakingDrink = true

	timer.Create("create_drink_294", self.DispenseCD[self.Drinks[drink].vendingsound || 1], 1, function()

		self.MakingDrink = false

		local entA = self:GetAngles()
		local pos = self:GetPos() + entA:Right()*9 + entA:Up()*32 + entA:Forward()*13

		local drink_itself = ents.Create("item_drink_294")

		drink_itself.SCP294 = self
		drink_itself.effect = self.Drinks[drink].effect

		drink_itself.drink = drink

		local col = self.Drinks[drink].color

		if !self.Drinks[drink].color then
			col = Color(255,255,255)
		end

		if self.Drinks[drink].sip then
			drink_itself.sip = self.Drinks[drink].sip
		else
			drink_itself.sip = 5
		end

		drink_itself:SetPos(pos)

		drink_itself:Spawn()

		drink_itself:SetNWInt("r", col.r)
		drink_itself:SetNWInt("g", col.g)
		drink_itself:SetNWInt("b", col.b)

	end)

	if self.Drinks[drink].vendingsound then
		self:EmitSound("scp294/dispense"..self.Drinks[drink].vendingsound..".ogg")
	else
		self:EmitSound("scp294/dispense1.ogg")
	end


end

net.Receive("send_drink", function(len, ply)

	local drinkname = net.ReadString()
	local scp294 = net.ReadEntity()

	if !IsValid(scp294) or scp294:GetClass() != "ent_scp_294" then return end
	if ply:GetEyeTrace().Entity != scp294 then return end

	local self = scp294

	if !self.Drinks[drinkname] then
		ply:RXSENDNotify("l:scp294_out_of_order"..drinkname.."\"")
		return
	end

	scp294:MakeDrink(drinkname)

end)