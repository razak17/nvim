local M = {}

local nnoremap = rvim.nnoremap
local fn = vim.fn
local fmt = string.format

local function find(word, ...)
  for _, str in ipairs({ ... }) do
    local match_start, match_end = string.find(word, str)
    if match_start then
      return str, match_start, match_end
    end
  end
end

--- Stolen from nlua.nvim this function attempts to open
--- vim help docs if an api or vim.fn function otherwise it
--- shows the lsp hover doc
--- @param word string
--- @param callback function
local function keyword(word, callback)
  local original_iskeyword = vim.bo.iskeyword

  vim.bo.iskeyword = vim.bo.iskeyword .. ",."
  word = word or fn.expand("<cword>")

  vim.bo.iskeyword = original_iskeyword

  -- TODO: This is a sub par work around, since I usually rename `vim.api` -> `api` or similar
  -- consider maybe using treesitter in the future
  local api_match = find(word, "api", "vim.api")
  local fn_match = find(word, "fn", "vim.fn")
  if api_match then
    local _, finish = string.find(word, api_match .. ".")
    local api_function = string.sub(word, finish + 1)

    vim.cmd(string.format("help %s", api_function))
    return
  elseif fn_match then
    local _, finish = string.find(word, fn_match .. ".")
    if not finish then
      return
    end
    local api_function = string.sub(word, finish + 1) .. "()"

    vim.cmd(string.format("help %s", api_function))
    return
  elseif callback then
    callback()
  else
    vim.lsp.buf.hover()
  end
end

function M.go()
  vim.opt_local.spell = true
  vim.opt_local.expandtab = false
  vim.opt_local.textwidth = 100
  vim.opt_local.softtabstop = 0
  vim.opt_local.tabstop = 4
  vim.opt_local.shiftwidth = 4
  vim.opt_local.smarttab = true
  vim.cmd([[setlocal iskeyword+=-]])

  if not rvim then
    return
  end
  local ok, whichkey = rvim.safe_require("which-key")
  if not ok then
    return
  end

  whichkey.register({
    ["<leader>G"] = {
      name = "+Go",
      b = { "<Cmd>GoBuild<CR>", "build" },
      f = {
        name = "+fix/fill",
        s = { "<Cmd>GoFillStruct<CR>", "fill struct" },
        p = { "<Cmd>GoFixPlurals<CR>", "fix plurals" },
      },
      ie = { "<Cmd>GoIfErr<CR>", "if err" },
    },
  })
end

function M.graphql()
  vim.opt_local.comment = ":#"
  vim.cmd([[setlocal commentstring=//\ %s]])
  vim.cmd([[setlocal iskeyword+=$,@-@]])
  vim.opt_local.formatoptions:remove("t")
end

function M.html()
  -- Set indent width to two spaces
  vim.opt_local.tabstop = 2
  vim.opt_local.shiftwidth = 2
  vim.opt_local.softtabstop = 2

  -- Fix quirkiness in indentation
  vim.opt_local.indentkeys:remove("*<Return>")
  -- setlocal indentkeys-=*<Return>

  -- Make lines longer, and don't break them automatically
  vim.cmd([[setlocal tw=120 linebreak textwidth=0]])

  vim.opt_local.wrap = false
  vim.opt_local.matchpairs:append("<:>")
  -- setlocal matchpairs+=<:>
end

function M.javascript()
  vim.opt_local.spell = true
end

function M.javascriptreact()
  vim.opt_local.textwidth = 100
  vim.cmd([[setlocal commentstring={/*%s*/}]])
end

function M.json()
  vim.opt_local.autoindent = true
  vim.opt_local.conceallevel = 0
  vim.opt_local.expandtab = true
  vim.opt_local.foldmethod = "syntax"
  vim.opt_local.formatoptions = "tcq2l"
  vim.opt_local.shiftwidth = 2
  vim.opt_local.softtabstop = 2
  vim.opt_local.tabstop = 4

  -- json 5 comment
  vim.cmd([[syntax region Comment start="//" end="$" |]])
  vim.cmd([[syntax region Comment start="/\*" end="\*/" |]])
  vim.cmd([[setlocal commentstring=//\ %s]])
end

function M.log()
  vim.opt_local.wrap = false
  vim.opt_local.foldmethod = "manual"
  vim.opt_local.colorcolumn = ""
  vim.opt_local.list = false
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = "yes:2"
end

function M.lua()
  if not rvim then
    return
  end

  -- This allows tpope's vim.surround to surround a text object with a function or conditional
  vim.b[fmt("surround_%s", fn.char2nr("F"))] = "function \1function: \1() \r end"
  vim.b[fmt("surround_%s", fn.char2nr("i"))] = "if \1if: \1 then \r end"

  nnoremap("gK", keyword, { buffer = 0 })
  nnoremap("<leader>so", function()
    vim.cmd("luafile %")
    vim.notify("Sourced " .. fn.expand("%"))
  end, "source current file")

  vim.opt_local.spell = true
  vim.cmd([[setlocal iskeyword+="]])
  vim.opt_local.textwidth = 100
  vim.opt_local.formatoptions:remove("o")
end

function M.python()
  vim.opt_local.spell = true
  vim.cmd([[setlocal iskeyword+="]])
  vim.opt_local.shiftwidth = 4
  vim.opt_local.softtabstop = 4
  vim.opt_local.tabstop = 4
end

function M.rust()
  vim.opt_local.spell = true
end

function M.typescript()
  vim.opt_local.spell = true
  vim.opt_local.textwidth = 100
end

function M.vim()
  vim.opt_local.spell = true
  vim.opt_local.colorcolumn = 120
  vim.cmd([[setlocal iskeyword+=:,#]])
  vim.opt_local.foldmethod = "marker"

  nnoremap("so", ":source % <bar> :lua vim.notify('Sourced ' .. vim.fn.expand('%'))<CR>")

  -- add custom vim-surround mappings for vim
  -- https://github.com/AndrewRadev/Vimfiles/blob/eada7a20dc705729f963348357d7754124d0b183/ftplugin/vim.vim#L3
  vim.b[fmt("surround_%s", fn.char2nr("i"))] = "if \1if: \1 then \r end"
  vim.b[fmt("surround_%s", fn.char2nr("w"))] = "while \1while: \1 \r endwhile"
  vim.b[fmt("surround_%s", fn.char2nr("f"))] = "for \1for: \1 {\r endfor"
  vim.b[fmt("surround_%s", fn.char2nr("e"))] = "foreach \1foreach: \1 \r enforeach"
  vim.b[fmt("surround_%s", fn.char2nr("F"))] = "function! \1function: \1() \r endfunction"
  vim.b[fmt("surround_%s", fn.char2nr("T"))] = "try \r endtry"
end

function M.yaml()
  vim.opt_local.indentkeys:remove("<:>")
  -- setlocal indentkeys-=<:>
  vim.cmd([[setlocal iskeyword+=-,$,#]])

  vim.opt_local.foldlevel = 99
  vim.opt_local.foldlevelstart = 99
end

function M.setup(filetype)
  if filetype == "go" then
    M.go()
  end
  if filetype == "graphql" then
    M.graphql()
  end
  if filetype == "html" then
    M.html()
  end
  if filetype == "javascript" then
    M.javascript()
  end
  if filetype == "javascriptreact" then
    M.javascriptreact()
  end
  if filetype == "json" then
    M.json()
  end
  if filetype == "log" then
    M.log()
  end
  if filetype == "lua" then
    M.lua()
  end
  if filetype == "python" then
    M.python()
  end
  if filetype == "rust" then
    M.rust()
  end
  if filetype == "typescript" then
    M.typescript()
  end
  if filetype == "typescriptreact" then
    M.javascriptreact()
  end
  if filetype == "yaml" then
    M.yaml()
  end
end

return M
