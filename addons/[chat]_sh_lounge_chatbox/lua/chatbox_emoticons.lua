/**
* Derma Emoticons 
**/

-- Enable Derma emoticons?
-- You can see the full list here: http://www.famfamfam.com/lab/icons/silk/previews/index_abc.png
LOUNGE_CHAT.EnableDermaEmoticons = true

-- Restrict Derma emoticons?
-- You can configure the restrictions in the "DermaEmoticonsRestrictions" option.
-- "false" means derma emoticons can be used by anyone.
LOUNGE_CHAT.RestrictDermaEmoticons = true

-- Here you can decide on restrictions for players to be able to use Derma emoticons in their messages.
-- Only works if the "RestrictDermaEmoticons" option is set to true
LOUNGE_CHAT.DermaEmoticonsRestrictions = {
	-- This means only admins, superadmins and players with the specific SteamID/SteamID64 can use Derma emoticons.
	usergroups = {"headadmin", "superadmin", "spectator", "admin", "premium"},
	--steamids = {"STEAM_0:1:8039869", "76561197976345467"}
}

/**
* Custom Emoticons 
**/

-- Add your custom emoticons here!
-- Two examples are provided for you to copy.
LOUNGE_CHAT.CustomEmoticons = {
	-- This creates a "grin" emoticon with the material "vgui/face/grin"
	["breachisreal3"] = {
		url = "https://i.imgur.com/CkNwlxh.png",
		w = 70/1.6,
		h = 112/1.6,
	},
	["breachisreal2"] = {
		url = "https://i.imgur.com/WxL74l6.png",
		w = 192/2,
		h = 108/2,
	},
	["breachisreal"] = {
		url = "https://i.imgur.com/iwwCuCf.png",
		w = 44,
		h = 62,
	},
	["yeet"] = {
		url = "https://i.imgur.com/6ojDGvL.png",
		w = 22,
		h = 22,
	},
	["grin"] = {
		path = "vgui/face/grin",
		w = 64,
		h = 32,
	},

	-- This creates a "awesomeface" emoticon with the URL "http://i.imgur.com/YBUpyZg.png"
	["awesomeface"] = {
		url = "http://i.imgur.com/YBUpyZg.png",
		w = 32,
		h = 32,
	},

	// FA emoticons
	["kami"] = {
		url = "https://vgy.me/pzfz8k.png",
		w = 32,
		h = 32,
	},
	["chaika"] = {
		url = "http://i.imgur.com/h25fTDE.png",
		w = 32,
		h = 32,
	},
	["thatcat"] = {
		url = "http://i.imgur.com/00Xaj13.png",
		w = 32,
		h = 32,
	},
	["cuole"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/21cc6daaccc1366970c835ebfcda7e25.jpg",
		w = 200,
		h = 200,
	},
	["youmo"] = {
		url = "https://s1.imagehub.cc/images/2024/12/03/b144379db33ec950a147ba38bb1085f6.png",
		w = 500,
		h = 500,
	},
	["404"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/3bf6b51a6d4d3e502241290243c9885c.jpg",
		w = 90,
		h = 100,
	},
	["404aini"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/3d22765fc246efe7e125e37e4b6af960.jpg",
		w = 250,
		h = 80,
	},
	["cai"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/ca68cc37803a33bbb4d009a50d39e87c.jpg",
		w = 300,
		h = 100,
	},
	["999"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/591f8318b91af65a592119303b4d03ce.jpg",
		w = 250,
		h = 200,
	},
	["shijian"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/4bdb57e007716da7a317e3470a7c7578.jpg",
		w = 200,
		h = 250,
	},
	["xibao"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/3516fcc0dc96e27b1d55734172aa7642.jpg",
		w = 250,
		h = 150,
	},
	["tianji"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/c7b375ce4ee1484b1326481d4cb1be80.jpg",
		w = 300,
		h = 90,
	},
	["ai"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/fb82607dffb0cba1d2d71dae98393e95.jpg",
		w = 50,
		h = 55,
	},
	["qwq"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/a112d70b4730aafec7bd74437910d8a3.jpg",
		w = 200,
		h = 150,
	},
	["yijian"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/31c8fda4d92f94c58507f258b1996fbb.jpg",
		w = 200,
		h = 200,
	},
	["meicuo"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/6c9cecacfd2272402d2fab5b8a7fd40c.jpg",
		w = 200,
		h = 200,
	},
	["bukeyi"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/a5480945a11e9615e66aafbd854c9949.jpg",
		w = 200,
		h = 205,
	},
	["baka"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/1009d135de1b1a965a30a63aca9d3225.jpg",
		w = 200,
		h = 200,
	},
	["feiji"] = {
		url = "https://s1.imagehub.cc/images/2024/10/17/9a8cb06561de3c79eb1fcfc622e8ee67.jpg",
		w = 200,
		h = 200,
	},
	["chuquan"] = {
		url = "https://s1.imagehub.cc/images/2024/10/25/e76d62f1a7ecb2212eada4c744112dab.jpg",
		w = 200,
		h = 200,
	},
	["jue"] = {
		url = "https://s1.imagehub.cc/images/2024/10/25/95bfb7fa6199d01b2341de54e00d6056.jpg",
		w = 200,
		h = 200,
	},
	["cuowu"] = {
		url = "https://s1.imagehub.cc/images/2024/10/25/fb703d1cd1d196ad1f3ff60bd8199f7f.jpg",
		w = 200,
		h = 200,
	},
	["SHANGHAI"] = {
		url = "https://s1.imagehub.cc/images/2024/10/25/e1fe0cae0689d6eb6df57844b9f4d093.jpg",
		w = 200,
		h = 200,
	},
	["DUCK1"] = {
		url = "https://s1.imagehub.cc/images/2024/10/25/a074cd238f2d6a027447f026410d41ab.jpg",
		w = 200,
		h = 200,
	},
	["DDOS"] = {
		url = "https://s1.imagehub.cc/images/2024/10/25/aaea8be511cc7d3aa2bf45e71f7e9788.jpg",
		w = 250,
		h = 150,
	},
	["SH"] = {
		url = "https://s1.imagehub.cc/images/2024/10/25/464cb71ede6366698e17674df0faa99f.jpg",
		w = 200,
		h = 100,
	},
	["hao"] = {
		url = "https://s1.imagehub.cc/images/2024/10/26/636d9a1f1795cb3ab39ef96f226587d0.jpg",
		w = 200,
		h = 200,
	},
	["NMSL"] = {
		url = "https://s1.imagehub.cc/images/2024/10/26/a8a2837f3d6f451e269e3dc1420f2344.jpg",
		w = 200,
		h = 200,
	},
	["MAN"] = {
		url = "https://s1.imagehub.cc/images/2024/10/26/a7359da4de6c3b75e0d03aa636432a7c.jpg",
		w = 200,
		h = 200,
	},
	["WAN"] = {
		url = "https://s1.imagehub.cc/images/2024/10/26/420da902c3e5ebdb48f5554d01df49f1.jpg",
		w = 200,
		h = 200,
	},
	["chouka"] = {
		url = "https://s1.imagehub.cc/images/2024/10/26/6d34a226c8831466edc08c50ae6be796.jpg",
		w = 250,
		h = 250,
	},
	["MENU"] = {
		url = "https://s1.imagehub.cc/images/2024/11/10/76b4cf54be8bbaf7efc26a47119678cd.jpg",
		w = 250,
		h = 250,
	},
	["YYZ1"] = {
		url = "https://s1.imagehub.cc/images/2024/11/11/ff78ece388474394f0dabb62dc504b9e.jpg",
		w = 300,
		h = 100,
	},
	["YYZ2"] = {
		url = "https://s1.imagehub.cc/images/2024/11/10/d04167e56a266fef1c4f1a26b41423c6.jpg",
		w = 250,
		h = 250,
	},
	["PG"] = {
		url = "https://s1.imagehub.cc/images/2024/11/10/5eba98df5eda71189270d6083f0a1f30.jpg",
		w = 300,
		h = 100,
	},
	["luke1"] = {
		url = "https://s1.imagehub.cc/images/2024/11/10/36a5f631c48336b2b9a9b1b647ac405f.jpg",
		w = 250,
		h = 100,
	},
	["tianji"] = {
		url = "https://s1.imagehub.cc/images/2024/11/10/408a1ce9b2a5d2eb2594906a8d1ab455.jpg",
		w = 250,
		h = 250,
	},
	["pangB"] = {
		url = "https://s1.imagehub.cc/images/2024/11/10/c73dad4b7da0d8fcb830e3d886981b6e.jpg",
		w = 250,
		h = 250,
	},
	["OP"] = {
		url = "https://s1.imagehub.cc/images/2024/11/10/1cd4ba0a581d9883521fa5c0e4547fc4.jpg",
		w = 250,
		h = 100,
	},
	["PG2"] = {
		url = "https://s1.imagehub.cc/images/2024/11/26/4fa3ee6b4698102d6edb59b54a0d1b8f.jpg",
		w = 350,
		h = 200,
	},
	["zhishengji"] = {
		url = "https://s1.imagehub.cc/images/2024/10/18/fa6672806dd3a7a0d26a8ddf5ecbcd2f.png",
		w = 200,
		h = 200,
	}
}
-- Here you can decide whether an emoticon can only be used by a specific usergroup/SteamID
LOUNGE_CHAT.EmoticonRestriction = {
	-- This restricts the "awesomeface" emoticon so that it can only be used by:
	-- * "admin" and "superadmin" usergroups
	-- * players with the SteamID "STEAM_0:1:8039869" or SteamID64 "76561197976345467"
	["awesomeface"] = {
		usergroups = {"headadmin", "superadmin", "spectator", "admin", "premium"},
		--steamids = {"STEAM_0:1:8039869", "76561197976345467"}
	},
}

/**
* End of configuration
**/

LOUNGE_CHAT.Emoticons = {}

function LOUNGE_CHAT:RegisterEmoticon(id, path, url, w, h, restrict)
	self.Emoticons[id] = {
		path = path,
		url = url,
		w = w or 16,
		h = h or 16,
		restrict = restrict,
	}
end

if (LOUNGE_CHAT.EnableDermaEmoticons) then
	local fil = file.Find("materials/icon16/*.png", "GAME")
	for _, f in pairs (fil) do
		local restrict
		if (LOUNGE_CHAT.RestrictDermaEmoticons) then
			restrict = LOUNGE_CHAT.DermaEmoticonsRestrictions
		end

		LOUNGE_CHAT:RegisterEmoticon(string.StripExtension(f), "icon16/" .. f, nil, 16, 16, restrict)
	end
end

for id, em in pairs (LOUNGE_CHAT.CustomEmoticons) do
	LOUNGE_CHAT:RegisterEmoticon(id, em.path, em.url, em.w, em.h, LOUNGE_CHAT.EmoticonRestriction[id])
end