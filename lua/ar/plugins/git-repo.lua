local minimal = ar.plugins.minimal
local git_cond = require('ar.utils.git').git_cond

return {
  {
    'almo7aya/openingh.nvim',
    cond = function() return git_cond('openingh.nvim') end,
    cmd = { 'OpenInGHFile', 'OpenInGHRepo', 'OpenInGHFileLines' },
    init = function()
      ar.add_to_select_menu('git', {
        ['Open File In GitHub'] = 'OpenInGHFile',
        ['Open Line In GitHub'] = 'OpenInGHFileLines',
        ['Open Repo In GitHub'] = 'OpenInGHRepo',
      })
    end,
    keys = {
      {
        '<leader>gof',
        function()
          vim.cmd('OpenInGHFile')
          vim.notify('opening file in github', 'info', { title = 'openingh' })
        end,
        desc = 'openingh: open file',
      },
      {
        '<leader>gor',
        function()
          vim.cmd('OpenInGHRepo')
          vim.notify('opening repo in github', 'info', { title = 'openingh' })
        end,
        desc = 'openingh: open repo',
      },
      {
        '<leader>gol',
        function()
          vim.cmd('OpenInGHFileLines')
          vim.notify(
            'opening file line in github',
            'info',
            { title = 'openingh' }
          )
        end,
        desc = 'openingh: open to line',
        mode = { 'n', 'x' },
      },
    },
  },
  {
    'https://git.sr.ht/~tomleb/repo-url.nvim',
    cond = function() return ar.get_plugin_cond('repo-url.nvim', not minimal) end,
    -- stylua: ignore
    keys= {
      {  mode = { 'n', 'v' }, '<localleader>gyb', ':lua require("repo-url").copy_blob_url()<CR>', desc= 'copy blob URL' },
      {  mode = { 'n', 'v' }, '<localleader>gob', ':lua require("repo-url").open_blob_url()<CR>', desc= 'open blob URL' },
      {  mode = { 'n', 'v' }, '<leader>gyu', ':lua require("repo-url").copy_blame_url()<CR>', desc= 'copy blame URL' },
      {  mode = { 'n', 'v' }, '<localleader>gou', ':lua require("repo-url").open_blame_url()<CR>', desc= 'open blame URL' },
      {  mode= { 'n', 'v' }, '<localleader>gyh', ':lua require("repo-url").copy_history_url()<CR>', desc= 'copy history URL' },
      {  mode= { 'n', 'v' }, '<localleader>goh', ':lua require("repo-url").open_history_url()<CR>', desc= 'open history URL' },
      {  mode= { 'n', 'v' }, '<localleader>gyr', ':lua require("repo-url").copy_raw_url()<CR>', desc= 'copy raw URL' },
      {  mode= { 'n', 'v' }, '<localleader>gor', ':lua require("repo-url").open_raw_url()<CR>', desc= 'open raw URL' },
    },
    opts = {},
    config = function(_, opts)
      local ru = require('repo-url')

      ru.setup(opts)

      -- For Go's go.mod file, generate permalinks to the dependency under the
      -- cursor and copy to the clipboard or open in the default browser.
      ar.augroup('repo-url', {
        event = { 'FileType' },
        pattern = 'gomod',
        command = function(args)
          map(
            'n',
            '<localleader>gyg',
            function() ru.copy_gomod_tree_url() end,
            { desc = 'copy gomod URL', buffer = args.buf }
          )
          map(
            'n',
            '<localleader>gog',
            function() ru.open_gomod_tree_url() end,
            { desc = 'open gomod URL', buffer = args.buf }
          )
        end,
      }, {
        -- For Go's go.sum file, generate permalinks to the dependency under the
        -- cursor and copy to the clipboard or open in the default browser.
        event = { 'FileType' },
        pattern = 'gosum',
        command = function(args)
          map(
            'n',
            '<localleader>gyg',
            function() ru.copy_gosum_tree_url() end,
            { desc = 'copy gosum URL', buffer = args.buf }
          )
          map(
            'n',
            '<localleader>gog',
            function() ru.open_gosum_tree_url() end,
            { desc = 'open gosum URL', buffer = args.buf }
          )
        end,
      })
    end,
  },
  {
    'linrongbin16/gitlinker.nvim',
    cond = function() return git_cond('gitlinker.nvim') end,
    cmd = { 'GitLink' },
    -- stylua: ignore
    keys = {
      { mode = { 'n', 'v' }, '<leader>gom', '<cmd>GitLink default_branch<cr>', desc = 'gitlinker: copy line URL (main branch)' },
      { mode = { 'n', 'v' }, '<leader>gob', '<cmd>GitLink current_branch<cr>', desc = 'gitlinker: copy line URL (current branch)' },
      { mode = { 'n', 'v' }, '<leader>goc', '<cmd>GitLink<cr>', desc = 'gitlinker: copy line URL (commit)' },
      { mode = { 'v', 'n' }, '<leader>gbm', '<cmd>GitLink! blame_default_branch<cr>', desc = 'gitlinker: github blame (main branch)' },
    },
    opts = {
      router = {
        default_branch = {
          ['^github%.com'] = 'https://github.com/'
            .. '{_A.USER}/'
            .. '{_A.REPO}/blob/'
            .. '{_A.DEFAULT_BRANCH}/' -- always 'master'/'main' branch
            .. '{_A.FILE}?plain=1' -- '?plain=1'
            .. '#L{_A.LSTART}'
            .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
        },
        current_branch = {
          ['^github%.com'] = 'https://github.com/'
            .. '{_A.USER}/'
            .. '{_A.REPO}/blob/'
            .. '{_A.CURRENT_BRANCH}/' -- always current branch
            .. '{_A.FILE}?plain=1' -- '?plain=1'
            .. '#L{_A.LSTART}'
            .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
        },
        blame_default_branch = {
          ['^github%.com'] = 'https://github.com/'
            .. '{_A.USER}/'
            .. '{_A.REPO}/blame/'
            .. '{_A.DEFAULT_BRANCH}/'
            .. '{_A.FILE}?plain=1' -- '?plain=1'
            .. '#L{_A.LSTART}'
            .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
        },
      },
    },
  },
}
