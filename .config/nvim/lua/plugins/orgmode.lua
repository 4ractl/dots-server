return {
  "nvim-orgmode/orgmode",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("orgmode").setup({
      org_agenda_files = { "~/base/sync/org/*" },
      org_default_notes_file = "~/base/sync/org/refile.org",
      -- Additional orgmode config
    })
  end,
}
