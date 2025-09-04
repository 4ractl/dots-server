return {
	"norcalli/nvim-colorizer.lua",
	config = function()
		require("colorizer").setup({
			-- Enable colorizer for all file types, or change the pattern as desired.
			"*",
			-- You can provide additional options here. For example:
			-- RGB      = true,   -- #RGB hex codes
			-- RRGGBB   = true,   -- #RRGGBB hex codes
			-- names    = false,  -- "Name" codes
			-- RRGGBBAA = true,   -- #RRGGBBAA hex codes
			-- AARRGGBB = true,   -- 0xAARRGGBB hex codes
			-- css      = true,   -- Enable all CSS features: rgb(), rgba(), hsl(), hsla()
			-- css_fn   = true,   -- Enable all CSS functions: calc(), min(), max(), clamp()
		})
	end,
}
