AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

if ( SERVER ) then

	util.AddNetworkString( "CreatePage" )

end

ENT.PrintName = "SCP-1025"
ENT.Information = "A Encyclopedia of Common Diseases"
ENT.Category = "SCP"

ENT.Editable = false
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:Initialize()

	if ( CLIENT ) then return end

	self:SetModel( "models/mishka/models/scp1025.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:SetSolidFlags( bit.bor( FSOLID_TRIGGER, FSOLID_USE_TRIGGER_BOUNDS ) )
	timer.Simple( 1, function()

		self:SetPos( Vector( self:GetPos().x, self:GetPos().y, BREACH.GroundPos( self:GetPos() ).z + 1 ) )

	end )
	local phys = self:GetPhysicsObject()
	if ( phys && phys:IsValid() ) then

		phys:Wake()

	end

end

function ENT:Draw()

	if ( SERVER ) then return end

	self:DrawModel()

end

if ( CLIENT ) then

	net.Receive( "CreatePage", function()

		local index = net.ReadInt( 3 )

		local client = LocalPlayer()

		if ( client.SCP_1025_MainWindow ) then

			client.SCP_1025_MainWindow:Remove()

		end

		surface.PlaySound( "nextoren/others/turn_page.wav" )

		gui.EnableScreenClicker( true )
		client.SCP_1025_MainWindow = vgui.Create( "DPanel" )
		client.SCP_1025_MainWindow:SetSize( ScrW(), ScrH() )
		client.SCP_1025_MainWindow:SetText( "" )
		client.SCP_1025_MainWindow.Paint = function( self )

			if ( input.IsKeyDown( KEY_BACKSPACE ) ) then

				self:Remove()
				surface.PlaySound( "nextoren/others/turn_page.wav" )
				gui.EnableScreenClicker( false )

			end

			DrawBlurPanel( self )

			draw.SimpleText( "BACKSPACE to close", "HUDFont", ScrW() / 2, ScrH() * .9, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		end

		client.SCP_1025_MainWindow_DiseaseImage = vgui.Create( "DImage", client.SCP_1025_MainWindow )
		client.SCP_1025_MainWindow_DiseaseImage:SetSize( 450, 634 )
		client.SCP_1025_MainWindow_DiseaseImage:SetImage( "nextoren/gui/scp_1025/1025_" .. index .. ".png" )
		client.SCP_1025_MainWindow_DiseaseImage:SetPos( ScrW() / 2 - ( 450 / 2 ), ScrH() / 2 - ( 634 / 2 ) )

	end )

end

ENT.Disease = {

	[ 1 ] = { name = "Common Cold", Effect = function( pl )

		pl:SCPdiseaster( 1 )

	end },
	[ 2 ] = { name = "Chickenpox", Effect = function( pl )

		pl:SCPdiseaster( 2 )

	end },
	[ 3 ] = { name = "Cancer of the Lungs", Effect = function( pl )

		pl:SCPdiseaster( 3 )

	end },
	[ 4 ] = { name = "Appendicits", Effect = function( pl )

		pl:SCPdiseaster( 4 )

	end },
	[ 5 ] = { name = "Asthma", Effect = function( pl )

		pl:SCPdiseaster( 5 )

	end },
	[ 6 ] = { name = "Cardiac Arrest", Effect = function( pl )

		pl:SCPdiseaster( 6 )

	end }

}

ENT.NextUse = 0

function ENT:Use( activator, caller )

	if ( caller:Team() == TEAM_SCP ) then return end

	if ( self.NextUse > CurTime() ) then return end

	self.NextUse = CurTime() + 1

	local randomindx = math.random( 1, #self.Disease )

	net.Start( "CreatePage" )

		net.WriteInt( randomindx - 1, 3 )

	net.Send( caller )

	self.Disease[ randomindx ].Effect( caller )

end
