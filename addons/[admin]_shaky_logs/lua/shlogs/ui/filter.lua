BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}

BREACH.AdminLogs.CurrentFilter = BREACH.AdminLogs.CurrentFilter || {Players = {}, round = 0}

local gr_l = Material("vgui/gradient-l", "noclamp smooth")
local gr_r = Material("vgui/gradient-r", "noclamp smooth")

local function drawlines(self, w, h)
	local mdlcolor = ColorAlpha(color_white, self.alpha*255)

	draw.RoundedBox(0,0,0,self.linetall,self.linewide, mdlcolor)
	draw.RoundedBox(0,0,0,self.linewide,self.linetall, mdlcolor)

	draw.RoundedBox(0,w-self.linetall,0,self.linetall,self.linewide, mdlcolor)
	draw.RoundedBox(0,w-self.linewide,0,self.linewide,self.linetall, mdlcolor)

	draw.RoundedBox(0,0,h-self.linewide,self.linetall,self.linewide, mdlcolor)
	draw.RoundedBox(0,0,h-self.linetall,self.linewide,self.linetall, mdlcolor)

	draw.RoundedBox(0,w-self.linetall,h-self.linewide,self.linetall,self.linewide, mdlcolor)
	draw.RoundedBox(0,w-self.linewide,h-self.linetall,self.linewide,self.linetall, mdlcolor)
end

local function drawbutton(self, w, h)
	if self:IsHovered() then
		self.alpha = math.Approach(self.alpha, 1, FrameTime()*self.alphaspeed)
	else
		self.alpha = math.Approach(self.alpha, 0.4, FrameTime()*self.alphaspeed)
	end

	drawlines(self, w, h)

	surface.SetDrawColor(ColorAlpha(color_white, 25*self.alpha))
	surface.SetMaterial(gr_l)
	surface.DrawTexturedRect(-w/(2.3*self.alpha),0,w,h)

	surface.SetDrawColor(ColorAlpha(color_white, 25*self.alpha))
	surface.SetMaterial(gr_r)
	surface.DrawTexturedRect(w/(2.3*self.alpha),0,w,h)

	draw.DrawText(self.Text, "shlog_button_text", w/2, h/2-self.align, color_white, TEXT_ALIGN_CENTER)
end

function BREACH.AdminLogs.UI:CreateFilterButton(panel)

	self._FilterPanel = vgui.Create("DPanel", panel)

	self._FilterPanel:SetSize(panel:GetWide()*0.3, panel:GetTall()-20)
	self._FilterPanel:SetPos(10, 10)
	self._FilterPanel.Paint = function() end

	self._FilterPanel.Button = vgui.Create("DButton", self._FilterPanel)
	self._FilterPanel.Button:SetSize(self._FilterPanel:GetSize())

	self._FilterPanel.Button.Text = L"l:shlogs_setfilter"

	self._FilterPanel.Button:SetText("")

	surface.SetFont("shlog_button_text")
	local _, align = surface.GetTextSize(self._FilterPanel.Button.Text)

	self._FilterPanel.Button.align = align/2

	self._FilterPanel.Button.linewide = 1
	self._FilterPanel.Button.linetall = 7

	self._FilterPanel.Button.alpha = 0.4
	self._FilterPanel.Button.alphaspeed = 4


	self._FilterPanel.Button.Paint = drawbutton
	self._FilterPanel.Button.OnCursorEntered = function(self)
		surface.PlaySound(BREACH.AdminLogs.Sounds["hover"])
	end
	self._FilterPanel.Button.DoClick = function(self)
		surface.PlaySound(BREACH.AdminLogs.Sounds["click"])
		BREACH.AdminLogs.UI:OpenFilterMenu()
	end

end

local col_bg = Color(27,27,27)

function BREACH.AdminLogs.UI:OpenFilterMenu()

	if IsValid(self.FilterMenu) then self.FilterMenu:Remove() end

	local currentfilter = table.Copy(BREACH.AdminLogs.CurrentFilter)

	local this = vgui.Create("DFrame", self._UI_LOGS_DFrame)

	this.Paint = function(self, w, h)
		draw.RoundedBox(0, 0,0, w, 25, color_white)
		draw.RoundedBox(0, 0,25, w, h-25, col_bg)
	end

	self.FilterMenu = this

	this:SetSize(300,self._UI_LOGS_DFrame:GetTall()*.8)

	this:SetPos(self._UI_LOGS_DFrame:GetWide()/2-this:GetWide()/2, self._UI_LOGS_DFrame:GetTall()/2-this:GetTall()/2)




	local playerlist = vgui.Create("DScrollPanel", this)

	playerlist:SetSize(this:GetWide()-20, this:GetTall()-60-110)
	playerlist:SetPos(10, 35)

	playerlist.FilterName = ""

	playerlist.Paint = function(self, w, h) end

	function playerlist:AddPlayer(sid64, isadd)

		local panel = vgui.Create("DPanel", self)
		panel:SetSize(0, 60)
		panel:Dock(TOP)
		panel:DockMargin( 0, 0, 0, 10 )

		panel.sid64 = sid64

		panel.linewide = 1
		panel.linetall = 7

		local clr = Color(0,255,0)

		self.isadd = isadd == true

		panel.Paint = function(self, w, h)

			local mdlcolor = color_white

			draw.RoundedBox(0,0,0,self.linetall,self.linewide, mdlcolor)
			draw.RoundedBox(0,0,0,self.linewide,self.linetall, mdlcolor)

			draw.RoundedBox(0,w-self.linetall,0,self.linetall,self.linewide, mdlcolor)
			draw.RoundedBox(0,w-self.linewide,0,self.linewide,self.linetall, mdlcolor)

			draw.RoundedBox(0,0,h-self.linewide,self.linetall,self.linewide, mdlcolor)
			draw.RoundedBox(0,0,h-self.linetall,self.linewide,self.linetall, mdlcolor)

			draw.RoundedBox(0,w-self.linetall,h-self.linewide,self.linetall,self.linewide, mdlcolor)
			draw.RoundedBox(0,w-self.linewide,h-self.linetall,self.linewide,self.linetall, mdlcolor)

			if isadd then
				draw.DrawText("+", "shlog_button_text", w-8, 0, clr, TEXT_ALIGN_RIGHT)
			end

		end

		local avatar = vgui.Create("AvatarImage", panel)
		avatar:SetSize(panel:GetTall()-10, panel:GetTall()-10)
		avatar:SetPos(5, 5)

		avatar:SetSteamID(sid64, 64)

		local text = vgui.Create("DLabel", panel)

		local name = sid64

		if BREACH.RememberNames[name] then
			if BREACH.RememberNames[sid64] and self.FilterName != "" and !string.lower(BREACH.RememberNames[sid64]):find(self.FilterName) then
				panel:Remove()
				return
			end
			name = BREACH.RememberNames[name]
		else
			steamworks.RequestPlayerInfo( name, function( steamName )
				BREACH.RememberNames[name] = steamName
				if BREACH.RememberNames[sid64] and self.FilterName != "" and !string.lower(BREACH.RememberNames[sid64]):find(self.FilterName) then
					if IsValid(panel) then panel:Remove() end
					return
				end
				text:SetText(steamName)
				text:SizeToContents()
			end )
		end

		text:SetFont("shlog_log_text")
		text:SetTextColor(color_white)
		text:SetText(name)
		text:SizeToContents()
		text:SetPos(avatar:GetX() + avatar:GetWide() + 10, panel:GetTall()/2-text:GetTall()/2)

		local butt = vgui.Create("DButton", panel)
		butt:Dock(FILL)

		butt:SetText("")
		butt.Paint = function() end

		butt.DoClick = function(self)

			if isadd then
				if !table.HasValue(currentfilter.Players, sid64) then
					table.insert(currentfilter.Players, sid64)
				end
			else
				table.RemoveByValue(currentfilter.Players, sid64)
			end

			playerlist:LoadCurrentFIlter()

		end

	end

	function playerlist:LoadCurrentFIlter()
		playerlist:Clear()
		if currentfilter.Players then
			local list = {}
			for i, v in pairs(currentfilter.Players) do
				table.insert(list, {id = v, name = BREACH.RememberNames[v]})
			end

			table.SortByMember(list, "name")

			for i, v in pairs(list) do
				playerlist:AddPlayer(v.id)
			end
		end
	end

	playerlist:LoadCurrentFIlter()

	this.Clear = vgui.Create("DButton", this)
	this.Clear:SetSize(this:GetWide()/3-20, 40)
	this.Clear.Text = "CLEAR"
	this.Clear:SetText("")
	surface.SetFont("shlog_button_text")
	local _, align = surface.GetTextSize(this.Clear.Text)
	this.Clear.align = align/2
	this.Clear.linewide = 1
	this.Clear.linetall = 7
	this.Clear.alpha = 0.4
	this.Clear.alphaspeed = 4
	this.Clear.Paint = drawbutton

	this.Clear:SetPos(10, this:GetTall()-50)

	this.Clear.OnCursorEntered = function(self)
		surface.PlaySound(BREACH.AdminLogs.Sounds["hover"])
	end
	this.Clear.DoClick = function(self)
		table.Empty(currentfilter)
		currentfilter.Players = {}
		currentfilter.round = 0
		this.RoundPicker.Trigger.CurValue = 0
		playerlist:LoadCurrentFIlter()
		surface.PlaySound(BREACH.AdminLogs.Sounds["click"])
	end


	this.RoundPicker = vgui.Create("DPanel", this)

	this.RoundPicker:SetSize(this:GetWide()-20, 40)
	this.RoundPicker:SetPos(10, playerlist:GetY()+playerlist:GetTall()+7+30)

	this.RoundPicker.Trigger = vgui.Create("DButton", this.RoundPicker)
	this.RoundPicker.Trigger:Dock(FILL)

	this.RoundPicker.Trigger:SetText("")
	this.RoundPicker.Trigger.Paint = function() end


	this.RoundPicker.Trigger.Activated = false

	this.RoundPicker.Trigger.CurValue = currentfilter.round

    this.RoundPicker.Trigger.OnMousePressed = function(self)
        self.savex, self.savey = gui.MousePos()
        self:SetCursor("blank")
        self.Activated = true

    end

    this.RoundPicker.Trigger.OnMouseReleased = function(self)
        self:SetCursor("hand")
        self.Activated = false
    end

    this.RoundPicker.Trigger.Think = function(self)
        if !self:IsHovered() and !input.IsMouseDown(MOUSE_LEFT) and self.Activated then self:OnMouseReleased() end
        if self.Activated then
    		self.CurValue = math.Clamp(self.CurValue - (self.savex - gui.MousePos())*0.01, 0, 10)
    		currentfilter.round = math.floor(self.CurValue)
        	gui.SetMousePos(self.savex, self.savey)
    	end
    end

    this.RoundPicker.alpha = 255
    this.RoundPicker.linewide = 1
    this.RoundPicker.linetall = 7

    this.RoundPicker.Paint = function(self, w, h)

    	drawlines(self, w, h)

    	local text = "l:shlogs_allrounds"

    	if self.Trigger.CurValue >= 1 then
    		text = "l:shlogs_round "..tostring(math.floor(self.Trigger.CurValue))
    	end


    	draw.DrawText(L(text), "shlog_log_text", w/2, 5, color_white, TEXT_ALIGN_CENTER)

   	end



	this.Add = vgui.Create("DButton", this)
	this.Add:SetSize(this:GetWide()/3-20, 40)
	this.Add.Text = "ADD"
	this.Add:SetText("")
	surface.SetFont("shlog_button_text")
	local _, align = surface.GetTextSize(this.Add.Text)
	this.Add.align = align/2
	this.Add.linewide = 1
	this.Add.linetall = 7
	this.Add.alpha = 0.4
	this.Add.alphaspeed = 4
	this.Add.Paint = drawbutton

	this.Add:SetPos(10+this:GetWide()/3, this:GetTall()-50)

	this.Add.OnCursorEntered = function(self)
		surface.PlaySound(BREACH.AdminLogs.Sounds["hover"])
	end
	this.Add.DoClick = function(self, forceful)
		if !forceful then surface.PlaySound(BREACH.AdminLogs.Sounds["click"]) end
		if playerlist.isadd and !forceful then
			playerlist:LoadCurrentFIlter()
			playerlist.isadd = false
			return
		end
		local list = {}
		for i, v in pairs(player.GetAll()) do
			if table.HasValue(currentfilter, v:SteamID64()) then continue end
			BREACH.RememberNames[v:SteamID64()] = v:Name()
			table.insert(list, {id = v:SteamID64(), name = BREACH.RememberNames[v:SteamID64()]})
		end

		if #list == 0 then return end

		playerlist:Clear()

		table.SortByMember(list, "name")

		for i, v in pairs(list) do
			playerlist:AddPlayer(v.id, true)
		end
	end

	this.Done = vgui.Create("DButton", this)
	this.Done:SetSize(this:GetWide()/3-20, 40)
	this.Done.Text = "DONE"
	this.Done:SetText("")
	surface.SetFont("shlog_button_text")
	local _, align = surface.GetTextSize(this.Done.Text)
	this.Done.align = align/2
	this.Done.linewide = 1
	this.Done.linetall = 7
	this.Done.alpha = 0.4
	this.Done.alphaspeed = 4
	this.Done.Paint = drawbutton

	this.Done:SetPos(this:GetWide()-10-this.Done:GetWide(), this:GetTall()-50)

	this.Done.OnCursorEntered = function(self)
		surface.PlaySound(BREACH.AdminLogs.Sounds["hover"])
	end
	this.Done.DoClick = function(self)
		surface.PlaySound(BREACH.AdminLogs.Sounds["click"])
		table.Empty(BREACH.AdminLogs.CurrentFilter)
		BREACH.AdminLogs.CurrentFilter = currentfilter

		net.Start("ShLogs_UpdateFilters")
		net.WriteTable(currentfilter)
		net.SendToServer()

		this:Remove()
	end

	this.TextEntry = vgui.Create( "DTextEntry", this )
	this.TextEntry:SetSize(this:GetWide()-20, 20)
	this.TextEntry:SetPos(10, playerlist:GetY()+playerlist:GetTall()+7)
	this.TextEntry.Think = function( self )
		local value = string.lower(self:GetValue())

		if value != playerlist.FilterName then
			playerlist.FilterName = string.lower(self:GetValue())
			if playerlist.isadd then
				this.Add.DoClick(this.Add, true)
			else
				playerlist:LoadCurrentFIlter()
			end
		end
	end





end


