if not rvim or vim.env.TMUX == nil or vim.env.RVIM_PLUGINS_ENABLED == '0' then return end

local fn, fmt = vim.fn, string.format

--- Get the color of the current vim background and update tmux accordingly
---@param reset boolean?
local function set_statusline(reset)
  if vim.bo.ft == 'TelescopePrompt' then return end
  local tmux_bg = '#292e42'
  local bg = reset and tmux_bg or rvim.highlight.get('Normal', 'bg')
  fn.jobstart(fmt('tmux set-option -g status-style bg=%s', bg))
end

local function clear_pane_title() fn.jobstart('tmux set-window-option automatic-rename on') end

local function set_window_title()
  local session = fn.fnamemodify(vim.loop.cwd(), ':t') or 'Neovim'
  local window_title = fmt('%s', session)
  fn.jobstart(fmt("tmux rename-window '%s'", window_title))
end

rvim.augroup('TmuxUtils', {
  event = { 'FocusGained', 'BufReadPost', 'BufEnter' },
  command = function() set_window_title() end,
}, {
  event = { 'VimLeave' },
  command = function() clear_pane_title() end,
}, {
  event = { 'VimLeave', 'VimLeavePre', 'FocusLost' },
  command = function() set_statusline(true) end,
}, {
  event = { 'ColorScheme', 'FocusGained' },
  command = function()
    -- NOTE: there is a race condition here as the colors
    -- for kitty to re-use need to be set AFTER the rest of the colorscheme
    -- overrides
    vim.defer_fn(function() set_statusline() end, 1)
  end,
})
