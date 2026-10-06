local coding = ar.plugins.coding

if ar.get_plugin_cond('yanky.nvim') then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add({
      'https://github.com/kkharji/sqlite.lua',
      'https://github.com/gbprod/yanky.nvim',
    }, { confirm = false })
    vim.g.whichkey_add_spec({
      '<localleader>y',
      group = 'Yanky',
      mode = { 'n', 'x' },
    })

    ar.highlight.plugin('treehopper', {
      theme = {
        ['onedark'] = { { YankyYanked = { link = 'IncSearch' } } },
      },
    })

    require('yanky').setup({ ring = { storage = 'sqlite' } })

    loaded = true
  end

  ar.pack.cmd('YankyRingHistory', load)

  -- stylua: ignore
  local mappings = {
    { '<C-w>p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: put after' },
    { '<C-w>P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: put before' },
    { '<C-w>yp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: gput after' },
    { '<C-w>yP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: gput before' },
    { '<C-w>yy', '<Plug>(YankyYank)', desc = 'yanky: yank text' },
    { '<C-w>yn', '<Plug>(YankyCycleForward)', desc = 'yanky: cycle forward' },
    { '<C-w>yb', '<Plug>(YankyCycleBackward)', desc = 'yanky: cycle backward' },
  }

  for _, mapping in ipairs(mappings) do
    map(mapping.mode or 'n', mapping[1], function()
      load()
      return mapping[2]
    end, { expr = true, desc = mapping.desc })
  end

  map('n', '<C-w>yo', '<Cmd>YankyRingHistory<CR>', {
    desc = 'yanky: open yank history',
  })
end

if ar.get_plugin_cond('treesj', coding) then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add({
      'https://github.com/Wansmer/treesj',
    }, { confirm = false })

    local opts = {
      use_default_keymaps = false,
      cursor_behavior = 'start',
      max_join_length = math.huge,
    }
    local gww = { both = { fallback = function() vim.cmd('normal! gww') end } }
    local joinWithoutCurly = {
      -- remove curly brackets in js when joining if statements https://github.com/Wansmer/treesj/issues/150
      statement_block = {
        join = {
          format_tree = function(tsj)
            if tsj:tsnode():parent():type() == 'if_statement' then
              tsj:remove_child({ '{', '}' })
              tsj:update_preset({ recursive = false }, 'join')
            else
              require('treesj.langs.javascript').statement_block.join.format_tree(
                tsj
              )
            end
          end,
        },
      },
      -- one-line-if-statement can be split into multi-line https://github.com/Wansmer/treesj/issues/150
      expression_statement = {
        join = { enable = false },
        split = {
          enable = function(tsn) return tsn:parent():type() == 'if_statement' end,
          format_tree = function(tsj) tsj:wrap({ left = '{', right = '}' }) end,
        },
      },
      return_statement = {
        join = { enable = false },
        split = {
          enable = function(tsn) return tsn:parent():type() == 'if_statement' end,
          format_tree = function(tsj) tsj:wrap({ left = '{', right = '}' }) end,
        },
      },
    }
    opts.langs = {
      comment = { source = gww, element = gww }, -- comments in any language
      lua = { comment = gww },
      jsdoc = { source = gww, description = gww },
      javascript = joinWithoutCurly,
      typescript = joinWithoutCurly,
      svelte = {
        ['quoted_attribute_value'] = {
          both = {
            enable = function(tsn) return tsn:parent():type() == 'attribute' end,
          },
          split = {
            format_tree = function(tsj)
              local str = tsj:child('attribute_value')
              local words = vim.split(str:text(), ' ')
              tsj:remove_child('attribute_value')
              for i, word in ipairs(words) do
                tsj:create_child({ text = word }, i + 1)
              end
            end,
          },
          join = {
            format_tree = function(tsj)
              local str = tsj:child('attribute_value')
              local node_text = str:text()
              tsj:remove_child('attribute_value')
              tsj:create_child({ text = node_text }, 2)
            end,
          },
        },
      },
    }
    require('treesj').setup(opts)

    loaded = true
  end

  ar.pack.cmd({ 'TSJSplit', 'TSJJoin' }, load)

  map('n', '<leader>oK', function()
    load()
    require('treesj').toggle()
  end, {
    desc = 'split-join lines',
  })
  map('n', 'gS', function()
    load()
    require('treesj').split()
  end, { desc = 'split to multiple lines' })
  map('n', 'gJ', function()
    load()
    require('treesj').join()
  end, { desc = 'join to single line' })
end
