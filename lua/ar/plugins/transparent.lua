return {
  {
    'tribela/transparent.nvim',
    cond = function()
      return ar.get_plugin_cond(
        'transparent.nvim',
        ar_config.ui.transparent.enable
      )
    end,
    init = function()
      ar.add_to_select_menu(
        'toggle',
        { ['Toggle Transparency'] = 'TransparentToggle' }
      )
    end,
    event = 'VimEnter',
    cmd = { 'TransparentToggle', 'TransparentEnable', 'TransparentDisable' },
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
        'PickerPrompt',
        'PickerPromptBorder',
        'PickerPreview',
        'PickerPreviewBorder',
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
