local api = vim.api
local M = {}

local fts = {
  "c", "cpp", "css", "graphql", "go", "haskell", "html", "javascript", "jsdoc",
  "julia", "json", "html", "lua", "python", "rust", "sh", "toml",
  "tsx", "typescript", "yaml"
}

local parsers = {
  "bash", "c", "cpp", "css", "graphql", "go", "haskell", "html", "javascript", "jsdoc",
  "julia", "json", "html", "lua", "python", "rust", "toml",
  "tsx", "typescript", "yaml"
}

local synoff = function()
  local filetypes = vim.fn.join(fts, ",")
  vim.cmd("au FileType "..filetypes.." set syn=off")
  vim.cmd("au FileType "..filetypes.." lua require'modules.lang.conf'.matchit()")
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
    playground = {
      enable = true,
      disable = {},
      updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = false -- Whether the query persists across vim sessions
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
    command! ToggleTsVtx lua require'modules.lang.conf'.toggle_ts_virt_text()
    hi TsVirtText guifg=#89ddff
    augroup TSVirtualText
      au!
      au BufEnter,CursorMoved,CursorMovedI,WinEnter,CompleteDone,InsertEnter,InsertLeave * lua require'modules.lang.conf'.ts_virt_text()
    augroup END

    command! ToggleTsHlGroups lua require'modules.lang.conf'.toggle_ts_hl_groups()
    augroup TSVirtualTextHlGroups
      au!
      au BufEnter,CursorMoved,CursorMovedI,WinEnter,CompleteDone,InsertEnter,InsertLeave * lua require'modules.lang.conf'.ts_hl_groups()
    augroup END
  ]], '')
end

return M

