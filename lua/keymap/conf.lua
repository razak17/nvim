local npairs = require('nvim-autopairs')
local vim, g, api, fn = vim, vim.g, vim.api, vim.fn
local config = {}

_G.completion_confirm=function()
  if vim.fn.pumvisible() ~= 0  then
    if vim.fn.complete_info()["selected"] ~= -1 then
      vim.fn["compe#confirm"]()
      return npairs.esc("")
    else
      vim.fn.nvim_select_popupmenu_item(0, false, false,{})
      vim.fn["compe#confirm"]()
      return npairs.esc("<c-n>")
    end
  else
    return npairs.check_break_line_char()
  end
end

_G.tab=function()
  if vim.fn.pumvisible() ~= 0  then
    return npairs.esc("<C-n>")
  else
    if vim.fn["vsnip#available"](1) ~= 0 then
      vim.fn.feedkeys(string.format('%c%c%c(vsnip-expand-or-jump)', 0x80, 253, 83))
      return npairs.esc("")
    else
      return npairs.esc("<Tab>")
    end
  end
end

_G.s_tab=function()
  if vim.fn.pumvisible() ~= 0  then
    return npairs.esc("<C-p>")
  else
    if vim.fn["vsnip#jumpable"](-1) ~= 0 then
      vim.fn.feedkeys(string.format('%c%c%c(vsnip-jump-prev)', 0x80, 253, 83))
      return npairs.esc("")
    else
      return npairs.esc("<C-h>")
    end
  end
end

function config.which_key()
  g.which_key_sep = ''
  g.which_key_timeout = 100
  g.which_key_use_floating_win = 0
  g.which_key_display_names = {
    ['<CR>']  = '↵',
    ['<TAB>'] =  '⇆'
  }

  api.nvim_set_keymap('n', "<leader>", ":<c-u> :WhichKey '<space>'<cr>",  {noremap = true, silent = true})
  api.nvim_set_keymap('v', "<leader>", ":<c-u> :WhichKeyVisual '<space>'<cr>",  {noremap = true, silent = true})
  fn['which_key#register']('<space>', 'g:which_key_map')

  g.which_key_map = {
    ["="] = "Balance window",
    ["-"] = "Decrease split by 5",
    ["+"] = "Increase split by 5",
    ["."] = "Open init.vim",
    [","] = "Open init.lua",
    ["/"] = "Comment",
    ["<CR>"] = "Source init.vim",
    d = "Delete current buffer",
    x = "Quit",
    y = "Yank",
    a = {
      name = "+Actions",
      ["/"] = "comment motion default",
      d = "force delete buffer",
      D = "delete all",
      e = "turn off guides",
      E = "delete all buffers and exit",
      f = {
        name = "+Fold",
        l = "under curosr",
        e = "toggle",
        r = "recursive cursor",
        o = "open all",
        x = "close all",
      },
      F = "resize 90%",
      h = "horizontal split",
      n = "no highlight",
      N = "toggle line numbers",
      o = "turn on guides",
      r = "empty registers",
      R = "toggle relative line numbers",
      s = "save and exit",
      T = "terminal",
      u = "undotreeToggle",
      v = "vertical split",
      V = "select all",
      x = "exit",
      Y = "yank all",
      z = "force exit",
    },
    b = {
      name = "+Buffer",
      n = "move next",
      b = "move previous",
      s = "word",
    },
    c = {
      name = "+Command",
      h = {
        name = "+Help",
        w = "word"
      },
      f = "nvim-tree find",
      r = "nvim-tree refresh",
      s = "edit snippet",
      v = "nvim-tree toggle",
    },
    C = {
      name = "+Switch case",
      c =  'shake_case -> camelCase',
      P =  'snake_case -> PascalCase',
      s =  'camelCase/PascalCase -> snake_case',
    },
    e = {
      name = "+Treesitter",
      h = "toggle highlight groups",
      m = "scope incremental",
      n = "init selection",
      v = "toggle virtual text",
    },
    f = {
      name = "+Telescope",
      c = {
        name = "+Command",
        A = "autocmds",
        c = "commands",
        b = "buffers",
        e = "planets",
        f = "builtin",
        h = "help",
        H = "history",
        k = "keymaps",
        l = "loclist",
        o = "old files",
        r = "registers",
        T = "treesitter",
        v = "vim options",
        z = "current file fuzzy find",
      },
      e = {
        name = "+Extensions",
        e = "packer"
      },
      f = "find files",
      l = {
        name = "+Live",
        g = "grep",
        w = "current word",
        e = "prompt",
      },
      r = {
        name = "+Config",
        c = "vimrc"
      },
      v = {
        name = "+Lsp",
        a = "code action",
        r = "references",
        s = {
          name = "+Symbols",
          d = "document",
          w = "workspace",
        }
      },
      g = {
        name = '+Git',
        b = "branches",
        c = "commits",
        C = "bcommits",
        f = "files",
        s = "status",
      }
    },
    F = {
      name = "+Far",
      f = "replace in File",
      r = "replace in Project"
    },
    g = {
      name = "+Git",
      a = 'fetch all',
      b = 'branches',
      A = 'blame',
      c = {
        name = '+Commit',
        a = "amend",
        m = "message",
      },
      C = 'checkout',
      d = 'diff',
      D = 'diff split',
      h = 'diffget',
      i = 'init',
      k = 'diffget',
      l = 'log',
      e = 'push',
      p = 'poosh',
      P = 'pull',
      r = 'remove',
      s = 'status',
    },
    I = {
      name = "+Info",
      c = "check health",
      e = "treesitter",
    },
    l = {
      name = "+Delete buffer",
      d = "all",
      h = "to left",
      x = "all except current",
    },
    L = {
      name = "+Lsp utils",
      i = "info",
      l = "log",
      r = "restart"
    },
    m = {
      name = "+Surround",
      O = "Type => Option<Type>",
      R = "Type => Option<Type, Err>",
      s = "val => Some(val)",
      o = "val => Ok(val)",
      e = "val => Err(val)",
      ['('] = "val => (val)",
      ["'"] = "val => 'val'",
      ['"'] = 'val => "val"',
    },
    P = {
      name = "+Plug",
      c =  'compile',
      C =  'clean',
      i =  'install',
      s =  'sync',
      U =  'update',
    },
    -- r = { name = "+Visual"},
    s = {
      name = "+Tab",
      b = 'previous',
      d = 'close',
      H = 'move left',
      k = 'delete Session',
      K = 'last',
      l = 'next',
      L = 'move right',
      N = 'new',
    },
    S = {
      name = "+Session",
      c = 'close Session',
      d = 'delete Session',
      l = 'load Session',
      s = 'save Session',
    },
    T = {
      name = "+Floaterm",
      e =  'toggle',
      n =  'node',
      N =  'new terminal',
      p =  'python',
      r =  'ranger',
    },
    v = {
      name = "+Code",
      a = "code action",
      D = "preview definition",
      d = {
        name = "+Diagnostics",
        b = "goto previous",
        c = "current line",
        l = "set loc list",
        n = "goto next",
      },
      f = "find the cursor word definition and reference",
      l = {
        name = "+Lsp",
        f = {
          name = "+find",
          w = "workspace symbols"
        },
        h = "show hover doc",
        i = "implementation",
        p = "peek Definition",
        r = "references",
        R = "rename",
        S = "signature",
        s = {
            name = "+Symbols",
            d = "document symbols",
            -- w = "workspace symbols"
        },
        t = "type definition",
      },
      w = {
        name = "+Color",
        m = "pencils"
      },
    },
  }

  -- TODO  (get this to work)
  function WhichKeyReverse()
    local key_maps = vim.g.which_key_map
    key_maps.r = {
      name = "+Line",
    }
    key_maps.r.e = {
      name = "+Line"
    }
    key_maps.r.e.v = "reverse"
    vim.g.which_key_map = key_maps
  end

  _G.WhichKey = {}

  -- TODO  (get this to work)
  WhichKey.SetKeyOnFT=function()
    if vim.fn.mode() == "V" then
      WhichKeyReverse()
    end
  end
end

return config
