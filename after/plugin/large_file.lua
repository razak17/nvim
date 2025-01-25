local enabled = ar_config.plugin.custom.large_file.enable

if not ar or ar.none or not enabled then return end

local api, fn, cmd, go = vim.api, vim.fn, vim.cmd, vim.go
local bo, o, wo, opt_l = vim.bo, vim.o, vim.wo, vim.opt_local

ar.large_file = {
  enable = false,
  exclusions = { 'NeogitCommitMessage' },
  -- 1MB if lsp is enabled else 500KB
  limit = ar.lsp.enable and 1024 or 500,
  line_count = 2048,
}

local lf = ar.large_file

---@param bufnr number
---@param unit? string
---@return integer|nil size in unit or bytes
local function get_buf_size(bufnr, unit)
  local size = fn.getfsize(api.nvim_buf_get_name(bufnr))
  unit = unit or 'bytes'
  local kb = size / 1024
  local mb = kb / 1024
  local gb = mb / 1024
  if unit == 'kb' then return math.floor(0.5 + kb) end
  if unit == 'mb' then return math.floor(0.5 + mb) end
  if unit == 'gb' then return math.floor(0.5 + gb) end
  return size
end

---@param bufnr number
local function handle_bigfile(bufnr)
  ar.augroup('large_file', {
    event = { 'BufEnter', 'BufReadPre', 'BufWritePre', 'BufReadPost' },
    command = function()
      cmd('syntax clear')
      opt_l.syntax = 'OFF'
    end,
    buffer = bufnr,
  }, {
    event = 'BufReadPost',
    command = function() vim.bo.filetype = '' end,
    buffer = bufnr,
  })

  opt_l.syntax = 'OFF'
  cmd.filetype('off')
  wo.wrap = false
  wo.statuscolumn = ''
  -- bo.bufhidden = 'unload'
  bo.swapfile = false
  wo.foldmethod = 'manual'
  -- bo.undolevels = -1
  go.undoreload = 0
  wo.list = false
  wo.spell = false
end

local function is_excluded(bufnr)
  return vim.tbl_contains(lf.exclusions, bo[bufnr].filetype)
end

ar.augroup('LargeFileAutocmds', {
  event = { 'BufReadPre', 'BufEnter' },
  command = function(args)
    if not ar.large_file.enable then return end

    if vim.b[args.buf].is_large_file == true then return end

    local line_count = api.nvim_buf_line_count(args.buf)
    local filesize = get_buf_size(args.buf, 'kb')

    if is_excluded(args.buf) then return end

    local is_large_file = line_count > lf.line_count or filesize > lf.limit

    vim.b[args.buf].is_large_file = is_large_file
    if is_large_file then
      handle_bigfile(args.buf)
    else
      cmd.filetype('on')
    end
  end,
}, {
  event = { 'BufWinEnter' },
  command = function(args)
    if not ar.large_file.enable then return end
    if vim.b[args.buf].is_large_file then o.eventignore = nil end
  end,
})
