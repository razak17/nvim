local separators = ar.ui.icons.separators
local minimal = ar.plugins.minimal

-- https://www.lazyvim.org/plugins/coding#miniai
-- Mini.ai indent text object
-- For "a", it will include the non-whitespace line surrounding the indent block.
-- "a" is line-wise, "i" is character-wise.
local function ai_indent(ai_type)
  local spaces = (' '):rep(vim.o.tabstop)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
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
  local start_line, end_line = 1, vim.fn.line('$')
  if ai_type == 'i' then
    -- Skip first and last blank lines for `i` textobject
    local first_nonblank, last_nonblank =
      vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
    -- Do nothing for buffer with all blanks
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end
    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return {
    from = { line = start_line, col = 1 },
    to = { line = end_line, col = to_col },
  }
end

local function deepcopy_with_prefix(base, prefix, desc_modify)
  local new_table = vim.deepcopy(base)
  for _, v in pairs(new_table) do
    v[1] = prefix .. v[1]
    if desc_modify then v.desc = v.desc:gsub(' including.*', '') end
  end
  return new_table
end

return {
  'echasnovski/mini.hipatterns',
  {
    'echasnovski/mini.icons',
    opts = {},
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
  },
  {
    'echasnovski/mini.indentscope',
    cond = not ar.plugins.minimal and ar.plugins.niceties,
    event = 'BufRead',
    opts = {
      symbol = separators.left_thin_block,
      draw = { delay = 100 },
      -- stylua: ignore
      filetype_exclude = {
        'lazy', 'fzf', 'alpha', 'dbout', 'neo-tree-popup', 'log', 'gitcommit',
        'txt', 'help', 'NvimTree', 'git', 'flutterToolsOutline', 'undotree',
        'markdown', 'norg', 'org', 'orgagenda',
        '', -- for all buffers without a file type
      },
    },
    config = function(_, opts)
      ar.highlight.plugin('mini-indentscope', {
        theme = {
          -- stylua: ignore
          ['onedark'] = {
            { MiniIndentscopeSymbol = { link = 'IndentBlanklineContextChar' } },
            { MiniIndentscopeSymbolOff = { link = 'IndentBlanklineChar' } },
          },
        },
      })
      require('mini.indentscope').setup(opts)
    end,
  },
  { 'echasnovski/mini.misc', opts = {} },
  {
    'echasnovski/mini.bracketed',
    cond = not ar.plugins.minimal,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'echasnovski/mini.animate',
    cond = not ar.plugins.minimal and false,
    event = 'VeryLazy',
    opts = {},
  },
  {
    'echasnovski/mini.trailspace',
    -- stylua: ignore
    keys = {
      { '<leader>wx', '<Cmd>lua MiniTrailspace.trim()<CR>', desc = 'trailspace: trim all', },
      { '<leader>wl', '<Cmd>lua MiniTrailspace.trim_last_lines()<CR>', desc = 'trailspace: trim last lines', },
    },
    opts = {},
  },
  {
    'echasnovski/mini.cursorword',
    cond = false,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'echasnovski/mini.ai',
    cond = not minimal,
    event = { 'VeryLazy' },
    config = function()
      local base = {
        { '<space>', desc = 'Whitespace' },
        { '"', desc = 'Balanced "' },
        { "'", desc = "Balanced '" },
        { '`', desc = 'Balanced `' },
        { '(', desc = 'Balanced (' },
        { ')', desc = 'Balanced ) including white-space' },
        { '>', desc = 'Balanced > including white-space' },
        { '<lt>', desc = 'Balanced <' },
        { ']', desc = 'Balanced ] including white-space' },
        { '[', desc = 'Balanced [' },
        { '}', desc = 'Balanced } including white-space' },
        { '{', desc = 'Balanced {' },
        { '?', desc = 'User Prompt' },
        { '_', desc = 'Underscore' },
        { 'a', desc = 'Argument' },
        { 'b', desc = 'Balanced ), ], }' },
        { 'c', desc = 'Class' },
        { 'd', desc = 'Digit(s)' },
        { 'e', desc = 'Word in CamelCase & snake_case' },
        { 'f', desc = 'Function' },
        { 'g', desc = 'Entire file' },
        { 'i', desc = 'Indent' },
        { 'o', desc = 'Block, conditional, loop' },
        { 'q', desc = 'Quote `, ", \'' },
        { 't', desc = 'Tag' },
        { 'u', desc = 'Use/call function & method' },
        { 'U', desc = 'Use/call without dot in name' },
      }

      local i = deepcopy_with_prefix(base, 'i')
      local a = deepcopy_with_prefix(base, 'a', true)
      local ic = deepcopy_with_prefix(base, 'in')
      local il = deepcopy_with_prefix(base, 'il')
      local ac = deepcopy_with_prefix(base, 'an', true)
      local al = deepcopy_with_prefix(base, 'al', true)

      require('which-key').add({
        mode = { 'o', 'x' },
        { 'a', group = 'around' },
        { 'i', group = 'inside' },
        { 'in', group = 'Inside next textobject' },
        { 'il', group = 'Inside last textobject' },
        { 'an', group = 'Around next textobject' },
        { 'al', group = 'Around last textobject' },
        i,
        a,
        ic,
        il,
        ac,
        al,
      })

      local ai = require('mini.ai')

      require('mini.ai').setup({
        n_lines = 500,
        custom_textobjects = {
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
  },
  {
    'echasnovski/mini.surround',
    keys = {
      'ds',
      { 'ym', desc = 'add surrounding' },
      { 'ys', desc = 'replace surrounding' },
    },
    config = function()
      require('mini.surround').setup({
        mappings = {
          add = 'ym',
          delete = 'ds',
          find = 'yf',
          find_left = 'yF',
          highlight = 'yh',
          replace = 'ys',
          update_n_lines = 'yn',
        },
      })
    end,
  },
  {
    'echasnovski/mini.diff',
    event = { 'BufRead', 'BufNewFile' },
    cond = false,
    opts = {},
  },
  {
    'echasnovski/mini.move',
    cond = not minimal and false,
    event = 'VeryLazy',
    opts = {
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = '<M-h>',
        right = '<M-l>',
        down = '<M-j>',
        up = '<M-k>',
        -- Move current line in Normal mode
        line_left = '<M-h>',
        line_right = '<M-/>',
        line_down = '<M-j>',
        line_up = '<M-k>',
      },
    },
  },
  {
    'echasnovski/mini.pairs',
    cond = minimal,
    event = 'VeryLazy',
    opts = {
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { 'string' },
      skip_unbalanced = true,
      markdown = true,
      mappings = {
        ['`'] = {
          action = 'closeopen',
          pair = '``',
          neigh_pattern = '[^\\`].',
          register = { cr = false },
        },
      },
    },
  },
  {
    'echasnovski/mini.comment',
    cond = false,
    event = 'VeryLazy',
    opts = {
      options = {
        custom_commentstring = function()
          return require('ts_context_commentstring.internal').calculate_commentstring()
            or vim.bo.commentstring
        end,
      },
    },
  },
}
