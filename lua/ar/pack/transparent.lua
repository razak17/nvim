if
  not ar.get_plugin_cond('transparent.nvim', ar.config.ui.transparent.enable)
then
  return
end

ar.pack.add({
  src = 'https://github.com/tribela/transparent.nvim',
  cmd = { 'TransparentToggle', 'TransparentEnable', 'TransparentDisable' },
  init = function()
    ar.add_to_select(
      'toggle',
      { ['Toggle Transparency'] = 'TransparentToggle' }
    )
  end,
  event = { 'VimEnter' },
  setup = function()
    ar.augroup('TransparentLightMode', {
      event = { 'ColorScheme' },
      command = function()
        local bg =
          vim.api.nvim_get_option_value('background', { scope = 'global' })
        if bg == 'light' then
          vim.schedule(function() vim.cmd('TransparentDisable') end)
        else
          vim.schedule(function() vim.cmd('TransparentEnable') end)
        end
      end,
    })

    require('transparent').setup({
      extra_groups = {
        'PopupNormal',
        'PopupBorder',
        'NormalFloat',
        'FloatBorder',
        'FloatShadow',
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
    })

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
})
