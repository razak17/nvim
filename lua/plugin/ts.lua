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
  vim.cmd("au FileType "..filetypes.." lua require'utils.matchit'.setup()")
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
        node_incremental = "n",
        scope_incremental = "<leader>em",
        node_decremental = "m"
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
          ["<leader>eV"] = "@function.outer", -- replace with block.inner and block.outer when its supported in more languages
          ["<leader>ev"] = "@function.inner"
        }
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>ef"] = "@parameter.inner", -- replace with block.inner when its supported in more languages
        },
        swap_previous = {
          ["<leader>ea"] = "@parameter.inner",
        },
      },
    },
  }

  vim.wo.foldexpr = "nvim_treesitter#foldexpr()"

  api.nvim_set_keymap('n', 'R', ':write | edit | TSBufEnable highlight<CR>', {});
  api.nvim_exec([[
    command! ToggleTsVtx lua require'plugin.ts'.toggle_ts_virt_text()
    hi TsVirtText guifg=#89ddff
    augroup TSVirtualText
      au!
      au BufEnter,CursorMoved,CursorMovedI,WinEnter,CompleteDone,InsertEnter,InsertLeave * lua require'plugin.ts'.ts_virt_text()
    augroup END

    command! ToggleTsHlGroups lua require'plugin.ts'.toggle_ts_hl_groups()
    augroup TSVirtualTextHlGroups
      au!
      au BufEnter,CursorMoved,CursorMovedI,WinEnter,CompleteDone,InsertEnter,InsertLeave * lua require'plugin.ts'.ts_hl_groups()
    augroup END
  ]], '')
end



local virt_enable = false

local ns_id = api.nvim_create_namespace('TSVirtualText')

function M.toggle_ts_virt_text()
  if virt_enable then
    virt_enable = false
    api.nvim_buf_clear_namespace(0, ns_id, 0,-1)
  else
    virt_enable = true
    M.ts_virt_text()
  end
end

function M.ts_virt_text()
  if not virt_enable then return end

  local node_info = require'nvim-treesitter'.statusline()
  if not node_info or node_info == "" then return end

  local cursor = api.nvim_win_get_cursor(0)
  api.nvim_buf_clear_namespace(0, ns_id, 0,-1)
  api.nvim_buf_set_virtual_text(0, ns_id, cursor[1]-1, {{ node_info, "TsVirtText" }}, {})
end

local hl_virt_enable = false
local hl_ns_id = api.nvim_create_namespace('TSVirtualTextHlGroups')

function M.toggle_ts_hl_groups()
  if hl_virt_enable then
    hl_virt_enable = false
    api.nvim_buf_clear_namespace(0, hl_ns_id, 0,-1)
  else
    hl_virt_enable = true
    M.ts_hl_groups()
  end
end

function M.ts_hl_groups()
  if not hl_virt_enable then return end

  local ns = api.nvim_get_namespaces()['treesitter/highlighter']
  local _, lnum, lcol = unpack(vim.fn.getcurpos())
  local extmarks = api.nvim_buf_get_extmarks(0, ns, {lnum-1, lcol-1}, {lnum-1, -1}, { details = true })
  local groups = {}

  for i, ext in ipairs(extmarks) do
    local infos = ext[4]
    if infos then
      local str = infos.hl_group
      if i ~= #extmarks then
        str = str..' > '
      end
      table.insert(groups, {str, infos.hl_group})
    end
  end

  api.nvim_buf_clear_namespace(0, hl_ns_id, 0,-1)
  api.nvim_buf_set_virtual_text(0, hl_ns_id, lnum-1, groups, {})
end

return M
