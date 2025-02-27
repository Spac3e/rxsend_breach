-- code was kindfully written by the developer of VAULT (oh, now it's called Monix, how unfortunate, now i wonder, why did he got kicked from VAULT out of a sudden?) Breach developer spac3

BREACH = BREACH || {}
BREACH.AdminLogs = BREACH.AdminLogs || {}
BREACH.AdminLogs.UI = BREACH.AdminLogs.UI || {}

local initiator_color = Color(193, 24, 24)
local victim_color = Color(0,128,255)

local dead_color = Color(255,0,0)

local v_col = Color(0,0,0,100)
local v_r = Material("vgui/gradient-r")
local v_l = Material("vgui/gradient-l")
local v_u = Material("vgui/gradient-u")
local v_d = Material("vgui/gradient-d")

function BREACH.AdminLogs.UI:CreateProgress(progress, summ)

	local pgr = vgui.Create("DPanel")
	pgr.draws = {}

	function pgr:UpdateInfoSize()
		self.draws = {}
		local offs = 0
		local a_summ = 0
		for i, pr in pairs(progress) do


			local _w = math.floor(pgr:GetWide()*(pr.value/summ))
			if i == #progress then
				_w = self:GetWide()-a_summ
			else
				a_summ = a_summ + _w
			end

			table.insert(self.draws, {col = pr.color, x = offs, w = _w, value = pr.value, status = pr.status})
			offs = offs + _w

		end
	end

	pgr:UpdateInfoSize()

	pgr.Paint = function(self, w, h)

		for i = 1, #self.draws do
			local _v = self.draws[i]

			draw.RoundedBox(0,_v.x,0,_v.w,h,_v.col)

		end

		surface.SetDrawColor(v_col)
		surface.SetMaterial(v_r)
		surface.DrawTexturedRect(w/2,0,w/2,h)
		surface.SetMaterial(v_l)
		surface.DrawTexturedRect(0,0,w/2,h)

		surface.SetMaterial(v_u)
		surface.DrawTexturedRect(0,0,w,h/2)
		surface.SetMaterial(v_d)
		surface.DrawTexturedRect(0,h/2,w,h/2)

	end

	return pgr

end

function BREACH.AdminLogs.UI:CreateCombatPanel(initiator, victim, combat_data, x, y, w, h, parent, logdata)

	local CombatPanel = vgui.Create("DPanel", parent)

	CombatPanel:SetSize(w, h)
	CombatPanel:SetPos(x, y)

	local initiator_avatar = vgui.Create("AvatarImage", CombatPanel)

	initiator_avatar:SetSize(h-14, h-14)
	initiator_avatar:SetPos(7,7)

	initiator_avatar:SetSteamID(initiator.sid64, 184)

	local col_shadow = Color(0,0,0,250)

	local _dead = L"l:shlogs_dead"

	local function paint_avatar(self, w, h, col, col2)


		if self.dead then
			surface.SetDrawColor(col_shadow)
			surface.SetMaterial(v_d)
			surface.DrawTexturedRect(0,h-20-h/2,w,h/2)

			draw.RoundedBox(0,0,h-20,w,20,col_shadow)

			draw.DrawText(_dead, "shlog_log_text", w/2, h-20, col2, TEXT_ALIGN_CENTER)
		end


		surface.SetDrawColor(col)
		surface.DrawOutlinedRect(0,0,w,h,1)
	end

	initiator_avatar.PaintOver = function(self, w, h)

		paint_avatar(self, w, h, initiator_color, victim_color)

	end

	local victim_avatar = vgui.Create("AvatarImage", CombatPanel)

	victim_avatar:SetSize(h-14, h-14)
	victim_avatar:SetPos(w-7-victim_avatar:GetWide(),7)

	victim_avatar:SetSteamID(victim.sid64, 184)

	victim_avatar.PaintOver = function(self, w, h)

		paint_avatar(self, w, h, victim_color, initiator_color)

	end

	

	local linewide = 1
	local linetall = 12

	CombatPanel.Paint = function(self, w, h)

		if !self.c1 then
			self.c1 = ColorAlpha(initiator_color,25)
			self.c2 = ColorAlpha(victim_color,25)
		end

		draw.RoundedBox(0,0,0,w,h,ColorAlpha(color_black,100))

		surface.SetDrawColor(self.c1)
		surface.SetMaterial(v_l)
		surface.DrawTexturedRect(0,0,w/1.8,h)

		surface.SetDrawColor(self.c2)
		surface.SetMaterial(v_r)
		surface.DrawTexturedRect(w/2.2,0,w/1.8,h)

		draw.RoundedBox(0,0,0,linetall,linewide, initiator_color)
		draw.RoundedBox(0,0,0,linewide,linetall, initiator_color)

		draw.RoundedBox(0,w-linetall,0,linetall,linewide, victim_color)
		draw.RoundedBox(0,w-linewide,0,linewide,linetall, victim_color)

		draw.RoundedBox(0,0,h-linewide,linetall,linewide, initiator_color)
		draw.RoundedBox(0,0,h-linetall,linewide,linetall, initiator_color)

		draw.RoundedBox(0,w-linetall,h-linewide,linetall,linewide, victim_color)
		draw.RoundedBox(0,w-linewide,h-linetall,linewide,linetall, victim_color)

	end

	local progress = {}

	local summ = 0

	for _, v in pairs(combat_data) do
		if v.damage then
			local damage = math.floor(v.damage)

			summ = summ + damage

			local col = victim_color

			if v.initiator then col = initiator_color end

			table.insert(progress, {
				color = col,
				value = damage,
				status = v.status,
			})

		end

		
		if isnumber(v.status) then

			if v.status == SHLOG_COMBAT_STATUS_INITIATOR_DEAD then
				initiator_avatar.dead = true
			else
				victim_avatar.dead = true
			end

		end
	end

	local pgr_bg = vgui.Create("DPanel", CombatPanel)
	pgr_bg:SetSize(w-(initiator_avatar:GetWide()+15)*2, 30)
	pgr_bg:SetPos(initiator_avatar:GetWide()+15, h*0.5)

	pgr_bg.Paint = function(self, w, h)

		draw.RoundedBox(0,0,0,w,h,color_black)

	end

	local pgr = BREACH.AdminLogs.UI:CreateProgress(progress, summ)

	pgr:SetParent(pgr_bg)
	pgr:SetSize(pgr_bg:GetWide() - 4, pgr_bg:GetTall() - 4)
	pgr:SetPos(2, 2)

	pgr:UpdateInfoSize()

	local text = BREACH.AdminLogs.UI:CreateRichText({
		BREACH.AdminLogs:NiceTextPlayer(initiator),
		" vs ",
		BREACH.AdminLogs:NiceTextPlayer(victim),
	}, 0, 0, CombatPanel:GetWide()/1.6, 30, CombatPanel)

	text:SetPos(CombatPanel:GetWide()*.09, 10)

	local l_id = 0

	local last

	for i, v in pairs(pgr.draws) do
		l_id = l_id + 1
		local btn = vgui.Create("DButton", pgr)

		btn:SetSize(v.w, pgr:GetTall())
		btn:SetPos(v.x, 0)
		btn:SetText("")

		btn.id = l_id

		btn.damage = v.value

		btn.hoverlerp = 0

		btn.Paint = function(self, w, h)

			if self:IsHovered() then
				self.hoverlerp = math.Approach(self.hoverlerp, 1, FrameTime()*3)
			else
				self.hoverlerp = math.Approach(self.hoverlerp, 0, FrameTime()*10)
			end

			if self.hoverlerp > 0 then
				draw.RoundedBox(0,0,0,w,h,ColorAlpha(color_white, self.hoverlerp*100))

				if v.status then
					draw.DrawText("DEATH", "shlog_log_text", w/2, 5, ColorAlpha(color_black, self.hoverlerp*255), TEXT_ALIGN_CENTER)
				else
					draw.DrawText(self.damage, "shlog_log_text", w/2, 5, ColorAlpha(color_black, self.hoverlerp*255), TEXT_ALIGN_CENTER)
				end
			end

		end

		btn.DoClick = function(self)
			BREACH.AdminLogs:LoadSnapshot(logdata.id, self.id)
		end

	end


end