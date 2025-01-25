return {
  {
    'tribela/transparent.nvim',
    cond = ar_config.ui.transparent.enable,
    event = 'VimEnter',
    opts = {
      extra_groups = {
        'PopupNormal',
        'PopupBorder',
        'NormalFloat',
        'FloatBorder',
        'NeoTreeTabInactive',
        'NoiceMini',
        'NoicePopupBaseGroup',
        'NoicePopupWarnBaseGroup',
        'NoicePopupInfoBaseGroup',
        'NoiceCmdlinePopup',
        'NoiceCmdlinePopupBorder',
        'NoiceFormatProgressDone',
        'NoiceFormatProgressTodo',
        'NoiceLspProgressClient',
        'NoiceLspProgressSpinner',
        'NoiceLspProgressTitle',
        'NoiceFormatEvent',
        'NoiceConfirm',
        'NoiceConfirmBorder',
        'MarkviewCode',
        'MarkviewInlineCode',
        'PickerBorder',
        'PickerPromptNormal',
        'PickerPromptBorder',
        'PickerResultsNormal',
        'PickerResultsBorder',
        'PickerPreviewNormal',
        'PickerPreviewBorder',
        'PickerSelection',
      },
    },
    config = function(_, opts)
      require('transparent').setup(opts)

      ar.highlight.plugin('transparent', {
        theme = {
          ['onedark'] = {
            { MarkviewCode = { link = 'NormalFloat' } },
            { MarkviewInlineCode = { link = 'NormalFloat' } },
            { FloatBorder = { link = 'WinSeparator' } },
            { PickerBorder = { link = 'WinSeparator' } },
            { PickerPromptBorder = { link = 'WinSeparator' } },
            { PickerResultsBorder = { link = 'WinSeparator' } },
            { PickerPreviewBorder = { link = 'WinSeparator' } },
            { PopupBorder = { link = 'FloatBorder' } },
            {
              NoicePopupBaseGroup = {
                fg = { from = 'Directory', alter = -0.25 },
              },
            },
            { NoicePopupWarnBaseGroup = { link = 'NoicePopupBaseGroup' } },
            { NoicePopupInfoBaseGroup = { link = 'NoicePopupBaseGroup' } },
          },
        },
      })
    end,
  },
}
