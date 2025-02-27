
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize( )

	self:SetModel( "models/weapons/w_smg1.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:DrawShadow( false )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self:GetPhysicsObject( )
	if phys:IsValid( ) then

		phys:Wake( )

	end

	self.Firing = false
	self.NextShot = 0

end

/*---------------------------------------------------------
	Here are some accessor functions for the different
	things you can change!
---------------------------------------------------------*/

// Damage

function ENT:SetDamage( f )

	self.Damage = f

end

function ENT:GetDamage( )

	return self.Damage

end

// Delay

function ENT:SetDelay( f )

	self.Delay = f

end

function ENT:GetDelay( )

	return self.Delay

end

// Number of Bullets

function ENT:SetNumBullets( f )

	self.NumBullets = f

end

function ENT:GetNumBullets( f )

	return self.NumBullets

end

// Spread

function ENT:SetSpread( f )

	self.Spread = Vector( f, f, 0 )

end

function ENT:GetSpread( )

	return self.Spread

end

// Toggle

function ENT:SetToggle( b )

	self.Toggle = b

end

function ENT:GetToggle( )

	return self.Toggle

end

// Sound

function ENT:SetSound( str )

	self.Sound = str

end

function ENT:GetSound( )

	return self.Sound

end

// AmmoType

function ENT:SetAmmoType( t )

	self.AmmoType = t

end

function ENT:GetAmmoType( )

	return self.AmmoType

end

// Firing on or off

function ENT:SetOn( b )

	self.Firing=b

end

function ENT:GetOn( )

	return self.Firing

end


// Tracer
function ENT:SetTracer( trcer )

	self.Tracer = trcer

end

function ENT:GetTracer( )

	return self.Tracer

end


/*---------------------------------------------------------
	Name: FireShot

	Fire a bullet.
---------------------------------------------------------*/

function ENT:FireShot( )

	if ( self.NextShot > CurTime( ) ) then return end

	self.NextShot = CurTime( ) + self.Delay

	// Make a sound if you want to.
	if ( self:GetSound( ) ) then

		self:EmitSound( self:GetSound( ) )

	end

	// Get the muzzle attachment (this is pretty much always 1)
	local Attachment = self:GetAttachment( 1 )

	// Get the shot angles and stuff.
	local shootAngles = self:GetAngles( )
	local shootDir = shootAngles:Forward( )
	local shootOrigin = Attachment.Pos + shootDir * 2

	// Shoot a bullet
	self:FirePhysicalBullets( {

		Src = shootOrigin,
		Dir = shootDir,
		Spread = self:GetSpread( ),

		Damage = ( self:GetDamage( ) or false ),

		Filter = self,

		AmmoType = self:GetAmmoType( ),

		WeaponFiring = self,
		Attacker = self:GetPlayer( ),

		Num = self:GetNumBullets( ),

	} )

	// Make a muzzle flash
	local effectdata = EffectData( )

		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngles( shootAngles )
		effectdata:SetScale( 1 )

	util.Effect( "MuzzleEffect", effectdata )

end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	self:TakePhysicsDamage( dmginfo )

end

/*---------------------------------------------------------
   Numpad control functions
   These are layed out like this so it'll all get saved properly
---------------------------------------------------------*/

local function On( pl, ent )

	if ( !ent || ent == NULL ) then return end

	if ( ent:GetToggle( ) ) then

		ent:SetOn( !ent:GetOn( ) )

	else

		ent:SetOn( true )

	end

end

local function Off( pl, ent )

	if ( !ent || ent == NULL ) then return end

	if ( ent:GetToggle( ) ) then return end

	ent:SetOn(false)

end

function ENT:Think( )

	if( self.Firing ) then

		self:FireShot( )

	end

	// Note: If you're overriding the next think time you need to return true
	self:NextThink( CurTime( ) )
	return true

end

numpad.Register( "physbulletturret_On", On )
numpad.Register( "physbulletturret_Off", Off )
