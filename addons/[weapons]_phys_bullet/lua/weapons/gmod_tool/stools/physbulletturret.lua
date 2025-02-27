TOOL.Category		= "Construction"
TOOL.Name			= "#tool.physbulletturret.name"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "key" ]			= "10"
TOOL.ClientConVar[ "delay" ]		= "0.05"
TOOL.ClientConVar[ "toggle" ]		= "0"
TOOL.ClientConVar[ "sound" ]		= "Pistol"
TOOL.ClientConVar[ "damage" ]		= "-1"
TOOL.ClientConVar[ "spread" ]		= "0"
TOOL.ClientConVar[ "numbullets" ]	= "1"
TOOL.ClientConVar[ "automatic" ]	= "1"
TOOL.ClientConVar[ "ammotype" ]		= "Pistol"

cleanup.Register( "turrets" )

CreateConVar( "sbox_maxturrets", 4, FCVAR_NOTIFY )

// Precache these sounds..
Sound( "ambient.electrical_zap_3" )
Sound( "NPC_FloorTurret.Shoot" )

// Add Default Language translation (saves adding it to the txt files)
if ( CLIENT ) then

	language.Add( "tool.physbulletturret.name", "PhysBullet Turret" )
	language.Add( "tool.physbulletturret.desc", "Throws PhysBullets at things" )
	language.Add( "tool.physbulletturret.0", "Click somewhere to spawn an turret. Click on an existing turret to change it." )

	language.Add( "tool.physbulletturret.spread", "Bullet Spread" )
	language.Add( "tool.physbulletturret.numbullets", "Bullets per Shot" )
	language.Add( "tool.physbulletturret.sound", "Shoot Sound" )

	language.Add( "Undone_turret", "Undone Turret" )

	language.Add( "Cleanup_turrets", "Turret" )
	language.Add( "Cleaned_turrets", "Cleaned up all Turrets" )
	language.Add( "SBoxLimit_turrets", "You've reached the Turret limit!" )

	language.Add( "Floor Turret", "Floor Turret" )
	language.Add( "AR2", "AR2" )
	language.Add( "ZAP", "Zap" )
	language.Add( "SMG", "SMG" )
	language.Add( "Shotgun", "Shotgun" )
	language.Add( "Airboat Heavy", "Airboat Heavy" )

end

function TOOL:LeftClick( trace, worldweld )

	worldweld = worldweld or false

	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end
	
	// If there's no physics object then we can't constraint it!
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	if (CLIENT) then return true end
	
	local ply = self:GetOwner()
	
	local key			= self:GetClientNumber( "key" ) 
	local delay			= self:GetClientNumber( "delay" ) 
	local toggle		= self:GetClientNumber( "toggle" ) == 1
	local sound			= self:GetClientInfo( "sound" )
	local ammotype		= self:GetClientInfo( "ammotype" )
	local damage		= self:GetClientNumber( "damage" )
	local spread		= self:GetClientNumber( "spread" )
	local numbullets	= self:GetClientNumber( "numbullets" )
	damage = ( damage == -1 and false or damage )

	if ( !game.SinglePlayer() ) then
	
		// Clamp stuff in multiplayer.. because people are idiots
		
		delay		= math.Clamp( delay, 0.01, 3600 )
		numbullets	= math.Clamp( numbullets, 1, 24 )
		spread		= math.Clamp( spread, 0, 1 )
		damage		= math.Clamp( damage, -1, 500 )
	
	end


	// We shot an existing turret - just change its values
	if ( trace.Entity:IsValid() && trace.Entity:GetClass() == "physbullet_turret" && trace.Entity.pl == ply ) then

		trace.Entity:SetDamage( damage )
		trace.Entity:SetDelay( delay )
		trace.Entity:SetToggle( toggle )
		trace.Entity:SetNumBullets( numbullets )
		trace.Entity:SetSpread( spread )
		trace.Entity:SetSound( sound )
		trace.Entity:SetAmmoType( ammotype )
		return true
		
	end

	if ( !self:GetSWEP():CheckLimit( "turrets" ) ) then return false end

	if ( trace.Entity != NULL && (!trace.Entity:IsWorld() || worldweld) ) then
	
		trace.HitPos = trace.HitPos + trace.HitNormal * 2
	
	else
	
		trace.HitPos = trace.HitPos + trace.HitNormal * 2
	
	end


	local turret = MakeTurret( ply, trace.HitPos, nil, key, delay, toggle, damage, sound, numbullets, spread, ammotype )
	/*
	local Angle = trace.HitNormal:Angle()
		Angle:RotateAroundAxis( Angle:Forward(), 90 )
		Angle:RotateAroundAxis( Angle:Forward(), 90 )
	*/
	turret:SetAngles( trace.HitNormal:Angle() )

	local weld

	// Don't weld to world
	if ( trace.Entity != NULL) then
		if (!trace.Entity:IsWorld() || worldweld) then
	
			weld = constraint.Weld( turret, trace.Entity, 0, trace.PhysicsBone, 0, 0, true )
			
			// Don't hit your parents or you will go to jail.
			
			turret:GetPhysicsObject():EnableCollisions( false )
			turret.nocollide = true
		else
			turret:GetPhysicsObject():Sleep()
		end
	end

	undo.Create("Turret")
		undo.AddEntity( turret )
		undo.AddEntity( weld )
		undo.SetPlayer( ply )
	undo.Finish()

	return true

end

function TOOL:RightClick( trace )
	return self:LeftClick( trace, true )
end

if (SERVER) then

	function MakeTurret( ply, Pos, Ang, key, delay, toggle, damage, sound, numbullets, spread, ammotype, Vel, aVel, frozen, nocollide )

		if ( !ply:CheckLimit( "turrets" ) ) then return nil end

		local turret = ents.Create( "physbullet_turret" )
		if (!turret:IsValid()) then return false end

		turret:SetPos( Pos )
		if ( Ang ) then turret:SetAngles( Ang ) end
		turret:Spawn()

		turret:SetDamage( damage )
		turret:SetPlayer( ply )

		turret:SetSpread( spread )
		turret:SetSound( sound )
		turret:SetAmmoType( ammotype )

		turret:SetNumBullets( numbullets )

		turret:SetDelay( delay )
		turret:SetToggle( toggle )

		numpad.OnDown( 	 ply, 	key, 	"physbulletturret_On", 	turret )
		numpad.OnUp( 	 ply, 	key, 	"physbulletturret_Off", 	turret )

		if ( nocollide == true ) then turret:GetPhysicsObject():EnableCollisions( false ) end

		local ttable = 
		{
			key		= key,
			delay 		= delay,
			toggle 		= toggle,
			damage 		= damage,
			pl			= ply,
			nocollide 	= nocollide,
			sound		= sound,
			spread		= spread,
			numbullets	= numbullets,
			ammotype		= ammotype
		}

		table.Merge( turret:GetTable(), ttable )
		
		ply:AddCount( "turrets", turret )
		ply:AddCleanup( "turrets", turret )

		return turret

	end

	duplicator.RegisterEntityClass( "physbullet_turret", MakeTurret, "Pos", "Ang", "key", "delay", "toggle", "damage", "sound", "numbullets", "spread", "ammotype", "Vel", "aVel", "frozen", "nocollide" )

end

function TOOL.BuildCPanel( CPanel )

	// HEADER
	CPanel:AddControl( "Header", { Text = "#tool.physbulletturret.name", Description	= "#tool.physbulletturret.desc" }  )

	// Presets
	local params = { Label = "#Presets", MenuButton = 1, Folder = "physbulletturret", Options = {}, CVars = {} }

		params.Options.default = {
			physbulletturret_key			=	3,
			physbulletturret_delay		=		0.2,
			physbulletturret_toggle		=		1,
			physbulletturret_sound		=		"pistol",
			physbulletturret_ammotype	=		"Pistol",
			physbulletturret_damage		=		-1,
			physbulletturret_spread		=		0,
			physbulletturret_numbullets	=		1,
		}

		table.insert( params.CVars, "physbulletturret_key" )
		table.insert( params.CVars, "physbulletturret_delay" )
		table.insert( params.CVars, "physbulletturret_toggle" )
		table.insert( params.CVars, "physbulletturret_sound" )
		table.insert( params.CVars, "physbulletturret_ammotype" )
		table.insert( params.CVars, "physbulletturret_damage" )
		table.insert( params.CVars, "physbulletturret_spread" )
		table.insert( params.CVars, "physbulletturret_numbullets" )

	CPanel:AddControl( "ComboBox", params )

	// Keypad
	CPanel:AddControl( "Numpad", { Label = "#Turret Key", Command = "physbulletturret_key", ButtonSize = 22 } )

	local AmmoTypes = { Label = "AmmoType", MenuButton = 0, Options = {}, CVars = {} }
		for k, v in SortedPairs( hab.Module.PhysBullet.AmmoTypes ) do

			AmmoTypes.Options[k] = { physbulletturret_ammotype = v.name }

		end

	CPanel:AddControl("ComboBox", AmmoTypes )

	// Shot sounds
	local weaponSounds = {Label = "#tool.physbulletturret.sound", MenuButton = 0, Options={}, CVars = {}}
		weaponSounds["Options"]["#None"]			= { physbulletturret_sound = "" }
		weaponSounds["Options"]["#Pistol"]			= { physbulletturret_sound = "Weapon_Pistol.Single" }
		weaponSounds["Options"]["#SMG"]				= { physbulletturret_sound = "Weapon_SMG1.Single" }
		weaponSounds["Options"]["#AR2"]				= { physbulletturret_sound = "Weapon_AR2.Single" }
		weaponSounds["Options"]["#Shotgun"]			= { physbulletturret_sound = "Weapon_Shotgun.Single" }
		weaponSounds["Options"]["#Floor Turret"]	= { physbulletturret_sound = "NPC_FloorTurret.Shoot" }
		weaponSounds["Options"]["#Airboat Heavy"]	= { physbulletturret_sound = "Airboat.FireGunHeavy" }
		weaponSounds["Options"]["#Zap"]				= { physbulletturret_sound = "ambient.electrical_zap_3" }
	CPanel:AddControl("ComboBox", weaponSounds )

	// Various controls that you should play with!

	CPanel:AddControl( "Slider", {

		Label	= "#tool.physbulletturret.numbullets",
		Type	= "Integer",
		Min		= 1,
		Max		= 24,
		Command = "physbulletturret_numbullets"

	} )

	CPanel:AddControl( "Slider", {

		Label	= "Bullet Damage",
		Type	= "Float",
		Min		= -1,
		Max		= 100,
		Command = "physbulletturret_damage"

	} )

	CPanel:AddControl( "Slider", {

		Label	= "#tool.physbulletturret.spread",
		Type	= "Float",
		Min		= 0,
		Max		= 1.0,
		Command = "physbulletturret_spread"

	} )

	// The delay between shots.
	CPanel:AddControl( "Slider", {
	
		Label	= "#Delay",
		Type	= "Float",
		Min		= 0.01,
		Max		= 1.0,
		Command = "physbulletturret_delay"

	} )

	// The toggle switch.
	CPanel:AddControl( "Checkbox", { Label = "#Toggle", Command = "physbulletturret_toggle" } )


end
