local tab = {}
tab.name = "TAB_WEPSTATS"
tab.id = 3
tab.text = "武器统计信息"
tab.switchToKey = "gm_showspare2"
tab.descOfStat = 1

if CLIENT then
	tab.callback = function(self)
		tab.descOfStat = 1
	end
	
	function tab:processKey(key, press)
		if key == "+attack" then
			if tab.descOfStat >= CustomizableWeaponry.statDisplay.totalCount then
				tab.descOfStat = 1
			else
				tab.descOfStat = math.Clamp(tab.descOfStat + 1, 1, CustomizableWeaponry.statDisplay.totalCount)
			end
			return true
		elseif key == "+attack2" then
			if tab.descOfStat == 1 then
				tab.descOfStat = CustomizableWeaponry.statDisplay.totalCount
			else	
				tab.descOfStat = math.Clamp(tab.descOfStat - 1, 1, CustomizableWeaponry.statDisplay.totalCount)
			end
			
			return true
		end
		
		return nil
	end
	
	function tab:drawFunc()
		CustomizableWeaponry.statDisplay:draw(wep, tab)
	end
end

CustomizableWeaponry.interactionMenu:addTab(tab)