
hab = hab or {
	version = "0.7a",
--credits	
	author = "The_HAVOK",
	contact = "STEAM_0:1:40989742",
	contrib = {},
--tables
	Module = Module or {},
	modules = modules or {},

	CVars = CVars or {},
	cval = cval or {},

	ChatCom = ChatCom or {},

	hooks = hooks or {},
	hooksCalcView = hooksCalcView or {},

	Menu = Menu or {},

	menus = menus or {},

	controls = controls or {},
	key = key or {},

}

MsgN( )
MsgN( "---------------------------------------" )
MsgN( "-----------Start Loading HAB-----------" )
MsgN( "---------------------------------------" )
MsgN( )

-- load utils first
AddCSLuaFile( "hab/utils.lua" )
include( "hab/utils.lua" )
MsgN( "	utils.lua Loaded" )

AddCSLuaFile( "hab/enumerators.lua" )
include( "hab/enumerators.lua" )
MsgN( "	enumerators.lua Loaded" )

AddCSLuaFile( "hab/redefine.lua" )
include( "hab/redefine.lua" )
MsgN( "	redefine.lua Loaded" )

-- load modules last
AddCSLuaFile( "hab/modules.lua" )
include( "hab/modules.lua" )

MsgN( )
MsgN( "---------------------------------------" )
MsgN( "------------End Loading HAB------------" )
MsgN( "---------------------------------------" )
MsgN( )
