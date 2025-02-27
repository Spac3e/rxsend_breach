
local folderList = file.Find( "hab/modules/*.lua", "LUA" )
MsgN( )
MsgN( "  ===================================  " )
MsgN( "  =====Start Loading HAB Modules=====  " )
MsgN( "  ===================================  " )
MsgN( )

MsgN( )
MsgN( "	Module base.lua Loaded..." )

AddCSLuaFile( "hab/modules/base.lua" )
include( "hab/modules/base.lua" )
hab.modules[ 0 ] = "base.lua"

for i, f in pairs(folderList) do

	if f != "base.lua" then -- base is loaded separatley

		MsgN( )
		MsgN( "	Module " .. f .. " Loaded..." )

		AddCSLuaFile( "hab/modules/" .. f )
		include( "hab/modules/" .. f )

		hab.modules[i] = f

	end

end

MsgN( )
MsgN( "  ===================================  " )
MsgN( "  ======End Loading HAB Modules======  " )
MsgN( "  ===================================  " )
MsgN( )
