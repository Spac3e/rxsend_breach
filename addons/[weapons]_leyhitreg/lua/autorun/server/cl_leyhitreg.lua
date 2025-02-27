local code = [[
local option_customnetmsg = "custom_info"

LeyHitreg = LeyHitreg or {}
LeyHitreg.totalbullets = LeyHitreg.totalbullets or 1
LeyHitreg.bulletlog = LeyHitreg.bulletlog or {}

local shotsthistime = 0


function LeyHitreg.EntityFireBullets( ent, data, mode )
--if LocalPlayer():SteamID() == "STEAM_0:0:18725400" then
	--print("function called")
--end
	if(not IsValid(ent) or ent != LocalPlayer()) then return end
--if LocalPlayer():SteamID() == "STEAM_0:0:18725400" then
	--print("ent == localplayer and valid")
--end
	--not defined in hab phys bullets
	--if(data.Num != 1) then return end -- more than 1 bullet n shit like that, shotguns dont need this
	local primaryfire = input.IsMouseDown(MOUSE_LEFT)

	if(not input.IsMouseDown(MOUSE_LEFT) and not input.IsMouseDown(MOUSE_RIGHT)) then
		primaryfire = true
		--return
	end

	local usingwep = ent:GetActiveWeapon()
	local spread = data.Spread

	data.Spread = Vector(0,0,0)

	if(LeyHitreg.lasttbl) then

		local mismatch = false

		if(LeyHitreg.lastwep!=usingwep) then
			mismatch = true
			--print("wrong wep")
		end

		if(not mismatch) then
			for k,v in pairs(LeyHitreg.lasttbl) do
				if(v == data[k]) then continue end
				if(k=="Callback") then continue end
				
				mismatch = true
				break
			end
		end


		if(not mismatch) then
			if(primaryfire and usingwep.Primary and  usingwep.Primary.Delay and CurTime() > usingwep.Primary.Delay + LeyHitreg.lastsendtime) then
				mismatch = true
			end

			if(not primaryfire and usingwep.Secondary and usingwep.Secondary.Delay and CurTime() > usingwep.Secondary.Delay + LeyHitreg.lastsendtime) then
				mismatch = true
			end

		end

		if(not mismatch) then
			--print("the same")
			return false
		end
	end

--if LocalPlayer():SteamID() == "STEAM_0:0:18725400" then
	--print("mismatch check passed")
--end

	if(CurTime() == ent.lasthittime) then
		shotsthistime = shotsthistime + 1
	else
		shotsthistime = 0
	end

	LeyHitreg.lastsendtime = CurTime()
	LeyHitreg.lasttbl = table.Copy(data)
	LeyHitreg.lastwep = usingwep

	--math.randomseed( CurTime() + shotsthistime )
	--print(data.Dir)
	--print(spread)
	data.Dir = data.Dir + Vector( spread.x * (math.random() * 2 - 1), spread.y * (math.random() * 2 - 1), spread.z *(math.random() * 2 - 1))



	--if(CurTime() == ent.lasthittime) then return true end


	ent.lasthittime = CurTime()


	local bulletsrc = data.Src
	local bulletdir = data.Dir


	local trtbl = {}
	
	trtbl.start = bulletsrc
	trtbl.endpos = trtbl.start + (bulletdir * (56756 * 8))
	trtbl.filter = LocalPlayer()
	trtbl.mask = MASK_SHOT
	
	--local trace = util.TraceLine(trtbl)

	--if(not IsValid(trace.Entity)) then return end





	local hitpos = data.tr.HitPos
	local hitent = data.tr.Entity
	local hitboxhit = data.tr.HitGroup


	if(IsValid(usingwep)) then

		if(primaryfire) then
			--if(usingwep.lhb_nextprimaryfire and usingwep.lhb_nextprimaryfire > CurTime()) then return end

			if(usingwep.Primary and usingwep.Primary.Delay) then
				usingwep.lhb_nextprimaryfire = CurTime() + usingwep.Primary.Delay
			end
		else
			--if(usingwep.lhb_nextsecondaryfire and usingwep.lhb_nextsecondaryfire > CurTime()) then return end

			if(usingwep.Secondary and usingwep.Secondary.Delay) then
				usingwep.lhb_nextsecondaryfire = CurTime() + usingwep.Secondary.Delay
			end
		end

	end

	net.Start("custom_info", true)
		net.WriteUInt(1,8)
		net.WriteBool(primaryfire)
		net.WriteEntity(usingwep)
		net.WriteEntity(hitent)

		net.WriteVector(bulletsrc)
		net.WriteVector(bulletdir)

		net.WriteVector(hitent:WorldToLocal(hitpos)) --hitpos
		net.WriteUInt(hitboxhit, 8)
		--net.WriteString(tostring(mode))
		local caliber = data.Caliber or 2
		net.WriteFloat(caliber) --net.WriteString(tostring(caliber))
		local hitnormal = data.tr.HitNormal or data.FlightDirection
		net.WriteVector(hitnormal)
		local hitmat = data.Surf or 0
		net.WriteInt(hitmat, 9)
		local bullettype = data.BulletType or 0
		net.WriteUInt(bullettype, 2) --net.WriteString(tostring(data.BulletType))
		--local bulletposition = data.Position
		--net.WriteVector(hitent:WorldToLocal(bulletposition)) --bulletposition
		net.WriteUInt(LeyHitreg.totalbullets, 16)
	net.SendToServer()
	LeyHitreg.totalbullets = LeyHitreg.totalbullets + 1
	--if LocalPlayer():SteamID() == "STEAM_0:0:18725400" then
		--print("sent this shit")
		local wepclass = IsValid(usingwep) and usingwep:GetClass() or "unknown_weapon"
		local hitentclass = IsValid(hitent) and hitent:GetClass() or "unknown_entity"
		LeyHitreg.bulletlog[#LeyHitreg.bulletlog + 1] = "[client] sent bullet("..LeyHitreg.totalbullets..") from weapon "..wepclass.." to hit entity "..hitentclass
		if #LeyHitreg.bulletlog > 150 then
			table.remove(LeyHitreg.bulletlog, 1)
		end
	--end

	return true
end

net.Receive("custom_info", function(len)
	local msg = "(SERVER) "..net.ReadString() or "(SERVER) invalid data"
	LeyHitreg.bulletlog[#LeyHitreg.bulletlog + 1] = msg
	if #LeyHitreg.bulletlog > 150 then
		table.remove(LeyHitreg.bulletlog, 1)
	end
end)

--hook.Add("EntityFireBullets", "LeyHitreg.EntityFireBullets", LeyHitreg.EntityFireBullets)
hook.Add("PhysBulletHit", "physbulletonbulletcreateeffects", function(ent, bullet, mode)
	--print("oneffects")
	--print("attacker == localplayer")
	--bullet.Dir = tr.Normal
	--bullet.Src = tr.StartPos
	--print(bullet.Dir)
	--print(bullet.Src)
	LeyHitreg.EntityFireBullets(ent, bullet, mode)
end)

concommand.Add("bulletlog", function(ply, cmd, args, argstr)
	for k, v in pairs(LeyHitreg.bulletlog) do
		print(k..": "..v)
	end
end)
]]

hook.Add("KsaikokOnCLLoaderInit", "Ksaikok_Load_Hitreg", function()
	ksaikok.Load("LeyHitreg", code)
end)

if ksaikok then
	ksaikok.LoadNow(code)
end