return {
  leader_mode = {
    ["="] = "balance window",
    ["."] = "append period",
    [","] = "append comma",
    [";"] = "append semi-colon",
    ["?"] = "search word",
    ["["] = "replace in file",
    ["]"] = "replace in line",
    ["`"] = "wrap backticks",
    ["'"] = "wrap single quotes",
    ['"'] = "wrap double quotes",
    [")"] = "wrap parenthesis",
    ["}"] = "wrap curly braces",
    B = "highlight word",
    x = { "<cmd>q!<cr>", "Quit" },
    y = "yank",
    A = "select all",
    H = { ':h <C-R>=expand("<cword>")<cr><CR>', "help cword" },
    D = "close all",
    S = "edit snippet",
    U = "capitalize word",
    Y = "yank all",
    a = {
      name = "+Actions",
      [";"] = "open terminal",
      d = { ":bdelete!<cr>", "force delete buffer" },
      e = "turn off guides",
      f = {
        name = "+Fold",
        l = "under curosr",
        r = "recursive cursor",
        o = "open all",
        x = "close all",
      },
      F = { ":vertical resize 90<cr>", "vertical resize 90" },
      h = "horizontal split",
      l = "open last buffer",
      L = { ":vertical resize 40<cr>", "vertical resize 30%%" },
      n = "no highlight",
      o = "turn on guides",
      O = { ":<C-f>:resize 10<cr>", "open old commands" },
      R = "empty registers",
      v = "vertical split",
      x = { ":wq!<cr>", "save and exit" },
      s = { ":w!<cr>", "force save" },
      z = { ":q!<cr>", "force exit" },
    },
    b = {
      name = "+Bufferline",
      c = "close all others",
    },
    L = {
      name = "+Rvim",
      [";"] = { ":Dashboard<cr>", "dashboard" },
      ["?"] = "search github",
      c = {
        "<cmd>lua vim.fn.execute('edit ' .. require('user.utils').join_paths(rvim.get_user_dir(), 'config/init.lua'))<cr>",
        "open config file",
      },
      C = { ":checkhealth<cr>", "check health" },
      d = {
        "<cmd>lua vim.fn.execute('edit ' .. require('user.core.log').get_path())<cr>",
        "Open rvim logfile",
      },
      l = {
        "<cmd>lua vim.fn.execute('edit ' .. vim.lsp.get_log_path())<cr>",
        "lsp: open logfile",
      },
      i = { ":LuaCacheProfile<cr>", "impatient: cache profile" },
      M = { ":messages<cr>", "messages" },
      p = { "<cmd>exe 'edit '.stdpath('cache').'/packer.nvim.log'<cr>", "packer: open logfile" },
      s = {
        "<cmd>lua vim.fn.execute('edit ' .. require('user.utils').join_paths(rvim.get_cache_dir(), 'prof.log'))<cr>",
        "open startuptime logs",
      },
      u = { ":UpdateRemotePlugins<cr>", "far: update remote" },
      v = {
        ":e " .. require("user.utils").join_paths(rvim.get_config_dir(), "init.lua<cr>"),
        "open vimrc",
      },
      V = "vim with me",
    },
    n = {
      name = "+New",
      f = "open file in same dir",
      s = "create new file in same dir",
    },
    w = {
      name = "+window",
      h = "change two horizontally split windows to vertical splits",
      v = "change two vertically split windows to horizontal splits",
    },
  },
  visual_mode = {
    ["/"] = "comment",
    ["["] = "replace all",
    ["?"] = "search selection",
    L = {
      name = "+Rvim",
      ["?"] = "search github",
    },
    p = "greatest remap",
    r = "reverse line",
    y = "next greatest",
    l = {
      name = "+Lsp",
    },
  },
  normal_mode = {
    ["]"] = {
      name = "+next",
      ["<space>"] = "add space below",
    },
    ["["] = {
      name = "+prev",
      ["<space>"] = "add space above",
    },
    ["g>"] = "show message history",
    ["gb"] = "lsp: go to buffer",
    ["ds"] = "surround: delete",
    ["z="] = "spell: correct an error",
  },
  plugin = {
    lsp = {
      name = "+Lsp",
      d = { ":Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "buffer diagnostics" },
      i = { ":LspInfo<cr>", "info" },
      I = { ":LspInstallInfo<cr>", "installer info" },
      n = { ":NullLsInfo<cr>", "null-ls info" },
      N = { ":NlspBufConfig<cr>", "nlsp buffer config" },
      p = {
        name = "+Peek",
      },
      L = "toggle loclist",
      s = { ":Telescope lsp_document_symbols<cr>", "document symbols" },
      S = { ":Telescope lsp_dynamic_workspace_symbols<cr>", "workspace symbols" },
      w = { ":Telescope diagnostics<cr>", "workspace diagnostics" },
      W = "toggle qflist",
    },
    dap_ui = {
      toggle = {
        ':lua require"dapui".toggle()',
        "toggle ui",
      },
      inspect = {
        ':lua require"dap.ui.variables".hover()',
        "inspect",
      },
    },
    packer = {
      name = "+Plug",
      c = { ":PlugCompile<cr>", "compile" },
      C = { ":PlugClean<cr>", "clean" },
      d = { ":PlugCompiledDelete<cr>", "delete packer_compiled" },
      u = { ":PlugUpdate<cr>", "update" },
      e = { ":PlugCompiledEdit<cr>", "edit packer_compiled" },
      i = { ":PlugInstall<cr>", "install" },
      r = { ":PlugRecompile<cr>", "recompile" },
      s = { ":PlugSync<cr>", "sync" },
      S = { ":PlugStatus<cr>", "Status" },
    },
    git = {
      name = "+Git",
      b = { ":Telescope git_branches<cr>", "checkout branch" },
      c = { ":Telescope git_commits<cr>", "checkout commit" },
      C = {
        ":Telescope git_bcommits<cr>",
        "Checkout buffer commit",
      },
      d = {
        "<cmd>Gitsigns diffthis HEAD<cr>",
        "view diff",
      },
      f = { ":Telescope git_files<cr>", "files" },
      o = { ":Telescope git_status<cr>", "open changed file" },
    },
    slide = {
      name = "+ASCII",
      A = "add 20 less than signs",
      b = "term",
      B = "bfraktur",
      e = "emboss",
      E = "emboss2",
      f = "bigascii12",
      F = "letter",
      m = "bigmono12",
      v = "asciidoc-view",
      w = "wideterm",
    },
  },
}
