local enabled = ar.plugin.large_file.enable

if not ar or ar.none or not enabled then return end

local api, fn, cmd, g = vim.api, vim.fn, vim.cmd, vim.g
local bo, o, wo = vim.bo, vim.o, vim.wo

ar.large_file = {
  active = false,
  exclusions = { 'NeogitCommitMessage' },
  limit = 100 * 1024, -- 100 KB
  line_count = 2000,
  plugins = {
    ['mini.indentscope'] = 'MiniIndentscope',
  },
}

ar.augroup('LargeFileAutocmds', {
  event = { 'BufEnter', 'BufReadPre', 'BufWritePre', 'TextChanged' },
  command = function(args)
    local lf = ar.large_file
    local line_count = api.nvim_buf_line_count(args.buf)
    local filesize = fn.getfsize(fn.expand('%'))
    if line_count > lf.line_count or filesize > lf.limit then
      lf.active = true

      wo.wrap = false
      bo.bufhidden = 'unload'
      -- o.eventignore = 'FileType'
      -- bo.buftype = 'nowrite'
      -- bo.undolevels = -1
      cmd.filetype('off')
    else
      lf.active = false

      bo.bufhidden = ''
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
    local lf = ar.large_file
    if vim.tbl_contains(lf.exclusions, bo[args.buf].filetype) then return end

    local byte_size = api.nvim_buf_get_offset(
      api.nvim_get_current_buf(),
      api.nvim_buf_line_count(api.nvim_get_current_buf())
    )
    if byte_size > lf.limit then
      if g.loaded_matchparen then cmd('NoMatchParen') end

      -- Handle plugins
      for plugin, au in pairs(lf.plugins) do
        if ar.is_available(plugin) then
          api.nvim_clear_autocmds({ group = au })
        end
      end
    else
      if not g.loaded_matchparen then cmd('DoMatchParen') end
    end
  end,
})
