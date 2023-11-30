-- local function get_openai_key()
--   if not fn.executable('pass') then
--     vim.notify(
--       'Pass not found. Environment variables may not be loaded',
--       vim.log.levels.ERROR
--     )
--     return
--   end
--   local key = fn.system('pass show api/tokens/openai-work')
--   if not key or vim.v.shell_error ~= 0 then
--     vim.notify('OpenAI key not found', vim.log.levels.ERROR)
--     return
--   end
--   return vim.trim(key)
-- end
--
-- vim.g.openai_api_key = get_openai_key()

return {
  {
    'robitx/gp.nvim',
    cond = rvim.ai.enable and not rvim.plugins.minimal,
    -- stylua: ignore
    keys = {
      -- Chat commands
      { '<c-g>n', '<Cmd>GpChatNew<CR>', desc = 'gp: new chat', mode = { 'n', 'i', 'v' }, },
      { '<c-g>f', '<Cmd>GpChatFinder<CR>', desc = 'gp: find chat', mode = { 'n', 'i' }, },
      { '<c-g><c-g>', '<Cmd>GpChatRespond<CR>', desc = 'gp: respond', mode = { 'n', 'i' }, },
      { '<c-g>d', '<Cmd>GpChatDeleteCR>', desc = 'gp: delete chat', mode = { 'n', 'i' }, },
      -- Prompt commands
      { '<c-g>i', '<Cmd>GpInline<CR>', desc = 'gp: inline', mode = { 'n', 'i' }, },
      { '<c-g>r', '<Cmd>GpRewrite<CR>', desc = 'gp: rewrite', mode = { 'n', 'i', 'v' }, },
      { '<c-g>a', '<Cmd>GpAppend<CR>', desc = 'gp: append', mode = { 'n', 'i', 'v' }, },
      { '<c-g>b', '<Cmd>GpPrepend<CR>', desc = 'gp: prepend', mode = { 'n', 'i', 'v' }, },
      { '<c-g>e', '<Cmd>GpEnew<CR>', desc = 'gp: enew', mode = { 'n', 'i', 'v' }, },
      { '<c-g>p', '<Cmd>GpPopup<CR>', desc = 'gp: popup', mode = { 'n', 'i', 'v' }, },
      { '<c-g>u', '<Cmd>GpUnitTests<CR>', desc = 'gp: unit tests', mode = { 'n', 'i', 'v' }, },
      { '<c-g>x', '<Cmd>GpExplain<CR>', desc = 'gp: explain', mode = { 'n', 'i', 'v' }, },
      { '<c-g>c', '<Cmd>GpCodeReview<CR>', desc = 'gp: code review', mode = { 'n', 'i', 'v' }, },
      { '<c-g>N', '<Cmd>GpBufferChatNew<CR>', desc = 'gp: buffer chat new', mode = { 'n', 'i', 'v' }, },
      { '<c-g>o', '<Cmd>GpActAs<CR>', desc = 'gp: act as', mode = { 'n', 'i', 'v' }, },
      { '<c-g>t', '<Cmd>GpTranslate<CR>', desc = 'gp: translate', mode = { 'n', 'i', 'v' }, },
    },
    cmd = {
      'GpUnitTests',
      'GpExplain',
      'GpCodeReview',
      'GpBufferChatNew',
      'GpActAs',
      'GpTranslate',
    },
    opts = {
      hooks = {
        -- example of adding command which writes unit tests for the selected code
        UnitTests = function(gp, params)
          local template = 'I have the following code from {{filename}}:\n\n'
            .. '```{{filetype}}\n{{selection}}\n```\n\n'
            .. 'Please respond by writing table driven unit tests for the code above.'
          gp.Prompt(
            params,
            gp.Target.enew,
            nil,
            gp.config.command_model,
            template,
            gp.config.command_system_prompt
          )
        end,
        -- example of adding command which explains the selected code
        Explain = function(gp, params)
          local template = 'I have the following code from {{filename}}:\n\n'
            .. '```{{filetype}}\n{{selection}}\n```\n\n'
            .. 'Please respond by explaining the code above.'
          gp.Prompt(
            params,
            gp.Target.popup,
            nil,
            gp.config.command_model,
            template,
            gp.config.chat_system_prompt
          )
        end,
        -- example of usig enew as a function specifying type for the new buffer
        CodeReview = function(gp, params)
          local template = 'I have the following code from {{filename}}:\n\n'
            .. '```{{filetype}}\n{{selection}}\n```\n\n'
            .. 'Please analyze for code smells and suggest improvements.'
          gp.Prompt(
            params,
            gp.Target.enew('markdown'),
            nil,
            gp.config.command_model,
            template,
            gp.config.command_system_prompt
          )
        end,
        -- example of making :%GpChatNew a dedicated command which
        -- opens new chat with the entire current buffer as a context
        BufferChatNew = function(gp, _)
          -- call GpChatNew command in range mode on whole buffer
          vim.api.nvim_command('%' .. gp.config.cmd_prefix .. 'ChatNew')
        end,
        Translate = function(gp, params)
          -- stylua: ignore
          local languages = {
            'Spanish', 'French', 'German', 'Italian', 'Portuguese', 'Dutch',
          }

          local pickers = require('telescope.pickers')
          local finders = require('telescope.finders')
          local actions = require('telescope.actions')
          local action_state = require('telescope.actions.state')

          pickers
            .new(rvim.telescope.minimal_ui(), {
              prompt_title = 'Select target language',
              finder = finders.new_table({
                results = languages,
                entry_maker = function(entry)
                  return { value = entry, ordinal = entry, display = entry }
                end,
              }),
              attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                  actions.close(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  local chat_system_prompt = 'You are a translator, please translate between English and '
                    .. selection.value
                  gp.cmd.ChatNew(
                    params,
                    gp.config.command_model,
                    chat_system_prompt
                  )
                end)
                return true
              end,
            })
            :find()
        end,
        ActAs = function(gp, params)
          local prompts =
            join_paths(vim.fn.stdpath('data'), 'site', 'prompts', 'prompts.csv')

          if not vim.fn.filereadable(prompts) then
            vim.notify('Prompts file not found', vim.log.levels.ERROR)
            return
          end

          local pickers = require('telescope.pickers')
          local finders = require('telescope.finders')
          local actions = require('telescope.actions')
          local action_state = require('telescope.actions.state')
          local conf = require('telescope.config').values
          local previewers = require('telescope.previewers')

          local function defaulter(f, default_opts)
            default_opts = default_opts or {}
            return {
              new = function(opts)
                if conf.preview == false and not opts.preview then
                  return false
                end
                opts.preview = type(opts.preview) ~= 'table' and {}
                  or opts.preview
                if type(conf.preview) == 'table' then
                  for k, v in pairs(conf.preview) do
                    opts.preview[k] = vim.F.if_nil(opts.preview[k], v)
                  end
                end
                return f(opts)
              end,
              __call = function()
                local ok, err = pcall(f(default_opts))
                if not ok then error(debug.traceback(err)) end
              end,
            }
          end

          local display_content_wrapped = defaulter(function(_)
            return previewers.new_buffer_previewer({
              define_preview = function(self, entry, _)
                local width = vim.api.nvim_win_get_width(self.state.winid)
                entry.preview_command(entry, self.state.bufnr, width)
              end,
            })
          end, {})

          local function split(text)
            local t = {}
            for str in string.gmatch(text, '%S+') do
              table.insert(t, str)
            end
            return t
          end

          local function split_string_by_line(text)
            local lines = {}
            for line in (text .. '\n'):gmatch('(.-)\n') do
              table.insert(lines, line)
            end
            return lines
          end

          local function wrap_text_to_table(text, max_line_length)
            local lines = {}

            local textByLines = split_string_by_line(text)
            for _, line in ipairs(textByLines) do
              if #line > max_line_length then
                local tmp_line = ''
                local words = split(line)
                for _, word in ipairs(words) do
                  if #tmp_line + #word + 1 > max_line_length then
                    table.insert(lines, tmp_line)
                    tmp_line = word
                  else
                    tmp_line = tmp_line .. ' ' .. word
                  end
                end
                table.insert(lines, tmp_line)
              else
                table.insert(lines, line)
              end
            end
            return lines
          end

          local function preview_command(entry, bufnr, width)
            vim.api.nvim_buf_call(bufnr, function()
              local preview = wrap_text_to_table(entry.value, width - 5)
              table.insert(preview, 1, '---')
              table.insert(preview, 1, entry.display)
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, preview)
            end)
          end

          local function entry_maker(entry)
            return {
              value = entry.prompt,
              display = entry.act,
              ordinal = entry.act,
              get_command = function(e, _) return { 'bat', e.prompt } end,
              preview_command = preview_command,
            }
          end

          local finder = function()
            local results = {}
            local lines = {}

            local items = table.concat(vim.fn.readfile(prompts), '\n')
            for line in string.gmatch(items, '[^\n]+') do
              local act, _prompt = string.match(line, '"(.*)","(.*)"')
              if act ~= 'act' and act ~= nil then
                _prompt = string.gsub(_prompt, '""', '"')
                table.insert(lines, { act = act, prompt = _prompt })
              end
            end

            for _, line in ipairs(lines) do
              local v = entry_maker(line)
              table.insert(results, v)
            end

            return results
          end

          pickers
            .new({}, {
              prompt_title = 'Prompt',
              results_title = 'Gp Acts As ...',
              sorter = conf.generic_sorter({}),
              previewer = display_content_wrapped.new({}),
              finder = finders.new_table({
                results = finder(),
                entry_maker = function(entry)
                  return {
                    value = entry.value,
                    ordinal = entry.ordinal,
                    display = entry.display,
                    preview_command = entry.preview_command,
                  }
                end,
              }),
              attach_mappings = function(prompt_bufnr, _)
                actions.select_default:replace(function()
                  actions.close(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  gp.cmd.ChatNew(
                    params,
                    gp.config.command_model,
                    selection.value
                  )
                  return true
                end)
                return true
              end,
            })
            :find()
        end,
      },
    },
  },
  {
    'jackMort/ChatGPT.nvim',
    cond = rvim.ai.enable and not rvim.plugins.minimal,
    cmd = {
      'ChatGPT',
      'ChatGPTActAs',
      'ChatGPTRun',
      'ChatGPTEditWithInstructions',
    },
    -- stylua: ignore
    keys = {
      { '<leader>aa', '<cmd>ChatGPTActAs<CR>', desc = 'chatgpt: act as' },
      { '<leader>ae', '<cmd>ChatGPTEditWithInstructions<CR>', desc = 'chatgpt: edit', },
      { '<leader>an', '<cmd>ChatGPT<CR>', desc = 'chatgpt: open' },
    },
    config = function()
      rvim.highlight.plugin('ChatGPT.nvim', {
        theme = {
          ['onedark'] = {
            { ChatGPTSelectedMessage = { link = 'FloatTitle' } },
            -- { ChatGPTTotalTokensBorder = { link = 'FloatTitle' } },
            { ChatGPTCompletion = { link = 'FloatTitle' } },
          },
        },
      })

      local border = {
        style = rvim.ui.border.rectangle,
        highlight = 'FloatBorder',
      }

      require('chatgpt').setup({
        popup_window = {
          border = border,
          win_options = {
            winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
          },
        },
        popup_input = {
          border = border,
          prompt = ' > ',
          submit = '<C-s>',
          win_options = {
            winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
          },
        },
        settings_window = {
          border = border,
          win_options = {
            winhighlight = 'Normal:Normal,FloatTitle:FloatTitle',
          },
        },
        chat = {
          loading_text = 'Cooking ...',
          keymaps = { close = { '<Esc>' } },
          sessions_window = {
            border = border,
            win_options = {
              winhighlight = 'Normal:Normal,FloatTitle:FloatTitle',
            },
          },
        },
      })
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
  },
  {
    'piersolenski/wtf.nvim',
    cond = rvim.lsp.enable and rvim.ai.enable,
    event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      { '<leader>ao', function() require('wtf').ai() end, desc = 'wtf: debug diagnostic with AI', },
      { '<leader>ag', function() require('wtf').search() end, desc = 'wtf: google search diagnostic', },
    },
    opts = {
      popup_type = 'horizontal', -- | 'popup' | 'horizontal' | 'vertical',
      language = 'english',
      search_engine = 'google', -- 'google' | 'duck_duck_go' | 'stack_overflow' | 'github',
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
    },
    dependencies = { 'MunifTanjim/nui.nvim' },
  },
  {
    'moozd/aidoc.nvim',
    cond = not rvim.plugins.minimal,
    keys = {
      {
        mode = 'x',
        '<leader>do',
        '<cmd>lua require("aidoc.api").generate({width = 65})<CR>',
        desc = 'aidoc: generate',
      },
    },
    opts = { keymap = '' },
  },
  {
    'zbirenbaum/copilot.lua',
    cond = rvim.ai.enable and not rvim.plugins.minimal,
    event = 'InsertEnter',
    -- stylua: ignore
    keys = {
      { '<leader>ap', '<Cmd>Copilot panel<CR>', desc = 'copilot: toggle panel', },
      { '<leader>at', '<Cmd>Copilot toggle<CR>', desc = 'copilot: toggle' },
    },
    opts = {
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = not rvim.plugins.overrides.copilot_cmp.enable,
        keymap = {
          accept_word = '<M-w>',
          accept_line = '<M-l>',
          accept = '<M-u>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-\\>',
        },
      },
      filetypes = {
        gitcommit = false,
        NeogitCommitMessage = false,
        DressingInput = false,
        TelescopePrompt = false,
        ['neo-tree-popup'] = false,
        ['dap-repl'] = false,
      },
      server_opts_overrides = {
        settings = {
          advanced = { inlineSuggestCount = 3 },
        },
      },
    },
  },
  {
    'David-Kunz/gen.nvim',
    cond = not rvim.plugins.minimal and rvim.ai.enable,
    cmd = { 'Gen' },
  },
  {
    'razak17/backseat.nvim',
    cmd = { 'Backseat', 'BackseatAsk', 'BackseatClear', 'BackseatClearLine' },
    opts = {
      highlight = { icon = '', group = 'DiagnosticVirtualTextInfo' },
      popup_type = 'popup', -- | 'popup' | 'horizontal' | 'vertical',
      winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
    },
    dependencies = { 'MunifTanjim/nui.nvim' },
  },
}
