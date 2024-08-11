local enabled = not ar.noplugin and ar.plugin.large_file.enable

if not ar or ar.none or not enabled then return end

local api, fn, cmd, g = vim.api, vim.fn, vim.cmd, vim.g
local bo, o, wo = vim.bo, vim.o, vim.wo

ar.large_file = {
  active = false,
  exclusions = { 'NeogitCommitMessage' },
  -- 100KB if lsp is enabled else 1MB
  limit = ar.lsp.enable and 100 * 1024 or 100 * 1024 * 1,
  line_count = 2048,
}

local lf = ar.large_file

ar.augroup('LargeFileAutocmds', {
  event = { 'BufEnter', 'BufReadPre', 'BufWritePre', 'TextChanged' },
  command = function(args)
    local line_count = api.nvim_buf_line_count(args.buf)
    local filesize = fn.getfsize(fn.expand('%'))
    if line_count > lf.line_count or filesize > lf.limit then
      ar.large_file.active = true

      wo.wrap = false
      bo.bufhidden = 'unload'
      -- o.eventignore = 'FileType'
      -- bo.buftype = 'nowrite'
      -- bo.undolevels = -1
      cmd.filetype('off')
    else
      ar.large_file.active = false

      -- bo.bufhidden = ''
      -- o.eventignore = nil
      -- bo.buftype = ''
      -- bo.undolevels = 1000
      cmd.filetype('on')
    end
  end,
}, {
  event = { 'BufWinEnter' },
  command = function()
    if ar.large_file.active then o.eventignore = nil end
  end,
}, {
  event = { 'BufEnter' },
  command = function(args)
    if vim.tbl_contains(lf.exclusions, bo[args.buf].filetype) then return end

    local byte_size = api.nvim_buf_get_offset(
      api.nvim_get_current_buf(),
      api.nvim_buf_line_count(api.nvim_get_current_buf())
    )
    if byte_size > lf.limit then
      if g.loaded_matchparen then cmd('NoMatchParen') end

      if ar.is_available('mini.indentscope') then
        -- vim.api.nvim_del_augroup_by_name('MiniIndentscope')
        api.nvim_clear_autocmds({ group = 'MiniIndentscope' })
      end
    else
      if not g.loaded_matchparen then cmd('DoMatchParen') end
    end
  end,
})
