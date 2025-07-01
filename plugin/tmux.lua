local enabled = ar_config.plugin.main.tmux.enable

if not ar or ar.none or not enabled or vim.env.TMUX == nil then return end

local fn, fmt = vim.fn, string.format

local ignored = {
  'TelescopePrompt',
  'buffer_manager',
  'harpoon',
  'buffalo',
  'fzf',
  'NeogitStatus',
  'NeogitPopup',
  'NeogitRebaseTodo',
  '',
}

--- Get the color of the current vim background and update tmux accordingly
---@param reset boolean?
local function set_statusline(reset)
  if vim.tbl_contains(ignored, vim.bo.ft) then return end
  local tmux_bg = '#20222f'
  local bg = tmux_bg
  if ar_config.ui.transparent.enable then
    bg = 'default'
  elseif not reset then
    bg = ar.highlight.get('Normal', 'bg')
  end
  fn.jobstart(fmt('tmux set-option -g status-style bg=%s', bg))
end

local function clear_pane_title()
  fn.jobstart('tmux set-window-option automatic-rename on')
end

local function set_window_title()
  local cwd = vim.uv.cwd()
  if cwd then
    local window_title = fn.fnamemodify(cwd, ':t') or 'Neovim'
    fn.jobstart(fmt("tmux rename-window '%s'", window_title))
  end
end

ar.augroup('TmuxUtils', {
  event = { 'FocusGained', 'BufReadPost', 'BufEnter' },
  command = function() set_window_title() end,
}, {
  event = { 'VimLeave' },
  command = function()
    set_window_title()
    clear_pane_title()
  end,
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
