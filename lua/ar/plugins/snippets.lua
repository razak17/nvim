local fn = vim.fn
local coding = ar.plugins.coding

local function expand_or_jump()
  local ls = require('luasnip')
  if ls.expand_or_locally_jumpable() then
    vim.schedule(function() ls.expand_or_jump(1) end)
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
  local modules_dir = join_paths(fn.stdpath('config'), 'lua', 'ar', 'snippets')
  local tmp = vim.split(fn.globpath(modules_dir, '*.lua'), '\n')
  return vim
    .iter(tmp)
    :map(function(f) return string.match(f, 'lua/(.+).lua$') end)
    :totable()
end

local function get_cond() return ar.get_plugin_cond('LuaSnip', coding) end

return {
  {
    'rafamadriz/friendly-snippets',
    cond = function()
      local cond = coding
        and ar_config.completion.snippets.variant == 'friendly-snippets'
      return ar.get_plugin_cond('friendly-snippets', cond)
    end,
  },
  {
    's1n7ax/nvim-snips',
    name = 'snips',
    dependencies = { 'razak17/nvim-ts-utils' },
  },
  {
    {
      'L3MON4D3/LuaSnip',
      cond = get_cond,
      event = 'InsertEnter',
      build = 'make install_jsregexp',
      -- stylua: ignore
      keys = {
        { '<leader>S', function() require('luasnip.loaders').edit_snippet_files() end, desc = 'LuaSnip: edit snippet' },
        { '<C-l>', expand_or_jump, desc = 'LuaSnip: expand or jump', mode = { 'i', 's' } },
        { '<C-b>', jump_prev, desc = 'LuaSnip: jump prev', mode = { 's' } },
        { '<C-/>', change_choice, desc = 'LuaSnip: change choice', mode = { 'i', 's' } },
      },
      config = function()
        local ls = require('luasnip')
        local types = require('luasnip.util.types')
        local extras = require('luasnip.extras')
        local fmt = require('luasnip.extras.fmt').fmt

        ls.config.set_config({
          history = false,
          region_check_events = 'CursorMoved,CursorHold,InsertEnter',
          delete_check_events = 'InsertLeave',
          ext_opts = {
            [types.choiceNode] = {
              active = {
                hl_mode = 'combine',
                virt_text = { { '●', 'Operator' } },
              },
            },
            [types.insertNode] = {
              active = {
                hl_mode = 'combine',
                virt_text = { { '●', 'Type' } },
              },
            },
          },
          enable_autosnippets = true,
          snip_env = {
            fmt = fmt,
            m = extras.match,
            t = ls.text_node,
            f = ls.function_node,
            c = ls.choice_node,
            d = ls.dynamic_node,
            i = ls.insert_node,
            l = extras.lamda,
            snippet = ls.snippet,
          },
        })

        require('luasnip').config.setup({ store_selection_keys = '<C-x>' })

        require('luasnip.loaders.from_lua').lazy_load()

        local paths = {
          join_paths(fn.stdpath('config'), 'snippets', 'textmate'),
        }

        if ar_config.completion.snippets.variant == 'friendly-snippets' then
          paths = vim.list_extend(paths, {
            join_paths(fn.stdpath('data'), 'lazy', 'friendly-snippets'),
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
      end,
    },
    {
      'saghen/blink.cmp',
      optional = true,
      opts = function(_, opts)
        if not coding then return opts end
        opts = opts or {}
        opts.snippets = vim.tbl_deep_extend('force', opts.snippets or {}, {
          preset = 'luasnip',
          expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
          active = function(filter)
            if filter and filter.direction then
              return require('luasnip').jumpable(filter.direction)
            end
            return require('luasnip').in_snippet()
          end,
          jump = function(direction) require('luasnip').jump(direction) end,
        })
        return opts
      end,
    },
    {
      'hrsh7th/nvim-cmp',
      optional = true,
      dependencies = { 'saadparwaiz1/cmp_luasnip' },
      opts = function(_, opts)
        opts.snippet = {
          expand = function(args) require('luasnip').lsp_expand(args.body) end,
        }
        vim.g.cmp_add_source(opts, {
          source = {
            name = 'luasnip',
            priority = 900,
            group_index = 1,
          },
          menu = { luasnip = '[LSNIP]' },
        })
      end,
    },
  },
  {
    'nvim-telescope/telescope.nvim',
    optional = true,
    dependencies = {
      {
        'benfowler/telescope-luasnip.nvim',
        cond = function()
          local picker = ar_config.picker.variant
          local condition = picker == 'telescope' and get_cond()
          return ar.get_plugin_cond('telescope-luasnip.nvim', condition)
        end,
        keys = {
          {
            '<leader>fS',
            function() require('telescope').extensions.luasnip.luasnip({}) end,
            desc = 'luasnip: available snippets',
          },
        },
        specs = {
          'nvim-telescope/telescope.nvim',
          optional = true,
          opts = function(_, opts)
            vim.g.telescope_add_extension({ 'luasnip' }, opts)
          end,
        },
      },
    },
  },
}
