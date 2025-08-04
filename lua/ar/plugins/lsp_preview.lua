local fmt = string.format

return {
  {
    -- 'razak17/glance.nvim',
    'dnlhc/glance.nvim',
    cond = ar.lsp.enable,
    cmd = { 'Glance' },
    -- stylua: ignore
    -- keys = {
      --   { 'gD', '<Cmd>Glance definitions<CR>', desc = 'lsp: glance definitions' },
      --   { 'gR', '<Cmd>Glance references<CR>', desc = 'lsp: glance references' },
      --   { 'gY', '<Cmd>Glance type_definitions<CR>', desc = 'lsp: glance type definitions' },
      --   { 'gM', '<Cmd>Glance implementations<CR>', desc = 'lsp: glance implementations' },
      -- },
    config = function()
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
    'rmagatti/goto-preview',
    cond = ar.lsp.enable,
    -- stylua: ignore
    keys = {
      { 'gpd', '<Cmd>lua require("goto-preview").goto_preview_definition()<CR>', desc = 'goto preview: definition' },
      { 'gpt', '<Cmd>lua require("goto-preview").goto_preview_type_definition()<CR>', desc = 'goto preview: type definition' },
      { 'gpi', '<Cmd>lua require("goto-preview").goto_preview_implementation()<CR>', desc = 'goto preview: implementation' },
      { 'gpD', '<Cmd>lua require("goto-preview").goto_preview_declaration()<CR>', desc = 'goto preview: declaration' },
      { 'gpr', '<Cmd>lua require("goto-preview").goto_preview_references()<CR>', desc = 'goto preview: references' },
      { 'gpx', '<Cmd>lua require("goto-preview").close_all_win()<CR>', desc = 'goto preview: close all windows' },
      { 'gpo', '<Cmd>lua require("goto-preview").close_all_win({ skip_curr_window = true })<CR>', desc = 'goto preview: close other windows' },
    },
    event = 'LspAttach',
    opts = {},
    dependencies = { 'rmagatti/logger.nvim' },
  },
  {
    'pechorin/any-jump.vim',
    cond = ar.lsp.enable,
    cmd = { 'AnyJump', 'AnyJumpArg', 'AnyJumpBack', 'AnyJumpLastResults' },
    init = function()
      vim.g.any_jump_disable_default_keybindings = 1
      vim.g.whichkey_add_spec({ '<leader>j', group = 'Any Jump' })
      ar.add_to_select_menu('lsp', {
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
    -- stylua: ignore
    keys = {
      { '<leader>jj', '<Cmd>AnyJump<CR>', desc = 'any-jump: jump' },
      { mode = { 'x' }, '<leader>jj', '<Cmd>AnyJumpVisual<CR>', desc = 'any-jump: jump' },
      { '<leader>jb', '<Cmd>AnyJumpBack<CR>', desc = 'any-jump: back' },
      { '<leader>jl', '<Cmd>AnyJumpLastResults<CR>', desc = 'any-jump: resume' },
    },
  },
}
