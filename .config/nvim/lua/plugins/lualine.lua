return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = {
        normal = {
          a = { bg = "#1a1b26", fg = "#7aa2f7" },
          b = { bg = "#1a1b26", fg = "#7aa2f7" },
          c = { bg = "#1a1b26", fg = "#7aa2f7" },
          x = { bg = "#1a1b26", fg = "#565f89" },
          y = { bg = "#1a1b26", fg = "#565f89" },
          z = { bg = "#1a1b26", fg = "#565f89" },  -- Same bg as everything else
        },
        inactive = {
          a = { bg = "#1a1b26", fg = "#414868" },
          b = { bg = "#1a1b26", fg = "#414868" },
          c = { bg = "#1a1b26", fg = "#414868" },
          x = { bg = "#1a1b26", fg = "#414868" },
          y = { bg = "#1a1b26", fg = "#414868" },
          z = { bg = "#1a1b26", fg = "#414868" },
        }
      },
      component_separators = "",
      section_separators = "",
      globalstatus = true,
    },
    sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { 
        { "filename", path = 1 }
      },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {
        { "progress" }
      }
    },
    inactive_sections = {
      lualine_c = { "filename" },
      lualine_x = {},
    },
  }
}
