AddCSLuaFile()

SWEP.Spawnable = true -- (Boolean) Can be spawned via the menu
SWEP.AdminOnly = false -- (Boolean) Admin only spawnable

SWEP.WeaponName = "v92_eq_unarmed" -- (String) Name of the weapon script
SWEP.PrintName = "Руки" -- (String) Printed name on menu

SWEP.ViewModelFOV = 90 -- (Integer) First-person field of view

SWEP.droppable				= false

if ( CLIENT ) then

	SWEP.BounceWeaponIcon = false
	SWEP.InvIcon = Material( "nextoren/gui/icons/hand.png" )

end

SWEP.UnDroppable = true
SWEP.UseHands = true
SWEP.ViewModel = Model( "models/jessev92/weapons/unarmed_c.mdl" )
SWEP.WorldModel = ""
SWEP.HoldType = "normal"


SWEP.Primary.ClipSize = -1

SWEP.Primary.DefaultClip = -1

SWEP.Primary.Automatic = true

SWEP.Primary.Ammo = "none"



SWEP.Secondary.ClipSize = -1

SWEP.Secondary.DefaultClip = -1

SWEP.Secondary.Automatic = true

SWEP.Secondary.Ammo = "none"

local blacklist = {
	["item_drink_294"] = true,
}

function SWEP:AnimationPlayback( Animation )
	local owner = self:GetOwner()

	local anim = owner:GetViewModel( ):LookupSequence( Animation )
	owner:GetViewModel( ):SendViewModelMatchingSequence( anim )
	owner:GetViewModel( ):SetCycle( 0 )

end

if SERVER then
	function SWEP:Think()
		local owner = self:GetOwner()
		local selftable = self:GetTable()
		if selftable.Drag and (not owner:KeyDown(IN_ATTACK) or not IsValid(selftable.Drag.Entity)) then

			local ent = self.Drag.Entity
	
	
	
	
	
			if IsValid(ent) then
	
				timer.Create('RemoveOwner_'..ent:EntIndex(), 30, 1, function()
	
					ent:SetNWEntity('PlayerCarrying', nil)
	
				end)
	
			end
	
	
	
			selftable.Drag = nil
	
		end

		if selftable.Drag and owner:GetPos():DistToSqr(selftable.Drag.Entity:GetPos()) > 40000 then
			selftable.Drag = nil
		end
	end
end

if CLIENT then

	function SWEP:Think()
		local owner = self:GetOwner()

		local movetype

		if ( ( self && self:IsValid() ) && ( owner && owner:IsValid() ) ) then

			local vm = owner:GetViewModel()

			if ( !( vm && vm:IsValid() ) ) then return end

			movetype = owner:GetMoveType()

			-- in noclip
			if movetype == 8 then

				vm:ResetSequence( 4 )

			-- If on ladder
			elseif movetype == 9 then

				-- if moving
				if owner:KeyDown( IN_FORWARD || IN_BACK )  then

					-- climb ladder sequence
					vm:ResetSequence( vm:LookupSequence( "ladder_climb" ) )

				else

					-- climb ladder sequence
					vm:ResetSequence( vm:LookupSequence( "ladder_idle" ) )

				end

			-- not in noclip
			else

				-- If swimming
				if owner:WaterLevel( ) >= 2 then

					-- if moving
					if owner:KeyDown( IN_FORWARD or IN_MOVELEFT or IN_MOVERIGHT or IN_BACK )  then

						-- and sprinting
						if owner:KeyDown( IN_SPEED ) then

							-- swimming fast
							vm:ResetSequence( 20 )

						-- not sprinting
						else

							-- swim slow
							vm:ResetSequence( 19 )

						end

					-- not moving
					else

						-- just be
						vm:ResetSequence( 18 )

					end

				-- in ankle water or not in water
				elseif owner:WaterLevel( ) < 2 then

					-- on ground
					if owner:OnGround( ) then

						-- use key
						if owner:KeyDown( IN_USE ) && movetype == MOVETYPE_WALK then

							vm:ResetSequence( 13 )
							owner:DoAnimationEvent( ACT_GMOD_GESTURE_ITEM_GIVE )

						else

							-- print( "Hands: OTHER; IDLE" )
							vm:ResetSequence( 2 )

						end

					else

						if owner:GetVelocity()["z"] > 10 then

							vm:ResetSequence( 5 )

						elseif owner:GetVelocity()["z"] < -250 and owner:GetVelocity()["z"] >= -500 then

							vm:ResetSequence( 18 )

						elseif owner:GetVelocity()["z"] < -500 and owner:GetVelocity()["z"] >= -750 then

							vm:ResetSequence( 19 )

						elseif owner:GetVelocity()["z"] < -750 then

							vm:ResetSequence( 20 )

						else

							vm:ResetSequence( 4 )

						end

					end

				else

					vm:ResetSequence( 2 )

				end

			end

		end

	end

end

function SWEP:Initialize()
	self.Time = 0
	self.Range = 100
	self:SetHoldType( self.HoldType )
end

function SWEP:PrimaryAttack( right )



	local Pos = self.Owner:GetShootPos()

	local Aim = self.Owner:GetAimVector()



	local Tr = util.TraceLine{

		start = Pos,

		endpos = Pos +Aim * self.Range,

		filter = player.GetAll(),

	}

	local HitEnt = Tr.Entity

	if IsValid(HitEnt) and HitEnt:GetClass() == "item_special_document" and self.Owner:GetRoleName() != role.SCI_SpyUSA then
		return
	end

	if self.Drag then

		HitEnt = self.Drag.Entity



	else

		if not IsValid( HitEnt ) or HitEnt:GetMoveType() ~= MOVETYPE_VPHYSICS or HitEnt:IsVehicle() or HitEnt.BlockDrag or IsValid( HitEnt:GetParent() or blacklist[HitEnt:GetClass()] ) then

			return

		end

		if HitEnt.IsLootingBy and #HitEnt.IsLootingBy > 0 then
			return
		end

		if not self.Drag then

			self.Drag = {

				OffPos = HitEnt:WorldToLocal(Tr.HitPos),

				Entity = HitEnt,

				Fraction = Tr.Fraction,

				OrigAng = HitEnt:GetAngles(),

			}

			if HitEnt:GetClass() == "prop_ragdoll" then

				local closest = 1000000000000000
				local physobj = HitEnt:GetPhysicsObjectNum(0)

				for i=0, HitEnt:GetPhysicsObjectCount() - 1 do -- "ragdoll" being a ragdoll entity
		 
					local phys = HitEnt:GetPhysicsObjectNum(i)
					local dist = phys:GetPos():DistToSqr(Tr.HitPos)
					if dist < closest then closest = dist physobj = phys end

				end

				if IsValid(physobj) then
					self.Drag.physobj = physobj
					self.Drag.OrigAng = physobj:GetAngles()
					self.Drag.OffPos = physobj:WorldToLocal(Tr.HitPos)
				end
				
			end


			if !IsValid(HitEnt:GetNWEntity('PlayerCarrying')) then

				HitEnt:SetNWEntity('PlayerCarrying', self.Owner)

	

				timer.Remove('RemoveOwner_'..HitEnt:EntIndex())

			end



			if HitEnt:GetNWEntity('PlayerCarrying') == self.Owner then

				timer.Remove('RemoveOwner_'..HitEnt:EntIndex())

			end

		end

	end



	if CLIENT or not IsValid( HitEnt ) then return end

	local Phys = HitEnt:GetPhysicsObject()

	if self.Drag.physobj then Phys = self.Drag.physobj end

	if IsValid( Phys ) then
		local Pos2 = Pos +Aim *self.Range *self.Drag.Fraction

		local OffPos = Phys:LocalToWorld( self.Drag.OffPos )

		local Dif = Pos2 -OffPos

		local Nom

		local addanglevelocity

		if HitEnt:GetClass() == "prop_ragdoll" then
			Nom = (Dif:GetNormal() *math.min(1, Dif:Length() /100) *500 ) * (Phys:GetMass())
			addanglevelocity = -Phys:GetAngleVelocity()
		else
			Nom = (Dif:GetNormal() *math.min(1, Dif:Length() /100) *500 -Phys:GetVelocity()) * Phys:GetMass()
			addanglevelocity = -Phys:GetAngleVelocity() / 4
		end

		Phys:ApplyForceOffset( Nom, OffPos )

		Phys:AddAngleVelocity( addanglevelocity )

	end



end


function SWEP:CanSecondaryAttack( )

	return false

end

function SWEP:Reload() end

function SWEP:Deploy( )
	local owner = self:GetOwner()

	if ( ( self && self:IsValid() ) && ( owner && owner:IsValid() ) ) then

		local vm = owner:GetViewModel()

		if ( !( vm && vm:IsValid() ) ) then return end

		vm:ResetSequence( 2 )

	end

end

function SWEP:OnDrop( )

	if ( self && self:IsValid() ) then

		self:Remove( )

	end

end
