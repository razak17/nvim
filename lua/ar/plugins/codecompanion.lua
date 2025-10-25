vim.g.codecompanion_add_extension = function(extension, opts)
  opts = opts or {}
  opts.extensions =
    vim.tbl_deep_extend('force', opts.extensions or {}, extension)
  return opts
end

local fmt = string.format
local models = ar_config.ai.models
local cmp = ar_config.completion.variant

local function get_cond()
  return ar.get_plugin_cond('codecompanion.nvim', ar.ai.enable)
end

return {
  {
    'olimorris/codecompanion.nvim',
    cond = get_cond,
    -- stylua: ignore
    keys = {
      { '<leader>akk', '<Cmd>CodeCompanion<CR>', desc = 'codecompanion: prompt' },
      { '<leader>ako', '<Cmd>CodeCompanionChat<CR>', desc = 'codecompanion: toggle' },
      { '<leader>aka', '<Cmd>CodeCompanionActions<CR>', desc = 'codecompanion: actions' },
      { '<leader>aka', ':CodeCompanion simplify<CR>', desc = 'codecompanion: simplify' },
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
          cmd = {},
          inline = {},
        },
        memory = {
          opts = {
            chat = {
              enabled = true,
            },
          },
          default = {
            description = 'Common memory files',
            files = {},
          },
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
            show_settings = false,
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
        extensions = {},
        adapters = {
          http = {},
        },
      }

      vim.g.codecompanion_add_extension({
        history = {
          enabled = true,
          opts = {
            keymap = 'gh',
            save_chat_keymap = 'sc',
            auto_save = true,
            expiration_days = 0,
            picker = 'snacks',
            chat_filter = nil, -- function(chat_data) return boolean end
            picker_keymaps = {
              rename = { n = 'r', i = '<M-r>' },
              delete = { n = 'd', i = '<M-d>' },
              duplicate = { n = '<C-y>', i = '<C-y>' },
            },
            auto_generate_title = true,
            title_generation_opts = {
              adapter = nil, -- defaults to current chat adapter
              model = nil, -- defaults to current chat model
              refresh_every_n_prompts = 10,
              max_refreshes = 15,
              format_title = function(original_title) return original_title end,
            },
            continue_last_chat = false,
            delete_on_clearing_chat = false,
            dir_to_save = vim.fn.stdpath('data') .. '/codecompanion-history',
            enable_logging = false,

            summary = {
              create_summary_keymap = 'gcs',
              browse_summaries_keymap = 'gbs',

              generation_opts = {
                adapter = nil, -- defaults to current chat adapter
                model = nil, -- defaults to current chat model
                context_size = 90000, -- max tokens that the model supports
                include_references = true, -- include slash command content
                include_tool_outputs = true, -- include tool execution results
                system_prompt = nil, -- custom system prompt (string or function)
                format_summary = nil, -- custom function to format generated summary e.g to remove <think/> tags from summary
              },
            },

            memory = {
              auto_create_memories_on_summary_generation = true,
              vectorcode_exe = 'vectorcode',
              tool_opts = {
                default_num = 10,
              },
              notify = true,
              index_on_startup = false,
            },
          },
        },
      }, opts)

      if ar.has('mcphub.nvim') then
        vim.g.codecompanion_add_extension({
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
        }, opts)
      end

      if ar.has('VectorCode') then
        vim.g.codecompanion_add_extension({
          vectorcode = {
            ---@type VectorCode.CodeCompanion.ExtensionOpts
            opts = {
              tool_group = {
                -- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
                enabled = true,
                -- a list of extra tools that you want to include in `@vectorcode_toolbox`.
                -- if you use @vectorcode_vectorise, it'll be very handy to include
                -- `file_search` here.
                extras = {},
                collapse = false, -- whether the individual tools should be shown in the chat
              },
              tool_opts = {
                ---@type VectorCode.CodeCompanion.ToolOpts
                ['*'] = {},
                ---@type VectorCode.CodeCompanion.LsToolOpts
                ls = {},
                ---@type VectorCode.CodeCompanion.VectoriseToolOpts
                vectorise = {},
                ---@type VectorCode.CodeCompanion.QueryToolOpts
                query = {
                  max_num = { chunk = -1, document = -1 },
                  default_num = { chunk = 50, document = 10 },
                  include_stderr = false,
                  use_lsp = false,
                  no_duplicate = true,
                  chunk_mode = false,
                  ---@type VectorCode.CodeCompanion.SummariseOpts
                  summarise = {
                    ---@type boolean|(fun(chat: CodeCompanion.Chat, results: VectorCode.QueryResult[]):boolean)|nil
                    enabled = false,
                    adapter = nil,
                    query_augmented = true,
                  },
                },
                files_ls = {},
                files_rm = {},
              },
            },
          },
        }, opts)
      end

      local function set_adapter_and_strategy(adapter, model)
        opts.strategies.chat.adapter = { name = adapter, model = model }
        opts.strategies.inline.adapter = { name = adapter, model = model }
      end

      if models.claude then
        set_adapter_and_strategy('anthropic')
      elseif models.copilot then
        -- https://docs.github.com/en/copilot/reference/ai-models/supported-models
        set_adapter_and_strategy('copilot', 'claude-haiku-4.5')
      elseif models.openai then
        -- https://platform.openai.com/docs/models
        set_adapter_and_strategy('openai', 'gpt-4.1')
      elseif models.gemini then
        set_adapter_and_strategy('gemini', 'gemini-2.5-flash-preview-05-20')
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
                fg = { from = 'CurSearch', attr = 'fg' },
              },
            },
            {
              CodeCompanionChatTool = {
                bg = { from = 'Special', attr = 'fg', alter = -0.1 },
                fg = { from = 'CurSearch', attr = 'fg' },
              },
            },
            {
              CodeCompanionChatVariable = {
                bg = { from = 'Directory', attr = 'fg', alter = 0.1 },
                fg = { from = 'CurSearch', attr = 'fg' },
              },
            },
          },
        },
      })

      require('codecompanion').setup(opts)
    end,
    dependencies = {
      'ravitemer/codecompanion-history.nvim',
      {
        'franco-ruggeri/codecompanion-spinner.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {},
      },
    },
  },
  {
    'saghen/blink.cmp',
    optional = true,
    opts = function(_, opts)
      return get_cond()
          and vim.g.blink_add_source({ 'codecompanion' }, {
            codecompanion = {
              name = '[CC]',
              module = 'codecompanion.providers.completion.blink',
              score_offset = 100,
              transform_items = function(_, items)
                local CompletionItemKind =
                  require('blink.cmp.types').CompletionItemKind
                local kind_idx = #CompletionItemKind + 1
                CompletionItemKind[kind_idx] = 'CodeCompanion'
                for _, item in ipairs(items) do
                  item.kind = kind_idx
                end
                return items
              end,
            },
          }, opts)
        or opts
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    optional = true,
    opts = function(_, opts)
      local codicons = ar.ui.codicons
      vim.g.cmp_add_source(opts, {
        source = {
          name = 'ecolog',
          group_index = 1,
        },
        menu = {
          codecompanion_tools = '[CC]',
          codecompanion_slash_commands = '[CC]',
        },
        format = {
          codecompanion_tools = { icon = codicons.misc.robot_alt },
          codecompanion_slash_commands = { icon = codicons.misc.robot_alt },
        },
      })
    end,
  },
}
