-- code was kindfully written by the developer of VAULT (oh, now it's called Monix, how unfortunate, now i wonder, why did he got kicked from VAULT out of a sudden?) Breach developer spac3

BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}

BREACH.AdminLogs._DeepInfoCache = BREACH.AdminLogs._DeepInfoCache || {}

local loading_gui = Material("shlogs/loading.png", "noclamp smooth")
local col_bg = Color(27,27,27)

local missingicon = Material("nextoren/gui/icons/missing.png", "noclamp smooth")

local function drawlines(self, w, h, mdlcolor)

	draw.RoundedBox(0,self.linewide+1,self.linewide+1,w-(self.linewide+1)*2,h-(self.linewide+1)*2, color_black)

	draw.RoundedBox(0,0,0,self.linetall,self.linewide, mdlcolor)
	draw.RoundedBox(0,0,0,self.linewide,self.linetall, mdlcolor)

	draw.RoundedBox(0,w-self.linetall,0,self.linetall,self.linewide, mdlcolor)
	draw.RoundedBox(0,w-self.linewide,0,self.linewide,self.linetall, mdlcolor)

	draw.RoundedBox(0,0,h-self.linewide,self.linetall,self.linewide, mdlcolor)
	draw.RoundedBox(0,0,h-self.linetall,self.linewide,self.linetall, mdlcolor)

	draw.RoundedBox(0,w-self.linetall,h-self.linewide,self.linetall,self.linewide, mdlcolor)
	draw.RoundedBox(0,w-self.linewide,h-self.linetall,self.linewide,self.linetall, mdlcolor)
end

net.Receive("ShLogs_ReceiveDEEPINFO", function(len)

	local data = net.ReadTable()

	if IsValid(BREACH.AdminLogs.UI.deep_info_loading) then
		BREACH.AdminLogs.UI.deep_info_loading:LoadData(data)
	end
	BREACH.AdminLogs.UI.deep_info_loading = nil



end)

function BREACH.AdminLogs.UI:OpenDeepInfo(playerdata, deep_info)

	if self.deep_info_loading and IsValid(self.deep_info_loading) then return end

	local this = vgui.Create("DFrame", self._UI_LOGS_DFrame)

	self.deep_info_loading = this

	this.Paint = function(self, w, h)
		draw.RoundedBox(0, 0,0, w, 25, color_white)
		draw.RoundedBox(0, 0,25, w, h-25, col_bg)
		if self.loading then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(loading_gui)
			surface.DrawTexturedRectRotated(w/2, h/2, 35, 35, (CurTime() * -300) % 360)
		end
	end

	this.loading = true

	this:SetSize(425,480)

	this:SetPos(self._UI_LOGS_DFrame:GetWide()/2-this:GetWide()/2, self._UI_LOGS_DFrame:GetTall()/2-this:GetTall()/2)

	function this:LoadData(data)

		BREACH.AdminLogs._DeepInfoCache[deep_info] = data

		self.loading = false

		local avatar = vgui.Create("DPanel", self)
		avatar.linetall = 6
		avatar.linewide = 1
		avatar:SetPos(10, 35)
		avatar:SetSize(144,160)

		avatar.Paint = function(self, w, h)

			drawlines(self, w, h, color_white)

		end

		local name = vgui.Create("DLabel", avatar)

		name:SetTextColor(color_white)
		name:SetFont("shlog_player_name")
		name:SetText( BREACH.RememberNames[playerdata.sid64] )
		name:SizeToContents()
		name:SetPos(avatar:GetWide()/2-name:GetWide()/2, 5)

		local avatarimage = vgui.Create("AvatarImage", avatar)
		avatarimage:SetPos(10, avatar:GetTall()-134)
		avatarimage:SetSize(124,124)

		avatarimage:SetSteamID(playerdata.sid64, 124)

		if data.inventory then

			local Inventory = vgui.Create("DPanel", self)

			Inventory:SetSize(250, 250)
			Inventory:SetPos(10, 35+160+20)

			Inventory.linetall = 6
			Inventory.linewide = 1

			Inventory.Paint = function(self, w, h)

				drawlines(self, w, h, color_white)

			end

			local scrollweapons = vgui.Create("DScrollPanel", Inventory)

			scrollweapons:SetSize(Inventory:GetWide()-20, Inventory:GetTall()-20)
			scrollweapons:SetPos(10, 10)

			function scrollweapons:AddWeapons(class)

				local weapon = weapons.Get(class)

				local panel = vgui.Create("DPanel", self)
				panel:SetSize(0, 60)
				panel:Dock(TOP)
				panel:DockMargin( 0, 0, 0, 10 )

				panel.linewide = 1
				panel.linetall = 7

				local clr = Color(0,255,0)

				panel.Paint = function(self, w, h)

					drawlines(self, w, h, color_white)

				end

				local avatar = vgui.Create("DPanel", panel)
				avatar:SetSize(panel:GetTall()-10, panel:GetTall()-10)
				avatar:SetPos(5, 5)

				if weapon.InvIcon then
					avatar.Icon = weapon.InvIcon
				else
					avatar.Icon = missingicon
				end

				avatar.linewide = 1
				avatar.linetall = 5

				avatar.Paint = function(self, w, h)

					surface.SetDrawColor(color_white)
					surface.SetMaterial(self.Icon)
					surface.DrawTexturedRect(0,0,w,h)

				end

				local text = vgui.Create("DLabel", panel)

				local name = class

				if weapon.PrintName then name = weapon.PrintName end

				text:SetFont("shlog_player_name")
				text:SetTextColor(color_white)
				text:SetText(name)
				text:SizeToContents()
				text:SetPos(avatar:GetX() + avatar:GetWide() + 10, panel:GetTall()/2-text:GetTall()/2)

				if class == data.activeweapon then
					local awpn = vgui.Create("DLabel", panel)
					awpn:SetFont("shlog_player_name")
					awpn:SetTextColor(Color(0,255,0))
					awpn:SetText("(ACTIVE)")
					awpn:SizeToContents()
					awpn:SetPos(text:GetX(), text:GetY()-2-awpn:GetTall())
				end

			end

			for i, v in pairs(data.inventory) do
				scrollweapons:AddWeapons(v)
			end

			scrollweapons:GetVBar():SetSize(0, 0)

		end



		local info = vgui.Create("DPanel", self)
		info.linetall = 6
		info.linewide = 1
		info:SetPos(avatar:GetWide()+avatar:GetX()+10, 35)
		info:SetSize(250,160)

		info.Paint = function(self, w, h)

			drawlines(self, w, h, color_white)

		end

		local text = {
			"l:shlogs_charname: "..data.charactername,
			"l:shlogs_role: "..GetLangRole(playerdata.role),
			"l:shlogs_team: "..gteams.GetName(playerdata.team)
		}

		local y = 10
		for i, v in pairs(text) do

			local text = vgui.Create("DLabel", info)

			text:SetFont("shlog_player_name")
			text:SetText(L(v))
			text:SetTextColor(color_white)
			text:SizeToContents()

			text:SetPos(10,y)

			y = y + text:GetTall() + 10

		end

		info:SetTall(y + 10)

		info:SetY(avatar:GetY()+avatar:GetTall()/2-info:GetTall()/2)

		if data.uniform and #data.uniform > 0 then

			local entity = scripted_ents.Get(data.uniform)

			local uniform = vgui.Create("DPanel", self)
			uniform.linetall = 6
			uniform.linewide = 1
			uniform:SetPos(250+10+10, 250)
			uniform:SetSize(144,160)

			uniform.Paint = function(self, w, h)

				drawlines(self, w, h, color_white)

			end

			local uniform_name = vgui.Create("DLabel", uniform)

			uniform_name:SetTextColor(color_white)
			uniform_name:SetFont("shlog_player_name")
			uniform_name:SetText( BREACH.TranslateString(entity.PrintName) )
			uniform_name:SizeToContents()
			uniform_name:SetPos(uniform:GetWide()/2-uniform_name:GetWide()/2, 5)

			local uniform_image = vgui.Create("DPanel", uniform)
			uniform_image:SetPos(10, uniform:GetTall()-134)
			uniform_image:SetSize(124,124)

			if entity.InvIcon then
				uniform_image.Icon = entity.InvIcon
			else
				uniform_image.Icon = missingicon
			end

			uniform_image.Paint = function(self, w, h)
				surface.SetDrawColor(color_white)
				surface.SetMaterial(self.Icon)
				surface.DrawTexturedRect(0,0,w,h)
			end

		end

	end

	if BREACH.AdminLogs._DeepInfoCache[deep_info] then

		if IsValid(BREACH.AdminLogs.UI.deep_info_loading) then
			BREACH.AdminLogs.UI.deep_info_loading:LoadData(BREACH.AdminLogs._DeepInfoCache[deep_info])
		end
		BREACH.AdminLogs.UI.deep_info_loading = nil

	else

		net.Start("ShLogs_ReceiveDEEPINFO")
		net.WriteUInt(deep_info, 32)
		net.SendToServer()

	end



end