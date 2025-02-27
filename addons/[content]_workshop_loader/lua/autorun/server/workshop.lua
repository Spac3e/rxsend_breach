local addones = {

	{id = "3074046594", name = "animations"},
	{id = "3074010797", name = "characters"},
	{id = "3074027601", name = "client"},
	{id = "3074041351", name = "heads"},
	{id = "3074044716", name = "items"},
	{id = "3074023535", name = "map_content"},
	{id = "3074042729", name = "items"}, //misc
	{id = "3074029785", name = "scp"},
	{id = "3074017057", name = "weapons"},
	{id = "3074052619", name = "map"},
	{id = "3074036709", name = "faces"},
	{id = "3350080560", name = "bgm"},
	{id = "3351789901", name = "173"},
	{id = "692549430", name = "bomb_vest"},
	{id = "757604550", name = "wos"},
	{id = "2871239513", name = "battering_ram"},
	{id = "785294711", name = "taser"},
	{id = "3372455195", name = "uiu_cont"},	
	{id = "3388440888", name = "soundpack"},
	{id = "3372909026", name = "sl"},
	{id = "2902543376", name = "qcw"},	
	{id = "3398869603", name = "035"},
}

for _, v in pairs(addones) do
	print("[RXSEND Content] MOUNTING \""..v.name.."\"")
	resource.AddWorkshop(v.id)
end