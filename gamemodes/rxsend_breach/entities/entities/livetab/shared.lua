ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.Spawnable = true
function ENT:SetupDataTables()

  self:NetworkVar( "Bool", 0, "BroadcastStatus" );
  self:NetworkVar( "Float", 0, "SupportChannel" )

end
function ENT:Initialize()

	self:SetBroadcastStatus( true )
  self:SetSupportChannel( 100.1 )

  		self:SetModel("models/next_breach/gas_monitor.mdl");

	self:PhysicsInit( SOLID_NONE )

	self:SetMoveType(MOVETYPE_NONE)

	self:SetSolid(SOLID_VPHYSICS)



	self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

	self:SetAngles( Angle( 0, -90, 0 ) )




	self:SetColor( ColorAlpha( color_white, 1 ) )
	self.SoundStarted = false

end