local RunConsoleCommand = RunConsoleCommand;
local FindMetaTable = FindMetaTable;
local CurTime = CurTime;
local pairs = pairs;
local string = string;
local table = table;
local timer = timer;
local hook = hook;
local math = math;
local pcall = pcall;
local unpack = unpack;
local tonumber = tonumber;
local tostring = tostring;
local ents = ents;
local ErrorNoHalt = ErrorNoHalt;
local DeriveGamemode = DeriveGamemode;
local util = util
local net = net
local player = player

local mply = FindMetaTable("Player")

DEFINE_BASECLASS( "player_default" )

local templevel = 0 -- set 0 to disable

local bonuslevel = 0

local PLAYER = {}

function PLAYER:SetupDataTables()

	if self._datatableapplied then return end

	self._datatableapplied = true

	local check = SysTime()
	
	self.Player:NetworkVar( "String", 0, "RoleName" )
	self.Player:NetworkVar( "String", 1, "Namesurvivor")
	self.Player:NetworkVar( "Int", 0, "NEXP" )
	self.Player:NetworkVar( "Int", 1, "NLevel" )
	self.Player:NetworkVar( "Int", 2, "NGTeam" )
	self.Player:NetworkVar( "Int", 3, "MaxSlots" )
	self.Player:NetworkVar( "Int", 4, "SpecialMax" )
    self.Player:NetworkVar( "Int", 5, "PenaltyAmount" )
	self.Player:NetworkVar( "Float", 0, "SpecialCD" )
	self.Player:NetworkVar( "Float", 1, "StaminaScale" )
	self.Player:NetworkVar( "Bool", 0, "Energized" )
	self.Player:NetworkVar( "Bool", 1, "Boosted" )
	self.Player:NetworkVar( "Bool", 2, "Adrenaline" )
	self.Player:NetworkVar( "Bool", 3, "Female" )
	self.Player:NetworkVar( "Bool", 4, "InDimension")
	self.Player:NetworkVar( "Bool", 5, "Crouching")

	print(SysTime() - check, " Spent on networkvaring..")
	
	if SERVER then
		print("Setting up datatables for " .. self.Player:Nick())
		self.Player:SetRoleName("Spectator")
		self.Player:SetNamesurvivor( "" )

		print("setting up data")

		BREACH.DataBaseSystem:LoadPlayer(self.Player, function()

			print("[RXSEND MYSQLOO] Data for " .. self.Player:Nick() .." has been set successfuly!")

		end)

		self.Player:SetNGTeam(1)
		self.Player:SetSpecialCD( 0 )
		self.Player:SetInDimension( false )
		self.Player:SetAdrenaline( false )
		self.Player:SetEnergized( false )
		self.Player:SetBoosted( false )
		self.Player:SetMaxSlots( 8 )
		self.Player:SetFemale( false )
		self.Player:SetCrouching( false )
		self.Player:SetSpecialMax( 0 )
		self.Player:SetStaminaScale(1.0)
	end
end

function CheckPlayerData( player, name )
	local pd = player:GetPData( name, 0 )
	if pd == "nil" then
		print( "Damaged playerdata found..." )
		player:RemovePData( name )
		player:SetPData( name, 1 )
	end
end

player_manager.RegisterClass( "class_breach", PLAYER, "player_default" )