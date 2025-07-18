local fmt = string.format
local models = ar_config.ai.models
local cmp = ar_config.completion.variant

return {
  {
    'olimorris/codecompanion.nvim',
    cond = function()
      return ar.get_plugin_cond('codecompanion.nvim', ar.ai.enable)
    end,
    -- stylua: ignore
    keys = {
      { '<leader>ako', '<Cmd>CodeCompanionChat<CR>', desc = 'codecompanion: toggle' },
      { '<leader>aka', '<Cmd>CodeCompanionActions<CR>', desc = 'codecompanion: actions' },
      { 'ga', '<Cmd>CodeCompanionAdd<CR>', desc = 'codecompanion: add' },
    },
    init = function()
      local visual_cmd = ar.visual_cmd
      vim.g.whichkey_add_spec({ '<leader>ak', group = 'Codecompanion' })
      ar.add_to_select_menu('ai', {
        ['Codecompanion'] = function()
          ar.create_select_menu('Codecompanion', {
            ['Toggle Chat'] = 'CodeCompanionChat Toggle',
            ['Actions'] = 'CodeCompanionActions',
            ['Add Selection'] = function() visual_cmd('CodeCompanionChat Add') end,
            ['Explain'] = function() visual_cmd('CodeCompanion /explain') end,
            ['Fix'] = function() visual_cmd('CodeCompanion /fix') end,
            ['Lsp'] = function() visual_cmd('CodeCompanion /lsp') end,
            ['Tests'] = function() visual_cmd('CodeCompanion /tests') end,
            ['Workspace'] = 'CodeCompanion /workspace',
            ['Code Workflow'] = 'CodeCompanion /cw',
            ['Edit<->Test workflow'] = 'CodeCompanion /et',
          })()
        end,
      })
    end,
    -- stylua: ignore
    cmd = {
      'CodeCompanion', 'CodeCompanionActions', 'CodeCompanionChat',
      'CodeCompanionCmd',
    },
    opts = function()
      local opts = {
        strategies = {
          chat = {
            roles = {
              llm = function(adapter)
                return fmt('  CodeCompanion (%s)', adapter.formatted_name)
              end,
              user = 'me',
            },
            keymaps = {
              close = {
                modes = { n = 'q', i = '<C-c>' },
                index = 2,
                callback = 'keymaps.close',
                description = 'Close Chat',
              },
              stop = {
                modes = { n = '<C-c>' },
                index = 3,
                callback = 'keymaps.stop',
                description = 'Stop Request',
              },
            },
            tools = {
              groups = {
                ['github_pr_workflow'] = {
                  description = 'GitHub operations from issue to PR',
                  tools = {
                    -- File operations
                    'neovim__read_multiple_files',
                    'neovim__write_file',
                    'neovim__edit_file',
                    -- GitHub operations
                    'github__list_issues',
                    'github__get_issue',
                    'github__get_issue_comments',
                    'github__create_issue',
                    'github__create_pull_request',
                    'github__get_file_contents',
                    'github__create_or_update_file',
                    'github__search_code',
                  },
                },
              },
            },
          },
          inline = {},
        },
        display = {
          action_palette = {
            width = 95,
            height = 10,
            prompt = 'Prompt ', -- Prompt used for interactive LLM calls
            provider = 'default', -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
            opts = {
              show_default_actions = true, -- Show the default actions in the action palette?
              show_default_prompt_library = true, -- Show the default prompt library in the action palette?
            },
          },
          chat = {
            auto_scroll = false,
            show_settings = true,
            window = {
              layout = 'vertical', -- float|vertical|horizontal|buffer
            },
          },
          inline = {
            diff = { hl_groups = { added = 'DiffAdd' } },
          },
        },
        opts = {
          log_level = 'DEBUG', -- TRACE|DEBUG|ERROR|INFO
          language = 'English', -- The language used for LLM responses
          system_prompt = function() return ar_config.ai.prompts.beast_mode end,
        },
        extensions = {
          mcphub = {
            callback = 'mcphub.extensions.codecompanion',
            opts = {
              -- MCP Tools
              make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
              show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
              add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
              show_result_in_chat = true, -- Show tool results directly in chat buffer
              -- MCP Resources
              make_vars = true, -- Convert MCP resources to #variables for prompts
              -- MCP Prompts
              make_slash_commands = true, -- Add MCP prompts as /slash commands
            },
          },
        },
        adapters = {},
      }

      local function set_adapter_and_strategy(model_name)
        opts.adapters[model_name] = model_name
        opts.strategies.chat.adapter = model_name
        opts.strategies.inline.adapter = model_name
      end

      if models.claude then
        set_adapter_and_strategy('anthropic')
      elseif models.openai then
        set_adapter_and_strategy('openai')
      elseif models.gemini then
        set_adapter_and_strategy('gemini')
      elseif models.copilot then
        set_adapter_and_strategy('copilot')
      end

      opts.strategies.chat.opts = opts.strategies.chat.opts or {}
      if cmp == 'blink' or cmp == 'cmp' then
        opts.strategies.chat.opts.completion_provider = cmp
      else
        opts.strategies.chat.opts.completion_provider = 'default'
      end
      return opts
    end,
    config = function(_, opts)
      ar.highlight.plugin('CodeCompanion', {
        theme = {
          ['onedark'] = {
            {
              CodeCompanionChatAgent = {
                bg = { from = 'Debug', attr = 'fg', alter = -0.1 },
                fg = { from = 'StatusLine', attr = 'bg' },
              },
            },
            {
              CodeCompanionChatTool = {
                bg = { from = 'Special', attr = 'fg', alter = -0.1 },
                fg = { from = 'StatusLine', attr = 'bg' },
              },
            },
            {
              CodeCompanionChatVariable = {
                bg = { from = 'Directory', attr = 'fg', alter = 0.1 },
                fg = { from = 'StatusLine', attr = 'bg' },
              },
            },
          },
        },
      })

      require('codecompanion').setup(opts)
    end,
    dependencies = {
      {
        'franco-ruggeri/codecompanion-spinner.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {},
      },
    },
  },
}
