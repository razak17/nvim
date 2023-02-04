local M = {
  'folke/noice.nvim',
  dependencies = { 'MunifTanjim/nui.nvim' },
  event = 'VeryLazy',
  enabled = rvim.nightly(),
}

function M.config()
  require('noice').setup({
    cmdline = {
      format = {
        cmdline = { title = '' },
        lua = { title = '' },
      },
    },
    lsp = {
      documentation = {
        opts = {
          border = { style = 'single' },
          position = { row = 2 },
        },
      },
      signature = { enabled = true },
      hover = { enabled = true },
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
        ['cmp.entry.get_documentation'] = true,
      },
    },
    views = {
      split = {
        win_options = {
          winhighlight = { Normal = 'Normal' },
        },
      },
      cmdline_popup = {
        position = {
          row = 5,
          col = '50%',
        },
        size = {
          width = 60,
          height = 'auto',
        },
        border = {
          style = 'single',
          padding = { 0, 1 },
        },
      },
      popupmenu = {
        relative = 'editor',
        position = {
          row = 9,
          col = '50%',
        },
        size = {
          width = 60,
          height = 10,
        },
        border = {
          style = 'single',
          padding = { 0, 1 },
        },
        win_options = {
          winhighlight = {
            Normal = 'NormalFloat',
            FloatBorder = 'FloatBorder',
          },
        },
      },
    },
    routes = {
      {
        filter = { event = 'msg_show', kind = 'search_count' },
        opts = { skip = true },
      },
      {
        filter = { event = 'msg_show', kind = '', find = 'written' },
        opts = { skip = true },
      },
    },
    presets = {
      inc_rename = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  })

  require('user.utils.highlights').plugin('noice', {
    {
      NoicePopupBaseGroup = {
        bg = { from = 'NormalFloat' },
        fg = { from = 'DiagnosticSignInfo' },
      },
    },
    {
      NoicePopupWarnBaseGroup = {
        bg = { from = 'NormalFloat' },
        fg = { from = 'Float' },
      },
    },
    {
      NoicePopupInfoBaseGroup = {
        bg = { from = 'NormalFloat' },
        fg = { from = 'Conditional' },
      },
    },
    { NoiceMini = { inherit = 'MsgArea', bg = { from = 'Normal' } } },
    { NoiceCmdlinePopup = { bg = { from = 'NormalFloat' } } },
    { NoiceCmdlinePopupBorder = { link = 'FloatBorder' } },
    { NoiceCmdlinePopupBorderCmdline = { link = 'NoicePopupBaseGroup' } },
    { NoiceCmdlinePopupBorderSearch = { link = 'NoicePopupWarnBaseGroup' } },
    { NoiceCmdlinePopupBorderFilter = { link = 'NoicePopupWarnBaseGroup' } },
    { NoiceCmdlinePopupBorderHelp = { link = 'NoicePopupInfoBaseGroup' } },
    { NoiceCmdlinePopupBorderIncRename = { link = 'NoicePopupWarnBaseGroup' } },
    { NoiceCmdlinePopupBorderInput = { link = 'NoicePopupBaseGroup' } },
    { NoiceCmdlinePopupBorderLua = { link = 'NoicePopupBaseGroup' } },
    { NoiceCmdlineIconCmdline = { link = 'NoicePopupBaseGroup' } },
    { NoiceCmdlineIconSearch = { link = 'NoicePopupWarnBaseGroup' } },
    { NoiceCmdlineIconFilter = { link = 'NoicePopupWarnBaseGroup' } },
    { NoiceCmdlineIconHelp = { link = 'NoicePopupInfoBaseGroup' } },
    { NoiceCmdlineIconIncRename = { link = 'NoicePopupWarnBaseGroup' } },
    { NoiceCmdlineIconInput = { link = 'NoicePopupBaseGroup' } },
    { NoiceCmdlineIconLua = { link = 'NoicePopupBaseGroup' } },
  })
end

return M
