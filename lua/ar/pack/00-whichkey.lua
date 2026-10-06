if not ar.get_plugin_cond('which-key.nvim') then return end

---Set up plugin-specific groups cleanly with the plugin config.
---@param spec wk.Spec
vim.g.whichkey_add_spec = function(spec)
  if not ar.has('which-key.nvim') then return end
  local ok, _ = pcall(require, 'which-key')
  if not ok then return end
  -- Deferred to ensure spec is loaded after whichkey itself
  vim.defer_fn(function() require('which-key').add(spec) end, 1500)
end

vim.pack.add({ 'https://github.com/folke/which-key.nvim' }, { confirm = false })

local function get_opts()
  local opts = {
    icons = {
      rules = false,
      keys = { CR = '↪', TAB = '→', Space = '󱁐 ' },
    },
    preset = 'helix',
    defaults = {},
    spec = {
      {
        mode = { 'n' },
        { '<leader>[', group = 'Replace all' },
        { '<leader>]', group = 'Replace in line' },
        { '<leader>A', group = 'Animations' },
        { '<leader>F', group = 'Picker (Current Dir)' },
        { '<leader>a', group = 'A.I.' },
        { '<leader>e', group = 'Explorer' },
        { '<leader>f', group = 'Picker' },
        { '<leader>fg', group = 'Git' },
        { '<leader>fl', group = 'Lazy' },
        { '<leader>fq', group = 'List' },
        { '<leader>fv', group = 'Vim' },
        { '<leader>g', group = 'Git' },
        { '<leader>gb', group = 'Blame' },
        { '<leader>go', group = 'Open' },
        { '<leader>gs', group = 'Stash' },
        { '<leader>gy', group = 'Yank' },
        { '<leader>h', group = 'Gitsigns' },
        { '<leader>i', group = 'Toggler/Swap' },
        { '<leader>L', group = 'List' },
        { '<leader>ls', group = 'Symbols' },
        { '<leader>m', group = 'Marks' },
        { '<leader>n', group = 'Notify' },
        { '<leader>o', group = 'UI select' },
        { '<leader>p', group = 'Print/Log' },
        { '<leader>q', group = 'Quit/Session' },
        { '<leader>r', group = 'Run' },
        { '<leader>s', group = 'Splits' },
        { '<leader>u', group = 'UI' },
        { '<leader>v', group = 'Vim' },
        { '<leader>w', group = 'Window' },
        { '<localleader>a', group = 'Actions' },
        { '<localleader>b', group = 'Buffer' },
        { '<localleader>c', group = 'Conceal' },
        { '<localleader>g', group = 'Git' },
        { '<localleader>gd', group = 'Diff' },
        { '<localleader>go', group = 'Open' },
        { '<localleader>gy', group = 'Yank' },
        { '<localleader>lr', group = 'Rulebook' },
        { '<localleader>m', group = 'Markdown' },
        { '<localleader>n', group = 'Neogen/Notifications' },
        { '<localleader>o', group = 'Open' },
        { '<localleader>r', group = 'Run' },
        { '<leader><leader>', group = 'Advanced' },
        { '<leader><leader>f', group = 'File' },
        { '<leader><leader>g', group = 'Git' },
        { '<leader><leader>gh', group = 'History' },
        { '<leader><leader>gi', group = 'Issues' },
        { '<leader><leader>go', group = 'Open' },
        { '<leader><leader>m', desc = 'Markdown' },
        { '<leader><leader>n', group = 'Sticky Note' },
        { '<leader><localleader>', group = 'Advanced' },
        { '<localleader><leader>', group = 'Advanced' },
      },
      {
        mode = { 'x' },
        { '<leader><leader>', group = 'Advanced' },
        { '<leader>a', group = 'Actions' },
        { '<leader>d', group = 'Delete' },
        { '<leader>f', group = 'File' },
        { '<leader>g', group = 'Git' },
        { '<leader>go', group = 'Open' },
        { '<leader>h', group = 'Hunk' },
        { '<leader>r', group = 'Run' },
        { '<leader>u', group = 'UI' },
        { '<localleader>a', group = 'A.I.' },
        { '<localleader>g', group = 'Git' },
        { '<localleader>h', group = 'Gitsigns' },
        { '<localleader>p', group = 'Share' },
        { '<leader><leader>m', desc = 'Markdown' },
        { '<leader><leader>ml', desc = 'Link' },
      },
    },
  }
  if opts.preset == 'classic' then
    opts.layout = { align = 'center' }
    opts.win = {
      col = 0.5,
      height = { min = 10, max = 25 },
      border = ar.ui.current.border.default,
      wo = {
        winblend = ar.config.ui.transparent.enable and 0 or 12, -- value between 0-100 0 for fully opaque and 100 for fully transparent
      },
    }
  end
  return opts
end

local function show(o)
  o = o or {}
  return function() require('which-key').show(o) end
end

local function load()
  vim.schedule(function()
    if vim.v.exiting ~= vim.NIL then return end

    vim.pack.add({
      'https://github.com/folke/which-key.nvim',
    }, { confirm = false })

    require('which-key').setup(get_opts())

    if ar.lsp.enable then
      vim.g.whichkey_add_spec({
        { '<leader>la', group = 'Code Actions', mode = { 'n', 'x' } },
      })

      if ar.has('mason.nvim') or ar.has('conform.nvim') then
        vim.g.whichkey_add_spec({
          { '<leader>l', group = 'LSP', mode = { 'n', 'x' } },
          { '<localleader>l', group = 'LSP', mode = { 'n', 'x' } },
        })
      end
    end
  end)
end

if vim.v.vim_did_enter == 1 then
  load()
else
  vim.api.nvim_create_autocmd('UIEnter', {
    once = true,
    callback = load,
  })
end

-- stylua: ignore start
map('n', '<leader>?', show({ global = false }), { desc = 'which-key: buffer keymaps' })
map('n', '<c-w><space>', show({ keys = '<c-w', loop = true }), { desc = 'which-key: window hydra mode' })
map('n', '<leader>wk', '<Cmd>WhichKey<CR>', { desc = 'which-key: all keymaps' })
-- stylua: ignore end
