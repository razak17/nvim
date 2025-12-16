-- https://github.com/delphinus/dotfiles/blob/master/.config/nvim/lua/core/telescope/init.lua#L1

---@param name string
---@return fun(opts: table?): function
local function builtin(name)
  return function(opts)
    return function(more_opts)
      local o = vim.tbl_extend('force', opts or {}, more_opts or {})
      require('telescope.builtin')[name](o)
    end
  end
end

---@param name string
---@param prop string?
---@return fun(opts: table?): function
local function extensions(name, prop)
  return function(opts)
    return function(more_opts)
      local o = vim.tbl_extend('force', opts or {}, more_opts or {})
      require('telescope').extensions[name][prop or name](o)
    end
  end
end

---@praam opts table?
---@return fun(more_opts: table?): nil
local function frecency(opts)
  return function(more_opts)
    local o = vim.tbl_extend('force', opts or {}, more_opts or {})
    extensions('frecency')(o)({})
  end
end

return {
  {
    'd00h/telescope-any',
    cond = function()
      local condition = not ar.plugins.minimal
        and ar.config.picker.variant == 'telescope'
      return ar.get_plugin_cond('telescope-any', condition)
    end,
    init = function()
      local instance
      vim.keymap.set('n', '<leader>fa', function()
        if not instance then
          instance = require('telescope-any').create_telescope_any({
            pickers = {
              [':'] = builtin('command_history')({}),
              ['/'] = extensions('egrepify')({}),
              ['?'] = builtin('grep_string')({}),
              ['w'] = builtin('grep_string')({}),

              ['m '] = builtin('marks')({}),
              ['q '] = builtin('quickfix')({}),
              ['l '] = builtin('loclist')({}),
              ['j '] = builtin('jumplist')({}),

              ['man '] = builtin('man_pages')({}),
              ['options '] = builtin('vim_options')({}),
              ['keymaps '] = builtin('keymaps')({}),

              ['colorscheme '] = builtin('colorscheme')({}),
              ['colo '] = builtin('colorscheme')({}),

              ['com '] = builtin('commands')({}),
              ['command '] = builtin('commands')({}),

              ['au '] = builtin('autocommands')({}),
              ['autocommand '] = builtin('autocommands')({}),

              ['highlight '] = builtin('highlights')({}),
              ['hi '] = builtin('highlights')({}),

              ['o '] = frecency({}),
              ['b '] = builtin('buffers')({}),

              ['gs '] = builtin('git_status')({}),
              ['gb '] = builtin('git_branches')({}),
              ['gc '] = builtin('git_commits')({}),

              ['d '] = builtin('diagnostics')({}),
              ['@'] = builtin('lsp_document_symbols')({}),

              ['B '] = function(opts)
                local parent = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
                extensions('file_browser')({
                  cwd = parent ~= '' and parent or nil,
                })(opts)
              end,

              ['# '] = builtin('current_buffer_fuzzy_find')({}),
              ['h '] = builtin('help_tags'),
              ['node '] = extensions('node_modules', 'list')({}),
              ['N '] = extensions('node_modules', 'list')({}),
              ['todo '] = extensions('todo-comments')({}),
              ['t '] = extensions('todo-comments')({}),
              ['yank'] = extensions('yank_history')({}),
              ['y '] = extensions('yank_history')({}),

              ['f '] = frecency({ workspace = 'CWD' }),
              ['v '] = frecency({ workspace = 'VIM' }),

              ['L '] = extensions('lazy')({}),

              [''] = frecency({}),
            },
          })
        end
        instance()
      end, { desc = 'any' })
    end,
  },
}
