AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "lootable_corpses_config.lua" )
include( "lootable_corpses_config.lua" )
include('shared.lua')

util.AddNetworkString( "LC_OpenMenu" )  
util.AddNetworkString( "LC_TakeWep" )
util.AddNetworkString( "LC_TakeMon" )
util.AddNetworkString( "LC_UpdateStuff" )

function ENT:Initialize()
	self.Entity:SetModel(LC.BoxModel)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	
	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Weapons = self.Weapons or {}
	self.Money = self.Money or 0
	self.VictimName = self.VictimName or "" 
	
	if(LC.ShouldDespawn) then
		timer.Create( "DespawnTimer"..self:EntIndex(), LC.TimeToDespawn, 1, function() 
			if(IsValid(self)) then
				self:Remove()
				sound.Play( table.Random(LC.DespawnSounds), self:GetPos(), 65, 100, 1 ) 
			end
			timer.Remove( "DespawnTimer"..self:EntIndex() )
		end )
	end
end

local function OpenLootMenu(ply, entid, entweps, entmoney, victimname)
	net.Start( "LC_OpenMenu" )
		net.WriteInt( entid, 16 )
		net.WriteInt( entmoney, 16 )
		net.WriteTable( entweps )
		net.WriteString( victimname )
	net.Send( ply )
end

local Delay = 1
local Refresh = 0
function ENT:Use(activator, caller)
	if(!IsValid(caller) or !caller:IsPlayer()) then return end
	if(self.IsLooted) then return end
	ply = caller
	local TimeLeft = Refresh - CurTime()
	if TimeLeft < 0 then
	--------------------
		OpenLootMenu(ply, self:EntIndex(), self.Weapons, self.Money, self.VictimName)
		ply.LastUsedBoxId = self:EntIndex()
	--------------------
	Refresh = CurTime() + Delay
	end
end