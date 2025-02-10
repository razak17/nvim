local enabled = ar_config.plugin.custom.smart_close.enable

if not ar or ar.none or not enabled then return end

local api, fn = vim.api, vim.fn

local smart_close_filetypes = ar.p_table({
  ['qf'] = true,
  ['log'] = true,
  ['help'] = true,
  ['query'] = true,
  ['dap-float'] = true,
  ['dbui'] = true,
  ['lspinfo'] = true,
  ['httpResult'] = true,
  ['git.*'] = true,
  ['Neogit.*'] = true,
  ['neotest.*'] = true,
  ['fugitive.*'] = true,
  ['copilot.*'] = true,
  ['tsplayground'] = true,
  ['oil'] = true,
  ['readup'] = true,
  ['telescope-lazy'] = true,
  ['grug-far'] = true,
  ['toggleterm'] = true,
  ['sticky'] = true,
})

local smart_close_buftypes = ar.p_table({
  ['nofile'] = true,
})

function ar.smart_close()
  if fn.winnr('$') ~= 1 then api.nvim_win_close(0, true) end
end

ar.augroup('SmartClose', {
  -- Auto open grep quickfix window
  event = { 'QuickFixCmdPost' },
  pattern = { '*grep*' },
  command = 'cwindow',
}, {
  -- Close certain filetypes by pressing q.
  event = { 'FileType' },
  command = function(args)
    local is_unmapped = fn.hasmapto('q', 'n') == 0

    local buf = vim.bo[args.buf]
    local is_eligible = is_unmapped
      or vim.wo.previewwindow
      or smart_close_filetypes[buf.ft]
      or smart_close_buftypes[buf.bt]
    if is_eligible then
      map('n', 'q', ar.smart_close, { buffer = args.buf, nowait = true })
    end
  end,
})
