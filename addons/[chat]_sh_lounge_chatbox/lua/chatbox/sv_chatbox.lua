util.AddNetworkString("LOUNGE_CHAT.Typing")
util.AddNetworkString("LOUNGE_CHAT.TTTRadio")

net.Receive("LOUNGE_CHAT.Typing", function(len, ply)
	ply:SetNWBool("LOUNGE_CHAT.Typing", net.ReadBool())
end)

-- shitty override for a shitty gamemode
hook.Add("TTTPlayerRadioCommand", "LOUNGE_CHAT.TTTPlayerRadioCommand", function(ply, msg_name, msg_target)
	local name = ""

	local ent = msg_target
	if (!isstring(msg_target) and IsValid(msg_target)) then
		if (ent:IsPlayer()) then
			name = ent:Nick()
		elseif (ent:GetClass() == "prop_ragdoll") then
			name = LANG.NameParam("quick_corpse_id")
			rag_name = CORPSE.GetPlayerNick(ent, "A Terrorist")
		end
	elseif (isstring(msg_target)) then
		-- lang string
		name = LANG.NameParam(msg_target)
	end

	net.Start("LOUNGE_CHAT.TTTRadio")
		net.WriteEntity(ply)
		net.WriteString(msg_name)
		net.WriteString(name)
		if (rag_name) then
			net.WriteString(rag_name)
		end
	net.Broadcast()

	return true
end)

if (LOUNGE_CHAT.UseWorkshop) then
	resource.AddWorkshop("893244794")
else
	resource.AddFile("materials/shenesis/chat/checked.png")
	resource.AddFile("materials/shenesis/chat/close.png")
	resource.AddFile("materials/shenesis/chat/smile.png")
	resource.AddFile("materials/shenesis/chat/options.png")
	resource.AddFile("resource/fonts/circular.ttf")
	resource.AddFile("resource/fonts/circular_bold.ttf")
end