local fmt = string.format
local icons = rvim.ui.icons
local codicons = rvim.ui.codicons
local highlight = rvim.highlight

---@param data { old_name: string, new_name: string }
local function make_rename_params(data)
  local clients = vim.lsp.get_active_clients()
  clients = vim.tbl_filter(function(client) return client.name ~= 'copilot' end, clients)
  for _, client in ipairs(clients) do
    local will_rename = vim.tbl_get(client, 'server_capabilities', 'workspace', 'fileOperations', 'willRename')
    if not will_rename then
      return vim.notify(fmt('%s does not LSP file rename', client.name), 'info', { title = 'LSP' })
    end
    local params = {
      files = {
        {
          oldUri = vim.uri_from_fname(data.old_name),
          newUri = vim.uri_from_fname(data.new_name),
        },
      },
    }
    local resp = client.request_sync('workspace/willRenameFiles', params, 1000)
    if resp and resp.result ~= nil then vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding) end
  end
end

local function will_rename_handler(data) make_rename_params({ old_name = data.source, new_name = data.destination }) end

local function get_telescope_opts(state, path)
  return {
    cwd = path,
    search_dirs = { path },
    attach_mappings = function(prompt_bufnr, map)
      local actions = require('telescope.actions')
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local action_state = require('telescope.actions.state')
        local selection = action_state.get_selected_entry()
        local filename = selection.filename
        if filename == nil then filename = selection[1] end
        -- any way to open the file without triggering auto-close event of neo-tree?
        require('neo-tree.sources.filesystem').navigate(state, state.path, filename)
      end)
      return true
    end,
  }
end

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    cmd = { 'Neotree' },
    branch = 'v2.x',
    keys = { { '<c-n>', '<cmd>Neotree toggle reveal<CR>', desc = 'toggle tree' } },
    config = function()
      highlight.plugin('NeoTree', {
        theme = {
          ['onedark'] = {
            { NeoTreeNormal = { link = 'PanelBackground' } },
            { NeoTreeNormalNC = { link = 'PanelBackground' } },
            { NeoTreeRootName = { bold = false, italic = false } },
            { NeoTreeStatusLine = { link = 'PanelBackground' } },
            { NeoTreeTabActive = { bg = { from = 'PanelBackground' } } },
            { NeoTreeTabInactive = { inherit = 'Comment', italic = false } },
            { NeoTreeTabSeparatorInactive = { link = 'WinSeparator' } },
          },
        },
      })

      vim.g.neo_tree_remove_legacy_commands = 1

      local symbols = require('lspkind').symbol_map
      local lsp_hls = rvim.ui.lsp.highlights

      require('neo-tree').setup({
        close_if_last_window = true,
        sources = { 'filesystem', 'git_status', 'document_symbols' },
        enable_opened_markers = true,
        source_selector = {
          winbar = true,
          separator_active = '',
          tabs_layout = 'center',
          sources = {
            { source = 'filesystem' },
            { source = 'git_status' },
            { source = 'document_symbols' },
          },
        },
        event_handlers = {
          { event = 'file_renamed', handler = will_rename_handler },
          {
            event = 'neo_tree_buffer_enter',
            handler = function() highlight.set('Cursor', { blend = 100 }) end,
          },
          {
            event = 'neo_tree_buffer_leave',
            handler = function() highlight.set('Cursor', { blend = 0 }) end,
          },
          {
            event = 'neo_tree_window_after_close',
            handler = function() highlight.set('Cursor', { blend = 0 }) end,
          },
        },
        filesystem = {
          follow_current_file = true,
          hijack_netrw_behavior = 'open_current',
          use_libuv_file_watcher = true,
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = true,
            never_show = { '.DS_Store' },
          },
          window = {
            mappings = {
              ['/'] = 'noop',
              ['g/'] = 'fuzzy_finder',
              ['gf'] = 'telescope_find',
              ['gw'] = 'telescope_grep',
            },
          },
          commands = {
            telescope_find = function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              if vim.fn.isdirectory(path) == 0 then return end
              require('telescope.builtin').find_files(get_telescope_opts(state, path))
            end,
            telescope_grep = function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              if vim.fn.isdirectory(path) == 0 then return end
              require('telescope.builtin').live_grep(get_telescope_opts(state, path))
            end,
          },
        },
        default_component_configs = {
          indent = {
            with_markers = false,
            with_expanders = true,
            expander_collapsed = icons.misc.triangle_short_down,
            expander_expanded = icons.misc.triangle_short_right,
          },
          icon = {
            folder_empty = codicons.documents.open_folder,
            default = codicons.documents.default_folder,
            highlight = 'DevIconDefault',
          },
          name = { highlight_opened_files = true },
          document_symbols = {
            follow_cursor = true,
            kinds = rvim.fold(function(acc, v, k)
              acc[k] = { icon = v, hl = lsp_hls[k] }
              return acc
            end, symbols),
          },
          modified = { symbol = codicons.misc.circle .. ' ' },
          git_status = {
            symbols = {
              added = codicons.git.added,
              deleted = codicons.git.removed,
              modified = codicons.git.mod,
              renamed = codicons.git.renamed,
              untracked = icons.git.untracked,
              ignored = codicons.git.ignored,
              unstaged = codicons.git.staged,
              staged = codicons.git.unstaged,
              conflict = icons.git.branch,
            },
          },
          diagnostics = {
            highlights = {
              hint = 'DiagnosticHint',
              info = 'DiagnosticInfo',
              warn = 'DiagnosticWarn',
              error = 'DiagnosticError',
            },
          },
        },
        window = {
          position = 'right',
          width = 35,
          mappings = {
            ['<esc>'] = 'revert_preview',
            ['<CR>'] = 'open_with_window_picker',
            ['<c-s>'] = 'split_with_window_picker',
            ['l'] = 'open',
            ['o'] = 'toggle_node',
            ['P'] = { 'toggle_preview', config = { use_float = false } },
            ['v'] = 'vsplit_with_window_picker',
            ['Z'] = 'expand_all_nodes',
          },
        },
      })
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
  },
  {
    's1n7ax/nvim-window-picker',
    version = '*',
    config = function()
      require('window-picker').setup({
        use_winbar = 'smart',
        autoselect_one = true,
        include_current = false,
        other_win_hl_color = highlight.get('Visual', 'bg'),
        filter_rules = {
          bo = {
            filetype = { 'neo-tree-popup', 'quickfix' },
            buftype = { 'terminal', 'quickfix', 'nofile' },
          },
        },
      })
    end,
  },
  {
    'razak17/oil.nvim',
    keys = {
      { '-', function() require('oil').open() end, desc = 'open parent directory' },
    },
    opts = { skip_confirm_for_simple_edits = true },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
}
