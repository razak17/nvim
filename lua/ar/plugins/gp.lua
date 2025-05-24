local api, fn = vim.api, vim.fn
local fmt = string.format

local models = ar_config.ai.models

vim.env.GOOGLEAI_API_KEY = vim.env.GEMINI_API_KEY or ''

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

local function gp_choose_agent()
  local buf = api.nvim_get_current_buf()
  local file_name = api.nvim_buf_get_name(buf)
  local is_chat = require('gp').not_chat(buf, file_name) == nil
  local agents = is_chat and require('gp')._chat_agents
    or require('gp')._command_agents
  local prompt_title = is_chat and 'Chat Models' or 'Completion Models'
  vim.ui.select(agents, { prompt = prompt_title }, function(selected)
    if selected ~= nil then require('gp').cmd.Agent({ args = selected }) end
  end)
end

local function gp_finder()
  Snacks.picker.files({
    show_empty = true,
    cwd = fn.stdpath('data') .. '/gp/chats',
    on_show = function() vim.cmd.stopinsert() end,
    -- TODO: Find a way to get newest files first
    -- matcher = { cwd_bonus = true, frecency = true, sort_empty = true },
    transform = function(item) return item end,
    win = {
      input = {
        keys = {
          ['<C-d>'] = 'trash_files',
        },
      },
    },
  })
end

local mode = { 'n', 'i', 'v' }

return {
  'robitx/gp.nvim',
  cond = ar.ai.enable,
  -- stylua: ignore
  keys = {
    { '<c-g><c-a>', gp_choose_agent, desc = 'gp: choose model' },
    -- Chat commands
    { '<c-g>n', '<Cmd>GpChatNew<CR>', desc = 'gp: new chat', mode = mode, },
    { '<c-g>f', gp_finder, desc = 'gp: find chat', mode = mode, },
    { '<c-g><c-g>', '<Cmd>GpChatRespond<CR>', desc = 'gp: respond', mode = mode, },
    { '<c-g>d', '<Cmd>GpChatDelete<CR>', desc = 'gp: delete chat', mode = mode, },
    { '<c-g>s', '<Cmd>GpChatToggle split<CR>', desc = 'gp: toggle chat in horizontal split' },
    { '<c-g>v', '<Cmd>GpChatToggle vsplit<CR>', desc = 'gp: toggle chat in vertical split' },
    -- Prompt commands
    { '<c-g>r', '<Cmd>GpRewrite<CR>', desc = 'gp: rewrite', mode = mode, },
    { '<c-g>a', '<Cmd>GpAppend<CR>', desc = 'gp: append', mode = mode, },
    { '<c-g>b', '<Cmd>GpPrepend<CR>', desc = 'gp: prepend', mode = mode, },
    { '<c-g>e', '<Cmd>GpEnew<CR>', desc = 'gp: enew', mode = mode, },
    { '<c-g>I', '<Cmd>GpInputRole<CR>', desc = 'gp: input role', mode = mode, },
    { '<c-g>p', '<Cmd>GpPopup<CR>', desc = 'gp: popup', mode = mode, },
    { '<c-g>u', '<Cmd>GpUnitTests<CR>', desc = 'gp: unit tests', mode = mode, },
    { '<c-g>x', '<Cmd>GpExplain<CR>', desc = 'gp: explain', mode = mode, },
    { '<c-g>c', '<Cmd>GpCodeReview<CR>', desc = 'gp: code review', mode = mode, },
    { '<c-g>N', '<Cmd>GpBufferChatNew<CR>', desc = 'gp: buffer chat new', mode = mode, },
    { '<c-g>o', '<Cmd>GpActAs<CR>', desc = 'gp: act as', mode = mode, },
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
    ar.add_to_select_menu('ai', {
      ['Gp'] = function()
        ar.create_select_menu('Gp', {
          ['New Chat'] = 'GpChatNew',
          ['Find Chat'] = 'GpChatFinder',
          ['Respond'] = 'GpChatRespond',
          ['Delete Chat'] = 'GpChatDelete',
          ['Toggle'] = 'GpChatToggle',
          ['Rewrite'] = 'GpRewrite',
          ['Append'] = 'GpAppend',
          ['GpPrepend'] = 'GpPrepend',
          ['Input Role'] = 'GpInputRole',
          ['Popup'] = 'GpPopup',
          ['Generate Tests'] = 'GpUnitTests',
          ['Explain Code Code'] = 'GpExplain',
          ['Review Code'] = 'GpCodeReview',
          ['New Buffer Chat'] = 'GpBufferChatNew',
          ['Act As'] = 'GpActAs',
          ['Toggle Vsplit'] = 'GpChatToggle vsplit',
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
      providers = {
        openai = { disable = not models.openai },
        copilot = { disable = not models.copilot },
        googleai = { disable = not models.gemini },
        anthropic = { disable = not models.claude },
      },
      agents = {
        { name = 'ChatClaude-3-Haiku', disable = true },
        { name = 'ChatCopilot', disable = true },
      },
      default_chat_agent = 'ChatGemini',
    }

    local function setup_model(model)
      table.insert(opts.agents, {
        provider = model.provider,
        name = model.name,
        model = model.model,
        chat = model.chat,
        command = model.command,
        system_prompt = require('gp.defaults').chat_system_prompt,
      })
    end

    if models.copilot then
      local copilot_models = {
        ['claude-3.5-sonnet'] = {},
        ['claude-3.7-sonnet'] = {},
        ['claude-3.7-sonnet-thought'] = { max_tokens = 8192 },
        ['gemini-2.0-flash-001'] = {},
        ['gemini-2.5-pro'] = {},
        ['gpt-4o'] = {},
        ['gpt-4o-mini'] = {},
        ['o3-mini'] = {},
        ['o4-mini'] = {},
      }
      for model, config in pairs(copilot_models) do
        setup_model({
          provider = 'copilot',
          name = fmt('ChatCopilot-%s', model),
          model = {
            model = model,
            temperature = config.temp or 1.1,
            top_p = config.top_p or 1,
            max_tokens = config.max_tokens or 4096,
          },
          chat = true,
          command = false,
        })
      end
    end
    if models.gemini then
      setup_model({
        provider = 'googleai',
        name = 'ChatGemini',
        model = { model = 'gemini-2.0-flash-001', temperature = 1.1, top_p = 1 },
        chat = true,
        command = false,
      })
    end
    if models.claude then
      setup_model({
        provider = 'anthropic',
        name = 'ChatClaude-3-5-Sonnet',
        model = {
          model = 'claude-3-5-sonnet-20240620',
          temperature = 0.8,
          top_p = 1,
        },
        chat = true,
        command = false,
      })
    end
    if models.openai then
      setup_model({
        provider = 'openai',
        name = 'ChatGPT4o',
        model = { model = 'gpt-4o', temperature = 1.1, top_p = 1 },
        chat = true,
        command = false,
      })
    end

    return opts
  end,
}
