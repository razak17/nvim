local fmt = string.format

local function get_cond(plugin)
  local cond = not ar.plugins.minimal and ar.lsp.enable
  return function() return ar.get_plugin_cond(plugin, cond) end
end

ar.pack.add({
  {
    src = 'https://github.com/dnlhc/glance.nvim',
    cond = get_cond('glance.nvim'),
    cmd = { 'Glance' },
    setup = function()
      require('glance').setup({
        preview_win_opts = { relativenumber = false },
      })

      ar.highlight.plugin('glance', {
        theme = {
          ['onedark'] = {
            { GlancePreviewNormal = { link = 'NormalFloat' } },
            -- { GlancePreviewMatch = { link = 'Comment' } },
            { GlanceListMatch = { link = 'Search' } },
          },
        },
      })
    end,
  },
  {
    src = 'https://github.com/rmagatti/goto-preview',
    cond = get_cond('goto-preview'),
    keys = {
      {
        'gpd',
        '<Cmd>lua require("goto-preview").goto_preview_definition()<CR>',
        desc = 'goto preview: definition',
      },
      {
        'gpt',
        '<Cmd>lua require("goto-preview").goto_preview_type_definition()<CR>',
        desc = 'goto preview: type definition',
      },
      {
        'gpi',
        '<Cmd>lua require("goto-preview").goto_preview_implementation()<CR>',
        desc = 'goto preview: implementation',
      },
      {
        'gpD',
        '<Cmd>lua require("goto-preview").goto_preview_declaration()<CR>',
        desc = 'goto preview: declaration',
      },
      {
        'gpr',
        '<Cmd>lua require("goto-preview").goto_preview_references()<CR>',
        desc = 'goto preview: references',
      },
      {
        'gpx',
        '<Cmd>lua require("goto-preview").close_all_win()<CR>',
        desc = 'goto preview: close all windows',
      },
      {
        'gpo',
        '<Cmd>lua require("goto-preview").close_all_win({ skip_curr_window = true })<CR>',
        desc = 'goto preview: close other windows',
      },
    },
    event = 'LspAttach',
    dependencies = {
      { src = 'https://github.com/rmagatti/logger.nvim' },
    },
    setup = function() require('goto-preview').setup() end,
  },
  {
    src = 'https://github.com/pechorin/any-jump.vim',
    cond = get_cond('any-jump.vim'),
    cmd = { 'AnyJump', 'AnyJumpArg', 'AnyJumpBack', 'AnyJumpLastResults' },
    init = function()
      vim.g.any_jump_disable_default_keybindings = 1
      vim.g.whichkey_add_spec({ '<leader>j', group = 'Any Jump' })
      ar.add_to_select('lsp', {
        ['Jump To Keyword'] = function()
          vim.ui.input({
            prompt = 'Keyword: ',
            default = '',
            completion = 'keyword',
          }, function(keyword)
            if not keyword or keyword == '' then return end
            vim.cmd(fmt('AnyJumpArg %s', keyword))
          end)
        end,
      })
    end,
    keys = {
      { '<leader>jj', '<Cmd>AnyJump<CR>', desc = 'any-jump: jump' },
      {
        mode = { 'x' },
        '<leader>jj',
        '<Cmd>AnyJumpVisual<CR>',
        desc = 'any-jump: jump',
      },
      { '<leader>jb', '<Cmd>AnyJumpBack<CR>', desc = 'any-jump: back' },
      {
        '<leader>jl',
        '<Cmd>AnyJumpLastResults<CR>',
        desc = 'any-jump: resume',
      },
    },
  },
})
