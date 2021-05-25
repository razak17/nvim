local config = {}

function config.nvim_treesitter()
  -- require('modules.lang.ts')
  local fts = {
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "graphql",
    "jsdoc",
    "json",
    "yaml",
    "go",
    "c",
    "cpp",
    "rust",
    "python",
    "bash",
    "lua"
  }

  local get_filetypes = function()
    local parsers = require("nvim-treesitter.parsers")
    local configs = parsers.get_parser_configs()
    return vim.tbl_map(function(ft)
      return configs[ft].filetype or ft
    end, parsers.available_parsers())
  end

  require'nvim-treesitter.configs'.setup {
    ensure_installed = fts,
    highlight = {enable = true}
    -- autotag = {enable = true},
    -- autopairs = {enable = true},
    -- rainbow = {
    --   enable = true,
    --   extended_mode = true,
    --   disable = {"lua", "json"},
    --   colors = {
    --     "royalblue3",
    --     "darkorange3",
    --     "seagreen3",
    --     "firebrick",
    --     "darkorchid3"
    --   }
    -- },
    -- matchup = {enable = true, disable = {"c", "python"}},
  }

  local fold =
      "set foldmethod=expr foldtext=v:lua.folds() foldexpr=nvim_treesitter#foldexpr()"
  -- -- TODO
  -- -- local highlight = ":edit | TSBufEnable highlight<CR>"

  local targets = get_filetypes()
  local filetypes = table.concat(targets, ",")

  -- -- vim.cmd [[edit | TSBufEnable highlight]]
  vim.cmd(string.format("autocmd FileType %s %s", filetypes, fold))
  -- -- vim.cmd(string.format("autocmd FileType %s %s", filetypes, highlight))

  vim.api.nvim_set_keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>',
                          {});
end

function config.nvim_lsp()
  require('modules.lang.lsp.lspconfig')
end

function config.dap()
  require 'modules.lang.dap'
end

function config.dap_ui()
  require("dapui").setup({
    mappings = {expand = "<CR>", open = "o", remove = "d"}
  })
end

function config.lsp_saga()
  local opts = {
    error_sign = '',
    warn_sign = '',
    hint_sign = '',
    infor_sign = '',
    code_action_icon = '💡'
  }
  return opts
end

return config
