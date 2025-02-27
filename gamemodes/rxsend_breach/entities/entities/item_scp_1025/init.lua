AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

ENT.BadDiseaseList = {
	{
		name = "l:diseases_appendicitis",
		eng_name = "Appendicitis",
		func = function(ply, book)
			ply.TempValues.diseaseremember.jumppower = ply:GetJumpPower()
			ply:SetJumpPower(0)
		end,
	},
	{
		name = "l:diseases_lungcancer",
		eng_name = "Lung Cancer",
		func = function(ply, book)
			ply.TempValues.diseaseremember.staminascale = ply:GetStaminaScale()
			ply:SetStaminaScale(0.06)
		end,
	},
	{
		name = "l:diseases_asthma",
		eng_name = "Asthma",
		func = function(ply, book)
			ply.TempValues.diseaseremember.staminascale = ply:GetStaminaScale()
			ply:SetStaminaScale(0.01)
		end,
	},
	{
		name = "l:diseases_cardiacarrest",
		eng_name = "Cardiac Arrest",
		func = function(ply, book)
			timer.Simple(10, function()
				if IsValid(ply) and ply:Alive() and ply:Health() > 0 and ply:GTeam() != TEAM_SPEC then
					ply:Kill()
				end
			end)
		end,
	},
	{
		name = "l:diseases_spontaneouscombustion",
		eng_name = "Spontaneous Combustion",
		func = function(ply, book)
			ply:SetHealth(1)
			ply:SetOnFire(6)
		end,
	},
}

ENT.NeutralDiseaseList = {
	{
		name = "l:diseases_chickenpox",
		eng_name = "Chickenpox",
		func = function(ply, book)
			timer.Simple(4, function()
				ply:setBottomMessage("l:scp1025_chickenpox")
			end)
		end
	},
	{
		name = "l:diseases_cold",
		eng_name = "cold",
		func = function(ply, book)
			local uniqueid = "SCP1025COLD"..ply:SteamID64()
			local remember
			timer.Create(uniqueid, 3, 0, function()

				if !IsValid(ply) or ply:GTeam() == TEAM_SPEC or ply:Health() <= 0 or !ply:Alive() then
					timer.Remove(uniqueid)
				end

				ply:EmitSound("^nextoren/unity/cough"..math.random(1,3)..".ogg", 75, 100, 1.5, CHAN_VOICE)

			end)
		end
	},
}

ENT.GoodDiseaseList = {
	{
		name = "l:diseases_musclemutation",
		eng_name = "Muscle Mutation",
		func = function(ply, book)
			ply:SetStaminaScale(ply:GetStaminaScale()+2)
			ply:SetMaxHealth(300)
			ply:SetHealth(300)
		end,
	},
	{
		name = "l:diseases_mitosis",
		eng_name = "Hyper-cellular mitosis",
		func = function(ply, book)
			local uniqid = "SCSP1025MITOSIS"..ply:SteamID64()
			timer.Create(uniqid, 10, 0, function()

				if !IsValid(ply) or ply:GTeam() == TEAM_SPEC or ply:Health() <= 0 or !ply:Alive() then
					timer.Remove(uniqid)
				end

				if ply:Health() < ply:GetMaxHealth() then
					ply:AnimatedHeal(ply:GetMaxHealth())
				end

			end)
		end
	}
}

function ENT:PickDisease(ply)

	local n = math.random(1, 100)
	if n > 70 then
		return self.NeutralDiseaseList[math.random(1, #self.NeutralDiseaseList)]
	elseif n > 30 then
		return self.GoodDiseaseList[math.random(1, #self.GoodDiseaseList)]
	else
		return self.BadDiseaseList[math.random(1, #self.BadDiseaseList)]
	end

	return self.NeutralDiseaseList[math.random(1, #self.NeutralDiseaseList)]

end

function ENT:Use(ply)

	if !ply:IsPlayer() then return end
	if ply:GetEyeTrace().Entity != self then return end
	if ply:GTeam() == TEAM_SCP or ply:GTeam() == TEAM_SPEC then return end
	if ply.TempValues.HasDisease then
		return
	end

	ply:BrProgressBar("l:progress_wait", 1.5, "nextoren/gui/icons/hand.png", self, false, function()
		if !ply.TempValues.diseaseremember then ply.TempValues.diseaseremember = {} end
		self:EmitSound("nextoren/others/turn_page.wav", 60, math.random(95, 105), 1, CHAN_BODY)

		local disease = self:PickDisease(ply)
		--[[
		ply:setBottomMessage({
			english = "You have read about \""..disease.eng_name.."\"",
			russian = "Вы прочитали об \""..disease.name.."\""
		})]]
		ply:RXSENDNotify("l:scp1025_you_read_about", (disease.name), "\"")
	
		ply.TempValues.HasDisease = true
		disease.func(ply, self)
	end)
end