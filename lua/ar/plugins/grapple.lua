local minimal = ar.plugins.minimal

-- https://www.reddit.com/r/neovim/comments/1nbiv93/combining_best_of_marks_and_harpoon_with_grapple/

local function save_mark()
  local char = vim.fn.getcharstr()
  -- Handle ESC, Ctrl-C, etc.
  if char == '' or vim.startswith(char, '<') then return end
  local grapple = require('grapple')
  grapple.tag({ name = char })
  local filepath = vim.api.nvim_buf_get_name(0)
  local filename = vim.fn.fnamemodify(filepath, ':t')
  vim.notify('Marked ' .. filename .. ' as ' .. char)
end

local function open_mark()
  local char = vim.fn.getcharstr()
  -- Handle ESC, Ctrl-C, etc.
  if char == '' or vim.startswith(char, '<') then return end
  local grapple = require('grapple')
  if char == "'" then
    grapple.toggle_tags()
    return
  end
  grapple.select({ name = char })
end

return {
  {
    desc = 'Neovim plugin for tagging important files',
    'cbochs/grapple.nvim',
    cond = function() return ar.get_plugin_cond('grapple.nvim', not minimal) end,
    -- stylua: ignore
    keys = {
      { 'm', save_mark, noremap = true, silent = true },
      { "'", open_mark, noremap = true, silent = true },
      { '<A-a>', '<Cmd>Grapple toggle<CR>', desc = 'grapple: add file' },
      { '<A-m>', '<Cmd>Grapple toggle_tags<CR>', desc = 'grapple: toggle tags' },
    },
    cmd = 'Grapple',
    opts = {
      scope = 'git_branch',
      default_scopes = {
        git = { shown = true },
        git_branch = { shown = true },
        global = { shown = true },
      },
    },
  },
}
