local models = ar_config.ai.models

local model_names = vim.tbl_keys(ar.ai.copilot_models)

local function get_copilot_providers()
  local providers_table = {
    copilot = {
      endpoint = 'https://api.githubcopilot.com',
      allow_insecure = false,
      timeout = 10 * 60 * 1000,
      extra_request_body = {
        temperature = 0,
        max_completion_tokens = 1000000,
        reasoning_effort = 'high',
      },
    },
  }
  for _, model_name in ipairs(model_names) do
    local provider_key = 'copilot-' .. model_name
    providers_table[provider_key] = {
      __inherited_from = 'copilot',
      model = model_name,
      display_name = provider_key,
    }
  end

  return providers_table
end

local function repo_map() require('avante.repo_map').show() end

local function toggle_action(action, opts)
  opts = opts or {}
  return function() require('avante.api').toggle[action](opts) end
end

local function get_cond() return ar.get_plugin_cond('avante.nvim', ar.ai.enable) end

return {
  {
    'yetone/avante.nvim',
    cond = function() return ar.get_plugin_cond('avante.nvim', ar.ai.enable) end,
    init = function()
      vim.g.whichkey_add_spec({ '<leader>av', group = 'Avante' })

      ar.add_to_select_menu('ai', {
        ['Avante'] = function()
          ar.create_select_menu('Avante', {
            ['Toggle Chat'] = 'AvanteToggle',
            ['Clear Chat'] = 'AvanteClear',
            ['Switch Provider'] = 'AvanteSwitchProvider',
            ['Refresh Chat'] = 'AvanteRefresh',
          })()
        end,
      })
      ar.augroup('Avante', {
        event = { 'FocusGained' },
        pattern = { '*' },
        command = function(arg)
          local ignored_filetypes =
            { 'Avante', 'AvanteInput', 'AvanteSelectedFiles' }
          local ft = vim.bo[arg.buf].ft
          if not vim.tbl_contains(ignored_filetypes, ft) then return end
          vim.cmd.resize({ '50', mods = { vertical = true } })
        end,
      })
    end,
    -- stylua: ignore
    keys = {
      { '<leader>avo', '<Cmd>AvanteAsk<CR>', desc = 'avante: ask' },
      { '<leader>avb', '<Cmd>AvanteBuild<CR>', desc = 'avante: build' },
      { '<leader>ave', '<Cmd>AvanteEdit<CR>', desc = 'avante: edit' },
      { '<leader>avf', '<Cmd>AvanteFocus<CR>', desc = 'avante: focus' },
      { '<leader>avh', '<Cmd>AvanteHistory<CR>', desc = 'avante: history' },
      { '<leader>avl', '<Cmd>AvanteClear<CR>', desc = 'avante: clear' },
      { '<leader>avm', '<Cmd>AvanteModels<CR>', desc = 'avante: select model' },
      { '<leader>avn', '<Cmd>AvanteChat<CR>', desc = 'avante: chat' },
      { '<leader>avN', '<Cmd>AvanteChatNew<CR>', desc = 'avante: new chat' },
      { '<leader>avp', '<Cmd>AvanteSwitchProvider<CR>', desc = 'avante: switch provider' },
      { '<leader>avr', '<Cmd>AvanteRefresh<CR>', desc = 'avante: refresh' },
      { '<leader>avt', '<Cmd>AvanteToggle<CR>', desc = 'avante: toggle' },
      { '<leader>avq', '<Cmd>AvanteStop<CR>', desc = 'avante: stop' },
      { '<leader>avM', repo_map, desc = 'avante: repo map' },
      { '<leader>avD', toggle_action('debug'), desc = 'avante: toggle debug' },
      { '<leader>avH', toggle_action('hint'), desc = 'avante: toggle hint' },
      { '<leader>avS', toggle_action('suggestion'), desc = 'avante: toggle suggestion' },
    },
    cmd = {
      'AvanteAsk',
      'AvanteBuild',
      'AvanteEdit',
      'AvanteFocus',
      'AvanteHistory',
      'AvanteClear',
      'AvanteModels',
      'AvanteChat',
      'AvanteChatNew',
      'AvanteSwitchProvider',
      'AvanteRefresh',
      'AvanteToggle',
      'AvanteStop',
    },
    opts = function()
      local opts = {
        mode = 'agentic',
        system_prompt = function() return ar_config.ai.prompts.beast_mode end,
        behaviour = { auto_set_keymaps = false },
        hints = { enabled = false },
        selector = {
          provider = 'snacks',
          provider_opts = {},
        },
        input = {
          provider = 'snacks',
          provider_opts = {
            title = 'Avante Input',
            icon = ' ',
          },
        },
        windows = {
          edit = { start_insert = false },
          ask = { start_insert = false },
        },
      }

      local function set_provider(provider, model_name)
        opts.provider = model_name or provider
        -- opts.auto_suggestions_provider = model_name or provider
        -- opts.cursor_applying_provider = model_name or provider
      end

      if models.claude then
        set_provider('claude')
      elseif models.copilot then
        set_provider('copilot', 'copilot-gemini-2.0-flash-001')
        opts.providers = get_copilot_providers()
      elseif models.openai then
        set_provider('openai')
      elseif models.gemini then
        set_provider('gemini')
      end

      ar.highlight.plugin('neogit', {
        theme = {
          ['onedark'] = {
            { AvanteInlineHint = { inherit = 'DiagnosticVirtualTextInfo' } },
          },
        },
      })

      return opts
    end,
    build = 'make',
    dependencies = {
      {
        'HakonHarnes/img-clip.nvim',
        opts = function(_, opts)
          return vim.tbl_extend('force', opts or {}, {
            default = vim.tbl_deep_extend('force', opts.default or {}, {
              embed_image_as_base64 = false,
              prompt_for_file_name = false,
              drag_and_drop = {
                insert_mode = true,
              },
              use_absolute_path = true,
            }),
          })
        end,
      },
    },
  },
  {
    'saghen/blink.cmp',
    optional = true,
    opts = function(_, opts)
      return get_cond()
          and vim.g.blink_add_source(
            { 'avante_commands', 'avante_files', 'avante_mentions' },
            {
              avante_commands = {
                name = 'avante_commands',
                module = 'blink.compat.source',
                score_offset = 90, -- show at a higher priority than lsp
                opts = {},
              },
              avante_files = {
                name = 'avante_files',
                module = 'blink.compat.source',
                score_offset = 100, -- show at a higher priority than lsp
                opts = {},
              },
              avante_mentions = {
                name = 'avante_mentions',
                module = 'blink.compat.source',
                score_offset = 1000, -- show at a higher priority than lsp
                opts = {},
              },
            },
            opts
          )
        or opts
    end,
  },
}
