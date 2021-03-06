local G = require 'core.global'
local packer = nil
local packer_compiled = G.local_nvim .. 'site/plugin/packges.vim'
local load_plugins = require 'utils.funcs'.plug_config
local Packer = {}

local function repos()
  return {
    { repo = 'christianchiarulli/nvcode-color-schemes.vim' },
    { repo = 'norcalli/nvim-colorizer.lua' },
    { repo = 'tpope/vim-fugitive' },
    { repo = 'b3nj5m1n/kommentary' },
    { repo = 'mbbill/undotree' },
    { repo = 'tjdevries/lsp_extensions.nvim' },
    { repo = 'glepnir/lspsaga.nvim' },
    { repo = 'onsails/lspkind-nvim' },
    { repo = 'tweekmonster/startuptime.vim', cmd = "StartupTime" },
    { repo = 'kyazdani42/nvim-tree.lua' },
    { repo = 'nvim-telescope/telescope-packer.nvim' },
    { repo = 'nvim-telescope/telescope-fzy-native.nvim' },
    { repo = 'glepnir/dashboard-nvim' },
    { repo = 'brooth/far.vim' },
    { repo = 'voldikss/vim-floaterm' },
    { repo = 'AndrewRadev/tagalong.vim' },
    { repo = 'romainl/vim-cool' },
    { repo = 'RRethy/vim-illuminate' },
    { repo = 'liuchengxu/vim-which-key' },
    { repo = 'mattn/emmet-vim' },
    { repo = "akinsho/nvim-bufferline.lua" },
    { repo = "hrsh7th/nvim-compe" },
    { repo = 'windwp/nvim-autopairs' },
    { repo = 'neovim/nvim-lspconfig' },
    { repo = 'airblade/vim-rooter' },
    {
      repo = 'glacambre/firenvim',
      run = function() vim.fn['firenvim#install'](0) end
    },
    {
      repo = "hrsh7th/vim-vsnip",
      requires = {'hrsh7th/vim-vsnip-integ'}
    },
    {
      repo = 'nvim-telescope/telescope.nvim',
      requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}, {'kyazdani42/nvim-web-devicons'}}
    },
    {
      repo = 'glepnir/galaxyline.nvim',
      branch = 'main',
      requires = {'kyazdani42/nvim-web-devicons'}
    },
    {
      repo = 'nvim-treesitter/nvim-treesitter',
      run = ':TSUpdate',
      requires = {
        {'nvim-treesitter/playground', after = 'nvim-treesitter'},
        {'romgrk/nvim-treesitter-context', after = 'nvim-treesitter'}
      },
    },
  }
end

function Packer:load_packer()
  if not packer then
    packer = require('packer')
  end
  packer.init({
    compile_path = packer_compiled,
    config = {
      display = {
        _open_fn = function(name)
          local ok, float_win = pcall(function()
            return require('plenary.window.float').percentage_range_window(0.8, 0.8)
          end)

          if not ok then
            vim.cmd [[65vnew  [packer] ]]
            return vim.api.nvim_get_current_win(), vim.api.nvim_get_current_buf()
          end

          local bufnr = float_win.buf
          local win = float_win.win

          vim.api.nvim_buf_set_name(bufnr, name)
          vim.api.nvim_win_set_option(win, 'winblend', 10)

          return win, bufnr
        end
      }
    }
  })

  local use = packer.use
  packer.reset()

  use {'wbthomason/packer.nvim', opt = true}
  use 'tpope/vim-surround'
end

local function init()
  if packer == nil then
    Packer:load_packer()
  end

  if vim.fn.exists('g:vscode') == 0 then
    for  _, item in ipairs(repos()) do
      load_plugins(use, item)
    end
  end
end

local plugins = setmetatable({}, {
  __index = function(_, key)
    init()
    return packer[key]
  end
})

return plugins

