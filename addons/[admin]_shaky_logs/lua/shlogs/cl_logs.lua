-- values were edited by the most talented programmer spac3

BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}

BREACH.AdminLogs.Sounds = {
	["log_open"] = Sound("shlogs/ui/log_open.mp3"),
	["click"] = Sound("shlogs/ui/click.mp3"),
	["hover"] = Sound("shlogs/ui/hover1.wav"),
}

local blur = Material("pp/blurscreen");
function BREACH:Blur(panel, amount, alpha)
	--if true then return end
	local x, y = panel:LocalToScreen(0, 0);
	local scrW, scrH = ScrW(), ScrH();

	surface.SetDrawColor(255, 255, 255, alpha);
	surface.SetMaterial(blur);

	for i = 1, 3 do
	    blur:SetFloat("$blur", (i / 3) * (amount or 6));
	    blur:Recompute();
	    render.UpdateScreenEffectTexture();
	    surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH);
	end
end

function BREACH.AdminLogs:GetLogs(page, type, filters, onreceive)
	if !type then type = "all" end

	net.Start("ShLogs_ReceiveLOGS")
	net.WriteString(type)
	net.SendToServer()

	BREACH.AdminLogs.ReceiveLogsCallback = onreceive

end

function BREACH.AdminLogs:SwtichPage(page, onreceive)

	net.Start("ShLogs_SwitchPage")
	net.WriteUInt(page, 8)
	net.SendToServer()

	BREACH.AdminLogs.ReceiveLogsCallback = onreceive

end

function BREACH.AdminLogs:GetPlayerData(logid, sid64, onreceive)
	if !type then type = "all" end

	net.Start("ShLogs_ReceivePLAYERINFO")
	net.WriteUInt(logid, 32)
	net.WriteString(sid64)
	net.SendToServer()

	BREACH.AdminLogs.ReceivePlayerDataCallback = onreceive

end

function BREACH.AdminLogs:NiceTextPlayer(playerdata)

	local col = gteams.GetColor(playerdata.team)

	local name = playerdata.sid64

	if BREACH.RememberNames[playerdata.sid64] then
		name = BREACH.RememberNames[playerdata.sid64]
	else
		steamworks.RequestPlayerInfo( playerdata.sid64, function( steamName )
			BREACH.RememberNames[playerdata.sid64] = steamName
		end )
	end

	name = name.."("..GetLangRole(playerdata.role)..")"

	local text = {
		color = col,
		text = name,
	}

	text.background = ColorAlpha(color_black, 200)

	if playerdata.team == TEAM_USA then
		text.background = ColorAlpha(color_white, 200)
	end

	return text

end

net.Receive("ShLogs_ReceiveLOGS", function(len)

	local logs = net.ReadTable()
	local page = net.ReadUInt(8)
	local pages = net.ReadUInt(8)

	if isfunction(BREACH.AdminLogs.ReceiveLogsCallback) then
		BREACH.AdminLogs.ReceiveLogsCallback(logs, page, pages)
	end

end)

net.Receive("ShLogs_ReceivePLAYERINFO", function(len)

	local data = net.ReadTable()

	if isfunction(BREACH.AdminLogs.ReceivePlayerDataCallback) then
		if BREACH.RememberNames[data.sid64] then
			data.steamName = BREACH.RememberNames[data.sid64]
			BREACH.AdminLogs.ReceivePlayerDataCallback(data)
		else
			steamworks.RequestPlayerInfo( data.sid64, function( steamName )
				data.steamName = steamName
				BREACH.RememberNames[data.sid64] = steamName
				BREACH.AdminLogs.ReceivePlayerDataCallback(data)
			end )
		end
	end

end)

concommand.Add("shlogs_openmenu", function()

	BREACH.AdminLogs.UI:OpenLogs()

end)