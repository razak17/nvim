local api, fn = vim.api, vim.fn
local minimal = ar.plugins.minimal

-- https://www.lazyvim.org/plugins/coding#miniai
-- Mini.ai indent text object
-- For "a", it will include the non-whitespace line surrounding the indent block.
-- "a" is line-wise, "i" is character-wise.
local function ai_indent(ai_type)
  local spaces = (' '):rep(vim.o.tabstop)
  local lines = api.nvim_buf_get_lines(0, 0, -1, false)
  local indents = {} ---@type {line: number, indent: number, text: string}[]

  for l, line in ipairs(lines) do
    if not line:find('^%s*$') then
      indents[#indents + 1] = {
        line = l,
        indent = #line:gsub('\t', spaces):match('^%s*'),
        text = line,
      }
    end
  end

  local ret = {}

  for i = 1, #indents do
    if i == 1 or indents[i - 1].indent < indents[i].indent then
      local from, to = i, i
      for j = i + 1, #indents do
        if indents[j].indent < indents[i].indent then break end
        to = j
      end
      from = ai_type == 'a' and from > 1 and from - 1 or from
      to = ai_type == 'a' and to < #indents and to + 1 or to
      ret[#ret + 1] = {
        indent = indents[i].indent,
        from = {
          line = indents[from].line,
          col = ai_type == 'a' and 1 or indents[from].indent + 1,
        },
        to = { line = indents[to].line, col = #indents[to].text },
      }
    end
  end

  return ret
end

-- taken from MiniExtra.gen_ai_spec.buffer
local function ai_buffer(ai_type)
  local start_line, end_line = 1, fn.line('$')
  if ai_type == 'i' then
    -- Skip first and last blank lines for `i` textobject
    local first_nonblank, last_nonblank =
      fn.nextnonblank(start_line), fn.prevnonblank(end_line)
    -- Do nothing for buffer with all blanks
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end
    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(fn.getline(end_line):len(), 1)
  return {
    from = { line = start_line, col = 1 },
    to = { line = end_line, col = to_col },
  }
end

return {
  {
    'echasnovski/mini.ai',
    cond = function() return ar.get_plugin_cond('mini.ai', not minimal) end,
    event = { 'VeryLazy' },
    config = function()
      -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/util/mini.lua?plain=1#L64
      local objects = {
        { ' ', desc = 'whitespace' },
        { '"', desc = '" string' },
        { "'", desc = "' string" },
        { '(', desc = '() block' },
        { ')', desc = '() block with ws' },
        { '<', desc = '<> block' },
        { '>', desc = '<> block with ws' },
        { '?', desc = 'user prompt' },
        { 'U', desc = 'use/call without dot' },
        { '[', desc = '[] block' },
        { ']', desc = '[] block with ws' },
        { '_', desc = 'underscore' },
        { '`', desc = '` string' },
        { 'a', desc = 'argument' },
        { 'b', desc = ')]} block' },
        { 'c', desc = 'class' },
        { 'd', desc = 'digit(s)' },
        { 'e', desc = 'CamelCase / snake_case' },
        { 'f', desc = 'function' },
        { 'g', desc = 'entire file' },
        { 'i', desc = 'indent' },
        { 'o', desc = 'block, conditional, loop' },
        { 'q', desc = 'quote `"\'' },
        { 't', desc = 'tag' },
        { 'u', desc = 'use/call' },
        { '{', desc = '{} block' },
        { '}', desc = '{} with ws' },
      }

      local ret = { mode = { 'o', 'x' } }
      for prefix, name in pairs({
        i = 'inside',
        a = 'around',
        il = 'last',
        ['in'] = 'next',
        al = 'last',
        an = 'next',
      }) do
        ret[#ret + 1] = { prefix, group = name }
        for _, obj in ipairs(objects) do
          local desc = obj.desc
          if prefix:sub(1, 1) == 'i' then desc = desc:gsub(' with ws', '') end
          ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
        end
      end

      if ar.is_available('which-key.nvim') then
        require('which-key').add(ret, { notify = false })
      end

      local ai = require('mini.ai')
      local gen_ai_spec = require('mini.extra').gen_ai_spec

      require('mini.ai').setup({
        n_lines = 500,
        custom_textobjects = {
          B = gen_ai_spec.buffer(),
          D = gen_ai_spec.diagnostic(),
          I = gen_ai_spec.indent(),
          L = gen_ai_spec.line(),
          N = gen_ai_spec.number(),
          o = ai.gen_spec.treesitter({ -- code block
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }),
          f = ai.gen_spec.treesitter({
            a = '@function.outer',
            i = '@function.inner',
          }), -- function
          c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }), -- class
          t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
          d = { '%f[%d]%d+' }, -- digits
          e = { -- Word with case
            {
              '%u[%l%d]+%f[^%l%d]',
              '%f[%S][%l%d]+%f[^%l%d]',
              '%f[%P][%l%d]+%f[^%l%d]',
              '^[%l%d]+%f[^%l%d]',
            },
            '^().*()$',
          },
          i = ai_indent, -- indent
          g = ai_buffer, -- buffer
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = '[%w_]' }), -- without dot in function name
        },
        mappings = { around_last = '', inside_last = '' },
      })
    end,
    dependencies = { 'echasnovski/mini.extra' },
  },
}
