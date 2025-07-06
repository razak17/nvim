local enabled = ar_config.plugin.custom.copilot_commit_message.enable

if not ar or ar.none or not enabled then return end

local api, fn = vim.api, vim.fn

local Spinner = {
  timer = nil,
  is_running = false,
  characters = {
    '',
    '',
    '',
    '',
    '',
    '',
  },
  index = 1,
  ns_id = api.nvim_create_namespace('commit_spinner'),
}

function Spinner:new()
  local instance = setmetatable({}, { __index = self })
  return instance
end

function Spinner:start()
  if self.is_running then return end

  self.timer = vim.uv.new_timer()
  if not self.timer then
    vim.notify('Failed to create timer', vim.log.levels.ERROR)
    return
  end

  self.is_running = true
  self.timer:start(0, 80, function() self:update() end)
end

function Spinner:update()
  if not self.is_running then return end

  vim.schedule(function()
    if not self.is_running then return end
    self.index = (self.index % #self.characters) + 1
    local cursor_line = fn.line('.')
    api.nvim_buf_clear_namespace(0, self.ns_id, 0, -1)
    api.nvim_buf_set_extmark(0, self.ns_id, cursor_line - 1, 0, {
      virt_text = {
        {
          self.characters[self.index] .. ' Generating commit message...',
          'Comment',
        },
      },
      virt_text_pos = 'overlay',
    })
  end)
end

function Spinner:stop()
  self.is_running = false
  if self.timer then
    self.timer:stop()
    self.timer:close()
    self.timer = nil
    vim.schedule(
      function() api.nvim_buf_clear_namespace(0, self.ns_id, 0, -1) end
    )
  end
end

local spinner = Spinner:new()
api.nvim_set_hl(
  0,
  'CopilotCommitMessageStyle',
  { fg = ar.highlight.get('DiffChange').bg, bg = 'None' }
)
api.nvim_set_hl(
  0,
  'CommitMessageScope',
  { fg = ar.highlight.get('DiffDelete').bg, bg = 'None' }
)

local function generate_message()
  spinner:start()

  local function callback(obj)
    spinner:stop()

    if obj.code ~= 0 then
      vim.notify(
        'Error generating commit message: ' .. obj.stderr,
        vim.log.levels.ERROR
      )
      return
    end

    local items = {}

    for _, line in ipairs(vim.split(obj.stdout, '\n')) do
      if line ~= '' then
        items[#items + 1] = {
          idx = #items,
          score = #items,
          text = line:gsub('^[0-9]+: ', ''),
        }
      end
    end

    vim.schedule(function()
      local function open_commit_picker(commit_items)
        local parent_win = api.nvim_get_current_win()
        local buf = api.nvim_create_buf(false, true)

        api.nvim_set_option_value('filetype', 'gitcommit', { buf = buf })
        api.nvim_set_option_value('buftype', 'nofile', { buf = buf })
        api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })
        api.nvim_set_option_value('swapfile', false, { buf = buf })

        local lines = {}

        for _, i in ipairs(commit_items) do
          table.insert(lines, i.text)
        end

        api.nvim_buf_set_lines(buf, 0, -1, false, lines)

        local width = math.floor(vim.o.columns * 0.5)
        local height = math.floor(vim.o.lines * 0.6)
        local row = math.floor(vim.o.lines * 0.2)
        local col = math.floor(vim.o.columns * 0.25)
        local win = api.nvim_open_win(buf, true, {
          relative = 'editor',
          width = width,
          height = height,
          row = row,
          col = col,
          style = 'minimal',
          border = 'rounded',
          noautocmd = true,
        })

        api.nvim_set_option_value('statusline', '', { win = win })
        api.nvim_set_option_value('winbar', '', { win = win })
        api.nvim_set_option_value('number', false, { win = win })
        api.nvim_set_option_value('relativenumber', false, { win = win })
        api.nvim_set_option_value('signcolumn', 'no', { win = win })

        api.nvim_set_option_value('modifiable', false, { buf = buf })
        api.nvim_set_option_value('readonly', true, { buf = buf })
        api.nvim_set_current_win(win)
        vim.cmd('stopinsert')

        vim.keymap.set('n', '<CR>', function()
          local lnum = api.nvim_win_get_cursor(0)[1]
          local line = api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1]
          api.nvim_win_close(win, true)
          api.nvim_set_current_win(parent_win)
          api.nvim_set_current_line(line)
        end, { buffer = buf, nowait = true })

        local quit_picker = function()
          api.nvim_win_close(win, true)
          api.nvim_set_current_win(parent_win)
        end
        map('n', '<Esc>', quit_picker, { buffer = buf, nowait = true })
        map('n', 'q', quit_picker, { buffer = buf, nowait = true })
      end

      open_commit_picker(items)
    end)
  end

  vim.system({
    'copilot-cli',
    '--action',
    'lazygit-conventional-commit',
    '--path',
    '.',
  }, { text = true }, callback)
end

require('ar.utils.fs').on_event('FileType', function()
  vim.keymap.set({ 'n', 'i' }, '<M-a>', function() generate_message() end)
end, { target = 'gitcommit' })
