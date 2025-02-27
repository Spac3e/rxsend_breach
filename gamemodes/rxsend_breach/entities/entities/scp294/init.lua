AddCSLuaFile( "cl_init.lua" ) 
AddCSLuaFile( "shared.lua" ) 
include('shared.lua')

util.AddNetworkString("OpenSCP294Panel")
util.AddNetworkString("GiveSCP294Cup")

function ENT:Initialize()
	self:SetModel( "models/vinrax/scp294/scp294_lg.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS ) 
	self:SetMoveType( MOVETYPE_VPHYSICS ) 
	self:SetSolid( SOLID_VPHYSICS ) 
	self:SetUseType( SIMPLE_USE )
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
	phys:Wake()
	end
end

function ENT:Use( ply, caller )
if ply:GTeam() == TEAM_SCP or ply:GTeam() == TEAM_SPEC then return end
	net.Start("OpenSCP294Panel")
		net.WriteEntity(self)
	net.Send(ply)
end

function ENT:Think()
end

function ENT:OnRemove()
end

net.Receive("GiveSCP294Cup", function(len, ply)
	local content 	= net.ReadString()
	local ent		= net.ReadEntity()

	if ent:GetClass() != "scp294" then
		return
	end

	local entA 		= ent:GetAngles()
	local pos 		= ent:GetPos() + entA:Right()*9 + entA:Up()*32 + entA:Forward()*13

	if !SCP294.Drinks[content] then
		ent:EmitSound("scp294/outofrange.ogg")
		return
	end

	if SCP294.Drinks[content] then
		if SCP294.Drinks[content].nospawn then
			ply:RXSENDNotify(SCP294.Drinks[content].nospawn)
			return
		end
	end

	for k , v in pairs (ents.FindInSphere( pos, 2 )) do
		if v:GetClass() == "scp294cup" then
				ent:EmitSound("scp294/outofrange.ogg")
				return
		end
	end

	local cup = ents.Create( "SCP294cup" )
	cup:SetPos( pos )
	cup:Spawn()
	cup:SetNWString("Drink", content)
	if (SCP294.Drinks[content]) then
		if (SCP294.Drinks[content].dispense) then
			SCP294.Drinks[content].dispense(ent)
		end
	else
		ent:EmitSound("scp294/dispense1.wav")
	end
end)

SCP294.Drinks = {}

SCP294.Drinks["antimatter"] = {
	nospawn = "l:scp294_nospawn_destructive",
}

SCP294.Drinks["void"] = {
	nospawn = "l:scp294_nospawn_destructive",
}

SCP294.Drinks["anti-matter"] = {
	nospawn = "l:scp294_nospawn_destructive",
}

SCP294.Drinks["boom"] = {
	nospawn = "l:scp294_nospawn_bad_idea",
}

SCP294.Drinks["explode"] = {
	nospawn = "l:scp294_nospawn_bad_idea",
}

SCP294.Drinks["air"] = {
	color = Color(75, 0, 130),

	effect = function(ply)
		ply:RXSENDNotify("l:scp294_nothing")
	end,

	dispense = function(ent)
		ent:EmitSound("scp294/dispense1.ogg")
	end
}

SCP294.Drinks["nothing"] = {
	color = Color(75, 0, 130),

	effect = function(ply)
		ply:RXSENDNotify("l:scp294_nothing")
	end,

	dispense = function(ent)
		ent:EmitSound("scp294/dispense1.ogg")
	end
}

SCP294.Drinks["hl3"] = {
	color = Color(75, 0, 130),

	effect = function(ply)
		ply:RXSENDNotify("l:scp294_nothing")
	end,

	dispense = function(ent)
		ent:EmitSound("scp294/dispense1.ogg")
	end
}

SCP294.Drinks["cup"] = {
	color = Color(75, 0, 130),

	effect = function(ply)
		ply:RXSENDNotify("l:scp294_nothing")
	end,

	dispense = function(ent)
		ent:EmitSound("scp294/dispense1.ogg")
	end
}

SCP294.Drinks["emptiness"] = {
	color = Color(75, 0, 130),

	effect = function(ply)
		ply:RXSENDNotify("l:scp294_nothing")
	end,

	dispense = function(ent)
		ent:EmitSound("scp294/dispense1.ogg")
	end
}

SCP294.Drinks["vacuum"] = {
	color = Color(75, 0, 130),

	effect = function(ply)
		ply:RXSENDNotify("l:scp294_nothing")
	end,

	dispense = function(ent)
		ent:EmitSound("scp294/dispense1.ogg")
	end
}

SCP294.Drinks["halflife3"] = {
	color = Color(75, 0, 130),

	effect = function(ply)
		ply:RXSENDNotify("l:scp294_nothing")
	end,

	dispense = function(ent)
		ent:EmitSound("scp294/dispense1.ogg")
	end
}

SCP294.Drinks["hl3"] = {
	color = Color(75, 0, 130),

	effect = function(ply)
		ply:RXSENDNotify("l:scp294_nothing")
	end,

	dispense = function(ent)
		ent:EmitSound("scp294/dispense1.ogg")
	end
}

SCP294.Drinks["water"] = {
	color = Color(0, 201, 255),

	effect = function(ply)
		ply:RXSENDNotify("l:scp294_refreshing_drink")
	end,

	dispense = function(ent)
		ent:EmitSound("scp294/dispense1.ogg")
	end
}

SCP294.Drinks["bleach"] = {
	color = Color(255, 255, 255),

	effect = function(ply)
		ply:RXSENDNotify("l:scp294_bleach")
		ply.TempValues.Bleached = true
		timer.Simple(60, function()
			if ply.TempValues.Bleached then
				local death = math.random(0, 1)
				if death == 1 then
					local dmginfo = DamageInfo()
					dmginfo:SetDamage(10000)
					dmginfo:SetDamageType(DMG_POISON)
					ply:TakeDamageInfo(dmginfo)
				else
					local dmginfo = DamageInfo()
					dmginfo:SetDamage(99)
					dmginfo:SetDamageType(DMG_POISON)
					ply:TakeDamageInfo(dmginfo)
				end
			end
		end)
	end,

	dispense = function(ent)
		ent:EmitSound("scp294/dispense1.ogg")
	end
}