-- code was kindfully written by the developer of VAULT (oh, now it's called Monix, how unfortunate, now i wonder, why did he got kicked from VAULT out of a sudden?) Breach developer spac3

local stringfind = string.find

BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}

BREACH.AdminLogs.SnapShot = BREACH.AdminLogs.SnapShot || {}

BREACH.AdminLogs.SnapShot._Cache = BREACH.AdminLogs.SnapShot._Cache || {}

BREACH.AdminLogs.SnapShot.SnapShotMode = BREACH.AdminLogs.SnapShot.SnapShotMode || false
BREACH.AdminLogs.SnapShot.SnapShotModels = BREACH.AdminLogs.SnapShot.SnapShotModels || {}
BREACH.AdminLogs.SnapShot.TraceDraw = BREACH.AdminLogs.SnapShot.TraceDraw || {}

local snapshot_defaultmodel = Model("models/cultist/humans/sci/hazmat_1.mdl")

local red_laser = Material("cable/red")
local blue_laser = Material("cable/blue")

function BREACH.AdminLogs:InSnapshotMode()
	return self.SnapShot.SnapShotMode
end


local szmat = Material("icon16/star.png")
local offset = Vector( 0, 0, 85 )
local angletobeedited = Angle(0, 0, 90)
local nicknamecolor = Color( 255, 255, 255, 220 )
local LocalPlayer = LocalPlayer

local function DrawTargetID(plypos, name)
	local client = LocalPlayer()

  local ang = client:EyeAngles()

  local pos = plypos + offset + ang:Up()

	ang:RotateAroundAxis( ang:Forward(), 90 )

  ang:RotateAroundAxis( ang:Right(), 90 )


	angletobeedited["y"] = ang["y"]

	cam.Start3D2D( pos, angletobeedited, 0.1 )

		draw.DrawText( name, "char_title", 2, 11, nicknamecolor, TEXT_ALIGN_CENTER )
	

	cam.End3D2D()

end


function BREACH.AdminLogs:LeaveSnapshotMode()
	if !self:InSnapshotMode() then return end

	for i, v in pairs(self.SnapShot.SnapShotModels) do
		if IsValid(v) then
			if v.BoneMergedEnts then
				for _, b in pairs(v.BoneMergedEnts) do
					if IsValid(b) then b:Remove() end
				end
			end
			v:Remove()
		end
	end

	self.SnapShot.SnapShotMode = false

	hook.Remove("PostDrawTranslucentRenderables", "shlogs_logging_scene_draw")
	hook.Remove( "PreDrawOutlines", "shlogs_logging_scene_draw_halo" )
	table.Empty(BREACH.AdminLogs.SnapShot.TraceDraw)

end

concommand.Add("debug_snapshotmodeleave", function() BREACH.AdminLogs:LeaveSnapshotMode() end)

local function _LoadSnapshot(snapshot)

	local data = {
		Targets = {},
		TraceDraw = {},
	}

	local laser = blue_laser

	for _, v in pairs(snapshot) do
		if istable(v) then
			if v.deep_info and v.deep_info.snapshot then

				local d = table.Copy(v.deep_info.snapshot)

				local name = v.sid64

				if BREACH.RememberNames[v.sid64] then name = BREACH.RememberNames[v.sid64] end

				d.name = name
				d.sid64 = v.sid64

				d.laser = laser

				laser = red_laser

				d.activeweapon = v.deep_info.activeweapon

				table.insert(data.Targets, d)

			end
		end
	end

	BREACH.AdminLogs:StartSnapshotMode(data)
end

function BREACH.AdminLogs:LoadSnapshot(snapshot_id, id)
	if self:InSnapshotMode() then return end

	if !id then id = 1 end

	if BREACH.AdminLogs.SnapShot._Cache[snapshot_id] and BREACH.AdminLogs.SnapShot._Cache[snapshot_id][id] then

		 _LoadSnapshot(BREACH.AdminLogs.SnapShot._Cache[snapshot_id][id])

	else

		BREACH.AdminLogs.SnapShot.Cur_Cacheid = snapshot_id
		BREACH.AdminLogs.SnapShot.Cur_Cachesid = id

		net.Start("ShLogs_ViewSnapshot")
		net.WriteUInt(snapshot_id, 32)
		net.WriteUInt(id, 12)
		net.SendToServer()

	end

	-- TODO

end

net.Receive("ShLogs_ViewSnapshot", function(len)

	local snapshot = net.ReadTable()
	 _LoadSnapshot(snapshot)

	BREACH.AdminLogs.SnapShot._Cache[BREACH.AdminLogs.SnapShot.Cur_Cacheid] = BREACH.AdminLogs.SnapShot._Cache[BREACH.AdminLogs.SnapShot.Cur_Cacheid] || {}
	BREACH.AdminLogs.SnapShot._Cache[BREACH.AdminLogs.SnapShot.Cur_Cacheid][BREACH.AdminLogs.SnapShot.Cur_Cachesid] = snapshot

end)

local custom_angle = Vector( 10, 0, 180 )
local aim_angle = Vector( 10, -5, 180 )
local origin_angle = Vector( -10, 0, 180 )

function BREACH.AdminLogs:StartSnapshotMode(snapshot_data)
	if self:InSnapshotMode() then return end

	self.SnapShot.SnapShotMode = true

	local pos = snapshot_data.Targets[1].pos

	net.Start("ShLogs_TeleportTo")
	net.WriteVector(pos)
	net.SendToServer()

	for i, v in pairs(snapshot_data.Targets) do
		local model = ClientsideModel(v.model)
		model:SetBodyGroups(v.bgroups)
		model:SetPos(v.pos)
		model:SetAngles(Angle(0, v.ang.y, 0))
		model:Spawn()

		model:SetSequence(v.seq)

		model:SetPoseParameter("aim_pitch", v.ang.p)
		model:SetPoseParameter("head_pitch", v.ang.p)


		for _, bn in pairs(v.bnmrgs) do
			ClientBoneMerge(model, bn)
		end


		if v.activeweapon != "none" then

			local wpn_data = weapons.Get(v.activeweapon)

			if istable(wpn_data) and wpn_data.WorldModel and ( (wpn_data.Pos and wpn_data.Ang) or (wpn_data.WMPos and wpn_data.WMAng) ) then

				local weapon_worldmodel = ClientsideModel( wpn_data.WorldModel )

				model.weaponmodel = weapon_worldmodel

				weapon_worldmodel.isweaponmdl = true

				if wpn_data.WMPos then
					weapon_worldmodel.Pos = wpn_data.WMPos
					weapon_worldmodel.Ang = wpn_data.WMAng
				else
					weapon_worldmodel.Pos = wpn_data.Pos
					weapon_worldmodel.Ang = wpn_data.Ang
				end

				weapon_worldmodel.Think = function(self)

					local bone = model:LookupBone( "ValveBiped.Bip01_R_Hand" )

				    if ( !bone ) then return end

					local pos, ang = model:GetBonePosition( bone )

					if ( bone ) then

						if isangle(wpn_data.Ang) then


							ang:RotateAroundAxis( ang:Right(), self.Ang.p )
							ang:RotateAroundAxis( ang:Forward(), self.Ang.y )
							ang:RotateAroundAxis( ang:Up(), self.Ang.r )

							self:SetPos( pos + ang:Right() * self.Pos.x + ang:Forward() * self.Pos.y + ang:Up() * self.Pos.z )
						else

							local name = model:GetSequenceName(v.seq)

							if ( stringfind(name, "Aim_MP40") || stringfind(name, "ZOOMED") ) then


								self.Ang = aim_angle


							elseif ( stringfind( name, "DOD_" ) || stringfind( name, "AHL_" ) ) then

								self.Ang = custom_angle

							else

								self.Ang = origin_angle

							end

							self:SetPos( pos + ang:Right() * self.Pos.y + ang:Forward() * self.Pos.x + ang:Up() * self.Pos.z )

							ang:RotateAroundAxis( ang:Right(), self.Ang.x )
							ang:RotateAroundAxis( ang:Forward(), self.Ang.z )
							ang:RotateAroundAxis( ang:Up(), self.Ang.y )
						end

						self:SetAngles( ang )
				    	if wpn_data.Skin and self:GetSkin() != wpn_data.Skin then

				    		self:SetSkin( wpn_data.Skin )

				    	end
						self:DrawModel()

					end
				end

				table.insert(self.SnapShot.SnapShotModels, weapon_worldmodel)

			end

		end



		table.insert(self.SnapShot.SnapShotModels, model)
	end

	hook.Add( "PreDrawOutlines", "shlogs_logging_scene_draw_halo", function()
		outline.Add(self.SnapShot.SnapShotModels, color_white, OUTLINE_MODE_BOTH)
	end )

	hook.Add("PostDrawTranslucentRenderables", "shlogs_logging_scene_draw", function()

		for _, ent in pairs(self.SnapShot.SnapShotModels) do
			if ent.isweaponmdl then
				ent.Think(ent)
			end
		end

		for _, f in pairs(snapshot_data.Targets) do
			if f.sid64 then
				DrawTargetID(f.pos, f.name)

				render.SetMaterial(f.laser)
				render.DrawBeam(f.shootpos, f.shootpos + f.ang:Forward()*1000, 2, 0, 1)

			end
		end

		--for _,f in pairs(BREACH.AdminLogs.SnapShot.TraceDraw) do f() end
	end)

end