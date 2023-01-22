local M = {
  'kevinhwang91/nvim-ufo',
  event = { 'BufRead', 'BufNewFile' },
  dependencies = { 'kevinhwang91/promise-async' },
}

function M.init()
  local ufo = require('ufo')
  rvim.nnoremap('zR', ufo.openAllFolds, 'open all folds')
  rvim.nnoremap('zM', ufo.closeAllFolds, 'close all folds')
  rvim.nnoremap('zP', ufo.peekFoldedLinesUnderCursor, 'preview fold')
end

function M.config()
  local ufo = require('ufo')
  local hl = require('user.utils.highlights')
  local opt, strwidth = vim.opt, vim.api.nvim_strwidth

  local function handler(virt_text, _, end_lnum, width, truncate, ctx)
    local result = {}
    local padding = ''
    local cur_width = 0
    local suffix_width = strwidth(ctx.text)
    local target_width = width - suffix_width

    for _, chunk in ipairs(virt_text) do
      local chunk_text = chunk[1]
      local chunk_width = strwidth(chunk_text)
      local cond = target_width > cur_width + chunk_width
      if cond then table.insert(result, chunk) end
      if not cond then
        chunk_text = truncate(chunk_text, target_width - cur_width)
        local hl_group = chunk[2]
        table.insert(result, { chunk_text, hl_group })
        chunk_width = strwidth(chunk_text)
        if cur_width + chunk_width < target_width then
          padding = padding .. (' '):rep(target_width - cur_width - chunk_width)
        end
        break
      end
      cur_width = cur_width + chunk_width
    end

    local end_text = ctx.get_fold_virt_text(end_lnum)
    -- reformat the end text to trim excess whitespace from indentation usually the first item is indentation
    if end_text[1] and end_text[1][1] then end_text[1][1] = end_text[1][1]:gsub('[%s\t]+', '') end

    table.insert(result, { ' ⋯ ', 'UfoFoldedEllipsis' })
    vim.list_extend(result, end_text)
    table.insert(result, { padding, '' })
    return result
  end

  opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
  opt.foldlevelstart = 99

  -- Don't add folds to sessions because they are added asynchronously and if the file does not
  -- exist on a git branch for which the folds where saved it will cause an error on startup
  -- opt.sessionoptions:append('folds')

  hl.plugin('ufo', {
    { Folded = { bold = false, italic = false, bg = { from = 'CursorLine' } } },
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
    enable_get_fold_virt_text = true,
    provider_selector = function() return { 'treesitter', 'indent' } end,
    preview = {
      win_config = {
        border = rvim.style.border.current,
        winhighlight = 'Normal:VertSplit,FloatBorder:VertSplit',
      },
    },
  })
end

return M
