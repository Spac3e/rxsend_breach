
if ( CLIENT ) then

	SWEP.InvIcon = Material( "nextoren/gui/icons/weapons/armotur.png" )

end

SWEP.ViewModelFOV	= 80
SWEP.ViewModelFlip	= false

SWEP.PrintName		= "传奇之刃"
SWEP.WorldModel = "models/weapons/tfa_l4d2/w_kf2_katana.mdl"
SWEP.ViewModel = "models/weapons/tfa_l4d2/c_kf2_katana.mdl"
SWEP.HoldType		= "knife"
SWEP.Spawnable		= false
SWEP.AdminSpawnable	= false

SWEP.droppable				= false
SWEP.UnDroppable 			= true

SWEP.UseHands				= true
SWEP.Pos = Vector( -3, 2, 1 )
SWEP.Ang = Angle( 60, 240, 20 )

SWEP.HitSound = Sound( "weapons/l4d2_kf2_katana/melee_katana_03.wav" )
SWEP.LightattackAnimations = { 7, 8 }
SWEP.LightattackAnimations_miss = { 3, 4 }

function SWEP:Initialize()

  self:SetHoldType( self.HoldType )

end

function SWEP:Deploy()

	self.HolsterDelay = nil
	self.IdleDelay = CurTime() + 1
	self:EmitSound( "weapons/l4d2_kf2_katana/knife_deploy.wav", 75, math.random( 100, 120 ), 1, CHAN_WEAPON )
	self:PlaySequence( "draw" )

end

function SWEP:Think()

	if ( ( self.IdleDelay || 0 ) < CurTime() && !self.IdlePlaying ) then

		self.IdlePlaying = true
		self:PlaySequence( "idle1" )

	end

end

function SWEP:Holster() return true end

local punch_angle = Angle( 2, 2, 2 )

local trigger_box = Vector( 20, 4, 32 )

function SWEP:PrimaryAttack()

  self:SetNextPrimaryFire( CurTime() + .1000 )

	self.IdleDelay = CurTime() + 1

	self.Owner:SetAnimation( PLAYER_ATTACK1 )

  local trace = {

    start = self.Owner:GetShootPos(),
    endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * 100,
    filter = { self.Owner },
    mins = -trigger_box,
    maxs = trigger_box

  }

  self.Owner:LagCompensation( true )

  local tr = util.TraceHull( trace )

  self.Owner:LagCompensation( false )

  local ent = tr.Entity

  if ( ent && ent:IsValid() && ent:IsPlayer() ) then

    self:PlaySequence( self.LightattackAnimations[ math.random( 1, #self.LightattackAnimations ) ] )

		local fx = EffectData()

    fx:SetOrigin( tr.HitPos )
    fx:SetNormal( tr.HitNormal )
    fx:SetColor( BLOOD_COLOR_RED )
    util.Effect( "BloodImpact", fx )

		if ( SERVER ) then

			local recipients = RecipientFilter()
			recipients:AddAllPlayers()

			local hit_snd = CreateSound( self, self.HitSound, recipients )
			hit_snd:SetDSP( 17 )
			hit_snd:Play()

			local dmginfo = DamageInfo()
			dmginfo:SetDamageType( DMG_SLASH )

			if ( ent:GTeam() != TEAM_SCP ) then

				dmginfo:SetDamage( ent:GetMaxHealth() * 0.03 )

			else

				dmginfo:SetDamage( 100 )

			end

			dmginfo:SetDamageForce( self.Owner:GetAimVector() * 3 )
			dmginfo:SetAttacker( self.Owner )
			dmginfo:SetInflictor( self )

			ent:TakeDamageInfo( dmginfo )


		end

  else

		self:EmitSound( "weapons/l4d2_kf2_katana/katana_swing_miss1.wav", 75, math.random( 100, 120 ), 1, CHAN_WEAPON )
    self:PlaySequence( self.LightattackAnimations_miss[ math.random( 1, #self.LightattackAnimations_miss ) ] )

  end

end

function SWEP:SecondaryAttack()

	self:SetNextSecondaryFire( CurTime() + .75 )

  self:PrimaryAttack()

end
