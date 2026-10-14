local fn = vim.fn
local coding = ar.plugins.coding

local function expand_or_jump()
  local ls = require('luasnip')
  if ls.expand_or_locally_jumpable() then
    vim.schedule(function() ls.expand_or_jump() end)
    return true
  else
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes('<c-i>', true, false, true),
      'n',
      false
    )
  end
end

local function jump_prev()
  local ls = require('luasnip')
  if ls.jumpable(-1) then
    vim.schedule(function() ls.jump(-1) end)
    return true
  end
end

local function change_choice()
  local ls = require('luasnip')
  if ls.choice_active() then
    vim.schedule(function() ls.change_choice(1) end)
    return true
  end
end

local function get_snippets_list()
  local modules_dir =
    vim.fs.joinpath(fn.stdpath('config'), 'lua', 'ar', 'snippets')
  local tmp = vim.split(fn.globpath(modules_dir, '*.lua'), '\n')
  return vim
    .iter(tmp)
    :map(function(f) return string.match(f, 'lua/(.+).lua$') end)
    :totable()
end

local function get_cond() return ar.get_plugin_cond('LuaSnip', coding) end

local friendly = ar.get_plugin_cond(
  'friendly-snippets',
  coding and ar.config.completion.snippets.variant == 'friendly-snippets'
)
if friendly then
  vim.pack.add(
    { 'https://github.com/rafamadriz/friendly-snippets' },
    { confirm = false }
  )
end

if ar.get_plugin_cond('nvim-snips') then
  vim.pack.add({
    'https://github.com/razak17/nvim-ts-utils',
    { src = 'https://github.com/s1n7ax/nvim-snips', name = 'snips' },
  }, { confirm = false })
end
if not get_cond() then return end

local function build(path)
  local result = vim
    .system({ 'make', 'install_jsregexp' }, { cwd = path, text = true })
    :wait()
  if result.code ~= 0 then
    error('LuaSnip jsregexp build failed: ' .. (result.stderr or ''))
  end
end
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('LuaSnipBuild', { clear = true }),
  callback = function(event)
    local data = event.data
    if
      data.spec.name == 'LuaSnip'
      and (data.kind == 'install' or data.kind == 'update')
    then
      build(data.path)
    end
  end,
})

local loaded = false
local function load()
  if loaded then return end
  vim.pack.add({ 'https://github.com/L3MON4D3/LuaSnip' }, { confirm = false })
  local ls = require('luasnip')
  local types = require('luasnip.util.types')
  local extras = require('luasnip.extras')
  local fmt = require('luasnip.extras.fmt').fmt

  ls.config.set_config({
    history = false,
    region_check_events = 'CursorMoved,CursorHold,InsertEnter',
    delete_check_events = 'InsertLeave',
    cut_selection_keys = '<C-x>',
    ext_opts = {
      [types.choiceNode] = {
        active = {
          virt_text = { { ' ', 'TSTextReference' } },
        },
      },
      [types.insertNode] = {
        active = {
          virt_text = { { ' ', 'TSEmphasis' } },
        },
      },
    },
    enable_autosnippets = ar.config.completion.variant ~= 'native',
    snip_env = {
      fmt = fmt,
      m = extras.match,
      t = ls.text_node,
      f = ls.function_node,
      c = ls.choice_node,
      d = ls.dynamic_node,
      i = ls.insert_node,
      l = extras.lambda,
      snippet = ls.snippet,
    },
  })

  require('luasnip.loaders.from_lua').lazy_load()

  local paths = {
    vim.fs.joinpath(fn.stdpath('config'), 'snippets'),
  }

  if friendly then
    paths = vim.list_extend(paths, {
      vim.pack.get({ 'friendly-snippets' })[1].path,
    })
  end

  require('luasnip.loaders.from_vscode').lazy_load({ paths = paths })

  ls.filetype_extend('NeogitCommitMessage', { 'gitcommit' })

  if ar.treesitter.enable and ar.has('snips') then
    local snippets_list = get_snippets_list()
    for _, module_path in ipairs(snippets_list) do
      local ok, snip = pcall(require, module_path)
      if ok then snip.setup() end
    end
  end
  loaded = true
end
ar.snippets = { load = load }

vim.api.nvim_create_autocmd('InsertEnter', { once = true, callback = load })
local mappings = {
  {
    '<leader>S',
    function() require('luasnip.loaders').edit_snippet_files() end,
    desc = 'LuaSnip: edit snippet',
  },
  {
    '<C-l>',
    expand_or_jump,
    desc = 'LuaSnip: expand or jump',
    mode = { 'i', 's' },
  },
  { '<C-b>', jump_prev, desc = 'LuaSnip: jump prev', mode = { 's' } },
  {
    '<C-/>',
    change_choice,
    desc = 'LuaSnip: change choice',
    mode = { 'i', 's' },
  },
}
for _, mapping in ipairs(mappings) do
  vim.keymap.set(mapping.mode or 'n', mapping[1], function()
    load()
    return mapping[2]()
  end, { desc = mapping.desc })
end

if ar.config.completion.variant == 'blink' then
  ar.pack.blink_opts = vim.tbl_deep_extend('force', ar.pack.blink_opts or {}, {
    snippets = {
      preset = 'luasnip',
      expand = function(snippet)
        load()
        require('luasnip').lsp_expand(snippet)
      end,
      active = function(filter)
        load()
        if filter and filter.direction then
          return require('luasnip').jumpable(filter.direction)
        end
        return require('luasnip').in_snippet()
      end,
      jump = function(direction)
        load()
        require('luasnip').jump(direction)
      end,
    },
  })
end

if
  ar.get_plugin_cond(
    'telescope-luasnip.nvim',
    ar.config.picker.variant == 'telescope'
  )
then
  vim.keymap.set('n', '<leader>fS', function()
    load()
    if not require('ar.pack.telescope') then return end
    vim.pack.add(
      { 'https://github.com/benfowler/telescope-luasnip.nvim' },
      { confirm = false }
    )
    vim.g.telescope_add_extension({ 'luasnip' })
    require('telescope').extensions.luasnip.luasnip({})
  end, { desc = 'luasnip: available snippets' })
end
