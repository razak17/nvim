local api, fn = vim.api, vim.fn
local fmt = string.format

local models = ar.config.ai.models

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

local function get_csv_items(prompts)
  local lines = {}

  local items = table.concat(fn.readfile(prompts), '\n')
  for line in string.gmatch(items, '[^\n]+') do
    local act, _prompt = string.match(line, '"(.*)","(.*)"')
    if act ~= 'act' and act ~= nil then
      _prompt = string.gsub(_prompt, '""', '"')
      table.insert(lines, { act = act, prompt = _prompt })
    end
  end
  return lines
end

local function gp_choose_agent()
  local buf = api.nvim_get_current_buf()
  local file_name = api.nvim_buf_get_name(buf)
  local gp = require('gp')
  local is_chat = gp.not_chat(buf, file_name) == nil
  local agents = is_chat and gp._chat_agents or gp._command_agents
  local prompt_title = is_chat and 'Chat Models' or 'Completion Models'
  local options = {}
  if models.claude then table.insert(options, 'ChatClaude') end
  if models.copilot then table.insert(options, 'ChatCopilot') end
  if models.gemini then table.insert(options, 'ChatGemini') end
  if models.openai then table.insert(options, 'ChatGPT') end
  vim.ui.select(options, { prompt = prompt_title }, function(choice)
    if choice == nil then return end
    local selected = vim
      .iter(agents)
      :filter(function(agent) return agent:match(choice) end)
      :map(function(agent)
        if choice ~= 'ChatCopilot' then return agent end
        return string.match(agent, choice .. '%-(.+)')
      end)
      :totable()
    vim.ui.select(selected, { prompt = choice .. ' models' }, function(agent)
      if agent == nil then return end
      if choice == 'ChatCopilot' then agent = fmt('%s-%s', choice, agent) end
      require('gp').cmd.Agent({ args = agent })
    end)
  end)
end

local function gp_finder()
  local gp = require('gp')
  local dir = gp.config.chat_dir
  local delete_shortcut = gp.config.chat_finder_mappings.delete
    or gp.config.chat_shortcut_delete

  local open_chat = function(item, target, toggle)
    if not item or not item.file then return end
    if toggle then
      target = target or gp.resolve_buf_target(gp.config.toggle_target)
    end
    gp.open_buf(item.file, target, gp._toggle_kind.chat, toggle)
  end

  local delete_chat = function(picker, item)
    if not item or not item.file then return end
    local file = item.file
    local refresh = function()
      gp.helpers.delete_file(file)
      picker:refresh()
    end
    if not gp.config.chat_confirm_delete then
      refresh()
      return
    end
    vim.ui.input({ prompt = 'Delete ' .. file .. '? [y/N] ' }, function(input)
      if input and input:lower() == 'y' then refresh() end
    end)
  end

  Snacks.picker.grep({
    cmd = 'rg',
    args = { '--sortr=path' },
    layout = {
      preset = 'wide_with_preview',
      layout = { height = 50, width = 400 },
    },
    formatters = {
      file = {
        filename_first = true,
        filename_only = true,
        truncate = 60,
      },
    },
    dirs = { dir },
    search = 'topic: ',
    -- search = gp.config.chat_finder_pattern,
    title = 'Gp Chat Finder',
    live = true,
    confirm = function(picker, item)
      picker:close()
      open_chat(item, gp.BufTarget.current, false)
    end,
    actions = {
      gp_chat_open = function(picker, item)
        picker:close()
        open_chat(item, gp.BufTarget.current, false)
      end,
      gp_chat_open_popup = function(picker, item)
        picker:close()
        open_chat(item, gp.BufTarget.popup, false)
      end,
      gp_chat_open_split = function(picker, item)
        picker:close()
        open_chat(item, gp.BufTarget.split, false)
      end,
      gp_chat_open_vsplit = function(picker, item)
        picker:close()
        open_chat(item, gp.BufTarget.vsplit, false)
      end,
      gp_chat_open_tab = function(picker, item)
        picker:close()
        open_chat(item, gp.BufTarget.tabnew, false)
      end,
      gp_chat_open_toggle = function(picker, item)
        picker:close()
        open_chat(item, gp.resolve_buf_target(gp.config.toggle_target), true)
      end,
      gp_chat_delete = delete_chat,
    },
    win = {
      input = {
        keys = {
          [delete_shortcut.shortcut] = {
            'gp_chat_delete',
            mode = delete_shortcut.modes,
          },
          ['<C-f>'] = { 'gp_chat_open_popup', mode = { 'n', 'i' } },
          ['<C-x>'] = { 'gp_chat_open_split', mode = { 'n', 'i' } },
          ['<C-v>'] = { 'gp_chat_open_vsplit', mode = { 'n', 'i' } },
          ['<C-t>'] = { 'gp_chat_open_tab', mode = { 'n', 'i' } },
          ['<C-g>t'] = { 'gp_chat_open_toggle', mode = { 'n', 'i' } },
        },
      },
      list = {
        keys = {
          [delete_shortcut.shortcut] = {
            'gp_chat_delete',
            mode = delete_shortcut.modes,
          },
          ['<C-f>'] = { 'gp_chat_open_popup', mode = 'n' },
          ['<C-x>'] = { 'gp_chat_open_split', mode = 'n' },
          ['<C-v>'] = { 'gp_chat_open_vsplit', mode = 'n' },
          ['<C-t>'] = { 'gp_chat_open_tab', mode = 'n' },
          ['<C-g>t'] = { 'gp_chat_open_toggle', mode = 'n' },
        },
      },
    },
  })
end

local mode = { 'n', 'i', 'v' }

return {
  'robitx/gp.nvim',
  event = 'VeryLazy',
  cond = function() return ar.get_plugin_cond('gp.nvim', ar.ai.enable) end,
  -- stylua: ignore
  keys = {
    { '<c-g><c-a>', gp_choose_agent, desc = 'gp: choose model' },
    -- Chat commands
    { '<c-g>n', '<Cmd>GpChatNew<CR>', desc = 'gp: new chat', mode = mode, },
    { '<c-g>f', gp_finder, desc = 'gp: find chat', mode = mode, },
    { '<c-g><CR>', '<Cmd>GpChatRespond<CR>', desc = 'gp: respond', mode = mode, },
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
    { '<c-g>q', '<Cmd>GpStop<CR>', desc = 'gp: stop' },
    { '<c-g>c', '<Cmd>GpCodeReview<CR>', desc = 'gp: code review', mode = mode, },
    { '<c-g>N', '<Cmd>GpBufferChatNew<CR>', desc = 'gp: buffer chat new', mode = mode, },
    { '<c-g>o', '<Cmd>GpActAs<CR>', desc = 'gp: act as', mode = mode, },
  },
  -- stylua: ignore
  cmd = {
    'GpChatNew', 'GpChatFinder', 'GpChatRespond', 'GpChatDelete', 'GpChatToggle',
    'GpRewrite', 'GpAppend', 'GpPrepend', 'GpEnew', 'GpInputRole', 'GpPopup',
    'GpUnitTests', 'GpExplain', 'GpCodeReview', 'GpBufferChatNew', 'GpActAs',
  },
  init = function()
    ar.add_to_select('ai', {
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

          local items = vim
            .iter(get_csv_items(prompts))
            :map(function(p) return { act = p.act, prompt = p.prompt } end)
            :totable()

          local select_opts = {
            prompt = 'Gp Act As:',
            format_item = function(item) return item.act end,
          }

          vim.ui.select(items, select_opts, function(choice)
            if choice == nil then return end
            local agent = gp.get_command_agent()
            gp.cmd.ChatNew(params, choice.prompt, agent)
          end)
        end,
      },
      providers = {
        openai = { disable = not models.openai },
        copilot = { disable = not models.copilot },
        googleai = { disable = not models.gemini },
        anthropic = { disable = not models.claude },
      },
      agents = {
        { name = 'CodeClaude-3-5-Haiku', disable = true },
        { name = 'ChatGPT4o', disable = true },
        { name = 'ChatGPT4o-mini', disable = true },
        { name = 'ChatGPT-o3-mini', disable = true },
      },
      default_chat_agent = 'ChatGPT-gpt-5.4',
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
      for model, config in pairs(ar.ai.copilot_models) do
        setup_model({
          provider = 'copilot',
          name = fmt('ChatCopilot-%s', model),
          model = {
            model = model,
            temperature = config.temp or 1.1,
            top_p = config.top_p or 1,
            max_tokens = config.max_tokens or 128000,
          },
          chat = true,
          command = false,
        })
      end
    end
    if models.gemini then
      local gemini_models = {
        ['gemini-2.0-flash-001'] = {},
      }
      for model, config in pairs(gemini_models) do
        setup_model({
          provider = 'googleai',
          name = fmt('ChatGemini-%s', model),
          model = {
            model = model,
            temperature = config.temp or 1.1,
            top_p = config.top_p or 1,
          },
          chat = true,
          command = false,
        })
      end
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
      for model, config in pairs(ar.ai.openai_models) do
        setup_model({
          provider = 'openai',
          name = fmt('ChatGPT-%s', model),
          model = {
            model = model,
            temperature = config.temp or 1.1,
            top_p = config.top_p or 1,
          },
          chat = true,
          command = false,
        })
      end
    end

    return opts
  end,
}
