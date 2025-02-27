ENT.Type = "anim"
ENT.PrintName = "LZ Status Monitor"
ENT.Spawnable = true

function ENT:SetupDataTables()

  self:NetworkVar( "Bool", 0, "EmergencyMode" )
  self:NetworkVar( "Float", 0, "DecontTimer" )

  self:SetEmergencyMode( false )
  self:SetDecontTimer(100)

end

function ENT:Initialize()

  	self:SetModel("models/next_breach/gas_monitor.mdl");

	self:PhysicsInit( SOLID_NONE )

	self:SetMoveType(MOVETYPE_NONE)

	self:SetSolid(SOLID_VPHYSICS)



	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )

	self:SetAngles( Angle( 0, -90, 0 ) )




	self:SetColor( ColorAlpha( color_white, 1 ) )

end