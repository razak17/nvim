if not ar.get_plugin_cond('sidekick.nvim', ar.ai.enable) then return end

local tiny_diags_disabled_by_nes = false
local load
local keys

local function setup()
  local opts = {
    nes = {
      enabled = true,
    },
    mux = {
      backend = 'tmux',
      enabled = true,
    },
    cli = {
      win = {
        keys = {
          stopinsert = { '<esc>', 'stopinsert', mode = 't' }, -- enter normal mode
          win_p = { '<M-Left>', 'blur' },
        },
      },
    },
  }
  require('sidekick').setup(opts)

  if ar.has('tiny-inline-diagnostic.nvim') then
    vim.api.nvim_create_autocmd('User', {
      pattern = 'SidekickNesHide',
      callback = function()
        if tiny_diags_disabled_by_nes then
          tiny_diags_disabled_by_nes = false
          require('tiny-inline-diagnostic').enable()
        end
      end,
    })

    vim.api.nvim_create_autocmd('User', {
      pattern = 'SidekickNesShow',
      callback = function()
        tiny_diags_disabled_by_nes = true
        require('tiny-inline-diagnostic').disable()
      end,
    })
  end
  -- Replace the bootstrap mapping with the real expression mapping.
  map('n', keys[1][1], keys[1][2], { expr = true, desc = keys[1].desc })
end

if vim.g.whichkey_add_spec then
  vim.g.whichkey_add_spec({
    '<leader>as',
    group = 'Sidekick',
    mode = { 'n', 'x' },
  })
end

keys = {
  {
    '<tab>',
    function()
      -- if there is a next edit, jump to it, otherwise apply it if any
      if not require('sidekick').nes_jump_or_apply() then
        return '<Tab>' -- fallback to normal tab
      end
    end,
    expr = true,
    desc = 'sidekick: goto/apply next edit suggestion',
  },
  {
    '<leader>aso',
    function() require('sidekick.cli').toggle() end,
    desc = 'sidekick: toggle cli',
  },
  {
    '<leader>asw',
    function() require('sidekick.cli').select() end,
    -- Or to select only installed tools:
    -- require("sidekick.cli").select({ filter = { installed = true } })
    desc = 'sidekick: select cli',
  },
  {
    '<leader>ass',
    function() require('sidekick.cli').send({ msg = '{this}' }) end,
    mode = { 'x', 'n' },
    desc = 'sidekick: send this',
  },
  {
    '<leader>asv',
    function() require('sidekick.cli').send({ msg = '{selection}' }) end,
    mode = { 'x' },
    desc = 'sidekick: send visual selection',
  },
  {
    '<leader>asp',
    function() require('sidekick.cli').prompt() end,
    mode = { 'n', 'x' },
    desc = 'sidekick: select prompt',
  },
  {
    '<leader>asf',
    function() require('sidekick.cli').send({ msg = '{file}' }) end,
    desc = 'sidekick: send file',
  },
  {
    '<leader>asq',
    function() require('sidekick.cli').close() end,
    mode = { 'n', 'x' },
    desc = 'sidekick: close',
  },
  {
    '<c-.>',
    function() require('sidekick.cli').focus() end,
    mode = { 'n', 't', 'i', 'x' },
    desc = 'sidekick: focus',
  },
}

ar.pack.add({
  src = 'https://github.com/folke/sidekick.nvim',
  setup = setup,
  keys = function(loader)
    load = loader
    for _, key in ipairs(keys) do
      if key.expr then
        map(key.mode or 'n', key[1], function()
          load()
          vim.api.nvim_feedkeys(vim.keycode(key[1]), 'mi', false)
        end, { desc = key.desc })
      else
        map(key.mode or 'n', key[1], function()
          load()
          return key[2]()
        end, { desc = key.desc })
      end
    end
  end,
})

ar.pack.snacks_opts = vim.tbl_deep_extend('force', ar.pack.snacks_opts or {}, {
  picker = {
    actions = {
      sidekick_send = function(...)
        load()
        return require('sidekick.cli.picker.snacks').send(...)
      end,
    },
    win = {
      input = {
        keys = {
          ['<a-a>'] = {
            'sidekick_send',
            mode = { 'n', 'i' },
          },
        },
      },
    },
  },
})
