BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}

surface.CreateFont( "shlog_player_name", {
	font = "Univers LT Std 47 Cn Lt",
	size = 17,
	weight = 0,
	antialias = true,
	extended = true,
	shadow = false,
	outline = false,
})

surface.CreateFont( "shlog_button", {
	font = "Univers LT Std 47 Cn Lt",
	size = 20,
	weight = 0,
	antialias = true,
	extended = true,
	shadow = false,
	outline = false,
})

local loading_gui = Material("shlogs/loading.png", "noclamp smooth")
local button_1_gui = Material("shlogs/button.png", "noclamp smooth")

local color_avatar_overlay = Color(200,200,200)

local color_button_hovered = Color(255,255,255)
local color_button_unhovered = Color(200,200,200, 200)

function BREACH.AdminLogs:CreatePlayerData(logid, playerdata)
	--if IsValid(BREACH.AdminLogs.UI.PlayerPanel) then BREACH.AdminLogs.UI.PlayerPanel:Remove() end

	local sid64 = playerdata.sid64

	local w, h = 390, 200
	local this = vgui.Create("DFrame", self.UI._UI_LOGS_DFrame)
	self.UI.PlayerPanel = this
	--self.UI.PlayerPanel:MakePopup()
	self.UI.PlayerPanel:SetSize(w,h+25)
	self.UI.PlayerPanel:SetPos(self.UI._UI_LOGS_DFrame:LocalCursorPos())

	self.UI.PlayerPanel.Main = vgui.Create("DPanel", self.UI.PlayerPanel)

	self.UI.PlayerPanel.Main:SetSize(w,h)
	self.UI.PlayerPanel.Main:SetPos(0,25)

	self.UI.PlayerPanel.Main.loading = true

	this:SetPos(math.Clamp(this:GetX(), 0, self.UI._UI_LOGS_DFrame:GetWide()-this:GetWide()), math.Clamp(this:GetY(), 0, self.UI._UI_LOGS_DFrame:GetTall()-this:GetTall()))

	this.Paint = function(self, w, h)
		draw.RoundedBox(0, 0,0, w, 25, color_white)
	end

	--this:SetZPos(200)

	function self.UI.PlayerPanel.Main:LoadPlayer(data)

		if self.load then return end
		self.load = true

		self.loading = false

		local avatar = vgui.Create("AvatarImage", self)
		avatar:SetSize(130, 130)
		avatar:SetSteamID(data.sid64, 128)
		avatar:SetPos(20,h-avatar:GetTall()-30)

		avatar.PaintOver = function(self, w, h)
			surface.SetDrawColor(color_avatar_overlay)
			surface.DrawOutlinedRect(0,0,w,h, 1)
		end

		local playername = vgui.Create("DPanel", self)
		playername:SetPos(avatar:GetPos())
		playername:SetSize(avatar:GetWide(), 17)
		playername:SetY(playername:GetY()-playername:GetTall()-2)

		playername.Paint = function(self, w, h)
			draw.DrawText(data.steamName, "shlog_player_name", w/2, 0, color_white, TEXT_ALIGN_CENTER)
		end

		local buttons = {
			{
				name = "SteamID",
				hover_name = util.SteamIDFrom64(data.sid64),
				onfunc = function()
					surface.PlaySound( "buttons/button1.wav" )
					SetClipboardText(util.SteamIDFrom64(data.sid64))
					BREACH.AdminLogs.UI:Tip("Скопировано!")
				end
			},
			{
				name = "SteamID64",
				hover_name = data.sid64,
				onfunc = function()
					surface.PlaySound( "buttons/button1.wav" )
					SetClipboardText(data.sid64)
					BREACH.AdminLogs.UI:Tip("Скопировано!")
				end
			},
			{
				name = L"l:shlogs_profile",
				onfunc = function()
					gui.OpenURL( "http://steamcommunity.com/profiles/"..data.sid64 )
    				surface.PlaySound( "buttons/button9.wav" )
				end
			},
			{
				name = L"l:shlogs_details",
				deepinfocheck = true,
				onfunc = function()
					BREACH.AdminLogs.UI:OpenDeepInfo(data, data.deepinfoid)
				end
			},
		}

		local offset = 0
		for i = 1, #buttons do
			local _b = buttons[i]
			local button = vgui.Create("DButton", self)

			button:SetSize(200, 30)
			button:SetPos(avatar:GetX() + avatar:GetWide() + 20, 20+offset)

			button:SetText("")

			if _b.deepinfocheck and !data.deepinfoid then
				button.locked = true
			end

			function button:DoClick()

				_b.onfunc()

			end

			button.Paint = function(self, w, h)

				local col = color_button_unhovered
				local text = _b.name

				if self:IsHovered() and !self.locked then
					if _b.hover_name then text = _b.hover_name end
					col = color_button_hovered
				end

				surface.SetMaterial(button_1_gui)
				surface.SetDrawColor(col)
				surface.DrawTexturedRect(0,0,w,h)

				draw.DrawText(text, "shlog_button", w/2, 5, col, TEXT_ALIGN_CENTER)
			end

			if button.locked then button:SetCursor("none") button:SetAlpha(5) end

			offset = offset + button:GetTall() + 10
		end

	end

	--[[
	timer.Simple(0.1, function()
		self.UI.PlayerPanel.Main:LoadPlayer({
			sid64 = "76561198869328954",
			steamName = "Shaky",
		})
	end)]]

	--[[

	BREACH.AdminLogs:GetPlayerData(logid, sid64, function(data)
		if IsValid(this) then
			this.Main:LoadPlayer(data)
		end
	end)

	--]]

	if BREACH.RememberNames[sid64] then
		playerdata.steamName = BREACH.RememberNames[sid64]
		this.Main:LoadPlayer(playerdata)
	else
		steamworks.RequestPlayerInfo( sid64, function( steamName )
			playerdata.steamName = steamName
			BREACH.RememberNames[sid64] = steamName
			this.Main:LoadPlayer(playerdata)
		end )
	end

	self.UI.PlayerPanel.Main.Paint = function(self, w, h)
		draw.RoundedBox(0,0,0,w,h,color_black)

		surface.SetDrawColor(color_white)
		surface.DrawOutlinedRect(1,0,w-2,h,1)
		if self.loading then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(loading_gui)
			surface.DrawTexturedRectRotated(w/2, h/2, 35, 35, (CurTime() * -300) % 360)
		end
	end

end