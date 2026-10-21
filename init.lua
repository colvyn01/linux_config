-- ==========================================================================
-- === Core Settings ===
-- ==========================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.termguicolors = true
vim.opt.cursorline = true

-- ==========================================================================
-- === UI & Colors ===
-- ==========================================================================
local palette = {
  os_bg   = "#ffb86b",  -- light amber
  os_fg   = "#2b1408",  -- dark brown
  dir_bg  = "#e8743b",  -- burnt orange
  git_bg  = "#5a2e1a",  -- rust brown
  lang_bg = "#3b1f12",  -- dark chestnut
  time_bg = "#281610",  -- espresso
  time_fg = "#f2b27a",  -- soft peach
  text    = "#f2d9c0",  -- warm cream
  muted   = "#8a6a55",  -- dimmed brown for comments and line numbers
  red     = "#e0523a",
  gold    = "#f0a030",
}

-- Strip backgrounds to inherit terminal transparency, then apply palette colors
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        local set_hl = vim.api.nvim_set_hl

        -- Transparent base
        set_hl(0, "Normal",      { bg = "none", ctermbg = "none" })
        set_hl(0, "NormalFloat", { bg = "none", ctermbg = "none" })

        -- Line numbers: muted for other lines, bright amber for the current one
        set_hl(0, "LineNr", { fg = "#9c7a60", ctermfg = 137 })
        set_hl(0, "CursorLineNr", {
            fg = palette.os_bg, ctermfg = 215, bg = "none", ctermbg = "none", bold = true
        })

        -- Current line, selection, and search
        set_hl(0, "CursorLine", { bg = palette.lang_bg })
        set_hl(0, "Visual",     { bg = palette.git_bg })
        set_hl(0, "Search",     { fg = palette.os_fg, bg = palette.gold })
        set_hl(0, "IncSearch",  { fg = palette.os_fg, bg = palette.dir_bg })

        -- Popup menu
        set_hl(0, "Pmenu",    { fg = palette.text, bg = palette.lang_bg })
        set_hl(0, "PmenuSel", { fg = palette.os_fg, bg = palette.dir_bg })

        -- Comments
        set_hl(0, "Comment", { fg = palette.muted, italic = true })
    end,
})

-- Use Neovim's default theme as the base; the autocmd above layers the palette on top
vim.cmd("colorscheme default")

-- Lualine theme built from the same palette
-- (a = mode block, b = middle block, c = background strip)
local function lualine_mode(accent)
  return {
    a = { fg = palette.os_fg,   bg = accent,           gui = "bold" },
    b = { fg = palette.dir_bg,  bg = palette.git_bg },
    c = { fg = palette.time_fg, bg = palette.time_bg },
  }
end

local lualine_theme = {
  normal   = lualine_mode(palette.dir_bg),
  insert   = lualine_mode(palette.os_bg),
  visual   = lualine_mode(palette.gold),
  replace  = lualine_mode(palette.red),
  command  = lualine_mode(palette.time_fg),
  inactive = {
    a = { fg = palette.time_fg, bg = palette.lang_bg },
    b = { fg = palette.muted,   bg = palette.lang_bg },
    c = { fg = palette.muted,   bg = palette.time_bg },
  },
}

-- ==========================================================================
-- === Plugin Manager (lazy.nvim) ===
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================================================
-- === Plugin Setup ===
-- ==========================================================================
require("lazy").setup({

  -- UI: Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = { theme = lualine_theme },
    },
  },

  -- Syntax: Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      -- Use git instead of curl/tar to avoid extraction errors
      require("nvim-treesitter.install").prefer_git = true

        require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "lua", "vim", "vimdoc", "query",
          "bash", "python", "javascript", "html", "css"
        },
        ignore_install = { "latex" },
        auto_install = true,
        highlight = {
          enable = true,
          disable = { "latex" },
          additional_vim_regex_highlighting = { "latex" },
        },
        indent = { enable = true },
      })
    end,
  },

  -- LaTeX: VimTeX
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "brave"
      vim.g.vimtex_view_general_options = "--new-window @pdf"
      vim.g.vimtex_quickfix_mode = 0
    end,
  },

})
