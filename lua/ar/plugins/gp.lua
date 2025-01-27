local api, fn = vim.api, vim.fn

local templates = {
  unit_tests = 'I have the following code from {{filename}}:\n\n'
    .. '```{{filetype}}\n{{selection}}\n```\n\n'
    .. 'Please respond by writing table driven unit tests for the code above.',
  explain = 'I have the following code from {{filename}}:\n\n'
    .. '```{{filetype}}\n{{selection}}\n```\n\n'
    .. 'Please respond by explaining the code above.',
  code_review = 'I have the following code from {{filename}}:\n\n'
    .. '```{{filetype}}\n{{selection}}\n```\n\n'
    .. 'Please analyze for code smells and suggest improvements.',
}

return {
  'robitx/gp.nvim',
  cond = not ar.plugins.minimal and ar.ai.enable,
  -- stylua: ignore
  keys = {
    -- Chat commands
    { '<c-g>n', '<Cmd>GpChatNew<CR>', desc = 'gp: new chat', mode = { 'n', 'i', 'v' }, },
    { '<c-g>f', '<Cmd>GpChatFinder<CR>', desc = 'gp: find chat', mode = { 'n', 'i' }, },
    { '<c-g><c-g>', '<Cmd>GpChatRespond<CR>', desc = 'gp: respond', mode = { 'n', 'i' }, },
    { '<c-g>d', '<Cmd>GpChatDelete<CR>', desc = 'gp: delete chat', mode = { 'n', 'i' }, },
    { '<c-g>s', '<Cmd>GpChatToggle split<CR>', desc = 'gp: toggle chat in horizontal split' },
    { '<c-g>v', '<Cmd>GpChatToggle vsplit<CR>', desc = 'gp: toggle chat in vertical split' },
    -- Prompt commands
    { '<c-g>r', '<Cmd>GpRewrite<CR>', desc = 'gp: rewrite', mode = { 'n', 'i', 'v' }, },
    { '<c-g>a', '<Cmd>GpAppend<CR>', desc = 'gp: append', mode = { 'n', 'i', 'v' }, },
    { '<c-g>b', '<Cmd>GpPrepend<CR>', desc = 'gp: prepend', mode = { 'n', 'i', 'v' }, },
    { '<c-g>e', '<Cmd>GpEnew<CR>', desc = 'gp: enew', mode = { 'n', 'i', 'v' }, },
    { '<c-g>I', '<Cmd>GpInputRole<CR>', desc = 'gp: input role', mode = { 'n', 'i', 'v' }, },
    { '<c-g>p', '<Cmd>GpPopup<CR>', desc = 'gp: popup', mode = { 'n', 'i', 'v' }, },
    { '<c-g>u', '<Cmd>GpUnitTests<CR>', desc = 'gp: unit tests', mode = { 'n', 'i', 'v' }, },
    { '<c-g>x', '<Cmd>GpExplain<CR>', desc = 'gp: explain', mode = { 'n', 'i', 'v' }, },
    { '<c-g>c', '<Cmd>GpCodeReview<CR>', desc = 'gp: code review', mode = { 'n', 'i', 'v' }, },
    { '<c-g>N', '<Cmd>GpBufferChatNew<CR>', desc = 'gp: buffer chat new', mode = { 'n', 'i', 'v' }, },
    { '<c-g>o', '<Cmd>GpActAs<CR>', desc = 'gp: act as', mode = { 'n', 'i', 'v' }, },
  },
  cmd = {
    'GpChatNew',
    'GpChatFinder',
    'GpChatRespond',
    'GpChatDelete',
    'GpChatToggle',
    'GpRewrite',
    'GpAppend',
    'GpPrepend',
    'GpEnew',
    'GpInputRole',
    'GpPopup',
    'GpUnitTests',
    'GpExplain',
    'GpCodeReview',
    'GpBufferChatNew',
    'GpActAs',
  },
  init = function()
    ar.add_to_menu('ai', {
      ['Gp'] = function()
        ar.create_select_menu('Gp', {
          ['Generate Tests'] = 'GpUnitTests',
          ['Explain Code Code'] = 'GpExplain',
          ['Review Code'] = 'GpCodeReview',
          ['New Buffer Chat'] = 'GpBufferChatNew',
          ['Act As'] = 'GpActAs',
          ['Input Role'] = 'GpInputRole',
          ['New Chat'] = 'GpChatNew',
          ['Toggle Vsplit'] = 'GpChatToggle vsplit',
          ['Find Chat'] = 'GpChatFinder',
          ['Delete Chat'] = 'GpChatDelete',
        })()
      end,
    })
  end,
  opts = function()
    local opts = {
      hooks = {
        UnitTests = function(gp, params)
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.vnew, agent, templates.unit_tests)
        end,
        Explain = function(gp, params)
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.vnew, agent, templates.explain)
        end,
        CodeReview = function(gp, params)
          local agent = gp.get_chat_agent()
          gp.Prompt(
            params,
            gp.Target.enew('markdown'),
            agent,
            templates.code_review
          )
        end,
        BufferChatNew = function(gp, _)
          api.nvim_command('%' .. gp.config.cmd_prefix .. 'ChatNew')
        end,
        InputRole = function(gp, params)
          vim.ui.input({ prompt = 'Input Role:' }, function(input)
            if not input then return end
            local agent = gp.get_chat_agent()
            gp.cmd.ChatNew(params, input, agent)
          end)
        end,

        ActAs = function(gp, params)
          local prompts =
            join_paths(fn.stdpath('data'), 'site', 'prompts', 'prompts.csv')

          if not fn.filereadable(prompts) then
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

            local items = table.concat(fn.readfile(prompts), '\n')
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
                  local agent = gp.get_command_agent()
                  gp.cmd.ChatNew(params, selection.value, agent)
                end)
                return true
              end,
            })
            :find()
        end,
      },
      providers = {},
      agents = {},
    }

    local gp_config = require('gp.config')
    local providers = gp_config.providers
    local default_system_prompt = require('gp.defaults').chat_system_prompt

    --- Setup a model with given provider and agent.
    --- Adds configuration to opts.providers and opts.agents.
    ---@param model_name string: The name of the model from gp_config
    ---@param agent string: The agent name to be configured
    local function setup_model(model_name, agent)
      if not providers[model_name] then return end

      opts.providers[model_name] = {
        endpoint = providers[model_name].endpoint,
        secret = providers[model_name].secret,
      }

      vim.tbl_extend('force', opts.agents, {
        {
          {
            name = agent,
            provider = model_name,
            chat = true,
            command = true,
            model = { model = agent },
            system_prompt = default_system_prompt,
          },
        },
      })
    end

    local models = ar_config.ai.models
    if models.openai then setup_model('openai', 'gpt-4o') end
    if models.copilot then setup_model('copilot', 'ChatCopilot') end
    if models.claude then setup_model('anthropic', 'ChatClaude-3-5-Sonnet') end

    return opts
  end,
}
