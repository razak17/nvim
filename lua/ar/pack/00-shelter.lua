local minimal = ar.plugins.minimal
local variant = ar.config.shelter.variant
local is_fzf = ar.config.picker.variant == 'fzf-lua'
local is_snacks = ar.config.picker.variant == 'snacks'
local is_blink = ar.config.completion.variant == 'blink'

local function get_cond(plugin, which)
  local condition = ar.config.shelter.enable and variant == which
  return ar.get_plugin_cond(plugin, condition)
end

if ar.get_plugin_cond('obfuscate.nvim', not minimal) then
  vim.pack.add(
    { 'https://github.com/ck-zhang/obfuscate.nvim' },
    { confirm = false }
  )
  ar.add_to_select(
    'toggle',
    { ['Toggle Obfuscate'] = 'lua require("obfuscate").toggle()' }
  )
end

if get_cond('camouflage.nvim', 'camouflage') then
  vim.pack.add(
    { 'https://github.com/zeybek/camouflage.nvim' },
    { confirm = false }
  )
  ar.add_to_select('toggle', { ['Toggle Camouflage'] = 'CamouflageToggle' })
  require('camouflage').setup({
    enabled = true,
    style = 'stars',
    integrations = {
      telescope = false,
      cmp = { disable_in_masked = false },
    },
    pwned = {
      enabled = true,
      auto_check = false,
      check_on_save = true,
      check_on_change = true,
      show_sign = true,
    },
  })
end

if get_cond('cloak.nvim', 'cloak') then
  vim.pack.add({ 'https://github.com/laytan/cloak.nvim' }, { confirm = false })
  ar.add_to_select('toggle', { ['Toggle Cloak'] = 'CloakToggle' })
  require('cloak').setup({
    patterns = {
      {
        file_pattern = {
          '.env*',
          '*.env.*',
          '*.secret.*',
          'secrets',
        },
        cloak_pattern = '=.+',
      },
    },
  })
end

if get_cond('shelter.nvim', 'shelter') then
  -- Detect filetypes before early BufReadPost redraws (for example, Quickfile).
  vim.cmd('filetype on')
  vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('ShelterBuild', { clear = true }),
    callback = function(event)
      local data = event.data
      if
        data.spec.name == 'shelter.nvim'
        and (data.kind == 'install' or data.kind == 'update')
      then
        vim.cmd.packadd('shelter.nvim')
        vim.cmd('ShelterBuild')
      end
    end,
  })
  vim.pack.add(
    { 'https://github.com/razak17/shelter.nvim' },
    { confirm = false }
  )
  ar.add_to_select('toggle', {
    ['Toggle Shelter'] = 'Shelter toggle',
  })
  ar.add_to_select('command_palette', {
    ['Shelter Peek'] = 'Shelter peek',
  })
  require('shelter').setup({
    default_mode = 'full', -- 'partial' | 'full' | 'none'
    env_filetypes = { 'dotenv', 'sh', 'conf', 'config', 'env' },
    highlight_group = 'Comment',
    mask_char = '*',
    skip_comments = false,
    modules = {
      files = {
        shelter_on_leave = true,
        disable_cmp = function() return ar.has('blink.cmp') end,
      },
      fzf_previewer = function() return ar.has('fzf-lua') end,
      snacks_previewer = function() return ar.has('snacks.nvim') end,
      telescope_previewer = function() return ar.has('telescope.nvim') end,
    },
  })
end

if get_cond('ecolog.nvim', 'ecolog') then
  vim.pack.add(
    { 'https://github.com/ph1losof/ecolog.nvim' },
    { confirm = false }
  )
  ar.add_to_select('toggle', {
    ['Toggle Ecolog Shelter'] = 'EcologShelterToggle',
  })
  ar.add_to_select('command_palette', {
    ['Ecolog Select'] = 'EcologSelect',
    ['Ecolog Goto'] = 'EcologGoto',
    ['Ecolog Goto Var'] = 'EcologGotoVar',
  })
  if ar.config.completion.variant == 'native' then
    ar.augroup('EcologNativeComp', {
      event = { 'FileType' },
      pattern = { 'javascript', 'typescript', 'python', 'lua' },
      command = function(args)
        vim.api.nvim_set_option_value(
          'omnifunc',
          "v:lua.require'ecolog.integrations.cmp.omnifunc'.complete",
          { buf = args.buf }
        )
      end,
    })
  end
  require('ecolog').setup({
    load_shell = true,
    vim_env = true,
    preferred_environment = 'local',
    types = true,
    integrations = {
      telescope = function() return ar.has('telescope.nvim') end,
      fzf = function() return is_fzf and ar.has('fzf-lua') end,
      snacks = function() return is_snacks and ar.has('snacks.nvim') end,
      nvim_cmp = function()
        return ar.config.completion.variant == 'cmp' and ar.has('nvim-cmp')
      end,
      blink_cmp = function() return is_blink and ar.has('blink.cmp') end,
      -- blink_cmp = true,
      omnifunc = { auto_setup = false },
      lspsaga = false,
      lsp = false, -- TODO: check this out later
      statusline = true,
    },
    shelter = {
      configuration = { partial_mode = true, mask_char = '*' },
      modules = {
        files = true,
        peek = false,
        cmp = true,
        telescope = ar.has('telescope.nvim'),
        telescope_previewer = ar.has('telescope.nvim'),
        fzf = is_fzf,
        fzf_previewer = is_fzf,
        snacks = is_snacks,
        snacks_previewer = is_snacks,
      },
    },
    path = vim.fn.getcwd(),
  })
  map(
    'n',
    '<leader>ep',
    '<Cmd>EcologPeek<CR>',
    { desc = 'ecolog: peek variable' }
  )
  map(
    'n',
    '<leader>el',
    '<Cmd>EcologShelterLinePeek<CR>',
    { desc = 'ecolog: peek line' }
  )
  if is_snacks then
    map('n', '<leader>f;', '<Cmd>EcologSnacks<CR>', { desc = 'snacks: ecolog' })
  elseif is_fzf then
    map('n', '<leader>f;', '<Cmd>EcologFzf<CR>', { desc = 'picker: ecolog' })
  elseif ar.config.picker.variant == 'telescope' then
    map('n', '<leader>f;', function()
      local telescope = require('telescope')
      telescope.load_extension('ecolog')
      telescope.extensions.ecolog.env(ar.telescope.minimal_ui())
    end, { desc = 'ecolog' })
  end
end
