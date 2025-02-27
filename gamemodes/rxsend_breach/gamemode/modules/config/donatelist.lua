local DONATELIST = {}

DONATELIST.discount = 0

DONATELIST.levelprice = 1


local desc_premium = "l:desc_premium"
local desc_newbiekit = "l:desc_newbiekit"
local desc_activewarn = "l:desc_activewarn"
local desc_penalty = "l:desc_penalty"
local desc_unmute = "l:desc_unmute"
local desc_ungag = "l:desc_ungag"
local desc_unban = "l:desc_unban"

local desc_prefix = "l:desc_prefix"
local desc_prefix_rainbow = "l:desc_prefix_rainbow"

local desc_admin = "l:desc_admin"

DONATELIST.Info = "l:donate_paymenttype"

local levellistcockers = {

  function(n) return true, 1 end,


} -- :) pretty boie

function DonationGetDiscount(n)

  return math.Round(n * ((100-DONATELIST.discount)/100), 2)

end


function CalculateRequiredMoneyForLevel(currentlevel, amountoflevels)

  local total = 0

  for i = currentlevel + 1, currentlevel + amountoflevels do
    for d = 1, #levellistcockers do
      local f = levellistcockers[d]
      local v, mune = f(i)

      if v then
        total = total + mune
        break
      end

    end
  end

  return total

end

function CalculateNewbiekit(currentlevel)

  local priceforprem = GetDonationPrice("premium", 1)
  local priceforlevel = CalculateRequiredMoneyForLevel(currentlevel, 15)

  return math.Round((priceforprem + priceforlevel)*0.7, 2)

end

donate_pricetag = {
	["admin"] = 100,

	["premium"] = {
		5,
		8,
	},

	["awarn"] = 5,
	["penalty"] = 2,
	["newbiekit"] = CalculateNewbiekit,
	["level"] = CalculateRequiredMoneyForLevel,

	["prefix"] = {

		5,
		10,

	},

	["ungag"] = {
		5,
		10,
		20,
	},

	["unmute"] = {
		5,
		10,
		20,
	},

	["unban"] = {
		20,
		50,
		100,
	},


}

function GetDonationPrice(type, id, mylevel, level)

  if id == 0 then return 0 end

  local d = donate_pricetag[type]

  if isfunction(d) then
    return d(mylevel, level)
  end

  if istable(d) then
    return d[id]
  end

  return d

end

DONATELIST.categories = {
    {
      name = "l:donationtitle_prem",
      items = {
        {
          name = "30 l:donate_days",
          desc = desc_premium,
          price = GetDonationPrice("premium", 1)
        },
        {
          name = "60 l:donate_days",
          desc = desc_premium,
          price = GetDonationPrice("premium", 2)
        },
      },
    },


    {
      name = "l:donate_other",
      items = {
        {
          name = "l:donate_awarn",
          desc = desc_activewarn,
          price = GetDonationPrice("awarn")
        },
        {
          name = "l:donate_penalty",
          desc = desc_penalty,
          price = GetDonationPrice("penalty")
        },
        {
          name = "l:donate_newbiekit",
          desc = desc_newbiekit,
          price = function(mylevel) return CalculateNewbiekit(mylevel) end
        },

        {
          name = "l:donate_level",
          islevelcock = true,
          price = 0
        },
        {
          name = "45 l:donate_level",
          price = function(mylevel) return CalculateRequiredMoneyForLevel(mylevel, 45) end
        },

        {
          name = "l:donate_prefix",
          desc = desc_prefix,
          price = GetDonationPrice("prefix", 1)
        },
        {
          name = "l:donate_gradientprefix",
          desc = desc_prefix_rainbow,
          price = GetDonationPrice("prefix", 2)
        },
      },
    },

    {
      name = "l:donate_vcb",
      items = {
        {
          name = "l:donate_ltaw",
          desc = desc_ungag,
          price = GetDonationPrice("ungag", 1)
        },
        {
          name = "l:donate_mtaw",
          desc = desc_ungag,
          price = GetDonationPrice("ungag", 2)
        },
        {
          name = "l:donate_perma",
          desc = desc_ungag,
          price = GetDonationPrice("ungag", 3)
        },
      },
    },

    {
      name = "l:donate_cb",
      items = {
        {
          name = "l:donate_ltaw",
          desc = desc_unmute,
          price = GetDonationPrice("unmute", 1)
        },
        {
          name = "l:donate_mtaw",
          desc = desc_unmute,
          price = GetDonationPrice("unmute", 2)
        },
        {
          name = "l:donate_perma",
          desc = desc_unmute,
          price = GetDonationPrice("unmute", 3)
        },
      },
    },

    {
      name = "l:donate_gb",
      items = {
        {
          name = "l:donate_ltaw",
          desc = desc_unban,
          price = GetDonationPrice("unban", 1)
        },
        {
          name = "l:donate_mtaw",
          desc = desc_unban,
          price = GetDonationPrice("unban", 2)
        },

        {
          name = "l:donate_perma",
          desc = desc_unban,
          price = GetDonationPrice("unban", 3)
        },

      },
    },

}

return DONATELIST