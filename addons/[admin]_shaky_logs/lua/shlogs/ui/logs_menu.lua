-- code was kindfully written by the most notorious, legendary and arousing programmer spac3

BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}
BREACH.AdminLogs.UI.Tips = BREACH.AdminLogs.UI.Tips || {}

BREACH.AdminLogs._Cache_Pages = BREACH.AdminLogs._Cache_Pages || {}

BREACH.AdminLogs.UI.SelectedType = BREACH.AdminLogs.UI.SelectedType || "none"

BREACH.RememberNames = BREACH.RememberNames || {}

local cl_shlogs_background = Color(27,27,27, 225)
local cl_shlogs_button = Color(168,0,0)

local gr_u = Material("vgui/gradient-d", "noclamp smooth")
local gr_b = Material("vgui/gradient-u", "noclamp smooth")

local gr_l = Material("vgui/gradient-l", "noclamp smooth")
local gr_r = Material("vgui/gradient-r", "noclamp smooth")

local loading_gui = Material("shlogs/loading.png", "noclamp smooth")
local bg_1 = Material("shlogs/bg_1.png", "noclamp smooth")
local bg_2 = Material("shlogs/bg_2.png", "noclamp smooth")
local cl_shlogs_logs_bg_color = Color(255,255,255,255)

BREACH.AdminLogs.CurrentLogs = BREACH.AdminLogs.CurrentLogs || {}

surface.CreateFont( "shlog_button_text", {
	font = "Univers LT Std 47 Cn Lt",
	size = 25,
	weight = 0,
	antialias = true,
	extended = true,
	shadow = false,
	outline = false,
})

surface.CreateFont( "shlog_log_text", {
	font = "Univers LT Std 47 Cn Lt",
	size = 19,
	weight = 0,
	antialias = true,
	extended = true,
	shadow = false,
	outline = false,
  
})

surface.CreateFont( "shlog_log_tip", {
	font = "Univers LT Std 47 Cn Lt",
	size = 18,
	weight = 0,
	antialias = true,
	extended = true,
	shadow = false,
	outline = false,
  
})

surface.CreateFont( "shlog_switch_text", {
	font = "Univers LT Std 47 Cn Lt",
	size = 22,
	weight = 0,
	antialias = true,
	extended = true,
	shadow = false,
	outline = false,
  
})

local particle = "[7]area_of_fog"
local particle_pos = Vector(0,0,0)
local particle_angle = Angle(0,0,0)

function BREACH.AdminLogs.UI:Tip(text, x, y, color)
	if !color then color = color_white end
	if !x and !y then x, y = gui.MousePos() y = y-20 end
	local tip = vgui.Create("DLabel")
	tip:SetFont("shlog_log_text")
	tip:SetTextColor(color)
	tip:SetText(text)
	tip:SizeToContents()

	tip:SetPos(x-tip:GetWide()/2, y)
	tip:MoveTo(tip:GetX(), y-100, 2, 0)
	tip:AlphaTo(0, 1, 0)

	tip.Think = function(self)
		self:MakePopup()
		self:SetMouseInputEnabled(false)
		self:SetKeyBoardInputEnabled(false)
	end

	timer.Simple(1, function()
		tip:Remove()
	end)
end

function BREACH.AdminLogs:CanAskForData()
	if self.UI._UI_LOGS.Logs.loading then return false end
	return true
end

function BREACH.AdminLogs:SwitchPage(page)

	if !self:CanAskForData() then return end

	if BREACH.AdminLogs._Cache_Pages[page] then
		BREACH.AdminLogs.UI._UI_LOGS.Logs:ClearLogs()
		BREACH.AdminLogs.UI:LoadLogs(BREACH.AdminLogs._Cache_Pages[page], page, self.UI._UI_LOGS.LowerPanel.Page_Switcher.pages)
		return
	end

	self.UI._UI_LOGS.Logs.loading = true
	BREACH.AdminLogs.UI._UI_LOGS.Logs:ClearLogs()

	BREACH.AdminLogs:SwtichPage(page, function(logs, page, pages)
		BREACH.AdminLogs.UI:LoadLogs(logs, page, pages)
	end)

end

function BREACH.AdminLogs.UI:CreateLogButton(name, log_class)

	local button = vgui.Create("DButton", self._UI_LOGS.ButtonList)

	local w, h = self._UI_LOGS.ButtonList:GetSize()

	button:SetSize(w-30, 35)

	button:SetText("")

	name = L(name)

	surface.SetFont("shlog_button_text")
	local _, align = surface.GetTextSize(name)

	local module = BREACH.AdminLogs:GetLogTypeModule(log_class)

	align = align/2

	local linewide = 1
	local linetall = 7

	button.alpha = 0.4
	local alphaspeed = 4


	button.Paint = function(self, w, h)

		if BREACH.AdminLogs.UI.SelectedType == log_class then
			self.alpha = math.Approach(self.alpha, 1, FrameTime()*alphaspeed)
		elseif self:IsHovered() then
			self.alpha = math.Approach(self.alpha, 0.8, FrameTime()*alphaspeed)
		else
			self.alpha = math.Approach(self.alpha, 0.4, FrameTime()*alphaspeed)
		end
	
		--draw.RoundedBox(0,0,0,w,h, module.color)

		local mdlcolor = ColorAlpha(module.color, self.alpha*255)

		draw.RoundedBox(0,0,0,linetall,linewide, mdlcolor)
		draw.RoundedBox(0,0,0,linewide,linetall, mdlcolor)

		draw.RoundedBox(0,w-linetall,0,linetall,linewide, mdlcolor)
		draw.RoundedBox(0,w-linewide,0,linewide,linetall, mdlcolor)

		draw.RoundedBox(0,0,h-linewide,linetall,linewide, mdlcolor)
		draw.RoundedBox(0,0,h-linetall,linewide,linetall, mdlcolor)

		draw.RoundedBox(0,w-linetall,h-linewide,linetall,linewide, mdlcolor)
		draw.RoundedBox(0,w-linewide,h-linetall,linewide,linetall, mdlcolor)

		surface.SetDrawColor(ColorAlpha(module.color, 25*self.alpha))
		surface.SetMaterial(gr_l)
		surface.DrawTexturedRect(-w/(2.3*self.alpha),0,w,h)

		surface.SetDrawColor(ColorAlpha(module.color, 25*self.alpha))
		surface.SetMaterial(gr_r)
		surface.DrawTexturedRect(w/(2.3*self.alpha),0,w,h)

		draw.DrawText(name, "shlog_button_text", w/2, h/2-align, ColorAlpha(color_white, self.alpha*255), TEXT_ALIGN_CENTER)

	end
	button.OnCursorEntered = function(self)
		surface.PlaySound(BREACH.AdminLogs.Sounds["hover"])
	end
	button.DoClick = function(self)
		if !BREACH.AdminLogs:CanAskForData() then return end
		BREACH.AdminLogs.UI.SelectedType = log_class
		BREACH.AdminLogs.UI._UI_LOGS.Logs:ClearLogs()
		BREACH.AdminLogs._Cache_Pages = {}
		surface.PlaySound(BREACH.AdminLogs.Sounds["click"])
		BREACH.AdminLogs:GetLogs(1, log_class, _, function(logs, page, pages)
			BREACH.AdminLogs.UI:LoadLogs(logs, page, pages)
		end)
	end

	return button

end

local function appearance(pnl, startx, starty)

	local savex, savey = pnl:GetPos()

	pnl:SetPos(startx, starty)

	pnl:MoveTo(savex, savey, 0.6, 0, 0.3)

end

function BREACH.AdminLogs.UI:OpenLogs()

	if !BREACH.AdminLogs:HaveAccess(LocalPlayer()) then return end

	BREACH.AdminLogs.UI.SelectedType = "none"

	local scrw, scrh = ScrW()*.85, ScrH()*.85

	for i, v in pairs(player.GetAll()) do
		BREACH.RememberNames[v:SteamID64()] = v:Name()
	end

	if IsValid(self._UI_LOGS) then self._UI_LOGS:Remove() end
	if IsValid(self._UI_LOGS_DFrame) then self._UI_LOGS_DFrame:Remove() end
	surface.PlaySound(BREACH.AdminLogs.Sounds["log_open"])
	self._UI_LOGS_DFrame = vgui.Create("DFrame")
	self._UI_LOGS_DFrame:SetAlpha(0)
	self._UI_LOGS_DFrame:AlphaTo(255, 0.3, 0)
	self._UI_LOGS_DFrame:MakePopup()
	self._UI_LOGS_DFrame:SetZPos(100)
	self._UI_LOGS_DFrame:SetSize(scrw, scrh+25)

	--лучше не придумал без оверрайда dframe.lua :D
	self._UI_LOGS_DFrame._Think = self._UI_LOGS_DFrame.Think
	self._UI_LOGS_DFrame.Think = function(self)
		self._Think(self)
		self:SetPos(math.Clamp(self:GetX(), 0, ScrW()-self:GetWide()), math.Clamp(self:GetY(), 0, ScrH()-self:GetTall()))
	end

	self._UI_LOGS_DFrame.Paint = function(self, w, h)
		draw.RoundedBox(0, 0,0, w, 25, color_black)
	end
	self._UI_LOGS_DFrame:Center()

	self._UI_LOGS_DFrame:SetTitle("Shaky Logs")

	self._UI_LOGS = vgui.Create("DPanel", self._UI_LOGS_DFrame)
	self._UI_LOGS:SetSize(scrw, scrh)
	self._UI_LOGS:SetPos(0,25)

	self._UI_LOGS.particle = CreateParticleSystemNoEntity( particle, Vector(0,0,0) )

	self._UI_LOGS.particle:StartEmission()
	self._UI_LOGS.particle:SetShouldDraw(false)

	function self._UI_LOGS:OnRemove()
		if IsValid(self.particle) then
			self.particle:StopEmissionAndDestroyImmediately()
		end
	end

	self._UI_LOGS.Paint = function(self, w, h)
		BREACH:Blur(self, 5)
		draw.RoundedBox(0,0,0,w,h,cl_shlogs_background)
		if self.particle then -- мразь украл со своего хл2рп
			local x, y = self:LocalToScreen( 0, 0 )
			cam.Start3D( particle_pos, particle_angle, 80, x, y, w, h, 5, 700 )
			self.particle:Render()
			cam.End3D()
		end
	end

	self._UI_LOGS.ButtonList = vgui.Create("DPanel", BREACH.AdminLogs.UI._UI_LOGS)
	self._UI_LOGS.ButtonList:SetSize(math.floor(scrw*.2), scrh)

	local bg_1_col = Color(255,255,255,50)

	self._UI_LOGS.ButtonList.Paint = function(self, w, h)
		surface.SetDrawColor(bg_1_col)
		surface.SetMaterial(bg_1)
		surface.DrawTexturedRect(0,0,w,h)
	end

	appearance(self._UI_LOGS.ButtonList, -self._UI_LOGS.ButtonList:GetWide()-50, 0)

	self._UI_LOGS.Logs = vgui.Create("DScrollPanel", BREACH.AdminLogs.UI._UI_LOGS)
	self._UI_LOGS.Logs:SetSize(scrw-self._UI_LOGS.ButtonList:GetWide(), scrh-50)
	self._UI_LOGS.Logs:SetPos(self._UI_LOGS.ButtonList:GetWide(), 0)

	local vbar = self._UI_LOGS.Logs:GetVBar()
	 function vbar:Paint(w, h)
	 end
	 function vbar.btnUp:Paint(w, h)
	 end
	 function vbar.btnDown:Paint(w, h)
	 end
	 function vbar.btnGrip:Paint(w, h)
	    surface.SetDrawColor(color_white)
	    surface.SetMaterial(gr_u)
	    surface.DrawTexturedRect(0, 0, w-3, h/2)
	    surface.SetMaterial(gr_b)
	    surface.DrawTexturedRect(0, h/2, w-3, h/2)
	end

	self._UI_LOGS.LowerPanel = vgui.Create("DPanel", BREACH.AdminLogs.UI._UI_LOGS)
	self._UI_LOGS.LowerPanel:SetSize(scrw-self._UI_LOGS.ButtonList:GetWide(), 50)
	self._UI_LOGS.LowerPanel:SetPos(self._UI_LOGS.ButtonList:GetWide(), scrh-50)
	local col = ColorAlpha(color_white, 125)
	self._UI_LOGS.LowerPanel.Paint = function(self, w, h)
		surface.SetDrawColor(col)
		surface.SetMaterial(bg_2)
		surface.DrawTexturedRect(0,0,w,h)
	end

	appearance(self._UI_LOGS.LowerPanel, self._UI_LOGS.LowerPanel:GetX(), scrh+self._UI_LOGS.LowerPanel:GetTall()+50)

	BREACH.AdminLogs.UI:CreateFilterButton(self._UI_LOGS.LowerPanel)

	self._UI_LOGS.LowerPanel.Page_Switcher = vgui.Create("DPanel", self._UI_LOGS.LowerPanel)
	self._UI_LOGS.LowerPanel.Page_Switcher:SetVisible(false)
	self._UI_LOGS.LowerPanel.Page_Switcher:SetSize(210, 33)
	self._UI_LOGS.LowerPanel.Page_Switcher:SetPos(self._UI_LOGS.LowerPanel:GetWide() - 220, self._UI_LOGS.LowerPanel:GetTall()/2-33/2)
	self._UI_LOGS.LowerPanel.Page_Switcher.Paint = function() end
	self._UI_LOGS.LowerPanel.Page_Switcher.pages = 1

	local TextEntry = vgui.Create( "DTextEntry", self._UI_LOGS.LowerPanel.Page_Switcher ) -- create the form as a child of frame
	self._UI_LOGS.LowerPanel.Page_Switcher.TextEntry = TextEntry
	TextEntry:SetSize(40, 23)
	TextEntry:SetText("1")
	TextEntry.page = 1
	TextEntry:SetUpdateOnType(true)

	TextEntry:SetPos(self._UI_LOGS.LowerPanel.Page_Switcher:GetWide()/2-TextEntry:GetWide()/2, 5)

	TextEntry.Paint = function(self, w, h)
		draw.RoundedBox(0,0,0,w,h,color_black)
		draw.DrawText(self:GetText(), "shlog_switch_text", w/2, 0, color_white, TEXT_ALIGN_CENTER)
	end

	TextEntry.OnGetFocus = function(self)
	    self:SetValue("")
	end
	TextEntry.OnChange = function(self)
		if tonumber(self:GetText()) == nil then
			self:SetText("")
		end
	end

	TextEntry.OnEnter = function(  )
		local num = tonumber(TextEntry:GetValue())

		if isnumber(num) then
			BREACH.AdminLogs:SwitchPage(math.Clamp(num, 1, self._UI_LOGS.LowerPanel.Page_Switcher.pages))
		end
	end

	for i = 1, 2 do

		local _t = self._UI_LOGS.LowerPanel.Page_Switcher:GetTable()

		local _b = vgui.Create("DButton", self._UI_LOGS.LowerPanel.Page_Switcher)
		local label = vgui.Create("DLabel", self._UI_LOGS.LowerPanel.Page_Switcher)
		label:SetFont("shlog_switch_text")
		label:SetText("1  /")
		if i == 2 then label:SetText("\\  1") end
		label:SetTextColor(color_white)
		_t["button"..i] = _b
		_t["label"..i] = label

		_b:SetSize(50, 33)
		if i == 2 then
			_b:SetPos(self._UI_LOGS.LowerPanel.Page_Switcher:GetWide()-_b:GetWide(), 0)
		end

		
		label:SizeToContents()

		if i == 1 then
			label:SetPos(_b:GetWide() + 10, self._UI_LOGS.LowerPanel.Page_Switcher:GetTall()/2-label:GetTall()/2)
		else
			label:SetPos(_b:GetX()-label:GetWide()-10, self._UI_LOGS.LowerPanel.Page_Switcher:GetTall()/2-label:GetTall()/2)
		end

		local text = "NEXT"

		if i == 1 then text = "PREV" end

		_b.DoClick = function()

			if i == 1 then
				BREACH.AdminLogs:SwitchPage(math.max(1, TextEntry.page - 1))
			else
				BREACH.AdminLogs:SwitchPage(math.min(self._UI_LOGS.LowerPanel.Page_Switcher.pages, TextEntry.page + 1))
			end

		end

		local b_color = Color(217, 217, 217)

		_b:SetText("")
		_b.Paint = function(self, w, h)
			draw.RoundedBox(0,0,0,w,h,b_color)
			draw.DrawText(text, "shlog_switch_text", w/2, 5, color_black, TEXT_ALIGN_CENTER)
		end

	end

	function self._UI_LOGS.LowerPanel:UpdateSwitcher(pages)
		self.Page_Switcher.pages = pages

		local prevsize = self.Page_Switcher.label2:GetWide()

		self.Page_Switcher.label2:SetText("\\  "..pages)
		self.Page_Switcher.label2:SizeToContents()

		local offs = (self.Page_Switcher.label2:GetWide() - prevsize)

		self.Page_Switcher:SetWide(self.Page_Switcher:GetWide() + offs)
		self.Page_Switcher:SetX(self.Page_Switcher:GetX() - offs)

		self.Page_Switcher.button2:SetPos(BREACH.AdminLogs.UI._UI_LOGS.LowerPanel.Page_Switcher:GetWide()-self.Page_Switcher.button2:GetWide(), 0)
		self.Page_Switcher.label2:SetX(self.Page_Switcher.button2:GetX()-self.Page_Switcher.label2:GetWide()-10)
	end

	function self._UI_LOGS.Logs:ClearLogs()
		self:Clear()--for _, panel in pairs(self:GetChildren()) do panel:Remove() end
		self.loading = true
	end

	self._UI_LOGS.clicker = vgui.Create("DPanel", self._UI_LOGS)-- чтобы можно было мышкой и клавой двигать, эффективнее метод не придумал
	self._UI_LOGS.clicker:SetSize(0,0)
	self._UI_LOGS.clicker.Paint = function() end
	self._UI_LOGS.clicker:MakePopup()

	self._UI_LOGS.Logs.Paint = function(self, w, h)
		if self.loading then
			surface.SetDrawColor(color_white)
			surface.SetMaterial(loading_gui)
			surface.DrawTexturedRectRotated(w/2, h/2, 35, 35, (RealTime() * 300) % 360)
		end
	end

	self._UI_LOGS.ButtonList.list = {}

	for _, log in pairs(BREACH.AdminLogs.RegisteredLogTypes) do
		local button = BREACH.AdminLogs.UI:CreateLogButton(log.name, log.class)
		button:SetPos(15, 15+button:GetTall()*#self._UI_LOGS.ButtonList.list+15*#self._UI_LOGS.ButtonList.list)
		table.insert(self._UI_LOGS.ButtonList.list, button)
	end

end

function BREACH.AdminLogs.UI:CreateLog(logdata)

	local offset = 20

	local logpanel = vgui.Create("DPanel", self._UI_LOGS.Logs:GetCanvas())

	logpanel:Dock(TOP)
	logpanel:SetSize(self._UI_LOGS.Logs:GetWide(), 50)

	local gridcol = ColorAlpha(color_white, 2)

	logpanel.Paint = function(self, w, h)
		if self.dogridcol then
			draw.RoundedBox(0,0,0,w,h,gridcol)
		end
	end

	if self.gridcolnext == 0 then
		self.gridcolnext = 1
	else
		self.gridcolnext = 0
		logpanel.dogridcol = true
	end

	local module = BREACH.AdminLogs:GetLogTypeModule(logdata.type)
	local text = L(module:GetText(logdata))

	text = string.Replace(text, ",", " ,") -- мда
	local current_text = string.Split(text, " ")

	table.insert(current_text, 1, {
			type = ShLogs_RT_date,
			date = logdata.date,
			round = logdata.round,
		})

	local nospaces = {}

	for i, v in pairs(current_text) do
		if v == "," and current_text[i-1] then
			nospaces[i-1] = true
		end
		if logdata[v] then
			local col = color_white
			if module.supa_colors and module.supa_colors[v] then col = module.supa_colors[v] end

			local text = "NULL"

			if isstring(logdata[v]) then

				text = logdata[v]

				local tab = string.Explode(" ", text)

				for d = 1, #tab do
					local datext = string.Replace(tab[d], " ", "")

					local value = {
						color = col,
						text = datext,
					}

					if istable(logdata[datext]) and logdata[datext].isply then

						value = BREACH.AdminLogs:NiceTextPlayer(logdata[datext])

					end

					if d == 1 then
						current_text[i] = value
					else
						table.insert(current_text, i+d-1, value)
					end
				end

				continue

			end
			current_text[i] = {
				color = col,
				text = text,
			}

			if logdata[v].isply then

				current_text[i] = BREACH.AdminLogs:NiceTextPlayer(logdata[v])

				current_text[i].onclick = function(panel, text_data)
					BREACH.AdminLogs:CreatePlayerData(logdata.id, logdata[v])
				end

				current_text[i].onrightclick = function(panel, text_data)

					local name = logdata[v].sid64

					if BREACH.RememberNames[logdata[v].sid64] then name = BREACH.RememberNames[logdata[v].sid64] end

					local menu = DermaMenu()

					menu:AddOption( name, function() end ):SetIcon("icon16/user.png")
					menu:AddSpacer()


					menu.Paint = function( self, w, h )

					  draw.RoundedBox( 0, 0, 0, w, h, ColorAlpha( color_black, 225 ) )

					end

					if logdata[v].hasnapshot then 
						menu:AddOption( L"l:shlogs_checksnapshot", function()

							BREACH.AdminLogs:LoadSnapshot(logdata.id)

						end ):SetIcon( "icon16/chart_bar.png" )

					end

					menu:AddOption( L"l:shlogs_close", function() end )
					menu:Open()

				end

			end

		end
	end

	for i = 1, #current_text - 1 do
		if isstring(current_text[i]) then
			if current_text[i] != " " and current_text[i].text != "" then
				if nospaces[i] then continue end
				current_text[i] = current_text[i] .. " "
			end
		elseif (istable(current_text[i]) and current_text[i].text) then
			if current_text[i].text != " " and current_text[i].text != "" then
				if nospaces[i] then continue end
				current_text[i].text = current_text[i].text.." "
			end
		end
	end

	local rtext_pan = BREACH.AdminLogs.UI:CreateRichText(current_text, 0, 0, logpanel:GetWide(), 5, logpanel)

	
	logpanel:SetTall(rtext_pan:GetTall()+offset)

	
end

function BREACH.AdminLogs.UI:CreateCombat(logdata)

	local offset = 20

	local logpanel = vgui.Create("DPanel", self._UI_LOGS.Logs:GetCanvas())

	logpanel:Dock(TOP)
	logpanel:SetSize(self._UI_LOGS.Logs:GetWide(), 120)

	local gridcol = ColorAlpha(color_white, 2)

	logpanel.Paint = function(self, w, h)

		if self.dogridcol then
			draw.RoundedBox(0,0,0,w,h,gridcol)
		end
	end

	if self.gridcolnext == 0 then
		self.gridcolnext = 1
	else
		self.gridcolnext = 0
		logpanel.dogridcol = true
	end

	local module = BREACH.AdminLogs:GetLogTypeModule(logdata.type)

	BREACH.AdminLogs.UI:CreateCombatPanel(logdata.initiator, logdata.victim, logdata.combat_data, 10, 30, logpanel:GetWide()-40, 80, logpanel, logdata)

	local rtext_pan = BREACH.AdminLogs.UI:CreateRichText({{type = ShLogs_RT_date, date = logdata.date, round = logdata.round}}, 10, 10, logpanel:GetWide(), 5, logpanel)
	
end

function BREACH.AdminLogs.UI:LoadLogs(tab, page, pages)
	--if true then return end
	self._UI_LOGS.Logs.loading = false

	self.gridcolnext = 0

	BREACH.AdminLogs._Cache_Pages[page] = tab

	self._UI_LOGS.LowerPanel.Page_Switcher:SetVisible(true)
	self._UI_LOGS.LowerPanel.Page_Switcher.TextEntry:SetText(tostring(page))
	self._UI_LOGS.LowerPanel.Page_Switcher.TextEntry.page = page

	self._UI_LOGS.LowerPanel:UpdateSwitcher(pages)

	if tab then

		for _, log in pairs(tab) do
			if log.combat_data then
				BREACH.AdminLogs.UI:CreateCombat(log)
			else
				BREACH.AdminLogs.UI:CreateLog(log)
			end
		end

	end
end

hook.Add( "OnPlayerChatCheck", "shlogs_openmenu", function( ply, strText, bTeam, bDead ) 
	strText = string.lower( strText )

	if ( strText:StartWith("!shlog" ) ) then
		if ply == LocalPlayer() and BREACH.AdminLogs:HaveAccess(ply) then
			LocalPlayer():ConCommand("shlogs_openmenu")
		end
		return true
	end
end )