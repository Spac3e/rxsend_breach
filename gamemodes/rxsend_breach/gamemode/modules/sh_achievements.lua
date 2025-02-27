function FindAchievementTableByName(name)

	for i = 1, #BreachAchievements.AchievementTable do
		local tab = BreachAchievements.AchievementTable[i]
		if tab.name == name then return tab end
	end

end