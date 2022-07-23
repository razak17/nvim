return function()
  local ufo = require('ufo')
  local hl = require('zephyr.utils')
  local opt, get_width = vim.opt, vim.api.nvim_strwidth

  local function handler(virt_text, _, _, width, truncate, ctx)
    local result = {}
    local padding = ''
    local cur_width = 0
    local suffix_width = get_width(ctx.text)
    local target_width = width - suffix_width

    for _, chunk in ipairs(virt_text) do
      local chunk_text = chunk[1]
      local chunk_width = get_width(chunk_text)
      if target_width > cur_width + chunk_width then
        table.insert(result, chunk)
      else
        chunk_text = truncate(chunk_text, target_width - cur_width)
        local hl_group = chunk[2]
        table.insert(result, { chunk_text, hl_group })
        chunk_width = get_width(chunk_text)
        if cur_width + chunk_width < target_width then
          padding = padding .. (' '):rep(target_width - cur_width - chunk_width)
        end
        break
      end
      cur_width = cur_width + chunk_width
    end

    local end_text = ctx.end_virt_text
    -- reformat the end text to trim excess whitespace from indentation usually the first item is indentation
    if end_text[1] and end_text[1][1] then end_text[1][1] = end_text[1][1]:gsub('[%s\t]+', '') end

    table.insert(result, { ' ⋯ ', 'NonText' })
    vim.list_extend(result, end_text)
    table.insert(result, { padding, '' })
    return result
  end

  opt.foldlevelstart = 99
  opt.sessionoptions:append('folds')

  hl.plugin('ufo', {
    Folded = {
      bold = false,
      italic = false,
      bg = hl.alter_color(hl.get('Normal', 'bg'), -7),
    },
  })

  rvim.augroup('UfoSettings', {
    {
      event = { 'FileType' },
      pattern = { 'org' },
      command = function() ufo.detach() end,
    },
  })

  ufo.setup({
    open_fold_hl_timeout = 0,
    fold_virt_text_handler = handler,
    enable_fold_end_virt_text = true,
    provider_selector = function() return { 'treesitter', 'indent' } end,
    preview = {
      win_config = {
        winhighlight = 'Normal:Normal,FloatBorder:Normal',
      },
    },
  })
  rvim.nnoremap('zR', ufo.openAllFolds, 'open all folds')
  rvim.nnoremap('zM', ufo.closeAllFolds, 'close all folds')
  -- rvim.nnoremap('zP', ufo.peekFoldedLinesUnderCursor, 'preview fold')
end
