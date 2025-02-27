-- code was kindfully provided by mastermind pac3

BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}

ShLogs_RT_button = 0
ShLogs_RT_date = 1
ShLogs_RT_player = 2

function BREACH.AdminLogs.UI:ExplodeText(text)
	local newtab = string.Explode(" ", text)

	for i, v in pairs(newtab) do
		if i != #newtab then
			v = v.." "
			newtab[i] = v
		end
	end

	return newtab
end

function BREACH.AdminLogs.UI:CreateRichText(text_info, x, y, w, h, parent, default_font, default_color)
	if isstring(text_info) then text_info = {text_info} end

	if !default_font then default_font = "shlog_log_text" end
	if !default_color then default_color = color_white end

	local richtext_panel = vgui.Create("DPanel", parent)
	richtext_panel:SetSize(w, h)
	richtext_panel:SetPos(x, y)

	richtext_panel.order = {}

	richtext_panel.Paint = function(self, w, h)  end

	surface.SetFont(default_font)
	local space_length = surface.GetTextSize(" ")

	for _, text in pairs(text_info) do

		local data_text = text
		local data_color = default_color
		local data_font = default_font

		if istable(text) then
			data_text = text.text
			if text.color then data_color = text.color end
		end

		if text.type == ShLogs_RT_date then
			data_text = os.date("%H:%M:%S ", text.date)
			if text.round then
				data_text = data_text.." | round "..text.round.." "
			end
			data_text = data_text.." "
			data_color = color_black
		end

		local labeltext = vgui.Create("DLabel", richtext_panel)
		labeltext:SetText(data_text)
		labeltext:SetTextColor(data_color)
		labeltext:SetFont(data_font)

		labeltext:SetMouseInputEnabled( true )

		if text.onclick or text.onrightclick then
			local button = vgui.Create("DButton", labeltext)
			button:SetText("")
			labeltext.b = button
			button.Paint = function() end
			button.DoClick = function() if !text.onclick then return end text.onclick(labeltext, text) end
			button.DoRightClick = function() if !text.onrightclick then return end text.onrightclick(labeltext, text) end
		end

		if text.type == ShLogs_RT_date then
			surface.SetFont(data_font)
			local ofset, _ = surface.GetTextSize(" ")
			labeltext.Paint = function(self, w, h)
				draw.RoundedBox(0,0,0,w-ofset,h,color_white)
			end
		end

		if text.background then
			labeltext.Paint = function(self, w, h)
				draw.RoundedBox(0,0,0,w,h,text.background)
			end
		end

		surface.SetFont(data_font)
		local tw, th = surface.GetTextSize(data_text)
		labeltext:SetSize(tw, th)
		if labeltext.b then labeltext.b:SetSize(tw, th) end

		table.insert(richtext_panel.order, labeltext)

	end

	function richtext_panel:PositionLabels(no_spacing)

		local offsetw, offseth = 0, 0
		local w = self:GetWide()
		local additiona_h = 0

		local first_offset_w = 0 -- for cool spacing effect :)

		for _, label in pairs(richtext_panel.order) do

			local dooffset = true
			additiona_h = label:GetTall()

			if !no_spacing and first_offset_w == 0 then first_offset_w = label:GetWide() end

			if offsetw + label:GetWide() > w-30 then
				offseth = offseth + label:GetTall()
				offsetw = first_offset_w
			end

			label:SetPos(offsetw, offseth)

			offsetw = offsetw + label:GetWide()

		end

		if offseth + additiona_h > self:GetTall() then
			self:SetTall(offseth + additiona_h)
		end

	end

	richtext_panel:PositionLabels()


	return richtext_panel

end

concommand.Add("shlog_richtext_Test", function()

	if IsValid(SHLOG_TEST_RT) then SHLOG_TEST_RT:Remove() return end

	SHLOG_TEST_RT = BREACH.AdminLogs.UI:CreateRichText({
		{
			type = ShLogs_RT_date,
			date = os.time(),
			round = 0,
		},
		"i like ",
		"to ",
		{
			color = Color(255,0,0),
			text = "have sex with your mom"
		},
		" have sex with your mom",
		" have sex with your mom",
		" have sex with your mom",
	}, 0, 0, 500, 30)

end)