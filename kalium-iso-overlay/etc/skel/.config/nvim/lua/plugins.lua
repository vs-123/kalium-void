-------------
-- PLUGINS --
-------------

vim.cmd([[
call plug#begin()
Plug 'folke/lazydev.nvim'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/nvim-cmp'
Plug 'neovim/nvim-lspconfig'
Plug 'godlygeek/tabular'
Plug 'Sang-it/fluoride'
Plug 'vs-123/royal-hemlock-nvim'
call plug#end()
]])

-----------
--  LSP  --
-----------

vim.lsp.config.clangd = {
   root_markers = { '.git' },
   filetypes = { 'c' },
}

vim.lsp.enable('clangd')

vim.lsp.config.cmake = {
   cmd = { 'cmake-language-server' },
   root_markers = { 'CMakeLists.txt' },
   filetypes = { 'cmake' }
}

vim.lsp.enable('cmake')

-- SETUP FOR NEOVIM'S LUA
require("lazydev").setup({
   library = {
      "~/.local/share/nvim/plugged",
   },
})

vim.lsp.config.lua_ls = {
   cmd = { 'lua-language-server' },
   root_markers = { 'init.lua', '.git' },
   filetypes = { 'lua' },
   settings = {
      Lua = {
         telemetry = { enable = false },
         workspace = {
            checkThirdParty = false,
            library = {
               vim.env.VIMRUNTIME,
            },
         },
      },
   },
}

vim.lsp.enable('lua_ls')

vim.diagnostic.config({ virtual_text = false, signs = false, underline = false })

-----------
--  CMP  --
-----------

local cmp = require('cmp')

-- DISABLE AUTOCOMPLETE AND USE MANUAL TRIGGER
-- AUTOCOMPLETE'S TOO DISTRACTING
cmp.setup({
   mapping = {
      ['<C-i>'] = cmp.mapping(function(_)
         cmp.complete()
      end),
      ['<enter>'] = cmp.mapping.confirm(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
   },
   window = { completion = { max_height = 7 } },
   sources = { { name = "nvim_lsp" } },
   completion = { autocomplete = false },
})

----------------
--  FLUORIDE  --
----------------

local fluoride = require("fluoride")
fluoride.setup({
   window = {
      title = "Fluoride",     -- string or false to disable
      width = 0.3,            -- proportion of terminal width (0-1)
      height = 0.85,          -- proportion of terminal height (0-1)
      row = 2,                -- fixed rows from top edge
      col = 2,                -- fixed cols from right edge
      border = "single",      -- border style (see below)
      winblend = 15,          -- transparency (0-100)
      footer = true,          -- show/hide help footer
      center_breakpoint = 80, -- switch to centered layout below this width
   },
   keymaps = {
      close = "q",            -- close the window
      close_alt = "<C-c>",    -- alternative close (set false to disable)
      jump = "<CR>",          -- jump to code point
      peek = "gd",            -- peek at code point (center + flash)
      hover = "K",            -- LSP hover on code point
   },
})
