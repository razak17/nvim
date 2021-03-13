local api = vim.api
local M = {}

local fts = {
  "c", "cpp", "css", "erlang", "graphql", "go", "haskell", "html", "javascript", "jsdoc",
  "julia", "json", "html", "lua", "python", "rust", "sh", "toml",
  "tsx", "typescript", "yaml"
}

local parsers = {
  "bash", "c", "cpp", "css", "erlang", "graphql", "go", "haskell", "html", "javascript", "jsdoc",
  "julia", "json", "html", "lua", "python", "rust", "toml",
  "tsx", "typescript", "yaml"
}

local synoff = function()
  local filetypes = vim.fn.join(fts, ",")
  vim.cmd("au FileType "..filetypes.." set syn=off")
  vim.cmd("au FileType "..filetypes.." lua require'modules.lang.utils'.matchit()")
end

function M.setup()
  synoff()
  require'nvim-treesitter.configs'.setup {
    ensure_installed = parsers,
    highlight = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      disable = {},
      keymaps = {
        init_selection = "<leader>en",
        scope_incremental = "<leader>em",
      }
    },
    indent = {
      enable = true,
    },
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        }
      },
    },
  }

  vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

  api.nvim_set_keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>', {});
  api.nvim_exec([[
    hi TsVirtText guifg=#89ddff
    command! ToggleTsVtx lua require'modules.lang.utils'.toggle_ts_virt_text()
    command! ToggleTsHlGroups lua require'modules.lang.utils'.toggle_ts_hl_groups()
  ]], '')
end

return M

