BREACH = BREACH || {}

function BREACH:GetWeaponPatternDebug(weaponname, shots)

	if IsValid(BREACH.PanelPatterDebug) then BREACH.PanelPatterDebug:Remove() return end
	BREACH.PanelPatterDebug = vgui.Create("DPanel")

	local weapon = weapons.Get(weaponname)

	BREACH.PanelPatterDebug:SetSize(1000,500)

	local offset = 0

	local nextthink = 0
	BREACH.PanelPatterDebug.Think = function(self, w, h)
		if nextthink > CurTime() then return end
		nextthink = CurTime() + 0.1
		offset = offset + 1
	end

	BREACH.PanelPatterDebug:Center()

	BREACH.PanelPatterDebug.Paint = function(self, w, h)
	
		draw.RoundedBox(0,0,0,w,h,color_white)

		local points = {
		}

		for i = 1, shots do
			--print(i+offset, i)
			local pattern_y = util.SharedRandom( weaponname, weapon.Recoil_Yaw[1], weapon.Recoil_Yaw[2], i + offset )
			points["point_"..i] = {
				num = i,
				y = pattern_y,
			}

			table.SortByMember( points, "num", true )
		end

		local cury = w/2
		local curx = h

		local prevpos_x, prevpos_y = w/2, h

		for i = 1, shots do
			v = points["point_"..i]
			old = cury
			cury = cury + Lerp(math.ease.InOutCirc(math.max(0.1,i/shots)), 0, v.y*100)
			curx = curx - h/shots
			local num = v.num

			if num > 1 then
				surface.SetDrawColor(color_black)
				surface.DrawLine(cury, curx, prevpos_x, prevpos_y)
				prevpos_x, prevpos_y = cury, curx
			end

		end

		draw.DrawText("OFFSET: "..offset, "BudgetLabel", 0,0, color_white)-- draw.DrawText(string text, string font = DermaDefault, number x = 0, number y = 0, table color = Color( 255, 255, 255, 255 ), number xAlign = TEXT_ALIGN_LEFT)
		draw.DrawText("SEEDNAME: "..weaponname, "BudgetLabel", 0,15, color_white)

	end

end

concommand.Add("BREACH_test", function()

	BREACH:GetWeaponPatternDebug("BREACH_machinegun_ppsh", 71)

end)

function BREACH:CreateSaperMenu(bombs, x, y)

	if IsValid(BREACH.SaperMenu) then BREACH.SaperMenu:Remove() return end

	BREACH.SaperMenu = vgui.Create("DFrame")
	BREACH.SaperMenu:SetSize(200,200)
	BREACH.SaperMenu:MakePopup()
	BREACH.SaperMenu:Center()
	BREACH.SaperMenu:SetTitle("Сапер")

	local Difficulties = {
		{
			name = "Easy",
			x = 9,
			y = 9,
			bombs = 10
		},
		{
			name = "Medium",
			x = 15,
			y = 15,
			bombs = 25
		},
		{
			name = "hard",
			x = 20,
			y = 20,
			bombs = 50
		},
		{
			name = "HARDCORE",
			x = 30,
			y = 23,
			bombs = 100
		},
	}

	local buttonlist = vgui.Create("DPanel",BREACH.SaperMenu)

	buttonlist:SetSize(100,25+30*#Difficulties)
	buttonlist:SetPos(100-50,35)

	buttonlist.Paint = function(self, w, h)
		draw.RoundedBox(2,0,0,w,h,color_white)
		draw.DrawText("DIFFICULTY", "ChatFont", w/2, h-20, color_black, TEXT_ALIGN_CENTER)
	end

	for i, v in ipairs(Difficulties) do
		local botun = vgui.Create("DButton", buttonlist)
		botun:SetSize(90,25)
		botun:SetPos(5,5+30*(i-1))
		botun:SetText(v.name)
		botun.DoClick = function()
			BREACH.SaperMenu:GenerateSaper(v.bombs, v.x, v.y)
		end
	end

	function BREACH.SaperMenu:GenerateSaper(bombs, x, y)
		local saperpanel = vgui.Create("DPanel", self)
		saperpanel:SetSize(x*36+6, y*36+6)
		buttonlist:Remove()
		self:SetSize(x*36+16, y*36+41)
		saperpanel:SetPos(5,30)
		self:Center()

		local buttonlist = {}
		local bomblist = {}

		local bombstogive = bombs

		for iy = 1, y do

			for ix = 1, x do
				local data = {
					posx = 36*(ix-1),
					posy = 36*(iy-1),
					isbomb = false,
					nearbombamount = 0,
					panel = nil,
					hidden = true,
					marked = false,
				}
				bomblist["button_"..iy.."_"..ix] = data
			end

		end

		while bombstogive != 0 do

			local picked = "button_"..math.random(1, y).."_"..math.random(1, x)

			if bomblist[picked].isbomb then continue end

			bomblist[picked].isbomb = true
			bombstogive = bombstogive - 1

		end

		for iy = 1, y do

			for ix = 1, x do
				if bomblist["button_"..iy.."_"..ix].isbomb then continue end

				if bomblist["button_"..(iy+1).."_"..ix] and bomblist["button_"..(iy+1).."_"..ix].isbomb then
					bomblist["button_"..iy.."_"..ix].nearbombamount = bomblist["button_"..iy.."_"..ix].nearbombamount + 1
				end
				if bomblist["button_"..(iy+1).."_"..(ix+1)] and bomblist["button_"..(iy+1).."_"..(ix+1)].isbomb then
					bomblist["button_"..iy.."_"..ix].nearbombamount = bomblist["button_"..iy.."_"..ix].nearbombamount + 1
				end
				if bomblist["button_"..iy.."_"..(ix+1)] and bomblist["button_"..iy.."_"..(ix+1)].isbomb then
					bomblist["button_"..iy.."_"..ix].nearbombamount = bomblist["button_"..iy.."_"..ix].nearbombamount + 1
				end

				if bomblist["button_"..(iy-1).."_"..ix] and bomblist["button_"..(iy-1).."_"..ix].isbomb then
					bomblist["button_"..iy.."_"..ix].nearbombamount = bomblist["button_"..iy.."_"..ix].nearbombamount + 1
				end

				if bomblist["button_"..(iy-1).."_"..(ix-1)] and bomblist["button_"..(iy-1).."_"..(ix-1)].isbomb then
					bomblist["button_"..iy.."_"..ix].nearbombamount = bomblist["button_"..iy.."_"..ix].nearbombamount + 1
				end

				if bomblist["button_"..iy.."_"..(ix-1)] and bomblist["button_"..iy.."_"..(ix-1)].isbomb then
					bomblist["button_"..iy.."_"..ix].nearbombamount = bomblist["button_"..iy.."_"..ix].nearbombamount + 1
				end

				if bomblist["button_"..(iy-1).."_"..(ix+1)] and bomblist["button_"..(iy-1).."_"..(ix+1)].isbomb then
					bomblist["button_"..iy.."_"..ix].nearbombamount = bomblist["button_"..iy.."_"..ix].nearbombamount + 1
				end
				if bomblist["button_"..(iy+1).."_"..(ix-1)] and bomblist["button_"..(iy+1).."_"..(ix-1)].isbomb then
					bomblist["button_"..iy.."_"..ix].nearbombamount = bomblist["button_"..iy.."_"..ix].nearbombamount + 1
				end

			end

		end

		local colors = {
			[1] = Color(0,255,0),
			[2] = Color(0,255,255),
			[3] = Color(255,0,0),
			[4] = Color(255,0,0),
			[5] = Color(255,0,0),
			[6] = Color(255,0,0),
			[7] = Color(255,0,0),
			[8] = Color(255,0,0),
		}

		local hiddenbox = Color(25,25,25)
		local nothidden = Color(215,215,215)
		local bombicon = Material("icon16/bomb.png")
		local markicon = Material("icon16/flag_red.png")

		for iy = 1, y do

			for ix = 1, x do
				local botun = vgui.Create("DButton", saperpanel)
				bomblist["button_"..iy.."_"..ix].panel = botun
				botun:SetSize(30,30)
				botun:SetText("")

				function botun:TakeNearClearChunks()
					local checkx, checky = 1, 0
					if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden and !bomblist["button_"..iy+checkx.."_"..ix+checky].isbomb then
						bomblist["button_"..iy+checkx.."_"..ix+checky].panel.DoClick(bomblist["button_"..iy+checkx.."_"..ix+checky].panel, bomblist["button_"..iy+checkx.."_"..ix+checky].nearbombamount > 0)
					end
					checkx, checky = -1, 0
					if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden and !bomblist["button_"..iy+checkx.."_"..ix+checky].isbomb then
						bomblist["button_"..iy+checkx.."_"..ix+checky].panel.DoClick(bomblist["button_"..iy+checkx.."_"..ix+checky].panel, bomblist["button_"..iy+checkx.."_"..ix+checky].nearbombamount > 0)
					end
					checkx, checky = 0, 1
					if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden and !bomblist["button_"..iy+checkx.."_"..ix+checky].isbomb then
						bomblist["button_"..iy+checkx.."_"..ix+checky].panel.DoClick(bomblist["button_"..iy+checkx.."_"..ix+checky].panel, bomblist["button_"..iy+checkx.."_"..ix+checky].nearbombamount > 0)
					end
					checkx, checky = 0, -1
					if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden and !bomblist["button_"..iy+checkx.."_"..ix+checky].isbomb then
						bomblist["button_"..iy+checkx.."_"..ix+checky].panel.DoClick(bomblist["button_"..iy+checkx.."_"..ix+checky].panel, bomblist["button_"..iy+checkx.."_"..ix+checky].nearbombamount > 0)
					end
				end
				--[[
				if bomblist["button_"..iy.."_"..ix].isbomb then
					botun:SetText("BOMB")
				elseif bomblist["button_"..iy.."_"..ix].nearbombamount > 0 then
					botun:SetText(bomblist["button_"..iy.."_"..ix].nearbombamount)
				else
					botun:SetText("")
				end--]]

				function botun:GetNearbies()
					local checkx, checky = 1, 0
					local checklist = {}
						if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden then
							table.insert(checklist, bomblist["button_"..iy+checkx.."_"..ix+checky])
						end
						checkx, checky = 1, 1
						if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden then
							table.insert(checklist, bomblist["button_"..iy+checkx.."_"..ix+checky])
						end
						checkx, checky = 0, 1
						if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden then
							table.insert(checklist, bomblist["button_"..iy+checkx.."_"..ix+checky])
						end

						checkx, checky = -1, 0
						if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden then
							table.insert(checklist, bomblist["button_"..iy+checkx.."_"..ix+checky])
						end
						checkx, checky = -1, -1
						if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden then
							table.insert(checklist, bomblist["button_"..iy+checkx.."_"..ix+checky])
						end
						checkx, checky = 0, -1
						if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden then
							table.insert(checklist, bomblist["button_"..iy+checkx.."_"..ix+checky])
						end

						checkx, checky = 1, 1
						if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden then
							table.insert(checklist, bomblist["button_"..iy+checkx.."_"..ix+checky])
						end
						checkx, checky = -1, -1
						if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden then
							table.insert(checklist, bomblist["button_"..iy+checkx.."_"..ix+checky])
						end
						checkx, checky = -1, 1
						if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden then
							table.insert(checklist, bomblist["button_"..iy+checkx.."_"..ix+checky])
						end
						checkx, checky = 1, -1
						if bomblist["button_"..iy+checkx.."_"..ix+checky] and bomblist["button_"..iy+checkx.."_"..ix+checky].hidden then
							table.insert(checklist, bomblist["button_"..iy+checkx.."_"..ix+checky])
						end
					return checklist
				end

				botun:SetText("")
				botun.DoClick = function(self, nocheck)
					if !bomblist["button_"..iy.."_"..ix].hidden and bomblist["button_"..iy.."_"..ix].nearbombamount > 0 then

						local checkx, checky = 1, 0
						local checklist = self:GetNearbies()
						local markedsum = 0

						for _, v in pairs(checklist) do
							print(v, v.marked)
							if v.marked then
								markedsum = markedsum + 1
							end
						end

						print(markedsum)

						if markedsum < bomblist["button_"..iy.."_"..ix].nearbombamount then
							return
						else
							for _, v in pairs(checklist) do
								if !v.marked then v.panel.DoClick(v.panel) end
							end
						end

						return
					end
					if colors[botun:GetText()] then
						botun:SetTextColor(colors[botun:GetText()])
					end
					bomblist["button_"..iy.."_"..ix].hidden = false
					if bomblist["button_"..iy.."_"..ix].isbomb then
						for _, tab in pairs(bomblist) do
							tab.hidden = false
						end
					end
					if !nocheck and !bomblist["button_"..iy.."_"..ix].isbomb and bomblist["button_"..iy.."_"..ix].nearbombamount <= 0 then self:TakeNearClearChunks() end
				end

				botun.DoRightClick = function(self)
					if !bomblist["button_"..iy.."_"..ix].hidden then return end
					bomblist["button_"..iy.."_"..ix].marked = !bomblist["button_"..iy.."_"..ix].marked
				end

				botun.Paint = function(self, w, h)
					local bgcolor = hiddenbox
					local tab = bomblist["button_"..iy.."_"..ix]

					if !tab.hidden then bgcolor = nothidden end

					local drawtext = false

					draw.RoundedBox(0,0,0,w,h,bgcolor)

					if !tab.hidden then
						if tab.isbomb then
							surface.SetDrawColor(255,255,255,255)
							surface.SetMaterial(bombicon)
							surface.DrawTexturedRect(7,7,15,15)

						elseif tab.nearbombamount > 0 then
							draw.DrawText(tostring(tab.nearbombamount), "ChatFont", w/2,h/2-5, colors[tab.nearbombamount], TEXT_ALIGN_CENTER)
						end
					else
						if tab.marked then

							surface.SetDrawColor(255,255,255,255)
							surface.SetMaterial(markicon)
							surface.DrawTexturedRect(7,7,15,15)

						end
					end

				end
				botun:SetPos(bomblist["button_"..iy.."_"..ix].posx+6, bomblist["button_"..iy.."_"..ix].posy+6)
			end

		end

		return saperpanel, saperpanel:GetSize()
	end

end

concommand.Add("br_saper", function()
	BREACH:CreateSaperMenu(12, 15, 15)
end)