-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system({
--     "git",
--     "clone",
--     "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git",
--     "--branch=stable", -- latest stable release
--     lazypath,
--   })
-- end
-- vim.opt.rtp:prepend(lazypath)
--
-- -- require("vim-options")
-- require("lazy").setup("plugins")

-- bootstrap lazy.nvim, LazyVim and your plugins
--
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")

-- Ensure that .org files are recognized with the org filetype
vim.cmd([[autocmd BufNewFile,BufRead *.org set filetype=org]])

require("config.lazy")

-- Configure Tokyonight theme
require("tokyonight").setup({
  style = "night", -- Use the "night" variant for a darker theme.
  -- Additional theme options can be added here if needed.
})

vim.cmd("colorscheme tokyonight-night")

-- Ensure that .org files are recognized with the org filetype
vim.cmd([[autocmd BufNewFile,BufRead *.org set filetype=org]])

require("config.lazy")

if vim.fn.has("clipboard") == 1 then
  vim.g.clipboard = {
    name = "wl-clipboard",
    copy = {
      ["+"] = "wl-copy",
      ["*"] = "wl-copy",
    },
    paste = {
      ["+"] = "wl-paste",
      ["*"] = "wl-paste",
    },
    cache_enabled = 0,
  }
end
