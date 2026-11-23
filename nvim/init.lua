-- ==========================================================================
-- === Core Settings ===
-- ==========================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.mouse = 'a'
vim.opt.clipboard = "unnamedplus"
vim.opt.undofile = true
vim.opt.termguicolors = true
vim.opt.cursorline = true

-- ==========================================================================
-- === UI & Colors ===
-- ==========================================================================
local theme_name = os.getenv("NVIM_THEME") or "hacker"
local ok, palette = pcall(require, "themes." .. theme_name)
if not ok then palette = require("themes.hacker") end

-- Strip backgrounds to inherit terminal transparency, then apply palette colors
vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        local set_hl = vim.api.nvim_set_hl

        -- Transparent base
        set_hl(0, "Normal",      { bg = "none", ctermbg = "none" })
        set_hl(0, "NormalFloat", { bg = "none", ctermbg = "none" })

        -- Line numbers: muted for other lines, bright amber for the current one
        set_hl(0, "LineNr", { fg = palette.muted, ctermfg = 137 })
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

        -- Base text
        set_hl(0, "Normal", { fg = palette.text, bg = "none", ctermbg = "none" })

        -- Syntax: warm replacements for default green/blue
        set_hl(0, "String",         { fg = palette.honey })
        set_hl(0, "Character",      { fg = palette.honey })
        set_hl(0, "Number",         { fg = palette.gold })
        set_hl(0, "Boolean",        { fg = palette.gold })
        set_hl(0, "Constant",       { fg = palette.rose })
        set_hl(0, "Identifier",     { fg = palette.text })
        set_hl(0, "Function",       { fg = palette.os_bg })
        set_hl(0, "Statement",      { fg = palette.dir_bg, bold = true })
        set_hl(0, "Keyword",        { fg = palette.dir_bg, bold = true })
        set_hl(0, "Type",           { fg = palette.sand })
        set_hl(0, "Special",        { fg = palette.time_fg })
        set_hl(0, "Operator",       { fg = palette.copper })
        set_hl(0, "Delimiter",      { fg = palette.copper })
        set_hl(0, "PreProc",        { fg = palette.rose })
        set_hl(0, "@property",      { fg = palette.text })
        set_hl(0, "@variable",      { fg = palette.text })
        set_hl(0, "@variable.member", { fg = palette.text })
        set_hl(0, "@string.escape", { fg = palette.dir_bg })
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
  -- Navigation: Find files and search text
  {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("telescope").setup({})

      local builtin = require("telescope.builtin")

      vim.keymap.set("n", "<leader>ff", builtin.find_files,
        { desc = "Find files" })

      vim.keymap.set("n", "<leader>fg", builtin.live_grep,
        { desc = "Search text in project" })

      vim.keymap.set("n", "<leader>fb", builtin.buffers,
        { desc = "Find open buffers" })

      vim.keymap.set("n", "<leader>fh", builtin.help_tags,
        { desc = "Search help" })
    end,
  },

  -- UI: Window animations only
  {
    "nvim-mini/mini.animate",
    version = "*",
    opts = {
      cursor = { enable = false },
      scroll = { enable = false },
      resize = { enable = true },
      open = { enable = true },
      close = { enable = true },
    },
  },

  -- UI: Smooth scrolling
  {
    "karb94/neoscroll.nvim",
    opts = {
      easing = "sine",
    },
  },
  -- UI: Animated cursor
  {
    "sphamba/smear-cursor.nvim",
    opts = {},
  },

  -- UI: Show hex colors (#rrggbb) in their real color
  {
    "nvim-mini/mini.hipatterns",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local hipatterns = require("mini.hipatterns")
      hipatterns.setup({
        highlighters = {
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })
    end,
  },
  -- UI: Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = { theme = lualine_theme },
      sections = {
        lualine_a = {
          { 'mode', fmt = function(str) return ' ' .. str end }
        }
      }
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
          "bash", "python", "javascript", "html", "css", "kotlin"
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

-- ==========================================================================
-- === LSP ===
-- ==========================================================================
vim.lsp.config('kotlin_language_server', {
  cmd = { 'kotlin-language-server' },
  filetypes = { 'kotlin' },
  root_dir = function(bufnr, on_dir)
    local markers = { 'settings.gradle', 'settings.gradle.kts', 'build.gradle', 'build.gradle.kts', 'pom.xml', '.git' }
    local root = vim.fs.root(bufnr, markers)
    on_dir(root or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
  end,
})
vim.lsp.enable('kotlin_language_server')

vim.lsp.config('pyright', {
cmd = { 'pyright-langserver', '--stdio' },
filetypes = { 'python' },
root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', '.git' },
settings = {
  python = { analysis = { autoSearchPaths = true, useLibraryCodeForTypes = true } },
},
})

vim.lsp.config('ruff', {
cmd = { 'ruff', 'server' },
filetypes = { 'python' },
root_markers = { 'pyproject.toml', 'ruff.toml', '.git' },
})

vim.lsp.enable({ 'pyright', 'ruff' })
