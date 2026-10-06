if
  not ar.get_plugin_cond('transparent.nvim', ar.config.ui.transparent.enable)
then
  return
end

local loaded = false

local cmd = { 'TransparentToggle', 'TransparentEnable', 'TransparentDisable' }

local function load()
  if loaded then return end
  for _, cmd in ipairs(cmd) do
    pcall(vim.api.nvim_del_user_command, cmd)
  end
  vim.pack.add(
    { 'https://github.com/tribela/transparent.nvim' },
    { confirm = false }
  )

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

  loaded = true
end

ar.add_to_select('toggle', { ['Toggle Transparency'] = 'TransparentToggle' })

ar.pack.cmd(cmd, load)

vim.api.nvim_create_autocmd({ 'VimEnter' }, {
  once = true,
  callback = load,
})
